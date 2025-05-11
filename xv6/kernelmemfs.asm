
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
8010005a:	bc 80 8d 19 80       	mov    $0x80198d80,%esp
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
8010006f:	68 00 ac 10 80       	push   $0x8010ac00
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 3d 51 00 00       	call   801051bb <initlock>
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
801000bd:	68 07 ac 10 80       	push   $0x8010ac07
801000c2:	50                   	push   %eax
801000c3:	e8 96 4f 00 00       	call   8010505e <initsleeplock>
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
80100101:	e8 d7 50 00 00       	call   801051dd <acquire>
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
80100140:	e8 06 51 00 00       	call   8010524b <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 43 4f 00 00       	call   8010509a <acquiresleep>
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
801001c1:	e8 85 50 00 00       	call   8010524b <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 c2 4e 00 00       	call   8010509a <acquiresleep>
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
801001f5:	68 0e ac 10 80       	push   $0x8010ac0e
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
8010022d:	e8 c5 a8 00 00       	call   8010aaf7 <iderw>
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
8010024a:	e8 fd 4e 00 00       	call   8010514c <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 1f ac 10 80       	push   $0x8010ac1f
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
80100278:	e8 7a a8 00 00       	call   8010aaf7 <iderw>
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
80100293:	e8 b4 4e 00 00       	call   8010514c <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 26 ac 10 80       	push   $0x8010ac26
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 43 4e 00 00       	call   801050fe <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 12 4f 00 00       	call   801051dd <acquire>
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
80100336:	e8 10 4f 00 00       	call   8010524b <release>
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
80100410:	e8 c8 4d 00 00       	call   801051dd <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 2d ac 10 80       	push   $0x8010ac2d
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
80100510:	c7 45 ec 36 ac 10 80 	movl   $0x8010ac36,-0x14(%ebp)
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
8010059e:	e8 a8 4c 00 00       	call   8010524b <release>
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
801005c7:	68 3d ac 10 80       	push   $0x8010ac3d
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
801005e6:	68 51 ac 10 80       	push   $0x8010ac51
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 9a 4c 00 00       	call   8010529d <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 53 ac 10 80       	push   $0x8010ac53
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
801006a1:	e8 be 83 00 00       	call   80108a64 <graphic_scroll_up>
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
801006f4:	e8 6b 83 00 00       	call   80108a64 <graphic_scroll_up>
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
80100756:	e8 76 83 00 00       	call   80108ad1 <font_render>
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
80100793:	e8 46 67 00 00       	call   80106ede <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 39 67 00 00       	call   80106ede <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 2c 67 00 00       	call   80106ede <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x57>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 1c 67 00 00       	call   80106ede <uartputc>
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
801007eb:	e8 ed 49 00 00       	call   801051dd <acquire>
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
8010093f:	e8 e6 3c 00 00       	call   8010462a <wakeup>
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
8010096a:	e8 dc 48 00 00       	call   8010524b <release>
8010096f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100972:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100976:	74 05                	je     8010097d <consoleintr+0x1a7>
    procdump();  // now call procdump() wo. cons.lock held
80100978:	e8 68 3d 00 00       	call   801046e5 <procdump>
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
801009a2:	e8 36 48 00 00       	call   801051dd <acquire>
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
801009c3:	e8 83 48 00 00       	call   8010524b <release>
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
801009f0:	e8 4e 3b 00 00       	call   80104543 <sleep>
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
80100a6e:	e8 d8 47 00 00       	call   8010524b <release>
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
80100aac:	e8 2c 47 00 00       	call   801051dd <acquire>
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
80100aee:	e8 58 47 00 00       	call   8010524b <release>
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
80100b1c:	68 57 ac 10 80       	push   $0x8010ac57
80100b21:	68 00 1a 19 80       	push   $0x80191a00
80100b26:	e8 90 46 00 00       	call   801051bb <initlock>
80100b2b:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b2e:	c7 05 4c 1a 19 80 90 	movl   $0x80100a90,0x80191a4c
80100b35:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b38:	c7 05 48 1a 19 80 80 	movl   $0x80100980,0x80191a48
80100b3f:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b42:	c7 45 f4 5f ac 10 80 	movl   $0x8010ac5f,-0xc(%ebp)
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
80100bbf:	68 75 ac 10 80       	push   $0x8010ac75
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
80100c1b:	e8 ba 72 00 00       	call   80107eda <setupkvm>
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
80100cc1:	e8 0e 76 00 00       	call   801082d4 <allocuvm>
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
80100d07:	e8 fb 74 00 00       	call   80108207 <loaduvm>
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
80100d76:	e8 59 75 00 00       	call   801082d4 <allocuvm>
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
80100d9a:	e8 97 77 00 00       	call   80108536 <clearpteu>
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
80100dd3:	e8 c9 48 00 00       	call   801056a1 <strlen>
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
80100e00:	e8 9c 48 00 00       	call   801056a1 <strlen>
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
80100e26:	e8 aa 78 00 00       	call   801086d5 <copyout>
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
80100ec2:	e8 0e 78 00 00       	call   801086d5 <copyout>
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
80100f10:	e8 41 47 00 00       	call   80105656 <safestrcpy>
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
80100f53:	e8 a0 70 00 00       	call   80107ff8 <switchuvm>
80100f58:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 cc             	push   -0x34(%ebp)
80100f61:	e8 37 75 00 00       	call   8010849d <freevm>
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
80100fa1:	e8 f7 74 00 00       	call   8010849d <freevm>
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
80100fd2:	68 81 ac 10 80       	push   $0x8010ac81
80100fd7:	68 a0 1a 19 80       	push   $0x80191aa0
80100fdc:	e8 da 41 00 00       	call   801051bb <initlock>
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
80100ff5:	e8 e3 41 00 00       	call   801051dd <acquire>
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
80101022:	e8 24 42 00 00       	call   8010524b <release>
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
80101045:	e8 01 42 00 00       	call   8010524b <release>
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
80101062:	e8 76 41 00 00       	call   801051dd <acquire>
80101067:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106a:	8b 45 08             	mov    0x8(%ebp),%eax
8010106d:	8b 40 04             	mov    0x4(%eax),%eax
80101070:	85 c0                	test   %eax,%eax
80101072:	7f 0d                	jg     80101081 <filedup+0x2d>
    panic("filedup");
80101074:	83 ec 0c             	sub    $0xc,%esp
80101077:	68 88 ac 10 80       	push   $0x8010ac88
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
80101098:	e8 ae 41 00 00       	call   8010524b <release>
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
801010b3:	e8 25 41 00 00       	call   801051dd <acquire>
801010b8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bb:	8b 45 08             	mov    0x8(%ebp),%eax
801010be:	8b 40 04             	mov    0x4(%eax),%eax
801010c1:	85 c0                	test   %eax,%eax
801010c3:	7f 0d                	jg     801010d2 <fileclose+0x2d>
    panic("fileclose");
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	68 90 ac 10 80       	push   $0x8010ac90
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
801010f3:	e8 53 41 00 00       	call   8010524b <release>
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
80101141:	e8 05 41 00 00       	call   8010524b <release>
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
80101290:	68 9a ac 10 80       	push   $0x8010ac9a
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
80101393:	68 a3 ac 10 80       	push   $0x8010aca3
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
801013c9:	68 b3 ac 10 80       	push   $0x8010acb3
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
80101401:	e8 0c 41 00 00       	call   80105512 <memmove>
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
80101447:	e8 07 40 00 00       	call   80105453 <memset>
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
801015a5:	68 c0 ac 10 80       	push   $0x8010acc0
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
80101630:	68 d6 ac 10 80       	push   $0x8010acd6
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
80101694:	68 e9 ac 10 80       	push   $0x8010ace9
80101699:	68 60 24 19 80       	push   $0x80192460
8010169e:	e8 18 3b 00 00       	call   801051bb <initlock>
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
801016ca:	68 f0 ac 10 80       	push   $0x8010acf0
801016cf:	50                   	push   %eax
801016d0:	e8 89 39 00 00       	call   8010505e <initsleeplock>
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
80101729:	68 f8 ac 10 80       	push   $0x8010acf8
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
801017a2:	e8 ac 3c 00 00       	call   80105453 <memset>
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
80101809:	68 4b ad 10 80       	push   $0x8010ad4b
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
801018af:	e8 5e 3c 00 00       	call   80105512 <memmove>
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
801018e4:	e8 f4 38 00 00       	call   801051dd <acquire>
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
80101932:	e8 14 39 00 00       	call   8010524b <release>
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
8010196e:	68 5d ad 10 80       	push   $0x8010ad5d
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
801019ab:	e8 9b 38 00 00       	call   8010524b <release>
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
801019c6:	e8 12 38 00 00       	call   801051dd <acquire>
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
801019e5:	e8 61 38 00 00       	call   8010524b <release>
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
80101a0b:	68 6d ad 10 80       	push   $0x8010ad6d
80101a10:	e8 94 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	83 c0 0c             	add    $0xc,%eax
80101a1b:	83 ec 0c             	sub    $0xc,%esp
80101a1e:	50                   	push   %eax
80101a1f:	e8 76 36 00 00       	call   8010509a <acquiresleep>
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
80101ac9:	e8 44 3a 00 00       	call   80105512 <memmove>
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
80101af8:	68 73 ad 10 80       	push   $0x8010ad73
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
80101b1b:	e8 2c 36 00 00       	call   8010514c <holdingsleep>
80101b20:	83 c4 10             	add    $0x10,%esp
80101b23:	85 c0                	test   %eax,%eax
80101b25:	74 0a                	je     80101b31 <iunlock+0x2c>
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	8b 40 08             	mov    0x8(%eax),%eax
80101b2d:	85 c0                	test   %eax,%eax
80101b2f:	7f 0d                	jg     80101b3e <iunlock+0x39>
    panic("iunlock");
80101b31:	83 ec 0c             	sub    $0xc,%esp
80101b34:	68 82 ad 10 80       	push   $0x8010ad82
80101b39:	e8 6b ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	83 c0 0c             	add    $0xc,%eax
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	50                   	push   %eax
80101b48:	e8 b1 35 00 00       	call   801050fe <releasesleep>
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
80101b63:	e8 32 35 00 00       	call   8010509a <acquiresleep>
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
80101b89:	e8 4f 36 00 00       	call   801051dd <acquire>
80101b8e:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	8b 40 08             	mov    0x8(%eax),%eax
80101b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	68 60 24 19 80       	push   $0x80192460
80101ba2:	e8 a4 36 00 00       	call   8010524b <release>
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
80101be9:	e8 10 35 00 00       	call   801050fe <releasesleep>
80101bee:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	68 60 24 19 80       	push   $0x80192460
80101bf9:	e8 df 35 00 00       	call   801051dd <acquire>
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
80101c18:	e8 2e 36 00 00       	call   8010524b <release>
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
80101d5c:	68 8a ad 10 80       	push   $0x8010ad8a
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
80101ffa:	e8 13 35 00 00       	call   80105512 <memmove>
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
8010214a:	e8 c3 33 00 00       	call   80105512 <memmove>
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
801021ca:	e8 d9 33 00 00       	call   801055a8 <strncmp>
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
801021ea:	68 9d ad 10 80       	push   $0x8010ad9d
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
80102219:	68 af ad 10 80       	push   $0x8010adaf
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
801022ee:	68 be ad 10 80       	push   $0x8010adbe
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
80102329:	e8 d0 32 00 00       	call   801055fe <strncpy>
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
80102355:	68 cb ad 10 80       	push   $0x8010adcb
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
801023c7:	e8 46 31 00 00       	call   80105512 <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	eb 26                	jmp    801023f7 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	50                   	push   %eax
801023d8:	ff 75 f4             	push   -0xc(%ebp)
801023db:	ff 75 0c             	push   0xc(%ebp)
801023de:	e8 2f 31 00 00       	call   80105512 <memmove>
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
801025c3:	0f b6 05 58 7a 19 80 	movzbl 0x80197a58,%eax
801025ca:	0f b6 c0             	movzbl %al,%eax
801025cd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025d0:	74 10                	je     801025e2 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025d2:	83 ec 0c             	sub    $0xc,%esp
801025d5:	68 d4 ad 10 80       	push   $0x8010add4
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
8010267c:	68 06 ae 10 80       	push   $0x8010ae06
80102681:	68 c0 40 19 80       	push   $0x801940c0
80102686:	e8 30 2b 00 00       	call   801051bb <initlock>
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
8010273b:	68 0b ae 10 80       	push   $0x8010ae0b
80102740:	e8 64 de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102745:	83 ec 04             	sub    $0x4,%esp
80102748:	68 00 10 00 00       	push   $0x1000
8010274d:	6a 01                	push   $0x1
8010274f:	ff 75 08             	push   0x8(%ebp)
80102752:	e8 fc 2c 00 00       	call   80105453 <memset>
80102757:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010275a:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010275f:	85 c0                	test   %eax,%eax
80102761:	74 10                	je     80102773 <kfree+0x65>
    acquire(&kmem.lock);
80102763:	83 ec 0c             	sub    $0xc,%esp
80102766:	68 c0 40 19 80       	push   $0x801940c0
8010276b:	e8 6d 2a 00 00       	call   801051dd <acquire>
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
8010279d:	e8 a9 2a 00 00       	call   8010524b <release>
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
801027bf:	e8 19 2a 00 00       	call   801051dd <acquire>
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
801027f0:	e8 56 2a 00 00       	call   8010524b <release>
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
80102d14:	e8 a1 27 00 00       	call   801054ba <memcmp>
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
80102e28:	68 11 ae 10 80       	push   $0x8010ae11
80102e2d:	68 20 41 19 80       	push   $0x80194120
80102e32:	e8 84 23 00 00       	call   801051bb <initlock>
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
80102edd:	e8 30 26 00 00       	call   80105512 <memmove>
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
8010304c:	e8 8c 21 00 00       	call   801051dd <acquire>
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
8010306a:	e8 d4 14 00 00       	call   80104543 <sleep>
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
8010309f:	e8 9f 14 00 00       	call   80104543 <sleep>
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
801030be:	e8 88 21 00 00       	call   8010524b <release>
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
801030df:	e8 f9 20 00 00       	call   801051dd <acquire>
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
80103100:	68 15 ae 10 80       	push   $0x8010ae15
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
8010312e:	e8 f7 14 00 00       	call   8010462a <wakeup>
80103133:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103136:	83 ec 0c             	sub    $0xc,%esp
80103139:	68 20 41 19 80       	push   $0x80194120
8010313e:	e8 08 21 00 00       	call   8010524b <release>
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
80103159:	e8 7f 20 00 00       	call   801051dd <acquire>
8010315e:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103161:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103168:	00 00 00 
    wakeup(&log);
8010316b:	83 ec 0c             	sub    $0xc,%esp
8010316e:	68 20 41 19 80       	push   $0x80194120
80103173:	e8 b2 14 00 00       	call   8010462a <wakeup>
80103178:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010317b:	83 ec 0c             	sub    $0xc,%esp
8010317e:	68 20 41 19 80       	push   $0x80194120
80103183:	e8 c3 20 00 00       	call   8010524b <release>
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
801031ff:	e8 0e 23 00 00       	call   80105512 <memmove>
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
8010329c:	68 24 ae 10 80       	push   $0x8010ae24
801032a1:	e8 03 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a6:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032ab:	85 c0                	test   %eax,%eax
801032ad:	7f 0d                	jg     801032bc <log_write+0x45>
    panic("log_write outside of trans");
801032af:	83 ec 0c             	sub    $0xc,%esp
801032b2:	68 3a ae 10 80       	push   $0x8010ae3a
801032b7:	e8 ed d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032bc:	83 ec 0c             	sub    $0xc,%esp
801032bf:	68 20 41 19 80       	push   $0x80194120
801032c4:	e8 14 1f 00 00       	call   801051dd <acquire>
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
80103342:	e8 04 1f 00 00       	call   8010524b <release>
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
80103378:	e8 2c 56 00 00       	call   801089a9 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337d:	83 ec 08             	sub    $0x8,%esp
80103380:	68 00 00 40 80       	push   $0x80400000
80103385:	68 00 90 19 80       	push   $0x80199000
8010338a:	e8 e4 f2 ff ff       	call   80102673 <kinit1>
8010338f:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103392:	e8 30 4c 00 00       	call   80107fc7 <kvmalloc>
  mpinit_uefi();
80103397:	e8 d7 53 00 00       	call   80108773 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339c:	e8 3f f6 ff ff       	call   801029e0 <lapicinit>
  seginit();       // segment descriptors
801033a1:	e8 b8 46 00 00       	call   80107a5e <seginit>
  picinit();    // disable pic
801033a6:	e8 9b 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033ab:	e8 de f1 ff ff       	call   8010258e <ioapicinit>
  consoleinit();   // console hardware
801033b0:	e8 54 d7 ff ff       	call   80100b09 <consoleinit>
  uartinit();      // serial port
801033b5:	e8 3d 3a 00 00       	call   80106df7 <uartinit>
  pinit();         // process table
801033ba:	e8 c0 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bf:	e8 fc 34 00 00       	call   801068c0 <tvinit>
  binit();         // buffer cache
801033c4:	e8 9d cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c9:	e8 fb db ff ff       	call   80100fc9 <fileinit>
  ideinit();       // disk 
801033ce:	e8 01 77 00 00       	call   8010aad4 <ideinit>
  startothers();   // start other processors
801033d3:	e8 8a 00 00 00       	call   80103462 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d8:	83 ec 08             	sub    $0x8,%esp
801033db:	68 00 00 00 a0       	push   $0xa0000000
801033e0:	68 00 00 40 80       	push   $0x80400000
801033e5:	e8 c2 f2 ff ff       	call   801026ac <kinit2>
801033ea:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033ed:	e8 12 58 00 00       	call   80108c04 <pci_init>
  arp_scan();
801033f2:	e8 47 65 00 00       	call   8010993e <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f7:	e8 ff 07 00 00       	call   80103bfb <userinit>

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
80103407:	e8 d3 4b 00 00       	call   80107fdf <switchkvm>
  seginit();
8010340c:	e8 4d 46 00 00       	call   80107a5e <seginit>
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
80103433:	68 55 ae 10 80       	push   $0x8010ae55
80103438:	e8 b7 cf ff ff       	call   801003f4 <cprintf>
8010343d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103440:	e8 f1 35 00 00       	call   80106a36 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103445:	e8 6e 05 00 00       	call   801039b8 <mycpu>
8010344a:	05 a0 00 00 00       	add    $0xa0,%eax
8010344f:	83 ec 08             	sub    $0x8,%esp
80103452:	6a 01                	push   $0x1
80103454:	50                   	push   %eax
80103455:	e8 f3 fe ff ff       	call   8010334d <xchg>
8010345a:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345d:	e8 06 0e 00 00       	call   80104268 <scheduler>

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
80103480:	e8 8d 20 00 00       	call   80105512 <memmove>
80103485:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103488:	c7 45 f4 a0 79 19 80 	movl   $0x801979a0,-0xc(%ebp)
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
8010350a:	a1 54 7a 19 80       	mov    0x80197a54,%eax
8010350f:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103515:	05 a0 79 19 80       	add    $0x801979a0,%eax
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
80103607:	68 69 ae 10 80       	push   $0x8010ae69
8010360c:	50                   	push   %eax
8010360d:	e8 a9 1b 00 00       	call   801051bb <initlock>
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
801036cc:	e8 0c 1b 00 00       	call   801051dd <acquire>
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
801036f3:	e8 32 0f 00 00       	call   8010462a <wakeup>
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
80103716:	e8 0f 0f 00 00       	call   8010462a <wakeup>
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
8010373f:	e8 07 1b 00 00       	call   8010524b <release>
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
8010375e:	e8 e8 1a 00 00       	call   8010524b <release>
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
80103778:	e8 60 1a 00 00       	call   801051dd <acquire>
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
801037ac:	e8 9a 1a 00 00       	call   8010524b <release>
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
801037ca:	e8 5b 0e 00 00       	call   8010462a <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 5b 0d 00 00       	call   80104543 <sleep>
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
8010384d:	e8 d8 0d 00 00       	call   8010462a <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 ea 19 00 00       	call   8010524b <release>
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
80103879:	e8 5f 19 00 00       	call   801051dd <acquire>
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
80103896:	e8 b0 19 00 00       	call   8010524b <release>
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
801038b9:	e8 85 0c 00 00       	call   80104543 <sleep>
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
8010394c:	e8 d9 0c 00 00       	call   8010462a <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 eb 18 00 00       	call   8010524b <release>
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
void enqueue(struct proc *p, int level);
struct proc* dequeue(int level);

void
pinit(void)
{
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
80103982:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 70 ae 10 80       	push   $0x8010ae70
8010398d:	68 00 52 19 80       	push   $0x80195200
80103992:	e8 24 18 00 00       	call   801051bb <initlock>
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
801039a8:	2d a0 79 19 80       	sub    $0x801979a0,%eax
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
801039cf:	68 78 ae 10 80       	push   $0x8010ae78
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
801039f3:	05 a0 79 19 80       	add    $0x801979a0,%eax
801039f8:	0f b6 00             	movzbl (%eax),%eax
801039fb:	0f b6 c0             	movzbl %al,%eax
801039fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a01:	75 10                	jne    80103a13 <mycpu+0x5b>
      return &cpus[i];
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80103a0c:	05 a0 79 19 80       	add    $0x801979a0,%eax
80103a11:	eb 1b                	jmp    80103a2e <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a17:	a1 54 7a 19 80       	mov    0x80197a54,%eax
80103a1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1f:	7c c9                	jl     801039ea <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 9e ae 10 80       	push   $0x8010ae9e
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
80103a36:	e8 0d 19 00 00       	call   80105348 <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 41 19 00 00       	call   80105395 <popcli>
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
80103a62:	68 00 52 19 80       	push   $0x80195200
80103a67:	e8 71 17 00 00       	call   801051dd <acquire>
80103a6c:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6f:	c7 45 f4 34 52 19 80 	movl   $0x80195234,-0xc(%ebp)
80103a76:	eb 0e                	jmp    80103a86 <allocproc+0x2d>
    if(p->state == UNUSED){
80103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7b:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7e:	85 c0                	test   %eax,%eax
80103a80:	74 27                	je     80103aa9 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a82:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103a86:	81 7d f4 34 71 19 80 	cmpl   $0x80197134,-0xc(%ebp)
80103a8d:	72 e9                	jb     80103a78 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a8f:	83 ec 0c             	sub    $0xc,%esp
80103a92:	68 00 52 19 80       	push   $0x80195200
80103a97:	e8 af 17 00 00       	call   8010524b <release>
80103a9c:	83 c4 10             	add    $0x10,%esp
  return 0;
80103a9f:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa4:	e9 50 01 00 00       	jmp    80103bf9 <allocproc+0x1a0>
      goto found;
80103aa9:	90                   	nop

found:
  p->state = EMBRYO;
80103aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aad:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid;
80103ab4:	8b 15 00 f0 10 80    	mov    0x8010f000,%edx
80103aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103abd:	89 50 10             	mov    %edx,0x10(%eax)
  nextpid++;
80103ac0:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103ac5:	83 c0 01             	add    $0x1,%eax
80103ac8:	a3 00 f0 10 80       	mov    %eax,0x8010f000

  int i = p - ptable.proc; // kernel_pstat 인덱스 계산
80103acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad0:	2d 34 52 19 80       	sub    $0x80195234,%eax
80103ad5:	c1 f8 02             	sar    $0x2,%eax
80103ad8:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80103ade:	89 45 f0             	mov    %eax,-0x10(%ebp)
  kernel_pstat.inuse[i] = 1;
80103ae1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ae4:	c7 04 85 00 42 19 80 	movl   $0x1,-0x7fe6be00(,%eax,4)
80103aeb:	01 00 00 00 
  kernel_pstat.pid[i] = p->pid;
80103aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af2:	8b 40 10             	mov    0x10(%eax),%eax
80103af5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103af8:	83 c2 40             	add    $0x40,%edx
80103afb:	89 04 95 00 42 19 80 	mov    %eax,-0x7fe6be00(,%edx,4)
  kernel_pstat.priority[i] = 3; // 기본 우선순위 (Q3)
80103b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b05:	83 e8 80             	sub    $0xffffff80,%eax
80103b08:	c7 04 85 00 42 19 80 	movl   $0x3,-0x7fe6be00(,%eax,4)
80103b0f:	03 00 00 00 
  memset(kernel_pstat.ticks[i], 0, sizeof(kernel_pstat.ticks[i]));
80103b13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b16:	83 c0 40             	add    $0x40,%eax
80103b19:	c1 e0 04             	shl    $0x4,%eax
80103b1c:	05 00 42 19 80       	add    $0x80194200,%eax
80103b21:	83 ec 04             	sub    $0x4,%esp
80103b24:	6a 10                	push   $0x10
80103b26:	6a 00                	push   $0x0
80103b28:	50                   	push   %eax
80103b29:	e8 25 19 00 00       	call   80105453 <memset>
80103b2e:	83 c4 10             	add    $0x10,%esp
  memset(kernel_pstat.wait_ticks[i], 0, sizeof(kernel_pstat.wait_ticks[i]));
80103b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b34:	83 e8 80             	sub    $0xffffff80,%eax
80103b37:	c1 e0 04             	shl    $0x4,%eax
80103b3a:	05 00 42 19 80       	add    $0x80194200,%eax
80103b3f:	83 ec 04             	sub    $0x4,%esp
80103b42:	6a 10                	push   $0x10
80103b44:	6a 00                	push   $0x0
80103b46:	50                   	push   %eax
80103b47:	e8 07 19 00 00       	call   80105453 <memset>
80103b4c:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103b4f:	83 ec 0c             	sub    $0xc,%esp
80103b52:	68 00 52 19 80       	push   $0x80195200
80103b57:	e8 ef 16 00 00       	call   8010524b <release>
80103b5c:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103b5f:	e8 44 ec ff ff       	call   801027a8 <kalloc>
80103b64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b67:	89 42 08             	mov    %eax,0x8(%edx)
80103b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6d:	8b 40 08             	mov    0x8(%eax),%eax
80103b70:	85 c0                	test   %eax,%eax
80103b72:	75 28                	jne    80103b9c <allocproc+0x143>
    cprintf("[ALLOC ERROR] kstack alloc failed for PID=%d\n", p->pid);
80103b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b77:	8b 40 10             	mov    0x10(%eax),%eax
80103b7a:	83 ec 08             	sub    $0x8,%esp
80103b7d:	50                   	push   %eax
80103b7e:	68 b0 ae 10 80       	push   $0x8010aeb0
80103b83:	e8 6c c8 ff ff       	call   801003f4 <cprintf>
80103b88:	83 c4 10             	add    $0x10,%esp
    p->state = UNUSED;
80103b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103b95:	b8 00 00 00 00       	mov    $0x0,%eax
80103b9a:	eb 5d                	jmp    80103bf9 <allocproc+0x1a0>
  }
  sp = p->kstack + KSTACKSIZE;
80103b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9f:	8b 40 08             	mov    0x8(%eax),%eax
80103ba2:	05 00 10 00 00       	add    $0x1000,%eax
80103ba7:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103baa:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
80103bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb1:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103bb4:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103bb7:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
80103bbb:	ba 7a 68 10 80       	mov    $0x8010687a,%edx
80103bc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bc3:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103bc5:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
80103bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcc:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103bcf:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd5:	8b 40 1c             	mov    0x1c(%eax),%eax
80103bd8:	83 ec 04             	sub    $0x4,%esp
80103bdb:	6a 14                	push   $0x14
80103bdd:	6a 00                	push   $0x0
80103bdf:	50                   	push   %eax
80103be0:	e8 6e 18 00 00       	call   80105453 <memset>
80103be5:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103beb:	8b 40 1c             	mov    0x1c(%eax),%eax
80103bee:	ba fd 44 10 80       	mov    $0x801044fd,%edx
80103bf3:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103bf9:	c9                   	leave
80103bfa:	c3                   	ret

80103bfb <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103bfb:	55                   	push   %ebp
80103bfc:	89 e5                	mov    %esp,%ebp
80103bfe:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103c01:	e8 53 fe ff ff       	call   80103a59 <allocproc>
80103c06:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0c:	a3 54 71 19 80       	mov    %eax,0x80197154
  if((p->pgdir = setupkvm()) == 0){
80103c11:	e8 c4 42 00 00       	call   80107eda <setupkvm>
80103c16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c19:	89 42 04             	mov    %eax,0x4(%edx)
80103c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1f:	8b 40 04             	mov    0x4(%eax),%eax
80103c22:	85 c0                	test   %eax,%eax
80103c24:	75 0d                	jne    80103c33 <userinit+0x38>
    panic("userinit: out of memory?");
80103c26:	83 ec 0c             	sub    $0xc,%esp
80103c29:	68 de ae 10 80       	push   $0x8010aede
80103c2e:	e8 76 c9 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103c33:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3b:	8b 40 04             	mov    0x4(%eax),%eax
80103c3e:	83 ec 04             	sub    $0x4,%esp
80103c41:	52                   	push   %edx
80103c42:	68 0c f5 10 80       	push   $0x8010f50c
80103c47:	50                   	push   %eax
80103c48:	e8 4a 45 00 00       	call   80108197 <inituvm>
80103c4d:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c53:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5c:	8b 40 18             	mov    0x18(%eax),%eax
80103c5f:	83 ec 04             	sub    $0x4,%esp
80103c62:	6a 4c                	push   $0x4c
80103c64:	6a 00                	push   $0x0
80103c66:	50                   	push   %eax
80103c67:	e8 e7 17 00 00       	call   80105453 <memset>
80103c6c:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c72:	8b 40 18             	mov    0x18(%eax),%eax
80103c75:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7e:	8b 40 18             	mov    0x18(%eax),%eax
80103c81:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8a:	8b 50 18             	mov    0x18(%eax),%edx
80103c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c90:	8b 40 18             	mov    0x18(%eax),%eax
80103c93:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c97:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9e:	8b 50 18             	mov    0x18(%eax),%edx
80103ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca4:	8b 40 18             	mov    0x18(%eax),%eax
80103ca7:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103cab:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb2:	8b 40 18             	mov    0x18(%eax),%eax
80103cb5:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cbf:	8b 40 18             	mov    0x18(%eax),%eax
80103cc2:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ccc:	8b 40 18             	mov    0x18(%eax),%eax
80103ccf:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd9:	83 c0 6c             	add    $0x6c,%eax
80103cdc:	83 ec 04             	sub    $0x4,%esp
80103cdf:	6a 10                	push   $0x10
80103ce1:	68 f7 ae 10 80       	push   $0x8010aef7
80103ce6:	50                   	push   %eax
80103ce7:	e8 6a 19 00 00       	call   80105656 <safestrcpy>
80103cec:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103cef:	83 ec 0c             	sub    $0xc,%esp
80103cf2:	68 00 af 10 80       	push   $0x8010af00
80103cf7:	e8 29 e8 ff ff       	call   80102525 <namei>
80103cfc:	83 c4 10             	add    $0x10,%esp
80103cff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d02:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103d05:	83 ec 0c             	sub    $0xc,%esp
80103d08:	68 00 52 19 80       	push   $0x80195200
80103d0d:	e8 cb 14 00 00       	call   801051dd <acquire>
80103d12:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d18:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  if (mycpu()->sched_policy > 0)
80103d1f:	e8 94 fc ff ff       	call   801039b8 <mycpu>
80103d24:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80103d2a:	85 c0                	test   %eax,%eax
80103d2c:	7e 10                	jle    80103d3e <userinit+0x143>
  enqueue(p, 3);
80103d2e:	83 ec 08             	sub    $0x8,%esp
80103d31:	6a 03                	push   $0x3
80103d33:	ff 75 f4             	push   -0xc(%ebp)
80103d36:	e8 de 0c 00 00       	call   80104a19 <enqueue>
80103d3b:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103d3e:	83 ec 0c             	sub    $0xc,%esp
80103d41:	68 00 52 19 80       	push   $0x80195200
80103d46:	e8 00 15 00 00       	call   8010524b <release>
80103d4b:	83 c4 10             	add    $0x10,%esp
}
80103d4e:	90                   	nop
80103d4f:	c9                   	leave
80103d50:	c3                   	ret

80103d51 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103d51:	55                   	push   %ebp
80103d52:	89 e5                	mov    %esp,%ebp
80103d54:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103d57:	e8 d4 fc ff ff       	call   80103a30 <myproc>
80103d5c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103d5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d62:	8b 00                	mov    (%eax),%eax
80103d64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103d67:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d6b:	7e 2e                	jle    80103d9b <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d6d:	8b 55 08             	mov    0x8(%ebp),%edx
80103d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d73:	01 c2                	add    %eax,%edx
80103d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d78:	8b 40 04             	mov    0x4(%eax),%eax
80103d7b:	83 ec 04             	sub    $0x4,%esp
80103d7e:	52                   	push   %edx
80103d7f:	ff 75 f4             	push   -0xc(%ebp)
80103d82:	50                   	push   %eax
80103d83:	e8 4c 45 00 00       	call   801082d4 <allocuvm>
80103d88:	83 c4 10             	add    $0x10,%esp
80103d8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d92:	75 3b                	jne    80103dcf <growproc+0x7e>
      return -1;
80103d94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d99:	eb 4f                	jmp    80103dea <growproc+0x99>
  } else if(n < 0){
80103d9b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103d9f:	79 2e                	jns    80103dcf <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103da1:	8b 55 08             	mov    0x8(%ebp),%edx
80103da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da7:	01 c2                	add    %eax,%edx
80103da9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dac:	8b 40 04             	mov    0x4(%eax),%eax
80103daf:	83 ec 04             	sub    $0x4,%esp
80103db2:	52                   	push   %edx
80103db3:	ff 75 f4             	push   -0xc(%ebp)
80103db6:	50                   	push   %eax
80103db7:	e8 1d 46 00 00       	call   801083d9 <deallocuvm>
80103dbc:	83 c4 10             	add    $0x10,%esp
80103dbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103dc2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103dc6:	75 07                	jne    80103dcf <growproc+0x7e>
      return -1;
80103dc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dcd:	eb 1b                	jmp    80103dea <growproc+0x99>
  }
  curproc->sz = sz;
80103dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103dd5:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103dd7:	83 ec 0c             	sub    $0xc,%esp
80103dda:	ff 75 f0             	push   -0x10(%ebp)
80103ddd:	e8 16 42 00 00       	call   80107ff8 <switchuvm>
80103de2:	83 c4 10             	add    $0x10,%esp
  return 0;
80103de5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103dea:	c9                   	leave
80103deb:	c3                   	ret

80103dec <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103dec:	55                   	push   %ebp
80103ded:	89 e5                	mov    %esp,%ebp
80103def:	57                   	push   %edi
80103df0:	56                   	push   %esi
80103df1:	53                   	push   %ebx
80103df2:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103df5:	e8 36 fc ff ff       	call   80103a30 <myproc>
80103dfa:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if ((np = allocproc()) == 0) {
80103dfd:	e8 57 fc ff ff       	call   80103a59 <allocproc>
80103e02:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103e05:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103e09:	75 0a                	jne    80103e15 <fork+0x29>
    return -1;
80103e0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e10:	e9 e9 01 00 00       	jmp    80103ffe <fork+0x212>
  }

  // Copy process state from proc.
  if ((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0) {
80103e15:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e18:	8b 10                	mov    (%eax),%edx
80103e1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e1d:	8b 40 04             	mov    0x4(%eax),%eax
80103e20:	83 ec 08             	sub    $0x8,%esp
80103e23:	52                   	push   %edx
80103e24:	50                   	push   %eax
80103e25:	e8 4d 47 00 00       	call   80108577 <copyuvm>
80103e2a:	83 c4 10             	add    $0x10,%esp
80103e2d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e30:	89 42 04             	mov    %eax,0x4(%edx)
80103e33:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e36:	8b 40 04             	mov    0x4(%eax),%eax
80103e39:	85 c0                	test   %eax,%eax
80103e3b:	75 30                	jne    80103e6d <fork+0x81>
    kfree(np->kstack);
80103e3d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e40:	8b 40 08             	mov    0x8(%eax),%eax
80103e43:	83 ec 0c             	sub    $0xc,%esp
80103e46:	50                   	push   %eax
80103e47:	e8 c2 e8 ff ff       	call   8010270e <kfree>
80103e4c:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103e4f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e52:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103e59:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e5c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103e63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e68:	e9 91 01 00 00       	jmp    80103ffe <fork+0x212>
  }
  np->sz = curproc->sz;
80103e6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e70:	8b 10                	mov    (%eax),%edx
80103e72:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e75:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103e77:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e7a:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103e7d:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103e80:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e83:	8b 48 18             	mov    0x18(%eax),%ecx
80103e86:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e89:	8b 40 18             	mov    0x18(%eax),%eax
80103e8c:	89 c2                	mov    %eax,%edx
80103e8e:	89 cb                	mov    %ecx,%ebx
80103e90:	b8 13 00 00 00       	mov    $0x13,%eax
80103e95:	89 d7                	mov    %edx,%edi
80103e97:	89 de                	mov    %ebx,%esi
80103e99:	89 c1                	mov    %eax,%ecx
80103e9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103e9d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ea0:	8b 40 18             	mov    0x18(%eax),%eax
80103ea3:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for (i = 0; i < NOFILE; i++)
80103eaa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103eb1:	eb 3b                	jmp    80103eee <fork+0x102>
    if (curproc->ofile[i])
80103eb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103eb6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103eb9:	83 c2 08             	add    $0x8,%edx
80103ebc:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ec0:	85 c0                	test   %eax,%eax
80103ec2:	74 26                	je     80103eea <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103ec4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ec7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103eca:	83 c2 08             	add    $0x8,%edx
80103ecd:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ed1:	83 ec 0c             	sub    $0xc,%esp
80103ed4:	50                   	push   %eax
80103ed5:	e8 7a d1 ff ff       	call   80101054 <filedup>
80103eda:	83 c4 10             	add    $0x10,%esp
80103edd:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103ee0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103ee3:	83 c1 08             	add    $0x8,%ecx
80103ee6:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for (i = 0; i < NOFILE; i++)
80103eea:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103eee:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103ef2:	7e bf                	jle    80103eb3 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103ef4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ef7:	8b 40 68             	mov    0x68(%eax),%eax
80103efa:	83 ec 0c             	sub    $0xc,%esp
80103efd:	50                   	push   %eax
80103efe:	e8 b5 da ff ff       	call   801019b8 <idup>
80103f03:	83 c4 10             	add    $0x10,%esp
80103f06:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103f09:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103f0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f0f:	8d 50 6c             	lea    0x6c(%eax),%edx
80103f12:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f15:	83 c0 6c             	add    $0x6c,%eax
80103f18:	83 ec 04             	sub    $0x4,%esp
80103f1b:	6a 10                	push   $0x10
80103f1d:	52                   	push   %edx
80103f1e:	50                   	push   %eax
80103f1f:	e8 32 17 00 00       	call   80105656 <safestrcpy>
80103f24:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103f27:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f2a:	8b 40 10             	mov    0x10(%eax),%eax
80103f2d:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103f30:	83 ec 0c             	sub    $0xc,%esp
80103f33:	68 00 52 19 80       	push   $0x80195200
80103f38:	e8 a0 12 00 00       	call   801051dd <acquire>
80103f3d:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103f40:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f43:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  // MLFQ용 kernel_pstat 등록
  int idx = np - ptable.proc;
80103f4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f4d:	2d 34 52 19 80       	sub    $0x80195234,%eax
80103f52:	c1 f8 02             	sar    $0x2,%eax
80103f55:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80103f5b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  kernel_pstat.inuse[idx] = 1;
80103f5e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80103f61:	c7 04 85 00 42 19 80 	movl   $0x1,-0x7fe6be00(,%eax,4)
80103f68:	01 00 00 00 
  kernel_pstat.pid[idx] = np->pid;
80103f6c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f6f:	8b 40 10             	mov    0x10(%eax),%eax
80103f72:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80103f75:	83 c2 40             	add    $0x40,%edx
80103f78:	89 04 95 00 42 19 80 	mov    %eax,-0x7fe6be00(,%edx,4)
  kernel_pstat.priority[idx] = 3;
80103f7f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80103f82:	83 e8 80             	sub    $0xffffff80,%eax
80103f85:	c7 04 85 00 42 19 80 	movl   $0x3,-0x7fe6be00(,%eax,4)
80103f8c:	03 00 00 00 
  memset(kernel_pstat.ticks[idx], 0, sizeof(kernel_pstat.ticks[idx]));
80103f90:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80103f93:	83 c0 40             	add    $0x40,%eax
80103f96:	c1 e0 04             	shl    $0x4,%eax
80103f99:	05 00 42 19 80       	add    $0x80194200,%eax
80103f9e:	83 ec 04             	sub    $0x4,%esp
80103fa1:	6a 10                	push   $0x10
80103fa3:	6a 00                	push   $0x0
80103fa5:	50                   	push   %eax
80103fa6:	e8 a8 14 00 00       	call   80105453 <memset>
80103fab:	83 c4 10             	add    $0x10,%esp
  memset(kernel_pstat.wait_ticks[idx], 0, sizeof(kernel_pstat.wait_ticks[idx]));
80103fae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80103fb1:	83 e8 80             	sub    $0xffffff80,%eax
80103fb4:	c1 e0 04             	shl    $0x4,%eax
80103fb7:	05 00 42 19 80       	add    $0x80194200,%eax
80103fbc:	83 ec 04             	sub    $0x4,%esp
80103fbf:	6a 10                	push   $0x10
80103fc1:	6a 00                	push   $0x0
80103fc3:	50                   	push   %eax
80103fc4:	e8 8a 14 00 00       	call   80105453 <memset>
80103fc9:	83 c4 10             	add    $0x10,%esp

  if (mycpu()->sched_policy > 0)
80103fcc:	e8 e7 f9 ff ff       	call   801039b8 <mycpu>
80103fd1:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80103fd7:	85 c0                	test   %eax,%eax
80103fd9:	7e 10                	jle    80103feb <fork+0x1ff>
    enqueue(np, 3);
80103fdb:	83 ec 08             	sub    $0x8,%esp
80103fde:	6a 03                	push   $0x3
80103fe0:	ff 75 dc             	push   -0x24(%ebp)
80103fe3:	e8 31 0a 00 00       	call   80104a19 <enqueue>
80103fe8:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103feb:	83 ec 0c             	sub    $0xc,%esp
80103fee:	68 00 52 19 80       	push   $0x80195200
80103ff3:	e8 53 12 00 00       	call   8010524b <release>
80103ff8:	83 c4 10             	add    $0x10,%esp

  return pid;
80103ffb:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103ffe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104001:	5b                   	pop    %ebx
80104002:	5e                   	pop    %esi
80104003:	5f                   	pop    %edi
80104004:	5d                   	pop    %ebp
80104005:	c3                   	ret

80104006 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104006:	55                   	push   %ebp
80104007:	89 e5                	mov    %esp,%ebp
80104009:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010400c:	e8 1f fa ff ff       	call   80103a30 <myproc>
80104011:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104014:	a1 54 71 19 80       	mov    0x80197154,%eax
80104019:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010401c:	75 0d                	jne    8010402b <exit+0x25>
    panic("init exiting");
8010401e:	83 ec 0c             	sub    $0xc,%esp
80104021:	68 02 af 10 80       	push   $0x8010af02
80104026:	e8 7e c5 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010402b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104032:	eb 3f                	jmp    80104073 <exit+0x6d>
    if(curproc->ofile[fd]){
80104034:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104037:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010403a:	83 c2 08             	add    $0x8,%edx
8010403d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104041:	85 c0                	test   %eax,%eax
80104043:	74 2a                	je     8010406f <exit+0x69>
      fileclose(curproc->ofile[fd]);
80104045:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104048:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010404b:	83 c2 08             	add    $0x8,%edx
8010404e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104052:	83 ec 0c             	sub    $0xc,%esp
80104055:	50                   	push   %eax
80104056:	e8 4a d0 ff ff       	call   801010a5 <fileclose>
8010405b:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
8010405e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104061:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104064:	83 c2 08             	add    $0x8,%edx
80104067:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010406e:	00 
  for(fd = 0; fd < NOFILE; fd++){
8010406f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104073:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104077:	7e bb                	jle    80104034 <exit+0x2e>
    }
  }

  begin_op();
80104079:	e8 c0 ef ff ff       	call   8010303e <begin_op>
  iput(curproc->cwd);
8010407e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104081:	8b 40 68             	mov    0x68(%eax),%eax
80104084:	83 ec 0c             	sub    $0xc,%esp
80104087:	50                   	push   %eax
80104088:	e8 c6 da ff ff       	call   80101b53 <iput>
8010408d:	83 c4 10             	add    $0x10,%esp
  end_op();
80104090:	e8 35 f0 ff ff       	call   801030ca <end_op>
  curproc->cwd = 0;
80104095:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104098:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010409f:	83 ec 0c             	sub    $0xc,%esp
801040a2:	68 00 52 19 80       	push   $0x80195200
801040a7:	e8 31 11 00 00       	call   801051dd <acquire>
801040ac:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801040af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040b2:	8b 40 14             	mov    0x14(%eax),%eax
801040b5:	83 ec 0c             	sub    $0xc,%esp
801040b8:	50                   	push   %eax
801040b9:	e8 2c 05 00 00       	call   801045ea <wakeup1>
801040be:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040c1:	c7 45 f4 34 52 19 80 	movl   $0x80195234,-0xc(%ebp)
801040c8:	eb 37                	jmp    80104101 <exit+0xfb>
    if(p->parent == curproc){
801040ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040cd:	8b 40 14             	mov    0x14(%eax),%eax
801040d0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801040d3:	75 28                	jne    801040fd <exit+0xf7>
      p->parent = initproc;
801040d5:	8b 15 54 71 19 80    	mov    0x80197154,%edx
801040db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040de:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801040e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e4:	8b 40 0c             	mov    0xc(%eax),%eax
801040e7:	83 f8 05             	cmp    $0x5,%eax
801040ea:	75 11                	jne    801040fd <exit+0xf7>
        wakeup1(initproc);
801040ec:	a1 54 71 19 80       	mov    0x80197154,%eax
801040f1:	83 ec 0c             	sub    $0xc,%esp
801040f4:	50                   	push   %eax
801040f5:	e8 f0 04 00 00       	call   801045ea <wakeup1>
801040fa:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040fd:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104101:	81 7d f4 34 71 19 80 	cmpl   $0x80197134,-0xc(%ebp)
80104108:	72 c0                	jb     801040ca <exit+0xc4>
    }
  }

  //kerner_pstat 상태 제거
  int i = curproc - ptable.proc;
8010410a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010410d:	2d 34 52 19 80       	sub    $0x80195234,%eax
80104112:	c1 f8 02             	sar    $0x2,%eax
80104115:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
8010411b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  kernel_pstat.inuse[i] = 0;
8010411e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104121:	c7 04 85 00 42 19 80 	movl   $0x0,-0x7fe6be00(,%eax,4)
80104128:	00 00 00 00 

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
8010412c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010412f:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104136:	e8 cf 02 00 00       	call   8010440a <sched>
  panic("zombie exit");
8010413b:	83 ec 0c             	sub    $0xc,%esp
8010413e:	68 0f af 10 80       	push   $0x8010af0f
80104143:	e8 61 c4 ff ff       	call   801005a9 <panic>

80104148 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104148:	55                   	push   %ebp
80104149:	89 e5                	mov    %esp,%ebp
8010414b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010414e:	e8 dd f8 ff ff       	call   80103a30 <myproc>
80104153:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104156:	83 ec 0c             	sub    $0xc,%esp
80104159:	68 00 52 19 80       	push   $0x80195200
8010415e:	e8 7a 10 00 00       	call   801051dd <acquire>
80104163:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104166:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010416d:	c7 45 f4 34 52 19 80 	movl   $0x80195234,-0xc(%ebp)
80104174:	e9 a1 00 00 00       	jmp    8010421a <wait+0xd2>
      if(p->parent != curproc)
80104179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010417c:	8b 40 14             	mov    0x14(%eax),%eax
8010417f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104182:	0f 85 8d 00 00 00    	jne    80104215 <wait+0xcd>
        continue;
      havekids = 1;
80104188:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010418f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104192:	8b 40 0c             	mov    0xc(%eax),%eax
80104195:	83 f8 05             	cmp    $0x5,%eax
80104198:	75 7c                	jne    80104216 <wait+0xce>
        // Found one.
        pid = p->pid;
8010419a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419d:	8b 40 10             	mov    0x10(%eax),%eax
801041a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801041a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a6:	8b 40 08             	mov    0x8(%eax),%eax
801041a9:	83 ec 0c             	sub    $0xc,%esp
801041ac:	50                   	push   %eax
801041ad:	e8 5c e5 ff ff       	call   8010270e <kfree>
801041b2:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801041b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801041bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c2:	8b 40 04             	mov    0x4(%eax),%eax
801041c5:	83 ec 0c             	sub    $0xc,%esp
801041c8:	50                   	push   %eax
801041c9:	e8 cf 42 00 00       	call   8010849d <freevm>
801041ce:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801041d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d4:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801041db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041de:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801041e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e8:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801041ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ef:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801041f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104200:	83 ec 0c             	sub    $0xc,%esp
80104203:	68 00 52 19 80       	push   $0x80195200
80104208:	e8 3e 10 00 00       	call   8010524b <release>
8010420d:	83 c4 10             	add    $0x10,%esp
        return pid;
80104210:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104213:	eb 51                	jmp    80104266 <wait+0x11e>
        continue;
80104215:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104216:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010421a:	81 7d f4 34 71 19 80 	cmpl   $0x80197134,-0xc(%ebp)
80104221:	0f 82 52 ff ff ff    	jb     80104179 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104227:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010422b:	74 0a                	je     80104237 <wait+0xef>
8010422d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104230:	8b 40 24             	mov    0x24(%eax),%eax
80104233:	85 c0                	test   %eax,%eax
80104235:	74 17                	je     8010424e <wait+0x106>
      release(&ptable.lock);
80104237:	83 ec 0c             	sub    $0xc,%esp
8010423a:	68 00 52 19 80       	push   $0x80195200
8010423f:	e8 07 10 00 00       	call   8010524b <release>
80104244:	83 c4 10             	add    $0x10,%esp
      return -1;
80104247:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010424c:	eb 18                	jmp    80104266 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010424e:	83 ec 08             	sub    $0x8,%esp
80104251:	68 00 52 19 80       	push   $0x80195200
80104256:	ff 75 ec             	push   -0x14(%ebp)
80104259:	e8 e5 02 00 00       	call   80104543 <sleep>
8010425e:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104261:	e9 00 ff ff ff       	jmp    80104166 <wait+0x1e>
  }
}
80104266:	c9                   	leave
80104267:	c3                   	ret

80104268 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104268:	55                   	push   %ebp
80104269:	89 e5                	mov    %esp,%ebp
8010426b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
8010426e:	e8 45 f7 ff ff       	call   801039b8 <mycpu>
80104273:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104276:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104279:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104280:	00 00 00 

  for(;;){
    sti();
80104283:	e8 f0 f6 ff ff       	call   80103978 <sti>
    acquire(&ptable.lock);
80104288:	83 ec 0c             	sub    $0xc,%esp
8010428b:	68 00 52 19 80       	push   $0x80195200
80104290:	e8 48 0f 00 00       	call   801051dd <acquire>
80104295:	83 c4 10             	add    $0x10,%esp

    if (c->sched_policy == 0) {
80104298:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010429b:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801042a1:	85 c0                	test   %eax,%eax
801042a3:	0f 85 f1 00 00 00    	jne    8010439a <scheduler+0x132>
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042a9:	c7 45 f4 34 52 19 80 	movl   $0x80195234,-0xc(%ebp)
801042b0:	eb 61                	jmp    80104313 <scheduler+0xab>
        if(p->state != RUNNABLE)
801042b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b5:	8b 40 0c             	mov    0xc(%eax),%eax
801042b8:	83 f8 03             	cmp    $0x3,%eax
801042bb:	75 51                	jne    8010430e <scheduler+0xa6>
          continue;
        c->proc = p;
801042bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042c3:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
801042c9:	83 ec 0c             	sub    $0xc,%esp
801042cc:	ff 75 f4             	push   -0xc(%ebp)
801042cf:	e8 24 3d 00 00       	call   80107ff8 <switchuvm>
801042d4:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
801042d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042da:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
        swtch(&(c->scheduler), p->context);
801042e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e4:	8b 40 1c             	mov    0x1c(%eax),%eax
801042e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801042ea:	83 c2 04             	add    $0x4,%edx
801042ed:	83 ec 08             	sub    $0x8,%esp
801042f0:	50                   	push   %eax
801042f1:	52                   	push   %edx
801042f2:	e8 d1 13 00 00       	call   801056c8 <swtch>
801042f7:	83 c4 10             	add    $0x10,%esp
        switchkvm();
801042fa:	e8 e0 3c 00 00       	call   80107fdf <switchkvm>
        c->proc = 0;
801042ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104302:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104309:	00 00 00 
8010430c:	eb 01                	jmp    8010430f <scheduler+0xa7>
          continue;
8010430e:	90                   	nop
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010430f:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104313:	81 7d f4 34 71 19 80 	cmpl   $0x80197134,-0xc(%ebp)
8010431a:	72 96                	jb     801042b2 <scheduler+0x4a>
      }
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010431c:	c7 45 f4 34 52 19 80 	movl   $0x80195234,-0xc(%ebp)
80104323:	eb 6a                	jmp    8010438f <scheduler+0x127>
        if(p->state == RUNNABLE && p != c->proc){
80104325:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104328:	8b 40 0c             	mov    0xc(%eax),%eax
8010432b:	83 f8 03             	cmp    $0x3,%eax
8010432e:	75 5b                	jne    8010438b <scheduler+0x123>
80104330:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104333:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104339:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010433c:	74 4d                	je     8010438b <scheduler+0x123>
          int i = p - ptable.proc;
8010433e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104341:	2d 34 52 19 80       	sub    $0x80195234,%eax
80104346:	c1 f8 02             	sar    $0x2,%eax
80104349:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
8010434f:	89 45 ec             	mov    %eax,-0x14(%ebp)
          kernel_pstat.wait_ticks[i][kernel_pstat.priority[i]]++;
80104352:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104355:	83 e8 80             	sub    $0xffffff80,%eax
80104358:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
8010435f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104362:	c1 e2 02             	shl    $0x2,%edx
80104365:	01 c2                	add    %eax,%edx
80104367:	81 c2 00 02 00 00    	add    $0x200,%edx
8010436d:	8b 14 95 00 42 19 80 	mov    -0x7fe6be00(,%edx,4),%edx
80104374:	83 c2 01             	add    $0x1,%edx
80104377:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010437a:	c1 e1 02             	shl    $0x2,%ecx
8010437d:	01 c8                	add    %ecx,%eax
8010437f:	05 00 02 00 00       	add    $0x200,%eax
80104384:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010438b:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010438f:	81 7d f4 34 71 19 80 	cmpl   $0x80197134,-0xc(%ebp)
80104396:	72 8d                	jb     80104325 <scheduler+0xbd>
80104398:	eb 5b                	jmp    801043f5 <scheduler+0x18d>
        }
      }
    } else if (c->sched_policy == 1) {
8010439a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010439d:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801043a3:	83 f8 01             	cmp    $0x1,%eax
801043a6:	75 11                	jne    801043b9 <scheduler+0x151>
      run_mlfq(1, 1);
801043a8:	83 ec 08             	sub    $0x8,%esp
801043ab:	6a 01                	push   $0x1
801043ad:	6a 01                	push   $0x1
801043af:	e8 62 0b 00 00       	call   80104f16 <run_mlfq>
801043b4:	83 c4 10             	add    $0x10,%esp
801043b7:	eb 3c                	jmp    801043f5 <scheduler+0x18d>
    } else if (c->sched_policy == 2) {
801043b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043bc:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801043c2:	83 f8 02             	cmp    $0x2,%eax
801043c5:	75 11                	jne    801043d8 <scheduler+0x170>
      run_mlfq(0, 1);
801043c7:	83 ec 08             	sub    $0x8,%esp
801043ca:	6a 01                	push   $0x1
801043cc:	6a 00                	push   $0x0
801043ce:	e8 43 0b 00 00       	call   80104f16 <run_mlfq>
801043d3:	83 c4 10             	add    $0x10,%esp
801043d6:	eb 1d                	jmp    801043f5 <scheduler+0x18d>
    } else if (c->sched_policy == 3) {
801043d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043db:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801043e1:	83 f8 03             	cmp    $0x3,%eax
801043e4:	75 0f                	jne    801043f5 <scheduler+0x18d>
      run_mlfq(1, 0);
801043e6:	83 ec 08             	sub    $0x8,%esp
801043e9:	6a 00                	push   $0x0
801043eb:	6a 01                	push   $0x1
801043ed:	e8 24 0b 00 00       	call   80104f16 <run_mlfq>
801043f2:	83 c4 10             	add    $0x10,%esp
    }

    release(&ptable.lock);
801043f5:	83 ec 0c             	sub    $0xc,%esp
801043f8:	68 00 52 19 80       	push   $0x80195200
801043fd:	e8 49 0e 00 00       	call   8010524b <release>
80104402:	83 c4 10             	add    $0x10,%esp
    sti();
80104405:	e9 79 fe ff ff       	jmp    80104283 <scheduler+0x1b>

8010440a <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
8010440a:	55                   	push   %ebp
8010440b:	89 e5                	mov    %esp,%ebp
8010440d:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104410:	e8 1b f6 ff ff       	call   80103a30 <myproc>
80104415:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104418:	83 ec 0c             	sub    $0xc,%esp
8010441b:	68 00 52 19 80       	push   $0x80195200
80104420:	e8 f3 0e 00 00       	call   80105318 <holding>
80104425:	83 c4 10             	add    $0x10,%esp
80104428:	85 c0                	test   %eax,%eax
8010442a:	75 0d                	jne    80104439 <sched+0x2f>
    panic("sched ptable.lock");
8010442c:	83 ec 0c             	sub    $0xc,%esp
8010442f:	68 1b af 10 80       	push   $0x8010af1b
80104434:	e8 70 c1 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
80104439:	e8 7a f5 ff ff       	call   801039b8 <mycpu>
8010443e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104444:	83 f8 01             	cmp    $0x1,%eax
80104447:	74 0d                	je     80104456 <sched+0x4c>
    panic("sched locks");
80104449:	83 ec 0c             	sub    $0xc,%esp
8010444c:	68 2d af 10 80       	push   $0x8010af2d
80104451:	e8 53 c1 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
80104456:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104459:	8b 40 0c             	mov    0xc(%eax),%eax
8010445c:	83 f8 04             	cmp    $0x4,%eax
8010445f:	75 0d                	jne    8010446e <sched+0x64>
    panic("sched running");
80104461:	83 ec 0c             	sub    $0xc,%esp
80104464:	68 39 af 10 80       	push   $0x8010af39
80104469:	e8 3b c1 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
8010446e:	e8 f5 f4 ff ff       	call   80103968 <readeflags>
80104473:	25 00 02 00 00       	and    $0x200,%eax
80104478:	85 c0                	test   %eax,%eax
8010447a:	74 0d                	je     80104489 <sched+0x7f>
    panic("sched interruptible");
8010447c:	83 ec 0c             	sub    $0xc,%esp
8010447f:	68 47 af 10 80       	push   $0x8010af47
80104484:	e8 20 c1 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104489:	e8 2a f5 ff ff       	call   801039b8 <mycpu>
8010448e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104494:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104497:	e8 1c f5 ff ff       	call   801039b8 <mycpu>
8010449c:	8b 40 04             	mov    0x4(%eax),%eax
8010449f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044a2:	83 c2 1c             	add    $0x1c,%edx
801044a5:	83 ec 08             	sub    $0x8,%esp
801044a8:	50                   	push   %eax
801044a9:	52                   	push   %edx
801044aa:	e8 19 12 00 00       	call   801056c8 <swtch>
801044af:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801044b2:	e8 01 f5 ff ff       	call   801039b8 <mycpu>
801044b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044ba:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801044c0:	90                   	nop
801044c1:	c9                   	leave
801044c2:	c3                   	ret

801044c3 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801044c3:	55                   	push   %ebp
801044c4:	89 e5                	mov    %esp,%ebp
801044c6:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801044c9:	83 ec 0c             	sub    $0xc,%esp
801044cc:	68 00 52 19 80       	push   $0x80195200
801044d1:	e8 07 0d 00 00       	call   801051dd <acquire>
801044d6:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
801044d9:	e8 52 f5 ff ff       	call   80103a30 <myproc>
801044de:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801044e5:	e8 20 ff ff ff       	call   8010440a <sched>
  release(&ptable.lock);
801044ea:	83 ec 0c             	sub    $0xc,%esp
801044ed:	68 00 52 19 80       	push   $0x80195200
801044f2:	e8 54 0d 00 00       	call   8010524b <release>
801044f7:	83 c4 10             	add    $0x10,%esp
}
801044fa:	90                   	nop
801044fb:	c9                   	leave
801044fc:	c3                   	ret

801044fd <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801044fd:	55                   	push   %ebp
801044fe:	89 e5                	mov    %esp,%ebp
80104500:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104503:	83 ec 0c             	sub    $0xc,%esp
80104506:	68 00 52 19 80       	push   $0x80195200
8010450b:	e8 3b 0d 00 00       	call   8010524b <release>
80104510:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104513:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104518:	85 c0                	test   %eax,%eax
8010451a:	74 24                	je     80104540 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010451c:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104523:	00 00 00 
    iinit(ROOTDEV);
80104526:	83 ec 0c             	sub    $0xc,%esp
80104529:	6a 01                	push   $0x1
8010452b:	e8 51 d1 ff ff       	call   80101681 <iinit>
80104530:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104533:	83 ec 0c             	sub    $0xc,%esp
80104536:	6a 01                	push   $0x1
80104538:	e8 e2 e8 ff ff       	call   80102e1f <initlog>
8010453d:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104540:	90                   	nop
80104541:	c9                   	leave
80104542:	c3                   	ret

80104543 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104543:	55                   	push   %ebp
80104544:	89 e5                	mov    %esp,%ebp
80104546:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104549:	e8 e2 f4 ff ff       	call   80103a30 <myproc>
8010454e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104551:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104555:	75 0d                	jne    80104564 <sleep+0x21>
    panic("sleep");
80104557:	83 ec 0c             	sub    $0xc,%esp
8010455a:	68 5b af 10 80       	push   $0x8010af5b
8010455f:	e8 45 c0 ff ff       	call   801005a9 <panic>

  if(lk == 0)
80104564:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104568:	75 0d                	jne    80104577 <sleep+0x34>
    panic("sleep without lk");
8010456a:	83 ec 0c             	sub    $0xc,%esp
8010456d:	68 61 af 10 80       	push   $0x8010af61
80104572:	e8 32 c0 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104577:	81 7d 0c 00 52 19 80 	cmpl   $0x80195200,0xc(%ebp)
8010457e:	74 1e                	je     8010459e <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104580:	83 ec 0c             	sub    $0xc,%esp
80104583:	68 00 52 19 80       	push   $0x80195200
80104588:	e8 50 0c 00 00       	call   801051dd <acquire>
8010458d:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104590:	83 ec 0c             	sub    $0xc,%esp
80104593:	ff 75 0c             	push   0xc(%ebp)
80104596:	e8 b0 0c 00 00       	call   8010524b <release>
8010459b:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
8010459e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a1:	8b 55 08             	mov    0x8(%ebp),%edx
801045a4:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801045a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045aa:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801045b1:	e8 54 fe ff ff       	call   8010440a <sched>

  // Tidy up.
  p->chan = 0;
801045b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b9:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801045c0:	81 7d 0c 00 52 19 80 	cmpl   $0x80195200,0xc(%ebp)
801045c7:	74 1e                	je     801045e7 <sleep+0xa4>
    release(&ptable.lock);
801045c9:	83 ec 0c             	sub    $0xc,%esp
801045cc:	68 00 52 19 80       	push   $0x80195200
801045d1:	e8 75 0c 00 00       	call   8010524b <release>
801045d6:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801045d9:	83 ec 0c             	sub    $0xc,%esp
801045dc:	ff 75 0c             	push   0xc(%ebp)
801045df:	e8 f9 0b 00 00       	call   801051dd <acquire>
801045e4:	83 c4 10             	add    $0x10,%esp
  }
}
801045e7:	90                   	nop
801045e8:	c9                   	leave
801045e9:	c3                   	ret

801045ea <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801045ea:	55                   	push   %ebp
801045eb:	89 e5                	mov    %esp,%ebp
801045ed:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045f0:	c7 45 fc 34 52 19 80 	movl   $0x80195234,-0x4(%ebp)
801045f7:	eb 24                	jmp    8010461d <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
801045f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045fc:	8b 40 0c             	mov    0xc(%eax),%eax
801045ff:	83 f8 02             	cmp    $0x2,%eax
80104602:	75 15                	jne    80104619 <wakeup1+0x2f>
80104604:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104607:	8b 40 20             	mov    0x20(%eax),%eax
8010460a:	39 45 08             	cmp    %eax,0x8(%ebp)
8010460d:	75 0a                	jne    80104619 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010460f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104612:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104619:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
8010461d:	81 7d fc 34 71 19 80 	cmpl   $0x80197134,-0x4(%ebp)
80104624:	72 d3                	jb     801045f9 <wakeup1+0xf>
}
80104626:	90                   	nop
80104627:	90                   	nop
80104628:	c9                   	leave
80104629:	c3                   	ret

8010462a <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010462a:	55                   	push   %ebp
8010462b:	89 e5                	mov    %esp,%ebp
8010462d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104630:	83 ec 0c             	sub    $0xc,%esp
80104633:	68 00 52 19 80       	push   $0x80195200
80104638:	e8 a0 0b 00 00       	call   801051dd <acquire>
8010463d:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104640:	83 ec 0c             	sub    $0xc,%esp
80104643:	ff 75 08             	push   0x8(%ebp)
80104646:	e8 9f ff ff ff       	call   801045ea <wakeup1>
8010464b:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010464e:	83 ec 0c             	sub    $0xc,%esp
80104651:	68 00 52 19 80       	push   $0x80195200
80104656:	e8 f0 0b 00 00       	call   8010524b <release>
8010465b:	83 c4 10             	add    $0x10,%esp
}
8010465e:	90                   	nop
8010465f:	c9                   	leave
80104660:	c3                   	ret

80104661 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104661:	55                   	push   %ebp
80104662:	89 e5                	mov    %esp,%ebp
80104664:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104667:	83 ec 0c             	sub    $0xc,%esp
8010466a:	68 00 52 19 80       	push   $0x80195200
8010466f:	e8 69 0b 00 00       	call   801051dd <acquire>
80104674:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104677:	c7 45 f4 34 52 19 80 	movl   $0x80195234,-0xc(%ebp)
8010467e:	eb 45                	jmp    801046c5 <kill+0x64>
    if(p->pid == pid){
80104680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104683:	8b 40 10             	mov    0x10(%eax),%eax
80104686:	39 45 08             	cmp    %eax,0x8(%ebp)
80104689:	75 36                	jne    801046c1 <kill+0x60>
      p->killed = 1;
8010468b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104695:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104698:	8b 40 0c             	mov    0xc(%eax),%eax
8010469b:	83 f8 02             	cmp    $0x2,%eax
8010469e:	75 0a                	jne    801046aa <kill+0x49>
        p->state = RUNNABLE;
801046a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801046aa:	83 ec 0c             	sub    $0xc,%esp
801046ad:	68 00 52 19 80       	push   $0x80195200
801046b2:	e8 94 0b 00 00       	call   8010524b <release>
801046b7:	83 c4 10             	add    $0x10,%esp
      return 0;
801046ba:	b8 00 00 00 00       	mov    $0x0,%eax
801046bf:	eb 22                	jmp    801046e3 <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046c1:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801046c5:	81 7d f4 34 71 19 80 	cmpl   $0x80197134,-0xc(%ebp)
801046cc:	72 b2                	jb     80104680 <kill+0x1f>
    }
  }
  release(&ptable.lock);
801046ce:	83 ec 0c             	sub    $0xc,%esp
801046d1:	68 00 52 19 80       	push   $0x80195200
801046d6:	e8 70 0b 00 00       	call   8010524b <release>
801046db:	83 c4 10             	add    $0x10,%esp
  return -1;
801046de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801046e3:	c9                   	leave
801046e4:	c3                   	ret

801046e5 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801046e5:	55                   	push   %ebp
801046e6:	89 e5                	mov    %esp,%ebp
801046e8:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046eb:	c7 45 f0 34 52 19 80 	movl   $0x80195234,-0x10(%ebp)
801046f2:	e9 d7 00 00 00       	jmp    801047ce <procdump+0xe9>
    if(p->state == UNUSED)
801046f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046fa:	8b 40 0c             	mov    0xc(%eax),%eax
801046fd:	85 c0                	test   %eax,%eax
801046ff:	0f 84 c4 00 00 00    	je     801047c9 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104705:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104708:	8b 40 0c             	mov    0xc(%eax),%eax
8010470b:	83 f8 05             	cmp    $0x5,%eax
8010470e:	77 23                	ja     80104733 <procdump+0x4e>
80104710:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104713:	8b 40 0c             	mov    0xc(%eax),%eax
80104716:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010471d:	85 c0                	test   %eax,%eax
8010471f:	74 12                	je     80104733 <procdump+0x4e>
      state = states[p->state];
80104721:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104724:	8b 40 0c             	mov    0xc(%eax),%eax
80104727:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010472e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104731:	eb 07                	jmp    8010473a <procdump+0x55>
    else
      state = "???";
80104733:	c7 45 ec 72 af 10 80 	movl   $0x8010af72,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010473a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010473d:	8d 50 6c             	lea    0x6c(%eax),%edx
80104740:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104743:	8b 40 10             	mov    0x10(%eax),%eax
80104746:	52                   	push   %edx
80104747:	ff 75 ec             	push   -0x14(%ebp)
8010474a:	50                   	push   %eax
8010474b:	68 76 af 10 80       	push   $0x8010af76
80104750:	e8 9f bc ff ff       	call   801003f4 <cprintf>
80104755:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104758:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010475b:	8b 40 0c             	mov    0xc(%eax),%eax
8010475e:	83 f8 02             	cmp    $0x2,%eax
80104761:	75 54                	jne    801047b7 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104763:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104766:	8b 40 1c             	mov    0x1c(%eax),%eax
80104769:	8b 40 0c             	mov    0xc(%eax),%eax
8010476c:	83 c0 08             	add    $0x8,%eax
8010476f:	89 c2                	mov    %eax,%edx
80104771:	83 ec 08             	sub    $0x8,%esp
80104774:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104777:	50                   	push   %eax
80104778:	52                   	push   %edx
80104779:	e8 1f 0b 00 00       	call   8010529d <getcallerpcs>
8010477e:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104781:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104788:	eb 1c                	jmp    801047a6 <procdump+0xc1>
        cprintf(" %p", pc[i]);
8010478a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478d:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104791:	83 ec 08             	sub    $0x8,%esp
80104794:	50                   	push   %eax
80104795:	68 7f af 10 80       	push   $0x8010af7f
8010479a:	e8 55 bc ff ff       	call   801003f4 <cprintf>
8010479f:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801047a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801047a6:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801047aa:	7f 0b                	jg     801047b7 <procdump+0xd2>
801047ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047af:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801047b3:	85 c0                	test   %eax,%eax
801047b5:	75 d3                	jne    8010478a <procdump+0xa5>
    }
    cprintf("\n");
801047b7:	83 ec 0c             	sub    $0xc,%esp
801047ba:	68 83 af 10 80       	push   $0x8010af83
801047bf:	e8 30 bc ff ff       	call   801003f4 <cprintf>
801047c4:	83 c4 10             	add    $0x10,%esp
801047c7:	eb 01                	jmp    801047ca <procdump+0xe5>
      continue;
801047c9:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047ca:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
801047ce:	81 7d f0 34 71 19 80 	cmpl   $0x80197134,-0x10(%ebp)
801047d5:	0f 82 1c ff ff ff    	jb     801046f7 <procdump+0x12>
  }
}
801047db:	90                   	nop
801047dc:	90                   	nop
801047dd:	c9                   	leave
801047de:	c3                   	ret

801047df <getpinfo>:

//현재 커널의 프로세스 상태들을 pstat에 담아서 유저에게 전달해주는 시스템 콜
int getpinfo(struct pstat *pstat) {
801047df:	55                   	push   %ebp
801047e0:	89 e5                	mov    %esp,%ebp
801047e2:	53                   	push   %ebx
801047e3:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
801047e6:	83 ec 0c             	sub    $0xc,%esp
801047e9:	68 00 52 19 80       	push   $0x80195200
801047ee:	e8 ea 09 00 00       	call   801051dd <acquire>
801047f3:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
801047f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801047fd:	e9 e6 00 00 00       	jmp    801048e8 <getpinfo+0x109>
    pstat->inuse[i] = kernel_pstat.inuse[i];
80104802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104805:	8b 0c 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%ecx
8010480c:	8b 45 08             	mov    0x8(%ebp),%eax
8010480f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104812:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    pstat->pid[i] = kernel_pstat.pid[i];
80104815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104818:	83 c0 40             	add    $0x40,%eax
8010481b:	8b 14 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%edx
80104822:	8b 45 08             	mov    0x8(%ebp),%eax
80104825:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104828:	83 c1 40             	add    $0x40,%ecx
8010482b:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    pstat->priority[i] = kernel_pstat.priority[i];
8010482e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104831:	83 e8 80             	sub    $0xffffff80,%eax
80104834:	8b 14 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%edx
8010483b:	8b 45 08             	mov    0x8(%ebp),%eax
8010483e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104841:	83 e9 80             	sub    $0xffffff80,%ecx
80104844:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    pstat->state[i] = ptable.proc[i].state; // proc에서 유일하게 읽기 가능
80104847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010484a:	6b c0 7c             	imul   $0x7c,%eax,%eax
8010484d:	05 40 52 19 80       	add    $0x80195240,%eax
80104852:	8b 00                	mov    (%eax),%eax
80104854:	89 c1                	mov    %eax,%ecx
80104856:	8b 45 08             	mov    0x8(%ebp),%eax
80104859:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010485c:	81 c2 c0 00 00 00    	add    $0xc0,%edx
80104862:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    for (int j = 0; j < 4; j++) {
80104865:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010486c:	eb 70                	jmp    801048de <getpinfo+0xff>
      pstat->ticks[i][j] = kernel_pstat.ticks[i][j];
8010486e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104871:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104878:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010487b:	01 d0                	add    %edx,%eax
8010487d:	05 00 01 00 00       	add    $0x100,%eax
80104882:	8b 14 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%edx
80104889:	8b 45 08             	mov    0x8(%ebp),%eax
8010488c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010488f:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
80104896:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104899:	01 d9                	add    %ebx,%ecx
8010489b:	81 c1 00 01 00 00    	add    $0x100,%ecx
801048a1:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      pstat->wait_ticks[i][j] = kernel_pstat.wait_ticks[i][j];
801048a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801048ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048b1:	01 d0                	add    %edx,%eax
801048b3:	05 00 02 00 00       	add    $0x200,%eax
801048b8:	8b 14 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%edx
801048bf:	8b 45 08             	mov    0x8(%ebp),%eax
801048c2:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801048c5:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
801048cc:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801048cf:	01 d9                	add    %ebx,%ecx
801048d1:	81 c1 00 02 00 00    	add    $0x200,%ecx
801048d7:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
801048da:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801048de:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
801048e2:	7e 8a                	jle    8010486e <getpinfo+0x8f>
  for (int i = 0; i < NPROC; i++) {
801048e4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801048e8:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801048ec:	0f 8e 10 ff ff ff    	jle    80104802 <getpinfo+0x23>
    }
  }
  release(&ptable.lock);
801048f2:	83 ec 0c             	sub    $0xc,%esp
801048f5:	68 00 52 19 80       	push   $0x80195200
801048fa:	e8 4c 09 00 00       	call   8010524b <release>
801048ff:	83 c4 10             	add    $0x10,%esp
  return 0;
80104902:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104907:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010490a:	c9                   	leave
8010490b:	c3                   	ret

8010490c <mlfq_enqueue_all_runnable>:

void mlfq_enqueue_all_runnable(void) {
8010490c:	55                   	push   %ebp
8010490d:	89 e5                	mov    %esp,%ebp
8010490f:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104912:	83 ec 0c             	sub    $0xc,%esp
80104915:	68 00 52 19 80       	push   $0x80195200
8010491a:	e8 be 08 00 00       	call   801051dd <acquire>
8010491f:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
80104922:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104929:	eb 6f                	jmp    8010499a <mlfq_enqueue_all_runnable+0x8e>
    if (!kernel_pstat.inuse[i]) continue;
8010492b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492e:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104935:	85 c0                	test   %eax,%eax
80104937:	74 5c                	je     80104995 <mlfq_enqueue_all_runnable+0x89>
    struct proc *p = &ptable.proc[i];
80104939:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493c:	6b c0 7c             	imul   $0x7c,%eax,%eax
8010493f:	83 c0 30             	add    $0x30,%eax
80104942:	05 00 52 19 80       	add    $0x80195200,%eax
80104947:	83 c0 04             	add    $0x4,%eax
8010494a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (p->state == RUNNABLE) {
8010494d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104950:	8b 40 0c             	mov    0xc(%eax),%eax
80104953:	83 f8 03             	cmp    $0x3,%eax
80104956:	75 3e                	jne    80104996 <mlfq_enqueue_all_runnable+0x8a>
      int q = kernel_pstat.priority[i];
80104958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495b:	83 e8 80             	sub    $0xffffff80,%eax
8010495e:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104965:	89 45 ec             	mov    %eax,-0x14(%ebp)
      enqueue(p, q);
80104968:	83 ec 08             	sub    $0x8,%esp
8010496b:	ff 75 ec             	push   -0x14(%ebp)
8010496e:	ff 75 f0             	push   -0x10(%ebp)
80104971:	e8 a3 00 00 00       	call   80104a19 <enqueue>
80104976:	83 c4 10             	add    $0x10,%esp
      cprintf("[AUTO-ENQUEUE] PID %d -> Q%d\n", p->pid, q);
80104979:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010497c:	8b 40 10             	mov    0x10(%eax),%eax
8010497f:	83 ec 04             	sub    $0x4,%esp
80104982:	ff 75 ec             	push   -0x14(%ebp)
80104985:	50                   	push   %eax
80104986:	68 85 af 10 80       	push   $0x8010af85
8010498b:	e8 64 ba ff ff       	call   801003f4 <cprintf>
80104990:	83 c4 10             	add    $0x10,%esp
80104993:	eb 01                	jmp    80104996 <mlfq_enqueue_all_runnable+0x8a>
    if (!kernel_pstat.inuse[i]) continue;
80104995:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104996:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010499a:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010499e:	7e 8b                	jle    8010492b <mlfq_enqueue_all_runnable+0x1f>
    }
  }
  release(&ptable.lock);
801049a0:	83 ec 0c             	sub    $0xc,%esp
801049a3:	68 00 52 19 80       	push   $0x80195200
801049a8:	e8 9e 08 00 00       	call   8010524b <release>
801049ad:	83 c4 10             	add    $0x10,%esp
}
801049b0:	90                   	nop
801049b1:	c9                   	leave
801049b2:	c3                   	ret

801049b3 <set_sched_policy>:

int
set_sched_policy(int policy)
{
801049b3:	55                   	push   %ebp
801049b4:	89 e5                	mov    %esp,%ebp
801049b6:	83 ec 08             	sub    $0x8,%esp
  if (policy < 0 || policy > 3)
801049b9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801049bd:	78 06                	js     801049c5 <set_sched_policy+0x12>
801049bf:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
801049c3:	7e 07                	jle    801049cc <set_sched_policy+0x19>
    return -1;
801049c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049ca:	eb 28                	jmp    801049f4 <set_sched_policy+0x41>

  pushcli(); 
801049cc:	e8 77 09 00 00       	call   80105348 <pushcli>
  mycpu()->sched_policy = policy;
801049d1:	e8 e2 ef ff ff       	call   801039b8 <mycpu>
801049d6:	8b 55 08             	mov    0x8(%ebp),%edx
801049d9:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
801049df:	e8 b1 09 00 00       	call   80105395 <popcli>

  if (policy > 0)
801049e4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801049e8:	7e 05                	jle    801049ef <set_sched_policy+0x3c>
  mlfq_enqueue_all_runnable();
801049ea:	e8 1d ff ff ff       	call   8010490c <mlfq_enqueue_all_runnable>

  return 0;
801049ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049f4:	c9                   	leave
801049f5:	c3                   	ret

801049f6 <get_sched_policy>:
int
get_sched_policy(void)
{
801049f6:	55                   	push   %ebp
801049f7:	89 e5                	mov    %esp,%ebp
801049f9:	83 ec 18             	sub    $0x18,%esp
  pushcli();  
801049fc:	e8 47 09 00 00       	call   80105348 <pushcli>
  int policy = mycpu()->sched_policy;
80104a01:	e8 b2 ef ff ff       	call   801039b8 <mycpu>
80104a06:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104a0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();   
80104a0f:	e8 81 09 00 00       	call   80105395 <popcli>
  return policy;
80104a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104a17:	c9                   	leave
80104a18:	c3                   	ret

80104a19 <enqueue>:
int q_front[4] = {0};
int q_back[4] = {0};

// Enqueue 함수
void
enqueue(struct proc *p, int level) {
80104a19:	55                   	push   %ebp
80104a1a:	89 e5                	mov    %esp,%ebp
80104a1c:	83 ec 10             	sub    $0x10,%esp
  for (int i = 0; i < NPROC; i++)
80104a1f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104a26:	eb 1d                	jmp    80104a45 <enqueue+0x2c>
    if (mlfq_queues[level][i] == p) return;
80104a28:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a2b:	c1 e0 06             	shl    $0x6,%eax
80104a2e:	89 c2                	mov    %eax,%edx
80104a30:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a33:	01 d0                	add    %edx,%eax
80104a35:	8b 04 85 00 4e 19 80 	mov    -0x7fe6b200(,%eax,4),%eax
80104a3c:	39 45 08             	cmp    %eax,0x8(%ebp)
80104a3f:	74 50                	je     80104a91 <enqueue+0x78>
  for (int i = 0; i < NPROC; i++)
80104a41:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104a45:	83 7d fc 3f          	cmpl   $0x3f,-0x4(%ebp)
80104a49:	7e dd                	jle    80104a28 <enqueue+0xf>
  for (int i = 0; i < NPROC; i++)
80104a4b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104a52:	eb 35                	jmp    80104a89 <enqueue+0x70>
    if (mlfq_queues[level][i] == 0) {
80104a54:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a57:	c1 e0 06             	shl    $0x6,%eax
80104a5a:	89 c2                	mov    %eax,%edx
80104a5c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a5f:	01 d0                	add    %edx,%eax
80104a61:	8b 04 85 00 4e 19 80 	mov    -0x7fe6b200(,%eax,4),%eax
80104a68:	85 c0                	test   %eax,%eax
80104a6a:	75 19                	jne    80104a85 <enqueue+0x6c>
      mlfq_queues[level][i] = p;
80104a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a6f:	c1 e0 06             	shl    $0x6,%eax
80104a72:	89 c2                	mov    %eax,%edx
80104a74:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a77:	01 c2                	add    %eax,%edx
80104a79:	8b 45 08             	mov    0x8(%ebp),%eax
80104a7c:	89 04 95 00 4e 19 80 	mov    %eax,-0x7fe6b200(,%edx,4)
      return;
80104a83:	eb 0d                	jmp    80104a92 <enqueue+0x79>
  for (int i = 0; i < NPROC; i++)
80104a85:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104a89:	83 7d f8 3f          	cmpl   $0x3f,-0x8(%ebp)
80104a8d:	7e c5                	jle    80104a54 <enqueue+0x3b>
80104a8f:	eb 01                	jmp    80104a92 <enqueue+0x79>
    if (mlfq_queues[level][i] == p) return;
80104a91:	90                   	nop
    }
}
80104a92:	c9                   	leave
80104a93:	c3                   	ret

80104a94 <dequeue>:

struct proc*
dequeue(int level) {
80104a94:	55                   	push   %ebp
80104a95:	89 e5                	mov    %esp,%ebp
80104a97:	83 ec 10             	sub    $0x10,%esp
  struct proc* p = 0;
80104a9a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for (int i = 0; i < NPROC; i++) {
80104aa1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104aa8:	e9 81 00 00 00       	jmp    80104b2e <dequeue+0x9a>
    if (mlfq_queues[level][i]) {
80104aad:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab0:	c1 e0 06             	shl    $0x6,%eax
80104ab3:	89 c2                	mov    %eax,%edx
80104ab5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ab8:	01 d0                	add    %edx,%eax
80104aba:	8b 04 85 00 4e 19 80 	mov    -0x7fe6b200(,%eax,4),%eax
80104ac1:	85 c0                	test   %eax,%eax
80104ac3:	74 65                	je     80104b2a <dequeue+0x96>
      p = mlfq_queues[level][i];
80104ac5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac8:	c1 e0 06             	shl    $0x6,%eax
80104acb:	89 c2                	mov    %eax,%edx
80104acd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ad0:	01 d0                	add    %edx,%eax
80104ad2:	8b 04 85 00 4e 19 80 	mov    -0x7fe6b200(,%eax,4),%eax
80104ad9:	89 45 fc             	mov    %eax,-0x4(%ebp)
      for (int j = i; j < NPROC - 1; j++)
80104adc:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104adf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ae2:	eb 2d                	jmp    80104b11 <dequeue+0x7d>
        mlfq_queues[level][j] = mlfq_queues[level][j+1];
80104ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae7:	8d 50 01             	lea    0x1(%eax),%edx
80104aea:	8b 45 08             	mov    0x8(%ebp),%eax
80104aed:	c1 e0 06             	shl    $0x6,%eax
80104af0:	01 d0                	add    %edx,%eax
80104af2:	8b 04 85 00 4e 19 80 	mov    -0x7fe6b200(,%eax,4),%eax
80104af9:	8b 55 08             	mov    0x8(%ebp),%edx
80104afc:	89 d1                	mov    %edx,%ecx
80104afe:	c1 e1 06             	shl    $0x6,%ecx
80104b01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b04:	01 ca                	add    %ecx,%edx
80104b06:	89 04 95 00 4e 19 80 	mov    %eax,-0x7fe6b200(,%edx,4)
      for (int j = i; j < NPROC - 1; j++)
80104b0d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104b11:	83 7d f4 3e          	cmpl   $0x3e,-0xc(%ebp)
80104b15:	7e cd                	jle    80104ae4 <dequeue+0x50>
      mlfq_queues[level][NPROC - 1] = 0;
80104b17:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1a:	c1 e0 08             	shl    $0x8,%eax
80104b1d:	05 fc 4e 19 80       	add    $0x80194efc,%eax
80104b22:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      break;
80104b28:	eb 0e                	jmp    80104b38 <dequeue+0xa4>
  for (int i = 0; i < NPROC; i++) {
80104b2a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104b2e:	83 7d f8 3f          	cmpl   $0x3f,-0x8(%ebp)
80104b32:	0f 8e 75 ff ff ff    	jle    80104aad <dequeue+0x19>
    }
  }
  return p;
80104b38:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b3b:	c9                   	leave
80104b3c:	c3                   	ret

80104b3d <apply_priority_boosting>:

// Boosting 조건 검사
void apply_priority_boosting(void) {
80104b3d:	55                   	push   %ebp
80104b3e:	89 e5                	mov    %esp,%ebp
80104b40:	83 ec 28             	sub    $0x28,%esp
  for (int i = 0; i < NPROC; i++) {
80104b43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104b4a:	e9 da 01 00 00       	jmp    80104d29 <apply_priority_boosting+0x1ec>
    if (!kernel_pstat.inuse[i]) continue;
80104b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b52:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104b59:	85 c0                	test   %eax,%eax
80104b5b:	0f 84 c3 01 00 00    	je     80104d24 <apply_priority_boosting+0x1e7>
    int q = kernel_pstat.priority[i];
80104b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b64:	83 e8 80             	sub    $0xffffff80,%eax
80104b67:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104b6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int waited = kernel_pstat.wait_ticks[i][q];
80104b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b74:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b7e:	01 d0                	add    %edx,%eax
80104b80:	05 00 02 00 00       	add    $0x200,%eax
80104b85:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104b8c:	89 45 ec             	mov    %eax,-0x14(%ebp)

    if (q == 2 && waited >= 160) {
80104b8f:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
80104b93:	75 70                	jne    80104c05 <apply_priority_boosting+0xc8>
80104b95:	81 7d ec 9f 00 00 00 	cmpl   $0x9f,-0x14(%ebp)
80104b9c:	7e 67                	jle    80104c05 <apply_priority_boosting+0xc8>
      kernel_pstat.priority[i] = 3;
80104b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba1:	83 e8 80             	sub    $0xffffff80,%eax
80104ba4:	c7 04 85 00 42 19 80 	movl   $0x3,-0x7fe6be00(,%eax,4)
80104bab:	03 00 00 00 
      kernel_pstat.wait_ticks[i][2] = 0;
80104baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb2:	c1 e0 04             	shl    $0x4,%eax
80104bb5:	05 08 4a 19 80       	add    $0x80194a08,%eax
80104bba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      cprintf("[BOOST] PID %d Q2→Q3 (waited=%d)\n", kernel_pstat.pid[i], waited);
80104bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc3:	83 c0 40             	add    $0x40,%eax
80104bc6:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104bcd:	83 ec 04             	sub    $0x4,%esp
80104bd0:	ff 75 ec             	push   -0x14(%ebp)
80104bd3:	50                   	push   %eax
80104bd4:	68 a4 af 10 80       	push   $0x8010afa4
80104bd9:	e8 16 b8 ff ff       	call   801003f4 <cprintf>
80104bde:	83 c4 10             	add    $0x10,%esp
      enqueue(&ptable.proc[i], 3);
80104be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be4:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104be7:	83 c0 30             	add    $0x30,%eax
80104bea:	05 00 52 19 80       	add    $0x80195200,%eax
80104bef:	83 c0 04             	add    $0x4,%eax
80104bf2:	83 ec 08             	sub    $0x8,%esp
80104bf5:	6a 03                	push   $0x3
80104bf7:	50                   	push   %eax
80104bf8:	e8 1c fe ff ff       	call   80104a19 <enqueue>
80104bfd:	83 c4 10             	add    $0x10,%esp
80104c00:	e9 20 01 00 00       	jmp    80104d25 <apply_priority_boosting+0x1e8>
    } else if (q == 1 && waited >= 320) {
80104c05:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
80104c09:	75 70                	jne    80104c7b <apply_priority_boosting+0x13e>
80104c0b:	81 7d ec 3f 01 00 00 	cmpl   $0x13f,-0x14(%ebp)
80104c12:	7e 67                	jle    80104c7b <apply_priority_boosting+0x13e>
      kernel_pstat.priority[i] = 2;
80104c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c17:	83 e8 80             	sub    $0xffffff80,%eax
80104c1a:	c7 04 85 00 42 19 80 	movl   $0x2,-0x7fe6be00(,%eax,4)
80104c21:	02 00 00 00 
      kernel_pstat.wait_ticks[i][1] = 0;
80104c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c28:	c1 e0 04             	shl    $0x4,%eax
80104c2b:	05 04 4a 19 80       	add    $0x80194a04,%eax
80104c30:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      cprintf("[BOOST] PID %d Q1→Q2 (waited=%d)\n", kernel_pstat.pid[i], waited);
80104c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c39:	83 c0 40             	add    $0x40,%eax
80104c3c:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104c43:	83 ec 04             	sub    $0x4,%esp
80104c46:	ff 75 ec             	push   -0x14(%ebp)
80104c49:	50                   	push   %eax
80104c4a:	68 c8 af 10 80       	push   $0x8010afc8
80104c4f:	e8 a0 b7 ff ff       	call   801003f4 <cprintf>
80104c54:	83 c4 10             	add    $0x10,%esp
      enqueue(&ptable.proc[i], 2);
80104c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c5a:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104c5d:	83 c0 30             	add    $0x30,%eax
80104c60:	05 00 52 19 80       	add    $0x80195200,%eax
80104c65:	83 c0 04             	add    $0x4,%eax
80104c68:	83 ec 08             	sub    $0x8,%esp
80104c6b:	6a 02                	push   $0x2
80104c6d:	50                   	push   %eax
80104c6e:	e8 a6 fd ff ff       	call   80104a19 <enqueue>
80104c73:	83 c4 10             	add    $0x10,%esp
80104c76:	e9 aa 00 00 00       	jmp    80104d25 <apply_priority_boosting+0x1e8>
    } else if (q == 0 && waited >= 500) {
80104c7b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c7f:	0f 85 a0 00 00 00    	jne    80104d25 <apply_priority_boosting+0x1e8>
80104c85:	81 7d ec f3 01 00 00 	cmpl   $0x1f3,-0x14(%ebp)
80104c8c:	0f 8e 93 00 00 00    	jle    80104d25 <apply_priority_boosting+0x1e8>
      int pid = kernel_pstat.pid[i];
80104c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c95:	83 c0 40             	add    $0x40,%eax
80104c98:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104c9f:	89 45 e8             	mov    %eax,-0x18(%ebp)
      int executed_ticks = kernel_pstat.ticks[i][0];
80104ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca5:	83 c0 40             	add    $0x40,%eax
80104ca8:	c1 e0 04             	shl    $0x4,%eax
80104cab:	05 00 42 19 80       	add    $0x80194200,%eax
80104cb0:	8b 00                	mov    (%eax),%eax
80104cb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      int wait_ticks = kernel_pstat.wait_ticks[i][0];
80104cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb8:	83 e8 80             	sub    $0xffffff80,%eax
80104cbb:	c1 e0 04             	shl    $0x4,%eax
80104cbe:	05 00 42 19 80       	add    $0x80194200,%eax
80104cc3:	8b 00                	mov    (%eax),%eax
80104cc5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    
      kernel_pstat.priority[i] = 1;
80104cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ccb:	83 e8 80             	sub    $0xffffff80,%eax
80104cce:	c7 04 85 00 42 19 80 	movl   $0x1,-0x7fe6be00(,%eax,4)
80104cd5:	01 00 00 00 
      kernel_pstat.wait_ticks[i][0] = 0;
80104cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cdc:	83 e8 80             	sub    $0xffffff80,%eax
80104cdf:	c1 e0 04             	shl    $0x4,%eax
80104ce2:	05 00 42 19 80       	add    $0x80194200,%eax
80104ce7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    
      cprintf("[BOOST] PID %d Q0→Q1 (waited=%d, ticks=%d)\n", pid, wait_ticks, executed_ticks);
80104ced:	ff 75 e4             	push   -0x1c(%ebp)
80104cf0:	ff 75 e0             	push   -0x20(%ebp)
80104cf3:	ff 75 e8             	push   -0x18(%ebp)
80104cf6:	68 ec af 10 80       	push   $0x8010afec
80104cfb:	e8 f4 b6 ff ff       	call   801003f4 <cprintf>
80104d00:	83 c4 10             	add    $0x10,%esp
    
      enqueue(&ptable.proc[i], 1);
80104d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d06:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104d09:	83 c0 30             	add    $0x30,%eax
80104d0c:	05 00 52 19 80       	add    $0x80195200,%eax
80104d11:	83 c0 04             	add    $0x4,%eax
80104d14:	83 ec 08             	sub    $0x8,%esp
80104d17:	6a 01                	push   $0x1
80104d19:	50                   	push   %eax
80104d1a:	e8 fa fc ff ff       	call   80104a19 <enqueue>
80104d1f:	83 c4 10             	add    $0x10,%esp
80104d22:	eb 01                	jmp    80104d25 <apply_priority_boosting+0x1e8>
    if (!kernel_pstat.inuse[i]) continue;
80104d24:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104d25:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104d29:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104d2d:	0f 8e 1c fe ff ff    	jle    80104b4f <apply_priority_boosting+0x12>
    }
  }
}
80104d33:	90                   	nop
80104d34:	90                   	nop
80104d35:	c9                   	leave
80104d36:	c3                   	ret

80104d37 <get_time_slice>:

// Time slice 계산
int get_time_slice(int level) {
80104d37:	55                   	push   %ebp
80104d38:	89 e5                	mov    %esp,%ebp
  if (level == 3) return 8;
80104d3a:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104d3e:	75 07                	jne    80104d47 <get_time_slice+0x10>
80104d40:	b8 08 00 00 00       	mov    $0x8,%eax
80104d45:	eb 1f                	jmp    80104d66 <get_time_slice+0x2f>
  if (level == 2) return 16;
80104d47:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
80104d4b:	75 07                	jne    80104d54 <get_time_slice+0x1d>
80104d4d:	b8 10 00 00 00       	mov    $0x10,%eax
80104d52:	eb 12                	jmp    80104d66 <get_time_slice+0x2f>
  if (level == 1) return 32;
80104d54:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
80104d58:	75 07                	jne    80104d61 <get_time_slice+0x2a>
80104d5a:	b8 20 00 00 00       	mov    $0x20,%eax
80104d5f:	eb 05                	jmp    80104d66 <get_time_slice+0x2f>
  return -1; // FIFO (Q0)
80104d61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d66:	5d                   	pop    %ebp
80104d67:	c3                   	ret

80104d68 <run_process>:

void
run_process(struct proc* p, int q, int slice, int tracking) {
80104d68:	55                   	push   %ebp
80104d69:	89 e5                	mov    %esp,%ebp
80104d6b:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c = mycpu();
80104d6e:	e8 45 ec ff ff       	call   801039b8 <mycpu>
80104d73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->proc = p;
80104d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d79:	8b 55 08             	mov    0x8(%ebp),%edx
80104d7c:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
  switchuvm(p);
80104d82:	83 ec 0c             	sub    $0xc,%esp
80104d85:	ff 75 08             	push   0x8(%ebp)
80104d88:	e8 6b 32 00 00       	call   80107ff8 <switchuvm>
80104d8d:	83 c4 10             	add    $0x10,%esp
  p->state = RUNNING;
80104d90:	8b 45 08             	mov    0x8(%ebp),%eax
80104d93:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
  int i = p - ptable.proc;
80104d9a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d9d:	2d 34 52 19 80       	sub    $0x80195234,%eax
80104da2:	c1 f8 02             	sar    $0x2,%eax
80104da5:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80104dab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cprintf("[RUN_PROCESS] PID %d starts at Q%d\n", p->pid, q);
80104dae:	8b 45 08             	mov    0x8(%ebp),%eax
80104db1:	8b 40 10             	mov    0x10(%eax),%eax
80104db4:	83 ec 04             	sub    $0x4,%esp
80104db7:	ff 75 0c             	push   0xc(%ebp)
80104dba:	50                   	push   %eax
80104dbb:	68 1c b0 10 80       	push   $0x8010b01c
80104dc0:	e8 2f b6 ff ff       	call   801003f4 <cprintf>
80104dc5:	83 c4 10             	add    $0x10,%esp
  swtch(&(c->scheduler), p->context);
80104dc8:	8b 45 08             	mov    0x8(%ebp),%eax
80104dcb:	8b 40 1c             	mov    0x1c(%eax),%eax
80104dce:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104dd1:	83 c2 04             	add    $0x4,%edx
80104dd4:	83 ec 08             	sub    $0x8,%esp
80104dd7:	50                   	push   %eax
80104dd8:	52                   	push   %edx
80104dd9:	e8 ea 08 00 00       	call   801056c8 <swtch>
80104dde:	83 c4 10             	add    $0x10,%esp
  switchkvm();
80104de1:	e8 f9 31 00 00       	call   80107fdf <switchkvm>
  c->proc = 0;
80104de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de9:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104df0:	00 00 00 
  if (tracking) kernel_pstat.ticks[i][q]++;
80104df3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80104df7:	74 39                	je     80104e32 <run_process+0xca>
80104df9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dfc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e03:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e06:	01 d0                	add    %edx,%eax
80104e08:	05 00 01 00 00       	add    $0x100,%eax
80104e0d:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104e14:	8d 50 01             	lea    0x1(%eax),%edx
80104e17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e1a:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80104e21:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e24:	01 c8                	add    %ecx,%eax
80104e26:	05 00 01 00 00       	add    $0x100,%eax
80104e2b:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
  if (slice != -1 && kernel_pstat.ticks[i][q] >= slice && q > 0) {
80104e32:	83 7d 10 ff          	cmpl   $0xffffffff,0x10(%ebp)
80104e36:	0f 84 8d 00 00 00    	je     80104ec9 <run_process+0x161>
80104e3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e3f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e46:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e49:	01 d0                	add    %edx,%eax
80104e4b:	05 00 01 00 00       	add    $0x100,%eax
80104e50:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104e57:	39 45 10             	cmp    %eax,0x10(%ebp)
80104e5a:	7f 6d                	jg     80104ec9 <run_process+0x161>
80104e5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e60:	7e 67                	jle    80104ec9 <run_process+0x161>
    kernel_pstat.priority[i] = q - 1;
80104e62:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e65:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e6b:	83 e8 80             	sub    $0xffffff80,%eax
80104e6e:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
    kernel_pstat.ticks[i][q] = 0;
80104e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e78:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e82:	01 d0                	add    %edx,%eax
80104e84:	05 00 01 00 00       	add    $0x100,%eax
80104e89:	c7 04 85 00 42 19 80 	movl   $0x0,-0x7fe6be00(,%eax,4)
80104e90:	00 00 00 00 
    cprintf("[DEMOTE] PID %d Q%d → Q%d\n", p->pid, q, q - 1);
80104e94:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e97:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e9a:	8b 45 08             	mov    0x8(%ebp),%eax
80104e9d:	8b 40 10             	mov    0x10(%eax),%eax
80104ea0:	52                   	push   %edx
80104ea1:	ff 75 0c             	push   0xc(%ebp)
80104ea4:	50                   	push   %eax
80104ea5:	68 40 b0 10 80       	push   $0x8010b040
80104eaa:	e8 45 b5 ff ff       	call   801003f4 <cprintf>
80104eaf:	83 c4 10             	add    $0x10,%esp
    enqueue(p, q - 1);
80104eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eb5:	83 e8 01             	sub    $0x1,%eax
80104eb8:	83 ec 08             	sub    $0x8,%esp
80104ebb:	50                   	push   %eax
80104ebc:	ff 75 08             	push   0x8(%ebp)
80104ebf:	e8 55 fb ff ff       	call   80104a19 <enqueue>
80104ec4:	83 c4 10             	add    $0x10,%esp
    cprintf("[EXIT_FIFO] PID %d finished Q0 execution (no re-enqueue)\n", p->pid);
  } else {
    cprintf("[RE-ENQUEUE] PID %d stays in Q%d\n", p->pid, q);
    enqueue(p, q);
  }
}
80104ec7:	eb 4a                	jmp    80104f13 <run_process+0x1ab>
  } else if (q == 0) {
80104ec9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104ecd:	75 19                	jne    80104ee8 <run_process+0x180>
    cprintf("[EXIT_FIFO] PID %d finished Q0 execution (no re-enqueue)\n", p->pid);
80104ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed2:	8b 40 10             	mov    0x10(%eax),%eax
80104ed5:	83 ec 08             	sub    $0x8,%esp
80104ed8:	50                   	push   %eax
80104ed9:	68 60 b0 10 80       	push   $0x8010b060
80104ede:	e8 11 b5 ff ff       	call   801003f4 <cprintf>
80104ee3:	83 c4 10             	add    $0x10,%esp
}
80104ee6:	eb 2b                	jmp    80104f13 <run_process+0x1ab>
    cprintf("[RE-ENQUEUE] PID %d stays in Q%d\n", p->pid, q);
80104ee8:	8b 45 08             	mov    0x8(%ebp),%eax
80104eeb:	8b 40 10             	mov    0x10(%eax),%eax
80104eee:	83 ec 04             	sub    $0x4,%esp
80104ef1:	ff 75 0c             	push   0xc(%ebp)
80104ef4:	50                   	push   %eax
80104ef5:	68 9c b0 10 80       	push   $0x8010b09c
80104efa:	e8 f5 b4 ff ff       	call   801003f4 <cprintf>
80104eff:	83 c4 10             	add    $0x10,%esp
    enqueue(p, q);
80104f02:	83 ec 08             	sub    $0x8,%esp
80104f05:	ff 75 0c             	push   0xc(%ebp)
80104f08:	ff 75 08             	push   0x8(%ebp)
80104f0b:	e8 09 fb ff ff       	call   80104a19 <enqueue>
80104f10:	83 c4 10             	add    $0x10,%esp
}
80104f13:	90                   	nop
80104f14:	c9                   	leave
80104f15:	c3                   	ret

80104f16 <run_mlfq>:

// MLFQ 스케줄러 진입점
void
run_mlfq(int tracking, int boosting) {
80104f16:	55                   	push   %ebp
80104f17:	89 e5                	mov    %esp,%ebp
80104f19:	83 ec 28             	sub    $0x28,%esp
  if (boosting)
80104f1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104f20:	74 05                	je     80104f27 <run_mlfq+0x11>
    apply_priority_boosting();
80104f22:	e8 16 fc ff ff       	call   80104b3d <apply_priority_boosting>

  for (int q = 3; q >= 0; q--) {
80104f27:	c7 45 f4 03 00 00 00 	movl   $0x3,-0xc(%ebp)
80104f2e:	eb 75                	jmp    80104fa5 <run_mlfq+0x8f>
    for (int i = 0; i < NPROC; i++) {
80104f30:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104f37:	eb 62                	jmp    80104f9b <run_mlfq+0x85>
      struct proc *p = mlfq_queues[q][i];
80104f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f3c:	c1 e0 06             	shl    $0x6,%eax
80104f3f:	89 c2                	mov    %eax,%edx
80104f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f44:	01 d0                	add    %edx,%eax
80104f46:	8b 04 85 00 4e 19 80 	mov    -0x7fe6b200(,%eax,4),%eax
80104f4d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if (p == 0 || p->state != RUNNABLE)
80104f50:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104f54:	74 40                	je     80104f96 <run_mlfq+0x80>
80104f56:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104f59:	8b 40 0c             	mov    0xc(%eax),%eax
80104f5c:	83 f8 03             	cmp    $0x3,%eax
80104f5f:	75 35                	jne    80104f96 <run_mlfq+0x80>
        continue;
      dequeue(q);
80104f61:	83 ec 0c             	sub    $0xc,%esp
80104f64:	ff 75 f4             	push   -0xc(%ebp)
80104f67:	e8 28 fb ff ff       	call   80104a94 <dequeue>
80104f6c:	83 c4 10             	add    $0x10,%esp
      int slice = get_time_slice(q);
80104f6f:	83 ec 0c             	sub    $0xc,%esp
80104f72:	ff 75 f4             	push   -0xc(%ebp)
80104f75:	e8 bd fd ff ff       	call   80104d37 <get_time_slice>
80104f7a:	83 c4 10             	add    $0x10,%esp
80104f7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      run_process(p, q, slice, tracking);
80104f80:	ff 75 08             	push   0x8(%ebp)
80104f83:	ff 75 e4             	push   -0x1c(%ebp)
80104f86:	ff 75 f4             	push   -0xc(%ebp)
80104f89:	ff 75 e8             	push   -0x18(%ebp)
80104f8c:	e8 d7 fd ff ff       	call   80104d68 <run_process>
80104f91:	83 c4 10             	add    $0x10,%esp
      goto tick_update;
80104f94:	eb 16                	jmp    80104fac <run_mlfq+0x96>
        continue;
80104f96:	90                   	nop
    for (int i = 0; i < NPROC; i++) {
80104f97:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104f9b:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80104f9f:	7e 98                	jle    80104f39 <run_mlfq+0x23>
  for (int q = 3; q >= 0; q--) {
80104fa1:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80104fa5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104fa9:	79 85                	jns    80104f30 <run_mlfq+0x1a>
    }
  }

tick_update:
80104fab:	90                   	nop
  if (!tracking) return;
80104fac:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104fb0:	0f 84 a5 00 00 00    	je     8010505b <run_mlfq+0x145>
  for (int i = 0; i < NPROC; i++) {
80104fb6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104fbd:	e9 8d 00 00 00       	jmp    8010504f <run_mlfq+0x139>
    struct proc* p = &ptable.proc[i];
80104fc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104fc5:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104fc8:	83 c0 30             	add    $0x30,%eax
80104fcb:	05 00 52 19 80       	add    $0x80195200,%eax
80104fd0:	83 c0 04             	add    $0x4,%eax
80104fd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!kernel_pstat.inuse[i]) continue;
80104fd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104fd9:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104fe0:	85 c0                	test   %eax,%eax
80104fe2:	74 66                	je     8010504a <run_mlfq+0x134>
    if (p->state == RUNNABLE && p != mycpu()->proc) {
80104fe4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fe7:	8b 40 0c             	mov    0xc(%eax),%eax
80104fea:	83 f8 03             	cmp    $0x3,%eax
80104fed:	75 5c                	jne    8010504b <run_mlfq+0x135>
80104fef:	e8 c4 e9 ff ff       	call   801039b8 <mycpu>
80104ff4:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104ffa:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80104ffd:	74 4c                	je     8010504b <run_mlfq+0x135>
      int q = kernel_pstat.priority[i];
80104fff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105002:	83 e8 80             	sub    $0xffffff80,%eax
80105005:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
8010500c:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kernel_pstat.wait_ticks[i][q]++;
8010500f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105012:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105019:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010501c:	01 d0                	add    %edx,%eax
8010501e:	05 00 02 00 00       	add    $0x200,%eax
80105023:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
8010502a:	8d 50 01             	lea    0x1(%eax),%edx
8010502d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105030:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80105037:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010503a:	01 c8                	add    %ecx,%eax
8010503c:	05 00 02 00 00       	add    $0x200,%eax
80105041:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
80105048:	eb 01                	jmp    8010504b <run_mlfq+0x135>
    if (!kernel_pstat.inuse[i]) continue;
8010504a:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
8010504b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010504f:	83 7d ec 3f          	cmpl   $0x3f,-0x14(%ebp)
80105053:	0f 8e 69 ff ff ff    	jle    80104fc2 <run_mlfq+0xac>
80105059:	eb 01                	jmp    8010505c <run_mlfq+0x146>
  if (!tracking) return;
8010505b:	90                   	nop
    }
  }
8010505c:	c9                   	leave
8010505d:	c3                   	ret

8010505e <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010505e:	55                   	push   %ebp
8010505f:	89 e5                	mov    %esp,%ebp
80105061:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80105064:	8b 45 08             	mov    0x8(%ebp),%eax
80105067:	83 c0 04             	add    $0x4,%eax
8010506a:	83 ec 08             	sub    $0x8,%esp
8010506d:	68 e8 b0 10 80       	push   $0x8010b0e8
80105072:	50                   	push   %eax
80105073:	e8 43 01 00 00       	call   801051bb <initlock>
80105078:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
8010507b:	8b 45 08             	mov    0x8(%ebp),%eax
8010507e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105081:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105084:	8b 45 08             	mov    0x8(%ebp),%eax
80105087:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010508d:	8b 45 08             	mov    0x8(%ebp),%eax
80105090:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105097:	90                   	nop
80105098:	c9                   	leave
80105099:	c3                   	ret

8010509a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010509a:	55                   	push   %ebp
8010509b:	89 e5                	mov    %esp,%ebp
8010509d:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801050a0:	8b 45 08             	mov    0x8(%ebp),%eax
801050a3:	83 c0 04             	add    $0x4,%eax
801050a6:	83 ec 0c             	sub    $0xc,%esp
801050a9:	50                   	push   %eax
801050aa:	e8 2e 01 00 00       	call   801051dd <acquire>
801050af:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801050b2:	eb 15                	jmp    801050c9 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
801050b4:	8b 45 08             	mov    0x8(%ebp),%eax
801050b7:	83 c0 04             	add    $0x4,%eax
801050ba:	83 ec 08             	sub    $0x8,%esp
801050bd:	50                   	push   %eax
801050be:	ff 75 08             	push   0x8(%ebp)
801050c1:	e8 7d f4 ff ff       	call   80104543 <sleep>
801050c6:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801050c9:	8b 45 08             	mov    0x8(%ebp),%eax
801050cc:	8b 00                	mov    (%eax),%eax
801050ce:	85 c0                	test   %eax,%eax
801050d0:	75 e2                	jne    801050b4 <acquiresleep+0x1a>
  }
  lk->locked = 1;
801050d2:	8b 45 08             	mov    0x8(%ebp),%eax
801050d5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801050db:	e8 50 e9 ff ff       	call   80103a30 <myproc>
801050e0:	8b 50 10             	mov    0x10(%eax),%edx
801050e3:	8b 45 08             	mov    0x8(%ebp),%eax
801050e6:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801050e9:	8b 45 08             	mov    0x8(%ebp),%eax
801050ec:	83 c0 04             	add    $0x4,%eax
801050ef:	83 ec 0c             	sub    $0xc,%esp
801050f2:	50                   	push   %eax
801050f3:	e8 53 01 00 00       	call   8010524b <release>
801050f8:	83 c4 10             	add    $0x10,%esp
}
801050fb:	90                   	nop
801050fc:	c9                   	leave
801050fd:	c3                   	ret

801050fe <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801050fe:	55                   	push   %ebp
801050ff:	89 e5                	mov    %esp,%ebp
80105101:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105104:	8b 45 08             	mov    0x8(%ebp),%eax
80105107:	83 c0 04             	add    $0x4,%eax
8010510a:	83 ec 0c             	sub    $0xc,%esp
8010510d:	50                   	push   %eax
8010510e:	e8 ca 00 00 00       	call   801051dd <acquire>
80105113:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80105116:	8b 45 08             	mov    0x8(%ebp),%eax
80105119:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010511f:	8b 45 08             	mov    0x8(%ebp),%eax
80105122:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105129:	83 ec 0c             	sub    $0xc,%esp
8010512c:	ff 75 08             	push   0x8(%ebp)
8010512f:	e8 f6 f4 ff ff       	call   8010462a <wakeup>
80105134:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80105137:	8b 45 08             	mov    0x8(%ebp),%eax
8010513a:	83 c0 04             	add    $0x4,%eax
8010513d:	83 ec 0c             	sub    $0xc,%esp
80105140:	50                   	push   %eax
80105141:	e8 05 01 00 00       	call   8010524b <release>
80105146:	83 c4 10             	add    $0x10,%esp
}
80105149:	90                   	nop
8010514a:	c9                   	leave
8010514b:	c3                   	ret

8010514c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010514c:	55                   	push   %ebp
8010514d:	89 e5                	mov    %esp,%ebp
8010514f:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80105152:	8b 45 08             	mov    0x8(%ebp),%eax
80105155:	83 c0 04             	add    $0x4,%eax
80105158:	83 ec 0c             	sub    $0xc,%esp
8010515b:	50                   	push   %eax
8010515c:	e8 7c 00 00 00       	call   801051dd <acquire>
80105161:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80105164:	8b 45 08             	mov    0x8(%ebp),%eax
80105167:	8b 00                	mov    (%eax),%eax
80105169:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010516c:	8b 45 08             	mov    0x8(%ebp),%eax
8010516f:	83 c0 04             	add    $0x4,%eax
80105172:	83 ec 0c             	sub    $0xc,%esp
80105175:	50                   	push   %eax
80105176:	e8 d0 00 00 00       	call   8010524b <release>
8010517b:	83 c4 10             	add    $0x10,%esp
  return r;
8010517e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105181:	c9                   	leave
80105182:	c3                   	ret

80105183 <readeflags>:
{
80105183:	55                   	push   %ebp
80105184:	89 e5                	mov    %esp,%ebp
80105186:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105189:	9c                   	pushf
8010518a:	58                   	pop    %eax
8010518b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010518e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105191:	c9                   	leave
80105192:	c3                   	ret

80105193 <cli>:
{
80105193:	55                   	push   %ebp
80105194:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105196:	fa                   	cli
}
80105197:	90                   	nop
80105198:	5d                   	pop    %ebp
80105199:	c3                   	ret

8010519a <sti>:
{
8010519a:	55                   	push   %ebp
8010519b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010519d:	fb                   	sti
}
8010519e:	90                   	nop
8010519f:	5d                   	pop    %ebp
801051a0:	c3                   	ret

801051a1 <xchg>:
{
801051a1:	55                   	push   %ebp
801051a2:	89 e5                	mov    %esp,%ebp
801051a4:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801051a7:	8b 55 08             	mov    0x8(%ebp),%edx
801051aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801051ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
801051b0:	f0 87 02             	lock xchg %eax,(%edx)
801051b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801051b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051b9:	c9                   	leave
801051ba:	c3                   	ret

801051bb <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801051bb:	55                   	push   %ebp
801051bc:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801051be:	8b 45 08             	mov    0x8(%ebp),%eax
801051c1:	8b 55 0c             	mov    0xc(%ebp),%edx
801051c4:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801051c7:	8b 45 08             	mov    0x8(%ebp),%eax
801051ca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801051d0:	8b 45 08             	mov    0x8(%ebp),%eax
801051d3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801051da:	90                   	nop
801051db:	5d                   	pop    %ebp
801051dc:	c3                   	ret

801051dd <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801051dd:	55                   	push   %ebp
801051de:	89 e5                	mov    %esp,%ebp
801051e0:	53                   	push   %ebx
801051e1:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801051e4:	e8 5f 01 00 00       	call   80105348 <pushcli>
  if(holding(lk)){
801051e9:	8b 45 08             	mov    0x8(%ebp),%eax
801051ec:	83 ec 0c             	sub    $0xc,%esp
801051ef:	50                   	push   %eax
801051f0:	e8 23 01 00 00       	call   80105318 <holding>
801051f5:	83 c4 10             	add    $0x10,%esp
801051f8:	85 c0                	test   %eax,%eax
801051fa:	74 0d                	je     80105209 <acquire+0x2c>
    panic("acquire");
801051fc:	83 ec 0c             	sub    $0xc,%esp
801051ff:	68 f3 b0 10 80       	push   $0x8010b0f3
80105204:	e8 a0 b3 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105209:	90                   	nop
8010520a:	8b 45 08             	mov    0x8(%ebp),%eax
8010520d:	83 ec 08             	sub    $0x8,%esp
80105210:	6a 01                	push   $0x1
80105212:	50                   	push   %eax
80105213:	e8 89 ff ff ff       	call   801051a1 <xchg>
80105218:	83 c4 10             	add    $0x10,%esp
8010521b:	85 c0                	test   %eax,%eax
8010521d:	75 eb                	jne    8010520a <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010521f:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105224:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105227:	e8 8c e7 ff ff       	call   801039b8 <mycpu>
8010522c:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010522f:	8b 45 08             	mov    0x8(%ebp),%eax
80105232:	83 c0 0c             	add    $0xc,%eax
80105235:	83 ec 08             	sub    $0x8,%esp
80105238:	50                   	push   %eax
80105239:	8d 45 08             	lea    0x8(%ebp),%eax
8010523c:	50                   	push   %eax
8010523d:	e8 5b 00 00 00       	call   8010529d <getcallerpcs>
80105242:	83 c4 10             	add    $0x10,%esp
}
80105245:	90                   	nop
80105246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105249:	c9                   	leave
8010524a:	c3                   	ret

8010524b <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010524b:	55                   	push   %ebp
8010524c:	89 e5                	mov    %esp,%ebp
8010524e:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105251:	83 ec 0c             	sub    $0xc,%esp
80105254:	ff 75 08             	push   0x8(%ebp)
80105257:	e8 bc 00 00 00       	call   80105318 <holding>
8010525c:	83 c4 10             	add    $0x10,%esp
8010525f:	85 c0                	test   %eax,%eax
80105261:	75 0d                	jne    80105270 <release+0x25>
    panic("release");
80105263:	83 ec 0c             	sub    $0xc,%esp
80105266:	68 fb b0 10 80       	push   $0x8010b0fb
8010526b:	e8 39 b3 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80105270:	8b 45 08             	mov    0x8(%ebp),%eax
80105273:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010527a:	8b 45 08             	mov    0x8(%ebp),%eax
8010527d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105284:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105289:	8b 45 08             	mov    0x8(%ebp),%eax
8010528c:	8b 55 08             	mov    0x8(%ebp),%edx
8010528f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105295:	e8 fb 00 00 00       	call   80105395 <popcli>
}
8010529a:	90                   	nop
8010529b:	c9                   	leave
8010529c:	c3                   	ret

8010529d <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010529d:	55                   	push   %ebp
8010529e:	89 e5                	mov    %esp,%ebp
801052a0:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801052a3:	8b 45 08             	mov    0x8(%ebp),%eax
801052a6:	83 e8 08             	sub    $0x8,%eax
801052a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801052ac:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801052b3:	eb 38                	jmp    801052ed <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801052b5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801052b9:	74 53                	je     8010530e <getcallerpcs+0x71>
801052bb:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801052c2:	76 4a                	jbe    8010530e <getcallerpcs+0x71>
801052c4:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801052c8:	74 44                	je     8010530e <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801052ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801052d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d7:	01 c2                	add    %eax,%edx
801052d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052dc:	8b 40 04             	mov    0x4(%eax),%eax
801052df:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801052e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052e4:	8b 00                	mov    (%eax),%eax
801052e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801052e9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801052ed:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801052f1:	7e c2                	jle    801052b5 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
801052f3:	eb 19                	jmp    8010530e <getcallerpcs+0x71>
    pcs[i] = 0;
801052f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801052ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105302:	01 d0                	add    %edx,%eax
80105304:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010530a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010530e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105312:	7e e1                	jle    801052f5 <getcallerpcs+0x58>
}
80105314:	90                   	nop
80105315:	90                   	nop
80105316:	c9                   	leave
80105317:	c3                   	ret

80105318 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105318:	55                   	push   %ebp
80105319:	89 e5                	mov    %esp,%ebp
8010531b:	53                   	push   %ebx
8010531c:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
8010531f:	8b 45 08             	mov    0x8(%ebp),%eax
80105322:	8b 00                	mov    (%eax),%eax
80105324:	85 c0                	test   %eax,%eax
80105326:	74 16                	je     8010533e <holding+0x26>
80105328:	8b 45 08             	mov    0x8(%ebp),%eax
8010532b:	8b 58 08             	mov    0x8(%eax),%ebx
8010532e:	e8 85 e6 ff ff       	call   801039b8 <mycpu>
80105333:	39 c3                	cmp    %eax,%ebx
80105335:	75 07                	jne    8010533e <holding+0x26>
80105337:	b8 01 00 00 00       	mov    $0x1,%eax
8010533c:	eb 05                	jmp    80105343 <holding+0x2b>
8010533e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105343:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105346:	c9                   	leave
80105347:	c3                   	ret

80105348 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105348:	55                   	push   %ebp
80105349:	89 e5                	mov    %esp,%ebp
8010534b:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010534e:	e8 30 fe ff ff       	call   80105183 <readeflags>
80105353:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105356:	e8 38 fe ff ff       	call   80105193 <cli>
  if(mycpu()->ncli == 0)
8010535b:	e8 58 e6 ff ff       	call   801039b8 <mycpu>
80105360:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105366:	85 c0                	test   %eax,%eax
80105368:	75 14                	jne    8010537e <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
8010536a:	e8 49 e6 ff ff       	call   801039b8 <mycpu>
8010536f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105372:	81 e2 00 02 00 00    	and    $0x200,%edx
80105378:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
8010537e:	e8 35 e6 ff ff       	call   801039b8 <mycpu>
80105383:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105389:	83 c2 01             	add    $0x1,%edx
8010538c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105392:	90                   	nop
80105393:	c9                   	leave
80105394:	c3                   	ret

80105395 <popcli>:

void
popcli(void)
{
80105395:	55                   	push   %ebp
80105396:	89 e5                	mov    %esp,%ebp
80105398:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010539b:	e8 e3 fd ff ff       	call   80105183 <readeflags>
801053a0:	25 00 02 00 00       	and    $0x200,%eax
801053a5:	85 c0                	test   %eax,%eax
801053a7:	74 0d                	je     801053b6 <popcli+0x21>
    panic("popcli - interruptible");
801053a9:	83 ec 0c             	sub    $0xc,%esp
801053ac:	68 03 b1 10 80       	push   $0x8010b103
801053b1:	e8 f3 b1 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
801053b6:	e8 fd e5 ff ff       	call   801039b8 <mycpu>
801053bb:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801053c1:	83 ea 01             	sub    $0x1,%edx
801053c4:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801053ca:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801053d0:	85 c0                	test   %eax,%eax
801053d2:	79 0d                	jns    801053e1 <popcli+0x4c>
    panic("popcli");
801053d4:	83 ec 0c             	sub    $0xc,%esp
801053d7:	68 1a b1 10 80       	push   $0x8010b11a
801053dc:	e8 c8 b1 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801053e1:	e8 d2 e5 ff ff       	call   801039b8 <mycpu>
801053e6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801053ec:	85 c0                	test   %eax,%eax
801053ee:	75 14                	jne    80105404 <popcli+0x6f>
801053f0:	e8 c3 e5 ff ff       	call   801039b8 <mycpu>
801053f5:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801053fb:	85 c0                	test   %eax,%eax
801053fd:	74 05                	je     80105404 <popcli+0x6f>
    sti();
801053ff:	e8 96 fd ff ff       	call   8010519a <sti>
}
80105404:	90                   	nop
80105405:	c9                   	leave
80105406:	c3                   	ret

80105407 <stosb>:
{
80105407:	55                   	push   %ebp
80105408:	89 e5                	mov    %esp,%ebp
8010540a:	57                   	push   %edi
8010540b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010540c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010540f:	8b 55 10             	mov    0x10(%ebp),%edx
80105412:	8b 45 0c             	mov    0xc(%ebp),%eax
80105415:	89 cb                	mov    %ecx,%ebx
80105417:	89 df                	mov    %ebx,%edi
80105419:	89 d1                	mov    %edx,%ecx
8010541b:	fc                   	cld
8010541c:	f3 aa                	rep stos %al,%es:(%edi)
8010541e:	89 ca                	mov    %ecx,%edx
80105420:	89 fb                	mov    %edi,%ebx
80105422:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105425:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105428:	90                   	nop
80105429:	5b                   	pop    %ebx
8010542a:	5f                   	pop    %edi
8010542b:	5d                   	pop    %ebp
8010542c:	c3                   	ret

8010542d <stosl>:
{
8010542d:	55                   	push   %ebp
8010542e:	89 e5                	mov    %esp,%ebp
80105430:	57                   	push   %edi
80105431:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105432:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105435:	8b 55 10             	mov    0x10(%ebp),%edx
80105438:	8b 45 0c             	mov    0xc(%ebp),%eax
8010543b:	89 cb                	mov    %ecx,%ebx
8010543d:	89 df                	mov    %ebx,%edi
8010543f:	89 d1                	mov    %edx,%ecx
80105441:	fc                   	cld
80105442:	f3 ab                	rep stos %eax,%es:(%edi)
80105444:	89 ca                	mov    %ecx,%edx
80105446:	89 fb                	mov    %edi,%ebx
80105448:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010544b:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010544e:	90                   	nop
8010544f:	5b                   	pop    %ebx
80105450:	5f                   	pop    %edi
80105451:	5d                   	pop    %ebp
80105452:	c3                   	ret

80105453 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105453:	55                   	push   %ebp
80105454:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105456:	8b 45 08             	mov    0x8(%ebp),%eax
80105459:	83 e0 03             	and    $0x3,%eax
8010545c:	85 c0                	test   %eax,%eax
8010545e:	75 43                	jne    801054a3 <memset+0x50>
80105460:	8b 45 10             	mov    0x10(%ebp),%eax
80105463:	83 e0 03             	and    $0x3,%eax
80105466:	85 c0                	test   %eax,%eax
80105468:	75 39                	jne    801054a3 <memset+0x50>
    c &= 0xFF;
8010546a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105471:	8b 45 10             	mov    0x10(%ebp),%eax
80105474:	c1 e8 02             	shr    $0x2,%eax
80105477:	89 c1                	mov    %eax,%ecx
80105479:	8b 45 0c             	mov    0xc(%ebp),%eax
8010547c:	c1 e0 18             	shl    $0x18,%eax
8010547f:	89 c2                	mov    %eax,%edx
80105481:	8b 45 0c             	mov    0xc(%ebp),%eax
80105484:	c1 e0 10             	shl    $0x10,%eax
80105487:	09 c2                	or     %eax,%edx
80105489:	8b 45 0c             	mov    0xc(%ebp),%eax
8010548c:	c1 e0 08             	shl    $0x8,%eax
8010548f:	09 d0                	or     %edx,%eax
80105491:	0b 45 0c             	or     0xc(%ebp),%eax
80105494:	51                   	push   %ecx
80105495:	50                   	push   %eax
80105496:	ff 75 08             	push   0x8(%ebp)
80105499:	e8 8f ff ff ff       	call   8010542d <stosl>
8010549e:	83 c4 0c             	add    $0xc,%esp
801054a1:	eb 12                	jmp    801054b5 <memset+0x62>
  } else
    stosb(dst, c, n);
801054a3:	8b 45 10             	mov    0x10(%ebp),%eax
801054a6:	50                   	push   %eax
801054a7:	ff 75 0c             	push   0xc(%ebp)
801054aa:	ff 75 08             	push   0x8(%ebp)
801054ad:	e8 55 ff ff ff       	call   80105407 <stosb>
801054b2:	83 c4 0c             	add    $0xc,%esp
  return dst;
801054b5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801054b8:	c9                   	leave
801054b9:	c3                   	ret

801054ba <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801054ba:	55                   	push   %ebp
801054bb:	89 e5                	mov    %esp,%ebp
801054bd:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801054c0:	8b 45 08             	mov    0x8(%ebp),%eax
801054c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801054c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801054c9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801054cc:	eb 2e                	jmp    801054fc <memcmp+0x42>
    if(*s1 != *s2)
801054ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054d1:	0f b6 10             	movzbl (%eax),%edx
801054d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054d7:	0f b6 00             	movzbl (%eax),%eax
801054da:	38 c2                	cmp    %al,%dl
801054dc:	74 16                	je     801054f4 <memcmp+0x3a>
      return *s1 - *s2;
801054de:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054e1:	0f b6 00             	movzbl (%eax),%eax
801054e4:	0f b6 d0             	movzbl %al,%edx
801054e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054ea:	0f b6 00             	movzbl (%eax),%eax
801054ed:	0f b6 c0             	movzbl %al,%eax
801054f0:	29 c2                	sub    %eax,%edx
801054f2:	eb 1a                	jmp    8010550e <memcmp+0x54>
    s1++, s2++;
801054f4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054f8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
801054fc:	8b 45 10             	mov    0x10(%ebp),%eax
801054ff:	8d 50 ff             	lea    -0x1(%eax),%edx
80105502:	89 55 10             	mov    %edx,0x10(%ebp)
80105505:	85 c0                	test   %eax,%eax
80105507:	75 c5                	jne    801054ce <memcmp+0x14>
  }

  return 0;
80105509:	ba 00 00 00 00       	mov    $0x0,%edx
}
8010550e:	89 d0                	mov    %edx,%eax
80105510:	c9                   	leave
80105511:	c3                   	ret

80105512 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105512:	55                   	push   %ebp
80105513:	89 e5                	mov    %esp,%ebp
80105515:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105518:	8b 45 0c             	mov    0xc(%ebp),%eax
8010551b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010551e:	8b 45 08             	mov    0x8(%ebp),%eax
80105521:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105524:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105527:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010552a:	73 54                	jae    80105580 <memmove+0x6e>
8010552c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010552f:	8b 45 10             	mov    0x10(%ebp),%eax
80105532:	01 d0                	add    %edx,%eax
80105534:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105537:	73 47                	jae    80105580 <memmove+0x6e>
    s += n;
80105539:	8b 45 10             	mov    0x10(%ebp),%eax
8010553c:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010553f:	8b 45 10             	mov    0x10(%ebp),%eax
80105542:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105545:	eb 13                	jmp    8010555a <memmove+0x48>
      *--d = *--s;
80105547:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010554b:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010554f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105552:	0f b6 10             	movzbl (%eax),%edx
80105555:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105558:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010555a:	8b 45 10             	mov    0x10(%ebp),%eax
8010555d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105560:	89 55 10             	mov    %edx,0x10(%ebp)
80105563:	85 c0                	test   %eax,%eax
80105565:	75 e0                	jne    80105547 <memmove+0x35>
  if(s < d && s + n > d){
80105567:	eb 24                	jmp    8010558d <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105569:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010556c:	8d 42 01             	lea    0x1(%edx),%eax
8010556f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105572:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105575:	8d 48 01             	lea    0x1(%eax),%ecx
80105578:	89 4d f8             	mov    %ecx,-0x8(%ebp)
8010557b:	0f b6 12             	movzbl (%edx),%edx
8010557e:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105580:	8b 45 10             	mov    0x10(%ebp),%eax
80105583:	8d 50 ff             	lea    -0x1(%eax),%edx
80105586:	89 55 10             	mov    %edx,0x10(%ebp)
80105589:	85 c0                	test   %eax,%eax
8010558b:	75 dc                	jne    80105569 <memmove+0x57>

  return dst;
8010558d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105590:	c9                   	leave
80105591:	c3                   	ret

80105592 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105592:	55                   	push   %ebp
80105593:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105595:	ff 75 10             	push   0x10(%ebp)
80105598:	ff 75 0c             	push   0xc(%ebp)
8010559b:	ff 75 08             	push   0x8(%ebp)
8010559e:	e8 6f ff ff ff       	call   80105512 <memmove>
801055a3:	83 c4 0c             	add    $0xc,%esp
}
801055a6:	c9                   	leave
801055a7:	c3                   	ret

801055a8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801055a8:	55                   	push   %ebp
801055a9:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801055ab:	eb 0c                	jmp    801055b9 <strncmp+0x11>
    n--, p++, q++;
801055ad:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801055b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801055b5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801055b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055bd:	74 1a                	je     801055d9 <strncmp+0x31>
801055bf:	8b 45 08             	mov    0x8(%ebp),%eax
801055c2:	0f b6 00             	movzbl (%eax),%eax
801055c5:	84 c0                	test   %al,%al
801055c7:	74 10                	je     801055d9 <strncmp+0x31>
801055c9:	8b 45 08             	mov    0x8(%ebp),%eax
801055cc:	0f b6 10             	movzbl (%eax),%edx
801055cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801055d2:	0f b6 00             	movzbl (%eax),%eax
801055d5:	38 c2                	cmp    %al,%dl
801055d7:	74 d4                	je     801055ad <strncmp+0x5>
  if(n == 0)
801055d9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055dd:	75 07                	jne    801055e6 <strncmp+0x3e>
    return 0;
801055df:	ba 00 00 00 00       	mov    $0x0,%edx
801055e4:	eb 14                	jmp    801055fa <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
801055e6:	8b 45 08             	mov    0x8(%ebp),%eax
801055e9:	0f b6 00             	movzbl (%eax),%eax
801055ec:	0f b6 d0             	movzbl %al,%edx
801055ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f2:	0f b6 00             	movzbl (%eax),%eax
801055f5:	0f b6 c0             	movzbl %al,%eax
801055f8:	29 c2                	sub    %eax,%edx
}
801055fa:	89 d0                	mov    %edx,%eax
801055fc:	5d                   	pop    %ebp
801055fd:	c3                   	ret

801055fe <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801055fe:	55                   	push   %ebp
801055ff:	89 e5                	mov    %esp,%ebp
80105601:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105604:	8b 45 08             	mov    0x8(%ebp),%eax
80105607:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010560a:	90                   	nop
8010560b:	8b 45 10             	mov    0x10(%ebp),%eax
8010560e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105611:	89 55 10             	mov    %edx,0x10(%ebp)
80105614:	85 c0                	test   %eax,%eax
80105616:	7e 2c                	jle    80105644 <strncpy+0x46>
80105618:	8b 55 0c             	mov    0xc(%ebp),%edx
8010561b:	8d 42 01             	lea    0x1(%edx),%eax
8010561e:	89 45 0c             	mov    %eax,0xc(%ebp)
80105621:	8b 45 08             	mov    0x8(%ebp),%eax
80105624:	8d 48 01             	lea    0x1(%eax),%ecx
80105627:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010562a:	0f b6 12             	movzbl (%edx),%edx
8010562d:	88 10                	mov    %dl,(%eax)
8010562f:	0f b6 00             	movzbl (%eax),%eax
80105632:	84 c0                	test   %al,%al
80105634:	75 d5                	jne    8010560b <strncpy+0xd>
    ;
  while(n-- > 0)
80105636:	eb 0c                	jmp    80105644 <strncpy+0x46>
    *s++ = 0;
80105638:	8b 45 08             	mov    0x8(%ebp),%eax
8010563b:	8d 50 01             	lea    0x1(%eax),%edx
8010563e:	89 55 08             	mov    %edx,0x8(%ebp)
80105641:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105644:	8b 45 10             	mov    0x10(%ebp),%eax
80105647:	8d 50 ff             	lea    -0x1(%eax),%edx
8010564a:	89 55 10             	mov    %edx,0x10(%ebp)
8010564d:	85 c0                	test   %eax,%eax
8010564f:	7f e7                	jg     80105638 <strncpy+0x3a>
  return os;
80105651:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105654:	c9                   	leave
80105655:	c3                   	ret

80105656 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105656:	55                   	push   %ebp
80105657:	89 e5                	mov    %esp,%ebp
80105659:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010565c:	8b 45 08             	mov    0x8(%ebp),%eax
8010565f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105662:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105666:	7f 05                	jg     8010566d <safestrcpy+0x17>
    return os;
80105668:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010566b:	eb 32                	jmp    8010569f <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
8010566d:	90                   	nop
8010566e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105672:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105676:	7e 1e                	jle    80105696 <safestrcpy+0x40>
80105678:	8b 55 0c             	mov    0xc(%ebp),%edx
8010567b:	8d 42 01             	lea    0x1(%edx),%eax
8010567e:	89 45 0c             	mov    %eax,0xc(%ebp)
80105681:	8b 45 08             	mov    0x8(%ebp),%eax
80105684:	8d 48 01             	lea    0x1(%eax),%ecx
80105687:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010568a:	0f b6 12             	movzbl (%edx),%edx
8010568d:	88 10                	mov    %dl,(%eax)
8010568f:	0f b6 00             	movzbl (%eax),%eax
80105692:	84 c0                	test   %al,%al
80105694:	75 d8                	jne    8010566e <safestrcpy+0x18>
    ;
  *s = 0;
80105696:	8b 45 08             	mov    0x8(%ebp),%eax
80105699:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010569c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010569f:	c9                   	leave
801056a0:	c3                   	ret

801056a1 <strlen>:

int
strlen(const char *s)
{
801056a1:	55                   	push   %ebp
801056a2:	89 e5                	mov    %esp,%ebp
801056a4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801056a7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801056ae:	eb 04                	jmp    801056b4 <strlen+0x13>
801056b0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056b4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056b7:	8b 45 08             	mov    0x8(%ebp),%eax
801056ba:	01 d0                	add    %edx,%eax
801056bc:	0f b6 00             	movzbl (%eax),%eax
801056bf:	84 c0                	test   %al,%al
801056c1:	75 ed                	jne    801056b0 <strlen+0xf>
    ;
  return n;
801056c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801056c6:	c9                   	leave
801056c7:	c3                   	ret

801056c8 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801056c8:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801056cc:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801056d0:	55                   	push   %ebp
  pushl %ebx
801056d1:	53                   	push   %ebx
  pushl %esi
801056d2:	56                   	push   %esi
  pushl %edi
801056d3:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801056d4:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801056d6:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801056d8:	5f                   	pop    %edi
  popl %esi
801056d9:	5e                   	pop    %esi
  popl %ebx
801056da:	5b                   	pop    %ebx
  popl %ebp
801056db:	5d                   	pop    %ebp
  ret
801056dc:	c3                   	ret

801056dd <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801056dd:	55                   	push   %ebp
801056de:	89 e5                	mov    %esp,%ebp
801056e0:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801056e3:	e8 48 e3 ff ff       	call   80103a30 <myproc>
801056e8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801056eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ee:	8b 00                	mov    (%eax),%eax
801056f0:	39 45 08             	cmp    %eax,0x8(%ebp)
801056f3:	73 0f                	jae    80105704 <fetchint+0x27>
801056f5:	8b 45 08             	mov    0x8(%ebp),%eax
801056f8:	8d 50 04             	lea    0x4(%eax),%edx
801056fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056fe:	8b 00                	mov    (%eax),%eax
80105700:	39 d0                	cmp    %edx,%eax
80105702:	73 07                	jae    8010570b <fetchint+0x2e>
    return -1;
80105704:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105709:	eb 0f                	jmp    8010571a <fetchint+0x3d>
  *ip = *(int*)(addr);
8010570b:	8b 45 08             	mov    0x8(%ebp),%eax
8010570e:	8b 10                	mov    (%eax),%edx
80105710:	8b 45 0c             	mov    0xc(%ebp),%eax
80105713:	89 10                	mov    %edx,(%eax)
  return 0;
80105715:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010571a:	c9                   	leave
8010571b:	c3                   	ret

8010571c <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010571c:	55                   	push   %ebp
8010571d:	89 e5                	mov    %esp,%ebp
8010571f:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105722:	e8 09 e3 ff ff       	call   80103a30 <myproc>
80105727:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010572a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010572d:	8b 00                	mov    (%eax),%eax
8010572f:	39 45 08             	cmp    %eax,0x8(%ebp)
80105732:	72 07                	jb     8010573b <fetchstr+0x1f>
    return -1;
80105734:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105739:	eb 41                	jmp    8010577c <fetchstr+0x60>
  *pp = (char*)addr;
8010573b:	8b 55 08             	mov    0x8(%ebp),%edx
8010573e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105741:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105743:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105746:	8b 00                	mov    (%eax),%eax
80105748:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010574b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010574e:	8b 00                	mov    (%eax),%eax
80105750:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105753:	eb 1a                	jmp    8010576f <fetchstr+0x53>
    if(*s == 0)
80105755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105758:	0f b6 00             	movzbl (%eax),%eax
8010575b:	84 c0                	test   %al,%al
8010575d:	75 0c                	jne    8010576b <fetchstr+0x4f>
      return s - *pp;
8010575f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105762:	8b 10                	mov    (%eax),%edx
80105764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105767:	29 d0                	sub    %edx,%eax
80105769:	eb 11                	jmp    8010577c <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
8010576b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010576f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105772:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105775:	72 de                	jb     80105755 <fetchstr+0x39>
  }
  return -1;
80105777:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010577c:	c9                   	leave
8010577d:	c3                   	ret

8010577e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010577e:	55                   	push   %ebp
8010577f:	89 e5                	mov    %esp,%ebp
80105781:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105784:	e8 a7 e2 ff ff       	call   80103a30 <myproc>
80105789:	8b 40 18             	mov    0x18(%eax),%eax
8010578c:	8b 40 44             	mov    0x44(%eax),%eax
8010578f:	8b 55 08             	mov    0x8(%ebp),%edx
80105792:	c1 e2 02             	shl    $0x2,%edx
80105795:	01 d0                	add    %edx,%eax
80105797:	83 c0 04             	add    $0x4,%eax
8010579a:	83 ec 08             	sub    $0x8,%esp
8010579d:	ff 75 0c             	push   0xc(%ebp)
801057a0:	50                   	push   %eax
801057a1:	e8 37 ff ff ff       	call   801056dd <fetchint>
801057a6:	83 c4 10             	add    $0x10,%esp
}
801057a9:	c9                   	leave
801057aa:	c3                   	ret

801057ab <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801057ab:	55                   	push   %ebp
801057ac:	89 e5                	mov    %esp,%ebp
801057ae:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801057b1:	e8 7a e2 ff ff       	call   80103a30 <myproc>
801057b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801057b9:	83 ec 08             	sub    $0x8,%esp
801057bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057bf:	50                   	push   %eax
801057c0:	ff 75 08             	push   0x8(%ebp)
801057c3:	e8 b6 ff ff ff       	call   8010577e <argint>
801057c8:	83 c4 10             	add    $0x10,%esp
801057cb:	85 c0                	test   %eax,%eax
801057cd:	79 07                	jns    801057d6 <argptr+0x2b>
    return -1;
801057cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057d4:	eb 3b                	jmp    80105811 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801057d6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057da:	78 1f                	js     801057fb <argptr+0x50>
801057dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057df:	8b 00                	mov    (%eax),%eax
801057e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057e4:	39 c2                	cmp    %eax,%edx
801057e6:	73 13                	jae    801057fb <argptr+0x50>
801057e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057eb:	89 c2                	mov    %eax,%edx
801057ed:	8b 45 10             	mov    0x10(%ebp),%eax
801057f0:	01 c2                	add    %eax,%edx
801057f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f5:	8b 00                	mov    (%eax),%eax
801057f7:	39 d0                	cmp    %edx,%eax
801057f9:	73 07                	jae    80105802 <argptr+0x57>
    return -1;
801057fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105800:	eb 0f                	jmp    80105811 <argptr+0x66>
  *pp = (char*)i;
80105802:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105805:	89 c2                	mov    %eax,%edx
80105807:	8b 45 0c             	mov    0xc(%ebp),%eax
8010580a:	89 10                	mov    %edx,(%eax)
  return 0;
8010580c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105811:	c9                   	leave
80105812:	c3                   	ret

80105813 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105813:	55                   	push   %ebp
80105814:	89 e5                	mov    %esp,%ebp
80105816:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105819:	83 ec 08             	sub    $0x8,%esp
8010581c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010581f:	50                   	push   %eax
80105820:	ff 75 08             	push   0x8(%ebp)
80105823:	e8 56 ff ff ff       	call   8010577e <argint>
80105828:	83 c4 10             	add    $0x10,%esp
8010582b:	85 c0                	test   %eax,%eax
8010582d:	79 07                	jns    80105836 <argstr+0x23>
    return -1;
8010582f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105834:	eb 12                	jmp    80105848 <argstr+0x35>
  return fetchstr(addr, pp);
80105836:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105839:	83 ec 08             	sub    $0x8,%esp
8010583c:	ff 75 0c             	push   0xc(%ebp)
8010583f:	50                   	push   %eax
80105840:	e8 d7 fe ff ff       	call   8010571c <fetchstr>
80105845:	83 c4 10             	add    $0x10,%esp
}
80105848:	c9                   	leave
80105849:	c3                   	ret

8010584a <syscall>:
[SYS_getSchedPolicy]    sys_getSchedPolicy,
};

void
syscall(void)
{
8010584a:	55                   	push   %ebp
8010584b:	89 e5                	mov    %esp,%ebp
8010584d:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105850:	e8 db e1 ff ff       	call   80103a30 <myproc>
80105855:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105858:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010585b:	8b 40 18             	mov    0x18(%eax),%eax
8010585e:	8b 40 1c             	mov    0x1c(%eax),%eax
80105861:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105864:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105868:	7e 2f                	jle    80105899 <syscall+0x4f>
8010586a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010586d:	83 f8 19             	cmp    $0x19,%eax
80105870:	77 27                	ja     80105899 <syscall+0x4f>
80105872:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105875:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010587c:	85 c0                	test   %eax,%eax
8010587e:	74 19                	je     80105899 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80105880:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105883:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010588a:	ff d0                	call   *%eax
8010588c:	89 c2                	mov    %eax,%edx
8010588e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105891:	8b 40 18             	mov    0x18(%eax),%eax
80105894:	89 50 1c             	mov    %edx,0x1c(%eax)
80105897:	eb 2c                	jmp    801058c5 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010589c:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010589f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a2:	8b 40 10             	mov    0x10(%eax),%eax
801058a5:	ff 75 f0             	push   -0x10(%ebp)
801058a8:	52                   	push   %edx
801058a9:	50                   	push   %eax
801058aa:	68 21 b1 10 80       	push   $0x8010b121
801058af:	e8 40 ab ff ff       	call   801003f4 <cprintf>
801058b4:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801058b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ba:	8b 40 18             	mov    0x18(%eax),%eax
801058bd:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801058c4:	90                   	nop
801058c5:	90                   	nop
801058c6:	c9                   	leave
801058c7:	c3                   	ret

801058c8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801058c8:	55                   	push   %ebp
801058c9:	89 e5                	mov    %esp,%ebp
801058cb:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801058ce:	83 ec 08             	sub    $0x8,%esp
801058d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058d4:	50                   	push   %eax
801058d5:	ff 75 08             	push   0x8(%ebp)
801058d8:	e8 a1 fe ff ff       	call   8010577e <argint>
801058dd:	83 c4 10             	add    $0x10,%esp
801058e0:	85 c0                	test   %eax,%eax
801058e2:	79 07                	jns    801058eb <argfd+0x23>
    return -1;
801058e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058e9:	eb 4f                	jmp    8010593a <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801058eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ee:	85 c0                	test   %eax,%eax
801058f0:	78 20                	js     80105912 <argfd+0x4a>
801058f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f5:	83 f8 0f             	cmp    $0xf,%eax
801058f8:	7f 18                	jg     80105912 <argfd+0x4a>
801058fa:	e8 31 e1 ff ff       	call   80103a30 <myproc>
801058ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105902:	83 c2 08             	add    $0x8,%edx
80105905:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105909:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010590c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105910:	75 07                	jne    80105919 <argfd+0x51>
    return -1;
80105912:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105917:	eb 21                	jmp    8010593a <argfd+0x72>
  if(pfd)
80105919:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010591d:	74 08                	je     80105927 <argfd+0x5f>
    *pfd = fd;
8010591f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105922:	8b 45 0c             	mov    0xc(%ebp),%eax
80105925:	89 10                	mov    %edx,(%eax)
  if(pf)
80105927:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010592b:	74 08                	je     80105935 <argfd+0x6d>
    *pf = f;
8010592d:	8b 45 10             	mov    0x10(%ebp),%eax
80105930:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105933:	89 10                	mov    %edx,(%eax)
  return 0;
80105935:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010593a:	c9                   	leave
8010593b:	c3                   	ret

8010593c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010593c:	55                   	push   %ebp
8010593d:	89 e5                	mov    %esp,%ebp
8010593f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105942:	e8 e9 e0 ff ff       	call   80103a30 <myproc>
80105947:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010594a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105951:	eb 2a                	jmp    8010597d <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105956:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105959:	83 c2 08             	add    $0x8,%edx
8010595c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105960:	85 c0                	test   %eax,%eax
80105962:	75 15                	jne    80105979 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105964:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105967:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010596a:	8d 4a 08             	lea    0x8(%edx),%ecx
8010596d:	8b 55 08             	mov    0x8(%ebp),%edx
80105970:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105977:	eb 0f                	jmp    80105988 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105979:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010597d:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105981:	7e d0                	jle    80105953 <fdalloc+0x17>
    }
  }
  return -1;
80105983:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105988:	c9                   	leave
80105989:	c3                   	ret

8010598a <sys_dup>:

int
sys_dup(void)
{
8010598a:	55                   	push   %ebp
8010598b:	89 e5                	mov    %esp,%ebp
8010598d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105990:	83 ec 04             	sub    $0x4,%esp
80105993:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105996:	50                   	push   %eax
80105997:	6a 00                	push   $0x0
80105999:	6a 00                	push   $0x0
8010599b:	e8 28 ff ff ff       	call   801058c8 <argfd>
801059a0:	83 c4 10             	add    $0x10,%esp
801059a3:	85 c0                	test   %eax,%eax
801059a5:	79 07                	jns    801059ae <sys_dup+0x24>
    return -1;
801059a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ac:	eb 31                	jmp    801059df <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801059ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b1:	83 ec 0c             	sub    $0xc,%esp
801059b4:	50                   	push   %eax
801059b5:	e8 82 ff ff ff       	call   8010593c <fdalloc>
801059ba:	83 c4 10             	add    $0x10,%esp
801059bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059c4:	79 07                	jns    801059cd <sys_dup+0x43>
    return -1;
801059c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059cb:	eb 12                	jmp    801059df <sys_dup+0x55>
  filedup(f);
801059cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d0:	83 ec 0c             	sub    $0xc,%esp
801059d3:	50                   	push   %eax
801059d4:	e8 7b b6 ff ff       	call   80101054 <filedup>
801059d9:	83 c4 10             	add    $0x10,%esp
  return fd;
801059dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801059df:	c9                   	leave
801059e0:	c3                   	ret

801059e1 <sys_read>:

int
sys_read(void)
{
801059e1:	55                   	push   %ebp
801059e2:	89 e5                	mov    %esp,%ebp
801059e4:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801059e7:	83 ec 04             	sub    $0x4,%esp
801059ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059ed:	50                   	push   %eax
801059ee:	6a 00                	push   $0x0
801059f0:	6a 00                	push   $0x0
801059f2:	e8 d1 fe ff ff       	call   801058c8 <argfd>
801059f7:	83 c4 10             	add    $0x10,%esp
801059fa:	85 c0                	test   %eax,%eax
801059fc:	78 2e                	js     80105a2c <sys_read+0x4b>
801059fe:	83 ec 08             	sub    $0x8,%esp
80105a01:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a04:	50                   	push   %eax
80105a05:	6a 02                	push   $0x2
80105a07:	e8 72 fd ff ff       	call   8010577e <argint>
80105a0c:	83 c4 10             	add    $0x10,%esp
80105a0f:	85 c0                	test   %eax,%eax
80105a11:	78 19                	js     80105a2c <sys_read+0x4b>
80105a13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a16:	83 ec 04             	sub    $0x4,%esp
80105a19:	50                   	push   %eax
80105a1a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a1d:	50                   	push   %eax
80105a1e:	6a 01                	push   $0x1
80105a20:	e8 86 fd ff ff       	call   801057ab <argptr>
80105a25:	83 c4 10             	add    $0x10,%esp
80105a28:	85 c0                	test   %eax,%eax
80105a2a:	79 07                	jns    80105a33 <sys_read+0x52>
    return -1;
80105a2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a31:	eb 17                	jmp    80105a4a <sys_read+0x69>
  return fileread(f, p, n);
80105a33:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a36:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3c:	83 ec 04             	sub    $0x4,%esp
80105a3f:	51                   	push   %ecx
80105a40:	52                   	push   %edx
80105a41:	50                   	push   %eax
80105a42:	e8 9d b7 ff ff       	call   801011e4 <fileread>
80105a47:	83 c4 10             	add    $0x10,%esp
}
80105a4a:	c9                   	leave
80105a4b:	c3                   	ret

80105a4c <sys_write>:

int
sys_write(void)
{
80105a4c:	55                   	push   %ebp
80105a4d:	89 e5                	mov    %esp,%ebp
80105a4f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a52:	83 ec 04             	sub    $0x4,%esp
80105a55:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a58:	50                   	push   %eax
80105a59:	6a 00                	push   $0x0
80105a5b:	6a 00                	push   $0x0
80105a5d:	e8 66 fe ff ff       	call   801058c8 <argfd>
80105a62:	83 c4 10             	add    $0x10,%esp
80105a65:	85 c0                	test   %eax,%eax
80105a67:	78 2e                	js     80105a97 <sys_write+0x4b>
80105a69:	83 ec 08             	sub    $0x8,%esp
80105a6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a6f:	50                   	push   %eax
80105a70:	6a 02                	push   $0x2
80105a72:	e8 07 fd ff ff       	call   8010577e <argint>
80105a77:	83 c4 10             	add    $0x10,%esp
80105a7a:	85 c0                	test   %eax,%eax
80105a7c:	78 19                	js     80105a97 <sys_write+0x4b>
80105a7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a81:	83 ec 04             	sub    $0x4,%esp
80105a84:	50                   	push   %eax
80105a85:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a88:	50                   	push   %eax
80105a89:	6a 01                	push   $0x1
80105a8b:	e8 1b fd ff ff       	call   801057ab <argptr>
80105a90:	83 c4 10             	add    $0x10,%esp
80105a93:	85 c0                	test   %eax,%eax
80105a95:	79 07                	jns    80105a9e <sys_write+0x52>
    return -1;
80105a97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a9c:	eb 17                	jmp    80105ab5 <sys_write+0x69>
  return filewrite(f, p, n);
80105a9e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105aa1:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa7:	83 ec 04             	sub    $0x4,%esp
80105aaa:	51                   	push   %ecx
80105aab:	52                   	push   %edx
80105aac:	50                   	push   %eax
80105aad:	e8 ea b7 ff ff       	call   8010129c <filewrite>
80105ab2:	83 c4 10             	add    $0x10,%esp
}
80105ab5:	c9                   	leave
80105ab6:	c3                   	ret

80105ab7 <sys_close>:

int
sys_close(void)
{
80105ab7:	55                   	push   %ebp
80105ab8:	89 e5                	mov    %esp,%ebp
80105aba:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105abd:	83 ec 04             	sub    $0x4,%esp
80105ac0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ac3:	50                   	push   %eax
80105ac4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ac7:	50                   	push   %eax
80105ac8:	6a 00                	push   $0x0
80105aca:	e8 f9 fd ff ff       	call   801058c8 <argfd>
80105acf:	83 c4 10             	add    $0x10,%esp
80105ad2:	85 c0                	test   %eax,%eax
80105ad4:	79 07                	jns    80105add <sys_close+0x26>
    return -1;
80105ad6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105adb:	eb 27                	jmp    80105b04 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105add:	e8 4e df ff ff       	call   80103a30 <myproc>
80105ae2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ae5:	83 c2 08             	add    $0x8,%edx
80105ae8:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105aef:	00 
  fileclose(f);
80105af0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af3:	83 ec 0c             	sub    $0xc,%esp
80105af6:	50                   	push   %eax
80105af7:	e8 a9 b5 ff ff       	call   801010a5 <fileclose>
80105afc:	83 c4 10             	add    $0x10,%esp
  return 0;
80105aff:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b04:	c9                   	leave
80105b05:	c3                   	ret

80105b06 <sys_fstat>:

int
sys_fstat(void)
{
80105b06:	55                   	push   %ebp
80105b07:	89 e5                	mov    %esp,%ebp
80105b09:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105b0c:	83 ec 04             	sub    $0x4,%esp
80105b0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b12:	50                   	push   %eax
80105b13:	6a 00                	push   $0x0
80105b15:	6a 00                	push   $0x0
80105b17:	e8 ac fd ff ff       	call   801058c8 <argfd>
80105b1c:	83 c4 10             	add    $0x10,%esp
80105b1f:	85 c0                	test   %eax,%eax
80105b21:	78 17                	js     80105b3a <sys_fstat+0x34>
80105b23:	83 ec 04             	sub    $0x4,%esp
80105b26:	6a 14                	push   $0x14
80105b28:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b2b:	50                   	push   %eax
80105b2c:	6a 01                	push   $0x1
80105b2e:	e8 78 fc ff ff       	call   801057ab <argptr>
80105b33:	83 c4 10             	add    $0x10,%esp
80105b36:	85 c0                	test   %eax,%eax
80105b38:	79 07                	jns    80105b41 <sys_fstat+0x3b>
    return -1;
80105b3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b3f:	eb 13                	jmp    80105b54 <sys_fstat+0x4e>
  return filestat(f, st);
80105b41:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b47:	83 ec 08             	sub    $0x8,%esp
80105b4a:	52                   	push   %edx
80105b4b:	50                   	push   %eax
80105b4c:	e8 3c b6 ff ff       	call   8010118d <filestat>
80105b51:	83 c4 10             	add    $0x10,%esp
}
80105b54:	c9                   	leave
80105b55:	c3                   	ret

80105b56 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105b56:	55                   	push   %ebp
80105b57:	89 e5                	mov    %esp,%ebp
80105b59:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105b5c:	83 ec 08             	sub    $0x8,%esp
80105b5f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105b62:	50                   	push   %eax
80105b63:	6a 00                	push   $0x0
80105b65:	e8 a9 fc ff ff       	call   80105813 <argstr>
80105b6a:	83 c4 10             	add    $0x10,%esp
80105b6d:	85 c0                	test   %eax,%eax
80105b6f:	78 15                	js     80105b86 <sys_link+0x30>
80105b71:	83 ec 08             	sub    $0x8,%esp
80105b74:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105b77:	50                   	push   %eax
80105b78:	6a 01                	push   $0x1
80105b7a:	e8 94 fc ff ff       	call   80105813 <argstr>
80105b7f:	83 c4 10             	add    $0x10,%esp
80105b82:	85 c0                	test   %eax,%eax
80105b84:	79 0a                	jns    80105b90 <sys_link+0x3a>
    return -1;
80105b86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b8b:	e9 68 01 00 00       	jmp    80105cf8 <sys_link+0x1a2>

  begin_op();
80105b90:	e8 a9 d4 ff ff       	call   8010303e <begin_op>
  if((ip = namei(old)) == 0){
80105b95:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105b98:	83 ec 0c             	sub    $0xc,%esp
80105b9b:	50                   	push   %eax
80105b9c:	e8 84 c9 ff ff       	call   80102525 <namei>
80105ba1:	83 c4 10             	add    $0x10,%esp
80105ba4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ba7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bab:	75 0f                	jne    80105bbc <sys_link+0x66>
    end_op();
80105bad:	e8 18 d5 ff ff       	call   801030ca <end_op>
    return -1;
80105bb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb7:	e9 3c 01 00 00       	jmp    80105cf8 <sys_link+0x1a2>
  }

  ilock(ip);
80105bbc:	83 ec 0c             	sub    $0xc,%esp
80105bbf:	ff 75 f4             	push   -0xc(%ebp)
80105bc2:	e8 2b be ff ff       	call   801019f2 <ilock>
80105bc7:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bcd:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105bd1:	66 83 f8 01          	cmp    $0x1,%ax
80105bd5:	75 1d                	jne    80105bf4 <sys_link+0x9e>
    iunlockput(ip);
80105bd7:	83 ec 0c             	sub    $0xc,%esp
80105bda:	ff 75 f4             	push   -0xc(%ebp)
80105bdd:	e8 41 c0 ff ff       	call   80101c23 <iunlockput>
80105be2:	83 c4 10             	add    $0x10,%esp
    end_op();
80105be5:	e8 e0 d4 ff ff       	call   801030ca <end_op>
    return -1;
80105bea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bef:	e9 04 01 00 00       	jmp    80105cf8 <sys_link+0x1a2>
  }

  ip->nlink++;
80105bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105bfb:	83 c0 01             	add    $0x1,%eax
80105bfe:	89 c2                	mov    %eax,%edx
80105c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c03:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105c07:	83 ec 0c             	sub    $0xc,%esp
80105c0a:	ff 75 f4             	push   -0xc(%ebp)
80105c0d:	e8 03 bc ff ff       	call   80101815 <iupdate>
80105c12:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105c15:	83 ec 0c             	sub    $0xc,%esp
80105c18:	ff 75 f4             	push   -0xc(%ebp)
80105c1b:	e8 e5 be ff ff       	call   80101b05 <iunlock>
80105c20:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105c23:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c26:	83 ec 08             	sub    $0x8,%esp
80105c29:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105c2c:	52                   	push   %edx
80105c2d:	50                   	push   %eax
80105c2e:	e8 0e c9 ff ff       	call   80102541 <nameiparent>
80105c33:	83 c4 10             	add    $0x10,%esp
80105c36:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c39:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c3d:	74 71                	je     80105cb0 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105c3f:	83 ec 0c             	sub    $0xc,%esp
80105c42:	ff 75 f0             	push   -0x10(%ebp)
80105c45:	e8 a8 bd ff ff       	call   801019f2 <ilock>
80105c4a:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105c4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c50:	8b 10                	mov    (%eax),%edx
80105c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c55:	8b 00                	mov    (%eax),%eax
80105c57:	39 c2                	cmp    %eax,%edx
80105c59:	75 1d                	jne    80105c78 <sys_link+0x122>
80105c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5e:	8b 40 04             	mov    0x4(%eax),%eax
80105c61:	83 ec 04             	sub    $0x4,%esp
80105c64:	50                   	push   %eax
80105c65:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105c68:	50                   	push   %eax
80105c69:	ff 75 f0             	push   -0x10(%ebp)
80105c6c:	e8 1d c6 ff ff       	call   8010228e <dirlink>
80105c71:	83 c4 10             	add    $0x10,%esp
80105c74:	85 c0                	test   %eax,%eax
80105c76:	79 10                	jns    80105c88 <sys_link+0x132>
    iunlockput(dp);
80105c78:	83 ec 0c             	sub    $0xc,%esp
80105c7b:	ff 75 f0             	push   -0x10(%ebp)
80105c7e:	e8 a0 bf ff ff       	call   80101c23 <iunlockput>
80105c83:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105c86:	eb 29                	jmp    80105cb1 <sys_link+0x15b>
  }
  iunlockput(dp);
80105c88:	83 ec 0c             	sub    $0xc,%esp
80105c8b:	ff 75 f0             	push   -0x10(%ebp)
80105c8e:	e8 90 bf ff ff       	call   80101c23 <iunlockput>
80105c93:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105c96:	83 ec 0c             	sub    $0xc,%esp
80105c99:	ff 75 f4             	push   -0xc(%ebp)
80105c9c:	e8 b2 be ff ff       	call   80101b53 <iput>
80105ca1:	83 c4 10             	add    $0x10,%esp

  end_op();
80105ca4:	e8 21 d4 ff ff       	call   801030ca <end_op>

  return 0;
80105ca9:	b8 00 00 00 00       	mov    $0x0,%eax
80105cae:	eb 48                	jmp    80105cf8 <sys_link+0x1a2>
    goto bad;
80105cb0:	90                   	nop

bad:
  ilock(ip);
80105cb1:	83 ec 0c             	sub    $0xc,%esp
80105cb4:	ff 75 f4             	push   -0xc(%ebp)
80105cb7:	e8 36 bd ff ff       	call   801019f2 <ilock>
80105cbc:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105cc6:	83 e8 01             	sub    $0x1,%eax
80105cc9:	89 c2                	mov    %eax,%edx
80105ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cce:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105cd2:	83 ec 0c             	sub    $0xc,%esp
80105cd5:	ff 75 f4             	push   -0xc(%ebp)
80105cd8:	e8 38 bb ff ff       	call   80101815 <iupdate>
80105cdd:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105ce0:	83 ec 0c             	sub    $0xc,%esp
80105ce3:	ff 75 f4             	push   -0xc(%ebp)
80105ce6:	e8 38 bf ff ff       	call   80101c23 <iunlockput>
80105ceb:	83 c4 10             	add    $0x10,%esp
  end_op();
80105cee:	e8 d7 d3 ff ff       	call   801030ca <end_op>
  return -1;
80105cf3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105cf8:	c9                   	leave
80105cf9:	c3                   	ret

80105cfa <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105cfa:	55                   	push   %ebp
80105cfb:	89 e5                	mov    %esp,%ebp
80105cfd:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d00:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105d07:	eb 40                	jmp    80105d49 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d0c:	6a 10                	push   $0x10
80105d0e:	50                   	push   %eax
80105d0f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d12:	50                   	push   %eax
80105d13:	ff 75 08             	push   0x8(%ebp)
80105d16:	e8 c3 c1 ff ff       	call   80101ede <readi>
80105d1b:	83 c4 10             	add    $0x10,%esp
80105d1e:	83 f8 10             	cmp    $0x10,%eax
80105d21:	74 0d                	je     80105d30 <isdirempty+0x36>
      panic("isdirempty: readi");
80105d23:	83 ec 0c             	sub    $0xc,%esp
80105d26:	68 3d b1 10 80       	push   $0x8010b13d
80105d2b:	e8 79 a8 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105d30:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105d34:	66 85 c0             	test   %ax,%ax
80105d37:	74 07                	je     80105d40 <isdirempty+0x46>
      return 0;
80105d39:	b8 00 00 00 00       	mov    $0x0,%eax
80105d3e:	eb 1b                	jmp    80105d5b <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d43:	83 c0 10             	add    $0x10,%eax
80105d46:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d49:	8b 45 08             	mov    0x8(%ebp),%eax
80105d4c:	8b 40 58             	mov    0x58(%eax),%eax
80105d4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d52:	39 c2                	cmp    %eax,%edx
80105d54:	72 b3                	jb     80105d09 <isdirempty+0xf>
  }
  return 1;
80105d56:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105d5b:	c9                   	leave
80105d5c:	c3                   	ret

80105d5d <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105d5d:	55                   	push   %ebp
80105d5e:	89 e5                	mov    %esp,%ebp
80105d60:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105d63:	83 ec 08             	sub    $0x8,%esp
80105d66:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105d69:	50                   	push   %eax
80105d6a:	6a 00                	push   $0x0
80105d6c:	e8 a2 fa ff ff       	call   80105813 <argstr>
80105d71:	83 c4 10             	add    $0x10,%esp
80105d74:	85 c0                	test   %eax,%eax
80105d76:	79 0a                	jns    80105d82 <sys_unlink+0x25>
    return -1;
80105d78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d7d:	e9 bf 01 00 00       	jmp    80105f41 <sys_unlink+0x1e4>

  begin_op();
80105d82:	e8 b7 d2 ff ff       	call   8010303e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105d87:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105d8a:	83 ec 08             	sub    $0x8,%esp
80105d8d:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105d90:	52                   	push   %edx
80105d91:	50                   	push   %eax
80105d92:	e8 aa c7 ff ff       	call   80102541 <nameiparent>
80105d97:	83 c4 10             	add    $0x10,%esp
80105d9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d9d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105da1:	75 0f                	jne    80105db2 <sys_unlink+0x55>
    end_op();
80105da3:	e8 22 d3 ff ff       	call   801030ca <end_op>
    return -1;
80105da8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dad:	e9 8f 01 00 00       	jmp    80105f41 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105db2:	83 ec 0c             	sub    $0xc,%esp
80105db5:	ff 75 f4             	push   -0xc(%ebp)
80105db8:	e8 35 bc ff ff       	call   801019f2 <ilock>
80105dbd:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105dc0:	83 ec 08             	sub    $0x8,%esp
80105dc3:	68 4f b1 10 80       	push   $0x8010b14f
80105dc8:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105dcb:	50                   	push   %eax
80105dcc:	e8 e8 c3 ff ff       	call   801021b9 <namecmp>
80105dd1:	83 c4 10             	add    $0x10,%esp
80105dd4:	85 c0                	test   %eax,%eax
80105dd6:	0f 84 49 01 00 00    	je     80105f25 <sys_unlink+0x1c8>
80105ddc:	83 ec 08             	sub    $0x8,%esp
80105ddf:	68 51 b1 10 80       	push   $0x8010b151
80105de4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105de7:	50                   	push   %eax
80105de8:	e8 cc c3 ff ff       	call   801021b9 <namecmp>
80105ded:	83 c4 10             	add    $0x10,%esp
80105df0:	85 c0                	test   %eax,%eax
80105df2:	0f 84 2d 01 00 00    	je     80105f25 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105df8:	83 ec 04             	sub    $0x4,%esp
80105dfb:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105dfe:	50                   	push   %eax
80105dff:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e02:	50                   	push   %eax
80105e03:	ff 75 f4             	push   -0xc(%ebp)
80105e06:	e8 c9 c3 ff ff       	call   801021d4 <dirlookup>
80105e0b:	83 c4 10             	add    $0x10,%esp
80105e0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e11:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e15:	0f 84 0d 01 00 00    	je     80105f28 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105e1b:	83 ec 0c             	sub    $0xc,%esp
80105e1e:	ff 75 f0             	push   -0x10(%ebp)
80105e21:	e8 cc bb ff ff       	call   801019f2 <ilock>
80105e26:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e2c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e30:	66 85 c0             	test   %ax,%ax
80105e33:	7f 0d                	jg     80105e42 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105e35:	83 ec 0c             	sub    $0xc,%esp
80105e38:	68 54 b1 10 80       	push   $0x8010b154
80105e3d:	e8 67 a7 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105e42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e45:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e49:	66 83 f8 01          	cmp    $0x1,%ax
80105e4d:	75 25                	jne    80105e74 <sys_unlink+0x117>
80105e4f:	83 ec 0c             	sub    $0xc,%esp
80105e52:	ff 75 f0             	push   -0x10(%ebp)
80105e55:	e8 a0 fe ff ff       	call   80105cfa <isdirempty>
80105e5a:	83 c4 10             	add    $0x10,%esp
80105e5d:	85 c0                	test   %eax,%eax
80105e5f:	75 13                	jne    80105e74 <sys_unlink+0x117>
    iunlockput(ip);
80105e61:	83 ec 0c             	sub    $0xc,%esp
80105e64:	ff 75 f0             	push   -0x10(%ebp)
80105e67:	e8 b7 bd ff ff       	call   80101c23 <iunlockput>
80105e6c:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105e6f:	e9 b5 00 00 00       	jmp    80105f29 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105e74:	83 ec 04             	sub    $0x4,%esp
80105e77:	6a 10                	push   $0x10
80105e79:	6a 00                	push   $0x0
80105e7b:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e7e:	50                   	push   %eax
80105e7f:	e8 cf f5 ff ff       	call   80105453 <memset>
80105e84:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e87:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105e8a:	6a 10                	push   $0x10
80105e8c:	50                   	push   %eax
80105e8d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e90:	50                   	push   %eax
80105e91:	ff 75 f4             	push   -0xc(%ebp)
80105e94:	e8 9a c1 ff ff       	call   80102033 <writei>
80105e99:	83 c4 10             	add    $0x10,%esp
80105e9c:	83 f8 10             	cmp    $0x10,%eax
80105e9f:	74 0d                	je     80105eae <sys_unlink+0x151>
    panic("unlink: writei");
80105ea1:	83 ec 0c             	sub    $0xc,%esp
80105ea4:	68 66 b1 10 80       	push   $0x8010b166
80105ea9:	e8 fb a6 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
80105eae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105eb5:	66 83 f8 01          	cmp    $0x1,%ax
80105eb9:	75 21                	jne    80105edc <sys_unlink+0x17f>
    dp->nlink--;
80105ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ebe:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ec2:	83 e8 01             	sub    $0x1,%eax
80105ec5:	89 c2                	mov    %eax,%edx
80105ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eca:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105ece:	83 ec 0c             	sub    $0xc,%esp
80105ed1:	ff 75 f4             	push   -0xc(%ebp)
80105ed4:	e8 3c b9 ff ff       	call   80101815 <iupdate>
80105ed9:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105edc:	83 ec 0c             	sub    $0xc,%esp
80105edf:	ff 75 f4             	push   -0xc(%ebp)
80105ee2:	e8 3c bd ff ff       	call   80101c23 <iunlockput>
80105ee7:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eed:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ef1:	83 e8 01             	sub    $0x1,%eax
80105ef4:	89 c2                	mov    %eax,%edx
80105ef6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef9:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105efd:	83 ec 0c             	sub    $0xc,%esp
80105f00:	ff 75 f0             	push   -0x10(%ebp)
80105f03:	e8 0d b9 ff ff       	call   80101815 <iupdate>
80105f08:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105f0b:	83 ec 0c             	sub    $0xc,%esp
80105f0e:	ff 75 f0             	push   -0x10(%ebp)
80105f11:	e8 0d bd ff ff       	call   80101c23 <iunlockput>
80105f16:	83 c4 10             	add    $0x10,%esp

  end_op();
80105f19:	e8 ac d1 ff ff       	call   801030ca <end_op>

  return 0;
80105f1e:	b8 00 00 00 00       	mov    $0x0,%eax
80105f23:	eb 1c                	jmp    80105f41 <sys_unlink+0x1e4>
    goto bad;
80105f25:	90                   	nop
80105f26:	eb 01                	jmp    80105f29 <sys_unlink+0x1cc>
    goto bad;
80105f28:	90                   	nop

bad:
  iunlockput(dp);
80105f29:	83 ec 0c             	sub    $0xc,%esp
80105f2c:	ff 75 f4             	push   -0xc(%ebp)
80105f2f:	e8 ef bc ff ff       	call   80101c23 <iunlockput>
80105f34:	83 c4 10             	add    $0x10,%esp
  end_op();
80105f37:	e8 8e d1 ff ff       	call   801030ca <end_op>
  return -1;
80105f3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f41:	c9                   	leave
80105f42:	c3                   	ret

80105f43 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105f43:	55                   	push   %ebp
80105f44:	89 e5                	mov    %esp,%ebp
80105f46:	83 ec 38             	sub    $0x38,%esp
80105f49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105f4c:	8b 55 10             	mov    0x10(%ebp),%edx
80105f4f:	8b 45 14             	mov    0x14(%ebp),%eax
80105f52:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105f56:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105f5a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105f5e:	83 ec 08             	sub    $0x8,%esp
80105f61:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f64:	50                   	push   %eax
80105f65:	ff 75 08             	push   0x8(%ebp)
80105f68:	e8 d4 c5 ff ff       	call   80102541 <nameiparent>
80105f6d:	83 c4 10             	add    $0x10,%esp
80105f70:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f77:	75 0a                	jne    80105f83 <create+0x40>
    return 0;
80105f79:	b8 00 00 00 00       	mov    $0x0,%eax
80105f7e:	e9 90 01 00 00       	jmp    80106113 <create+0x1d0>
  ilock(dp);
80105f83:	83 ec 0c             	sub    $0xc,%esp
80105f86:	ff 75 f4             	push   -0xc(%ebp)
80105f89:	e8 64 ba ff ff       	call   801019f2 <ilock>
80105f8e:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105f91:	83 ec 04             	sub    $0x4,%esp
80105f94:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f97:	50                   	push   %eax
80105f98:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f9b:	50                   	push   %eax
80105f9c:	ff 75 f4             	push   -0xc(%ebp)
80105f9f:	e8 30 c2 ff ff       	call   801021d4 <dirlookup>
80105fa4:	83 c4 10             	add    $0x10,%esp
80105fa7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105faa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fae:	74 50                	je     80106000 <create+0xbd>
    iunlockput(dp);
80105fb0:	83 ec 0c             	sub    $0xc,%esp
80105fb3:	ff 75 f4             	push   -0xc(%ebp)
80105fb6:	e8 68 bc ff ff       	call   80101c23 <iunlockput>
80105fbb:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105fbe:	83 ec 0c             	sub    $0xc,%esp
80105fc1:	ff 75 f0             	push   -0x10(%ebp)
80105fc4:	e8 29 ba ff ff       	call   801019f2 <ilock>
80105fc9:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105fcc:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105fd1:	75 15                	jne    80105fe8 <create+0xa5>
80105fd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105fda:	66 83 f8 02          	cmp    $0x2,%ax
80105fde:	75 08                	jne    80105fe8 <create+0xa5>
      return ip;
80105fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe3:	e9 2b 01 00 00       	jmp    80106113 <create+0x1d0>
    iunlockput(ip);
80105fe8:	83 ec 0c             	sub    $0xc,%esp
80105feb:	ff 75 f0             	push   -0x10(%ebp)
80105fee:	e8 30 bc ff ff       	call   80101c23 <iunlockput>
80105ff3:	83 c4 10             	add    $0x10,%esp
    return 0;
80105ff6:	b8 00 00 00 00       	mov    $0x0,%eax
80105ffb:	e9 13 01 00 00       	jmp    80106113 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106000:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106004:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106007:	8b 00                	mov    (%eax),%eax
80106009:	83 ec 08             	sub    $0x8,%esp
8010600c:	52                   	push   %edx
8010600d:	50                   	push   %eax
8010600e:	e8 2c b7 ff ff       	call   8010173f <ialloc>
80106013:	83 c4 10             	add    $0x10,%esp
80106016:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106019:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010601d:	75 0d                	jne    8010602c <create+0xe9>
    panic("create: ialloc");
8010601f:	83 ec 0c             	sub    $0xc,%esp
80106022:	68 75 b1 10 80       	push   $0x8010b175
80106027:	e8 7d a5 ff ff       	call   801005a9 <panic>

  ilock(ip);
8010602c:	83 ec 0c             	sub    $0xc,%esp
8010602f:	ff 75 f0             	push   -0x10(%ebp)
80106032:	e8 bb b9 ff ff       	call   801019f2 <ilock>
80106037:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010603a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603d:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106041:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80106045:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106048:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010604c:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80106050:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106053:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106059:	83 ec 0c             	sub    $0xc,%esp
8010605c:	ff 75 f0             	push   -0x10(%ebp)
8010605f:	e8 b1 b7 ff ff       	call   80101815 <iupdate>
80106064:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106067:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010606c:	75 6a                	jne    801060d8 <create+0x195>
    dp->nlink++;  // for ".."
8010606e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106071:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106075:	83 c0 01             	add    $0x1,%eax
80106078:	89 c2                	mov    %eax,%edx
8010607a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010607d:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106081:	83 ec 0c             	sub    $0xc,%esp
80106084:	ff 75 f4             	push   -0xc(%ebp)
80106087:	e8 89 b7 ff ff       	call   80101815 <iupdate>
8010608c:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010608f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106092:	8b 40 04             	mov    0x4(%eax),%eax
80106095:	83 ec 04             	sub    $0x4,%esp
80106098:	50                   	push   %eax
80106099:	68 4f b1 10 80       	push   $0x8010b14f
8010609e:	ff 75 f0             	push   -0x10(%ebp)
801060a1:	e8 e8 c1 ff ff       	call   8010228e <dirlink>
801060a6:	83 c4 10             	add    $0x10,%esp
801060a9:	85 c0                	test   %eax,%eax
801060ab:	78 1e                	js     801060cb <create+0x188>
801060ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b0:	8b 40 04             	mov    0x4(%eax),%eax
801060b3:	83 ec 04             	sub    $0x4,%esp
801060b6:	50                   	push   %eax
801060b7:	68 51 b1 10 80       	push   $0x8010b151
801060bc:	ff 75 f0             	push   -0x10(%ebp)
801060bf:	e8 ca c1 ff ff       	call   8010228e <dirlink>
801060c4:	83 c4 10             	add    $0x10,%esp
801060c7:	85 c0                	test   %eax,%eax
801060c9:	79 0d                	jns    801060d8 <create+0x195>
      panic("create dots");
801060cb:	83 ec 0c             	sub    $0xc,%esp
801060ce:	68 84 b1 10 80       	push   $0x8010b184
801060d3:	e8 d1 a4 ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801060d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060db:	8b 40 04             	mov    0x4(%eax),%eax
801060de:	83 ec 04             	sub    $0x4,%esp
801060e1:	50                   	push   %eax
801060e2:	8d 45 de             	lea    -0x22(%ebp),%eax
801060e5:	50                   	push   %eax
801060e6:	ff 75 f4             	push   -0xc(%ebp)
801060e9:	e8 a0 c1 ff ff       	call   8010228e <dirlink>
801060ee:	83 c4 10             	add    $0x10,%esp
801060f1:	85 c0                	test   %eax,%eax
801060f3:	79 0d                	jns    80106102 <create+0x1bf>
    panic("create: dirlink");
801060f5:	83 ec 0c             	sub    $0xc,%esp
801060f8:	68 90 b1 10 80       	push   $0x8010b190
801060fd:	e8 a7 a4 ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80106102:	83 ec 0c             	sub    $0xc,%esp
80106105:	ff 75 f4             	push   -0xc(%ebp)
80106108:	e8 16 bb ff ff       	call   80101c23 <iunlockput>
8010610d:	83 c4 10             	add    $0x10,%esp

  return ip;
80106110:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106113:	c9                   	leave
80106114:	c3                   	ret

80106115 <sys_open>:

int
sys_open(void)
{
80106115:	55                   	push   %ebp
80106116:	89 e5                	mov    %esp,%ebp
80106118:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010611b:	83 ec 08             	sub    $0x8,%esp
8010611e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106121:	50                   	push   %eax
80106122:	6a 00                	push   $0x0
80106124:	e8 ea f6 ff ff       	call   80105813 <argstr>
80106129:	83 c4 10             	add    $0x10,%esp
8010612c:	85 c0                	test   %eax,%eax
8010612e:	78 15                	js     80106145 <sys_open+0x30>
80106130:	83 ec 08             	sub    $0x8,%esp
80106133:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106136:	50                   	push   %eax
80106137:	6a 01                	push   $0x1
80106139:	e8 40 f6 ff ff       	call   8010577e <argint>
8010613e:	83 c4 10             	add    $0x10,%esp
80106141:	85 c0                	test   %eax,%eax
80106143:	79 0a                	jns    8010614f <sys_open+0x3a>
    return -1;
80106145:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010614a:	e9 61 01 00 00       	jmp    801062b0 <sys_open+0x19b>

  begin_op();
8010614f:	e8 ea ce ff ff       	call   8010303e <begin_op>

  if(omode & O_CREATE){
80106154:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106157:	25 00 02 00 00       	and    $0x200,%eax
8010615c:	85 c0                	test   %eax,%eax
8010615e:	74 2a                	je     8010618a <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106160:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106163:	6a 00                	push   $0x0
80106165:	6a 00                	push   $0x0
80106167:	6a 02                	push   $0x2
80106169:	50                   	push   %eax
8010616a:	e8 d4 fd ff ff       	call   80105f43 <create>
8010616f:	83 c4 10             	add    $0x10,%esp
80106172:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106175:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106179:	75 75                	jne    801061f0 <sys_open+0xdb>
      end_op();
8010617b:	e8 4a cf ff ff       	call   801030ca <end_op>
      return -1;
80106180:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106185:	e9 26 01 00 00       	jmp    801062b0 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010618a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010618d:	83 ec 0c             	sub    $0xc,%esp
80106190:	50                   	push   %eax
80106191:	e8 8f c3 ff ff       	call   80102525 <namei>
80106196:	83 c4 10             	add    $0x10,%esp
80106199:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010619c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061a0:	75 0f                	jne    801061b1 <sys_open+0x9c>
      end_op();
801061a2:	e8 23 cf ff ff       	call   801030ca <end_op>
      return -1;
801061a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061ac:	e9 ff 00 00 00       	jmp    801062b0 <sys_open+0x19b>
    }
    ilock(ip);
801061b1:	83 ec 0c             	sub    $0xc,%esp
801061b4:	ff 75 f4             	push   -0xc(%ebp)
801061b7:	e8 36 b8 ff ff       	call   801019f2 <ilock>
801061bc:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801061bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061c2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801061c6:	66 83 f8 01          	cmp    $0x1,%ax
801061ca:	75 24                	jne    801061f0 <sys_open+0xdb>
801061cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061cf:	85 c0                	test   %eax,%eax
801061d1:	74 1d                	je     801061f0 <sys_open+0xdb>
      iunlockput(ip);
801061d3:	83 ec 0c             	sub    $0xc,%esp
801061d6:	ff 75 f4             	push   -0xc(%ebp)
801061d9:	e8 45 ba ff ff       	call   80101c23 <iunlockput>
801061de:	83 c4 10             	add    $0x10,%esp
      end_op();
801061e1:	e8 e4 ce ff ff       	call   801030ca <end_op>
      return -1;
801061e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061eb:	e9 c0 00 00 00       	jmp    801062b0 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801061f0:	e8 f2 ad ff ff       	call   80100fe7 <filealloc>
801061f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061fc:	74 17                	je     80106215 <sys_open+0x100>
801061fe:	83 ec 0c             	sub    $0xc,%esp
80106201:	ff 75 f0             	push   -0x10(%ebp)
80106204:	e8 33 f7 ff ff       	call   8010593c <fdalloc>
80106209:	83 c4 10             	add    $0x10,%esp
8010620c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010620f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106213:	79 2e                	jns    80106243 <sys_open+0x12e>
    if(f)
80106215:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106219:	74 0e                	je     80106229 <sys_open+0x114>
      fileclose(f);
8010621b:	83 ec 0c             	sub    $0xc,%esp
8010621e:	ff 75 f0             	push   -0x10(%ebp)
80106221:	e8 7f ae ff ff       	call   801010a5 <fileclose>
80106226:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106229:	83 ec 0c             	sub    $0xc,%esp
8010622c:	ff 75 f4             	push   -0xc(%ebp)
8010622f:	e8 ef b9 ff ff       	call   80101c23 <iunlockput>
80106234:	83 c4 10             	add    $0x10,%esp
    end_op();
80106237:	e8 8e ce ff ff       	call   801030ca <end_op>
    return -1;
8010623c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106241:	eb 6d                	jmp    801062b0 <sys_open+0x19b>
  }
  iunlock(ip);
80106243:	83 ec 0c             	sub    $0xc,%esp
80106246:	ff 75 f4             	push   -0xc(%ebp)
80106249:	e8 b7 b8 ff ff       	call   80101b05 <iunlock>
8010624e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106251:	e8 74 ce ff ff       	call   801030ca <end_op>

  f->type = FD_INODE;
80106256:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106259:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010625f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106262:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106265:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106268:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010626b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106272:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106275:	83 e0 01             	and    $0x1,%eax
80106278:	85 c0                	test   %eax,%eax
8010627a:	0f 94 c0             	sete   %al
8010627d:	89 c2                	mov    %eax,%edx
8010627f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106282:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106285:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106288:	83 e0 01             	and    $0x1,%eax
8010628b:	85 c0                	test   %eax,%eax
8010628d:	75 0a                	jne    80106299 <sys_open+0x184>
8010628f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106292:	83 e0 02             	and    $0x2,%eax
80106295:	85 c0                	test   %eax,%eax
80106297:	74 07                	je     801062a0 <sys_open+0x18b>
80106299:	b8 01 00 00 00       	mov    $0x1,%eax
8010629e:	eb 05                	jmp    801062a5 <sys_open+0x190>
801062a0:	b8 00 00 00 00       	mov    $0x0,%eax
801062a5:	89 c2                	mov    %eax,%edx
801062a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062aa:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801062ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801062b0:	c9                   	leave
801062b1:	c3                   	ret

801062b2 <sys_mkdir>:

int
sys_mkdir(void)
{
801062b2:	55                   	push   %ebp
801062b3:	89 e5                	mov    %esp,%ebp
801062b5:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801062b8:	e8 81 cd ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801062bd:	83 ec 08             	sub    $0x8,%esp
801062c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062c3:	50                   	push   %eax
801062c4:	6a 00                	push   $0x0
801062c6:	e8 48 f5 ff ff       	call   80105813 <argstr>
801062cb:	83 c4 10             	add    $0x10,%esp
801062ce:	85 c0                	test   %eax,%eax
801062d0:	78 1b                	js     801062ed <sys_mkdir+0x3b>
801062d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062d5:	6a 00                	push   $0x0
801062d7:	6a 00                	push   $0x0
801062d9:	6a 01                	push   $0x1
801062db:	50                   	push   %eax
801062dc:	e8 62 fc ff ff       	call   80105f43 <create>
801062e1:	83 c4 10             	add    $0x10,%esp
801062e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062eb:	75 0c                	jne    801062f9 <sys_mkdir+0x47>
    end_op();
801062ed:	e8 d8 cd ff ff       	call   801030ca <end_op>
    return -1;
801062f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f7:	eb 18                	jmp    80106311 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801062f9:	83 ec 0c             	sub    $0xc,%esp
801062fc:	ff 75 f4             	push   -0xc(%ebp)
801062ff:	e8 1f b9 ff ff       	call   80101c23 <iunlockput>
80106304:	83 c4 10             	add    $0x10,%esp
  end_op();
80106307:	e8 be cd ff ff       	call   801030ca <end_op>
  return 0;
8010630c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106311:	c9                   	leave
80106312:	c3                   	ret

80106313 <sys_mknod>:

int
sys_mknod(void)
{
80106313:	55                   	push   %ebp
80106314:	89 e5                	mov    %esp,%ebp
80106316:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106319:	e8 20 cd ff ff       	call   8010303e <begin_op>
  if((argstr(0, &path)) < 0 ||
8010631e:	83 ec 08             	sub    $0x8,%esp
80106321:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106324:	50                   	push   %eax
80106325:	6a 00                	push   $0x0
80106327:	e8 e7 f4 ff ff       	call   80105813 <argstr>
8010632c:	83 c4 10             	add    $0x10,%esp
8010632f:	85 c0                	test   %eax,%eax
80106331:	78 4f                	js     80106382 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80106333:	83 ec 08             	sub    $0x8,%esp
80106336:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106339:	50                   	push   %eax
8010633a:	6a 01                	push   $0x1
8010633c:	e8 3d f4 ff ff       	call   8010577e <argint>
80106341:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80106344:	85 c0                	test   %eax,%eax
80106346:	78 3a                	js     80106382 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80106348:	83 ec 08             	sub    $0x8,%esp
8010634b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010634e:	50                   	push   %eax
8010634f:	6a 02                	push   $0x2
80106351:	e8 28 f4 ff ff       	call   8010577e <argint>
80106356:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80106359:	85 c0                	test   %eax,%eax
8010635b:	78 25                	js     80106382 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010635d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106360:	0f bf c8             	movswl %ax,%ecx
80106363:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106366:	0f bf d0             	movswl %ax,%edx
80106369:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010636c:	51                   	push   %ecx
8010636d:	52                   	push   %edx
8010636e:	6a 03                	push   $0x3
80106370:	50                   	push   %eax
80106371:	e8 cd fb ff ff       	call   80105f43 <create>
80106376:	83 c4 10             	add    $0x10,%esp
80106379:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
8010637c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106380:	75 0c                	jne    8010638e <sys_mknod+0x7b>
    end_op();
80106382:	e8 43 cd ff ff       	call   801030ca <end_op>
    return -1;
80106387:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010638c:	eb 18                	jmp    801063a6 <sys_mknod+0x93>
  }
  iunlockput(ip);
8010638e:	83 ec 0c             	sub    $0xc,%esp
80106391:	ff 75 f4             	push   -0xc(%ebp)
80106394:	e8 8a b8 ff ff       	call   80101c23 <iunlockput>
80106399:	83 c4 10             	add    $0x10,%esp
  end_op();
8010639c:	e8 29 cd ff ff       	call   801030ca <end_op>
  return 0;
801063a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063a6:	c9                   	leave
801063a7:	c3                   	ret

801063a8 <sys_chdir>:

int
sys_chdir(void)
{
801063a8:	55                   	push   %ebp
801063a9:	89 e5                	mov    %esp,%ebp
801063ab:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801063ae:	e8 7d d6 ff ff       	call   80103a30 <myproc>
801063b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801063b6:	e8 83 cc ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801063bb:	83 ec 08             	sub    $0x8,%esp
801063be:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063c1:	50                   	push   %eax
801063c2:	6a 00                	push   $0x0
801063c4:	e8 4a f4 ff ff       	call   80105813 <argstr>
801063c9:	83 c4 10             	add    $0x10,%esp
801063cc:	85 c0                	test   %eax,%eax
801063ce:	78 18                	js     801063e8 <sys_chdir+0x40>
801063d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801063d3:	83 ec 0c             	sub    $0xc,%esp
801063d6:	50                   	push   %eax
801063d7:	e8 49 c1 ff ff       	call   80102525 <namei>
801063dc:	83 c4 10             	add    $0x10,%esp
801063df:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063e6:	75 0c                	jne    801063f4 <sys_chdir+0x4c>
    end_op();
801063e8:	e8 dd cc ff ff       	call   801030ca <end_op>
    return -1;
801063ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f2:	eb 68                	jmp    8010645c <sys_chdir+0xb4>
  }
  ilock(ip);
801063f4:	83 ec 0c             	sub    $0xc,%esp
801063f7:	ff 75 f0             	push   -0x10(%ebp)
801063fa:	e8 f3 b5 ff ff       	call   801019f2 <ilock>
801063ff:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106402:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106405:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106409:	66 83 f8 01          	cmp    $0x1,%ax
8010640d:	74 1a                	je     80106429 <sys_chdir+0x81>
    iunlockput(ip);
8010640f:	83 ec 0c             	sub    $0xc,%esp
80106412:	ff 75 f0             	push   -0x10(%ebp)
80106415:	e8 09 b8 ff ff       	call   80101c23 <iunlockput>
8010641a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010641d:	e8 a8 cc ff ff       	call   801030ca <end_op>
    return -1;
80106422:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106427:	eb 33                	jmp    8010645c <sys_chdir+0xb4>
  }
  iunlock(ip);
80106429:	83 ec 0c             	sub    $0xc,%esp
8010642c:	ff 75 f0             	push   -0x10(%ebp)
8010642f:	e8 d1 b6 ff ff       	call   80101b05 <iunlock>
80106434:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80106437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010643a:	8b 40 68             	mov    0x68(%eax),%eax
8010643d:	83 ec 0c             	sub    $0xc,%esp
80106440:	50                   	push   %eax
80106441:	e8 0d b7 ff ff       	call   80101b53 <iput>
80106446:	83 c4 10             	add    $0x10,%esp
  end_op();
80106449:	e8 7c cc ff ff       	call   801030ca <end_op>
  curproc->cwd = ip;
8010644e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106451:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106454:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106457:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010645c:	c9                   	leave
8010645d:	c3                   	ret

8010645e <sys_exec>:

int
sys_exec(void)
{
8010645e:	55                   	push   %ebp
8010645f:	89 e5                	mov    %esp,%ebp
80106461:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106467:	83 ec 08             	sub    $0x8,%esp
8010646a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010646d:	50                   	push   %eax
8010646e:	6a 00                	push   $0x0
80106470:	e8 9e f3 ff ff       	call   80105813 <argstr>
80106475:	83 c4 10             	add    $0x10,%esp
80106478:	85 c0                	test   %eax,%eax
8010647a:	78 18                	js     80106494 <sys_exec+0x36>
8010647c:	83 ec 08             	sub    $0x8,%esp
8010647f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106485:	50                   	push   %eax
80106486:	6a 01                	push   $0x1
80106488:	e8 f1 f2 ff ff       	call   8010577e <argint>
8010648d:	83 c4 10             	add    $0x10,%esp
80106490:	85 c0                	test   %eax,%eax
80106492:	79 0a                	jns    8010649e <sys_exec+0x40>
    return -1;
80106494:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106499:	e9 c6 00 00 00       	jmp    80106564 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
8010649e:	83 ec 04             	sub    $0x4,%esp
801064a1:	68 80 00 00 00       	push   $0x80
801064a6:	6a 00                	push   $0x0
801064a8:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801064ae:	50                   	push   %eax
801064af:	e8 9f ef ff ff       	call   80105453 <memset>
801064b4:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801064b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801064be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c1:	83 f8 1f             	cmp    $0x1f,%eax
801064c4:	76 0a                	jbe    801064d0 <sys_exec+0x72>
      return -1;
801064c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064cb:	e9 94 00 00 00       	jmp    80106564 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801064d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d3:	c1 e0 02             	shl    $0x2,%eax
801064d6:	89 c2                	mov    %eax,%edx
801064d8:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801064de:	01 c2                	add    %eax,%edx
801064e0:	83 ec 08             	sub    $0x8,%esp
801064e3:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801064e9:	50                   	push   %eax
801064ea:	52                   	push   %edx
801064eb:	e8 ed f1 ff ff       	call   801056dd <fetchint>
801064f0:	83 c4 10             	add    $0x10,%esp
801064f3:	85 c0                	test   %eax,%eax
801064f5:	79 07                	jns    801064fe <sys_exec+0xa0>
      return -1;
801064f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064fc:	eb 66                	jmp    80106564 <sys_exec+0x106>
    if(uarg == 0){
801064fe:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106504:	85 c0                	test   %eax,%eax
80106506:	75 27                	jne    8010652f <sys_exec+0xd1>
      argv[i] = 0;
80106508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010650b:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106512:	00 00 00 00 
      break;
80106516:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106517:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010651a:	83 ec 08             	sub    $0x8,%esp
8010651d:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106523:	52                   	push   %edx
80106524:	50                   	push   %eax
80106525:	e8 60 a6 ff ff       	call   80100b8a <exec>
8010652a:	83 c4 10             	add    $0x10,%esp
8010652d:	eb 35                	jmp    80106564 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
8010652f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106535:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106538:	c1 e2 02             	shl    $0x2,%edx
8010653b:	01 c2                	add    %eax,%edx
8010653d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106543:	83 ec 08             	sub    $0x8,%esp
80106546:	52                   	push   %edx
80106547:	50                   	push   %eax
80106548:	e8 cf f1 ff ff       	call   8010571c <fetchstr>
8010654d:	83 c4 10             	add    $0x10,%esp
80106550:	85 c0                	test   %eax,%eax
80106552:	79 07                	jns    8010655b <sys_exec+0xfd>
      return -1;
80106554:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106559:	eb 09                	jmp    80106564 <sys_exec+0x106>
  for(i=0;; i++){
8010655b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
8010655f:	e9 5a ff ff ff       	jmp    801064be <sys_exec+0x60>
}
80106564:	c9                   	leave
80106565:	c3                   	ret

80106566 <sys_pipe>:

int
sys_pipe(void)
{
80106566:	55                   	push   %ebp
80106567:	89 e5                	mov    %esp,%ebp
80106569:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010656c:	83 ec 04             	sub    $0x4,%esp
8010656f:	6a 08                	push   $0x8
80106571:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106574:	50                   	push   %eax
80106575:	6a 00                	push   $0x0
80106577:	e8 2f f2 ff ff       	call   801057ab <argptr>
8010657c:	83 c4 10             	add    $0x10,%esp
8010657f:	85 c0                	test   %eax,%eax
80106581:	79 0a                	jns    8010658d <sys_pipe+0x27>
    return -1;
80106583:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106588:	e9 ae 00 00 00       	jmp    8010663b <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
8010658d:	83 ec 08             	sub    $0x8,%esp
80106590:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106593:	50                   	push   %eax
80106594:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106597:	50                   	push   %eax
80106598:	e8 d0 cf ff ff       	call   8010356d <pipealloc>
8010659d:	83 c4 10             	add    $0x10,%esp
801065a0:	85 c0                	test   %eax,%eax
801065a2:	79 0a                	jns    801065ae <sys_pipe+0x48>
    return -1;
801065a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065a9:	e9 8d 00 00 00       	jmp    8010663b <sys_pipe+0xd5>
  fd0 = -1;
801065ae:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801065b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801065b8:	83 ec 0c             	sub    $0xc,%esp
801065bb:	50                   	push   %eax
801065bc:	e8 7b f3 ff ff       	call   8010593c <fdalloc>
801065c1:	83 c4 10             	add    $0x10,%esp
801065c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065cb:	78 18                	js     801065e5 <sys_pipe+0x7f>
801065cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065d0:	83 ec 0c             	sub    $0xc,%esp
801065d3:	50                   	push   %eax
801065d4:	e8 63 f3 ff ff       	call   8010593c <fdalloc>
801065d9:	83 c4 10             	add    $0x10,%esp
801065dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065e3:	79 3e                	jns    80106623 <sys_pipe+0xbd>
    if(fd0 >= 0)
801065e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065e9:	78 13                	js     801065fe <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
801065eb:	e8 40 d4 ff ff       	call   80103a30 <myproc>
801065f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065f3:	83 c2 08             	add    $0x8,%edx
801065f6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801065fd:	00 
    fileclose(rf);
801065fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106601:	83 ec 0c             	sub    $0xc,%esp
80106604:	50                   	push   %eax
80106605:	e8 9b aa ff ff       	call   801010a5 <fileclose>
8010660a:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010660d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106610:	83 ec 0c             	sub    $0xc,%esp
80106613:	50                   	push   %eax
80106614:	e8 8c aa ff ff       	call   801010a5 <fileclose>
80106619:	83 c4 10             	add    $0x10,%esp
    return -1;
8010661c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106621:	eb 18                	jmp    8010663b <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80106623:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106626:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106629:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010662b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010662e:	8d 50 04             	lea    0x4(%eax),%edx
80106631:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106634:	89 02                	mov    %eax,(%edx)
  return 0;
80106636:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010663b:	c9                   	leave
8010663c:	c3                   	ret

8010663d <sys_getpinfo>:

#include "pstat.h"

int getpinfo(struct pstat *ps);

int sys_getpinfo(void) {
8010663d:	55                   	push   %ebp
8010663e:	89 e5                	mov    %esp,%ebp
80106640:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (char**)&ps, sizeof(struct pstat)) < 0)
80106643:	83 ec 04             	sub    $0x4,%esp
80106646:	68 00 0c 00 00       	push   $0xc00
8010664b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010664e:	50                   	push   %eax
8010664f:	6a 00                	push   $0x0
80106651:	e8 55 f1 ff ff       	call   801057ab <argptr>
80106656:	83 c4 10             	add    $0x10,%esp
80106659:	85 c0                	test   %eax,%eax
8010665b:	79 07                	jns    80106664 <sys_getpinfo+0x27>
    return -1;
8010665d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106662:	eb 0f                	jmp    80106673 <sys_getpinfo+0x36>
  return getpinfo(ps);
80106664:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106667:	83 ec 0c             	sub    $0xc,%esp
8010666a:	50                   	push   %eax
8010666b:	e8 6f e1 ff ff       	call   801047df <getpinfo>
80106670:	83 c4 10             	add    $0x10,%esp
}
80106673:	c9                   	leave
80106674:	c3                   	ret

80106675 <sys_setSchedPolicy>:

extern int set_sched_policy(int);
int
sys_setSchedPolicy(void)
{
80106675:	55                   	push   %ebp
80106676:	89 e5                	mov    %esp,%ebp
80106678:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if(argint(0, &policy) < 0)
8010667b:	83 ec 08             	sub    $0x8,%esp
8010667e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106681:	50                   	push   %eax
80106682:	6a 00                	push   $0x0
80106684:	e8 f5 f0 ff ff       	call   8010577e <argint>
80106689:	83 c4 10             	add    $0x10,%esp
8010668c:	85 c0                	test   %eax,%eax
8010668e:	79 07                	jns    80106697 <sys_setSchedPolicy+0x22>
    return -1;
80106690:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106695:	eb 23                	jmp    801066ba <sys_setSchedPolicy+0x45>
  cprintf("[SYSCALL] setSchedPolicy called with %d\n", policy);
80106697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010669a:	83 ec 08             	sub    $0x8,%esp
8010669d:	50                   	push   %eax
8010669e:	68 a0 b1 10 80       	push   $0x8010b1a0
801066a3:	e8 4c 9d ff ff       	call   801003f4 <cprintf>
801066a8:	83 c4 10             	add    $0x10,%esp
  return set_sched_policy(policy);
801066ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ae:	83 ec 0c             	sub    $0xc,%esp
801066b1:	50                   	push   %eax
801066b2:	e8 fc e2 ff ff       	call   801049b3 <set_sched_policy>
801066b7:	83 c4 10             	add    $0x10,%esp
}
801066ba:	c9                   	leave
801066bb:	c3                   	ret

801066bc <sys_getSchedPolicy>:

extern int get_sched_policy(void);

int
sys_getSchedPolicy(void)
{
801066bc:	55                   	push   %ebp
801066bd:	89 e5                	mov    %esp,%ebp
801066bf:	83 ec 08             	sub    $0x8,%esp
  return get_sched_policy();
801066c2:	e8 2f e3 ff ff       	call   801049f6 <get_sched_policy>
}
801066c7:	c9                   	leave
801066c8:	c3                   	ret

801066c9 <sys_yield>:
int
sys_yield(void)
{
801066c9:	55                   	push   %ebp
801066ca:	89 e5                	mov    %esp,%ebp
801066cc:	83 ec 08             	sub    $0x8,%esp
  yield(); // 커널 내부 yield 함수
801066cf:	e8 ef dd ff ff       	call   801044c3 <yield>
  return 0;
801066d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066d9:	c9                   	leave
801066da:	c3                   	ret

801066db <sys_fork>:

int
sys_fork(void)
{
801066db:	55                   	push   %ebp
801066dc:	89 e5                	mov    %esp,%ebp
801066de:	83 ec 08             	sub    $0x8,%esp
  return fork();
801066e1:	e8 06 d7 ff ff       	call   80103dec <fork>
}
801066e6:	c9                   	leave
801066e7:	c3                   	ret

801066e8 <sys_exit>:

int
sys_exit(void)
{
801066e8:	55                   	push   %ebp
801066e9:	89 e5                	mov    %esp,%ebp
801066eb:	83 ec 08             	sub    $0x8,%esp
  exit();
801066ee:	e8 13 d9 ff ff       	call   80104006 <exit>
  return 0;  // not reached
801066f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066f8:	c9                   	leave
801066f9:	c3                   	ret

801066fa <sys_wait>:

int
sys_wait(void)
{
801066fa:	55                   	push   %ebp
801066fb:	89 e5                	mov    %esp,%ebp
801066fd:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106700:	e8 43 da ff ff       	call   80104148 <wait>
}
80106705:	c9                   	leave
80106706:	c3                   	ret

80106707 <sys_kill>:

int
sys_kill(void)
{
80106707:	55                   	push   %ebp
80106708:	89 e5                	mov    %esp,%ebp
8010670a:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010670d:	83 ec 08             	sub    $0x8,%esp
80106710:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106713:	50                   	push   %eax
80106714:	6a 00                	push   $0x0
80106716:	e8 63 f0 ff ff       	call   8010577e <argint>
8010671b:	83 c4 10             	add    $0x10,%esp
8010671e:	85 c0                	test   %eax,%eax
80106720:	79 07                	jns    80106729 <sys_kill+0x22>
    return -1;
80106722:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106727:	eb 0f                	jmp    80106738 <sys_kill+0x31>
  return kill(pid);
80106729:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010672c:	83 ec 0c             	sub    $0xc,%esp
8010672f:	50                   	push   %eax
80106730:	e8 2c df ff ff       	call   80104661 <kill>
80106735:	83 c4 10             	add    $0x10,%esp
}
80106738:	c9                   	leave
80106739:	c3                   	ret

8010673a <sys_getpid>:

int
sys_getpid(void)
{
8010673a:	55                   	push   %ebp
8010673b:	89 e5                	mov    %esp,%ebp
8010673d:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106740:	e8 eb d2 ff ff       	call   80103a30 <myproc>
80106745:	8b 40 10             	mov    0x10(%eax),%eax
}
80106748:	c9                   	leave
80106749:	c3                   	ret

8010674a <sys_sbrk>:

int
sys_sbrk(void)
{
8010674a:	55                   	push   %ebp
8010674b:	89 e5                	mov    %esp,%ebp
8010674d:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106750:	83 ec 08             	sub    $0x8,%esp
80106753:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106756:	50                   	push   %eax
80106757:	6a 00                	push   $0x0
80106759:	e8 20 f0 ff ff       	call   8010577e <argint>
8010675e:	83 c4 10             	add    $0x10,%esp
80106761:	85 c0                	test   %eax,%eax
80106763:	79 07                	jns    8010676c <sys_sbrk+0x22>
    return -1;
80106765:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010676a:	eb 27                	jmp    80106793 <sys_sbrk+0x49>
  addr = myproc()->sz;
8010676c:	e8 bf d2 ff ff       	call   80103a30 <myproc>
80106771:	8b 00                	mov    (%eax),%eax
80106773:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106776:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106779:	83 ec 0c             	sub    $0xc,%esp
8010677c:	50                   	push   %eax
8010677d:	e8 cf d5 ff ff       	call   80103d51 <growproc>
80106782:	83 c4 10             	add    $0x10,%esp
80106785:	85 c0                	test   %eax,%eax
80106787:	79 07                	jns    80106790 <sys_sbrk+0x46>
    return -1;
80106789:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010678e:	eb 03                	jmp    80106793 <sys_sbrk+0x49>
  return addr;
80106790:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106793:	c9                   	leave
80106794:	c3                   	ret

80106795 <sys_sleep>:

int
sys_sleep(void)
{
80106795:	55                   	push   %ebp
80106796:	89 e5                	mov    %esp,%ebp
80106798:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010679b:	83 ec 08             	sub    $0x8,%esp
8010679e:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067a1:	50                   	push   %eax
801067a2:	6a 00                	push   $0x0
801067a4:	e8 d5 ef ff ff       	call   8010577e <argint>
801067a9:	83 c4 10             	add    $0x10,%esp
801067ac:	85 c0                	test   %eax,%eax
801067ae:	79 07                	jns    801067b7 <sys_sleep+0x22>
    return -1;
801067b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067b5:	eb 76                	jmp    8010682d <sys_sleep+0x98>
  acquire(&tickslock);
801067b7:	83 ec 0c             	sub    $0xc,%esp
801067ba:	68 60 79 19 80       	push   $0x80197960
801067bf:	e8 19 ea ff ff       	call   801051dd <acquire>
801067c4:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801067c7:	a1 94 79 19 80       	mov    0x80197994,%eax
801067cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801067cf:	eb 38                	jmp    80106809 <sys_sleep+0x74>
    if(myproc()->killed){
801067d1:	e8 5a d2 ff ff       	call   80103a30 <myproc>
801067d6:	8b 40 24             	mov    0x24(%eax),%eax
801067d9:	85 c0                	test   %eax,%eax
801067db:	74 17                	je     801067f4 <sys_sleep+0x5f>
      release(&tickslock);
801067dd:	83 ec 0c             	sub    $0xc,%esp
801067e0:	68 60 79 19 80       	push   $0x80197960
801067e5:	e8 61 ea ff ff       	call   8010524b <release>
801067ea:	83 c4 10             	add    $0x10,%esp
      return -1;
801067ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067f2:	eb 39                	jmp    8010682d <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
801067f4:	83 ec 08             	sub    $0x8,%esp
801067f7:	68 60 79 19 80       	push   $0x80197960
801067fc:	68 94 79 19 80       	push   $0x80197994
80106801:	e8 3d dd ff ff       	call   80104543 <sleep>
80106806:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106809:	a1 94 79 19 80       	mov    0x80197994,%eax
8010680e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106811:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106814:	39 d0                	cmp    %edx,%eax
80106816:	72 b9                	jb     801067d1 <sys_sleep+0x3c>
  }
  release(&tickslock);
80106818:	83 ec 0c             	sub    $0xc,%esp
8010681b:	68 60 79 19 80       	push   $0x80197960
80106820:	e8 26 ea ff ff       	call   8010524b <release>
80106825:	83 c4 10             	add    $0x10,%esp
  return 0;
80106828:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010682d:	c9                   	leave
8010682e:	c3                   	ret

8010682f <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010682f:	55                   	push   %ebp
80106830:	89 e5                	mov    %esp,%ebp
80106832:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106835:	83 ec 0c             	sub    $0xc,%esp
80106838:	68 60 79 19 80       	push   $0x80197960
8010683d:	e8 9b e9 ff ff       	call   801051dd <acquire>
80106842:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106845:	a1 94 79 19 80       	mov    0x80197994,%eax
8010684a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010684d:	83 ec 0c             	sub    $0xc,%esp
80106850:	68 60 79 19 80       	push   $0x80197960
80106855:	e8 f1 e9 ff ff       	call   8010524b <release>
8010685a:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010685d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106860:	c9                   	leave
80106861:	c3                   	ret

80106862 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106862:	1e                   	push   %ds
  pushl %es
80106863:	06                   	push   %es
  pushl %fs
80106864:	0f a0                	push   %fs
  pushl %gs
80106866:	0f a8                	push   %gs
  pushal
80106868:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106869:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010686d:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010686f:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106871:	54                   	push   %esp
  call trap
80106872:	e8 d7 01 00 00       	call   80106a4e <trap>
  addl $4, %esp
80106877:	83 c4 04             	add    $0x4,%esp

8010687a <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010687a:	61                   	popa
  popl %gs
8010687b:	0f a9                	pop    %gs
  popl %fs
8010687d:	0f a1                	pop    %fs
  popl %es
8010687f:	07                   	pop    %es
  popl %ds
80106880:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106881:	83 c4 08             	add    $0x8,%esp
  iret
80106884:	cf                   	iret

80106885 <lidt>:
{
80106885:	55                   	push   %ebp
80106886:	89 e5                	mov    %esp,%ebp
80106888:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010688b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010688e:	83 e8 01             	sub    $0x1,%eax
80106891:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106895:	8b 45 08             	mov    0x8(%ebp),%eax
80106898:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010689c:	8b 45 08             	mov    0x8(%ebp),%eax
8010689f:	c1 e8 10             	shr    $0x10,%eax
801068a2:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801068a6:	8d 45 fa             	lea    -0x6(%ebp),%eax
801068a9:	0f 01 18             	lidtl  (%eax)
}
801068ac:	90                   	nop
801068ad:	c9                   	leave
801068ae:	c3                   	ret

801068af <rcr2>:

static inline uint
rcr2(void)
{
801068af:	55                   	push   %ebp
801068b0:	89 e5                	mov    %esp,%ebp
801068b2:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801068b5:	0f 20 d0             	mov    %cr2,%eax
801068b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801068bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801068be:	c9                   	leave
801068bf:	c3                   	ret

801068c0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801068c0:	55                   	push   %ebp
801068c1:	89 e5                	mov    %esp,%ebp
801068c3:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801068c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801068cd:	e9 c3 00 00 00       	jmp    80106995 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801068d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d5:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
801068dc:	89 c2                	mov    %eax,%edx
801068de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e1:	66 89 14 c5 60 71 19 	mov    %dx,-0x7fe68ea0(,%eax,8)
801068e8:	80 
801068e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ec:	66 c7 04 c5 62 71 19 	movw   $0x8,-0x7fe68e9e(,%eax,8)
801068f3:	80 08 00 
801068f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068f9:	0f b6 14 c5 64 71 19 	movzbl -0x7fe68e9c(,%eax,8),%edx
80106900:	80 
80106901:	83 e2 e0             	and    $0xffffffe0,%edx
80106904:	88 14 c5 64 71 19 80 	mov    %dl,-0x7fe68e9c(,%eax,8)
8010690b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010690e:	0f b6 14 c5 64 71 19 	movzbl -0x7fe68e9c(,%eax,8),%edx
80106915:	80 
80106916:	83 e2 1f             	and    $0x1f,%edx
80106919:	88 14 c5 64 71 19 80 	mov    %dl,-0x7fe68e9c(,%eax,8)
80106920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106923:	0f b6 14 c5 65 71 19 	movzbl -0x7fe68e9b(,%eax,8),%edx
8010692a:	80 
8010692b:	83 e2 f0             	and    $0xfffffff0,%edx
8010692e:	83 ca 0e             	or     $0xe,%edx
80106931:	88 14 c5 65 71 19 80 	mov    %dl,-0x7fe68e9b(,%eax,8)
80106938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010693b:	0f b6 14 c5 65 71 19 	movzbl -0x7fe68e9b(,%eax,8),%edx
80106942:	80 
80106943:	83 e2 ef             	and    $0xffffffef,%edx
80106946:	88 14 c5 65 71 19 80 	mov    %dl,-0x7fe68e9b(,%eax,8)
8010694d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106950:	0f b6 14 c5 65 71 19 	movzbl -0x7fe68e9b(,%eax,8),%edx
80106957:	80 
80106958:	83 e2 9f             	and    $0xffffff9f,%edx
8010695b:	88 14 c5 65 71 19 80 	mov    %dl,-0x7fe68e9b(,%eax,8)
80106962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106965:	0f b6 14 c5 65 71 19 	movzbl -0x7fe68e9b(,%eax,8),%edx
8010696c:	80 
8010696d:	83 ca 80             	or     $0xffffff80,%edx
80106970:	88 14 c5 65 71 19 80 	mov    %dl,-0x7fe68e9b(,%eax,8)
80106977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010697a:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
80106981:	c1 e8 10             	shr    $0x10,%eax
80106984:	89 c2                	mov    %eax,%edx
80106986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106989:	66 89 14 c5 66 71 19 	mov    %dx,-0x7fe68e9a(,%eax,8)
80106990:	80 
  for(i = 0; i < 256; i++)
80106991:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106995:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010699c:	0f 8e 30 ff ff ff    	jle    801068d2 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801069a2:	a1 88 f1 10 80       	mov    0x8010f188,%eax
801069a7:	66 a3 60 73 19 80    	mov    %ax,0x80197360
801069ad:	66 c7 05 62 73 19 80 	movw   $0x8,0x80197362
801069b4:	08 00 
801069b6:	0f b6 05 64 73 19 80 	movzbl 0x80197364,%eax
801069bd:	83 e0 e0             	and    $0xffffffe0,%eax
801069c0:	a2 64 73 19 80       	mov    %al,0x80197364
801069c5:	0f b6 05 64 73 19 80 	movzbl 0x80197364,%eax
801069cc:	83 e0 1f             	and    $0x1f,%eax
801069cf:	a2 64 73 19 80       	mov    %al,0x80197364
801069d4:	0f b6 05 65 73 19 80 	movzbl 0x80197365,%eax
801069db:	83 c8 0f             	or     $0xf,%eax
801069de:	a2 65 73 19 80       	mov    %al,0x80197365
801069e3:	0f b6 05 65 73 19 80 	movzbl 0x80197365,%eax
801069ea:	83 e0 ef             	and    $0xffffffef,%eax
801069ed:	a2 65 73 19 80       	mov    %al,0x80197365
801069f2:	0f b6 05 65 73 19 80 	movzbl 0x80197365,%eax
801069f9:	83 c8 60             	or     $0x60,%eax
801069fc:	a2 65 73 19 80       	mov    %al,0x80197365
80106a01:	0f b6 05 65 73 19 80 	movzbl 0x80197365,%eax
80106a08:	83 c8 80             	or     $0xffffff80,%eax
80106a0b:	a2 65 73 19 80       	mov    %al,0x80197365
80106a10:	a1 88 f1 10 80       	mov    0x8010f188,%eax
80106a15:	c1 e8 10             	shr    $0x10,%eax
80106a18:	66 a3 66 73 19 80    	mov    %ax,0x80197366

  initlock(&tickslock, "time");
80106a1e:	83 ec 08             	sub    $0x8,%esp
80106a21:	68 cc b1 10 80       	push   $0x8010b1cc
80106a26:	68 60 79 19 80       	push   $0x80197960
80106a2b:	e8 8b e7 ff ff       	call   801051bb <initlock>
80106a30:	83 c4 10             	add    $0x10,%esp
}
80106a33:	90                   	nop
80106a34:	c9                   	leave
80106a35:	c3                   	ret

80106a36 <idtinit>:

void
idtinit(void)
{
80106a36:	55                   	push   %ebp
80106a37:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106a39:	68 00 08 00 00       	push   $0x800
80106a3e:	68 60 71 19 80       	push   $0x80197160
80106a43:	e8 3d fe ff ff       	call   80106885 <lidt>
80106a48:	83 c4 08             	add    $0x8,%esp
}
80106a4b:	90                   	nop
80106a4c:	c9                   	leave
80106a4d:	c3                   	ret

80106a4e <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106a4e:	55                   	push   %ebp
80106a4f:	89 e5                	mov    %esp,%ebp
80106a51:	57                   	push   %edi
80106a52:	56                   	push   %esi
80106a53:	53                   	push   %ebx
80106a54:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106a57:	8b 45 08             	mov    0x8(%ebp),%eax
80106a5a:	8b 40 30             	mov    0x30(%eax),%eax
80106a5d:	83 f8 40             	cmp    $0x40,%eax
80106a60:	75 3b                	jne    80106a9d <trap+0x4f>
    if(myproc()->killed)
80106a62:	e8 c9 cf ff ff       	call   80103a30 <myproc>
80106a67:	8b 40 24             	mov    0x24(%eax),%eax
80106a6a:	85 c0                	test   %eax,%eax
80106a6c:	74 05                	je     80106a73 <trap+0x25>
      exit();
80106a6e:	e8 93 d5 ff ff       	call   80104006 <exit>
    myproc()->tf = tf;
80106a73:	e8 b8 cf ff ff       	call   80103a30 <myproc>
80106a78:	8b 55 08             	mov    0x8(%ebp),%edx
80106a7b:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106a7e:	e8 c7 ed ff ff       	call   8010584a <syscall>
    if(myproc()->killed)
80106a83:	e8 a8 cf ff ff       	call   80103a30 <myproc>
80106a88:	8b 40 24             	mov    0x24(%eax),%eax
80106a8b:	85 c0                	test   %eax,%eax
80106a8d:	0f 84 1f 03 00 00    	je     80106db2 <trap+0x364>
      exit();
80106a93:	e8 6e d5 ff ff       	call   80104006 <exit>
    return;
80106a98:	e9 15 03 00 00       	jmp    80106db2 <trap+0x364>
  }

  switch(tf->trapno){
80106a9d:	8b 45 08             	mov    0x8(%ebp),%eax
80106aa0:	8b 40 30             	mov    0x30(%eax),%eax
80106aa3:	83 e8 20             	sub    $0x20,%eax
80106aa6:	83 f8 1f             	cmp    $0x1f,%eax
80106aa9:	0f 87 ce 01 00 00    	ja     80106c7d <trap+0x22f>
80106aaf:	8b 04 85 a0 b2 10 80 	mov    -0x7fef4d60(,%eax,4),%eax
80106ab6:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106ab8:	e8 e0 ce ff ff       	call   8010399d <cpuid>
80106abd:	85 c0                	test   %eax,%eax
80106abf:	75 3d                	jne    80106afe <trap+0xb0>
      acquire(&tickslock);
80106ac1:	83 ec 0c             	sub    $0xc,%esp
80106ac4:	68 60 79 19 80       	push   $0x80197960
80106ac9:	e8 0f e7 ff ff       	call   801051dd <acquire>
80106ace:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106ad1:	a1 94 79 19 80       	mov    0x80197994,%eax
80106ad6:	83 c0 01             	add    $0x1,%eax
80106ad9:	a3 94 79 19 80       	mov    %eax,0x80197994
      wakeup(&ticks);
80106ade:	83 ec 0c             	sub    $0xc,%esp
80106ae1:	68 94 79 19 80       	push   $0x80197994
80106ae6:	e8 3f db ff ff       	call   8010462a <wakeup>
80106aeb:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106aee:	83 ec 0c             	sub    $0xc,%esp
80106af1:	68 60 79 19 80       	push   $0x80197960
80106af6:	e8 50 e7 ff ff       	call   8010524b <release>
80106afb:	83 c4 10             	add    $0x10,%esp
    }
    //현재 실행 중인 프로세스에 대해 tick 누적
    struct proc* p = myproc();
80106afe:	e8 2d cf ff ff       	call   80103a30 <myproc>
80106b03:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0 && p->state == RUNNING && mycpu()->sched_policy != 0) {
80106b06:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106b0a:	0f 84 f8 00 00 00    	je     80106c08 <trap+0x1ba>
80106b10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b13:	8b 40 0c             	mov    0xc(%eax),%eax
80106b16:	83 f8 04             	cmp    $0x4,%eax
80106b19:	0f 85 e9 00 00 00    	jne    80106c08 <trap+0x1ba>
80106b1f:	e8 94 ce ff ff       	call   801039b8 <mycpu>
80106b24:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106b2a:	85 c0                	test   %eax,%eax
80106b2c:	0f 84 d6 00 00 00    	je     80106c08 <trap+0x1ba>
      int idx = myproc() - ptable.proc;
80106b32:	e8 f9 ce ff ff       	call   80103a30 <myproc>
80106b37:	2d 34 52 19 80       	sub    $0x80195234,%eax
80106b3c:	c1 f8 02             	sar    $0x2,%eax
80106b3f:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80106b45:	89 45 e0             	mov    %eax,-0x20(%ebp)
      int q = kernel_pstat.priority[idx];
80106b48:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b4b:	83 e8 80             	sub    $0xffffff80,%eax
80106b4e:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80106b55:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kernel_pstat.ticks[idx][q]++;  //  실제 실행 시간 증가
80106b58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b5b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106b62:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106b65:	01 d0                	add    %edx,%eax
80106b67:	05 00 01 00 00       	add    $0x100,%eax
80106b6c:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80106b73:	8d 50 01             	lea    0x1(%eax),%edx
80106b76:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b79:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80106b80:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106b83:	01 c8                	add    %ecx,%eax
80106b85:	05 00 01 00 00       	add    $0x100,%eax
80106b8a:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)

      //로그 출력용
      if (kernel_pstat.ticks[idx][q] == 1 || kernel_pstat.ticks[idx][q] % 8 == 0) {
80106b91:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b94:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106b9b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106b9e:	01 d0                	add    %edx,%eax
80106ba0:	05 00 01 00 00       	add    $0x100,%eax
80106ba5:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80106bac:	83 f8 01             	cmp    $0x1,%eax
80106baf:	74 22                	je     80106bd3 <trap+0x185>
80106bb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106bb4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106bbb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106bbe:	01 d0                	add    %edx,%eax
80106bc0:	05 00 01 00 00       	add    $0x100,%eax
80106bc5:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80106bcc:	83 e0 07             	and    $0x7,%eax
80106bcf:	85 c0                	test   %eax,%eax
80106bd1:	75 35                	jne    80106c08 <trap+0x1ba>
        cprintf("[TIMER] PID %d ticked on Q%d, total = %d\n",
80106bd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106bd6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106bdd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106be0:	01 d0                	add    %edx,%eax
80106be2:	05 00 01 00 00       	add    $0x100,%eax
80106be7:	8b 1c 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%ebx
                myproc()->pid, q, kernel_pstat.ticks[idx][q]);
80106bee:	e8 3d ce ff ff       	call   80103a30 <myproc>
        cprintf("[TIMER] PID %d ticked on Q%d, total = %d\n",
80106bf3:	8b 40 10             	mov    0x10(%eax),%eax
80106bf6:	53                   	push   %ebx
80106bf7:	ff 75 dc             	push   -0x24(%ebp)
80106bfa:	50                   	push   %eax
80106bfb:	68 d4 b1 10 80       	push   $0x8010b1d4
80106c00:	e8 ef 97 ff ff       	call   801003f4 <cprintf>
80106c05:	83 c4 10             	add    $0x10,%esp
      }
    }

    lapiceoi();
80106c08:	e8 11 bf ff ff       	call   80102b1e <lapiceoi>
    break;
80106c0d:	e9 20 01 00 00       	jmp    80106d32 <trap+0x2e4>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106c12:	e8 da 3e 00 00       	call   8010aaf1 <ideintr>
    lapiceoi();
80106c17:	e8 02 bf ff ff       	call   80102b1e <lapiceoi>
    break;
80106c1c:	e9 11 01 00 00       	jmp    80106d32 <trap+0x2e4>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106c21:	e8 43 bd ff ff       	call   80102969 <kbdintr>
    lapiceoi();
80106c26:	e8 f3 be ff ff       	call   80102b1e <lapiceoi>
    break;
80106c2b:	e9 02 01 00 00       	jmp    80106d32 <trap+0x2e4>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106c30:	e8 51 03 00 00       	call   80106f86 <uartintr>
    lapiceoi();
80106c35:	e8 e4 be ff ff       	call   80102b1e <lapiceoi>
    break;
80106c3a:	e9 f3 00 00 00       	jmp    80106d32 <trap+0x2e4>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106c3f:	e8 76 2b 00 00       	call   801097ba <i8254_intr>
    lapiceoi();
80106c44:	e8 d5 be ff ff       	call   80102b1e <lapiceoi>
    break;
80106c49:	e9 e4 00 00 00       	jmp    80106d32 <trap+0x2e4>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c4e:	8b 45 08             	mov    0x8(%ebp),%eax
80106c51:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106c54:	8b 45 08             	mov    0x8(%ebp),%eax
80106c57:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c5b:	0f b7 d8             	movzwl %ax,%ebx
80106c5e:	e8 3a cd ff ff       	call   8010399d <cpuid>
80106c63:	56                   	push   %esi
80106c64:	53                   	push   %ebx
80106c65:	50                   	push   %eax
80106c66:	68 00 b2 10 80       	push   $0x8010b200
80106c6b:	e8 84 97 ff ff       	call   801003f4 <cprintf>
80106c70:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106c73:	e8 a6 be ff ff       	call   80102b1e <lapiceoi>
    break;
80106c78:	e9 b5 00 00 00       	jmp    80106d32 <trap+0x2e4>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106c7d:	e8 ae cd ff ff       	call   80103a30 <myproc>
80106c82:	85 c0                	test   %eax,%eax
80106c84:	74 11                	je     80106c97 <trap+0x249>
80106c86:	8b 45 08             	mov    0x8(%ebp),%eax
80106c89:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c8d:	0f b7 c0             	movzwl %ax,%eax
80106c90:	83 e0 03             	and    $0x3,%eax
80106c93:	85 c0                	test   %eax,%eax
80106c95:	75 39                	jne    80106cd0 <trap+0x282>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c97:	e8 13 fc ff ff       	call   801068af <rcr2>
80106c9c:	89 c3                	mov    %eax,%ebx
80106c9e:	8b 45 08             	mov    0x8(%ebp),%eax
80106ca1:	8b 70 38             	mov    0x38(%eax),%esi
80106ca4:	e8 f4 cc ff ff       	call   8010399d <cpuid>
80106ca9:	8b 55 08             	mov    0x8(%ebp),%edx
80106cac:	8b 52 30             	mov    0x30(%edx),%edx
80106caf:	83 ec 0c             	sub    $0xc,%esp
80106cb2:	53                   	push   %ebx
80106cb3:	56                   	push   %esi
80106cb4:	50                   	push   %eax
80106cb5:	52                   	push   %edx
80106cb6:	68 24 b2 10 80       	push   $0x8010b224
80106cbb:	e8 34 97 ff ff       	call   801003f4 <cprintf>
80106cc0:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106cc3:	83 ec 0c             	sub    $0xc,%esp
80106cc6:	68 56 b2 10 80       	push   $0x8010b256
80106ccb:	e8 d9 98 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106cd0:	e8 da fb ff ff       	call   801068af <rcr2>
80106cd5:	89 c6                	mov    %eax,%esi
80106cd7:	8b 45 08             	mov    0x8(%ebp),%eax
80106cda:	8b 40 38             	mov    0x38(%eax),%eax
80106cdd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106ce0:	e8 b8 cc ff ff       	call   8010399d <cpuid>
80106ce5:	89 c3                	mov    %eax,%ebx
80106ce7:	8b 45 08             	mov    0x8(%ebp),%eax
80106cea:	8b 48 34             	mov    0x34(%eax),%ecx
80106ced:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80106cf3:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106cf6:	e8 35 cd ff ff       	call   80103a30 <myproc>
80106cfb:	8d 50 6c             	lea    0x6c(%eax),%edx
80106cfe:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106d01:	e8 2a cd ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d06:	8b 40 10             	mov    0x10(%eax),%eax
80106d09:	56                   	push   %esi
80106d0a:	ff 75 d4             	push   -0x2c(%ebp)
80106d0d:	53                   	push   %ebx
80106d0e:	ff 75 d0             	push   -0x30(%ebp)
80106d11:	57                   	push   %edi
80106d12:	ff 75 cc             	push   -0x34(%ebp)
80106d15:	50                   	push   %eax
80106d16:	68 5c b2 10 80       	push   $0x8010b25c
80106d1b:	e8 d4 96 ff ff       	call   801003f4 <cprintf>
80106d20:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106d23:	e8 08 cd ff ff       	call   80103a30 <myproc>
80106d28:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106d2f:	eb 01                	jmp    80106d32 <trap+0x2e4>
    break;
80106d31:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106d32:	e8 f9 cc ff ff       	call   80103a30 <myproc>
80106d37:	85 c0                	test   %eax,%eax
80106d39:	74 23                	je     80106d5e <trap+0x310>
80106d3b:	e8 f0 cc ff ff       	call   80103a30 <myproc>
80106d40:	8b 40 24             	mov    0x24(%eax),%eax
80106d43:	85 c0                	test   %eax,%eax
80106d45:	74 17                	je     80106d5e <trap+0x310>
80106d47:	8b 45 08             	mov    0x8(%ebp),%eax
80106d4a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d4e:	0f b7 c0             	movzwl %ax,%eax
80106d51:	83 e0 03             	and    $0x3,%eax
80106d54:	83 f8 03             	cmp    $0x3,%eax
80106d57:	75 05                	jne    80106d5e <trap+0x310>
    exit();
80106d59:	e8 a8 d2 ff ff       	call   80104006 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106d5e:	e8 cd cc ff ff       	call   80103a30 <myproc>
80106d63:	85 c0                	test   %eax,%eax
80106d65:	74 1d                	je     80106d84 <trap+0x336>
80106d67:	e8 c4 cc ff ff       	call   80103a30 <myproc>
80106d6c:	8b 40 0c             	mov    0xc(%eax),%eax
80106d6f:	83 f8 04             	cmp    $0x4,%eax
80106d72:	75 10                	jne    80106d84 <trap+0x336>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106d74:	8b 45 08             	mov    0x8(%ebp),%eax
80106d77:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106d7a:	83 f8 20             	cmp    $0x20,%eax
80106d7d:	75 05                	jne    80106d84 <trap+0x336>
    yield();
80106d7f:	e8 3f d7 ff ff       	call   801044c3 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106d84:	e8 a7 cc ff ff       	call   80103a30 <myproc>
80106d89:	85 c0                	test   %eax,%eax
80106d8b:	74 26                	je     80106db3 <trap+0x365>
80106d8d:	e8 9e cc ff ff       	call   80103a30 <myproc>
80106d92:	8b 40 24             	mov    0x24(%eax),%eax
80106d95:	85 c0                	test   %eax,%eax
80106d97:	74 1a                	je     80106db3 <trap+0x365>
80106d99:	8b 45 08             	mov    0x8(%ebp),%eax
80106d9c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106da0:	0f b7 c0             	movzwl %ax,%eax
80106da3:	83 e0 03             	and    $0x3,%eax
80106da6:	83 f8 03             	cmp    $0x3,%eax
80106da9:	75 08                	jne    80106db3 <trap+0x365>
    exit();
80106dab:	e8 56 d2 ff ff       	call   80104006 <exit>
80106db0:	eb 01                	jmp    80106db3 <trap+0x365>
    return;
80106db2:	90                   	nop
}
80106db3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106db6:	5b                   	pop    %ebx
80106db7:	5e                   	pop    %esi
80106db8:	5f                   	pop    %edi
80106db9:	5d                   	pop    %ebp
80106dba:	c3                   	ret

80106dbb <inb>:
{
80106dbb:	55                   	push   %ebp
80106dbc:	89 e5                	mov    %esp,%ebp
80106dbe:	83 ec 14             	sub    $0x14,%esp
80106dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80106dc4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106dc8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106dcc:	89 c2                	mov    %eax,%edx
80106dce:	ec                   	in     (%dx),%al
80106dcf:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106dd2:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106dd6:	c9                   	leave
80106dd7:	c3                   	ret

80106dd8 <outb>:
{
80106dd8:	55                   	push   %ebp
80106dd9:	89 e5                	mov    %esp,%ebp
80106ddb:	83 ec 08             	sub    $0x8,%esp
80106dde:	8b 55 08             	mov    0x8(%ebp),%edx
80106de1:	8b 45 0c             	mov    0xc(%ebp),%eax
80106de4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106de8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106deb:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106def:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106df3:	ee                   	out    %al,(%dx)
}
80106df4:	90                   	nop
80106df5:	c9                   	leave
80106df6:	c3                   	ret

80106df7 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106df7:	55                   	push   %ebp
80106df8:	89 e5                	mov    %esp,%ebp
80106dfa:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106dfd:	6a 00                	push   $0x0
80106dff:	68 fa 03 00 00       	push   $0x3fa
80106e04:	e8 cf ff ff ff       	call   80106dd8 <outb>
80106e09:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106e0c:	68 80 00 00 00       	push   $0x80
80106e11:	68 fb 03 00 00       	push   $0x3fb
80106e16:	e8 bd ff ff ff       	call   80106dd8 <outb>
80106e1b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106e1e:	6a 0c                	push   $0xc
80106e20:	68 f8 03 00 00       	push   $0x3f8
80106e25:	e8 ae ff ff ff       	call   80106dd8 <outb>
80106e2a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106e2d:	6a 00                	push   $0x0
80106e2f:	68 f9 03 00 00       	push   $0x3f9
80106e34:	e8 9f ff ff ff       	call   80106dd8 <outb>
80106e39:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106e3c:	6a 03                	push   $0x3
80106e3e:	68 fb 03 00 00       	push   $0x3fb
80106e43:	e8 90 ff ff ff       	call   80106dd8 <outb>
80106e48:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106e4b:	6a 00                	push   $0x0
80106e4d:	68 fc 03 00 00       	push   $0x3fc
80106e52:	e8 81 ff ff ff       	call   80106dd8 <outb>
80106e57:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106e5a:	6a 01                	push   $0x1
80106e5c:	68 f9 03 00 00       	push   $0x3f9
80106e61:	e8 72 ff ff ff       	call   80106dd8 <outb>
80106e66:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106e69:	68 fd 03 00 00       	push   $0x3fd
80106e6e:	e8 48 ff ff ff       	call   80106dbb <inb>
80106e73:	83 c4 04             	add    $0x4,%esp
80106e76:	3c ff                	cmp    $0xff,%al
80106e78:	74 61                	je     80106edb <uartinit+0xe4>
    return;
  uart = 1;
80106e7a:	c7 05 98 79 19 80 01 	movl   $0x1,0x80197998
80106e81:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e84:	68 fa 03 00 00       	push   $0x3fa
80106e89:	e8 2d ff ff ff       	call   80106dbb <inb>
80106e8e:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106e91:	68 f8 03 00 00       	push   $0x3f8
80106e96:	e8 20 ff ff ff       	call   80106dbb <inb>
80106e9b:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106e9e:	83 ec 08             	sub    $0x8,%esp
80106ea1:	6a 00                	push   $0x0
80106ea3:	6a 04                	push   $0x4
80106ea5:	e8 8c b7 ff ff       	call   80102636 <ioapicenable>
80106eaa:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106ead:	c7 45 f4 20 b3 10 80 	movl   $0x8010b320,-0xc(%ebp)
80106eb4:	eb 19                	jmp    80106ecf <uartinit+0xd8>
    uartputc(*p);
80106eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eb9:	0f b6 00             	movzbl (%eax),%eax
80106ebc:	0f be c0             	movsbl %al,%eax
80106ebf:	83 ec 0c             	sub    $0xc,%esp
80106ec2:	50                   	push   %eax
80106ec3:	e8 16 00 00 00       	call   80106ede <uartputc>
80106ec8:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106ecb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed2:	0f b6 00             	movzbl (%eax),%eax
80106ed5:	84 c0                	test   %al,%al
80106ed7:	75 dd                	jne    80106eb6 <uartinit+0xbf>
80106ed9:	eb 01                	jmp    80106edc <uartinit+0xe5>
    return;
80106edb:	90                   	nop
}
80106edc:	c9                   	leave
80106edd:	c3                   	ret

80106ede <uartputc>:

void
uartputc(int c)
{
80106ede:	55                   	push   %ebp
80106edf:	89 e5                	mov    %esp,%ebp
80106ee1:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106ee4:	a1 98 79 19 80       	mov    0x80197998,%eax
80106ee9:	85 c0                	test   %eax,%eax
80106eeb:	74 53                	je     80106f40 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106eed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ef4:	eb 11                	jmp    80106f07 <uartputc+0x29>
    microdelay(10);
80106ef6:	83 ec 0c             	sub    $0xc,%esp
80106ef9:	6a 0a                	push   $0xa
80106efb:	e8 39 bc ff ff       	call   80102b39 <microdelay>
80106f00:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f03:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106f07:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106f0b:	7f 1a                	jg     80106f27 <uartputc+0x49>
80106f0d:	83 ec 0c             	sub    $0xc,%esp
80106f10:	68 fd 03 00 00       	push   $0x3fd
80106f15:	e8 a1 fe ff ff       	call   80106dbb <inb>
80106f1a:	83 c4 10             	add    $0x10,%esp
80106f1d:	0f b6 c0             	movzbl %al,%eax
80106f20:	83 e0 20             	and    $0x20,%eax
80106f23:	85 c0                	test   %eax,%eax
80106f25:	74 cf                	je     80106ef6 <uartputc+0x18>
  outb(COM1+0, c);
80106f27:	8b 45 08             	mov    0x8(%ebp),%eax
80106f2a:	0f b6 c0             	movzbl %al,%eax
80106f2d:	83 ec 08             	sub    $0x8,%esp
80106f30:	50                   	push   %eax
80106f31:	68 f8 03 00 00       	push   $0x3f8
80106f36:	e8 9d fe ff ff       	call   80106dd8 <outb>
80106f3b:	83 c4 10             	add    $0x10,%esp
80106f3e:	eb 01                	jmp    80106f41 <uartputc+0x63>
    return;
80106f40:	90                   	nop
}
80106f41:	c9                   	leave
80106f42:	c3                   	ret

80106f43 <uartgetc>:

static int
uartgetc(void)
{
80106f43:	55                   	push   %ebp
80106f44:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106f46:	a1 98 79 19 80       	mov    0x80197998,%eax
80106f4b:	85 c0                	test   %eax,%eax
80106f4d:	75 07                	jne    80106f56 <uartgetc+0x13>
    return -1;
80106f4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f54:	eb 2e                	jmp    80106f84 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106f56:	68 fd 03 00 00       	push   $0x3fd
80106f5b:	e8 5b fe ff ff       	call   80106dbb <inb>
80106f60:	83 c4 04             	add    $0x4,%esp
80106f63:	0f b6 c0             	movzbl %al,%eax
80106f66:	83 e0 01             	and    $0x1,%eax
80106f69:	85 c0                	test   %eax,%eax
80106f6b:	75 07                	jne    80106f74 <uartgetc+0x31>
    return -1;
80106f6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f72:	eb 10                	jmp    80106f84 <uartgetc+0x41>
  return inb(COM1+0);
80106f74:	68 f8 03 00 00       	push   $0x3f8
80106f79:	e8 3d fe ff ff       	call   80106dbb <inb>
80106f7e:	83 c4 04             	add    $0x4,%esp
80106f81:	0f b6 c0             	movzbl %al,%eax
}
80106f84:	c9                   	leave
80106f85:	c3                   	ret

80106f86 <uartintr>:

void
uartintr(void)
{
80106f86:	55                   	push   %ebp
80106f87:	89 e5                	mov    %esp,%ebp
80106f89:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106f8c:	83 ec 0c             	sub    $0xc,%esp
80106f8f:	68 43 6f 10 80       	push   $0x80106f43
80106f94:	e8 3d 98 ff ff       	call   801007d6 <consoleintr>
80106f99:	83 c4 10             	add    $0x10,%esp
}
80106f9c:	90                   	nop
80106f9d:	c9                   	leave
80106f9e:	c3                   	ret

80106f9f <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106f9f:	6a 00                	push   $0x0
  pushl $0
80106fa1:	6a 00                	push   $0x0
  jmp alltraps
80106fa3:	e9 ba f8 ff ff       	jmp    80106862 <alltraps>

80106fa8 <vector1>:
.globl vector1
vector1:
  pushl $0
80106fa8:	6a 00                	push   $0x0
  pushl $1
80106faa:	6a 01                	push   $0x1
  jmp alltraps
80106fac:	e9 b1 f8 ff ff       	jmp    80106862 <alltraps>

80106fb1 <vector2>:
.globl vector2
vector2:
  pushl $0
80106fb1:	6a 00                	push   $0x0
  pushl $2
80106fb3:	6a 02                	push   $0x2
  jmp alltraps
80106fb5:	e9 a8 f8 ff ff       	jmp    80106862 <alltraps>

80106fba <vector3>:
.globl vector3
vector3:
  pushl $0
80106fba:	6a 00                	push   $0x0
  pushl $3
80106fbc:	6a 03                	push   $0x3
  jmp alltraps
80106fbe:	e9 9f f8 ff ff       	jmp    80106862 <alltraps>

80106fc3 <vector4>:
.globl vector4
vector4:
  pushl $0
80106fc3:	6a 00                	push   $0x0
  pushl $4
80106fc5:	6a 04                	push   $0x4
  jmp alltraps
80106fc7:	e9 96 f8 ff ff       	jmp    80106862 <alltraps>

80106fcc <vector5>:
.globl vector5
vector5:
  pushl $0
80106fcc:	6a 00                	push   $0x0
  pushl $5
80106fce:	6a 05                	push   $0x5
  jmp alltraps
80106fd0:	e9 8d f8 ff ff       	jmp    80106862 <alltraps>

80106fd5 <vector6>:
.globl vector6
vector6:
  pushl $0
80106fd5:	6a 00                	push   $0x0
  pushl $6
80106fd7:	6a 06                	push   $0x6
  jmp alltraps
80106fd9:	e9 84 f8 ff ff       	jmp    80106862 <alltraps>

80106fde <vector7>:
.globl vector7
vector7:
  pushl $0
80106fde:	6a 00                	push   $0x0
  pushl $7
80106fe0:	6a 07                	push   $0x7
  jmp alltraps
80106fe2:	e9 7b f8 ff ff       	jmp    80106862 <alltraps>

80106fe7 <vector8>:
.globl vector8
vector8:
  pushl $8
80106fe7:	6a 08                	push   $0x8
  jmp alltraps
80106fe9:	e9 74 f8 ff ff       	jmp    80106862 <alltraps>

80106fee <vector9>:
.globl vector9
vector9:
  pushl $0
80106fee:	6a 00                	push   $0x0
  pushl $9
80106ff0:	6a 09                	push   $0x9
  jmp alltraps
80106ff2:	e9 6b f8 ff ff       	jmp    80106862 <alltraps>

80106ff7 <vector10>:
.globl vector10
vector10:
  pushl $10
80106ff7:	6a 0a                	push   $0xa
  jmp alltraps
80106ff9:	e9 64 f8 ff ff       	jmp    80106862 <alltraps>

80106ffe <vector11>:
.globl vector11
vector11:
  pushl $11
80106ffe:	6a 0b                	push   $0xb
  jmp alltraps
80107000:	e9 5d f8 ff ff       	jmp    80106862 <alltraps>

80107005 <vector12>:
.globl vector12
vector12:
  pushl $12
80107005:	6a 0c                	push   $0xc
  jmp alltraps
80107007:	e9 56 f8 ff ff       	jmp    80106862 <alltraps>

8010700c <vector13>:
.globl vector13
vector13:
  pushl $13
8010700c:	6a 0d                	push   $0xd
  jmp alltraps
8010700e:	e9 4f f8 ff ff       	jmp    80106862 <alltraps>

80107013 <vector14>:
.globl vector14
vector14:
  pushl $14
80107013:	6a 0e                	push   $0xe
  jmp alltraps
80107015:	e9 48 f8 ff ff       	jmp    80106862 <alltraps>

8010701a <vector15>:
.globl vector15
vector15:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $15
8010701c:	6a 0f                	push   $0xf
  jmp alltraps
8010701e:	e9 3f f8 ff ff       	jmp    80106862 <alltraps>

80107023 <vector16>:
.globl vector16
vector16:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $16
80107025:	6a 10                	push   $0x10
  jmp alltraps
80107027:	e9 36 f8 ff ff       	jmp    80106862 <alltraps>

8010702c <vector17>:
.globl vector17
vector17:
  pushl $17
8010702c:	6a 11                	push   $0x11
  jmp alltraps
8010702e:	e9 2f f8 ff ff       	jmp    80106862 <alltraps>

80107033 <vector18>:
.globl vector18
vector18:
  pushl $0
80107033:	6a 00                	push   $0x0
  pushl $18
80107035:	6a 12                	push   $0x12
  jmp alltraps
80107037:	e9 26 f8 ff ff       	jmp    80106862 <alltraps>

8010703c <vector19>:
.globl vector19
vector19:
  pushl $0
8010703c:	6a 00                	push   $0x0
  pushl $19
8010703e:	6a 13                	push   $0x13
  jmp alltraps
80107040:	e9 1d f8 ff ff       	jmp    80106862 <alltraps>

80107045 <vector20>:
.globl vector20
vector20:
  pushl $0
80107045:	6a 00                	push   $0x0
  pushl $20
80107047:	6a 14                	push   $0x14
  jmp alltraps
80107049:	e9 14 f8 ff ff       	jmp    80106862 <alltraps>

8010704e <vector21>:
.globl vector21
vector21:
  pushl $0
8010704e:	6a 00                	push   $0x0
  pushl $21
80107050:	6a 15                	push   $0x15
  jmp alltraps
80107052:	e9 0b f8 ff ff       	jmp    80106862 <alltraps>

80107057 <vector22>:
.globl vector22
vector22:
  pushl $0
80107057:	6a 00                	push   $0x0
  pushl $22
80107059:	6a 16                	push   $0x16
  jmp alltraps
8010705b:	e9 02 f8 ff ff       	jmp    80106862 <alltraps>

80107060 <vector23>:
.globl vector23
vector23:
  pushl $0
80107060:	6a 00                	push   $0x0
  pushl $23
80107062:	6a 17                	push   $0x17
  jmp alltraps
80107064:	e9 f9 f7 ff ff       	jmp    80106862 <alltraps>

80107069 <vector24>:
.globl vector24
vector24:
  pushl $0
80107069:	6a 00                	push   $0x0
  pushl $24
8010706b:	6a 18                	push   $0x18
  jmp alltraps
8010706d:	e9 f0 f7 ff ff       	jmp    80106862 <alltraps>

80107072 <vector25>:
.globl vector25
vector25:
  pushl $0
80107072:	6a 00                	push   $0x0
  pushl $25
80107074:	6a 19                	push   $0x19
  jmp alltraps
80107076:	e9 e7 f7 ff ff       	jmp    80106862 <alltraps>

8010707b <vector26>:
.globl vector26
vector26:
  pushl $0
8010707b:	6a 00                	push   $0x0
  pushl $26
8010707d:	6a 1a                	push   $0x1a
  jmp alltraps
8010707f:	e9 de f7 ff ff       	jmp    80106862 <alltraps>

80107084 <vector27>:
.globl vector27
vector27:
  pushl $0
80107084:	6a 00                	push   $0x0
  pushl $27
80107086:	6a 1b                	push   $0x1b
  jmp alltraps
80107088:	e9 d5 f7 ff ff       	jmp    80106862 <alltraps>

8010708d <vector28>:
.globl vector28
vector28:
  pushl $0
8010708d:	6a 00                	push   $0x0
  pushl $28
8010708f:	6a 1c                	push   $0x1c
  jmp alltraps
80107091:	e9 cc f7 ff ff       	jmp    80106862 <alltraps>

80107096 <vector29>:
.globl vector29
vector29:
  pushl $0
80107096:	6a 00                	push   $0x0
  pushl $29
80107098:	6a 1d                	push   $0x1d
  jmp alltraps
8010709a:	e9 c3 f7 ff ff       	jmp    80106862 <alltraps>

8010709f <vector30>:
.globl vector30
vector30:
  pushl $0
8010709f:	6a 00                	push   $0x0
  pushl $30
801070a1:	6a 1e                	push   $0x1e
  jmp alltraps
801070a3:	e9 ba f7 ff ff       	jmp    80106862 <alltraps>

801070a8 <vector31>:
.globl vector31
vector31:
  pushl $0
801070a8:	6a 00                	push   $0x0
  pushl $31
801070aa:	6a 1f                	push   $0x1f
  jmp alltraps
801070ac:	e9 b1 f7 ff ff       	jmp    80106862 <alltraps>

801070b1 <vector32>:
.globl vector32
vector32:
  pushl $0
801070b1:	6a 00                	push   $0x0
  pushl $32
801070b3:	6a 20                	push   $0x20
  jmp alltraps
801070b5:	e9 a8 f7 ff ff       	jmp    80106862 <alltraps>

801070ba <vector33>:
.globl vector33
vector33:
  pushl $0
801070ba:	6a 00                	push   $0x0
  pushl $33
801070bc:	6a 21                	push   $0x21
  jmp alltraps
801070be:	e9 9f f7 ff ff       	jmp    80106862 <alltraps>

801070c3 <vector34>:
.globl vector34
vector34:
  pushl $0
801070c3:	6a 00                	push   $0x0
  pushl $34
801070c5:	6a 22                	push   $0x22
  jmp alltraps
801070c7:	e9 96 f7 ff ff       	jmp    80106862 <alltraps>

801070cc <vector35>:
.globl vector35
vector35:
  pushl $0
801070cc:	6a 00                	push   $0x0
  pushl $35
801070ce:	6a 23                	push   $0x23
  jmp alltraps
801070d0:	e9 8d f7 ff ff       	jmp    80106862 <alltraps>

801070d5 <vector36>:
.globl vector36
vector36:
  pushl $0
801070d5:	6a 00                	push   $0x0
  pushl $36
801070d7:	6a 24                	push   $0x24
  jmp alltraps
801070d9:	e9 84 f7 ff ff       	jmp    80106862 <alltraps>

801070de <vector37>:
.globl vector37
vector37:
  pushl $0
801070de:	6a 00                	push   $0x0
  pushl $37
801070e0:	6a 25                	push   $0x25
  jmp alltraps
801070e2:	e9 7b f7 ff ff       	jmp    80106862 <alltraps>

801070e7 <vector38>:
.globl vector38
vector38:
  pushl $0
801070e7:	6a 00                	push   $0x0
  pushl $38
801070e9:	6a 26                	push   $0x26
  jmp alltraps
801070eb:	e9 72 f7 ff ff       	jmp    80106862 <alltraps>

801070f0 <vector39>:
.globl vector39
vector39:
  pushl $0
801070f0:	6a 00                	push   $0x0
  pushl $39
801070f2:	6a 27                	push   $0x27
  jmp alltraps
801070f4:	e9 69 f7 ff ff       	jmp    80106862 <alltraps>

801070f9 <vector40>:
.globl vector40
vector40:
  pushl $0
801070f9:	6a 00                	push   $0x0
  pushl $40
801070fb:	6a 28                	push   $0x28
  jmp alltraps
801070fd:	e9 60 f7 ff ff       	jmp    80106862 <alltraps>

80107102 <vector41>:
.globl vector41
vector41:
  pushl $0
80107102:	6a 00                	push   $0x0
  pushl $41
80107104:	6a 29                	push   $0x29
  jmp alltraps
80107106:	e9 57 f7 ff ff       	jmp    80106862 <alltraps>

8010710b <vector42>:
.globl vector42
vector42:
  pushl $0
8010710b:	6a 00                	push   $0x0
  pushl $42
8010710d:	6a 2a                	push   $0x2a
  jmp alltraps
8010710f:	e9 4e f7 ff ff       	jmp    80106862 <alltraps>

80107114 <vector43>:
.globl vector43
vector43:
  pushl $0
80107114:	6a 00                	push   $0x0
  pushl $43
80107116:	6a 2b                	push   $0x2b
  jmp alltraps
80107118:	e9 45 f7 ff ff       	jmp    80106862 <alltraps>

8010711d <vector44>:
.globl vector44
vector44:
  pushl $0
8010711d:	6a 00                	push   $0x0
  pushl $44
8010711f:	6a 2c                	push   $0x2c
  jmp alltraps
80107121:	e9 3c f7 ff ff       	jmp    80106862 <alltraps>

80107126 <vector45>:
.globl vector45
vector45:
  pushl $0
80107126:	6a 00                	push   $0x0
  pushl $45
80107128:	6a 2d                	push   $0x2d
  jmp alltraps
8010712a:	e9 33 f7 ff ff       	jmp    80106862 <alltraps>

8010712f <vector46>:
.globl vector46
vector46:
  pushl $0
8010712f:	6a 00                	push   $0x0
  pushl $46
80107131:	6a 2e                	push   $0x2e
  jmp alltraps
80107133:	e9 2a f7 ff ff       	jmp    80106862 <alltraps>

80107138 <vector47>:
.globl vector47
vector47:
  pushl $0
80107138:	6a 00                	push   $0x0
  pushl $47
8010713a:	6a 2f                	push   $0x2f
  jmp alltraps
8010713c:	e9 21 f7 ff ff       	jmp    80106862 <alltraps>

80107141 <vector48>:
.globl vector48
vector48:
  pushl $0
80107141:	6a 00                	push   $0x0
  pushl $48
80107143:	6a 30                	push   $0x30
  jmp alltraps
80107145:	e9 18 f7 ff ff       	jmp    80106862 <alltraps>

8010714a <vector49>:
.globl vector49
vector49:
  pushl $0
8010714a:	6a 00                	push   $0x0
  pushl $49
8010714c:	6a 31                	push   $0x31
  jmp alltraps
8010714e:	e9 0f f7 ff ff       	jmp    80106862 <alltraps>

80107153 <vector50>:
.globl vector50
vector50:
  pushl $0
80107153:	6a 00                	push   $0x0
  pushl $50
80107155:	6a 32                	push   $0x32
  jmp alltraps
80107157:	e9 06 f7 ff ff       	jmp    80106862 <alltraps>

8010715c <vector51>:
.globl vector51
vector51:
  pushl $0
8010715c:	6a 00                	push   $0x0
  pushl $51
8010715e:	6a 33                	push   $0x33
  jmp alltraps
80107160:	e9 fd f6 ff ff       	jmp    80106862 <alltraps>

80107165 <vector52>:
.globl vector52
vector52:
  pushl $0
80107165:	6a 00                	push   $0x0
  pushl $52
80107167:	6a 34                	push   $0x34
  jmp alltraps
80107169:	e9 f4 f6 ff ff       	jmp    80106862 <alltraps>

8010716e <vector53>:
.globl vector53
vector53:
  pushl $0
8010716e:	6a 00                	push   $0x0
  pushl $53
80107170:	6a 35                	push   $0x35
  jmp alltraps
80107172:	e9 eb f6 ff ff       	jmp    80106862 <alltraps>

80107177 <vector54>:
.globl vector54
vector54:
  pushl $0
80107177:	6a 00                	push   $0x0
  pushl $54
80107179:	6a 36                	push   $0x36
  jmp alltraps
8010717b:	e9 e2 f6 ff ff       	jmp    80106862 <alltraps>

80107180 <vector55>:
.globl vector55
vector55:
  pushl $0
80107180:	6a 00                	push   $0x0
  pushl $55
80107182:	6a 37                	push   $0x37
  jmp alltraps
80107184:	e9 d9 f6 ff ff       	jmp    80106862 <alltraps>

80107189 <vector56>:
.globl vector56
vector56:
  pushl $0
80107189:	6a 00                	push   $0x0
  pushl $56
8010718b:	6a 38                	push   $0x38
  jmp alltraps
8010718d:	e9 d0 f6 ff ff       	jmp    80106862 <alltraps>

80107192 <vector57>:
.globl vector57
vector57:
  pushl $0
80107192:	6a 00                	push   $0x0
  pushl $57
80107194:	6a 39                	push   $0x39
  jmp alltraps
80107196:	e9 c7 f6 ff ff       	jmp    80106862 <alltraps>

8010719b <vector58>:
.globl vector58
vector58:
  pushl $0
8010719b:	6a 00                	push   $0x0
  pushl $58
8010719d:	6a 3a                	push   $0x3a
  jmp alltraps
8010719f:	e9 be f6 ff ff       	jmp    80106862 <alltraps>

801071a4 <vector59>:
.globl vector59
vector59:
  pushl $0
801071a4:	6a 00                	push   $0x0
  pushl $59
801071a6:	6a 3b                	push   $0x3b
  jmp alltraps
801071a8:	e9 b5 f6 ff ff       	jmp    80106862 <alltraps>

801071ad <vector60>:
.globl vector60
vector60:
  pushl $0
801071ad:	6a 00                	push   $0x0
  pushl $60
801071af:	6a 3c                	push   $0x3c
  jmp alltraps
801071b1:	e9 ac f6 ff ff       	jmp    80106862 <alltraps>

801071b6 <vector61>:
.globl vector61
vector61:
  pushl $0
801071b6:	6a 00                	push   $0x0
  pushl $61
801071b8:	6a 3d                	push   $0x3d
  jmp alltraps
801071ba:	e9 a3 f6 ff ff       	jmp    80106862 <alltraps>

801071bf <vector62>:
.globl vector62
vector62:
  pushl $0
801071bf:	6a 00                	push   $0x0
  pushl $62
801071c1:	6a 3e                	push   $0x3e
  jmp alltraps
801071c3:	e9 9a f6 ff ff       	jmp    80106862 <alltraps>

801071c8 <vector63>:
.globl vector63
vector63:
  pushl $0
801071c8:	6a 00                	push   $0x0
  pushl $63
801071ca:	6a 3f                	push   $0x3f
  jmp alltraps
801071cc:	e9 91 f6 ff ff       	jmp    80106862 <alltraps>

801071d1 <vector64>:
.globl vector64
vector64:
  pushl $0
801071d1:	6a 00                	push   $0x0
  pushl $64
801071d3:	6a 40                	push   $0x40
  jmp alltraps
801071d5:	e9 88 f6 ff ff       	jmp    80106862 <alltraps>

801071da <vector65>:
.globl vector65
vector65:
  pushl $0
801071da:	6a 00                	push   $0x0
  pushl $65
801071dc:	6a 41                	push   $0x41
  jmp alltraps
801071de:	e9 7f f6 ff ff       	jmp    80106862 <alltraps>

801071e3 <vector66>:
.globl vector66
vector66:
  pushl $0
801071e3:	6a 00                	push   $0x0
  pushl $66
801071e5:	6a 42                	push   $0x42
  jmp alltraps
801071e7:	e9 76 f6 ff ff       	jmp    80106862 <alltraps>

801071ec <vector67>:
.globl vector67
vector67:
  pushl $0
801071ec:	6a 00                	push   $0x0
  pushl $67
801071ee:	6a 43                	push   $0x43
  jmp alltraps
801071f0:	e9 6d f6 ff ff       	jmp    80106862 <alltraps>

801071f5 <vector68>:
.globl vector68
vector68:
  pushl $0
801071f5:	6a 00                	push   $0x0
  pushl $68
801071f7:	6a 44                	push   $0x44
  jmp alltraps
801071f9:	e9 64 f6 ff ff       	jmp    80106862 <alltraps>

801071fe <vector69>:
.globl vector69
vector69:
  pushl $0
801071fe:	6a 00                	push   $0x0
  pushl $69
80107200:	6a 45                	push   $0x45
  jmp alltraps
80107202:	e9 5b f6 ff ff       	jmp    80106862 <alltraps>

80107207 <vector70>:
.globl vector70
vector70:
  pushl $0
80107207:	6a 00                	push   $0x0
  pushl $70
80107209:	6a 46                	push   $0x46
  jmp alltraps
8010720b:	e9 52 f6 ff ff       	jmp    80106862 <alltraps>

80107210 <vector71>:
.globl vector71
vector71:
  pushl $0
80107210:	6a 00                	push   $0x0
  pushl $71
80107212:	6a 47                	push   $0x47
  jmp alltraps
80107214:	e9 49 f6 ff ff       	jmp    80106862 <alltraps>

80107219 <vector72>:
.globl vector72
vector72:
  pushl $0
80107219:	6a 00                	push   $0x0
  pushl $72
8010721b:	6a 48                	push   $0x48
  jmp alltraps
8010721d:	e9 40 f6 ff ff       	jmp    80106862 <alltraps>

80107222 <vector73>:
.globl vector73
vector73:
  pushl $0
80107222:	6a 00                	push   $0x0
  pushl $73
80107224:	6a 49                	push   $0x49
  jmp alltraps
80107226:	e9 37 f6 ff ff       	jmp    80106862 <alltraps>

8010722b <vector74>:
.globl vector74
vector74:
  pushl $0
8010722b:	6a 00                	push   $0x0
  pushl $74
8010722d:	6a 4a                	push   $0x4a
  jmp alltraps
8010722f:	e9 2e f6 ff ff       	jmp    80106862 <alltraps>

80107234 <vector75>:
.globl vector75
vector75:
  pushl $0
80107234:	6a 00                	push   $0x0
  pushl $75
80107236:	6a 4b                	push   $0x4b
  jmp alltraps
80107238:	e9 25 f6 ff ff       	jmp    80106862 <alltraps>

8010723d <vector76>:
.globl vector76
vector76:
  pushl $0
8010723d:	6a 00                	push   $0x0
  pushl $76
8010723f:	6a 4c                	push   $0x4c
  jmp alltraps
80107241:	e9 1c f6 ff ff       	jmp    80106862 <alltraps>

80107246 <vector77>:
.globl vector77
vector77:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $77
80107248:	6a 4d                	push   $0x4d
  jmp alltraps
8010724a:	e9 13 f6 ff ff       	jmp    80106862 <alltraps>

8010724f <vector78>:
.globl vector78
vector78:
  pushl $0
8010724f:	6a 00                	push   $0x0
  pushl $78
80107251:	6a 4e                	push   $0x4e
  jmp alltraps
80107253:	e9 0a f6 ff ff       	jmp    80106862 <alltraps>

80107258 <vector79>:
.globl vector79
vector79:
  pushl $0
80107258:	6a 00                	push   $0x0
  pushl $79
8010725a:	6a 4f                	push   $0x4f
  jmp alltraps
8010725c:	e9 01 f6 ff ff       	jmp    80106862 <alltraps>

80107261 <vector80>:
.globl vector80
vector80:
  pushl $0
80107261:	6a 00                	push   $0x0
  pushl $80
80107263:	6a 50                	push   $0x50
  jmp alltraps
80107265:	e9 f8 f5 ff ff       	jmp    80106862 <alltraps>

8010726a <vector81>:
.globl vector81
vector81:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $81
8010726c:	6a 51                	push   $0x51
  jmp alltraps
8010726e:	e9 ef f5 ff ff       	jmp    80106862 <alltraps>

80107273 <vector82>:
.globl vector82
vector82:
  pushl $0
80107273:	6a 00                	push   $0x0
  pushl $82
80107275:	6a 52                	push   $0x52
  jmp alltraps
80107277:	e9 e6 f5 ff ff       	jmp    80106862 <alltraps>

8010727c <vector83>:
.globl vector83
vector83:
  pushl $0
8010727c:	6a 00                	push   $0x0
  pushl $83
8010727e:	6a 53                	push   $0x53
  jmp alltraps
80107280:	e9 dd f5 ff ff       	jmp    80106862 <alltraps>

80107285 <vector84>:
.globl vector84
vector84:
  pushl $0
80107285:	6a 00                	push   $0x0
  pushl $84
80107287:	6a 54                	push   $0x54
  jmp alltraps
80107289:	e9 d4 f5 ff ff       	jmp    80106862 <alltraps>

8010728e <vector85>:
.globl vector85
vector85:
  pushl $0
8010728e:	6a 00                	push   $0x0
  pushl $85
80107290:	6a 55                	push   $0x55
  jmp alltraps
80107292:	e9 cb f5 ff ff       	jmp    80106862 <alltraps>

80107297 <vector86>:
.globl vector86
vector86:
  pushl $0
80107297:	6a 00                	push   $0x0
  pushl $86
80107299:	6a 56                	push   $0x56
  jmp alltraps
8010729b:	e9 c2 f5 ff ff       	jmp    80106862 <alltraps>

801072a0 <vector87>:
.globl vector87
vector87:
  pushl $0
801072a0:	6a 00                	push   $0x0
  pushl $87
801072a2:	6a 57                	push   $0x57
  jmp alltraps
801072a4:	e9 b9 f5 ff ff       	jmp    80106862 <alltraps>

801072a9 <vector88>:
.globl vector88
vector88:
  pushl $0
801072a9:	6a 00                	push   $0x0
  pushl $88
801072ab:	6a 58                	push   $0x58
  jmp alltraps
801072ad:	e9 b0 f5 ff ff       	jmp    80106862 <alltraps>

801072b2 <vector89>:
.globl vector89
vector89:
  pushl $0
801072b2:	6a 00                	push   $0x0
  pushl $89
801072b4:	6a 59                	push   $0x59
  jmp alltraps
801072b6:	e9 a7 f5 ff ff       	jmp    80106862 <alltraps>

801072bb <vector90>:
.globl vector90
vector90:
  pushl $0
801072bb:	6a 00                	push   $0x0
  pushl $90
801072bd:	6a 5a                	push   $0x5a
  jmp alltraps
801072bf:	e9 9e f5 ff ff       	jmp    80106862 <alltraps>

801072c4 <vector91>:
.globl vector91
vector91:
  pushl $0
801072c4:	6a 00                	push   $0x0
  pushl $91
801072c6:	6a 5b                	push   $0x5b
  jmp alltraps
801072c8:	e9 95 f5 ff ff       	jmp    80106862 <alltraps>

801072cd <vector92>:
.globl vector92
vector92:
  pushl $0
801072cd:	6a 00                	push   $0x0
  pushl $92
801072cf:	6a 5c                	push   $0x5c
  jmp alltraps
801072d1:	e9 8c f5 ff ff       	jmp    80106862 <alltraps>

801072d6 <vector93>:
.globl vector93
vector93:
  pushl $0
801072d6:	6a 00                	push   $0x0
  pushl $93
801072d8:	6a 5d                	push   $0x5d
  jmp alltraps
801072da:	e9 83 f5 ff ff       	jmp    80106862 <alltraps>

801072df <vector94>:
.globl vector94
vector94:
  pushl $0
801072df:	6a 00                	push   $0x0
  pushl $94
801072e1:	6a 5e                	push   $0x5e
  jmp alltraps
801072e3:	e9 7a f5 ff ff       	jmp    80106862 <alltraps>

801072e8 <vector95>:
.globl vector95
vector95:
  pushl $0
801072e8:	6a 00                	push   $0x0
  pushl $95
801072ea:	6a 5f                	push   $0x5f
  jmp alltraps
801072ec:	e9 71 f5 ff ff       	jmp    80106862 <alltraps>

801072f1 <vector96>:
.globl vector96
vector96:
  pushl $0
801072f1:	6a 00                	push   $0x0
  pushl $96
801072f3:	6a 60                	push   $0x60
  jmp alltraps
801072f5:	e9 68 f5 ff ff       	jmp    80106862 <alltraps>

801072fa <vector97>:
.globl vector97
vector97:
  pushl $0
801072fa:	6a 00                	push   $0x0
  pushl $97
801072fc:	6a 61                	push   $0x61
  jmp alltraps
801072fe:	e9 5f f5 ff ff       	jmp    80106862 <alltraps>

80107303 <vector98>:
.globl vector98
vector98:
  pushl $0
80107303:	6a 00                	push   $0x0
  pushl $98
80107305:	6a 62                	push   $0x62
  jmp alltraps
80107307:	e9 56 f5 ff ff       	jmp    80106862 <alltraps>

8010730c <vector99>:
.globl vector99
vector99:
  pushl $0
8010730c:	6a 00                	push   $0x0
  pushl $99
8010730e:	6a 63                	push   $0x63
  jmp alltraps
80107310:	e9 4d f5 ff ff       	jmp    80106862 <alltraps>

80107315 <vector100>:
.globl vector100
vector100:
  pushl $0
80107315:	6a 00                	push   $0x0
  pushl $100
80107317:	6a 64                	push   $0x64
  jmp alltraps
80107319:	e9 44 f5 ff ff       	jmp    80106862 <alltraps>

8010731e <vector101>:
.globl vector101
vector101:
  pushl $0
8010731e:	6a 00                	push   $0x0
  pushl $101
80107320:	6a 65                	push   $0x65
  jmp alltraps
80107322:	e9 3b f5 ff ff       	jmp    80106862 <alltraps>

80107327 <vector102>:
.globl vector102
vector102:
  pushl $0
80107327:	6a 00                	push   $0x0
  pushl $102
80107329:	6a 66                	push   $0x66
  jmp alltraps
8010732b:	e9 32 f5 ff ff       	jmp    80106862 <alltraps>

80107330 <vector103>:
.globl vector103
vector103:
  pushl $0
80107330:	6a 00                	push   $0x0
  pushl $103
80107332:	6a 67                	push   $0x67
  jmp alltraps
80107334:	e9 29 f5 ff ff       	jmp    80106862 <alltraps>

80107339 <vector104>:
.globl vector104
vector104:
  pushl $0
80107339:	6a 00                	push   $0x0
  pushl $104
8010733b:	6a 68                	push   $0x68
  jmp alltraps
8010733d:	e9 20 f5 ff ff       	jmp    80106862 <alltraps>

80107342 <vector105>:
.globl vector105
vector105:
  pushl $0
80107342:	6a 00                	push   $0x0
  pushl $105
80107344:	6a 69                	push   $0x69
  jmp alltraps
80107346:	e9 17 f5 ff ff       	jmp    80106862 <alltraps>

8010734b <vector106>:
.globl vector106
vector106:
  pushl $0
8010734b:	6a 00                	push   $0x0
  pushl $106
8010734d:	6a 6a                	push   $0x6a
  jmp alltraps
8010734f:	e9 0e f5 ff ff       	jmp    80106862 <alltraps>

80107354 <vector107>:
.globl vector107
vector107:
  pushl $0
80107354:	6a 00                	push   $0x0
  pushl $107
80107356:	6a 6b                	push   $0x6b
  jmp alltraps
80107358:	e9 05 f5 ff ff       	jmp    80106862 <alltraps>

8010735d <vector108>:
.globl vector108
vector108:
  pushl $0
8010735d:	6a 00                	push   $0x0
  pushl $108
8010735f:	6a 6c                	push   $0x6c
  jmp alltraps
80107361:	e9 fc f4 ff ff       	jmp    80106862 <alltraps>

80107366 <vector109>:
.globl vector109
vector109:
  pushl $0
80107366:	6a 00                	push   $0x0
  pushl $109
80107368:	6a 6d                	push   $0x6d
  jmp alltraps
8010736a:	e9 f3 f4 ff ff       	jmp    80106862 <alltraps>

8010736f <vector110>:
.globl vector110
vector110:
  pushl $0
8010736f:	6a 00                	push   $0x0
  pushl $110
80107371:	6a 6e                	push   $0x6e
  jmp alltraps
80107373:	e9 ea f4 ff ff       	jmp    80106862 <alltraps>

80107378 <vector111>:
.globl vector111
vector111:
  pushl $0
80107378:	6a 00                	push   $0x0
  pushl $111
8010737a:	6a 6f                	push   $0x6f
  jmp alltraps
8010737c:	e9 e1 f4 ff ff       	jmp    80106862 <alltraps>

80107381 <vector112>:
.globl vector112
vector112:
  pushl $0
80107381:	6a 00                	push   $0x0
  pushl $112
80107383:	6a 70                	push   $0x70
  jmp alltraps
80107385:	e9 d8 f4 ff ff       	jmp    80106862 <alltraps>

8010738a <vector113>:
.globl vector113
vector113:
  pushl $0
8010738a:	6a 00                	push   $0x0
  pushl $113
8010738c:	6a 71                	push   $0x71
  jmp alltraps
8010738e:	e9 cf f4 ff ff       	jmp    80106862 <alltraps>

80107393 <vector114>:
.globl vector114
vector114:
  pushl $0
80107393:	6a 00                	push   $0x0
  pushl $114
80107395:	6a 72                	push   $0x72
  jmp alltraps
80107397:	e9 c6 f4 ff ff       	jmp    80106862 <alltraps>

8010739c <vector115>:
.globl vector115
vector115:
  pushl $0
8010739c:	6a 00                	push   $0x0
  pushl $115
8010739e:	6a 73                	push   $0x73
  jmp alltraps
801073a0:	e9 bd f4 ff ff       	jmp    80106862 <alltraps>

801073a5 <vector116>:
.globl vector116
vector116:
  pushl $0
801073a5:	6a 00                	push   $0x0
  pushl $116
801073a7:	6a 74                	push   $0x74
  jmp alltraps
801073a9:	e9 b4 f4 ff ff       	jmp    80106862 <alltraps>

801073ae <vector117>:
.globl vector117
vector117:
  pushl $0
801073ae:	6a 00                	push   $0x0
  pushl $117
801073b0:	6a 75                	push   $0x75
  jmp alltraps
801073b2:	e9 ab f4 ff ff       	jmp    80106862 <alltraps>

801073b7 <vector118>:
.globl vector118
vector118:
  pushl $0
801073b7:	6a 00                	push   $0x0
  pushl $118
801073b9:	6a 76                	push   $0x76
  jmp alltraps
801073bb:	e9 a2 f4 ff ff       	jmp    80106862 <alltraps>

801073c0 <vector119>:
.globl vector119
vector119:
  pushl $0
801073c0:	6a 00                	push   $0x0
  pushl $119
801073c2:	6a 77                	push   $0x77
  jmp alltraps
801073c4:	e9 99 f4 ff ff       	jmp    80106862 <alltraps>

801073c9 <vector120>:
.globl vector120
vector120:
  pushl $0
801073c9:	6a 00                	push   $0x0
  pushl $120
801073cb:	6a 78                	push   $0x78
  jmp alltraps
801073cd:	e9 90 f4 ff ff       	jmp    80106862 <alltraps>

801073d2 <vector121>:
.globl vector121
vector121:
  pushl $0
801073d2:	6a 00                	push   $0x0
  pushl $121
801073d4:	6a 79                	push   $0x79
  jmp alltraps
801073d6:	e9 87 f4 ff ff       	jmp    80106862 <alltraps>

801073db <vector122>:
.globl vector122
vector122:
  pushl $0
801073db:	6a 00                	push   $0x0
  pushl $122
801073dd:	6a 7a                	push   $0x7a
  jmp alltraps
801073df:	e9 7e f4 ff ff       	jmp    80106862 <alltraps>

801073e4 <vector123>:
.globl vector123
vector123:
  pushl $0
801073e4:	6a 00                	push   $0x0
  pushl $123
801073e6:	6a 7b                	push   $0x7b
  jmp alltraps
801073e8:	e9 75 f4 ff ff       	jmp    80106862 <alltraps>

801073ed <vector124>:
.globl vector124
vector124:
  pushl $0
801073ed:	6a 00                	push   $0x0
  pushl $124
801073ef:	6a 7c                	push   $0x7c
  jmp alltraps
801073f1:	e9 6c f4 ff ff       	jmp    80106862 <alltraps>

801073f6 <vector125>:
.globl vector125
vector125:
  pushl $0
801073f6:	6a 00                	push   $0x0
  pushl $125
801073f8:	6a 7d                	push   $0x7d
  jmp alltraps
801073fa:	e9 63 f4 ff ff       	jmp    80106862 <alltraps>

801073ff <vector126>:
.globl vector126
vector126:
  pushl $0
801073ff:	6a 00                	push   $0x0
  pushl $126
80107401:	6a 7e                	push   $0x7e
  jmp alltraps
80107403:	e9 5a f4 ff ff       	jmp    80106862 <alltraps>

80107408 <vector127>:
.globl vector127
vector127:
  pushl $0
80107408:	6a 00                	push   $0x0
  pushl $127
8010740a:	6a 7f                	push   $0x7f
  jmp alltraps
8010740c:	e9 51 f4 ff ff       	jmp    80106862 <alltraps>

80107411 <vector128>:
.globl vector128
vector128:
  pushl $0
80107411:	6a 00                	push   $0x0
  pushl $128
80107413:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107418:	e9 45 f4 ff ff       	jmp    80106862 <alltraps>

8010741d <vector129>:
.globl vector129
vector129:
  pushl $0
8010741d:	6a 00                	push   $0x0
  pushl $129
8010741f:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107424:	e9 39 f4 ff ff       	jmp    80106862 <alltraps>

80107429 <vector130>:
.globl vector130
vector130:
  pushl $0
80107429:	6a 00                	push   $0x0
  pushl $130
8010742b:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107430:	e9 2d f4 ff ff       	jmp    80106862 <alltraps>

80107435 <vector131>:
.globl vector131
vector131:
  pushl $0
80107435:	6a 00                	push   $0x0
  pushl $131
80107437:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010743c:	e9 21 f4 ff ff       	jmp    80106862 <alltraps>

80107441 <vector132>:
.globl vector132
vector132:
  pushl $0
80107441:	6a 00                	push   $0x0
  pushl $132
80107443:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107448:	e9 15 f4 ff ff       	jmp    80106862 <alltraps>

8010744d <vector133>:
.globl vector133
vector133:
  pushl $0
8010744d:	6a 00                	push   $0x0
  pushl $133
8010744f:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107454:	e9 09 f4 ff ff       	jmp    80106862 <alltraps>

80107459 <vector134>:
.globl vector134
vector134:
  pushl $0
80107459:	6a 00                	push   $0x0
  pushl $134
8010745b:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107460:	e9 fd f3 ff ff       	jmp    80106862 <alltraps>

80107465 <vector135>:
.globl vector135
vector135:
  pushl $0
80107465:	6a 00                	push   $0x0
  pushl $135
80107467:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010746c:	e9 f1 f3 ff ff       	jmp    80106862 <alltraps>

80107471 <vector136>:
.globl vector136
vector136:
  pushl $0
80107471:	6a 00                	push   $0x0
  pushl $136
80107473:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107478:	e9 e5 f3 ff ff       	jmp    80106862 <alltraps>

8010747d <vector137>:
.globl vector137
vector137:
  pushl $0
8010747d:	6a 00                	push   $0x0
  pushl $137
8010747f:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107484:	e9 d9 f3 ff ff       	jmp    80106862 <alltraps>

80107489 <vector138>:
.globl vector138
vector138:
  pushl $0
80107489:	6a 00                	push   $0x0
  pushl $138
8010748b:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107490:	e9 cd f3 ff ff       	jmp    80106862 <alltraps>

80107495 <vector139>:
.globl vector139
vector139:
  pushl $0
80107495:	6a 00                	push   $0x0
  pushl $139
80107497:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010749c:	e9 c1 f3 ff ff       	jmp    80106862 <alltraps>

801074a1 <vector140>:
.globl vector140
vector140:
  pushl $0
801074a1:	6a 00                	push   $0x0
  pushl $140
801074a3:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801074a8:	e9 b5 f3 ff ff       	jmp    80106862 <alltraps>

801074ad <vector141>:
.globl vector141
vector141:
  pushl $0
801074ad:	6a 00                	push   $0x0
  pushl $141
801074af:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801074b4:	e9 a9 f3 ff ff       	jmp    80106862 <alltraps>

801074b9 <vector142>:
.globl vector142
vector142:
  pushl $0
801074b9:	6a 00                	push   $0x0
  pushl $142
801074bb:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801074c0:	e9 9d f3 ff ff       	jmp    80106862 <alltraps>

801074c5 <vector143>:
.globl vector143
vector143:
  pushl $0
801074c5:	6a 00                	push   $0x0
  pushl $143
801074c7:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801074cc:	e9 91 f3 ff ff       	jmp    80106862 <alltraps>

801074d1 <vector144>:
.globl vector144
vector144:
  pushl $0
801074d1:	6a 00                	push   $0x0
  pushl $144
801074d3:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801074d8:	e9 85 f3 ff ff       	jmp    80106862 <alltraps>

801074dd <vector145>:
.globl vector145
vector145:
  pushl $0
801074dd:	6a 00                	push   $0x0
  pushl $145
801074df:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801074e4:	e9 79 f3 ff ff       	jmp    80106862 <alltraps>

801074e9 <vector146>:
.globl vector146
vector146:
  pushl $0
801074e9:	6a 00                	push   $0x0
  pushl $146
801074eb:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801074f0:	e9 6d f3 ff ff       	jmp    80106862 <alltraps>

801074f5 <vector147>:
.globl vector147
vector147:
  pushl $0
801074f5:	6a 00                	push   $0x0
  pushl $147
801074f7:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801074fc:	e9 61 f3 ff ff       	jmp    80106862 <alltraps>

80107501 <vector148>:
.globl vector148
vector148:
  pushl $0
80107501:	6a 00                	push   $0x0
  pushl $148
80107503:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107508:	e9 55 f3 ff ff       	jmp    80106862 <alltraps>

8010750d <vector149>:
.globl vector149
vector149:
  pushl $0
8010750d:	6a 00                	push   $0x0
  pushl $149
8010750f:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107514:	e9 49 f3 ff ff       	jmp    80106862 <alltraps>

80107519 <vector150>:
.globl vector150
vector150:
  pushl $0
80107519:	6a 00                	push   $0x0
  pushl $150
8010751b:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107520:	e9 3d f3 ff ff       	jmp    80106862 <alltraps>

80107525 <vector151>:
.globl vector151
vector151:
  pushl $0
80107525:	6a 00                	push   $0x0
  pushl $151
80107527:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010752c:	e9 31 f3 ff ff       	jmp    80106862 <alltraps>

80107531 <vector152>:
.globl vector152
vector152:
  pushl $0
80107531:	6a 00                	push   $0x0
  pushl $152
80107533:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107538:	e9 25 f3 ff ff       	jmp    80106862 <alltraps>

8010753d <vector153>:
.globl vector153
vector153:
  pushl $0
8010753d:	6a 00                	push   $0x0
  pushl $153
8010753f:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107544:	e9 19 f3 ff ff       	jmp    80106862 <alltraps>

80107549 <vector154>:
.globl vector154
vector154:
  pushl $0
80107549:	6a 00                	push   $0x0
  pushl $154
8010754b:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107550:	e9 0d f3 ff ff       	jmp    80106862 <alltraps>

80107555 <vector155>:
.globl vector155
vector155:
  pushl $0
80107555:	6a 00                	push   $0x0
  pushl $155
80107557:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010755c:	e9 01 f3 ff ff       	jmp    80106862 <alltraps>

80107561 <vector156>:
.globl vector156
vector156:
  pushl $0
80107561:	6a 00                	push   $0x0
  pushl $156
80107563:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107568:	e9 f5 f2 ff ff       	jmp    80106862 <alltraps>

8010756d <vector157>:
.globl vector157
vector157:
  pushl $0
8010756d:	6a 00                	push   $0x0
  pushl $157
8010756f:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107574:	e9 e9 f2 ff ff       	jmp    80106862 <alltraps>

80107579 <vector158>:
.globl vector158
vector158:
  pushl $0
80107579:	6a 00                	push   $0x0
  pushl $158
8010757b:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107580:	e9 dd f2 ff ff       	jmp    80106862 <alltraps>

80107585 <vector159>:
.globl vector159
vector159:
  pushl $0
80107585:	6a 00                	push   $0x0
  pushl $159
80107587:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010758c:	e9 d1 f2 ff ff       	jmp    80106862 <alltraps>

80107591 <vector160>:
.globl vector160
vector160:
  pushl $0
80107591:	6a 00                	push   $0x0
  pushl $160
80107593:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107598:	e9 c5 f2 ff ff       	jmp    80106862 <alltraps>

8010759d <vector161>:
.globl vector161
vector161:
  pushl $0
8010759d:	6a 00                	push   $0x0
  pushl $161
8010759f:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801075a4:	e9 b9 f2 ff ff       	jmp    80106862 <alltraps>

801075a9 <vector162>:
.globl vector162
vector162:
  pushl $0
801075a9:	6a 00                	push   $0x0
  pushl $162
801075ab:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801075b0:	e9 ad f2 ff ff       	jmp    80106862 <alltraps>

801075b5 <vector163>:
.globl vector163
vector163:
  pushl $0
801075b5:	6a 00                	push   $0x0
  pushl $163
801075b7:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801075bc:	e9 a1 f2 ff ff       	jmp    80106862 <alltraps>

801075c1 <vector164>:
.globl vector164
vector164:
  pushl $0
801075c1:	6a 00                	push   $0x0
  pushl $164
801075c3:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801075c8:	e9 95 f2 ff ff       	jmp    80106862 <alltraps>

801075cd <vector165>:
.globl vector165
vector165:
  pushl $0
801075cd:	6a 00                	push   $0x0
  pushl $165
801075cf:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801075d4:	e9 89 f2 ff ff       	jmp    80106862 <alltraps>

801075d9 <vector166>:
.globl vector166
vector166:
  pushl $0
801075d9:	6a 00                	push   $0x0
  pushl $166
801075db:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801075e0:	e9 7d f2 ff ff       	jmp    80106862 <alltraps>

801075e5 <vector167>:
.globl vector167
vector167:
  pushl $0
801075e5:	6a 00                	push   $0x0
  pushl $167
801075e7:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801075ec:	e9 71 f2 ff ff       	jmp    80106862 <alltraps>

801075f1 <vector168>:
.globl vector168
vector168:
  pushl $0
801075f1:	6a 00                	push   $0x0
  pushl $168
801075f3:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801075f8:	e9 65 f2 ff ff       	jmp    80106862 <alltraps>

801075fd <vector169>:
.globl vector169
vector169:
  pushl $0
801075fd:	6a 00                	push   $0x0
  pushl $169
801075ff:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107604:	e9 59 f2 ff ff       	jmp    80106862 <alltraps>

80107609 <vector170>:
.globl vector170
vector170:
  pushl $0
80107609:	6a 00                	push   $0x0
  pushl $170
8010760b:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107610:	e9 4d f2 ff ff       	jmp    80106862 <alltraps>

80107615 <vector171>:
.globl vector171
vector171:
  pushl $0
80107615:	6a 00                	push   $0x0
  pushl $171
80107617:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010761c:	e9 41 f2 ff ff       	jmp    80106862 <alltraps>

80107621 <vector172>:
.globl vector172
vector172:
  pushl $0
80107621:	6a 00                	push   $0x0
  pushl $172
80107623:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107628:	e9 35 f2 ff ff       	jmp    80106862 <alltraps>

8010762d <vector173>:
.globl vector173
vector173:
  pushl $0
8010762d:	6a 00                	push   $0x0
  pushl $173
8010762f:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107634:	e9 29 f2 ff ff       	jmp    80106862 <alltraps>

80107639 <vector174>:
.globl vector174
vector174:
  pushl $0
80107639:	6a 00                	push   $0x0
  pushl $174
8010763b:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107640:	e9 1d f2 ff ff       	jmp    80106862 <alltraps>

80107645 <vector175>:
.globl vector175
vector175:
  pushl $0
80107645:	6a 00                	push   $0x0
  pushl $175
80107647:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010764c:	e9 11 f2 ff ff       	jmp    80106862 <alltraps>

80107651 <vector176>:
.globl vector176
vector176:
  pushl $0
80107651:	6a 00                	push   $0x0
  pushl $176
80107653:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107658:	e9 05 f2 ff ff       	jmp    80106862 <alltraps>

8010765d <vector177>:
.globl vector177
vector177:
  pushl $0
8010765d:	6a 00                	push   $0x0
  pushl $177
8010765f:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107664:	e9 f9 f1 ff ff       	jmp    80106862 <alltraps>

80107669 <vector178>:
.globl vector178
vector178:
  pushl $0
80107669:	6a 00                	push   $0x0
  pushl $178
8010766b:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107670:	e9 ed f1 ff ff       	jmp    80106862 <alltraps>

80107675 <vector179>:
.globl vector179
vector179:
  pushl $0
80107675:	6a 00                	push   $0x0
  pushl $179
80107677:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010767c:	e9 e1 f1 ff ff       	jmp    80106862 <alltraps>

80107681 <vector180>:
.globl vector180
vector180:
  pushl $0
80107681:	6a 00                	push   $0x0
  pushl $180
80107683:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107688:	e9 d5 f1 ff ff       	jmp    80106862 <alltraps>

8010768d <vector181>:
.globl vector181
vector181:
  pushl $0
8010768d:	6a 00                	push   $0x0
  pushl $181
8010768f:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107694:	e9 c9 f1 ff ff       	jmp    80106862 <alltraps>

80107699 <vector182>:
.globl vector182
vector182:
  pushl $0
80107699:	6a 00                	push   $0x0
  pushl $182
8010769b:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801076a0:	e9 bd f1 ff ff       	jmp    80106862 <alltraps>

801076a5 <vector183>:
.globl vector183
vector183:
  pushl $0
801076a5:	6a 00                	push   $0x0
  pushl $183
801076a7:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801076ac:	e9 b1 f1 ff ff       	jmp    80106862 <alltraps>

801076b1 <vector184>:
.globl vector184
vector184:
  pushl $0
801076b1:	6a 00                	push   $0x0
  pushl $184
801076b3:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801076b8:	e9 a5 f1 ff ff       	jmp    80106862 <alltraps>

801076bd <vector185>:
.globl vector185
vector185:
  pushl $0
801076bd:	6a 00                	push   $0x0
  pushl $185
801076bf:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801076c4:	e9 99 f1 ff ff       	jmp    80106862 <alltraps>

801076c9 <vector186>:
.globl vector186
vector186:
  pushl $0
801076c9:	6a 00                	push   $0x0
  pushl $186
801076cb:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801076d0:	e9 8d f1 ff ff       	jmp    80106862 <alltraps>

801076d5 <vector187>:
.globl vector187
vector187:
  pushl $0
801076d5:	6a 00                	push   $0x0
  pushl $187
801076d7:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801076dc:	e9 81 f1 ff ff       	jmp    80106862 <alltraps>

801076e1 <vector188>:
.globl vector188
vector188:
  pushl $0
801076e1:	6a 00                	push   $0x0
  pushl $188
801076e3:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801076e8:	e9 75 f1 ff ff       	jmp    80106862 <alltraps>

801076ed <vector189>:
.globl vector189
vector189:
  pushl $0
801076ed:	6a 00                	push   $0x0
  pushl $189
801076ef:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801076f4:	e9 69 f1 ff ff       	jmp    80106862 <alltraps>

801076f9 <vector190>:
.globl vector190
vector190:
  pushl $0
801076f9:	6a 00                	push   $0x0
  pushl $190
801076fb:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107700:	e9 5d f1 ff ff       	jmp    80106862 <alltraps>

80107705 <vector191>:
.globl vector191
vector191:
  pushl $0
80107705:	6a 00                	push   $0x0
  pushl $191
80107707:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010770c:	e9 51 f1 ff ff       	jmp    80106862 <alltraps>

80107711 <vector192>:
.globl vector192
vector192:
  pushl $0
80107711:	6a 00                	push   $0x0
  pushl $192
80107713:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107718:	e9 45 f1 ff ff       	jmp    80106862 <alltraps>

8010771d <vector193>:
.globl vector193
vector193:
  pushl $0
8010771d:	6a 00                	push   $0x0
  pushl $193
8010771f:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107724:	e9 39 f1 ff ff       	jmp    80106862 <alltraps>

80107729 <vector194>:
.globl vector194
vector194:
  pushl $0
80107729:	6a 00                	push   $0x0
  pushl $194
8010772b:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107730:	e9 2d f1 ff ff       	jmp    80106862 <alltraps>

80107735 <vector195>:
.globl vector195
vector195:
  pushl $0
80107735:	6a 00                	push   $0x0
  pushl $195
80107737:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010773c:	e9 21 f1 ff ff       	jmp    80106862 <alltraps>

80107741 <vector196>:
.globl vector196
vector196:
  pushl $0
80107741:	6a 00                	push   $0x0
  pushl $196
80107743:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107748:	e9 15 f1 ff ff       	jmp    80106862 <alltraps>

8010774d <vector197>:
.globl vector197
vector197:
  pushl $0
8010774d:	6a 00                	push   $0x0
  pushl $197
8010774f:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107754:	e9 09 f1 ff ff       	jmp    80106862 <alltraps>

80107759 <vector198>:
.globl vector198
vector198:
  pushl $0
80107759:	6a 00                	push   $0x0
  pushl $198
8010775b:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107760:	e9 fd f0 ff ff       	jmp    80106862 <alltraps>

80107765 <vector199>:
.globl vector199
vector199:
  pushl $0
80107765:	6a 00                	push   $0x0
  pushl $199
80107767:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010776c:	e9 f1 f0 ff ff       	jmp    80106862 <alltraps>

80107771 <vector200>:
.globl vector200
vector200:
  pushl $0
80107771:	6a 00                	push   $0x0
  pushl $200
80107773:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107778:	e9 e5 f0 ff ff       	jmp    80106862 <alltraps>

8010777d <vector201>:
.globl vector201
vector201:
  pushl $0
8010777d:	6a 00                	push   $0x0
  pushl $201
8010777f:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107784:	e9 d9 f0 ff ff       	jmp    80106862 <alltraps>

80107789 <vector202>:
.globl vector202
vector202:
  pushl $0
80107789:	6a 00                	push   $0x0
  pushl $202
8010778b:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107790:	e9 cd f0 ff ff       	jmp    80106862 <alltraps>

80107795 <vector203>:
.globl vector203
vector203:
  pushl $0
80107795:	6a 00                	push   $0x0
  pushl $203
80107797:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010779c:	e9 c1 f0 ff ff       	jmp    80106862 <alltraps>

801077a1 <vector204>:
.globl vector204
vector204:
  pushl $0
801077a1:	6a 00                	push   $0x0
  pushl $204
801077a3:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801077a8:	e9 b5 f0 ff ff       	jmp    80106862 <alltraps>

801077ad <vector205>:
.globl vector205
vector205:
  pushl $0
801077ad:	6a 00                	push   $0x0
  pushl $205
801077af:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801077b4:	e9 a9 f0 ff ff       	jmp    80106862 <alltraps>

801077b9 <vector206>:
.globl vector206
vector206:
  pushl $0
801077b9:	6a 00                	push   $0x0
  pushl $206
801077bb:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801077c0:	e9 9d f0 ff ff       	jmp    80106862 <alltraps>

801077c5 <vector207>:
.globl vector207
vector207:
  pushl $0
801077c5:	6a 00                	push   $0x0
  pushl $207
801077c7:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801077cc:	e9 91 f0 ff ff       	jmp    80106862 <alltraps>

801077d1 <vector208>:
.globl vector208
vector208:
  pushl $0
801077d1:	6a 00                	push   $0x0
  pushl $208
801077d3:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801077d8:	e9 85 f0 ff ff       	jmp    80106862 <alltraps>

801077dd <vector209>:
.globl vector209
vector209:
  pushl $0
801077dd:	6a 00                	push   $0x0
  pushl $209
801077df:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801077e4:	e9 79 f0 ff ff       	jmp    80106862 <alltraps>

801077e9 <vector210>:
.globl vector210
vector210:
  pushl $0
801077e9:	6a 00                	push   $0x0
  pushl $210
801077eb:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801077f0:	e9 6d f0 ff ff       	jmp    80106862 <alltraps>

801077f5 <vector211>:
.globl vector211
vector211:
  pushl $0
801077f5:	6a 00                	push   $0x0
  pushl $211
801077f7:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801077fc:	e9 61 f0 ff ff       	jmp    80106862 <alltraps>

80107801 <vector212>:
.globl vector212
vector212:
  pushl $0
80107801:	6a 00                	push   $0x0
  pushl $212
80107803:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107808:	e9 55 f0 ff ff       	jmp    80106862 <alltraps>

8010780d <vector213>:
.globl vector213
vector213:
  pushl $0
8010780d:	6a 00                	push   $0x0
  pushl $213
8010780f:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107814:	e9 49 f0 ff ff       	jmp    80106862 <alltraps>

80107819 <vector214>:
.globl vector214
vector214:
  pushl $0
80107819:	6a 00                	push   $0x0
  pushl $214
8010781b:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107820:	e9 3d f0 ff ff       	jmp    80106862 <alltraps>

80107825 <vector215>:
.globl vector215
vector215:
  pushl $0
80107825:	6a 00                	push   $0x0
  pushl $215
80107827:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010782c:	e9 31 f0 ff ff       	jmp    80106862 <alltraps>

80107831 <vector216>:
.globl vector216
vector216:
  pushl $0
80107831:	6a 00                	push   $0x0
  pushl $216
80107833:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107838:	e9 25 f0 ff ff       	jmp    80106862 <alltraps>

8010783d <vector217>:
.globl vector217
vector217:
  pushl $0
8010783d:	6a 00                	push   $0x0
  pushl $217
8010783f:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107844:	e9 19 f0 ff ff       	jmp    80106862 <alltraps>

80107849 <vector218>:
.globl vector218
vector218:
  pushl $0
80107849:	6a 00                	push   $0x0
  pushl $218
8010784b:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107850:	e9 0d f0 ff ff       	jmp    80106862 <alltraps>

80107855 <vector219>:
.globl vector219
vector219:
  pushl $0
80107855:	6a 00                	push   $0x0
  pushl $219
80107857:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010785c:	e9 01 f0 ff ff       	jmp    80106862 <alltraps>

80107861 <vector220>:
.globl vector220
vector220:
  pushl $0
80107861:	6a 00                	push   $0x0
  pushl $220
80107863:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107868:	e9 f5 ef ff ff       	jmp    80106862 <alltraps>

8010786d <vector221>:
.globl vector221
vector221:
  pushl $0
8010786d:	6a 00                	push   $0x0
  pushl $221
8010786f:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107874:	e9 e9 ef ff ff       	jmp    80106862 <alltraps>

80107879 <vector222>:
.globl vector222
vector222:
  pushl $0
80107879:	6a 00                	push   $0x0
  pushl $222
8010787b:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107880:	e9 dd ef ff ff       	jmp    80106862 <alltraps>

80107885 <vector223>:
.globl vector223
vector223:
  pushl $0
80107885:	6a 00                	push   $0x0
  pushl $223
80107887:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010788c:	e9 d1 ef ff ff       	jmp    80106862 <alltraps>

80107891 <vector224>:
.globl vector224
vector224:
  pushl $0
80107891:	6a 00                	push   $0x0
  pushl $224
80107893:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107898:	e9 c5 ef ff ff       	jmp    80106862 <alltraps>

8010789d <vector225>:
.globl vector225
vector225:
  pushl $0
8010789d:	6a 00                	push   $0x0
  pushl $225
8010789f:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801078a4:	e9 b9 ef ff ff       	jmp    80106862 <alltraps>

801078a9 <vector226>:
.globl vector226
vector226:
  pushl $0
801078a9:	6a 00                	push   $0x0
  pushl $226
801078ab:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801078b0:	e9 ad ef ff ff       	jmp    80106862 <alltraps>

801078b5 <vector227>:
.globl vector227
vector227:
  pushl $0
801078b5:	6a 00                	push   $0x0
  pushl $227
801078b7:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801078bc:	e9 a1 ef ff ff       	jmp    80106862 <alltraps>

801078c1 <vector228>:
.globl vector228
vector228:
  pushl $0
801078c1:	6a 00                	push   $0x0
  pushl $228
801078c3:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801078c8:	e9 95 ef ff ff       	jmp    80106862 <alltraps>

801078cd <vector229>:
.globl vector229
vector229:
  pushl $0
801078cd:	6a 00                	push   $0x0
  pushl $229
801078cf:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801078d4:	e9 89 ef ff ff       	jmp    80106862 <alltraps>

801078d9 <vector230>:
.globl vector230
vector230:
  pushl $0
801078d9:	6a 00                	push   $0x0
  pushl $230
801078db:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801078e0:	e9 7d ef ff ff       	jmp    80106862 <alltraps>

801078e5 <vector231>:
.globl vector231
vector231:
  pushl $0
801078e5:	6a 00                	push   $0x0
  pushl $231
801078e7:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801078ec:	e9 71 ef ff ff       	jmp    80106862 <alltraps>

801078f1 <vector232>:
.globl vector232
vector232:
  pushl $0
801078f1:	6a 00                	push   $0x0
  pushl $232
801078f3:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801078f8:	e9 65 ef ff ff       	jmp    80106862 <alltraps>

801078fd <vector233>:
.globl vector233
vector233:
  pushl $0
801078fd:	6a 00                	push   $0x0
  pushl $233
801078ff:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107904:	e9 59 ef ff ff       	jmp    80106862 <alltraps>

80107909 <vector234>:
.globl vector234
vector234:
  pushl $0
80107909:	6a 00                	push   $0x0
  pushl $234
8010790b:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107910:	e9 4d ef ff ff       	jmp    80106862 <alltraps>

80107915 <vector235>:
.globl vector235
vector235:
  pushl $0
80107915:	6a 00                	push   $0x0
  pushl $235
80107917:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010791c:	e9 41 ef ff ff       	jmp    80106862 <alltraps>

80107921 <vector236>:
.globl vector236
vector236:
  pushl $0
80107921:	6a 00                	push   $0x0
  pushl $236
80107923:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107928:	e9 35 ef ff ff       	jmp    80106862 <alltraps>

8010792d <vector237>:
.globl vector237
vector237:
  pushl $0
8010792d:	6a 00                	push   $0x0
  pushl $237
8010792f:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107934:	e9 29 ef ff ff       	jmp    80106862 <alltraps>

80107939 <vector238>:
.globl vector238
vector238:
  pushl $0
80107939:	6a 00                	push   $0x0
  pushl $238
8010793b:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107940:	e9 1d ef ff ff       	jmp    80106862 <alltraps>

80107945 <vector239>:
.globl vector239
vector239:
  pushl $0
80107945:	6a 00                	push   $0x0
  pushl $239
80107947:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010794c:	e9 11 ef ff ff       	jmp    80106862 <alltraps>

80107951 <vector240>:
.globl vector240
vector240:
  pushl $0
80107951:	6a 00                	push   $0x0
  pushl $240
80107953:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107958:	e9 05 ef ff ff       	jmp    80106862 <alltraps>

8010795d <vector241>:
.globl vector241
vector241:
  pushl $0
8010795d:	6a 00                	push   $0x0
  pushl $241
8010795f:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107964:	e9 f9 ee ff ff       	jmp    80106862 <alltraps>

80107969 <vector242>:
.globl vector242
vector242:
  pushl $0
80107969:	6a 00                	push   $0x0
  pushl $242
8010796b:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107970:	e9 ed ee ff ff       	jmp    80106862 <alltraps>

80107975 <vector243>:
.globl vector243
vector243:
  pushl $0
80107975:	6a 00                	push   $0x0
  pushl $243
80107977:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010797c:	e9 e1 ee ff ff       	jmp    80106862 <alltraps>

80107981 <vector244>:
.globl vector244
vector244:
  pushl $0
80107981:	6a 00                	push   $0x0
  pushl $244
80107983:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107988:	e9 d5 ee ff ff       	jmp    80106862 <alltraps>

8010798d <vector245>:
.globl vector245
vector245:
  pushl $0
8010798d:	6a 00                	push   $0x0
  pushl $245
8010798f:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107994:	e9 c9 ee ff ff       	jmp    80106862 <alltraps>

80107999 <vector246>:
.globl vector246
vector246:
  pushl $0
80107999:	6a 00                	push   $0x0
  pushl $246
8010799b:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801079a0:	e9 bd ee ff ff       	jmp    80106862 <alltraps>

801079a5 <vector247>:
.globl vector247
vector247:
  pushl $0
801079a5:	6a 00                	push   $0x0
  pushl $247
801079a7:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801079ac:	e9 b1 ee ff ff       	jmp    80106862 <alltraps>

801079b1 <vector248>:
.globl vector248
vector248:
  pushl $0
801079b1:	6a 00                	push   $0x0
  pushl $248
801079b3:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801079b8:	e9 a5 ee ff ff       	jmp    80106862 <alltraps>

801079bd <vector249>:
.globl vector249
vector249:
  pushl $0
801079bd:	6a 00                	push   $0x0
  pushl $249
801079bf:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801079c4:	e9 99 ee ff ff       	jmp    80106862 <alltraps>

801079c9 <vector250>:
.globl vector250
vector250:
  pushl $0
801079c9:	6a 00                	push   $0x0
  pushl $250
801079cb:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801079d0:	e9 8d ee ff ff       	jmp    80106862 <alltraps>

801079d5 <vector251>:
.globl vector251
vector251:
  pushl $0
801079d5:	6a 00                	push   $0x0
  pushl $251
801079d7:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801079dc:	e9 81 ee ff ff       	jmp    80106862 <alltraps>

801079e1 <vector252>:
.globl vector252
vector252:
  pushl $0
801079e1:	6a 00                	push   $0x0
  pushl $252
801079e3:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801079e8:	e9 75 ee ff ff       	jmp    80106862 <alltraps>

801079ed <vector253>:
.globl vector253
vector253:
  pushl $0
801079ed:	6a 00                	push   $0x0
  pushl $253
801079ef:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801079f4:	e9 69 ee ff ff       	jmp    80106862 <alltraps>

801079f9 <vector254>:
.globl vector254
vector254:
  pushl $0
801079f9:	6a 00                	push   $0x0
  pushl $254
801079fb:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107a00:	e9 5d ee ff ff       	jmp    80106862 <alltraps>

80107a05 <vector255>:
.globl vector255
vector255:
  pushl $0
80107a05:	6a 00                	push   $0x0
  pushl $255
80107a07:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107a0c:	e9 51 ee ff ff       	jmp    80106862 <alltraps>

80107a11 <lgdt>:
{
80107a11:	55                   	push   %ebp
80107a12:	89 e5                	mov    %esp,%ebp
80107a14:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107a17:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a1a:	83 e8 01             	sub    $0x1,%eax
80107a1d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107a21:	8b 45 08             	mov    0x8(%ebp),%eax
80107a24:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107a28:	8b 45 08             	mov    0x8(%ebp),%eax
80107a2b:	c1 e8 10             	shr    $0x10,%eax
80107a2e:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107a32:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107a35:	0f 01 10             	lgdtl  (%eax)
}
80107a38:	90                   	nop
80107a39:	c9                   	leave
80107a3a:	c3                   	ret

80107a3b <ltr>:
{
80107a3b:	55                   	push   %ebp
80107a3c:	89 e5                	mov    %esp,%ebp
80107a3e:	83 ec 04             	sub    $0x4,%esp
80107a41:	8b 45 08             	mov    0x8(%ebp),%eax
80107a44:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107a48:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a4c:	0f 00 d8             	ltr    %eax
}
80107a4f:	90                   	nop
80107a50:	c9                   	leave
80107a51:	c3                   	ret

80107a52 <lcr3>:

static inline void
lcr3(uint val)
{
80107a52:	55                   	push   %ebp
80107a53:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a55:	8b 45 08             	mov    0x8(%ebp),%eax
80107a58:	0f 22 d8             	mov    %eax,%cr3
}
80107a5b:	90                   	nop
80107a5c:	5d                   	pop    %ebp
80107a5d:	c3                   	ret

80107a5e <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107a5e:	55                   	push   %ebp
80107a5f:	89 e5                	mov    %esp,%ebp
80107a61:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107a64:	e8 34 bf ff ff       	call   8010399d <cpuid>
80107a69:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
80107a6f:	05 a0 79 19 80       	add    $0x801979a0,%eax
80107a74:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7a:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a83:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8c:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a93:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a97:	83 e2 f0             	and    $0xfffffff0,%edx
80107a9a:	83 ca 0a             	or     $0xa,%edx
80107a9d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107aa7:	83 ca 10             	or     $0x10,%edx
80107aaa:	88 50 7d             	mov    %dl,0x7d(%eax)
80107aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ab4:	83 e2 9f             	and    $0xffffff9f,%edx
80107ab7:	88 50 7d             	mov    %dl,0x7d(%eax)
80107aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abd:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ac1:	83 ca 80             	or     $0xffffff80,%edx
80107ac4:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aca:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ace:	83 ca 0f             	or     $0xf,%edx
80107ad1:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107adb:	83 e2 ef             	and    $0xffffffef,%edx
80107ade:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ae8:	83 e2 df             	and    $0xffffffdf,%edx
80107aeb:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107af5:	83 ca 40             	or     $0x40,%edx
80107af8:	88 50 7e             	mov    %dl,0x7e(%eax)
80107afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afe:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b02:	83 ca 80             	or     $0xffffff80,%edx
80107b05:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0b:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b12:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107b19:	ff ff 
80107b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1e:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107b25:	00 00 
80107b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2a:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b34:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b3b:	83 e2 f0             	and    $0xfffffff0,%edx
80107b3e:	83 ca 02             	or     $0x2,%edx
80107b41:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b51:	83 ca 10             	or     $0x10,%edx
80107b54:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b64:	83 e2 9f             	and    $0xffffff9f,%edx
80107b67:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b70:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b77:	83 ca 80             	or     $0xffffff80,%edx
80107b7a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b83:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b8a:	83 ca 0f             	or     $0xf,%edx
80107b8d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b96:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b9d:	83 e2 ef             	and    $0xffffffef,%edx
80107ba0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bb0:	83 e2 df             	and    $0xffffffdf,%edx
80107bb3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbc:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bc3:	83 ca 40             	or     $0x40,%edx
80107bc6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcf:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bd6:	83 ca 80             	or     $0xffffff80,%edx
80107bd9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be2:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bec:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107bf3:	ff ff 
80107bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf8:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107bff:	00 00 
80107c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c04:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107c15:	83 e2 f0             	and    $0xfffffff0,%edx
80107c18:	83 ca 0a             	or     $0xa,%edx
80107c1b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c24:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107c2b:	83 ca 10             	or     $0x10,%edx
80107c2e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c37:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107c3e:	83 ca 60             	or     $0x60,%edx
80107c41:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107c51:	83 ca 80             	or     $0xffffff80,%edx
80107c54:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c64:	83 ca 0f             	or     $0xf,%edx
80107c67:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c70:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c77:	83 e2 ef             	and    $0xffffffef,%edx
80107c7a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c83:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c8a:	83 e2 df             	and    $0xffffffdf,%edx
80107c8d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c96:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c9d:	83 ca 40             	or     $0x40,%edx
80107ca0:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca9:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107cb0:	83 ca 80             	or     $0xffffff80,%edx
80107cb3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbc:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc6:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107ccd:	ff ff 
80107ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd2:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107cd9:	00 00 
80107cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cde:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107cef:	83 e2 f0             	and    $0xfffffff0,%edx
80107cf2:	83 ca 02             	or     $0x2,%edx
80107cf5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfe:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d05:	83 ca 10             	or     $0x10,%edx
80107d08:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d11:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d18:	83 ca 60             	or     $0x60,%edx
80107d1b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d24:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d2b:	83 ca 80             	or     $0xffffff80,%edx
80107d2e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d37:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d3e:	83 ca 0f             	or     $0xf,%edx
80107d41:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d51:	83 e2 ef             	and    $0xffffffef,%edx
80107d54:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d64:	83 e2 df             	and    $0xffffffdf,%edx
80107d67:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d70:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d77:	83 ca 40             	or     $0x40,%edx
80107d7a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d83:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d8a:	83 ca 80             	or     $0xffffff80,%edx
80107d8d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d96:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da0:	83 c0 70             	add    $0x70,%eax
80107da3:	83 ec 08             	sub    $0x8,%esp
80107da6:	6a 30                	push   $0x30
80107da8:	50                   	push   %eax
80107da9:	e8 63 fc ff ff       	call   80107a11 <lgdt>
80107dae:	83 c4 10             	add    $0x10,%esp
}
80107db1:	90                   	nop
80107db2:	c9                   	leave
80107db3:	c3                   	ret

80107db4 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107db4:	55                   	push   %ebp
80107db5:	89 e5                	mov    %esp,%ebp
80107db7:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107dba:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dbd:	c1 e8 16             	shr    $0x16,%eax
80107dc0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107dc7:	8b 45 08             	mov    0x8(%ebp),%eax
80107dca:	01 d0                	add    %edx,%eax
80107dcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dd2:	8b 00                	mov    (%eax),%eax
80107dd4:	83 e0 01             	and    $0x1,%eax
80107dd7:	85 c0                	test   %eax,%eax
80107dd9:	74 14                	je     80107def <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dde:	8b 00                	mov    (%eax),%eax
80107de0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107de5:	05 00 00 00 80       	add    $0x80000000,%eax
80107dea:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ded:	eb 42                	jmp    80107e31 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107def:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107df3:	74 0e                	je     80107e03 <walkpgdir+0x4f>
80107df5:	e8 ae a9 ff ff       	call   801027a8 <kalloc>
80107dfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107dfd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e01:	75 07                	jne    80107e0a <walkpgdir+0x56>
      return 0;
80107e03:	b8 00 00 00 00       	mov    $0x0,%eax
80107e08:	eb 3e                	jmp    80107e48 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107e0a:	83 ec 04             	sub    $0x4,%esp
80107e0d:	68 00 10 00 00       	push   $0x1000
80107e12:	6a 00                	push   $0x0
80107e14:	ff 75 f4             	push   -0xc(%ebp)
80107e17:	e8 37 d6 ff ff       	call   80105453 <memset>
80107e1c:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e22:	05 00 00 00 80       	add    $0x80000000,%eax
80107e27:	83 c8 07             	or     $0x7,%eax
80107e2a:	89 c2                	mov    %eax,%edx
80107e2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e2f:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107e31:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e34:	c1 e8 0c             	shr    $0xc,%eax
80107e37:	25 ff 03 00 00       	and    $0x3ff,%eax
80107e3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e46:	01 d0                	add    %edx,%eax
}
80107e48:	c9                   	leave
80107e49:	c3                   	ret

80107e4a <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107e4a:	55                   	push   %ebp
80107e4b:	89 e5                	mov    %esp,%ebp
80107e4d:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107e50:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107e5b:	8b 55 0c             	mov    0xc(%ebp),%edx
80107e5e:	8b 45 10             	mov    0x10(%ebp),%eax
80107e61:	01 d0                	add    %edx,%eax
80107e63:	83 e8 01             	sub    $0x1,%eax
80107e66:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107e6e:	83 ec 04             	sub    $0x4,%esp
80107e71:	6a 01                	push   $0x1
80107e73:	ff 75 f4             	push   -0xc(%ebp)
80107e76:	ff 75 08             	push   0x8(%ebp)
80107e79:	e8 36 ff ff ff       	call   80107db4 <walkpgdir>
80107e7e:	83 c4 10             	add    $0x10,%esp
80107e81:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e84:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e88:	75 07                	jne    80107e91 <mappages+0x47>
      return -1;
80107e8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e8f:	eb 47                	jmp    80107ed8 <mappages+0x8e>
    if(*pte & PTE_P)
80107e91:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e94:	8b 00                	mov    (%eax),%eax
80107e96:	83 e0 01             	and    $0x1,%eax
80107e99:	85 c0                	test   %eax,%eax
80107e9b:	74 0d                	je     80107eaa <mappages+0x60>
      panic("remap");
80107e9d:	83 ec 0c             	sub    $0xc,%esp
80107ea0:	68 28 b3 10 80       	push   $0x8010b328
80107ea5:	e8 ff 86 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107eaa:	8b 45 18             	mov    0x18(%ebp),%eax
80107ead:	0b 45 14             	or     0x14(%ebp),%eax
80107eb0:	83 c8 01             	or     $0x1,%eax
80107eb3:	89 c2                	mov    %eax,%edx
80107eb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107eb8:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107ec0:	74 10                	je     80107ed2 <mappages+0x88>
      break;
    a += PGSIZE;
80107ec2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107ec9:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107ed0:	eb 9c                	jmp    80107e6e <mappages+0x24>
      break;
80107ed2:	90                   	nop
  }
  return 0;
80107ed3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ed8:	c9                   	leave
80107ed9:	c3                   	ret

80107eda <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107eda:	55                   	push   %ebp
80107edb:	89 e5                	mov    %esp,%ebp
80107edd:	53                   	push   %ebx
80107ede:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107ee1:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107ee8:	a1 64 7a 19 80       	mov    0x80197a64,%eax
80107eed:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107ef2:	29 c2                	sub    %eax,%edx
80107ef4:	89 d0                	mov    %edx,%eax
80107ef6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107ef9:	a1 5c 7a 19 80       	mov    0x80197a5c,%eax
80107efe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107f01:	8b 15 5c 7a 19 80    	mov    0x80197a5c,%edx
80107f07:	a1 64 7a 19 80       	mov    0x80197a64,%eax
80107f0c:	01 d0                	add    %edx,%eax
80107f0e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107f11:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1b:	83 c0 30             	add    $0x30,%eax
80107f1e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107f21:	89 10                	mov    %edx,(%eax)
80107f23:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107f26:	89 50 04             	mov    %edx,0x4(%eax)
80107f29:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107f2c:	89 50 08             	mov    %edx,0x8(%eax)
80107f2f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107f32:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107f35:	e8 6e a8 ff ff       	call   801027a8 <kalloc>
80107f3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f3d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f41:	75 07                	jne    80107f4a <setupkvm+0x70>
    return 0;
80107f43:	b8 00 00 00 00       	mov    $0x0,%eax
80107f48:	eb 78                	jmp    80107fc2 <setupkvm+0xe8>
  }
  memset(pgdir, 0, PGSIZE);
80107f4a:	83 ec 04             	sub    $0x4,%esp
80107f4d:	68 00 10 00 00       	push   $0x1000
80107f52:	6a 00                	push   $0x0
80107f54:	ff 75 f0             	push   -0x10(%ebp)
80107f57:	e8 f7 d4 ff ff       	call   80105453 <memset>
80107f5c:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f5f:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107f66:	eb 4e                	jmp    80107fb6 <setupkvm+0xdc>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6b:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f71:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107f74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f77:	8b 58 08             	mov    0x8(%eax),%ebx
80107f7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7d:	8b 40 04             	mov    0x4(%eax),%eax
80107f80:	29 c3                	sub    %eax,%ebx
80107f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f85:	8b 00                	mov    (%eax),%eax
80107f87:	83 ec 0c             	sub    $0xc,%esp
80107f8a:	51                   	push   %ecx
80107f8b:	52                   	push   %edx
80107f8c:	53                   	push   %ebx
80107f8d:	50                   	push   %eax
80107f8e:	ff 75 f0             	push   -0x10(%ebp)
80107f91:	e8 b4 fe ff ff       	call   80107e4a <mappages>
80107f96:	83 c4 20             	add    $0x20,%esp
80107f99:	85 c0                	test   %eax,%eax
80107f9b:	79 15                	jns    80107fb2 <setupkvm+0xd8>
      freevm(pgdir);
80107f9d:	83 ec 0c             	sub    $0xc,%esp
80107fa0:	ff 75 f0             	push   -0x10(%ebp)
80107fa3:	e8 f5 04 00 00       	call   8010849d <freevm>
80107fa8:	83 c4 10             	add    $0x10,%esp
      return 0;
80107fab:	b8 00 00 00 00       	mov    $0x0,%eax
80107fb0:	eb 10                	jmp    80107fc2 <setupkvm+0xe8>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107fb2:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107fb6:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80107fbd:	72 a9                	jb     80107f68 <setupkvm+0x8e>
    }
  return pgdir;
80107fbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107fc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107fc5:	c9                   	leave
80107fc6:	c3                   	ret

80107fc7 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107fc7:	55                   	push   %ebp
80107fc8:	89 e5                	mov    %esp,%ebp
80107fca:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107fcd:	e8 08 ff ff ff       	call   80107eda <setupkvm>
80107fd2:	a3 9c 79 19 80       	mov    %eax,0x8019799c
  switchkvm();
80107fd7:	e8 03 00 00 00       	call   80107fdf <switchkvm>
}
80107fdc:	90                   	nop
80107fdd:	c9                   	leave
80107fde:	c3                   	ret

80107fdf <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107fdf:	55                   	push   %ebp
80107fe0:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107fe2:	a1 9c 79 19 80       	mov    0x8019799c,%eax
80107fe7:	05 00 00 00 80       	add    $0x80000000,%eax
80107fec:	50                   	push   %eax
80107fed:	e8 60 fa ff ff       	call   80107a52 <lcr3>
80107ff2:	83 c4 04             	add    $0x4,%esp
}
80107ff5:	90                   	nop
80107ff6:	c9                   	leave
80107ff7:	c3                   	ret

80107ff8 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107ff8:	55                   	push   %ebp
80107ff9:	89 e5                	mov    %esp,%ebp
80107ffb:	56                   	push   %esi
80107ffc:	53                   	push   %ebx
80107ffd:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80108000:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108004:	75 0d                	jne    80108013 <switchuvm+0x1b>
    panic("switchuvm: no process");
80108006:	83 ec 0c             	sub    $0xc,%esp
80108009:	68 2e b3 10 80       	push   $0x8010b32e
8010800e:	e8 96 85 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80108013:	8b 45 08             	mov    0x8(%ebp),%eax
80108016:	8b 40 08             	mov    0x8(%eax),%eax
80108019:	85 c0                	test   %eax,%eax
8010801b:	75 0d                	jne    8010802a <switchuvm+0x32>
    panic("switchuvm: no kstack");
8010801d:	83 ec 0c             	sub    $0xc,%esp
80108020:	68 44 b3 10 80       	push   $0x8010b344
80108025:	e8 7f 85 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
8010802a:	8b 45 08             	mov    0x8(%ebp),%eax
8010802d:	8b 40 04             	mov    0x4(%eax),%eax
80108030:	85 c0                	test   %eax,%eax
80108032:	75 0d                	jne    80108041 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80108034:	83 ec 0c             	sub    $0xc,%esp
80108037:	68 59 b3 10 80       	push   $0x8010b359
8010803c:	e8 68 85 ff ff       	call   801005a9 <panic>

  pushcli();
80108041:	e8 02 d3 ff ff       	call   80105348 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80108046:	e8 6d b9 ff ff       	call   801039b8 <mycpu>
8010804b:	89 c3                	mov    %eax,%ebx
8010804d:	e8 66 b9 ff ff       	call   801039b8 <mycpu>
80108052:	83 c0 08             	add    $0x8,%eax
80108055:	89 c6                	mov    %eax,%esi
80108057:	e8 5c b9 ff ff       	call   801039b8 <mycpu>
8010805c:	83 c0 08             	add    $0x8,%eax
8010805f:	c1 e8 10             	shr    $0x10,%eax
80108062:	88 45 f7             	mov    %al,-0x9(%ebp)
80108065:	e8 4e b9 ff ff       	call   801039b8 <mycpu>
8010806a:	83 c0 08             	add    $0x8,%eax
8010806d:	c1 e8 18             	shr    $0x18,%eax
80108070:	89 c2                	mov    %eax,%edx
80108072:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108079:	67 00 
8010807b:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108082:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80108086:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
8010808c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108093:	83 e0 f0             	and    $0xfffffff0,%eax
80108096:	83 c8 09             	or     $0x9,%eax
80108099:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010809f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801080a6:	83 c8 10             	or     $0x10,%eax
801080a9:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801080af:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801080b6:	83 e0 9f             	and    $0xffffff9f,%eax
801080b9:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801080bf:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801080c6:	83 c8 80             	or     $0xffffff80,%eax
801080c9:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801080cf:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801080d6:	83 e0 f0             	and    $0xfffffff0,%eax
801080d9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801080df:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801080e6:	83 e0 ef             	and    $0xffffffef,%eax
801080e9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801080ef:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801080f6:	83 e0 df             	and    $0xffffffdf,%eax
801080f9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801080ff:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108106:	83 c8 40             	or     $0x40,%eax
80108109:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010810f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108116:	83 e0 7f             	and    $0x7f,%eax
80108119:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010811f:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108125:	e8 8e b8 ff ff       	call   801039b8 <mycpu>
8010812a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108131:	83 e2 ef             	and    $0xffffffef,%edx
80108134:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010813a:	e8 79 b8 ff ff       	call   801039b8 <mycpu>
8010813f:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108145:	8b 45 08             	mov    0x8(%ebp),%eax
80108148:	8b 40 08             	mov    0x8(%eax),%eax
8010814b:	89 c3                	mov    %eax,%ebx
8010814d:	e8 66 b8 ff ff       	call   801039b8 <mycpu>
80108152:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80108158:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010815b:	e8 58 b8 ff ff       	call   801039b8 <mycpu>
80108160:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108166:	83 ec 0c             	sub    $0xc,%esp
80108169:	6a 28                	push   $0x28
8010816b:	e8 cb f8 ff ff       	call   80107a3b <ltr>
80108170:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108173:	8b 45 08             	mov    0x8(%ebp),%eax
80108176:	8b 40 04             	mov    0x4(%eax),%eax
80108179:	05 00 00 00 80       	add    $0x80000000,%eax
8010817e:	83 ec 0c             	sub    $0xc,%esp
80108181:	50                   	push   %eax
80108182:	e8 cb f8 ff ff       	call   80107a52 <lcr3>
80108187:	83 c4 10             	add    $0x10,%esp
  popcli();
8010818a:	e8 06 d2 ff ff       	call   80105395 <popcli>
}
8010818f:	90                   	nop
80108190:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108193:	5b                   	pop    %ebx
80108194:	5e                   	pop    %esi
80108195:	5d                   	pop    %ebp
80108196:	c3                   	ret

80108197 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108197:	55                   	push   %ebp
80108198:	89 e5                	mov    %esp,%ebp
8010819a:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
8010819d:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801081a4:	76 0d                	jbe    801081b3 <inituvm+0x1c>
    panic("inituvm: more than a page");
801081a6:	83 ec 0c             	sub    $0xc,%esp
801081a9:	68 6d b3 10 80       	push   $0x8010b36d
801081ae:	e8 f6 83 ff ff       	call   801005a9 <panic>
  mem = kalloc();
801081b3:	e8 f0 a5 ff ff       	call   801027a8 <kalloc>
801081b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801081bb:	83 ec 04             	sub    $0x4,%esp
801081be:	68 00 10 00 00       	push   $0x1000
801081c3:	6a 00                	push   $0x0
801081c5:	ff 75 f4             	push   -0xc(%ebp)
801081c8:	e8 86 d2 ff ff       	call   80105453 <memset>
801081cd:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801081d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d3:	05 00 00 00 80       	add    $0x80000000,%eax
801081d8:	83 ec 0c             	sub    $0xc,%esp
801081db:	6a 06                	push   $0x6
801081dd:	50                   	push   %eax
801081de:	68 00 10 00 00       	push   $0x1000
801081e3:	6a 00                	push   $0x0
801081e5:	ff 75 08             	push   0x8(%ebp)
801081e8:	e8 5d fc ff ff       	call   80107e4a <mappages>
801081ed:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801081f0:	83 ec 04             	sub    $0x4,%esp
801081f3:	ff 75 10             	push   0x10(%ebp)
801081f6:	ff 75 0c             	push   0xc(%ebp)
801081f9:	ff 75 f4             	push   -0xc(%ebp)
801081fc:	e8 11 d3 ff ff       	call   80105512 <memmove>
80108201:	83 c4 10             	add    $0x10,%esp
}
80108204:	90                   	nop
80108205:	c9                   	leave
80108206:	c3                   	ret

80108207 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108207:	55                   	push   %ebp
80108208:	89 e5                	mov    %esp,%ebp
8010820a:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010820d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108210:	25 ff 0f 00 00       	and    $0xfff,%eax
80108215:	85 c0                	test   %eax,%eax
80108217:	74 0d                	je     80108226 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108219:	83 ec 0c             	sub    $0xc,%esp
8010821c:	68 88 b3 10 80       	push   $0x8010b388
80108221:	e8 83 83 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108226:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010822d:	e9 8f 00 00 00       	jmp    801082c1 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108232:	8b 55 0c             	mov    0xc(%ebp),%edx
80108235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108238:	01 d0                	add    %edx,%eax
8010823a:	83 ec 04             	sub    $0x4,%esp
8010823d:	6a 00                	push   $0x0
8010823f:	50                   	push   %eax
80108240:	ff 75 08             	push   0x8(%ebp)
80108243:	e8 6c fb ff ff       	call   80107db4 <walkpgdir>
80108248:	83 c4 10             	add    $0x10,%esp
8010824b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010824e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108252:	75 0d                	jne    80108261 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80108254:	83 ec 0c             	sub    $0xc,%esp
80108257:	68 ab b3 10 80       	push   $0x8010b3ab
8010825c:	e8 48 83 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80108261:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108264:	8b 00                	mov    (%eax),%eax
80108266:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010826b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010826e:	8b 45 18             	mov    0x18(%ebp),%eax
80108271:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108274:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108279:	77 0b                	ja     80108286 <loaduvm+0x7f>
      n = sz - i;
8010827b:	8b 45 18             	mov    0x18(%ebp),%eax
8010827e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108281:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108284:	eb 07                	jmp    8010828d <loaduvm+0x86>
    else
      n = PGSIZE;
80108286:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010828d:	8b 55 14             	mov    0x14(%ebp),%edx
80108290:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108293:	01 d0                	add    %edx,%eax
80108295:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108298:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010829e:	ff 75 f0             	push   -0x10(%ebp)
801082a1:	50                   	push   %eax
801082a2:	52                   	push   %edx
801082a3:	ff 75 10             	push   0x10(%ebp)
801082a6:	e8 33 9c ff ff       	call   80101ede <readi>
801082ab:	83 c4 10             	add    $0x10,%esp
801082ae:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801082b1:	74 07                	je     801082ba <loaduvm+0xb3>
      return -1;
801082b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801082b8:	eb 18                	jmp    801082d2 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
801082ba:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c4:	3b 45 18             	cmp    0x18(%ebp),%eax
801082c7:	0f 82 65 ff ff ff    	jb     80108232 <loaduvm+0x2b>
  }
  return 0;
801082cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801082d2:	c9                   	leave
801082d3:	c3                   	ret

801082d4 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801082d4:	55                   	push   %ebp
801082d5:	89 e5                	mov    %esp,%ebp
801082d7:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801082da:	8b 45 10             	mov    0x10(%ebp),%eax
801082dd:	85 c0                	test   %eax,%eax
801082df:	79 0a                	jns    801082eb <allocuvm+0x17>
    return 0;
801082e1:	b8 00 00 00 00       	mov    $0x0,%eax
801082e6:	e9 ec 00 00 00       	jmp    801083d7 <allocuvm+0x103>
  if(newsz < oldsz)
801082eb:	8b 45 10             	mov    0x10(%ebp),%eax
801082ee:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082f1:	73 08                	jae    801082fb <allocuvm+0x27>
    return oldsz;
801082f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801082f6:	e9 dc 00 00 00       	jmp    801083d7 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
801082fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801082fe:	05 ff 0f 00 00       	add    $0xfff,%eax
80108303:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108308:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010830b:	e9 b8 00 00 00       	jmp    801083c8 <allocuvm+0xf4>
    mem = kalloc();
80108310:	e8 93 a4 ff ff       	call   801027a8 <kalloc>
80108315:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108318:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010831c:	75 2e                	jne    8010834c <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
8010831e:	83 ec 0c             	sub    $0xc,%esp
80108321:	68 c9 b3 10 80       	push   $0x8010b3c9
80108326:	e8 c9 80 ff ff       	call   801003f4 <cprintf>
8010832b:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010832e:	83 ec 04             	sub    $0x4,%esp
80108331:	ff 75 0c             	push   0xc(%ebp)
80108334:	ff 75 10             	push   0x10(%ebp)
80108337:	ff 75 08             	push   0x8(%ebp)
8010833a:	e8 9a 00 00 00       	call   801083d9 <deallocuvm>
8010833f:	83 c4 10             	add    $0x10,%esp
      return 0;
80108342:	b8 00 00 00 00       	mov    $0x0,%eax
80108347:	e9 8b 00 00 00       	jmp    801083d7 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
8010834c:	83 ec 04             	sub    $0x4,%esp
8010834f:	68 00 10 00 00       	push   $0x1000
80108354:	6a 00                	push   $0x0
80108356:	ff 75 f0             	push   -0x10(%ebp)
80108359:	e8 f5 d0 ff ff       	call   80105453 <memset>
8010835e:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108361:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108364:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010836a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836d:	83 ec 0c             	sub    $0xc,%esp
80108370:	6a 06                	push   $0x6
80108372:	52                   	push   %edx
80108373:	68 00 10 00 00       	push   $0x1000
80108378:	50                   	push   %eax
80108379:	ff 75 08             	push   0x8(%ebp)
8010837c:	e8 c9 fa ff ff       	call   80107e4a <mappages>
80108381:	83 c4 20             	add    $0x20,%esp
80108384:	85 c0                	test   %eax,%eax
80108386:	79 39                	jns    801083c1 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80108388:	83 ec 0c             	sub    $0xc,%esp
8010838b:	68 e1 b3 10 80       	push   $0x8010b3e1
80108390:	e8 5f 80 ff ff       	call   801003f4 <cprintf>
80108395:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108398:	83 ec 04             	sub    $0x4,%esp
8010839b:	ff 75 0c             	push   0xc(%ebp)
8010839e:	ff 75 10             	push   0x10(%ebp)
801083a1:	ff 75 08             	push   0x8(%ebp)
801083a4:	e8 30 00 00 00       	call   801083d9 <deallocuvm>
801083a9:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801083ac:	83 ec 0c             	sub    $0xc,%esp
801083af:	ff 75 f0             	push   -0x10(%ebp)
801083b2:	e8 57 a3 ff ff       	call   8010270e <kfree>
801083b7:	83 c4 10             	add    $0x10,%esp
      return 0;
801083ba:	b8 00 00 00 00       	mov    $0x0,%eax
801083bf:	eb 16                	jmp    801083d7 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
801083c1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083cb:	3b 45 10             	cmp    0x10(%ebp),%eax
801083ce:	0f 82 3c ff ff ff    	jb     80108310 <allocuvm+0x3c>
    }
  }
  return newsz;
801083d4:	8b 45 10             	mov    0x10(%ebp),%eax
}
801083d7:	c9                   	leave
801083d8:	c3                   	ret

801083d9 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801083d9:	55                   	push   %ebp
801083da:	89 e5                	mov    %esp,%ebp
801083dc:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801083df:	8b 45 10             	mov    0x10(%ebp),%eax
801083e2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083e5:	72 08                	jb     801083ef <deallocuvm+0x16>
    return oldsz;
801083e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801083ea:	e9 ac 00 00 00       	jmp    8010849b <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801083ef:	8b 45 10             	mov    0x10(%ebp),%eax
801083f2:	05 ff 0f 00 00       	add    $0xfff,%eax
801083f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801083ff:	e9 88 00 00 00       	jmp    8010848c <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108404:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108407:	83 ec 04             	sub    $0x4,%esp
8010840a:	6a 00                	push   $0x0
8010840c:	50                   	push   %eax
8010840d:	ff 75 08             	push   0x8(%ebp)
80108410:	e8 9f f9 ff ff       	call   80107db4 <walkpgdir>
80108415:	83 c4 10             	add    $0x10,%esp
80108418:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010841b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010841f:	75 16                	jne    80108437 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108421:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108424:	c1 e8 16             	shr    $0x16,%eax
80108427:	83 c0 01             	add    $0x1,%eax
8010842a:	c1 e0 16             	shl    $0x16,%eax
8010842d:	2d 00 10 00 00       	sub    $0x1000,%eax
80108432:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108435:	eb 4e                	jmp    80108485 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108437:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010843a:	8b 00                	mov    (%eax),%eax
8010843c:	83 e0 01             	and    $0x1,%eax
8010843f:	85 c0                	test   %eax,%eax
80108441:	74 42                	je     80108485 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108443:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108446:	8b 00                	mov    (%eax),%eax
80108448:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010844d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108450:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108454:	75 0d                	jne    80108463 <deallocuvm+0x8a>
        panic("kfree");
80108456:	83 ec 0c             	sub    $0xc,%esp
80108459:	68 fd b3 10 80       	push   $0x8010b3fd
8010845e:	e8 46 81 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80108463:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108466:	05 00 00 00 80       	add    $0x80000000,%eax
8010846b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010846e:	83 ec 0c             	sub    $0xc,%esp
80108471:	ff 75 e8             	push   -0x18(%ebp)
80108474:	e8 95 a2 ff ff       	call   8010270e <kfree>
80108479:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010847c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010847f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108485:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010848c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010848f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108492:	0f 82 6c ff ff ff    	jb     80108404 <deallocuvm+0x2b>
    }
  }
  return newsz;
80108498:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010849b:	c9                   	leave
8010849c:	c3                   	ret

8010849d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010849d:	55                   	push   %ebp
8010849e:	89 e5                	mov    %esp,%ebp
801084a0:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801084a3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801084a7:	75 0d                	jne    801084b6 <freevm+0x19>
    panic("freevm: no pgdir");
801084a9:	83 ec 0c             	sub    $0xc,%esp
801084ac:	68 03 b4 10 80       	push   $0x8010b403
801084b1:	e8 f3 80 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801084b6:	83 ec 04             	sub    $0x4,%esp
801084b9:	6a 00                	push   $0x0
801084bb:	68 00 00 00 80       	push   $0x80000000
801084c0:	ff 75 08             	push   0x8(%ebp)
801084c3:	e8 11 ff ff ff       	call   801083d9 <deallocuvm>
801084c8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801084cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084d2:	eb 48                	jmp    8010851c <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801084d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801084de:	8b 45 08             	mov    0x8(%ebp),%eax
801084e1:	01 d0                	add    %edx,%eax
801084e3:	8b 00                	mov    (%eax),%eax
801084e5:	83 e0 01             	and    $0x1,%eax
801084e8:	85 c0                	test   %eax,%eax
801084ea:	74 2c                	je     80108518 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801084ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801084f6:	8b 45 08             	mov    0x8(%ebp),%eax
801084f9:	01 d0                	add    %edx,%eax
801084fb:	8b 00                	mov    (%eax),%eax
801084fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108502:	05 00 00 00 80       	add    $0x80000000,%eax
80108507:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010850a:	83 ec 0c             	sub    $0xc,%esp
8010850d:	ff 75 f0             	push   -0x10(%ebp)
80108510:	e8 f9 a1 ff ff       	call   8010270e <kfree>
80108515:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108518:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010851c:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108523:	76 af                	jbe    801084d4 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80108525:	83 ec 0c             	sub    $0xc,%esp
80108528:	ff 75 08             	push   0x8(%ebp)
8010852b:	e8 de a1 ff ff       	call   8010270e <kfree>
80108530:	83 c4 10             	add    $0x10,%esp
}
80108533:	90                   	nop
80108534:	c9                   	leave
80108535:	c3                   	ret

80108536 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108536:	55                   	push   %ebp
80108537:	89 e5                	mov    %esp,%ebp
80108539:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010853c:	83 ec 04             	sub    $0x4,%esp
8010853f:	6a 00                	push   $0x0
80108541:	ff 75 0c             	push   0xc(%ebp)
80108544:	ff 75 08             	push   0x8(%ebp)
80108547:	e8 68 f8 ff ff       	call   80107db4 <walkpgdir>
8010854c:	83 c4 10             	add    $0x10,%esp
8010854f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108552:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108556:	75 0d                	jne    80108565 <clearpteu+0x2f>
    panic("clearpteu");
80108558:	83 ec 0c             	sub    $0xc,%esp
8010855b:	68 14 b4 10 80       	push   $0x8010b414
80108560:	e8 44 80 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80108565:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108568:	8b 00                	mov    (%eax),%eax
8010856a:	83 e0 fb             	and    $0xfffffffb,%eax
8010856d:	89 c2                	mov    %eax,%edx
8010856f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108572:	89 10                	mov    %edx,(%eax)
}
80108574:	90                   	nop
80108575:	c9                   	leave
80108576:	c3                   	ret

80108577 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108577:	55                   	push   %ebp
80108578:	89 e5                	mov    %esp,%ebp
8010857a:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010857d:	e8 58 f9 ff ff       	call   80107eda <setupkvm>
80108582:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108585:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108589:	75 0a                	jne    80108595 <copyuvm+0x1e>
    return 0;
8010858b:	b8 00 00 00 00       	mov    $0x0,%eax
80108590:	e9 eb 00 00 00       	jmp    80108680 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80108595:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010859c:	e9 b7 00 00 00       	jmp    80108658 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801085a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a4:	83 ec 04             	sub    $0x4,%esp
801085a7:	6a 00                	push   $0x0
801085a9:	50                   	push   %eax
801085aa:	ff 75 08             	push   0x8(%ebp)
801085ad:	e8 02 f8 ff ff       	call   80107db4 <walkpgdir>
801085b2:	83 c4 10             	add    $0x10,%esp
801085b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
801085b8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085bc:	75 0d                	jne    801085cb <copyuvm+0x54>
      panic("copyuvm: pte should exist");
801085be:	83 ec 0c             	sub    $0xc,%esp
801085c1:	68 1e b4 10 80       	push   $0x8010b41e
801085c6:	e8 de 7f ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
801085cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085ce:	8b 00                	mov    (%eax),%eax
801085d0:	83 e0 01             	and    $0x1,%eax
801085d3:	85 c0                	test   %eax,%eax
801085d5:	75 0d                	jne    801085e4 <copyuvm+0x6d>
      panic("copyuvm: page not present");
801085d7:	83 ec 0c             	sub    $0xc,%esp
801085da:	68 38 b4 10 80       	push   $0x8010b438
801085df:	e8 c5 7f ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
801085e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085e7:	8b 00                	mov    (%eax),%eax
801085e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801085f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085f4:	8b 00                	mov    (%eax),%eax
801085f6:	25 ff 0f 00 00       	and    $0xfff,%eax
801085fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801085fe:	e8 a5 a1 ff ff       	call   801027a8 <kalloc>
80108603:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108606:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010860a:	74 5d                	je     80108669 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010860c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010860f:	05 00 00 00 80       	add    $0x80000000,%eax
80108614:	83 ec 04             	sub    $0x4,%esp
80108617:	68 00 10 00 00       	push   $0x1000
8010861c:	50                   	push   %eax
8010861d:	ff 75 e0             	push   -0x20(%ebp)
80108620:	e8 ed ce ff ff       	call   80105512 <memmove>
80108625:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108628:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010862b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010862e:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108637:	83 ec 0c             	sub    $0xc,%esp
8010863a:	52                   	push   %edx
8010863b:	51                   	push   %ecx
8010863c:	68 00 10 00 00       	push   $0x1000
80108641:	50                   	push   %eax
80108642:	ff 75 f0             	push   -0x10(%ebp)
80108645:	e8 00 f8 ff ff       	call   80107e4a <mappages>
8010864a:	83 c4 20             	add    $0x20,%esp
8010864d:	85 c0                	test   %eax,%eax
8010864f:	78 1b                	js     8010866c <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80108651:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010865b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010865e:	0f 82 3d ff ff ff    	jb     801085a1 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80108664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108667:	eb 17                	jmp    80108680 <copyuvm+0x109>
      goto bad;
80108669:	90                   	nop
8010866a:	eb 01                	jmp    8010866d <copyuvm+0xf6>
      goto bad;
8010866c:	90                   	nop

bad:
  freevm(d);
8010866d:	83 ec 0c             	sub    $0xc,%esp
80108670:	ff 75 f0             	push   -0x10(%ebp)
80108673:	e8 25 fe ff ff       	call   8010849d <freevm>
80108678:	83 c4 10             	add    $0x10,%esp
  return 0;
8010867b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108680:	c9                   	leave
80108681:	c3                   	ret

80108682 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108682:	55                   	push   %ebp
80108683:	89 e5                	mov    %esp,%ebp
80108685:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108688:	83 ec 04             	sub    $0x4,%esp
8010868b:	6a 00                	push   $0x0
8010868d:	ff 75 0c             	push   0xc(%ebp)
80108690:	ff 75 08             	push   0x8(%ebp)
80108693:	e8 1c f7 ff ff       	call   80107db4 <walkpgdir>
80108698:	83 c4 10             	add    $0x10,%esp
8010869b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010869e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a1:	8b 00                	mov    (%eax),%eax
801086a3:	83 e0 01             	and    $0x1,%eax
801086a6:	85 c0                	test   %eax,%eax
801086a8:	75 07                	jne    801086b1 <uva2ka+0x2f>
    return 0;
801086aa:	b8 00 00 00 00       	mov    $0x0,%eax
801086af:	eb 22                	jmp    801086d3 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
801086b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b4:	8b 00                	mov    (%eax),%eax
801086b6:	83 e0 04             	and    $0x4,%eax
801086b9:	85 c0                	test   %eax,%eax
801086bb:	75 07                	jne    801086c4 <uva2ka+0x42>
    return 0;
801086bd:	b8 00 00 00 00       	mov    $0x0,%eax
801086c2:	eb 0f                	jmp    801086d3 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
801086c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c7:	8b 00                	mov    (%eax),%eax
801086c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086ce:	05 00 00 00 80       	add    $0x80000000,%eax
}
801086d3:	c9                   	leave
801086d4:	c3                   	ret

801086d5 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801086d5:	55                   	push   %ebp
801086d6:	89 e5                	mov    %esp,%ebp
801086d8:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801086db:	8b 45 10             	mov    0x10(%ebp),%eax
801086de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801086e1:	eb 7f                	jmp    80108762 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801086e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801086e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801086ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086f1:	83 ec 08             	sub    $0x8,%esp
801086f4:	50                   	push   %eax
801086f5:	ff 75 08             	push   0x8(%ebp)
801086f8:	e8 85 ff ff ff       	call   80108682 <uva2ka>
801086fd:	83 c4 10             	add    $0x10,%esp
80108700:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108703:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108707:	75 07                	jne    80108710 <copyout+0x3b>
      return -1;
80108709:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010870e:	eb 61                	jmp    80108771 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108710:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108713:	2b 45 0c             	sub    0xc(%ebp),%eax
80108716:	05 00 10 00 00       	add    $0x1000,%eax
8010871b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010871e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108721:	39 45 14             	cmp    %eax,0x14(%ebp)
80108724:	73 06                	jae    8010872c <copyout+0x57>
      n = len;
80108726:	8b 45 14             	mov    0x14(%ebp),%eax
80108729:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010872c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010872f:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108732:	89 c2                	mov    %eax,%edx
80108734:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108737:	01 d0                	add    %edx,%eax
80108739:	83 ec 04             	sub    $0x4,%esp
8010873c:	ff 75 f0             	push   -0x10(%ebp)
8010873f:	ff 75 f4             	push   -0xc(%ebp)
80108742:	50                   	push   %eax
80108743:	e8 ca cd ff ff       	call   80105512 <memmove>
80108748:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010874b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010874e:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108751:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108754:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108757:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010875a:	05 00 10 00 00       	add    $0x1000,%eax
8010875f:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108762:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108766:	0f 85 77 ff ff ff    	jne    801086e3 <copyout+0xe>
  }
  return 0;
8010876c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108771:	c9                   	leave
80108772:	c3                   	ret

80108773 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108773:	55                   	push   %ebp
80108774:	89 e5                	mov    %esp,%ebp
80108776:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108779:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108780:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108783:	8b 40 08             	mov    0x8(%eax),%eax
80108786:	05 00 00 00 80       	add    $0x80000000,%eax
8010878b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
8010878e:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108795:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108798:	8b 40 24             	mov    0x24(%eax),%eax
8010879b:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
801087a0:	c7 05 54 7a 19 80 00 	movl   $0x0,0x80197a54
801087a7:	00 00 00 

  while(i<madt->len){
801087aa:	e9 bc 00 00 00       	jmp    8010886b <mpinit_uefi+0xf8>
    uchar *entry_type = ((uchar *)madt)+i;
801087af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801087b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801087b5:	01 d0                	add    %edx,%eax
801087b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801087ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087bd:	0f b6 00             	movzbl (%eax),%eax
801087c0:	0f b6 c0             	movzbl %al,%eax
801087c3:	83 f8 05             	cmp    $0x5,%eax
801087c6:	0f 87 9f 00 00 00    	ja     8010886b <mpinit_uefi+0xf8>
801087cc:	8b 04 85 54 b4 10 80 	mov    -0x7fef4bac(,%eax,4),%eax
801087d3:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801087d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801087db:	a1 54 7a 19 80       	mov    0x80197a54,%eax
801087e0:	85 c0                	test   %eax,%eax
801087e2:	7f 28                	jg     8010880c <mpinit_uefi+0x99>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801087e4:	8b 15 54 7a 19 80    	mov    0x80197a54,%edx
801087ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087ed:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801087f1:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
801087f7:	81 c2 a0 79 19 80    	add    $0x801979a0,%edx
801087fd:	88 02                	mov    %al,(%edx)
          ncpu++;
801087ff:	a1 54 7a 19 80       	mov    0x80197a54,%eax
80108804:	83 c0 01             	add    $0x1,%eax
80108807:	a3 54 7a 19 80       	mov    %eax,0x80197a54
        }
        i += lapic_entry->record_len;
8010880c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010880f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108813:	0f b6 c0             	movzbl %al,%eax
80108816:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108819:	eb 50                	jmp    8010886b <mpinit_uefi+0xf8>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
8010881b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010881e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108821:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108824:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108828:	a2 58 7a 19 80       	mov    %al,0x80197a58
        i += ioapic->record_len;
8010882d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108830:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108834:	0f b6 c0             	movzbl %al,%eax
80108837:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010883a:	eb 2f                	jmp    8010886b <mpinit_uefi+0xf8>

      case 2:
        iso = (struct uefi_iso *)entry_type;
8010883c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010883f:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108842:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108845:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108849:	0f b6 c0             	movzbl %al,%eax
8010884c:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010884f:	eb 1a                	jmp    8010886b <mpinit_uefi+0xf8>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108851:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108854:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108857:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010885a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010885e:	0f b6 c0             	movzbl %al,%eax
80108861:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108864:	eb 05                	jmp    8010886b <mpinit_uefi+0xf8>

      case 5:
        i = i + 0xC;
80108866:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
8010886a:	90                   	nop
  while(i<madt->len){
8010886b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886e:	8b 40 04             	mov    0x4(%eax),%eax
80108871:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108874:	0f 82 35 ff ff ff    	jb     801087af <mpinit_uefi+0x3c>
    }
  }

}
8010887a:	90                   	nop
8010887b:	90                   	nop
8010887c:	c9                   	leave
8010887d:	c3                   	ret

8010887e <inb>:
{
8010887e:	55                   	push   %ebp
8010887f:	89 e5                	mov    %esp,%ebp
80108881:	83 ec 14             	sub    $0x14,%esp
80108884:	8b 45 08             	mov    0x8(%ebp),%eax
80108887:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010888b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010888f:	89 c2                	mov    %eax,%edx
80108891:	ec                   	in     (%dx),%al
80108892:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108895:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108899:	c9                   	leave
8010889a:	c3                   	ret

8010889b <outb>:
{
8010889b:	55                   	push   %ebp
8010889c:	89 e5                	mov    %esp,%ebp
8010889e:	83 ec 08             	sub    $0x8,%esp
801088a1:	8b 55 08             	mov    0x8(%ebp),%edx
801088a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801088a7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801088ab:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801088ae:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801088b2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801088b6:	ee                   	out    %al,(%dx)
}
801088b7:	90                   	nop
801088b8:	c9                   	leave
801088b9:	c3                   	ret

801088ba <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801088ba:	55                   	push   %ebp
801088bb:	89 e5                	mov    %esp,%ebp
801088bd:	83 ec 28             	sub    $0x28,%esp
801088c0:	8b 45 08             	mov    0x8(%ebp),%eax
801088c3:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801088c6:	6a 00                	push   $0x0
801088c8:	68 fa 03 00 00       	push   $0x3fa
801088cd:	e8 c9 ff ff ff       	call   8010889b <outb>
801088d2:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801088d5:	68 80 00 00 00       	push   $0x80
801088da:	68 fb 03 00 00       	push   $0x3fb
801088df:	e8 b7 ff ff ff       	call   8010889b <outb>
801088e4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801088e7:	6a 0c                	push   $0xc
801088e9:	68 f8 03 00 00       	push   $0x3f8
801088ee:	e8 a8 ff ff ff       	call   8010889b <outb>
801088f3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801088f6:	6a 00                	push   $0x0
801088f8:	68 f9 03 00 00       	push   $0x3f9
801088fd:	e8 99 ff ff ff       	call   8010889b <outb>
80108902:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108905:	6a 03                	push   $0x3
80108907:	68 fb 03 00 00       	push   $0x3fb
8010890c:	e8 8a ff ff ff       	call   8010889b <outb>
80108911:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108914:	6a 00                	push   $0x0
80108916:	68 fc 03 00 00       	push   $0x3fc
8010891b:	e8 7b ff ff ff       	call   8010889b <outb>
80108920:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80108923:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010892a:	eb 11                	jmp    8010893d <uart_debug+0x83>
8010892c:	83 ec 0c             	sub    $0xc,%esp
8010892f:	6a 0a                	push   $0xa
80108931:	e8 03 a2 ff ff       	call   80102b39 <microdelay>
80108936:	83 c4 10             	add    $0x10,%esp
80108939:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010893d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108941:	7f 1a                	jg     8010895d <uart_debug+0xa3>
80108943:	83 ec 0c             	sub    $0xc,%esp
80108946:	68 fd 03 00 00       	push   $0x3fd
8010894b:	e8 2e ff ff ff       	call   8010887e <inb>
80108950:	83 c4 10             	add    $0x10,%esp
80108953:	0f b6 c0             	movzbl %al,%eax
80108956:	83 e0 20             	and    $0x20,%eax
80108959:	85 c0                	test   %eax,%eax
8010895b:	74 cf                	je     8010892c <uart_debug+0x72>
  outb(COM1+0, p);
8010895d:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108961:	0f b6 c0             	movzbl %al,%eax
80108964:	83 ec 08             	sub    $0x8,%esp
80108967:	50                   	push   %eax
80108968:	68 f8 03 00 00       	push   $0x3f8
8010896d:	e8 29 ff ff ff       	call   8010889b <outb>
80108972:	83 c4 10             	add    $0x10,%esp
}
80108975:	90                   	nop
80108976:	c9                   	leave
80108977:	c3                   	ret

80108978 <uart_debugs>:

void uart_debugs(char *p){
80108978:	55                   	push   %ebp
80108979:	89 e5                	mov    %esp,%ebp
8010897b:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010897e:	eb 1b                	jmp    8010899b <uart_debugs+0x23>
    uart_debug(*p++);
80108980:	8b 45 08             	mov    0x8(%ebp),%eax
80108983:	8d 50 01             	lea    0x1(%eax),%edx
80108986:	89 55 08             	mov    %edx,0x8(%ebp)
80108989:	0f b6 00             	movzbl (%eax),%eax
8010898c:	0f be c0             	movsbl %al,%eax
8010898f:	83 ec 0c             	sub    $0xc,%esp
80108992:	50                   	push   %eax
80108993:	e8 22 ff ff ff       	call   801088ba <uart_debug>
80108998:	83 c4 10             	add    $0x10,%esp
  while(*p){
8010899b:	8b 45 08             	mov    0x8(%ebp),%eax
8010899e:	0f b6 00             	movzbl (%eax),%eax
801089a1:	84 c0                	test   %al,%al
801089a3:	75 db                	jne    80108980 <uart_debugs+0x8>
  }
}
801089a5:	90                   	nop
801089a6:	90                   	nop
801089a7:	c9                   	leave
801089a8:	c3                   	ret

801089a9 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801089a9:	55                   	push   %ebp
801089aa:	89 e5                	mov    %esp,%ebp
801089ac:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801089af:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801089b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801089b9:	8b 50 14             	mov    0x14(%eax),%edx
801089bc:	8b 40 10             	mov    0x10(%eax),%eax
801089bf:	a3 5c 7a 19 80       	mov    %eax,0x80197a5c
  gpu.vram_size = boot_param->graphic_config.frame_size;
801089c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801089c7:	8b 50 1c             	mov    0x1c(%eax),%edx
801089ca:	8b 40 18             	mov    0x18(%eax),%eax
801089cd:	a3 64 7a 19 80       	mov    %eax,0x80197a64
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801089d2:	a1 64 7a 19 80       	mov    0x80197a64,%eax
801089d7:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801089dc:	29 c2                	sub    %eax,%edx
801089de:	89 15 60 7a 19 80    	mov    %edx,0x80197a60
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801089e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801089e7:	8b 50 24             	mov    0x24(%eax),%edx
801089ea:	8b 40 20             	mov    0x20(%eax),%eax
801089ed:	a3 68 7a 19 80       	mov    %eax,0x80197a68
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801089f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801089f5:	8b 50 2c             	mov    0x2c(%eax),%edx
801089f8:	8b 40 28             	mov    0x28(%eax),%eax
801089fb:	a3 6c 7a 19 80       	mov    %eax,0x80197a6c
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108a00:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108a03:	8b 50 34             	mov    0x34(%eax),%edx
80108a06:	8b 40 30             	mov    0x30(%eax),%eax
80108a09:	a3 70 7a 19 80       	mov    %eax,0x80197a70
}
80108a0e:	90                   	nop
80108a0f:	c9                   	leave
80108a10:	c3                   	ret

80108a11 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108a11:	55                   	push   %ebp
80108a12:	89 e5                	mov    %esp,%ebp
80108a14:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108a17:	8b 15 70 7a 19 80    	mov    0x80197a70,%edx
80108a1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a20:	0f af d0             	imul   %eax,%edx
80108a23:	8b 45 08             	mov    0x8(%ebp),%eax
80108a26:	01 d0                	add    %edx,%eax
80108a28:	c1 e0 02             	shl    $0x2,%eax
80108a2b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108a2e:	8b 15 60 7a 19 80    	mov    0x80197a60,%edx
80108a34:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108a37:	01 d0                	add    %edx,%eax
80108a39:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108a3c:	8b 45 10             	mov    0x10(%ebp),%eax
80108a3f:	0f b6 10             	movzbl (%eax),%edx
80108a42:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108a45:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108a47:	8b 45 10             	mov    0x10(%ebp),%eax
80108a4a:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108a4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108a51:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108a54:	8b 45 10             	mov    0x10(%ebp),%eax
80108a57:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108a5b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108a5e:	88 50 02             	mov    %dl,0x2(%eax)
}
80108a61:	90                   	nop
80108a62:	c9                   	leave
80108a63:	c3                   	ret

80108a64 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108a64:	55                   	push   %ebp
80108a65:	89 e5                	mov    %esp,%ebp
80108a67:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108a6a:	8b 15 70 7a 19 80    	mov    0x80197a70,%edx
80108a70:	8b 45 08             	mov    0x8(%ebp),%eax
80108a73:	0f af c2             	imul   %edx,%eax
80108a76:	c1 e0 02             	shl    $0x2,%eax
80108a79:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108a7c:	8b 15 64 7a 19 80    	mov    0x80197a64,%edx
80108a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a85:	29 c2                	sub    %eax,%edx
80108a87:	8b 0d 60 7a 19 80    	mov    0x80197a60,%ecx
80108a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a90:	01 c8                	add    %ecx,%eax
80108a92:	89 c1                	mov    %eax,%ecx
80108a94:	a1 60 7a 19 80       	mov    0x80197a60,%eax
80108a99:	83 ec 04             	sub    $0x4,%esp
80108a9c:	52                   	push   %edx
80108a9d:	51                   	push   %ecx
80108a9e:	50                   	push   %eax
80108a9f:	e8 6e ca ff ff       	call   80105512 <memmove>
80108aa4:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aaa:	8b 0d 60 7a 19 80    	mov    0x80197a60,%ecx
80108ab0:	8b 15 64 7a 19 80    	mov    0x80197a64,%edx
80108ab6:	01 d1                	add    %edx,%ecx
80108ab8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108abb:	29 d1                	sub    %edx,%ecx
80108abd:	89 ca                	mov    %ecx,%edx
80108abf:	83 ec 04             	sub    $0x4,%esp
80108ac2:	50                   	push   %eax
80108ac3:	6a 00                	push   $0x0
80108ac5:	52                   	push   %edx
80108ac6:	e8 88 c9 ff ff       	call   80105453 <memset>
80108acb:	83 c4 10             	add    $0x10,%esp
}
80108ace:	90                   	nop
80108acf:	c9                   	leave
80108ad0:	c3                   	ret

80108ad1 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108ad1:	55                   	push   %ebp
80108ad2:	89 e5                	mov    %esp,%ebp
80108ad4:	53                   	push   %ebx
80108ad5:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108ad8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108adf:	e9 b1 00 00 00       	jmp    80108b95 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80108ae4:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108aeb:	e9 97 00 00 00       	jmp    80108b87 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108af0:	8b 45 10             	mov    0x10(%ebp),%eax
80108af3:	83 e8 20             	sub    $0x20,%eax
80108af6:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108afc:	01 d0                	add    %edx,%eax
80108afe:	0f b7 84 00 80 b4 10 	movzwl -0x7fef4b80(%eax,%eax,1),%eax
80108b05:	80 
80108b06:	0f b7 d0             	movzwl %ax,%edx
80108b09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b0c:	bb 01 00 00 00       	mov    $0x1,%ebx
80108b11:	89 c1                	mov    %eax,%ecx
80108b13:	d3 e3                	shl    %cl,%ebx
80108b15:	89 d8                	mov    %ebx,%eax
80108b17:	21 d0                	and    %edx,%eax
80108b19:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108b1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b1f:	ba 01 00 00 00       	mov    $0x1,%edx
80108b24:	89 c1                	mov    %eax,%ecx
80108b26:	d3 e2                	shl    %cl,%edx
80108b28:	89 d0                	mov    %edx,%eax
80108b2a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108b2d:	75 2b                	jne    80108b5a <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108b2f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b35:	01 c2                	add    %eax,%edx
80108b37:	b8 0e 00 00 00       	mov    $0xe,%eax
80108b3c:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108b3f:	89 c1                	mov    %eax,%ecx
80108b41:	8b 45 08             	mov    0x8(%ebp),%eax
80108b44:	01 c8                	add    %ecx,%eax
80108b46:	83 ec 04             	sub    $0x4,%esp
80108b49:	68 00 f5 10 80       	push   $0x8010f500
80108b4e:	52                   	push   %edx
80108b4f:	50                   	push   %eax
80108b50:	e8 bc fe ff ff       	call   80108a11 <graphic_draw_pixel>
80108b55:	83 c4 10             	add    $0x10,%esp
80108b58:	eb 29                	jmp    80108b83 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108b5a:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b60:	01 c2                	add    %eax,%edx
80108b62:	b8 0e 00 00 00       	mov    $0xe,%eax
80108b67:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108b6a:	89 c1                	mov    %eax,%ecx
80108b6c:	8b 45 08             	mov    0x8(%ebp),%eax
80108b6f:	01 c8                	add    %ecx,%eax
80108b71:	83 ec 04             	sub    $0x4,%esp
80108b74:	68 74 7a 19 80       	push   $0x80197a74
80108b79:	52                   	push   %edx
80108b7a:	50                   	push   %eax
80108b7b:	e8 91 fe ff ff       	call   80108a11 <graphic_draw_pixel>
80108b80:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108b83:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108b87:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b8b:	0f 89 5f ff ff ff    	jns    80108af0 <font_render+0x1f>
  for(int i=0;i<30;i++){
80108b91:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108b95:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108b99:	0f 8e 45 ff ff ff    	jle    80108ae4 <font_render+0x13>
      }
    }
  }
}
80108b9f:	90                   	nop
80108ba0:	90                   	nop
80108ba1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108ba4:	c9                   	leave
80108ba5:	c3                   	ret

80108ba6 <font_render_string>:

void font_render_string(char *string,int row){
80108ba6:	55                   	push   %ebp
80108ba7:	89 e5                	mov    %esp,%ebp
80108ba9:	53                   	push   %ebx
80108baa:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108bad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108bb4:	eb 33                	jmp    80108be9 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108bb6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80108bbc:	01 d0                	add    %edx,%eax
80108bbe:	0f b6 00             	movzbl (%eax),%eax
80108bc1:	0f be d8             	movsbl %al,%ebx
80108bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bc7:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108bca:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108bcd:	89 d0                	mov    %edx,%eax
80108bcf:	c1 e0 04             	shl    $0x4,%eax
80108bd2:	29 d0                	sub    %edx,%eax
80108bd4:	83 c0 02             	add    $0x2,%eax
80108bd7:	83 ec 04             	sub    $0x4,%esp
80108bda:	53                   	push   %ebx
80108bdb:	51                   	push   %ecx
80108bdc:	50                   	push   %eax
80108bdd:	e8 ef fe ff ff       	call   80108ad1 <font_render>
80108be2:	83 c4 10             	add    $0x10,%esp
    i++;
80108be5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108be9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108bec:	8b 45 08             	mov    0x8(%ebp),%eax
80108bef:	01 d0                	add    %edx,%eax
80108bf1:	0f b6 00             	movzbl (%eax),%eax
80108bf4:	84 c0                	test   %al,%al
80108bf6:	74 06                	je     80108bfe <font_render_string+0x58>
80108bf8:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108bfc:	7e b8                	jle    80108bb6 <font_render_string+0x10>
  }
}
80108bfe:	90                   	nop
80108bff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c02:	c9                   	leave
80108c03:	c3                   	ret

80108c04 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108c04:	55                   	push   %ebp
80108c05:	89 e5                	mov    %esp,%ebp
80108c07:	53                   	push   %ebx
80108c08:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108c0b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c12:	eb 6b                	jmp    80108c7f <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108c14:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108c1b:	eb 58                	jmp    80108c75 <pci_init+0x71>
      for(int k=0;k<8;k++){
80108c1d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108c24:	eb 45                	jmp    80108c6b <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108c26:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108c29:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c2f:	83 ec 0c             	sub    $0xc,%esp
80108c32:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108c35:	53                   	push   %ebx
80108c36:	6a 00                	push   $0x0
80108c38:	51                   	push   %ecx
80108c39:	52                   	push   %edx
80108c3a:	50                   	push   %eax
80108c3b:	e8 b0 00 00 00       	call   80108cf0 <pci_access_config>
80108c40:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108c43:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c46:	0f b7 c0             	movzwl %ax,%eax
80108c49:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108c4e:	74 17                	je     80108c67 <pci_init+0x63>
        pci_init_device(i,j,k);
80108c50:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108c53:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c59:	83 ec 04             	sub    $0x4,%esp
80108c5c:	51                   	push   %ecx
80108c5d:	52                   	push   %edx
80108c5e:	50                   	push   %eax
80108c5f:	e8 37 01 00 00       	call   80108d9b <pci_init_device>
80108c64:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108c67:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108c6b:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108c6f:	7e b5                	jle    80108c26 <pci_init+0x22>
    for(int j=0;j<32;j++){
80108c71:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108c75:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108c79:	7e a2                	jle    80108c1d <pci_init+0x19>
  for(int i=0;i<256;i++){
80108c7b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108c7f:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108c86:	7e 8c                	jle    80108c14 <pci_init+0x10>
      }
      }
    }
  }
}
80108c88:	90                   	nop
80108c89:	90                   	nop
80108c8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c8d:	c9                   	leave
80108c8e:	c3                   	ret

80108c8f <pci_write_config>:

void pci_write_config(uint config){
80108c8f:	55                   	push   %ebp
80108c90:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108c92:	8b 45 08             	mov    0x8(%ebp),%eax
80108c95:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108c9a:	89 c0                	mov    %eax,%eax
80108c9c:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108c9d:	90                   	nop
80108c9e:	5d                   	pop    %ebp
80108c9f:	c3                   	ret

80108ca0 <pci_write_data>:

void pci_write_data(uint config){
80108ca0:	55                   	push   %ebp
80108ca1:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80108ca6:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108cab:	89 c0                	mov    %eax,%eax
80108cad:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108cae:	90                   	nop
80108caf:	5d                   	pop    %ebp
80108cb0:	c3                   	ret

80108cb1 <pci_read_config>:
uint pci_read_config(){
80108cb1:	55                   	push   %ebp
80108cb2:	89 e5                	mov    %esp,%ebp
80108cb4:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108cb7:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108cbc:	ed                   	in     (%dx),%eax
80108cbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108cc0:	83 ec 0c             	sub    $0xc,%esp
80108cc3:	68 c8 00 00 00       	push   $0xc8
80108cc8:	e8 6c 9e ff ff       	call   80102b39 <microdelay>
80108ccd:	83 c4 10             	add    $0x10,%esp
  return data;
80108cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108cd3:	c9                   	leave
80108cd4:	c3                   	ret

80108cd5 <pci_test>:


void pci_test(){
80108cd5:	55                   	push   %ebp
80108cd6:	89 e5                	mov    %esp,%ebp
80108cd8:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108cdb:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108ce2:	ff 75 fc             	push   -0x4(%ebp)
80108ce5:	e8 a5 ff ff ff       	call   80108c8f <pci_write_config>
80108cea:	83 c4 04             	add    $0x4,%esp
}
80108ced:	90                   	nop
80108cee:	c9                   	leave
80108cef:	c3                   	ret

80108cf0 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108cf0:	55                   	push   %ebp
80108cf1:	89 e5                	mov    %esp,%ebp
80108cf3:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80108cf9:	c1 e0 10             	shl    $0x10,%eax
80108cfc:	25 00 00 ff 00       	and    $0xff0000,%eax
80108d01:	89 c2                	mov    %eax,%edx
80108d03:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d06:	c1 e0 0b             	shl    $0xb,%eax
80108d09:	0f b7 c0             	movzwl %ax,%eax
80108d0c:	09 c2                	or     %eax,%edx
80108d0e:	8b 45 10             	mov    0x10(%ebp),%eax
80108d11:	c1 e0 08             	shl    $0x8,%eax
80108d14:	25 00 07 00 00       	and    $0x700,%eax
80108d19:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108d1b:	8b 45 14             	mov    0x14(%ebp),%eax
80108d1e:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108d23:	09 d0                	or     %edx,%eax
80108d25:	0d 00 00 00 80       	or     $0x80000000,%eax
80108d2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108d2d:	ff 75 f4             	push   -0xc(%ebp)
80108d30:	e8 5a ff ff ff       	call   80108c8f <pci_write_config>
80108d35:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108d38:	e8 74 ff ff ff       	call   80108cb1 <pci_read_config>
80108d3d:	8b 55 18             	mov    0x18(%ebp),%edx
80108d40:	89 02                	mov    %eax,(%edx)
}
80108d42:	90                   	nop
80108d43:	c9                   	leave
80108d44:	c3                   	ret

80108d45 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108d45:	55                   	push   %ebp
80108d46:	89 e5                	mov    %esp,%ebp
80108d48:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108d4b:	8b 45 08             	mov    0x8(%ebp),%eax
80108d4e:	c1 e0 10             	shl    $0x10,%eax
80108d51:	25 00 00 ff 00       	and    $0xff0000,%eax
80108d56:	89 c2                	mov    %eax,%edx
80108d58:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d5b:	c1 e0 0b             	shl    $0xb,%eax
80108d5e:	0f b7 c0             	movzwl %ax,%eax
80108d61:	09 c2                	or     %eax,%edx
80108d63:	8b 45 10             	mov    0x10(%ebp),%eax
80108d66:	c1 e0 08             	shl    $0x8,%eax
80108d69:	25 00 07 00 00       	and    $0x700,%eax
80108d6e:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108d70:	8b 45 14             	mov    0x14(%ebp),%eax
80108d73:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108d78:	09 d0                	or     %edx,%eax
80108d7a:	0d 00 00 00 80       	or     $0x80000000,%eax
80108d7f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108d82:	ff 75 fc             	push   -0x4(%ebp)
80108d85:	e8 05 ff ff ff       	call   80108c8f <pci_write_config>
80108d8a:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108d8d:	ff 75 18             	push   0x18(%ebp)
80108d90:	e8 0b ff ff ff       	call   80108ca0 <pci_write_data>
80108d95:	83 c4 04             	add    $0x4,%esp
}
80108d98:	90                   	nop
80108d99:	c9                   	leave
80108d9a:	c3                   	ret

80108d9b <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108d9b:	55                   	push   %ebp
80108d9c:	89 e5                	mov    %esp,%ebp
80108d9e:	53                   	push   %ebx
80108d9f:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108da2:	8b 45 08             	mov    0x8(%ebp),%eax
80108da5:	a2 78 7a 19 80       	mov    %al,0x80197a78
  dev.device_num = device_num;
80108daa:	8b 45 0c             	mov    0xc(%ebp),%eax
80108dad:	a2 79 7a 19 80       	mov    %al,0x80197a79
  dev.function_num = function_num;
80108db2:	8b 45 10             	mov    0x10(%ebp),%eax
80108db5:	a2 7a 7a 19 80       	mov    %al,0x80197a7a
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108dba:	ff 75 10             	push   0x10(%ebp)
80108dbd:	ff 75 0c             	push   0xc(%ebp)
80108dc0:	ff 75 08             	push   0x8(%ebp)
80108dc3:	68 c4 ca 10 80       	push   $0x8010cac4
80108dc8:	e8 27 76 ff ff       	call   801003f4 <cprintf>
80108dcd:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108dd0:	83 ec 0c             	sub    $0xc,%esp
80108dd3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108dd6:	50                   	push   %eax
80108dd7:	6a 00                	push   $0x0
80108dd9:	ff 75 10             	push   0x10(%ebp)
80108ddc:	ff 75 0c             	push   0xc(%ebp)
80108ddf:	ff 75 08             	push   0x8(%ebp)
80108de2:	e8 09 ff ff ff       	call   80108cf0 <pci_access_config>
80108de7:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108dea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ded:	c1 e8 10             	shr    $0x10,%eax
80108df0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108df3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108df6:	25 ff ff 00 00       	and    $0xffff,%eax
80108dfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e01:	a3 7c 7a 19 80       	mov    %eax,0x80197a7c
  dev.vendor_id = vendor_id;
80108e06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e09:	a3 80 7a 19 80       	mov    %eax,0x80197a80
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108e0e:	83 ec 04             	sub    $0x4,%esp
80108e11:	ff 75 f0             	push   -0x10(%ebp)
80108e14:	ff 75 f4             	push   -0xc(%ebp)
80108e17:	68 f8 ca 10 80       	push   $0x8010caf8
80108e1c:	e8 d3 75 ff ff       	call   801003f4 <cprintf>
80108e21:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108e24:	83 ec 0c             	sub    $0xc,%esp
80108e27:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108e2a:	50                   	push   %eax
80108e2b:	6a 08                	push   $0x8
80108e2d:	ff 75 10             	push   0x10(%ebp)
80108e30:	ff 75 0c             	push   0xc(%ebp)
80108e33:	ff 75 08             	push   0x8(%ebp)
80108e36:	e8 b5 fe ff ff       	call   80108cf0 <pci_access_config>
80108e3b:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108e3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e41:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108e44:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e47:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108e4a:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108e4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e50:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108e53:	0f b6 c0             	movzbl %al,%eax
80108e56:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108e59:	c1 eb 18             	shr    $0x18,%ebx
80108e5c:	83 ec 0c             	sub    $0xc,%esp
80108e5f:	51                   	push   %ecx
80108e60:	52                   	push   %edx
80108e61:	50                   	push   %eax
80108e62:	53                   	push   %ebx
80108e63:	68 1c cb 10 80       	push   $0x8010cb1c
80108e68:	e8 87 75 ff ff       	call   801003f4 <cprintf>
80108e6d:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108e70:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e73:	c1 e8 18             	shr    $0x18,%eax
80108e76:	a2 84 7a 19 80       	mov    %al,0x80197a84
  dev.sub_class = (data>>16)&0xFF;
80108e7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e7e:	c1 e8 10             	shr    $0x10,%eax
80108e81:	a2 85 7a 19 80       	mov    %al,0x80197a85
  dev.interface = (data>>8)&0xFF;
80108e86:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e89:	c1 e8 08             	shr    $0x8,%eax
80108e8c:	a2 86 7a 19 80       	mov    %al,0x80197a86
  dev.revision_id = data&0xFF;
80108e91:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e94:	a2 87 7a 19 80       	mov    %al,0x80197a87
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108e99:	83 ec 0c             	sub    $0xc,%esp
80108e9c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108e9f:	50                   	push   %eax
80108ea0:	6a 10                	push   $0x10
80108ea2:	ff 75 10             	push   0x10(%ebp)
80108ea5:	ff 75 0c             	push   0xc(%ebp)
80108ea8:	ff 75 08             	push   0x8(%ebp)
80108eab:	e8 40 fe ff ff       	call   80108cf0 <pci_access_config>
80108eb0:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108eb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108eb6:	a3 88 7a 19 80       	mov    %eax,0x80197a88
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108ebb:	83 ec 0c             	sub    $0xc,%esp
80108ebe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108ec1:	50                   	push   %eax
80108ec2:	6a 14                	push   $0x14
80108ec4:	ff 75 10             	push   0x10(%ebp)
80108ec7:	ff 75 0c             	push   0xc(%ebp)
80108eca:	ff 75 08             	push   0x8(%ebp)
80108ecd:	e8 1e fe ff ff       	call   80108cf0 <pci_access_config>
80108ed2:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108ed5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ed8:	a3 8c 7a 19 80       	mov    %eax,0x80197a8c
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108edd:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108ee4:	75 5a                	jne    80108f40 <pci_init_device+0x1a5>
80108ee6:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108eed:	75 51                	jne    80108f40 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108eef:	83 ec 0c             	sub    $0xc,%esp
80108ef2:	68 61 cb 10 80       	push   $0x8010cb61
80108ef7:	e8 f8 74 ff ff       	call   801003f4 <cprintf>
80108efc:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108eff:	83 ec 0c             	sub    $0xc,%esp
80108f02:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108f05:	50                   	push   %eax
80108f06:	68 f0 00 00 00       	push   $0xf0
80108f0b:	ff 75 10             	push   0x10(%ebp)
80108f0e:	ff 75 0c             	push   0xc(%ebp)
80108f11:	ff 75 08             	push   0x8(%ebp)
80108f14:	e8 d7 fd ff ff       	call   80108cf0 <pci_access_config>
80108f19:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108f1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f1f:	83 ec 08             	sub    $0x8,%esp
80108f22:	50                   	push   %eax
80108f23:	68 7b cb 10 80       	push   $0x8010cb7b
80108f28:	e8 c7 74 ff ff       	call   801003f4 <cprintf>
80108f2d:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108f30:	83 ec 0c             	sub    $0xc,%esp
80108f33:	68 78 7a 19 80       	push   $0x80197a78
80108f38:	e8 09 00 00 00       	call   80108f46 <i8254_init>
80108f3d:	83 c4 10             	add    $0x10,%esp
  }
}
80108f40:	90                   	nop
80108f41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108f44:	c9                   	leave
80108f45:	c3                   	ret

80108f46 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108f46:	55                   	push   %ebp
80108f47:	89 e5                	mov    %esp,%ebp
80108f49:	53                   	push   %ebx
80108f4a:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80108f50:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108f54:	0f b6 c8             	movzbl %al,%ecx
80108f57:	8b 45 08             	mov    0x8(%ebp),%eax
80108f5a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108f5e:	0f b6 d0             	movzbl %al,%edx
80108f61:	8b 45 08             	mov    0x8(%ebp),%eax
80108f64:	0f b6 00             	movzbl (%eax),%eax
80108f67:	0f b6 c0             	movzbl %al,%eax
80108f6a:	83 ec 0c             	sub    $0xc,%esp
80108f6d:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108f70:	53                   	push   %ebx
80108f71:	6a 04                	push   $0x4
80108f73:	51                   	push   %ecx
80108f74:	52                   	push   %edx
80108f75:	50                   	push   %eax
80108f76:	e8 75 fd ff ff       	call   80108cf0 <pci_access_config>
80108f7b:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108f7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f81:	83 c8 04             	or     $0x4,%eax
80108f84:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108f87:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80108f8d:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108f91:	0f b6 c8             	movzbl %al,%ecx
80108f94:	8b 45 08             	mov    0x8(%ebp),%eax
80108f97:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108f9b:	0f b6 d0             	movzbl %al,%edx
80108f9e:	8b 45 08             	mov    0x8(%ebp),%eax
80108fa1:	0f b6 00             	movzbl (%eax),%eax
80108fa4:	0f b6 c0             	movzbl %al,%eax
80108fa7:	83 ec 0c             	sub    $0xc,%esp
80108faa:	53                   	push   %ebx
80108fab:	6a 04                	push   $0x4
80108fad:	51                   	push   %ecx
80108fae:	52                   	push   %edx
80108faf:	50                   	push   %eax
80108fb0:	e8 90 fd ff ff       	call   80108d45 <pci_write_config_register>
80108fb5:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108fb8:	8b 45 08             	mov    0x8(%ebp),%eax
80108fbb:	8b 40 10             	mov    0x10(%eax),%eax
80108fbe:	05 00 00 00 40       	add    $0x40000000,%eax
80108fc3:	a3 90 7a 19 80       	mov    %eax,0x80197a90
  uint *ctrl = (uint *)base_addr;
80108fc8:	a1 90 7a 19 80       	mov    0x80197a90,%eax
80108fcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108fd0:	a1 90 7a 19 80       	mov    0x80197a90,%eax
80108fd5:	05 d8 00 00 00       	add    $0xd8,%eax
80108fda:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108fdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fe0:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fe9:	8b 00                	mov    (%eax),%eax
80108feb:	0d 00 00 00 04       	or     $0x4000000,%eax
80108ff0:	89 c2                	mov    %eax,%edx
80108ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ff5:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108ff7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ffa:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80109000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109003:	8b 00                	mov    (%eax),%eax
80109005:	83 c8 40             	or     $0x40,%eax
80109008:	89 c2                	mov    %eax,%edx
8010900a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010900d:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
8010900f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109012:	8b 10                	mov    (%eax),%edx
80109014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109017:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80109019:	83 ec 0c             	sub    $0xc,%esp
8010901c:	68 90 cb 10 80       	push   $0x8010cb90
80109021:	e8 ce 73 ff ff       	call   801003f4 <cprintf>
80109026:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80109029:	e8 7a 97 ff ff       	call   801027a8 <kalloc>
8010902e:	a3 9c 7a 19 80       	mov    %eax,0x80197a9c
  *intr_addr = 0;
80109033:	a1 9c 7a 19 80       	mov    0x80197a9c,%eax
80109038:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
8010903e:	a1 9c 7a 19 80       	mov    0x80197a9c,%eax
80109043:	83 ec 08             	sub    $0x8,%esp
80109046:	50                   	push   %eax
80109047:	68 b2 cb 10 80       	push   $0x8010cbb2
8010904c:	e8 a3 73 ff ff       	call   801003f4 <cprintf>
80109051:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80109054:	e8 50 00 00 00       	call   801090a9 <i8254_init_recv>
  i8254_init_send();
80109059:	e8 69 03 00 00       	call   801093c7 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
8010905e:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109065:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80109068:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010906f:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80109072:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109079:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
8010907c:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109083:	0f b6 c0             	movzbl %al,%eax
80109086:	83 ec 0c             	sub    $0xc,%esp
80109089:	53                   	push   %ebx
8010908a:	51                   	push   %ecx
8010908b:	52                   	push   %edx
8010908c:	50                   	push   %eax
8010908d:	68 c0 cb 10 80       	push   $0x8010cbc0
80109092:	e8 5d 73 ff ff       	call   801003f4 <cprintf>
80109097:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
8010909a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010909d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801090a3:	90                   	nop
801090a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801090a7:	c9                   	leave
801090a8:	c3                   	ret

801090a9 <i8254_init_recv>:

void i8254_init_recv(){
801090a9:	55                   	push   %ebp
801090aa:	89 e5                	mov    %esp,%ebp
801090ac:	57                   	push   %edi
801090ad:	56                   	push   %esi
801090ae:	53                   	push   %ebx
801090af:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801090b2:	83 ec 0c             	sub    $0xc,%esp
801090b5:	6a 00                	push   $0x0
801090b7:	e8 e8 04 00 00       	call   801095a4 <i8254_read_eeprom>
801090bc:	83 c4 10             	add    $0x10,%esp
801090bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801090c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801090c5:	a2 94 7a 19 80       	mov    %al,0x80197a94
  mac_addr[1] = data_l>>8;
801090ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
801090cd:	c1 e8 08             	shr    $0x8,%eax
801090d0:	a2 95 7a 19 80       	mov    %al,0x80197a95
  uint data_m = i8254_read_eeprom(0x1);
801090d5:	83 ec 0c             	sub    $0xc,%esp
801090d8:	6a 01                	push   $0x1
801090da:	e8 c5 04 00 00       	call   801095a4 <i8254_read_eeprom>
801090df:	83 c4 10             	add    $0x10,%esp
801090e2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801090e5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801090e8:	a2 96 7a 19 80       	mov    %al,0x80197a96
  mac_addr[3] = data_m>>8;
801090ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801090f0:	c1 e8 08             	shr    $0x8,%eax
801090f3:	a2 97 7a 19 80       	mov    %al,0x80197a97
  uint data_h = i8254_read_eeprom(0x2);
801090f8:	83 ec 0c             	sub    $0xc,%esp
801090fb:	6a 02                	push   $0x2
801090fd:	e8 a2 04 00 00       	call   801095a4 <i8254_read_eeprom>
80109102:	83 c4 10             	add    $0x10,%esp
80109105:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80109108:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010910b:	a2 98 7a 19 80       	mov    %al,0x80197a98
  mac_addr[5] = data_h>>8;
80109110:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109113:	c1 e8 08             	shr    $0x8,%eax
80109116:	a2 99 7a 19 80       	mov    %al,0x80197a99
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
8010911b:	0f b6 05 99 7a 19 80 	movzbl 0x80197a99,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109122:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80109125:	0f b6 05 98 7a 19 80 	movzbl 0x80197a98,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010912c:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
8010912f:	0f b6 05 97 7a 19 80 	movzbl 0x80197a97,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109136:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80109139:	0f b6 05 96 7a 19 80 	movzbl 0x80197a96,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109140:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80109143:	0f b6 05 95 7a 19 80 	movzbl 0x80197a95,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010914a:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
8010914d:	0f b6 05 94 7a 19 80 	movzbl 0x80197a94,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109154:	0f b6 c0             	movzbl %al,%eax
80109157:	83 ec 04             	sub    $0x4,%esp
8010915a:	57                   	push   %edi
8010915b:	56                   	push   %esi
8010915c:	53                   	push   %ebx
8010915d:	51                   	push   %ecx
8010915e:	52                   	push   %edx
8010915f:	50                   	push   %eax
80109160:	68 d8 cb 10 80       	push   $0x8010cbd8
80109165:	e8 8a 72 ff ff       	call   801003f4 <cprintf>
8010916a:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
8010916d:	a1 90 7a 19 80       	mov    0x80197a90,%eax
80109172:	05 00 54 00 00       	add    $0x5400,%eax
80109177:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
8010917a:	a1 90 7a 19 80       	mov    0x80197a90,%eax
8010917f:	05 04 54 00 00       	add    $0x5404,%eax
80109184:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80109187:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010918a:	c1 e0 10             	shl    $0x10,%eax
8010918d:	0b 45 d8             	or     -0x28(%ebp),%eax
80109190:	89 c2                	mov    %eax,%edx
80109192:	8b 45 cc             	mov    -0x34(%ebp),%eax
80109195:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80109197:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010919a:	0d 00 00 00 80       	or     $0x80000000,%eax
8010919f:	89 c2                	mov    %eax,%edx
801091a1:	8b 45 c8             	mov    -0x38(%ebp),%eax
801091a4:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801091a6:	a1 90 7a 19 80       	mov    0x80197a90,%eax
801091ab:	05 00 52 00 00       	add    $0x5200,%eax
801091b0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801091b3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801091ba:	eb 19                	jmp    801091d5 <i8254_init_recv+0x12c>
    mta[i] = 0;
801091bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801091bf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091c6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801091c9:	01 d0                	add    %edx,%eax
801091cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801091d1:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801091d5:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801091d9:	7e e1                	jle    801091bc <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801091db:	a1 90 7a 19 80       	mov    0x80197a90,%eax
801091e0:	05 d0 00 00 00       	add    $0xd0,%eax
801091e5:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801091e8:	8b 45 c0             	mov    -0x40(%ebp),%eax
801091eb:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801091f1:	a1 90 7a 19 80       	mov    0x80197a90,%eax
801091f6:	05 c8 00 00 00       	add    $0xc8,%eax
801091fb:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801091fe:	8b 45 bc             	mov    -0x44(%ebp),%eax
80109201:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80109207:	a1 90 7a 19 80       	mov    0x80197a90,%eax
8010920c:	05 28 28 00 00       	add    $0x2828,%eax
80109211:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80109214:	8b 45 b8             	mov    -0x48(%ebp),%eax
80109217:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
8010921d:	a1 90 7a 19 80       	mov    0x80197a90,%eax
80109222:	05 00 01 00 00       	add    $0x100,%eax
80109227:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
8010922a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010922d:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80109233:	e8 70 95 ff ff       	call   801027a8 <kalloc>
80109238:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
8010923b:	a1 90 7a 19 80       	mov    0x80197a90,%eax
80109240:	05 00 28 00 00       	add    $0x2800,%eax
80109245:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80109248:	a1 90 7a 19 80       	mov    0x80197a90,%eax
8010924d:	05 04 28 00 00       	add    $0x2804,%eax
80109252:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80109255:	a1 90 7a 19 80       	mov    0x80197a90,%eax
8010925a:	05 08 28 00 00       	add    $0x2808,%eax
8010925f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80109262:	a1 90 7a 19 80       	mov    0x80197a90,%eax
80109267:	05 10 28 00 00       	add    $0x2810,%eax
8010926c:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
8010926f:	a1 90 7a 19 80       	mov    0x80197a90,%eax
80109274:	05 18 28 00 00       	add    $0x2818,%eax
80109279:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
8010927c:	8b 45 b0             	mov    -0x50(%ebp),%eax
8010927f:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80109285:	8b 45 ac             	mov    -0x54(%ebp),%eax
80109288:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
8010928a:	8b 45 a8             	mov    -0x58(%ebp),%eax
8010928d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80109293:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80109296:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
8010929c:	8b 45 a0             	mov    -0x60(%ebp),%eax
8010929f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
801092a5:	8b 45 9c             	mov    -0x64(%ebp),%eax
801092a8:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
801092ae:	8b 45 b0             	mov    -0x50(%ebp),%eax
801092b1:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801092b4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801092bb:	eb 73                	jmp    80109330 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
801092bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092c0:	c1 e0 04             	shl    $0x4,%eax
801092c3:	89 c2                	mov    %eax,%edx
801092c5:	8b 45 98             	mov    -0x68(%ebp),%eax
801092c8:	01 d0                	add    %edx,%eax
801092ca:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
801092d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092d4:	c1 e0 04             	shl    $0x4,%eax
801092d7:	89 c2                	mov    %eax,%edx
801092d9:	8b 45 98             	mov    -0x68(%ebp),%eax
801092dc:	01 d0                	add    %edx,%eax
801092de:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
801092e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092e7:	c1 e0 04             	shl    $0x4,%eax
801092ea:	89 c2                	mov    %eax,%edx
801092ec:	8b 45 98             	mov    -0x68(%ebp),%eax
801092ef:	01 d0                	add    %edx,%eax
801092f1:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
801092f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092fa:	c1 e0 04             	shl    $0x4,%eax
801092fd:	89 c2                	mov    %eax,%edx
801092ff:	8b 45 98             	mov    -0x68(%ebp),%eax
80109302:	01 d0                	add    %edx,%eax
80109304:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80109308:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010930b:	c1 e0 04             	shl    $0x4,%eax
8010930e:	89 c2                	mov    %eax,%edx
80109310:	8b 45 98             	mov    -0x68(%ebp),%eax
80109313:	01 d0                	add    %edx,%eax
80109315:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80109319:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010931c:	c1 e0 04             	shl    $0x4,%eax
8010931f:	89 c2                	mov    %eax,%edx
80109321:	8b 45 98             	mov    -0x68(%ebp),%eax
80109324:	01 d0                	add    %edx,%eax
80109326:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
8010932c:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80109330:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80109337:	7e 84                	jle    801092bd <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80109339:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80109340:	eb 57                	jmp    80109399 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80109342:	e8 61 94 ff ff       	call   801027a8 <kalloc>
80109347:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
8010934a:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
8010934e:	75 12                	jne    80109362 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80109350:	83 ec 0c             	sub    $0xc,%esp
80109353:	68 f8 cb 10 80       	push   $0x8010cbf8
80109358:	e8 97 70 ff ff       	call   801003f4 <cprintf>
8010935d:	83 c4 10             	add    $0x10,%esp
      break;
80109360:	eb 3d                	jmp    8010939f <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80109362:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109365:	c1 e0 04             	shl    $0x4,%eax
80109368:	89 c2                	mov    %eax,%edx
8010936a:	8b 45 98             	mov    -0x68(%ebp),%eax
8010936d:	01 d0                	add    %edx,%eax
8010936f:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109372:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109378:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010937a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010937d:	83 c0 01             	add    $0x1,%eax
80109380:	c1 e0 04             	shl    $0x4,%eax
80109383:	89 c2                	mov    %eax,%edx
80109385:	8b 45 98             	mov    -0x68(%ebp),%eax
80109388:	01 d0                	add    %edx,%eax
8010938a:	8b 55 94             	mov    -0x6c(%ebp),%edx
8010938d:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109393:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80109395:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80109399:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
8010939d:	7e a3                	jle    80109342 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
8010939f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801093a2:	8b 00                	mov    (%eax),%eax
801093a4:	83 c8 02             	or     $0x2,%eax
801093a7:	89 c2                	mov    %eax,%edx
801093a9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801093ac:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801093ae:	83 ec 0c             	sub    $0xc,%esp
801093b1:	68 18 cc 10 80       	push   $0x8010cc18
801093b6:	e8 39 70 ff ff       	call   801003f4 <cprintf>
801093bb:	83 c4 10             	add    $0x10,%esp
}
801093be:	90                   	nop
801093bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801093c2:	5b                   	pop    %ebx
801093c3:	5e                   	pop    %esi
801093c4:	5f                   	pop    %edi
801093c5:	5d                   	pop    %ebp
801093c6:	c3                   	ret

801093c7 <i8254_init_send>:

void i8254_init_send(){
801093c7:	55                   	push   %ebp
801093c8:	89 e5                	mov    %esp,%ebp
801093ca:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801093cd:	a1 90 7a 19 80       	mov    0x80197a90,%eax
801093d2:	05 28 38 00 00       	add    $0x3828,%eax
801093d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801093da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093dd:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801093e3:	e8 c0 93 ff ff       	call   801027a8 <kalloc>
801093e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801093eb:	a1 90 7a 19 80       	mov    0x80197a90,%eax
801093f0:	05 00 38 00 00       	add    $0x3800,%eax
801093f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
801093f8:	a1 90 7a 19 80       	mov    0x80197a90,%eax
801093fd:	05 04 38 00 00       	add    $0x3804,%eax
80109402:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80109405:	a1 90 7a 19 80       	mov    0x80197a90,%eax
8010940a:	05 08 38 00 00       	add    $0x3808,%eax
8010940f:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80109412:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109415:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010941b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010941e:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80109420:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109423:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80109429:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010942c:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80109432:	a1 90 7a 19 80       	mov    0x80197a90,%eax
80109437:	05 10 38 00 00       	add    $0x3810,%eax
8010943c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
8010943f:	a1 90 7a 19 80       	mov    0x80197a90,%eax
80109444:	05 18 38 00 00       	add    $0x3818,%eax
80109449:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
8010944c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010944f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80109455:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109458:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
8010945e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109461:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109464:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010946b:	e9 82 00 00 00       	jmp    801094f2 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80109470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109473:	c1 e0 04             	shl    $0x4,%eax
80109476:	89 c2                	mov    %eax,%edx
80109478:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010947b:	01 d0                	add    %edx,%eax
8010947d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80109484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109487:	c1 e0 04             	shl    $0x4,%eax
8010948a:	89 c2                	mov    %eax,%edx
8010948c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010948f:	01 d0                	add    %edx,%eax
80109491:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80109497:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010949a:	c1 e0 04             	shl    $0x4,%eax
8010949d:	89 c2                	mov    %eax,%edx
8010949f:	8b 45 d0             	mov    -0x30(%ebp),%eax
801094a2:	01 d0                	add    %edx,%eax
801094a4:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801094a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ab:	c1 e0 04             	shl    $0x4,%eax
801094ae:	89 c2                	mov    %eax,%edx
801094b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
801094b3:	01 d0                	add    %edx,%eax
801094b5:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801094b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094bc:	c1 e0 04             	shl    $0x4,%eax
801094bf:	89 c2                	mov    %eax,%edx
801094c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801094c4:	01 d0                	add    %edx,%eax
801094c6:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801094ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094cd:	c1 e0 04             	shl    $0x4,%eax
801094d0:	89 c2                	mov    %eax,%edx
801094d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801094d5:	01 d0                	add    %edx,%eax
801094d7:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
801094db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094de:	c1 e0 04             	shl    $0x4,%eax
801094e1:	89 c2                	mov    %eax,%edx
801094e3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801094e6:	01 d0                	add    %edx,%eax
801094e8:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801094ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801094f2:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801094f9:	0f 8e 71 ff ff ff    	jle    80109470 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801094ff:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109506:	eb 57                	jmp    8010955f <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80109508:	e8 9b 92 ff ff       	call   801027a8 <kalloc>
8010950d:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80109510:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80109514:	75 12                	jne    80109528 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80109516:	83 ec 0c             	sub    $0xc,%esp
80109519:	68 f8 cb 10 80       	push   $0x8010cbf8
8010951e:	e8 d1 6e ff ff       	call   801003f4 <cprintf>
80109523:	83 c4 10             	add    $0x10,%esp
      break;
80109526:	eb 3d                	jmp    80109565 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80109528:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010952b:	c1 e0 04             	shl    $0x4,%eax
8010952e:	89 c2                	mov    %eax,%edx
80109530:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109533:	01 d0                	add    %edx,%eax
80109535:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109538:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010953e:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109540:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109543:	83 c0 01             	add    $0x1,%eax
80109546:	c1 e0 04             	shl    $0x4,%eax
80109549:	89 c2                	mov    %eax,%edx
8010954b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010954e:	01 d0                	add    %edx,%eax
80109550:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109553:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109559:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
8010955b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010955f:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80109563:	7e a3                	jle    80109508 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80109565:	a1 90 7a 19 80       	mov    0x80197a90,%eax
8010956a:	05 00 04 00 00       	add    $0x400,%eax
8010956f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80109572:	8b 45 c8             	mov    -0x38(%ebp),%eax
80109575:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
8010957b:	a1 90 7a 19 80       	mov    0x80197a90,%eax
80109580:	05 10 04 00 00       	add    $0x410,%eax
80109585:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80109588:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010958b:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80109591:	83 ec 0c             	sub    $0xc,%esp
80109594:	68 38 cc 10 80       	push   $0x8010cc38
80109599:	e8 56 6e ff ff       	call   801003f4 <cprintf>
8010959e:	83 c4 10             	add    $0x10,%esp

}
801095a1:	90                   	nop
801095a2:	c9                   	leave
801095a3:	c3                   	ret

801095a4 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
801095a4:	55                   	push   %ebp
801095a5:	89 e5                	mov    %esp,%ebp
801095a7:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
801095aa:	a1 90 7a 19 80       	mov    0x80197a90,%eax
801095af:	83 c0 14             	add    $0x14,%eax
801095b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801095b5:	8b 45 08             	mov    0x8(%ebp),%eax
801095b8:	c1 e0 08             	shl    $0x8,%eax
801095bb:	0f b7 c0             	movzwl %ax,%eax
801095be:	83 c8 01             	or     $0x1,%eax
801095c1:	89 c2                	mov    %eax,%edx
801095c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095c6:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801095c8:	83 ec 0c             	sub    $0xc,%esp
801095cb:	68 58 cc 10 80       	push   $0x8010cc58
801095d0:	e8 1f 6e ff ff       	call   801003f4 <cprintf>
801095d5:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801095d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095db:	8b 00                	mov    (%eax),%eax
801095dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801095e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095e3:	83 e0 10             	and    $0x10,%eax
801095e6:	85 c0                	test   %eax,%eax
801095e8:	75 02                	jne    801095ec <i8254_read_eeprom+0x48>
  while(1){
801095ea:	eb dc                	jmp    801095c8 <i8254_read_eeprom+0x24>
      break;
801095ec:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801095ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095f0:	8b 00                	mov    (%eax),%eax
801095f2:	c1 e8 10             	shr    $0x10,%eax
}
801095f5:	c9                   	leave
801095f6:	c3                   	ret

801095f7 <i8254_recv>:
void i8254_recv(){
801095f7:	55                   	push   %ebp
801095f8:	89 e5                	mov    %esp,%ebp
801095fa:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
801095fd:	a1 90 7a 19 80       	mov    0x80197a90,%eax
80109602:	05 10 28 00 00       	add    $0x2810,%eax
80109607:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
8010960a:	a1 90 7a 19 80       	mov    0x80197a90,%eax
8010960f:	05 18 28 00 00       	add    $0x2818,%eax
80109614:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109617:	a1 90 7a 19 80       	mov    0x80197a90,%eax
8010961c:	05 00 28 00 00       	add    $0x2800,%eax
80109621:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80109624:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109627:	8b 00                	mov    (%eax),%eax
80109629:	05 00 00 00 80       	add    $0x80000000,%eax
8010962e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80109631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109634:	8b 10                	mov    (%eax),%edx
80109636:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109639:	8b 00                	mov    (%eax),%eax
8010963b:	29 c2                	sub    %eax,%edx
8010963d:	89 d0                	mov    %edx,%eax
8010963f:	25 ff 00 00 00       	and    $0xff,%eax
80109644:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109647:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010964b:	7e 37                	jle    80109684 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
8010964d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109650:	8b 00                	mov    (%eax),%eax
80109652:	c1 e0 04             	shl    $0x4,%eax
80109655:	89 c2                	mov    %eax,%edx
80109657:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010965a:	01 d0                	add    %edx,%eax
8010965c:	8b 00                	mov    (%eax),%eax
8010965e:	05 00 00 00 80       	add    $0x80000000,%eax
80109663:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80109666:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109669:	8b 00                	mov    (%eax),%eax
8010966b:	83 c0 01             	add    $0x1,%eax
8010966e:	0f b6 d0             	movzbl %al,%edx
80109671:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109674:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109676:	83 ec 0c             	sub    $0xc,%esp
80109679:	ff 75 e0             	push   -0x20(%ebp)
8010967c:	e8 13 09 00 00       	call   80109f94 <eth_proc>
80109681:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109684:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109687:	8b 10                	mov    (%eax),%edx
80109689:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010968c:	8b 00                	mov    (%eax),%eax
8010968e:	39 c2                	cmp    %eax,%edx
80109690:	75 9f                	jne    80109631 <i8254_recv+0x3a>
      (*rdt)--;
80109692:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109695:	8b 00                	mov    (%eax),%eax
80109697:	8d 50 ff             	lea    -0x1(%eax),%edx
8010969a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010969d:	89 10                	mov    %edx,(%eax)
  while(1){
8010969f:	eb 90                	jmp    80109631 <i8254_recv+0x3a>

801096a1 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
801096a1:	55                   	push   %ebp
801096a2:	89 e5                	mov    %esp,%ebp
801096a4:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
801096a7:	a1 90 7a 19 80       	mov    0x80197a90,%eax
801096ac:	05 10 38 00 00       	add    $0x3810,%eax
801096b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801096b4:	a1 90 7a 19 80       	mov    0x80197a90,%eax
801096b9:	05 18 38 00 00       	add    $0x3818,%eax
801096be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801096c1:	a1 90 7a 19 80       	mov    0x80197a90,%eax
801096c6:	05 00 38 00 00       	add    $0x3800,%eax
801096cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
801096ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801096d1:	8b 00                	mov    (%eax),%eax
801096d3:	05 00 00 00 80       	add    $0x80000000,%eax
801096d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801096db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096de:	8b 10                	mov    (%eax),%edx
801096e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096e3:	8b 00                	mov    (%eax),%eax
801096e5:	29 c2                	sub    %eax,%edx
801096e7:	0f b6 c2             	movzbl %dl,%eax
801096ea:	ba 00 01 00 00       	mov    $0x100,%edx
801096ef:	29 c2                	sub    %eax,%edx
801096f1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801096f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096f7:	8b 00                	mov    (%eax),%eax
801096f9:	25 ff 00 00 00       	and    $0xff,%eax
801096fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80109701:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109705:	0f 8e a8 00 00 00    	jle    801097b3 <i8254_send+0x112>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
8010970b:	8b 45 08             	mov    0x8(%ebp),%eax
8010970e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109711:	89 d1                	mov    %edx,%ecx
80109713:	c1 e1 04             	shl    $0x4,%ecx
80109716:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109719:	01 ca                	add    %ecx,%edx
8010971b:	8b 12                	mov    (%edx),%edx
8010971d:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109723:	83 ec 04             	sub    $0x4,%esp
80109726:	ff 75 0c             	push   0xc(%ebp)
80109729:	50                   	push   %eax
8010972a:	52                   	push   %edx
8010972b:	e8 e2 bd ff ff       	call   80105512 <memmove>
80109730:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109733:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109736:	c1 e0 04             	shl    $0x4,%eax
80109739:	89 c2                	mov    %eax,%edx
8010973b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010973e:	01 d0                	add    %edx,%eax
80109740:	8b 55 0c             	mov    0xc(%ebp),%edx
80109743:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109747:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010974a:	c1 e0 04             	shl    $0x4,%eax
8010974d:	89 c2                	mov    %eax,%edx
8010974f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109752:	01 d0                	add    %edx,%eax
80109754:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109758:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010975b:	c1 e0 04             	shl    $0x4,%eax
8010975e:	89 c2                	mov    %eax,%edx
80109760:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109763:	01 d0                	add    %edx,%eax
80109765:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109769:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010976c:	c1 e0 04             	shl    $0x4,%eax
8010976f:	89 c2                	mov    %eax,%edx
80109771:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109774:	01 d0                	add    %edx,%eax
80109776:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
8010977a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010977d:	c1 e0 04             	shl    $0x4,%eax
80109780:	89 c2                	mov    %eax,%edx
80109782:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109785:	01 d0                	add    %edx,%eax
80109787:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
8010978d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109790:	c1 e0 04             	shl    $0x4,%eax
80109793:	89 c2                	mov    %eax,%edx
80109795:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109798:	01 d0                	add    %edx,%eax
8010979a:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
8010979e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097a1:	8b 00                	mov    (%eax),%eax
801097a3:	83 c0 01             	add    $0x1,%eax
801097a6:	0f b6 d0             	movzbl %al,%edx
801097a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097ac:	89 10                	mov    %edx,(%eax)
    return len;
801097ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801097b1:	eb 05                	jmp    801097b8 <i8254_send+0x117>
  }else{
    return -1;
801097b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801097b8:	c9                   	leave
801097b9:	c3                   	ret

801097ba <i8254_intr>:

void i8254_intr(){
801097ba:	55                   	push   %ebp
801097bb:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801097bd:	a1 9c 7a 19 80       	mov    0x80197a9c,%eax
801097c2:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801097c8:	90                   	nop
801097c9:	5d                   	pop    %ebp
801097ca:	c3                   	ret

801097cb <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801097cb:	55                   	push   %ebp
801097cc:	89 e5                	mov    %esp,%ebp
801097ce:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801097d1:	8b 45 08             	mov    0x8(%ebp),%eax
801097d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801097d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097da:	0f b7 00             	movzwl (%eax),%eax
801097dd:	66 3d 00 01          	cmp    $0x100,%ax
801097e1:	74 0a                	je     801097ed <arp_proc+0x22>
801097e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801097e8:	e9 4f 01 00 00       	jmp    8010993c <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801097ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097f0:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801097f4:	66 83 f8 08          	cmp    $0x8,%ax
801097f8:	74 0a                	je     80109804 <arp_proc+0x39>
801097fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801097ff:	e9 38 01 00 00       	jmp    8010993c <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80109804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109807:	0f b6 40 04          	movzbl 0x4(%eax),%eax
8010980b:	3c 06                	cmp    $0x6,%al
8010980d:	74 0a                	je     80109819 <arp_proc+0x4e>
8010980f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109814:	e9 23 01 00 00       	jmp    8010993c <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80109819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010981c:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109820:	3c 04                	cmp    $0x4,%al
80109822:	74 0a                	je     8010982e <arp_proc+0x63>
80109824:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109829:	e9 0e 01 00 00       	jmp    8010993c <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
8010982e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109831:	83 c0 18             	add    $0x18,%eax
80109834:	83 ec 04             	sub    $0x4,%esp
80109837:	6a 04                	push   $0x4
80109839:	50                   	push   %eax
8010983a:	68 04 f5 10 80       	push   $0x8010f504
8010983f:	e8 76 bc ff ff       	call   801054ba <memcmp>
80109844:	83 c4 10             	add    $0x10,%esp
80109847:	85 c0                	test   %eax,%eax
80109849:	74 27                	je     80109872 <arp_proc+0xa7>
8010984b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010984e:	83 c0 0e             	add    $0xe,%eax
80109851:	83 ec 04             	sub    $0x4,%esp
80109854:	6a 04                	push   $0x4
80109856:	50                   	push   %eax
80109857:	68 04 f5 10 80       	push   $0x8010f504
8010985c:	e8 59 bc ff ff       	call   801054ba <memcmp>
80109861:	83 c4 10             	add    $0x10,%esp
80109864:	85 c0                	test   %eax,%eax
80109866:	74 0a                	je     80109872 <arp_proc+0xa7>
80109868:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010986d:	e9 ca 00 00 00       	jmp    8010993c <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109872:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109875:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109879:	66 3d 00 01          	cmp    $0x100,%ax
8010987d:	75 69                	jne    801098e8 <arp_proc+0x11d>
8010987f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109882:	83 c0 18             	add    $0x18,%eax
80109885:	83 ec 04             	sub    $0x4,%esp
80109888:	6a 04                	push   $0x4
8010988a:	50                   	push   %eax
8010988b:	68 04 f5 10 80       	push   $0x8010f504
80109890:	e8 25 bc ff ff       	call   801054ba <memcmp>
80109895:	83 c4 10             	add    $0x10,%esp
80109898:	85 c0                	test   %eax,%eax
8010989a:	75 4c                	jne    801098e8 <arp_proc+0x11d>
    uint send = (uint)kalloc();
8010989c:	e8 07 8f ff ff       	call   801027a8 <kalloc>
801098a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801098a4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801098ab:	83 ec 04             	sub    $0x4,%esp
801098ae:	8d 45 ec             	lea    -0x14(%ebp),%eax
801098b1:	50                   	push   %eax
801098b2:	ff 75 f0             	push   -0x10(%ebp)
801098b5:	ff 75 f4             	push   -0xc(%ebp)
801098b8:	e8 1f 04 00 00       	call   80109cdc <arp_reply_pkt_create>
801098bd:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801098c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098c3:	83 ec 08             	sub    $0x8,%esp
801098c6:	50                   	push   %eax
801098c7:	ff 75 f0             	push   -0x10(%ebp)
801098ca:	e8 d2 fd ff ff       	call   801096a1 <i8254_send>
801098cf:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801098d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098d5:	83 ec 0c             	sub    $0xc,%esp
801098d8:	50                   	push   %eax
801098d9:	e8 30 8e ff ff       	call   8010270e <kfree>
801098de:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801098e1:	b8 02 00 00 00       	mov    $0x2,%eax
801098e6:	eb 54                	jmp    8010993c <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801098e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098eb:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801098ef:	66 3d 00 02          	cmp    $0x200,%ax
801098f3:	75 42                	jne    80109937 <arp_proc+0x16c>
801098f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098f8:	83 c0 18             	add    $0x18,%eax
801098fb:	83 ec 04             	sub    $0x4,%esp
801098fe:	6a 04                	push   $0x4
80109900:	50                   	push   %eax
80109901:	68 04 f5 10 80       	push   $0x8010f504
80109906:	e8 af bb ff ff       	call   801054ba <memcmp>
8010990b:	83 c4 10             	add    $0x10,%esp
8010990e:	85 c0                	test   %eax,%eax
80109910:	75 25                	jne    80109937 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80109912:	83 ec 0c             	sub    $0xc,%esp
80109915:	68 5c cc 10 80       	push   $0x8010cc5c
8010991a:	e8 d5 6a ff ff       	call   801003f4 <cprintf>
8010991f:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80109922:	83 ec 0c             	sub    $0xc,%esp
80109925:	ff 75 f4             	push   -0xc(%ebp)
80109928:	e8 af 01 00 00       	call   80109adc <arp_table_update>
8010992d:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109930:	b8 01 00 00 00       	mov    $0x1,%eax
80109935:	eb 05                	jmp    8010993c <arp_proc+0x171>
  }else{
    return -1;
80109937:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
8010993c:	c9                   	leave
8010993d:	c3                   	ret

8010993e <arp_scan>:

void arp_scan(){
8010993e:	55                   	push   %ebp
8010993f:	89 e5                	mov    %esp,%ebp
80109941:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109944:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010994b:	eb 6f                	jmp    801099bc <arp_scan+0x7e>
    uint send = (uint)kalloc();
8010994d:	e8 56 8e ff ff       	call   801027a8 <kalloc>
80109952:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109955:	83 ec 04             	sub    $0x4,%esp
80109958:	ff 75 f4             	push   -0xc(%ebp)
8010995b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010995e:	50                   	push   %eax
8010995f:	ff 75 ec             	push   -0x14(%ebp)
80109962:	e8 62 00 00 00       	call   801099c9 <arp_broadcast>
80109967:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
8010996a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010996d:	83 ec 08             	sub    $0x8,%esp
80109970:	50                   	push   %eax
80109971:	ff 75 ec             	push   -0x14(%ebp)
80109974:	e8 28 fd ff ff       	call   801096a1 <i8254_send>
80109979:	83 c4 10             	add    $0x10,%esp
8010997c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010997f:	eb 22                	jmp    801099a3 <arp_scan+0x65>
      microdelay(1);
80109981:	83 ec 0c             	sub    $0xc,%esp
80109984:	6a 01                	push   $0x1
80109986:	e8 ae 91 ff ff       	call   80102b39 <microdelay>
8010998b:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010998e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109991:	83 ec 08             	sub    $0x8,%esp
80109994:	50                   	push   %eax
80109995:	ff 75 ec             	push   -0x14(%ebp)
80109998:	e8 04 fd ff ff       	call   801096a1 <i8254_send>
8010999d:	83 c4 10             	add    $0x10,%esp
801099a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801099a3:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801099a7:	74 d8                	je     80109981 <arp_scan+0x43>
    }
    kfree((char *)send);
801099a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801099ac:	83 ec 0c             	sub    $0xc,%esp
801099af:	50                   	push   %eax
801099b0:	e8 59 8d ff ff       	call   8010270e <kfree>
801099b5:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801099b8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801099bc:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801099c3:	7e 88                	jle    8010994d <arp_scan+0xf>
  }
}
801099c5:	90                   	nop
801099c6:	90                   	nop
801099c7:	c9                   	leave
801099c8:	c3                   	ret

801099c9 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801099c9:	55                   	push   %ebp
801099ca:	89 e5                	mov    %esp,%ebp
801099cc:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801099cf:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801099d3:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801099d7:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801099db:	8b 45 10             	mov    0x10(%ebp),%eax
801099de:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801099e1:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801099e8:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801099ee:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801099f5:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801099fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801099fe:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109a04:	8b 45 08             	mov    0x8(%ebp),%eax
80109a07:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109a0a:	8b 45 08             	mov    0x8(%ebp),%eax
80109a0d:	83 c0 0e             	add    $0xe,%eax
80109a10:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a16:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a1d:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a24:	83 ec 04             	sub    $0x4,%esp
80109a27:	6a 06                	push   $0x6
80109a29:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109a2c:	52                   	push   %edx
80109a2d:	50                   	push   %eax
80109a2e:	e8 df ba ff ff       	call   80105512 <memmove>
80109a33:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a39:	83 c0 06             	add    $0x6,%eax
80109a3c:	83 ec 04             	sub    $0x4,%esp
80109a3f:	6a 06                	push   $0x6
80109a41:	68 94 7a 19 80       	push   $0x80197a94
80109a46:	50                   	push   %eax
80109a47:	e8 c6 ba ff ff       	call   80105512 <memmove>
80109a4c:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a52:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109a57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a5a:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a63:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109a67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a6a:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a71:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a7a:	8d 50 12             	lea    0x12(%eax),%edx
80109a7d:	83 ec 04             	sub    $0x4,%esp
80109a80:	6a 06                	push   $0x6
80109a82:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109a85:	50                   	push   %eax
80109a86:	52                   	push   %edx
80109a87:	e8 86 ba ff ff       	call   80105512 <memmove>
80109a8c:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a92:	8d 50 18             	lea    0x18(%eax),%edx
80109a95:	83 ec 04             	sub    $0x4,%esp
80109a98:	6a 04                	push   $0x4
80109a9a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109a9d:	50                   	push   %eax
80109a9e:	52                   	push   %edx
80109a9f:	e8 6e ba ff ff       	call   80105512 <memmove>
80109aa4:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109aa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aaa:	83 c0 08             	add    $0x8,%eax
80109aad:	83 ec 04             	sub    $0x4,%esp
80109ab0:	6a 06                	push   $0x6
80109ab2:	68 94 7a 19 80       	push   $0x80197a94
80109ab7:	50                   	push   %eax
80109ab8:	e8 55 ba ff ff       	call   80105512 <memmove>
80109abd:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109ac0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ac3:	83 c0 0e             	add    $0xe,%eax
80109ac6:	83 ec 04             	sub    $0x4,%esp
80109ac9:	6a 04                	push   $0x4
80109acb:	68 04 f5 10 80       	push   $0x8010f504
80109ad0:	50                   	push   %eax
80109ad1:	e8 3c ba ff ff       	call   80105512 <memmove>
80109ad6:	83 c4 10             	add    $0x10,%esp
}
80109ad9:	90                   	nop
80109ada:	c9                   	leave
80109adb:	c3                   	ret

80109adc <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109adc:	55                   	push   %ebp
80109add:	89 e5                	mov    %esp,%ebp
80109adf:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80109ae5:	83 c0 0e             	add    $0xe,%eax
80109ae8:	83 ec 0c             	sub    $0xc,%esp
80109aeb:	50                   	push   %eax
80109aec:	e8 bc 00 00 00       	call   80109bad <arp_table_search>
80109af1:	83 c4 10             	add    $0x10,%esp
80109af4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109af7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109afb:	78 2d                	js     80109b2a <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109afd:	8b 45 08             	mov    0x8(%ebp),%eax
80109b00:	8d 48 08             	lea    0x8(%eax),%ecx
80109b03:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109b06:	89 d0                	mov    %edx,%eax
80109b08:	c1 e0 02             	shl    $0x2,%eax
80109b0b:	01 d0                	add    %edx,%eax
80109b0d:	01 c0                	add    %eax,%eax
80109b0f:	01 d0                	add    %edx,%eax
80109b11:	05 a0 7a 19 80       	add    $0x80197aa0,%eax
80109b16:	83 c0 04             	add    $0x4,%eax
80109b19:	83 ec 04             	sub    $0x4,%esp
80109b1c:	6a 06                	push   $0x6
80109b1e:	51                   	push   %ecx
80109b1f:	50                   	push   %eax
80109b20:	e8 ed b9 ff ff       	call   80105512 <memmove>
80109b25:	83 c4 10             	add    $0x10,%esp
80109b28:	eb 70                	jmp    80109b9a <arp_table_update+0xbe>
  }else{
    index += 1;
80109b2a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109b2e:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109b31:	8b 45 08             	mov    0x8(%ebp),%eax
80109b34:	8d 48 08             	lea    0x8(%eax),%ecx
80109b37:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109b3a:	89 d0                	mov    %edx,%eax
80109b3c:	c1 e0 02             	shl    $0x2,%eax
80109b3f:	01 d0                	add    %edx,%eax
80109b41:	01 c0                	add    %eax,%eax
80109b43:	01 d0                	add    %edx,%eax
80109b45:	05 a0 7a 19 80       	add    $0x80197aa0,%eax
80109b4a:	83 c0 04             	add    $0x4,%eax
80109b4d:	83 ec 04             	sub    $0x4,%esp
80109b50:	6a 06                	push   $0x6
80109b52:	51                   	push   %ecx
80109b53:	50                   	push   %eax
80109b54:	e8 b9 b9 ff ff       	call   80105512 <memmove>
80109b59:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109b5c:	8b 45 08             	mov    0x8(%ebp),%eax
80109b5f:	8d 48 0e             	lea    0xe(%eax),%ecx
80109b62:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109b65:	89 d0                	mov    %edx,%eax
80109b67:	c1 e0 02             	shl    $0x2,%eax
80109b6a:	01 d0                	add    %edx,%eax
80109b6c:	01 c0                	add    %eax,%eax
80109b6e:	01 d0                	add    %edx,%eax
80109b70:	05 a0 7a 19 80       	add    $0x80197aa0,%eax
80109b75:	83 ec 04             	sub    $0x4,%esp
80109b78:	6a 04                	push   $0x4
80109b7a:	51                   	push   %ecx
80109b7b:	50                   	push   %eax
80109b7c:	e8 91 b9 ff ff       	call   80105512 <memmove>
80109b81:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109b84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109b87:	89 d0                	mov    %edx,%eax
80109b89:	c1 e0 02             	shl    $0x2,%eax
80109b8c:	01 d0                	add    %edx,%eax
80109b8e:	01 c0                	add    %eax,%eax
80109b90:	01 d0                	add    %edx,%eax
80109b92:	05 aa 7a 19 80       	add    $0x80197aaa,%eax
80109b97:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109b9a:	83 ec 0c             	sub    $0xc,%esp
80109b9d:	68 a0 7a 19 80       	push   $0x80197aa0
80109ba2:	e8 83 00 00 00       	call   80109c2a <print_arp_table>
80109ba7:	83 c4 10             	add    $0x10,%esp
}
80109baa:	90                   	nop
80109bab:	c9                   	leave
80109bac:	c3                   	ret

80109bad <arp_table_search>:

int arp_table_search(uchar *ip){
80109bad:	55                   	push   %ebp
80109bae:	89 e5                	mov    %esp,%ebp
80109bb0:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109bb3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109bba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109bc1:	eb 59                	jmp    80109c1c <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109bc3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109bc6:	89 d0                	mov    %edx,%eax
80109bc8:	c1 e0 02             	shl    $0x2,%eax
80109bcb:	01 d0                	add    %edx,%eax
80109bcd:	01 c0                	add    %eax,%eax
80109bcf:	01 d0                	add    %edx,%eax
80109bd1:	05 a0 7a 19 80       	add    $0x80197aa0,%eax
80109bd6:	83 ec 04             	sub    $0x4,%esp
80109bd9:	6a 04                	push   $0x4
80109bdb:	ff 75 08             	push   0x8(%ebp)
80109bde:	50                   	push   %eax
80109bdf:	e8 d6 b8 ff ff       	call   801054ba <memcmp>
80109be4:	83 c4 10             	add    $0x10,%esp
80109be7:	85 c0                	test   %eax,%eax
80109be9:	75 05                	jne    80109bf0 <arp_table_search+0x43>
      return i;
80109beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bee:	eb 38                	jmp    80109c28 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109bf0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109bf3:	89 d0                	mov    %edx,%eax
80109bf5:	c1 e0 02             	shl    $0x2,%eax
80109bf8:	01 d0                	add    %edx,%eax
80109bfa:	01 c0                	add    %eax,%eax
80109bfc:	01 d0                	add    %edx,%eax
80109bfe:	05 aa 7a 19 80       	add    $0x80197aaa,%eax
80109c03:	0f b6 00             	movzbl (%eax),%eax
80109c06:	84 c0                	test   %al,%al
80109c08:	75 0e                	jne    80109c18 <arp_table_search+0x6b>
80109c0a:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109c0e:	75 08                	jne    80109c18 <arp_table_search+0x6b>
      empty = -i;
80109c10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c13:	f7 d8                	neg    %eax
80109c15:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109c18:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109c1c:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109c20:	7e a1                	jle    80109bc3 <arp_table_search+0x16>
    }
  }
  return empty-1;
80109c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c25:	83 e8 01             	sub    $0x1,%eax
}
80109c28:	c9                   	leave
80109c29:	c3                   	ret

80109c2a <print_arp_table>:

void print_arp_table(){
80109c2a:	55                   	push   %ebp
80109c2b:	89 e5                	mov    %esp,%ebp
80109c2d:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109c30:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109c37:	e9 92 00 00 00       	jmp    80109cce <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109c3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109c3f:	89 d0                	mov    %edx,%eax
80109c41:	c1 e0 02             	shl    $0x2,%eax
80109c44:	01 d0                	add    %edx,%eax
80109c46:	01 c0                	add    %eax,%eax
80109c48:	01 d0                	add    %edx,%eax
80109c4a:	05 aa 7a 19 80       	add    $0x80197aaa,%eax
80109c4f:	0f b6 00             	movzbl (%eax),%eax
80109c52:	84 c0                	test   %al,%al
80109c54:	74 74                	je     80109cca <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109c56:	83 ec 08             	sub    $0x8,%esp
80109c59:	ff 75 f4             	push   -0xc(%ebp)
80109c5c:	68 6f cc 10 80       	push   $0x8010cc6f
80109c61:	e8 8e 67 ff ff       	call   801003f4 <cprintf>
80109c66:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109c69:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109c6c:	89 d0                	mov    %edx,%eax
80109c6e:	c1 e0 02             	shl    $0x2,%eax
80109c71:	01 d0                	add    %edx,%eax
80109c73:	01 c0                	add    %eax,%eax
80109c75:	01 d0                	add    %edx,%eax
80109c77:	05 a0 7a 19 80       	add    $0x80197aa0,%eax
80109c7c:	83 ec 0c             	sub    $0xc,%esp
80109c7f:	50                   	push   %eax
80109c80:	e8 54 02 00 00       	call   80109ed9 <print_ipv4>
80109c85:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109c88:	83 ec 0c             	sub    $0xc,%esp
80109c8b:	68 7e cc 10 80       	push   $0x8010cc7e
80109c90:	e8 5f 67 ff ff       	call   801003f4 <cprintf>
80109c95:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109c98:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109c9b:	89 d0                	mov    %edx,%eax
80109c9d:	c1 e0 02             	shl    $0x2,%eax
80109ca0:	01 d0                	add    %edx,%eax
80109ca2:	01 c0                	add    %eax,%eax
80109ca4:	01 d0                	add    %edx,%eax
80109ca6:	05 a0 7a 19 80       	add    $0x80197aa0,%eax
80109cab:	83 c0 04             	add    $0x4,%eax
80109cae:	83 ec 0c             	sub    $0xc,%esp
80109cb1:	50                   	push   %eax
80109cb2:	e8 70 02 00 00       	call   80109f27 <print_mac>
80109cb7:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109cba:	83 ec 0c             	sub    $0xc,%esp
80109cbd:	68 80 cc 10 80       	push   $0x8010cc80
80109cc2:	e8 2d 67 ff ff       	call   801003f4 <cprintf>
80109cc7:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109cca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109cce:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109cd2:	0f 8e 64 ff ff ff    	jle    80109c3c <print_arp_table+0x12>
    }
  }
}
80109cd8:	90                   	nop
80109cd9:	90                   	nop
80109cda:	c9                   	leave
80109cdb:	c3                   	ret

80109cdc <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109cdc:	55                   	push   %ebp
80109cdd:	89 e5                	mov    %esp,%ebp
80109cdf:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109ce2:	8b 45 10             	mov    0x10(%ebp),%eax
80109ce5:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
80109cee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80109cf4:	83 c0 0e             	add    $0xe,%eax
80109cf7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cfd:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d04:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109d08:	8b 45 08             	mov    0x8(%ebp),%eax
80109d0b:	8d 50 08             	lea    0x8(%eax),%edx
80109d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d11:	83 ec 04             	sub    $0x4,%esp
80109d14:	6a 06                	push   $0x6
80109d16:	52                   	push   %edx
80109d17:	50                   	push   %eax
80109d18:	e8 f5 b7 ff ff       	call   80105512 <memmove>
80109d1d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d23:	83 c0 06             	add    $0x6,%eax
80109d26:	83 ec 04             	sub    $0x4,%esp
80109d29:	6a 06                	push   $0x6
80109d2b:	68 94 7a 19 80       	push   $0x80197a94
80109d30:	50                   	push   %eax
80109d31:	e8 dc b7 ff ff       	call   80105512 <memmove>
80109d36:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d3c:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d44:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109d4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d4d:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109d51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d54:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109d58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d5b:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109d61:	8b 45 08             	mov    0x8(%ebp),%eax
80109d64:	8d 50 08             	lea    0x8(%eax),%edx
80109d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d6a:	83 c0 12             	add    $0x12,%eax
80109d6d:	83 ec 04             	sub    $0x4,%esp
80109d70:	6a 06                	push   $0x6
80109d72:	52                   	push   %edx
80109d73:	50                   	push   %eax
80109d74:	e8 99 b7 ff ff       	call   80105512 <memmove>
80109d79:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109d7c:	8b 45 08             	mov    0x8(%ebp),%eax
80109d7f:	8d 50 0e             	lea    0xe(%eax),%edx
80109d82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d85:	83 c0 18             	add    $0x18,%eax
80109d88:	83 ec 04             	sub    $0x4,%esp
80109d8b:	6a 04                	push   $0x4
80109d8d:	52                   	push   %edx
80109d8e:	50                   	push   %eax
80109d8f:	e8 7e b7 ff ff       	call   80105512 <memmove>
80109d94:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109d97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d9a:	83 c0 08             	add    $0x8,%eax
80109d9d:	83 ec 04             	sub    $0x4,%esp
80109da0:	6a 06                	push   $0x6
80109da2:	68 94 7a 19 80       	push   $0x80197a94
80109da7:	50                   	push   %eax
80109da8:	e8 65 b7 ff ff       	call   80105512 <memmove>
80109dad:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109db0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109db3:	83 c0 0e             	add    $0xe,%eax
80109db6:	83 ec 04             	sub    $0x4,%esp
80109db9:	6a 04                	push   $0x4
80109dbb:	68 04 f5 10 80       	push   $0x8010f504
80109dc0:	50                   	push   %eax
80109dc1:	e8 4c b7 ff ff       	call   80105512 <memmove>
80109dc6:	83 c4 10             	add    $0x10,%esp
}
80109dc9:	90                   	nop
80109dca:	c9                   	leave
80109dcb:	c3                   	ret

80109dcc <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109dcc:	55                   	push   %ebp
80109dcd:	89 e5                	mov    %esp,%ebp
80109dcf:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109dd2:	83 ec 0c             	sub    $0xc,%esp
80109dd5:	68 82 cc 10 80       	push   $0x8010cc82
80109dda:	e8 15 66 ff ff       	call   801003f4 <cprintf>
80109ddf:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109de2:	8b 45 08             	mov    0x8(%ebp),%eax
80109de5:	83 c0 0e             	add    $0xe,%eax
80109de8:	83 ec 0c             	sub    $0xc,%esp
80109deb:	50                   	push   %eax
80109dec:	e8 e8 00 00 00       	call   80109ed9 <print_ipv4>
80109df1:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109df4:	83 ec 0c             	sub    $0xc,%esp
80109df7:	68 80 cc 10 80       	push   $0x8010cc80
80109dfc:	e8 f3 65 ff ff       	call   801003f4 <cprintf>
80109e01:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109e04:	8b 45 08             	mov    0x8(%ebp),%eax
80109e07:	83 c0 08             	add    $0x8,%eax
80109e0a:	83 ec 0c             	sub    $0xc,%esp
80109e0d:	50                   	push   %eax
80109e0e:	e8 14 01 00 00       	call   80109f27 <print_mac>
80109e13:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109e16:	83 ec 0c             	sub    $0xc,%esp
80109e19:	68 80 cc 10 80       	push   $0x8010cc80
80109e1e:	e8 d1 65 ff ff       	call   801003f4 <cprintf>
80109e23:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109e26:	83 ec 0c             	sub    $0xc,%esp
80109e29:	68 99 cc 10 80       	push   $0x8010cc99
80109e2e:	e8 c1 65 ff ff       	call   801003f4 <cprintf>
80109e33:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109e36:	8b 45 08             	mov    0x8(%ebp),%eax
80109e39:	83 c0 18             	add    $0x18,%eax
80109e3c:	83 ec 0c             	sub    $0xc,%esp
80109e3f:	50                   	push   %eax
80109e40:	e8 94 00 00 00       	call   80109ed9 <print_ipv4>
80109e45:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109e48:	83 ec 0c             	sub    $0xc,%esp
80109e4b:	68 80 cc 10 80       	push   $0x8010cc80
80109e50:	e8 9f 65 ff ff       	call   801003f4 <cprintf>
80109e55:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109e58:	8b 45 08             	mov    0x8(%ebp),%eax
80109e5b:	83 c0 12             	add    $0x12,%eax
80109e5e:	83 ec 0c             	sub    $0xc,%esp
80109e61:	50                   	push   %eax
80109e62:	e8 c0 00 00 00       	call   80109f27 <print_mac>
80109e67:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109e6a:	83 ec 0c             	sub    $0xc,%esp
80109e6d:	68 80 cc 10 80       	push   $0x8010cc80
80109e72:	e8 7d 65 ff ff       	call   801003f4 <cprintf>
80109e77:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109e7a:	83 ec 0c             	sub    $0xc,%esp
80109e7d:	68 b0 cc 10 80       	push   $0x8010ccb0
80109e82:	e8 6d 65 ff ff       	call   801003f4 <cprintf>
80109e87:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109e8a:	8b 45 08             	mov    0x8(%ebp),%eax
80109e8d:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109e91:	66 3d 00 01          	cmp    $0x100,%ax
80109e95:	75 12                	jne    80109ea9 <print_arp_info+0xdd>
80109e97:	83 ec 0c             	sub    $0xc,%esp
80109e9a:	68 bc cc 10 80       	push   $0x8010ccbc
80109e9f:	e8 50 65 ff ff       	call   801003f4 <cprintf>
80109ea4:	83 c4 10             	add    $0x10,%esp
80109ea7:	eb 1d                	jmp    80109ec6 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109ea9:	8b 45 08             	mov    0x8(%ebp),%eax
80109eac:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109eb0:	66 3d 00 02          	cmp    $0x200,%ax
80109eb4:	75 10                	jne    80109ec6 <print_arp_info+0xfa>
    cprintf("Reply\n");
80109eb6:	83 ec 0c             	sub    $0xc,%esp
80109eb9:	68 c5 cc 10 80       	push   $0x8010ccc5
80109ebe:	e8 31 65 ff ff       	call   801003f4 <cprintf>
80109ec3:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109ec6:	83 ec 0c             	sub    $0xc,%esp
80109ec9:	68 80 cc 10 80       	push   $0x8010cc80
80109ece:	e8 21 65 ff ff       	call   801003f4 <cprintf>
80109ed3:	83 c4 10             	add    $0x10,%esp
}
80109ed6:	90                   	nop
80109ed7:	c9                   	leave
80109ed8:	c3                   	ret

80109ed9 <print_ipv4>:

void print_ipv4(uchar *ip){
80109ed9:	55                   	push   %ebp
80109eda:	89 e5                	mov    %esp,%ebp
80109edc:	53                   	push   %ebx
80109edd:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80109ee3:	83 c0 03             	add    $0x3,%eax
80109ee6:	0f b6 00             	movzbl (%eax),%eax
80109ee9:	0f b6 d8             	movzbl %al,%ebx
80109eec:	8b 45 08             	mov    0x8(%ebp),%eax
80109eef:	83 c0 02             	add    $0x2,%eax
80109ef2:	0f b6 00             	movzbl (%eax),%eax
80109ef5:	0f b6 c8             	movzbl %al,%ecx
80109ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80109efb:	83 c0 01             	add    $0x1,%eax
80109efe:	0f b6 00             	movzbl (%eax),%eax
80109f01:	0f b6 d0             	movzbl %al,%edx
80109f04:	8b 45 08             	mov    0x8(%ebp),%eax
80109f07:	0f b6 00             	movzbl (%eax),%eax
80109f0a:	0f b6 c0             	movzbl %al,%eax
80109f0d:	83 ec 0c             	sub    $0xc,%esp
80109f10:	53                   	push   %ebx
80109f11:	51                   	push   %ecx
80109f12:	52                   	push   %edx
80109f13:	50                   	push   %eax
80109f14:	68 cc cc 10 80       	push   $0x8010cccc
80109f19:	e8 d6 64 ff ff       	call   801003f4 <cprintf>
80109f1e:	83 c4 20             	add    $0x20,%esp
}
80109f21:	90                   	nop
80109f22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109f25:	c9                   	leave
80109f26:	c3                   	ret

80109f27 <print_mac>:

void print_mac(uchar *mac){
80109f27:	55                   	push   %ebp
80109f28:	89 e5                	mov    %esp,%ebp
80109f2a:	57                   	push   %edi
80109f2b:	56                   	push   %esi
80109f2c:	53                   	push   %ebx
80109f2d:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109f30:	8b 45 08             	mov    0x8(%ebp),%eax
80109f33:	83 c0 05             	add    $0x5,%eax
80109f36:	0f b6 00             	movzbl (%eax),%eax
80109f39:	0f b6 f8             	movzbl %al,%edi
80109f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80109f3f:	83 c0 04             	add    $0x4,%eax
80109f42:	0f b6 00             	movzbl (%eax),%eax
80109f45:	0f b6 f0             	movzbl %al,%esi
80109f48:	8b 45 08             	mov    0x8(%ebp),%eax
80109f4b:	83 c0 03             	add    $0x3,%eax
80109f4e:	0f b6 00             	movzbl (%eax),%eax
80109f51:	0f b6 d8             	movzbl %al,%ebx
80109f54:	8b 45 08             	mov    0x8(%ebp),%eax
80109f57:	83 c0 02             	add    $0x2,%eax
80109f5a:	0f b6 00             	movzbl (%eax),%eax
80109f5d:	0f b6 c8             	movzbl %al,%ecx
80109f60:	8b 45 08             	mov    0x8(%ebp),%eax
80109f63:	83 c0 01             	add    $0x1,%eax
80109f66:	0f b6 00             	movzbl (%eax),%eax
80109f69:	0f b6 d0             	movzbl %al,%edx
80109f6c:	8b 45 08             	mov    0x8(%ebp),%eax
80109f6f:	0f b6 00             	movzbl (%eax),%eax
80109f72:	0f b6 c0             	movzbl %al,%eax
80109f75:	83 ec 04             	sub    $0x4,%esp
80109f78:	57                   	push   %edi
80109f79:	56                   	push   %esi
80109f7a:	53                   	push   %ebx
80109f7b:	51                   	push   %ecx
80109f7c:	52                   	push   %edx
80109f7d:	50                   	push   %eax
80109f7e:	68 e4 cc 10 80       	push   $0x8010cce4
80109f83:	e8 6c 64 ff ff       	call   801003f4 <cprintf>
80109f88:	83 c4 20             	add    $0x20,%esp
}
80109f8b:	90                   	nop
80109f8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109f8f:	5b                   	pop    %ebx
80109f90:	5e                   	pop    %esi
80109f91:	5f                   	pop    %edi
80109f92:	5d                   	pop    %ebp
80109f93:	c3                   	ret

80109f94 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109f94:	55                   	push   %ebp
80109f95:	89 e5                	mov    %esp,%ebp
80109f97:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80109f9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109fa0:	8b 45 08             	mov    0x8(%ebp),%eax
80109fa3:	83 c0 0e             	add    $0xe,%eax
80109fa6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fac:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109fb0:	3c 08                	cmp    $0x8,%al
80109fb2:	75 1b                	jne    80109fcf <eth_proc+0x3b>
80109fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fb7:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109fbb:	3c 06                	cmp    $0x6,%al
80109fbd:	75 10                	jne    80109fcf <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109fbf:	83 ec 0c             	sub    $0xc,%esp
80109fc2:	ff 75 f0             	push   -0x10(%ebp)
80109fc5:	e8 01 f8 ff ff       	call   801097cb <arp_proc>
80109fca:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109fcd:	eb 24                	jmp    80109ff3 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fd2:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109fd6:	3c 08                	cmp    $0x8,%al
80109fd8:	75 19                	jne    80109ff3 <eth_proc+0x5f>
80109fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fdd:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109fe1:	84 c0                	test   %al,%al
80109fe3:	75 0e                	jne    80109ff3 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109fe5:	83 ec 0c             	sub    $0xc,%esp
80109fe8:	ff 75 08             	push   0x8(%ebp)
80109feb:	e8 8d 00 00 00       	call   8010a07d <ipv4_proc>
80109ff0:	83 c4 10             	add    $0x10,%esp
}
80109ff3:	90                   	nop
80109ff4:	c9                   	leave
80109ff5:	c3                   	ret

80109ff6 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109ff6:	55                   	push   %ebp
80109ff7:	89 e5                	mov    %esp,%ebp
80109ff9:	83 ec 04             	sub    $0x4,%esp
80109ffc:	8b 45 08             	mov    0x8(%ebp),%eax
80109fff:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010a003:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a007:	66 c1 c0 08          	rol    $0x8,%ax
}
8010a00b:	c9                   	leave
8010a00c:	c3                   	ret

8010a00d <H2N_ushort>:

ushort H2N_ushort(ushort value){
8010a00d:	55                   	push   %ebp
8010a00e:	89 e5                	mov    %esp,%ebp
8010a010:	83 ec 04             	sub    $0x4,%esp
8010a013:	8b 45 08             	mov    0x8(%ebp),%eax
8010a016:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010a01a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a01e:	66 c1 c0 08          	rol    $0x8,%ax
}
8010a022:	c9                   	leave
8010a023:	c3                   	ret

8010a024 <H2N_uint>:

uint H2N_uint(uint value){
8010a024:	55                   	push   %ebp
8010a025:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
8010a027:	8b 45 08             	mov    0x8(%ebp),%eax
8010a02a:	c1 e0 18             	shl    $0x18,%eax
8010a02d:	25 00 00 00 0f       	and    $0xf000000,%eax
8010a032:	89 c2                	mov    %eax,%edx
8010a034:	8b 45 08             	mov    0x8(%ebp),%eax
8010a037:	c1 e0 08             	shl    $0x8,%eax
8010a03a:	25 00 f0 00 00       	and    $0xf000,%eax
8010a03f:	09 c2                	or     %eax,%edx
8010a041:	8b 45 08             	mov    0x8(%ebp),%eax
8010a044:	c1 e8 08             	shr    $0x8,%eax
8010a047:	83 e0 0f             	and    $0xf,%eax
8010a04a:	01 d0                	add    %edx,%eax
}
8010a04c:	5d                   	pop    %ebp
8010a04d:	c3                   	ret

8010a04e <N2H_uint>:

uint N2H_uint(uint value){
8010a04e:	55                   	push   %ebp
8010a04f:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010a051:	8b 45 08             	mov    0x8(%ebp),%eax
8010a054:	c1 e0 18             	shl    $0x18,%eax
8010a057:	89 c2                	mov    %eax,%edx
8010a059:	8b 45 08             	mov    0x8(%ebp),%eax
8010a05c:	c1 e0 08             	shl    $0x8,%eax
8010a05f:	25 00 00 ff 00       	and    $0xff0000,%eax
8010a064:	01 c2                	add    %eax,%edx
8010a066:	8b 45 08             	mov    0x8(%ebp),%eax
8010a069:	c1 e8 08             	shr    $0x8,%eax
8010a06c:	25 00 ff 00 00       	and    $0xff00,%eax
8010a071:	01 c2                	add    %eax,%edx
8010a073:	8b 45 08             	mov    0x8(%ebp),%eax
8010a076:	c1 e8 18             	shr    $0x18,%eax
8010a079:	01 d0                	add    %edx,%eax
}
8010a07b:	5d                   	pop    %ebp
8010a07c:	c3                   	ret

8010a07d <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
8010a07d:	55                   	push   %ebp
8010a07e:	89 e5                	mov    %esp,%ebp
8010a080:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010a083:	8b 45 08             	mov    0x8(%ebp),%eax
8010a086:	83 c0 0e             	add    $0xe,%eax
8010a089:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
8010a08c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a08f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a093:	0f b7 d0             	movzwl %ax,%edx
8010a096:	a1 08 f5 10 80       	mov    0x8010f508,%eax
8010a09b:	39 c2                	cmp    %eax,%edx
8010a09d:	74 60                	je     8010a0ff <ipv4_proc+0x82>
8010a09f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0a2:	83 c0 0c             	add    $0xc,%eax
8010a0a5:	83 ec 04             	sub    $0x4,%esp
8010a0a8:	6a 04                	push   $0x4
8010a0aa:	50                   	push   %eax
8010a0ab:	68 04 f5 10 80       	push   $0x8010f504
8010a0b0:	e8 05 b4 ff ff       	call   801054ba <memcmp>
8010a0b5:	83 c4 10             	add    $0x10,%esp
8010a0b8:	85 c0                	test   %eax,%eax
8010a0ba:	74 43                	je     8010a0ff <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
8010a0bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0bf:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a0c3:	0f b7 c0             	movzwl %ax,%eax
8010a0c6:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
8010a0cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0ce:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a0d2:	3c 01                	cmp    $0x1,%al
8010a0d4:	75 10                	jne    8010a0e6 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
8010a0d6:	83 ec 0c             	sub    $0xc,%esp
8010a0d9:	ff 75 08             	push   0x8(%ebp)
8010a0dc:	e8 a3 00 00 00       	call   8010a184 <icmp_proc>
8010a0e1:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
8010a0e4:	eb 19                	jmp    8010a0ff <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
8010a0e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0e9:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a0ed:	3c 06                	cmp    $0x6,%al
8010a0ef:	75 0e                	jne    8010a0ff <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
8010a0f1:	83 ec 0c             	sub    $0xc,%esp
8010a0f4:	ff 75 08             	push   0x8(%ebp)
8010a0f7:	e8 b3 03 00 00       	call   8010a4af <tcp_proc>
8010a0fc:	83 c4 10             	add    $0x10,%esp
}
8010a0ff:	90                   	nop
8010a100:	c9                   	leave
8010a101:	c3                   	ret

8010a102 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010a102:	55                   	push   %ebp
8010a103:	89 e5                	mov    %esp,%ebp
8010a105:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
8010a108:	8b 45 08             	mov    0x8(%ebp),%eax
8010a10b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010a10e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a111:	0f b6 00             	movzbl (%eax),%eax
8010a114:	83 e0 0f             	and    $0xf,%eax
8010a117:	01 c0                	add    %eax,%eax
8010a119:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010a11c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a123:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a12a:	eb 48                	jmp    8010a174 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a12c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a12f:	01 c0                	add    %eax,%eax
8010a131:	89 c2                	mov    %eax,%edx
8010a133:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a136:	01 d0                	add    %edx,%eax
8010a138:	0f b6 00             	movzbl (%eax),%eax
8010a13b:	0f b6 c0             	movzbl %al,%eax
8010a13e:	c1 e0 08             	shl    $0x8,%eax
8010a141:	89 c2                	mov    %eax,%edx
8010a143:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a146:	01 c0                	add    %eax,%eax
8010a148:	8d 48 01             	lea    0x1(%eax),%ecx
8010a14b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a14e:	01 c8                	add    %ecx,%eax
8010a150:	0f b6 00             	movzbl (%eax),%eax
8010a153:	0f b6 c0             	movzbl %al,%eax
8010a156:	01 d0                	add    %edx,%eax
8010a158:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a15b:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a162:	76 0c                	jbe    8010a170 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a164:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a167:	0f b7 c0             	movzwl %ax,%eax
8010a16a:	83 c0 01             	add    $0x1,%eax
8010a16d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a170:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a174:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
8010a178:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010a17b:	7c af                	jl     8010a12c <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
8010a17d:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a180:	f7 d0                	not    %eax
}
8010a182:	c9                   	leave
8010a183:	c3                   	ret

8010a184 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010a184:	55                   	push   %ebp
8010a185:	89 e5                	mov    %esp,%ebp
8010a187:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010a18a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a18d:	83 c0 0e             	add    $0xe,%eax
8010a190:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a193:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a196:	0f b6 00             	movzbl (%eax),%eax
8010a199:	0f b6 c0             	movzbl %al,%eax
8010a19c:	83 e0 0f             	and    $0xf,%eax
8010a19f:	c1 e0 02             	shl    $0x2,%eax
8010a1a2:	89 c2                	mov    %eax,%edx
8010a1a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1a7:	01 d0                	add    %edx,%eax
8010a1a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
8010a1ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1af:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010a1b3:	84 c0                	test   %al,%al
8010a1b5:	75 4f                	jne    8010a206 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010a1b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1ba:	0f b6 00             	movzbl (%eax),%eax
8010a1bd:	3c 08                	cmp    $0x8,%al
8010a1bf:	75 45                	jne    8010a206 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
8010a1c1:	e8 e2 85 ff ff       	call   801027a8 <kalloc>
8010a1c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
8010a1c9:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
8010a1d0:	83 ec 04             	sub    $0x4,%esp
8010a1d3:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010a1d6:	50                   	push   %eax
8010a1d7:	ff 75 ec             	push   -0x14(%ebp)
8010a1da:	ff 75 08             	push   0x8(%ebp)
8010a1dd:	e8 78 00 00 00       	call   8010a25a <icmp_reply_pkt_create>
8010a1e2:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010a1e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1e8:	83 ec 08             	sub    $0x8,%esp
8010a1eb:	50                   	push   %eax
8010a1ec:	ff 75 ec             	push   -0x14(%ebp)
8010a1ef:	e8 ad f4 ff ff       	call   801096a1 <i8254_send>
8010a1f4:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010a1f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1fa:	83 ec 0c             	sub    $0xc,%esp
8010a1fd:	50                   	push   %eax
8010a1fe:	e8 0b 85 ff ff       	call   8010270e <kfree>
8010a203:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010a206:	90                   	nop
8010a207:	c9                   	leave
8010a208:	c3                   	ret

8010a209 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
8010a209:	55                   	push   %ebp
8010a20a:	89 e5                	mov    %esp,%ebp
8010a20c:	53                   	push   %ebx
8010a20d:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010a210:	8b 45 08             	mov    0x8(%ebp),%eax
8010a213:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a217:	0f b7 c0             	movzwl %ax,%eax
8010a21a:	83 ec 0c             	sub    $0xc,%esp
8010a21d:	50                   	push   %eax
8010a21e:	e8 d3 fd ff ff       	call   80109ff6 <N2H_ushort>
8010a223:	83 c4 10             	add    $0x10,%esp
8010a226:	0f b7 d8             	movzwl %ax,%ebx
8010a229:	8b 45 08             	mov    0x8(%ebp),%eax
8010a22c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a230:	0f b7 c0             	movzwl %ax,%eax
8010a233:	83 ec 0c             	sub    $0xc,%esp
8010a236:	50                   	push   %eax
8010a237:	e8 ba fd ff ff       	call   80109ff6 <N2H_ushort>
8010a23c:	83 c4 10             	add    $0x10,%esp
8010a23f:	0f b7 c0             	movzwl %ax,%eax
8010a242:	83 ec 04             	sub    $0x4,%esp
8010a245:	53                   	push   %ebx
8010a246:	50                   	push   %eax
8010a247:	68 03 cd 10 80       	push   $0x8010cd03
8010a24c:	e8 a3 61 ff ff       	call   801003f4 <cprintf>
8010a251:	83 c4 10             	add    $0x10,%esp
}
8010a254:	90                   	nop
8010a255:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a258:	c9                   	leave
8010a259:	c3                   	ret

8010a25a <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010a25a:	55                   	push   %ebp
8010a25b:	89 e5                	mov    %esp,%ebp
8010a25d:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a260:	8b 45 08             	mov    0x8(%ebp),%eax
8010a263:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a266:	8b 45 08             	mov    0x8(%ebp),%eax
8010a269:	83 c0 0e             	add    $0xe,%eax
8010a26c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010a26f:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a272:	0f b6 00             	movzbl (%eax),%eax
8010a275:	0f b6 c0             	movzbl %al,%eax
8010a278:	83 e0 0f             	and    $0xf,%eax
8010a27b:	c1 e0 02             	shl    $0x2,%eax
8010a27e:	89 c2                	mov    %eax,%edx
8010a280:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a283:	01 d0                	add    %edx,%eax
8010a285:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a288:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a28b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010a28e:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a291:	83 c0 0e             	add    $0xe,%eax
8010a294:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010a297:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a29a:	83 c0 14             	add    $0x14,%eax
8010a29d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
8010a2a0:	8b 45 10             	mov    0x10(%ebp),%eax
8010a2a3:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a2a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2ac:	8d 50 06             	lea    0x6(%eax),%edx
8010a2af:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2b2:	83 ec 04             	sub    $0x4,%esp
8010a2b5:	6a 06                	push   $0x6
8010a2b7:	52                   	push   %edx
8010a2b8:	50                   	push   %eax
8010a2b9:	e8 54 b2 ff ff       	call   80105512 <memmove>
8010a2be:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a2c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2c4:	83 c0 06             	add    $0x6,%eax
8010a2c7:	83 ec 04             	sub    $0x4,%esp
8010a2ca:	6a 06                	push   $0x6
8010a2cc:	68 94 7a 19 80       	push   $0x80197a94
8010a2d1:	50                   	push   %eax
8010a2d2:	e8 3b b2 ff ff       	call   80105512 <memmove>
8010a2d7:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a2da:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2dd:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a2e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2e4:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a2e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2eb:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a2ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2f1:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a2f5:	83 ec 0c             	sub    $0xc,%esp
8010a2f8:	6a 54                	push   $0x54
8010a2fa:	e8 0e fd ff ff       	call   8010a00d <H2N_ushort>
8010a2ff:	83 c4 10             	add    $0x10,%esp
8010a302:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a305:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a309:	0f b7 15 60 7d 19 80 	movzwl 0x80197d60,%edx
8010a310:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a313:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a317:	0f b7 05 60 7d 19 80 	movzwl 0x80197d60,%eax
8010a31e:	83 c0 01             	add    $0x1,%eax
8010a321:	66 a3 60 7d 19 80    	mov    %ax,0x80197d60
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a327:	83 ec 0c             	sub    $0xc,%esp
8010a32a:	68 00 40 00 00       	push   $0x4000
8010a32f:	e8 d9 fc ff ff       	call   8010a00d <H2N_ushort>
8010a334:	83 c4 10             	add    $0x10,%esp
8010a337:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a33a:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a33e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a341:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a345:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a348:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a34c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a34f:	83 c0 0c             	add    $0xc,%eax
8010a352:	83 ec 04             	sub    $0x4,%esp
8010a355:	6a 04                	push   $0x4
8010a357:	68 04 f5 10 80       	push   $0x8010f504
8010a35c:	50                   	push   %eax
8010a35d:	e8 b0 b1 ff ff       	call   80105512 <memmove>
8010a362:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a365:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a368:	8d 50 0c             	lea    0xc(%eax),%edx
8010a36b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a36e:	83 c0 10             	add    $0x10,%eax
8010a371:	83 ec 04             	sub    $0x4,%esp
8010a374:	6a 04                	push   $0x4
8010a376:	52                   	push   %edx
8010a377:	50                   	push   %eax
8010a378:	e8 95 b1 ff ff       	call   80105512 <memmove>
8010a37d:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a380:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a383:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a389:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a38c:	83 ec 0c             	sub    $0xc,%esp
8010a38f:	50                   	push   %eax
8010a390:	e8 6d fd ff ff       	call   8010a102 <ipv4_chksum>
8010a395:	83 c4 10             	add    $0x10,%esp
8010a398:	0f b7 c0             	movzwl %ax,%eax
8010a39b:	83 ec 0c             	sub    $0xc,%esp
8010a39e:	50                   	push   %eax
8010a39f:	e8 69 fc ff ff       	call   8010a00d <H2N_ushort>
8010a3a4:	83 c4 10             	add    $0x10,%esp
8010a3a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a3aa:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a3ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3b1:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a3b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3b7:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a3bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3be:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a3c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3c5:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a3c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3cc:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a3d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3d3:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a3d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3da:	8d 50 08             	lea    0x8(%eax),%edx
8010a3dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3e0:	83 c0 08             	add    $0x8,%eax
8010a3e3:	83 ec 04             	sub    $0x4,%esp
8010a3e6:	6a 08                	push   $0x8
8010a3e8:	52                   	push   %edx
8010a3e9:	50                   	push   %eax
8010a3ea:	e8 23 b1 ff ff       	call   80105512 <memmove>
8010a3ef:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a3f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3f5:	8d 50 10             	lea    0x10(%eax),%edx
8010a3f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3fb:	83 c0 10             	add    $0x10,%eax
8010a3fe:	83 ec 04             	sub    $0x4,%esp
8010a401:	6a 30                	push   $0x30
8010a403:	52                   	push   %edx
8010a404:	50                   	push   %eax
8010a405:	e8 08 b1 ff ff       	call   80105512 <memmove>
8010a40a:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a40d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a410:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a416:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a419:	83 ec 0c             	sub    $0xc,%esp
8010a41c:	50                   	push   %eax
8010a41d:	e8 1c 00 00 00       	call   8010a43e <icmp_chksum>
8010a422:	83 c4 10             	add    $0x10,%esp
8010a425:	0f b7 c0             	movzwl %ax,%eax
8010a428:	83 ec 0c             	sub    $0xc,%esp
8010a42b:	50                   	push   %eax
8010a42c:	e8 dc fb ff ff       	call   8010a00d <H2N_ushort>
8010a431:	83 c4 10             	add    $0x10,%esp
8010a434:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a437:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a43b:	90                   	nop
8010a43c:	c9                   	leave
8010a43d:	c3                   	ret

8010a43e <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a43e:	55                   	push   %ebp
8010a43f:	89 e5                	mov    %esp,%ebp
8010a441:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a444:	8b 45 08             	mov    0x8(%ebp),%eax
8010a447:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a44a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a451:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a458:	eb 48                	jmp    8010a4a2 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a45a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a45d:	01 c0                	add    %eax,%eax
8010a45f:	89 c2                	mov    %eax,%edx
8010a461:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a464:	01 d0                	add    %edx,%eax
8010a466:	0f b6 00             	movzbl (%eax),%eax
8010a469:	0f b6 c0             	movzbl %al,%eax
8010a46c:	c1 e0 08             	shl    $0x8,%eax
8010a46f:	89 c2                	mov    %eax,%edx
8010a471:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a474:	01 c0                	add    %eax,%eax
8010a476:	8d 48 01             	lea    0x1(%eax),%ecx
8010a479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a47c:	01 c8                	add    %ecx,%eax
8010a47e:	0f b6 00             	movzbl (%eax),%eax
8010a481:	0f b6 c0             	movzbl %al,%eax
8010a484:	01 d0                	add    %edx,%eax
8010a486:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a489:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a490:	76 0c                	jbe    8010a49e <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a492:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a495:	0f b7 c0             	movzwl %ax,%eax
8010a498:	83 c0 01             	add    $0x1,%eax
8010a49b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a49e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a4a2:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a4a6:	7e b2                	jle    8010a45a <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
8010a4a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a4ab:	f7 d0                	not    %eax
}
8010a4ad:	c9                   	leave
8010a4ae:	c3                   	ret

8010a4af <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a4af:	55                   	push   %ebp
8010a4b0:	89 e5                	mov    %esp,%ebp
8010a4b2:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a4b5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4b8:	83 c0 0e             	add    $0xe,%eax
8010a4bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a4be:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4c1:	0f b6 00             	movzbl (%eax),%eax
8010a4c4:	0f b6 c0             	movzbl %al,%eax
8010a4c7:	83 e0 0f             	and    $0xf,%eax
8010a4ca:	c1 e0 02             	shl    $0x2,%eax
8010a4cd:	89 c2                	mov    %eax,%edx
8010a4cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4d2:	01 d0                	add    %edx,%eax
8010a4d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a4d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4da:	83 c0 14             	add    $0x14,%eax
8010a4dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a4e0:	e8 c3 82 ff ff       	call   801027a8 <kalloc>
8010a4e5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a4e8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a4ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4f2:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a4f6:	0f b6 c0             	movzbl %al,%eax
8010a4f9:	83 e0 02             	and    $0x2,%eax
8010a4fc:	85 c0                	test   %eax,%eax
8010a4fe:	74 3d                	je     8010a53d <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a500:	83 ec 0c             	sub    $0xc,%esp
8010a503:	6a 00                	push   $0x0
8010a505:	6a 12                	push   $0x12
8010a507:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a50a:	50                   	push   %eax
8010a50b:	ff 75 e8             	push   -0x18(%ebp)
8010a50e:	ff 75 08             	push   0x8(%ebp)
8010a511:	e8 a2 01 00 00       	call   8010a6b8 <tcp_pkt_create>
8010a516:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a519:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a51c:	83 ec 08             	sub    $0x8,%esp
8010a51f:	50                   	push   %eax
8010a520:	ff 75 e8             	push   -0x18(%ebp)
8010a523:	e8 79 f1 ff ff       	call   801096a1 <i8254_send>
8010a528:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a52b:	a1 64 7d 19 80       	mov    0x80197d64,%eax
8010a530:	83 c0 01             	add    $0x1,%eax
8010a533:	a3 64 7d 19 80       	mov    %eax,0x80197d64
8010a538:	e9 69 01 00 00       	jmp    8010a6a6 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a53d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a540:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a544:	3c 18                	cmp    $0x18,%al
8010a546:	0f 85 10 01 00 00    	jne    8010a65c <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010a54c:	83 ec 04             	sub    $0x4,%esp
8010a54f:	6a 03                	push   $0x3
8010a551:	68 1e cd 10 80       	push   $0x8010cd1e
8010a556:	ff 75 ec             	push   -0x14(%ebp)
8010a559:	e8 5c af ff ff       	call   801054ba <memcmp>
8010a55e:	83 c4 10             	add    $0x10,%esp
8010a561:	85 c0                	test   %eax,%eax
8010a563:	74 74                	je     8010a5d9 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a565:	83 ec 0c             	sub    $0xc,%esp
8010a568:	68 22 cd 10 80       	push   $0x8010cd22
8010a56d:	e8 82 5e ff ff       	call   801003f4 <cprintf>
8010a572:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a575:	83 ec 0c             	sub    $0xc,%esp
8010a578:	6a 00                	push   $0x0
8010a57a:	6a 10                	push   $0x10
8010a57c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a57f:	50                   	push   %eax
8010a580:	ff 75 e8             	push   -0x18(%ebp)
8010a583:	ff 75 08             	push   0x8(%ebp)
8010a586:	e8 2d 01 00 00       	call   8010a6b8 <tcp_pkt_create>
8010a58b:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a58e:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a591:	83 ec 08             	sub    $0x8,%esp
8010a594:	50                   	push   %eax
8010a595:	ff 75 e8             	push   -0x18(%ebp)
8010a598:	e8 04 f1 ff ff       	call   801096a1 <i8254_send>
8010a59d:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a5a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a5a3:	83 c0 36             	add    $0x36,%eax
8010a5a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a5a9:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a5ac:	50                   	push   %eax
8010a5ad:	ff 75 e0             	push   -0x20(%ebp)
8010a5b0:	6a 00                	push   $0x0
8010a5b2:	6a 00                	push   $0x0
8010a5b4:	e8 5a 04 00 00       	call   8010aa13 <http_proc>
8010a5b9:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a5bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a5bf:	83 ec 0c             	sub    $0xc,%esp
8010a5c2:	50                   	push   %eax
8010a5c3:	6a 18                	push   $0x18
8010a5c5:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a5c8:	50                   	push   %eax
8010a5c9:	ff 75 e8             	push   -0x18(%ebp)
8010a5cc:	ff 75 08             	push   0x8(%ebp)
8010a5cf:	e8 e4 00 00 00       	call   8010a6b8 <tcp_pkt_create>
8010a5d4:	83 c4 20             	add    $0x20,%esp
8010a5d7:	eb 62                	jmp    8010a63b <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a5d9:	83 ec 0c             	sub    $0xc,%esp
8010a5dc:	6a 00                	push   $0x0
8010a5de:	6a 10                	push   $0x10
8010a5e0:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a5e3:	50                   	push   %eax
8010a5e4:	ff 75 e8             	push   -0x18(%ebp)
8010a5e7:	ff 75 08             	push   0x8(%ebp)
8010a5ea:	e8 c9 00 00 00       	call   8010a6b8 <tcp_pkt_create>
8010a5ef:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a5f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a5f5:	83 ec 08             	sub    $0x8,%esp
8010a5f8:	50                   	push   %eax
8010a5f9:	ff 75 e8             	push   -0x18(%ebp)
8010a5fc:	e8 a0 f0 ff ff       	call   801096a1 <i8254_send>
8010a601:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a604:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a607:	83 c0 36             	add    $0x36,%eax
8010a60a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a60d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a610:	50                   	push   %eax
8010a611:	ff 75 e4             	push   -0x1c(%ebp)
8010a614:	6a 00                	push   $0x0
8010a616:	6a 00                	push   $0x0
8010a618:	e8 f6 03 00 00       	call   8010aa13 <http_proc>
8010a61d:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a620:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a623:	83 ec 0c             	sub    $0xc,%esp
8010a626:	50                   	push   %eax
8010a627:	6a 18                	push   $0x18
8010a629:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a62c:	50                   	push   %eax
8010a62d:	ff 75 e8             	push   -0x18(%ebp)
8010a630:	ff 75 08             	push   0x8(%ebp)
8010a633:	e8 80 00 00 00       	call   8010a6b8 <tcp_pkt_create>
8010a638:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a63b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a63e:	83 ec 08             	sub    $0x8,%esp
8010a641:	50                   	push   %eax
8010a642:	ff 75 e8             	push   -0x18(%ebp)
8010a645:	e8 57 f0 ff ff       	call   801096a1 <i8254_send>
8010a64a:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a64d:	a1 64 7d 19 80       	mov    0x80197d64,%eax
8010a652:	83 c0 01             	add    $0x1,%eax
8010a655:	a3 64 7d 19 80       	mov    %eax,0x80197d64
8010a65a:	eb 4a                	jmp    8010a6a6 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a65c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a65f:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a663:	3c 10                	cmp    $0x10,%al
8010a665:	75 3f                	jne    8010a6a6 <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a667:	a1 68 7d 19 80       	mov    0x80197d68,%eax
8010a66c:	83 f8 01             	cmp    $0x1,%eax
8010a66f:	75 35                	jne    8010a6a6 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a671:	83 ec 0c             	sub    $0xc,%esp
8010a674:	6a 00                	push   $0x0
8010a676:	6a 01                	push   $0x1
8010a678:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a67b:	50                   	push   %eax
8010a67c:	ff 75 e8             	push   -0x18(%ebp)
8010a67f:	ff 75 08             	push   0x8(%ebp)
8010a682:	e8 31 00 00 00       	call   8010a6b8 <tcp_pkt_create>
8010a687:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a68a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a68d:	83 ec 08             	sub    $0x8,%esp
8010a690:	50                   	push   %eax
8010a691:	ff 75 e8             	push   -0x18(%ebp)
8010a694:	e8 08 f0 ff ff       	call   801096a1 <i8254_send>
8010a699:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a69c:	c7 05 68 7d 19 80 00 	movl   $0x0,0x80197d68
8010a6a3:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a6a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a6a9:	83 ec 0c             	sub    $0xc,%esp
8010a6ac:	50                   	push   %eax
8010a6ad:	e8 5c 80 ff ff       	call   8010270e <kfree>
8010a6b2:	83 c4 10             	add    $0x10,%esp
}
8010a6b5:	90                   	nop
8010a6b6:	c9                   	leave
8010a6b7:	c3                   	ret

8010a6b8 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a6b8:	55                   	push   %ebp
8010a6b9:	89 e5                	mov    %esp,%ebp
8010a6bb:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a6be:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a6c4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6c7:	83 c0 0e             	add    $0xe,%eax
8010a6ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a6cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6d0:	0f b6 00             	movzbl (%eax),%eax
8010a6d3:	0f b6 c0             	movzbl %al,%eax
8010a6d6:	83 e0 0f             	and    $0xf,%eax
8010a6d9:	c1 e0 02             	shl    $0x2,%eax
8010a6dc:	89 c2                	mov    %eax,%edx
8010a6de:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6e1:	01 d0                	add    %edx,%eax
8010a6e3:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a6e6:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a6e9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a6ec:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a6ef:	83 c0 0e             	add    $0xe,%eax
8010a6f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a6f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6f8:	83 c0 14             	add    $0x14,%eax
8010a6fb:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a6fe:	8b 45 18             	mov    0x18(%ebp),%eax
8010a701:	8d 50 36             	lea    0x36(%eax),%edx
8010a704:	8b 45 10             	mov    0x10(%ebp),%eax
8010a707:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a70c:	8d 50 06             	lea    0x6(%eax),%edx
8010a70f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a712:	83 ec 04             	sub    $0x4,%esp
8010a715:	6a 06                	push   $0x6
8010a717:	52                   	push   %edx
8010a718:	50                   	push   %eax
8010a719:	e8 f4 ad ff ff       	call   80105512 <memmove>
8010a71e:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a721:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a724:	83 c0 06             	add    $0x6,%eax
8010a727:	83 ec 04             	sub    $0x4,%esp
8010a72a:	6a 06                	push   $0x6
8010a72c:	68 94 7a 19 80       	push   $0x80197a94
8010a731:	50                   	push   %eax
8010a732:	e8 db ad ff ff       	call   80105512 <memmove>
8010a737:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a73a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a73d:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a741:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a744:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a748:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a74b:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a74e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a751:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a755:	8b 45 18             	mov    0x18(%ebp),%eax
8010a758:	83 c0 28             	add    $0x28,%eax
8010a75b:	0f b7 c0             	movzwl %ax,%eax
8010a75e:	83 ec 0c             	sub    $0xc,%esp
8010a761:	50                   	push   %eax
8010a762:	e8 a6 f8 ff ff       	call   8010a00d <H2N_ushort>
8010a767:	83 c4 10             	add    $0x10,%esp
8010a76a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a76d:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a771:	0f b7 15 60 7d 19 80 	movzwl 0x80197d60,%edx
8010a778:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a77b:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a77f:	0f b7 05 60 7d 19 80 	movzwl 0x80197d60,%eax
8010a786:	83 c0 01             	add    $0x1,%eax
8010a789:	66 a3 60 7d 19 80    	mov    %ax,0x80197d60
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a78f:	83 ec 0c             	sub    $0xc,%esp
8010a792:	6a 00                	push   $0x0
8010a794:	e8 74 f8 ff ff       	call   8010a00d <H2N_ushort>
8010a799:	83 c4 10             	add    $0x10,%esp
8010a79c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a79f:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a7a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7a6:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a7aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7ad:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a7b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7b4:	83 c0 0c             	add    $0xc,%eax
8010a7b7:	83 ec 04             	sub    $0x4,%esp
8010a7ba:	6a 04                	push   $0x4
8010a7bc:	68 04 f5 10 80       	push   $0x8010f504
8010a7c1:	50                   	push   %eax
8010a7c2:	e8 4b ad ff ff       	call   80105512 <memmove>
8010a7c7:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a7ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a7cd:	8d 50 0c             	lea    0xc(%eax),%edx
8010a7d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7d3:	83 c0 10             	add    $0x10,%eax
8010a7d6:	83 ec 04             	sub    $0x4,%esp
8010a7d9:	6a 04                	push   $0x4
8010a7db:	52                   	push   %edx
8010a7dc:	50                   	push   %eax
8010a7dd:	e8 30 ad ff ff       	call   80105512 <memmove>
8010a7e2:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a7e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7e8:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a7ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7f1:	83 ec 0c             	sub    $0xc,%esp
8010a7f4:	50                   	push   %eax
8010a7f5:	e8 08 f9 ff ff       	call   8010a102 <ipv4_chksum>
8010a7fa:	83 c4 10             	add    $0x10,%esp
8010a7fd:	0f b7 c0             	movzwl %ax,%eax
8010a800:	83 ec 0c             	sub    $0xc,%esp
8010a803:	50                   	push   %eax
8010a804:	e8 04 f8 ff ff       	call   8010a00d <H2N_ushort>
8010a809:	83 c4 10             	add    $0x10,%esp
8010a80c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a80f:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a813:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a816:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a81a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a81d:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a820:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a823:	0f b7 10             	movzwl (%eax),%edx
8010a826:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a829:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a82d:	a1 64 7d 19 80       	mov    0x80197d64,%eax
8010a832:	83 ec 0c             	sub    $0xc,%esp
8010a835:	50                   	push   %eax
8010a836:	e8 e9 f7 ff ff       	call   8010a024 <H2N_uint>
8010a83b:	83 c4 10             	add    $0x10,%esp
8010a83e:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a841:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a844:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a847:	8b 40 04             	mov    0x4(%eax),%eax
8010a84a:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a850:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a853:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a856:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a859:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a85d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a860:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a864:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a867:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a86b:	8b 45 14             	mov    0x14(%ebp),%eax
8010a86e:	89 c2                	mov    %eax,%edx
8010a870:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a873:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a876:	83 ec 0c             	sub    $0xc,%esp
8010a879:	68 90 38 00 00       	push   $0x3890
8010a87e:	e8 8a f7 ff ff       	call   8010a00d <H2N_ushort>
8010a883:	83 c4 10             	add    $0x10,%esp
8010a886:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a889:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a88d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a890:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a896:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a899:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a89f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a8a2:	83 ec 0c             	sub    $0xc,%esp
8010a8a5:	50                   	push   %eax
8010a8a6:	e8 1f 00 00 00       	call   8010a8ca <tcp_chksum>
8010a8ab:	83 c4 10             	add    $0x10,%esp
8010a8ae:	83 c0 08             	add    $0x8,%eax
8010a8b1:	0f b7 c0             	movzwl %ax,%eax
8010a8b4:	83 ec 0c             	sub    $0xc,%esp
8010a8b7:	50                   	push   %eax
8010a8b8:	e8 50 f7 ff ff       	call   8010a00d <H2N_ushort>
8010a8bd:	83 c4 10             	add    $0x10,%esp
8010a8c0:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a8c3:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a8c7:	90                   	nop
8010a8c8:	c9                   	leave
8010a8c9:	c3                   	ret

8010a8ca <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a8ca:	55                   	push   %ebp
8010a8cb:	89 e5                	mov    %esp,%ebp
8010a8cd:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a8d0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a8d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a8d9:	83 c0 14             	add    $0x14,%eax
8010a8dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a8df:	83 ec 04             	sub    $0x4,%esp
8010a8e2:	6a 04                	push   $0x4
8010a8e4:	68 04 f5 10 80       	push   $0x8010f504
8010a8e9:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a8ec:	50                   	push   %eax
8010a8ed:	e8 20 ac ff ff       	call   80105512 <memmove>
8010a8f2:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a8f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a8f8:	83 c0 0c             	add    $0xc,%eax
8010a8fb:	83 ec 04             	sub    $0x4,%esp
8010a8fe:	6a 04                	push   $0x4
8010a900:	50                   	push   %eax
8010a901:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a904:	83 c0 04             	add    $0x4,%eax
8010a907:	50                   	push   %eax
8010a908:	e8 05 ac ff ff       	call   80105512 <memmove>
8010a90d:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a910:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a914:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a918:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a91b:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a91f:	0f b7 c0             	movzwl %ax,%eax
8010a922:	83 ec 0c             	sub    $0xc,%esp
8010a925:	50                   	push   %eax
8010a926:	e8 cb f6 ff ff       	call   80109ff6 <N2H_ushort>
8010a92b:	83 c4 10             	add    $0x10,%esp
8010a92e:	83 e8 14             	sub    $0x14,%eax
8010a931:	0f b7 c0             	movzwl %ax,%eax
8010a934:	83 ec 0c             	sub    $0xc,%esp
8010a937:	50                   	push   %eax
8010a938:	e8 d0 f6 ff ff       	call   8010a00d <H2N_ushort>
8010a93d:	83 c4 10             	add    $0x10,%esp
8010a940:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a944:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a94b:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a94e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a951:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a958:	eb 33                	jmp    8010a98d <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a95a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a95d:	01 c0                	add    %eax,%eax
8010a95f:	89 c2                	mov    %eax,%edx
8010a961:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a964:	01 d0                	add    %edx,%eax
8010a966:	0f b6 00             	movzbl (%eax),%eax
8010a969:	0f b6 c0             	movzbl %al,%eax
8010a96c:	c1 e0 08             	shl    $0x8,%eax
8010a96f:	89 c2                	mov    %eax,%edx
8010a971:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a974:	01 c0                	add    %eax,%eax
8010a976:	8d 48 01             	lea    0x1(%eax),%ecx
8010a979:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a97c:	01 c8                	add    %ecx,%eax
8010a97e:	0f b6 00             	movzbl (%eax),%eax
8010a981:	0f b6 c0             	movzbl %al,%eax
8010a984:	01 d0                	add    %edx,%eax
8010a986:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a989:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a98d:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a991:	7e c7                	jle    8010a95a <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a993:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a996:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a999:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a9a0:	eb 33                	jmp    8010a9d5 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a9a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a9a5:	01 c0                	add    %eax,%eax
8010a9a7:	89 c2                	mov    %eax,%edx
8010a9a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a9ac:	01 d0                	add    %edx,%eax
8010a9ae:	0f b6 00             	movzbl (%eax),%eax
8010a9b1:	0f b6 c0             	movzbl %al,%eax
8010a9b4:	c1 e0 08             	shl    $0x8,%eax
8010a9b7:	89 c2                	mov    %eax,%edx
8010a9b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a9bc:	01 c0                	add    %eax,%eax
8010a9be:	8d 48 01             	lea    0x1(%eax),%ecx
8010a9c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a9c4:	01 c8                	add    %ecx,%eax
8010a9c6:	0f b6 00             	movzbl (%eax),%eax
8010a9c9:	0f b6 c0             	movzbl %al,%eax
8010a9cc:	01 d0                	add    %edx,%eax
8010a9ce:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a9d1:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a9d5:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a9d9:	0f b7 c0             	movzwl %ax,%eax
8010a9dc:	83 ec 0c             	sub    $0xc,%esp
8010a9df:	50                   	push   %eax
8010a9e0:	e8 11 f6 ff ff       	call   80109ff6 <N2H_ushort>
8010a9e5:	83 c4 10             	add    $0x10,%esp
8010a9e8:	66 d1 e8             	shr    $1,%ax
8010a9eb:	0f b7 c0             	movzwl %ax,%eax
8010a9ee:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a9f1:	7c af                	jl     8010a9a2 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a9f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a9f6:	c1 e8 10             	shr    $0x10,%eax
8010a9f9:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a9fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a9ff:	f7 d0                	not    %eax
}
8010aa01:	c9                   	leave
8010aa02:	c3                   	ret

8010aa03 <tcp_fin>:

void tcp_fin(){
8010aa03:	55                   	push   %ebp
8010aa04:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010aa06:	c7 05 68 7d 19 80 01 	movl   $0x1,0x80197d68
8010aa0d:	00 00 00 
}
8010aa10:	90                   	nop
8010aa11:	5d                   	pop    %ebp
8010aa12:	c3                   	ret

8010aa13 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010aa13:	55                   	push   %ebp
8010aa14:	89 e5                	mov    %esp,%ebp
8010aa16:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010aa19:	8b 45 10             	mov    0x10(%ebp),%eax
8010aa1c:	83 ec 04             	sub    $0x4,%esp
8010aa1f:	6a 00                	push   $0x0
8010aa21:	68 2b cd 10 80       	push   $0x8010cd2b
8010aa26:	50                   	push   %eax
8010aa27:	e8 65 00 00 00       	call   8010aa91 <http_strcpy>
8010aa2c:	83 c4 10             	add    $0x10,%esp
8010aa2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010aa32:	8b 45 10             	mov    0x10(%ebp),%eax
8010aa35:	83 ec 04             	sub    $0x4,%esp
8010aa38:	ff 75 f4             	push   -0xc(%ebp)
8010aa3b:	68 3e cd 10 80       	push   $0x8010cd3e
8010aa40:	50                   	push   %eax
8010aa41:	e8 4b 00 00 00       	call   8010aa91 <http_strcpy>
8010aa46:	83 c4 10             	add    $0x10,%esp
8010aa49:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010aa4c:	8b 45 10             	mov    0x10(%ebp),%eax
8010aa4f:	83 ec 04             	sub    $0x4,%esp
8010aa52:	ff 75 f4             	push   -0xc(%ebp)
8010aa55:	68 59 cd 10 80       	push   $0x8010cd59
8010aa5a:	50                   	push   %eax
8010aa5b:	e8 31 00 00 00       	call   8010aa91 <http_strcpy>
8010aa60:	83 c4 10             	add    $0x10,%esp
8010aa63:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010aa66:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010aa69:	83 e0 01             	and    $0x1,%eax
8010aa6c:	85 c0                	test   %eax,%eax
8010aa6e:	74 11                	je     8010aa81 <http_proc+0x6e>
    char *payload = (char *)send;
8010aa70:	8b 45 10             	mov    0x10(%ebp),%eax
8010aa73:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010aa76:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010aa79:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010aa7c:	01 d0                	add    %edx,%eax
8010aa7e:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010aa81:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010aa84:	8b 45 14             	mov    0x14(%ebp),%eax
8010aa87:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010aa89:	e8 75 ff ff ff       	call   8010aa03 <tcp_fin>
}
8010aa8e:	90                   	nop
8010aa8f:	c9                   	leave
8010aa90:	c3                   	ret

8010aa91 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010aa91:	55                   	push   %ebp
8010aa92:	89 e5                	mov    %esp,%ebp
8010aa94:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010aa97:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010aa9e:	eb 20                	jmp    8010aac0 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010aaa0:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010aaa3:	8b 45 0c             	mov    0xc(%ebp),%eax
8010aaa6:	01 d0                	add    %edx,%eax
8010aaa8:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010aaab:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010aaae:	01 ca                	add    %ecx,%edx
8010aab0:	89 d1                	mov    %edx,%ecx
8010aab2:	8b 55 08             	mov    0x8(%ebp),%edx
8010aab5:	01 ca                	add    %ecx,%edx
8010aab7:	0f b6 00             	movzbl (%eax),%eax
8010aaba:	88 02                	mov    %al,(%edx)
    i++;
8010aabc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010aac0:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010aac3:	8b 45 0c             	mov    0xc(%ebp),%eax
8010aac6:	01 d0                	add    %edx,%eax
8010aac8:	0f b6 00             	movzbl (%eax),%eax
8010aacb:	84 c0                	test   %al,%al
8010aacd:	75 d1                	jne    8010aaa0 <http_strcpy+0xf>
  }
  return i;
8010aacf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010aad2:	c9                   	leave
8010aad3:	c3                   	ret

8010aad4 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010aad4:	55                   	push   %ebp
8010aad5:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010aad7:	c7 05 70 7d 19 80 c2 	movl   $0x8010f5c2,0x80197d70
8010aade:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010aae1:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010aae6:	c1 e8 09             	shr    $0x9,%eax
8010aae9:	a3 6c 7d 19 80       	mov    %eax,0x80197d6c
}
8010aaee:	90                   	nop
8010aaef:	5d                   	pop    %ebp
8010aaf0:	c3                   	ret

8010aaf1 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010aaf1:	55                   	push   %ebp
8010aaf2:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010aaf4:	90                   	nop
8010aaf5:	5d                   	pop    %ebp
8010aaf6:	c3                   	ret

8010aaf7 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010aaf7:	55                   	push   %ebp
8010aaf8:	89 e5                	mov    %esp,%ebp
8010aafa:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010aafd:	8b 45 08             	mov    0x8(%ebp),%eax
8010ab00:	83 c0 0c             	add    $0xc,%eax
8010ab03:	83 ec 0c             	sub    $0xc,%esp
8010ab06:	50                   	push   %eax
8010ab07:	e8 40 a6 ff ff       	call   8010514c <holdingsleep>
8010ab0c:	83 c4 10             	add    $0x10,%esp
8010ab0f:	85 c0                	test   %eax,%eax
8010ab11:	75 0d                	jne    8010ab20 <iderw+0x29>
    panic("iderw: buf not locked");
8010ab13:	83 ec 0c             	sub    $0xc,%esp
8010ab16:	68 6a cd 10 80       	push   $0x8010cd6a
8010ab1b:	e8 89 5a ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010ab20:	8b 45 08             	mov    0x8(%ebp),%eax
8010ab23:	8b 00                	mov    (%eax),%eax
8010ab25:	83 e0 06             	and    $0x6,%eax
8010ab28:	83 f8 02             	cmp    $0x2,%eax
8010ab2b:	75 0d                	jne    8010ab3a <iderw+0x43>
    panic("iderw: nothing to do");
8010ab2d:	83 ec 0c             	sub    $0xc,%esp
8010ab30:	68 80 cd 10 80       	push   $0x8010cd80
8010ab35:	e8 6f 5a ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010ab3a:	8b 45 08             	mov    0x8(%ebp),%eax
8010ab3d:	8b 40 04             	mov    0x4(%eax),%eax
8010ab40:	83 f8 01             	cmp    $0x1,%eax
8010ab43:	74 0d                	je     8010ab52 <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010ab45:	83 ec 0c             	sub    $0xc,%esp
8010ab48:	68 95 cd 10 80       	push   $0x8010cd95
8010ab4d:	e8 57 5a ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010ab52:	8b 45 08             	mov    0x8(%ebp),%eax
8010ab55:	8b 40 08             	mov    0x8(%eax),%eax
8010ab58:	8b 15 6c 7d 19 80    	mov    0x80197d6c,%edx
8010ab5e:	39 d0                	cmp    %edx,%eax
8010ab60:	72 0d                	jb     8010ab6f <iderw+0x78>
    panic("iderw: block out of range");
8010ab62:	83 ec 0c             	sub    $0xc,%esp
8010ab65:	68 b3 cd 10 80       	push   $0x8010cdb3
8010ab6a:	e8 3a 5a ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010ab6f:	8b 15 70 7d 19 80    	mov    0x80197d70,%edx
8010ab75:	8b 45 08             	mov    0x8(%ebp),%eax
8010ab78:	8b 40 08             	mov    0x8(%eax),%eax
8010ab7b:	c1 e0 09             	shl    $0x9,%eax
8010ab7e:	01 d0                	add    %edx,%eax
8010ab80:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010ab83:	8b 45 08             	mov    0x8(%ebp),%eax
8010ab86:	8b 00                	mov    (%eax),%eax
8010ab88:	83 e0 04             	and    $0x4,%eax
8010ab8b:	85 c0                	test   %eax,%eax
8010ab8d:	74 2b                	je     8010abba <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010ab8f:	8b 45 08             	mov    0x8(%ebp),%eax
8010ab92:	8b 00                	mov    (%eax),%eax
8010ab94:	83 e0 fb             	and    $0xfffffffb,%eax
8010ab97:	89 c2                	mov    %eax,%edx
8010ab99:	8b 45 08             	mov    0x8(%ebp),%eax
8010ab9c:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010ab9e:	8b 45 08             	mov    0x8(%ebp),%eax
8010aba1:	83 c0 5c             	add    $0x5c,%eax
8010aba4:	83 ec 04             	sub    $0x4,%esp
8010aba7:	68 00 02 00 00       	push   $0x200
8010abac:	50                   	push   %eax
8010abad:	ff 75 f4             	push   -0xc(%ebp)
8010abb0:	e8 5d a9 ff ff       	call   80105512 <memmove>
8010abb5:	83 c4 10             	add    $0x10,%esp
8010abb8:	eb 1a                	jmp    8010abd4 <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010abba:	8b 45 08             	mov    0x8(%ebp),%eax
8010abbd:	83 c0 5c             	add    $0x5c,%eax
8010abc0:	83 ec 04             	sub    $0x4,%esp
8010abc3:	68 00 02 00 00       	push   $0x200
8010abc8:	ff 75 f4             	push   -0xc(%ebp)
8010abcb:	50                   	push   %eax
8010abcc:	e8 41 a9 ff ff       	call   80105512 <memmove>
8010abd1:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010abd4:	8b 45 08             	mov    0x8(%ebp),%eax
8010abd7:	8b 00                	mov    (%eax),%eax
8010abd9:	83 c8 02             	or     $0x2,%eax
8010abdc:	89 c2                	mov    %eax,%edx
8010abde:	8b 45 08             	mov    0x8(%ebp),%eax
8010abe1:	89 10                	mov    %edx,(%eax)
}
8010abe3:	90                   	nop
8010abe4:	c9                   	leave
8010abe5:	c3                   	ret
