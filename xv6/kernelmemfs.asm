
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
8010005a:	bc 60 7e 19 80       	mov    $0x80197e60,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba c4 33 10 80       	mov    $0x801033c4,%edx
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
8010006f:	68 80 a3 10 80       	push   $0x8010a380
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 21 48 00 00       	call   8010489f <initlock>
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
801000bd:	68 87 a3 10 80       	push   $0x8010a387
801000c2:	50                   	push   %eax
801000c3:	e8 7a 46 00 00       	call   80104742 <initsleeplock>
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
80100101:	e8 bb 47 00 00       	call   801048c1 <acquire>
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
80100140:	e8 ea 47 00 00       	call   8010492f <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 27 46 00 00       	call   8010477e <acquiresleep>
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
801001c1:	e8 69 47 00 00       	call   8010492f <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 a6 45 00 00       	call   8010477e <acquiresleep>
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
801001f5:	68 8e a3 10 80       	push   $0x8010a38e
801001fa:	e8 c2 03 00 00       	call   801005c1 <panic>
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
8010022d:	e8 4e a0 00 00       	call   8010a280 <iderw>
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
8010024a:	e8 e1 45 00 00       	call   80104830 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 9f a3 10 80       	push   $0x8010a39f
8010025e:	e8 5e 03 00 00       	call   801005c1 <panic>
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
80100278:	e8 03 a0 00 00       	call   8010a280 <iderw>
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
80100293:	e8 98 45 00 00       	call   80104830 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 a6 a3 10 80       	push   $0x8010a3a6
801002a7:	e8 15 03 00 00       	call   801005c1 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 27 45 00 00       	call   801047e2 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 f6 45 00 00       	call   801048c1 <acquire>
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
80100336:	e8 f4 45 00 00       	call   8010492f <release>
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
801003de:	e8 a3 03 00 00       	call   80100786 <consputc>
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
80100410:	e8 ac 44 00 00       	call   801048c1 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 b0 a3 10 80       	push   $0x8010a3b0
80100427:	e8 95 01 00 00       	call   801005c1 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 47 01 00 00       	jmp    80100585 <cprintf+0x191>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 37 03 00 00       	call   80100786 <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 2a 01 00 00       	jmp    80100581 <cprintf+0x18d>
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
80100475:	0f 84 2c 01 00 00    	je     801005a7 <cprintf+0x1b3>
      break;
    switch(c){
8010047b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010047f:	0f 84 d1 00 00 00    	je     80100556 <cprintf+0x162>
80100485:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100489:	0f 8c d6 00 00 00    	jl     80100565 <cprintf+0x171>
8010048f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100493:	0f 8f cc 00 00 00    	jg     80100565 <cprintf+0x171>
80100499:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
8010049d:	0f 8c c2 00 00 00    	jl     80100565 <cprintf+0x171>
801004a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004a6:	83 e8 63             	sub    $0x63,%eax
801004a9:	83 f8 15             	cmp    $0x15,%eax
801004ac:	0f 87 b3 00 00 00    	ja     80100565 <cprintf+0x171>
801004b2:	8b 04 85 c0 a3 10 80 	mov    -0x7fef5c40(,%eax,4),%eax
801004b9:	ff e0                	jmp    *%eax
    case 'd':
      printint(*argp++, 10, 1);
801004bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004be:	8d 50 04             	lea    0x4(%eax),%edx
801004c1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c4:	8b 00                	mov    (%eax),%eax
801004c6:	83 ec 04             	sub    $0x4,%esp
801004c9:	6a 01                	push   $0x1
801004cb:	6a 0a                	push   $0xa
801004cd:	50                   	push   %eax
801004ce:	e8 75 fe ff ff       	call   80100348 <printint>
801004d3:	83 c4 10             	add    $0x10,%esp
      break;
801004d6:	e9 a6 00 00 00       	jmp    80100581 <cprintf+0x18d>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004de:	8d 50 04             	lea    0x4(%eax),%edx
801004e1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e4:	8b 00                	mov    (%eax),%eax
801004e6:	83 ec 04             	sub    $0x4,%esp
801004e9:	6a 00                	push   $0x0
801004eb:	6a 10                	push   $0x10
801004ed:	50                   	push   %eax
801004ee:	e8 55 fe ff ff       	call   80100348 <printint>
801004f3:	83 c4 10             	add    $0x10,%esp
      break;
801004f6:	e9 86 00 00 00       	jmp    80100581 <cprintf+0x18d>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004fe:	8d 50 04             	lea    0x4(%eax),%edx
80100501:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100504:	8b 00                	mov    (%eax),%eax
80100506:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100509:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050d:	75 22                	jne    80100531 <cprintf+0x13d>
        s = "(null)";
8010050f:	c7 45 ec b9 a3 10 80 	movl   $0x8010a3b9,-0x14(%ebp)
      for(; *s; s++)
80100516:	eb 19                	jmp    80100531 <cprintf+0x13d>
        consputc(*s);
80100518:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051b:	0f b6 00             	movzbl (%eax),%eax
8010051e:	0f be c0             	movsbl %al,%eax
80100521:	83 ec 0c             	sub    $0xc,%esp
80100524:	50                   	push   %eax
80100525:	e8 5c 02 00 00       	call   80100786 <consputc>
8010052a:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100531:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100534:	0f b6 00             	movzbl (%eax),%eax
80100537:	84 c0                	test   %al,%al
80100539:	75 dd                	jne    80100518 <cprintf+0x124>
      break;
8010053b:	eb 44                	jmp    80100581 <cprintf+0x18d>
    // %c 출력
    case 'c':
      consputc(*argp++);
8010053d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100540:	8d 50 04             	lea    0x4(%eax),%edx
80100543:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100546:	8b 00                	mov    (%eax),%eax
80100548:	83 ec 0c             	sub    $0xc,%esp
8010054b:	50                   	push   %eax
8010054c:	e8 35 02 00 00       	call   80100786 <consputc>
80100551:	83 c4 10             	add    $0x10,%esp
      break;
80100554:	eb 2b                	jmp    80100581 <cprintf+0x18d>
    case '%':
      consputc('%');
80100556:	83 ec 0c             	sub    $0xc,%esp
80100559:	6a 25                	push   $0x25
8010055b:	e8 26 02 00 00       	call   80100786 <consputc>
80100560:	83 c4 10             	add    $0x10,%esp
      break;
80100563:	eb 1c                	jmp    80100581 <cprintf+0x18d>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100565:	83 ec 0c             	sub    $0xc,%esp
80100568:	6a 25                	push   $0x25
8010056a:	e8 17 02 00 00       	call   80100786 <consputc>
8010056f:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100572:	83 ec 0c             	sub    $0xc,%esp
80100575:	ff 75 e4             	push   -0x1c(%ebp)
80100578:	e8 09 02 00 00       	call   80100786 <consputc>
8010057d:	83 c4 10             	add    $0x10,%esp
      break;
80100580:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100581:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100585:	8b 55 08             	mov    0x8(%ebp),%edx
80100588:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010058b:	01 d0                	add    %edx,%eax
8010058d:	0f b6 00             	movzbl (%eax),%eax
80100590:	0f be c0             	movsbl %al,%eax
80100593:	25 ff 00 00 00       	and    $0xff,%eax
80100598:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010059b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010059f:	0f 85 99 fe ff ff    	jne    8010043e <cprintf+0x4a>
801005a5:	eb 01                	jmp    801005a8 <cprintf+0x1b4>
      break;
801005a7:	90                   	nop
    }
  }

  if(locking)
801005a8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005ac:	74 10                	je     801005be <cprintf+0x1ca>
    release(&cons.lock);
801005ae:	83 ec 0c             	sub    $0xc,%esp
801005b1:	68 00 1a 19 80       	push   $0x80191a00
801005b6:	e8 74 43 00 00       	call   8010492f <release>
801005bb:	83 c4 10             	add    $0x10,%esp
}
801005be:	90                   	nop
801005bf:	c9                   	leave
801005c0:	c3                   	ret

801005c1 <panic>:

void
panic(char *s)
{
801005c1:	55                   	push   %ebp
801005c2:	89 e5                	mov    %esp,%ebp
801005c4:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005c7:	e8 75 fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005cc:	c7 05 34 1a 19 80 00 	movl   $0x0,0x80191a34
801005d3:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005d6:	e8 7e 25 00 00       	call   80102b59 <lapicid>
801005db:	83 ec 08             	sub    $0x8,%esp
801005de:	50                   	push   %eax
801005df:	68 18 a4 10 80       	push   $0x8010a418
801005e4:	e8 0b fe ff ff       	call   801003f4 <cprintf>
801005e9:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005ec:	8b 45 08             	mov    0x8(%ebp),%eax
801005ef:	83 ec 0c             	sub    $0xc,%esp
801005f2:	50                   	push   %eax
801005f3:	e8 fc fd ff ff       	call   801003f4 <cprintf>
801005f8:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005fb:	83 ec 0c             	sub    $0xc,%esp
801005fe:	68 2c a4 10 80       	push   $0x8010a42c
80100603:	e8 ec fd ff ff       	call   801003f4 <cprintf>
80100608:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
8010060b:	83 ec 08             	sub    $0x8,%esp
8010060e:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100611:	50                   	push   %eax
80100612:	8d 45 08             	lea    0x8(%ebp),%eax
80100615:	50                   	push   %eax
80100616:	e8 66 43 00 00       	call   80104981 <getcallerpcs>
8010061b:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010061e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100625:	eb 1c                	jmp    80100643 <panic+0x82>
    cprintf(" %p", pcs[i]);
80100627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010062a:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010062e:	83 ec 08             	sub    $0x8,%esp
80100631:	50                   	push   %eax
80100632:	68 2e a4 10 80       	push   $0x8010a42e
80100637:	e8 b8 fd ff ff       	call   801003f4 <cprintf>
8010063c:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010063f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100643:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100647:	7e de                	jle    80100627 <panic+0x66>
  panicked = 1; // freeze other CPU
80100649:	c7 05 ec 19 19 80 01 	movl   $0x1,0x801919ec
80100650:	00 00 00 
  for(;;)
80100653:	90                   	nop
80100654:	eb fd                	jmp    80100653 <panic+0x92>

80100656 <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
80100656:	55                   	push   %ebp
80100657:	89 e5                	mov    %esp,%ebp
80100659:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
8010065c:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100660:	75 64                	jne    801006c6 <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
80100662:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100668:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010066d:	89 c8                	mov    %ecx,%eax
8010066f:	f7 ea                	imul   %edx
80100671:	89 d0                	mov    %edx,%eax
80100673:	c1 f8 04             	sar    $0x4,%eax
80100676:	89 ca                	mov    %ecx,%edx
80100678:	c1 fa 1f             	sar    $0x1f,%edx
8010067b:	29 d0                	sub    %edx,%eax
8010067d:	6b d0 35             	imul   $0x35,%eax,%edx
80100680:	89 c8                	mov    %ecx,%eax
80100682:	29 d0                	sub    %edx,%eax
80100684:	ba 35 00 00 00       	mov    $0x35,%edx
80100689:	29 c2                	sub    %eax,%edx
8010068b:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100690:	01 d0                	add    %edx,%eax
80100692:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
80100697:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010069c:	3d 23 04 00 00       	cmp    $0x423,%eax
801006a1:	0f 8e dc 00 00 00    	jle    80100783 <graphic_putc+0x12d>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006a7:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006ac:	83 e8 35             	sub    $0x35,%eax
801006af:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006b4:	83 ec 0c             	sub    $0xc,%esp
801006b7:	6a 1e                	push   $0x1e
801006b9:	e8 2f 7b 00 00       	call   801081ed <graphic_scroll_up>
801006be:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006c1:	e9 bd 00 00 00       	jmp    80100783 <graphic_putc+0x12d>
  }else if(c == BACKSPACE){
801006c6:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006cd:	75 1f                	jne    801006ee <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006cf:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006d4:	85 c0                	test   %eax,%eax
801006d6:	0f 8e a7 00 00 00    	jle    80100783 <graphic_putc+0x12d>
801006dc:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e1:	83 e8 01             	sub    $0x1,%eax
801006e4:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006e9:	e9 95 00 00 00       	jmp    80100783 <graphic_putc+0x12d>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006ee:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006f3:	3d 23 04 00 00       	cmp    $0x423,%eax
801006f8:	7e 1a                	jle    80100714 <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006fa:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006ff:	83 e8 35             	sub    $0x35,%eax
80100702:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
80100707:	83 ec 0c             	sub    $0xc,%esp
8010070a:	6a 1e                	push   $0x1e
8010070c:	e8 dc 7a 00 00       	call   801081ed <graphic_scroll_up>
80100711:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
80100714:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
8010071a:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010071f:	89 c8                	mov    %ecx,%eax
80100721:	f7 ea                	imul   %edx
80100723:	89 d0                	mov    %edx,%eax
80100725:	c1 f8 04             	sar    $0x4,%eax
80100728:	89 ca                	mov    %ecx,%edx
8010072a:	c1 fa 1f             	sar    $0x1f,%edx
8010072d:	29 d0                	sub    %edx,%eax
8010072f:	6b d0 35             	imul   $0x35,%eax,%edx
80100732:	89 c8                	mov    %ecx,%eax
80100734:	29 d0                	sub    %edx,%eax
80100736:	89 c2                	mov    %eax,%edx
80100738:	c1 e2 04             	shl    $0x4,%edx
8010073b:	29 c2                	sub    %eax,%edx
8010073d:	8d 42 02             	lea    0x2(%edx),%eax
80100740:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
80100743:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100749:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010074e:	89 c8                	mov    %ecx,%eax
80100750:	f7 ea                	imul   %edx
80100752:	c1 fa 04             	sar    $0x4,%edx
80100755:	89 c8                	mov    %ecx,%eax
80100757:	c1 f8 1f             	sar    $0x1f,%eax
8010075a:	29 c2                	sub    %eax,%edx
8010075c:	6b c2 1e             	imul   $0x1e,%edx,%eax
8010075f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
80100762:	83 ec 04             	sub    $0x4,%esp
80100765:	ff 75 08             	push   0x8(%ebp)
80100768:	ff 75 f0             	push   -0x10(%ebp)
8010076b:	ff 75 f4             	push   -0xc(%ebp)
8010076e:	e8 e7 7a 00 00       	call   8010825a <font_render>
80100773:	83 c4 10             	add    $0x10,%esp
    console_pos++;
80100776:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010077b:	83 c0 01             	add    $0x1,%eax
8010077e:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
80100783:	90                   	nop
80100784:	c9                   	leave
80100785:	c3                   	ret

80100786 <consputc>:


void
consputc(int c)
{
80100786:	55                   	push   %ebp
80100787:	89 e5                	mov    %esp,%ebp
80100789:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
8010078c:	a1 ec 19 19 80       	mov    0x801919ec,%eax
80100791:	85 c0                	test   %eax,%eax
80100793:	74 08                	je     8010079d <consputc+0x17>
    cli();
80100795:	e8 a7 fb ff ff       	call   80100341 <cli>
    for(;;)
8010079a:	90                   	nop
8010079b:	eb fd                	jmp    8010079a <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
8010079d:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007a4:	75 29                	jne    801007cf <consputc+0x49>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007a6:	83 ec 0c             	sub    $0xc,%esp
801007a9:	6a 08                	push   $0x8
801007ab:	e8 cc 5e 00 00       	call   8010667c <uartputc>
801007b0:	83 c4 10             	add    $0x10,%esp
801007b3:	83 ec 0c             	sub    $0xc,%esp
801007b6:	6a 20                	push   $0x20
801007b8:	e8 bf 5e 00 00       	call   8010667c <uartputc>
801007bd:	83 c4 10             	add    $0x10,%esp
801007c0:	83 ec 0c             	sub    $0xc,%esp
801007c3:	6a 08                	push   $0x8
801007c5:	e8 b2 5e 00 00       	call   8010667c <uartputc>
801007ca:	83 c4 10             	add    $0x10,%esp
801007cd:	eb 0e                	jmp    801007dd <consputc+0x57>
  } else {
    uartputc(c);
801007cf:	83 ec 0c             	sub    $0xc,%esp
801007d2:	ff 75 08             	push   0x8(%ebp)
801007d5:	e8 a2 5e 00 00       	call   8010667c <uartputc>
801007da:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007dd:	83 ec 0c             	sub    $0xc,%esp
801007e0:	ff 75 08             	push   0x8(%ebp)
801007e3:	e8 6e fe ff ff       	call   80100656 <graphic_putc>
801007e8:	83 c4 10             	add    $0x10,%esp
}
801007eb:	90                   	nop
801007ec:	c9                   	leave
801007ed:	c3                   	ret

801007ee <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007ee:	55                   	push   %ebp
801007ef:	89 e5                	mov    %esp,%ebp
801007f1:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007fb:	83 ec 0c             	sub    $0xc,%esp
801007fe:	68 00 1a 19 80       	push   $0x80191a00
80100803:	e8 b9 40 00 00       	call   801048c1 <acquire>
80100808:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
8010080b:	e9 58 01 00 00       	jmp    80100968 <consoleintr+0x17a>
    switch(c){
80100810:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100814:	0f 84 81 00 00 00    	je     8010089b <consoleintr+0xad>
8010081a:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010081e:	0f 8f ac 00 00 00    	jg     801008d0 <consoleintr+0xe2>
80100824:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100828:	74 43                	je     8010086d <consoleintr+0x7f>
8010082a:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010082e:	0f 8f 9c 00 00 00    	jg     801008d0 <consoleintr+0xe2>
80100834:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100838:	74 61                	je     8010089b <consoleintr+0xad>
8010083a:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
8010083e:	0f 85 8c 00 00 00    	jne    801008d0 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100844:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
8010084b:	e9 18 01 00 00       	jmp    80100968 <consoleintr+0x17a>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100850:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100855:	83 e8 01             	sub    $0x1,%eax
80100858:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
8010085d:	83 ec 0c             	sub    $0xc,%esp
80100860:	68 00 01 00 00       	push   $0x100
80100865:	e8 1c ff ff ff       	call   80100786 <consputc>
8010086a:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
8010086d:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100873:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100878:	39 c2                	cmp    %eax,%edx
8010087a:	0f 84 e1 00 00 00    	je     80100961 <consoleintr+0x173>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100880:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100885:	83 e8 01             	sub    $0x1,%eax
80100888:	83 e0 7f             	and    $0x7f,%eax
8010088b:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
      while(input.e != input.w &&
80100892:	3c 0a                	cmp    $0xa,%al
80100894:	75 ba                	jne    80100850 <consoleintr+0x62>
      }
      break;
80100896:	e9 c6 00 00 00       	jmp    80100961 <consoleintr+0x173>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010089b:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
801008a1:	a1 e4 19 19 80       	mov    0x801919e4,%eax
801008a6:	39 c2                	cmp    %eax,%edx
801008a8:	0f 84 b6 00 00 00    	je     80100964 <consoleintr+0x176>
        input.e--;
801008ae:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008b3:	83 e8 01             	sub    $0x1,%eax
801008b6:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
801008bb:	83 ec 0c             	sub    $0xc,%esp
801008be:	68 00 01 00 00       	push   $0x100
801008c3:	e8 be fe ff ff       	call   80100786 <consputc>
801008c8:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008cb:	e9 94 00 00 00       	jmp    80100964 <consoleintr+0x176>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008d4:	0f 84 8d 00 00 00    	je     80100967 <consoleintr+0x179>
801008da:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
801008e0:	a1 e0 19 19 80       	mov    0x801919e0,%eax
801008e5:	29 c2                	sub    %eax,%edx
801008e7:	83 fa 7f             	cmp    $0x7f,%edx
801008ea:	77 7b                	ja     80100967 <consoleintr+0x179>
        c = (c == '\r') ? '\n' : c;
801008ec:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008f0:	74 05                	je     801008f7 <consoleintr+0x109>
801008f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008f5:	eb 05                	jmp    801008fc <consoleintr+0x10e>
801008f7:	b8 0a 00 00 00       	mov    $0xa,%eax
801008fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008ff:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100904:	8d 50 01             	lea    0x1(%eax),%edx
80100907:	89 15 e8 19 19 80    	mov    %edx,0x801919e8
8010090d:	83 e0 7f             	and    $0x7f,%eax
80100910:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100913:	88 90 60 19 19 80    	mov    %dl,-0x7fe6e6a0(%eax)
        consputc(c);
80100919:	83 ec 0c             	sub    $0xc,%esp
8010091c:	ff 75 f0             	push   -0x10(%ebp)
8010091f:	e8 62 fe ff ff       	call   80100786 <consputc>
80100924:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100927:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010092b:	74 18                	je     80100945 <consoleintr+0x157>
8010092d:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100931:	74 12                	je     80100945 <consoleintr+0x157>
80100933:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100939:	a1 e0 19 19 80       	mov    0x801919e0,%eax
8010093e:	83 e8 80             	sub    $0xffffff80,%eax
80100941:	39 c2                	cmp    %eax,%edx
80100943:	75 22                	jne    80100967 <consoleintr+0x179>
          input.w = input.e;
80100945:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010094a:	a3 e4 19 19 80       	mov    %eax,0x801919e4
          wakeup(&input.r);
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 e0 19 19 80       	push   $0x801919e0
80100957:	e8 ef 3a 00 00       	call   8010444b <wakeup>
8010095c:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
8010095f:	eb 06                	jmp    80100967 <consoleintr+0x179>
      break;
80100961:	90                   	nop
80100962:	eb 04                	jmp    80100968 <consoleintr+0x17a>
      break;
80100964:	90                   	nop
80100965:	eb 01                	jmp    80100968 <consoleintr+0x17a>
      break;
80100967:	90                   	nop
  while((c = getc()) >= 0){
80100968:	8b 45 08             	mov    0x8(%ebp),%eax
8010096b:	ff d0                	call   *%eax
8010096d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100970:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100974:	0f 89 96 fe ff ff    	jns    80100810 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
8010097a:	83 ec 0c             	sub    $0xc,%esp
8010097d:	68 00 1a 19 80       	push   $0x80191a00
80100982:	e8 a8 3f 00 00       	call   8010492f <release>
80100987:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010098a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010098e:	74 05                	je     80100995 <consoleintr+0x1a7>
    procdump();  // now call procdump() wo. cons.lock held
80100990:	e8 81 3b 00 00       	call   80104516 <procdump>
  }
}
80100995:	90                   	nop
80100996:	c9                   	leave
80100997:	c3                   	ret

80100998 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100998:	55                   	push   %ebp
80100999:	89 e5                	mov    %esp,%ebp
8010099b:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
8010099e:	83 ec 0c             	sub    $0xc,%esp
801009a1:	ff 75 08             	push   0x8(%ebp)
801009a4:	e8 b9 11 00 00       	call   80101b62 <iunlock>
801009a9:	83 c4 10             	add    $0x10,%esp
  target = n;
801009ac:	8b 45 10             	mov    0x10(%ebp),%eax
801009af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009b2:	83 ec 0c             	sub    $0xc,%esp
801009b5:	68 00 1a 19 80       	push   $0x80191a00
801009ba:	e8 02 3f 00 00       	call   801048c1 <acquire>
801009bf:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009c2:	e9 ab 00 00 00       	jmp    80100a72 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009c7:	e8 c1 30 00 00       	call   80103a8d <myproc>
801009cc:	8b 40 24             	mov    0x24(%eax),%eax
801009cf:	85 c0                	test   %eax,%eax
801009d1:	74 28                	je     801009fb <consoleread+0x63>
        release(&cons.lock);
801009d3:	83 ec 0c             	sub    $0xc,%esp
801009d6:	68 00 1a 19 80       	push   $0x80191a00
801009db:	e8 4f 3f 00 00       	call   8010492f <release>
801009e0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009e3:	83 ec 0c             	sub    $0xc,%esp
801009e6:	ff 75 08             	push   0x8(%ebp)
801009e9:	e8 61 10 00 00       	call   80101a4f <ilock>
801009ee:	83 c4 10             	add    $0x10,%esp
        return -1;
801009f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009f6:	e9 ab 00 00 00       	jmp    80100aa6 <consoleread+0x10e>
      }
      sleep(&input.r, &cons.lock);
801009fb:	83 ec 08             	sub    $0x8,%esp
801009fe:	68 00 1a 19 80       	push   $0x80191a00
80100a03:	68 e0 19 19 80       	push   $0x801919e0
80100a08:	e8 57 39 00 00       	call   80104364 <sleep>
80100a0d:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a10:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
80100a16:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100a1b:	39 c2                	cmp    %eax,%edx
80100a1d:	74 a8                	je     801009c7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a1f:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a24:	8d 50 01             	lea    0x1(%eax),%edx
80100a27:	89 15 e0 19 19 80    	mov    %edx,0x801919e0
80100a2d:	83 e0 7f             	and    $0x7f,%eax
80100a30:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
80100a37:	0f be c0             	movsbl %al,%eax
80100a3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a3d:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a41:	75 17                	jne    80100a5a <consoleread+0xc2>
      if(n < target){
80100a43:	8b 45 10             	mov    0x10(%ebp),%eax
80100a46:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a49:	73 2f                	jae    80100a7a <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a4b:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a50:	83 e8 01             	sub    $0x1,%eax
80100a53:	a3 e0 19 19 80       	mov    %eax,0x801919e0
      }
      break;
80100a58:	eb 20                	jmp    80100a7a <consoleread+0xe2>
    }
    *dst++ = c;
80100a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a5d:	8d 50 01             	lea    0x1(%eax),%edx
80100a60:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a63:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a66:	88 10                	mov    %dl,(%eax)
    --n;
80100a68:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a6c:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a70:	74 0b                	je     80100a7d <consoleread+0xe5>
  while(n > 0){
80100a72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a76:	7f 98                	jg     80100a10 <consoleread+0x78>
80100a78:	eb 04                	jmp    80100a7e <consoleread+0xe6>
      break;
80100a7a:	90                   	nop
80100a7b:	eb 01                	jmp    80100a7e <consoleread+0xe6>
      break;
80100a7d:	90                   	nop
  }
  release(&cons.lock);
80100a7e:	83 ec 0c             	sub    $0xc,%esp
80100a81:	68 00 1a 19 80       	push   $0x80191a00
80100a86:	e8 a4 3e 00 00       	call   8010492f <release>
80100a8b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a8e:	83 ec 0c             	sub    $0xc,%esp
80100a91:	ff 75 08             	push   0x8(%ebp)
80100a94:	e8 b6 0f 00 00       	call   80101a4f <ilock>
80100a99:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a9c:	8b 45 10             	mov    0x10(%ebp),%eax
80100a9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100aa2:	29 c2                	sub    %eax,%edx
80100aa4:	89 d0                	mov    %edx,%eax
}
80100aa6:	c9                   	leave
80100aa7:	c3                   	ret

80100aa8 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100aa8:	55                   	push   %ebp
80100aa9:	89 e5                	mov    %esp,%ebp
80100aab:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100aae:	83 ec 0c             	sub    $0xc,%esp
80100ab1:	ff 75 08             	push   0x8(%ebp)
80100ab4:	e8 a9 10 00 00       	call   80101b62 <iunlock>
80100ab9:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100abc:	83 ec 0c             	sub    $0xc,%esp
80100abf:	68 00 1a 19 80       	push   $0x80191a00
80100ac4:	e8 f8 3d 00 00       	call   801048c1 <acquire>
80100ac9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100acc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100ad3:	eb 21                	jmp    80100af6 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100ad5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100adb:	01 d0                	add    %edx,%eax
80100add:	0f b6 00             	movzbl (%eax),%eax
80100ae0:	0f be c0             	movsbl %al,%eax
80100ae3:	0f b6 c0             	movzbl %al,%eax
80100ae6:	83 ec 0c             	sub    $0xc,%esp
80100ae9:	50                   	push   %eax
80100aea:	e8 97 fc ff ff       	call   80100786 <consputc>
80100aef:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100af2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100af9:	3b 45 10             	cmp    0x10(%ebp),%eax
80100afc:	7c d7                	jl     80100ad5 <consolewrite+0x2d>
  release(&cons.lock);
80100afe:	83 ec 0c             	sub    $0xc,%esp
80100b01:	68 00 1a 19 80       	push   $0x80191a00
80100b06:	e8 24 3e 00 00       	call   8010492f <release>
80100b0b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b0e:	83 ec 0c             	sub    $0xc,%esp
80100b11:	ff 75 08             	push   0x8(%ebp)
80100b14:	e8 36 0f 00 00       	call   80101a4f <ilock>
80100b19:	83 c4 10             	add    $0x10,%esp

  return n;
80100b1c:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b1f:	c9                   	leave
80100b20:	c3                   	ret

80100b21 <consoleinit>:

void
consoleinit(void)
{
80100b21:	55                   	push   %ebp
80100b22:	89 e5                	mov    %esp,%ebp
80100b24:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b27:	c7 05 ec 19 19 80 00 	movl   $0x0,0x801919ec
80100b2e:	00 00 00 
  initlock(&cons.lock, "console");
80100b31:	83 ec 08             	sub    $0x8,%esp
80100b34:	68 32 a4 10 80       	push   $0x8010a432
80100b39:	68 00 1a 19 80       	push   $0x80191a00
80100b3e:	e8 5c 3d 00 00       	call   8010489f <initlock>
80100b43:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b46:	c7 05 4c 1a 19 80 a8 	movl   $0x80100aa8,0x80191a4c
80100b4d:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b50:	c7 05 48 1a 19 80 98 	movl   $0x80100998,0x80191a48
80100b57:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b5a:	c7 45 f4 3a a4 10 80 	movl   $0x8010a43a,-0xc(%ebp)
80100b61:	eb 19                	jmp    80100b7c <consoleinit+0x5b>
    graphic_putc(*p);
80100b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b66:	0f b6 00             	movzbl (%eax),%eax
80100b69:	0f be c0             	movsbl %al,%eax
80100b6c:	83 ec 0c             	sub    $0xc,%esp
80100b6f:	50                   	push   %eax
80100b70:	e8 e1 fa ff ff       	call   80100656 <graphic_putc>
80100b75:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b7f:	0f b6 00             	movzbl (%eax),%eax
80100b82:	84 c0                	test   %al,%al
80100b84:	75 dd                	jne    80100b63 <consoleinit+0x42>
  
  cons.locking = 1;
80100b86:	c7 05 34 1a 19 80 01 	movl   $0x1,0x80191a34
80100b8d:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b90:	83 ec 08             	sub    $0x8,%esp
80100b93:	6a 00                	push   $0x0
80100b95:	6a 01                	push   $0x1
80100b97:	e8 f7 1a 00 00       	call   80102693 <ioapicenable>
80100b9c:	83 c4 10             	add    $0x10,%esp
80100b9f:	90                   	nop
80100ba0:	c9                   	leave
80100ba1:	c3                   	ret

80100ba2 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100ba2:	55                   	push   %ebp
80100ba3:	89 e5                	mov    %esp,%ebp
80100ba5:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100bab:	e8 dd 2e 00 00       	call   80103a8d <myproc>
80100bb0:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bb3:	e8 e3 24 00 00       	call   8010309b <begin_op>

  if((ip = namei(path)) == 0){
80100bb8:	83 ec 0c             	sub    $0xc,%esp
80100bbb:	ff 75 08             	push   0x8(%ebp)
80100bbe:	e8 bf 19 00 00       	call   80102582 <namei>
80100bc3:	83 c4 10             	add    $0x10,%esp
80100bc6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bc9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bcd:	75 1f                	jne    80100bee <exec+0x4c>
    end_op();
80100bcf:	e8 53 25 00 00       	call   80103127 <end_op>
    cprintf("exec: fail\n");
80100bd4:	83 ec 0c             	sub    $0xc,%esp
80100bd7:	68 50 a4 10 80       	push   $0x8010a450
80100bdc:	e8 13 f8 ff ff       	call   801003f4 <cprintf>
80100be1:	83 c4 10             	add    $0x10,%esp
    return -1;
80100be4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100be9:	e9 36 04 00 00       	jmp    80101024 <exec+0x482>
  }
  ilock(ip);
80100bee:	83 ec 0c             	sub    $0xc,%esp
80100bf1:	ff 75 d8             	push   -0x28(%ebp)
80100bf4:	e8 56 0e 00 00       	call   80101a4f <ilock>
80100bf9:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bfc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c03:	6a 34                	push   $0x34
80100c05:	6a 00                	push   $0x0
80100c07:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c0d:	50                   	push   %eax
80100c0e:	ff 75 d8             	push   -0x28(%ebp)
80100c11:	e8 25 13 00 00       	call   80101f3b <readi>
80100c16:	83 c4 10             	add    $0x10,%esp
80100c19:	83 f8 34             	cmp    $0x34,%eax
80100c1c:	0f 85 9b 03 00 00    	jne    80100fbd <exec+0x41b>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c22:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c28:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c2d:	0f 85 8d 03 00 00    	jne    80100fc0 <exec+0x41e>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c33:	e8 40 6a 00 00       	call   80107678 <setupkvm>
80100c38:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c3b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c3f:	0f 84 7e 03 00 00    	je     80100fc3 <exec+0x421>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c45:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c4c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c53:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c59:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c5c:	e9 de 00 00 00       	jmp    80100d3f <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c61:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c64:	6a 20                	push   $0x20
80100c66:	50                   	push   %eax
80100c67:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c6d:	50                   	push   %eax
80100c6e:	ff 75 d8             	push   -0x28(%ebp)
80100c71:	e8 c5 12 00 00       	call   80101f3b <readi>
80100c76:	83 c4 10             	add    $0x10,%esp
80100c79:	83 f8 20             	cmp    $0x20,%eax
80100c7c:	0f 85 44 03 00 00    	jne    80100fc6 <exec+0x424>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c82:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c88:	83 f8 01             	cmp    $0x1,%eax
80100c8b:	0f 85 a0 00 00 00    	jne    80100d31 <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c91:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c97:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c9d:	39 c2                	cmp    %eax,%edx
80100c9f:	0f 82 24 03 00 00    	jb     80100fc9 <exec+0x427>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100ca5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100cab:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cb1:	01 c2                	add    %eax,%edx
80100cb3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cb9:	39 c2                	cmp    %eax,%edx
80100cbb:	0f 82 0b 03 00 00    	jb     80100fcc <exec+0x42a>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cc1:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100cc7:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ccd:	01 d0                	add    %edx,%eax
80100ccf:	83 ec 04             	sub    $0x4,%esp
80100cd2:	50                   	push   %eax
80100cd3:	ff 75 e0             	push   -0x20(%ebp)
80100cd6:	ff 75 d4             	push   -0x2c(%ebp)
80100cd9:	e8 94 6d 00 00       	call   80107a72 <allocuvm>
80100cde:	83 c4 10             	add    $0x10,%esp
80100ce1:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ce4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ce8:	0f 84 e1 02 00 00    	je     80100fcf <exec+0x42d>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100cee:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cf4:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cf9:	85 c0                	test   %eax,%eax
80100cfb:	0f 85 d1 02 00 00    	jne    80100fd2 <exec+0x430>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d01:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d07:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d0d:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100d13:	83 ec 0c             	sub    $0xc,%esp
80100d16:	52                   	push   %edx
80100d17:	50                   	push   %eax
80100d18:	ff 75 d8             	push   -0x28(%ebp)
80100d1b:	51                   	push   %ecx
80100d1c:	ff 75 d4             	push   -0x2c(%ebp)
80100d1f:	e8 81 6c 00 00       	call   801079a5 <loaduvm>
80100d24:	83 c4 20             	add    $0x20,%esp
80100d27:	85 c0                	test   %eax,%eax
80100d29:	0f 88 a6 02 00 00    	js     80100fd5 <exec+0x433>
80100d2f:	eb 01                	jmp    80100d32 <exec+0x190>
      continue;
80100d31:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d32:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d36:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d39:	83 c0 20             	add    $0x20,%eax
80100d3c:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d3f:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d46:	0f b7 c0             	movzwl %ax,%eax
80100d49:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d4c:	0f 8c 0f ff ff ff    	jl     80100c61 <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d52:	83 ec 0c             	sub    $0xc,%esp
80100d55:	ff 75 d8             	push   -0x28(%ebp)
80100d58:	e8 23 0f 00 00       	call   80101c80 <iunlockput>
80100d5d:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d60:	e8 c2 23 00 00       	call   80103127 <end_op>
  ip = 0;
80100d65:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  // sz를 커널 베이스로 이동 페이지를 할당해야 하기 때문에 그 크기만큼 빼줌
  // 2*PGSIZE로 하면 페이지의 끝 주소가 커널 베이스가 되기 때문에 한 단계 더 내린다.
  // Pagefault가 발생했을 때 스택의 바로 아래인지를 판단하기 위해 gaurd page도 할당한다.
  cprintf("[exec] sz %x curproc pid %d\n",sz,curproc->pid);
80100d6c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100d6f:	8b 40 10             	mov    0x10(%eax),%eax
80100d72:	83 ec 04             	sub    $0x4,%esp
80100d75:	50                   	push   %eax
80100d76:	ff 75 e0             	push   -0x20(%ebp)
80100d79:	68 5c a4 10 80       	push   $0x8010a45c
80100d7e:	e8 71 f6 ff ff       	call   801003f4 <cprintf>
80100d83:	83 c4 10             	add    $0x10,%esp
  sz = PGROUNDDOWN(KERNBASE - 2*PGSIZE);
80100d86:	c7 45 e0 00 e0 ff 7f 	movl   $0x7fffe000,-0x20(%ebp)
  // 커널 베이스에서 PGSIZE만큼 할당
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
80100d8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d90:	05 00 10 00 00       	add    $0x1000,%eax
80100d95:	83 ec 04             	sub    $0x4,%esp
80100d98:	50                   	push   %eax
80100d99:	ff 75 e0             	push   -0x20(%ebp)
80100d9c:	ff 75 d4             	push   -0x2c(%ebp)
80100d9f:	e8 ce 6c 00 00       	call   80107a72 <allocuvm>
80100da4:	83 c4 10             	add    $0x10,%esp
80100da7:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100daa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dae:	0f 84 24 02 00 00    	je     80100fd8 <exec+0x436>
    goto bad;
  // 스택 포인터를 sz로
  sp = sz;
80100db4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100db7:	89 45 dc             	mov    %eax,-0x24(%ebp)
  // 0xb98은 text, data영역의 윗 부분
  // sz는 사용 중인 유저 공간을 나타내주는데 스택을 kernbase로 옮겨서
  // 스택 외의 코드까지만 sz로 변경
  sz = PGROUNDUP(0xb98) /*+ 2*PGSIZE*/;
80100dba:	c7 45 e0 00 10 00 00 	movl   $0x1000,-0x20(%ebp)
  cprintf("[exec] sz %x curproc pid %d\n",sz,curproc->pid);
80100dc1:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100dc4:	8b 40 10             	mov    0x10(%eax),%eax
80100dc7:	83 ec 04             	sub    $0x4,%esp
80100dca:	50                   	push   %eax
80100dcb:	ff 75 e0             	push   -0x20(%ebp)
80100dce:	68 5c a4 10 80       	push   $0x8010a45c
80100dd3:	e8 1c f6 ff ff       	call   801003f4 <cprintf>
80100dd8:	83 c4 10             	add    $0x10,%esp


  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100ddb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100de2:	e9 96 00 00 00       	jmp    80100e7d <exec+0x2db>
    if(argc >= MAXARG)
80100de7:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100deb:	0f 87 ea 01 00 00    	ja     80100fdb <exec+0x439>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100df1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dfe:	01 d0                	add    %edx,%eax
80100e00:	8b 00                	mov    (%eax),%eax
80100e02:	83 ec 0c             	sub    $0xc,%esp
80100e05:	50                   	push   %eax
80100e06:	e8 7a 3f 00 00       	call   80104d85 <strlen>
80100e0b:	83 c4 10             	add    $0x10,%esp
80100e0e:	89 c2                	mov    %eax,%edx
80100e10:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e13:	29 d0                	sub    %edx,%eax
80100e15:	83 e8 01             	sub    $0x1,%eax
80100e18:	83 e0 fc             	and    $0xfffffffc,%eax
80100e1b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e21:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e28:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e2b:	01 d0                	add    %edx,%eax
80100e2d:	8b 00                	mov    (%eax),%eax
80100e2f:	83 ec 0c             	sub    $0xc,%esp
80100e32:	50                   	push   %eax
80100e33:	e8 4d 3f 00 00       	call   80104d85 <strlen>
80100e38:	83 c4 10             	add    $0x10,%esp
80100e3b:	83 c0 01             	add    $0x1,%eax
80100e3e:	89 c1                	mov    %eax,%ecx
80100e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e4d:	01 d0                	add    %edx,%eax
80100e4f:	8b 00                	mov    (%eax),%eax
80100e51:	51                   	push   %ecx
80100e52:	50                   	push   %eax
80100e53:	ff 75 dc             	push   -0x24(%ebp)
80100e56:	ff 75 d4             	push   -0x2c(%ebp)
80100e59:	e8 00 70 00 00       	call   80107e5e <copyout>
80100e5e:	83 c4 10             	add    $0x10,%esp
80100e61:	85 c0                	test   %eax,%eax
80100e63:	0f 88 75 01 00 00    	js     80100fde <exec+0x43c>
      goto bad;
    ustack[3+argc] = sp;
80100e69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6c:	8d 50 03             	lea    0x3(%eax),%edx
80100e6f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e72:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e79:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e80:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e87:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e8a:	01 d0                	add    %edx,%eax
80100e8c:	8b 00                	mov    (%eax),%eax
80100e8e:	85 c0                	test   %eax,%eax
80100e90:	0f 85 51 ff ff ff    	jne    80100de7 <exec+0x245>
  }
  ustack[3+argc] = 0;
80100e96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e99:	83 c0 03             	add    $0x3,%eax
80100e9c:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100ea3:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ea7:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100eae:	ff ff ff 
  ustack[1] = argc;
80100eb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb4:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100eba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ebd:	83 c0 01             	add    $0x1,%eax
80100ec0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ec7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100eca:	29 d0                	sub    %edx,%eax
80100ecc:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100ed2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ed5:	83 c0 04             	add    $0x4,%eax
80100ed8:	c1 e0 02             	shl    $0x2,%eax
80100edb:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ede:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee1:	83 c0 04             	add    $0x4,%eax
80100ee4:	c1 e0 02             	shl    $0x2,%eax
80100ee7:	50                   	push   %eax
80100ee8:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100eee:	50                   	push   %eax
80100eef:	ff 75 dc             	push   -0x24(%ebp)
80100ef2:	ff 75 d4             	push   -0x2c(%ebp)
80100ef5:	e8 64 6f 00 00       	call   80107e5e <copyout>
80100efa:	83 c4 10             	add    $0x10,%esp
80100efd:	85 c0                	test   %eax,%eax
80100eff:	0f 88 dc 00 00 00    	js     80100fe1 <exec+0x43f>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f05:	8b 45 08             	mov    0x8(%ebp),%eax
80100f08:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f11:	eb 17                	jmp    80100f2a <exec+0x388>
    if(*s == '/')
80100f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f16:	0f b6 00             	movzbl (%eax),%eax
80100f19:	3c 2f                	cmp    $0x2f,%al
80100f1b:	75 09                	jne    80100f26 <exec+0x384>
      last = s+1;
80100f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f20:	83 c0 01             	add    $0x1,%eax
80100f23:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f26:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f2d:	0f b6 00             	movzbl (%eax),%eax
80100f30:	84 c0                	test   %al,%al
80100f32:	75 df                	jne    80100f13 <exec+0x371>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f34:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f37:	83 c0 6c             	add    $0x6c,%eax
80100f3a:	83 ec 04             	sub    $0x4,%esp
80100f3d:	6a 10                	push   $0x10
80100f3f:	ff 75 f0             	push   -0x10(%ebp)
80100f42:	50                   	push   %eax
80100f43:	e8 f2 3d 00 00       	call   80104d3a <safestrcpy>
80100f48:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f4b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f4e:	8b 40 04             	mov    0x4(%eax),%eax
80100f51:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f54:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f57:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f5a:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f5d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f60:	8b 40 18             	mov    0x18(%eax),%eax
80100f63:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f69:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->sz = sz;
80100f6c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f6f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f72:	89 10                	mov    %edx,(%eax)
  curproc->tf->esp = sp;
80100f74:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f77:	8b 40 18             	mov    0x18(%eax),%eax
80100f7a:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f7d:	89 50 44             	mov    %edx,0x44(%eax)
  cprintf("[exec] eip %x\n",curproc->tf->eip);
80100f80:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f83:	8b 40 18             	mov    0x18(%eax),%eax
80100f86:	8b 40 38             	mov    0x38(%eax),%eax
80100f89:	83 ec 08             	sub    $0x8,%esp
80100f8c:	50                   	push   %eax
80100f8d:	68 79 a4 10 80       	push   $0x8010a479
80100f92:	e8 5d f4 ff ff       	call   801003f4 <cprintf>
80100f97:	83 c4 10             	add    $0x10,%esp
  switchuvm(curproc);
80100f9a:	83 ec 0c             	sub    $0xc,%esp
80100f9d:	ff 75 d0             	push   -0x30(%ebp)
80100fa0:	e8 f1 67 00 00       	call   80107796 <switchuvm>
80100fa5:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fa8:	83 ec 0c             	sub    $0xc,%esp
80100fab:	ff 75 cc             	push   -0x34(%ebp)
80100fae:	e8 88 6c 00 00       	call   80107c3b <freevm>
80100fb3:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fb6:	b8 00 00 00 00       	mov    $0x0,%eax
80100fbb:	eb 67                	jmp    80101024 <exec+0x482>
    goto bad;
80100fbd:	90                   	nop
80100fbe:	eb 22                	jmp    80100fe2 <exec+0x440>
    goto bad;
80100fc0:	90                   	nop
80100fc1:	eb 1f                	jmp    80100fe2 <exec+0x440>
    goto bad;
80100fc3:	90                   	nop
80100fc4:	eb 1c                	jmp    80100fe2 <exec+0x440>
      goto bad;
80100fc6:	90                   	nop
80100fc7:	eb 19                	jmp    80100fe2 <exec+0x440>
      goto bad;
80100fc9:	90                   	nop
80100fca:	eb 16                	jmp    80100fe2 <exec+0x440>
      goto bad;
80100fcc:	90                   	nop
80100fcd:	eb 13                	jmp    80100fe2 <exec+0x440>
      goto bad;
80100fcf:	90                   	nop
80100fd0:	eb 10                	jmp    80100fe2 <exec+0x440>
      goto bad;
80100fd2:	90                   	nop
80100fd3:	eb 0d                	jmp    80100fe2 <exec+0x440>
      goto bad;
80100fd5:	90                   	nop
80100fd6:	eb 0a                	jmp    80100fe2 <exec+0x440>
    goto bad;
80100fd8:	90                   	nop
80100fd9:	eb 07                	jmp    80100fe2 <exec+0x440>
      goto bad;
80100fdb:	90                   	nop
80100fdc:	eb 04                	jmp    80100fe2 <exec+0x440>
      goto bad;
80100fde:	90                   	nop
80100fdf:	eb 01                	jmp    80100fe2 <exec+0x440>
    goto bad;
80100fe1:	90                   	nop

 bad:
  cprintf("bad \n");
80100fe2:	83 ec 0c             	sub    $0xc,%esp
80100fe5:	68 88 a4 10 80       	push   $0x8010a488
80100fea:	e8 05 f4 ff ff       	call   801003f4 <cprintf>
80100fef:	83 c4 10             	add    $0x10,%esp
  if(pgdir)
80100ff2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ff6:	74 0e                	je     80101006 <exec+0x464>
    freevm(pgdir);
80100ff8:	83 ec 0c             	sub    $0xc,%esp
80100ffb:	ff 75 d4             	push   -0x2c(%ebp)
80100ffe:	e8 38 6c 00 00       	call   80107c3b <freevm>
80101003:	83 c4 10             	add    $0x10,%esp
  if(ip){
80101006:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010100a:	74 13                	je     8010101f <exec+0x47d>
    iunlockput(ip);
8010100c:	83 ec 0c             	sub    $0xc,%esp
8010100f:	ff 75 d8             	push   -0x28(%ebp)
80101012:	e8 69 0c 00 00       	call   80101c80 <iunlockput>
80101017:	83 c4 10             	add    $0x10,%esp
    end_op();
8010101a:	e8 08 21 00 00       	call   80103127 <end_op>
  }
  return -1;
8010101f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101024:	c9                   	leave
80101025:	c3                   	ret

80101026 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101026:	55                   	push   %ebp
80101027:	89 e5                	mov    %esp,%ebp
80101029:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010102c:	83 ec 08             	sub    $0x8,%esp
8010102f:	68 8e a4 10 80       	push   $0x8010a48e
80101034:	68 a0 1a 19 80       	push   $0x80191aa0
80101039:	e8 61 38 00 00       	call   8010489f <initlock>
8010103e:	83 c4 10             	add    $0x10,%esp
}
80101041:	90                   	nop
80101042:	c9                   	leave
80101043:	c3                   	ret

80101044 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101044:	55                   	push   %ebp
80101045:	89 e5                	mov    %esp,%ebp
80101047:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010104a:	83 ec 0c             	sub    $0xc,%esp
8010104d:	68 a0 1a 19 80       	push   $0x80191aa0
80101052:	e8 6a 38 00 00       	call   801048c1 <acquire>
80101057:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010105a:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80101061:	eb 2d                	jmp    80101090 <filealloc+0x4c>
    if(f->ref == 0){
80101063:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101066:	8b 40 04             	mov    0x4(%eax),%eax
80101069:	85 c0                	test   %eax,%eax
8010106b:	75 1f                	jne    8010108c <filealloc+0x48>
      f->ref = 1;
8010106d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101070:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101077:	83 ec 0c             	sub    $0xc,%esp
8010107a:	68 a0 1a 19 80       	push   $0x80191aa0
8010107f:	e8 ab 38 00 00       	call   8010492f <release>
80101084:	83 c4 10             	add    $0x10,%esp
      return f;
80101087:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010108a:	eb 23                	jmp    801010af <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010108c:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101090:	b8 34 24 19 80       	mov    $0x80192434,%eax
80101095:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101098:	72 c9                	jb     80101063 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
8010109a:	83 ec 0c             	sub    $0xc,%esp
8010109d:	68 a0 1a 19 80       	push   $0x80191aa0
801010a2:	e8 88 38 00 00       	call   8010492f <release>
801010a7:	83 c4 10             	add    $0x10,%esp
  return 0;
801010aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801010af:	c9                   	leave
801010b0:	c3                   	ret

801010b1 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801010b1:	55                   	push   %ebp
801010b2:	89 e5                	mov    %esp,%ebp
801010b4:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801010b7:	83 ec 0c             	sub    $0xc,%esp
801010ba:	68 a0 1a 19 80       	push   $0x80191aa0
801010bf:	e8 fd 37 00 00       	call   801048c1 <acquire>
801010c4:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010c7:	8b 45 08             	mov    0x8(%ebp),%eax
801010ca:	8b 40 04             	mov    0x4(%eax),%eax
801010cd:	85 c0                	test   %eax,%eax
801010cf:	7f 0d                	jg     801010de <filedup+0x2d>
    panic("filedup");
801010d1:	83 ec 0c             	sub    $0xc,%esp
801010d4:	68 95 a4 10 80       	push   $0x8010a495
801010d9:	e8 e3 f4 ff ff       	call   801005c1 <panic>
  f->ref++;
801010de:	8b 45 08             	mov    0x8(%ebp),%eax
801010e1:	8b 40 04             	mov    0x4(%eax),%eax
801010e4:	8d 50 01             	lea    0x1(%eax),%edx
801010e7:	8b 45 08             	mov    0x8(%ebp),%eax
801010ea:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010ed:	83 ec 0c             	sub    $0xc,%esp
801010f0:	68 a0 1a 19 80       	push   $0x80191aa0
801010f5:	e8 35 38 00 00       	call   8010492f <release>
801010fa:	83 c4 10             	add    $0x10,%esp
  return f;
801010fd:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101100:	c9                   	leave
80101101:	c3                   	ret

80101102 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101102:	55                   	push   %ebp
80101103:	89 e5                	mov    %esp,%ebp
80101105:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101108:	83 ec 0c             	sub    $0xc,%esp
8010110b:	68 a0 1a 19 80       	push   $0x80191aa0
80101110:	e8 ac 37 00 00       	call   801048c1 <acquire>
80101115:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101118:	8b 45 08             	mov    0x8(%ebp),%eax
8010111b:	8b 40 04             	mov    0x4(%eax),%eax
8010111e:	85 c0                	test   %eax,%eax
80101120:	7f 0d                	jg     8010112f <fileclose+0x2d>
    panic("fileclose");
80101122:	83 ec 0c             	sub    $0xc,%esp
80101125:	68 9d a4 10 80       	push   $0x8010a49d
8010112a:	e8 92 f4 ff ff       	call   801005c1 <panic>
  if(--f->ref > 0){
8010112f:	8b 45 08             	mov    0x8(%ebp),%eax
80101132:	8b 40 04             	mov    0x4(%eax),%eax
80101135:	8d 50 ff             	lea    -0x1(%eax),%edx
80101138:	8b 45 08             	mov    0x8(%ebp),%eax
8010113b:	89 50 04             	mov    %edx,0x4(%eax)
8010113e:	8b 45 08             	mov    0x8(%ebp),%eax
80101141:	8b 40 04             	mov    0x4(%eax),%eax
80101144:	85 c0                	test   %eax,%eax
80101146:	7e 15                	jle    8010115d <fileclose+0x5b>
    release(&ftable.lock);
80101148:	83 ec 0c             	sub    $0xc,%esp
8010114b:	68 a0 1a 19 80       	push   $0x80191aa0
80101150:	e8 da 37 00 00       	call   8010492f <release>
80101155:	83 c4 10             	add    $0x10,%esp
80101158:	e9 8b 00 00 00       	jmp    801011e8 <fileclose+0xe6>
    return;
  }
  ff = *f;
8010115d:	8b 45 08             	mov    0x8(%ebp),%eax
80101160:	8b 10                	mov    (%eax),%edx
80101162:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101165:	8b 50 04             	mov    0x4(%eax),%edx
80101168:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010116b:	8b 50 08             	mov    0x8(%eax),%edx
8010116e:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101171:	8b 50 0c             	mov    0xc(%eax),%edx
80101174:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101177:	8b 50 10             	mov    0x10(%eax),%edx
8010117a:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010117d:	8b 40 14             	mov    0x14(%eax),%eax
80101180:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101183:	8b 45 08             	mov    0x8(%ebp),%eax
80101186:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010118d:	8b 45 08             	mov    0x8(%ebp),%eax
80101190:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101196:	83 ec 0c             	sub    $0xc,%esp
80101199:	68 a0 1a 19 80       	push   $0x80191aa0
8010119e:	e8 8c 37 00 00       	call   8010492f <release>
801011a3:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
801011a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011a9:	83 f8 01             	cmp    $0x1,%eax
801011ac:	75 19                	jne    801011c7 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801011ae:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801011b2:	0f be d0             	movsbl %al,%edx
801011b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011b8:	83 ec 08             	sub    $0x8,%esp
801011bb:	52                   	push   %edx
801011bc:	50                   	push   %eax
801011bd:	e8 5a 25 00 00       	call   8010371c <pipeclose>
801011c2:	83 c4 10             	add    $0x10,%esp
801011c5:	eb 21                	jmp    801011e8 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801011c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011ca:	83 f8 02             	cmp    $0x2,%eax
801011cd:	75 19                	jne    801011e8 <fileclose+0xe6>
    begin_op();
801011cf:	e8 c7 1e 00 00       	call   8010309b <begin_op>
    iput(ff.ip);
801011d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011d7:	83 ec 0c             	sub    $0xc,%esp
801011da:	50                   	push   %eax
801011db:	e8 d0 09 00 00       	call   80101bb0 <iput>
801011e0:	83 c4 10             	add    $0x10,%esp
    end_op();
801011e3:	e8 3f 1f 00 00       	call   80103127 <end_op>
  }
}
801011e8:	c9                   	leave
801011e9:	c3                   	ret

801011ea <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011ea:	55                   	push   %ebp
801011eb:	89 e5                	mov    %esp,%ebp
801011ed:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011f0:	8b 45 08             	mov    0x8(%ebp),%eax
801011f3:	8b 00                	mov    (%eax),%eax
801011f5:	83 f8 02             	cmp    $0x2,%eax
801011f8:	75 40                	jne    8010123a <filestat+0x50>
    ilock(f->ip);
801011fa:	8b 45 08             	mov    0x8(%ebp),%eax
801011fd:	8b 40 10             	mov    0x10(%eax),%eax
80101200:	83 ec 0c             	sub    $0xc,%esp
80101203:	50                   	push   %eax
80101204:	e8 46 08 00 00       	call   80101a4f <ilock>
80101209:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010120c:	8b 45 08             	mov    0x8(%ebp),%eax
8010120f:	8b 40 10             	mov    0x10(%eax),%eax
80101212:	83 ec 08             	sub    $0x8,%esp
80101215:	ff 75 0c             	push   0xc(%ebp)
80101218:	50                   	push   %eax
80101219:	e8 d7 0c 00 00       	call   80101ef5 <stati>
8010121e:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101221:	8b 45 08             	mov    0x8(%ebp),%eax
80101224:	8b 40 10             	mov    0x10(%eax),%eax
80101227:	83 ec 0c             	sub    $0xc,%esp
8010122a:	50                   	push   %eax
8010122b:	e8 32 09 00 00       	call   80101b62 <iunlock>
80101230:	83 c4 10             	add    $0x10,%esp
    return 0;
80101233:	b8 00 00 00 00       	mov    $0x0,%eax
80101238:	eb 05                	jmp    8010123f <filestat+0x55>
  }
  return -1;
8010123a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010123f:	c9                   	leave
80101240:	c3                   	ret

80101241 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101241:	55                   	push   %ebp
80101242:	89 e5                	mov    %esp,%ebp
80101244:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101247:	8b 45 08             	mov    0x8(%ebp),%eax
8010124a:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010124e:	84 c0                	test   %al,%al
80101250:	75 0a                	jne    8010125c <fileread+0x1b>
    return -1;
80101252:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101257:	e9 9b 00 00 00       	jmp    801012f7 <fileread+0xb6>
  if(f->type == FD_PIPE)
8010125c:	8b 45 08             	mov    0x8(%ebp),%eax
8010125f:	8b 00                	mov    (%eax),%eax
80101261:	83 f8 01             	cmp    $0x1,%eax
80101264:	75 1a                	jne    80101280 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	8b 40 0c             	mov    0xc(%eax),%eax
8010126c:	83 ec 04             	sub    $0x4,%esp
8010126f:	ff 75 10             	push   0x10(%ebp)
80101272:	ff 75 0c             	push   0xc(%ebp)
80101275:	50                   	push   %eax
80101276:	e8 4e 26 00 00       	call   801038c9 <piperead>
8010127b:	83 c4 10             	add    $0x10,%esp
8010127e:	eb 77                	jmp    801012f7 <fileread+0xb6>
  if(f->type == FD_INODE){
80101280:	8b 45 08             	mov    0x8(%ebp),%eax
80101283:	8b 00                	mov    (%eax),%eax
80101285:	83 f8 02             	cmp    $0x2,%eax
80101288:	75 60                	jne    801012ea <fileread+0xa9>
    ilock(f->ip);
8010128a:	8b 45 08             	mov    0x8(%ebp),%eax
8010128d:	8b 40 10             	mov    0x10(%eax),%eax
80101290:	83 ec 0c             	sub    $0xc,%esp
80101293:	50                   	push   %eax
80101294:	e8 b6 07 00 00       	call   80101a4f <ilock>
80101299:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010129c:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010129f:	8b 45 08             	mov    0x8(%ebp),%eax
801012a2:	8b 50 14             	mov    0x14(%eax),%edx
801012a5:	8b 45 08             	mov    0x8(%ebp),%eax
801012a8:	8b 40 10             	mov    0x10(%eax),%eax
801012ab:	51                   	push   %ecx
801012ac:	52                   	push   %edx
801012ad:	ff 75 0c             	push   0xc(%ebp)
801012b0:	50                   	push   %eax
801012b1:	e8 85 0c 00 00       	call   80101f3b <readi>
801012b6:	83 c4 10             	add    $0x10,%esp
801012b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012c0:	7e 11                	jle    801012d3 <fileread+0x92>
      f->off += r;
801012c2:	8b 45 08             	mov    0x8(%ebp),%eax
801012c5:	8b 50 14             	mov    0x14(%eax),%edx
801012c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012cb:	01 c2                	add    %eax,%edx
801012cd:	8b 45 08             	mov    0x8(%ebp),%eax
801012d0:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012d3:	8b 45 08             	mov    0x8(%ebp),%eax
801012d6:	8b 40 10             	mov    0x10(%eax),%eax
801012d9:	83 ec 0c             	sub    $0xc,%esp
801012dc:	50                   	push   %eax
801012dd:	e8 80 08 00 00       	call   80101b62 <iunlock>
801012e2:	83 c4 10             	add    $0x10,%esp
    return r;
801012e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012e8:	eb 0d                	jmp    801012f7 <fileread+0xb6>
  }
  panic("fileread");
801012ea:	83 ec 0c             	sub    $0xc,%esp
801012ed:	68 a7 a4 10 80       	push   $0x8010a4a7
801012f2:	e8 ca f2 ff ff       	call   801005c1 <panic>
}
801012f7:	c9                   	leave
801012f8:	c3                   	ret

801012f9 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012f9:	55                   	push   %ebp
801012fa:	89 e5                	mov    %esp,%ebp
801012fc:	53                   	push   %ebx
801012fd:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101300:	8b 45 08             	mov    0x8(%ebp),%eax
80101303:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101307:	84 c0                	test   %al,%al
80101309:	75 0a                	jne    80101315 <filewrite+0x1c>
    return -1;
8010130b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101310:	e9 1b 01 00 00       	jmp    80101430 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101315:	8b 45 08             	mov    0x8(%ebp),%eax
80101318:	8b 00                	mov    (%eax),%eax
8010131a:	83 f8 01             	cmp    $0x1,%eax
8010131d:	75 1d                	jne    8010133c <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010131f:	8b 45 08             	mov    0x8(%ebp),%eax
80101322:	8b 40 0c             	mov    0xc(%eax),%eax
80101325:	83 ec 04             	sub    $0x4,%esp
80101328:	ff 75 10             	push   0x10(%ebp)
8010132b:	ff 75 0c             	push   0xc(%ebp)
8010132e:	50                   	push   %eax
8010132f:	e8 93 24 00 00       	call   801037c7 <pipewrite>
80101334:	83 c4 10             	add    $0x10,%esp
80101337:	e9 f4 00 00 00       	jmp    80101430 <filewrite+0x137>
  if(f->type == FD_INODE){
8010133c:	8b 45 08             	mov    0x8(%ebp),%eax
8010133f:	8b 00                	mov    (%eax),%eax
80101341:	83 f8 02             	cmp    $0x2,%eax
80101344:	0f 85 d9 00 00 00    	jne    80101423 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
8010134a:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101351:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101358:	e9 a3 00 00 00       	jmp    80101400 <filewrite+0x107>
      int n1 = n - i;
8010135d:	8b 45 10             	mov    0x10(%ebp),%eax
80101360:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101363:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101366:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101369:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010136c:	7e 06                	jle    80101374 <filewrite+0x7b>
        n1 = max;
8010136e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101371:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101374:	e8 22 1d 00 00       	call   8010309b <begin_op>
      ilock(f->ip);
80101379:	8b 45 08             	mov    0x8(%ebp),%eax
8010137c:	8b 40 10             	mov    0x10(%eax),%eax
8010137f:	83 ec 0c             	sub    $0xc,%esp
80101382:	50                   	push   %eax
80101383:	e8 c7 06 00 00       	call   80101a4f <ilock>
80101388:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010138b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010138e:	8b 45 08             	mov    0x8(%ebp),%eax
80101391:	8b 50 14             	mov    0x14(%eax),%edx
80101394:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101397:	8b 45 0c             	mov    0xc(%ebp),%eax
8010139a:	01 c3                	add    %eax,%ebx
8010139c:	8b 45 08             	mov    0x8(%ebp),%eax
8010139f:	8b 40 10             	mov    0x10(%eax),%eax
801013a2:	51                   	push   %ecx
801013a3:	52                   	push   %edx
801013a4:	53                   	push   %ebx
801013a5:	50                   	push   %eax
801013a6:	e8 e5 0c 00 00       	call   80102090 <writei>
801013ab:	83 c4 10             	add    $0x10,%esp
801013ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013b1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013b5:	7e 11                	jle    801013c8 <filewrite+0xcf>
        f->off += r;
801013b7:	8b 45 08             	mov    0x8(%ebp),%eax
801013ba:	8b 50 14             	mov    0x14(%eax),%edx
801013bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013c0:	01 c2                	add    %eax,%edx
801013c2:	8b 45 08             	mov    0x8(%ebp),%eax
801013c5:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013c8:	8b 45 08             	mov    0x8(%ebp),%eax
801013cb:	8b 40 10             	mov    0x10(%eax),%eax
801013ce:	83 ec 0c             	sub    $0xc,%esp
801013d1:	50                   	push   %eax
801013d2:	e8 8b 07 00 00       	call   80101b62 <iunlock>
801013d7:	83 c4 10             	add    $0x10,%esp
      end_op();
801013da:	e8 48 1d 00 00       	call   80103127 <end_op>

      if(r < 0)
801013df:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013e3:	78 29                	js     8010140e <filewrite+0x115>
        break;
      if(r != n1)
801013e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013e8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013eb:	74 0d                	je     801013fa <filewrite+0x101>
        panic("short filewrite");
801013ed:	83 ec 0c             	sub    $0xc,%esp
801013f0:	68 b0 a4 10 80       	push   $0x8010a4b0
801013f5:	e8 c7 f1 ff ff       	call   801005c1 <panic>
      i += r;
801013fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013fd:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101403:	3b 45 10             	cmp    0x10(%ebp),%eax
80101406:	0f 8c 51 ff ff ff    	jl     8010135d <filewrite+0x64>
8010140c:	eb 01                	jmp    8010140f <filewrite+0x116>
        break;
8010140e:	90                   	nop
    }
    return i == n ? n : -1;
8010140f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101412:	3b 45 10             	cmp    0x10(%ebp),%eax
80101415:	75 05                	jne    8010141c <filewrite+0x123>
80101417:	8b 45 10             	mov    0x10(%ebp),%eax
8010141a:	eb 14                	jmp    80101430 <filewrite+0x137>
8010141c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101421:	eb 0d                	jmp    80101430 <filewrite+0x137>
  }
  panic("filewrite");
80101423:	83 ec 0c             	sub    $0xc,%esp
80101426:	68 c0 a4 10 80       	push   $0x8010a4c0
8010142b:	e8 91 f1 ff ff       	call   801005c1 <panic>
}
80101430:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101433:	c9                   	leave
80101434:	c3                   	ret

80101435 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101435:	55                   	push   %ebp
80101436:	89 e5                	mov    %esp,%ebp
80101438:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
8010143b:	8b 45 08             	mov    0x8(%ebp),%eax
8010143e:	83 ec 08             	sub    $0x8,%esp
80101441:	6a 01                	push   $0x1
80101443:	50                   	push   %eax
80101444:	e8 b8 ed ff ff       	call   80100201 <bread>
80101449:	83 c4 10             	add    $0x10,%esp
8010144c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010144f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101452:	83 c0 5c             	add    $0x5c,%eax
80101455:	83 ec 04             	sub    $0x4,%esp
80101458:	6a 1c                	push   $0x1c
8010145a:	50                   	push   %eax
8010145b:	ff 75 0c             	push   0xc(%ebp)
8010145e:	e8 93 37 00 00       	call   80104bf6 <memmove>
80101463:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101466:	83 ec 0c             	sub    $0xc,%esp
80101469:	ff 75 f4             	push   -0xc(%ebp)
8010146c:	e8 12 ee ff ff       	call   80100283 <brelse>
80101471:	83 c4 10             	add    $0x10,%esp
}
80101474:	90                   	nop
80101475:	c9                   	leave
80101476:	c3                   	ret

80101477 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101477:	55                   	push   %ebp
80101478:	89 e5                	mov    %esp,%ebp
8010147a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010147d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101480:	8b 45 08             	mov    0x8(%ebp),%eax
80101483:	83 ec 08             	sub    $0x8,%esp
80101486:	52                   	push   %edx
80101487:	50                   	push   %eax
80101488:	e8 74 ed ff ff       	call   80100201 <bread>
8010148d:	83 c4 10             	add    $0x10,%esp
80101490:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101496:	83 c0 5c             	add    $0x5c,%eax
80101499:	83 ec 04             	sub    $0x4,%esp
8010149c:	68 00 02 00 00       	push   $0x200
801014a1:	6a 00                	push   $0x0
801014a3:	50                   	push   %eax
801014a4:	e8 8e 36 00 00       	call   80104b37 <memset>
801014a9:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014ac:	83 ec 0c             	sub    $0xc,%esp
801014af:	ff 75 f4             	push   -0xc(%ebp)
801014b2:	e8 1d 1e 00 00       	call   801032d4 <log_write>
801014b7:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014ba:	83 ec 0c             	sub    $0xc,%esp
801014bd:	ff 75 f4             	push   -0xc(%ebp)
801014c0:	e8 be ed ff ff       	call   80100283 <brelse>
801014c5:	83 c4 10             	add    $0x10,%esp
}
801014c8:	90                   	nop
801014c9:	c9                   	leave
801014ca:	c3                   	ret

801014cb <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014cb:	55                   	push   %ebp
801014cc:	89 e5                	mov    %esp,%ebp
801014ce:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014d1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014df:	e9 0b 01 00 00       	jmp    801015ef <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
801014e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014e7:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014ed:	85 c0                	test   %eax,%eax
801014ef:	0f 48 c2             	cmovs  %edx,%eax
801014f2:	c1 f8 0c             	sar    $0xc,%eax
801014f5:	89 c2                	mov    %eax,%edx
801014f7:	a1 58 24 19 80       	mov    0x80192458,%eax
801014fc:	01 d0                	add    %edx,%eax
801014fe:	83 ec 08             	sub    $0x8,%esp
80101501:	50                   	push   %eax
80101502:	ff 75 08             	push   0x8(%ebp)
80101505:	e8 f7 ec ff ff       	call   80100201 <bread>
8010150a:	83 c4 10             	add    $0x10,%esp
8010150d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101510:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101517:	e9 9e 00 00 00       	jmp    801015ba <balloc+0xef>
      m = 1 << (bi % 8);
8010151c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010151f:	83 e0 07             	and    $0x7,%eax
80101522:	ba 01 00 00 00       	mov    $0x1,%edx
80101527:	89 c1                	mov    %eax,%ecx
80101529:	d3 e2                	shl    %cl,%edx
8010152b:	89 d0                	mov    %edx,%eax
8010152d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101533:	8d 50 07             	lea    0x7(%eax),%edx
80101536:	85 c0                	test   %eax,%eax
80101538:	0f 48 c2             	cmovs  %edx,%eax
8010153b:	c1 f8 03             	sar    $0x3,%eax
8010153e:	89 c2                	mov    %eax,%edx
80101540:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101543:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101548:	0f b6 c0             	movzbl %al,%eax
8010154b:	23 45 e8             	and    -0x18(%ebp),%eax
8010154e:	85 c0                	test   %eax,%eax
80101550:	75 64                	jne    801015b6 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
80101552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101555:	8d 50 07             	lea    0x7(%eax),%edx
80101558:	85 c0                	test   %eax,%eax
8010155a:	0f 48 c2             	cmovs  %edx,%eax
8010155d:	c1 f8 03             	sar    $0x3,%eax
80101560:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101563:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101568:	89 d1                	mov    %edx,%ecx
8010156a:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010156d:	09 ca                	or     %ecx,%edx
8010156f:	89 d1                	mov    %edx,%ecx
80101571:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101574:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101578:	83 ec 0c             	sub    $0xc,%esp
8010157b:	ff 75 ec             	push   -0x14(%ebp)
8010157e:	e8 51 1d 00 00       	call   801032d4 <log_write>
80101583:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101586:	83 ec 0c             	sub    $0xc,%esp
80101589:	ff 75 ec             	push   -0x14(%ebp)
8010158c:	e8 f2 ec ff ff       	call   80100283 <brelse>
80101591:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101594:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101597:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010159a:	01 c2                	add    %eax,%edx
8010159c:	8b 45 08             	mov    0x8(%ebp),%eax
8010159f:	83 ec 08             	sub    $0x8,%esp
801015a2:	52                   	push   %edx
801015a3:	50                   	push   %eax
801015a4:	e8 ce fe ff ff       	call   80101477 <bzero>
801015a9:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b2:	01 d0                	add    %edx,%eax
801015b4:	eb 56                	jmp    8010160c <balloc+0x141>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015b6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015ba:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015c1:	7f 17                	jg     801015da <balloc+0x10f>
801015c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c9:	01 d0                	add    %edx,%eax
801015cb:	89 c2                	mov    %eax,%edx
801015cd:	a1 40 24 19 80       	mov    0x80192440,%eax
801015d2:	39 c2                	cmp    %eax,%edx
801015d4:	0f 82 42 ff ff ff    	jb     8010151c <balloc+0x51>
      }
    }
    brelse(bp);
801015da:	83 ec 0c             	sub    $0xc,%esp
801015dd:	ff 75 ec             	push   -0x14(%ebp)
801015e0:	e8 9e ec ff ff       	call   80100283 <brelse>
801015e5:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801015e8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015ef:	a1 40 24 19 80       	mov    0x80192440,%eax
801015f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015f7:	39 c2                	cmp    %eax,%edx
801015f9:	0f 82 e5 fe ff ff    	jb     801014e4 <balloc+0x19>
  }
  panic("balloc: out of blocks");
801015ff:	83 ec 0c             	sub    $0xc,%esp
80101602:	68 cc a4 10 80       	push   $0x8010a4cc
80101607:	e8 b5 ef ff ff       	call   801005c1 <panic>
}
8010160c:	c9                   	leave
8010160d:	c3                   	ret

8010160e <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010160e:	55                   	push   %ebp
8010160f:	89 e5                	mov    %esp,%ebp
80101611:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101614:	83 ec 08             	sub    $0x8,%esp
80101617:	68 40 24 19 80       	push   $0x80192440
8010161c:	ff 75 08             	push   0x8(%ebp)
8010161f:	e8 11 fe ff ff       	call   80101435 <readsb>
80101624:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101627:	8b 45 0c             	mov    0xc(%ebp),%eax
8010162a:	c1 e8 0c             	shr    $0xc,%eax
8010162d:	89 c2                	mov    %eax,%edx
8010162f:	a1 58 24 19 80       	mov    0x80192458,%eax
80101634:	01 c2                	add    %eax,%edx
80101636:	8b 45 08             	mov    0x8(%ebp),%eax
80101639:	83 ec 08             	sub    $0x8,%esp
8010163c:	52                   	push   %edx
8010163d:	50                   	push   %eax
8010163e:	e8 be eb ff ff       	call   80100201 <bread>
80101643:	83 c4 10             	add    $0x10,%esp
80101646:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101649:	8b 45 0c             	mov    0xc(%ebp),%eax
8010164c:	25 ff 0f 00 00       	and    $0xfff,%eax
80101651:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101654:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101657:	83 e0 07             	and    $0x7,%eax
8010165a:	ba 01 00 00 00       	mov    $0x1,%edx
8010165f:	89 c1                	mov    %eax,%ecx
80101661:	d3 e2                	shl    %cl,%edx
80101663:	89 d0                	mov    %edx,%eax
80101665:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101668:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010166b:	8d 50 07             	lea    0x7(%eax),%edx
8010166e:	85 c0                	test   %eax,%eax
80101670:	0f 48 c2             	cmovs  %edx,%eax
80101673:	c1 f8 03             	sar    $0x3,%eax
80101676:	89 c2                	mov    %eax,%edx
80101678:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010167b:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101680:	0f b6 c0             	movzbl %al,%eax
80101683:	23 45 ec             	and    -0x14(%ebp),%eax
80101686:	85 c0                	test   %eax,%eax
80101688:	75 0d                	jne    80101697 <bfree+0x89>
    panic("freeing free block");
8010168a:	83 ec 0c             	sub    $0xc,%esp
8010168d:	68 e2 a4 10 80       	push   $0x8010a4e2
80101692:	e8 2a ef ff ff       	call   801005c1 <panic>
  bp->data[bi/8] &= ~m;
80101697:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010169a:	8d 50 07             	lea    0x7(%eax),%edx
8010169d:	85 c0                	test   %eax,%eax
8010169f:	0f 48 c2             	cmovs  %edx,%eax
801016a2:	c1 f8 03             	sar    $0x3,%eax
801016a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016a8:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801016ad:	89 d1                	mov    %edx,%ecx
801016af:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016b2:	f7 d2                	not    %edx
801016b4:	21 ca                	and    %ecx,%edx
801016b6:	89 d1                	mov    %edx,%ecx
801016b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016bb:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801016bf:	83 ec 0c             	sub    $0xc,%esp
801016c2:	ff 75 f4             	push   -0xc(%ebp)
801016c5:	e8 0a 1c 00 00       	call   801032d4 <log_write>
801016ca:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016cd:	83 ec 0c             	sub    $0xc,%esp
801016d0:	ff 75 f4             	push   -0xc(%ebp)
801016d3:	e8 ab eb ff ff       	call   80100283 <brelse>
801016d8:	83 c4 10             	add    $0x10,%esp
}
801016db:	90                   	nop
801016dc:	c9                   	leave
801016dd:	c3                   	ret

801016de <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016de:	55                   	push   %ebp
801016df:	89 e5                	mov    %esp,%ebp
801016e1:	57                   	push   %edi
801016e2:	56                   	push   %esi
801016e3:	53                   	push   %ebx
801016e4:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
801016e7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801016ee:	83 ec 08             	sub    $0x8,%esp
801016f1:	68 f5 a4 10 80       	push   $0x8010a4f5
801016f6:	68 60 24 19 80       	push   $0x80192460
801016fb:	e8 9f 31 00 00       	call   8010489f <initlock>
80101700:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101703:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010170a:	eb 2d                	jmp    80101739 <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
8010170c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010170f:	89 d0                	mov    %edx,%eax
80101711:	c1 e0 03             	shl    $0x3,%eax
80101714:	01 d0                	add    %edx,%eax
80101716:	c1 e0 04             	shl    $0x4,%eax
80101719:	83 c0 30             	add    $0x30,%eax
8010171c:	05 60 24 19 80       	add    $0x80192460,%eax
80101721:	83 c0 10             	add    $0x10,%eax
80101724:	83 ec 08             	sub    $0x8,%esp
80101727:	68 fc a4 10 80       	push   $0x8010a4fc
8010172c:	50                   	push   %eax
8010172d:	e8 10 30 00 00       	call   80104742 <initsleeplock>
80101732:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101735:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101739:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
8010173d:	7e cd                	jle    8010170c <iinit+0x2e>
  }

  readsb(dev, &sb);
8010173f:	83 ec 08             	sub    $0x8,%esp
80101742:	68 40 24 19 80       	push   $0x80192440
80101747:	ff 75 08             	push   0x8(%ebp)
8010174a:	e8 e6 fc ff ff       	call   80101435 <readsb>
8010174f:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101752:	a1 58 24 19 80       	mov    0x80192458,%eax
80101757:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010175a:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
80101760:	8b 35 50 24 19 80    	mov    0x80192450,%esi
80101766:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
8010176c:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
80101772:	8b 15 44 24 19 80    	mov    0x80192444,%edx
80101778:	a1 40 24 19 80       	mov    0x80192440,%eax
8010177d:	ff 75 d4             	push   -0x2c(%ebp)
80101780:	57                   	push   %edi
80101781:	56                   	push   %esi
80101782:	53                   	push   %ebx
80101783:	51                   	push   %ecx
80101784:	52                   	push   %edx
80101785:	50                   	push   %eax
80101786:	68 04 a5 10 80       	push   $0x8010a504
8010178b:	e8 64 ec ff ff       	call   801003f4 <cprintf>
80101790:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101793:	90                   	nop
80101794:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101797:	5b                   	pop    %ebx
80101798:	5e                   	pop    %esi
80101799:	5f                   	pop    %edi
8010179a:	5d                   	pop    %ebp
8010179b:	c3                   	ret

8010179c <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010179c:	55                   	push   %ebp
8010179d:	89 e5                	mov    %esp,%ebp
8010179f:	83 ec 28             	sub    $0x28,%esp
801017a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801017a5:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017a9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017b0:	e9 9e 00 00 00       	jmp    80101853 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801017b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b8:	c1 e8 03             	shr    $0x3,%eax
801017bb:	89 c2                	mov    %eax,%edx
801017bd:	a1 54 24 19 80       	mov    0x80192454,%eax
801017c2:	01 d0                	add    %edx,%eax
801017c4:	83 ec 08             	sub    $0x8,%esp
801017c7:	50                   	push   %eax
801017c8:	ff 75 08             	push   0x8(%ebp)
801017cb:	e8 31 ea ff ff       	call   80100201 <bread>
801017d0:	83 c4 10             	add    $0x10,%esp
801017d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801017d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017d9:	8d 50 5c             	lea    0x5c(%eax),%edx
801017dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017df:	83 e0 07             	and    $0x7,%eax
801017e2:	c1 e0 06             	shl    $0x6,%eax
801017e5:	01 d0                	add    %edx,%eax
801017e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801017ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017ed:	0f b7 00             	movzwl (%eax),%eax
801017f0:	66 85 c0             	test   %ax,%ax
801017f3:	75 4c                	jne    80101841 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
801017f5:	83 ec 04             	sub    $0x4,%esp
801017f8:	6a 40                	push   $0x40
801017fa:	6a 00                	push   $0x0
801017fc:	ff 75 ec             	push   -0x14(%ebp)
801017ff:	e8 33 33 00 00       	call   80104b37 <memset>
80101804:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101807:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010180a:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010180e:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101811:	83 ec 0c             	sub    $0xc,%esp
80101814:	ff 75 f0             	push   -0x10(%ebp)
80101817:	e8 b8 1a 00 00       	call   801032d4 <log_write>
8010181c:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010181f:	83 ec 0c             	sub    $0xc,%esp
80101822:	ff 75 f0             	push   -0x10(%ebp)
80101825:	e8 59 ea ff ff       	call   80100283 <brelse>
8010182a:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010182d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101830:	83 ec 08             	sub    $0x8,%esp
80101833:	50                   	push   %eax
80101834:	ff 75 08             	push   0x8(%ebp)
80101837:	e8 f7 00 00 00       	call   80101933 <iget>
8010183c:	83 c4 10             	add    $0x10,%esp
8010183f:	eb 2f                	jmp    80101870 <ialloc+0xd4>
    }
    brelse(bp);
80101841:	83 ec 0c             	sub    $0xc,%esp
80101844:	ff 75 f0             	push   -0x10(%ebp)
80101847:	e8 37 ea ff ff       	call   80100283 <brelse>
8010184c:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
8010184f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101853:	a1 48 24 19 80       	mov    0x80192448,%eax
80101858:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010185b:	39 c2                	cmp    %eax,%edx
8010185d:	0f 82 52 ff ff ff    	jb     801017b5 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
80101863:	83 ec 0c             	sub    $0xc,%esp
80101866:	68 57 a5 10 80       	push   $0x8010a557
8010186b:	e8 51 ed ff ff       	call   801005c1 <panic>
}
80101870:	c9                   	leave
80101871:	c3                   	ret

80101872 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101872:	55                   	push   %ebp
80101873:	89 e5                	mov    %esp,%ebp
80101875:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101878:	8b 45 08             	mov    0x8(%ebp),%eax
8010187b:	8b 40 04             	mov    0x4(%eax),%eax
8010187e:	c1 e8 03             	shr    $0x3,%eax
80101881:	89 c2                	mov    %eax,%edx
80101883:	a1 54 24 19 80       	mov    0x80192454,%eax
80101888:	01 c2                	add    %eax,%edx
8010188a:	8b 45 08             	mov    0x8(%ebp),%eax
8010188d:	8b 00                	mov    (%eax),%eax
8010188f:	83 ec 08             	sub    $0x8,%esp
80101892:	52                   	push   %edx
80101893:	50                   	push   %eax
80101894:	e8 68 e9 ff ff       	call   80100201 <bread>
80101899:	83 c4 10             	add    $0x10,%esp
8010189c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010189f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a2:	8d 50 5c             	lea    0x5c(%eax),%edx
801018a5:	8b 45 08             	mov    0x8(%ebp),%eax
801018a8:	8b 40 04             	mov    0x4(%eax),%eax
801018ab:	83 e0 07             	and    $0x7,%eax
801018ae:	c1 e0 06             	shl    $0x6,%eax
801018b1:	01 d0                	add    %edx,%eax
801018b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801018b6:	8b 45 08             	mov    0x8(%ebp),%eax
801018b9:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801018bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018c0:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801018c3:	8b 45 08             	mov    0x8(%ebp),%eax
801018c6:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801018ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018cd:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801018d1:	8b 45 08             	mov    0x8(%ebp),%eax
801018d4:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801018d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018db:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801018df:	8b 45 08             	mov    0x8(%ebp),%eax
801018e2:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801018e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018e9:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801018ed:	8b 45 08             	mov    0x8(%ebp),%eax
801018f0:	8b 50 58             	mov    0x58(%eax),%edx
801018f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f6:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018f9:	8b 45 08             	mov    0x8(%ebp),%eax
801018fc:	8d 50 5c             	lea    0x5c(%eax),%edx
801018ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101902:	83 c0 0c             	add    $0xc,%eax
80101905:	83 ec 04             	sub    $0x4,%esp
80101908:	6a 34                	push   $0x34
8010190a:	52                   	push   %edx
8010190b:	50                   	push   %eax
8010190c:	e8 e5 32 00 00       	call   80104bf6 <memmove>
80101911:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101914:	83 ec 0c             	sub    $0xc,%esp
80101917:	ff 75 f4             	push   -0xc(%ebp)
8010191a:	e8 b5 19 00 00       	call   801032d4 <log_write>
8010191f:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101922:	83 ec 0c             	sub    $0xc,%esp
80101925:	ff 75 f4             	push   -0xc(%ebp)
80101928:	e8 56 e9 ff ff       	call   80100283 <brelse>
8010192d:	83 c4 10             	add    $0x10,%esp
}
80101930:	90                   	nop
80101931:	c9                   	leave
80101932:	c3                   	ret

80101933 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101933:	55                   	push   %ebp
80101934:	89 e5                	mov    %esp,%ebp
80101936:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101939:	83 ec 0c             	sub    $0xc,%esp
8010193c:	68 60 24 19 80       	push   $0x80192460
80101941:	e8 7b 2f 00 00       	call   801048c1 <acquire>
80101946:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101949:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101950:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
80101957:	eb 60                	jmp    801019b9 <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010195c:	8b 40 08             	mov    0x8(%eax),%eax
8010195f:	85 c0                	test   %eax,%eax
80101961:	7e 39                	jle    8010199c <iget+0x69>
80101963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101966:	8b 00                	mov    (%eax),%eax
80101968:	39 45 08             	cmp    %eax,0x8(%ebp)
8010196b:	75 2f                	jne    8010199c <iget+0x69>
8010196d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101970:	8b 40 04             	mov    0x4(%eax),%eax
80101973:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101976:	75 24                	jne    8010199c <iget+0x69>
      ip->ref++;
80101978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197b:	8b 40 08             	mov    0x8(%eax),%eax
8010197e:	8d 50 01             	lea    0x1(%eax),%edx
80101981:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101984:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101987:	83 ec 0c             	sub    $0xc,%esp
8010198a:	68 60 24 19 80       	push   $0x80192460
8010198f:	e8 9b 2f 00 00       	call   8010492f <release>
80101994:	83 c4 10             	add    $0x10,%esp
      return ip;
80101997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199a:	eb 77                	jmp    80101a13 <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010199c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019a0:	75 10                	jne    801019b2 <iget+0x7f>
801019a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a5:	8b 40 08             	mov    0x8(%eax),%eax
801019a8:	85 c0                	test   %eax,%eax
801019aa:	75 06                	jne    801019b2 <iget+0x7f>
      empty = ip;
801019ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019b2:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801019b9:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
801019c0:	72 97                	jb     80101959 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019c2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019c6:	75 0d                	jne    801019d5 <iget+0xa2>
    panic("iget: no inodes");
801019c8:	83 ec 0c             	sub    $0xc,%esp
801019cb:	68 69 a5 10 80       	push   $0x8010a569
801019d0:	e8 ec eb ff ff       	call   801005c1 <panic>

  ip = empty;
801019d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801019db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019de:	8b 55 08             	mov    0x8(%ebp),%edx
801019e1:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801019e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e6:	8b 55 0c             	mov    0xc(%ebp),%edx
801019e9:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801019ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ef:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
801019f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f9:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a00:	83 ec 0c             	sub    $0xc,%esp
80101a03:	68 60 24 19 80       	push   $0x80192460
80101a08:	e8 22 2f 00 00       	call   8010492f <release>
80101a0d:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a13:	c9                   	leave
80101a14:	c3                   	ret

80101a15 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a15:	55                   	push   %ebp
80101a16:	89 e5                	mov    %esp,%ebp
80101a18:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a1b:	83 ec 0c             	sub    $0xc,%esp
80101a1e:	68 60 24 19 80       	push   $0x80192460
80101a23:	e8 99 2e 00 00       	call   801048c1 <acquire>
80101a28:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2e:	8b 40 08             	mov    0x8(%eax),%eax
80101a31:	8d 50 01             	lea    0x1(%eax),%edx
80101a34:	8b 45 08             	mov    0x8(%ebp),%eax
80101a37:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a3a:	83 ec 0c             	sub    $0xc,%esp
80101a3d:	68 60 24 19 80       	push   $0x80192460
80101a42:	e8 e8 2e 00 00       	call   8010492f <release>
80101a47:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a4a:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a4d:	c9                   	leave
80101a4e:	c3                   	ret

80101a4f <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a4f:	55                   	push   %ebp
80101a50:	89 e5                	mov    %esp,%ebp
80101a52:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a55:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a59:	74 0a                	je     80101a65 <ilock+0x16>
80101a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5e:	8b 40 08             	mov    0x8(%eax),%eax
80101a61:	85 c0                	test   %eax,%eax
80101a63:	7f 0d                	jg     80101a72 <ilock+0x23>
    panic("ilock");
80101a65:	83 ec 0c             	sub    $0xc,%esp
80101a68:	68 79 a5 10 80       	push   $0x8010a579
80101a6d:	e8 4f eb ff ff       	call   801005c1 <panic>

  acquiresleep(&ip->lock);
80101a72:	8b 45 08             	mov    0x8(%ebp),%eax
80101a75:	83 c0 0c             	add    $0xc,%eax
80101a78:	83 ec 0c             	sub    $0xc,%esp
80101a7b:	50                   	push   %eax
80101a7c:	e8 fd 2c 00 00       	call   8010477e <acquiresleep>
80101a81:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a84:	8b 45 08             	mov    0x8(%ebp),%eax
80101a87:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a8a:	85 c0                	test   %eax,%eax
80101a8c:	0f 85 cd 00 00 00    	jne    80101b5f <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a92:	8b 45 08             	mov    0x8(%ebp),%eax
80101a95:	8b 40 04             	mov    0x4(%eax),%eax
80101a98:	c1 e8 03             	shr    $0x3,%eax
80101a9b:	89 c2                	mov    %eax,%edx
80101a9d:	a1 54 24 19 80       	mov    0x80192454,%eax
80101aa2:	01 c2                	add    %eax,%edx
80101aa4:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa7:	8b 00                	mov    (%eax),%eax
80101aa9:	83 ec 08             	sub    $0x8,%esp
80101aac:	52                   	push   %edx
80101aad:	50                   	push   %eax
80101aae:	e8 4e e7 ff ff       	call   80100201 <bread>
80101ab3:	83 c4 10             	add    $0x10,%esp
80101ab6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101abc:	8d 50 5c             	lea    0x5c(%eax),%edx
80101abf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac2:	8b 40 04             	mov    0x4(%eax),%eax
80101ac5:	83 e0 07             	and    $0x7,%eax
80101ac8:	c1 e0 06             	shl    $0x6,%eax
80101acb:	01 d0                	add    %edx,%eax
80101acd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ad3:	0f b7 10             	movzwl (%eax),%edx
80101ad6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad9:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101add:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ae0:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aee:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101af2:	8b 45 08             	mov    0x8(%ebp),%eax
80101af5:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101af9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101afc:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b00:	8b 45 08             	mov    0x8(%ebp),%eax
80101b03:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b0a:	8b 50 08             	mov    0x8(%eax),%edx
80101b0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b10:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b16:	8d 50 0c             	lea    0xc(%eax),%edx
80101b19:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1c:	83 c0 5c             	add    $0x5c,%eax
80101b1f:	83 ec 04             	sub    $0x4,%esp
80101b22:	6a 34                	push   $0x34
80101b24:	52                   	push   %edx
80101b25:	50                   	push   %eax
80101b26:	e8 cb 30 00 00       	call   80104bf6 <memmove>
80101b2b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b2e:	83 ec 0c             	sub    $0xc,%esp
80101b31:	ff 75 f4             	push   -0xc(%ebp)
80101b34:	e8 4a e7 ff ff       	call   80100283 <brelse>
80101b39:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101b3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3f:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b46:	8b 45 08             	mov    0x8(%ebp),%eax
80101b49:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101b4d:	66 85 c0             	test   %ax,%ax
80101b50:	75 0d                	jne    80101b5f <ilock+0x110>
      panic("ilock: no type");
80101b52:	83 ec 0c             	sub    $0xc,%esp
80101b55:	68 7f a5 10 80       	push   $0x8010a57f
80101b5a:	e8 62 ea ff ff       	call   801005c1 <panic>
  }
}
80101b5f:	90                   	nop
80101b60:	c9                   	leave
80101b61:	c3                   	ret

80101b62 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b62:	55                   	push   %ebp
80101b63:	89 e5                	mov    %esp,%ebp
80101b65:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b68:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b6c:	74 20                	je     80101b8e <iunlock+0x2c>
80101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b71:	83 c0 0c             	add    $0xc,%eax
80101b74:	83 ec 0c             	sub    $0xc,%esp
80101b77:	50                   	push   %eax
80101b78:	e8 b3 2c 00 00       	call   80104830 <holdingsleep>
80101b7d:	83 c4 10             	add    $0x10,%esp
80101b80:	85 c0                	test   %eax,%eax
80101b82:	74 0a                	je     80101b8e <iunlock+0x2c>
80101b84:	8b 45 08             	mov    0x8(%ebp),%eax
80101b87:	8b 40 08             	mov    0x8(%eax),%eax
80101b8a:	85 c0                	test   %eax,%eax
80101b8c:	7f 0d                	jg     80101b9b <iunlock+0x39>
    panic("iunlock");
80101b8e:	83 ec 0c             	sub    $0xc,%esp
80101b91:	68 8e a5 10 80       	push   $0x8010a58e
80101b96:	e8 26 ea ff ff       	call   801005c1 <panic>

  releasesleep(&ip->lock);
80101b9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9e:	83 c0 0c             	add    $0xc,%eax
80101ba1:	83 ec 0c             	sub    $0xc,%esp
80101ba4:	50                   	push   %eax
80101ba5:	e8 38 2c 00 00       	call   801047e2 <releasesleep>
80101baa:	83 c4 10             	add    $0x10,%esp
}
80101bad:	90                   	nop
80101bae:	c9                   	leave
80101baf:	c3                   	ret

80101bb0 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101bb0:	55                   	push   %ebp
80101bb1:	89 e5                	mov    %esp,%ebp
80101bb3:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101bb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb9:	83 c0 0c             	add    $0xc,%eax
80101bbc:	83 ec 0c             	sub    $0xc,%esp
80101bbf:	50                   	push   %eax
80101bc0:	e8 b9 2b 00 00       	call   8010477e <acquiresleep>
80101bc5:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcb:	8b 40 4c             	mov    0x4c(%eax),%eax
80101bce:	85 c0                	test   %eax,%eax
80101bd0:	74 6a                	je     80101c3c <iput+0x8c>
80101bd2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd5:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101bd9:	66 85 c0             	test   %ax,%ax
80101bdc:	75 5e                	jne    80101c3c <iput+0x8c>
    acquire(&icache.lock);
80101bde:	83 ec 0c             	sub    $0xc,%esp
80101be1:	68 60 24 19 80       	push   $0x80192460
80101be6:	e8 d6 2c 00 00       	call   801048c1 <acquire>
80101beb:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101bee:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf1:	8b 40 08             	mov    0x8(%eax),%eax
80101bf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101bf7:	83 ec 0c             	sub    $0xc,%esp
80101bfa:	68 60 24 19 80       	push   $0x80192460
80101bff:	e8 2b 2d 00 00       	call   8010492f <release>
80101c04:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c07:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c0b:	75 2f                	jne    80101c3c <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c0d:	83 ec 0c             	sub    $0xc,%esp
80101c10:	ff 75 08             	push   0x8(%ebp)
80101c13:	e8 ad 01 00 00       	call   80101dc5 <itrunc>
80101c18:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1e:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c24:	83 ec 0c             	sub    $0xc,%esp
80101c27:	ff 75 08             	push   0x8(%ebp)
80101c2a:	e8 43 fc ff ff       	call   80101872 <iupdate>
80101c2f:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101c32:	8b 45 08             	mov    0x8(%ebp),%eax
80101c35:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3f:	83 c0 0c             	add    $0xc,%eax
80101c42:	83 ec 0c             	sub    $0xc,%esp
80101c45:	50                   	push   %eax
80101c46:	e8 97 2b 00 00       	call   801047e2 <releasesleep>
80101c4b:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c4e:	83 ec 0c             	sub    $0xc,%esp
80101c51:	68 60 24 19 80       	push   $0x80192460
80101c56:	e8 66 2c 00 00       	call   801048c1 <acquire>
80101c5b:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c61:	8b 40 08             	mov    0x8(%eax),%eax
80101c64:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c67:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6a:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c6d:	83 ec 0c             	sub    $0xc,%esp
80101c70:	68 60 24 19 80       	push   $0x80192460
80101c75:	e8 b5 2c 00 00       	call   8010492f <release>
80101c7a:	83 c4 10             	add    $0x10,%esp
}
80101c7d:	90                   	nop
80101c7e:	c9                   	leave
80101c7f:	c3                   	ret

80101c80 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c80:	55                   	push   %ebp
80101c81:	89 e5                	mov    %esp,%ebp
80101c83:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c86:	83 ec 0c             	sub    $0xc,%esp
80101c89:	ff 75 08             	push   0x8(%ebp)
80101c8c:	e8 d1 fe ff ff       	call   80101b62 <iunlock>
80101c91:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c94:	83 ec 0c             	sub    $0xc,%esp
80101c97:	ff 75 08             	push   0x8(%ebp)
80101c9a:	e8 11 ff ff ff       	call   80101bb0 <iput>
80101c9f:	83 c4 10             	add    $0x10,%esp
}
80101ca2:	90                   	nop
80101ca3:	c9                   	leave
80101ca4:	c3                   	ret

80101ca5 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101ca5:	55                   	push   %ebp
80101ca6:	89 e5                	mov    %esp,%ebp
80101ca8:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cab:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101caf:	77 42                	ja     80101cf3 <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101cb1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb4:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cb7:	83 c2 14             	add    $0x14,%edx
80101cba:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cc5:	75 24                	jne    80101ceb <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101cc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cca:	8b 00                	mov    (%eax),%eax
80101ccc:	83 ec 0c             	sub    $0xc,%esp
80101ccf:	50                   	push   %eax
80101cd0:	e8 f6 f7 ff ff       	call   801014cb <balloc>
80101cd5:	83 c4 10             	add    $0x10,%esp
80101cd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cdb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cde:	8b 55 0c             	mov    0xc(%ebp),%edx
80101ce1:	8d 4a 14             	lea    0x14(%edx),%ecx
80101ce4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ce7:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cee:	e9 d0 00 00 00       	jmp    80101dc3 <bmap+0x11e>
  }
  bn -= NDIRECT;
80101cf3:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101cf7:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101cfb:	0f 87 b5 00 00 00    	ja     80101db6 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d01:	8b 45 08             	mov    0x8(%ebp),%eax
80101d04:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d11:	75 20                	jne    80101d33 <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d13:	8b 45 08             	mov    0x8(%ebp),%eax
80101d16:	8b 00                	mov    (%eax),%eax
80101d18:	83 ec 0c             	sub    $0xc,%esp
80101d1b:	50                   	push   %eax
80101d1c:	e8 aa f7 ff ff       	call   801014cb <balloc>
80101d21:	83 c4 10             	add    $0x10,%esp
80101d24:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d27:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d2d:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d33:	8b 45 08             	mov    0x8(%ebp),%eax
80101d36:	8b 00                	mov    (%eax),%eax
80101d38:	83 ec 08             	sub    $0x8,%esp
80101d3b:	ff 75 f4             	push   -0xc(%ebp)
80101d3e:	50                   	push   %eax
80101d3f:	e8 bd e4 ff ff       	call   80100201 <bread>
80101d44:	83 c4 10             	add    $0x10,%esp
80101d47:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d4d:	83 c0 5c             	add    $0x5c,%eax
80101d50:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d53:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d56:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d60:	01 d0                	add    %edx,%eax
80101d62:	8b 00                	mov    (%eax),%eax
80101d64:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d67:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d6b:	75 36                	jne    80101da3 <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d70:	8b 00                	mov    (%eax),%eax
80101d72:	83 ec 0c             	sub    $0xc,%esp
80101d75:	50                   	push   %eax
80101d76:	e8 50 f7 ff ff       	call   801014cb <balloc>
80101d7b:	83 c4 10             	add    $0x10,%esp
80101d7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d81:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d84:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d8e:	01 c2                	add    %eax,%edx
80101d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d93:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d95:	83 ec 0c             	sub    $0xc,%esp
80101d98:	ff 75 f0             	push   -0x10(%ebp)
80101d9b:	e8 34 15 00 00       	call   801032d4 <log_write>
80101da0:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101da3:	83 ec 0c             	sub    $0xc,%esp
80101da6:	ff 75 f0             	push   -0x10(%ebp)
80101da9:	e8 d5 e4 ff ff       	call   80100283 <brelse>
80101dae:	83 c4 10             	add    $0x10,%esp
    return addr;
80101db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101db4:	eb 0d                	jmp    80101dc3 <bmap+0x11e>
  }

  panic("bmap: out of range");
80101db6:	83 ec 0c             	sub    $0xc,%esp
80101db9:	68 96 a5 10 80       	push   $0x8010a596
80101dbe:	e8 fe e7 ff ff       	call   801005c1 <panic>
}
80101dc3:	c9                   	leave
80101dc4:	c3                   	ret

80101dc5 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101dc5:	55                   	push   %ebp
80101dc6:	89 e5                	mov    %esp,%ebp
80101dc8:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101dcb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101dd2:	eb 45                	jmp    80101e19 <itrunc+0x54>
    if(ip->addrs[i]){
80101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dda:	83 c2 14             	add    $0x14,%edx
80101ddd:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101de1:	85 c0                	test   %eax,%eax
80101de3:	74 30                	je     80101e15 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101de5:	8b 45 08             	mov    0x8(%ebp),%eax
80101de8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101deb:	83 c2 14             	add    $0x14,%edx
80101dee:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101df2:	8b 55 08             	mov    0x8(%ebp),%edx
80101df5:	8b 12                	mov    (%edx),%edx
80101df7:	83 ec 08             	sub    $0x8,%esp
80101dfa:	50                   	push   %eax
80101dfb:	52                   	push   %edx
80101dfc:	e8 0d f8 ff ff       	call   8010160e <bfree>
80101e01:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e04:	8b 45 08             	mov    0x8(%ebp),%eax
80101e07:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e0a:	83 c2 14             	add    $0x14,%edx
80101e0d:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e14:	00 
  for(i = 0; i < NDIRECT; i++){
80101e15:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e19:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e1d:	7e b5                	jle    80101dd4 <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101e1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e22:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e28:	85 c0                	test   %eax,%eax
80101e2a:	0f 84 aa 00 00 00    	je     80101eda <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e30:	8b 45 08             	mov    0x8(%ebp),%eax
80101e33:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e39:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3c:	8b 00                	mov    (%eax),%eax
80101e3e:	83 ec 08             	sub    $0x8,%esp
80101e41:	52                   	push   %edx
80101e42:	50                   	push   %eax
80101e43:	e8 b9 e3 ff ff       	call   80100201 <bread>
80101e48:	83 c4 10             	add    $0x10,%esp
80101e4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e51:	83 c0 5c             	add    $0x5c,%eax
80101e54:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e57:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e5e:	eb 3c                	jmp    80101e9c <itrunc+0xd7>
      if(a[j])
80101e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e63:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e6d:	01 d0                	add    %edx,%eax
80101e6f:	8b 00                	mov    (%eax),%eax
80101e71:	85 c0                	test   %eax,%eax
80101e73:	74 23                	je     80101e98 <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e78:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e82:	01 d0                	add    %edx,%eax
80101e84:	8b 00                	mov    (%eax),%eax
80101e86:	8b 55 08             	mov    0x8(%ebp),%edx
80101e89:	8b 12                	mov    (%edx),%edx
80101e8b:	83 ec 08             	sub    $0x8,%esp
80101e8e:	50                   	push   %eax
80101e8f:	52                   	push   %edx
80101e90:	e8 79 f7 ff ff       	call   8010160e <bfree>
80101e95:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e98:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e9f:	83 f8 7f             	cmp    $0x7f,%eax
80101ea2:	76 bc                	jbe    80101e60 <itrunc+0x9b>
    }
    brelse(bp);
80101ea4:	83 ec 0c             	sub    $0xc,%esp
80101ea7:	ff 75 ec             	push   -0x14(%ebp)
80101eaa:	e8 d4 e3 ff ff       	call   80100283 <brelse>
80101eaf:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101eb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ebb:	8b 55 08             	mov    0x8(%ebp),%edx
80101ebe:	8b 12                	mov    (%edx),%edx
80101ec0:	83 ec 08             	sub    $0x8,%esp
80101ec3:	50                   	push   %eax
80101ec4:	52                   	push   %edx
80101ec5:	e8 44 f7 ff ff       	call   8010160e <bfree>
80101eca:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed0:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101ed7:	00 00 00 
  }

  ip->size = 0;
80101eda:	8b 45 08             	mov    0x8(%ebp),%eax
80101edd:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101ee4:	83 ec 0c             	sub    $0xc,%esp
80101ee7:	ff 75 08             	push   0x8(%ebp)
80101eea:	e8 83 f9 ff ff       	call   80101872 <iupdate>
80101eef:	83 c4 10             	add    $0x10,%esp
}
80101ef2:	90                   	nop
80101ef3:	c9                   	leave
80101ef4:	c3                   	ret

80101ef5 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101ef5:	55                   	push   %ebp
80101ef6:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80101efb:	8b 00                	mov    (%eax),%eax
80101efd:	89 c2                	mov    %eax,%edx
80101eff:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f02:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f05:	8b 45 08             	mov    0x8(%ebp),%eax
80101f08:	8b 50 04             	mov    0x4(%eax),%edx
80101f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f0e:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f11:	8b 45 08             	mov    0x8(%ebp),%eax
80101f14:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101f18:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f1b:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f21:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101f25:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f28:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2f:	8b 50 58             	mov    0x58(%eax),%edx
80101f32:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f35:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f38:	90                   	nop
80101f39:	5d                   	pop    %ebp
80101f3a:	c3                   	ret

80101f3b <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f3b:	55                   	push   %ebp
80101f3c:	89 e5                	mov    %esp,%ebp
80101f3e:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f41:	8b 45 08             	mov    0x8(%ebp),%eax
80101f44:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f48:	66 83 f8 03          	cmp    $0x3,%ax
80101f4c:	75 5c                	jne    80101faa <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f51:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f55:	66 85 c0             	test   %ax,%ax
80101f58:	78 20                	js     80101f7a <readi+0x3f>
80101f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f61:	66 83 f8 09          	cmp    $0x9,%ax
80101f65:	7f 13                	jg     80101f7a <readi+0x3f>
80101f67:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f6e:	98                   	cwtl
80101f6f:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f76:	85 c0                	test   %eax,%eax
80101f78:	75 0a                	jne    80101f84 <readi+0x49>
      return -1;
80101f7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f7f:	e9 0a 01 00 00       	jmp    8010208e <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f84:	8b 45 08             	mov    0x8(%ebp),%eax
80101f87:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f8b:	98                   	cwtl
80101f8c:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f93:	8b 55 14             	mov    0x14(%ebp),%edx
80101f96:	83 ec 04             	sub    $0x4,%esp
80101f99:	52                   	push   %edx
80101f9a:	ff 75 0c             	push   0xc(%ebp)
80101f9d:	ff 75 08             	push   0x8(%ebp)
80101fa0:	ff d0                	call   *%eax
80101fa2:	83 c4 10             	add    $0x10,%esp
80101fa5:	e9 e4 00 00 00       	jmp    8010208e <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101faa:	8b 45 08             	mov    0x8(%ebp),%eax
80101fad:	8b 40 58             	mov    0x58(%eax),%eax
80101fb0:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fb3:	72 0d                	jb     80101fc2 <readi+0x87>
80101fb5:	8b 55 10             	mov    0x10(%ebp),%edx
80101fb8:	8b 45 14             	mov    0x14(%ebp),%eax
80101fbb:	01 d0                	add    %edx,%eax
80101fbd:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fc0:	73 0a                	jae    80101fcc <readi+0x91>
    return -1;
80101fc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fc7:	e9 c2 00 00 00       	jmp    8010208e <readi+0x153>
  if(off + n > ip->size)
80101fcc:	8b 55 10             	mov    0x10(%ebp),%edx
80101fcf:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd2:	01 c2                	add    %eax,%edx
80101fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd7:	8b 40 58             	mov    0x58(%eax),%eax
80101fda:	39 d0                	cmp    %edx,%eax
80101fdc:	73 0c                	jae    80101fea <readi+0xaf>
    n = ip->size - off;
80101fde:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe1:	8b 40 58             	mov    0x58(%eax),%eax
80101fe4:	2b 45 10             	sub    0x10(%ebp),%eax
80101fe7:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101fea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ff1:	e9 89 00 00 00       	jmp    8010207f <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101ff6:	8b 45 10             	mov    0x10(%ebp),%eax
80101ff9:	c1 e8 09             	shr    $0x9,%eax
80101ffc:	83 ec 08             	sub    $0x8,%esp
80101fff:	50                   	push   %eax
80102000:	ff 75 08             	push   0x8(%ebp)
80102003:	e8 9d fc ff ff       	call   80101ca5 <bmap>
80102008:	83 c4 10             	add    $0x10,%esp
8010200b:	8b 55 08             	mov    0x8(%ebp),%edx
8010200e:	8b 12                	mov    (%edx),%edx
80102010:	83 ec 08             	sub    $0x8,%esp
80102013:	50                   	push   %eax
80102014:	52                   	push   %edx
80102015:	e8 e7 e1 ff ff       	call   80100201 <bread>
8010201a:	83 c4 10             	add    $0x10,%esp
8010201d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102020:	8b 45 10             	mov    0x10(%ebp),%eax
80102023:	25 ff 01 00 00       	and    $0x1ff,%eax
80102028:	ba 00 02 00 00       	mov    $0x200,%edx
8010202d:	29 c2                	sub    %eax,%edx
8010202f:	8b 45 14             	mov    0x14(%ebp),%eax
80102032:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102035:	39 c2                	cmp    %eax,%edx
80102037:	0f 46 c2             	cmovbe %edx,%eax
8010203a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010203d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102040:	8d 50 5c             	lea    0x5c(%eax),%edx
80102043:	8b 45 10             	mov    0x10(%ebp),%eax
80102046:	25 ff 01 00 00       	and    $0x1ff,%eax
8010204b:	01 d0                	add    %edx,%eax
8010204d:	83 ec 04             	sub    $0x4,%esp
80102050:	ff 75 ec             	push   -0x14(%ebp)
80102053:	50                   	push   %eax
80102054:	ff 75 0c             	push   0xc(%ebp)
80102057:	e8 9a 2b 00 00       	call   80104bf6 <memmove>
8010205c:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010205f:	83 ec 0c             	sub    $0xc,%esp
80102062:	ff 75 f0             	push   -0x10(%ebp)
80102065:	e8 19 e2 ff ff       	call   80100283 <brelse>
8010206a:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010206d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102070:	01 45 f4             	add    %eax,-0xc(%ebp)
80102073:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102076:	01 45 10             	add    %eax,0x10(%ebp)
80102079:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010207c:	01 45 0c             	add    %eax,0xc(%ebp)
8010207f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102082:	3b 45 14             	cmp    0x14(%ebp),%eax
80102085:	0f 82 6b ff ff ff    	jb     80101ff6 <readi+0xbb>
  }
  return n;
8010208b:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010208e:	c9                   	leave
8010208f:	c3                   	ret

80102090 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102090:	55                   	push   %ebp
80102091:	89 e5                	mov    %esp,%ebp
80102093:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102096:	8b 45 08             	mov    0x8(%ebp),%eax
80102099:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010209d:	66 83 f8 03          	cmp    $0x3,%ax
801020a1:	75 5c                	jne    801020ff <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020a3:	8b 45 08             	mov    0x8(%ebp),%eax
801020a6:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020aa:	66 85 c0             	test   %ax,%ax
801020ad:	78 20                	js     801020cf <writei+0x3f>
801020af:	8b 45 08             	mov    0x8(%ebp),%eax
801020b2:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020b6:	66 83 f8 09          	cmp    $0x9,%ax
801020ba:	7f 13                	jg     801020cf <writei+0x3f>
801020bc:	8b 45 08             	mov    0x8(%ebp),%eax
801020bf:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020c3:	98                   	cwtl
801020c4:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
801020cb:	85 c0                	test   %eax,%eax
801020cd:	75 0a                	jne    801020d9 <writei+0x49>
      return -1;
801020cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d4:	e9 3b 01 00 00       	jmp    80102214 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
801020d9:	8b 45 08             	mov    0x8(%ebp),%eax
801020dc:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020e0:	98                   	cwtl
801020e1:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
801020e8:	8b 55 14             	mov    0x14(%ebp),%edx
801020eb:	83 ec 04             	sub    $0x4,%esp
801020ee:	52                   	push   %edx
801020ef:	ff 75 0c             	push   0xc(%ebp)
801020f2:	ff 75 08             	push   0x8(%ebp)
801020f5:	ff d0                	call   *%eax
801020f7:	83 c4 10             	add    $0x10,%esp
801020fa:	e9 15 01 00 00       	jmp    80102214 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
801020ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102102:	8b 40 58             	mov    0x58(%eax),%eax
80102105:	3b 45 10             	cmp    0x10(%ebp),%eax
80102108:	72 0d                	jb     80102117 <writei+0x87>
8010210a:	8b 55 10             	mov    0x10(%ebp),%edx
8010210d:	8b 45 14             	mov    0x14(%ebp),%eax
80102110:	01 d0                	add    %edx,%eax
80102112:	3b 45 10             	cmp    0x10(%ebp),%eax
80102115:	73 0a                	jae    80102121 <writei+0x91>
    return -1;
80102117:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010211c:	e9 f3 00 00 00       	jmp    80102214 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
80102121:	8b 55 10             	mov    0x10(%ebp),%edx
80102124:	8b 45 14             	mov    0x14(%ebp),%eax
80102127:	01 d0                	add    %edx,%eax
80102129:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010212e:	76 0a                	jbe    8010213a <writei+0xaa>
    return -1;
80102130:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102135:	e9 da 00 00 00       	jmp    80102214 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010213a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102141:	e9 97 00 00 00       	jmp    801021dd <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102146:	8b 45 10             	mov    0x10(%ebp),%eax
80102149:	c1 e8 09             	shr    $0x9,%eax
8010214c:	83 ec 08             	sub    $0x8,%esp
8010214f:	50                   	push   %eax
80102150:	ff 75 08             	push   0x8(%ebp)
80102153:	e8 4d fb ff ff       	call   80101ca5 <bmap>
80102158:	83 c4 10             	add    $0x10,%esp
8010215b:	8b 55 08             	mov    0x8(%ebp),%edx
8010215e:	8b 12                	mov    (%edx),%edx
80102160:	83 ec 08             	sub    $0x8,%esp
80102163:	50                   	push   %eax
80102164:	52                   	push   %edx
80102165:	e8 97 e0 ff ff       	call   80100201 <bread>
8010216a:	83 c4 10             	add    $0x10,%esp
8010216d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102170:	8b 45 10             	mov    0x10(%ebp),%eax
80102173:	25 ff 01 00 00       	and    $0x1ff,%eax
80102178:	ba 00 02 00 00       	mov    $0x200,%edx
8010217d:	29 c2                	sub    %eax,%edx
8010217f:	8b 45 14             	mov    0x14(%ebp),%eax
80102182:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102185:	39 c2                	cmp    %eax,%edx
80102187:	0f 46 c2             	cmovbe %edx,%eax
8010218a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010218d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102190:	8d 50 5c             	lea    0x5c(%eax),%edx
80102193:	8b 45 10             	mov    0x10(%ebp),%eax
80102196:	25 ff 01 00 00       	and    $0x1ff,%eax
8010219b:	01 d0                	add    %edx,%eax
8010219d:	83 ec 04             	sub    $0x4,%esp
801021a0:	ff 75 ec             	push   -0x14(%ebp)
801021a3:	ff 75 0c             	push   0xc(%ebp)
801021a6:	50                   	push   %eax
801021a7:	e8 4a 2a 00 00       	call   80104bf6 <memmove>
801021ac:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801021af:	83 ec 0c             	sub    $0xc,%esp
801021b2:	ff 75 f0             	push   -0x10(%ebp)
801021b5:	e8 1a 11 00 00       	call   801032d4 <log_write>
801021ba:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801021bd:	83 ec 0c             	sub    $0xc,%esp
801021c0:	ff 75 f0             	push   -0x10(%ebp)
801021c3:	e8 bb e0 ff ff       	call   80100283 <brelse>
801021c8:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021ce:	01 45 f4             	add    %eax,-0xc(%ebp)
801021d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021d4:	01 45 10             	add    %eax,0x10(%ebp)
801021d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021da:	01 45 0c             	add    %eax,0xc(%ebp)
801021dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021e0:	3b 45 14             	cmp    0x14(%ebp),%eax
801021e3:	0f 82 5d ff ff ff    	jb     80102146 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
801021e9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801021ed:	74 22                	je     80102211 <writei+0x181>
801021ef:	8b 45 08             	mov    0x8(%ebp),%eax
801021f2:	8b 40 58             	mov    0x58(%eax),%eax
801021f5:	3b 45 10             	cmp    0x10(%ebp),%eax
801021f8:	73 17                	jae    80102211 <writei+0x181>
    ip->size = off;
801021fa:	8b 45 08             	mov    0x8(%ebp),%eax
801021fd:	8b 55 10             	mov    0x10(%ebp),%edx
80102200:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102203:	83 ec 0c             	sub    $0xc,%esp
80102206:	ff 75 08             	push   0x8(%ebp)
80102209:	e8 64 f6 ff ff       	call   80101872 <iupdate>
8010220e:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102211:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102214:	c9                   	leave
80102215:	c3                   	ret

80102216 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102216:	55                   	push   %ebp
80102217:	89 e5                	mov    %esp,%ebp
80102219:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
8010221c:	83 ec 04             	sub    $0x4,%esp
8010221f:	6a 0e                	push   $0xe
80102221:	ff 75 0c             	push   0xc(%ebp)
80102224:	ff 75 08             	push   0x8(%ebp)
80102227:	e8 60 2a 00 00       	call   80104c8c <strncmp>
8010222c:	83 c4 10             	add    $0x10,%esp
}
8010222f:	c9                   	leave
80102230:	c3                   	ret

80102231 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102231:	55                   	push   %ebp
80102232:	89 e5                	mov    %esp,%ebp
80102234:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102237:	8b 45 08             	mov    0x8(%ebp),%eax
8010223a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010223e:	66 83 f8 01          	cmp    $0x1,%ax
80102242:	74 0d                	je     80102251 <dirlookup+0x20>
    panic("dirlookup not DIR");
80102244:	83 ec 0c             	sub    $0xc,%esp
80102247:	68 a9 a5 10 80       	push   $0x8010a5a9
8010224c:	e8 70 e3 ff ff       	call   801005c1 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102251:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102258:	eb 7b                	jmp    801022d5 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010225a:	6a 10                	push   $0x10
8010225c:	ff 75 f4             	push   -0xc(%ebp)
8010225f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102262:	50                   	push   %eax
80102263:	ff 75 08             	push   0x8(%ebp)
80102266:	e8 d0 fc ff ff       	call   80101f3b <readi>
8010226b:	83 c4 10             	add    $0x10,%esp
8010226e:	83 f8 10             	cmp    $0x10,%eax
80102271:	74 0d                	je     80102280 <dirlookup+0x4f>
      panic("dirlookup read");
80102273:	83 ec 0c             	sub    $0xc,%esp
80102276:	68 bb a5 10 80       	push   $0x8010a5bb
8010227b:	e8 41 e3 ff ff       	call   801005c1 <panic>
    if(de.inum == 0)
80102280:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102284:	66 85 c0             	test   %ax,%ax
80102287:	74 47                	je     801022d0 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102289:	83 ec 08             	sub    $0x8,%esp
8010228c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010228f:	83 c0 02             	add    $0x2,%eax
80102292:	50                   	push   %eax
80102293:	ff 75 0c             	push   0xc(%ebp)
80102296:	e8 7b ff ff ff       	call   80102216 <namecmp>
8010229b:	83 c4 10             	add    $0x10,%esp
8010229e:	85 c0                	test   %eax,%eax
801022a0:	75 2f                	jne    801022d1 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
801022a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022a6:	74 08                	je     801022b0 <dirlookup+0x7f>
        *poff = off;
801022a8:	8b 45 10             	mov    0x10(%ebp),%eax
801022ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022ae:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801022b0:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022b4:	0f b7 c0             	movzwl %ax,%eax
801022b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801022ba:	8b 45 08             	mov    0x8(%ebp),%eax
801022bd:	8b 00                	mov    (%eax),%eax
801022bf:	83 ec 08             	sub    $0x8,%esp
801022c2:	ff 75 f0             	push   -0x10(%ebp)
801022c5:	50                   	push   %eax
801022c6:	e8 68 f6 ff ff       	call   80101933 <iget>
801022cb:	83 c4 10             	add    $0x10,%esp
801022ce:	eb 19                	jmp    801022e9 <dirlookup+0xb8>
      continue;
801022d0:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
801022d1:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801022d5:	8b 45 08             	mov    0x8(%ebp),%eax
801022d8:	8b 40 58             	mov    0x58(%eax),%eax
801022db:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801022de:	0f 82 76 ff ff ff    	jb     8010225a <dirlookup+0x29>
    }
  }

  return 0;
801022e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022e9:	c9                   	leave
801022ea:	c3                   	ret

801022eb <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022eb:	55                   	push   %ebp
801022ec:	89 e5                	mov    %esp,%ebp
801022ee:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022f1:	83 ec 04             	sub    $0x4,%esp
801022f4:	6a 00                	push   $0x0
801022f6:	ff 75 0c             	push   0xc(%ebp)
801022f9:	ff 75 08             	push   0x8(%ebp)
801022fc:	e8 30 ff ff ff       	call   80102231 <dirlookup>
80102301:	83 c4 10             	add    $0x10,%esp
80102304:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102307:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010230b:	74 18                	je     80102325 <dirlink+0x3a>
    iput(ip);
8010230d:	83 ec 0c             	sub    $0xc,%esp
80102310:	ff 75 f0             	push   -0x10(%ebp)
80102313:	e8 98 f8 ff ff       	call   80101bb0 <iput>
80102318:	83 c4 10             	add    $0x10,%esp
    return -1;
8010231b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102320:	e9 9c 00 00 00       	jmp    801023c1 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102325:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010232c:	eb 39                	jmp    80102367 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010232e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102331:	6a 10                	push   $0x10
80102333:	50                   	push   %eax
80102334:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102337:	50                   	push   %eax
80102338:	ff 75 08             	push   0x8(%ebp)
8010233b:	e8 fb fb ff ff       	call   80101f3b <readi>
80102340:	83 c4 10             	add    $0x10,%esp
80102343:	83 f8 10             	cmp    $0x10,%eax
80102346:	74 0d                	je     80102355 <dirlink+0x6a>
      panic("dirlink read");
80102348:	83 ec 0c             	sub    $0xc,%esp
8010234b:	68 ca a5 10 80       	push   $0x8010a5ca
80102350:	e8 6c e2 ff ff       	call   801005c1 <panic>
    if(de.inum == 0)
80102355:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102359:	66 85 c0             	test   %ax,%ax
8010235c:	74 18                	je     80102376 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010235e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102361:	83 c0 10             	add    $0x10,%eax
80102364:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102367:	8b 45 08             	mov    0x8(%ebp),%eax
8010236a:	8b 40 58             	mov    0x58(%eax),%eax
8010236d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102370:	39 c2                	cmp    %eax,%edx
80102372:	72 ba                	jb     8010232e <dirlink+0x43>
80102374:	eb 01                	jmp    80102377 <dirlink+0x8c>
      break;
80102376:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102377:	83 ec 04             	sub    $0x4,%esp
8010237a:	6a 0e                	push   $0xe
8010237c:	ff 75 0c             	push   0xc(%ebp)
8010237f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102382:	83 c0 02             	add    $0x2,%eax
80102385:	50                   	push   %eax
80102386:	e8 57 29 00 00       	call   80104ce2 <strncpy>
8010238b:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010238e:	8b 45 10             	mov    0x10(%ebp),%eax
80102391:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102398:	6a 10                	push   $0x10
8010239a:	50                   	push   %eax
8010239b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010239e:	50                   	push   %eax
8010239f:	ff 75 08             	push   0x8(%ebp)
801023a2:	e8 e9 fc ff ff       	call   80102090 <writei>
801023a7:	83 c4 10             	add    $0x10,%esp
801023aa:	83 f8 10             	cmp    $0x10,%eax
801023ad:	74 0d                	je     801023bc <dirlink+0xd1>
    panic("dirlink");
801023af:	83 ec 0c             	sub    $0xc,%esp
801023b2:	68 d7 a5 10 80       	push   $0x8010a5d7
801023b7:	e8 05 e2 ff ff       	call   801005c1 <panic>

  return 0;
801023bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023c1:	c9                   	leave
801023c2:	c3                   	ret

801023c3 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801023c3:	55                   	push   %ebp
801023c4:	89 e5                	mov    %esp,%ebp
801023c6:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801023c9:	eb 04                	jmp    801023cf <skipelem+0xc>
    path++;
801023cb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023cf:	8b 45 08             	mov    0x8(%ebp),%eax
801023d2:	0f b6 00             	movzbl (%eax),%eax
801023d5:	3c 2f                	cmp    $0x2f,%al
801023d7:	74 f2                	je     801023cb <skipelem+0x8>
  if(*path == 0)
801023d9:	8b 45 08             	mov    0x8(%ebp),%eax
801023dc:	0f b6 00             	movzbl (%eax),%eax
801023df:	84 c0                	test   %al,%al
801023e1:	75 07                	jne    801023ea <skipelem+0x27>
    return 0;
801023e3:	b8 00 00 00 00       	mov    $0x0,%eax
801023e8:	eb 77                	jmp    80102461 <skipelem+0x9e>
  s = path;
801023ea:	8b 45 08             	mov    0x8(%ebp),%eax
801023ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023f0:	eb 04                	jmp    801023f6 <skipelem+0x33>
    path++;
801023f2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801023f6:	8b 45 08             	mov    0x8(%ebp),%eax
801023f9:	0f b6 00             	movzbl (%eax),%eax
801023fc:	3c 2f                	cmp    $0x2f,%al
801023fe:	74 0a                	je     8010240a <skipelem+0x47>
80102400:	8b 45 08             	mov    0x8(%ebp),%eax
80102403:	0f b6 00             	movzbl (%eax),%eax
80102406:	84 c0                	test   %al,%al
80102408:	75 e8                	jne    801023f2 <skipelem+0x2f>
  len = path - s;
8010240a:	8b 45 08             	mov    0x8(%ebp),%eax
8010240d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102410:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102413:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102417:	7e 15                	jle    8010242e <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
80102419:	83 ec 04             	sub    $0x4,%esp
8010241c:	6a 0e                	push   $0xe
8010241e:	ff 75 f4             	push   -0xc(%ebp)
80102421:	ff 75 0c             	push   0xc(%ebp)
80102424:	e8 cd 27 00 00       	call   80104bf6 <memmove>
80102429:	83 c4 10             	add    $0x10,%esp
8010242c:	eb 26                	jmp    80102454 <skipelem+0x91>
  else {
    memmove(name, s, len);
8010242e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102431:	83 ec 04             	sub    $0x4,%esp
80102434:	50                   	push   %eax
80102435:	ff 75 f4             	push   -0xc(%ebp)
80102438:	ff 75 0c             	push   0xc(%ebp)
8010243b:	e8 b6 27 00 00       	call   80104bf6 <memmove>
80102440:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102443:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102446:	8b 45 0c             	mov    0xc(%ebp),%eax
80102449:	01 d0                	add    %edx,%eax
8010244b:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010244e:	eb 04                	jmp    80102454 <skipelem+0x91>
    path++;
80102450:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102454:	8b 45 08             	mov    0x8(%ebp),%eax
80102457:	0f b6 00             	movzbl (%eax),%eax
8010245a:	3c 2f                	cmp    $0x2f,%al
8010245c:	74 f2                	je     80102450 <skipelem+0x8d>
  return path;
8010245e:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102461:	c9                   	leave
80102462:	c3                   	ret

80102463 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102463:	55                   	push   %ebp
80102464:	89 e5                	mov    %esp,%ebp
80102466:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102469:	8b 45 08             	mov    0x8(%ebp),%eax
8010246c:	0f b6 00             	movzbl (%eax),%eax
8010246f:	3c 2f                	cmp    $0x2f,%al
80102471:	75 17                	jne    8010248a <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102473:	83 ec 08             	sub    $0x8,%esp
80102476:	6a 01                	push   $0x1
80102478:	6a 01                	push   $0x1
8010247a:	e8 b4 f4 ff ff       	call   80101933 <iget>
8010247f:	83 c4 10             	add    $0x10,%esp
80102482:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102485:	e9 ba 00 00 00       	jmp    80102544 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
8010248a:	e8 fe 15 00 00       	call   80103a8d <myproc>
8010248f:	8b 40 68             	mov    0x68(%eax),%eax
80102492:	83 ec 0c             	sub    $0xc,%esp
80102495:	50                   	push   %eax
80102496:	e8 7a f5 ff ff       	call   80101a15 <idup>
8010249b:	83 c4 10             	add    $0x10,%esp
8010249e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801024a1:	e9 9e 00 00 00       	jmp    80102544 <namex+0xe1>
    ilock(ip);
801024a6:	83 ec 0c             	sub    $0xc,%esp
801024a9:	ff 75 f4             	push   -0xc(%ebp)
801024ac:	e8 9e f5 ff ff       	call   80101a4f <ilock>
801024b1:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801024b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801024bb:	66 83 f8 01          	cmp    $0x1,%ax
801024bf:	74 18                	je     801024d9 <namex+0x76>
      iunlockput(ip);
801024c1:	83 ec 0c             	sub    $0xc,%esp
801024c4:	ff 75 f4             	push   -0xc(%ebp)
801024c7:	e8 b4 f7 ff ff       	call   80101c80 <iunlockput>
801024cc:	83 c4 10             	add    $0x10,%esp
      return 0;
801024cf:	b8 00 00 00 00       	mov    $0x0,%eax
801024d4:	e9 a7 00 00 00       	jmp    80102580 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
801024d9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024dd:	74 20                	je     801024ff <namex+0x9c>
801024df:	8b 45 08             	mov    0x8(%ebp),%eax
801024e2:	0f b6 00             	movzbl (%eax),%eax
801024e5:	84 c0                	test   %al,%al
801024e7:	75 16                	jne    801024ff <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
801024e9:	83 ec 0c             	sub    $0xc,%esp
801024ec:	ff 75 f4             	push   -0xc(%ebp)
801024ef:	e8 6e f6 ff ff       	call   80101b62 <iunlock>
801024f4:	83 c4 10             	add    $0x10,%esp
      return ip;
801024f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024fa:	e9 81 00 00 00       	jmp    80102580 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024ff:	83 ec 04             	sub    $0x4,%esp
80102502:	6a 00                	push   $0x0
80102504:	ff 75 10             	push   0x10(%ebp)
80102507:	ff 75 f4             	push   -0xc(%ebp)
8010250a:	e8 22 fd ff ff       	call   80102231 <dirlookup>
8010250f:	83 c4 10             	add    $0x10,%esp
80102512:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102515:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102519:	75 15                	jne    80102530 <namex+0xcd>
      iunlockput(ip);
8010251b:	83 ec 0c             	sub    $0xc,%esp
8010251e:	ff 75 f4             	push   -0xc(%ebp)
80102521:	e8 5a f7 ff ff       	call   80101c80 <iunlockput>
80102526:	83 c4 10             	add    $0x10,%esp
      return 0;
80102529:	b8 00 00 00 00       	mov    $0x0,%eax
8010252e:	eb 50                	jmp    80102580 <namex+0x11d>
    }
    iunlockput(ip);
80102530:	83 ec 0c             	sub    $0xc,%esp
80102533:	ff 75 f4             	push   -0xc(%ebp)
80102536:	e8 45 f7 ff ff       	call   80101c80 <iunlockput>
8010253b:	83 c4 10             	add    $0x10,%esp
    ip = next;
8010253e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102541:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
80102544:	83 ec 08             	sub    $0x8,%esp
80102547:	ff 75 10             	push   0x10(%ebp)
8010254a:	ff 75 08             	push   0x8(%ebp)
8010254d:	e8 71 fe ff ff       	call   801023c3 <skipelem>
80102552:	83 c4 10             	add    $0x10,%esp
80102555:	89 45 08             	mov    %eax,0x8(%ebp)
80102558:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010255c:	0f 85 44 ff ff ff    	jne    801024a6 <namex+0x43>
  }
  if(nameiparent){
80102562:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102566:	74 15                	je     8010257d <namex+0x11a>
    iput(ip);
80102568:	83 ec 0c             	sub    $0xc,%esp
8010256b:	ff 75 f4             	push   -0xc(%ebp)
8010256e:	e8 3d f6 ff ff       	call   80101bb0 <iput>
80102573:	83 c4 10             	add    $0x10,%esp
    return 0;
80102576:	b8 00 00 00 00       	mov    $0x0,%eax
8010257b:	eb 03                	jmp    80102580 <namex+0x11d>
  }
  return ip;
8010257d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102580:	c9                   	leave
80102581:	c3                   	ret

80102582 <namei>:

struct inode*
namei(char *path)
{
80102582:	55                   	push   %ebp
80102583:	89 e5                	mov    %esp,%ebp
80102585:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102588:	83 ec 04             	sub    $0x4,%esp
8010258b:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010258e:	50                   	push   %eax
8010258f:	6a 00                	push   $0x0
80102591:	ff 75 08             	push   0x8(%ebp)
80102594:	e8 ca fe ff ff       	call   80102463 <namex>
80102599:	83 c4 10             	add    $0x10,%esp
}
8010259c:	c9                   	leave
8010259d:	c3                   	ret

8010259e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010259e:	55                   	push   %ebp
8010259f:	89 e5                	mov    %esp,%ebp
801025a1:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801025a4:	83 ec 04             	sub    $0x4,%esp
801025a7:	ff 75 0c             	push   0xc(%ebp)
801025aa:	6a 01                	push   $0x1
801025ac:	ff 75 08             	push   0x8(%ebp)
801025af:	e8 af fe ff ff       	call   80102463 <namex>
801025b4:	83 c4 10             	add    $0x10,%esp
}
801025b7:	c9                   	leave
801025b8:	c3                   	ret

801025b9 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801025b9:	55                   	push   %ebp
801025ba:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801025bc:	a1 b4 40 19 80       	mov    0x801940b4,%eax
801025c1:	8b 55 08             	mov    0x8(%ebp),%edx
801025c4:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801025c6:	a1 b4 40 19 80       	mov    0x801940b4,%eax
801025cb:	8b 40 10             	mov    0x10(%eax),%eax
}
801025ce:	5d                   	pop    %ebp
801025cf:	c3                   	ret

801025d0 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801025d0:	55                   	push   %ebp
801025d1:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801025d3:	a1 b4 40 19 80       	mov    0x801940b4,%eax
801025d8:	8b 55 08             	mov    0x8(%ebp),%edx
801025db:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801025dd:	a1 b4 40 19 80       	mov    0x801940b4,%eax
801025e2:	8b 55 0c             	mov    0xc(%ebp),%edx
801025e5:	89 50 10             	mov    %edx,0x10(%eax)
}
801025e8:	90                   	nop
801025e9:	5d                   	pop    %ebp
801025ea:	c3                   	ret

801025eb <ioapicinit>:

void
ioapicinit(void)
{
801025eb:	55                   	push   %ebp
801025ec:	89 e5                	mov    %esp,%ebp
801025ee:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
801025f1:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
801025f8:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801025fb:	6a 01                	push   $0x1
801025fd:	e8 b7 ff ff ff       	call   801025b9 <ioapicread>
80102602:	83 c4 04             	add    $0x4,%esp
80102605:	c1 e8 10             	shr    $0x10,%eax
80102608:	25 ff 00 00 00       	and    $0xff,%eax
8010260d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102610:	6a 00                	push   $0x0
80102612:	e8 a2 ff ff ff       	call   801025b9 <ioapicread>
80102617:	83 c4 04             	add    $0x4,%esp
8010261a:	c1 e8 18             	shr    $0x18,%eax
8010261d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102620:	0f b6 05 34 6b 19 80 	movzbl 0x80196b34,%eax
80102627:	0f b6 c0             	movzbl %al,%eax
8010262a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010262d:	74 10                	je     8010263f <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010262f:	83 ec 0c             	sub    $0xc,%esp
80102632:	68 e0 a5 10 80       	push   $0x8010a5e0
80102637:	e8 b8 dd ff ff       	call   801003f4 <cprintf>
8010263c:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010263f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102646:	eb 3f                	jmp    80102687 <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010264b:	83 c0 20             	add    $0x20,%eax
8010264e:	0d 00 00 01 00       	or     $0x10000,%eax
80102653:	89 c2                	mov    %eax,%edx
80102655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102658:	83 c0 08             	add    $0x8,%eax
8010265b:	01 c0                	add    %eax,%eax
8010265d:	83 ec 08             	sub    $0x8,%esp
80102660:	52                   	push   %edx
80102661:	50                   	push   %eax
80102662:	e8 69 ff ff ff       	call   801025d0 <ioapicwrite>
80102667:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
8010266a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010266d:	83 c0 08             	add    $0x8,%eax
80102670:	01 c0                	add    %eax,%eax
80102672:	83 c0 01             	add    $0x1,%eax
80102675:	83 ec 08             	sub    $0x8,%esp
80102678:	6a 00                	push   $0x0
8010267a:	50                   	push   %eax
8010267b:	e8 50 ff ff ff       	call   801025d0 <ioapicwrite>
80102680:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102683:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010268a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010268d:	7e b9                	jle    80102648 <ioapicinit+0x5d>
  }
}
8010268f:	90                   	nop
80102690:	90                   	nop
80102691:	c9                   	leave
80102692:	c3                   	ret

80102693 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102693:	55                   	push   %ebp
80102694:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102696:	8b 45 08             	mov    0x8(%ebp),%eax
80102699:	83 c0 20             	add    $0x20,%eax
8010269c:	89 c2                	mov    %eax,%edx
8010269e:	8b 45 08             	mov    0x8(%ebp),%eax
801026a1:	83 c0 08             	add    $0x8,%eax
801026a4:	01 c0                	add    %eax,%eax
801026a6:	52                   	push   %edx
801026a7:	50                   	push   %eax
801026a8:	e8 23 ff ff ff       	call   801025d0 <ioapicwrite>
801026ad:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801026b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801026b3:	c1 e0 18             	shl    $0x18,%eax
801026b6:	89 c2                	mov    %eax,%edx
801026b8:	8b 45 08             	mov    0x8(%ebp),%eax
801026bb:	83 c0 08             	add    $0x8,%eax
801026be:	01 c0                	add    %eax,%eax
801026c0:	83 c0 01             	add    $0x1,%eax
801026c3:	52                   	push   %edx
801026c4:	50                   	push   %eax
801026c5:	e8 06 ff ff ff       	call   801025d0 <ioapicwrite>
801026ca:	83 c4 08             	add    $0x8,%esp
}
801026cd:	90                   	nop
801026ce:	c9                   	leave
801026cf:	c3                   	ret

801026d0 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801026d0:	55                   	push   %ebp
801026d1:	89 e5                	mov    %esp,%ebp
801026d3:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
801026d6:	83 ec 08             	sub    $0x8,%esp
801026d9:	68 12 a6 10 80       	push   $0x8010a612
801026de:	68 c0 40 19 80       	push   $0x801940c0
801026e3:	e8 b7 21 00 00       	call   8010489f <initlock>
801026e8:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
801026eb:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
801026f2:	00 00 00 
  freerange(vstart, vend);
801026f5:	83 ec 08             	sub    $0x8,%esp
801026f8:	ff 75 0c             	push   0xc(%ebp)
801026fb:	ff 75 08             	push   0x8(%ebp)
801026fe:	e8 2a 00 00 00       	call   8010272d <freerange>
80102703:	83 c4 10             	add    $0x10,%esp
}
80102706:	90                   	nop
80102707:	c9                   	leave
80102708:	c3                   	ret

80102709 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102709:	55                   	push   %ebp
8010270a:	89 e5                	mov    %esp,%ebp
8010270c:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
8010270f:	83 ec 08             	sub    $0x8,%esp
80102712:	ff 75 0c             	push   0xc(%ebp)
80102715:	ff 75 08             	push   0x8(%ebp)
80102718:	e8 10 00 00 00       	call   8010272d <freerange>
8010271d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102720:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
80102727:	00 00 00 
}
8010272a:	90                   	nop
8010272b:	c9                   	leave
8010272c:	c3                   	ret

8010272d <freerange>:

void
freerange(void *vstart, void *vend)
{
8010272d:	55                   	push   %ebp
8010272e:	89 e5                	mov    %esp,%ebp
80102730:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102733:	8b 45 08             	mov    0x8(%ebp),%eax
80102736:	05 ff 0f 00 00       	add    $0xfff,%eax
8010273b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102740:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102743:	eb 15                	jmp    8010275a <freerange+0x2d>
    kfree(p);
80102745:	83 ec 0c             	sub    $0xc,%esp
80102748:	ff 75 f4             	push   -0xc(%ebp)
8010274b:	e8 1b 00 00 00       	call   8010276b <kfree>
80102750:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102753:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010275a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010275d:	05 00 10 00 00       	add    $0x1000,%eax
80102762:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102765:	73 de                	jae    80102745 <freerange+0x18>
}
80102767:	90                   	nop
80102768:	90                   	nop
80102769:	c9                   	leave
8010276a:	c3                   	ret

8010276b <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
8010276b:	55                   	push   %ebp
8010276c:	89 e5                	mov    %esp,%ebp
8010276e:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102771:	8b 45 08             	mov    0x8(%ebp),%eax
80102774:	25 ff 0f 00 00       	and    $0xfff,%eax
80102779:	85 c0                	test   %eax,%eax
8010277b:	75 18                	jne    80102795 <kfree+0x2a>
8010277d:	81 7d 08 00 80 19 80 	cmpl   $0x80198000,0x8(%ebp)
80102784:	72 0f                	jb     80102795 <kfree+0x2a>
80102786:	8b 45 08             	mov    0x8(%ebp),%eax
80102789:	05 00 00 00 80       	add    $0x80000000,%eax
8010278e:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102793:	76 0d                	jbe    801027a2 <kfree+0x37>
    panic("kfree");
80102795:	83 ec 0c             	sub    $0xc,%esp
80102798:	68 17 a6 10 80       	push   $0x8010a617
8010279d:	e8 1f de ff ff       	call   801005c1 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
801027a2:	83 ec 04             	sub    $0x4,%esp
801027a5:	68 00 10 00 00       	push   $0x1000
801027aa:	6a 01                	push   $0x1
801027ac:	ff 75 08             	push   0x8(%ebp)
801027af:	e8 83 23 00 00       	call   80104b37 <memset>
801027b4:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
801027b7:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027bc:	85 c0                	test   %eax,%eax
801027be:	74 10                	je     801027d0 <kfree+0x65>
    acquire(&kmem.lock);
801027c0:	83 ec 0c             	sub    $0xc,%esp
801027c3:	68 c0 40 19 80       	push   $0x801940c0
801027c8:	e8 f4 20 00 00       	call   801048c1 <acquire>
801027cd:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
801027d0:	8b 45 08             	mov    0x8(%ebp),%eax
801027d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
801027d6:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
801027dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027df:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
801027e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e4:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027e9:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027ee:	85 c0                	test   %eax,%eax
801027f0:	74 10                	je     80102802 <kfree+0x97>
    release(&kmem.lock);
801027f2:	83 ec 0c             	sub    $0xc,%esp
801027f5:	68 c0 40 19 80       	push   $0x801940c0
801027fa:	e8 30 21 00 00       	call   8010492f <release>
801027ff:	83 c4 10             	add    $0x10,%esp
}
80102802:	90                   	nop
80102803:	c9                   	leave
80102804:	c3                   	ret

80102805 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102805:	55                   	push   %ebp
80102806:	89 e5                	mov    %esp,%ebp
80102808:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
8010280b:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102810:	85 c0                	test   %eax,%eax
80102812:	74 10                	je     80102824 <kalloc+0x1f>
    acquire(&kmem.lock);
80102814:	83 ec 0c             	sub    $0xc,%esp
80102817:	68 c0 40 19 80       	push   $0x801940c0
8010281c:	e8 a0 20 00 00       	call   801048c1 <acquire>
80102821:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102824:	a1 f8 40 19 80       	mov    0x801940f8,%eax
80102829:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
8010282c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102830:	74 0a                	je     8010283c <kalloc+0x37>
    kmem.freelist = r->next;
80102832:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102835:	8b 00                	mov    (%eax),%eax
80102837:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
8010283c:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102841:	85 c0                	test   %eax,%eax
80102843:	74 10                	je     80102855 <kalloc+0x50>
    release(&kmem.lock);
80102845:	83 ec 0c             	sub    $0xc,%esp
80102848:	68 c0 40 19 80       	push   $0x801940c0
8010284d:	e8 dd 20 00 00       	call   8010492f <release>
80102852:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102855:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102858:	c9                   	leave
80102859:	c3                   	ret

8010285a <inb>:
{
8010285a:	55                   	push   %ebp
8010285b:	89 e5                	mov    %esp,%ebp
8010285d:	83 ec 14             	sub    $0x14,%esp
80102860:	8b 45 08             	mov    0x8(%ebp),%eax
80102863:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102867:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010286b:	89 c2                	mov    %eax,%edx
8010286d:	ec                   	in     (%dx),%al
8010286e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102871:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102875:	c9                   	leave
80102876:	c3                   	ret

80102877 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102877:	55                   	push   %ebp
80102878:	89 e5                	mov    %esp,%ebp
8010287a:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
8010287d:	6a 64                	push   $0x64
8010287f:	e8 d6 ff ff ff       	call   8010285a <inb>
80102884:	83 c4 04             	add    $0x4,%esp
80102887:	0f b6 c0             	movzbl %al,%eax
8010288a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
8010288d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102890:	83 e0 01             	and    $0x1,%eax
80102893:	85 c0                	test   %eax,%eax
80102895:	75 0a                	jne    801028a1 <kbdgetc+0x2a>
    return -1;
80102897:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010289c:	e9 23 01 00 00       	jmp    801029c4 <kbdgetc+0x14d>
  data = inb(KBDATAP);
801028a1:	6a 60                	push   $0x60
801028a3:	e8 b2 ff ff ff       	call   8010285a <inb>
801028a8:	83 c4 04             	add    $0x4,%esp
801028ab:	0f b6 c0             	movzbl %al,%eax
801028ae:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
801028b1:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
801028b8:	75 17                	jne    801028d1 <kbdgetc+0x5a>
    shift |= E0ESC;
801028ba:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028bf:	83 c8 40             	or     $0x40,%eax
801028c2:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028c7:	b8 00 00 00 00       	mov    $0x0,%eax
801028cc:	e9 f3 00 00 00       	jmp    801029c4 <kbdgetc+0x14d>
  } else if(data & 0x80){
801028d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028d4:	25 80 00 00 00       	and    $0x80,%eax
801028d9:	85 c0                	test   %eax,%eax
801028db:	74 45                	je     80102922 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801028dd:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028e2:	83 e0 40             	and    $0x40,%eax
801028e5:	85 c0                	test   %eax,%eax
801028e7:	75 08                	jne    801028f1 <kbdgetc+0x7a>
801028e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028ec:	83 e0 7f             	and    $0x7f,%eax
801028ef:	eb 03                	jmp    801028f4 <kbdgetc+0x7d>
801028f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801028f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028fa:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028ff:	0f b6 00             	movzbl (%eax),%eax
80102902:	83 c8 40             	or     $0x40,%eax
80102905:	0f b6 c0             	movzbl %al,%eax
80102908:	f7 d0                	not    %eax
8010290a:	89 c2                	mov    %eax,%edx
8010290c:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102911:	21 d0                	and    %edx,%eax
80102913:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
80102918:	b8 00 00 00 00       	mov    $0x0,%eax
8010291d:	e9 a2 00 00 00       	jmp    801029c4 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102922:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102927:	83 e0 40             	and    $0x40,%eax
8010292a:	85 c0                	test   %eax,%eax
8010292c:	74 14                	je     80102942 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
8010292e:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102935:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010293a:	83 e0 bf             	and    $0xffffffbf,%eax
8010293d:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
80102942:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102945:	05 20 d0 10 80       	add    $0x8010d020,%eax
8010294a:	0f b6 00             	movzbl (%eax),%eax
8010294d:	0f b6 d0             	movzbl %al,%edx
80102950:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102955:	09 d0                	or     %edx,%eax
80102957:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
8010295c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010295f:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102964:	0f b6 00             	movzbl (%eax),%eax
80102967:	0f b6 d0             	movzbl %al,%edx
8010296a:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010296f:	31 d0                	xor    %edx,%eax
80102971:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102976:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010297b:	83 e0 03             	and    $0x3,%eax
8010297e:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102985:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102988:	01 d0                	add    %edx,%eax
8010298a:	0f b6 00             	movzbl (%eax),%eax
8010298d:	0f b6 c0             	movzbl %al,%eax
80102990:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102993:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102998:	83 e0 08             	and    $0x8,%eax
8010299b:	85 c0                	test   %eax,%eax
8010299d:	74 22                	je     801029c1 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010299f:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
801029a3:	76 0c                	jbe    801029b1 <kbdgetc+0x13a>
801029a5:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
801029a9:	77 06                	ja     801029b1 <kbdgetc+0x13a>
      c += 'A' - 'a';
801029ab:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
801029af:	eb 10                	jmp    801029c1 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
801029b1:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
801029b5:	76 0a                	jbe    801029c1 <kbdgetc+0x14a>
801029b7:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
801029bb:	77 04                	ja     801029c1 <kbdgetc+0x14a>
      c += 'a' - 'A';
801029bd:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
801029c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801029c4:	c9                   	leave
801029c5:	c3                   	ret

801029c6 <kbdintr>:

void
kbdintr(void)
{
801029c6:	55                   	push   %ebp
801029c7:	89 e5                	mov    %esp,%ebp
801029c9:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
801029cc:	83 ec 0c             	sub    $0xc,%esp
801029cf:	68 77 28 10 80       	push   $0x80102877
801029d4:	e8 15 de ff ff       	call   801007ee <consoleintr>
801029d9:	83 c4 10             	add    $0x10,%esp
}
801029dc:	90                   	nop
801029dd:	c9                   	leave
801029de:	c3                   	ret

801029df <inb>:
{
801029df:	55                   	push   %ebp
801029e0:	89 e5                	mov    %esp,%ebp
801029e2:	83 ec 14             	sub    $0x14,%esp
801029e5:	8b 45 08             	mov    0x8(%ebp),%eax
801029e8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029ec:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801029f0:	89 c2                	mov    %eax,%edx
801029f2:	ec                   	in     (%dx),%al
801029f3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801029f6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801029fa:	c9                   	leave
801029fb:	c3                   	ret

801029fc <outb>:
{
801029fc:	55                   	push   %ebp
801029fd:	89 e5                	mov    %esp,%ebp
801029ff:	83 ec 08             	sub    $0x8,%esp
80102a02:	8b 55 08             	mov    0x8(%ebp),%edx
80102a05:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a08:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102a0c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a0f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102a13:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102a17:	ee                   	out    %al,(%dx)
}
80102a18:	90                   	nop
80102a19:	c9                   	leave
80102a1a:	c3                   	ret

80102a1b <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102a1b:	55                   	push   %ebp
80102a1c:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102a1e:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a23:	8b 55 08             	mov    0x8(%ebp),%edx
80102a26:	c1 e2 02             	shl    $0x2,%edx
80102a29:	01 c2                	add    %eax,%edx
80102a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a2e:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102a30:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a35:	83 c0 20             	add    $0x20,%eax
80102a38:	8b 00                	mov    (%eax),%eax
}
80102a3a:	90                   	nop
80102a3b:	5d                   	pop    %ebp
80102a3c:	c3                   	ret

80102a3d <lapicinit>:

void
lapicinit(void)
{
80102a3d:	55                   	push   %ebp
80102a3e:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102a40:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a45:	85 c0                	test   %eax,%eax
80102a47:	0f 84 09 01 00 00    	je     80102b56 <lapicinit+0x119>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102a4d:	68 3f 01 00 00       	push   $0x13f
80102a52:	6a 3c                	push   $0x3c
80102a54:	e8 c2 ff ff ff       	call   80102a1b <lapicw>
80102a59:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102a5c:	6a 0b                	push   $0xb
80102a5e:	68 f8 00 00 00       	push   $0xf8
80102a63:	e8 b3 ff ff ff       	call   80102a1b <lapicw>
80102a68:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a6b:	68 20 00 02 00       	push   $0x20020
80102a70:	68 c8 00 00 00       	push   $0xc8
80102a75:	e8 a1 ff ff ff       	call   80102a1b <lapicw>
80102a7a:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a7d:	68 80 96 98 00       	push   $0x989680
80102a82:	68 e0 00 00 00       	push   $0xe0
80102a87:	e8 8f ff ff ff       	call   80102a1b <lapicw>
80102a8c:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a8f:	68 00 00 01 00       	push   $0x10000
80102a94:	68 d4 00 00 00       	push   $0xd4
80102a99:	e8 7d ff ff ff       	call   80102a1b <lapicw>
80102a9e:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102aa1:	68 00 00 01 00       	push   $0x10000
80102aa6:	68 d8 00 00 00       	push   $0xd8
80102aab:	e8 6b ff ff ff       	call   80102a1b <lapicw>
80102ab0:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102ab3:	a1 00 41 19 80       	mov    0x80194100,%eax
80102ab8:	83 c0 30             	add    $0x30,%eax
80102abb:	8b 00                	mov    (%eax),%eax
80102abd:	25 00 00 fc 00       	and    $0xfc0000,%eax
80102ac2:	85 c0                	test   %eax,%eax
80102ac4:	74 12                	je     80102ad8 <lapicinit+0x9b>
    lapicw(PCINT, MASKED);
80102ac6:	68 00 00 01 00       	push   $0x10000
80102acb:	68 d0 00 00 00       	push   $0xd0
80102ad0:	e8 46 ff ff ff       	call   80102a1b <lapicw>
80102ad5:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102ad8:	6a 33                	push   $0x33
80102ada:	68 dc 00 00 00       	push   $0xdc
80102adf:	e8 37 ff ff ff       	call   80102a1b <lapicw>
80102ae4:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102ae7:	6a 00                	push   $0x0
80102ae9:	68 a0 00 00 00       	push   $0xa0
80102aee:	e8 28 ff ff ff       	call   80102a1b <lapicw>
80102af3:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102af6:	6a 00                	push   $0x0
80102af8:	68 a0 00 00 00       	push   $0xa0
80102afd:	e8 19 ff ff ff       	call   80102a1b <lapicw>
80102b02:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102b05:	6a 00                	push   $0x0
80102b07:	6a 2c                	push   $0x2c
80102b09:	e8 0d ff ff ff       	call   80102a1b <lapicw>
80102b0e:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102b11:	6a 00                	push   $0x0
80102b13:	68 c4 00 00 00       	push   $0xc4
80102b18:	e8 fe fe ff ff       	call   80102a1b <lapicw>
80102b1d:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102b20:	68 00 85 08 00       	push   $0x88500
80102b25:	68 c0 00 00 00       	push   $0xc0
80102b2a:	e8 ec fe ff ff       	call   80102a1b <lapicw>
80102b2f:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102b32:	90                   	nop
80102b33:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b38:	05 00 03 00 00       	add    $0x300,%eax
80102b3d:	8b 00                	mov    (%eax),%eax
80102b3f:	25 00 10 00 00       	and    $0x1000,%eax
80102b44:	85 c0                	test   %eax,%eax
80102b46:	75 eb                	jne    80102b33 <lapicinit+0xf6>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102b48:	6a 00                	push   $0x0
80102b4a:	6a 20                	push   $0x20
80102b4c:	e8 ca fe ff ff       	call   80102a1b <lapicw>
80102b51:	83 c4 08             	add    $0x8,%esp
80102b54:	eb 01                	jmp    80102b57 <lapicinit+0x11a>
    return;
80102b56:	90                   	nop
}
80102b57:	c9                   	leave
80102b58:	c3                   	ret

80102b59 <lapicid>:

int
lapicid(void)
{
80102b59:	55                   	push   %ebp
80102b5a:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102b5c:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b61:	85 c0                	test   %eax,%eax
80102b63:	75 07                	jne    80102b6c <lapicid+0x13>
    return 0;
80102b65:	b8 00 00 00 00       	mov    $0x0,%eax
80102b6a:	eb 0d                	jmp    80102b79 <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b6c:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b71:	83 c0 20             	add    $0x20,%eax
80102b74:	8b 00                	mov    (%eax),%eax
80102b76:	c1 e8 18             	shr    $0x18,%eax
}
80102b79:	5d                   	pop    %ebp
80102b7a:	c3                   	ret

80102b7b <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b7b:	55                   	push   %ebp
80102b7c:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b7e:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b83:	85 c0                	test   %eax,%eax
80102b85:	74 0c                	je     80102b93 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b87:	6a 00                	push   $0x0
80102b89:	6a 2c                	push   $0x2c
80102b8b:	e8 8b fe ff ff       	call   80102a1b <lapicw>
80102b90:	83 c4 08             	add    $0x8,%esp
}
80102b93:	90                   	nop
80102b94:	c9                   	leave
80102b95:	c3                   	ret

80102b96 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b96:	55                   	push   %ebp
80102b97:	89 e5                	mov    %esp,%ebp
}
80102b99:	90                   	nop
80102b9a:	5d                   	pop    %ebp
80102b9b:	c3                   	ret

80102b9c <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b9c:	55                   	push   %ebp
80102b9d:	89 e5                	mov    %esp,%ebp
80102b9f:	83 ec 14             	sub    $0x14,%esp
80102ba2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba5:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102ba8:	6a 0f                	push   $0xf
80102baa:	6a 70                	push   $0x70
80102bac:	e8 4b fe ff ff       	call   801029fc <outb>
80102bb1:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102bb4:	6a 0a                	push   $0xa
80102bb6:	6a 71                	push   $0x71
80102bb8:	e8 3f fe ff ff       	call   801029fc <outb>
80102bbd:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102bc0:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102bc7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102bca:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bd2:	c1 e8 04             	shr    $0x4,%eax
80102bd5:	89 c2                	mov    %eax,%edx
80102bd7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102bda:	83 c0 02             	add    $0x2,%eax
80102bdd:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102be0:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102be4:	c1 e0 18             	shl    $0x18,%eax
80102be7:	50                   	push   %eax
80102be8:	68 c4 00 00 00       	push   $0xc4
80102bed:	e8 29 fe ff ff       	call   80102a1b <lapicw>
80102bf2:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102bf5:	68 00 c5 00 00       	push   $0xc500
80102bfa:	68 c0 00 00 00       	push   $0xc0
80102bff:	e8 17 fe ff ff       	call   80102a1b <lapicw>
80102c04:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c07:	68 c8 00 00 00       	push   $0xc8
80102c0c:	e8 85 ff ff ff       	call   80102b96 <microdelay>
80102c11:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102c14:	68 00 85 00 00       	push   $0x8500
80102c19:	68 c0 00 00 00       	push   $0xc0
80102c1e:	e8 f8 fd ff ff       	call   80102a1b <lapicw>
80102c23:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102c26:	6a 64                	push   $0x64
80102c28:	e8 69 ff ff ff       	call   80102b96 <microdelay>
80102c2d:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102c30:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102c37:	eb 3d                	jmp    80102c76 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102c39:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102c3d:	c1 e0 18             	shl    $0x18,%eax
80102c40:	50                   	push   %eax
80102c41:	68 c4 00 00 00       	push   $0xc4
80102c46:	e8 d0 fd ff ff       	call   80102a1b <lapicw>
80102c4b:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102c4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c51:	c1 e8 0c             	shr    $0xc,%eax
80102c54:	80 cc 06             	or     $0x6,%ah
80102c57:	50                   	push   %eax
80102c58:	68 c0 00 00 00       	push   $0xc0
80102c5d:	e8 b9 fd ff ff       	call   80102a1b <lapicw>
80102c62:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c65:	68 c8 00 00 00       	push   $0xc8
80102c6a:	e8 27 ff ff ff       	call   80102b96 <microdelay>
80102c6f:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c72:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c76:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c7a:	7e bd                	jle    80102c39 <lapicstartap+0x9d>
  }
}
80102c7c:	90                   	nop
80102c7d:	90                   	nop
80102c7e:	c9                   	leave
80102c7f:	c3                   	ret

80102c80 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c80:	55                   	push   %ebp
80102c81:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c83:	8b 45 08             	mov    0x8(%ebp),%eax
80102c86:	0f b6 c0             	movzbl %al,%eax
80102c89:	50                   	push   %eax
80102c8a:	6a 70                	push   $0x70
80102c8c:	e8 6b fd ff ff       	call   801029fc <outb>
80102c91:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c94:	68 c8 00 00 00       	push   $0xc8
80102c99:	e8 f8 fe ff ff       	call   80102b96 <microdelay>
80102c9e:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102ca1:	6a 71                	push   $0x71
80102ca3:	e8 37 fd ff ff       	call   801029df <inb>
80102ca8:	83 c4 04             	add    $0x4,%esp
80102cab:	0f b6 c0             	movzbl %al,%eax
}
80102cae:	c9                   	leave
80102caf:	c3                   	ret

80102cb0 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102cb0:	55                   	push   %ebp
80102cb1:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102cb3:	6a 00                	push   $0x0
80102cb5:	e8 c6 ff ff ff       	call   80102c80 <cmos_read>
80102cba:	83 c4 04             	add    $0x4,%esp
80102cbd:	8b 55 08             	mov    0x8(%ebp),%edx
80102cc0:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102cc2:	6a 02                	push   $0x2
80102cc4:	e8 b7 ff ff ff       	call   80102c80 <cmos_read>
80102cc9:	83 c4 04             	add    $0x4,%esp
80102ccc:	8b 55 08             	mov    0x8(%ebp),%edx
80102ccf:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102cd2:	6a 04                	push   $0x4
80102cd4:	e8 a7 ff ff ff       	call   80102c80 <cmos_read>
80102cd9:	83 c4 04             	add    $0x4,%esp
80102cdc:	8b 55 08             	mov    0x8(%ebp),%edx
80102cdf:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102ce2:	6a 07                	push   $0x7
80102ce4:	e8 97 ff ff ff       	call   80102c80 <cmos_read>
80102ce9:	83 c4 04             	add    $0x4,%esp
80102cec:	8b 55 08             	mov    0x8(%ebp),%edx
80102cef:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102cf2:	6a 08                	push   $0x8
80102cf4:	e8 87 ff ff ff       	call   80102c80 <cmos_read>
80102cf9:	83 c4 04             	add    $0x4,%esp
80102cfc:	8b 55 08             	mov    0x8(%ebp),%edx
80102cff:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102d02:	6a 09                	push   $0x9
80102d04:	e8 77 ff ff ff       	call   80102c80 <cmos_read>
80102d09:	83 c4 04             	add    $0x4,%esp
80102d0c:	8b 55 08             	mov    0x8(%ebp),%edx
80102d0f:	89 42 14             	mov    %eax,0x14(%edx)
}
80102d12:	90                   	nop
80102d13:	c9                   	leave
80102d14:	c3                   	ret

80102d15 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102d15:	55                   	push   %ebp
80102d16:	89 e5                	mov    %esp,%ebp
80102d18:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102d1b:	6a 0b                	push   $0xb
80102d1d:	e8 5e ff ff ff       	call   80102c80 <cmos_read>
80102d22:	83 c4 04             	add    $0x4,%esp
80102d25:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d2b:	83 e0 04             	and    $0x4,%eax
80102d2e:	85 c0                	test   %eax,%eax
80102d30:	0f 94 c0             	sete   %al
80102d33:	0f b6 c0             	movzbl %al,%eax
80102d36:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102d39:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d3c:	50                   	push   %eax
80102d3d:	e8 6e ff ff ff       	call   80102cb0 <fill_rtcdate>
80102d42:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102d45:	6a 0a                	push   $0xa
80102d47:	e8 34 ff ff ff       	call   80102c80 <cmos_read>
80102d4c:	83 c4 04             	add    $0x4,%esp
80102d4f:	25 80 00 00 00       	and    $0x80,%eax
80102d54:	85 c0                	test   %eax,%eax
80102d56:	75 27                	jne    80102d7f <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102d58:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d5b:	50                   	push   %eax
80102d5c:	e8 4f ff ff ff       	call   80102cb0 <fill_rtcdate>
80102d61:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d64:	83 ec 04             	sub    $0x4,%esp
80102d67:	6a 18                	push   $0x18
80102d69:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d6c:	50                   	push   %eax
80102d6d:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d70:	50                   	push   %eax
80102d71:	e8 28 1e 00 00       	call   80104b9e <memcmp>
80102d76:	83 c4 10             	add    $0x10,%esp
80102d79:	85 c0                	test   %eax,%eax
80102d7b:	74 05                	je     80102d82 <cmostime+0x6d>
80102d7d:	eb ba                	jmp    80102d39 <cmostime+0x24>
        continue;
80102d7f:	90                   	nop
    fill_rtcdate(&t1);
80102d80:	eb b7                	jmp    80102d39 <cmostime+0x24>
      break;
80102d82:	90                   	nop
  }

  // convert
  if(bcd) {
80102d83:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d87:	0f 84 b4 00 00 00    	je     80102e41 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d8d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d90:	c1 e8 04             	shr    $0x4,%eax
80102d93:	89 c2                	mov    %eax,%edx
80102d95:	89 d0                	mov    %edx,%eax
80102d97:	c1 e0 02             	shl    $0x2,%eax
80102d9a:	01 d0                	add    %edx,%eax
80102d9c:	01 c0                	add    %eax,%eax
80102d9e:	89 c2                	mov    %eax,%edx
80102da0:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102da3:	83 e0 0f             	and    $0xf,%eax
80102da6:	01 d0                	add    %edx,%eax
80102da8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102dab:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102dae:	c1 e8 04             	shr    $0x4,%eax
80102db1:	89 c2                	mov    %eax,%edx
80102db3:	89 d0                	mov    %edx,%eax
80102db5:	c1 e0 02             	shl    $0x2,%eax
80102db8:	01 d0                	add    %edx,%eax
80102dba:	01 c0                	add    %eax,%eax
80102dbc:	89 c2                	mov    %eax,%edx
80102dbe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102dc1:	83 e0 0f             	and    $0xf,%eax
80102dc4:	01 d0                	add    %edx,%eax
80102dc6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102dc9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102dcc:	c1 e8 04             	shr    $0x4,%eax
80102dcf:	89 c2                	mov    %eax,%edx
80102dd1:	89 d0                	mov    %edx,%eax
80102dd3:	c1 e0 02             	shl    $0x2,%eax
80102dd6:	01 d0                	add    %edx,%eax
80102dd8:	01 c0                	add    %eax,%eax
80102dda:	89 c2                	mov    %eax,%edx
80102ddc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102ddf:	83 e0 0f             	and    $0xf,%eax
80102de2:	01 d0                	add    %edx,%eax
80102de4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102de7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102dea:	c1 e8 04             	shr    $0x4,%eax
80102ded:	89 c2                	mov    %eax,%edx
80102def:	89 d0                	mov    %edx,%eax
80102df1:	c1 e0 02             	shl    $0x2,%eax
80102df4:	01 d0                	add    %edx,%eax
80102df6:	01 c0                	add    %eax,%eax
80102df8:	89 c2                	mov    %eax,%edx
80102dfa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102dfd:	83 e0 0f             	and    $0xf,%eax
80102e00:	01 d0                	add    %edx,%eax
80102e02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102e05:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e08:	c1 e8 04             	shr    $0x4,%eax
80102e0b:	89 c2                	mov    %eax,%edx
80102e0d:	89 d0                	mov    %edx,%eax
80102e0f:	c1 e0 02             	shl    $0x2,%eax
80102e12:	01 d0                	add    %edx,%eax
80102e14:	01 c0                	add    %eax,%eax
80102e16:	89 c2                	mov    %eax,%edx
80102e18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e1b:	83 e0 0f             	and    $0xf,%eax
80102e1e:	01 d0                	add    %edx,%eax
80102e20:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102e23:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e26:	c1 e8 04             	shr    $0x4,%eax
80102e29:	89 c2                	mov    %eax,%edx
80102e2b:	89 d0                	mov    %edx,%eax
80102e2d:	c1 e0 02             	shl    $0x2,%eax
80102e30:	01 d0                	add    %edx,%eax
80102e32:	01 c0                	add    %eax,%eax
80102e34:	89 c2                	mov    %eax,%edx
80102e36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e39:	83 e0 0f             	and    $0xf,%eax
80102e3c:	01 d0                	add    %edx,%eax
80102e3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102e41:	8b 45 08             	mov    0x8(%ebp),%eax
80102e44:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102e47:	89 10                	mov    %edx,(%eax)
80102e49:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102e4c:	89 50 04             	mov    %edx,0x4(%eax)
80102e4f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102e52:	89 50 08             	mov    %edx,0x8(%eax)
80102e55:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102e58:	89 50 0c             	mov    %edx,0xc(%eax)
80102e5b:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102e5e:	89 50 10             	mov    %edx,0x10(%eax)
80102e61:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e64:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e67:	8b 45 08             	mov    0x8(%ebp),%eax
80102e6a:	8b 40 14             	mov    0x14(%eax),%eax
80102e6d:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e73:	8b 45 08             	mov    0x8(%ebp),%eax
80102e76:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e79:	90                   	nop
80102e7a:	c9                   	leave
80102e7b:	c3                   	ret

80102e7c <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e7c:	55                   	push   %ebp
80102e7d:	89 e5                	mov    %esp,%ebp
80102e7f:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e82:	83 ec 08             	sub    $0x8,%esp
80102e85:	68 1d a6 10 80       	push   $0x8010a61d
80102e8a:	68 20 41 19 80       	push   $0x80194120
80102e8f:	e8 0b 1a 00 00       	call   8010489f <initlock>
80102e94:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e97:	83 ec 08             	sub    $0x8,%esp
80102e9a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e9d:	50                   	push   %eax
80102e9e:	ff 75 08             	push   0x8(%ebp)
80102ea1:	e8 8f e5 ff ff       	call   80101435 <readsb>
80102ea6:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102ea9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102eac:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102eb1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102eb4:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80102ebc:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102ec1:	e8 b3 01 00 00       	call   80103079 <recover_from_log>
}
80102ec6:	90                   	nop
80102ec7:	c9                   	leave
80102ec8:	c3                   	ret

80102ec9 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102ec9:	55                   	push   %ebp
80102eca:	89 e5                	mov    %esp,%ebp
80102ecc:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102ecf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ed6:	e9 95 00 00 00       	jmp    80102f70 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102edb:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ee4:	01 d0                	add    %edx,%eax
80102ee6:	83 c0 01             	add    $0x1,%eax
80102ee9:	89 c2                	mov    %eax,%edx
80102eeb:	a1 64 41 19 80       	mov    0x80194164,%eax
80102ef0:	83 ec 08             	sub    $0x8,%esp
80102ef3:	52                   	push   %edx
80102ef4:	50                   	push   %eax
80102ef5:	e8 07 d3 ff ff       	call   80100201 <bread>
80102efa:	83 c4 10             	add    $0x10,%esp
80102efd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f03:	83 c0 10             	add    $0x10,%eax
80102f06:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102f0d:	89 c2                	mov    %eax,%edx
80102f0f:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f14:	83 ec 08             	sub    $0x8,%esp
80102f17:	52                   	push   %edx
80102f18:	50                   	push   %eax
80102f19:	e8 e3 d2 ff ff       	call   80100201 <bread>
80102f1e:	83 c4 10             	add    $0x10,%esp
80102f21:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102f24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f27:	8d 50 5c             	lea    0x5c(%eax),%edx
80102f2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f2d:	83 c0 5c             	add    $0x5c,%eax
80102f30:	83 ec 04             	sub    $0x4,%esp
80102f33:	68 00 02 00 00       	push   $0x200
80102f38:	52                   	push   %edx
80102f39:	50                   	push   %eax
80102f3a:	e8 b7 1c 00 00       	call   80104bf6 <memmove>
80102f3f:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102f42:	83 ec 0c             	sub    $0xc,%esp
80102f45:	ff 75 ec             	push   -0x14(%ebp)
80102f48:	e8 ed d2 ff ff       	call   8010023a <bwrite>
80102f4d:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102f50:	83 ec 0c             	sub    $0xc,%esp
80102f53:	ff 75 f0             	push   -0x10(%ebp)
80102f56:	e8 28 d3 ff ff       	call   80100283 <brelse>
80102f5b:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102f5e:	83 ec 0c             	sub    $0xc,%esp
80102f61:	ff 75 ec             	push   -0x14(%ebp)
80102f64:	e8 1a d3 ff ff       	call   80100283 <brelse>
80102f69:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f6c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f70:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f75:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f78:	0f 8c 5d ff ff ff    	jl     80102edb <install_trans+0x12>
  }
}
80102f7e:	90                   	nop
80102f7f:	90                   	nop
80102f80:	c9                   	leave
80102f81:	c3                   	ret

80102f82 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f82:	55                   	push   %ebp
80102f83:	89 e5                	mov    %esp,%ebp
80102f85:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f88:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f8d:	89 c2                	mov    %eax,%edx
80102f8f:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f94:	83 ec 08             	sub    $0x8,%esp
80102f97:	52                   	push   %edx
80102f98:	50                   	push   %eax
80102f99:	e8 63 d2 ff ff       	call   80100201 <bread>
80102f9e:	83 c4 10             	add    $0x10,%esp
80102fa1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fa7:	83 c0 5c             	add    $0x5c,%eax
80102faa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102fad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fb0:	8b 00                	mov    (%eax),%eax
80102fb2:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102fb7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fbe:	eb 1b                	jmp    80102fdb <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102fc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fc3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fc6:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102fca:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102fcd:	83 c2 10             	add    $0x10,%edx
80102fd0:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fd7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102fdb:	a1 68 41 19 80       	mov    0x80194168,%eax
80102fe0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102fe3:	7c db                	jl     80102fc0 <read_head+0x3e>
  }
  brelse(buf);
80102fe5:	83 ec 0c             	sub    $0xc,%esp
80102fe8:	ff 75 f0             	push   -0x10(%ebp)
80102feb:	e8 93 d2 ff ff       	call   80100283 <brelse>
80102ff0:	83 c4 10             	add    $0x10,%esp
}
80102ff3:	90                   	nop
80102ff4:	c9                   	leave
80102ff5:	c3                   	ret

80102ff6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102ff6:	55                   	push   %ebp
80102ff7:	89 e5                	mov    %esp,%ebp
80102ff9:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102ffc:	a1 54 41 19 80       	mov    0x80194154,%eax
80103001:	89 c2                	mov    %eax,%edx
80103003:	a1 64 41 19 80       	mov    0x80194164,%eax
80103008:	83 ec 08             	sub    $0x8,%esp
8010300b:	52                   	push   %edx
8010300c:	50                   	push   %eax
8010300d:	e8 ef d1 ff ff       	call   80100201 <bread>
80103012:	83 c4 10             	add    $0x10,%esp
80103015:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103018:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010301b:	83 c0 5c             	add    $0x5c,%eax
8010301e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103021:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80103027:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010302a:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010302c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103033:	eb 1b                	jmp    80103050 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103038:	83 c0 10             	add    $0x10,%eax
8010303b:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80103042:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103045:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103048:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010304c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103050:	a1 68 41 19 80       	mov    0x80194168,%eax
80103055:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103058:	7c db                	jl     80103035 <write_head+0x3f>
  }
  bwrite(buf);
8010305a:	83 ec 0c             	sub    $0xc,%esp
8010305d:	ff 75 f0             	push   -0x10(%ebp)
80103060:	e8 d5 d1 ff ff       	call   8010023a <bwrite>
80103065:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103068:	83 ec 0c             	sub    $0xc,%esp
8010306b:	ff 75 f0             	push   -0x10(%ebp)
8010306e:	e8 10 d2 ff ff       	call   80100283 <brelse>
80103073:	83 c4 10             	add    $0x10,%esp
}
80103076:	90                   	nop
80103077:	c9                   	leave
80103078:	c3                   	ret

80103079 <recover_from_log>:

static void
recover_from_log(void)
{
80103079:	55                   	push   %ebp
8010307a:	89 e5                	mov    %esp,%ebp
8010307c:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010307f:	e8 fe fe ff ff       	call   80102f82 <read_head>
  install_trans(); // if committed, copy from log to disk
80103084:	e8 40 fe ff ff       	call   80102ec9 <install_trans>
  log.lh.n = 0;
80103089:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103090:	00 00 00 
  write_head(); // clear the log
80103093:	e8 5e ff ff ff       	call   80102ff6 <write_head>
}
80103098:	90                   	nop
80103099:	c9                   	leave
8010309a:	c3                   	ret

8010309b <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010309b:	55                   	push   %ebp
8010309c:	89 e5                	mov    %esp,%ebp
8010309e:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801030a1:	83 ec 0c             	sub    $0xc,%esp
801030a4:	68 20 41 19 80       	push   $0x80194120
801030a9:	e8 13 18 00 00       	call   801048c1 <acquire>
801030ae:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801030b1:	a1 60 41 19 80       	mov    0x80194160,%eax
801030b6:	85 c0                	test   %eax,%eax
801030b8:	74 17                	je     801030d1 <begin_op+0x36>
      sleep(&log, &log.lock);
801030ba:	83 ec 08             	sub    $0x8,%esp
801030bd:	68 20 41 19 80       	push   $0x80194120
801030c2:	68 20 41 19 80       	push   $0x80194120
801030c7:	e8 98 12 00 00       	call   80104364 <sleep>
801030cc:	83 c4 10             	add    $0x10,%esp
801030cf:	eb e0                	jmp    801030b1 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801030d1:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
801030d7:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030dc:	8d 50 01             	lea    0x1(%eax),%edx
801030df:	89 d0                	mov    %edx,%eax
801030e1:	c1 e0 02             	shl    $0x2,%eax
801030e4:	01 d0                	add    %edx,%eax
801030e6:	01 c0                	add    %eax,%eax
801030e8:	01 c8                	add    %ecx,%eax
801030ea:	83 f8 1e             	cmp    $0x1e,%eax
801030ed:	7e 17                	jle    80103106 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801030ef:	83 ec 08             	sub    $0x8,%esp
801030f2:	68 20 41 19 80       	push   $0x80194120
801030f7:	68 20 41 19 80       	push   $0x80194120
801030fc:	e8 63 12 00 00       	call   80104364 <sleep>
80103101:	83 c4 10             	add    $0x10,%esp
80103104:	eb ab                	jmp    801030b1 <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103106:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010310b:	83 c0 01             	add    $0x1,%eax
8010310e:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
80103113:	83 ec 0c             	sub    $0xc,%esp
80103116:	68 20 41 19 80       	push   $0x80194120
8010311b:	e8 0f 18 00 00       	call   8010492f <release>
80103120:	83 c4 10             	add    $0x10,%esp
      break;
80103123:	90                   	nop
    }
  }
}
80103124:	90                   	nop
80103125:	c9                   	leave
80103126:	c3                   	ret

80103127 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103127:	55                   	push   %ebp
80103128:	89 e5                	mov    %esp,%ebp
8010312a:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010312d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103134:	83 ec 0c             	sub    $0xc,%esp
80103137:	68 20 41 19 80       	push   $0x80194120
8010313c:	e8 80 17 00 00       	call   801048c1 <acquire>
80103141:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103144:	a1 5c 41 19 80       	mov    0x8019415c,%eax
80103149:	83 e8 01             	sub    $0x1,%eax
8010314c:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
80103151:	a1 60 41 19 80       	mov    0x80194160,%eax
80103156:	85 c0                	test   %eax,%eax
80103158:	74 0d                	je     80103167 <end_op+0x40>
    panic("log.committing");
8010315a:	83 ec 0c             	sub    $0xc,%esp
8010315d:	68 21 a6 10 80       	push   $0x8010a621
80103162:	e8 5a d4 ff ff       	call   801005c1 <panic>
  if(log.outstanding == 0){
80103167:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010316c:	85 c0                	test   %eax,%eax
8010316e:	75 13                	jne    80103183 <end_op+0x5c>
    do_commit = 1;
80103170:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103177:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
8010317e:	00 00 00 
80103181:	eb 10                	jmp    80103193 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103183:	83 ec 0c             	sub    $0xc,%esp
80103186:	68 20 41 19 80       	push   $0x80194120
8010318b:	e8 bb 12 00 00       	call   8010444b <wakeup>
80103190:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103193:	83 ec 0c             	sub    $0xc,%esp
80103196:	68 20 41 19 80       	push   $0x80194120
8010319b:	e8 8f 17 00 00       	call   8010492f <release>
801031a0:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801031a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801031a7:	74 3f                	je     801031e8 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801031a9:	e8 f6 00 00 00       	call   801032a4 <commit>
    acquire(&log.lock);
801031ae:	83 ec 0c             	sub    $0xc,%esp
801031b1:	68 20 41 19 80       	push   $0x80194120
801031b6:	e8 06 17 00 00       	call   801048c1 <acquire>
801031bb:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
801031be:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
801031c5:	00 00 00 
    wakeup(&log);
801031c8:	83 ec 0c             	sub    $0xc,%esp
801031cb:	68 20 41 19 80       	push   $0x80194120
801031d0:	e8 76 12 00 00       	call   8010444b <wakeup>
801031d5:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801031d8:	83 ec 0c             	sub    $0xc,%esp
801031db:	68 20 41 19 80       	push   $0x80194120
801031e0:	e8 4a 17 00 00       	call   8010492f <release>
801031e5:	83 c4 10             	add    $0x10,%esp
  }
}
801031e8:	90                   	nop
801031e9:	c9                   	leave
801031ea:	c3                   	ret

801031eb <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801031eb:	55                   	push   %ebp
801031ec:	89 e5                	mov    %esp,%ebp
801031ee:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801031f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801031f8:	e9 95 00 00 00       	jmp    80103292 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801031fd:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80103203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103206:	01 d0                	add    %edx,%eax
80103208:	83 c0 01             	add    $0x1,%eax
8010320b:	89 c2                	mov    %eax,%edx
8010320d:	a1 64 41 19 80       	mov    0x80194164,%eax
80103212:	83 ec 08             	sub    $0x8,%esp
80103215:	52                   	push   %edx
80103216:	50                   	push   %eax
80103217:	e8 e5 cf ff ff       	call   80100201 <bread>
8010321c:	83 c4 10             	add    $0x10,%esp
8010321f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103222:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103225:	83 c0 10             	add    $0x10,%eax
80103228:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
8010322f:	89 c2                	mov    %eax,%edx
80103231:	a1 64 41 19 80       	mov    0x80194164,%eax
80103236:	83 ec 08             	sub    $0x8,%esp
80103239:	52                   	push   %edx
8010323a:	50                   	push   %eax
8010323b:	e8 c1 cf ff ff       	call   80100201 <bread>
80103240:	83 c4 10             	add    $0x10,%esp
80103243:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103246:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103249:	8d 50 5c             	lea    0x5c(%eax),%edx
8010324c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010324f:	83 c0 5c             	add    $0x5c,%eax
80103252:	83 ec 04             	sub    $0x4,%esp
80103255:	68 00 02 00 00       	push   $0x200
8010325a:	52                   	push   %edx
8010325b:	50                   	push   %eax
8010325c:	e8 95 19 00 00       	call   80104bf6 <memmove>
80103261:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103264:	83 ec 0c             	sub    $0xc,%esp
80103267:	ff 75 f0             	push   -0x10(%ebp)
8010326a:	e8 cb cf ff ff       	call   8010023a <bwrite>
8010326f:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103272:	83 ec 0c             	sub    $0xc,%esp
80103275:	ff 75 ec             	push   -0x14(%ebp)
80103278:	e8 06 d0 ff ff       	call   80100283 <brelse>
8010327d:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103280:	83 ec 0c             	sub    $0xc,%esp
80103283:	ff 75 f0             	push   -0x10(%ebp)
80103286:	e8 f8 cf ff ff       	call   80100283 <brelse>
8010328b:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010328e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103292:	a1 68 41 19 80       	mov    0x80194168,%eax
80103297:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010329a:	0f 8c 5d ff ff ff    	jl     801031fd <write_log+0x12>
  }
}
801032a0:	90                   	nop
801032a1:	90                   	nop
801032a2:	c9                   	leave
801032a3:	c3                   	ret

801032a4 <commit>:

static void
commit()
{
801032a4:	55                   	push   %ebp
801032a5:	89 e5                	mov    %esp,%ebp
801032a7:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801032aa:	a1 68 41 19 80       	mov    0x80194168,%eax
801032af:	85 c0                	test   %eax,%eax
801032b1:	7e 1e                	jle    801032d1 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801032b3:	e8 33 ff ff ff       	call   801031eb <write_log>
    write_head();    // Write header to disk -- the real commit
801032b8:	e8 39 fd ff ff       	call   80102ff6 <write_head>
    install_trans(); // Now install writes to home locations
801032bd:	e8 07 fc ff ff       	call   80102ec9 <install_trans>
    log.lh.n = 0;
801032c2:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
801032c9:	00 00 00 
    write_head();    // Erase the transaction from the log
801032cc:	e8 25 fd ff ff       	call   80102ff6 <write_head>
  }
}
801032d1:	90                   	nop
801032d2:	c9                   	leave
801032d3:	c3                   	ret

801032d4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801032d4:	55                   	push   %ebp
801032d5:	89 e5                	mov    %esp,%ebp
801032d7:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801032da:	a1 68 41 19 80       	mov    0x80194168,%eax
801032df:	83 f8 1d             	cmp    $0x1d,%eax
801032e2:	7f 12                	jg     801032f6 <log_write+0x22>
801032e4:	8b 15 68 41 19 80    	mov    0x80194168,%edx
801032ea:	a1 58 41 19 80       	mov    0x80194158,%eax
801032ef:	83 e8 01             	sub    $0x1,%eax
801032f2:	39 c2                	cmp    %eax,%edx
801032f4:	7c 0d                	jl     80103303 <log_write+0x2f>
    panic("too big a transaction");
801032f6:	83 ec 0c             	sub    $0xc,%esp
801032f9:	68 30 a6 10 80       	push   $0x8010a630
801032fe:	e8 be d2 ff ff       	call   801005c1 <panic>
  if (log.outstanding < 1)
80103303:	a1 5c 41 19 80       	mov    0x8019415c,%eax
80103308:	85 c0                	test   %eax,%eax
8010330a:	7f 0d                	jg     80103319 <log_write+0x45>
    panic("log_write outside of trans");
8010330c:	83 ec 0c             	sub    $0xc,%esp
8010330f:	68 46 a6 10 80       	push   $0x8010a646
80103314:	e8 a8 d2 ff ff       	call   801005c1 <panic>

  acquire(&log.lock);
80103319:	83 ec 0c             	sub    $0xc,%esp
8010331c:	68 20 41 19 80       	push   $0x80194120
80103321:	e8 9b 15 00 00       	call   801048c1 <acquire>
80103326:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103329:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103330:	eb 1d                	jmp    8010334f <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103332:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103335:	83 c0 10             	add    $0x10,%eax
80103338:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
8010333f:	89 c2                	mov    %eax,%edx
80103341:	8b 45 08             	mov    0x8(%ebp),%eax
80103344:	8b 40 08             	mov    0x8(%eax),%eax
80103347:	39 c2                	cmp    %eax,%edx
80103349:	74 10                	je     8010335b <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
8010334b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010334f:	a1 68 41 19 80       	mov    0x80194168,%eax
80103354:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103357:	7c d9                	jl     80103332 <log_write+0x5e>
80103359:	eb 01                	jmp    8010335c <log_write+0x88>
      break;
8010335b:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
8010335c:	8b 45 08             	mov    0x8(%ebp),%eax
8010335f:	8b 40 08             	mov    0x8(%eax),%eax
80103362:	89 c2                	mov    %eax,%edx
80103364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103367:	83 c0 10             	add    $0x10,%eax
8010336a:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103371:	a1 68 41 19 80       	mov    0x80194168,%eax
80103376:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103379:	75 0d                	jne    80103388 <log_write+0xb4>
    log.lh.n++;
8010337b:	a1 68 41 19 80       	mov    0x80194168,%eax
80103380:	83 c0 01             	add    $0x1,%eax
80103383:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
80103388:	8b 45 08             	mov    0x8(%ebp),%eax
8010338b:	8b 00                	mov    (%eax),%eax
8010338d:	83 c8 04             	or     $0x4,%eax
80103390:	89 c2                	mov    %eax,%edx
80103392:	8b 45 08             	mov    0x8(%ebp),%eax
80103395:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103397:	83 ec 0c             	sub    $0xc,%esp
8010339a:	68 20 41 19 80       	push   $0x80194120
8010339f:	e8 8b 15 00 00       	call   8010492f <release>
801033a4:	83 c4 10             	add    $0x10,%esp
}
801033a7:	90                   	nop
801033a8:	c9                   	leave
801033a9:	c3                   	ret

801033aa <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801033aa:	55                   	push   %ebp
801033ab:	89 e5                	mov    %esp,%ebp
801033ad:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801033b0:	8b 55 08             	mov    0x8(%ebp),%edx
801033b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801033b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801033b9:	f0 87 02             	lock xchg %eax,(%edx)
801033bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801033bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801033c2:	c9                   	leave
801033c3:	c3                   	ret

801033c4 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801033c4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801033c8:	83 e4 f0             	and    $0xfffffff0,%esp
801033cb:	ff 71 fc             	push   -0x4(%ecx)
801033ce:	55                   	push   %ebp
801033cf:	89 e5                	mov    %esp,%ebp
801033d1:	51                   	push   %ecx
801033d2:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
801033d5:	e8 58 4d 00 00       	call   80108132 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801033da:	83 ec 08             	sub    $0x8,%esp
801033dd:	68 00 00 40 80       	push   $0x80400000
801033e2:	68 00 80 19 80       	push   $0x80198000
801033e7:	e8 e4 f2 ff ff       	call   801026d0 <kinit1>
801033ec:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801033ef:	e8 71 43 00 00       	call   80107765 <kvmalloc>
  mpinit_uefi();
801033f4:	e8 03 4b 00 00       	call   80107efc <mpinit_uefi>
  lapicinit();     // interrupt controller
801033f9:	e8 3f f6 ff ff       	call   80102a3d <lapicinit>
  seginit();       // segment descriptors
801033fe:	e8 f9 3d 00 00       	call   801071fc <seginit>
  picinit();    // disable pic
80103403:	e8 9b 01 00 00       	call   801035a3 <picinit>
  ioapicinit();    // another interrupt controller
80103408:	e8 de f1 ff ff       	call   801025eb <ioapicinit>
  consoleinit();   // console hardware
8010340d:	e8 0f d7 ff ff       	call   80100b21 <consoleinit>
  uartinit();      // serial port
80103412:	e8 7e 31 00 00       	call   80106595 <uartinit>
  pinit();         // process table
80103417:	e8 c0 05 00 00       	call   801039dc <pinit>
  tvinit();        // trap vectors
8010341c:	e8 50 2c 00 00       	call   80106071 <tvinit>
  binit();         // buffer cache
80103421:	e8 40 cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103426:	e8 fb db ff ff       	call   80101026 <fileinit>
  ideinit();       // disk 
8010342b:	e8 2d 6e 00 00       	call   8010a25d <ideinit>
  startothers();   // start other processors
80103430:	e8 8a 00 00 00       	call   801034bf <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103435:	83 ec 08             	sub    $0x8,%esp
80103438:	68 00 00 00 a0       	push   $0xa0000000
8010343d:	68 00 00 40 80       	push   $0x80400000
80103442:	e8 c2 f2 ff ff       	call   80102709 <kinit2>
80103447:	83 c4 10             	add    $0x10,%esp
  pci_init();
8010344a:	e8 3e 4f 00 00       	call   8010838d <pci_init>
  arp_scan();
8010344f:	e8 73 5c 00 00       	call   801090c7 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
80103454:	e8 61 07 00 00       	call   80103bba <userinit>
  mpmain();        // finish this processor's setup
80103459:	e8 1a 00 00 00       	call   80103478 <mpmain>

8010345e <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010345e:	55                   	push   %ebp
8010345f:	89 e5                	mov    %esp,%ebp
80103461:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103464:	e8 14 43 00 00       	call   8010777d <switchkvm>
  seginit();
80103469:	e8 8e 3d 00 00       	call   801071fc <seginit>
  lapicinit();
8010346e:	e8 ca f5 ff ff       	call   80102a3d <lapicinit>
  mpmain();
80103473:	e8 00 00 00 00       	call   80103478 <mpmain>

80103478 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103478:	55                   	push   %ebp
80103479:	89 e5                	mov    %esp,%ebp
8010347b:	53                   	push   %ebx
8010347c:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
8010347f:	e8 76 05 00 00       	call   801039fa <cpuid>
80103484:	89 c3                	mov    %eax,%ebx
80103486:	e8 6f 05 00 00       	call   801039fa <cpuid>
8010348b:	83 ec 04             	sub    $0x4,%esp
8010348e:	53                   	push   %ebx
8010348f:	50                   	push   %eax
80103490:	68 61 a6 10 80       	push   $0x8010a661
80103495:	e8 5a cf ff ff       	call   801003f4 <cprintf>
8010349a:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010349d:	e8 45 2d 00 00       	call   801061e7 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801034a2:	e8 6e 05 00 00       	call   80103a15 <mycpu>
801034a7:	05 a0 00 00 00       	add    $0xa0,%eax
801034ac:	83 ec 08             	sub    $0x8,%esp
801034af:	6a 01                	push   $0x1
801034b1:	50                   	push   %eax
801034b2:	e8 f3 fe ff ff       	call   801033aa <xchg>
801034b7:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801034ba:	e8 96 0c 00 00       	call   80104155 <scheduler>

801034bf <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801034bf:	55                   	push   %ebp
801034c0:	89 e5                	mov    %esp,%ebp
801034c2:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801034c5:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801034cc:	b8 8a 00 00 00       	mov    $0x8a,%eax
801034d1:	83 ec 04             	sub    $0x4,%esp
801034d4:	50                   	push   %eax
801034d5:	68 18 f5 10 80       	push   $0x8010f518
801034da:	ff 75 f0             	push   -0x10(%ebp)
801034dd:	e8 14 17 00 00       	call   80104bf6 <memmove>
801034e2:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801034e5:	c7 45 f4 80 6a 19 80 	movl   $0x80196a80,-0xc(%ebp)
801034ec:	eb 79                	jmp    80103567 <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
801034ee:	e8 22 05 00 00       	call   80103a15 <mycpu>
801034f3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034f6:	74 67                	je     8010355f <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801034f8:	e8 08 f3 ff ff       	call   80102805 <kalloc>
801034fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103500:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103503:	83 e8 04             	sub    $0x4,%eax
80103506:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103509:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010350f:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103511:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103514:	83 e8 08             	sub    $0x8,%eax
80103517:	c7 00 5e 34 10 80    	movl   $0x8010345e,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
8010351d:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
80103522:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103528:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010352b:	83 e8 0c             	sub    $0xc,%eax
8010352e:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103533:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103539:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010353c:	0f b6 00             	movzbl (%eax),%eax
8010353f:	0f b6 c0             	movzbl %al,%eax
80103542:	83 ec 08             	sub    $0x8,%esp
80103545:	52                   	push   %edx
80103546:	50                   	push   %eax
80103547:	e8 50 f6 ff ff       	call   80102b9c <lapicstartap>
8010354c:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010354f:	90                   	nop
80103550:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103553:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103559:	85 c0                	test   %eax,%eax
8010355b:	74 f3                	je     80103550 <startothers+0x91>
8010355d:	eb 01                	jmp    80103560 <startothers+0xa1>
      continue;
8010355f:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103560:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103567:	a1 30 6b 19 80       	mov    0x80196b30,%eax
8010356c:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103572:	05 80 6a 19 80       	add    $0x80196a80,%eax
80103577:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010357a:	0f 82 6e ff ff ff    	jb     801034ee <startothers+0x2f>
      ;
  }
}
80103580:	90                   	nop
80103581:	90                   	nop
80103582:	c9                   	leave
80103583:	c3                   	ret

80103584 <outb>:
{
80103584:	55                   	push   %ebp
80103585:	89 e5                	mov    %esp,%ebp
80103587:	83 ec 08             	sub    $0x8,%esp
8010358a:	8b 55 08             	mov    0x8(%ebp),%edx
8010358d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103590:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103594:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103597:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010359b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010359f:	ee                   	out    %al,(%dx)
}
801035a0:	90                   	nop
801035a1:	c9                   	leave
801035a2:	c3                   	ret

801035a3 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
801035a3:	55                   	push   %ebp
801035a4:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801035a6:	68 ff 00 00 00       	push   $0xff
801035ab:	6a 21                	push   $0x21
801035ad:	e8 d2 ff ff ff       	call   80103584 <outb>
801035b2:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
801035b5:	68 ff 00 00 00       	push   $0xff
801035ba:	68 a1 00 00 00       	push   $0xa1
801035bf:	e8 c0 ff ff ff       	call   80103584 <outb>
801035c4:	83 c4 08             	add    $0x8,%esp
}
801035c7:	90                   	nop
801035c8:	c9                   	leave
801035c9:	c3                   	ret

801035ca <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801035ca:	55                   	push   %ebp
801035cb:	89 e5                	mov    %esp,%ebp
801035cd:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801035d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801035d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801035da:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801035e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801035e3:	8b 10                	mov    (%eax),%edx
801035e5:	8b 45 08             	mov    0x8(%ebp),%eax
801035e8:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801035ea:	e8 55 da ff ff       	call   80101044 <filealloc>
801035ef:	8b 55 08             	mov    0x8(%ebp),%edx
801035f2:	89 02                	mov    %eax,(%edx)
801035f4:	8b 45 08             	mov    0x8(%ebp),%eax
801035f7:	8b 00                	mov    (%eax),%eax
801035f9:	85 c0                	test   %eax,%eax
801035fb:	0f 84 c8 00 00 00    	je     801036c9 <pipealloc+0xff>
80103601:	e8 3e da ff ff       	call   80101044 <filealloc>
80103606:	8b 55 0c             	mov    0xc(%ebp),%edx
80103609:	89 02                	mov    %eax,(%edx)
8010360b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010360e:	8b 00                	mov    (%eax),%eax
80103610:	85 c0                	test   %eax,%eax
80103612:	0f 84 b1 00 00 00    	je     801036c9 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103618:	e8 e8 f1 ff ff       	call   80102805 <kalloc>
8010361d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103620:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103624:	0f 84 a2 00 00 00    	je     801036cc <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
8010362a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010362d:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103634:	00 00 00 
  p->writeopen = 1;
80103637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010363a:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103641:	00 00 00 
  p->nwrite = 0;
80103644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103647:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010364e:	00 00 00 
  p->nread = 0;
80103651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103654:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010365b:	00 00 00 
  initlock(&p->lock, "pipe");
8010365e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103661:	83 ec 08             	sub    $0x8,%esp
80103664:	68 75 a6 10 80       	push   $0x8010a675
80103669:	50                   	push   %eax
8010366a:	e8 30 12 00 00       	call   8010489f <initlock>
8010366f:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103672:	8b 45 08             	mov    0x8(%ebp),%eax
80103675:	8b 00                	mov    (%eax),%eax
80103677:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010367d:	8b 45 08             	mov    0x8(%ebp),%eax
80103680:	8b 00                	mov    (%eax),%eax
80103682:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103686:	8b 45 08             	mov    0x8(%ebp),%eax
80103689:	8b 00                	mov    (%eax),%eax
8010368b:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010368f:	8b 45 08             	mov    0x8(%ebp),%eax
80103692:	8b 00                	mov    (%eax),%eax
80103694:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103697:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010369a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010369d:	8b 00                	mov    (%eax),%eax
8010369f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801036a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a8:	8b 00                	mov    (%eax),%eax
801036aa:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801036ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801036b1:	8b 00                	mov    (%eax),%eax
801036b3:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801036b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801036ba:	8b 00                	mov    (%eax),%eax
801036bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036bf:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801036c2:	b8 00 00 00 00       	mov    $0x0,%eax
801036c7:	eb 51                	jmp    8010371a <pipealloc+0x150>
    goto bad;
801036c9:	90                   	nop
801036ca:	eb 01                	jmp    801036cd <pipealloc+0x103>
    goto bad;
801036cc:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
801036cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801036d1:	74 0e                	je     801036e1 <pipealloc+0x117>
    kfree((char*)p);
801036d3:	83 ec 0c             	sub    $0xc,%esp
801036d6:	ff 75 f4             	push   -0xc(%ebp)
801036d9:	e8 8d f0 ff ff       	call   8010276b <kfree>
801036de:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801036e1:	8b 45 08             	mov    0x8(%ebp),%eax
801036e4:	8b 00                	mov    (%eax),%eax
801036e6:	85 c0                	test   %eax,%eax
801036e8:	74 11                	je     801036fb <pipealloc+0x131>
    fileclose(*f0);
801036ea:	8b 45 08             	mov    0x8(%ebp),%eax
801036ed:	8b 00                	mov    (%eax),%eax
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	50                   	push   %eax
801036f3:	e8 0a da ff ff       	call   80101102 <fileclose>
801036f8:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801036fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801036fe:	8b 00                	mov    (%eax),%eax
80103700:	85 c0                	test   %eax,%eax
80103702:	74 11                	je     80103715 <pipealloc+0x14b>
    fileclose(*f1);
80103704:	8b 45 0c             	mov    0xc(%ebp),%eax
80103707:	8b 00                	mov    (%eax),%eax
80103709:	83 ec 0c             	sub    $0xc,%esp
8010370c:	50                   	push   %eax
8010370d:	e8 f0 d9 ff ff       	call   80101102 <fileclose>
80103712:	83 c4 10             	add    $0x10,%esp
  return -1;
80103715:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010371a:	c9                   	leave
8010371b:	c3                   	ret

8010371c <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010371c:	55                   	push   %ebp
8010371d:	89 e5                	mov    %esp,%ebp
8010371f:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103722:	8b 45 08             	mov    0x8(%ebp),%eax
80103725:	83 ec 0c             	sub    $0xc,%esp
80103728:	50                   	push   %eax
80103729:	e8 93 11 00 00       	call   801048c1 <acquire>
8010372e:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103731:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103735:	74 23                	je     8010375a <pipeclose+0x3e>
    p->writeopen = 0;
80103737:	8b 45 08             	mov    0x8(%ebp),%eax
8010373a:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103741:	00 00 00 
    wakeup(&p->nread);
80103744:	8b 45 08             	mov    0x8(%ebp),%eax
80103747:	05 34 02 00 00       	add    $0x234,%eax
8010374c:	83 ec 0c             	sub    $0xc,%esp
8010374f:	50                   	push   %eax
80103750:	e8 f6 0c 00 00       	call   8010444b <wakeup>
80103755:	83 c4 10             	add    $0x10,%esp
80103758:	eb 21                	jmp    8010377b <pipeclose+0x5f>
  } else {
    p->readopen = 0;
8010375a:	8b 45 08             	mov    0x8(%ebp),%eax
8010375d:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103764:	00 00 00 
    wakeup(&p->nwrite);
80103767:	8b 45 08             	mov    0x8(%ebp),%eax
8010376a:	05 38 02 00 00       	add    $0x238,%eax
8010376f:	83 ec 0c             	sub    $0xc,%esp
80103772:	50                   	push   %eax
80103773:	e8 d3 0c 00 00       	call   8010444b <wakeup>
80103778:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010377b:	8b 45 08             	mov    0x8(%ebp),%eax
8010377e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103784:	85 c0                	test   %eax,%eax
80103786:	75 2c                	jne    801037b4 <pipeclose+0x98>
80103788:	8b 45 08             	mov    0x8(%ebp),%eax
8010378b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103791:	85 c0                	test   %eax,%eax
80103793:	75 1f                	jne    801037b4 <pipeclose+0x98>
    release(&p->lock);
80103795:	8b 45 08             	mov    0x8(%ebp),%eax
80103798:	83 ec 0c             	sub    $0xc,%esp
8010379b:	50                   	push   %eax
8010379c:	e8 8e 11 00 00       	call   8010492f <release>
801037a1:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801037a4:	83 ec 0c             	sub    $0xc,%esp
801037a7:	ff 75 08             	push   0x8(%ebp)
801037aa:	e8 bc ef ff ff       	call   8010276b <kfree>
801037af:	83 c4 10             	add    $0x10,%esp
801037b2:	eb 10                	jmp    801037c4 <pipeclose+0xa8>
  } else
    release(&p->lock);
801037b4:	8b 45 08             	mov    0x8(%ebp),%eax
801037b7:	83 ec 0c             	sub    $0xc,%esp
801037ba:	50                   	push   %eax
801037bb:	e8 6f 11 00 00       	call   8010492f <release>
801037c0:	83 c4 10             	add    $0x10,%esp
}
801037c3:	90                   	nop
801037c4:	90                   	nop
801037c5:	c9                   	leave
801037c6:	c3                   	ret

801037c7 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801037c7:	55                   	push   %ebp
801037c8:	89 e5                	mov    %esp,%ebp
801037ca:	53                   	push   %ebx
801037cb:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801037ce:	8b 45 08             	mov    0x8(%ebp),%eax
801037d1:	83 ec 0c             	sub    $0xc,%esp
801037d4:	50                   	push   %eax
801037d5:	e8 e7 10 00 00       	call   801048c1 <acquire>
801037da:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801037dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037e4:	e9 ad 00 00 00       	jmp    80103896 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
801037e9:	8b 45 08             	mov    0x8(%ebp),%eax
801037ec:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801037f2:	85 c0                	test   %eax,%eax
801037f4:	74 0c                	je     80103802 <pipewrite+0x3b>
801037f6:	e8 92 02 00 00       	call   80103a8d <myproc>
801037fb:	8b 40 24             	mov    0x24(%eax),%eax
801037fe:	85 c0                	test   %eax,%eax
80103800:	74 19                	je     8010381b <pipewrite+0x54>
        release(&p->lock);
80103802:	8b 45 08             	mov    0x8(%ebp),%eax
80103805:	83 ec 0c             	sub    $0xc,%esp
80103808:	50                   	push   %eax
80103809:	e8 21 11 00 00       	call   8010492f <release>
8010380e:	83 c4 10             	add    $0x10,%esp
        return -1;
80103811:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103816:	e9 a9 00 00 00       	jmp    801038c4 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
8010381b:	8b 45 08             	mov    0x8(%ebp),%eax
8010381e:	05 34 02 00 00       	add    $0x234,%eax
80103823:	83 ec 0c             	sub    $0xc,%esp
80103826:	50                   	push   %eax
80103827:	e8 1f 0c 00 00       	call   8010444b <wakeup>
8010382c:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010382f:	8b 45 08             	mov    0x8(%ebp),%eax
80103832:	8b 55 08             	mov    0x8(%ebp),%edx
80103835:	81 c2 38 02 00 00    	add    $0x238,%edx
8010383b:	83 ec 08             	sub    $0x8,%esp
8010383e:	50                   	push   %eax
8010383f:	52                   	push   %edx
80103840:	e8 1f 0b 00 00       	call   80104364 <sleep>
80103845:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103848:	8b 45 08             	mov    0x8(%ebp),%eax
8010384b:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103851:	8b 45 08             	mov    0x8(%ebp),%eax
80103854:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010385a:	05 00 02 00 00       	add    $0x200,%eax
8010385f:	39 c2                	cmp    %eax,%edx
80103861:	74 86                	je     801037e9 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103863:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103866:	8b 45 0c             	mov    0xc(%ebp),%eax
80103869:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010386c:	8b 45 08             	mov    0x8(%ebp),%eax
8010386f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103875:	8d 48 01             	lea    0x1(%eax),%ecx
80103878:	8b 55 08             	mov    0x8(%ebp),%edx
8010387b:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103881:	25 ff 01 00 00       	and    $0x1ff,%eax
80103886:	89 c1                	mov    %eax,%ecx
80103888:	0f b6 13             	movzbl (%ebx),%edx
8010388b:	8b 45 08             	mov    0x8(%ebp),%eax
8010388e:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103892:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103899:	3b 45 10             	cmp    0x10(%ebp),%eax
8010389c:	7c aa                	jl     80103848 <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010389e:	8b 45 08             	mov    0x8(%ebp),%eax
801038a1:	05 34 02 00 00       	add    $0x234,%eax
801038a6:	83 ec 0c             	sub    $0xc,%esp
801038a9:	50                   	push   %eax
801038aa:	e8 9c 0b 00 00       	call   8010444b <wakeup>
801038af:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801038b2:	8b 45 08             	mov    0x8(%ebp),%eax
801038b5:	83 ec 0c             	sub    $0xc,%esp
801038b8:	50                   	push   %eax
801038b9:	e8 71 10 00 00       	call   8010492f <release>
801038be:	83 c4 10             	add    $0x10,%esp
  return n;
801038c1:	8b 45 10             	mov    0x10(%ebp),%eax
}
801038c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038c7:	c9                   	leave
801038c8:	c3                   	ret

801038c9 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801038c9:	55                   	push   %ebp
801038ca:	89 e5                	mov    %esp,%ebp
801038cc:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801038cf:	8b 45 08             	mov    0x8(%ebp),%eax
801038d2:	83 ec 0c             	sub    $0xc,%esp
801038d5:	50                   	push   %eax
801038d6:	e8 e6 0f 00 00       	call   801048c1 <acquire>
801038db:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038de:	eb 3e                	jmp    8010391e <piperead+0x55>
    if(myproc()->killed){
801038e0:	e8 a8 01 00 00       	call   80103a8d <myproc>
801038e5:	8b 40 24             	mov    0x24(%eax),%eax
801038e8:	85 c0                	test   %eax,%eax
801038ea:	74 19                	je     80103905 <piperead+0x3c>
      release(&p->lock);
801038ec:	8b 45 08             	mov    0x8(%ebp),%eax
801038ef:	83 ec 0c             	sub    $0xc,%esp
801038f2:	50                   	push   %eax
801038f3:	e8 37 10 00 00       	call   8010492f <release>
801038f8:	83 c4 10             	add    $0x10,%esp
      return -1;
801038fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103900:	e9 be 00 00 00       	jmp    801039c3 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103905:	8b 45 08             	mov    0x8(%ebp),%eax
80103908:	8b 55 08             	mov    0x8(%ebp),%edx
8010390b:	81 c2 34 02 00 00    	add    $0x234,%edx
80103911:	83 ec 08             	sub    $0x8,%esp
80103914:	50                   	push   %eax
80103915:	52                   	push   %edx
80103916:	e8 49 0a 00 00       	call   80104364 <sleep>
8010391b:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010391e:	8b 45 08             	mov    0x8(%ebp),%eax
80103921:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103930:	39 c2                	cmp    %eax,%edx
80103932:	75 0d                	jne    80103941 <piperead+0x78>
80103934:	8b 45 08             	mov    0x8(%ebp),%eax
80103937:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010393d:	85 c0                	test   %eax,%eax
8010393f:	75 9f                	jne    801038e0 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103948:	eb 48                	jmp    80103992 <piperead+0xc9>
    if(p->nread == p->nwrite)
8010394a:	8b 45 08             	mov    0x8(%ebp),%eax
8010394d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103953:	8b 45 08             	mov    0x8(%ebp),%eax
80103956:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010395c:	39 c2                	cmp    %eax,%edx
8010395e:	74 3c                	je     8010399c <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103960:	8b 45 08             	mov    0x8(%ebp),%eax
80103963:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103969:	8d 48 01             	lea    0x1(%eax),%ecx
8010396c:	8b 55 08             	mov    0x8(%ebp),%edx
8010396f:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103975:	25 ff 01 00 00       	and    $0x1ff,%eax
8010397a:	89 c1                	mov    %eax,%ecx
8010397c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010397f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103982:	01 c2                	add    %eax,%edx
80103984:	8b 45 08             	mov    0x8(%ebp),%eax
80103987:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010398c:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010398e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103995:	3b 45 10             	cmp    0x10(%ebp),%eax
80103998:	7c b0                	jl     8010394a <piperead+0x81>
8010399a:	eb 01                	jmp    8010399d <piperead+0xd4>
      break;
8010399c:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010399d:	8b 45 08             	mov    0x8(%ebp),%eax
801039a0:	05 38 02 00 00       	add    $0x238,%eax
801039a5:	83 ec 0c             	sub    $0xc,%esp
801039a8:	50                   	push   %eax
801039a9:	e8 9d 0a 00 00       	call   8010444b <wakeup>
801039ae:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801039b1:	8b 45 08             	mov    0x8(%ebp),%eax
801039b4:	83 ec 0c             	sub    $0xc,%esp
801039b7:	50                   	push   %eax
801039b8:	e8 72 0f 00 00       	call   8010492f <release>
801039bd:	83 c4 10             	add    $0x10,%esp
  return i;
801039c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801039c3:	c9                   	leave
801039c4:	c3                   	ret

801039c5 <readeflags>:
{
801039c5:	55                   	push   %ebp
801039c6:	89 e5                	mov    %esp,%ebp
801039c8:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801039cb:	9c                   	pushf
801039cc:	58                   	pop    %eax
801039cd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801039d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801039d3:	c9                   	leave
801039d4:	c3                   	ret

801039d5 <sti>:
{
801039d5:	55                   	push   %ebp
801039d6:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801039d8:	fb                   	sti
}
801039d9:	90                   	nop
801039da:	5d                   	pop    %ebp
801039db:	c3                   	ret

801039dc <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801039dc:	55                   	push   %ebp
801039dd:	89 e5                	mov    %esp,%ebp
801039df:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801039e2:	83 ec 08             	sub    $0x8,%esp
801039e5:	68 7c a6 10 80       	push   $0x8010a67c
801039ea:	68 00 42 19 80       	push   $0x80194200
801039ef:	e8 ab 0e 00 00       	call   8010489f <initlock>
801039f4:	83 c4 10             	add    $0x10,%esp
}
801039f7:	90                   	nop
801039f8:	c9                   	leave
801039f9:	c3                   	ret

801039fa <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
801039fa:	55                   	push   %ebp
801039fb:	89 e5                	mov    %esp,%ebp
801039fd:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103a00:	e8 10 00 00 00       	call   80103a15 <mycpu>
80103a05:	2d 80 6a 19 80       	sub    $0x80196a80,%eax
80103a0a:	c1 f8 04             	sar    $0x4,%eax
80103a0d:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103a13:	c9                   	leave
80103a14:	c3                   	ret

80103a15 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103a15:	55                   	push   %ebp
80103a16:	89 e5                	mov    %esp,%ebp
80103a18:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103a1b:	e8 a5 ff ff ff       	call   801039c5 <readeflags>
80103a20:	25 00 02 00 00       	and    $0x200,%eax
80103a25:	85 c0                	test   %eax,%eax
80103a27:	74 0d                	je     80103a36 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
80103a29:	83 ec 0c             	sub    $0xc,%esp
80103a2c:	68 84 a6 10 80       	push   $0x8010a684
80103a31:	e8 8b cb ff ff       	call   801005c1 <panic>
  }

  apicid = lapicid();
80103a36:	e8 1e f1 ff ff       	call   80102b59 <lapicid>
80103a3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103a3e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a45:	eb 2d                	jmp    80103a74 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
80103a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a4a:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a50:	05 80 6a 19 80       	add    $0x80196a80,%eax
80103a55:	0f b6 00             	movzbl (%eax),%eax
80103a58:	0f b6 c0             	movzbl %al,%eax
80103a5b:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a5e:	75 10                	jne    80103a70 <mycpu+0x5b>
      return &cpus[i];
80103a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a63:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a69:	05 80 6a 19 80       	add    $0x80196a80,%eax
80103a6e:	eb 1b                	jmp    80103a8b <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a70:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a74:	a1 30 6b 19 80       	mov    0x80196b30,%eax
80103a79:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a7c:	7c c9                	jl     80103a47 <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a7e:	83 ec 0c             	sub    $0xc,%esp
80103a81:	68 aa a6 10 80       	push   $0x8010a6aa
80103a86:	e8 36 cb ff ff       	call   801005c1 <panic>
}
80103a8b:	c9                   	leave
80103a8c:	c3                   	ret

80103a8d <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a8d:	55                   	push   %ebp
80103a8e:	89 e5                	mov    %esp,%ebp
80103a90:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a93:	e8 94 0f 00 00       	call   80104a2c <pushcli>
  c = mycpu();
80103a98:	e8 78 ff ff ff       	call   80103a15 <mycpu>
80103a9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103aa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103aac:	e8 c8 0f 00 00       	call   80104a79 <popcli>
  return p;
80103ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103ab4:	c9                   	leave
80103ab5:	c3                   	ret

80103ab6 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103ab6:	55                   	push   %ebp
80103ab7:	89 e5                	mov    %esp,%ebp
80103ab9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;
  acquire(&ptable.lock);
80103abc:	83 ec 0c             	sub    $0xc,%esp
80103abf:	68 00 42 19 80       	push   $0x80194200
80103ac4:	e8 f8 0d 00 00       	call   801048c1 <acquire>
80103ac9:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103acc:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103ad3:	eb 0e                	jmp    80103ae3 <allocproc+0x2d>
    if(p->state == UNUSED){
80103ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad8:	8b 40 0c             	mov    0xc(%eax),%eax
80103adb:	85 c0                	test   %eax,%eax
80103add:	74 27                	je     80103b06 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103adf:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103ae3:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80103aea:	72 e9                	jb     80103ad5 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103aec:	83 ec 0c             	sub    $0xc,%esp
80103aef:	68 00 42 19 80       	push   $0x80194200
80103af4:	e8 36 0e 00 00       	call   8010492f <release>
80103af9:	83 c4 10             	add    $0x10,%esp
  return 0;
80103afc:	b8 00 00 00 00       	mov    $0x0,%eax
80103b01:	e9 b2 00 00 00       	jmp    80103bb8 <allocproc+0x102>
      goto found;
80103b06:	90                   	nop

found:
  p->state = EMBRYO;
80103b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0a:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103b11:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103b16:	8d 50 01             	lea    0x1(%eax),%edx
80103b19:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103b1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b22:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103b25:	83 ec 0c             	sub    $0xc,%esp
80103b28:	68 00 42 19 80       	push   $0x80194200
80103b2d:	e8 fd 0d 00 00       	call   8010492f <release>
80103b32:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103b35:	e8 cb ec ff ff       	call   80102805 <kalloc>
80103b3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b3d:	89 42 08             	mov    %eax,0x8(%edx)
80103b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b43:	8b 40 08             	mov    0x8(%eax),%eax
80103b46:	85 c0                	test   %eax,%eax
80103b48:	75 11                	jne    80103b5b <allocproc+0xa5>
    p->state = UNUSED;
80103b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103b54:	b8 00 00 00 00       	mov    $0x0,%eax
80103b59:	eb 5d                	jmp    80103bb8 <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b5e:	8b 40 08             	mov    0x8(%eax),%eax
80103b61:	05 00 10 00 00       	add    $0x1000,%eax
80103b66:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b69:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b70:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b73:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b76:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b7a:	ba 2b 60 10 80       	mov    $0x8010602b,%edx
80103b7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b82:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b84:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b8e:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b94:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b97:	83 ec 04             	sub    $0x4,%esp
80103b9a:	6a 14                	push   $0x14
80103b9c:	6a 00                	push   $0x0
80103b9e:	50                   	push   %eax
80103b9f:	e8 93 0f 00 00       	call   80104b37 <memset>
80103ba4:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103baa:	8b 40 1c             	mov    0x1c(%eax),%eax
80103bad:	ba 1e 43 10 80       	mov    $0x8010431e,%edx
80103bb2:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103bb8:	c9                   	leave
80103bb9:	c3                   	ret

80103bba <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103bba:	55                   	push   %ebp
80103bbb:	89 e5                	mov    %esp,%ebp
80103bbd:	83 ec 18             	sub    $0x18,%esp
  cprintf("[userinit] in \n");
80103bc0:	83 ec 0c             	sub    $0xc,%esp
80103bc3:	68 ba a6 10 80       	push   $0x8010a6ba
80103bc8:	e8 27 c8 ff ff       	call   801003f4 <cprintf>
80103bcd:	83 c4 10             	add    $0x10,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103bd0:	e8 e1 fe ff ff       	call   80103ab6 <allocproc>
80103bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bdb:	a3 34 62 19 80       	mov    %eax,0x80196234
  if((p->pgdir = setupkvm()) == 0){
80103be0:	e8 93 3a 00 00       	call   80107678 <setupkvm>
80103be5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103be8:	89 42 04             	mov    %eax,0x4(%edx)
80103beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bee:	8b 40 04             	mov    0x4(%eax),%eax
80103bf1:	85 c0                	test   %eax,%eax
80103bf3:	75 0d                	jne    80103c02 <userinit+0x48>
    panic("userinit: out of memory?");
80103bf5:	83 ec 0c             	sub    $0xc,%esp
80103bf8:	68 ca a6 10 80       	push   $0x8010a6ca
80103bfd:	e8 bf c9 ff ff       	call   801005c1 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103c02:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0a:	8b 40 04             	mov    0x4(%eax),%eax
80103c0d:	83 ec 04             	sub    $0x4,%esp
80103c10:	52                   	push   %edx
80103c11:	68 ec f4 10 80       	push   $0x8010f4ec
80103c16:	50                   	push   %eax
80103c17:	e8 19 3d 00 00       	call   80107935 <inituvm>
80103c1c:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c22:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2b:	8b 40 18             	mov    0x18(%eax),%eax
80103c2e:	83 ec 04             	sub    $0x4,%esp
80103c31:	6a 4c                	push   $0x4c
80103c33:	6a 00                	push   $0x0
80103c35:	50                   	push   %eax
80103c36:	e8 fc 0e 00 00       	call   80104b37 <memset>
80103c3b:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c41:	8b 40 18             	mov    0x18(%eax),%eax
80103c44:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c4d:	8b 40 18             	mov    0x18(%eax),%eax
80103c50:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c59:	8b 50 18             	mov    0x18(%eax),%edx
80103c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5f:	8b 40 18             	mov    0x18(%eax),%eax
80103c62:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c66:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6d:	8b 50 18             	mov    0x18(%eax),%edx
80103c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c73:	8b 40 18             	mov    0x18(%eax),%eax
80103c76:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c7a:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c81:	8b 40 18             	mov    0x18(%eax),%eax
80103c84:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8e:	8b 40 18             	mov    0x18(%eax),%eax
80103c91:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9b:	8b 40 18             	mov    0x18(%eax),%eax
80103c9e:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca8:	83 c0 6c             	add    $0x6c,%eax
80103cab:	83 ec 04             	sub    $0x4,%esp
80103cae:	6a 10                	push   $0x10
80103cb0:	68 e3 a6 10 80       	push   $0x8010a6e3
80103cb5:	50                   	push   %eax
80103cb6:	e8 7f 10 00 00       	call   80104d3a <safestrcpy>
80103cbb:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103cbe:	83 ec 0c             	sub    $0xc,%esp
80103cc1:	68 ec a6 10 80       	push   $0x8010a6ec
80103cc6:	e8 b7 e8 ff ff       	call   80102582 <namei>
80103ccb:	83 c4 10             	add    $0x10,%esp
80103cce:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cd1:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103cd4:	83 ec 0c             	sub    $0xc,%esp
80103cd7:	68 00 42 19 80       	push   $0x80194200
80103cdc:	e8 e0 0b 00 00       	call   801048c1 <acquire>
80103ce1:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103cee:	83 ec 0c             	sub    $0xc,%esp
80103cf1:	68 00 42 19 80       	push   $0x80194200
80103cf6:	e8 34 0c 00 00       	call   8010492f <release>
80103cfb:	83 c4 10             	add    $0x10,%esp
}
80103cfe:	90                   	nop
80103cff:	c9                   	leave
80103d00:	c3                   	ret

80103d01 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103d01:	55                   	push   %ebp
80103d02:	89 e5                	mov    %esp,%ebp
80103d04:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103d07:	e8 81 fd ff ff       	call   80103a8d <myproc>
80103d0c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103d0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d12:	8b 00                	mov    (%eax),%eax
80103d14:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103d17:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d1b:	7e 2e                	jle    80103d4b <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d1d:	8b 55 08             	mov    0x8(%ebp),%edx
80103d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d23:	01 c2                	add    %eax,%edx
80103d25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d28:	8b 40 04             	mov    0x4(%eax),%eax
80103d2b:	83 ec 04             	sub    $0x4,%esp
80103d2e:	52                   	push   %edx
80103d2f:	ff 75 f4             	push   -0xc(%ebp)
80103d32:	50                   	push   %eax
80103d33:	e8 3a 3d 00 00       	call   80107a72 <allocuvm>
80103d38:	83 c4 10             	add    $0x10,%esp
80103d3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d3e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d42:	75 3b                	jne    80103d7f <growproc+0x7e>
      return -1;
80103d44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d49:	eb 4f                	jmp    80103d9a <growproc+0x99>
  } else if(n < 0){
80103d4b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d4f:	79 2e                	jns    80103d7f <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d51:	8b 55 08             	mov    0x8(%ebp),%edx
80103d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d57:	01 c2                	add    %eax,%edx
80103d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d5c:	8b 40 04             	mov    0x4(%eax),%eax
80103d5f:	83 ec 04             	sub    $0x4,%esp
80103d62:	52                   	push   %edx
80103d63:	ff 75 f4             	push   -0xc(%ebp)
80103d66:	50                   	push   %eax
80103d67:	e8 0b 3e 00 00       	call   80107b77 <deallocuvm>
80103d6c:	83 c4 10             	add    $0x10,%esp
80103d6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d76:	75 07                	jne    80103d7f <growproc+0x7e>
      return -1;
80103d78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d7d:	eb 1b                	jmp    80103d9a <growproc+0x99>
  }
  curproc->sz = sz;
80103d7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d82:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d85:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d87:	83 ec 0c             	sub    $0xc,%esp
80103d8a:	ff 75 f0             	push   -0x10(%ebp)
80103d8d:	e8 04 3a 00 00       	call   80107796 <switchuvm>
80103d92:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d95:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d9a:	c9                   	leave
80103d9b:	c3                   	ret

80103d9c <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d9c:	55                   	push   %ebp
80103d9d:	89 e5                	mov    %esp,%ebp
80103d9f:	57                   	push   %edi
80103da0:	56                   	push   %esi
80103da1:	53                   	push   %ebx
80103da2:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103da5:	e8 e3 fc ff ff       	call   80103a8d <myproc>
80103daa:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103dad:	e8 04 fd ff ff       	call   80103ab6 <allocproc>
80103db2:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103db5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103db9:	75 0a                	jne    80103dc5 <fork+0x29>
    return -1;
80103dbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dc0:	e9 48 01 00 00       	jmp    80103f0d <fork+0x171>
  } 
  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103dc5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dc8:	8b 10                	mov    (%eax),%edx
80103dca:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dcd:	8b 40 04             	mov    0x4(%eax),%eax
80103dd0:	83 ec 08             	sub    $0x8,%esp
80103dd3:	52                   	push   %edx
80103dd4:	50                   	push   %eax
80103dd5:	e8 3b 3f 00 00       	call   80107d15 <copyuvm>
80103dda:	83 c4 10             	add    $0x10,%esp
80103ddd:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103de0:	89 42 04             	mov    %eax,0x4(%edx)
80103de3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103de6:	8b 40 04             	mov    0x4(%eax),%eax
80103de9:	85 c0                	test   %eax,%eax
80103deb:	75 30                	jne    80103e1d <fork+0x81>
    kfree(np->kstack);
80103ded:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103df0:	8b 40 08             	mov    0x8(%eax),%eax
80103df3:	83 ec 0c             	sub    $0xc,%esp
80103df6:	50                   	push   %eax
80103df7:	e8 6f e9 ff ff       	call   8010276b <kfree>
80103dfc:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103dff:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e02:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103e09:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e0c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103e13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e18:	e9 f0 00 00 00       	jmp    80103f0d <fork+0x171>
  }
  np->sz = curproc->sz;
80103e1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e20:	8b 10                	mov    (%eax),%edx
80103e22:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e25:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103e27:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e2a:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103e2d:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103e30:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e33:	8b 48 18             	mov    0x18(%eax),%ecx
80103e36:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e39:	8b 40 18             	mov    0x18(%eax),%eax
80103e3c:	89 c2                	mov    %eax,%edx
80103e3e:	89 cb                	mov    %ecx,%ebx
80103e40:	b8 13 00 00 00       	mov    $0x13,%eax
80103e45:	89 d7                	mov    %edx,%edi
80103e47:	89 de                	mov    %ebx,%esi
80103e49:	89 c1                	mov    %eax,%ecx
80103e4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103e4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e50:	8b 40 18             	mov    0x18(%eax),%eax
80103e53:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103e5a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103e61:	eb 3b                	jmp    80103e9e <fork+0x102>
    if(curproc->ofile[i])
80103e63:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e66:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e69:	83 c2 08             	add    $0x8,%edx
80103e6c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e70:	85 c0                	test   %eax,%eax
80103e72:	74 26                	je     80103e9a <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e74:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e77:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e7a:	83 c2 08             	add    $0x8,%edx
80103e7d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e81:	83 ec 0c             	sub    $0xc,%esp
80103e84:	50                   	push   %eax
80103e85:	e8 27 d2 ff ff       	call   801010b1 <filedup>
80103e8a:	83 c4 10             	add    $0x10,%esp
80103e8d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e90:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e93:	83 c1 08             	add    $0x8,%ecx
80103e96:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e9a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e9e:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103ea2:	7e bf                	jle    80103e63 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103ea4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ea7:	8b 40 68             	mov    0x68(%eax),%eax
80103eaa:	83 ec 0c             	sub    $0xc,%esp
80103ead:	50                   	push   %eax
80103eae:	e8 62 db ff ff       	call   80101a15 <idup>
80103eb3:	83 c4 10             	add    $0x10,%esp
80103eb6:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103eb9:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103ebc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ebf:	8d 50 6c             	lea    0x6c(%eax),%edx
80103ec2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ec5:	83 c0 6c             	add    $0x6c,%eax
80103ec8:	83 ec 04             	sub    $0x4,%esp
80103ecb:	6a 10                	push   $0x10
80103ecd:	52                   	push   %edx
80103ece:	50                   	push   %eax
80103ecf:	e8 66 0e 00 00       	call   80104d3a <safestrcpy>
80103ed4:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103ed7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103eda:	8b 40 10             	mov    0x10(%eax),%eax
80103edd:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103ee0:	83 ec 0c             	sub    $0xc,%esp
80103ee3:	68 00 42 19 80       	push   $0x80194200
80103ee8:	e8 d4 09 00 00       	call   801048c1 <acquire>
80103eed:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103ef0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ef3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103efa:	83 ec 0c             	sub    $0xc,%esp
80103efd:	68 00 42 19 80       	push   $0x80194200
80103f02:	e8 28 0a 00 00       	call   8010492f <release>
80103f07:	83 c4 10             	add    $0x10,%esp
  return pid;
80103f0a:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103f0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103f10:	5b                   	pop    %ebx
80103f11:	5e                   	pop    %esi
80103f12:	5f                   	pop    %edi
80103f13:	5d                   	pop    %ebp
80103f14:	c3                   	ret

80103f15 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103f15:	55                   	push   %ebp
80103f16:	89 e5                	mov    %esp,%ebp
80103f18:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103f1b:	e8 6d fb ff ff       	call   80103a8d <myproc>
80103f20:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103f23:	a1 34 62 19 80       	mov    0x80196234,%eax
80103f28:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f2b:	75 0d                	jne    80103f3a <exit+0x25>
    panic("init exiting");
80103f2d:	83 ec 0c             	sub    $0xc,%esp
80103f30:	68 ee a6 10 80       	push   $0x8010a6ee
80103f35:	e8 87 c6 ff ff       	call   801005c1 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103f3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103f41:	eb 3f                	jmp    80103f82 <exit+0x6d>
    if(curproc->ofile[fd]){
80103f43:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f46:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f49:	83 c2 08             	add    $0x8,%edx
80103f4c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f50:	85 c0                	test   %eax,%eax
80103f52:	74 2a                	je     80103f7e <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103f54:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f57:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f5a:	83 c2 08             	add    $0x8,%edx
80103f5d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f61:	83 ec 0c             	sub    $0xc,%esp
80103f64:	50                   	push   %eax
80103f65:	e8 98 d1 ff ff       	call   80101102 <fileclose>
80103f6a:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f70:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f73:	83 c2 08             	add    $0x8,%edx
80103f76:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f7d:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f7e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f82:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f86:	7e bb                	jle    80103f43 <exit+0x2e>
    }
  }

  begin_op();
80103f88:	e8 0e f1 ff ff       	call   8010309b <begin_op>
  iput(curproc->cwd);
80103f8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f90:	8b 40 68             	mov    0x68(%eax),%eax
80103f93:	83 ec 0c             	sub    $0xc,%esp
80103f96:	50                   	push   %eax
80103f97:	e8 14 dc ff ff       	call   80101bb0 <iput>
80103f9c:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f9f:	e8 83 f1 ff ff       	call   80103127 <end_op>
  curproc->cwd = 0;
80103fa4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fa7:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103fae:	83 ec 0c             	sub    $0xc,%esp
80103fb1:	68 00 42 19 80       	push   $0x80194200
80103fb6:	e8 06 09 00 00       	call   801048c1 <acquire>
80103fbb:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103fbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fc1:	8b 40 14             	mov    0x14(%eax),%eax
80103fc4:	83 ec 0c             	sub    $0xc,%esp
80103fc7:	50                   	push   %eax
80103fc8:	e8 3e 04 00 00       	call   8010440b <wakeup1>
80103fcd:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fd0:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103fd7:	eb 37                	jmp    80104010 <exit+0xfb>
    if(p->parent == curproc){
80103fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fdc:	8b 40 14             	mov    0x14(%eax),%eax
80103fdf:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103fe2:	75 28                	jne    8010400c <exit+0xf7>
      p->parent = initproc;
80103fe4:	8b 15 34 62 19 80    	mov    0x80196234,%edx
80103fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fed:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff3:	8b 40 0c             	mov    0xc(%eax),%eax
80103ff6:	83 f8 05             	cmp    $0x5,%eax
80103ff9:	75 11                	jne    8010400c <exit+0xf7>
        wakeup1(initproc);
80103ffb:	a1 34 62 19 80       	mov    0x80196234,%eax
80104000:	83 ec 0c             	sub    $0xc,%esp
80104003:	50                   	push   %eax
80104004:	e8 02 04 00 00       	call   8010440b <wakeup1>
80104009:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010400c:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104010:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80104017:	72 c0                	jb     80103fd9 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104019:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010401c:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104023:	e8 03 02 00 00       	call   8010422b <sched>
  panic("zombie exit");
80104028:	83 ec 0c             	sub    $0xc,%esp
8010402b:	68 fb a6 10 80       	push   $0x8010a6fb
80104030:	e8 8c c5 ff ff       	call   801005c1 <panic>

80104035 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104035:	55                   	push   %ebp
80104036:	89 e5                	mov    %esp,%ebp
80104038:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010403b:	e8 4d fa ff ff       	call   80103a8d <myproc>
80104040:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104043:	83 ec 0c             	sub    $0xc,%esp
80104046:	68 00 42 19 80       	push   $0x80194200
8010404b:	e8 71 08 00 00       	call   801048c1 <acquire>
80104050:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104053:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010405a:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104061:	e9 a1 00 00 00       	jmp    80104107 <wait+0xd2>
      if(p->parent != curproc)
80104066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104069:	8b 40 14             	mov    0x14(%eax),%eax
8010406c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010406f:	0f 85 8d 00 00 00    	jne    80104102 <wait+0xcd>
        continue;
      havekids = 1;
80104075:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010407c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010407f:	8b 40 0c             	mov    0xc(%eax),%eax
80104082:	83 f8 05             	cmp    $0x5,%eax
80104085:	75 7c                	jne    80104103 <wait+0xce>
        // Found one.
        pid = p->pid;
80104087:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010408a:	8b 40 10             	mov    0x10(%eax),%eax
8010408d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104090:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104093:	8b 40 08             	mov    0x8(%eax),%eax
80104096:	83 ec 0c             	sub    $0xc,%esp
80104099:	50                   	push   %eax
8010409a:	e8 cc e6 ff ff       	call   8010276b <kfree>
8010409f:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801040a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801040ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040af:	8b 40 04             	mov    0x4(%eax),%eax
801040b2:	83 ec 0c             	sub    $0xc,%esp
801040b5:	50                   	push   %eax
801040b6:	e8 80 3b 00 00       	call   80107c3b <freevm>
801040bb:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801040be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c1:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801040c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040cb:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801040d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d5:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801040d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040dc:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801040e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801040ed:	83 ec 0c             	sub    $0xc,%esp
801040f0:	68 00 42 19 80       	push   $0x80194200
801040f5:	e8 35 08 00 00       	call   8010492f <release>
801040fa:	83 c4 10             	add    $0x10,%esp
        return pid;
801040fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104100:	eb 51                	jmp    80104153 <wait+0x11e>
        continue;
80104102:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104103:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104107:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
8010410e:	0f 82 52 ff ff ff    	jb     80104066 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104114:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104118:	74 0a                	je     80104124 <wait+0xef>
8010411a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010411d:	8b 40 24             	mov    0x24(%eax),%eax
80104120:	85 c0                	test   %eax,%eax
80104122:	74 17                	je     8010413b <wait+0x106>
      release(&ptable.lock);
80104124:	83 ec 0c             	sub    $0xc,%esp
80104127:	68 00 42 19 80       	push   $0x80194200
8010412c:	e8 fe 07 00 00       	call   8010492f <release>
80104131:	83 c4 10             	add    $0x10,%esp
      return -1;
80104134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104139:	eb 18                	jmp    80104153 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010413b:	83 ec 08             	sub    $0x8,%esp
8010413e:	68 00 42 19 80       	push   $0x80194200
80104143:	ff 75 ec             	push   -0x14(%ebp)
80104146:	e8 19 02 00 00       	call   80104364 <sleep>
8010414b:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010414e:	e9 00 ff ff ff       	jmp    80104053 <wait+0x1e>
  }
}
80104153:	c9                   	leave
80104154:	c3                   	ret

80104155 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104155:	55                   	push   %ebp
80104156:	89 e5                	mov    %esp,%ebp
80104158:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
8010415b:	e8 b5 f8 ff ff       	call   80103a15 <mycpu>
80104160:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104163:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104166:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010416d:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104170:	e8 60 f8 ff ff       	call   801039d5 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104175:	83 ec 0c             	sub    $0xc,%esp
80104178:	68 00 42 19 80       	push   $0x80194200
8010417d:	e8 3f 07 00 00       	call   801048c1 <acquire>
80104182:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104185:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010418c:	eb 61                	jmp    801041ef <scheduler+0x9a>
      if(p->state != RUNNABLE)
8010418e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104191:	8b 40 0c             	mov    0xc(%eax),%eax
80104194:	83 f8 03             	cmp    $0x3,%eax
80104197:	75 51                	jne    801041ea <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104199:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010419c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010419f:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
801041a5:	83 ec 0c             	sub    $0xc,%esp
801041a8:	ff 75 f4             	push   -0xc(%ebp)
801041ab:	e8 e6 35 00 00       	call   80107796 <switchuvm>
801041b0:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801041b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b6:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&(c->scheduler), p->context);
801041bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c0:	8b 40 1c             	mov    0x1c(%eax),%eax
801041c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041c6:	83 c2 04             	add    $0x4,%edx
801041c9:	83 ec 08             	sub    $0x8,%esp
801041cc:	50                   	push   %eax
801041cd:	52                   	push   %edx
801041ce:	e8 d9 0b 00 00       	call   80104dac <swtch>
801041d3:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801041d6:	e8 a2 35 00 00       	call   8010777d <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
801041db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041de:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801041e5:	00 00 00 
801041e8:	eb 01                	jmp    801041eb <scheduler+0x96>
        continue;
801041ea:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041eb:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801041ef:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
801041f6:	72 96                	jb     8010418e <scheduler+0x39>
    }
    release(&ptable.lock);
801041f8:	83 ec 0c             	sub    $0xc,%esp
801041fb:	68 00 42 19 80       	push   $0x80194200
80104200:	e8 2a 07 00 00       	call   8010492f <release>
80104205:	83 c4 10             	add    $0x10,%esp
    sti();
80104208:	e9 63 ff ff ff       	jmp    80104170 <scheduler+0x1b>

8010420d <uthread_init>:
// uthread_init: 유저 레벨 쓰레드의 스케줄러의 주소를 커널의 proccess에 넘겨준다.
// 이 함수를 시스템콜에서 호출하여 uthread의 스케줄러의 주소를 가져오고 
// 커널에서 인터럽트가 발생할 때 uthread의 스케줄러를 실행할 수 있게 된다.
int 
uthread_init(int address)
{
8010420d:	55                   	push   %ebp
8010420e:	89 e5                	mov    %esp,%ebp
80104210:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104213:	e8 75 f8 ff ff       	call   80103a8d <myproc>
80104218:	89 45 f4             	mov    %eax,-0xc(%ebp)
//  p->trapflag = 1;
  curproc->scheduler = (uint)address;
8010421b:	8b 55 08             	mov    0x8(%ebp),%edx
8010421e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104221:	89 50 7c             	mov    %edx,0x7c(%eax)
  //cprintf("address: %d", address);
  return 0;
80104224:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104229:	c9                   	leave
8010422a:	c3                   	ret

8010422b <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
8010422b:	55                   	push   %ebp
8010422c:	89 e5                	mov    %esp,%ebp
8010422e:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104231:	e8 57 f8 ff ff       	call   80103a8d <myproc>
80104236:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104239:	83 ec 0c             	sub    $0xc,%esp
8010423c:	68 00 42 19 80       	push   $0x80194200
80104241:	e8 b6 07 00 00       	call   801049fc <holding>
80104246:	83 c4 10             	add    $0x10,%esp
80104249:	85 c0                	test   %eax,%eax
8010424b:	75 0d                	jne    8010425a <sched+0x2f>
    panic("sched ptable.lock");
8010424d:	83 ec 0c             	sub    $0xc,%esp
80104250:	68 07 a7 10 80       	push   $0x8010a707
80104255:	e8 67 c3 ff ff       	call   801005c1 <panic>
  if(mycpu()->ncli != 1)
8010425a:	e8 b6 f7 ff ff       	call   80103a15 <mycpu>
8010425f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104265:	83 f8 01             	cmp    $0x1,%eax
80104268:	74 0d                	je     80104277 <sched+0x4c>
    panic("sched locks");
8010426a:	83 ec 0c             	sub    $0xc,%esp
8010426d:	68 19 a7 10 80       	push   $0x8010a719
80104272:	e8 4a c3 ff ff       	call   801005c1 <panic>
  if(p->state == RUNNING)
80104277:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427a:	8b 40 0c             	mov    0xc(%eax),%eax
8010427d:	83 f8 04             	cmp    $0x4,%eax
80104280:	75 0d                	jne    8010428f <sched+0x64>
    panic("sched running");
80104282:	83 ec 0c             	sub    $0xc,%esp
80104285:	68 25 a7 10 80       	push   $0x8010a725
8010428a:	e8 32 c3 ff ff       	call   801005c1 <panic>
  if(readeflags()&FL_IF)
8010428f:	e8 31 f7 ff ff       	call   801039c5 <readeflags>
80104294:	25 00 02 00 00       	and    $0x200,%eax
80104299:	85 c0                	test   %eax,%eax
8010429b:	74 0d                	je     801042aa <sched+0x7f>
    panic("sched interruptible");
8010429d:	83 ec 0c             	sub    $0xc,%esp
801042a0:	68 33 a7 10 80       	push   $0x8010a733
801042a5:	e8 17 c3 ff ff       	call   801005c1 <panic>
  intena = mycpu()->intena;
801042aa:	e8 66 f7 ff ff       	call   80103a15 <mycpu>
801042af:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801042b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801042b8:	e8 58 f7 ff ff       	call   80103a15 <mycpu>
801042bd:	8b 40 04             	mov    0x4(%eax),%eax
801042c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042c3:	83 c2 1c             	add    $0x1c,%edx
801042c6:	83 ec 08             	sub    $0x8,%esp
801042c9:	50                   	push   %eax
801042ca:	52                   	push   %edx
801042cb:	e8 dc 0a 00 00       	call   80104dac <swtch>
801042d0:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801042d3:	e8 3d f7 ff ff       	call   80103a15 <mycpu>
801042d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801042db:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801042e1:	90                   	nop
801042e2:	c9                   	leave
801042e3:	c3                   	ret

801042e4 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801042e4:	55                   	push   %ebp
801042e5:	89 e5                	mov    %esp,%ebp
801042e7:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801042ea:	83 ec 0c             	sub    $0xc,%esp
801042ed:	68 00 42 19 80       	push   $0x80194200
801042f2:	e8 ca 05 00 00       	call   801048c1 <acquire>
801042f7:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
801042fa:	e8 8e f7 ff ff       	call   80103a8d <myproc>
801042ff:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104306:	e8 20 ff ff ff       	call   8010422b <sched>
  release(&ptable.lock);
8010430b:	83 ec 0c             	sub    $0xc,%esp
8010430e:	68 00 42 19 80       	push   $0x80194200
80104313:	e8 17 06 00 00       	call   8010492f <release>
80104318:	83 c4 10             	add    $0x10,%esp
}
8010431b:	90                   	nop
8010431c:	c9                   	leave
8010431d:	c3                   	ret

8010431e <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010431e:	55                   	push   %ebp
8010431f:	89 e5                	mov    %esp,%ebp
80104321:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104324:	83 ec 0c             	sub    $0xc,%esp
80104327:	68 00 42 19 80       	push   $0x80194200
8010432c:	e8 fe 05 00 00       	call   8010492f <release>
80104331:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104334:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104339:	85 c0                	test   %eax,%eax
8010433b:	74 24                	je     80104361 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010433d:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104344:	00 00 00 
    iinit(ROOTDEV);
80104347:	83 ec 0c             	sub    $0xc,%esp
8010434a:	6a 01                	push   $0x1
8010434c:	e8 8d d3 ff ff       	call   801016de <iinit>
80104351:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104354:	83 ec 0c             	sub    $0xc,%esp
80104357:	6a 01                	push   $0x1
80104359:	e8 1e eb ff ff       	call   80102e7c <initlog>
8010435e:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104361:	90                   	nop
80104362:	c9                   	leave
80104363:	c3                   	ret

80104364 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104364:	55                   	push   %ebp
80104365:	89 e5                	mov    %esp,%ebp
80104367:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
8010436a:	e8 1e f7 ff ff       	call   80103a8d <myproc>
8010436f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104372:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104376:	75 0d                	jne    80104385 <sleep+0x21>
    panic("sleep");
80104378:	83 ec 0c             	sub    $0xc,%esp
8010437b:	68 47 a7 10 80       	push   $0x8010a747
80104380:	e8 3c c2 ff ff       	call   801005c1 <panic>

  if(lk == 0)
80104385:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104389:	75 0d                	jne    80104398 <sleep+0x34>
    panic("sleep without lk");
8010438b:	83 ec 0c             	sub    $0xc,%esp
8010438e:	68 4d a7 10 80       	push   $0x8010a74d
80104393:	e8 29 c2 ff ff       	call   801005c1 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104398:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010439f:	74 1e                	je     801043bf <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
801043a1:	83 ec 0c             	sub    $0xc,%esp
801043a4:	68 00 42 19 80       	push   $0x80194200
801043a9:	e8 13 05 00 00       	call   801048c1 <acquire>
801043ae:	83 c4 10             	add    $0x10,%esp
    release(lk);
801043b1:	83 ec 0c             	sub    $0xc,%esp
801043b4:	ff 75 0c             	push   0xc(%ebp)
801043b7:	e8 73 05 00 00       	call   8010492f <release>
801043bc:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801043bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c2:	8b 55 08             	mov    0x8(%ebp),%edx
801043c5:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801043c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043cb:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801043d2:	e8 54 fe ff ff       	call   8010422b <sched>

  // Tidy up.
  p->chan = 0;
801043d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043da:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801043e1:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
801043e8:	74 1e                	je     80104408 <sleep+0xa4>
    release(&ptable.lock);
801043ea:	83 ec 0c             	sub    $0xc,%esp
801043ed:	68 00 42 19 80       	push   $0x80194200
801043f2:	e8 38 05 00 00       	call   8010492f <release>
801043f7:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801043fa:	83 ec 0c             	sub    $0xc,%esp
801043fd:	ff 75 0c             	push   0xc(%ebp)
80104400:	e8 bc 04 00 00       	call   801048c1 <acquire>
80104405:	83 c4 10             	add    $0x10,%esp
  }
}
80104408:	90                   	nop
80104409:	c9                   	leave
8010440a:	c3                   	ret

8010440b <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010440b:	55                   	push   %ebp
8010440c:	89 e5                	mov    %esp,%ebp
8010440e:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104411:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
80104418:	eb 24                	jmp    8010443e <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
8010441a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010441d:	8b 40 0c             	mov    0xc(%eax),%eax
80104420:	83 f8 02             	cmp    $0x2,%eax
80104423:	75 15                	jne    8010443a <wakeup1+0x2f>
80104425:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104428:	8b 40 20             	mov    0x20(%eax),%eax
8010442b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010442e:	75 0a                	jne    8010443a <wakeup1+0x2f>
      p->state = RUNNABLE;
80104430:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104433:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010443a:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
8010443e:	81 7d fc 34 62 19 80 	cmpl   $0x80196234,-0x4(%ebp)
80104445:	72 d3                	jb     8010441a <wakeup1+0xf>
}
80104447:	90                   	nop
80104448:	90                   	nop
80104449:	c9                   	leave
8010444a:	c3                   	ret

8010444b <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010444b:	55                   	push   %ebp
8010444c:	89 e5                	mov    %esp,%ebp
8010444e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104451:	83 ec 0c             	sub    $0xc,%esp
80104454:	68 00 42 19 80       	push   $0x80194200
80104459:	e8 63 04 00 00       	call   801048c1 <acquire>
8010445e:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104461:	83 ec 0c             	sub    $0xc,%esp
80104464:	ff 75 08             	push   0x8(%ebp)
80104467:	e8 9f ff ff ff       	call   8010440b <wakeup1>
8010446c:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010446f:	83 ec 0c             	sub    $0xc,%esp
80104472:	68 00 42 19 80       	push   $0x80194200
80104477:	e8 b3 04 00 00       	call   8010492f <release>
8010447c:	83 c4 10             	add    $0x10,%esp
}
8010447f:	90                   	nop
80104480:	c9                   	leave
80104481:	c3                   	ret

80104482 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104482:	55                   	push   %ebp
80104483:	89 e5                	mov    %esp,%ebp
80104485:	83 ec 18             	sub    $0x18,%esp
  cprintf("kill\n");
80104488:	83 ec 0c             	sub    $0xc,%esp
8010448b:	68 5e a7 10 80       	push   $0x8010a75e
80104490:	e8 5f bf ff ff       	call   801003f4 <cprintf>
80104495:	83 c4 10             	add    $0x10,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104498:	83 ec 0c             	sub    $0xc,%esp
8010449b:	68 00 42 19 80       	push   $0x80194200
801044a0:	e8 1c 04 00 00       	call   801048c1 <acquire>
801044a5:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044a8:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
801044af:	eb 45                	jmp    801044f6 <kill+0x74>
    if(p->pid == pid){
801044b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b4:	8b 40 10             	mov    0x10(%eax),%eax
801044b7:	39 45 08             	cmp    %eax,0x8(%ebp)
801044ba:	75 36                	jne    801044f2 <kill+0x70>
      p->killed = 1;
801044bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044bf:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801044c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c9:	8b 40 0c             	mov    0xc(%eax),%eax
801044cc:	83 f8 02             	cmp    $0x2,%eax
801044cf:	75 0a                	jne    801044db <kill+0x59>
        p->state = RUNNABLE;
801044d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801044db:	83 ec 0c             	sub    $0xc,%esp
801044de:	68 00 42 19 80       	push   $0x80194200
801044e3:	e8 47 04 00 00       	call   8010492f <release>
801044e8:	83 c4 10             	add    $0x10,%esp
      return 0;
801044eb:	b8 00 00 00 00       	mov    $0x0,%eax
801044f0:	eb 22                	jmp    80104514 <kill+0x92>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044f2:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801044f6:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
801044fd:	72 b2                	jb     801044b1 <kill+0x2f>
    }
  }
  release(&ptable.lock);
801044ff:	83 ec 0c             	sub    $0xc,%esp
80104502:	68 00 42 19 80       	push   $0x80194200
80104507:	e8 23 04 00 00       	call   8010492f <release>
8010450c:	83 c4 10             	add    $0x10,%esp
  return -1;
8010450f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104514:	c9                   	leave
80104515:	c3                   	ret

80104516 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104516:	55                   	push   %ebp
80104517:	89 e5                	mov    %esp,%ebp
80104519:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010451c:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
80104523:	e9 d7 00 00 00       	jmp    801045ff <procdump+0xe9>
    if(p->state == UNUSED)
80104528:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010452b:	8b 40 0c             	mov    0xc(%eax),%eax
8010452e:	85 c0                	test   %eax,%eax
80104530:	0f 84 c4 00 00 00    	je     801045fa <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104536:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104539:	8b 40 0c             	mov    0xc(%eax),%eax
8010453c:	83 f8 05             	cmp    $0x5,%eax
8010453f:	77 23                	ja     80104564 <procdump+0x4e>
80104541:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104544:	8b 40 0c             	mov    0xc(%eax),%eax
80104547:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010454e:	85 c0                	test   %eax,%eax
80104550:	74 12                	je     80104564 <procdump+0x4e>
      state = states[p->state];
80104552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104555:	8b 40 0c             	mov    0xc(%eax),%eax
80104558:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010455f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104562:	eb 07                	jmp    8010456b <procdump+0x55>
    else
      state = "???";
80104564:	c7 45 ec 64 a7 10 80 	movl   $0x8010a764,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010456b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010456e:	8d 50 6c             	lea    0x6c(%eax),%edx
80104571:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104574:	8b 40 10             	mov    0x10(%eax),%eax
80104577:	52                   	push   %edx
80104578:	ff 75 ec             	push   -0x14(%ebp)
8010457b:	50                   	push   %eax
8010457c:	68 68 a7 10 80       	push   $0x8010a768
80104581:	e8 6e be ff ff       	call   801003f4 <cprintf>
80104586:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104589:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010458c:	8b 40 0c             	mov    0xc(%eax),%eax
8010458f:	83 f8 02             	cmp    $0x2,%eax
80104592:	75 54                	jne    801045e8 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104594:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104597:	8b 40 1c             	mov    0x1c(%eax),%eax
8010459a:	8b 40 0c             	mov    0xc(%eax),%eax
8010459d:	83 c0 08             	add    $0x8,%eax
801045a0:	89 c2                	mov    %eax,%edx
801045a2:	83 ec 08             	sub    $0x8,%esp
801045a5:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801045a8:	50                   	push   %eax
801045a9:	52                   	push   %edx
801045aa:	e8 d2 03 00 00       	call   80104981 <getcallerpcs>
801045af:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801045b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801045b9:	eb 1c                	jmp    801045d7 <procdump+0xc1>
        cprintf(" %p", pc[i]);
801045bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045be:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801045c2:	83 ec 08             	sub    $0x8,%esp
801045c5:	50                   	push   %eax
801045c6:	68 71 a7 10 80       	push   $0x8010a771
801045cb:	e8 24 be ff ff       	call   801003f4 <cprintf>
801045d0:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801045d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801045d7:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801045db:	7f 0b                	jg     801045e8 <procdump+0xd2>
801045dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e0:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801045e4:	85 c0                	test   %eax,%eax
801045e6:	75 d3                	jne    801045bb <procdump+0xa5>
    }
    cprintf("\n");
801045e8:	83 ec 0c             	sub    $0xc,%esp
801045eb:	68 75 a7 10 80       	push   $0x8010a775
801045f0:	e8 ff bd ff ff       	call   801003f4 <cprintf>
801045f5:	83 c4 10             	add    $0x10,%esp
801045f8:	eb 01                	jmp    801045fb <procdump+0xe5>
      continue;
801045fa:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045fb:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
801045ff:	81 7d f0 34 62 19 80 	cmpl   $0x80196234,-0x10(%ebp)
80104606:	0f 82 1c ff ff ff    	jb     80104528 <procdump+0x12>
  }
}
8010460c:	90                   	nop
8010460d:	90                   	nop
8010460e:	c9                   	leave
8010460f:	c3                   	ret

80104610 <printpt>:

// 페이지 테이블 출력
int printpt(int pid){
80104610:	55                   	push   %ebp
80104611:	89 e5                	mov    %esp,%ebp
80104613:	53                   	push   %ebx
80104614:	83 ec 14             	sub    $0x14,%esp
  struct proc* p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104617:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010461e:	eb 0f                	jmp    8010462f <printpt+0x1f>
    if (p->pid == pid)
80104620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104623:	8b 40 10             	mov    0x10(%eax),%eax
80104626:	39 45 08             	cmp    %eax,0x8(%ebp)
80104629:	74 0f                	je     8010463a <printpt+0x2a>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010462b:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010462f:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80104636:	72 e8                	jb     80104620 <printpt+0x10>
80104638:	eb 01                	jmp    8010463b <printpt+0x2b>
      break;
8010463a:	90                   	nop
  }
  if (p == 0){
8010463b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010463f:	75 1a                	jne    8010465b <printpt+0x4b>
    cprintf("[printpt] invaild proccess\n");
80104641:	83 ec 0c             	sub    $0xc,%esp
80104644:	68 77 a7 10 80       	push   $0x8010a777
80104649:	e8 a6 bd ff ff       	call   801003f4 <cprintf>
8010464e:	83 c4 10             	add    $0x10,%esp
    return -1;
80104651:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104656:	e9 e2 00 00 00       	jmp    8010473d <printpt+0x12d>
  }
  
  pde_t* pgdir = p->pgdir;
8010465b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465e:	8b 40 04             	mov    0x4(%eax),%eax
80104661:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint va;
  // walkpgdir은 pgdir에서 va(가상주소)가 위치한 페이지 테이블 엔트리를 반환한다.
  cprintf("START PAGE TABLE (pid %d) \n", pid);
80104664:	83 ec 08             	sub    $0x8,%esp
80104667:	ff 75 08             	push   0x8(%ebp)
8010466a:	68 93 a7 10 80       	push   $0x8010a793
8010466f:	e8 80 bd ff ff       	call   801003f4 <cprintf>
80104674:	83 c4 10             	add    $0x10,%esp
  // 페이지 테이블 엔트리를 한 줄씩 출력
  // xv6에서는 pagesize를 4KB로 설정 PGSIZE == 4096 임
  for (va = 0; va < KERNBASE; va += PGSIZE)
80104677:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010467e:	e9 9a 00 00 00       	jmp    8010471d <printpt+0x10d>
  {
    // va가 속한 페이지 테이블 엔트리
    pte_t* pte = walkpgdir(pgdir, (void*) va, 0);
80104683:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104686:	83 ec 04             	sub    $0x4,%esp
80104689:	6a 00                	push   $0x0
8010468b:	50                   	push   %eax
8010468c:	ff 75 ec             	push   -0x14(%ebp)
8010468f:	e8 be 2e 00 00       	call   80107552 <walkpgdir>
80104694:	83 c4 10             	add    $0x10,%esp
80104697:	89 45 e8             	mov    %eax,-0x18(%ebp)
    // pte가 유효하지 않으면 패스
    if (!(*pte & PTE_P) || pte == 0) continue;
8010469a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010469d:	8b 00                	mov    (%eax),%eax
8010469f:	83 e0 01             	and    $0x1,%eax
801046a2:	85 c0                	test   %eax,%eax
801046a4:	74 6f                	je     80104715 <printpt+0x105>
801046a6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801046aa:	74 69                	je     80104715 <printpt+0x105>
    cprintf("pte: %x\n",pte);
801046ac:	83 ec 08             	sub    $0x8,%esp
801046af:	ff 75 e8             	push   -0x18(%ebp)
801046b2:	68 af a7 10 80       	push   $0x8010a7af
801046b7:	e8 38 bd ff ff       	call   801003f4 <cprintf>
801046bc:	83 c4 10             	add    $0x10,%esp
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
      (*pte & PTE_W)?'W':'-', PTE_ADDR(*pte) >> 12); 
801046bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801046c2:	8b 00                	mov    (%eax),%eax
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
801046c4:	c1 e8 0c             	shr    $0xc,%eax
801046c7:	89 c2                	mov    %eax,%edx
      (*pte & PTE_W)?'W':'-', PTE_ADDR(*pte) >> 12); 
801046c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801046cc:	8b 00                	mov    (%eax),%eax
801046ce:	83 e0 02             	and    $0x2,%eax
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
801046d1:	85 c0                	test   %eax,%eax
801046d3:	74 07                	je     801046dc <printpt+0xcc>
801046d5:	bb 57 00 00 00       	mov    $0x57,%ebx
801046da:	eb 05                	jmp    801046e1 <printpt+0xd1>
801046dc:	bb 2d 00 00 00       	mov    $0x2d,%ebx
801046e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801046e4:	8b 00                	mov    (%eax),%eax
801046e6:	83 e0 04             	and    $0x4,%eax
801046e9:	85 c0                	test   %eax,%eax
801046eb:	74 07                	je     801046f4 <printpt+0xe4>
801046ed:	b9 55 00 00 00       	mov    $0x55,%ecx
801046f2:	eb 05                	jmp    801046f9 <printpt+0xe9>
801046f4:	b9 4b 00 00 00       	mov    $0x4b,%ecx
801046f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046fc:	c1 e8 0c             	shr    $0xc,%eax
801046ff:	83 ec 0c             	sub    $0xc,%esp
80104702:	52                   	push   %edx
80104703:	53                   	push   %ebx
80104704:	51                   	push   %ecx
80104705:	50                   	push   %eax
80104706:	68 b8 a7 10 80       	push   $0x8010a7b8
8010470b:	e8 e4 bc ff ff       	call   801003f4 <cprintf>
80104710:	83 c4 20             	add    $0x20,%esp
80104713:	eb 01                	jmp    80104716 <printpt+0x106>
    if (!(*pte & PTE_P) || pte == 0) continue;
80104715:	90                   	nop
  for (va = 0; va < KERNBASE; va += PGSIZE)
80104716:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
8010471d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104720:	85 c0                	test   %eax,%eax
80104722:	0f 89 5b ff ff ff    	jns    80104683 <printpt+0x73>
  }
  cprintf("END PAGE TABLE\n");
80104728:	83 ec 0c             	sub    $0xc,%esp
8010472b:	68 c7 a7 10 80       	push   $0x8010a7c7
80104730:	e8 bf bc ff ff       	call   801003f4 <cprintf>
80104735:	83 c4 10             	add    $0x10,%esp
  return 0;
80104738:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010473d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104740:	c9                   	leave
80104741:	c3                   	ret

80104742 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104742:	55                   	push   %ebp
80104743:	89 e5                	mov    %esp,%ebp
80104745:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104748:	8b 45 08             	mov    0x8(%ebp),%eax
8010474b:	83 c0 04             	add    $0x4,%eax
8010474e:	83 ec 08             	sub    $0x8,%esp
80104751:	68 01 a8 10 80       	push   $0x8010a801
80104756:	50                   	push   %eax
80104757:	e8 43 01 00 00       	call   8010489f <initlock>
8010475c:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
8010475f:	8b 45 08             	mov    0x8(%ebp),%eax
80104762:	8b 55 0c             	mov    0xc(%ebp),%edx
80104765:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104768:	8b 45 08             	mov    0x8(%ebp),%eax
8010476b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104771:	8b 45 08             	mov    0x8(%ebp),%eax
80104774:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
8010477b:	90                   	nop
8010477c:	c9                   	leave
8010477d:	c3                   	ret

8010477e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010477e:	55                   	push   %ebp
8010477f:	89 e5                	mov    %esp,%ebp
80104781:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104784:	8b 45 08             	mov    0x8(%ebp),%eax
80104787:	83 c0 04             	add    $0x4,%eax
8010478a:	83 ec 0c             	sub    $0xc,%esp
8010478d:	50                   	push   %eax
8010478e:	e8 2e 01 00 00       	call   801048c1 <acquire>
80104793:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104796:	eb 15                	jmp    801047ad <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104798:	8b 45 08             	mov    0x8(%ebp),%eax
8010479b:	83 c0 04             	add    $0x4,%eax
8010479e:	83 ec 08             	sub    $0x8,%esp
801047a1:	50                   	push   %eax
801047a2:	ff 75 08             	push   0x8(%ebp)
801047a5:	e8 ba fb ff ff       	call   80104364 <sleep>
801047aa:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801047ad:	8b 45 08             	mov    0x8(%ebp),%eax
801047b0:	8b 00                	mov    (%eax),%eax
801047b2:	85 c0                	test   %eax,%eax
801047b4:	75 e2                	jne    80104798 <acquiresleep+0x1a>
  }
  lk->locked = 1;
801047b6:	8b 45 08             	mov    0x8(%ebp),%eax
801047b9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801047bf:	e8 c9 f2 ff ff       	call   80103a8d <myproc>
801047c4:	8b 50 10             	mov    0x10(%eax),%edx
801047c7:	8b 45 08             	mov    0x8(%ebp),%eax
801047ca:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801047cd:	8b 45 08             	mov    0x8(%ebp),%eax
801047d0:	83 c0 04             	add    $0x4,%eax
801047d3:	83 ec 0c             	sub    $0xc,%esp
801047d6:	50                   	push   %eax
801047d7:	e8 53 01 00 00       	call   8010492f <release>
801047dc:	83 c4 10             	add    $0x10,%esp
}
801047df:	90                   	nop
801047e0:	c9                   	leave
801047e1:	c3                   	ret

801047e2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801047e2:	55                   	push   %ebp
801047e3:	89 e5                	mov    %esp,%ebp
801047e5:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801047e8:	8b 45 08             	mov    0x8(%ebp),%eax
801047eb:	83 c0 04             	add    $0x4,%eax
801047ee:	83 ec 0c             	sub    $0xc,%esp
801047f1:	50                   	push   %eax
801047f2:	e8 ca 00 00 00       	call   801048c1 <acquire>
801047f7:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801047fa:	8b 45 08             	mov    0x8(%ebp),%eax
801047fd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104803:	8b 45 08             	mov    0x8(%ebp),%eax
80104806:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
8010480d:	83 ec 0c             	sub    $0xc,%esp
80104810:	ff 75 08             	push   0x8(%ebp)
80104813:	e8 33 fc ff ff       	call   8010444b <wakeup>
80104818:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
8010481b:	8b 45 08             	mov    0x8(%ebp),%eax
8010481e:	83 c0 04             	add    $0x4,%eax
80104821:	83 ec 0c             	sub    $0xc,%esp
80104824:	50                   	push   %eax
80104825:	e8 05 01 00 00       	call   8010492f <release>
8010482a:	83 c4 10             	add    $0x10,%esp
}
8010482d:	90                   	nop
8010482e:	c9                   	leave
8010482f:	c3                   	ret

80104830 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104830:	55                   	push   %ebp
80104831:	89 e5                	mov    %esp,%ebp
80104833:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104836:	8b 45 08             	mov    0x8(%ebp),%eax
80104839:	83 c0 04             	add    $0x4,%eax
8010483c:	83 ec 0c             	sub    $0xc,%esp
8010483f:	50                   	push   %eax
80104840:	e8 7c 00 00 00       	call   801048c1 <acquire>
80104845:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104848:	8b 45 08             	mov    0x8(%ebp),%eax
8010484b:	8b 00                	mov    (%eax),%eax
8010484d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104850:	8b 45 08             	mov    0x8(%ebp),%eax
80104853:	83 c0 04             	add    $0x4,%eax
80104856:	83 ec 0c             	sub    $0xc,%esp
80104859:	50                   	push   %eax
8010485a:	e8 d0 00 00 00       	call   8010492f <release>
8010485f:	83 c4 10             	add    $0x10,%esp
  return r;
80104862:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104865:	c9                   	leave
80104866:	c3                   	ret

80104867 <readeflags>:
{
80104867:	55                   	push   %ebp
80104868:	89 e5                	mov    %esp,%ebp
8010486a:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010486d:	9c                   	pushf
8010486e:	58                   	pop    %eax
8010486f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104872:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104875:	c9                   	leave
80104876:	c3                   	ret

80104877 <cli>:
{
80104877:	55                   	push   %ebp
80104878:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010487a:	fa                   	cli
}
8010487b:	90                   	nop
8010487c:	5d                   	pop    %ebp
8010487d:	c3                   	ret

8010487e <sti>:
{
8010487e:	55                   	push   %ebp
8010487f:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104881:	fb                   	sti
}
80104882:	90                   	nop
80104883:	5d                   	pop    %ebp
80104884:	c3                   	ret

80104885 <xchg>:
{
80104885:	55                   	push   %ebp
80104886:	89 e5                	mov    %esp,%ebp
80104888:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
8010488b:	8b 55 08             	mov    0x8(%ebp),%edx
8010488e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104891:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104894:	f0 87 02             	lock xchg %eax,(%edx)
80104897:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
8010489a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010489d:	c9                   	leave
8010489e:	c3                   	ret

8010489f <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010489f:	55                   	push   %ebp
801048a0:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801048a2:	8b 45 08             	mov    0x8(%ebp),%eax
801048a5:	8b 55 0c             	mov    0xc(%ebp),%edx
801048a8:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801048ab:	8b 45 08             	mov    0x8(%ebp),%eax
801048ae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801048b4:	8b 45 08             	mov    0x8(%ebp),%eax
801048b7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801048be:	90                   	nop
801048bf:	5d                   	pop    %ebp
801048c0:	c3                   	ret

801048c1 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801048c1:	55                   	push   %ebp
801048c2:	89 e5                	mov    %esp,%ebp
801048c4:	53                   	push   %ebx
801048c5:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801048c8:	e8 5f 01 00 00       	call   80104a2c <pushcli>
  if(holding(lk)){
801048cd:	8b 45 08             	mov    0x8(%ebp),%eax
801048d0:	83 ec 0c             	sub    $0xc,%esp
801048d3:	50                   	push   %eax
801048d4:	e8 23 01 00 00       	call   801049fc <holding>
801048d9:	83 c4 10             	add    $0x10,%esp
801048dc:	85 c0                	test   %eax,%eax
801048de:	74 0d                	je     801048ed <acquire+0x2c>
    panic("acquire");
801048e0:	83 ec 0c             	sub    $0xc,%esp
801048e3:	68 0c a8 10 80       	push   $0x8010a80c
801048e8:	e8 d4 bc ff ff       	call   801005c1 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801048ed:	90                   	nop
801048ee:	8b 45 08             	mov    0x8(%ebp),%eax
801048f1:	83 ec 08             	sub    $0x8,%esp
801048f4:	6a 01                	push   $0x1
801048f6:	50                   	push   %eax
801048f7:	e8 89 ff ff ff       	call   80104885 <xchg>
801048fc:	83 c4 10             	add    $0x10,%esp
801048ff:	85 c0                	test   %eax,%eax
80104901:	75 eb                	jne    801048ee <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104903:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104908:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010490b:	e8 05 f1 ff ff       	call   80103a15 <mycpu>
80104910:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104913:	8b 45 08             	mov    0x8(%ebp),%eax
80104916:	83 c0 0c             	add    $0xc,%eax
80104919:	83 ec 08             	sub    $0x8,%esp
8010491c:	50                   	push   %eax
8010491d:	8d 45 08             	lea    0x8(%ebp),%eax
80104920:	50                   	push   %eax
80104921:	e8 5b 00 00 00       	call   80104981 <getcallerpcs>
80104926:	83 c4 10             	add    $0x10,%esp
}
80104929:	90                   	nop
8010492a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010492d:	c9                   	leave
8010492e:	c3                   	ret

8010492f <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010492f:	55                   	push   %ebp
80104930:	89 e5                	mov    %esp,%ebp
80104932:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104935:	83 ec 0c             	sub    $0xc,%esp
80104938:	ff 75 08             	push   0x8(%ebp)
8010493b:	e8 bc 00 00 00       	call   801049fc <holding>
80104940:	83 c4 10             	add    $0x10,%esp
80104943:	85 c0                	test   %eax,%eax
80104945:	75 0d                	jne    80104954 <release+0x25>
    panic("release");
80104947:	83 ec 0c             	sub    $0xc,%esp
8010494a:	68 14 a8 10 80       	push   $0x8010a814
8010494f:	e8 6d bc ff ff       	call   801005c1 <panic>

  lk->pcs[0] = 0;
80104954:	8b 45 08             	mov    0x8(%ebp),%eax
80104957:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010495e:	8b 45 08             	mov    0x8(%ebp),%eax
80104961:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104968:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010496d:	8b 45 08             	mov    0x8(%ebp),%eax
80104970:	8b 55 08             	mov    0x8(%ebp),%edx
80104973:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104979:	e8 fb 00 00 00       	call   80104a79 <popcli>
}
8010497e:	90                   	nop
8010497f:	c9                   	leave
80104980:	c3                   	ret

80104981 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104981:	55                   	push   %ebp
80104982:	89 e5                	mov    %esp,%ebp
80104984:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104987:	8b 45 08             	mov    0x8(%ebp),%eax
8010498a:	83 e8 08             	sub    $0x8,%eax
8010498d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104990:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104997:	eb 38                	jmp    801049d1 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104999:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010499d:	74 53                	je     801049f2 <getcallerpcs+0x71>
8010499f:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801049a6:	76 4a                	jbe    801049f2 <getcallerpcs+0x71>
801049a8:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801049ac:	74 44                	je     801049f2 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801049ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
801049b1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801049b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801049bb:	01 c2                	add    %eax,%edx
801049bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049c0:	8b 40 04             	mov    0x4(%eax),%eax
801049c3:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801049c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049c8:	8b 00                	mov    (%eax),%eax
801049ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801049cd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801049d1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801049d5:	7e c2                	jle    80104999 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
801049d7:	eb 19                	jmp    801049f2 <getcallerpcs+0x71>
    pcs[i] = 0;
801049d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801049dc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801049e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801049e6:	01 d0                	add    %edx,%eax
801049e8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801049ee:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801049f2:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801049f6:	7e e1                	jle    801049d9 <getcallerpcs+0x58>
}
801049f8:	90                   	nop
801049f9:	90                   	nop
801049fa:	c9                   	leave
801049fb:	c3                   	ret

801049fc <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801049fc:	55                   	push   %ebp
801049fd:	89 e5                	mov    %esp,%ebp
801049ff:	53                   	push   %ebx
80104a00:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104a03:	8b 45 08             	mov    0x8(%ebp),%eax
80104a06:	8b 00                	mov    (%eax),%eax
80104a08:	85 c0                	test   %eax,%eax
80104a0a:	74 16                	je     80104a22 <holding+0x26>
80104a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a0f:	8b 58 08             	mov    0x8(%eax),%ebx
80104a12:	e8 fe ef ff ff       	call   80103a15 <mycpu>
80104a17:	39 c3                	cmp    %eax,%ebx
80104a19:	75 07                	jne    80104a22 <holding+0x26>
80104a1b:	b8 01 00 00 00       	mov    $0x1,%eax
80104a20:	eb 05                	jmp    80104a27 <holding+0x2b>
80104a22:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a2a:	c9                   	leave
80104a2b:	c3                   	ret

80104a2c <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104a2c:	55                   	push   %ebp
80104a2d:	89 e5                	mov    %esp,%ebp
80104a2f:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104a32:	e8 30 fe ff ff       	call   80104867 <readeflags>
80104a37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104a3a:	e8 38 fe ff ff       	call   80104877 <cli>
  if(mycpu()->ncli == 0)
80104a3f:	e8 d1 ef ff ff       	call   80103a15 <mycpu>
80104a44:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a4a:	85 c0                	test   %eax,%eax
80104a4c:	75 14                	jne    80104a62 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104a4e:	e8 c2 ef ff ff       	call   80103a15 <mycpu>
80104a53:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a56:	81 e2 00 02 00 00    	and    $0x200,%edx
80104a5c:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104a62:	e8 ae ef ff ff       	call   80103a15 <mycpu>
80104a67:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104a6d:	83 c2 01             	add    $0x1,%edx
80104a70:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104a76:	90                   	nop
80104a77:	c9                   	leave
80104a78:	c3                   	ret

80104a79 <popcli>:

void
popcli(void)
{
80104a79:	55                   	push   %ebp
80104a7a:	89 e5                	mov    %esp,%ebp
80104a7c:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104a7f:	e8 e3 fd ff ff       	call   80104867 <readeflags>
80104a84:	25 00 02 00 00       	and    $0x200,%eax
80104a89:	85 c0                	test   %eax,%eax
80104a8b:	74 0d                	je     80104a9a <popcli+0x21>
    panic("popcli - interruptible");
80104a8d:	83 ec 0c             	sub    $0xc,%esp
80104a90:	68 1c a8 10 80       	push   $0x8010a81c
80104a95:	e8 27 bb ff ff       	call   801005c1 <panic>
  if(--mycpu()->ncli < 0)
80104a9a:	e8 76 ef ff ff       	call   80103a15 <mycpu>
80104a9f:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104aa5:	83 ea 01             	sub    $0x1,%edx
80104aa8:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104aae:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ab4:	85 c0                	test   %eax,%eax
80104ab6:	79 0d                	jns    80104ac5 <popcli+0x4c>
    panic("popcli");
80104ab8:	83 ec 0c             	sub    $0xc,%esp
80104abb:	68 33 a8 10 80       	push   $0x8010a833
80104ac0:	e8 fc ba ff ff       	call   801005c1 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104ac5:	e8 4b ef ff ff       	call   80103a15 <mycpu>
80104aca:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ad0:	85 c0                	test   %eax,%eax
80104ad2:	75 14                	jne    80104ae8 <popcli+0x6f>
80104ad4:	e8 3c ef ff ff       	call   80103a15 <mycpu>
80104ad9:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104adf:	85 c0                	test   %eax,%eax
80104ae1:	74 05                	je     80104ae8 <popcli+0x6f>
    sti();
80104ae3:	e8 96 fd ff ff       	call   8010487e <sti>
}
80104ae8:	90                   	nop
80104ae9:	c9                   	leave
80104aea:	c3                   	ret

80104aeb <stosb>:
{
80104aeb:	55                   	push   %ebp
80104aec:	89 e5                	mov    %esp,%ebp
80104aee:	57                   	push   %edi
80104aef:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104af0:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104af3:	8b 55 10             	mov    0x10(%ebp),%edx
80104af6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104af9:	89 cb                	mov    %ecx,%ebx
80104afb:	89 df                	mov    %ebx,%edi
80104afd:	89 d1                	mov    %edx,%ecx
80104aff:	fc                   	cld
80104b00:	f3 aa                	rep stos %al,%es:(%edi)
80104b02:	89 ca                	mov    %ecx,%edx
80104b04:	89 fb                	mov    %edi,%ebx
80104b06:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104b09:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104b0c:	90                   	nop
80104b0d:	5b                   	pop    %ebx
80104b0e:	5f                   	pop    %edi
80104b0f:	5d                   	pop    %ebp
80104b10:	c3                   	ret

80104b11 <stosl>:
{
80104b11:	55                   	push   %ebp
80104b12:	89 e5                	mov    %esp,%ebp
80104b14:	57                   	push   %edi
80104b15:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104b16:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b19:	8b 55 10             	mov    0x10(%ebp),%edx
80104b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b1f:	89 cb                	mov    %ecx,%ebx
80104b21:	89 df                	mov    %ebx,%edi
80104b23:	89 d1                	mov    %edx,%ecx
80104b25:	fc                   	cld
80104b26:	f3 ab                	rep stos %eax,%es:(%edi)
80104b28:	89 ca                	mov    %ecx,%edx
80104b2a:	89 fb                	mov    %edi,%ebx
80104b2c:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104b2f:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104b32:	90                   	nop
80104b33:	5b                   	pop    %ebx
80104b34:	5f                   	pop    %edi
80104b35:	5d                   	pop    %ebp
80104b36:	c3                   	ret

80104b37 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104b37:	55                   	push   %ebp
80104b38:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104b3a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b3d:	83 e0 03             	and    $0x3,%eax
80104b40:	85 c0                	test   %eax,%eax
80104b42:	75 43                	jne    80104b87 <memset+0x50>
80104b44:	8b 45 10             	mov    0x10(%ebp),%eax
80104b47:	83 e0 03             	and    $0x3,%eax
80104b4a:	85 c0                	test   %eax,%eax
80104b4c:	75 39                	jne    80104b87 <memset+0x50>
    c &= 0xFF;
80104b4e:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104b55:	8b 45 10             	mov    0x10(%ebp),%eax
80104b58:	c1 e8 02             	shr    $0x2,%eax
80104b5b:	89 c1                	mov    %eax,%ecx
80104b5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b60:	c1 e0 18             	shl    $0x18,%eax
80104b63:	89 c2                	mov    %eax,%edx
80104b65:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b68:	c1 e0 10             	shl    $0x10,%eax
80104b6b:	09 c2                	or     %eax,%edx
80104b6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b70:	c1 e0 08             	shl    $0x8,%eax
80104b73:	09 d0                	or     %edx,%eax
80104b75:	0b 45 0c             	or     0xc(%ebp),%eax
80104b78:	51                   	push   %ecx
80104b79:	50                   	push   %eax
80104b7a:	ff 75 08             	push   0x8(%ebp)
80104b7d:	e8 8f ff ff ff       	call   80104b11 <stosl>
80104b82:	83 c4 0c             	add    $0xc,%esp
80104b85:	eb 12                	jmp    80104b99 <memset+0x62>
  } else
    stosb(dst, c, n);
80104b87:	8b 45 10             	mov    0x10(%ebp),%eax
80104b8a:	50                   	push   %eax
80104b8b:	ff 75 0c             	push   0xc(%ebp)
80104b8e:	ff 75 08             	push   0x8(%ebp)
80104b91:	e8 55 ff ff ff       	call   80104aeb <stosb>
80104b96:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104b99:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104b9c:	c9                   	leave
80104b9d:	c3                   	ret

80104b9e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104b9e:	55                   	push   %ebp
80104b9f:	89 e5                	mov    %esp,%ebp
80104ba1:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104ba4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104baa:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bad:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104bb0:	eb 2e                	jmp    80104be0 <memcmp+0x42>
    if(*s1 != *s2)
80104bb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bb5:	0f b6 10             	movzbl (%eax),%edx
80104bb8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bbb:	0f b6 00             	movzbl (%eax),%eax
80104bbe:	38 c2                	cmp    %al,%dl
80104bc0:	74 16                	je     80104bd8 <memcmp+0x3a>
      return *s1 - *s2;
80104bc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bc5:	0f b6 00             	movzbl (%eax),%eax
80104bc8:	0f b6 d0             	movzbl %al,%edx
80104bcb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bce:	0f b6 00             	movzbl (%eax),%eax
80104bd1:	0f b6 c0             	movzbl %al,%eax
80104bd4:	29 c2                	sub    %eax,%edx
80104bd6:	eb 1a                	jmp    80104bf2 <memcmp+0x54>
    s1++, s2++;
80104bd8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104bdc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104be0:	8b 45 10             	mov    0x10(%ebp),%eax
80104be3:	8d 50 ff             	lea    -0x1(%eax),%edx
80104be6:	89 55 10             	mov    %edx,0x10(%ebp)
80104be9:	85 c0                	test   %eax,%eax
80104beb:	75 c5                	jne    80104bb2 <memcmp+0x14>
  }

  return 0;
80104bed:	ba 00 00 00 00       	mov    $0x0,%edx
}
80104bf2:	89 d0                	mov    %edx,%eax
80104bf4:	c9                   	leave
80104bf5:	c3                   	ret

80104bf6 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104bf6:	55                   	push   %ebp
80104bf7:	89 e5                	mov    %esp,%ebp
80104bf9:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104c02:	8b 45 08             	mov    0x8(%ebp),%eax
80104c05:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104c08:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c0b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104c0e:	73 54                	jae    80104c64 <memmove+0x6e>
80104c10:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104c13:	8b 45 10             	mov    0x10(%ebp),%eax
80104c16:	01 d0                	add    %edx,%eax
80104c18:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104c1b:	73 47                	jae    80104c64 <memmove+0x6e>
    s += n;
80104c1d:	8b 45 10             	mov    0x10(%ebp),%eax
80104c20:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104c23:	8b 45 10             	mov    0x10(%ebp),%eax
80104c26:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104c29:	eb 13                	jmp    80104c3e <memmove+0x48>
      *--d = *--s;
80104c2b:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104c2f:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104c33:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c36:	0f b6 10             	movzbl (%eax),%edx
80104c39:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c3c:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104c3e:	8b 45 10             	mov    0x10(%ebp),%eax
80104c41:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c44:	89 55 10             	mov    %edx,0x10(%ebp)
80104c47:	85 c0                	test   %eax,%eax
80104c49:	75 e0                	jne    80104c2b <memmove+0x35>
  if(s < d && s + n > d){
80104c4b:	eb 24                	jmp    80104c71 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104c4d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104c50:	8d 42 01             	lea    0x1(%edx),%eax
80104c53:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104c56:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c59:	8d 48 01             	lea    0x1(%eax),%ecx
80104c5c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104c5f:	0f b6 12             	movzbl (%edx),%edx
80104c62:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104c64:	8b 45 10             	mov    0x10(%ebp),%eax
80104c67:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c6a:	89 55 10             	mov    %edx,0x10(%ebp)
80104c6d:	85 c0                	test   %eax,%eax
80104c6f:	75 dc                	jne    80104c4d <memmove+0x57>

  return dst;
80104c71:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104c74:	c9                   	leave
80104c75:	c3                   	ret

80104c76 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104c76:	55                   	push   %ebp
80104c77:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104c79:	ff 75 10             	push   0x10(%ebp)
80104c7c:	ff 75 0c             	push   0xc(%ebp)
80104c7f:	ff 75 08             	push   0x8(%ebp)
80104c82:	e8 6f ff ff ff       	call   80104bf6 <memmove>
80104c87:	83 c4 0c             	add    $0xc,%esp
}
80104c8a:	c9                   	leave
80104c8b:	c3                   	ret

80104c8c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104c8c:	55                   	push   %ebp
80104c8d:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104c8f:	eb 0c                	jmp    80104c9d <strncmp+0x11>
    n--, p++, q++;
80104c91:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104c95:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104c99:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104c9d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ca1:	74 1a                	je     80104cbd <strncmp+0x31>
80104ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca6:	0f b6 00             	movzbl (%eax),%eax
80104ca9:	84 c0                	test   %al,%al
80104cab:	74 10                	je     80104cbd <strncmp+0x31>
80104cad:	8b 45 08             	mov    0x8(%ebp),%eax
80104cb0:	0f b6 10             	movzbl (%eax),%edx
80104cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cb6:	0f b6 00             	movzbl (%eax),%eax
80104cb9:	38 c2                	cmp    %al,%dl
80104cbb:	74 d4                	je     80104c91 <strncmp+0x5>
  if(n == 0)
80104cbd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104cc1:	75 07                	jne    80104cca <strncmp+0x3e>
    return 0;
80104cc3:	ba 00 00 00 00       	mov    $0x0,%edx
80104cc8:	eb 14                	jmp    80104cde <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
80104cca:	8b 45 08             	mov    0x8(%ebp),%eax
80104ccd:	0f b6 00             	movzbl (%eax),%eax
80104cd0:	0f b6 d0             	movzbl %al,%edx
80104cd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cd6:	0f b6 00             	movzbl (%eax),%eax
80104cd9:	0f b6 c0             	movzbl %al,%eax
80104cdc:	29 c2                	sub    %eax,%edx
}
80104cde:	89 d0                	mov    %edx,%eax
80104ce0:	5d                   	pop    %ebp
80104ce1:	c3                   	ret

80104ce2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104ce2:	55                   	push   %ebp
80104ce3:	89 e5                	mov    %esp,%ebp
80104ce5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104ce8:	8b 45 08             	mov    0x8(%ebp),%eax
80104ceb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104cee:	90                   	nop
80104cef:	8b 45 10             	mov    0x10(%ebp),%eax
80104cf2:	8d 50 ff             	lea    -0x1(%eax),%edx
80104cf5:	89 55 10             	mov    %edx,0x10(%ebp)
80104cf8:	85 c0                	test   %eax,%eax
80104cfa:	7e 2c                	jle    80104d28 <strncpy+0x46>
80104cfc:	8b 55 0c             	mov    0xc(%ebp),%edx
80104cff:	8d 42 01             	lea    0x1(%edx),%eax
80104d02:	89 45 0c             	mov    %eax,0xc(%ebp)
80104d05:	8b 45 08             	mov    0x8(%ebp),%eax
80104d08:	8d 48 01             	lea    0x1(%eax),%ecx
80104d0b:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104d0e:	0f b6 12             	movzbl (%edx),%edx
80104d11:	88 10                	mov    %dl,(%eax)
80104d13:	0f b6 00             	movzbl (%eax),%eax
80104d16:	84 c0                	test   %al,%al
80104d18:	75 d5                	jne    80104cef <strncpy+0xd>
    ;
  while(n-- > 0)
80104d1a:	eb 0c                	jmp    80104d28 <strncpy+0x46>
    *s++ = 0;
80104d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d1f:	8d 50 01             	lea    0x1(%eax),%edx
80104d22:	89 55 08             	mov    %edx,0x8(%ebp)
80104d25:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104d28:	8b 45 10             	mov    0x10(%ebp),%eax
80104d2b:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d2e:	89 55 10             	mov    %edx,0x10(%ebp)
80104d31:	85 c0                	test   %eax,%eax
80104d33:	7f e7                	jg     80104d1c <strncpy+0x3a>
  return os;
80104d35:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d38:	c9                   	leave
80104d39:	c3                   	ret

80104d3a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104d3a:	55                   	push   %ebp
80104d3b:	89 e5                	mov    %esp,%ebp
80104d3d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104d40:	8b 45 08             	mov    0x8(%ebp),%eax
80104d43:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104d46:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d4a:	7f 05                	jg     80104d51 <safestrcpy+0x17>
    return os;
80104d4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d4f:	eb 32                	jmp    80104d83 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104d51:	90                   	nop
80104d52:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104d56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d5a:	7e 1e                	jle    80104d7a <safestrcpy+0x40>
80104d5c:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d5f:	8d 42 01             	lea    0x1(%edx),%eax
80104d62:	89 45 0c             	mov    %eax,0xc(%ebp)
80104d65:	8b 45 08             	mov    0x8(%ebp),%eax
80104d68:	8d 48 01             	lea    0x1(%eax),%ecx
80104d6b:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104d6e:	0f b6 12             	movzbl (%edx),%edx
80104d71:	88 10                	mov    %dl,(%eax)
80104d73:	0f b6 00             	movzbl (%eax),%eax
80104d76:	84 c0                	test   %al,%al
80104d78:	75 d8                	jne    80104d52 <safestrcpy+0x18>
    ;
  *s = 0;
80104d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d7d:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104d80:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d83:	c9                   	leave
80104d84:	c3                   	ret

80104d85 <strlen>:

int
strlen(const char *s)
{
80104d85:	55                   	push   %ebp
80104d86:	89 e5                	mov    %esp,%ebp
80104d88:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104d8b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104d92:	eb 04                	jmp    80104d98 <strlen+0x13>
80104d94:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104d98:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80104d9e:	01 d0                	add    %edx,%eax
80104da0:	0f b6 00             	movzbl (%eax),%eax
80104da3:	84 c0                	test   %al,%al
80104da5:	75 ed                	jne    80104d94 <strlen+0xf>
    ;
  return n;
80104da7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104daa:	c9                   	leave
80104dab:	c3                   	ret

80104dac <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104dac:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104db0:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104db4:	55                   	push   %ebp
  pushl %ebx
80104db5:	53                   	push   %ebx
  pushl %esi
80104db6:	56                   	push   %esi
  pushl %edi
80104db7:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104db8:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104dba:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104dbc:	5f                   	pop    %edi
  popl %esi
80104dbd:	5e                   	pop    %esi
  popl %ebx
80104dbe:	5b                   	pop    %ebx
  popl %ebp
80104dbf:	5d                   	pop    %ebp
  ret
80104dc0:	c3                   	ret

80104dc1 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104dc1:	55                   	push   %ebp
80104dc2:	89 e5                	mov    %esp,%ebp
  // sz가 stack영역은 포함하지 않게 설정되었기 때문에 kernbase로 변경
  // fetchstr, argptr도 동일
  if(addr >= KERNBASE || addr+4 >= KERNBASE)
80104dc4:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc7:	85 c0                	test   %eax,%eax
80104dc9:	78 0a                	js     80104dd5 <fetchint+0x14>
80104dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80104dce:	83 c0 04             	add    $0x4,%eax
80104dd1:	85 c0                	test   %eax,%eax
80104dd3:	79 07                	jns    80104ddc <fetchint+0x1b>
    return -1;
80104dd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dda:	eb 0f                	jmp    80104deb <fetchint+0x2a>
  *ip = *(int*)(addr);
80104ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80104ddf:	8b 10                	mov    (%eax),%edx
80104de1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104de4:	89 10                	mov    %edx,(%eax)
  return 0;
80104de6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104deb:	5d                   	pop    %ebp
80104dec:	c3                   	ret

80104ded <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104ded:	55                   	push   %ebp
80104dee:	89 e5                	mov    %esp,%ebp
80104df0:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= KERNBASE)
80104df3:	8b 45 08             	mov    0x8(%ebp),%eax
80104df6:	85 c0                	test   %eax,%eax
80104df8:	79 07                	jns    80104e01 <fetchstr+0x14>
    return -1;
80104dfa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dff:	eb 40                	jmp    80104e41 <fetchstr+0x54>
  *pp = (char*)addr;
80104e01:	8b 55 08             	mov    0x8(%ebp),%edx
80104e04:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e07:	89 10                	mov    %edx,(%eax)
  ep = (char*)(KERNBASE-1);
80104e09:	c7 45 f8 ff ff ff 7f 	movl   $0x7fffffff,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
80104e10:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e13:	8b 00                	mov    (%eax),%eax
80104e15:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104e18:	eb 1a                	jmp    80104e34 <fetchstr+0x47>
    if(*s == 0)
80104e1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e1d:	0f b6 00             	movzbl (%eax),%eax
80104e20:	84 c0                	test   %al,%al
80104e22:	75 0c                	jne    80104e30 <fetchstr+0x43>
      return s - *pp;
80104e24:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e27:	8b 10                	mov    (%eax),%edx
80104e29:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e2c:	29 d0                	sub    %edx,%eax
80104e2e:	eb 11                	jmp    80104e41 <fetchstr+0x54>
  for(s = *pp; s < ep; s++){
80104e30:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104e34:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e37:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e3a:	72 de                	jb     80104e1a <fetchstr+0x2d>
  }
  return -1;
80104e3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104e41:	c9                   	leave
80104e42:	c3                   	ret

80104e43 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104e43:	55                   	push   %ebp
80104e44:	89 e5                	mov    %esp,%ebp
80104e46:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104e49:	e8 3f ec ff ff       	call   80103a8d <myproc>
80104e4e:	8b 40 18             	mov    0x18(%eax),%eax
80104e51:	8b 40 44             	mov    0x44(%eax),%eax
80104e54:	8b 55 08             	mov    0x8(%ebp),%edx
80104e57:	c1 e2 02             	shl    $0x2,%edx
80104e5a:	01 d0                	add    %edx,%eax
80104e5c:	83 c0 04             	add    $0x4,%eax
80104e5f:	83 ec 08             	sub    $0x8,%esp
80104e62:	ff 75 0c             	push   0xc(%ebp)
80104e65:	50                   	push   %eax
80104e66:	e8 56 ff ff ff       	call   80104dc1 <fetchint>
80104e6b:	83 c4 10             	add    $0x10,%esp
}
80104e6e:	c9                   	leave
80104e6f:	c3                   	ret

80104e70 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104e70:	55                   	push   %ebp
80104e71:	89 e5                	mov    %esp,%ebp
80104e73:	83 ec 18             	sub    $0x18,%esp
  int i;
 
  if(argint(n, &i) < 0)
80104e76:	83 ec 08             	sub    $0x8,%esp
80104e79:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e7c:	50                   	push   %eax
80104e7d:	ff 75 08             	push   0x8(%ebp)
80104e80:	e8 be ff ff ff       	call   80104e43 <argint>
80104e85:	83 c4 10             	add    $0x10,%esp
80104e88:	85 c0                	test   %eax,%eax
80104e8a:	79 07                	jns    80104e93 <argptr+0x23>
    return -1;
80104e8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e91:	eb 34                	jmp    80104ec7 <argptr+0x57>
  if(size < 0 || (uint)i >= KERNBASE || (uint)i+size > KERNBASE)
80104e93:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e97:	78 18                	js     80104eb1 <argptr+0x41>
80104e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e9c:	85 c0                	test   %eax,%eax
80104e9e:	78 11                	js     80104eb1 <argptr+0x41>
80104ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea3:	89 c2                	mov    %eax,%edx
80104ea5:	8b 45 10             	mov    0x10(%ebp),%eax
80104ea8:	01 d0                	add    %edx,%eax
80104eaa:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80104eaf:	76 07                	jbe    80104eb8 <argptr+0x48>
    return -1;
80104eb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eb6:	eb 0f                	jmp    80104ec7 <argptr+0x57>
  *pp = (char*)i;
80104eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ebb:	89 c2                	mov    %eax,%edx
80104ebd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ec0:	89 10                	mov    %edx,(%eax)
  return 0;
80104ec2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ec7:	c9                   	leave
80104ec8:	c3                   	ret

80104ec9 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104ec9:	55                   	push   %ebp
80104eca:	89 e5                	mov    %esp,%ebp
80104ecc:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104ecf:	83 ec 08             	sub    $0x8,%esp
80104ed2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ed5:	50                   	push   %eax
80104ed6:	ff 75 08             	push   0x8(%ebp)
80104ed9:	e8 65 ff ff ff       	call   80104e43 <argint>
80104ede:	83 c4 10             	add    $0x10,%esp
80104ee1:	85 c0                	test   %eax,%eax
80104ee3:	79 07                	jns    80104eec <argstr+0x23>
    return -1;
80104ee5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eea:	eb 12                	jmp    80104efe <argstr+0x35>
  return fetchstr(addr, pp);
80104eec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eef:	83 ec 08             	sub    $0x8,%esp
80104ef2:	ff 75 0c             	push   0xc(%ebp)
80104ef5:	50                   	push   %eax
80104ef6:	e8 f2 fe ff ff       	call   80104ded <fetchstr>
80104efb:	83 c4 10             	add    $0x10,%esp
}
80104efe:	c9                   	leave
80104eff:	c3                   	ret

80104f00 <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
80104f00:	55                   	push   %ebp
80104f01:	89 e5                	mov    %esp,%ebp
80104f03:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104f06:	e8 82 eb ff ff       	call   80103a8d <myproc>
80104f0b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f11:	8b 40 18             	mov    0x18(%eax),%eax
80104f14:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f17:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104f1a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104f1e:	7e 2f                	jle    80104f4f <syscall+0x4f>
80104f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f23:	83 f8 17             	cmp    $0x17,%eax
80104f26:	77 27                	ja     80104f4f <syscall+0x4f>
80104f28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f2b:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104f32:	85 c0                	test   %eax,%eax
80104f34:	74 19                	je     80104f4f <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f39:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104f40:	ff d0                	call   *%eax
80104f42:	89 c2                	mov    %eax,%edx
80104f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f47:	8b 40 18             	mov    0x18(%eax),%eax
80104f4a:	89 50 1c             	mov    %edx,0x1c(%eax)
80104f4d:	eb 2c                	jmp    80104f7b <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f52:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f58:	8b 40 10             	mov    0x10(%eax),%eax
80104f5b:	ff 75 f0             	push   -0x10(%ebp)
80104f5e:	52                   	push   %edx
80104f5f:	50                   	push   %eax
80104f60:	68 3a a8 10 80       	push   $0x8010a83a
80104f65:	e8 8a b4 ff ff       	call   801003f4 <cprintf>
80104f6a:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f70:	8b 40 18             	mov    0x18(%eax),%eax
80104f73:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
80104f7a:	90                   	nop
80104f7b:	90                   	nop
80104f7c:	c9                   	leave
80104f7d:	c3                   	ret

80104f7e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104f7e:	55                   	push   %ebp
80104f7f:	89 e5                	mov    %esp,%ebp
80104f81:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104f84:	83 ec 08             	sub    $0x8,%esp
80104f87:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f8a:	50                   	push   %eax
80104f8b:	ff 75 08             	push   0x8(%ebp)
80104f8e:	e8 b0 fe ff ff       	call   80104e43 <argint>
80104f93:	83 c4 10             	add    $0x10,%esp
80104f96:	85 c0                	test   %eax,%eax
80104f98:	79 07                	jns    80104fa1 <argfd+0x23>
    return -1;
80104f9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f9f:	eb 4f                	jmp    80104ff0 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa4:	85 c0                	test   %eax,%eax
80104fa6:	78 20                	js     80104fc8 <argfd+0x4a>
80104fa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fab:	83 f8 0f             	cmp    $0xf,%eax
80104fae:	7f 18                	jg     80104fc8 <argfd+0x4a>
80104fb0:	e8 d8 ea ff ff       	call   80103a8d <myproc>
80104fb5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104fb8:	83 c2 08             	add    $0x8,%edx
80104fbb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104fbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104fc2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104fc6:	75 07                	jne    80104fcf <argfd+0x51>
    return -1;
80104fc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fcd:	eb 21                	jmp    80104ff0 <argfd+0x72>
  if(pfd)
80104fcf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104fd3:	74 08                	je     80104fdd <argfd+0x5f>
    *pfd = fd;
80104fd5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fdb:	89 10                	mov    %edx,(%eax)
  if(pf)
80104fdd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fe1:	74 08                	je     80104feb <argfd+0x6d>
    *pf = f;
80104fe3:	8b 45 10             	mov    0x10(%ebp),%eax
80104fe6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fe9:	89 10                	mov    %edx,(%eax)
  return 0;
80104feb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ff0:	c9                   	leave
80104ff1:	c3                   	ret

80104ff2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104ff2:	55                   	push   %ebp
80104ff3:	89 e5                	mov    %esp,%ebp
80104ff5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104ff8:	e8 90 ea ff ff       	call   80103a8d <myproc>
80104ffd:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105000:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105007:	eb 2a                	jmp    80105033 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105009:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010500c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010500f:	83 c2 08             	add    $0x8,%edx
80105012:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105016:	85 c0                	test   %eax,%eax
80105018:	75 15                	jne    8010502f <fdalloc+0x3d>
      curproc->ofile[fd] = f;
8010501a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010501d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105020:	8d 4a 08             	lea    0x8(%edx),%ecx
80105023:	8b 55 08             	mov    0x8(%ebp),%edx
80105026:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010502a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010502d:	eb 0f                	jmp    8010503e <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
8010502f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105033:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105037:	7e d0                	jle    80105009 <fdalloc+0x17>
    }
  }
  return -1;
80105039:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010503e:	c9                   	leave
8010503f:	c3                   	ret

80105040 <sys_dup>:

int
sys_dup(void)
{
80105040:	55                   	push   %ebp
80105041:	89 e5                	mov    %esp,%ebp
80105043:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105046:	83 ec 04             	sub    $0x4,%esp
80105049:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010504c:	50                   	push   %eax
8010504d:	6a 00                	push   $0x0
8010504f:	6a 00                	push   $0x0
80105051:	e8 28 ff ff ff       	call   80104f7e <argfd>
80105056:	83 c4 10             	add    $0x10,%esp
80105059:	85 c0                	test   %eax,%eax
8010505b:	79 07                	jns    80105064 <sys_dup+0x24>
    return -1;
8010505d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105062:	eb 31                	jmp    80105095 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105064:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105067:	83 ec 0c             	sub    $0xc,%esp
8010506a:	50                   	push   %eax
8010506b:	e8 82 ff ff ff       	call   80104ff2 <fdalloc>
80105070:	83 c4 10             	add    $0x10,%esp
80105073:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105076:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010507a:	79 07                	jns    80105083 <sys_dup+0x43>
    return -1;
8010507c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105081:	eb 12                	jmp    80105095 <sys_dup+0x55>
  filedup(f);
80105083:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105086:	83 ec 0c             	sub    $0xc,%esp
80105089:	50                   	push   %eax
8010508a:	e8 22 c0 ff ff       	call   801010b1 <filedup>
8010508f:	83 c4 10             	add    $0x10,%esp
  return fd;
80105092:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105095:	c9                   	leave
80105096:	c3                   	ret

80105097 <sys_read>:

int
sys_read(void)
{
80105097:	55                   	push   %ebp
80105098:	89 e5                	mov    %esp,%ebp
8010509a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010509d:	83 ec 04             	sub    $0x4,%esp
801050a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050a3:	50                   	push   %eax
801050a4:	6a 00                	push   $0x0
801050a6:	6a 00                	push   $0x0
801050a8:	e8 d1 fe ff ff       	call   80104f7e <argfd>
801050ad:	83 c4 10             	add    $0x10,%esp
801050b0:	85 c0                	test   %eax,%eax
801050b2:	78 2e                	js     801050e2 <sys_read+0x4b>
801050b4:	83 ec 08             	sub    $0x8,%esp
801050b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050ba:	50                   	push   %eax
801050bb:	6a 02                	push   $0x2
801050bd:	e8 81 fd ff ff       	call   80104e43 <argint>
801050c2:	83 c4 10             	add    $0x10,%esp
801050c5:	85 c0                	test   %eax,%eax
801050c7:	78 19                	js     801050e2 <sys_read+0x4b>
801050c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050cc:	83 ec 04             	sub    $0x4,%esp
801050cf:	50                   	push   %eax
801050d0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801050d3:	50                   	push   %eax
801050d4:	6a 01                	push   $0x1
801050d6:	e8 95 fd ff ff       	call   80104e70 <argptr>
801050db:	83 c4 10             	add    $0x10,%esp
801050de:	85 c0                	test   %eax,%eax
801050e0:	79 07                	jns    801050e9 <sys_read+0x52>
    return -1;
801050e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050e7:	eb 17                	jmp    80105100 <sys_read+0x69>
  return fileread(f, p, n);
801050e9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801050ec:	8b 55 ec             	mov    -0x14(%ebp),%edx
801050ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f2:	83 ec 04             	sub    $0x4,%esp
801050f5:	51                   	push   %ecx
801050f6:	52                   	push   %edx
801050f7:	50                   	push   %eax
801050f8:	e8 44 c1 ff ff       	call   80101241 <fileread>
801050fd:	83 c4 10             	add    $0x10,%esp
}
80105100:	c9                   	leave
80105101:	c3                   	ret

80105102 <sys_write>:

int
sys_write(void)
{
80105102:	55                   	push   %ebp
80105103:	89 e5                	mov    %esp,%ebp
80105105:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105108:	83 ec 04             	sub    $0x4,%esp
8010510b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010510e:	50                   	push   %eax
8010510f:	6a 00                	push   $0x0
80105111:	6a 00                	push   $0x0
80105113:	e8 66 fe ff ff       	call   80104f7e <argfd>
80105118:	83 c4 10             	add    $0x10,%esp
8010511b:	85 c0                	test   %eax,%eax
8010511d:	78 2e                	js     8010514d <sys_write+0x4b>
8010511f:	83 ec 08             	sub    $0x8,%esp
80105122:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105125:	50                   	push   %eax
80105126:	6a 02                	push   $0x2
80105128:	e8 16 fd ff ff       	call   80104e43 <argint>
8010512d:	83 c4 10             	add    $0x10,%esp
80105130:	85 c0                	test   %eax,%eax
80105132:	78 19                	js     8010514d <sys_write+0x4b>
80105134:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105137:	83 ec 04             	sub    $0x4,%esp
8010513a:	50                   	push   %eax
8010513b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010513e:	50                   	push   %eax
8010513f:	6a 01                	push   $0x1
80105141:	e8 2a fd ff ff       	call   80104e70 <argptr>
80105146:	83 c4 10             	add    $0x10,%esp
80105149:	85 c0                	test   %eax,%eax
8010514b:	79 07                	jns    80105154 <sys_write+0x52>
    return -1;
8010514d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105152:	eb 17                	jmp    8010516b <sys_write+0x69>
  return filewrite(f, p, n);
80105154:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105157:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010515a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010515d:	83 ec 04             	sub    $0x4,%esp
80105160:	51                   	push   %ecx
80105161:	52                   	push   %edx
80105162:	50                   	push   %eax
80105163:	e8 91 c1 ff ff       	call   801012f9 <filewrite>
80105168:	83 c4 10             	add    $0x10,%esp
}
8010516b:	c9                   	leave
8010516c:	c3                   	ret

8010516d <sys_close>:

int
sys_close(void)
{
8010516d:	55                   	push   %ebp
8010516e:	89 e5                	mov    %esp,%ebp
80105170:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105173:	83 ec 04             	sub    $0x4,%esp
80105176:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105179:	50                   	push   %eax
8010517a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010517d:	50                   	push   %eax
8010517e:	6a 00                	push   $0x0
80105180:	e8 f9 fd ff ff       	call   80104f7e <argfd>
80105185:	83 c4 10             	add    $0x10,%esp
80105188:	85 c0                	test   %eax,%eax
8010518a:	79 07                	jns    80105193 <sys_close+0x26>
    return -1;
8010518c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105191:	eb 27                	jmp    801051ba <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105193:	e8 f5 e8 ff ff       	call   80103a8d <myproc>
80105198:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010519b:	83 c2 08             	add    $0x8,%edx
8010519e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801051a5:	00 
  fileclose(f);
801051a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051a9:	83 ec 0c             	sub    $0xc,%esp
801051ac:	50                   	push   %eax
801051ad:	e8 50 bf ff ff       	call   80101102 <fileclose>
801051b2:	83 c4 10             	add    $0x10,%esp
  return 0;
801051b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051ba:	c9                   	leave
801051bb:	c3                   	ret

801051bc <sys_fstat>:

int
sys_fstat(void)
{
801051bc:	55                   	push   %ebp
801051bd:	89 e5                	mov    %esp,%ebp
801051bf:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801051c2:	83 ec 04             	sub    $0x4,%esp
801051c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051c8:	50                   	push   %eax
801051c9:	6a 00                	push   $0x0
801051cb:	6a 00                	push   $0x0
801051cd:	e8 ac fd ff ff       	call   80104f7e <argfd>
801051d2:	83 c4 10             	add    $0x10,%esp
801051d5:	85 c0                	test   %eax,%eax
801051d7:	78 17                	js     801051f0 <sys_fstat+0x34>
801051d9:	83 ec 04             	sub    $0x4,%esp
801051dc:	6a 14                	push   $0x14
801051de:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051e1:	50                   	push   %eax
801051e2:	6a 01                	push   $0x1
801051e4:	e8 87 fc ff ff       	call   80104e70 <argptr>
801051e9:	83 c4 10             	add    $0x10,%esp
801051ec:	85 c0                	test   %eax,%eax
801051ee:	79 07                	jns    801051f7 <sys_fstat+0x3b>
    return -1;
801051f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051f5:	eb 13                	jmp    8010520a <sys_fstat+0x4e>
  return filestat(f, st);
801051f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fd:	83 ec 08             	sub    $0x8,%esp
80105200:	52                   	push   %edx
80105201:	50                   	push   %eax
80105202:	e8 e3 bf ff ff       	call   801011ea <filestat>
80105207:	83 c4 10             	add    $0x10,%esp
}
8010520a:	c9                   	leave
8010520b:	c3                   	ret

8010520c <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010520c:	55                   	push   %ebp
8010520d:	89 e5                	mov    %esp,%ebp
8010520f:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105212:	83 ec 08             	sub    $0x8,%esp
80105215:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105218:	50                   	push   %eax
80105219:	6a 00                	push   $0x0
8010521b:	e8 a9 fc ff ff       	call   80104ec9 <argstr>
80105220:	83 c4 10             	add    $0x10,%esp
80105223:	85 c0                	test   %eax,%eax
80105225:	78 15                	js     8010523c <sys_link+0x30>
80105227:	83 ec 08             	sub    $0x8,%esp
8010522a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010522d:	50                   	push   %eax
8010522e:	6a 01                	push   $0x1
80105230:	e8 94 fc ff ff       	call   80104ec9 <argstr>
80105235:	83 c4 10             	add    $0x10,%esp
80105238:	85 c0                	test   %eax,%eax
8010523a:	79 0a                	jns    80105246 <sys_link+0x3a>
    return -1;
8010523c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105241:	e9 68 01 00 00       	jmp    801053ae <sys_link+0x1a2>

  begin_op();
80105246:	e8 50 de ff ff       	call   8010309b <begin_op>
  if((ip = namei(old)) == 0){
8010524b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010524e:	83 ec 0c             	sub    $0xc,%esp
80105251:	50                   	push   %eax
80105252:	e8 2b d3 ff ff       	call   80102582 <namei>
80105257:	83 c4 10             	add    $0x10,%esp
8010525a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010525d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105261:	75 0f                	jne    80105272 <sys_link+0x66>
    end_op();
80105263:	e8 bf de ff ff       	call   80103127 <end_op>
    return -1;
80105268:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010526d:	e9 3c 01 00 00       	jmp    801053ae <sys_link+0x1a2>
  }

  ilock(ip);
80105272:	83 ec 0c             	sub    $0xc,%esp
80105275:	ff 75 f4             	push   -0xc(%ebp)
80105278:	e8 d2 c7 ff ff       	call   80101a4f <ilock>
8010527d:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105280:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105283:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105287:	66 83 f8 01          	cmp    $0x1,%ax
8010528b:	75 1d                	jne    801052aa <sys_link+0x9e>
    iunlockput(ip);
8010528d:	83 ec 0c             	sub    $0xc,%esp
80105290:	ff 75 f4             	push   -0xc(%ebp)
80105293:	e8 e8 c9 ff ff       	call   80101c80 <iunlockput>
80105298:	83 c4 10             	add    $0x10,%esp
    end_op();
8010529b:	e8 87 de ff ff       	call   80103127 <end_op>
    return -1;
801052a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052a5:	e9 04 01 00 00       	jmp    801053ae <sys_link+0x1a2>
  }

  ip->nlink++;
801052aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ad:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801052b1:	83 c0 01             	add    $0x1,%eax
801052b4:	89 c2                	mov    %eax,%edx
801052b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052b9:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801052bd:	83 ec 0c             	sub    $0xc,%esp
801052c0:	ff 75 f4             	push   -0xc(%ebp)
801052c3:	e8 aa c5 ff ff       	call   80101872 <iupdate>
801052c8:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801052cb:	83 ec 0c             	sub    $0xc,%esp
801052ce:	ff 75 f4             	push   -0xc(%ebp)
801052d1:	e8 8c c8 ff ff       	call   80101b62 <iunlock>
801052d6:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801052d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801052dc:	83 ec 08             	sub    $0x8,%esp
801052df:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801052e2:	52                   	push   %edx
801052e3:	50                   	push   %eax
801052e4:	e8 b5 d2 ff ff       	call   8010259e <nameiparent>
801052e9:	83 c4 10             	add    $0x10,%esp
801052ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
801052ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801052f3:	74 71                	je     80105366 <sys_link+0x15a>
    goto bad;
  ilock(dp);
801052f5:	83 ec 0c             	sub    $0xc,%esp
801052f8:	ff 75 f0             	push   -0x10(%ebp)
801052fb:	e8 4f c7 ff ff       	call   80101a4f <ilock>
80105300:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105303:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105306:	8b 10                	mov    (%eax),%edx
80105308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010530b:	8b 00                	mov    (%eax),%eax
8010530d:	39 c2                	cmp    %eax,%edx
8010530f:	75 1d                	jne    8010532e <sys_link+0x122>
80105311:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105314:	8b 40 04             	mov    0x4(%eax),%eax
80105317:	83 ec 04             	sub    $0x4,%esp
8010531a:	50                   	push   %eax
8010531b:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010531e:	50                   	push   %eax
8010531f:	ff 75 f0             	push   -0x10(%ebp)
80105322:	e8 c4 cf ff ff       	call   801022eb <dirlink>
80105327:	83 c4 10             	add    $0x10,%esp
8010532a:	85 c0                	test   %eax,%eax
8010532c:	79 10                	jns    8010533e <sys_link+0x132>
    iunlockput(dp);
8010532e:	83 ec 0c             	sub    $0xc,%esp
80105331:	ff 75 f0             	push   -0x10(%ebp)
80105334:	e8 47 c9 ff ff       	call   80101c80 <iunlockput>
80105339:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010533c:	eb 29                	jmp    80105367 <sys_link+0x15b>
  }
  iunlockput(dp);
8010533e:	83 ec 0c             	sub    $0xc,%esp
80105341:	ff 75 f0             	push   -0x10(%ebp)
80105344:	e8 37 c9 ff ff       	call   80101c80 <iunlockput>
80105349:	83 c4 10             	add    $0x10,%esp
  iput(ip);
8010534c:	83 ec 0c             	sub    $0xc,%esp
8010534f:	ff 75 f4             	push   -0xc(%ebp)
80105352:	e8 59 c8 ff ff       	call   80101bb0 <iput>
80105357:	83 c4 10             	add    $0x10,%esp

  end_op();
8010535a:	e8 c8 dd ff ff       	call   80103127 <end_op>

  return 0;
8010535f:	b8 00 00 00 00       	mov    $0x0,%eax
80105364:	eb 48                	jmp    801053ae <sys_link+0x1a2>
    goto bad;
80105366:	90                   	nop

bad:
  ilock(ip);
80105367:	83 ec 0c             	sub    $0xc,%esp
8010536a:	ff 75 f4             	push   -0xc(%ebp)
8010536d:	e8 dd c6 ff ff       	call   80101a4f <ilock>
80105372:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105378:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010537c:	83 e8 01             	sub    $0x1,%eax
8010537f:	89 c2                	mov    %eax,%edx
80105381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105384:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105388:	83 ec 0c             	sub    $0xc,%esp
8010538b:	ff 75 f4             	push   -0xc(%ebp)
8010538e:	e8 df c4 ff ff       	call   80101872 <iupdate>
80105393:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105396:	83 ec 0c             	sub    $0xc,%esp
80105399:	ff 75 f4             	push   -0xc(%ebp)
8010539c:	e8 df c8 ff ff       	call   80101c80 <iunlockput>
801053a1:	83 c4 10             	add    $0x10,%esp
  end_op();
801053a4:	e8 7e dd ff ff       	call   80103127 <end_op>
  return -1;
801053a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801053ae:	c9                   	leave
801053af:	c3                   	ret

801053b0 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801053b0:	55                   	push   %ebp
801053b1:	89 e5                	mov    %esp,%ebp
801053b3:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801053b6:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801053bd:	eb 40                	jmp    801053ff <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801053bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c2:	6a 10                	push   $0x10
801053c4:	50                   	push   %eax
801053c5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801053c8:	50                   	push   %eax
801053c9:	ff 75 08             	push   0x8(%ebp)
801053cc:	e8 6a cb ff ff       	call   80101f3b <readi>
801053d1:	83 c4 10             	add    $0x10,%esp
801053d4:	83 f8 10             	cmp    $0x10,%eax
801053d7:	74 0d                	je     801053e6 <isdirempty+0x36>
      panic("isdirempty: readi");
801053d9:	83 ec 0c             	sub    $0xc,%esp
801053dc:	68 56 a8 10 80       	push   $0x8010a856
801053e1:	e8 db b1 ff ff       	call   801005c1 <panic>
    if(de.inum != 0)
801053e6:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801053ea:	66 85 c0             	test   %ax,%ax
801053ed:	74 07                	je     801053f6 <isdirempty+0x46>
      return 0;
801053ef:	b8 00 00 00 00       	mov    $0x0,%eax
801053f4:	eb 1b                	jmp    80105411 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801053f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f9:	83 c0 10             	add    $0x10,%eax
801053fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105402:	8b 40 58             	mov    0x58(%eax),%eax
80105405:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105408:	39 c2                	cmp    %eax,%edx
8010540a:	72 b3                	jb     801053bf <isdirempty+0xf>
  }
  return 1;
8010540c:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105411:	c9                   	leave
80105412:	c3                   	ret

80105413 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105413:	55                   	push   %ebp
80105414:	89 e5                	mov    %esp,%ebp
80105416:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105419:	83 ec 08             	sub    $0x8,%esp
8010541c:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010541f:	50                   	push   %eax
80105420:	6a 00                	push   $0x0
80105422:	e8 a2 fa ff ff       	call   80104ec9 <argstr>
80105427:	83 c4 10             	add    $0x10,%esp
8010542a:	85 c0                	test   %eax,%eax
8010542c:	79 0a                	jns    80105438 <sys_unlink+0x25>
    return -1;
8010542e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105433:	e9 bf 01 00 00       	jmp    801055f7 <sys_unlink+0x1e4>

  begin_op();
80105438:	e8 5e dc ff ff       	call   8010309b <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010543d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105440:	83 ec 08             	sub    $0x8,%esp
80105443:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105446:	52                   	push   %edx
80105447:	50                   	push   %eax
80105448:	e8 51 d1 ff ff       	call   8010259e <nameiparent>
8010544d:	83 c4 10             	add    $0x10,%esp
80105450:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105453:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105457:	75 0f                	jne    80105468 <sys_unlink+0x55>
    end_op();
80105459:	e8 c9 dc ff ff       	call   80103127 <end_op>
    return -1;
8010545e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105463:	e9 8f 01 00 00       	jmp    801055f7 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105468:	83 ec 0c             	sub    $0xc,%esp
8010546b:	ff 75 f4             	push   -0xc(%ebp)
8010546e:	e8 dc c5 ff ff       	call   80101a4f <ilock>
80105473:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105476:	83 ec 08             	sub    $0x8,%esp
80105479:	68 68 a8 10 80       	push   $0x8010a868
8010547e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105481:	50                   	push   %eax
80105482:	e8 8f cd ff ff       	call   80102216 <namecmp>
80105487:	83 c4 10             	add    $0x10,%esp
8010548a:	85 c0                	test   %eax,%eax
8010548c:	0f 84 49 01 00 00    	je     801055db <sys_unlink+0x1c8>
80105492:	83 ec 08             	sub    $0x8,%esp
80105495:	68 6a a8 10 80       	push   $0x8010a86a
8010549a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010549d:	50                   	push   %eax
8010549e:	e8 73 cd ff ff       	call   80102216 <namecmp>
801054a3:	83 c4 10             	add    $0x10,%esp
801054a6:	85 c0                	test   %eax,%eax
801054a8:	0f 84 2d 01 00 00    	je     801055db <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801054ae:	83 ec 04             	sub    $0x4,%esp
801054b1:	8d 45 c8             	lea    -0x38(%ebp),%eax
801054b4:	50                   	push   %eax
801054b5:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801054b8:	50                   	push   %eax
801054b9:	ff 75 f4             	push   -0xc(%ebp)
801054bc:	e8 70 cd ff ff       	call   80102231 <dirlookup>
801054c1:	83 c4 10             	add    $0x10,%esp
801054c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801054c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054cb:	0f 84 0d 01 00 00    	je     801055de <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
801054d1:	83 ec 0c             	sub    $0xc,%esp
801054d4:	ff 75 f0             	push   -0x10(%ebp)
801054d7:	e8 73 c5 ff ff       	call   80101a4f <ilock>
801054dc:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801054df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054e2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801054e6:	66 85 c0             	test   %ax,%ax
801054e9:	7f 0d                	jg     801054f8 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801054eb:	83 ec 0c             	sub    $0xc,%esp
801054ee:	68 6d a8 10 80       	push   $0x8010a86d
801054f3:	e8 c9 b0 ff ff       	call   801005c1 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801054f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054fb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801054ff:	66 83 f8 01          	cmp    $0x1,%ax
80105503:	75 25                	jne    8010552a <sys_unlink+0x117>
80105505:	83 ec 0c             	sub    $0xc,%esp
80105508:	ff 75 f0             	push   -0x10(%ebp)
8010550b:	e8 a0 fe ff ff       	call   801053b0 <isdirempty>
80105510:	83 c4 10             	add    $0x10,%esp
80105513:	85 c0                	test   %eax,%eax
80105515:	75 13                	jne    8010552a <sys_unlink+0x117>
    iunlockput(ip);
80105517:	83 ec 0c             	sub    $0xc,%esp
8010551a:	ff 75 f0             	push   -0x10(%ebp)
8010551d:	e8 5e c7 ff ff       	call   80101c80 <iunlockput>
80105522:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105525:	e9 b5 00 00 00       	jmp    801055df <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
8010552a:	83 ec 04             	sub    $0x4,%esp
8010552d:	6a 10                	push   $0x10
8010552f:	6a 00                	push   $0x0
80105531:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105534:	50                   	push   %eax
80105535:	e8 fd f5 ff ff       	call   80104b37 <memset>
8010553a:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010553d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105540:	6a 10                	push   $0x10
80105542:	50                   	push   %eax
80105543:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105546:	50                   	push   %eax
80105547:	ff 75 f4             	push   -0xc(%ebp)
8010554a:	e8 41 cb ff ff       	call   80102090 <writei>
8010554f:	83 c4 10             	add    $0x10,%esp
80105552:	83 f8 10             	cmp    $0x10,%eax
80105555:	74 0d                	je     80105564 <sys_unlink+0x151>
    panic("unlink: writei");
80105557:	83 ec 0c             	sub    $0xc,%esp
8010555a:	68 7f a8 10 80       	push   $0x8010a87f
8010555f:	e8 5d b0 ff ff       	call   801005c1 <panic>
  if(ip->type == T_DIR){
80105564:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105567:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010556b:	66 83 f8 01          	cmp    $0x1,%ax
8010556f:	75 21                	jne    80105592 <sys_unlink+0x17f>
    dp->nlink--;
80105571:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105574:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105578:	83 e8 01             	sub    $0x1,%eax
8010557b:	89 c2                	mov    %eax,%edx
8010557d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105580:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105584:	83 ec 0c             	sub    $0xc,%esp
80105587:	ff 75 f4             	push   -0xc(%ebp)
8010558a:	e8 e3 c2 ff ff       	call   80101872 <iupdate>
8010558f:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105592:	83 ec 0c             	sub    $0xc,%esp
80105595:	ff 75 f4             	push   -0xc(%ebp)
80105598:	e8 e3 c6 ff ff       	call   80101c80 <iunlockput>
8010559d:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801055a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055a3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055a7:	83 e8 01             	sub    $0x1,%eax
801055aa:	89 c2                	mov    %eax,%edx
801055ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055af:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801055b3:	83 ec 0c             	sub    $0xc,%esp
801055b6:	ff 75 f0             	push   -0x10(%ebp)
801055b9:	e8 b4 c2 ff ff       	call   80101872 <iupdate>
801055be:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801055c1:	83 ec 0c             	sub    $0xc,%esp
801055c4:	ff 75 f0             	push   -0x10(%ebp)
801055c7:	e8 b4 c6 ff ff       	call   80101c80 <iunlockput>
801055cc:	83 c4 10             	add    $0x10,%esp

  end_op();
801055cf:	e8 53 db ff ff       	call   80103127 <end_op>

  return 0;
801055d4:	b8 00 00 00 00       	mov    $0x0,%eax
801055d9:	eb 1c                	jmp    801055f7 <sys_unlink+0x1e4>
    goto bad;
801055db:	90                   	nop
801055dc:	eb 01                	jmp    801055df <sys_unlink+0x1cc>
    goto bad;
801055de:	90                   	nop

bad:
  iunlockput(dp);
801055df:	83 ec 0c             	sub    $0xc,%esp
801055e2:	ff 75 f4             	push   -0xc(%ebp)
801055e5:	e8 96 c6 ff ff       	call   80101c80 <iunlockput>
801055ea:	83 c4 10             	add    $0x10,%esp
  end_op();
801055ed:	e8 35 db ff ff       	call   80103127 <end_op>
  return -1;
801055f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055f7:	c9                   	leave
801055f8:	c3                   	ret

801055f9 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801055f9:	55                   	push   %ebp
801055fa:	89 e5                	mov    %esp,%ebp
801055fc:	83 ec 38             	sub    $0x38,%esp
801055ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105602:	8b 55 10             	mov    0x10(%ebp),%edx
80105605:	8b 45 14             	mov    0x14(%ebp),%eax
80105608:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010560c:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105610:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105614:	83 ec 08             	sub    $0x8,%esp
80105617:	8d 45 de             	lea    -0x22(%ebp),%eax
8010561a:	50                   	push   %eax
8010561b:	ff 75 08             	push   0x8(%ebp)
8010561e:	e8 7b cf ff ff       	call   8010259e <nameiparent>
80105623:	83 c4 10             	add    $0x10,%esp
80105626:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105629:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010562d:	75 0a                	jne    80105639 <create+0x40>
    return 0;
8010562f:	b8 00 00 00 00       	mov    $0x0,%eax
80105634:	e9 90 01 00 00       	jmp    801057c9 <create+0x1d0>
  ilock(dp);
80105639:	83 ec 0c             	sub    $0xc,%esp
8010563c:	ff 75 f4             	push   -0xc(%ebp)
8010563f:	e8 0b c4 ff ff       	call   80101a4f <ilock>
80105644:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105647:	83 ec 04             	sub    $0x4,%esp
8010564a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010564d:	50                   	push   %eax
8010564e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105651:	50                   	push   %eax
80105652:	ff 75 f4             	push   -0xc(%ebp)
80105655:	e8 d7 cb ff ff       	call   80102231 <dirlookup>
8010565a:	83 c4 10             	add    $0x10,%esp
8010565d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105660:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105664:	74 50                	je     801056b6 <create+0xbd>
    iunlockput(dp);
80105666:	83 ec 0c             	sub    $0xc,%esp
80105669:	ff 75 f4             	push   -0xc(%ebp)
8010566c:	e8 0f c6 ff ff       	call   80101c80 <iunlockput>
80105671:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105674:	83 ec 0c             	sub    $0xc,%esp
80105677:	ff 75 f0             	push   -0x10(%ebp)
8010567a:	e8 d0 c3 ff ff       	call   80101a4f <ilock>
8010567f:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105682:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105687:	75 15                	jne    8010569e <create+0xa5>
80105689:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010568c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105690:	66 83 f8 02          	cmp    $0x2,%ax
80105694:	75 08                	jne    8010569e <create+0xa5>
      return ip;
80105696:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105699:	e9 2b 01 00 00       	jmp    801057c9 <create+0x1d0>
    iunlockput(ip);
8010569e:	83 ec 0c             	sub    $0xc,%esp
801056a1:	ff 75 f0             	push   -0x10(%ebp)
801056a4:	e8 d7 c5 ff ff       	call   80101c80 <iunlockput>
801056a9:	83 c4 10             	add    $0x10,%esp
    return 0;
801056ac:	b8 00 00 00 00       	mov    $0x0,%eax
801056b1:	e9 13 01 00 00       	jmp    801057c9 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801056b6:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801056ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056bd:	8b 00                	mov    (%eax),%eax
801056bf:	83 ec 08             	sub    $0x8,%esp
801056c2:	52                   	push   %edx
801056c3:	50                   	push   %eax
801056c4:	e8 d3 c0 ff ff       	call   8010179c <ialloc>
801056c9:	83 c4 10             	add    $0x10,%esp
801056cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801056cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801056d3:	75 0d                	jne    801056e2 <create+0xe9>
    panic("create: ialloc");
801056d5:	83 ec 0c             	sub    $0xc,%esp
801056d8:	68 8e a8 10 80       	push   $0x8010a88e
801056dd:	e8 df ae ff ff       	call   801005c1 <panic>

  ilock(ip);
801056e2:	83 ec 0c             	sub    $0xc,%esp
801056e5:	ff 75 f0             	push   -0x10(%ebp)
801056e8:	e8 62 c3 ff ff       	call   80101a4f <ilock>
801056ed:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801056f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056f3:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801056f7:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801056fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056fe:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105702:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105706:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105709:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
8010570f:	83 ec 0c             	sub    $0xc,%esp
80105712:	ff 75 f0             	push   -0x10(%ebp)
80105715:	e8 58 c1 ff ff       	call   80101872 <iupdate>
8010571a:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
8010571d:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105722:	75 6a                	jne    8010578e <create+0x195>
    dp->nlink++;  // for ".."
80105724:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105727:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010572b:	83 c0 01             	add    $0x1,%eax
8010572e:	89 c2                	mov    %eax,%edx
80105730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105733:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105737:	83 ec 0c             	sub    $0xc,%esp
8010573a:	ff 75 f4             	push   -0xc(%ebp)
8010573d:	e8 30 c1 ff ff       	call   80101872 <iupdate>
80105742:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105745:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105748:	8b 40 04             	mov    0x4(%eax),%eax
8010574b:	83 ec 04             	sub    $0x4,%esp
8010574e:	50                   	push   %eax
8010574f:	68 68 a8 10 80       	push   $0x8010a868
80105754:	ff 75 f0             	push   -0x10(%ebp)
80105757:	e8 8f cb ff ff       	call   801022eb <dirlink>
8010575c:	83 c4 10             	add    $0x10,%esp
8010575f:	85 c0                	test   %eax,%eax
80105761:	78 1e                	js     80105781 <create+0x188>
80105763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105766:	8b 40 04             	mov    0x4(%eax),%eax
80105769:	83 ec 04             	sub    $0x4,%esp
8010576c:	50                   	push   %eax
8010576d:	68 6a a8 10 80       	push   $0x8010a86a
80105772:	ff 75 f0             	push   -0x10(%ebp)
80105775:	e8 71 cb ff ff       	call   801022eb <dirlink>
8010577a:	83 c4 10             	add    $0x10,%esp
8010577d:	85 c0                	test   %eax,%eax
8010577f:	79 0d                	jns    8010578e <create+0x195>
      panic("create dots");
80105781:	83 ec 0c             	sub    $0xc,%esp
80105784:	68 9d a8 10 80       	push   $0x8010a89d
80105789:	e8 33 ae ff ff       	call   801005c1 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010578e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105791:	8b 40 04             	mov    0x4(%eax),%eax
80105794:	83 ec 04             	sub    $0x4,%esp
80105797:	50                   	push   %eax
80105798:	8d 45 de             	lea    -0x22(%ebp),%eax
8010579b:	50                   	push   %eax
8010579c:	ff 75 f4             	push   -0xc(%ebp)
8010579f:	e8 47 cb ff ff       	call   801022eb <dirlink>
801057a4:	83 c4 10             	add    $0x10,%esp
801057a7:	85 c0                	test   %eax,%eax
801057a9:	79 0d                	jns    801057b8 <create+0x1bf>
    panic("create: dirlink");
801057ab:	83 ec 0c             	sub    $0xc,%esp
801057ae:	68 a9 a8 10 80       	push   $0x8010a8a9
801057b3:	e8 09 ae ff ff       	call   801005c1 <panic>

  iunlockput(dp);
801057b8:	83 ec 0c             	sub    $0xc,%esp
801057bb:	ff 75 f4             	push   -0xc(%ebp)
801057be:	e8 bd c4 ff ff       	call   80101c80 <iunlockput>
801057c3:	83 c4 10             	add    $0x10,%esp

  return ip;
801057c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801057c9:	c9                   	leave
801057ca:	c3                   	ret

801057cb <sys_open>:

int
sys_open(void)
{
801057cb:	55                   	push   %ebp
801057cc:	89 e5                	mov    %esp,%ebp
801057ce:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801057d1:	83 ec 08             	sub    $0x8,%esp
801057d4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801057d7:	50                   	push   %eax
801057d8:	6a 00                	push   $0x0
801057da:	e8 ea f6 ff ff       	call   80104ec9 <argstr>
801057df:	83 c4 10             	add    $0x10,%esp
801057e2:	85 c0                	test   %eax,%eax
801057e4:	78 15                	js     801057fb <sys_open+0x30>
801057e6:	83 ec 08             	sub    $0x8,%esp
801057e9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801057ec:	50                   	push   %eax
801057ed:	6a 01                	push   $0x1
801057ef:	e8 4f f6 ff ff       	call   80104e43 <argint>
801057f4:	83 c4 10             	add    $0x10,%esp
801057f7:	85 c0                	test   %eax,%eax
801057f9:	79 0a                	jns    80105805 <sys_open+0x3a>
    return -1;
801057fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105800:	e9 61 01 00 00       	jmp    80105966 <sys_open+0x19b>

  begin_op();
80105805:	e8 91 d8 ff ff       	call   8010309b <begin_op>

  if(omode & O_CREATE){
8010580a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010580d:	25 00 02 00 00       	and    $0x200,%eax
80105812:	85 c0                	test   %eax,%eax
80105814:	74 2a                	je     80105840 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105816:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105819:	6a 00                	push   $0x0
8010581b:	6a 00                	push   $0x0
8010581d:	6a 02                	push   $0x2
8010581f:	50                   	push   %eax
80105820:	e8 d4 fd ff ff       	call   801055f9 <create>
80105825:	83 c4 10             	add    $0x10,%esp
80105828:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010582b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010582f:	75 75                	jne    801058a6 <sys_open+0xdb>
      end_op();
80105831:	e8 f1 d8 ff ff       	call   80103127 <end_op>
      return -1;
80105836:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010583b:	e9 26 01 00 00       	jmp    80105966 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105840:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105843:	83 ec 0c             	sub    $0xc,%esp
80105846:	50                   	push   %eax
80105847:	e8 36 cd ff ff       	call   80102582 <namei>
8010584c:	83 c4 10             	add    $0x10,%esp
8010584f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105852:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105856:	75 0f                	jne    80105867 <sys_open+0x9c>
      end_op();
80105858:	e8 ca d8 ff ff       	call   80103127 <end_op>
      return -1;
8010585d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105862:	e9 ff 00 00 00       	jmp    80105966 <sys_open+0x19b>
    }
    ilock(ip);
80105867:	83 ec 0c             	sub    $0xc,%esp
8010586a:	ff 75 f4             	push   -0xc(%ebp)
8010586d:	e8 dd c1 ff ff       	call   80101a4f <ilock>
80105872:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105878:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010587c:	66 83 f8 01          	cmp    $0x1,%ax
80105880:	75 24                	jne    801058a6 <sys_open+0xdb>
80105882:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105885:	85 c0                	test   %eax,%eax
80105887:	74 1d                	je     801058a6 <sys_open+0xdb>
      iunlockput(ip);
80105889:	83 ec 0c             	sub    $0xc,%esp
8010588c:	ff 75 f4             	push   -0xc(%ebp)
8010588f:	e8 ec c3 ff ff       	call   80101c80 <iunlockput>
80105894:	83 c4 10             	add    $0x10,%esp
      end_op();
80105897:	e8 8b d8 ff ff       	call   80103127 <end_op>
      return -1;
8010589c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058a1:	e9 c0 00 00 00       	jmp    80105966 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801058a6:	e8 99 b7 ff ff       	call   80101044 <filealloc>
801058ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
801058ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058b2:	74 17                	je     801058cb <sys_open+0x100>
801058b4:	83 ec 0c             	sub    $0xc,%esp
801058b7:	ff 75 f0             	push   -0x10(%ebp)
801058ba:	e8 33 f7 ff ff       	call   80104ff2 <fdalloc>
801058bf:	83 c4 10             	add    $0x10,%esp
801058c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801058c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801058c9:	79 2e                	jns    801058f9 <sys_open+0x12e>
    if(f)
801058cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058cf:	74 0e                	je     801058df <sys_open+0x114>
      fileclose(f);
801058d1:	83 ec 0c             	sub    $0xc,%esp
801058d4:	ff 75 f0             	push   -0x10(%ebp)
801058d7:	e8 26 b8 ff ff       	call   80101102 <fileclose>
801058dc:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801058df:	83 ec 0c             	sub    $0xc,%esp
801058e2:	ff 75 f4             	push   -0xc(%ebp)
801058e5:	e8 96 c3 ff ff       	call   80101c80 <iunlockput>
801058ea:	83 c4 10             	add    $0x10,%esp
    end_op();
801058ed:	e8 35 d8 ff ff       	call   80103127 <end_op>
    return -1;
801058f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f7:	eb 6d                	jmp    80105966 <sys_open+0x19b>
  }
  iunlock(ip);
801058f9:	83 ec 0c             	sub    $0xc,%esp
801058fc:	ff 75 f4             	push   -0xc(%ebp)
801058ff:	e8 5e c2 ff ff       	call   80101b62 <iunlock>
80105904:	83 c4 10             	add    $0x10,%esp
  end_op();
80105907:	e8 1b d8 ff ff       	call   80103127 <end_op>

  f->type = FD_INODE;
8010590c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010590f:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105915:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105918:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010591b:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010591e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105921:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105928:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010592b:	83 e0 01             	and    $0x1,%eax
8010592e:	85 c0                	test   %eax,%eax
80105930:	0f 94 c0             	sete   %al
80105933:	89 c2                	mov    %eax,%edx
80105935:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105938:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010593b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010593e:	83 e0 01             	and    $0x1,%eax
80105941:	85 c0                	test   %eax,%eax
80105943:	75 0a                	jne    8010594f <sys_open+0x184>
80105945:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105948:	83 e0 02             	and    $0x2,%eax
8010594b:	85 c0                	test   %eax,%eax
8010594d:	74 07                	je     80105956 <sys_open+0x18b>
8010594f:	b8 01 00 00 00       	mov    $0x1,%eax
80105954:	eb 05                	jmp    8010595b <sys_open+0x190>
80105956:	b8 00 00 00 00       	mov    $0x0,%eax
8010595b:	89 c2                	mov    %eax,%edx
8010595d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105960:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105963:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105966:	c9                   	leave
80105967:	c3                   	ret

80105968 <sys_mkdir>:

int
sys_mkdir(void)
{
80105968:	55                   	push   %ebp
80105969:	89 e5                	mov    %esp,%ebp
8010596b:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010596e:	e8 28 d7 ff ff       	call   8010309b <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105973:	83 ec 08             	sub    $0x8,%esp
80105976:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105979:	50                   	push   %eax
8010597a:	6a 00                	push   $0x0
8010597c:	e8 48 f5 ff ff       	call   80104ec9 <argstr>
80105981:	83 c4 10             	add    $0x10,%esp
80105984:	85 c0                	test   %eax,%eax
80105986:	78 1b                	js     801059a3 <sys_mkdir+0x3b>
80105988:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010598b:	6a 00                	push   $0x0
8010598d:	6a 00                	push   $0x0
8010598f:	6a 01                	push   $0x1
80105991:	50                   	push   %eax
80105992:	e8 62 fc ff ff       	call   801055f9 <create>
80105997:	83 c4 10             	add    $0x10,%esp
8010599a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010599d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059a1:	75 0c                	jne    801059af <sys_mkdir+0x47>
    end_op();
801059a3:	e8 7f d7 ff ff       	call   80103127 <end_op>
    return -1;
801059a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ad:	eb 18                	jmp    801059c7 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801059af:	83 ec 0c             	sub    $0xc,%esp
801059b2:	ff 75 f4             	push   -0xc(%ebp)
801059b5:	e8 c6 c2 ff ff       	call   80101c80 <iunlockput>
801059ba:	83 c4 10             	add    $0x10,%esp
  end_op();
801059bd:	e8 65 d7 ff ff       	call   80103127 <end_op>
  return 0;
801059c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059c7:	c9                   	leave
801059c8:	c3                   	ret

801059c9 <sys_mknod>:

int
sys_mknod(void)
{
801059c9:	55                   	push   %ebp
801059ca:	89 e5                	mov    %esp,%ebp
801059cc:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801059cf:	e8 c7 d6 ff ff       	call   8010309b <begin_op>
  if((argstr(0, &path)) < 0 ||
801059d4:	83 ec 08             	sub    $0x8,%esp
801059d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059da:	50                   	push   %eax
801059db:	6a 00                	push   $0x0
801059dd:	e8 e7 f4 ff ff       	call   80104ec9 <argstr>
801059e2:	83 c4 10             	add    $0x10,%esp
801059e5:	85 c0                	test   %eax,%eax
801059e7:	78 4f                	js     80105a38 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
801059e9:	83 ec 08             	sub    $0x8,%esp
801059ec:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059ef:	50                   	push   %eax
801059f0:	6a 01                	push   $0x1
801059f2:	e8 4c f4 ff ff       	call   80104e43 <argint>
801059f7:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801059fa:	85 c0                	test   %eax,%eax
801059fc:	78 3a                	js     80105a38 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
801059fe:	83 ec 08             	sub    $0x8,%esp
80105a01:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105a04:	50                   	push   %eax
80105a05:	6a 02                	push   $0x2
80105a07:	e8 37 f4 ff ff       	call   80104e43 <argint>
80105a0c:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105a0f:	85 c0                	test   %eax,%eax
80105a11:	78 25                	js     80105a38 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105a13:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105a16:	0f bf c8             	movswl %ax,%ecx
80105a19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105a1c:	0f bf d0             	movswl %ax,%edx
80105a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a22:	51                   	push   %ecx
80105a23:	52                   	push   %edx
80105a24:	6a 03                	push   $0x3
80105a26:	50                   	push   %eax
80105a27:	e8 cd fb ff ff       	call   801055f9 <create>
80105a2c:	83 c4 10             	add    $0x10,%esp
80105a2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105a32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a36:	75 0c                	jne    80105a44 <sys_mknod+0x7b>
    end_op();
80105a38:	e8 ea d6 ff ff       	call   80103127 <end_op>
    return -1;
80105a3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a42:	eb 18                	jmp    80105a5c <sys_mknod+0x93>
  }
  iunlockput(ip);
80105a44:	83 ec 0c             	sub    $0xc,%esp
80105a47:	ff 75 f4             	push   -0xc(%ebp)
80105a4a:	e8 31 c2 ff ff       	call   80101c80 <iunlockput>
80105a4f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a52:	e8 d0 d6 ff ff       	call   80103127 <end_op>
  return 0;
80105a57:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a5c:	c9                   	leave
80105a5d:	c3                   	ret

80105a5e <sys_chdir>:

int
sys_chdir(void)
{
80105a5e:	55                   	push   %ebp
80105a5f:	89 e5                	mov    %esp,%ebp
80105a61:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105a64:	e8 24 e0 ff ff       	call   80103a8d <myproc>
80105a69:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105a6c:	e8 2a d6 ff ff       	call   8010309b <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105a71:	83 ec 08             	sub    $0x8,%esp
80105a74:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a77:	50                   	push   %eax
80105a78:	6a 00                	push   $0x0
80105a7a:	e8 4a f4 ff ff       	call   80104ec9 <argstr>
80105a7f:	83 c4 10             	add    $0x10,%esp
80105a82:	85 c0                	test   %eax,%eax
80105a84:	78 18                	js     80105a9e <sys_chdir+0x40>
80105a86:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105a89:	83 ec 0c             	sub    $0xc,%esp
80105a8c:	50                   	push   %eax
80105a8d:	e8 f0 ca ff ff       	call   80102582 <namei>
80105a92:	83 c4 10             	add    $0x10,%esp
80105a95:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a98:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a9c:	75 0c                	jne    80105aaa <sys_chdir+0x4c>
    end_op();
80105a9e:	e8 84 d6 ff ff       	call   80103127 <end_op>
    return -1;
80105aa3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa8:	eb 68                	jmp    80105b12 <sys_chdir+0xb4>
  }
  ilock(ip);
80105aaa:	83 ec 0c             	sub    $0xc,%esp
80105aad:	ff 75 f0             	push   -0x10(%ebp)
80105ab0:	e8 9a bf ff ff       	call   80101a4f <ilock>
80105ab5:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105abb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105abf:	66 83 f8 01          	cmp    $0x1,%ax
80105ac3:	74 1a                	je     80105adf <sys_chdir+0x81>
    iunlockput(ip);
80105ac5:	83 ec 0c             	sub    $0xc,%esp
80105ac8:	ff 75 f0             	push   -0x10(%ebp)
80105acb:	e8 b0 c1 ff ff       	call   80101c80 <iunlockput>
80105ad0:	83 c4 10             	add    $0x10,%esp
    end_op();
80105ad3:	e8 4f d6 ff ff       	call   80103127 <end_op>
    return -1;
80105ad8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105add:	eb 33                	jmp    80105b12 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105adf:	83 ec 0c             	sub    $0xc,%esp
80105ae2:	ff 75 f0             	push   -0x10(%ebp)
80105ae5:	e8 78 c0 ff ff       	call   80101b62 <iunlock>
80105aea:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105af0:	8b 40 68             	mov    0x68(%eax),%eax
80105af3:	83 ec 0c             	sub    $0xc,%esp
80105af6:	50                   	push   %eax
80105af7:	e8 b4 c0 ff ff       	call   80101bb0 <iput>
80105afc:	83 c4 10             	add    $0x10,%esp
  end_op();
80105aff:	e8 23 d6 ff ff       	call   80103127 <end_op>
  curproc->cwd = ip;
80105b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b07:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b0a:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105b0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b12:	c9                   	leave
80105b13:	c3                   	ret

80105b14 <sys_exec>:

int
sys_exec(void)
{
80105b14:	55                   	push   %ebp
80105b15:	89 e5                	mov    %esp,%ebp
80105b17:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105b1d:	83 ec 08             	sub    $0x8,%esp
80105b20:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b23:	50                   	push   %eax
80105b24:	6a 00                	push   $0x0
80105b26:	e8 9e f3 ff ff       	call   80104ec9 <argstr>
80105b2b:	83 c4 10             	add    $0x10,%esp
80105b2e:	85 c0                	test   %eax,%eax
80105b30:	78 18                	js     80105b4a <sys_exec+0x36>
80105b32:	83 ec 08             	sub    $0x8,%esp
80105b35:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105b3b:	50                   	push   %eax
80105b3c:	6a 01                	push   $0x1
80105b3e:	e8 00 f3 ff ff       	call   80104e43 <argint>
80105b43:	83 c4 10             	add    $0x10,%esp
80105b46:	85 c0                	test   %eax,%eax
80105b48:	79 0a                	jns    80105b54 <sys_exec+0x40>
    return -1;
80105b4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b4f:	e9 c6 00 00 00       	jmp    80105c1a <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105b54:	83 ec 04             	sub    $0x4,%esp
80105b57:	68 80 00 00 00       	push   $0x80
80105b5c:	6a 00                	push   $0x0
80105b5e:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105b64:	50                   	push   %eax
80105b65:	e8 cd ef ff ff       	call   80104b37 <memset>
80105b6a:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105b6d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b77:	83 f8 1f             	cmp    $0x1f,%eax
80105b7a:	76 0a                	jbe    80105b86 <sys_exec+0x72>
      return -1;
80105b7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b81:	e9 94 00 00 00       	jmp    80105c1a <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b89:	c1 e0 02             	shl    $0x2,%eax
80105b8c:	89 c2                	mov    %eax,%edx
80105b8e:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105b94:	01 c2                	add    %eax,%edx
80105b96:	83 ec 08             	sub    $0x8,%esp
80105b99:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105b9f:	50                   	push   %eax
80105ba0:	52                   	push   %edx
80105ba1:	e8 1b f2 ff ff       	call   80104dc1 <fetchint>
80105ba6:	83 c4 10             	add    $0x10,%esp
80105ba9:	85 c0                	test   %eax,%eax
80105bab:	79 07                	jns    80105bb4 <sys_exec+0xa0>
      return -1;
80105bad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb2:	eb 66                	jmp    80105c1a <sys_exec+0x106>
    if(uarg == 0){
80105bb4:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105bba:	85 c0                	test   %eax,%eax
80105bbc:	75 27                	jne    80105be5 <sys_exec+0xd1>
      argv[i] = 0;
80105bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc1:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105bc8:	00 00 00 00 
      break;
80105bcc:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105bcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd0:	83 ec 08             	sub    $0x8,%esp
80105bd3:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105bd9:	52                   	push   %edx
80105bda:	50                   	push   %eax
80105bdb:	e8 c2 af ff ff       	call   80100ba2 <exec>
80105be0:	83 c4 10             	add    $0x10,%esp
80105be3:	eb 35                	jmp    80105c1a <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105be5:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105beb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bee:	c1 e2 02             	shl    $0x2,%edx
80105bf1:	01 c2                	add    %eax,%edx
80105bf3:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105bf9:	83 ec 08             	sub    $0x8,%esp
80105bfc:	52                   	push   %edx
80105bfd:	50                   	push   %eax
80105bfe:	e8 ea f1 ff ff       	call   80104ded <fetchstr>
80105c03:	83 c4 10             	add    $0x10,%esp
80105c06:	85 c0                	test   %eax,%eax
80105c08:	79 07                	jns    80105c11 <sys_exec+0xfd>
      return -1;
80105c0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c0f:	eb 09                	jmp    80105c1a <sys_exec+0x106>
  for(i=0;; i++){
80105c11:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105c15:	e9 5a ff ff ff       	jmp    80105b74 <sys_exec+0x60>
}
80105c1a:	c9                   	leave
80105c1b:	c3                   	ret

80105c1c <sys_pipe>:

int
sys_pipe(void)
{
80105c1c:	55                   	push   %ebp
80105c1d:	89 e5                	mov    %esp,%ebp
80105c1f:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105c22:	83 ec 04             	sub    $0x4,%esp
80105c25:	6a 08                	push   $0x8
80105c27:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c2a:	50                   	push   %eax
80105c2b:	6a 00                	push   $0x0
80105c2d:	e8 3e f2 ff ff       	call   80104e70 <argptr>
80105c32:	83 c4 10             	add    $0x10,%esp
80105c35:	85 c0                	test   %eax,%eax
80105c37:	79 0a                	jns    80105c43 <sys_pipe+0x27>
    return -1;
80105c39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c3e:	e9 ae 00 00 00       	jmp    80105cf1 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105c43:	83 ec 08             	sub    $0x8,%esp
80105c46:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c49:	50                   	push   %eax
80105c4a:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c4d:	50                   	push   %eax
80105c4e:	e8 77 d9 ff ff       	call   801035ca <pipealloc>
80105c53:	83 c4 10             	add    $0x10,%esp
80105c56:	85 c0                	test   %eax,%eax
80105c58:	79 0a                	jns    80105c64 <sys_pipe+0x48>
    return -1;
80105c5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c5f:	e9 8d 00 00 00       	jmp    80105cf1 <sys_pipe+0xd5>
  fd0 = -1;
80105c64:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105c6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c6e:	83 ec 0c             	sub    $0xc,%esp
80105c71:	50                   	push   %eax
80105c72:	e8 7b f3 ff ff       	call   80104ff2 <fdalloc>
80105c77:	83 c4 10             	add    $0x10,%esp
80105c7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c81:	78 18                	js     80105c9b <sys_pipe+0x7f>
80105c83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c86:	83 ec 0c             	sub    $0xc,%esp
80105c89:	50                   	push   %eax
80105c8a:	e8 63 f3 ff ff       	call   80104ff2 <fdalloc>
80105c8f:	83 c4 10             	add    $0x10,%esp
80105c92:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c95:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c99:	79 3e                	jns    80105cd9 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105c9b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c9f:	78 13                	js     80105cb4 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105ca1:	e8 e7 dd ff ff       	call   80103a8d <myproc>
80105ca6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ca9:	83 c2 08             	add    $0x8,%edx
80105cac:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105cb3:	00 
    fileclose(rf);
80105cb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105cb7:	83 ec 0c             	sub    $0xc,%esp
80105cba:	50                   	push   %eax
80105cbb:	e8 42 b4 ff ff       	call   80101102 <fileclose>
80105cc0:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105cc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cc6:	83 ec 0c             	sub    $0xc,%esp
80105cc9:	50                   	push   %eax
80105cca:	e8 33 b4 ff ff       	call   80101102 <fileclose>
80105ccf:	83 c4 10             	add    $0x10,%esp
    return -1;
80105cd2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cd7:	eb 18                	jmp    80105cf1 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105cd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105cdc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cdf:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105ce1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ce4:	8d 50 04             	lea    0x4(%eax),%edx
80105ce7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cea:	89 02                	mov    %eax,(%edx)
  return 0;
80105cec:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cf1:	c9                   	leave
80105cf2:	c3                   	ret

80105cf3 <sys_printpt>:
#include "mmu.h"
#include "proc.h"

int
sys_printpt(void)
{
80105cf3:	55                   	push   %ebp
80105cf4:	89 e5                	mov    %esp,%ebp
80105cf6:	83 ec 18             	sub    $0x18,%esp
  int pid;
  if (argint(0, &pid) < 0)
80105cf9:	83 ec 08             	sub    $0x8,%esp
80105cfc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cff:	50                   	push   %eax
80105d00:	6a 00                	push   $0x0
80105d02:	e8 3c f1 ff ff       	call   80104e43 <argint>
80105d07:	83 c4 10             	add    $0x10,%esp
80105d0a:	85 c0                	test   %eax,%eax
80105d0c:	79 07                	jns    80105d15 <sys_printpt+0x22>
        return -1;
80105d0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d13:	eb 0f                	jmp    80105d24 <sys_printpt+0x31>
  return printpt(pid);
80105d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d18:	83 ec 0c             	sub    $0xc,%esp
80105d1b:	50                   	push   %eax
80105d1c:	e8 ef e8 ff ff       	call   80104610 <printpt>
80105d21:	83 c4 10             	add    $0x10,%esp
}
80105d24:	c9                   	leave
80105d25:	c3                   	ret

80105d26 <sys_fork>:

int
sys_fork(void)
{
80105d26:	55                   	push   %ebp
80105d27:	89 e5                	mov    %esp,%ebp
80105d29:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105d2c:	e8 6b e0 ff ff       	call   80103d9c <fork>
}
80105d31:	c9                   	leave
80105d32:	c3                   	ret

80105d33 <sys_exit>:

int
sys_exit(void)
{
80105d33:	55                   	push   %ebp
80105d34:	89 e5                	mov    %esp,%ebp
80105d36:	83 ec 08             	sub    $0x8,%esp
  exit();
80105d39:	e8 d7 e1 ff ff       	call   80103f15 <exit>
  return 0;  // not reached
80105d3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d43:	c9                   	leave
80105d44:	c3                   	ret

80105d45 <sys_wait>:

int
sys_wait(void)
{
80105d45:	55                   	push   %ebp
80105d46:	89 e5                	mov    %esp,%ebp
80105d48:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105d4b:	e8 e5 e2 ff ff       	call   80104035 <wait>
}
80105d50:	c9                   	leave
80105d51:	c3                   	ret

80105d52 <sys_uthread_init>:
int
sys_uthread_init(void)
{
80105d52:	55                   	push   %ebp
80105d53:	89 e5                	mov    %esp,%ebp
80105d55:	83 ec 18             	sub    $0x18,%esp
    // 시스템콜의 인자값을 받아온다.
    int address;
    if (argint(0, &address) < 0)
80105d58:	83 ec 08             	sub    $0x8,%esp
80105d5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d5e:	50                   	push   %eax
80105d5f:	6a 00                	push   $0x0
80105d61:	e8 dd f0 ff ff       	call   80104e43 <argint>
80105d66:	83 c4 10             	add    $0x10,%esp
80105d69:	85 c0                	test   %eax,%eax
80105d6b:	79 07                	jns    80105d74 <sys_uthread_init+0x22>
        return -1;
80105d6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d72:	eb 0f                	jmp    80105d83 <sys_uthread_init+0x31>
    // proc.c의 uthread_init() 함수 호출
    return uthread_init(address);
80105d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d77:	83 ec 0c             	sub    $0xc,%esp
80105d7a:	50                   	push   %eax
80105d7b:	e8 8d e4 ff ff       	call   8010420d <uthread_init>
80105d80:	83 c4 10             	add    $0x10,%esp
}
80105d83:	c9                   	leave
80105d84:	c3                   	ret

80105d85 <sys_kill>:

int
sys_kill(void)
{
80105d85:	55                   	push   %ebp
80105d86:	89 e5                	mov    %esp,%ebp
80105d88:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105d8b:	83 ec 08             	sub    $0x8,%esp
80105d8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d91:	50                   	push   %eax
80105d92:	6a 00                	push   $0x0
80105d94:	e8 aa f0 ff ff       	call   80104e43 <argint>
80105d99:	83 c4 10             	add    $0x10,%esp
80105d9c:	85 c0                	test   %eax,%eax
80105d9e:	79 07                	jns    80105da7 <sys_kill+0x22>
    return -1;
80105da0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105da5:	eb 0f                	jmp    80105db6 <sys_kill+0x31>
  return kill(pid);
80105da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105daa:	83 ec 0c             	sub    $0xc,%esp
80105dad:	50                   	push   %eax
80105dae:	e8 cf e6 ff ff       	call   80104482 <kill>
80105db3:	83 c4 10             	add    $0x10,%esp
}
80105db6:	c9                   	leave
80105db7:	c3                   	ret

80105db8 <sys_getpid>:

int
sys_getpid(void)
{
80105db8:	55                   	push   %ebp
80105db9:	89 e5                	mov    %esp,%ebp
80105dbb:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105dbe:	e8 ca dc ff ff       	call   80103a8d <myproc>
80105dc3:	8b 40 10             	mov    0x10(%eax),%eax
}
80105dc6:	c9                   	leave
80105dc7:	c3                   	ret

80105dc8 <sys_sbrk>:

int
sys_sbrk(void)
{
80105dc8:	55                   	push   %ebp
80105dc9:	89 e5                	mov    %esp,%ebp
80105dcb:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;
  struct proc* p = myproc();
80105dce:	e8 ba dc ff ff       	call   80103a8d <myproc>
80105dd3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(argint(0, &n) < 0)
80105dd6:	83 ec 08             	sub    $0x8,%esp
80105dd9:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ddc:	50                   	push   %eax
80105ddd:	6a 00                	push   $0x0
80105ddf:	e8 5f f0 ff ff       	call   80104e43 <argint>
80105de4:	83 c4 10             	add    $0x10,%esp
80105de7:	85 c0                	test   %eax,%eax
80105de9:	79 0a                	jns    80105df5 <sys_sbrk+0x2d>
    return -1;
80105deb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105df0:	e9 4f 01 00 00       	jmp    80105f44 <sys_sbrk+0x17c>
  // addr = 메모리를 늘리기 전 주소
  addr = p->sz;
80105df5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df8:	8b 00                	mov    (%eax),%eax
80105dfa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (n > 0)
80105dfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105e00:	85 c0                	test   %eax,%eax
80105e02:	0f 8e b5 00 00 00    	jle    80105ebd <sys_sbrk+0xf5>
  { 
    if (PGROUNDUP(p->sz + n) >= p->tf->esp){
80105e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e0b:	8b 00                	mov    (%eax),%eax
80105e0d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80105e10:	01 d0                	add    %edx,%eax
80105e12:	05 ff 0f 00 00       	add    $0xfff,%eax
80105e17:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80105e1c:	89 c2                	mov    %eax,%edx
80105e1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e21:	8b 40 18             	mov    0x18(%eax),%eax
80105e24:	8b 40 44             	mov    0x44(%eax),%eax
80105e27:	39 c2                	cmp    %eax,%edx
80105e29:	72 1c                	jb     80105e47 <sys_sbrk+0x7f>
      kill(p->pid);
80105e2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e2e:	8b 40 10             	mov    0x10(%eax),%eax
80105e31:	83 ec 0c             	sub    $0xc,%esp
80105e34:	50                   	push   %eax
80105e35:	e8 48 e6 ff ff       	call   80104482 <kill>
80105e3a:	83 c4 10             	add    $0x10,%esp
      return -1;
80105e3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e42:	e9 fd 00 00 00       	jmp    80105f44 <sys_sbrk+0x17c>
    }
    else{
      uint oldsz = PGROUNDUP(p->sz);
80105e47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e4a:	8b 00                	mov    (%eax),%eax
80105e4c:	05 ff 0f 00 00       	add    $0xfff,%eax
80105e51:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80105e56:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint newsz = p->sz + n;
80105e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e5c:	8b 00                	mov    (%eax),%eax
80105e5e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80105e61:	01 d0                	add    %edx,%eax
80105e63:	89 45 e8             	mov    %eax,-0x18(%ebp)
      p->sz = newsz;
80105e66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e69:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105e6c:	89 10                	mov    %edx,(%eax)
      for(; oldsz < newsz; oldsz += PGSIZE){
80105e6e:	eb 32                	jmp    80105ea2 <sys_sbrk+0xda>
      pte_t *pte = walkpgdir(p->pgdir, (void*)oldsz, 1);
80105e70:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e76:	8b 40 04             	mov    0x4(%eax),%eax
80105e79:	83 ec 04             	sub    $0x4,%esp
80105e7c:	6a 01                	push   $0x1
80105e7e:	52                   	push   %edx
80105e7f:	50                   	push   %eax
80105e80:	e8 cd 16 00 00       	call   80107552 <walkpgdir>
80105e85:	83 c4 10             	add    $0x10,%esp
80105e88:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if (pte == 0)
80105e8b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80105e8f:	75 0a                	jne    80105e9b <sys_sbrk+0xd3>
        return -1;
80105e91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e96:	e9 a9 00 00 00       	jmp    80105f44 <sys_sbrk+0x17c>
      for(; oldsz < newsz; oldsz += PGSIZE){
80105e9b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80105ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea5:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80105ea8:	72 c6                	jb     80105e70 <sys_sbrk+0xa8>
      // cprintf("pgtab %x\n",*pte);
      }
      switchuvm(p);
80105eaa:	83 ec 0c             	sub    $0xc,%esp
80105ead:	ff 75 f0             	push   -0x10(%ebp)
80105eb0:	e8 e1 18 00 00       	call   80107796 <switchuvm>
80105eb5:	83 c4 10             	add    $0x10,%esp
80105eb8:	e9 84 00 00 00       	jmp    80105f41 <sys_sbrk+0x179>
    }
  }
  // 메모리 할당을 해제할 때는 바로 해제
  else if (n<0)
80105ebd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105ec0:	85 c0                	test   %eax,%eax
80105ec2:	79 7d                	jns    80105f41 <sys_sbrk+0x179>
  {
    cprintf("[sbrk] sz %x \n",p->sz);
80105ec4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec7:	8b 00                	mov    (%eax),%eax
80105ec9:	83 ec 08             	sub    $0x8,%esp
80105ecc:	50                   	push   %eax
80105ecd:	68 b9 a8 10 80       	push   $0x8010a8b9
80105ed2:	e8 1d a5 ff ff       	call   801003f4 <cprintf>
80105ed7:	83 c4 10             	add    $0x10,%esp
    if(growproc(n) < 0)
80105eda:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105edd:	83 ec 0c             	sub    $0xc,%esp
80105ee0:	50                   	push   %eax
80105ee1:	e8 1b de ff ff       	call   80103d01 <growproc>
80105ee6:	83 c4 10             	add    $0x10,%esp
80105ee9:	85 c0                	test   %eax,%eax
80105eeb:	79 07                	jns    80105ef4 <sys_sbrk+0x12c>
      return -1;
80105eed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef2:	eb 50                	jmp    80105f44 <sys_sbrk+0x17c>
    cprintf("[sbrk] sz %x \n",p->sz);
80105ef4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef7:	8b 00                	mov    (%eax),%eax
80105ef9:	83 ec 08             	sub    $0x8,%esp
80105efc:	50                   	push   %eax
80105efd:	68 b9 a8 10 80       	push   $0x8010a8b9
80105f02:	e8 ed a4 ff ff       	call   801003f4 <cprintf>
80105f07:	83 c4 10             	add    $0x10,%esp
    cprintf("[sbrk] addr %x \n", addr);
80105f0a:	83 ec 08             	sub    $0x8,%esp
80105f0d:	ff 75 ec             	push   -0x14(%ebp)
80105f10:	68 c8 a8 10 80       	push   $0x8010a8c8
80105f15:	e8 da a4 ff ff       	call   801003f4 <cprintf>
80105f1a:	83 c4 10             	add    $0x10,%esp
    cprintf("[sbrk] esp %x eip %x \n",p->tf->esp, p->tf->eip);
80105f1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f20:	8b 40 18             	mov    0x18(%eax),%eax
80105f23:	8b 50 38             	mov    0x38(%eax),%edx
80105f26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f29:	8b 40 18             	mov    0x18(%eax),%eax
80105f2c:	8b 40 44             	mov    0x44(%eax),%eax
80105f2f:	83 ec 04             	sub    $0x4,%esp
80105f32:	52                   	push   %edx
80105f33:	50                   	push   %eax
80105f34:	68 d9 a8 10 80       	push   $0x8010a8d9
80105f39:	e8 b6 a4 ff ff       	call   801003f4 <cprintf>
80105f3e:	83 c4 10             	add    $0x10,%esp
  }
  return addr;
80105f41:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105f44:	c9                   	leave
80105f45:	c3                   	ret

80105f46 <sys_sleep>:

int
sys_sleep(void)
{
80105f46:	55                   	push   %ebp
80105f47:	89 e5                	mov    %esp,%ebp
80105f49:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105f4c:	83 ec 08             	sub    $0x8,%esp
80105f4f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f52:	50                   	push   %eax
80105f53:	6a 00                	push   $0x0
80105f55:	e8 e9 ee ff ff       	call   80104e43 <argint>
80105f5a:	83 c4 10             	add    $0x10,%esp
80105f5d:	85 c0                	test   %eax,%eax
80105f5f:	79 07                	jns    80105f68 <sys_sleep+0x22>
    return -1;
80105f61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f66:	eb 76                	jmp    80105fde <sys_sleep+0x98>
  acquire(&tickslock);
80105f68:	83 ec 0c             	sub    $0xc,%esp
80105f6b:	68 40 6a 19 80       	push   $0x80196a40
80105f70:	e8 4c e9 ff ff       	call   801048c1 <acquire>
80105f75:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105f78:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105f7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105f80:	eb 38                	jmp    80105fba <sys_sleep+0x74>
    if(myproc()->killed){
80105f82:	e8 06 db ff ff       	call   80103a8d <myproc>
80105f87:	8b 40 24             	mov    0x24(%eax),%eax
80105f8a:	85 c0                	test   %eax,%eax
80105f8c:	74 17                	je     80105fa5 <sys_sleep+0x5f>
      release(&tickslock);
80105f8e:	83 ec 0c             	sub    $0xc,%esp
80105f91:	68 40 6a 19 80       	push   $0x80196a40
80105f96:	e8 94 e9 ff ff       	call   8010492f <release>
80105f9b:	83 c4 10             	add    $0x10,%esp
      return -1;
80105f9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fa3:	eb 39                	jmp    80105fde <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105fa5:	83 ec 08             	sub    $0x8,%esp
80105fa8:	68 40 6a 19 80       	push   $0x80196a40
80105fad:	68 74 6a 19 80       	push   $0x80196a74
80105fb2:	e8 ad e3 ff ff       	call   80104364 <sleep>
80105fb7:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105fba:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105fbf:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105fc2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105fc5:	39 d0                	cmp    %edx,%eax
80105fc7:	72 b9                	jb     80105f82 <sys_sleep+0x3c>
  }
  release(&tickslock);
80105fc9:	83 ec 0c             	sub    $0xc,%esp
80105fcc:	68 40 6a 19 80       	push   $0x80196a40
80105fd1:	e8 59 e9 ff ff       	call   8010492f <release>
80105fd6:	83 c4 10             	add    $0x10,%esp
  return 0;
80105fd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fde:	c9                   	leave
80105fdf:	c3                   	ret

80105fe0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105fe0:	55                   	push   %ebp
80105fe1:	89 e5                	mov    %esp,%ebp
80105fe3:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105fe6:	83 ec 0c             	sub    $0xc,%esp
80105fe9:	68 40 6a 19 80       	push   $0x80196a40
80105fee:	e8 ce e8 ff ff       	call   801048c1 <acquire>
80105ff3:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105ff6:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105ffb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105ffe:	83 ec 0c             	sub    $0xc,%esp
80106001:	68 40 6a 19 80       	push   $0x80196a40
80106006:	e8 24 e9 ff ff       	call   8010492f <release>
8010600b:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010600e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106011:	c9                   	leave
80106012:	c3                   	ret

80106013 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106013:	1e                   	push   %ds
  pushl %es
80106014:	06                   	push   %es
  pushl %fs
80106015:	0f a0                	push   %fs
  pushl %gs
80106017:	0f a8                	push   %gs
  pushal
80106019:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010601a:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010601e:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106020:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106022:	54                   	push   %esp
  call trap
80106023:	e8 d7 01 00 00       	call   801061ff <trap>
  addl $4, %esp
80106028:	83 c4 04             	add    $0x4,%esp

8010602b <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010602b:	61                   	popa
  popl %gs
8010602c:	0f a9                	pop    %gs
  popl %fs
8010602e:	0f a1                	pop    %fs
  popl %es
80106030:	07                   	pop    %es
  popl %ds
80106031:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106032:	83 c4 08             	add    $0x8,%esp
  iret
80106035:	cf                   	iret

80106036 <lidt>:
{
80106036:	55                   	push   %ebp
80106037:	89 e5                	mov    %esp,%ebp
80106039:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010603c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010603f:	83 e8 01             	sub    $0x1,%eax
80106042:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106046:	8b 45 08             	mov    0x8(%ebp),%eax
80106049:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010604d:	8b 45 08             	mov    0x8(%ebp),%eax
80106050:	c1 e8 10             	shr    $0x10,%eax
80106053:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106057:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010605a:	0f 01 18             	lidtl  (%eax)
}
8010605d:	90                   	nop
8010605e:	c9                   	leave
8010605f:	c3                   	ret

80106060 <rcr2>:

static inline uint
rcr2(void)
{
80106060:	55                   	push   %ebp
80106061:	89 e5                	mov    %esp,%ebp
80106063:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106066:	0f 20 d0             	mov    %cr2,%eax
80106069:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010606c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010606f:	c9                   	leave
80106070:	c3                   	ret

80106071 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106071:	55                   	push   %ebp
80106072:	89 e5                	mov    %esp,%ebp
80106074:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106077:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010607e:	e9 c3 00 00 00       	jmp    80106146 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106083:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106086:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
8010608d:	89 c2                	mov    %eax,%edx
8010608f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106092:	66 89 14 c5 40 62 19 	mov    %dx,-0x7fe69dc0(,%eax,8)
80106099:	80 
8010609a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010609d:	66 c7 04 c5 42 62 19 	movw   $0x8,-0x7fe69dbe(,%eax,8)
801060a4:	80 08 00 
801060a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060aa:	0f b6 14 c5 44 62 19 	movzbl -0x7fe69dbc(,%eax,8),%edx
801060b1:	80 
801060b2:	83 e2 e0             	and    $0xffffffe0,%edx
801060b5:	88 14 c5 44 62 19 80 	mov    %dl,-0x7fe69dbc(,%eax,8)
801060bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060bf:	0f b6 14 c5 44 62 19 	movzbl -0x7fe69dbc(,%eax,8),%edx
801060c6:	80 
801060c7:	83 e2 1f             	and    $0x1f,%edx
801060ca:	88 14 c5 44 62 19 80 	mov    %dl,-0x7fe69dbc(,%eax,8)
801060d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d4:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
801060db:	80 
801060dc:	83 e2 f0             	and    $0xfffffff0,%edx
801060df:	83 ca 0e             	or     $0xe,%edx
801060e2:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
801060e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ec:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
801060f3:	80 
801060f4:	83 e2 ef             	and    $0xffffffef,%edx
801060f7:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
801060fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106101:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80106108:	80 
80106109:	83 e2 9f             	and    $0xffffff9f,%edx
8010610c:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80106113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106116:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
8010611d:	80 
8010611e:	83 ca 80             	or     $0xffffff80,%edx
80106121:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80106128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010612b:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80106132:	c1 e8 10             	shr    $0x10,%eax
80106135:	89 c2                	mov    %eax,%edx
80106137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010613a:	66 89 14 c5 46 62 19 	mov    %dx,-0x7fe69dba(,%eax,8)
80106141:	80 
  for(i = 0; i < 256; i++)
80106142:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106146:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010614d:	0f 8e 30 ff ff ff    	jle    80106083 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106153:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106158:	66 a3 40 64 19 80    	mov    %ax,0x80196440
8010615e:	66 c7 05 42 64 19 80 	movw   $0x8,0x80196442
80106165:	08 00 
80106167:	0f b6 05 44 64 19 80 	movzbl 0x80196444,%eax
8010616e:	83 e0 e0             	and    $0xffffffe0,%eax
80106171:	a2 44 64 19 80       	mov    %al,0x80196444
80106176:	0f b6 05 44 64 19 80 	movzbl 0x80196444,%eax
8010617d:	83 e0 1f             	and    $0x1f,%eax
80106180:	a2 44 64 19 80       	mov    %al,0x80196444
80106185:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
8010618c:	83 c8 0f             	or     $0xf,%eax
8010618f:	a2 45 64 19 80       	mov    %al,0x80196445
80106194:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
8010619b:	83 e0 ef             	and    $0xffffffef,%eax
8010619e:	a2 45 64 19 80       	mov    %al,0x80196445
801061a3:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
801061aa:	83 c8 60             	or     $0x60,%eax
801061ad:	a2 45 64 19 80       	mov    %al,0x80196445
801061b2:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
801061b9:	83 c8 80             	or     $0xffffff80,%eax
801061bc:	a2 45 64 19 80       	mov    %al,0x80196445
801061c1:	a1 80 f1 10 80       	mov    0x8010f180,%eax
801061c6:	c1 e8 10             	shr    $0x10,%eax
801061c9:	66 a3 46 64 19 80    	mov    %ax,0x80196446

  initlock(&tickslock, "time");
801061cf:	83 ec 08             	sub    $0x8,%esp
801061d2:	68 f0 a8 10 80       	push   $0x8010a8f0
801061d7:	68 40 6a 19 80       	push   $0x80196a40
801061dc:	e8 be e6 ff ff       	call   8010489f <initlock>
801061e1:	83 c4 10             	add    $0x10,%esp
}
801061e4:	90                   	nop
801061e5:	c9                   	leave
801061e6:	c3                   	ret

801061e7 <idtinit>:

void
idtinit(void)
{
801061e7:	55                   	push   %ebp
801061e8:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801061ea:	68 00 08 00 00       	push   $0x800
801061ef:	68 40 62 19 80       	push   $0x80196240
801061f4:	e8 3d fe ff ff       	call   80106036 <lidt>
801061f9:	83 c4 08             	add    $0x8,%esp
}
801061fc:	90                   	nop
801061fd:	c9                   	leave
801061fe:	c3                   	ret

801061ff <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801061ff:	55                   	push   %ebp
80106200:	89 e5                	mov    %esp,%ebp
80106202:	57                   	push   %edi
80106203:	56                   	push   %esi
80106204:	53                   	push   %ebx
80106205:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106208:	8b 45 08             	mov    0x8(%ebp),%eax
8010620b:	8b 40 30             	mov    0x30(%eax),%eax
8010620e:	83 f8 40             	cmp    $0x40,%eax
80106211:	75 3b                	jne    8010624e <trap+0x4f>
    if(myproc()->killed)
80106213:	e8 75 d8 ff ff       	call   80103a8d <myproc>
80106218:	8b 40 24             	mov    0x24(%eax),%eax
8010621b:	85 c0                	test   %eax,%eax
8010621d:	74 05                	je     80106224 <trap+0x25>
      exit();
8010621f:	e8 f1 dc ff ff       	call   80103f15 <exit>
    myproc()->tf = tf;
80106224:	e8 64 d8 ff ff       	call   80103a8d <myproc>
80106229:	8b 55 08             	mov    0x8(%ebp),%edx
8010622c:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010622f:	e8 cc ec ff ff       	call   80104f00 <syscall>
    if(myproc()->killed)
80106234:	e8 54 d8 ff ff       	call   80103a8d <myproc>
80106239:	8b 40 24             	mov    0x24(%eax),%eax
8010623c:	85 c0                	test   %eax,%eax
8010623e:	0f 84 0c 03 00 00    	je     80106550 <trap+0x351>
      exit();
80106244:	e8 cc dc ff ff       	call   80103f15 <exit>
    return;
80106249:	e9 02 03 00 00       	jmp    80106550 <trap+0x351>
  }

  switch(tf->trapno){
8010624e:	8b 45 08             	mov    0x8(%ebp),%eax
80106251:	8b 40 30             	mov    0x30(%eax),%eax
80106254:	83 e8 0e             	sub    $0xe,%eax
80106257:	83 f8 31             	cmp    $0x31,%eax
8010625a:	0f 87 bb 01 00 00    	ja     8010641b <trap+0x21c>
80106260:	8b 04 85 c4 a9 10 80 	mov    -0x7fef563c(,%eax,4),%eax
80106267:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106269:	e8 8c d7 ff ff       	call   801039fa <cpuid>
8010626e:	85 c0                	test   %eax,%eax
80106270:	75 3d                	jne    801062af <trap+0xb0>
      acquire(&tickslock);
80106272:	83 ec 0c             	sub    $0xc,%esp
80106275:	68 40 6a 19 80       	push   $0x80196a40
8010627a:	e8 42 e6 ff ff       	call   801048c1 <acquire>
8010627f:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106282:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80106287:	83 c0 01             	add    $0x1,%eax
8010628a:	a3 74 6a 19 80       	mov    %eax,0x80196a74
      wakeup(&ticks);
8010628f:	83 ec 0c             	sub    $0xc,%esp
80106292:	68 74 6a 19 80       	push   $0x80196a74
80106297:	e8 af e1 ff ff       	call   8010444b <wakeup>
8010629c:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
8010629f:	83 ec 0c             	sub    $0xc,%esp
801062a2:	68 40 6a 19 80       	push   $0x80196a40
801062a7:	e8 83 e6 ff ff       	call   8010492f <release>
801062ac:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801062af:	e8 c7 c8 ff ff       	call   80102b7b <lapiceoi>


    break;
801062b4:	e9 17 02 00 00       	jmp    801064d0 <trap+0x2d1>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801062b9:	e8 bc 3f 00 00       	call   8010a27a <ideintr>
    lapiceoi();
801062be:	e8 b8 c8 ff ff       	call   80102b7b <lapiceoi>
    break;
801062c3:	e9 08 02 00 00       	jmp    801064d0 <trap+0x2d1>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801062c8:	e8 f9 c6 ff ff       	call   801029c6 <kbdintr>
    lapiceoi();
801062cd:	e8 a9 c8 ff ff       	call   80102b7b <lapiceoi>
    break;
801062d2:	e9 f9 01 00 00       	jmp    801064d0 <trap+0x2d1>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801062d7:	e8 48 04 00 00       	call   80106724 <uartintr>
    lapiceoi();
801062dc:	e8 9a c8 ff ff       	call   80102b7b <lapiceoi>
    break;
801062e1:	e9 ea 01 00 00       	jmp    801064d0 <trap+0x2d1>
  case T_IRQ0 + 0xB:
    i8254_intr();
801062e6:	e8 58 2c 00 00       	call   80108f43 <i8254_intr>
    lapiceoi();
801062eb:	e8 8b c8 ff ff       	call   80102b7b <lapiceoi>
    break;
801062f0:	e9 db 01 00 00       	jmp    801064d0 <trap+0x2d1>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801062f5:	8b 45 08             	mov    0x8(%ebp),%eax
801062f8:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801062fb:	8b 45 08             	mov    0x8(%ebp),%eax
801062fe:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106302:	0f b7 d8             	movzwl %ax,%ebx
80106305:	e8 f0 d6 ff ff       	call   801039fa <cpuid>
8010630a:	56                   	push   %esi
8010630b:	53                   	push   %ebx
8010630c:	50                   	push   %eax
8010630d:	68 f8 a8 10 80       	push   $0x8010a8f8
80106312:	e8 dd a0 ff ff       	call   801003f4 <cprintf>
80106317:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
8010631a:	e8 5c c8 ff ff       	call   80102b7b <lapiceoi>
    break;
8010631f:	e9 ac 01 00 00       	jmp    801064d0 <trap+0x2d1>
  
    // page fault 발생 시 이 블록 실행
  case T_PGFLT:
    if(myproc()->killed)
80106324:	e8 64 d7 ff ff       	call   80103a8d <myproc>
80106329:	8b 40 24             	mov    0x24(%eax),%eax
8010632c:	85 c0                	test   %eax,%eax
8010632e:	74 05                	je     80106335 <trap+0x136>
      exit();
80106330:	e8 e0 db ff ff       	call   80103f15 <exit>
    pde_t* pgdir;
    uint va;
    struct proc* p;
    uint sp;
    p = myproc();
80106335:	e8 53 d7 ff ff       	call   80103a8d <myproc>
8010633a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    // va = 페이지 폴트가 난 가상 주소의 페이지 시작 주소
    va = PGROUNDDOWN(rcr2());
8010633d:	e8 1e fd ff ff       	call   80106060 <rcr2>
80106342:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106347:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pgdir = p->pgdir;
8010634a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010634d:	8b 40 04             	mov    0x4(%eax),%eax
80106350:	89 45 dc             	mov    %eax,-0x24(%ebp)
    sp = p->tf->esp;
80106353:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106356:	8b 40 18             	mov    0x18(%eax),%eax
80106359:	8b 40 44             	mov    0x44(%eax),%eax
8010635c:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // sz+PGSIZE보다 크면 비정상적인 힙 영역 접근
    // sp-PGSIZE보다 작으면 비정상적인 스택 접근
    if (va > p->sz + PGSIZE && va < sp - PGSIZE){
8010635f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106362:	8b 00                	mov    (%eax),%eax
80106364:	05 00 10 00 00       	add    $0x1000,%eax
80106369:	3b 45 e0             	cmp    -0x20(%ebp),%eax
8010636c:	73 48                	jae    801063b6 <trap+0x1b7>
8010636e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106371:	2d 00 10 00 00       	sub    $0x1000,%eax
80106376:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80106379:	73 3b                	jae    801063b6 <trap+0x1b7>
      cprintf("invaild access va %x sz %x sp %x eip %x\n",rcr2(),p->sz,sp, p->tf->eip);
8010637b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010637e:	8b 40 18             	mov    0x18(%eax),%eax
80106381:	8b 70 38             	mov    0x38(%eax),%esi
80106384:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106387:	8b 18                	mov    (%eax),%ebx
80106389:	e8 d2 fc ff ff       	call   80106060 <rcr2>
8010638e:	83 ec 0c             	sub    $0xc,%esp
80106391:	56                   	push   %esi
80106392:	ff 75 d8             	push   -0x28(%ebp)
80106395:	53                   	push   %ebx
80106396:	50                   	push   %eax
80106397:	68 1c a9 10 80       	push   $0x8010a91c
8010639c:	e8 53 a0 ff ff       	call   801003f4 <cprintf>
801063a1:	83 c4 20             	add    $0x20,%esp
      kill(p->pid);
801063a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063a7:	8b 40 10             	mov    0x10(%eax),%eax
801063aa:	83 ec 0c             	sub    $0xc,%esp
801063ad:	50                   	push   %eax
801063ae:	e8 cf e0 ff ff       	call   80104482 <kill>
801063b3:	83 c4 10             	add    $0x10,%esp
    }

    if (va <= p->sz + PGSIZE){
801063b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063b9:	8b 00                	mov    (%eax),%eax
801063bb:	05 00 10 00 00       	add    $0x1000,%eax
801063c0:	3b 45 e0             	cmp    -0x20(%ebp),%eax
801063c3:	72 1c                	jb     801063e1 <trap+0x1e2>
      allocuvm(pgdir, va, va + PGSIZE);
801063c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801063c8:	05 00 10 00 00       	add    $0x1000,%eax
801063cd:	83 ec 04             	sub    $0x4,%esp
801063d0:	50                   	push   %eax
801063d1:	ff 75 e0             	push   -0x20(%ebp)
801063d4:	ff 75 dc             	push   -0x24(%ebp)
801063d7:	e8 96 16 00 00       	call   80107a72 <allocuvm>
801063dc:	83 c4 10             	add    $0x10,%esp
801063df:	eb 27                	jmp    80106408 <trap+0x209>
    }
    else if (va >= sp - PGSIZE)
801063e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
801063e4:	2d 00 10 00 00       	sub    $0x1000,%eax
801063e9:	39 45 e0             	cmp    %eax,-0x20(%ebp)
801063ec:	72 1a                	jb     80106408 <trap+0x209>
    {
      allocuvm(pgdir, va, va + PGSIZE);
801063ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801063f1:	05 00 10 00 00       	add    $0x1000,%eax
801063f6:	83 ec 04             	sub    $0x4,%esp
801063f9:	50                   	push   %eax
801063fa:	ff 75 e0             	push   -0x20(%ebp)
801063fd:	ff 75 dc             	push   -0x24(%ebp)
80106400:	e8 6d 16 00 00       	call   80107a72 <allocuvm>
80106405:	83 c4 10             	add    $0x10,%esp
    }

    // flush
    switchuvm(p);
80106408:	83 ec 0c             	sub    $0xc,%esp
8010640b:	ff 75 e4             	push   -0x1c(%ebp)
8010640e:	e8 83 13 00 00       	call   80107796 <switchuvm>
80106413:	83 c4 10             	add    $0x10,%esp
    break;
80106416:	e9 b5 00 00 00       	jmp    801064d0 <trap+0x2d1>


  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010641b:	e8 6d d6 ff ff       	call   80103a8d <myproc>
80106420:	85 c0                	test   %eax,%eax
80106422:	74 11                	je     80106435 <trap+0x236>
80106424:	8b 45 08             	mov    0x8(%ebp),%eax
80106427:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010642b:	0f b7 c0             	movzwl %ax,%eax
8010642e:	83 e0 03             	and    $0x3,%eax
80106431:	85 c0                	test   %eax,%eax
80106433:	75 39                	jne    8010646e <trap+0x26f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106435:	e8 26 fc ff ff       	call   80106060 <rcr2>
8010643a:	89 c3                	mov    %eax,%ebx
8010643c:	8b 45 08             	mov    0x8(%ebp),%eax
8010643f:	8b 70 38             	mov    0x38(%eax),%esi
80106442:	e8 b3 d5 ff ff       	call   801039fa <cpuid>
80106447:	8b 55 08             	mov    0x8(%ebp),%edx
8010644a:	8b 52 30             	mov    0x30(%edx),%edx
8010644d:	83 ec 0c             	sub    $0xc,%esp
80106450:	53                   	push   %ebx
80106451:	56                   	push   %esi
80106452:	50                   	push   %eax
80106453:	52                   	push   %edx
80106454:	68 48 a9 10 80       	push   $0x8010a948
80106459:	e8 96 9f ff ff       	call   801003f4 <cprintf>
8010645e:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106461:	83 ec 0c             	sub    $0xc,%esp
80106464:	68 7a a9 10 80       	push   $0x8010a97a
80106469:	e8 53 a1 ff ff       	call   801005c1 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010646e:	e8 ed fb ff ff       	call   80106060 <rcr2>
80106473:	89 c6                	mov    %eax,%esi
80106475:	8b 45 08             	mov    0x8(%ebp),%eax
80106478:	8b 40 38             	mov    0x38(%eax),%eax
8010647b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010647e:	e8 77 d5 ff ff       	call   801039fa <cpuid>
80106483:	89 c3                	mov    %eax,%ebx
80106485:	8b 45 08             	mov    0x8(%ebp),%eax
80106488:	8b 48 34             	mov    0x34(%eax),%ecx
8010648b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
8010648e:	8b 45 08             	mov    0x8(%ebp),%eax
80106491:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106494:	e8 f4 d5 ff ff       	call   80103a8d <myproc>
80106499:	8d 50 6c             	lea    0x6c(%eax),%edx
8010649c:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010649f:	e8 e9 d5 ff ff       	call   80103a8d <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801064a4:	8b 40 10             	mov    0x10(%eax),%eax
801064a7:	56                   	push   %esi
801064a8:	ff 75 d4             	push   -0x2c(%ebp)
801064ab:	53                   	push   %ebx
801064ac:	ff 75 d0             	push   -0x30(%ebp)
801064af:	57                   	push   %edi
801064b0:	ff 75 cc             	push   -0x34(%ebp)
801064b3:	50                   	push   %eax
801064b4:	68 80 a9 10 80       	push   $0x8010a980
801064b9:	e8 36 9f ff ff       	call   801003f4 <cprintf>
801064be:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801064c1:	e8 c7 d5 ff ff       	call   80103a8d <myproc>
801064c6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801064cd:	eb 01                	jmp    801064d0 <trap+0x2d1>
    break;
801064cf:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801064d0:	e8 b8 d5 ff ff       	call   80103a8d <myproc>
801064d5:	85 c0                	test   %eax,%eax
801064d7:	74 23                	je     801064fc <trap+0x2fd>
801064d9:	e8 af d5 ff ff       	call   80103a8d <myproc>
801064de:	8b 40 24             	mov    0x24(%eax),%eax
801064e1:	85 c0                	test   %eax,%eax
801064e3:	74 17                	je     801064fc <trap+0x2fd>
801064e5:	8b 45 08             	mov    0x8(%ebp),%eax
801064e8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801064ec:	0f b7 c0             	movzwl %ax,%eax
801064ef:	83 e0 03             	and    $0x3,%eax
801064f2:	83 f8 03             	cmp    $0x3,%eax
801064f5:	75 05                	jne    801064fc <trap+0x2fd>
    exit();
801064f7:	e8 19 da ff ff       	call   80103f15 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801064fc:	e8 8c d5 ff ff       	call   80103a8d <myproc>
80106501:	85 c0                	test   %eax,%eax
80106503:	74 1d                	je     80106522 <trap+0x323>
80106505:	e8 83 d5 ff ff       	call   80103a8d <myproc>
8010650a:	8b 40 0c             	mov    0xc(%eax),%eax
8010650d:	83 f8 04             	cmp    $0x4,%eax
80106510:	75 10                	jne    80106522 <trap+0x323>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106512:	8b 45 08             	mov    0x8(%ebp),%eax
80106515:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106518:	83 f8 20             	cmp    $0x20,%eax
8010651b:	75 05                	jne    80106522 <trap+0x323>
    yield();
8010651d:	e8 c2 dd ff ff       	call   801042e4 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106522:	e8 66 d5 ff ff       	call   80103a8d <myproc>
80106527:	85 c0                	test   %eax,%eax
80106529:	74 26                	je     80106551 <trap+0x352>
8010652b:	e8 5d d5 ff ff       	call   80103a8d <myproc>
80106530:	8b 40 24             	mov    0x24(%eax),%eax
80106533:	85 c0                	test   %eax,%eax
80106535:	74 1a                	je     80106551 <trap+0x352>
80106537:	8b 45 08             	mov    0x8(%ebp),%eax
8010653a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010653e:	0f b7 c0             	movzwl %ax,%eax
80106541:	83 e0 03             	and    $0x3,%eax
80106544:	83 f8 03             	cmp    $0x3,%eax
80106547:	75 08                	jne    80106551 <trap+0x352>
    exit();
80106549:	e8 c7 d9 ff ff       	call   80103f15 <exit>
8010654e:	eb 01                	jmp    80106551 <trap+0x352>
    return;
80106550:	90                   	nop
80106551:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106554:	5b                   	pop    %ebx
80106555:	5e                   	pop    %esi
80106556:	5f                   	pop    %edi
80106557:	5d                   	pop    %ebp
80106558:	c3                   	ret

80106559 <inb>:
{
80106559:	55                   	push   %ebp
8010655a:	89 e5                	mov    %esp,%ebp
8010655c:	83 ec 14             	sub    $0x14,%esp
8010655f:	8b 45 08             	mov    0x8(%ebp),%eax
80106562:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106566:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010656a:	89 c2                	mov    %eax,%edx
8010656c:	ec                   	in     (%dx),%al
8010656d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106570:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106574:	c9                   	leave
80106575:	c3                   	ret

80106576 <outb>:
{
80106576:	55                   	push   %ebp
80106577:	89 e5                	mov    %esp,%ebp
80106579:	83 ec 08             	sub    $0x8,%esp
8010657c:	8b 55 08             	mov    0x8(%ebp),%edx
8010657f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106582:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106586:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106589:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010658d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106591:	ee                   	out    %al,(%dx)
}
80106592:	90                   	nop
80106593:	c9                   	leave
80106594:	c3                   	ret

80106595 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106595:	55                   	push   %ebp
80106596:	89 e5                	mov    %esp,%ebp
80106598:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010659b:	6a 00                	push   $0x0
8010659d:	68 fa 03 00 00       	push   $0x3fa
801065a2:	e8 cf ff ff ff       	call   80106576 <outb>
801065a7:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801065aa:	68 80 00 00 00       	push   $0x80
801065af:	68 fb 03 00 00       	push   $0x3fb
801065b4:	e8 bd ff ff ff       	call   80106576 <outb>
801065b9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801065bc:	6a 0c                	push   $0xc
801065be:	68 f8 03 00 00       	push   $0x3f8
801065c3:	e8 ae ff ff ff       	call   80106576 <outb>
801065c8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801065cb:	6a 00                	push   $0x0
801065cd:	68 f9 03 00 00       	push   $0x3f9
801065d2:	e8 9f ff ff ff       	call   80106576 <outb>
801065d7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801065da:	6a 03                	push   $0x3
801065dc:	68 fb 03 00 00       	push   $0x3fb
801065e1:	e8 90 ff ff ff       	call   80106576 <outb>
801065e6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801065e9:	6a 00                	push   $0x0
801065eb:	68 fc 03 00 00       	push   $0x3fc
801065f0:	e8 81 ff ff ff       	call   80106576 <outb>
801065f5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801065f8:	6a 01                	push   $0x1
801065fa:	68 f9 03 00 00       	push   $0x3f9
801065ff:	e8 72 ff ff ff       	call   80106576 <outb>
80106604:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106607:	68 fd 03 00 00       	push   $0x3fd
8010660c:	e8 48 ff ff ff       	call   80106559 <inb>
80106611:	83 c4 04             	add    $0x4,%esp
80106614:	3c ff                	cmp    $0xff,%al
80106616:	74 61                	je     80106679 <uartinit+0xe4>
    return;
  uart = 1;
80106618:	c7 05 78 6a 19 80 01 	movl   $0x1,0x80196a78
8010661f:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106622:	68 fa 03 00 00       	push   $0x3fa
80106627:	e8 2d ff ff ff       	call   80106559 <inb>
8010662c:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010662f:	68 f8 03 00 00       	push   $0x3f8
80106634:	e8 20 ff ff ff       	call   80106559 <inb>
80106639:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010663c:	83 ec 08             	sub    $0x8,%esp
8010663f:	6a 00                	push   $0x0
80106641:	6a 04                	push   $0x4
80106643:	e8 4b c0 ff ff       	call   80102693 <ioapicenable>
80106648:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010664b:	c7 45 f4 8c aa 10 80 	movl   $0x8010aa8c,-0xc(%ebp)
80106652:	eb 19                	jmp    8010666d <uartinit+0xd8>
    uartputc(*p);
80106654:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106657:	0f b6 00             	movzbl (%eax),%eax
8010665a:	0f be c0             	movsbl %al,%eax
8010665d:	83 ec 0c             	sub    $0xc,%esp
80106660:	50                   	push   %eax
80106661:	e8 16 00 00 00       	call   8010667c <uartputc>
80106666:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106669:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010666d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106670:	0f b6 00             	movzbl (%eax),%eax
80106673:	84 c0                	test   %al,%al
80106675:	75 dd                	jne    80106654 <uartinit+0xbf>
80106677:	eb 01                	jmp    8010667a <uartinit+0xe5>
    return;
80106679:	90                   	nop
}
8010667a:	c9                   	leave
8010667b:	c3                   	ret

8010667c <uartputc>:

void
uartputc(int c)
{
8010667c:	55                   	push   %ebp
8010667d:	89 e5                	mov    %esp,%ebp
8010667f:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106682:	a1 78 6a 19 80       	mov    0x80196a78,%eax
80106687:	85 c0                	test   %eax,%eax
80106689:	74 53                	je     801066de <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010668b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106692:	eb 11                	jmp    801066a5 <uartputc+0x29>
    microdelay(10);
80106694:	83 ec 0c             	sub    $0xc,%esp
80106697:	6a 0a                	push   $0xa
80106699:	e8 f8 c4 ff ff       	call   80102b96 <microdelay>
8010669e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801066a1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801066a5:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801066a9:	7f 1a                	jg     801066c5 <uartputc+0x49>
801066ab:	83 ec 0c             	sub    $0xc,%esp
801066ae:	68 fd 03 00 00       	push   $0x3fd
801066b3:	e8 a1 fe ff ff       	call   80106559 <inb>
801066b8:	83 c4 10             	add    $0x10,%esp
801066bb:	0f b6 c0             	movzbl %al,%eax
801066be:	83 e0 20             	and    $0x20,%eax
801066c1:	85 c0                	test   %eax,%eax
801066c3:	74 cf                	je     80106694 <uartputc+0x18>
  outb(COM1+0, c);
801066c5:	8b 45 08             	mov    0x8(%ebp),%eax
801066c8:	0f b6 c0             	movzbl %al,%eax
801066cb:	83 ec 08             	sub    $0x8,%esp
801066ce:	50                   	push   %eax
801066cf:	68 f8 03 00 00       	push   $0x3f8
801066d4:	e8 9d fe ff ff       	call   80106576 <outb>
801066d9:	83 c4 10             	add    $0x10,%esp
801066dc:	eb 01                	jmp    801066df <uartputc+0x63>
    return;
801066de:	90                   	nop
}
801066df:	c9                   	leave
801066e0:	c3                   	ret

801066e1 <uartgetc>:

static int
uartgetc(void)
{
801066e1:	55                   	push   %ebp
801066e2:	89 e5                	mov    %esp,%ebp
  if(!uart)
801066e4:	a1 78 6a 19 80       	mov    0x80196a78,%eax
801066e9:	85 c0                	test   %eax,%eax
801066eb:	75 07                	jne    801066f4 <uartgetc+0x13>
    return -1;
801066ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f2:	eb 2e                	jmp    80106722 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801066f4:	68 fd 03 00 00       	push   $0x3fd
801066f9:	e8 5b fe ff ff       	call   80106559 <inb>
801066fe:	83 c4 04             	add    $0x4,%esp
80106701:	0f b6 c0             	movzbl %al,%eax
80106704:	83 e0 01             	and    $0x1,%eax
80106707:	85 c0                	test   %eax,%eax
80106709:	75 07                	jne    80106712 <uartgetc+0x31>
    return -1;
8010670b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106710:	eb 10                	jmp    80106722 <uartgetc+0x41>
  return inb(COM1+0);
80106712:	68 f8 03 00 00       	push   $0x3f8
80106717:	e8 3d fe ff ff       	call   80106559 <inb>
8010671c:	83 c4 04             	add    $0x4,%esp
8010671f:	0f b6 c0             	movzbl %al,%eax
}
80106722:	c9                   	leave
80106723:	c3                   	ret

80106724 <uartintr>:

void
uartintr(void)
{
80106724:	55                   	push   %ebp
80106725:	89 e5                	mov    %esp,%ebp
80106727:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010672a:	83 ec 0c             	sub    $0xc,%esp
8010672d:	68 e1 66 10 80       	push   $0x801066e1
80106732:	e8 b7 a0 ff ff       	call   801007ee <consoleintr>
80106737:	83 c4 10             	add    $0x10,%esp
}
8010673a:	90                   	nop
8010673b:	c9                   	leave
8010673c:	c3                   	ret

8010673d <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010673d:	6a 00                	push   $0x0
  pushl $0
8010673f:	6a 00                	push   $0x0
  jmp alltraps
80106741:	e9 cd f8 ff ff       	jmp    80106013 <alltraps>

80106746 <vector1>:
.globl vector1
vector1:
  pushl $0
80106746:	6a 00                	push   $0x0
  pushl $1
80106748:	6a 01                	push   $0x1
  jmp alltraps
8010674a:	e9 c4 f8 ff ff       	jmp    80106013 <alltraps>

8010674f <vector2>:
.globl vector2
vector2:
  pushl $0
8010674f:	6a 00                	push   $0x0
  pushl $2
80106751:	6a 02                	push   $0x2
  jmp alltraps
80106753:	e9 bb f8 ff ff       	jmp    80106013 <alltraps>

80106758 <vector3>:
.globl vector3
vector3:
  pushl $0
80106758:	6a 00                	push   $0x0
  pushl $3
8010675a:	6a 03                	push   $0x3
  jmp alltraps
8010675c:	e9 b2 f8 ff ff       	jmp    80106013 <alltraps>

80106761 <vector4>:
.globl vector4
vector4:
  pushl $0
80106761:	6a 00                	push   $0x0
  pushl $4
80106763:	6a 04                	push   $0x4
  jmp alltraps
80106765:	e9 a9 f8 ff ff       	jmp    80106013 <alltraps>

8010676a <vector5>:
.globl vector5
vector5:
  pushl $0
8010676a:	6a 00                	push   $0x0
  pushl $5
8010676c:	6a 05                	push   $0x5
  jmp alltraps
8010676e:	e9 a0 f8 ff ff       	jmp    80106013 <alltraps>

80106773 <vector6>:
.globl vector6
vector6:
  pushl $0
80106773:	6a 00                	push   $0x0
  pushl $6
80106775:	6a 06                	push   $0x6
  jmp alltraps
80106777:	e9 97 f8 ff ff       	jmp    80106013 <alltraps>

8010677c <vector7>:
.globl vector7
vector7:
  pushl $0
8010677c:	6a 00                	push   $0x0
  pushl $7
8010677e:	6a 07                	push   $0x7
  jmp alltraps
80106780:	e9 8e f8 ff ff       	jmp    80106013 <alltraps>

80106785 <vector8>:
.globl vector8
vector8:
  pushl $8
80106785:	6a 08                	push   $0x8
  jmp alltraps
80106787:	e9 87 f8 ff ff       	jmp    80106013 <alltraps>

8010678c <vector9>:
.globl vector9
vector9:
  pushl $0
8010678c:	6a 00                	push   $0x0
  pushl $9
8010678e:	6a 09                	push   $0x9
  jmp alltraps
80106790:	e9 7e f8 ff ff       	jmp    80106013 <alltraps>

80106795 <vector10>:
.globl vector10
vector10:
  pushl $10
80106795:	6a 0a                	push   $0xa
  jmp alltraps
80106797:	e9 77 f8 ff ff       	jmp    80106013 <alltraps>

8010679c <vector11>:
.globl vector11
vector11:
  pushl $11
8010679c:	6a 0b                	push   $0xb
  jmp alltraps
8010679e:	e9 70 f8 ff ff       	jmp    80106013 <alltraps>

801067a3 <vector12>:
.globl vector12
vector12:
  pushl $12
801067a3:	6a 0c                	push   $0xc
  jmp alltraps
801067a5:	e9 69 f8 ff ff       	jmp    80106013 <alltraps>

801067aa <vector13>:
.globl vector13
vector13:
  pushl $13
801067aa:	6a 0d                	push   $0xd
  jmp alltraps
801067ac:	e9 62 f8 ff ff       	jmp    80106013 <alltraps>

801067b1 <vector14>:
.globl vector14
vector14:
  pushl $14
801067b1:	6a 0e                	push   $0xe
  jmp alltraps
801067b3:	e9 5b f8 ff ff       	jmp    80106013 <alltraps>

801067b8 <vector15>:
.globl vector15
vector15:
  pushl $0
801067b8:	6a 00                	push   $0x0
  pushl $15
801067ba:	6a 0f                	push   $0xf
  jmp alltraps
801067bc:	e9 52 f8 ff ff       	jmp    80106013 <alltraps>

801067c1 <vector16>:
.globl vector16
vector16:
  pushl $0
801067c1:	6a 00                	push   $0x0
  pushl $16
801067c3:	6a 10                	push   $0x10
  jmp alltraps
801067c5:	e9 49 f8 ff ff       	jmp    80106013 <alltraps>

801067ca <vector17>:
.globl vector17
vector17:
  pushl $17
801067ca:	6a 11                	push   $0x11
  jmp alltraps
801067cc:	e9 42 f8 ff ff       	jmp    80106013 <alltraps>

801067d1 <vector18>:
.globl vector18
vector18:
  pushl $0
801067d1:	6a 00                	push   $0x0
  pushl $18
801067d3:	6a 12                	push   $0x12
  jmp alltraps
801067d5:	e9 39 f8 ff ff       	jmp    80106013 <alltraps>

801067da <vector19>:
.globl vector19
vector19:
  pushl $0
801067da:	6a 00                	push   $0x0
  pushl $19
801067dc:	6a 13                	push   $0x13
  jmp alltraps
801067de:	e9 30 f8 ff ff       	jmp    80106013 <alltraps>

801067e3 <vector20>:
.globl vector20
vector20:
  pushl $0
801067e3:	6a 00                	push   $0x0
  pushl $20
801067e5:	6a 14                	push   $0x14
  jmp alltraps
801067e7:	e9 27 f8 ff ff       	jmp    80106013 <alltraps>

801067ec <vector21>:
.globl vector21
vector21:
  pushl $0
801067ec:	6a 00                	push   $0x0
  pushl $21
801067ee:	6a 15                	push   $0x15
  jmp alltraps
801067f0:	e9 1e f8 ff ff       	jmp    80106013 <alltraps>

801067f5 <vector22>:
.globl vector22
vector22:
  pushl $0
801067f5:	6a 00                	push   $0x0
  pushl $22
801067f7:	6a 16                	push   $0x16
  jmp alltraps
801067f9:	e9 15 f8 ff ff       	jmp    80106013 <alltraps>

801067fe <vector23>:
.globl vector23
vector23:
  pushl $0
801067fe:	6a 00                	push   $0x0
  pushl $23
80106800:	6a 17                	push   $0x17
  jmp alltraps
80106802:	e9 0c f8 ff ff       	jmp    80106013 <alltraps>

80106807 <vector24>:
.globl vector24
vector24:
  pushl $0
80106807:	6a 00                	push   $0x0
  pushl $24
80106809:	6a 18                	push   $0x18
  jmp alltraps
8010680b:	e9 03 f8 ff ff       	jmp    80106013 <alltraps>

80106810 <vector25>:
.globl vector25
vector25:
  pushl $0
80106810:	6a 00                	push   $0x0
  pushl $25
80106812:	6a 19                	push   $0x19
  jmp alltraps
80106814:	e9 fa f7 ff ff       	jmp    80106013 <alltraps>

80106819 <vector26>:
.globl vector26
vector26:
  pushl $0
80106819:	6a 00                	push   $0x0
  pushl $26
8010681b:	6a 1a                	push   $0x1a
  jmp alltraps
8010681d:	e9 f1 f7 ff ff       	jmp    80106013 <alltraps>

80106822 <vector27>:
.globl vector27
vector27:
  pushl $0
80106822:	6a 00                	push   $0x0
  pushl $27
80106824:	6a 1b                	push   $0x1b
  jmp alltraps
80106826:	e9 e8 f7 ff ff       	jmp    80106013 <alltraps>

8010682b <vector28>:
.globl vector28
vector28:
  pushl $0
8010682b:	6a 00                	push   $0x0
  pushl $28
8010682d:	6a 1c                	push   $0x1c
  jmp alltraps
8010682f:	e9 df f7 ff ff       	jmp    80106013 <alltraps>

80106834 <vector29>:
.globl vector29
vector29:
  pushl $0
80106834:	6a 00                	push   $0x0
  pushl $29
80106836:	6a 1d                	push   $0x1d
  jmp alltraps
80106838:	e9 d6 f7 ff ff       	jmp    80106013 <alltraps>

8010683d <vector30>:
.globl vector30
vector30:
  pushl $0
8010683d:	6a 00                	push   $0x0
  pushl $30
8010683f:	6a 1e                	push   $0x1e
  jmp alltraps
80106841:	e9 cd f7 ff ff       	jmp    80106013 <alltraps>

80106846 <vector31>:
.globl vector31
vector31:
  pushl $0
80106846:	6a 00                	push   $0x0
  pushl $31
80106848:	6a 1f                	push   $0x1f
  jmp alltraps
8010684a:	e9 c4 f7 ff ff       	jmp    80106013 <alltraps>

8010684f <vector32>:
.globl vector32
vector32:
  pushl $0
8010684f:	6a 00                	push   $0x0
  pushl $32
80106851:	6a 20                	push   $0x20
  jmp alltraps
80106853:	e9 bb f7 ff ff       	jmp    80106013 <alltraps>

80106858 <vector33>:
.globl vector33
vector33:
  pushl $0
80106858:	6a 00                	push   $0x0
  pushl $33
8010685a:	6a 21                	push   $0x21
  jmp alltraps
8010685c:	e9 b2 f7 ff ff       	jmp    80106013 <alltraps>

80106861 <vector34>:
.globl vector34
vector34:
  pushl $0
80106861:	6a 00                	push   $0x0
  pushl $34
80106863:	6a 22                	push   $0x22
  jmp alltraps
80106865:	e9 a9 f7 ff ff       	jmp    80106013 <alltraps>

8010686a <vector35>:
.globl vector35
vector35:
  pushl $0
8010686a:	6a 00                	push   $0x0
  pushl $35
8010686c:	6a 23                	push   $0x23
  jmp alltraps
8010686e:	e9 a0 f7 ff ff       	jmp    80106013 <alltraps>

80106873 <vector36>:
.globl vector36
vector36:
  pushl $0
80106873:	6a 00                	push   $0x0
  pushl $36
80106875:	6a 24                	push   $0x24
  jmp alltraps
80106877:	e9 97 f7 ff ff       	jmp    80106013 <alltraps>

8010687c <vector37>:
.globl vector37
vector37:
  pushl $0
8010687c:	6a 00                	push   $0x0
  pushl $37
8010687e:	6a 25                	push   $0x25
  jmp alltraps
80106880:	e9 8e f7 ff ff       	jmp    80106013 <alltraps>

80106885 <vector38>:
.globl vector38
vector38:
  pushl $0
80106885:	6a 00                	push   $0x0
  pushl $38
80106887:	6a 26                	push   $0x26
  jmp alltraps
80106889:	e9 85 f7 ff ff       	jmp    80106013 <alltraps>

8010688e <vector39>:
.globl vector39
vector39:
  pushl $0
8010688e:	6a 00                	push   $0x0
  pushl $39
80106890:	6a 27                	push   $0x27
  jmp alltraps
80106892:	e9 7c f7 ff ff       	jmp    80106013 <alltraps>

80106897 <vector40>:
.globl vector40
vector40:
  pushl $0
80106897:	6a 00                	push   $0x0
  pushl $40
80106899:	6a 28                	push   $0x28
  jmp alltraps
8010689b:	e9 73 f7 ff ff       	jmp    80106013 <alltraps>

801068a0 <vector41>:
.globl vector41
vector41:
  pushl $0
801068a0:	6a 00                	push   $0x0
  pushl $41
801068a2:	6a 29                	push   $0x29
  jmp alltraps
801068a4:	e9 6a f7 ff ff       	jmp    80106013 <alltraps>

801068a9 <vector42>:
.globl vector42
vector42:
  pushl $0
801068a9:	6a 00                	push   $0x0
  pushl $42
801068ab:	6a 2a                	push   $0x2a
  jmp alltraps
801068ad:	e9 61 f7 ff ff       	jmp    80106013 <alltraps>

801068b2 <vector43>:
.globl vector43
vector43:
  pushl $0
801068b2:	6a 00                	push   $0x0
  pushl $43
801068b4:	6a 2b                	push   $0x2b
  jmp alltraps
801068b6:	e9 58 f7 ff ff       	jmp    80106013 <alltraps>

801068bb <vector44>:
.globl vector44
vector44:
  pushl $0
801068bb:	6a 00                	push   $0x0
  pushl $44
801068bd:	6a 2c                	push   $0x2c
  jmp alltraps
801068bf:	e9 4f f7 ff ff       	jmp    80106013 <alltraps>

801068c4 <vector45>:
.globl vector45
vector45:
  pushl $0
801068c4:	6a 00                	push   $0x0
  pushl $45
801068c6:	6a 2d                	push   $0x2d
  jmp alltraps
801068c8:	e9 46 f7 ff ff       	jmp    80106013 <alltraps>

801068cd <vector46>:
.globl vector46
vector46:
  pushl $0
801068cd:	6a 00                	push   $0x0
  pushl $46
801068cf:	6a 2e                	push   $0x2e
  jmp alltraps
801068d1:	e9 3d f7 ff ff       	jmp    80106013 <alltraps>

801068d6 <vector47>:
.globl vector47
vector47:
  pushl $0
801068d6:	6a 00                	push   $0x0
  pushl $47
801068d8:	6a 2f                	push   $0x2f
  jmp alltraps
801068da:	e9 34 f7 ff ff       	jmp    80106013 <alltraps>

801068df <vector48>:
.globl vector48
vector48:
  pushl $0
801068df:	6a 00                	push   $0x0
  pushl $48
801068e1:	6a 30                	push   $0x30
  jmp alltraps
801068e3:	e9 2b f7 ff ff       	jmp    80106013 <alltraps>

801068e8 <vector49>:
.globl vector49
vector49:
  pushl $0
801068e8:	6a 00                	push   $0x0
  pushl $49
801068ea:	6a 31                	push   $0x31
  jmp alltraps
801068ec:	e9 22 f7 ff ff       	jmp    80106013 <alltraps>

801068f1 <vector50>:
.globl vector50
vector50:
  pushl $0
801068f1:	6a 00                	push   $0x0
  pushl $50
801068f3:	6a 32                	push   $0x32
  jmp alltraps
801068f5:	e9 19 f7 ff ff       	jmp    80106013 <alltraps>

801068fa <vector51>:
.globl vector51
vector51:
  pushl $0
801068fa:	6a 00                	push   $0x0
  pushl $51
801068fc:	6a 33                	push   $0x33
  jmp alltraps
801068fe:	e9 10 f7 ff ff       	jmp    80106013 <alltraps>

80106903 <vector52>:
.globl vector52
vector52:
  pushl $0
80106903:	6a 00                	push   $0x0
  pushl $52
80106905:	6a 34                	push   $0x34
  jmp alltraps
80106907:	e9 07 f7 ff ff       	jmp    80106013 <alltraps>

8010690c <vector53>:
.globl vector53
vector53:
  pushl $0
8010690c:	6a 00                	push   $0x0
  pushl $53
8010690e:	6a 35                	push   $0x35
  jmp alltraps
80106910:	e9 fe f6 ff ff       	jmp    80106013 <alltraps>

80106915 <vector54>:
.globl vector54
vector54:
  pushl $0
80106915:	6a 00                	push   $0x0
  pushl $54
80106917:	6a 36                	push   $0x36
  jmp alltraps
80106919:	e9 f5 f6 ff ff       	jmp    80106013 <alltraps>

8010691e <vector55>:
.globl vector55
vector55:
  pushl $0
8010691e:	6a 00                	push   $0x0
  pushl $55
80106920:	6a 37                	push   $0x37
  jmp alltraps
80106922:	e9 ec f6 ff ff       	jmp    80106013 <alltraps>

80106927 <vector56>:
.globl vector56
vector56:
  pushl $0
80106927:	6a 00                	push   $0x0
  pushl $56
80106929:	6a 38                	push   $0x38
  jmp alltraps
8010692b:	e9 e3 f6 ff ff       	jmp    80106013 <alltraps>

80106930 <vector57>:
.globl vector57
vector57:
  pushl $0
80106930:	6a 00                	push   $0x0
  pushl $57
80106932:	6a 39                	push   $0x39
  jmp alltraps
80106934:	e9 da f6 ff ff       	jmp    80106013 <alltraps>

80106939 <vector58>:
.globl vector58
vector58:
  pushl $0
80106939:	6a 00                	push   $0x0
  pushl $58
8010693b:	6a 3a                	push   $0x3a
  jmp alltraps
8010693d:	e9 d1 f6 ff ff       	jmp    80106013 <alltraps>

80106942 <vector59>:
.globl vector59
vector59:
  pushl $0
80106942:	6a 00                	push   $0x0
  pushl $59
80106944:	6a 3b                	push   $0x3b
  jmp alltraps
80106946:	e9 c8 f6 ff ff       	jmp    80106013 <alltraps>

8010694b <vector60>:
.globl vector60
vector60:
  pushl $0
8010694b:	6a 00                	push   $0x0
  pushl $60
8010694d:	6a 3c                	push   $0x3c
  jmp alltraps
8010694f:	e9 bf f6 ff ff       	jmp    80106013 <alltraps>

80106954 <vector61>:
.globl vector61
vector61:
  pushl $0
80106954:	6a 00                	push   $0x0
  pushl $61
80106956:	6a 3d                	push   $0x3d
  jmp alltraps
80106958:	e9 b6 f6 ff ff       	jmp    80106013 <alltraps>

8010695d <vector62>:
.globl vector62
vector62:
  pushl $0
8010695d:	6a 00                	push   $0x0
  pushl $62
8010695f:	6a 3e                	push   $0x3e
  jmp alltraps
80106961:	e9 ad f6 ff ff       	jmp    80106013 <alltraps>

80106966 <vector63>:
.globl vector63
vector63:
  pushl $0
80106966:	6a 00                	push   $0x0
  pushl $63
80106968:	6a 3f                	push   $0x3f
  jmp alltraps
8010696a:	e9 a4 f6 ff ff       	jmp    80106013 <alltraps>

8010696f <vector64>:
.globl vector64
vector64:
  pushl $0
8010696f:	6a 00                	push   $0x0
  pushl $64
80106971:	6a 40                	push   $0x40
  jmp alltraps
80106973:	e9 9b f6 ff ff       	jmp    80106013 <alltraps>

80106978 <vector65>:
.globl vector65
vector65:
  pushl $0
80106978:	6a 00                	push   $0x0
  pushl $65
8010697a:	6a 41                	push   $0x41
  jmp alltraps
8010697c:	e9 92 f6 ff ff       	jmp    80106013 <alltraps>

80106981 <vector66>:
.globl vector66
vector66:
  pushl $0
80106981:	6a 00                	push   $0x0
  pushl $66
80106983:	6a 42                	push   $0x42
  jmp alltraps
80106985:	e9 89 f6 ff ff       	jmp    80106013 <alltraps>

8010698a <vector67>:
.globl vector67
vector67:
  pushl $0
8010698a:	6a 00                	push   $0x0
  pushl $67
8010698c:	6a 43                	push   $0x43
  jmp alltraps
8010698e:	e9 80 f6 ff ff       	jmp    80106013 <alltraps>

80106993 <vector68>:
.globl vector68
vector68:
  pushl $0
80106993:	6a 00                	push   $0x0
  pushl $68
80106995:	6a 44                	push   $0x44
  jmp alltraps
80106997:	e9 77 f6 ff ff       	jmp    80106013 <alltraps>

8010699c <vector69>:
.globl vector69
vector69:
  pushl $0
8010699c:	6a 00                	push   $0x0
  pushl $69
8010699e:	6a 45                	push   $0x45
  jmp alltraps
801069a0:	e9 6e f6 ff ff       	jmp    80106013 <alltraps>

801069a5 <vector70>:
.globl vector70
vector70:
  pushl $0
801069a5:	6a 00                	push   $0x0
  pushl $70
801069a7:	6a 46                	push   $0x46
  jmp alltraps
801069a9:	e9 65 f6 ff ff       	jmp    80106013 <alltraps>

801069ae <vector71>:
.globl vector71
vector71:
  pushl $0
801069ae:	6a 00                	push   $0x0
  pushl $71
801069b0:	6a 47                	push   $0x47
  jmp alltraps
801069b2:	e9 5c f6 ff ff       	jmp    80106013 <alltraps>

801069b7 <vector72>:
.globl vector72
vector72:
  pushl $0
801069b7:	6a 00                	push   $0x0
  pushl $72
801069b9:	6a 48                	push   $0x48
  jmp alltraps
801069bb:	e9 53 f6 ff ff       	jmp    80106013 <alltraps>

801069c0 <vector73>:
.globl vector73
vector73:
  pushl $0
801069c0:	6a 00                	push   $0x0
  pushl $73
801069c2:	6a 49                	push   $0x49
  jmp alltraps
801069c4:	e9 4a f6 ff ff       	jmp    80106013 <alltraps>

801069c9 <vector74>:
.globl vector74
vector74:
  pushl $0
801069c9:	6a 00                	push   $0x0
  pushl $74
801069cb:	6a 4a                	push   $0x4a
  jmp alltraps
801069cd:	e9 41 f6 ff ff       	jmp    80106013 <alltraps>

801069d2 <vector75>:
.globl vector75
vector75:
  pushl $0
801069d2:	6a 00                	push   $0x0
  pushl $75
801069d4:	6a 4b                	push   $0x4b
  jmp alltraps
801069d6:	e9 38 f6 ff ff       	jmp    80106013 <alltraps>

801069db <vector76>:
.globl vector76
vector76:
  pushl $0
801069db:	6a 00                	push   $0x0
  pushl $76
801069dd:	6a 4c                	push   $0x4c
  jmp alltraps
801069df:	e9 2f f6 ff ff       	jmp    80106013 <alltraps>

801069e4 <vector77>:
.globl vector77
vector77:
  pushl $0
801069e4:	6a 00                	push   $0x0
  pushl $77
801069e6:	6a 4d                	push   $0x4d
  jmp alltraps
801069e8:	e9 26 f6 ff ff       	jmp    80106013 <alltraps>

801069ed <vector78>:
.globl vector78
vector78:
  pushl $0
801069ed:	6a 00                	push   $0x0
  pushl $78
801069ef:	6a 4e                	push   $0x4e
  jmp alltraps
801069f1:	e9 1d f6 ff ff       	jmp    80106013 <alltraps>

801069f6 <vector79>:
.globl vector79
vector79:
  pushl $0
801069f6:	6a 00                	push   $0x0
  pushl $79
801069f8:	6a 4f                	push   $0x4f
  jmp alltraps
801069fa:	e9 14 f6 ff ff       	jmp    80106013 <alltraps>

801069ff <vector80>:
.globl vector80
vector80:
  pushl $0
801069ff:	6a 00                	push   $0x0
  pushl $80
80106a01:	6a 50                	push   $0x50
  jmp alltraps
80106a03:	e9 0b f6 ff ff       	jmp    80106013 <alltraps>

80106a08 <vector81>:
.globl vector81
vector81:
  pushl $0
80106a08:	6a 00                	push   $0x0
  pushl $81
80106a0a:	6a 51                	push   $0x51
  jmp alltraps
80106a0c:	e9 02 f6 ff ff       	jmp    80106013 <alltraps>

80106a11 <vector82>:
.globl vector82
vector82:
  pushl $0
80106a11:	6a 00                	push   $0x0
  pushl $82
80106a13:	6a 52                	push   $0x52
  jmp alltraps
80106a15:	e9 f9 f5 ff ff       	jmp    80106013 <alltraps>

80106a1a <vector83>:
.globl vector83
vector83:
  pushl $0
80106a1a:	6a 00                	push   $0x0
  pushl $83
80106a1c:	6a 53                	push   $0x53
  jmp alltraps
80106a1e:	e9 f0 f5 ff ff       	jmp    80106013 <alltraps>

80106a23 <vector84>:
.globl vector84
vector84:
  pushl $0
80106a23:	6a 00                	push   $0x0
  pushl $84
80106a25:	6a 54                	push   $0x54
  jmp alltraps
80106a27:	e9 e7 f5 ff ff       	jmp    80106013 <alltraps>

80106a2c <vector85>:
.globl vector85
vector85:
  pushl $0
80106a2c:	6a 00                	push   $0x0
  pushl $85
80106a2e:	6a 55                	push   $0x55
  jmp alltraps
80106a30:	e9 de f5 ff ff       	jmp    80106013 <alltraps>

80106a35 <vector86>:
.globl vector86
vector86:
  pushl $0
80106a35:	6a 00                	push   $0x0
  pushl $86
80106a37:	6a 56                	push   $0x56
  jmp alltraps
80106a39:	e9 d5 f5 ff ff       	jmp    80106013 <alltraps>

80106a3e <vector87>:
.globl vector87
vector87:
  pushl $0
80106a3e:	6a 00                	push   $0x0
  pushl $87
80106a40:	6a 57                	push   $0x57
  jmp alltraps
80106a42:	e9 cc f5 ff ff       	jmp    80106013 <alltraps>

80106a47 <vector88>:
.globl vector88
vector88:
  pushl $0
80106a47:	6a 00                	push   $0x0
  pushl $88
80106a49:	6a 58                	push   $0x58
  jmp alltraps
80106a4b:	e9 c3 f5 ff ff       	jmp    80106013 <alltraps>

80106a50 <vector89>:
.globl vector89
vector89:
  pushl $0
80106a50:	6a 00                	push   $0x0
  pushl $89
80106a52:	6a 59                	push   $0x59
  jmp alltraps
80106a54:	e9 ba f5 ff ff       	jmp    80106013 <alltraps>

80106a59 <vector90>:
.globl vector90
vector90:
  pushl $0
80106a59:	6a 00                	push   $0x0
  pushl $90
80106a5b:	6a 5a                	push   $0x5a
  jmp alltraps
80106a5d:	e9 b1 f5 ff ff       	jmp    80106013 <alltraps>

80106a62 <vector91>:
.globl vector91
vector91:
  pushl $0
80106a62:	6a 00                	push   $0x0
  pushl $91
80106a64:	6a 5b                	push   $0x5b
  jmp alltraps
80106a66:	e9 a8 f5 ff ff       	jmp    80106013 <alltraps>

80106a6b <vector92>:
.globl vector92
vector92:
  pushl $0
80106a6b:	6a 00                	push   $0x0
  pushl $92
80106a6d:	6a 5c                	push   $0x5c
  jmp alltraps
80106a6f:	e9 9f f5 ff ff       	jmp    80106013 <alltraps>

80106a74 <vector93>:
.globl vector93
vector93:
  pushl $0
80106a74:	6a 00                	push   $0x0
  pushl $93
80106a76:	6a 5d                	push   $0x5d
  jmp alltraps
80106a78:	e9 96 f5 ff ff       	jmp    80106013 <alltraps>

80106a7d <vector94>:
.globl vector94
vector94:
  pushl $0
80106a7d:	6a 00                	push   $0x0
  pushl $94
80106a7f:	6a 5e                	push   $0x5e
  jmp alltraps
80106a81:	e9 8d f5 ff ff       	jmp    80106013 <alltraps>

80106a86 <vector95>:
.globl vector95
vector95:
  pushl $0
80106a86:	6a 00                	push   $0x0
  pushl $95
80106a88:	6a 5f                	push   $0x5f
  jmp alltraps
80106a8a:	e9 84 f5 ff ff       	jmp    80106013 <alltraps>

80106a8f <vector96>:
.globl vector96
vector96:
  pushl $0
80106a8f:	6a 00                	push   $0x0
  pushl $96
80106a91:	6a 60                	push   $0x60
  jmp alltraps
80106a93:	e9 7b f5 ff ff       	jmp    80106013 <alltraps>

80106a98 <vector97>:
.globl vector97
vector97:
  pushl $0
80106a98:	6a 00                	push   $0x0
  pushl $97
80106a9a:	6a 61                	push   $0x61
  jmp alltraps
80106a9c:	e9 72 f5 ff ff       	jmp    80106013 <alltraps>

80106aa1 <vector98>:
.globl vector98
vector98:
  pushl $0
80106aa1:	6a 00                	push   $0x0
  pushl $98
80106aa3:	6a 62                	push   $0x62
  jmp alltraps
80106aa5:	e9 69 f5 ff ff       	jmp    80106013 <alltraps>

80106aaa <vector99>:
.globl vector99
vector99:
  pushl $0
80106aaa:	6a 00                	push   $0x0
  pushl $99
80106aac:	6a 63                	push   $0x63
  jmp alltraps
80106aae:	e9 60 f5 ff ff       	jmp    80106013 <alltraps>

80106ab3 <vector100>:
.globl vector100
vector100:
  pushl $0
80106ab3:	6a 00                	push   $0x0
  pushl $100
80106ab5:	6a 64                	push   $0x64
  jmp alltraps
80106ab7:	e9 57 f5 ff ff       	jmp    80106013 <alltraps>

80106abc <vector101>:
.globl vector101
vector101:
  pushl $0
80106abc:	6a 00                	push   $0x0
  pushl $101
80106abe:	6a 65                	push   $0x65
  jmp alltraps
80106ac0:	e9 4e f5 ff ff       	jmp    80106013 <alltraps>

80106ac5 <vector102>:
.globl vector102
vector102:
  pushl $0
80106ac5:	6a 00                	push   $0x0
  pushl $102
80106ac7:	6a 66                	push   $0x66
  jmp alltraps
80106ac9:	e9 45 f5 ff ff       	jmp    80106013 <alltraps>

80106ace <vector103>:
.globl vector103
vector103:
  pushl $0
80106ace:	6a 00                	push   $0x0
  pushl $103
80106ad0:	6a 67                	push   $0x67
  jmp alltraps
80106ad2:	e9 3c f5 ff ff       	jmp    80106013 <alltraps>

80106ad7 <vector104>:
.globl vector104
vector104:
  pushl $0
80106ad7:	6a 00                	push   $0x0
  pushl $104
80106ad9:	6a 68                	push   $0x68
  jmp alltraps
80106adb:	e9 33 f5 ff ff       	jmp    80106013 <alltraps>

80106ae0 <vector105>:
.globl vector105
vector105:
  pushl $0
80106ae0:	6a 00                	push   $0x0
  pushl $105
80106ae2:	6a 69                	push   $0x69
  jmp alltraps
80106ae4:	e9 2a f5 ff ff       	jmp    80106013 <alltraps>

80106ae9 <vector106>:
.globl vector106
vector106:
  pushl $0
80106ae9:	6a 00                	push   $0x0
  pushl $106
80106aeb:	6a 6a                	push   $0x6a
  jmp alltraps
80106aed:	e9 21 f5 ff ff       	jmp    80106013 <alltraps>

80106af2 <vector107>:
.globl vector107
vector107:
  pushl $0
80106af2:	6a 00                	push   $0x0
  pushl $107
80106af4:	6a 6b                	push   $0x6b
  jmp alltraps
80106af6:	e9 18 f5 ff ff       	jmp    80106013 <alltraps>

80106afb <vector108>:
.globl vector108
vector108:
  pushl $0
80106afb:	6a 00                	push   $0x0
  pushl $108
80106afd:	6a 6c                	push   $0x6c
  jmp alltraps
80106aff:	e9 0f f5 ff ff       	jmp    80106013 <alltraps>

80106b04 <vector109>:
.globl vector109
vector109:
  pushl $0
80106b04:	6a 00                	push   $0x0
  pushl $109
80106b06:	6a 6d                	push   $0x6d
  jmp alltraps
80106b08:	e9 06 f5 ff ff       	jmp    80106013 <alltraps>

80106b0d <vector110>:
.globl vector110
vector110:
  pushl $0
80106b0d:	6a 00                	push   $0x0
  pushl $110
80106b0f:	6a 6e                	push   $0x6e
  jmp alltraps
80106b11:	e9 fd f4 ff ff       	jmp    80106013 <alltraps>

80106b16 <vector111>:
.globl vector111
vector111:
  pushl $0
80106b16:	6a 00                	push   $0x0
  pushl $111
80106b18:	6a 6f                	push   $0x6f
  jmp alltraps
80106b1a:	e9 f4 f4 ff ff       	jmp    80106013 <alltraps>

80106b1f <vector112>:
.globl vector112
vector112:
  pushl $0
80106b1f:	6a 00                	push   $0x0
  pushl $112
80106b21:	6a 70                	push   $0x70
  jmp alltraps
80106b23:	e9 eb f4 ff ff       	jmp    80106013 <alltraps>

80106b28 <vector113>:
.globl vector113
vector113:
  pushl $0
80106b28:	6a 00                	push   $0x0
  pushl $113
80106b2a:	6a 71                	push   $0x71
  jmp alltraps
80106b2c:	e9 e2 f4 ff ff       	jmp    80106013 <alltraps>

80106b31 <vector114>:
.globl vector114
vector114:
  pushl $0
80106b31:	6a 00                	push   $0x0
  pushl $114
80106b33:	6a 72                	push   $0x72
  jmp alltraps
80106b35:	e9 d9 f4 ff ff       	jmp    80106013 <alltraps>

80106b3a <vector115>:
.globl vector115
vector115:
  pushl $0
80106b3a:	6a 00                	push   $0x0
  pushl $115
80106b3c:	6a 73                	push   $0x73
  jmp alltraps
80106b3e:	e9 d0 f4 ff ff       	jmp    80106013 <alltraps>

80106b43 <vector116>:
.globl vector116
vector116:
  pushl $0
80106b43:	6a 00                	push   $0x0
  pushl $116
80106b45:	6a 74                	push   $0x74
  jmp alltraps
80106b47:	e9 c7 f4 ff ff       	jmp    80106013 <alltraps>

80106b4c <vector117>:
.globl vector117
vector117:
  pushl $0
80106b4c:	6a 00                	push   $0x0
  pushl $117
80106b4e:	6a 75                	push   $0x75
  jmp alltraps
80106b50:	e9 be f4 ff ff       	jmp    80106013 <alltraps>

80106b55 <vector118>:
.globl vector118
vector118:
  pushl $0
80106b55:	6a 00                	push   $0x0
  pushl $118
80106b57:	6a 76                	push   $0x76
  jmp alltraps
80106b59:	e9 b5 f4 ff ff       	jmp    80106013 <alltraps>

80106b5e <vector119>:
.globl vector119
vector119:
  pushl $0
80106b5e:	6a 00                	push   $0x0
  pushl $119
80106b60:	6a 77                	push   $0x77
  jmp alltraps
80106b62:	e9 ac f4 ff ff       	jmp    80106013 <alltraps>

80106b67 <vector120>:
.globl vector120
vector120:
  pushl $0
80106b67:	6a 00                	push   $0x0
  pushl $120
80106b69:	6a 78                	push   $0x78
  jmp alltraps
80106b6b:	e9 a3 f4 ff ff       	jmp    80106013 <alltraps>

80106b70 <vector121>:
.globl vector121
vector121:
  pushl $0
80106b70:	6a 00                	push   $0x0
  pushl $121
80106b72:	6a 79                	push   $0x79
  jmp alltraps
80106b74:	e9 9a f4 ff ff       	jmp    80106013 <alltraps>

80106b79 <vector122>:
.globl vector122
vector122:
  pushl $0
80106b79:	6a 00                	push   $0x0
  pushl $122
80106b7b:	6a 7a                	push   $0x7a
  jmp alltraps
80106b7d:	e9 91 f4 ff ff       	jmp    80106013 <alltraps>

80106b82 <vector123>:
.globl vector123
vector123:
  pushl $0
80106b82:	6a 00                	push   $0x0
  pushl $123
80106b84:	6a 7b                	push   $0x7b
  jmp alltraps
80106b86:	e9 88 f4 ff ff       	jmp    80106013 <alltraps>

80106b8b <vector124>:
.globl vector124
vector124:
  pushl $0
80106b8b:	6a 00                	push   $0x0
  pushl $124
80106b8d:	6a 7c                	push   $0x7c
  jmp alltraps
80106b8f:	e9 7f f4 ff ff       	jmp    80106013 <alltraps>

80106b94 <vector125>:
.globl vector125
vector125:
  pushl $0
80106b94:	6a 00                	push   $0x0
  pushl $125
80106b96:	6a 7d                	push   $0x7d
  jmp alltraps
80106b98:	e9 76 f4 ff ff       	jmp    80106013 <alltraps>

80106b9d <vector126>:
.globl vector126
vector126:
  pushl $0
80106b9d:	6a 00                	push   $0x0
  pushl $126
80106b9f:	6a 7e                	push   $0x7e
  jmp alltraps
80106ba1:	e9 6d f4 ff ff       	jmp    80106013 <alltraps>

80106ba6 <vector127>:
.globl vector127
vector127:
  pushl $0
80106ba6:	6a 00                	push   $0x0
  pushl $127
80106ba8:	6a 7f                	push   $0x7f
  jmp alltraps
80106baa:	e9 64 f4 ff ff       	jmp    80106013 <alltraps>

80106baf <vector128>:
.globl vector128
vector128:
  pushl $0
80106baf:	6a 00                	push   $0x0
  pushl $128
80106bb1:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106bb6:	e9 58 f4 ff ff       	jmp    80106013 <alltraps>

80106bbb <vector129>:
.globl vector129
vector129:
  pushl $0
80106bbb:	6a 00                	push   $0x0
  pushl $129
80106bbd:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106bc2:	e9 4c f4 ff ff       	jmp    80106013 <alltraps>

80106bc7 <vector130>:
.globl vector130
vector130:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $130
80106bc9:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106bce:	e9 40 f4 ff ff       	jmp    80106013 <alltraps>

80106bd3 <vector131>:
.globl vector131
vector131:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $131
80106bd5:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106bda:	e9 34 f4 ff ff       	jmp    80106013 <alltraps>

80106bdf <vector132>:
.globl vector132
vector132:
  pushl $0
80106bdf:	6a 00                	push   $0x0
  pushl $132
80106be1:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106be6:	e9 28 f4 ff ff       	jmp    80106013 <alltraps>

80106beb <vector133>:
.globl vector133
vector133:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $133
80106bed:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106bf2:	e9 1c f4 ff ff       	jmp    80106013 <alltraps>

80106bf7 <vector134>:
.globl vector134
vector134:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $134
80106bf9:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106bfe:	e9 10 f4 ff ff       	jmp    80106013 <alltraps>

80106c03 <vector135>:
.globl vector135
vector135:
  pushl $0
80106c03:	6a 00                	push   $0x0
  pushl $135
80106c05:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106c0a:	e9 04 f4 ff ff       	jmp    80106013 <alltraps>

80106c0f <vector136>:
.globl vector136
vector136:
  pushl $0
80106c0f:	6a 00                	push   $0x0
  pushl $136
80106c11:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106c16:	e9 f8 f3 ff ff       	jmp    80106013 <alltraps>

80106c1b <vector137>:
.globl vector137
vector137:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $137
80106c1d:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106c22:	e9 ec f3 ff ff       	jmp    80106013 <alltraps>

80106c27 <vector138>:
.globl vector138
vector138:
  pushl $0
80106c27:	6a 00                	push   $0x0
  pushl $138
80106c29:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106c2e:	e9 e0 f3 ff ff       	jmp    80106013 <alltraps>

80106c33 <vector139>:
.globl vector139
vector139:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $139
80106c35:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106c3a:	e9 d4 f3 ff ff       	jmp    80106013 <alltraps>

80106c3f <vector140>:
.globl vector140
vector140:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $140
80106c41:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106c46:	e9 c8 f3 ff ff       	jmp    80106013 <alltraps>

80106c4b <vector141>:
.globl vector141
vector141:
  pushl $0
80106c4b:	6a 00                	push   $0x0
  pushl $141
80106c4d:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106c52:	e9 bc f3 ff ff       	jmp    80106013 <alltraps>

80106c57 <vector142>:
.globl vector142
vector142:
  pushl $0
80106c57:	6a 00                	push   $0x0
  pushl $142
80106c59:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106c5e:	e9 b0 f3 ff ff       	jmp    80106013 <alltraps>

80106c63 <vector143>:
.globl vector143
vector143:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $143
80106c65:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106c6a:	e9 a4 f3 ff ff       	jmp    80106013 <alltraps>

80106c6f <vector144>:
.globl vector144
vector144:
  pushl $0
80106c6f:	6a 00                	push   $0x0
  pushl $144
80106c71:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106c76:	e9 98 f3 ff ff       	jmp    80106013 <alltraps>

80106c7b <vector145>:
.globl vector145
vector145:
  pushl $0
80106c7b:	6a 00                	push   $0x0
  pushl $145
80106c7d:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106c82:	e9 8c f3 ff ff       	jmp    80106013 <alltraps>

80106c87 <vector146>:
.globl vector146
vector146:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $146
80106c89:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106c8e:	e9 80 f3 ff ff       	jmp    80106013 <alltraps>

80106c93 <vector147>:
.globl vector147
vector147:
  pushl $0
80106c93:	6a 00                	push   $0x0
  pushl $147
80106c95:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106c9a:	e9 74 f3 ff ff       	jmp    80106013 <alltraps>

80106c9f <vector148>:
.globl vector148
vector148:
  pushl $0
80106c9f:	6a 00                	push   $0x0
  pushl $148
80106ca1:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106ca6:	e9 68 f3 ff ff       	jmp    80106013 <alltraps>

80106cab <vector149>:
.globl vector149
vector149:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $149
80106cad:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106cb2:	e9 5c f3 ff ff       	jmp    80106013 <alltraps>

80106cb7 <vector150>:
.globl vector150
vector150:
  pushl $0
80106cb7:	6a 00                	push   $0x0
  pushl $150
80106cb9:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106cbe:	e9 50 f3 ff ff       	jmp    80106013 <alltraps>

80106cc3 <vector151>:
.globl vector151
vector151:
  pushl $0
80106cc3:	6a 00                	push   $0x0
  pushl $151
80106cc5:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106cca:	e9 44 f3 ff ff       	jmp    80106013 <alltraps>

80106ccf <vector152>:
.globl vector152
vector152:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $152
80106cd1:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106cd6:	e9 38 f3 ff ff       	jmp    80106013 <alltraps>

80106cdb <vector153>:
.globl vector153
vector153:
  pushl $0
80106cdb:	6a 00                	push   $0x0
  pushl $153
80106cdd:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106ce2:	e9 2c f3 ff ff       	jmp    80106013 <alltraps>

80106ce7 <vector154>:
.globl vector154
vector154:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $154
80106ce9:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106cee:	e9 20 f3 ff ff       	jmp    80106013 <alltraps>

80106cf3 <vector155>:
.globl vector155
vector155:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $155
80106cf5:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106cfa:	e9 14 f3 ff ff       	jmp    80106013 <alltraps>

80106cff <vector156>:
.globl vector156
vector156:
  pushl $0
80106cff:	6a 00                	push   $0x0
  pushl $156
80106d01:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106d06:	e9 08 f3 ff ff       	jmp    80106013 <alltraps>

80106d0b <vector157>:
.globl vector157
vector157:
  pushl $0
80106d0b:	6a 00                	push   $0x0
  pushl $157
80106d0d:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106d12:	e9 fc f2 ff ff       	jmp    80106013 <alltraps>

80106d17 <vector158>:
.globl vector158
vector158:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $158
80106d19:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106d1e:	e9 f0 f2 ff ff       	jmp    80106013 <alltraps>

80106d23 <vector159>:
.globl vector159
vector159:
  pushl $0
80106d23:	6a 00                	push   $0x0
  pushl $159
80106d25:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106d2a:	e9 e4 f2 ff ff       	jmp    80106013 <alltraps>

80106d2f <vector160>:
.globl vector160
vector160:
  pushl $0
80106d2f:	6a 00                	push   $0x0
  pushl $160
80106d31:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106d36:	e9 d8 f2 ff ff       	jmp    80106013 <alltraps>

80106d3b <vector161>:
.globl vector161
vector161:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $161
80106d3d:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106d42:	e9 cc f2 ff ff       	jmp    80106013 <alltraps>

80106d47 <vector162>:
.globl vector162
vector162:
  pushl $0
80106d47:	6a 00                	push   $0x0
  pushl $162
80106d49:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106d4e:	e9 c0 f2 ff ff       	jmp    80106013 <alltraps>

80106d53 <vector163>:
.globl vector163
vector163:
  pushl $0
80106d53:	6a 00                	push   $0x0
  pushl $163
80106d55:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106d5a:	e9 b4 f2 ff ff       	jmp    80106013 <alltraps>

80106d5f <vector164>:
.globl vector164
vector164:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $164
80106d61:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106d66:	e9 a8 f2 ff ff       	jmp    80106013 <alltraps>

80106d6b <vector165>:
.globl vector165
vector165:
  pushl $0
80106d6b:	6a 00                	push   $0x0
  pushl $165
80106d6d:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106d72:	e9 9c f2 ff ff       	jmp    80106013 <alltraps>

80106d77 <vector166>:
.globl vector166
vector166:
  pushl $0
80106d77:	6a 00                	push   $0x0
  pushl $166
80106d79:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106d7e:	e9 90 f2 ff ff       	jmp    80106013 <alltraps>

80106d83 <vector167>:
.globl vector167
vector167:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $167
80106d85:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106d8a:	e9 84 f2 ff ff       	jmp    80106013 <alltraps>

80106d8f <vector168>:
.globl vector168
vector168:
  pushl $0
80106d8f:	6a 00                	push   $0x0
  pushl $168
80106d91:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106d96:	e9 78 f2 ff ff       	jmp    80106013 <alltraps>

80106d9b <vector169>:
.globl vector169
vector169:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $169
80106d9d:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106da2:	e9 6c f2 ff ff       	jmp    80106013 <alltraps>

80106da7 <vector170>:
.globl vector170
vector170:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $170
80106da9:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106dae:	e9 60 f2 ff ff       	jmp    80106013 <alltraps>

80106db3 <vector171>:
.globl vector171
vector171:
  pushl $0
80106db3:	6a 00                	push   $0x0
  pushl $171
80106db5:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106dba:	e9 54 f2 ff ff       	jmp    80106013 <alltraps>

80106dbf <vector172>:
.globl vector172
vector172:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $172
80106dc1:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106dc6:	e9 48 f2 ff ff       	jmp    80106013 <alltraps>

80106dcb <vector173>:
.globl vector173
vector173:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $173
80106dcd:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106dd2:	e9 3c f2 ff ff       	jmp    80106013 <alltraps>

80106dd7 <vector174>:
.globl vector174
vector174:
  pushl $0
80106dd7:	6a 00                	push   $0x0
  pushl $174
80106dd9:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106dde:	e9 30 f2 ff ff       	jmp    80106013 <alltraps>

80106de3 <vector175>:
.globl vector175
vector175:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $175
80106de5:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106dea:	e9 24 f2 ff ff       	jmp    80106013 <alltraps>

80106def <vector176>:
.globl vector176
vector176:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $176
80106df1:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106df6:	e9 18 f2 ff ff       	jmp    80106013 <alltraps>

80106dfb <vector177>:
.globl vector177
vector177:
  pushl $0
80106dfb:	6a 00                	push   $0x0
  pushl $177
80106dfd:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106e02:	e9 0c f2 ff ff       	jmp    80106013 <alltraps>

80106e07 <vector178>:
.globl vector178
vector178:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $178
80106e09:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106e0e:	e9 00 f2 ff ff       	jmp    80106013 <alltraps>

80106e13 <vector179>:
.globl vector179
vector179:
  pushl $0
80106e13:	6a 00                	push   $0x0
  pushl $179
80106e15:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106e1a:	e9 f4 f1 ff ff       	jmp    80106013 <alltraps>

80106e1f <vector180>:
.globl vector180
vector180:
  pushl $0
80106e1f:	6a 00                	push   $0x0
  pushl $180
80106e21:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106e26:	e9 e8 f1 ff ff       	jmp    80106013 <alltraps>

80106e2b <vector181>:
.globl vector181
vector181:
  pushl $0
80106e2b:	6a 00                	push   $0x0
  pushl $181
80106e2d:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106e32:	e9 dc f1 ff ff       	jmp    80106013 <alltraps>

80106e37 <vector182>:
.globl vector182
vector182:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $182
80106e39:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106e3e:	e9 d0 f1 ff ff       	jmp    80106013 <alltraps>

80106e43 <vector183>:
.globl vector183
vector183:
  pushl $0
80106e43:	6a 00                	push   $0x0
  pushl $183
80106e45:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106e4a:	e9 c4 f1 ff ff       	jmp    80106013 <alltraps>

80106e4f <vector184>:
.globl vector184
vector184:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $184
80106e51:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106e56:	e9 b8 f1 ff ff       	jmp    80106013 <alltraps>

80106e5b <vector185>:
.globl vector185
vector185:
  pushl $0
80106e5b:	6a 00                	push   $0x0
  pushl $185
80106e5d:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106e62:	e9 ac f1 ff ff       	jmp    80106013 <alltraps>

80106e67 <vector186>:
.globl vector186
vector186:
  pushl $0
80106e67:	6a 00                	push   $0x0
  pushl $186
80106e69:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106e6e:	e9 a0 f1 ff ff       	jmp    80106013 <alltraps>

80106e73 <vector187>:
.globl vector187
vector187:
  pushl $0
80106e73:	6a 00                	push   $0x0
  pushl $187
80106e75:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106e7a:	e9 94 f1 ff ff       	jmp    80106013 <alltraps>

80106e7f <vector188>:
.globl vector188
vector188:
  pushl $0
80106e7f:	6a 00                	push   $0x0
  pushl $188
80106e81:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106e86:	e9 88 f1 ff ff       	jmp    80106013 <alltraps>

80106e8b <vector189>:
.globl vector189
vector189:
  pushl $0
80106e8b:	6a 00                	push   $0x0
  pushl $189
80106e8d:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106e92:	e9 7c f1 ff ff       	jmp    80106013 <alltraps>

80106e97 <vector190>:
.globl vector190
vector190:
  pushl $0
80106e97:	6a 00                	push   $0x0
  pushl $190
80106e99:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106e9e:	e9 70 f1 ff ff       	jmp    80106013 <alltraps>

80106ea3 <vector191>:
.globl vector191
vector191:
  pushl $0
80106ea3:	6a 00                	push   $0x0
  pushl $191
80106ea5:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106eaa:	e9 64 f1 ff ff       	jmp    80106013 <alltraps>

80106eaf <vector192>:
.globl vector192
vector192:
  pushl $0
80106eaf:	6a 00                	push   $0x0
  pushl $192
80106eb1:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106eb6:	e9 58 f1 ff ff       	jmp    80106013 <alltraps>

80106ebb <vector193>:
.globl vector193
vector193:
  pushl $0
80106ebb:	6a 00                	push   $0x0
  pushl $193
80106ebd:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106ec2:	e9 4c f1 ff ff       	jmp    80106013 <alltraps>

80106ec7 <vector194>:
.globl vector194
vector194:
  pushl $0
80106ec7:	6a 00                	push   $0x0
  pushl $194
80106ec9:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106ece:	e9 40 f1 ff ff       	jmp    80106013 <alltraps>

80106ed3 <vector195>:
.globl vector195
vector195:
  pushl $0
80106ed3:	6a 00                	push   $0x0
  pushl $195
80106ed5:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106eda:	e9 34 f1 ff ff       	jmp    80106013 <alltraps>

80106edf <vector196>:
.globl vector196
vector196:
  pushl $0
80106edf:	6a 00                	push   $0x0
  pushl $196
80106ee1:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106ee6:	e9 28 f1 ff ff       	jmp    80106013 <alltraps>

80106eeb <vector197>:
.globl vector197
vector197:
  pushl $0
80106eeb:	6a 00                	push   $0x0
  pushl $197
80106eed:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106ef2:	e9 1c f1 ff ff       	jmp    80106013 <alltraps>

80106ef7 <vector198>:
.globl vector198
vector198:
  pushl $0
80106ef7:	6a 00                	push   $0x0
  pushl $198
80106ef9:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106efe:	e9 10 f1 ff ff       	jmp    80106013 <alltraps>

80106f03 <vector199>:
.globl vector199
vector199:
  pushl $0
80106f03:	6a 00                	push   $0x0
  pushl $199
80106f05:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106f0a:	e9 04 f1 ff ff       	jmp    80106013 <alltraps>

80106f0f <vector200>:
.globl vector200
vector200:
  pushl $0
80106f0f:	6a 00                	push   $0x0
  pushl $200
80106f11:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106f16:	e9 f8 f0 ff ff       	jmp    80106013 <alltraps>

80106f1b <vector201>:
.globl vector201
vector201:
  pushl $0
80106f1b:	6a 00                	push   $0x0
  pushl $201
80106f1d:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106f22:	e9 ec f0 ff ff       	jmp    80106013 <alltraps>

80106f27 <vector202>:
.globl vector202
vector202:
  pushl $0
80106f27:	6a 00                	push   $0x0
  pushl $202
80106f29:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106f2e:	e9 e0 f0 ff ff       	jmp    80106013 <alltraps>

80106f33 <vector203>:
.globl vector203
vector203:
  pushl $0
80106f33:	6a 00                	push   $0x0
  pushl $203
80106f35:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106f3a:	e9 d4 f0 ff ff       	jmp    80106013 <alltraps>

80106f3f <vector204>:
.globl vector204
vector204:
  pushl $0
80106f3f:	6a 00                	push   $0x0
  pushl $204
80106f41:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106f46:	e9 c8 f0 ff ff       	jmp    80106013 <alltraps>

80106f4b <vector205>:
.globl vector205
vector205:
  pushl $0
80106f4b:	6a 00                	push   $0x0
  pushl $205
80106f4d:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106f52:	e9 bc f0 ff ff       	jmp    80106013 <alltraps>

80106f57 <vector206>:
.globl vector206
vector206:
  pushl $0
80106f57:	6a 00                	push   $0x0
  pushl $206
80106f59:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106f5e:	e9 b0 f0 ff ff       	jmp    80106013 <alltraps>

80106f63 <vector207>:
.globl vector207
vector207:
  pushl $0
80106f63:	6a 00                	push   $0x0
  pushl $207
80106f65:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106f6a:	e9 a4 f0 ff ff       	jmp    80106013 <alltraps>

80106f6f <vector208>:
.globl vector208
vector208:
  pushl $0
80106f6f:	6a 00                	push   $0x0
  pushl $208
80106f71:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106f76:	e9 98 f0 ff ff       	jmp    80106013 <alltraps>

80106f7b <vector209>:
.globl vector209
vector209:
  pushl $0
80106f7b:	6a 00                	push   $0x0
  pushl $209
80106f7d:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106f82:	e9 8c f0 ff ff       	jmp    80106013 <alltraps>

80106f87 <vector210>:
.globl vector210
vector210:
  pushl $0
80106f87:	6a 00                	push   $0x0
  pushl $210
80106f89:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106f8e:	e9 80 f0 ff ff       	jmp    80106013 <alltraps>

80106f93 <vector211>:
.globl vector211
vector211:
  pushl $0
80106f93:	6a 00                	push   $0x0
  pushl $211
80106f95:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106f9a:	e9 74 f0 ff ff       	jmp    80106013 <alltraps>

80106f9f <vector212>:
.globl vector212
vector212:
  pushl $0
80106f9f:	6a 00                	push   $0x0
  pushl $212
80106fa1:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106fa6:	e9 68 f0 ff ff       	jmp    80106013 <alltraps>

80106fab <vector213>:
.globl vector213
vector213:
  pushl $0
80106fab:	6a 00                	push   $0x0
  pushl $213
80106fad:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106fb2:	e9 5c f0 ff ff       	jmp    80106013 <alltraps>

80106fb7 <vector214>:
.globl vector214
vector214:
  pushl $0
80106fb7:	6a 00                	push   $0x0
  pushl $214
80106fb9:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106fbe:	e9 50 f0 ff ff       	jmp    80106013 <alltraps>

80106fc3 <vector215>:
.globl vector215
vector215:
  pushl $0
80106fc3:	6a 00                	push   $0x0
  pushl $215
80106fc5:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106fca:	e9 44 f0 ff ff       	jmp    80106013 <alltraps>

80106fcf <vector216>:
.globl vector216
vector216:
  pushl $0
80106fcf:	6a 00                	push   $0x0
  pushl $216
80106fd1:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106fd6:	e9 38 f0 ff ff       	jmp    80106013 <alltraps>

80106fdb <vector217>:
.globl vector217
vector217:
  pushl $0
80106fdb:	6a 00                	push   $0x0
  pushl $217
80106fdd:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106fe2:	e9 2c f0 ff ff       	jmp    80106013 <alltraps>

80106fe7 <vector218>:
.globl vector218
vector218:
  pushl $0
80106fe7:	6a 00                	push   $0x0
  pushl $218
80106fe9:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106fee:	e9 20 f0 ff ff       	jmp    80106013 <alltraps>

80106ff3 <vector219>:
.globl vector219
vector219:
  pushl $0
80106ff3:	6a 00                	push   $0x0
  pushl $219
80106ff5:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106ffa:	e9 14 f0 ff ff       	jmp    80106013 <alltraps>

80106fff <vector220>:
.globl vector220
vector220:
  pushl $0
80106fff:	6a 00                	push   $0x0
  pushl $220
80107001:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107006:	e9 08 f0 ff ff       	jmp    80106013 <alltraps>

8010700b <vector221>:
.globl vector221
vector221:
  pushl $0
8010700b:	6a 00                	push   $0x0
  pushl $221
8010700d:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107012:	e9 fc ef ff ff       	jmp    80106013 <alltraps>

80107017 <vector222>:
.globl vector222
vector222:
  pushl $0
80107017:	6a 00                	push   $0x0
  pushl $222
80107019:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010701e:	e9 f0 ef ff ff       	jmp    80106013 <alltraps>

80107023 <vector223>:
.globl vector223
vector223:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $223
80107025:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010702a:	e9 e4 ef ff ff       	jmp    80106013 <alltraps>

8010702f <vector224>:
.globl vector224
vector224:
  pushl $0
8010702f:	6a 00                	push   $0x0
  pushl $224
80107031:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107036:	e9 d8 ef ff ff       	jmp    80106013 <alltraps>

8010703b <vector225>:
.globl vector225
vector225:
  pushl $0
8010703b:	6a 00                	push   $0x0
  pushl $225
8010703d:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107042:	e9 cc ef ff ff       	jmp    80106013 <alltraps>

80107047 <vector226>:
.globl vector226
vector226:
  pushl $0
80107047:	6a 00                	push   $0x0
  pushl $226
80107049:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010704e:	e9 c0 ef ff ff       	jmp    80106013 <alltraps>

80107053 <vector227>:
.globl vector227
vector227:
  pushl $0
80107053:	6a 00                	push   $0x0
  pushl $227
80107055:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010705a:	e9 b4 ef ff ff       	jmp    80106013 <alltraps>

8010705f <vector228>:
.globl vector228
vector228:
  pushl $0
8010705f:	6a 00                	push   $0x0
  pushl $228
80107061:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107066:	e9 a8 ef ff ff       	jmp    80106013 <alltraps>

8010706b <vector229>:
.globl vector229
vector229:
  pushl $0
8010706b:	6a 00                	push   $0x0
  pushl $229
8010706d:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107072:	e9 9c ef ff ff       	jmp    80106013 <alltraps>

80107077 <vector230>:
.globl vector230
vector230:
  pushl $0
80107077:	6a 00                	push   $0x0
  pushl $230
80107079:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010707e:	e9 90 ef ff ff       	jmp    80106013 <alltraps>

80107083 <vector231>:
.globl vector231
vector231:
  pushl $0
80107083:	6a 00                	push   $0x0
  pushl $231
80107085:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010708a:	e9 84 ef ff ff       	jmp    80106013 <alltraps>

8010708f <vector232>:
.globl vector232
vector232:
  pushl $0
8010708f:	6a 00                	push   $0x0
  pushl $232
80107091:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107096:	e9 78 ef ff ff       	jmp    80106013 <alltraps>

8010709b <vector233>:
.globl vector233
vector233:
  pushl $0
8010709b:	6a 00                	push   $0x0
  pushl $233
8010709d:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801070a2:	e9 6c ef ff ff       	jmp    80106013 <alltraps>

801070a7 <vector234>:
.globl vector234
vector234:
  pushl $0
801070a7:	6a 00                	push   $0x0
  pushl $234
801070a9:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801070ae:	e9 60 ef ff ff       	jmp    80106013 <alltraps>

801070b3 <vector235>:
.globl vector235
vector235:
  pushl $0
801070b3:	6a 00                	push   $0x0
  pushl $235
801070b5:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801070ba:	e9 54 ef ff ff       	jmp    80106013 <alltraps>

801070bf <vector236>:
.globl vector236
vector236:
  pushl $0
801070bf:	6a 00                	push   $0x0
  pushl $236
801070c1:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801070c6:	e9 48 ef ff ff       	jmp    80106013 <alltraps>

801070cb <vector237>:
.globl vector237
vector237:
  pushl $0
801070cb:	6a 00                	push   $0x0
  pushl $237
801070cd:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801070d2:	e9 3c ef ff ff       	jmp    80106013 <alltraps>

801070d7 <vector238>:
.globl vector238
vector238:
  pushl $0
801070d7:	6a 00                	push   $0x0
  pushl $238
801070d9:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801070de:	e9 30 ef ff ff       	jmp    80106013 <alltraps>

801070e3 <vector239>:
.globl vector239
vector239:
  pushl $0
801070e3:	6a 00                	push   $0x0
  pushl $239
801070e5:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801070ea:	e9 24 ef ff ff       	jmp    80106013 <alltraps>

801070ef <vector240>:
.globl vector240
vector240:
  pushl $0
801070ef:	6a 00                	push   $0x0
  pushl $240
801070f1:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801070f6:	e9 18 ef ff ff       	jmp    80106013 <alltraps>

801070fb <vector241>:
.globl vector241
vector241:
  pushl $0
801070fb:	6a 00                	push   $0x0
  pushl $241
801070fd:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107102:	e9 0c ef ff ff       	jmp    80106013 <alltraps>

80107107 <vector242>:
.globl vector242
vector242:
  pushl $0
80107107:	6a 00                	push   $0x0
  pushl $242
80107109:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010710e:	e9 00 ef ff ff       	jmp    80106013 <alltraps>

80107113 <vector243>:
.globl vector243
vector243:
  pushl $0
80107113:	6a 00                	push   $0x0
  pushl $243
80107115:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010711a:	e9 f4 ee ff ff       	jmp    80106013 <alltraps>

8010711f <vector244>:
.globl vector244
vector244:
  pushl $0
8010711f:	6a 00                	push   $0x0
  pushl $244
80107121:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107126:	e9 e8 ee ff ff       	jmp    80106013 <alltraps>

8010712b <vector245>:
.globl vector245
vector245:
  pushl $0
8010712b:	6a 00                	push   $0x0
  pushl $245
8010712d:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107132:	e9 dc ee ff ff       	jmp    80106013 <alltraps>

80107137 <vector246>:
.globl vector246
vector246:
  pushl $0
80107137:	6a 00                	push   $0x0
  pushl $246
80107139:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010713e:	e9 d0 ee ff ff       	jmp    80106013 <alltraps>

80107143 <vector247>:
.globl vector247
vector247:
  pushl $0
80107143:	6a 00                	push   $0x0
  pushl $247
80107145:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010714a:	e9 c4 ee ff ff       	jmp    80106013 <alltraps>

8010714f <vector248>:
.globl vector248
vector248:
  pushl $0
8010714f:	6a 00                	push   $0x0
  pushl $248
80107151:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107156:	e9 b8 ee ff ff       	jmp    80106013 <alltraps>

8010715b <vector249>:
.globl vector249
vector249:
  pushl $0
8010715b:	6a 00                	push   $0x0
  pushl $249
8010715d:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107162:	e9 ac ee ff ff       	jmp    80106013 <alltraps>

80107167 <vector250>:
.globl vector250
vector250:
  pushl $0
80107167:	6a 00                	push   $0x0
  pushl $250
80107169:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010716e:	e9 a0 ee ff ff       	jmp    80106013 <alltraps>

80107173 <vector251>:
.globl vector251
vector251:
  pushl $0
80107173:	6a 00                	push   $0x0
  pushl $251
80107175:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010717a:	e9 94 ee ff ff       	jmp    80106013 <alltraps>

8010717f <vector252>:
.globl vector252
vector252:
  pushl $0
8010717f:	6a 00                	push   $0x0
  pushl $252
80107181:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107186:	e9 88 ee ff ff       	jmp    80106013 <alltraps>

8010718b <vector253>:
.globl vector253
vector253:
  pushl $0
8010718b:	6a 00                	push   $0x0
  pushl $253
8010718d:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107192:	e9 7c ee ff ff       	jmp    80106013 <alltraps>

80107197 <vector254>:
.globl vector254
vector254:
  pushl $0
80107197:	6a 00                	push   $0x0
  pushl $254
80107199:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010719e:	e9 70 ee ff ff       	jmp    80106013 <alltraps>

801071a3 <vector255>:
.globl vector255
vector255:
  pushl $0
801071a3:	6a 00                	push   $0x0
  pushl $255
801071a5:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801071aa:	e9 64 ee ff ff       	jmp    80106013 <alltraps>

801071af <lgdt>:
{
801071af:	55                   	push   %ebp
801071b0:	89 e5                	mov    %esp,%ebp
801071b2:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801071b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801071b8:	83 e8 01             	sub    $0x1,%eax
801071bb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801071bf:	8b 45 08             	mov    0x8(%ebp),%eax
801071c2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801071c6:	8b 45 08             	mov    0x8(%ebp),%eax
801071c9:	c1 e8 10             	shr    $0x10,%eax
801071cc:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801071d0:	8d 45 fa             	lea    -0x6(%ebp),%eax
801071d3:	0f 01 10             	lgdtl  (%eax)
}
801071d6:	90                   	nop
801071d7:	c9                   	leave
801071d8:	c3                   	ret

801071d9 <ltr>:
{
801071d9:	55                   	push   %ebp
801071da:	89 e5                	mov    %esp,%ebp
801071dc:	83 ec 04             	sub    $0x4,%esp
801071df:	8b 45 08             	mov    0x8(%ebp),%eax
801071e2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801071e6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801071ea:	0f 00 d8             	ltr    %eax
}
801071ed:	90                   	nop
801071ee:	c9                   	leave
801071ef:	c3                   	ret

801071f0 <lcr3>:

static inline void
lcr3(uint val)
{
801071f0:	55                   	push   %ebp
801071f1:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801071f3:	8b 45 08             	mov    0x8(%ebp),%eax
801071f6:	0f 22 d8             	mov    %eax,%cr3
}
801071f9:	90                   	nop
801071fa:	5d                   	pop    %ebp
801071fb:	c3                   	ret

801071fc <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801071fc:	55                   	push   %ebp
801071fd:	89 e5                	mov    %esp,%ebp
801071ff:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107202:	e8 f3 c7 ff ff       	call   801039fa <cpuid>
80107207:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010720d:	05 80 6a 19 80       	add    $0x80196a80,%eax
80107212:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107218:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010721e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107221:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107227:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010722a:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010722e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107231:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107235:	83 e2 f0             	and    $0xfffffff0,%edx
80107238:	83 ca 0a             	or     $0xa,%edx
8010723b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010723e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107241:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107245:	83 ca 10             	or     $0x10,%edx
80107248:	88 50 7d             	mov    %dl,0x7d(%eax)
8010724b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010724e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107252:	83 e2 9f             	and    $0xffffff9f,%edx
80107255:	88 50 7d             	mov    %dl,0x7d(%eax)
80107258:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010725b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010725f:	83 ca 80             	or     $0xffffff80,%edx
80107262:	88 50 7d             	mov    %dl,0x7d(%eax)
80107265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107268:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010726c:	83 ca 0f             	or     $0xf,%edx
8010726f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107272:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107275:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107279:	83 e2 ef             	and    $0xffffffef,%edx
8010727c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010727f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107282:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107286:	83 e2 df             	and    $0xffffffdf,%edx
80107289:	88 50 7e             	mov    %dl,0x7e(%eax)
8010728c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010728f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107293:	83 ca 40             	or     $0x40,%edx
80107296:	88 50 7e             	mov    %dl,0x7e(%eax)
80107299:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010729c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801072a0:	83 ca 80             	or     $0xffffff80,%edx
801072a3:	88 50 7e             	mov    %dl,0x7e(%eax)
801072a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a9:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801072ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b0:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801072b7:	ff ff 
801072b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072bc:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801072c3:	00 00 
801072c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c8:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801072cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072d2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801072d9:	83 e2 f0             	and    $0xfffffff0,%edx
801072dc:	83 ca 02             	or     $0x2,%edx
801072df:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801072e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072e8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801072ef:	83 ca 10             	or     $0x10,%edx
801072f2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801072f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072fb:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107302:	83 e2 9f             	and    $0xffffff9f,%edx
80107305:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010730b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010730e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107315:	83 ca 80             	or     $0xffffff80,%edx
80107318:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010731e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107321:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107328:	83 ca 0f             	or     $0xf,%edx
8010732b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107334:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010733b:	83 e2 ef             	and    $0xffffffef,%edx
8010733e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107347:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010734e:	83 e2 df             	and    $0xffffffdf,%edx
80107351:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010735a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107361:	83 ca 40             	or     $0x40,%edx
80107364:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010736a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010736d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107374:	83 ca 80             	or     $0xffffff80,%edx
80107377:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010737d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107380:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107387:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010738a:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107391:	ff ff 
80107393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107396:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
8010739d:	00 00 
8010739f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a2:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801073a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ac:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801073b3:	83 e2 f0             	and    $0xfffffff0,%edx
801073b6:	83 ca 0a             	or     $0xa,%edx
801073b9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801073bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801073c9:	83 ca 10             	or     $0x10,%edx
801073cc:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801073d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d5:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801073dc:	83 ca 60             	or     $0x60,%edx
801073df:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801073e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e8:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801073ef:	83 ca 80             	or     $0xffffff80,%edx
801073f2:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801073f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073fb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107402:	83 ca 0f             	or     $0xf,%edx
80107405:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010740b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010740e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107415:	83 e2 ef             	and    $0xffffffef,%edx
80107418:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010741e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107421:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107428:	83 e2 df             	and    $0xffffffdf,%edx
8010742b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107434:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010743b:	83 ca 40             	or     $0x40,%edx
8010743e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107447:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010744e:	83 ca 80             	or     $0xffffff80,%edx
80107451:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010745a:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107464:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010746b:	ff ff 
8010746d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107470:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107477:	00 00 
80107479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747c:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107486:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010748d:	83 e2 f0             	and    $0xfffffff0,%edx
80107490:	83 ca 02             	or     $0x2,%edx
80107493:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010749c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801074a3:	83 ca 10             	or     $0x10,%edx
801074a6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801074ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074af:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801074b6:	83 ca 60             	or     $0x60,%edx
801074b9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801074bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801074c9:	83 ca 80             	or     $0xffffff80,%edx
801074cc:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801074d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801074dc:	83 ca 0f             	or     $0xf,%edx
801074df:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801074e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801074ef:	83 e2 ef             	and    $0xffffffef,%edx
801074f2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801074f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074fb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107502:	83 e2 df             	and    $0xffffffdf,%edx
80107505:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010750b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010750e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107515:	83 ca 40             	or     $0x40,%edx
80107518:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010751e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107521:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107528:	83 ca 80             	or     $0xffffff80,%edx
8010752b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107534:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010753b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753e:	83 c0 70             	add    $0x70,%eax
80107541:	83 ec 08             	sub    $0x8,%esp
80107544:	6a 30                	push   $0x30
80107546:	50                   	push   %eax
80107547:	e8 63 fc ff ff       	call   801071af <lgdt>
8010754c:	83 c4 10             	add    $0x10,%esp
}
8010754f:	90                   	nop
80107550:	c9                   	leave
80107551:	c3                   	ret

80107552 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
/*static 전역에서 사용해야 함*/ pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107552:	55                   	push   %ebp
80107553:	89 e5                	mov    %esp,%ebp
80107555:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107558:	8b 45 0c             	mov    0xc(%ebp),%eax
8010755b:	c1 e8 16             	shr    $0x16,%eax
8010755e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107565:	8b 45 08             	mov    0x8(%ebp),%eax
80107568:	01 d0                	add    %edx,%eax
8010756a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010756d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107570:	8b 00                	mov    (%eax),%eax
80107572:	83 e0 01             	and    $0x1,%eax
80107575:	85 c0                	test   %eax,%eax
80107577:	74 14                	je     8010758d <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107579:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010757c:	8b 00                	mov    (%eax),%eax
8010757e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107583:	05 00 00 00 80       	add    $0x80000000,%eax
80107588:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010758b:	eb 42                	jmp    801075cf <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010758d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107591:	74 0e                	je     801075a1 <walkpgdir+0x4f>
80107593:	e8 6d b2 ff ff       	call   80102805 <kalloc>
80107598:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010759b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010759f:	75 07                	jne    801075a8 <walkpgdir+0x56>
      return 0;
801075a1:	b8 00 00 00 00       	mov    $0x0,%eax
801075a6:	eb 3e                	jmp    801075e6 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801075a8:	83 ec 04             	sub    $0x4,%esp
801075ab:	68 00 10 00 00       	push   $0x1000
801075b0:	6a 00                	push   $0x0
801075b2:	ff 75 f4             	push   -0xc(%ebp)
801075b5:	e8 7d d5 ff ff       	call   80104b37 <memset>
801075ba:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801075bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c0:	05 00 00 00 80       	add    $0x80000000,%eax
801075c5:	83 c8 07             	or     $0x7,%eax
801075c8:	89 c2                	mov    %eax,%edx
801075ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801075cd:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801075cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801075d2:	c1 e8 0c             	shr    $0xc,%eax
801075d5:	25 ff 03 00 00       	and    $0x3ff,%eax
801075da:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801075e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e4:	01 d0                	add    %edx,%eax
}
801075e6:	c9                   	leave
801075e7:	c3                   	ret

801075e8 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
/*static 전역에서 사용해야 함*/ int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801075e8:	55                   	push   %ebp
801075e9:	89 e5                	mov    %esp,%ebp
801075eb:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801075ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801075f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801075f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801075f9:	8b 55 0c             	mov    0xc(%ebp),%edx
801075fc:	8b 45 10             	mov    0x10(%ebp),%eax
801075ff:	01 d0                	add    %edx,%eax
80107601:	83 e8 01             	sub    $0x1,%eax
80107604:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107609:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010760c:	83 ec 04             	sub    $0x4,%esp
8010760f:	6a 01                	push   $0x1
80107611:	ff 75 f4             	push   -0xc(%ebp)
80107614:	ff 75 08             	push   0x8(%ebp)
80107617:	e8 36 ff ff ff       	call   80107552 <walkpgdir>
8010761c:	83 c4 10             	add    $0x10,%esp
8010761f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107622:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107626:	75 07                	jne    8010762f <mappages+0x47>
      return -1;
80107628:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010762d:	eb 47                	jmp    80107676 <mappages+0x8e>
    if(*pte & PTE_P)
8010762f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107632:	8b 00                	mov    (%eax),%eax
80107634:	83 e0 01             	and    $0x1,%eax
80107637:	85 c0                	test   %eax,%eax
80107639:	74 0d                	je     80107648 <mappages+0x60>
      panic("remap");
8010763b:	83 ec 0c             	sub    $0xc,%esp
8010763e:	68 94 aa 10 80       	push   $0x8010aa94
80107643:	e8 79 8f ff ff       	call   801005c1 <panic>
    *pte = pa | perm | PTE_P;
80107648:	8b 45 18             	mov    0x18(%ebp),%eax
8010764b:	0b 45 14             	or     0x14(%ebp),%eax
8010764e:	83 c8 01             	or     $0x1,%eax
80107651:	89 c2                	mov    %eax,%edx
80107653:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107656:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010765b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010765e:	74 10                	je     80107670 <mappages+0x88>
      break;
    a += PGSIZE;
80107660:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107667:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010766e:	eb 9c                	jmp    8010760c <mappages+0x24>
      break;
80107670:	90                   	nop
  }
  return 0;
80107671:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107676:	c9                   	leave
80107677:	c3                   	ret

80107678 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107678:	55                   	push   %ebp
80107679:	89 e5                	mov    %esp,%ebp
8010767b:	53                   	push   %ebx
8010767c:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
8010767f:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107686:	a1 40 6b 19 80       	mov    0x80196b40,%eax
8010768b:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107690:	29 c2                	sub    %eax,%edx
80107692:	89 d0                	mov    %edx,%eax
80107694:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107697:	a1 38 6b 19 80       	mov    0x80196b38,%eax
8010769c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010769f:	8b 15 38 6b 19 80    	mov    0x80196b38,%edx
801076a5:	a1 40 6b 19 80       	mov    0x80196b40,%eax
801076aa:	01 d0                	add    %edx,%eax
801076ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
801076af:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
801076b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b9:	83 c0 30             	add    $0x30,%eax
801076bc:	8b 55 e0             	mov    -0x20(%ebp),%edx
801076bf:	89 10                	mov    %edx,(%eax)
801076c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801076c4:	89 50 04             	mov    %edx,0x4(%eax)
801076c7:	8b 55 e8             	mov    -0x18(%ebp),%edx
801076ca:	89 50 08             	mov    %edx,0x8(%eax)
801076cd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801076d0:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
801076d3:	e8 2d b1 ff ff       	call   80102805 <kalloc>
801076d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801076db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801076df:	75 07                	jne    801076e8 <setupkvm+0x70>
    return 0;
801076e1:	b8 00 00 00 00       	mov    $0x0,%eax
801076e6:	eb 78                	jmp    80107760 <setupkvm+0xe8>
  }
  memset(pgdir, 0, PGSIZE);
801076e8:	83 ec 04             	sub    $0x4,%esp
801076eb:	68 00 10 00 00       	push   $0x1000
801076f0:	6a 00                	push   $0x0
801076f2:	ff 75 f0             	push   -0x10(%ebp)
801076f5:	e8 3d d4 ff ff       	call   80104b37 <memset>
801076fa:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801076fd:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107704:	eb 4e                	jmp    80107754 <setupkvm+0xdc>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107709:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010770c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010770f:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107715:	8b 58 08             	mov    0x8(%eax),%ebx
80107718:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771b:	8b 40 04             	mov    0x4(%eax),%eax
8010771e:	29 c3                	sub    %eax,%ebx
80107720:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107723:	8b 00                	mov    (%eax),%eax
80107725:	83 ec 0c             	sub    $0xc,%esp
80107728:	51                   	push   %ecx
80107729:	52                   	push   %edx
8010772a:	53                   	push   %ebx
8010772b:	50                   	push   %eax
8010772c:	ff 75 f0             	push   -0x10(%ebp)
8010772f:	e8 b4 fe ff ff       	call   801075e8 <mappages>
80107734:	83 c4 20             	add    $0x20,%esp
80107737:	85 c0                	test   %eax,%eax
80107739:	79 15                	jns    80107750 <setupkvm+0xd8>
      freevm(pgdir);
8010773b:	83 ec 0c             	sub    $0xc,%esp
8010773e:	ff 75 f0             	push   -0x10(%ebp)
80107741:	e8 f5 04 00 00       	call   80107c3b <freevm>
80107746:	83 c4 10             	add    $0x10,%esp
      return 0;
80107749:	b8 00 00 00 00       	mov    $0x0,%eax
8010774e:	eb 10                	jmp    80107760 <setupkvm+0xe8>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107750:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107754:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
8010775b:	72 a9                	jb     80107706 <setupkvm+0x8e>
    }
  return pgdir;
8010775d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107760:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107763:	c9                   	leave
80107764:	c3                   	ret

80107765 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107765:	55                   	push   %ebp
80107766:	89 e5                	mov    %esp,%ebp
80107768:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010776b:	e8 08 ff ff ff       	call   80107678 <setupkvm>
80107770:	a3 7c 6a 19 80       	mov    %eax,0x80196a7c
  switchkvm();
80107775:	e8 03 00 00 00       	call   8010777d <switchkvm>
}
8010777a:	90                   	nop
8010777b:	c9                   	leave
8010777c:	c3                   	ret

8010777d <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010777d:	55                   	push   %ebp
8010777e:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107780:	a1 7c 6a 19 80       	mov    0x80196a7c,%eax
80107785:	05 00 00 00 80       	add    $0x80000000,%eax
8010778a:	50                   	push   %eax
8010778b:	e8 60 fa ff ff       	call   801071f0 <lcr3>
80107790:	83 c4 04             	add    $0x4,%esp
}
80107793:	90                   	nop
80107794:	c9                   	leave
80107795:	c3                   	ret

80107796 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107796:	55                   	push   %ebp
80107797:	89 e5                	mov    %esp,%ebp
80107799:	56                   	push   %esi
8010779a:	53                   	push   %ebx
8010779b:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
8010779e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801077a2:	75 0d                	jne    801077b1 <switchuvm+0x1b>
    panic("switchuvm: no process");
801077a4:	83 ec 0c             	sub    $0xc,%esp
801077a7:	68 9a aa 10 80       	push   $0x8010aa9a
801077ac:	e8 10 8e ff ff       	call   801005c1 <panic>
  if(p->kstack == 0)
801077b1:	8b 45 08             	mov    0x8(%ebp),%eax
801077b4:	8b 40 08             	mov    0x8(%eax),%eax
801077b7:	85 c0                	test   %eax,%eax
801077b9:	75 0d                	jne    801077c8 <switchuvm+0x32>
    panic("switchuvm: no kstack");
801077bb:	83 ec 0c             	sub    $0xc,%esp
801077be:	68 b0 aa 10 80       	push   $0x8010aab0
801077c3:	e8 f9 8d ff ff       	call   801005c1 <panic>
  if(p->pgdir == 0)
801077c8:	8b 45 08             	mov    0x8(%ebp),%eax
801077cb:	8b 40 04             	mov    0x4(%eax),%eax
801077ce:	85 c0                	test   %eax,%eax
801077d0:	75 0d                	jne    801077df <switchuvm+0x49>
    panic("switchuvm: no pgdir");
801077d2:	83 ec 0c             	sub    $0xc,%esp
801077d5:	68 c5 aa 10 80       	push   $0x8010aac5
801077da:	e8 e2 8d ff ff       	call   801005c1 <panic>

  pushcli();
801077df:	e8 48 d2 ff ff       	call   80104a2c <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801077e4:	e8 2c c2 ff ff       	call   80103a15 <mycpu>
801077e9:	89 c3                	mov    %eax,%ebx
801077eb:	e8 25 c2 ff ff       	call   80103a15 <mycpu>
801077f0:	83 c0 08             	add    $0x8,%eax
801077f3:	89 c6                	mov    %eax,%esi
801077f5:	e8 1b c2 ff ff       	call   80103a15 <mycpu>
801077fa:	83 c0 08             	add    $0x8,%eax
801077fd:	c1 e8 10             	shr    $0x10,%eax
80107800:	88 45 f7             	mov    %al,-0x9(%ebp)
80107803:	e8 0d c2 ff ff       	call   80103a15 <mycpu>
80107808:	83 c0 08             	add    $0x8,%eax
8010780b:	c1 e8 18             	shr    $0x18,%eax
8010780e:	89 c2                	mov    %eax,%edx
80107810:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107817:	67 00 
80107819:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107820:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107824:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
8010782a:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107831:	83 e0 f0             	and    $0xfffffff0,%eax
80107834:	83 c8 09             	or     $0x9,%eax
80107837:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010783d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107844:	83 c8 10             	or     $0x10,%eax
80107847:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010784d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107854:	83 e0 9f             	and    $0xffffff9f,%eax
80107857:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010785d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107864:	83 c8 80             	or     $0xffffff80,%eax
80107867:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010786d:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107874:	83 e0 f0             	and    $0xfffffff0,%eax
80107877:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010787d:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107884:	83 e0 ef             	and    $0xffffffef,%eax
80107887:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010788d:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107894:	83 e0 df             	and    $0xffffffdf,%eax
80107897:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010789d:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801078a4:	83 c8 40             	or     $0x40,%eax
801078a7:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801078ad:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801078b4:	83 e0 7f             	and    $0x7f,%eax
801078b7:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801078bd:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801078c3:	e8 4d c1 ff ff       	call   80103a15 <mycpu>
801078c8:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801078cf:	83 e2 ef             	and    $0xffffffef,%edx
801078d2:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801078d8:	e8 38 c1 ff ff       	call   80103a15 <mycpu>
801078dd:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801078e3:	8b 45 08             	mov    0x8(%ebp),%eax
801078e6:	8b 40 08             	mov    0x8(%eax),%eax
801078e9:	89 c3                	mov    %eax,%ebx
801078eb:	e8 25 c1 ff ff       	call   80103a15 <mycpu>
801078f0:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801078f6:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801078f9:	e8 17 c1 ff ff       	call   80103a15 <mycpu>
801078fe:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107904:	83 ec 0c             	sub    $0xc,%esp
80107907:	6a 28                	push   $0x28
80107909:	e8 cb f8 ff ff       	call   801071d9 <ltr>
8010790e:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107911:	8b 45 08             	mov    0x8(%ebp),%eax
80107914:	8b 40 04             	mov    0x4(%eax),%eax
80107917:	05 00 00 00 80       	add    $0x80000000,%eax
8010791c:	83 ec 0c             	sub    $0xc,%esp
8010791f:	50                   	push   %eax
80107920:	e8 cb f8 ff ff       	call   801071f0 <lcr3>
80107925:	83 c4 10             	add    $0x10,%esp
  popcli();
80107928:	e8 4c d1 ff ff       	call   80104a79 <popcli>
}
8010792d:	90                   	nop
8010792e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107931:	5b                   	pop    %ebx
80107932:	5e                   	pop    %esi
80107933:	5d                   	pop    %ebp
80107934:	c3                   	ret

80107935 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107935:	55                   	push   %ebp
80107936:	89 e5                	mov    %esp,%ebp
80107938:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010793b:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107942:	76 0d                	jbe    80107951 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107944:	83 ec 0c             	sub    $0xc,%esp
80107947:	68 d9 aa 10 80       	push   $0x8010aad9
8010794c:	e8 70 8c ff ff       	call   801005c1 <panic>
  mem = kalloc();
80107951:	e8 af ae ff ff       	call   80102805 <kalloc>
80107956:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107959:	83 ec 04             	sub    $0x4,%esp
8010795c:	68 00 10 00 00       	push   $0x1000
80107961:	6a 00                	push   $0x0
80107963:	ff 75 f4             	push   -0xc(%ebp)
80107966:	e8 cc d1 ff ff       	call   80104b37 <memset>
8010796b:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010796e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107971:	05 00 00 00 80       	add    $0x80000000,%eax
80107976:	83 ec 0c             	sub    $0xc,%esp
80107979:	6a 06                	push   $0x6
8010797b:	50                   	push   %eax
8010797c:	68 00 10 00 00       	push   $0x1000
80107981:	6a 00                	push   $0x0
80107983:	ff 75 08             	push   0x8(%ebp)
80107986:	e8 5d fc ff ff       	call   801075e8 <mappages>
8010798b:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010798e:	83 ec 04             	sub    $0x4,%esp
80107991:	ff 75 10             	push   0x10(%ebp)
80107994:	ff 75 0c             	push   0xc(%ebp)
80107997:	ff 75 f4             	push   -0xc(%ebp)
8010799a:	e8 57 d2 ff ff       	call   80104bf6 <memmove>
8010799f:	83 c4 10             	add    $0x10,%esp
}
801079a2:	90                   	nop
801079a3:	c9                   	leave
801079a4:	c3                   	ret

801079a5 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801079a5:	55                   	push   %ebp
801079a6:	89 e5                	mov    %esp,%ebp
801079a8:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801079ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801079ae:	25 ff 0f 00 00       	and    $0xfff,%eax
801079b3:	85 c0                	test   %eax,%eax
801079b5:	74 0d                	je     801079c4 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801079b7:	83 ec 0c             	sub    $0xc,%esp
801079ba:	68 f4 aa 10 80       	push   $0x8010aaf4
801079bf:	e8 fd 8b ff ff       	call   801005c1 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801079c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079cb:	e9 8f 00 00 00       	jmp    80107a5f <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801079d0:	8b 55 0c             	mov    0xc(%ebp),%edx
801079d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d6:	01 d0                	add    %edx,%eax
801079d8:	83 ec 04             	sub    $0x4,%esp
801079db:	6a 00                	push   $0x0
801079dd:	50                   	push   %eax
801079de:	ff 75 08             	push   0x8(%ebp)
801079e1:	e8 6c fb ff ff       	call   80107552 <walkpgdir>
801079e6:	83 c4 10             	add    $0x10,%esp
801079e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801079ec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801079f0:	75 0d                	jne    801079ff <loaduvm+0x5a>
      panic("loaduvm: address should exist");
801079f2:	83 ec 0c             	sub    $0xc,%esp
801079f5:	68 17 ab 10 80       	push   $0x8010ab17
801079fa:	e8 c2 8b ff ff       	call   801005c1 <panic>
    pa = PTE_ADDR(*pte);
801079ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a02:	8b 00                	mov    (%eax),%eax
80107a04:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a09:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107a0c:	8b 45 18             	mov    0x18(%ebp),%eax
80107a0f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107a12:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107a17:	77 0b                	ja     80107a24 <loaduvm+0x7f>
      n = sz - i;
80107a19:	8b 45 18             	mov    0x18(%ebp),%eax
80107a1c:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107a1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a22:	eb 07                	jmp    80107a2b <loaduvm+0x86>
    else
      n = PGSIZE;
80107a24:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107a2b:	8b 55 14             	mov    0x14(%ebp),%edx
80107a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a31:	01 d0                	add    %edx,%eax
80107a33:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107a36:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107a3c:	ff 75 f0             	push   -0x10(%ebp)
80107a3f:	50                   	push   %eax
80107a40:	52                   	push   %edx
80107a41:	ff 75 10             	push   0x10(%ebp)
80107a44:	e8 f2 a4 ff ff       	call   80101f3b <readi>
80107a49:	83 c4 10             	add    $0x10,%esp
80107a4c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107a4f:	74 07                	je     80107a58 <loaduvm+0xb3>
      return -1;
80107a51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a56:	eb 18                	jmp    80107a70 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107a58:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a62:	3b 45 18             	cmp    0x18(%ebp),%eax
80107a65:	0f 82 65 ff ff ff    	jb     801079d0 <loaduvm+0x2b>
  }
  return 0;
80107a6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a70:	c9                   	leave
80107a71:	c3                   	ret

80107a72 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107a72:	55                   	push   %ebp
80107a73:	89 e5                	mov    %esp,%ebp
80107a75:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107a78:	8b 45 10             	mov    0x10(%ebp),%eax
80107a7b:	85 c0                	test   %eax,%eax
80107a7d:	79 0a                	jns    80107a89 <allocuvm+0x17>
    return 0;
80107a7f:	b8 00 00 00 00       	mov    $0x0,%eax
80107a84:	e9 ec 00 00 00       	jmp    80107b75 <allocuvm+0x103>
  if(newsz < oldsz)
80107a89:	8b 45 10             	mov    0x10(%ebp),%eax
80107a8c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107a8f:	73 08                	jae    80107a99 <allocuvm+0x27>
    return oldsz;
80107a91:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a94:	e9 dc 00 00 00       	jmp    80107b75 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107a99:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a9c:	05 ff 0f 00 00       	add    $0xfff,%eax
80107aa1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107aa6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107aa9:	e9 b8 00 00 00       	jmp    80107b66 <allocuvm+0xf4>
    mem = kalloc();
80107aae:	e8 52 ad ff ff       	call   80102805 <kalloc>
80107ab3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107ab6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107aba:	75 2e                	jne    80107aea <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107abc:	83 ec 0c             	sub    $0xc,%esp
80107abf:	68 35 ab 10 80       	push   $0x8010ab35
80107ac4:	e8 2b 89 ff ff       	call   801003f4 <cprintf>
80107ac9:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107acc:	83 ec 04             	sub    $0x4,%esp
80107acf:	ff 75 0c             	push   0xc(%ebp)
80107ad2:	ff 75 10             	push   0x10(%ebp)
80107ad5:	ff 75 08             	push   0x8(%ebp)
80107ad8:	e8 9a 00 00 00       	call   80107b77 <deallocuvm>
80107add:	83 c4 10             	add    $0x10,%esp
      return 0;
80107ae0:	b8 00 00 00 00       	mov    $0x0,%eax
80107ae5:	e9 8b 00 00 00       	jmp    80107b75 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107aea:	83 ec 04             	sub    $0x4,%esp
80107aed:	68 00 10 00 00       	push   $0x1000
80107af2:	6a 00                	push   $0x0
80107af4:	ff 75 f0             	push   -0x10(%ebp)
80107af7:	e8 3b d0 ff ff       	call   80104b37 <memset>
80107afc:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b02:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0b:	83 ec 0c             	sub    $0xc,%esp
80107b0e:	6a 06                	push   $0x6
80107b10:	52                   	push   %edx
80107b11:	68 00 10 00 00       	push   $0x1000
80107b16:	50                   	push   %eax
80107b17:	ff 75 08             	push   0x8(%ebp)
80107b1a:	e8 c9 fa ff ff       	call   801075e8 <mappages>
80107b1f:	83 c4 20             	add    $0x20,%esp
80107b22:	85 c0                	test   %eax,%eax
80107b24:	79 39                	jns    80107b5f <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107b26:	83 ec 0c             	sub    $0xc,%esp
80107b29:	68 4d ab 10 80       	push   $0x8010ab4d
80107b2e:	e8 c1 88 ff ff       	call   801003f4 <cprintf>
80107b33:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107b36:	83 ec 04             	sub    $0x4,%esp
80107b39:	ff 75 0c             	push   0xc(%ebp)
80107b3c:	ff 75 10             	push   0x10(%ebp)
80107b3f:	ff 75 08             	push   0x8(%ebp)
80107b42:	e8 30 00 00 00       	call   80107b77 <deallocuvm>
80107b47:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107b4a:	83 ec 0c             	sub    $0xc,%esp
80107b4d:	ff 75 f0             	push   -0x10(%ebp)
80107b50:	e8 16 ac ff ff       	call   8010276b <kfree>
80107b55:	83 c4 10             	add    $0x10,%esp
      return 0;
80107b58:	b8 00 00 00 00       	mov    $0x0,%eax
80107b5d:	eb 16                	jmp    80107b75 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107b5f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b69:	3b 45 10             	cmp    0x10(%ebp),%eax
80107b6c:	0f 82 3c ff ff ff    	jb     80107aae <allocuvm+0x3c>
    }
  }
  return newsz;
80107b72:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107b75:	c9                   	leave
80107b76:	c3                   	ret

80107b77 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107b77:	55                   	push   %ebp
80107b78:	89 e5                	mov    %esp,%ebp
80107b7a:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107b7d:	8b 45 10             	mov    0x10(%ebp),%eax
80107b80:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107b83:	72 08                	jb     80107b8d <deallocuvm+0x16>
    return oldsz;
80107b85:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b88:	e9 ac 00 00 00       	jmp    80107c39 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107b8d:	8b 45 10             	mov    0x10(%ebp),%eax
80107b90:	05 ff 0f 00 00       	add    $0xfff,%eax
80107b95:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107b9d:	e9 88 00 00 00       	jmp    80107c2a <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba5:	83 ec 04             	sub    $0x4,%esp
80107ba8:	6a 00                	push   $0x0
80107baa:	50                   	push   %eax
80107bab:	ff 75 08             	push   0x8(%ebp)
80107bae:	e8 9f f9 ff ff       	call   80107552 <walkpgdir>
80107bb3:	83 c4 10             	add    $0x10,%esp
80107bb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107bb9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107bbd:	75 16                	jne    80107bd5 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc2:	c1 e8 16             	shr    $0x16,%eax
80107bc5:	83 c0 01             	add    $0x1,%eax
80107bc8:	c1 e0 16             	shl    $0x16,%eax
80107bcb:	2d 00 10 00 00       	sub    $0x1000,%eax
80107bd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107bd3:	eb 4e                	jmp    80107c23 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107bd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bd8:	8b 00                	mov    (%eax),%eax
80107bda:	83 e0 01             	and    $0x1,%eax
80107bdd:	85 c0                	test   %eax,%eax
80107bdf:	74 42                	je     80107c23 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107be1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107be4:	8b 00                	mov    (%eax),%eax
80107be6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107beb:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107bee:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107bf2:	75 0d                	jne    80107c01 <deallocuvm+0x8a>
        panic("kfree");
80107bf4:	83 ec 0c             	sub    $0xc,%esp
80107bf7:	68 69 ab 10 80       	push   $0x8010ab69
80107bfc:	e8 c0 89 ff ff       	call   801005c1 <panic>
      char *v = P2V(pa);
80107c01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c04:	05 00 00 00 80       	add    $0x80000000,%eax
80107c09:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107c0c:	83 ec 0c             	sub    $0xc,%esp
80107c0f:	ff 75 e8             	push   -0x18(%ebp)
80107c12:	e8 54 ab ff ff       	call   8010276b <kfree>
80107c17:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c1d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107c23:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107c30:	0f 82 6c ff ff ff    	jb     80107ba2 <deallocuvm+0x2b>
    }
  }
  return newsz;
80107c36:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107c39:	c9                   	leave
80107c3a:	c3                   	ret

80107c3b <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107c3b:	55                   	push   %ebp
80107c3c:	89 e5                	mov    %esp,%ebp
80107c3e:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107c41:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107c45:	75 0d                	jne    80107c54 <freevm+0x19>
    panic("freevm: no pgdir");
80107c47:	83 ec 0c             	sub    $0xc,%esp
80107c4a:	68 6f ab 10 80       	push   $0x8010ab6f
80107c4f:	e8 6d 89 ff ff       	call   801005c1 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107c54:	83 ec 04             	sub    $0x4,%esp
80107c57:	6a 00                	push   $0x0
80107c59:	68 00 00 00 80       	push   $0x80000000
80107c5e:	ff 75 08             	push   0x8(%ebp)
80107c61:	e8 11 ff ff ff       	call   80107b77 <deallocuvm>
80107c66:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107c69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107c70:	eb 48                	jmp    80107cba <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c75:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c7c:	8b 45 08             	mov    0x8(%ebp),%eax
80107c7f:	01 d0                	add    %edx,%eax
80107c81:	8b 00                	mov    (%eax),%eax
80107c83:	83 e0 01             	and    $0x1,%eax
80107c86:	85 c0                	test   %eax,%eax
80107c88:	74 2c                	je     80107cb6 <freevm+0x7b>
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
80107cae:	e8 b8 aa ff ff       	call   8010276b <kfree>
80107cb3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107cb6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107cba:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107cc1:	76 af                	jbe    80107c72 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107cc3:	83 ec 0c             	sub    $0xc,%esp
80107cc6:	ff 75 08             	push   0x8(%ebp)
80107cc9:	e8 9d aa ff ff       	call   8010276b <kfree>
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
80107cd4:	55                   	push   %ebp
80107cd5:	89 e5                	mov    %esp,%ebp
80107cd7:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107cda:	83 ec 04             	sub    $0x4,%esp
80107cdd:	6a 00                	push   $0x0
80107cdf:	ff 75 0c             	push   0xc(%ebp)
80107ce2:	ff 75 08             	push   0x8(%ebp)
80107ce5:	e8 68 f8 ff ff       	call   80107552 <walkpgdir>
80107cea:	83 c4 10             	add    $0x10,%esp
80107ced:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107cf0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107cf4:	75 0d                	jne    80107d03 <clearpteu+0x2f>
    panic("clearpteu");
80107cf6:	83 ec 0c             	sub    $0xc,%esp
80107cf9:	68 80 ab 10 80       	push   $0x8010ab80
80107cfe:	e8 be 88 ff ff       	call   801005c1 <panic>
  *pte &= ~PTE_U;
80107d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d06:	8b 00                	mov    (%eax),%eax
80107d08:	83 e0 fb             	and    $0xfffffffb,%eax
80107d0b:	89 c2                	mov    %eax,%edx
80107d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d10:	89 10                	mov    %edx,(%eax)
}
80107d12:	90                   	nop
80107d13:	c9                   	leave
80107d14:	c3                   	ret

80107d15 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107d15:	55                   	push   %ebp
80107d16:	89 e5                	mov    %esp,%ebp
80107d18:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;
  
  if((d = setupkvm()) == 0)
80107d1b:	e8 58 f9 ff ff       	call   80107678 <setupkvm>
80107d20:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d27:	75 0a                	jne    80107d33 <copyuvm+0x1e>
    return 0;
80107d29:	b8 00 00 00 00       	mov    $0x0,%eax
80107d2e:	e9 d6 00 00 00       	jmp    80107e09 <copyuvm+0xf4>
    // 스택을 힙 영역으로 옮겼으니 힙 영역까지의 페이지 복사
    // text, data 영역 0xb98까지 stack 영역 0xb98+ 2*PGSIZE까지
    // heap 영역 stack영역 위부터 kernbase까지
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107d33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d3a:	e9 a3 00 00 00       	jmp    80107de2 <copyuvm+0xcd>
    
    // 스택을 힙 영역의 맨 위에 할당했기 때문에 kernbase까지 복사를 해야하는데
    // 할당되지 않은 페이지, 유효하지 않은 페이지는 복사하지 않고 지나감
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d42:	83 ec 04             	sub    $0x4,%esp
80107d45:	6a 00                	push   $0x0
80107d47:	50                   	push   %eax
80107d48:	ff 75 08             	push   0x8(%ebp)
80107d4b:	e8 02 f8 ff ff       	call   80107552 <walkpgdir>
80107d50:	83 c4 10             	add    $0x10,%esp
80107d53:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d56:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d5a:	74 7b                	je     80107dd7 <copyuvm+0xc2>
      continue;
    if(!(*pte & PTE_P)){
80107d5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d5f:	8b 00                	mov    (%eax),%eax
80107d61:	83 e0 01             	and    $0x1,%eax
80107d64:	85 c0                	test   %eax,%eax
80107d66:	74 72                	je     80107dda <copyuvm+0xc5>
      continue;
    }
    // PTE_ADDR 페이지 테이블 엔트리에서 물리 주소 부분
    // PTE_FLAGS flag 부분 추출
    pa = PTE_ADDR(*pte);
80107d68:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d6b:	8b 00                	mov    (%eax),%eax
80107d6d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d72:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107d75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d78:	8b 00                	mov    (%eax),%eax
80107d7a:	25 ff 0f 00 00       	and    $0xfff,%eax
80107d7f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 페이지를 복사할 물리 주소 할당
    if((mem = kalloc()) == 0)
80107d82:	e8 7e aa ff ff       	call   80102805 <kalloc>
80107d87:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107d8a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107d8e:	74 62                	je     80107df2 <copyuvm+0xdd>
      goto bad;
    // 현재 페이지의 물리 주소인 pa를  mem에 복사
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107d90:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d93:	05 00 00 00 80       	add    $0x80000000,%eax
80107d98:	83 ec 04             	sub    $0x4,%esp
80107d9b:	68 00 10 00 00       	push   $0x1000
80107da0:	50                   	push   %eax
80107da1:	ff 75 e0             	push   -0x20(%ebp)
80107da4:	e8 4d ce ff ff       	call   80104bf6 <memmove>
80107da9:	83 c4 10             	add    $0x10,%esp
    // 현재 가상주소에 복사받은 mem을 매핑
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107dac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107daf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107db2:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbb:	83 ec 0c             	sub    $0xc,%esp
80107dbe:	52                   	push   %edx
80107dbf:	51                   	push   %ecx
80107dc0:	68 00 10 00 00       	push   $0x1000
80107dc5:	50                   	push   %eax
80107dc6:	ff 75 f0             	push   -0x10(%ebp)
80107dc9:	e8 1a f8 ff ff       	call   801075e8 <mappages>
80107dce:	83 c4 20             	add    $0x20,%esp
80107dd1:	85 c0                	test   %eax,%eax
80107dd3:	78 20                	js     80107df5 <copyuvm+0xe0>
80107dd5:	eb 04                	jmp    80107ddb <copyuvm+0xc6>
      continue;
80107dd7:	90                   	nop
80107dd8:	eb 01                	jmp    80107ddb <copyuvm+0xc6>
      continue;
80107dda:	90                   	nop
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107ddb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de5:	85 c0                	test   %eax,%eax
80107de7:	0f 89 52 ff ff ff    	jns    80107d3f <copyuvm+0x2a>
      goto bad;
  }  
  return d;
80107ded:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107df0:	eb 17                	jmp    80107e09 <copyuvm+0xf4>
      goto bad;
80107df2:	90                   	nop
80107df3:	eb 01                	jmp    80107df6 <copyuvm+0xe1>
      goto bad;
80107df5:	90                   	nop

bad:
  freevm(d);
80107df6:	83 ec 0c             	sub    $0xc,%esp
80107df9:	ff 75 f0             	push   -0x10(%ebp)
80107dfc:	e8 3a fe ff ff       	call   80107c3b <freevm>
80107e01:	83 c4 10             	add    $0x10,%esp
  return 0;
80107e04:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e09:	c9                   	leave
80107e0a:	c3                   	ret

80107e0b <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107e0b:	55                   	push   %ebp
80107e0c:	89 e5                	mov    %esp,%ebp
80107e0e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107e11:	83 ec 04             	sub    $0x4,%esp
80107e14:	6a 00                	push   $0x0
80107e16:	ff 75 0c             	push   0xc(%ebp)
80107e19:	ff 75 08             	push   0x8(%ebp)
80107e1c:	e8 31 f7 ff ff       	call   80107552 <walkpgdir>
80107e21:	83 c4 10             	add    $0x10,%esp
80107e24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2a:	8b 00                	mov    (%eax),%eax
80107e2c:	83 e0 01             	and    $0x1,%eax
80107e2f:	85 c0                	test   %eax,%eax
80107e31:	75 07                	jne    80107e3a <uva2ka+0x2f>
    return 0;
80107e33:	b8 00 00 00 00       	mov    $0x0,%eax
80107e38:	eb 22                	jmp    80107e5c <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3d:	8b 00                	mov    (%eax),%eax
80107e3f:	83 e0 04             	and    $0x4,%eax
80107e42:	85 c0                	test   %eax,%eax
80107e44:	75 07                	jne    80107e4d <uva2ka+0x42>
    return 0;
80107e46:	b8 00 00 00 00       	mov    $0x0,%eax
80107e4b:	eb 0f                	jmp    80107e5c <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e50:	8b 00                	mov    (%eax),%eax
80107e52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e57:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107e5c:	c9                   	leave
80107e5d:	c3                   	ret

80107e5e <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107e5e:	55                   	push   %ebp
80107e5f:	89 e5                	mov    %esp,%ebp
80107e61:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107e64:	8b 45 10             	mov    0x10(%ebp),%eax
80107e67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107e6a:	eb 7f                	jmp    80107eeb <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107e6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e74:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107e77:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e7a:	83 ec 08             	sub    $0x8,%esp
80107e7d:	50                   	push   %eax
80107e7e:	ff 75 08             	push   0x8(%ebp)
80107e81:	e8 85 ff ff ff       	call   80107e0b <uva2ka>
80107e86:	83 c4 10             	add    $0x10,%esp
80107e89:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107e8c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107e90:	75 07                	jne    80107e99 <copyout+0x3b>
      return -1;
80107e92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e97:	eb 61                	jmp    80107efa <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107e99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e9c:	2b 45 0c             	sub    0xc(%ebp),%eax
80107e9f:	05 00 10 00 00       	add    $0x1000,%eax
80107ea4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107ea7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eaa:	39 45 14             	cmp    %eax,0x14(%ebp)
80107ead:	73 06                	jae    80107eb5 <copyout+0x57>
      n = len;
80107eaf:	8b 45 14             	mov    0x14(%ebp),%eax
80107eb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107eb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eb8:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107ebb:	89 c2                	mov    %eax,%edx
80107ebd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ec0:	01 d0                	add    %edx,%eax
80107ec2:	83 ec 04             	sub    $0x4,%esp
80107ec5:	ff 75 f0             	push   -0x10(%ebp)
80107ec8:	ff 75 f4             	push   -0xc(%ebp)
80107ecb:	50                   	push   %eax
80107ecc:	e8 25 cd ff ff       	call   80104bf6 <memmove>
80107ed1:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107ed4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ed7:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107edd:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107ee0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ee3:	05 00 10 00 00       	add    $0x1000,%eax
80107ee8:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107eeb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107eef:	0f 85 77 ff ff ff    	jne    80107e6c <copyout+0xe>
  }
  return 0;
80107ef5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107efa:	c9                   	leave
80107efb:	c3                   	ret

80107efc <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107efc:	55                   	push   %ebp
80107efd:	89 e5                	mov    %esp,%ebp
80107eff:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107f02:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107f09:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f0c:	8b 40 08             	mov    0x8(%eax),%eax
80107f0f:	05 00 00 00 80       	add    $0x80000000,%eax
80107f14:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107f17:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f21:	8b 40 24             	mov    0x24(%eax),%eax
80107f24:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107f29:	c7 05 30 6b 19 80 00 	movl   $0x0,0x80196b30
80107f30:	00 00 00 

  while(i<madt->len){
80107f33:	e9 bc 00 00 00       	jmp    80107ff4 <mpinit_uefi+0xf8>
    uchar *entry_type = ((uchar *)madt)+i;
80107f38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f3e:	01 d0                	add    %edx,%eax
80107f40:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f46:	0f b6 00             	movzbl (%eax),%eax
80107f49:	0f b6 c0             	movzbl %al,%eax
80107f4c:	83 f8 05             	cmp    $0x5,%eax
80107f4f:	0f 87 9f 00 00 00    	ja     80107ff4 <mpinit_uefi+0xf8>
80107f55:	8b 04 85 8c ab 10 80 	mov    -0x7fef5474(,%eax,4),%eax
80107f5c:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107f5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f61:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107f64:	a1 30 6b 19 80       	mov    0x80196b30,%eax
80107f69:	85 c0                	test   %eax,%eax
80107f6b:	7f 28                	jg     80107f95 <mpinit_uefi+0x99>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107f6d:	8b 15 30 6b 19 80    	mov    0x80196b30,%edx
80107f73:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107f76:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107f7a:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107f80:	81 c2 80 6a 19 80    	add    $0x80196a80,%edx
80107f86:	88 02                	mov    %al,(%edx)
          ncpu++;
80107f88:	a1 30 6b 19 80       	mov    0x80196b30,%eax
80107f8d:	83 c0 01             	add    $0x1,%eax
80107f90:	a3 30 6b 19 80       	mov    %eax,0x80196b30
        }
        i += lapic_entry->record_len;
80107f95:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107f98:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107f9c:	0f b6 c0             	movzbl %al,%eax
80107f9f:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107fa2:	eb 50                	jmp    80107ff4 <mpinit_uefi+0xf8>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fa7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107faa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107fad:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107fb1:	a2 34 6b 19 80       	mov    %al,0x80196b34
        i += ioapic->record_len;
80107fb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107fb9:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107fbd:	0f b6 c0             	movzbl %al,%eax
80107fc0:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107fc3:	eb 2f                	jmp    80107ff4 <mpinit_uefi+0xf8>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fc8:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107fcb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107fce:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107fd2:	0f b6 c0             	movzbl %al,%eax
80107fd5:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107fd8:	eb 1a                	jmp    80107ff4 <mpinit_uefi+0xf8>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107fda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107fe0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fe3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107fe7:	0f b6 c0             	movzbl %al,%eax
80107fea:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107fed:	eb 05                	jmp    80107ff4 <mpinit_uefi+0xf8>

      case 5:
        i = i + 0xC;
80107fef:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107ff3:	90                   	nop
  while(i<madt->len){
80107ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff7:	8b 40 04             	mov    0x4(%eax),%eax
80107ffa:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107ffd:	0f 82 35 ff ff ff    	jb     80107f38 <mpinit_uefi+0x3c>
    }
  }

}
80108003:	90                   	nop
80108004:	90                   	nop
80108005:	c9                   	leave
80108006:	c3                   	ret

80108007 <inb>:
{
80108007:	55                   	push   %ebp
80108008:	89 e5                	mov    %esp,%ebp
8010800a:	83 ec 14             	sub    $0x14,%esp
8010800d:	8b 45 08             	mov    0x8(%ebp),%eax
80108010:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108014:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108018:	89 c2                	mov    %eax,%edx
8010801a:	ec                   	in     (%dx),%al
8010801b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010801e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108022:	c9                   	leave
80108023:	c3                   	ret

80108024 <outb>:
{
80108024:	55                   	push   %ebp
80108025:	89 e5                	mov    %esp,%ebp
80108027:	83 ec 08             	sub    $0x8,%esp
8010802a:	8b 55 08             	mov    0x8(%ebp),%edx
8010802d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108030:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80108034:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108037:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010803b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010803f:	ee                   	out    %al,(%dx)
}
80108040:	90                   	nop
80108041:	c9                   	leave
80108042:	c3                   	ret

80108043 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108043:	55                   	push   %ebp
80108044:	89 e5                	mov    %esp,%ebp
80108046:	83 ec 28             	sub    $0x28,%esp
80108049:	8b 45 08             	mov    0x8(%ebp),%eax
8010804c:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
8010804f:	6a 00                	push   $0x0
80108051:	68 fa 03 00 00       	push   $0x3fa
80108056:	e8 c9 ff ff ff       	call   80108024 <outb>
8010805b:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010805e:	68 80 00 00 00       	push   $0x80
80108063:	68 fb 03 00 00       	push   $0x3fb
80108068:	e8 b7 ff ff ff       	call   80108024 <outb>
8010806d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108070:	6a 0c                	push   $0xc
80108072:	68 f8 03 00 00       	push   $0x3f8
80108077:	e8 a8 ff ff ff       	call   80108024 <outb>
8010807c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010807f:	6a 00                	push   $0x0
80108081:	68 f9 03 00 00       	push   $0x3f9
80108086:	e8 99 ff ff ff       	call   80108024 <outb>
8010808b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010808e:	6a 03                	push   $0x3
80108090:	68 fb 03 00 00       	push   $0x3fb
80108095:	e8 8a ff ff ff       	call   80108024 <outb>
8010809a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010809d:	6a 00                	push   $0x0
8010809f:	68 fc 03 00 00       	push   $0x3fc
801080a4:	e8 7b ff ff ff       	call   80108024 <outb>
801080a9:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801080ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801080b3:	eb 11                	jmp    801080c6 <uart_debug+0x83>
801080b5:	83 ec 0c             	sub    $0xc,%esp
801080b8:	6a 0a                	push   $0xa
801080ba:	e8 d7 aa ff ff       	call   80102b96 <microdelay>
801080bf:	83 c4 10             	add    $0x10,%esp
801080c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801080c6:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801080ca:	7f 1a                	jg     801080e6 <uart_debug+0xa3>
801080cc:	83 ec 0c             	sub    $0xc,%esp
801080cf:	68 fd 03 00 00       	push   $0x3fd
801080d4:	e8 2e ff ff ff       	call   80108007 <inb>
801080d9:	83 c4 10             	add    $0x10,%esp
801080dc:	0f b6 c0             	movzbl %al,%eax
801080df:	83 e0 20             	and    $0x20,%eax
801080e2:	85 c0                	test   %eax,%eax
801080e4:	74 cf                	je     801080b5 <uart_debug+0x72>
  outb(COM1+0, p);
801080e6:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801080ea:	0f b6 c0             	movzbl %al,%eax
801080ed:	83 ec 08             	sub    $0x8,%esp
801080f0:	50                   	push   %eax
801080f1:	68 f8 03 00 00       	push   $0x3f8
801080f6:	e8 29 ff ff ff       	call   80108024 <outb>
801080fb:	83 c4 10             	add    $0x10,%esp
}
801080fe:	90                   	nop
801080ff:	c9                   	leave
80108100:	c3                   	ret

80108101 <uart_debugs>:

void uart_debugs(char *p){
80108101:	55                   	push   %ebp
80108102:	89 e5                	mov    %esp,%ebp
80108104:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108107:	eb 1b                	jmp    80108124 <uart_debugs+0x23>
    uart_debug(*p++);
80108109:	8b 45 08             	mov    0x8(%ebp),%eax
8010810c:	8d 50 01             	lea    0x1(%eax),%edx
8010810f:	89 55 08             	mov    %edx,0x8(%ebp)
80108112:	0f b6 00             	movzbl (%eax),%eax
80108115:	0f be c0             	movsbl %al,%eax
80108118:	83 ec 0c             	sub    $0xc,%esp
8010811b:	50                   	push   %eax
8010811c:	e8 22 ff ff ff       	call   80108043 <uart_debug>
80108121:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108124:	8b 45 08             	mov    0x8(%ebp),%eax
80108127:	0f b6 00             	movzbl (%eax),%eax
8010812a:	84 c0                	test   %al,%al
8010812c:	75 db                	jne    80108109 <uart_debugs+0x8>
  }
}
8010812e:	90                   	nop
8010812f:	90                   	nop
80108130:	c9                   	leave
80108131:	c3                   	ret

80108132 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108132:	55                   	push   %ebp
80108133:	89 e5                	mov    %esp,%ebp
80108135:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108138:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
8010813f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108142:	8b 50 14             	mov    0x14(%eax),%edx
80108145:	8b 40 10             	mov    0x10(%eax),%eax
80108148:	a3 38 6b 19 80       	mov    %eax,0x80196b38
  gpu.vram_size = boot_param->graphic_config.frame_size;
8010814d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108150:	8b 50 1c             	mov    0x1c(%eax),%edx
80108153:	8b 40 18             	mov    0x18(%eax),%eax
80108156:	a3 40 6b 19 80       	mov    %eax,0x80196b40
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
8010815b:	a1 40 6b 19 80       	mov    0x80196b40,%eax
80108160:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108165:	29 c2                	sub    %eax,%edx
80108167:	89 15 3c 6b 19 80    	mov    %edx,0x80196b3c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010816d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108170:	8b 50 24             	mov    0x24(%eax),%edx
80108173:	8b 40 20             	mov    0x20(%eax),%eax
80108176:	a3 44 6b 19 80       	mov    %eax,0x80196b44
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
8010817b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010817e:	8b 50 2c             	mov    0x2c(%eax),%edx
80108181:	8b 40 28             	mov    0x28(%eax),%eax
80108184:	a3 48 6b 19 80       	mov    %eax,0x80196b48
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108189:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010818c:	8b 50 34             	mov    0x34(%eax),%edx
8010818f:	8b 40 30             	mov    0x30(%eax),%eax
80108192:	a3 4c 6b 19 80       	mov    %eax,0x80196b4c
}
80108197:	90                   	nop
80108198:	c9                   	leave
80108199:	c3                   	ret

8010819a <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010819a:	55                   	push   %ebp
8010819b:	89 e5                	mov    %esp,%ebp
8010819d:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801081a0:	8b 15 4c 6b 19 80    	mov    0x80196b4c,%edx
801081a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801081a9:	0f af d0             	imul   %eax,%edx
801081ac:	8b 45 08             	mov    0x8(%ebp),%eax
801081af:	01 d0                	add    %edx,%eax
801081b1:	c1 e0 02             	shl    $0x2,%eax
801081b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801081b7:	8b 15 3c 6b 19 80    	mov    0x80196b3c,%edx
801081bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081c0:	01 d0                	add    %edx,%eax
801081c2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801081c5:	8b 45 10             	mov    0x10(%ebp),%eax
801081c8:	0f b6 10             	movzbl (%eax),%edx
801081cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801081ce:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801081d0:	8b 45 10             	mov    0x10(%ebp),%eax
801081d3:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801081d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801081da:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801081dd:	8b 45 10             	mov    0x10(%ebp),%eax
801081e0:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801081e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801081e7:	88 50 02             	mov    %dl,0x2(%eax)
}
801081ea:	90                   	nop
801081eb:	c9                   	leave
801081ec:	c3                   	ret

801081ed <graphic_scroll_up>:

void graphic_scroll_up(int height){
801081ed:	55                   	push   %ebp
801081ee:	89 e5                	mov    %esp,%ebp
801081f0:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801081f3:	8b 15 4c 6b 19 80    	mov    0x80196b4c,%edx
801081f9:	8b 45 08             	mov    0x8(%ebp),%eax
801081fc:	0f af c2             	imul   %edx,%eax
801081ff:	c1 e0 02             	shl    $0x2,%eax
80108202:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108205:	8b 15 40 6b 19 80    	mov    0x80196b40,%edx
8010820b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010820e:	29 c2                	sub    %eax,%edx
80108210:	8b 0d 3c 6b 19 80    	mov    0x80196b3c,%ecx
80108216:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108219:	01 c8                	add    %ecx,%eax
8010821b:	89 c1                	mov    %eax,%ecx
8010821d:	a1 3c 6b 19 80       	mov    0x80196b3c,%eax
80108222:	83 ec 04             	sub    $0x4,%esp
80108225:	52                   	push   %edx
80108226:	51                   	push   %ecx
80108227:	50                   	push   %eax
80108228:	e8 c9 c9 ff ff       	call   80104bf6 <memmove>
8010822d:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108230:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108233:	8b 0d 3c 6b 19 80    	mov    0x80196b3c,%ecx
80108239:	8b 15 40 6b 19 80    	mov    0x80196b40,%edx
8010823f:	01 d1                	add    %edx,%ecx
80108241:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108244:	29 d1                	sub    %edx,%ecx
80108246:	89 ca                	mov    %ecx,%edx
80108248:	83 ec 04             	sub    $0x4,%esp
8010824b:	50                   	push   %eax
8010824c:	6a 00                	push   $0x0
8010824e:	52                   	push   %edx
8010824f:	e8 e3 c8 ff ff       	call   80104b37 <memset>
80108254:	83 c4 10             	add    $0x10,%esp
}
80108257:	90                   	nop
80108258:	c9                   	leave
80108259:	c3                   	ret

8010825a <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
8010825a:	55                   	push   %ebp
8010825b:	89 e5                	mov    %esp,%ebp
8010825d:	53                   	push   %ebx
8010825e:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108261:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108268:	e9 b1 00 00 00       	jmp    8010831e <font_render+0xc4>
    for(int j=14;j>-1;j--){
8010826d:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108274:	e9 97 00 00 00       	jmp    80108310 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108279:	8b 45 10             	mov    0x10(%ebp),%eax
8010827c:	83 e8 20             	sub    $0x20,%eax
8010827f:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108282:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108285:	01 d0                	add    %edx,%eax
80108287:	0f b7 84 00 c0 ab 10 	movzwl -0x7fef5440(%eax,%eax,1),%eax
8010828e:	80 
8010828f:	0f b7 d0             	movzwl %ax,%edx
80108292:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108295:	bb 01 00 00 00       	mov    $0x1,%ebx
8010829a:	89 c1                	mov    %eax,%ecx
8010829c:	d3 e3                	shl    %cl,%ebx
8010829e:	89 d8                	mov    %ebx,%eax
801082a0:	21 d0                	and    %edx,%eax
801082a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801082a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082a8:	ba 01 00 00 00       	mov    $0x1,%edx
801082ad:	89 c1                	mov    %eax,%ecx
801082af:	d3 e2                	shl    %cl,%edx
801082b1:	89 d0                	mov    %edx,%eax
801082b3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801082b6:	75 2b                	jne    801082e3 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801082b8:	8b 55 0c             	mov    0xc(%ebp),%edx
801082bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082be:	01 c2                	add    %eax,%edx
801082c0:	b8 0e 00 00 00       	mov    $0xe,%eax
801082c5:	2b 45 f0             	sub    -0x10(%ebp),%eax
801082c8:	89 c1                	mov    %eax,%ecx
801082ca:	8b 45 08             	mov    0x8(%ebp),%eax
801082cd:	01 c8                	add    %ecx,%eax
801082cf:	83 ec 04             	sub    $0x4,%esp
801082d2:	68 e0 f4 10 80       	push   $0x8010f4e0
801082d7:	52                   	push   %edx
801082d8:	50                   	push   %eax
801082d9:	e8 bc fe ff ff       	call   8010819a <graphic_draw_pixel>
801082de:	83 c4 10             	add    $0x10,%esp
801082e1:	eb 29                	jmp    8010830c <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801082e3:	8b 55 0c             	mov    0xc(%ebp),%edx
801082e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e9:	01 c2                	add    %eax,%edx
801082eb:	b8 0e 00 00 00       	mov    $0xe,%eax
801082f0:	2b 45 f0             	sub    -0x10(%ebp),%eax
801082f3:	89 c1                	mov    %eax,%ecx
801082f5:	8b 45 08             	mov    0x8(%ebp),%eax
801082f8:	01 c8                	add    %ecx,%eax
801082fa:	83 ec 04             	sub    $0x4,%esp
801082fd:	68 50 6b 19 80       	push   $0x80196b50
80108302:	52                   	push   %edx
80108303:	50                   	push   %eax
80108304:	e8 91 fe ff ff       	call   8010819a <graphic_draw_pixel>
80108309:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
8010830c:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108310:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108314:	0f 89 5f ff ff ff    	jns    80108279 <font_render+0x1f>
  for(int i=0;i<30;i++){
8010831a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010831e:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108322:	0f 8e 45 ff ff ff    	jle    8010826d <font_render+0x13>
      }
    }
  }
}
80108328:	90                   	nop
80108329:	90                   	nop
8010832a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010832d:	c9                   	leave
8010832e:	c3                   	ret

8010832f <font_render_string>:

void font_render_string(char *string,int row){
8010832f:	55                   	push   %ebp
80108330:	89 e5                	mov    %esp,%ebp
80108332:	53                   	push   %ebx
80108333:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108336:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010833d:	eb 33                	jmp    80108372 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
8010833f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108342:	8b 45 08             	mov    0x8(%ebp),%eax
80108345:	01 d0                	add    %edx,%eax
80108347:	0f b6 00             	movzbl (%eax),%eax
8010834a:	0f be d8             	movsbl %al,%ebx
8010834d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108350:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108353:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108356:	89 d0                	mov    %edx,%eax
80108358:	c1 e0 04             	shl    $0x4,%eax
8010835b:	29 d0                	sub    %edx,%eax
8010835d:	83 c0 02             	add    $0x2,%eax
80108360:	83 ec 04             	sub    $0x4,%esp
80108363:	53                   	push   %ebx
80108364:	51                   	push   %ecx
80108365:	50                   	push   %eax
80108366:	e8 ef fe ff ff       	call   8010825a <font_render>
8010836b:	83 c4 10             	add    $0x10,%esp
    i++;
8010836e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108372:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108375:	8b 45 08             	mov    0x8(%ebp),%eax
80108378:	01 d0                	add    %edx,%eax
8010837a:	0f b6 00             	movzbl (%eax),%eax
8010837d:	84 c0                	test   %al,%al
8010837f:	74 06                	je     80108387 <font_render_string+0x58>
80108381:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108385:	7e b8                	jle    8010833f <font_render_string+0x10>
  }
}
80108387:	90                   	nop
80108388:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010838b:	c9                   	leave
8010838c:	c3                   	ret

8010838d <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010838d:	55                   	push   %ebp
8010838e:	89 e5                	mov    %esp,%ebp
80108390:	53                   	push   %ebx
80108391:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108394:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010839b:	eb 6b                	jmp    80108408 <pci_init+0x7b>
    for(int j=0;j<32;j++){
8010839d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801083a4:	eb 58                	jmp    801083fe <pci_init+0x71>
      for(int k=0;k<8;k++){
801083a6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801083ad:	eb 45                	jmp    801083f4 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
801083af:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801083b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801083b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b8:	83 ec 0c             	sub    $0xc,%esp
801083bb:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801083be:	53                   	push   %ebx
801083bf:	6a 00                	push   $0x0
801083c1:	51                   	push   %ecx
801083c2:	52                   	push   %edx
801083c3:	50                   	push   %eax
801083c4:	e8 b0 00 00 00       	call   80108479 <pci_access_config>
801083c9:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801083cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083cf:	0f b7 c0             	movzwl %ax,%eax
801083d2:	3d ff ff 00 00       	cmp    $0xffff,%eax
801083d7:	74 17                	je     801083f0 <pci_init+0x63>
        pci_init_device(i,j,k);
801083d9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801083dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801083df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e2:	83 ec 04             	sub    $0x4,%esp
801083e5:	51                   	push   %ecx
801083e6:	52                   	push   %edx
801083e7:	50                   	push   %eax
801083e8:	e8 37 01 00 00       	call   80108524 <pci_init_device>
801083ed:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801083f0:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801083f4:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801083f8:	7e b5                	jle    801083af <pci_init+0x22>
    for(int j=0;j<32;j++){
801083fa:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801083fe:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108402:	7e a2                	jle    801083a6 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108404:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108408:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010840f:	7e 8c                	jle    8010839d <pci_init+0x10>
      }
      }
    }
  }
}
80108411:	90                   	nop
80108412:	90                   	nop
80108413:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108416:	c9                   	leave
80108417:	c3                   	ret

80108418 <pci_write_config>:

void pci_write_config(uint config){
80108418:	55                   	push   %ebp
80108419:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
8010841b:	8b 45 08             	mov    0x8(%ebp),%eax
8010841e:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108423:	89 c0                	mov    %eax,%eax
80108425:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108426:	90                   	nop
80108427:	5d                   	pop    %ebp
80108428:	c3                   	ret

80108429 <pci_write_data>:

void pci_write_data(uint config){
80108429:	55                   	push   %ebp
8010842a:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
8010842c:	8b 45 08             	mov    0x8(%ebp),%eax
8010842f:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108434:	89 c0                	mov    %eax,%eax
80108436:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108437:	90                   	nop
80108438:	5d                   	pop    %ebp
80108439:	c3                   	ret

8010843a <pci_read_config>:
uint pci_read_config(){
8010843a:	55                   	push   %ebp
8010843b:	89 e5                	mov    %esp,%ebp
8010843d:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108440:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108445:	ed                   	in     (%dx),%eax
80108446:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108449:	83 ec 0c             	sub    $0xc,%esp
8010844c:	68 c8 00 00 00       	push   $0xc8
80108451:	e8 40 a7 ff ff       	call   80102b96 <microdelay>
80108456:	83 c4 10             	add    $0x10,%esp
  return data;
80108459:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010845c:	c9                   	leave
8010845d:	c3                   	ret

8010845e <pci_test>:


void pci_test(){
8010845e:	55                   	push   %ebp
8010845f:	89 e5                	mov    %esp,%ebp
80108461:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108464:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
8010846b:	ff 75 fc             	push   -0x4(%ebp)
8010846e:	e8 a5 ff ff ff       	call   80108418 <pci_write_config>
80108473:	83 c4 04             	add    $0x4,%esp
}
80108476:	90                   	nop
80108477:	c9                   	leave
80108478:	c3                   	ret

80108479 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108479:	55                   	push   %ebp
8010847a:	89 e5                	mov    %esp,%ebp
8010847c:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010847f:	8b 45 08             	mov    0x8(%ebp),%eax
80108482:	c1 e0 10             	shl    $0x10,%eax
80108485:	25 00 00 ff 00       	and    $0xff0000,%eax
8010848a:	89 c2                	mov    %eax,%edx
8010848c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010848f:	c1 e0 0b             	shl    $0xb,%eax
80108492:	0f b7 c0             	movzwl %ax,%eax
80108495:	09 c2                	or     %eax,%edx
80108497:	8b 45 10             	mov    0x10(%ebp),%eax
8010849a:	c1 e0 08             	shl    $0x8,%eax
8010849d:	25 00 07 00 00       	and    $0x700,%eax
801084a2:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801084a4:	8b 45 14             	mov    0x14(%ebp),%eax
801084a7:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801084ac:	09 d0                	or     %edx,%eax
801084ae:	0d 00 00 00 80       	or     $0x80000000,%eax
801084b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801084b6:	ff 75 f4             	push   -0xc(%ebp)
801084b9:	e8 5a ff ff ff       	call   80108418 <pci_write_config>
801084be:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801084c1:	e8 74 ff ff ff       	call   8010843a <pci_read_config>
801084c6:	8b 55 18             	mov    0x18(%ebp),%edx
801084c9:	89 02                	mov    %eax,(%edx)
}
801084cb:	90                   	nop
801084cc:	c9                   	leave
801084cd:	c3                   	ret

801084ce <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801084ce:	55                   	push   %ebp
801084cf:	89 e5                	mov    %esp,%ebp
801084d1:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801084d4:	8b 45 08             	mov    0x8(%ebp),%eax
801084d7:	c1 e0 10             	shl    $0x10,%eax
801084da:	25 00 00 ff 00       	and    $0xff0000,%eax
801084df:	89 c2                	mov    %eax,%edx
801084e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801084e4:	c1 e0 0b             	shl    $0xb,%eax
801084e7:	0f b7 c0             	movzwl %ax,%eax
801084ea:	09 c2                	or     %eax,%edx
801084ec:	8b 45 10             	mov    0x10(%ebp),%eax
801084ef:	c1 e0 08             	shl    $0x8,%eax
801084f2:	25 00 07 00 00       	and    $0x700,%eax
801084f7:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801084f9:	8b 45 14             	mov    0x14(%ebp),%eax
801084fc:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108501:	09 d0                	or     %edx,%eax
80108503:	0d 00 00 00 80       	or     $0x80000000,%eax
80108508:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
8010850b:	ff 75 fc             	push   -0x4(%ebp)
8010850e:	e8 05 ff ff ff       	call   80108418 <pci_write_config>
80108513:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108516:	ff 75 18             	push   0x18(%ebp)
80108519:	e8 0b ff ff ff       	call   80108429 <pci_write_data>
8010851e:	83 c4 04             	add    $0x4,%esp
}
80108521:	90                   	nop
80108522:	c9                   	leave
80108523:	c3                   	ret

80108524 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108524:	55                   	push   %ebp
80108525:	89 e5                	mov    %esp,%ebp
80108527:	53                   	push   %ebx
80108528:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
8010852b:	8b 45 08             	mov    0x8(%ebp),%eax
8010852e:	a2 54 6b 19 80       	mov    %al,0x80196b54
  dev.device_num = device_num;
80108533:	8b 45 0c             	mov    0xc(%ebp),%eax
80108536:	a2 55 6b 19 80       	mov    %al,0x80196b55
  dev.function_num = function_num;
8010853b:	8b 45 10             	mov    0x10(%ebp),%eax
8010853e:	a2 56 6b 19 80       	mov    %al,0x80196b56
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108543:	ff 75 10             	push   0x10(%ebp)
80108546:	ff 75 0c             	push   0xc(%ebp)
80108549:	ff 75 08             	push   0x8(%ebp)
8010854c:	68 04 c2 10 80       	push   $0x8010c204
80108551:	e8 9e 7e ff ff       	call   801003f4 <cprintf>
80108556:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108559:	83 ec 0c             	sub    $0xc,%esp
8010855c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010855f:	50                   	push   %eax
80108560:	6a 00                	push   $0x0
80108562:	ff 75 10             	push   0x10(%ebp)
80108565:	ff 75 0c             	push   0xc(%ebp)
80108568:	ff 75 08             	push   0x8(%ebp)
8010856b:	e8 09 ff ff ff       	call   80108479 <pci_access_config>
80108570:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108573:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108576:	c1 e8 10             	shr    $0x10,%eax
80108579:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
8010857c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010857f:	25 ff ff 00 00       	and    $0xffff,%eax
80108584:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858a:	a3 58 6b 19 80       	mov    %eax,0x80196b58
  dev.vendor_id = vendor_id;
8010858f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108592:	a3 5c 6b 19 80       	mov    %eax,0x80196b5c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108597:	83 ec 04             	sub    $0x4,%esp
8010859a:	ff 75 f0             	push   -0x10(%ebp)
8010859d:	ff 75 f4             	push   -0xc(%ebp)
801085a0:	68 38 c2 10 80       	push   $0x8010c238
801085a5:	e8 4a 7e ff ff       	call   801003f4 <cprintf>
801085aa:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801085ad:	83 ec 0c             	sub    $0xc,%esp
801085b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801085b3:	50                   	push   %eax
801085b4:	6a 08                	push   $0x8
801085b6:	ff 75 10             	push   0x10(%ebp)
801085b9:	ff 75 0c             	push   0xc(%ebp)
801085bc:	ff 75 08             	push   0x8(%ebp)
801085bf:	e8 b5 fe ff ff       	call   80108479 <pci_access_config>
801085c4:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801085c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085ca:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801085cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085d0:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801085d3:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801085d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085d9:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801085dc:	0f b6 c0             	movzbl %al,%eax
801085df:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801085e2:	c1 eb 18             	shr    $0x18,%ebx
801085e5:	83 ec 0c             	sub    $0xc,%esp
801085e8:	51                   	push   %ecx
801085e9:	52                   	push   %edx
801085ea:	50                   	push   %eax
801085eb:	53                   	push   %ebx
801085ec:	68 5c c2 10 80       	push   $0x8010c25c
801085f1:	e8 fe 7d ff ff       	call   801003f4 <cprintf>
801085f6:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
801085f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085fc:	c1 e8 18             	shr    $0x18,%eax
801085ff:	a2 60 6b 19 80       	mov    %al,0x80196b60
  dev.sub_class = (data>>16)&0xFF;
80108604:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108607:	c1 e8 10             	shr    $0x10,%eax
8010860a:	a2 61 6b 19 80       	mov    %al,0x80196b61
  dev.interface = (data>>8)&0xFF;
8010860f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108612:	c1 e8 08             	shr    $0x8,%eax
80108615:	a2 62 6b 19 80       	mov    %al,0x80196b62
  dev.revision_id = data&0xFF;
8010861a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010861d:	a2 63 6b 19 80       	mov    %al,0x80196b63
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108622:	83 ec 0c             	sub    $0xc,%esp
80108625:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108628:	50                   	push   %eax
80108629:	6a 10                	push   $0x10
8010862b:	ff 75 10             	push   0x10(%ebp)
8010862e:	ff 75 0c             	push   0xc(%ebp)
80108631:	ff 75 08             	push   0x8(%ebp)
80108634:	e8 40 fe ff ff       	call   80108479 <pci_access_config>
80108639:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
8010863c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010863f:	a3 64 6b 19 80       	mov    %eax,0x80196b64
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108644:	83 ec 0c             	sub    $0xc,%esp
80108647:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010864a:	50                   	push   %eax
8010864b:	6a 14                	push   $0x14
8010864d:	ff 75 10             	push   0x10(%ebp)
80108650:	ff 75 0c             	push   0xc(%ebp)
80108653:	ff 75 08             	push   0x8(%ebp)
80108656:	e8 1e fe ff ff       	call   80108479 <pci_access_config>
8010865b:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
8010865e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108661:	a3 68 6b 19 80       	mov    %eax,0x80196b68
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108666:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
8010866d:	75 5a                	jne    801086c9 <pci_init_device+0x1a5>
8010866f:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108676:	75 51                	jne    801086c9 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108678:	83 ec 0c             	sub    $0xc,%esp
8010867b:	68 a1 c2 10 80       	push   $0x8010c2a1
80108680:	e8 6f 7d ff ff       	call   801003f4 <cprintf>
80108685:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108688:	83 ec 0c             	sub    $0xc,%esp
8010868b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010868e:	50                   	push   %eax
8010868f:	68 f0 00 00 00       	push   $0xf0
80108694:	ff 75 10             	push   0x10(%ebp)
80108697:	ff 75 0c             	push   0xc(%ebp)
8010869a:	ff 75 08             	push   0x8(%ebp)
8010869d:	e8 d7 fd ff ff       	call   80108479 <pci_access_config>
801086a2:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801086a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086a8:	83 ec 08             	sub    $0x8,%esp
801086ab:	50                   	push   %eax
801086ac:	68 bb c2 10 80       	push   $0x8010c2bb
801086b1:	e8 3e 7d ff ff       	call   801003f4 <cprintf>
801086b6:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801086b9:	83 ec 0c             	sub    $0xc,%esp
801086bc:	68 54 6b 19 80       	push   $0x80196b54
801086c1:	e8 09 00 00 00       	call   801086cf <i8254_init>
801086c6:	83 c4 10             	add    $0x10,%esp
  }
}
801086c9:	90                   	nop
801086ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801086cd:	c9                   	leave
801086ce:	c3                   	ret

801086cf <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
801086cf:	55                   	push   %ebp
801086d0:	89 e5                	mov    %esp,%ebp
801086d2:	53                   	push   %ebx
801086d3:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
801086d6:	8b 45 08             	mov    0x8(%ebp),%eax
801086d9:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801086dd:	0f b6 c8             	movzbl %al,%ecx
801086e0:	8b 45 08             	mov    0x8(%ebp),%eax
801086e3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801086e7:	0f b6 d0             	movzbl %al,%edx
801086ea:	8b 45 08             	mov    0x8(%ebp),%eax
801086ed:	0f b6 00             	movzbl (%eax),%eax
801086f0:	0f b6 c0             	movzbl %al,%eax
801086f3:	83 ec 0c             	sub    $0xc,%esp
801086f6:	8d 5d ec             	lea    -0x14(%ebp),%ebx
801086f9:	53                   	push   %ebx
801086fa:	6a 04                	push   $0x4
801086fc:	51                   	push   %ecx
801086fd:	52                   	push   %edx
801086fe:	50                   	push   %eax
801086ff:	e8 75 fd ff ff       	call   80108479 <pci_access_config>
80108704:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108707:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010870a:	83 c8 04             	or     $0x4,%eax
8010870d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108710:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108713:	8b 45 08             	mov    0x8(%ebp),%eax
80108716:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010871a:	0f b6 c8             	movzbl %al,%ecx
8010871d:	8b 45 08             	mov    0x8(%ebp),%eax
80108720:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108724:	0f b6 d0             	movzbl %al,%edx
80108727:	8b 45 08             	mov    0x8(%ebp),%eax
8010872a:	0f b6 00             	movzbl (%eax),%eax
8010872d:	0f b6 c0             	movzbl %al,%eax
80108730:	83 ec 0c             	sub    $0xc,%esp
80108733:	53                   	push   %ebx
80108734:	6a 04                	push   $0x4
80108736:	51                   	push   %ecx
80108737:	52                   	push   %edx
80108738:	50                   	push   %eax
80108739:	e8 90 fd ff ff       	call   801084ce <pci_write_config_register>
8010873e:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108741:	8b 45 08             	mov    0x8(%ebp),%eax
80108744:	8b 40 10             	mov    0x10(%eax),%eax
80108747:	05 00 00 00 40       	add    $0x40000000,%eax
8010874c:	a3 6c 6b 19 80       	mov    %eax,0x80196b6c
  uint *ctrl = (uint *)base_addr;
80108751:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108756:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108759:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
8010875e:	05 d8 00 00 00       	add    $0xd8,%eax
80108763:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108766:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108769:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
8010876f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108772:	8b 00                	mov    (%eax),%eax
80108774:	0d 00 00 00 04       	or     $0x4000000,%eax
80108779:	89 c2                	mov    %eax,%edx
8010877b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877e:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108780:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108783:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108789:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010878c:	8b 00                	mov    (%eax),%eax
8010878e:	83 c8 40             	or     $0x40,%eax
80108791:	89 c2                	mov    %eax,%edx
80108793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108796:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108798:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010879b:	8b 10                	mov    (%eax),%edx
8010879d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a0:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
801087a2:	83 ec 0c             	sub    $0xc,%esp
801087a5:	68 d0 c2 10 80       	push   $0x8010c2d0
801087aa:	e8 45 7c ff ff       	call   801003f4 <cprintf>
801087af:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801087b2:	e8 4e a0 ff ff       	call   80102805 <kalloc>
801087b7:	a3 78 6b 19 80       	mov    %eax,0x80196b78
  *intr_addr = 0;
801087bc:	a1 78 6b 19 80       	mov    0x80196b78,%eax
801087c1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
801087c7:	a1 78 6b 19 80       	mov    0x80196b78,%eax
801087cc:	83 ec 08             	sub    $0x8,%esp
801087cf:	50                   	push   %eax
801087d0:	68 f2 c2 10 80       	push   $0x8010c2f2
801087d5:	e8 1a 7c ff ff       	call   801003f4 <cprintf>
801087da:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
801087dd:	e8 50 00 00 00       	call   80108832 <i8254_init_recv>
  i8254_init_send();
801087e2:	e8 69 03 00 00       	call   80108b50 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
801087e7:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801087ee:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
801087f1:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801087f8:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
801087fb:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108802:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108805:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010880c:	0f b6 c0             	movzbl %al,%eax
8010880f:	83 ec 0c             	sub    $0xc,%esp
80108812:	53                   	push   %ebx
80108813:	51                   	push   %ecx
80108814:	52                   	push   %edx
80108815:	50                   	push   %eax
80108816:	68 00 c3 10 80       	push   $0x8010c300
8010881b:	e8 d4 7b ff ff       	call   801003f4 <cprintf>
80108820:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108823:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108826:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
8010882c:	90                   	nop
8010882d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108830:	c9                   	leave
80108831:	c3                   	ret

80108832 <i8254_init_recv>:

void i8254_init_recv(){
80108832:	55                   	push   %ebp
80108833:	89 e5                	mov    %esp,%ebp
80108835:	57                   	push   %edi
80108836:	56                   	push   %esi
80108837:	53                   	push   %ebx
80108838:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
8010883b:	83 ec 0c             	sub    $0xc,%esp
8010883e:	6a 00                	push   $0x0
80108840:	e8 e8 04 00 00       	call   80108d2d <i8254_read_eeprom>
80108845:	83 c4 10             	add    $0x10,%esp
80108848:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
8010884b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010884e:	a2 70 6b 19 80       	mov    %al,0x80196b70
  mac_addr[1] = data_l>>8;
80108853:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108856:	c1 e8 08             	shr    $0x8,%eax
80108859:	a2 71 6b 19 80       	mov    %al,0x80196b71
  uint data_m = i8254_read_eeprom(0x1);
8010885e:	83 ec 0c             	sub    $0xc,%esp
80108861:	6a 01                	push   $0x1
80108863:	e8 c5 04 00 00       	call   80108d2d <i8254_read_eeprom>
80108868:	83 c4 10             	add    $0x10,%esp
8010886b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
8010886e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108871:	a2 72 6b 19 80       	mov    %al,0x80196b72
  mac_addr[3] = data_m>>8;
80108876:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108879:	c1 e8 08             	shr    $0x8,%eax
8010887c:	a2 73 6b 19 80       	mov    %al,0x80196b73
  uint data_h = i8254_read_eeprom(0x2);
80108881:	83 ec 0c             	sub    $0xc,%esp
80108884:	6a 02                	push   $0x2
80108886:	e8 a2 04 00 00       	call   80108d2d <i8254_read_eeprom>
8010888b:	83 c4 10             	add    $0x10,%esp
8010888e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108891:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108894:	a2 74 6b 19 80       	mov    %al,0x80196b74
  mac_addr[5] = data_h>>8;
80108899:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010889c:	c1 e8 08             	shr    $0x8,%eax
8010889f:	a2 75 6b 19 80       	mov    %al,0x80196b75
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
801088a4:	0f b6 05 75 6b 19 80 	movzbl 0x80196b75,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801088ab:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
801088ae:	0f b6 05 74 6b 19 80 	movzbl 0x80196b74,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801088b5:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
801088b8:	0f b6 05 73 6b 19 80 	movzbl 0x80196b73,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801088bf:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
801088c2:	0f b6 05 72 6b 19 80 	movzbl 0x80196b72,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801088c9:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
801088cc:	0f b6 05 71 6b 19 80 	movzbl 0x80196b71,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801088d3:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
801088d6:	0f b6 05 70 6b 19 80 	movzbl 0x80196b70,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801088dd:	0f b6 c0             	movzbl %al,%eax
801088e0:	83 ec 04             	sub    $0x4,%esp
801088e3:	57                   	push   %edi
801088e4:	56                   	push   %esi
801088e5:	53                   	push   %ebx
801088e6:	51                   	push   %ecx
801088e7:	52                   	push   %edx
801088e8:	50                   	push   %eax
801088e9:	68 18 c3 10 80       	push   $0x8010c318
801088ee:	e8 01 7b ff ff       	call   801003f4 <cprintf>
801088f3:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
801088f6:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
801088fb:	05 00 54 00 00       	add    $0x5400,%eax
80108900:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108903:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108908:	05 04 54 00 00       	add    $0x5404,%eax
8010890d:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108910:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108913:	c1 e0 10             	shl    $0x10,%eax
80108916:	0b 45 d8             	or     -0x28(%ebp),%eax
80108919:	89 c2                	mov    %eax,%edx
8010891b:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010891e:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108920:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108923:	0d 00 00 00 80       	or     $0x80000000,%eax
80108928:	89 c2                	mov    %eax,%edx
8010892a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010892d:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
8010892f:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108934:	05 00 52 00 00       	add    $0x5200,%eax
80108939:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
8010893c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108943:	eb 19                	jmp    8010895e <i8254_init_recv+0x12c>
    mta[i] = 0;
80108945:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108948:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010894f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108952:	01 d0                	add    %edx,%eax
80108954:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
8010895a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010895e:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108962:	7e e1                	jle    80108945 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108964:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108969:	05 d0 00 00 00       	add    $0xd0,%eax
8010896e:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108971:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108974:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
8010897a:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
8010897f:	05 c8 00 00 00       	add    $0xc8,%eax
80108984:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108987:	8b 45 bc             	mov    -0x44(%ebp),%eax
8010898a:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108990:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108995:	05 28 28 00 00       	add    $0x2828,%eax
8010899a:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
8010899d:	8b 45 b8             	mov    -0x48(%ebp),%eax
801089a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
801089a6:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
801089ab:	05 00 01 00 00       	add    $0x100,%eax
801089b0:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
801089b3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801089b6:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
801089bc:	e8 44 9e ff ff       	call   80102805 <kalloc>
801089c1:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
801089c4:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
801089c9:	05 00 28 00 00       	add    $0x2800,%eax
801089ce:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
801089d1:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
801089d6:	05 04 28 00 00       	add    $0x2804,%eax
801089db:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
801089de:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
801089e3:	05 08 28 00 00       	add    $0x2808,%eax
801089e8:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
801089eb:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
801089f0:	05 10 28 00 00       	add    $0x2810,%eax
801089f5:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801089f8:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
801089fd:	05 18 28 00 00       	add    $0x2818,%eax
80108a02:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108a05:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108a08:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108a0e:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108a11:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108a13:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108a16:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108a1c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108a1f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108a25:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108a28:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108a2e:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108a31:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108a37:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108a3a:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108a3d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108a44:	eb 73                	jmp    80108ab9 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108a46:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a49:	c1 e0 04             	shl    $0x4,%eax
80108a4c:	89 c2                	mov    %eax,%edx
80108a4e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a51:	01 d0                	add    %edx,%eax
80108a53:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108a5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a5d:	c1 e0 04             	shl    $0x4,%eax
80108a60:	89 c2                	mov    %eax,%edx
80108a62:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a65:	01 d0                	add    %edx,%eax
80108a67:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108a6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a70:	c1 e0 04             	shl    $0x4,%eax
80108a73:	89 c2                	mov    %eax,%edx
80108a75:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a78:	01 d0                	add    %edx,%eax
80108a7a:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108a80:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a83:	c1 e0 04             	shl    $0x4,%eax
80108a86:	89 c2                	mov    %eax,%edx
80108a88:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a8b:	01 d0                	add    %edx,%eax
80108a8d:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108a91:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a94:	c1 e0 04             	shl    $0x4,%eax
80108a97:	89 c2                	mov    %eax,%edx
80108a99:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a9c:	01 d0                	add    %edx,%eax
80108a9e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108aa2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108aa5:	c1 e0 04             	shl    $0x4,%eax
80108aa8:	89 c2                	mov    %eax,%edx
80108aaa:	8b 45 98             	mov    -0x68(%ebp),%eax
80108aad:	01 d0                	add    %edx,%eax
80108aaf:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108ab5:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108ab9:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108ac0:	7e 84                	jle    80108a46 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108ac2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108ac9:	eb 57                	jmp    80108b22 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108acb:	e8 35 9d ff ff       	call   80102805 <kalloc>
80108ad0:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108ad3:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108ad7:	75 12                	jne    80108aeb <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108ad9:	83 ec 0c             	sub    $0xc,%esp
80108adc:	68 38 c3 10 80       	push   $0x8010c338
80108ae1:	e8 0e 79 ff ff       	call   801003f4 <cprintf>
80108ae6:	83 c4 10             	add    $0x10,%esp
      break;
80108ae9:	eb 3d                	jmp    80108b28 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108aeb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108aee:	c1 e0 04             	shl    $0x4,%eax
80108af1:	89 c2                	mov    %eax,%edx
80108af3:	8b 45 98             	mov    -0x68(%ebp),%eax
80108af6:	01 d0                	add    %edx,%eax
80108af8:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108afb:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108b01:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108b03:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108b06:	83 c0 01             	add    $0x1,%eax
80108b09:	c1 e0 04             	shl    $0x4,%eax
80108b0c:	89 c2                	mov    %eax,%edx
80108b0e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108b11:	01 d0                	add    %edx,%eax
80108b13:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108b16:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108b1c:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108b1e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108b22:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108b26:	7e a3                	jle    80108acb <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108b28:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108b2b:	8b 00                	mov    (%eax),%eax
80108b2d:	83 c8 02             	or     $0x2,%eax
80108b30:	89 c2                	mov    %eax,%edx
80108b32:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108b35:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108b37:	83 ec 0c             	sub    $0xc,%esp
80108b3a:	68 58 c3 10 80       	push   $0x8010c358
80108b3f:	e8 b0 78 ff ff       	call   801003f4 <cprintf>
80108b44:	83 c4 10             	add    $0x10,%esp
}
80108b47:	90                   	nop
80108b48:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108b4b:	5b                   	pop    %ebx
80108b4c:	5e                   	pop    %esi
80108b4d:	5f                   	pop    %edi
80108b4e:	5d                   	pop    %ebp
80108b4f:	c3                   	ret

80108b50 <i8254_init_send>:

void i8254_init_send(){
80108b50:	55                   	push   %ebp
80108b51:	89 e5                	mov    %esp,%ebp
80108b53:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108b56:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108b5b:	05 28 38 00 00       	add    $0x3828,%eax
80108b60:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108b63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b66:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108b6c:	e8 94 9c ff ff       	call   80102805 <kalloc>
80108b71:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108b74:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108b79:	05 00 38 00 00       	add    $0x3800,%eax
80108b7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108b81:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108b86:	05 04 38 00 00       	add    $0x3804,%eax
80108b8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108b8e:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108b93:	05 08 38 00 00       	add    $0x3808,%eax
80108b98:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108b9b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b9e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108ba4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ba7:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108ba9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108bb2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108bb5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108bbb:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108bc0:	05 10 38 00 00       	add    $0x3810,%eax
80108bc5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108bc8:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108bcd:	05 18 38 00 00       	add    $0x3818,%eax
80108bd2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108bd5:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108bd8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108bde:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108be1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108be7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bea:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108bed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108bf4:	e9 82 00 00 00       	jmp    80108c7b <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bfc:	c1 e0 04             	shl    $0x4,%eax
80108bff:	89 c2                	mov    %eax,%edx
80108c01:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c04:	01 d0                	add    %edx,%eax
80108c06:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c10:	c1 e0 04             	shl    $0x4,%eax
80108c13:	89 c2                	mov    %eax,%edx
80108c15:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c18:	01 d0                	add    %edx,%eax
80108c1a:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c23:	c1 e0 04             	shl    $0x4,%eax
80108c26:	89 c2                	mov    %eax,%edx
80108c28:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c2b:	01 d0                	add    %edx,%eax
80108c2d:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c34:	c1 e0 04             	shl    $0x4,%eax
80108c37:	89 c2                	mov    %eax,%edx
80108c39:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c3c:	01 d0                	add    %edx,%eax
80108c3e:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c45:	c1 e0 04             	shl    $0x4,%eax
80108c48:	89 c2                	mov    %eax,%edx
80108c4a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c4d:	01 d0                	add    %edx,%eax
80108c4f:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c56:	c1 e0 04             	shl    $0x4,%eax
80108c59:	89 c2                	mov    %eax,%edx
80108c5b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c5e:	01 d0                	add    %edx,%eax
80108c60:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c67:	c1 e0 04             	shl    $0x4,%eax
80108c6a:	89 c2                	mov    %eax,%edx
80108c6c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c6f:	01 d0                	add    %edx,%eax
80108c71:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108c77:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108c7b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108c82:	0f 8e 71 ff ff ff    	jle    80108bf9 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108c88:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108c8f:	eb 57                	jmp    80108ce8 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108c91:	e8 6f 9b ff ff       	call   80102805 <kalloc>
80108c96:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108c99:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108c9d:	75 12                	jne    80108cb1 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108c9f:	83 ec 0c             	sub    $0xc,%esp
80108ca2:	68 38 c3 10 80       	push   $0x8010c338
80108ca7:	e8 48 77 ff ff       	call   801003f4 <cprintf>
80108cac:	83 c4 10             	add    $0x10,%esp
      break;
80108caf:	eb 3d                	jmp    80108cee <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cb4:	c1 e0 04             	shl    $0x4,%eax
80108cb7:	89 c2                	mov    %eax,%edx
80108cb9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cbc:	01 d0                	add    %edx,%eax
80108cbe:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108cc1:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108cc7:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108cc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ccc:	83 c0 01             	add    $0x1,%eax
80108ccf:	c1 e0 04             	shl    $0x4,%eax
80108cd2:	89 c2                	mov    %eax,%edx
80108cd4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cd7:	01 d0                	add    %edx,%eax
80108cd9:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108cdc:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108ce2:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108ce4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108ce8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108cec:	7e a3                	jle    80108c91 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108cee:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108cf3:	05 00 04 00 00       	add    $0x400,%eax
80108cf8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108cfb:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108cfe:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108d04:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108d09:	05 10 04 00 00       	add    $0x410,%eax
80108d0e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108d11:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108d14:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108d1a:	83 ec 0c             	sub    $0xc,%esp
80108d1d:	68 78 c3 10 80       	push   $0x8010c378
80108d22:	e8 cd 76 ff ff       	call   801003f4 <cprintf>
80108d27:	83 c4 10             	add    $0x10,%esp

}
80108d2a:	90                   	nop
80108d2b:	c9                   	leave
80108d2c:	c3                   	ret

80108d2d <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108d2d:	55                   	push   %ebp
80108d2e:	89 e5                	mov    %esp,%ebp
80108d30:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108d33:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108d38:	83 c0 14             	add    $0x14,%eax
80108d3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108d3e:	8b 45 08             	mov    0x8(%ebp),%eax
80108d41:	c1 e0 08             	shl    $0x8,%eax
80108d44:	0f b7 c0             	movzwl %ax,%eax
80108d47:	83 c8 01             	or     $0x1,%eax
80108d4a:	89 c2                	mov    %eax,%edx
80108d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d4f:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108d51:	83 ec 0c             	sub    $0xc,%esp
80108d54:	68 98 c3 10 80       	push   $0x8010c398
80108d59:	e8 96 76 ff ff       	call   801003f4 <cprintf>
80108d5e:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d64:	8b 00                	mov    (%eax),%eax
80108d66:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d6c:	83 e0 10             	and    $0x10,%eax
80108d6f:	85 c0                	test   %eax,%eax
80108d71:	75 02                	jne    80108d75 <i8254_read_eeprom+0x48>
  while(1){
80108d73:	eb dc                	jmp    80108d51 <i8254_read_eeprom+0x24>
      break;
80108d75:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d79:	8b 00                	mov    (%eax),%eax
80108d7b:	c1 e8 10             	shr    $0x10,%eax
}
80108d7e:	c9                   	leave
80108d7f:	c3                   	ret

80108d80 <i8254_recv>:
void i8254_recv(){
80108d80:	55                   	push   %ebp
80108d81:	89 e5                	mov    %esp,%ebp
80108d83:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108d86:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108d8b:	05 10 28 00 00       	add    $0x2810,%eax
80108d90:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108d93:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108d98:	05 18 28 00 00       	add    $0x2818,%eax
80108d9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108da0:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108da5:	05 00 28 00 00       	add    $0x2800,%eax
80108daa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108dad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108db0:	8b 00                	mov    (%eax),%eax
80108db2:	05 00 00 00 80       	add    $0x80000000,%eax
80108db7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dbd:	8b 10                	mov    (%eax),%edx
80108dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dc2:	8b 00                	mov    (%eax),%eax
80108dc4:	29 c2                	sub    %eax,%edx
80108dc6:	89 d0                	mov    %edx,%eax
80108dc8:	25 ff 00 00 00       	and    $0xff,%eax
80108dcd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108dd0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108dd4:	7e 37                	jle    80108e0d <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108dd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dd9:	8b 00                	mov    (%eax),%eax
80108ddb:	c1 e0 04             	shl    $0x4,%eax
80108dde:	89 c2                	mov    %eax,%edx
80108de0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108de3:	01 d0                	add    %edx,%eax
80108de5:	8b 00                	mov    (%eax),%eax
80108de7:	05 00 00 00 80       	add    $0x80000000,%eax
80108dec:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108def:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108df2:	8b 00                	mov    (%eax),%eax
80108df4:	83 c0 01             	add    $0x1,%eax
80108df7:	0f b6 d0             	movzbl %al,%edx
80108dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dfd:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108dff:	83 ec 0c             	sub    $0xc,%esp
80108e02:	ff 75 e0             	push   -0x20(%ebp)
80108e05:	e8 13 09 00 00       	call   8010971d <eth_proc>
80108e0a:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e10:	8b 10                	mov    (%eax),%edx
80108e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e15:	8b 00                	mov    (%eax),%eax
80108e17:	39 c2                	cmp    %eax,%edx
80108e19:	75 9f                	jne    80108dba <i8254_recv+0x3a>
      (*rdt)--;
80108e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e1e:	8b 00                	mov    (%eax),%eax
80108e20:	8d 50 ff             	lea    -0x1(%eax),%edx
80108e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e26:	89 10                	mov    %edx,(%eax)
  while(1){
80108e28:	eb 90                	jmp    80108dba <i8254_recv+0x3a>

80108e2a <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108e2a:	55                   	push   %ebp
80108e2b:	89 e5                	mov    %esp,%ebp
80108e2d:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108e30:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108e35:	05 10 38 00 00       	add    $0x3810,%eax
80108e3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108e3d:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108e42:	05 18 38 00 00       	add    $0x3818,%eax
80108e47:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108e4a:	a1 6c 6b 19 80       	mov    0x80196b6c,%eax
80108e4f:	05 00 38 00 00       	add    $0x3800,%eax
80108e54:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108e57:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e5a:	8b 00                	mov    (%eax),%eax
80108e5c:	05 00 00 00 80       	add    $0x80000000,%eax
80108e61:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108e64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e67:	8b 10                	mov    (%eax),%edx
80108e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e6c:	8b 00                	mov    (%eax),%eax
80108e6e:	29 c2                	sub    %eax,%edx
80108e70:	0f b6 c2             	movzbl %dl,%eax
80108e73:	ba 00 01 00 00       	mov    $0x100,%edx
80108e78:	29 c2                	sub    %eax,%edx
80108e7a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108e7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e80:	8b 00                	mov    (%eax),%eax
80108e82:	25 ff 00 00 00       	and    $0xff,%eax
80108e87:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108e8a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108e8e:	0f 8e a8 00 00 00    	jle    80108f3c <i8254_send+0x112>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108e94:	8b 45 08             	mov    0x8(%ebp),%eax
80108e97:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108e9a:	89 d1                	mov    %edx,%ecx
80108e9c:	c1 e1 04             	shl    $0x4,%ecx
80108e9f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108ea2:	01 ca                	add    %ecx,%edx
80108ea4:	8b 12                	mov    (%edx),%edx
80108ea6:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108eac:	83 ec 04             	sub    $0x4,%esp
80108eaf:	ff 75 0c             	push   0xc(%ebp)
80108eb2:	50                   	push   %eax
80108eb3:	52                   	push   %edx
80108eb4:	e8 3d bd ff ff       	call   80104bf6 <memmove>
80108eb9:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108ebc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ebf:	c1 e0 04             	shl    $0x4,%eax
80108ec2:	89 c2                	mov    %eax,%edx
80108ec4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ec7:	01 d0                	add    %edx,%eax
80108ec9:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ecc:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108ed0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ed3:	c1 e0 04             	shl    $0x4,%eax
80108ed6:	89 c2                	mov    %eax,%edx
80108ed8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108edb:	01 d0                	add    %edx,%eax
80108edd:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108ee1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ee4:	c1 e0 04             	shl    $0x4,%eax
80108ee7:	89 c2                	mov    %eax,%edx
80108ee9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108eec:	01 d0                	add    %edx,%eax
80108eee:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108ef2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ef5:	c1 e0 04             	shl    $0x4,%eax
80108ef8:	89 c2                	mov    %eax,%edx
80108efa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108efd:	01 d0                	add    %edx,%eax
80108eff:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108f03:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f06:	c1 e0 04             	shl    $0x4,%eax
80108f09:	89 c2                	mov    %eax,%edx
80108f0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f0e:	01 d0                	add    %edx,%eax
80108f10:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108f16:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f19:	c1 e0 04             	shl    $0x4,%eax
80108f1c:	89 c2                	mov    %eax,%edx
80108f1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f21:	01 d0                	add    %edx,%eax
80108f23:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108f27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f2a:	8b 00                	mov    (%eax),%eax
80108f2c:	83 c0 01             	add    $0x1,%eax
80108f2f:	0f b6 d0             	movzbl %al,%edx
80108f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f35:	89 10                	mov    %edx,(%eax)
    return len;
80108f37:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f3a:	eb 05                	jmp    80108f41 <i8254_send+0x117>
  }else{
    return -1;
80108f3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108f41:	c9                   	leave
80108f42:	c3                   	ret

80108f43 <i8254_intr>:

void i8254_intr(){
80108f43:	55                   	push   %ebp
80108f44:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108f46:	a1 78 6b 19 80       	mov    0x80196b78,%eax
80108f4b:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108f51:	90                   	nop
80108f52:	5d                   	pop    %ebp
80108f53:	c3                   	ret

80108f54 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108f54:	55                   	push   %ebp
80108f55:	89 e5                	mov    %esp,%ebp
80108f57:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80108f5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f63:	0f b7 00             	movzwl (%eax),%eax
80108f66:	66 3d 00 01          	cmp    $0x100,%ax
80108f6a:	74 0a                	je     80108f76 <arp_proc+0x22>
80108f6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f71:	e9 4f 01 00 00       	jmp    801090c5 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f79:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108f7d:	66 83 f8 08          	cmp    $0x8,%ax
80108f81:	74 0a                	je     80108f8d <arp_proc+0x39>
80108f83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f88:	e9 38 01 00 00       	jmp    801090c5 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f90:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108f94:	3c 06                	cmp    $0x6,%al
80108f96:	74 0a                	je     80108fa2 <arp_proc+0x4e>
80108f98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f9d:	e9 23 01 00 00       	jmp    801090c5 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fa5:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108fa9:	3c 04                	cmp    $0x4,%al
80108fab:	74 0a                	je     80108fb7 <arp_proc+0x63>
80108fad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108fb2:	e9 0e 01 00 00       	jmp    801090c5 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fba:	83 c0 18             	add    $0x18,%eax
80108fbd:	83 ec 04             	sub    $0x4,%esp
80108fc0:	6a 04                	push   $0x4
80108fc2:	50                   	push   %eax
80108fc3:	68 e4 f4 10 80       	push   $0x8010f4e4
80108fc8:	e8 d1 bb ff ff       	call   80104b9e <memcmp>
80108fcd:	83 c4 10             	add    $0x10,%esp
80108fd0:	85 c0                	test   %eax,%eax
80108fd2:	74 27                	je     80108ffb <arp_proc+0xa7>
80108fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fd7:	83 c0 0e             	add    $0xe,%eax
80108fda:	83 ec 04             	sub    $0x4,%esp
80108fdd:	6a 04                	push   $0x4
80108fdf:	50                   	push   %eax
80108fe0:	68 e4 f4 10 80       	push   $0x8010f4e4
80108fe5:	e8 b4 bb ff ff       	call   80104b9e <memcmp>
80108fea:	83 c4 10             	add    $0x10,%esp
80108fed:	85 c0                	test   %eax,%eax
80108fef:	74 0a                	je     80108ffb <arp_proc+0xa7>
80108ff1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ff6:	e9 ca 00 00 00       	jmp    801090c5 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ffe:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109002:	66 3d 00 01          	cmp    $0x100,%ax
80109006:	75 69                	jne    80109071 <arp_proc+0x11d>
80109008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010900b:	83 c0 18             	add    $0x18,%eax
8010900e:	83 ec 04             	sub    $0x4,%esp
80109011:	6a 04                	push   $0x4
80109013:	50                   	push   %eax
80109014:	68 e4 f4 10 80       	push   $0x8010f4e4
80109019:	e8 80 bb ff ff       	call   80104b9e <memcmp>
8010901e:	83 c4 10             	add    $0x10,%esp
80109021:	85 c0                	test   %eax,%eax
80109023:	75 4c                	jne    80109071 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80109025:	e8 db 97 ff ff       	call   80102805 <kalloc>
8010902a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
8010902d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109034:	83 ec 04             	sub    $0x4,%esp
80109037:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010903a:	50                   	push   %eax
8010903b:	ff 75 f0             	push   -0x10(%ebp)
8010903e:	ff 75 f4             	push   -0xc(%ebp)
80109041:	e8 1f 04 00 00       	call   80109465 <arp_reply_pkt_create>
80109046:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109049:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010904c:	83 ec 08             	sub    $0x8,%esp
8010904f:	50                   	push   %eax
80109050:	ff 75 f0             	push   -0x10(%ebp)
80109053:	e8 d2 fd ff ff       	call   80108e2a <i8254_send>
80109058:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
8010905b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010905e:	83 ec 0c             	sub    $0xc,%esp
80109061:	50                   	push   %eax
80109062:	e8 04 97 ff ff       	call   8010276b <kfree>
80109067:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010906a:	b8 02 00 00 00       	mov    $0x2,%eax
8010906f:	eb 54                	jmp    801090c5 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109074:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109078:	66 3d 00 02          	cmp    $0x200,%ax
8010907c:	75 42                	jne    801090c0 <arp_proc+0x16c>
8010907e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109081:	83 c0 18             	add    $0x18,%eax
80109084:	83 ec 04             	sub    $0x4,%esp
80109087:	6a 04                	push   $0x4
80109089:	50                   	push   %eax
8010908a:	68 e4 f4 10 80       	push   $0x8010f4e4
8010908f:	e8 0a bb ff ff       	call   80104b9e <memcmp>
80109094:	83 c4 10             	add    $0x10,%esp
80109097:	85 c0                	test   %eax,%eax
80109099:	75 25                	jne    801090c0 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
8010909b:	83 ec 0c             	sub    $0xc,%esp
8010909e:	68 9c c3 10 80       	push   $0x8010c39c
801090a3:	e8 4c 73 ff ff       	call   801003f4 <cprintf>
801090a8:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801090ab:	83 ec 0c             	sub    $0xc,%esp
801090ae:	ff 75 f4             	push   -0xc(%ebp)
801090b1:	e8 af 01 00 00       	call   80109265 <arp_table_update>
801090b6:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
801090b9:	b8 01 00 00 00       	mov    $0x1,%eax
801090be:	eb 05                	jmp    801090c5 <arp_proc+0x171>
  }else{
    return -1;
801090c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
801090c5:	c9                   	leave
801090c6:	c3                   	ret

801090c7 <arp_scan>:

void arp_scan(){
801090c7:	55                   	push   %ebp
801090c8:	89 e5                	mov    %esp,%ebp
801090ca:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
801090cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801090d4:	eb 6f                	jmp    80109145 <arp_scan+0x7e>
    uint send = (uint)kalloc();
801090d6:	e8 2a 97 ff ff       	call   80102805 <kalloc>
801090db:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801090de:	83 ec 04             	sub    $0x4,%esp
801090e1:	ff 75 f4             	push   -0xc(%ebp)
801090e4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801090e7:	50                   	push   %eax
801090e8:	ff 75 ec             	push   -0x14(%ebp)
801090eb:	e8 62 00 00 00       	call   80109152 <arp_broadcast>
801090f0:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
801090f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090f6:	83 ec 08             	sub    $0x8,%esp
801090f9:	50                   	push   %eax
801090fa:	ff 75 ec             	push   -0x14(%ebp)
801090fd:	e8 28 fd ff ff       	call   80108e2a <i8254_send>
80109102:	83 c4 10             	add    $0x10,%esp
80109105:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109108:	eb 22                	jmp    8010912c <arp_scan+0x65>
      microdelay(1);
8010910a:	83 ec 0c             	sub    $0xc,%esp
8010910d:	6a 01                	push   $0x1
8010910f:	e8 82 9a ff ff       	call   80102b96 <microdelay>
80109114:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109117:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010911a:	83 ec 08             	sub    $0x8,%esp
8010911d:	50                   	push   %eax
8010911e:	ff 75 ec             	push   -0x14(%ebp)
80109121:	e8 04 fd ff ff       	call   80108e2a <i8254_send>
80109126:	83 c4 10             	add    $0x10,%esp
80109129:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010912c:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109130:	74 d8                	je     8010910a <arp_scan+0x43>
    }
    kfree((char *)send);
80109132:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109135:	83 ec 0c             	sub    $0xc,%esp
80109138:	50                   	push   %eax
80109139:	e8 2d 96 ff ff       	call   8010276b <kfree>
8010913e:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109141:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109145:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010914c:	7e 88                	jle    801090d6 <arp_scan+0xf>
  }
}
8010914e:	90                   	nop
8010914f:	90                   	nop
80109150:	c9                   	leave
80109151:	c3                   	ret

80109152 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109152:	55                   	push   %ebp
80109153:	89 e5                	mov    %esp,%ebp
80109155:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109158:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
8010915c:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109160:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109164:	8b 45 10             	mov    0x10(%ebp),%eax
80109167:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
8010916a:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109171:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109177:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010917e:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109184:	8b 45 0c             	mov    0xc(%ebp),%eax
80109187:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010918d:	8b 45 08             	mov    0x8(%ebp),%eax
80109190:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109193:	8b 45 08             	mov    0x8(%ebp),%eax
80109196:	83 c0 0e             	add    $0xe,%eax
80109199:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
8010919c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010919f:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801091a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091a6:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801091aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ad:	83 ec 04             	sub    $0x4,%esp
801091b0:	6a 06                	push   $0x6
801091b2:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801091b5:	52                   	push   %edx
801091b6:	50                   	push   %eax
801091b7:	e8 3a ba ff ff       	call   80104bf6 <memmove>
801091bc:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801091bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c2:	83 c0 06             	add    $0x6,%eax
801091c5:	83 ec 04             	sub    $0x4,%esp
801091c8:	6a 06                	push   $0x6
801091ca:	68 70 6b 19 80       	push   $0x80196b70
801091cf:	50                   	push   %eax
801091d0:	e8 21 ba ff ff       	call   80104bf6 <memmove>
801091d5:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801091d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091db:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801091e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091e3:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801091e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091ec:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801091f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091f3:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801091f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091fa:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109200:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109203:	8d 50 12             	lea    0x12(%eax),%edx
80109206:	83 ec 04             	sub    $0x4,%esp
80109209:	6a 06                	push   $0x6
8010920b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010920e:	50                   	push   %eax
8010920f:	52                   	push   %edx
80109210:	e8 e1 b9 ff ff       	call   80104bf6 <memmove>
80109215:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109218:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010921b:	8d 50 18             	lea    0x18(%eax),%edx
8010921e:	83 ec 04             	sub    $0x4,%esp
80109221:	6a 04                	push   $0x4
80109223:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109226:	50                   	push   %eax
80109227:	52                   	push   %edx
80109228:	e8 c9 b9 ff ff       	call   80104bf6 <memmove>
8010922d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109230:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109233:	83 c0 08             	add    $0x8,%eax
80109236:	83 ec 04             	sub    $0x4,%esp
80109239:	6a 06                	push   $0x6
8010923b:	68 70 6b 19 80       	push   $0x80196b70
80109240:	50                   	push   %eax
80109241:	e8 b0 b9 ff ff       	call   80104bf6 <memmove>
80109246:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109249:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010924c:	83 c0 0e             	add    $0xe,%eax
8010924f:	83 ec 04             	sub    $0x4,%esp
80109252:	6a 04                	push   $0x4
80109254:	68 e4 f4 10 80       	push   $0x8010f4e4
80109259:	50                   	push   %eax
8010925a:	e8 97 b9 ff ff       	call   80104bf6 <memmove>
8010925f:	83 c4 10             	add    $0x10,%esp
}
80109262:	90                   	nop
80109263:	c9                   	leave
80109264:	c3                   	ret

80109265 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109265:	55                   	push   %ebp
80109266:	89 e5                	mov    %esp,%ebp
80109268:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
8010926b:	8b 45 08             	mov    0x8(%ebp),%eax
8010926e:	83 c0 0e             	add    $0xe,%eax
80109271:	83 ec 0c             	sub    $0xc,%esp
80109274:	50                   	push   %eax
80109275:	e8 bc 00 00 00       	call   80109336 <arp_table_search>
8010927a:	83 c4 10             	add    $0x10,%esp
8010927d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109280:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109284:	78 2d                	js     801092b3 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109286:	8b 45 08             	mov    0x8(%ebp),%eax
80109289:	8d 48 08             	lea    0x8(%eax),%ecx
8010928c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010928f:	89 d0                	mov    %edx,%eax
80109291:	c1 e0 02             	shl    $0x2,%eax
80109294:	01 d0                	add    %edx,%eax
80109296:	01 c0                	add    %eax,%eax
80109298:	01 d0                	add    %edx,%eax
8010929a:	05 80 6b 19 80       	add    $0x80196b80,%eax
8010929f:	83 c0 04             	add    $0x4,%eax
801092a2:	83 ec 04             	sub    $0x4,%esp
801092a5:	6a 06                	push   $0x6
801092a7:	51                   	push   %ecx
801092a8:	50                   	push   %eax
801092a9:	e8 48 b9 ff ff       	call   80104bf6 <memmove>
801092ae:	83 c4 10             	add    $0x10,%esp
801092b1:	eb 70                	jmp    80109323 <arp_table_update+0xbe>
  }else{
    index += 1;
801092b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801092b7:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801092ba:	8b 45 08             	mov    0x8(%ebp),%eax
801092bd:	8d 48 08             	lea    0x8(%eax),%ecx
801092c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801092c3:	89 d0                	mov    %edx,%eax
801092c5:	c1 e0 02             	shl    $0x2,%eax
801092c8:	01 d0                	add    %edx,%eax
801092ca:	01 c0                	add    %eax,%eax
801092cc:	01 d0                	add    %edx,%eax
801092ce:	05 80 6b 19 80       	add    $0x80196b80,%eax
801092d3:	83 c0 04             	add    $0x4,%eax
801092d6:	83 ec 04             	sub    $0x4,%esp
801092d9:	6a 06                	push   $0x6
801092db:	51                   	push   %ecx
801092dc:	50                   	push   %eax
801092dd:	e8 14 b9 ff ff       	call   80104bf6 <memmove>
801092e2:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801092e5:	8b 45 08             	mov    0x8(%ebp),%eax
801092e8:	8d 48 0e             	lea    0xe(%eax),%ecx
801092eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801092ee:	89 d0                	mov    %edx,%eax
801092f0:	c1 e0 02             	shl    $0x2,%eax
801092f3:	01 d0                	add    %edx,%eax
801092f5:	01 c0                	add    %eax,%eax
801092f7:	01 d0                	add    %edx,%eax
801092f9:	05 80 6b 19 80       	add    $0x80196b80,%eax
801092fe:	83 ec 04             	sub    $0x4,%esp
80109301:	6a 04                	push   $0x4
80109303:	51                   	push   %ecx
80109304:	50                   	push   %eax
80109305:	e8 ec b8 ff ff       	call   80104bf6 <memmove>
8010930a:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
8010930d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109310:	89 d0                	mov    %edx,%eax
80109312:	c1 e0 02             	shl    $0x2,%eax
80109315:	01 d0                	add    %edx,%eax
80109317:	01 c0                	add    %eax,%eax
80109319:	01 d0                	add    %edx,%eax
8010931b:	05 8a 6b 19 80       	add    $0x80196b8a,%eax
80109320:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109323:	83 ec 0c             	sub    $0xc,%esp
80109326:	68 80 6b 19 80       	push   $0x80196b80
8010932b:	e8 83 00 00 00       	call   801093b3 <print_arp_table>
80109330:	83 c4 10             	add    $0x10,%esp
}
80109333:	90                   	nop
80109334:	c9                   	leave
80109335:	c3                   	ret

80109336 <arp_table_search>:

int arp_table_search(uchar *ip){
80109336:	55                   	push   %ebp
80109337:	89 e5                	mov    %esp,%ebp
80109339:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
8010933c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109343:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010934a:	eb 59                	jmp    801093a5 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
8010934c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010934f:	89 d0                	mov    %edx,%eax
80109351:	c1 e0 02             	shl    $0x2,%eax
80109354:	01 d0                	add    %edx,%eax
80109356:	01 c0                	add    %eax,%eax
80109358:	01 d0                	add    %edx,%eax
8010935a:	05 80 6b 19 80       	add    $0x80196b80,%eax
8010935f:	83 ec 04             	sub    $0x4,%esp
80109362:	6a 04                	push   $0x4
80109364:	ff 75 08             	push   0x8(%ebp)
80109367:	50                   	push   %eax
80109368:	e8 31 b8 ff ff       	call   80104b9e <memcmp>
8010936d:	83 c4 10             	add    $0x10,%esp
80109370:	85 c0                	test   %eax,%eax
80109372:	75 05                	jne    80109379 <arp_table_search+0x43>
      return i;
80109374:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109377:	eb 38                	jmp    801093b1 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109379:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010937c:	89 d0                	mov    %edx,%eax
8010937e:	c1 e0 02             	shl    $0x2,%eax
80109381:	01 d0                	add    %edx,%eax
80109383:	01 c0                	add    %eax,%eax
80109385:	01 d0                	add    %edx,%eax
80109387:	05 8a 6b 19 80       	add    $0x80196b8a,%eax
8010938c:	0f b6 00             	movzbl (%eax),%eax
8010938f:	84 c0                	test   %al,%al
80109391:	75 0e                	jne    801093a1 <arp_table_search+0x6b>
80109393:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109397:	75 08                	jne    801093a1 <arp_table_search+0x6b>
      empty = -i;
80109399:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010939c:	f7 d8                	neg    %eax
8010939e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801093a1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801093a5:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801093a9:	7e a1                	jle    8010934c <arp_table_search+0x16>
    }
  }
  return empty-1;
801093ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093ae:	83 e8 01             	sub    $0x1,%eax
}
801093b1:	c9                   	leave
801093b2:	c3                   	ret

801093b3 <print_arp_table>:

void print_arp_table(){
801093b3:	55                   	push   %ebp
801093b4:	89 e5                	mov    %esp,%ebp
801093b6:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801093b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801093c0:	e9 92 00 00 00       	jmp    80109457 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
801093c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093c8:	89 d0                	mov    %edx,%eax
801093ca:	c1 e0 02             	shl    $0x2,%eax
801093cd:	01 d0                	add    %edx,%eax
801093cf:	01 c0                	add    %eax,%eax
801093d1:	01 d0                	add    %edx,%eax
801093d3:	05 8a 6b 19 80       	add    $0x80196b8a,%eax
801093d8:	0f b6 00             	movzbl (%eax),%eax
801093db:	84 c0                	test   %al,%al
801093dd:	74 74                	je     80109453 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
801093df:	83 ec 08             	sub    $0x8,%esp
801093e2:	ff 75 f4             	push   -0xc(%ebp)
801093e5:	68 af c3 10 80       	push   $0x8010c3af
801093ea:	e8 05 70 ff ff       	call   801003f4 <cprintf>
801093ef:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801093f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093f5:	89 d0                	mov    %edx,%eax
801093f7:	c1 e0 02             	shl    $0x2,%eax
801093fa:	01 d0                	add    %edx,%eax
801093fc:	01 c0                	add    %eax,%eax
801093fe:	01 d0                	add    %edx,%eax
80109400:	05 80 6b 19 80       	add    $0x80196b80,%eax
80109405:	83 ec 0c             	sub    $0xc,%esp
80109408:	50                   	push   %eax
80109409:	e8 54 02 00 00       	call   80109662 <print_ipv4>
8010940e:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109411:	83 ec 0c             	sub    $0xc,%esp
80109414:	68 be c3 10 80       	push   $0x8010c3be
80109419:	e8 d6 6f ff ff       	call   801003f4 <cprintf>
8010941e:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109421:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109424:	89 d0                	mov    %edx,%eax
80109426:	c1 e0 02             	shl    $0x2,%eax
80109429:	01 d0                	add    %edx,%eax
8010942b:	01 c0                	add    %eax,%eax
8010942d:	01 d0                	add    %edx,%eax
8010942f:	05 80 6b 19 80       	add    $0x80196b80,%eax
80109434:	83 c0 04             	add    $0x4,%eax
80109437:	83 ec 0c             	sub    $0xc,%esp
8010943a:	50                   	push   %eax
8010943b:	e8 70 02 00 00       	call   801096b0 <print_mac>
80109440:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109443:	83 ec 0c             	sub    $0xc,%esp
80109446:	68 c0 c3 10 80       	push   $0x8010c3c0
8010944b:	e8 a4 6f ff ff       	call   801003f4 <cprintf>
80109450:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109453:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109457:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010945b:	0f 8e 64 ff ff ff    	jle    801093c5 <print_arp_table+0x12>
    }
  }
}
80109461:	90                   	nop
80109462:	90                   	nop
80109463:	c9                   	leave
80109464:	c3                   	ret

80109465 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109465:	55                   	push   %ebp
80109466:	89 e5                	mov    %esp,%ebp
80109468:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010946b:	8b 45 10             	mov    0x10(%ebp),%eax
8010946e:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109474:	8b 45 0c             	mov    0xc(%ebp),%eax
80109477:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010947a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010947d:	83 c0 0e             	add    $0xe,%eax
80109480:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109486:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010948a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010948d:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109491:	8b 45 08             	mov    0x8(%ebp),%eax
80109494:	8d 50 08             	lea    0x8(%eax),%edx
80109497:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010949a:	83 ec 04             	sub    $0x4,%esp
8010949d:	6a 06                	push   $0x6
8010949f:	52                   	push   %edx
801094a0:	50                   	push   %eax
801094a1:	e8 50 b7 ff ff       	call   80104bf6 <memmove>
801094a6:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801094a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ac:	83 c0 06             	add    $0x6,%eax
801094af:	83 ec 04             	sub    $0x4,%esp
801094b2:	6a 06                	push   $0x6
801094b4:	68 70 6b 19 80       	push   $0x80196b70
801094b9:	50                   	push   %eax
801094ba:	e8 37 b7 ff ff       	call   80104bf6 <memmove>
801094bf:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801094c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094c5:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801094ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094cd:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801094d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094d6:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801094da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094dd:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
801094e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094e4:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
801094ea:	8b 45 08             	mov    0x8(%ebp),%eax
801094ed:	8d 50 08             	lea    0x8(%eax),%edx
801094f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094f3:	83 c0 12             	add    $0x12,%eax
801094f6:	83 ec 04             	sub    $0x4,%esp
801094f9:	6a 06                	push   $0x6
801094fb:	52                   	push   %edx
801094fc:	50                   	push   %eax
801094fd:	e8 f4 b6 ff ff       	call   80104bf6 <memmove>
80109502:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109505:	8b 45 08             	mov    0x8(%ebp),%eax
80109508:	8d 50 0e             	lea    0xe(%eax),%edx
8010950b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010950e:	83 c0 18             	add    $0x18,%eax
80109511:	83 ec 04             	sub    $0x4,%esp
80109514:	6a 04                	push   $0x4
80109516:	52                   	push   %edx
80109517:	50                   	push   %eax
80109518:	e8 d9 b6 ff ff       	call   80104bf6 <memmove>
8010951d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109520:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109523:	83 c0 08             	add    $0x8,%eax
80109526:	83 ec 04             	sub    $0x4,%esp
80109529:	6a 06                	push   $0x6
8010952b:	68 70 6b 19 80       	push   $0x80196b70
80109530:	50                   	push   %eax
80109531:	e8 c0 b6 ff ff       	call   80104bf6 <memmove>
80109536:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109539:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010953c:	83 c0 0e             	add    $0xe,%eax
8010953f:	83 ec 04             	sub    $0x4,%esp
80109542:	6a 04                	push   $0x4
80109544:	68 e4 f4 10 80       	push   $0x8010f4e4
80109549:	50                   	push   %eax
8010954a:	e8 a7 b6 ff ff       	call   80104bf6 <memmove>
8010954f:	83 c4 10             	add    $0x10,%esp
}
80109552:	90                   	nop
80109553:	c9                   	leave
80109554:	c3                   	ret

80109555 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109555:	55                   	push   %ebp
80109556:	89 e5                	mov    %esp,%ebp
80109558:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
8010955b:	83 ec 0c             	sub    $0xc,%esp
8010955e:	68 c2 c3 10 80       	push   $0x8010c3c2
80109563:	e8 8c 6e ff ff       	call   801003f4 <cprintf>
80109568:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
8010956b:	8b 45 08             	mov    0x8(%ebp),%eax
8010956e:	83 c0 0e             	add    $0xe,%eax
80109571:	83 ec 0c             	sub    $0xc,%esp
80109574:	50                   	push   %eax
80109575:	e8 e8 00 00 00       	call   80109662 <print_ipv4>
8010957a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010957d:	83 ec 0c             	sub    $0xc,%esp
80109580:	68 c0 c3 10 80       	push   $0x8010c3c0
80109585:	e8 6a 6e ff ff       	call   801003f4 <cprintf>
8010958a:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010958d:	8b 45 08             	mov    0x8(%ebp),%eax
80109590:	83 c0 08             	add    $0x8,%eax
80109593:	83 ec 0c             	sub    $0xc,%esp
80109596:	50                   	push   %eax
80109597:	e8 14 01 00 00       	call   801096b0 <print_mac>
8010959c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010959f:	83 ec 0c             	sub    $0xc,%esp
801095a2:	68 c0 c3 10 80       	push   $0x8010c3c0
801095a7:	e8 48 6e ff ff       	call   801003f4 <cprintf>
801095ac:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801095af:	83 ec 0c             	sub    $0xc,%esp
801095b2:	68 d9 c3 10 80       	push   $0x8010c3d9
801095b7:	e8 38 6e ff ff       	call   801003f4 <cprintf>
801095bc:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
801095bf:	8b 45 08             	mov    0x8(%ebp),%eax
801095c2:	83 c0 18             	add    $0x18,%eax
801095c5:	83 ec 0c             	sub    $0xc,%esp
801095c8:	50                   	push   %eax
801095c9:	e8 94 00 00 00       	call   80109662 <print_ipv4>
801095ce:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801095d1:	83 ec 0c             	sub    $0xc,%esp
801095d4:	68 c0 c3 10 80       	push   $0x8010c3c0
801095d9:	e8 16 6e ff ff       	call   801003f4 <cprintf>
801095de:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
801095e1:	8b 45 08             	mov    0x8(%ebp),%eax
801095e4:	83 c0 12             	add    $0x12,%eax
801095e7:	83 ec 0c             	sub    $0xc,%esp
801095ea:	50                   	push   %eax
801095eb:	e8 c0 00 00 00       	call   801096b0 <print_mac>
801095f0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801095f3:	83 ec 0c             	sub    $0xc,%esp
801095f6:	68 c0 c3 10 80       	push   $0x8010c3c0
801095fb:	e8 f4 6d ff ff       	call   801003f4 <cprintf>
80109600:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109603:	83 ec 0c             	sub    $0xc,%esp
80109606:	68 f0 c3 10 80       	push   $0x8010c3f0
8010960b:	e8 e4 6d ff ff       	call   801003f4 <cprintf>
80109610:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109613:	8b 45 08             	mov    0x8(%ebp),%eax
80109616:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010961a:	66 3d 00 01          	cmp    $0x100,%ax
8010961e:	75 12                	jne    80109632 <print_arp_info+0xdd>
80109620:	83 ec 0c             	sub    $0xc,%esp
80109623:	68 fc c3 10 80       	push   $0x8010c3fc
80109628:	e8 c7 6d ff ff       	call   801003f4 <cprintf>
8010962d:	83 c4 10             	add    $0x10,%esp
80109630:	eb 1d                	jmp    8010964f <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109632:	8b 45 08             	mov    0x8(%ebp),%eax
80109635:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109639:	66 3d 00 02          	cmp    $0x200,%ax
8010963d:	75 10                	jne    8010964f <print_arp_info+0xfa>
    cprintf("Reply\n");
8010963f:	83 ec 0c             	sub    $0xc,%esp
80109642:	68 05 c4 10 80       	push   $0x8010c405
80109647:	e8 a8 6d ff ff       	call   801003f4 <cprintf>
8010964c:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010964f:	83 ec 0c             	sub    $0xc,%esp
80109652:	68 c0 c3 10 80       	push   $0x8010c3c0
80109657:	e8 98 6d ff ff       	call   801003f4 <cprintf>
8010965c:	83 c4 10             	add    $0x10,%esp
}
8010965f:	90                   	nop
80109660:	c9                   	leave
80109661:	c3                   	ret

80109662 <print_ipv4>:

void print_ipv4(uchar *ip){
80109662:	55                   	push   %ebp
80109663:	89 e5                	mov    %esp,%ebp
80109665:	53                   	push   %ebx
80109666:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109669:	8b 45 08             	mov    0x8(%ebp),%eax
8010966c:	83 c0 03             	add    $0x3,%eax
8010966f:	0f b6 00             	movzbl (%eax),%eax
80109672:	0f b6 d8             	movzbl %al,%ebx
80109675:	8b 45 08             	mov    0x8(%ebp),%eax
80109678:	83 c0 02             	add    $0x2,%eax
8010967b:	0f b6 00             	movzbl (%eax),%eax
8010967e:	0f b6 c8             	movzbl %al,%ecx
80109681:	8b 45 08             	mov    0x8(%ebp),%eax
80109684:	83 c0 01             	add    $0x1,%eax
80109687:	0f b6 00             	movzbl (%eax),%eax
8010968a:	0f b6 d0             	movzbl %al,%edx
8010968d:	8b 45 08             	mov    0x8(%ebp),%eax
80109690:	0f b6 00             	movzbl (%eax),%eax
80109693:	0f b6 c0             	movzbl %al,%eax
80109696:	83 ec 0c             	sub    $0xc,%esp
80109699:	53                   	push   %ebx
8010969a:	51                   	push   %ecx
8010969b:	52                   	push   %edx
8010969c:	50                   	push   %eax
8010969d:	68 0c c4 10 80       	push   $0x8010c40c
801096a2:	e8 4d 6d ff ff       	call   801003f4 <cprintf>
801096a7:	83 c4 20             	add    $0x20,%esp
}
801096aa:	90                   	nop
801096ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801096ae:	c9                   	leave
801096af:	c3                   	ret

801096b0 <print_mac>:

void print_mac(uchar *mac){
801096b0:	55                   	push   %ebp
801096b1:	89 e5                	mov    %esp,%ebp
801096b3:	57                   	push   %edi
801096b4:	56                   	push   %esi
801096b5:	53                   	push   %ebx
801096b6:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
801096b9:	8b 45 08             	mov    0x8(%ebp),%eax
801096bc:	83 c0 05             	add    $0x5,%eax
801096bf:	0f b6 00             	movzbl (%eax),%eax
801096c2:	0f b6 f8             	movzbl %al,%edi
801096c5:	8b 45 08             	mov    0x8(%ebp),%eax
801096c8:	83 c0 04             	add    $0x4,%eax
801096cb:	0f b6 00             	movzbl (%eax),%eax
801096ce:	0f b6 f0             	movzbl %al,%esi
801096d1:	8b 45 08             	mov    0x8(%ebp),%eax
801096d4:	83 c0 03             	add    $0x3,%eax
801096d7:	0f b6 00             	movzbl (%eax),%eax
801096da:	0f b6 d8             	movzbl %al,%ebx
801096dd:	8b 45 08             	mov    0x8(%ebp),%eax
801096e0:	83 c0 02             	add    $0x2,%eax
801096e3:	0f b6 00             	movzbl (%eax),%eax
801096e6:	0f b6 c8             	movzbl %al,%ecx
801096e9:	8b 45 08             	mov    0x8(%ebp),%eax
801096ec:	83 c0 01             	add    $0x1,%eax
801096ef:	0f b6 00             	movzbl (%eax),%eax
801096f2:	0f b6 d0             	movzbl %al,%edx
801096f5:	8b 45 08             	mov    0x8(%ebp),%eax
801096f8:	0f b6 00             	movzbl (%eax),%eax
801096fb:	0f b6 c0             	movzbl %al,%eax
801096fe:	83 ec 04             	sub    $0x4,%esp
80109701:	57                   	push   %edi
80109702:	56                   	push   %esi
80109703:	53                   	push   %ebx
80109704:	51                   	push   %ecx
80109705:	52                   	push   %edx
80109706:	50                   	push   %eax
80109707:	68 24 c4 10 80       	push   $0x8010c424
8010970c:	e8 e3 6c ff ff       	call   801003f4 <cprintf>
80109711:	83 c4 20             	add    $0x20,%esp
}
80109714:	90                   	nop
80109715:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109718:	5b                   	pop    %ebx
80109719:	5e                   	pop    %esi
8010971a:	5f                   	pop    %edi
8010971b:	5d                   	pop    %ebp
8010971c:	c3                   	ret

8010971d <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
8010971d:	55                   	push   %ebp
8010971e:	89 e5                	mov    %esp,%ebp
80109720:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109723:	8b 45 08             	mov    0x8(%ebp),%eax
80109726:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109729:	8b 45 08             	mov    0x8(%ebp),%eax
8010972c:	83 c0 0e             	add    $0xe,%eax
8010972f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109735:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109739:	3c 08                	cmp    $0x8,%al
8010973b:	75 1b                	jne    80109758 <eth_proc+0x3b>
8010973d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109740:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109744:	3c 06                	cmp    $0x6,%al
80109746:	75 10                	jne    80109758 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109748:	83 ec 0c             	sub    $0xc,%esp
8010974b:	ff 75 f0             	push   -0x10(%ebp)
8010974e:	e8 01 f8 ff ff       	call   80108f54 <arp_proc>
80109753:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109756:	eb 24                	jmp    8010977c <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010975b:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010975f:	3c 08                	cmp    $0x8,%al
80109761:	75 19                	jne    8010977c <eth_proc+0x5f>
80109763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109766:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010976a:	84 c0                	test   %al,%al
8010976c:	75 0e                	jne    8010977c <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
8010976e:	83 ec 0c             	sub    $0xc,%esp
80109771:	ff 75 08             	push   0x8(%ebp)
80109774:	e8 8d 00 00 00       	call   80109806 <ipv4_proc>
80109779:	83 c4 10             	add    $0x10,%esp
}
8010977c:	90                   	nop
8010977d:	c9                   	leave
8010977e:	c3                   	ret

8010977f <N2H_ushort>:

ushort N2H_ushort(ushort value){
8010977f:	55                   	push   %ebp
80109780:	89 e5                	mov    %esp,%ebp
80109782:	83 ec 04             	sub    $0x4,%esp
80109785:	8b 45 08             	mov    0x8(%ebp),%eax
80109788:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010978c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109790:	66 c1 c0 08          	rol    $0x8,%ax
}
80109794:	c9                   	leave
80109795:	c3                   	ret

80109796 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109796:	55                   	push   %ebp
80109797:	89 e5                	mov    %esp,%ebp
80109799:	83 ec 04             	sub    $0x4,%esp
8010979c:	8b 45 08             	mov    0x8(%ebp),%eax
8010979f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801097a3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801097a7:	66 c1 c0 08          	rol    $0x8,%ax
}
801097ab:	c9                   	leave
801097ac:	c3                   	ret

801097ad <H2N_uint>:

uint H2N_uint(uint value){
801097ad:	55                   	push   %ebp
801097ae:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
801097b0:	8b 45 08             	mov    0x8(%ebp),%eax
801097b3:	c1 e0 18             	shl    $0x18,%eax
801097b6:	25 00 00 00 0f       	and    $0xf000000,%eax
801097bb:	89 c2                	mov    %eax,%edx
801097bd:	8b 45 08             	mov    0x8(%ebp),%eax
801097c0:	c1 e0 08             	shl    $0x8,%eax
801097c3:	25 00 f0 00 00       	and    $0xf000,%eax
801097c8:	09 c2                	or     %eax,%edx
801097ca:	8b 45 08             	mov    0x8(%ebp),%eax
801097cd:	c1 e8 08             	shr    $0x8,%eax
801097d0:	83 e0 0f             	and    $0xf,%eax
801097d3:	01 d0                	add    %edx,%eax
}
801097d5:	5d                   	pop    %ebp
801097d6:	c3                   	ret

801097d7 <N2H_uint>:

uint N2H_uint(uint value){
801097d7:	55                   	push   %ebp
801097d8:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
801097da:	8b 45 08             	mov    0x8(%ebp),%eax
801097dd:	c1 e0 18             	shl    $0x18,%eax
801097e0:	89 c2                	mov    %eax,%edx
801097e2:	8b 45 08             	mov    0x8(%ebp),%eax
801097e5:	c1 e0 08             	shl    $0x8,%eax
801097e8:	25 00 00 ff 00       	and    $0xff0000,%eax
801097ed:	01 c2                	add    %eax,%edx
801097ef:	8b 45 08             	mov    0x8(%ebp),%eax
801097f2:	c1 e8 08             	shr    $0x8,%eax
801097f5:	25 00 ff 00 00       	and    $0xff00,%eax
801097fa:	01 c2                	add    %eax,%edx
801097fc:	8b 45 08             	mov    0x8(%ebp),%eax
801097ff:	c1 e8 18             	shr    $0x18,%eax
80109802:	01 d0                	add    %edx,%eax
}
80109804:	5d                   	pop    %ebp
80109805:	c3                   	ret

80109806 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109806:	55                   	push   %ebp
80109807:	89 e5                	mov    %esp,%ebp
80109809:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010980c:	8b 45 08             	mov    0x8(%ebp),%eax
8010980f:	83 c0 0e             	add    $0xe,%eax
80109812:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109818:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010981c:	0f b7 d0             	movzwl %ax,%edx
8010981f:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109824:	39 c2                	cmp    %eax,%edx
80109826:	74 60                	je     80109888 <ipv4_proc+0x82>
80109828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010982b:	83 c0 0c             	add    $0xc,%eax
8010982e:	83 ec 04             	sub    $0x4,%esp
80109831:	6a 04                	push   $0x4
80109833:	50                   	push   %eax
80109834:	68 e4 f4 10 80       	push   $0x8010f4e4
80109839:	e8 60 b3 ff ff       	call   80104b9e <memcmp>
8010983e:	83 c4 10             	add    $0x10,%esp
80109841:	85 c0                	test   %eax,%eax
80109843:	74 43                	je     80109888 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109848:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010984c:	0f b7 c0             	movzwl %ax,%eax
8010984f:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109854:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109857:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010985b:	3c 01                	cmp    $0x1,%al
8010985d:	75 10                	jne    8010986f <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
8010985f:	83 ec 0c             	sub    $0xc,%esp
80109862:	ff 75 08             	push   0x8(%ebp)
80109865:	e8 a3 00 00 00       	call   8010990d <icmp_proc>
8010986a:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
8010986d:	eb 19                	jmp    80109888 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
8010986f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109872:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109876:	3c 06                	cmp    $0x6,%al
80109878:	75 0e                	jne    80109888 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
8010987a:	83 ec 0c             	sub    $0xc,%esp
8010987d:	ff 75 08             	push   0x8(%ebp)
80109880:	e8 b3 03 00 00       	call   80109c38 <tcp_proc>
80109885:	83 c4 10             	add    $0x10,%esp
}
80109888:	90                   	nop
80109889:	c9                   	leave
8010988a:	c3                   	ret

8010988b <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010988b:	55                   	push   %ebp
8010988c:	89 e5                	mov    %esp,%ebp
8010988e:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109891:	8b 45 08             	mov    0x8(%ebp),%eax
80109894:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010989a:	0f b6 00             	movzbl (%eax),%eax
8010989d:	83 e0 0f             	and    $0xf,%eax
801098a0:	01 c0                	add    %eax,%eax
801098a2:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
801098a5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
801098ac:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801098b3:	eb 48                	jmp    801098fd <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
801098b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801098b8:	01 c0                	add    %eax,%eax
801098ba:	89 c2                	mov    %eax,%edx
801098bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098bf:	01 d0                	add    %edx,%eax
801098c1:	0f b6 00             	movzbl (%eax),%eax
801098c4:	0f b6 c0             	movzbl %al,%eax
801098c7:	c1 e0 08             	shl    $0x8,%eax
801098ca:	89 c2                	mov    %eax,%edx
801098cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
801098cf:	01 c0                	add    %eax,%eax
801098d1:	8d 48 01             	lea    0x1(%eax),%ecx
801098d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098d7:	01 c8                	add    %ecx,%eax
801098d9:	0f b6 00             	movzbl (%eax),%eax
801098dc:	0f b6 c0             	movzbl %al,%eax
801098df:	01 d0                	add    %edx,%eax
801098e1:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
801098e4:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
801098eb:	76 0c                	jbe    801098f9 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
801098ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801098f0:	0f b7 c0             	movzwl %ax,%eax
801098f3:	83 c0 01             	add    $0x1,%eax
801098f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
801098f9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801098fd:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109901:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109904:	7c af                	jl     801098b5 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109906:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109909:	f7 d0                	not    %eax
}
8010990b:	c9                   	leave
8010990c:	c3                   	ret

8010990d <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010990d:	55                   	push   %ebp
8010990e:	89 e5                	mov    %esp,%ebp
80109910:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109913:	8b 45 08             	mov    0x8(%ebp),%eax
80109916:	83 c0 0e             	add    $0xe,%eax
80109919:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010991c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010991f:	0f b6 00             	movzbl (%eax),%eax
80109922:	0f b6 c0             	movzbl %al,%eax
80109925:	83 e0 0f             	and    $0xf,%eax
80109928:	c1 e0 02             	shl    $0x2,%eax
8010992b:	89 c2                	mov    %eax,%edx
8010992d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109930:	01 d0                	add    %edx,%eax
80109932:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109935:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109938:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010993c:	84 c0                	test   %al,%al
8010993e:	75 4f                	jne    8010998f <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109940:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109943:	0f b6 00             	movzbl (%eax),%eax
80109946:	3c 08                	cmp    $0x8,%al
80109948:	75 45                	jne    8010998f <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
8010994a:	e8 b6 8e ff ff       	call   80102805 <kalloc>
8010994f:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109952:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109959:	83 ec 04             	sub    $0x4,%esp
8010995c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010995f:	50                   	push   %eax
80109960:	ff 75 ec             	push   -0x14(%ebp)
80109963:	ff 75 08             	push   0x8(%ebp)
80109966:	e8 78 00 00 00       	call   801099e3 <icmp_reply_pkt_create>
8010996b:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010996e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109971:	83 ec 08             	sub    $0x8,%esp
80109974:	50                   	push   %eax
80109975:	ff 75 ec             	push   -0x14(%ebp)
80109978:	e8 ad f4 ff ff       	call   80108e2a <i8254_send>
8010997d:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109980:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109983:	83 ec 0c             	sub    $0xc,%esp
80109986:	50                   	push   %eax
80109987:	e8 df 8d ff ff       	call   8010276b <kfree>
8010998c:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010998f:	90                   	nop
80109990:	c9                   	leave
80109991:	c3                   	ret

80109992 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109992:	55                   	push   %ebp
80109993:	89 e5                	mov    %esp,%ebp
80109995:	53                   	push   %ebx
80109996:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109999:	8b 45 08             	mov    0x8(%ebp),%eax
8010999c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801099a0:	0f b7 c0             	movzwl %ax,%eax
801099a3:	83 ec 0c             	sub    $0xc,%esp
801099a6:	50                   	push   %eax
801099a7:	e8 d3 fd ff ff       	call   8010977f <N2H_ushort>
801099ac:	83 c4 10             	add    $0x10,%esp
801099af:	0f b7 d8             	movzwl %ax,%ebx
801099b2:	8b 45 08             	mov    0x8(%ebp),%eax
801099b5:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801099b9:	0f b7 c0             	movzwl %ax,%eax
801099bc:	83 ec 0c             	sub    $0xc,%esp
801099bf:	50                   	push   %eax
801099c0:	e8 ba fd ff ff       	call   8010977f <N2H_ushort>
801099c5:	83 c4 10             	add    $0x10,%esp
801099c8:	0f b7 c0             	movzwl %ax,%eax
801099cb:	83 ec 04             	sub    $0x4,%esp
801099ce:	53                   	push   %ebx
801099cf:	50                   	push   %eax
801099d0:	68 43 c4 10 80       	push   $0x8010c443
801099d5:	e8 1a 6a ff ff       	call   801003f4 <cprintf>
801099da:	83 c4 10             	add    $0x10,%esp
}
801099dd:	90                   	nop
801099de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801099e1:	c9                   	leave
801099e2:	c3                   	ret

801099e3 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
801099e3:	55                   	push   %ebp
801099e4:	89 e5                	mov    %esp,%ebp
801099e6:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
801099e9:	8b 45 08             	mov    0x8(%ebp),%eax
801099ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
801099ef:	8b 45 08             	mov    0x8(%ebp),%eax
801099f2:	83 c0 0e             	add    $0xe,%eax
801099f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
801099f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099fb:	0f b6 00             	movzbl (%eax),%eax
801099fe:	0f b6 c0             	movzbl %al,%eax
80109a01:	83 e0 0f             	and    $0xf,%eax
80109a04:	c1 e0 02             	shl    $0x2,%eax
80109a07:	89 c2                	mov    %eax,%edx
80109a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a0c:	01 d0                	add    %edx,%eax
80109a0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109a11:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a14:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109a17:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a1a:	83 c0 0e             	add    $0xe,%eax
80109a1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109a20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a23:	83 c0 14             	add    $0x14,%eax
80109a26:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109a29:	8b 45 10             	mov    0x10(%ebp),%eax
80109a2c:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a35:	8d 50 06             	lea    0x6(%eax),%edx
80109a38:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a3b:	83 ec 04             	sub    $0x4,%esp
80109a3e:	6a 06                	push   $0x6
80109a40:	52                   	push   %edx
80109a41:	50                   	push   %eax
80109a42:	e8 af b1 ff ff       	call   80104bf6 <memmove>
80109a47:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109a4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a4d:	83 c0 06             	add    $0x6,%eax
80109a50:	83 ec 04             	sub    $0x4,%esp
80109a53:	6a 06                	push   $0x6
80109a55:	68 70 6b 19 80       	push   $0x80196b70
80109a5a:	50                   	push   %eax
80109a5b:	e8 96 b1 ff ff       	call   80104bf6 <memmove>
80109a60:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109a63:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a66:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109a6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a6d:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109a71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a74:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109a77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a7a:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109a7e:	83 ec 0c             	sub    $0xc,%esp
80109a81:	6a 54                	push   $0x54
80109a83:	e8 0e fd ff ff       	call   80109796 <H2N_ushort>
80109a88:	83 c4 10             	add    $0x10,%esp
80109a8b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109a8e:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109a92:	0f b7 15 40 6e 19 80 	movzwl 0x80196e40,%edx
80109a99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a9c:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109aa0:	0f b7 05 40 6e 19 80 	movzwl 0x80196e40,%eax
80109aa7:	83 c0 01             	add    $0x1,%eax
80109aaa:	66 a3 40 6e 19 80    	mov    %ax,0x80196e40
  ipv4_send->fragment = H2N_ushort(0x4000);
80109ab0:	83 ec 0c             	sub    $0xc,%esp
80109ab3:	68 00 40 00 00       	push   $0x4000
80109ab8:	e8 d9 fc ff ff       	call   80109796 <H2N_ushort>
80109abd:	83 c4 10             	add    $0x10,%esp
80109ac0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ac3:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109ac7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109aca:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109ace:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ad1:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109ad5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ad8:	83 c0 0c             	add    $0xc,%eax
80109adb:	83 ec 04             	sub    $0x4,%esp
80109ade:	6a 04                	push   $0x4
80109ae0:	68 e4 f4 10 80       	push   $0x8010f4e4
80109ae5:	50                   	push   %eax
80109ae6:	e8 0b b1 ff ff       	call   80104bf6 <memmove>
80109aeb:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109af1:	8d 50 0c             	lea    0xc(%eax),%edx
80109af4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109af7:	83 c0 10             	add    $0x10,%eax
80109afa:	83 ec 04             	sub    $0x4,%esp
80109afd:	6a 04                	push   $0x4
80109aff:	52                   	push   %edx
80109b00:	50                   	push   %eax
80109b01:	e8 f0 b0 ff ff       	call   80104bf6 <memmove>
80109b06:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109b09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b0c:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109b12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b15:	83 ec 0c             	sub    $0xc,%esp
80109b18:	50                   	push   %eax
80109b19:	e8 6d fd ff ff       	call   8010988b <ipv4_chksum>
80109b1e:	83 c4 10             	add    $0x10,%esp
80109b21:	0f b7 c0             	movzwl %ax,%eax
80109b24:	83 ec 0c             	sub    $0xc,%esp
80109b27:	50                   	push   %eax
80109b28:	e8 69 fc ff ff       	call   80109796 <H2N_ushort>
80109b2d:	83 c4 10             	add    $0x10,%esp
80109b30:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109b33:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109b37:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109b3a:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109b3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109b40:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109b44:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b47:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109b4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109b4e:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109b52:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b55:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109b59:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109b5c:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109b60:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b63:	8d 50 08             	lea    0x8(%eax),%edx
80109b66:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109b69:	83 c0 08             	add    $0x8,%eax
80109b6c:	83 ec 04             	sub    $0x4,%esp
80109b6f:	6a 08                	push   $0x8
80109b71:	52                   	push   %edx
80109b72:	50                   	push   %eax
80109b73:	e8 7e b0 ff ff       	call   80104bf6 <memmove>
80109b78:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109b7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b7e:	8d 50 10             	lea    0x10(%eax),%edx
80109b81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109b84:	83 c0 10             	add    $0x10,%eax
80109b87:	83 ec 04             	sub    $0x4,%esp
80109b8a:	6a 30                	push   $0x30
80109b8c:	52                   	push   %edx
80109b8d:	50                   	push   %eax
80109b8e:	e8 63 b0 ff ff       	call   80104bf6 <memmove>
80109b93:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109b96:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109b99:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109b9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ba2:	83 ec 0c             	sub    $0xc,%esp
80109ba5:	50                   	push   %eax
80109ba6:	e8 1c 00 00 00       	call   80109bc7 <icmp_chksum>
80109bab:	83 c4 10             	add    $0x10,%esp
80109bae:	0f b7 c0             	movzwl %ax,%eax
80109bb1:	83 ec 0c             	sub    $0xc,%esp
80109bb4:	50                   	push   %eax
80109bb5:	e8 dc fb ff ff       	call   80109796 <H2N_ushort>
80109bba:	83 c4 10             	add    $0x10,%esp
80109bbd:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109bc0:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109bc4:	90                   	nop
80109bc5:	c9                   	leave
80109bc6:	c3                   	ret

80109bc7 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109bc7:	55                   	push   %ebp
80109bc8:	89 e5                	mov    %esp,%ebp
80109bca:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80109bd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109bd3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109bda:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109be1:	eb 48                	jmp    80109c2b <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109be3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109be6:	01 c0                	add    %eax,%eax
80109be8:	89 c2                	mov    %eax,%edx
80109bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bed:	01 d0                	add    %edx,%eax
80109bef:	0f b6 00             	movzbl (%eax),%eax
80109bf2:	0f b6 c0             	movzbl %al,%eax
80109bf5:	c1 e0 08             	shl    $0x8,%eax
80109bf8:	89 c2                	mov    %eax,%edx
80109bfa:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109bfd:	01 c0                	add    %eax,%eax
80109bff:	8d 48 01             	lea    0x1(%eax),%ecx
80109c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c05:	01 c8                	add    %ecx,%eax
80109c07:	0f b6 00             	movzbl (%eax),%eax
80109c0a:	0f b6 c0             	movzbl %al,%eax
80109c0d:	01 d0                	add    %edx,%eax
80109c0f:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109c12:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109c19:	76 0c                	jbe    80109c27 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109c1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109c1e:	0f b7 c0             	movzwl %ax,%eax
80109c21:	83 c0 01             	add    $0x1,%eax
80109c24:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109c27:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109c2b:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109c2f:	7e b2                	jle    80109be3 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109c31:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109c34:	f7 d0                	not    %eax
}
80109c36:	c9                   	leave
80109c37:	c3                   	ret

80109c38 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109c38:	55                   	push   %ebp
80109c39:	89 e5                	mov    %esp,%ebp
80109c3b:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80109c41:	83 c0 0e             	add    $0xe,%eax
80109c44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c4a:	0f b6 00             	movzbl (%eax),%eax
80109c4d:	0f b6 c0             	movzbl %al,%eax
80109c50:	83 e0 0f             	and    $0xf,%eax
80109c53:	c1 e0 02             	shl    $0x2,%eax
80109c56:	89 c2                	mov    %eax,%edx
80109c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c5b:	01 d0                	add    %edx,%eax
80109c5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c63:	83 c0 14             	add    $0x14,%eax
80109c66:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109c69:	e8 97 8b ff ff       	call   80102805 <kalloc>
80109c6e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109c71:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109c78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c7b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109c7f:	0f b6 c0             	movzbl %al,%eax
80109c82:	83 e0 02             	and    $0x2,%eax
80109c85:	85 c0                	test   %eax,%eax
80109c87:	74 3d                	je     80109cc6 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109c89:	83 ec 0c             	sub    $0xc,%esp
80109c8c:	6a 00                	push   $0x0
80109c8e:	6a 12                	push   $0x12
80109c90:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109c93:	50                   	push   %eax
80109c94:	ff 75 e8             	push   -0x18(%ebp)
80109c97:	ff 75 08             	push   0x8(%ebp)
80109c9a:	e8 a2 01 00 00       	call   80109e41 <tcp_pkt_create>
80109c9f:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109ca2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ca5:	83 ec 08             	sub    $0x8,%esp
80109ca8:	50                   	push   %eax
80109ca9:	ff 75 e8             	push   -0x18(%ebp)
80109cac:	e8 79 f1 ff ff       	call   80108e2a <i8254_send>
80109cb1:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109cb4:	a1 44 6e 19 80       	mov    0x80196e44,%eax
80109cb9:	83 c0 01             	add    $0x1,%eax
80109cbc:	a3 44 6e 19 80       	mov    %eax,0x80196e44
80109cc1:	e9 69 01 00 00       	jmp    80109e2f <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109cc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cc9:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ccd:	3c 18                	cmp    $0x18,%al
80109ccf:	0f 85 10 01 00 00    	jne    80109de5 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109cd5:	83 ec 04             	sub    $0x4,%esp
80109cd8:	6a 03                	push   $0x3
80109cda:	68 5e c4 10 80       	push   $0x8010c45e
80109cdf:	ff 75 ec             	push   -0x14(%ebp)
80109ce2:	e8 b7 ae ff ff       	call   80104b9e <memcmp>
80109ce7:	83 c4 10             	add    $0x10,%esp
80109cea:	85 c0                	test   %eax,%eax
80109cec:	74 74                	je     80109d62 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109cee:	83 ec 0c             	sub    $0xc,%esp
80109cf1:	68 62 c4 10 80       	push   $0x8010c462
80109cf6:	e8 f9 66 ff ff       	call   801003f4 <cprintf>
80109cfb:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109cfe:	83 ec 0c             	sub    $0xc,%esp
80109d01:	6a 00                	push   $0x0
80109d03:	6a 10                	push   $0x10
80109d05:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109d08:	50                   	push   %eax
80109d09:	ff 75 e8             	push   -0x18(%ebp)
80109d0c:	ff 75 08             	push   0x8(%ebp)
80109d0f:	e8 2d 01 00 00       	call   80109e41 <tcp_pkt_create>
80109d14:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109d17:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109d1a:	83 ec 08             	sub    $0x8,%esp
80109d1d:	50                   	push   %eax
80109d1e:	ff 75 e8             	push   -0x18(%ebp)
80109d21:	e8 04 f1 ff ff       	call   80108e2a <i8254_send>
80109d26:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109d29:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d2c:	83 c0 36             	add    $0x36,%eax
80109d2f:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109d32:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109d35:	50                   	push   %eax
80109d36:	ff 75 e0             	push   -0x20(%ebp)
80109d39:	6a 00                	push   $0x0
80109d3b:	6a 00                	push   $0x0
80109d3d:	e8 5a 04 00 00       	call   8010a19c <http_proc>
80109d42:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109d45:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109d48:	83 ec 0c             	sub    $0xc,%esp
80109d4b:	50                   	push   %eax
80109d4c:	6a 18                	push   $0x18
80109d4e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109d51:	50                   	push   %eax
80109d52:	ff 75 e8             	push   -0x18(%ebp)
80109d55:	ff 75 08             	push   0x8(%ebp)
80109d58:	e8 e4 00 00 00       	call   80109e41 <tcp_pkt_create>
80109d5d:	83 c4 20             	add    $0x20,%esp
80109d60:	eb 62                	jmp    80109dc4 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109d62:	83 ec 0c             	sub    $0xc,%esp
80109d65:	6a 00                	push   $0x0
80109d67:	6a 10                	push   $0x10
80109d69:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109d6c:	50                   	push   %eax
80109d6d:	ff 75 e8             	push   -0x18(%ebp)
80109d70:	ff 75 08             	push   0x8(%ebp)
80109d73:	e8 c9 00 00 00       	call   80109e41 <tcp_pkt_create>
80109d78:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109d7b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109d7e:	83 ec 08             	sub    $0x8,%esp
80109d81:	50                   	push   %eax
80109d82:	ff 75 e8             	push   -0x18(%ebp)
80109d85:	e8 a0 f0 ff ff       	call   80108e2a <i8254_send>
80109d8a:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109d8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d90:	83 c0 36             	add    $0x36,%eax
80109d93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109d96:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d99:	50                   	push   %eax
80109d9a:	ff 75 e4             	push   -0x1c(%ebp)
80109d9d:	6a 00                	push   $0x0
80109d9f:	6a 00                	push   $0x0
80109da1:	e8 f6 03 00 00       	call   8010a19c <http_proc>
80109da6:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109da9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109dac:	83 ec 0c             	sub    $0xc,%esp
80109daf:	50                   	push   %eax
80109db0:	6a 18                	push   $0x18
80109db2:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109db5:	50                   	push   %eax
80109db6:	ff 75 e8             	push   -0x18(%ebp)
80109db9:	ff 75 08             	push   0x8(%ebp)
80109dbc:	e8 80 00 00 00       	call   80109e41 <tcp_pkt_create>
80109dc1:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109dc4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109dc7:	83 ec 08             	sub    $0x8,%esp
80109dca:	50                   	push   %eax
80109dcb:	ff 75 e8             	push   -0x18(%ebp)
80109dce:	e8 57 f0 ff ff       	call   80108e2a <i8254_send>
80109dd3:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109dd6:	a1 44 6e 19 80       	mov    0x80196e44,%eax
80109ddb:	83 c0 01             	add    $0x1,%eax
80109dde:	a3 44 6e 19 80       	mov    %eax,0x80196e44
80109de3:	eb 4a                	jmp    80109e2f <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109de8:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109dec:	3c 10                	cmp    $0x10,%al
80109dee:	75 3f                	jne    80109e2f <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109df0:	a1 48 6e 19 80       	mov    0x80196e48,%eax
80109df5:	83 f8 01             	cmp    $0x1,%eax
80109df8:	75 35                	jne    80109e2f <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109dfa:	83 ec 0c             	sub    $0xc,%esp
80109dfd:	6a 00                	push   $0x0
80109dff:	6a 01                	push   $0x1
80109e01:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e04:	50                   	push   %eax
80109e05:	ff 75 e8             	push   -0x18(%ebp)
80109e08:	ff 75 08             	push   0x8(%ebp)
80109e0b:	e8 31 00 00 00       	call   80109e41 <tcp_pkt_create>
80109e10:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109e13:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e16:	83 ec 08             	sub    $0x8,%esp
80109e19:	50                   	push   %eax
80109e1a:	ff 75 e8             	push   -0x18(%ebp)
80109e1d:	e8 08 f0 ff ff       	call   80108e2a <i8254_send>
80109e22:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109e25:	c7 05 48 6e 19 80 00 	movl   $0x0,0x80196e48
80109e2c:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109e2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e32:	83 ec 0c             	sub    $0xc,%esp
80109e35:	50                   	push   %eax
80109e36:	e8 30 89 ff ff       	call   8010276b <kfree>
80109e3b:	83 c4 10             	add    $0x10,%esp
}
80109e3e:	90                   	nop
80109e3f:	c9                   	leave
80109e40:	c3                   	ret

80109e41 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109e41:	55                   	push   %ebp
80109e42:	89 e5                	mov    %esp,%ebp
80109e44:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109e47:	8b 45 08             	mov    0x8(%ebp),%eax
80109e4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80109e50:	83 c0 0e             	add    $0xe,%eax
80109e53:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e59:	0f b6 00             	movzbl (%eax),%eax
80109e5c:	0f b6 c0             	movzbl %al,%eax
80109e5f:	83 e0 0f             	and    $0xf,%eax
80109e62:	c1 e0 02             	shl    $0x2,%eax
80109e65:	89 c2                	mov    %eax,%edx
80109e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e6a:	01 d0                	add    %edx,%eax
80109e6c:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109e6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e72:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109e75:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e78:	83 c0 0e             	add    $0xe,%eax
80109e7b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109e7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e81:	83 c0 14             	add    $0x14,%eax
80109e84:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109e87:	8b 45 18             	mov    0x18(%ebp),%eax
80109e8a:	8d 50 36             	lea    0x36(%eax),%edx
80109e8d:	8b 45 10             	mov    0x10(%ebp),%eax
80109e90:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e95:	8d 50 06             	lea    0x6(%eax),%edx
80109e98:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e9b:	83 ec 04             	sub    $0x4,%esp
80109e9e:	6a 06                	push   $0x6
80109ea0:	52                   	push   %edx
80109ea1:	50                   	push   %eax
80109ea2:	e8 4f ad ff ff       	call   80104bf6 <memmove>
80109ea7:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109eaa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ead:	83 c0 06             	add    $0x6,%eax
80109eb0:	83 ec 04             	sub    $0x4,%esp
80109eb3:	6a 06                	push   $0x6
80109eb5:	68 70 6b 19 80       	push   $0x80196b70
80109eba:	50                   	push   %eax
80109ebb:	e8 36 ad ff ff       	call   80104bf6 <memmove>
80109ec0:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109ec3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ec6:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109eca:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ecd:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109ed1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ed4:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109ed7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109eda:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109ede:	8b 45 18             	mov    0x18(%ebp),%eax
80109ee1:	83 c0 28             	add    $0x28,%eax
80109ee4:	0f b7 c0             	movzwl %ax,%eax
80109ee7:	83 ec 0c             	sub    $0xc,%esp
80109eea:	50                   	push   %eax
80109eeb:	e8 a6 f8 ff ff       	call   80109796 <H2N_ushort>
80109ef0:	83 c4 10             	add    $0x10,%esp
80109ef3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ef6:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109efa:	0f b7 15 40 6e 19 80 	movzwl 0x80196e40,%edx
80109f01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f04:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109f08:	0f b7 05 40 6e 19 80 	movzwl 0x80196e40,%eax
80109f0f:	83 c0 01             	add    $0x1,%eax
80109f12:	66 a3 40 6e 19 80    	mov    %ax,0x80196e40
  ipv4_send->fragment = H2N_ushort(0x0000);
80109f18:	83 ec 0c             	sub    $0xc,%esp
80109f1b:	6a 00                	push   $0x0
80109f1d:	e8 74 f8 ff ff       	call   80109796 <H2N_ushort>
80109f22:	83 c4 10             	add    $0x10,%esp
80109f25:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109f28:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109f2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f2f:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109f33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f36:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109f3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f3d:	83 c0 0c             	add    $0xc,%eax
80109f40:	83 ec 04             	sub    $0x4,%esp
80109f43:	6a 04                	push   $0x4
80109f45:	68 e4 f4 10 80       	push   $0x8010f4e4
80109f4a:	50                   	push   %eax
80109f4b:	e8 a6 ac ff ff       	call   80104bf6 <memmove>
80109f50:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109f53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f56:	8d 50 0c             	lea    0xc(%eax),%edx
80109f59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f5c:	83 c0 10             	add    $0x10,%eax
80109f5f:	83 ec 04             	sub    $0x4,%esp
80109f62:	6a 04                	push   $0x4
80109f64:	52                   	push   %edx
80109f65:	50                   	push   %eax
80109f66:	e8 8b ac ff ff       	call   80104bf6 <memmove>
80109f6b:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109f6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f71:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109f77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f7a:	83 ec 0c             	sub    $0xc,%esp
80109f7d:	50                   	push   %eax
80109f7e:	e8 08 f9 ff ff       	call   8010988b <ipv4_chksum>
80109f83:	83 c4 10             	add    $0x10,%esp
80109f86:	0f b7 c0             	movzwl %ax,%eax
80109f89:	83 ec 0c             	sub    $0xc,%esp
80109f8c:	50                   	push   %eax
80109f8d:	e8 04 f8 ff ff       	call   80109796 <H2N_ushort>
80109f92:	83 c4 10             	add    $0x10,%esp
80109f95:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109f98:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109f9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f9f:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109fa3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fa6:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109fa9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109fac:	0f b7 10             	movzwl (%eax),%edx
80109faf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fb2:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109fb6:	a1 44 6e 19 80       	mov    0x80196e44,%eax
80109fbb:	83 ec 0c             	sub    $0xc,%esp
80109fbe:	50                   	push   %eax
80109fbf:	e8 e9 f7 ff ff       	call   801097ad <H2N_uint>
80109fc4:	83 c4 10             	add    $0x10,%esp
80109fc7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109fca:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109fcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109fd0:	8b 40 04             	mov    0x4(%eax),%eax
80109fd3:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109fd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fdc:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109fdf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fe2:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109fe6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fe9:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109fed:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ff0:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109ff4:	8b 45 14             	mov    0x14(%ebp),%eax
80109ff7:	89 c2                	mov    %eax,%edx
80109ff9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ffc:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109fff:	83 ec 0c             	sub    $0xc,%esp
8010a002:	68 90 38 00 00       	push   $0x3890
8010a007:	e8 8a f7 ff ff       	call   80109796 <H2N_ushort>
8010a00c:	83 c4 10             	add    $0x10,%esp
8010a00f:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a012:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a016:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a019:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a01f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a022:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a028:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a02b:	83 ec 0c             	sub    $0xc,%esp
8010a02e:	50                   	push   %eax
8010a02f:	e8 1f 00 00 00       	call   8010a053 <tcp_chksum>
8010a034:	83 c4 10             	add    $0x10,%esp
8010a037:	83 c0 08             	add    $0x8,%eax
8010a03a:	0f b7 c0             	movzwl %ax,%eax
8010a03d:	83 ec 0c             	sub    $0xc,%esp
8010a040:	50                   	push   %eax
8010a041:	e8 50 f7 ff ff       	call   80109796 <H2N_ushort>
8010a046:	83 c4 10             	add    $0x10,%esp
8010a049:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a04c:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a050:	90                   	nop
8010a051:	c9                   	leave
8010a052:	c3                   	ret

8010a053 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a053:	55                   	push   %ebp
8010a054:	89 e5                	mov    %esp,%ebp
8010a056:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a059:	8b 45 08             	mov    0x8(%ebp),%eax
8010a05c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a05f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a062:	83 c0 14             	add    $0x14,%eax
8010a065:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a068:	83 ec 04             	sub    $0x4,%esp
8010a06b:	6a 04                	push   $0x4
8010a06d:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a072:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a075:	50                   	push   %eax
8010a076:	e8 7b ab ff ff       	call   80104bf6 <memmove>
8010a07b:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a07e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a081:	83 c0 0c             	add    $0xc,%eax
8010a084:	83 ec 04             	sub    $0x4,%esp
8010a087:	6a 04                	push   $0x4
8010a089:	50                   	push   %eax
8010a08a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a08d:	83 c0 04             	add    $0x4,%eax
8010a090:	50                   	push   %eax
8010a091:	e8 60 ab ff ff       	call   80104bf6 <memmove>
8010a096:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a099:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a09d:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a0a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0a4:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a0a8:	0f b7 c0             	movzwl %ax,%eax
8010a0ab:	83 ec 0c             	sub    $0xc,%esp
8010a0ae:	50                   	push   %eax
8010a0af:	e8 cb f6 ff ff       	call   8010977f <N2H_ushort>
8010a0b4:	83 c4 10             	add    $0x10,%esp
8010a0b7:	83 e8 14             	sub    $0x14,%eax
8010a0ba:	0f b7 c0             	movzwl %ax,%eax
8010a0bd:	83 ec 0c             	sub    $0xc,%esp
8010a0c0:	50                   	push   %eax
8010a0c1:	e8 d0 f6 ff ff       	call   80109796 <H2N_ushort>
8010a0c6:	83 c4 10             	add    $0x10,%esp
8010a0c9:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a0cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a0d4:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a0d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a0da:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a0e1:	eb 33                	jmp    8010a116 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a0e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0e6:	01 c0                	add    %eax,%eax
8010a0e8:	89 c2                	mov    %eax,%edx
8010a0ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0ed:	01 d0                	add    %edx,%eax
8010a0ef:	0f b6 00             	movzbl (%eax),%eax
8010a0f2:	0f b6 c0             	movzbl %al,%eax
8010a0f5:	c1 e0 08             	shl    $0x8,%eax
8010a0f8:	89 c2                	mov    %eax,%edx
8010a0fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0fd:	01 c0                	add    %eax,%eax
8010a0ff:	8d 48 01             	lea    0x1(%eax),%ecx
8010a102:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a105:	01 c8                	add    %ecx,%eax
8010a107:	0f b6 00             	movzbl (%eax),%eax
8010a10a:	0f b6 c0             	movzbl %al,%eax
8010a10d:	01 d0                	add    %edx,%eax
8010a10f:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a112:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a116:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a11a:	7e c7                	jle    8010a0e3 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a11c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a11f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a122:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a129:	eb 33                	jmp    8010a15e <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a12b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a12e:	01 c0                	add    %eax,%eax
8010a130:	89 c2                	mov    %eax,%edx
8010a132:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a135:	01 d0                	add    %edx,%eax
8010a137:	0f b6 00             	movzbl (%eax),%eax
8010a13a:	0f b6 c0             	movzbl %al,%eax
8010a13d:	c1 e0 08             	shl    $0x8,%eax
8010a140:	89 c2                	mov    %eax,%edx
8010a142:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a145:	01 c0                	add    %eax,%eax
8010a147:	8d 48 01             	lea    0x1(%eax),%ecx
8010a14a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a14d:	01 c8                	add    %ecx,%eax
8010a14f:	0f b6 00             	movzbl (%eax),%eax
8010a152:	0f b6 c0             	movzbl %al,%eax
8010a155:	01 d0                	add    %edx,%eax
8010a157:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a15a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a15e:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a162:	0f b7 c0             	movzwl %ax,%eax
8010a165:	83 ec 0c             	sub    $0xc,%esp
8010a168:	50                   	push   %eax
8010a169:	e8 11 f6 ff ff       	call   8010977f <N2H_ushort>
8010a16e:	83 c4 10             	add    $0x10,%esp
8010a171:	66 d1 e8             	shr    $1,%ax
8010a174:	0f b7 c0             	movzwl %ax,%eax
8010a177:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a17a:	7c af                	jl     8010a12b <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a17c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a17f:	c1 e8 10             	shr    $0x10,%eax
8010a182:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a185:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a188:	f7 d0                	not    %eax
}
8010a18a:	c9                   	leave
8010a18b:	c3                   	ret

8010a18c <tcp_fin>:

void tcp_fin(){
8010a18c:	55                   	push   %ebp
8010a18d:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a18f:	c7 05 48 6e 19 80 01 	movl   $0x1,0x80196e48
8010a196:	00 00 00 
}
8010a199:	90                   	nop
8010a19a:	5d                   	pop    %ebp
8010a19b:	c3                   	ret

8010a19c <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a19c:	55                   	push   %ebp
8010a19d:	89 e5                	mov    %esp,%ebp
8010a19f:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a1a2:	8b 45 10             	mov    0x10(%ebp),%eax
8010a1a5:	83 ec 04             	sub    $0x4,%esp
8010a1a8:	6a 00                	push   $0x0
8010a1aa:	68 6b c4 10 80       	push   $0x8010c46b
8010a1af:	50                   	push   %eax
8010a1b0:	e8 65 00 00 00       	call   8010a21a <http_strcpy>
8010a1b5:	83 c4 10             	add    $0x10,%esp
8010a1b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a1bb:	8b 45 10             	mov    0x10(%ebp),%eax
8010a1be:	83 ec 04             	sub    $0x4,%esp
8010a1c1:	ff 75 f4             	push   -0xc(%ebp)
8010a1c4:	68 7e c4 10 80       	push   $0x8010c47e
8010a1c9:	50                   	push   %eax
8010a1ca:	e8 4b 00 00 00       	call   8010a21a <http_strcpy>
8010a1cf:	83 c4 10             	add    $0x10,%esp
8010a1d2:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a1d5:	8b 45 10             	mov    0x10(%ebp),%eax
8010a1d8:	83 ec 04             	sub    $0x4,%esp
8010a1db:	ff 75 f4             	push   -0xc(%ebp)
8010a1de:	68 99 c4 10 80       	push   $0x8010c499
8010a1e3:	50                   	push   %eax
8010a1e4:	e8 31 00 00 00       	call   8010a21a <http_strcpy>
8010a1e9:	83 c4 10             	add    $0x10,%esp
8010a1ec:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a1ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1f2:	83 e0 01             	and    $0x1,%eax
8010a1f5:	85 c0                	test   %eax,%eax
8010a1f7:	74 11                	je     8010a20a <http_proc+0x6e>
    char *payload = (char *)send;
8010a1f9:	8b 45 10             	mov    0x10(%ebp),%eax
8010a1fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a1ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a202:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a205:	01 d0                	add    %edx,%eax
8010a207:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a20a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a20d:	8b 45 14             	mov    0x14(%ebp),%eax
8010a210:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a212:	e8 75 ff ff ff       	call   8010a18c <tcp_fin>
}
8010a217:	90                   	nop
8010a218:	c9                   	leave
8010a219:	c3                   	ret

8010a21a <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a21a:	55                   	push   %ebp
8010a21b:	89 e5                	mov    %esp,%ebp
8010a21d:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a220:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a227:	eb 20                	jmp    8010a249 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a229:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a22c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a22f:	01 d0                	add    %edx,%eax
8010a231:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a234:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a237:	01 ca                	add    %ecx,%edx
8010a239:	89 d1                	mov    %edx,%ecx
8010a23b:	8b 55 08             	mov    0x8(%ebp),%edx
8010a23e:	01 ca                	add    %ecx,%edx
8010a240:	0f b6 00             	movzbl (%eax),%eax
8010a243:	88 02                	mov    %al,(%edx)
    i++;
8010a245:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a249:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a24c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a24f:	01 d0                	add    %edx,%eax
8010a251:	0f b6 00             	movzbl (%eax),%eax
8010a254:	84 c0                	test   %al,%al
8010a256:	75 d1                	jne    8010a229 <http_strcpy+0xf>
  }
  return i;
8010a258:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a25b:	c9                   	leave
8010a25c:	c3                   	ret

8010a25d <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a25d:	55                   	push   %ebp
8010a25e:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a260:	c7 05 50 6e 19 80 a2 	movl   $0x8010f5a2,0x80196e50
8010a267:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a26a:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a26f:	c1 e8 09             	shr    $0x9,%eax
8010a272:	a3 4c 6e 19 80       	mov    %eax,0x80196e4c
}
8010a277:	90                   	nop
8010a278:	5d                   	pop    %ebp
8010a279:	c3                   	ret

8010a27a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a27a:	55                   	push   %ebp
8010a27b:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a27d:	90                   	nop
8010a27e:	5d                   	pop    %ebp
8010a27f:	c3                   	ret

8010a280 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a280:	55                   	push   %ebp
8010a281:	89 e5                	mov    %esp,%ebp
8010a283:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a286:	8b 45 08             	mov    0x8(%ebp),%eax
8010a289:	83 c0 0c             	add    $0xc,%eax
8010a28c:	83 ec 0c             	sub    $0xc,%esp
8010a28f:	50                   	push   %eax
8010a290:	e8 9b a5 ff ff       	call   80104830 <holdingsleep>
8010a295:	83 c4 10             	add    $0x10,%esp
8010a298:	85 c0                	test   %eax,%eax
8010a29a:	75 0d                	jne    8010a2a9 <iderw+0x29>
    panic("iderw: buf not locked");
8010a29c:	83 ec 0c             	sub    $0xc,%esp
8010a29f:	68 aa c4 10 80       	push   $0x8010c4aa
8010a2a4:	e8 18 63 ff ff       	call   801005c1 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a2a9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2ac:	8b 00                	mov    (%eax),%eax
8010a2ae:	83 e0 06             	and    $0x6,%eax
8010a2b1:	83 f8 02             	cmp    $0x2,%eax
8010a2b4:	75 0d                	jne    8010a2c3 <iderw+0x43>
    panic("iderw: nothing to do");
8010a2b6:	83 ec 0c             	sub    $0xc,%esp
8010a2b9:	68 c0 c4 10 80       	push   $0x8010c4c0
8010a2be:	e8 fe 62 ff ff       	call   801005c1 <panic>
  if(b->dev != 1)
8010a2c3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2c6:	8b 40 04             	mov    0x4(%eax),%eax
8010a2c9:	83 f8 01             	cmp    $0x1,%eax
8010a2cc:	74 0d                	je     8010a2db <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a2ce:	83 ec 0c             	sub    $0xc,%esp
8010a2d1:	68 d5 c4 10 80       	push   $0x8010c4d5
8010a2d6:	e8 e6 62 ff ff       	call   801005c1 <panic>
  if(b->blockno >= disksize)
8010a2db:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2de:	8b 40 08             	mov    0x8(%eax),%eax
8010a2e1:	8b 15 4c 6e 19 80    	mov    0x80196e4c,%edx
8010a2e7:	39 d0                	cmp    %edx,%eax
8010a2e9:	72 0d                	jb     8010a2f8 <iderw+0x78>
    panic("iderw: block out of range");
8010a2eb:	83 ec 0c             	sub    $0xc,%esp
8010a2ee:	68 f3 c4 10 80       	push   $0x8010c4f3
8010a2f3:	e8 c9 62 ff ff       	call   801005c1 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a2f8:	8b 15 50 6e 19 80    	mov    0x80196e50,%edx
8010a2fe:	8b 45 08             	mov    0x8(%ebp),%eax
8010a301:	8b 40 08             	mov    0x8(%eax),%eax
8010a304:	c1 e0 09             	shl    $0x9,%eax
8010a307:	01 d0                	add    %edx,%eax
8010a309:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a30c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a30f:	8b 00                	mov    (%eax),%eax
8010a311:	83 e0 04             	and    $0x4,%eax
8010a314:	85 c0                	test   %eax,%eax
8010a316:	74 2b                	je     8010a343 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a318:	8b 45 08             	mov    0x8(%ebp),%eax
8010a31b:	8b 00                	mov    (%eax),%eax
8010a31d:	83 e0 fb             	and    $0xfffffffb,%eax
8010a320:	89 c2                	mov    %eax,%edx
8010a322:	8b 45 08             	mov    0x8(%ebp),%eax
8010a325:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a327:	8b 45 08             	mov    0x8(%ebp),%eax
8010a32a:	83 c0 5c             	add    $0x5c,%eax
8010a32d:	83 ec 04             	sub    $0x4,%esp
8010a330:	68 00 02 00 00       	push   $0x200
8010a335:	50                   	push   %eax
8010a336:	ff 75 f4             	push   -0xc(%ebp)
8010a339:	e8 b8 a8 ff ff       	call   80104bf6 <memmove>
8010a33e:	83 c4 10             	add    $0x10,%esp
8010a341:	eb 1a                	jmp    8010a35d <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a343:	8b 45 08             	mov    0x8(%ebp),%eax
8010a346:	83 c0 5c             	add    $0x5c,%eax
8010a349:	83 ec 04             	sub    $0x4,%esp
8010a34c:	68 00 02 00 00       	push   $0x200
8010a351:	ff 75 f4             	push   -0xc(%ebp)
8010a354:	50                   	push   %eax
8010a355:	e8 9c a8 ff ff       	call   80104bf6 <memmove>
8010a35a:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a35d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a360:	8b 00                	mov    (%eax),%eax
8010a362:	83 c8 02             	or     $0x2,%eax
8010a365:	89 c2                	mov    %eax,%edx
8010a367:	8b 45 08             	mov    0x8(%ebp),%eax
8010a36a:	89 10                	mov    %edx,(%eax)
}
8010a36c:	90                   	nop
8010a36d:	c9                   	leave
8010a36e:	c3                   	ret
