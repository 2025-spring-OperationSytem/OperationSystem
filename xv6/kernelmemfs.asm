
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
8010006f:	68 40 a9 10 80       	push   $0x8010a940
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 1a 4f 00 00       	call   80104f98 <initlock>
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
801000bd:	68 47 a9 10 80       	push   $0x8010a947
801000c2:	50                   	push   %eax
801000c3:	e8 73 4d 00 00       	call   80104e3b <initsleeplock>
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
80100101:	e8 b4 4e 00 00       	call   80104fba <acquire>
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
80100140:	e8 e3 4e 00 00       	call   80105028 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 20 4d 00 00       	call   80104e77 <acquiresleep>
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
801001c1:	e8 62 4e 00 00       	call   80105028 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 9f 4c 00 00       	call   80104e77 <acquiresleep>
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
801001f5:	68 4e a9 10 80       	push   $0x8010a94e
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
8010022d:	e8 10 a6 00 00       	call   8010a842 <iderw>
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
8010024a:	e8 da 4c 00 00       	call   80104f29 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 5f a9 10 80       	push   $0x8010a95f
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
80100278:	e8 c5 a5 00 00       	call   8010a842 <iderw>
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
80100293:	e8 91 4c 00 00       	call   80104f29 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 66 a9 10 80       	push   $0x8010a966
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 20 4c 00 00       	call   80104edb <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 ef 4c 00 00       	call   80104fba <acquire>
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
80100336:	e8 ed 4c 00 00       	call   80105028 <release>
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
80100410:	e8 a5 4b 00 00       	call   80104fba <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 6d a9 10 80       	push   $0x8010a96d
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
80100510:	c7 45 ec 76 a9 10 80 	movl   $0x8010a976,-0x14(%ebp)
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
8010059e:	e8 85 4a 00 00       	call   80105028 <release>
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
801005c7:	68 7d a9 10 80       	push   $0x8010a97d
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
801005e6:	68 91 a9 10 80       	push   $0x8010a991
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 77 4a 00 00       	call   8010507a <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 93 a9 10 80       	push   $0x8010a993
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
801006a1:	e8 09 81 00 00       	call   801087af <graphic_scroll_up>
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
801006f4:	e8 b6 80 00 00       	call   801087af <graphic_scroll_up>
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
80100756:	e8 c1 80 00 00       	call   8010881c <font_render>
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
80100793:	e8 91 64 00 00       	call   80106c29 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 84 64 00 00       	call   80106c29 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 77 64 00 00       	call   80106c29 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x57>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 67 64 00 00       	call   80106c29 <uartputc>
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
801007eb:	e8 ca 47 00 00       	call   80104fba <acquire>
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
8010093f:	e8 26 3c 00 00       	call   8010456a <wakeup>
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
8010096a:	e8 b9 46 00 00       	call   80105028 <release>
8010096f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100972:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100976:	74 05                	je     8010097d <consoleintr+0x1a7>
    procdump();  // now call procdump() wo. cons.lock held
80100978:	e8 a8 3c 00 00       	call   80104625 <procdump>
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
801009a2:	e8 13 46 00 00       	call   80104fba <acquire>
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
801009c3:	e8 60 46 00 00       	call   80105028 <release>
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
801009f0:	e8 8e 3a 00 00       	call   80104483 <sleep>
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
80100a6e:	e8 b5 45 00 00       	call   80105028 <release>
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
80100aac:	e8 09 45 00 00       	call   80104fba <acquire>
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
80100aee:	e8 35 45 00 00       	call   80105028 <release>
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
80100b1c:	68 97 a9 10 80       	push   $0x8010a997
80100b21:	68 00 1a 19 80       	push   $0x80191a00
80100b26:	e8 6d 44 00 00       	call   80104f98 <initlock>
80100b2b:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b2e:	c7 05 4c 1a 19 80 90 	movl   $0x80100a90,0x80191a4c
80100b35:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b38:	c7 05 48 1a 19 80 80 	movl   $0x80100980,0x80191a48
80100b3f:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b42:	c7 45 f4 9f a9 10 80 	movl   $0x8010a99f,-0xc(%ebp)
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
80100bbf:	68 b5 a9 10 80       	push   $0x8010a9b5
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
80100c1b:	e8 05 70 00 00       	call   80107c25 <setupkvm>
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
80100cc1:	e8 59 73 00 00       	call   8010801f <allocuvm>
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
80100d07:	e8 46 72 00 00       	call   80107f52 <loaduvm>
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
80100d76:	e8 a4 72 00 00       	call   8010801f <allocuvm>
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
80100d9a:	e8 e2 74 00 00       	call   80108281 <clearpteu>
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
80100dd3:	e8 a6 46 00 00       	call   8010547e <strlen>
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
80100e00:	e8 79 46 00 00       	call   8010547e <strlen>
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
80100e26:	e8 f5 75 00 00       	call   80108420 <copyout>
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
80100ec2:	e8 59 75 00 00       	call   80108420 <copyout>
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
80100f10:	e8 1e 45 00 00       	call   80105433 <safestrcpy>
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
80100f53:	e8 eb 6d 00 00       	call   80107d43 <switchuvm>
80100f58:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 cc             	push   -0x34(%ebp)
80100f61:	e8 82 72 00 00       	call   801081e8 <freevm>
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
80100fa1:	e8 42 72 00 00       	call   801081e8 <freevm>
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
80100fd2:	68 c1 a9 10 80       	push   $0x8010a9c1
80100fd7:	68 a0 1a 19 80       	push   $0x80191aa0
80100fdc:	e8 b7 3f 00 00       	call   80104f98 <initlock>
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
80100ff5:	e8 c0 3f 00 00       	call   80104fba <acquire>
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
80101022:	e8 01 40 00 00       	call   80105028 <release>
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
80101045:	e8 de 3f 00 00       	call   80105028 <release>
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
80101062:	e8 53 3f 00 00       	call   80104fba <acquire>
80101067:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106a:	8b 45 08             	mov    0x8(%ebp),%eax
8010106d:	8b 40 04             	mov    0x4(%eax),%eax
80101070:	85 c0                	test   %eax,%eax
80101072:	7f 0d                	jg     80101081 <filedup+0x2d>
    panic("filedup");
80101074:	83 ec 0c             	sub    $0xc,%esp
80101077:	68 c8 a9 10 80       	push   $0x8010a9c8
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
80101098:	e8 8b 3f 00 00       	call   80105028 <release>
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
801010b3:	e8 02 3f 00 00       	call   80104fba <acquire>
801010b8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bb:	8b 45 08             	mov    0x8(%ebp),%eax
801010be:	8b 40 04             	mov    0x4(%eax),%eax
801010c1:	85 c0                	test   %eax,%eax
801010c3:	7f 0d                	jg     801010d2 <fileclose+0x2d>
    panic("fileclose");
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	68 d0 a9 10 80       	push   $0x8010a9d0
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
801010f3:	e8 30 3f 00 00       	call   80105028 <release>
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
80101141:	e8 e2 3e 00 00       	call   80105028 <release>
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
80101290:	68 da a9 10 80       	push   $0x8010a9da
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
80101393:	68 e3 a9 10 80       	push   $0x8010a9e3
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
801013c9:	68 f3 a9 10 80       	push   $0x8010a9f3
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
80101401:	e8 e9 3e 00 00       	call   801052ef <memmove>
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
80101447:	e8 e4 3d 00 00       	call   80105230 <memset>
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
801015a5:	68 00 aa 10 80       	push   $0x8010aa00
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
80101630:	68 16 aa 10 80       	push   $0x8010aa16
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
80101694:	68 29 aa 10 80       	push   $0x8010aa29
80101699:	68 60 24 19 80       	push   $0x80192460
8010169e:	e8 f5 38 00 00       	call   80104f98 <initlock>
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
801016ca:	68 30 aa 10 80       	push   $0x8010aa30
801016cf:	50                   	push   %eax
801016d0:	e8 66 37 00 00       	call   80104e3b <initsleeplock>
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
80101729:	68 38 aa 10 80       	push   $0x8010aa38
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
801017a2:	e8 89 3a 00 00       	call   80105230 <memset>
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
80101809:	68 8b aa 10 80       	push   $0x8010aa8b
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
801018af:	e8 3b 3a 00 00       	call   801052ef <memmove>
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
801018e4:	e8 d1 36 00 00       	call   80104fba <acquire>
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
80101932:	e8 f1 36 00 00       	call   80105028 <release>
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
8010196e:	68 9d aa 10 80       	push   $0x8010aa9d
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
801019ab:	e8 78 36 00 00       	call   80105028 <release>
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
801019c6:	e8 ef 35 00 00       	call   80104fba <acquire>
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
801019e5:	e8 3e 36 00 00       	call   80105028 <release>
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
80101a0b:	68 ad aa 10 80       	push   $0x8010aaad
80101a10:	e8 94 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	83 c0 0c             	add    $0xc,%eax
80101a1b:	83 ec 0c             	sub    $0xc,%esp
80101a1e:	50                   	push   %eax
80101a1f:	e8 53 34 00 00       	call   80104e77 <acquiresleep>
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
80101ac9:	e8 21 38 00 00       	call   801052ef <memmove>
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
80101af8:	68 b3 aa 10 80       	push   $0x8010aab3
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
80101b1b:	e8 09 34 00 00       	call   80104f29 <holdingsleep>
80101b20:	83 c4 10             	add    $0x10,%esp
80101b23:	85 c0                	test   %eax,%eax
80101b25:	74 0a                	je     80101b31 <iunlock+0x2c>
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	8b 40 08             	mov    0x8(%eax),%eax
80101b2d:	85 c0                	test   %eax,%eax
80101b2f:	7f 0d                	jg     80101b3e <iunlock+0x39>
    panic("iunlock");
80101b31:	83 ec 0c             	sub    $0xc,%esp
80101b34:	68 c2 aa 10 80       	push   $0x8010aac2
80101b39:	e8 6b ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	83 c0 0c             	add    $0xc,%eax
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	50                   	push   %eax
80101b48:	e8 8e 33 00 00       	call   80104edb <releasesleep>
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
80101b63:	e8 0f 33 00 00       	call   80104e77 <acquiresleep>
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
80101b89:	e8 2c 34 00 00       	call   80104fba <acquire>
80101b8e:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	8b 40 08             	mov    0x8(%eax),%eax
80101b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	68 60 24 19 80       	push   $0x80192460
80101ba2:	e8 81 34 00 00       	call   80105028 <release>
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
80101be9:	e8 ed 32 00 00       	call   80104edb <releasesleep>
80101bee:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	68 60 24 19 80       	push   $0x80192460
80101bf9:	e8 bc 33 00 00       	call   80104fba <acquire>
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
80101c18:	e8 0b 34 00 00       	call   80105028 <release>
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
80101d5c:	68 ca aa 10 80       	push   $0x8010aaca
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
80101ffa:	e8 f0 32 00 00       	call   801052ef <memmove>
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
8010214a:	e8 a0 31 00 00       	call   801052ef <memmove>
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
801021ca:	e8 b6 31 00 00       	call   80105385 <strncmp>
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
801021ea:	68 dd aa 10 80       	push   $0x8010aadd
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
80102219:	68 ef aa 10 80       	push   $0x8010aaef
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
801022ee:	68 fe aa 10 80       	push   $0x8010aafe
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
80102329:	e8 ad 30 00 00       	call   801053db <strncpy>
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
80102355:	68 0b ab 10 80       	push   $0x8010ab0b
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
801023c7:	e8 23 2f 00 00       	call   801052ef <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	eb 26                	jmp    801023f7 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	50                   	push   %eax
801023d8:	ff 75 f4             	push   -0xc(%ebp)
801023db:	ff 75 0c             	push   0xc(%ebp)
801023de:	e8 0c 2f 00 00       	call   801052ef <memmove>
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
801025d5:	68 14 ab 10 80       	push   $0x8010ab14
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
8010267c:	68 46 ab 10 80       	push   $0x8010ab46
80102681:	68 c0 40 19 80       	push   $0x801940c0
80102686:	e8 0d 29 00 00       	call   80104f98 <initlock>
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
8010273b:	68 4b ab 10 80       	push   $0x8010ab4b
80102740:	e8 64 de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102745:	83 ec 04             	sub    $0x4,%esp
80102748:	68 00 10 00 00       	push   $0x1000
8010274d:	6a 01                	push   $0x1
8010274f:	ff 75 08             	push   0x8(%ebp)
80102752:	e8 d9 2a 00 00       	call   80105230 <memset>
80102757:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010275a:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010275f:	85 c0                	test   %eax,%eax
80102761:	74 10                	je     80102773 <kfree+0x65>
    acquire(&kmem.lock);
80102763:	83 ec 0c             	sub    $0xc,%esp
80102766:	68 c0 40 19 80       	push   $0x801940c0
8010276b:	e8 4a 28 00 00       	call   80104fba <acquire>
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
8010279d:	e8 86 28 00 00       	call   80105028 <release>
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
801027bf:	e8 f6 27 00 00       	call   80104fba <acquire>
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
801027f0:	e8 33 28 00 00       	call   80105028 <release>
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
80102d14:	e8 7e 25 00 00       	call   80105297 <memcmp>
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
80102e28:	68 51 ab 10 80       	push   $0x8010ab51
80102e2d:	68 20 41 19 80       	push   $0x80194120
80102e32:	e8 61 21 00 00       	call   80104f98 <initlock>
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
80102edd:	e8 0d 24 00 00       	call   801052ef <memmove>
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
8010304c:	e8 69 1f 00 00       	call   80104fba <acquire>
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
8010306a:	e8 14 14 00 00       	call   80104483 <sleep>
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
8010309f:	e8 df 13 00 00       	call   80104483 <sleep>
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
801030be:	e8 65 1f 00 00       	call   80105028 <release>
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
801030df:	e8 d6 1e 00 00       	call   80104fba <acquire>
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
80103100:	68 55 ab 10 80       	push   $0x8010ab55
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
8010312e:	e8 37 14 00 00       	call   8010456a <wakeup>
80103133:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103136:	83 ec 0c             	sub    $0xc,%esp
80103139:	68 20 41 19 80       	push   $0x80194120
8010313e:	e8 e5 1e 00 00       	call   80105028 <release>
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
80103159:	e8 5c 1e 00 00       	call   80104fba <acquire>
8010315e:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103161:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103168:	00 00 00 
    wakeup(&log);
8010316b:	83 ec 0c             	sub    $0xc,%esp
8010316e:	68 20 41 19 80       	push   $0x80194120
80103173:	e8 f2 13 00 00       	call   8010456a <wakeup>
80103178:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010317b:	83 ec 0c             	sub    $0xc,%esp
8010317e:	68 20 41 19 80       	push   $0x80194120
80103183:	e8 a0 1e 00 00       	call   80105028 <release>
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
801031ff:	e8 eb 20 00 00       	call   801052ef <memmove>
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
8010329c:	68 64 ab 10 80       	push   $0x8010ab64
801032a1:	e8 03 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a6:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032ab:	85 c0                	test   %eax,%eax
801032ad:	7f 0d                	jg     801032bc <log_write+0x45>
    panic("log_write outside of trans");
801032af:	83 ec 0c             	sub    $0xc,%esp
801032b2:	68 7a ab 10 80       	push   $0x8010ab7a
801032b7:	e8 ed d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032bc:	83 ec 0c             	sub    $0xc,%esp
801032bf:	68 20 41 19 80       	push   $0x80194120
801032c4:	e8 f1 1c 00 00       	call   80104fba <acquire>
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
80103342:	e8 e1 1c 00 00       	call   80105028 <release>
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
80103378:	e8 77 53 00 00       	call   801086f4 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337d:	83 ec 08             	sub    $0x8,%esp
80103380:	68 00 00 40 80       	push   $0x80400000
80103385:	68 00 90 19 80       	push   $0x80199000
8010338a:	e8 e4 f2 ff ff       	call   80102673 <kinit1>
8010338f:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103392:	e8 7b 49 00 00       	call   80107d12 <kvmalloc>
  mpinit_uefi();
80103397:	e8 22 51 00 00       	call   801084be <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339c:	e8 3f f6 ff ff       	call   801029e0 <lapicinit>
  seginit();       // segment descriptors
801033a1:	e8 03 44 00 00       	call   801077a9 <seginit>
  picinit();    // disable pic
801033a6:	e8 9b 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033ab:	e8 de f1 ff ff       	call   8010258e <ioapicinit>
  consoleinit();   // console hardware
801033b0:	e8 54 d7 ff ff       	call   80100b09 <consoleinit>
  uartinit();      // serial port
801033b5:	e8 88 37 00 00       	call   80106b42 <uartinit>
  pinit();         // process table
801033ba:	e8 c0 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bf:	e8 d9 32 00 00       	call   8010669d <tvinit>
  binit();         // buffer cache
801033c4:	e8 9d cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c9:	e8 fb db ff ff       	call   80100fc9 <fileinit>
  ideinit();       // disk 
801033ce:	e8 4c 74 00 00       	call   8010a81f <ideinit>
  startothers();   // start other processors
801033d3:	e8 8a 00 00 00       	call   80103462 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d8:	83 ec 08             	sub    $0x8,%esp
801033db:	68 00 00 00 a0       	push   $0xa0000000
801033e0:	68 00 00 40 80       	push   $0x80400000
801033e5:	e8 c2 f2 ff ff       	call   801026ac <kinit2>
801033ea:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033ed:	e8 5d 55 00 00       	call   8010894f <pci_init>
  arp_scan();
801033f2:	e8 92 62 00 00       	call   80109689 <arp_scan>
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
80103407:	e8 1e 49 00 00       	call   80107d2a <switchkvm>
  seginit();
8010340c:	e8 98 43 00 00       	call   801077a9 <seginit>
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
80103433:	68 95 ab 10 80       	push   $0x8010ab95
80103438:	e8 b7 cf ff ff       	call   801003f4 <cprintf>
8010343d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103440:	e8 ce 33 00 00       	call   80106813 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103445:	e8 6e 05 00 00       	call   801039b8 <mycpu>
8010344a:	05 a0 00 00 00       	add    $0xa0,%eax
8010344f:	83 ec 08             	sub    $0x8,%esp
80103452:	6a 01                	push   $0x1
80103454:	50                   	push   %eax
80103455:	e8 f3 fe ff ff       	call   8010334d <xchg>
8010345a:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345d:	e8 9a 0d 00 00       	call   801041fc <scheduler>

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
80103480:	e8 6a 1e 00 00       	call   801052ef <memmove>
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
80103607:	68 a9 ab 10 80       	push   $0x8010aba9
8010360c:	50                   	push   %eax
8010360d:	e8 86 19 00 00       	call   80104f98 <initlock>
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
801036cc:	e8 e9 18 00 00       	call   80104fba <acquire>
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
801036f3:	e8 72 0e 00 00       	call   8010456a <wakeup>
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
80103716:	e8 4f 0e 00 00       	call   8010456a <wakeup>
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
8010373f:	e8 e4 18 00 00       	call   80105028 <release>
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
8010375e:	e8 c5 18 00 00       	call   80105028 <release>
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
80103778:	e8 3d 18 00 00       	call   80104fba <acquire>
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
801037ac:	e8 77 18 00 00       	call   80105028 <release>
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
801037ca:	e8 9b 0d 00 00       	call   8010456a <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 9b 0c 00 00       	call   80104483 <sleep>
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
8010384d:	e8 18 0d 00 00       	call   8010456a <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 c7 17 00 00       	call   80105028 <release>
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
80103879:	e8 3c 17 00 00       	call   80104fba <acquire>
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
80103896:	e8 8d 17 00 00       	call   80105028 <release>
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
801038b9:	e8 c5 0b 00 00       	call   80104483 <sleep>
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
8010394c:	e8 19 0c 00 00       	call   8010456a <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 c8 16 00 00       	call   80105028 <release>
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
80103988:	68 b0 ab 10 80       	push   $0x8010abb0
8010398d:	68 00 4e 19 80       	push   $0x80194e00
80103992:	e8 01 16 00 00       	call   80104f98 <initlock>
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
801039cf:	68 b8 ab 10 80       	push   $0x8010abb8
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
80103a24:	68 de ab 10 80       	push   $0x8010abde
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
80103a36:	e8 ea 16 00 00       	call   80105125 <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 1e 17 00 00       	call   80105172 <popcli>
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
80103a67:	e8 4e 15 00 00       	call   80104fba <acquire>
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
80103a97:	e8 8c 15 00 00       	call   80105028 <release>
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
80103b24:	e8 07 17 00 00       	call   80105230 <memset>
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
80103b42:	e8 e9 16 00 00       	call   80105230 <memset>
80103b47:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103b4a:	83 ec 0c             	sub    $0xc,%esp
80103b4d:	68 00 4e 19 80       	push   $0x80194e00
80103b52:	e8 d1 14 00 00       	call   80105028 <release>
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
80103b9f:	ba 57 66 10 80       	mov    $0x80106657,%edx
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
80103bc4:	e8 67 16 00 00       	call   80105230 <memset>
80103bc9:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcf:	8b 40 1c             	mov    0x1c(%eax),%eax
80103bd2:	ba 3d 44 10 80       	mov    $0x8010443d,%edx
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
80103bf5:	e8 2b 40 00 00       	call   80107c25 <setupkvm>
80103bfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bfd:	89 42 04             	mov    %eax,0x4(%edx)
80103c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c03:	8b 40 04             	mov    0x4(%eax),%eax
80103c06:	85 c0                	test   %eax,%eax
80103c08:	75 0d                	jne    80103c17 <userinit+0x38>
    panic("userinit: out of memory?");
80103c0a:	83 ec 0c             	sub    $0xc,%esp
80103c0d:	68 ee ab 10 80       	push   $0x8010abee
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
80103c2c:	e8 b1 42 00 00       	call   80107ee2 <inituvm>
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
80103c4b:	e8 e0 15 00 00       	call   80105230 <memset>
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
80103cc5:	68 07 ac 10 80       	push   $0x8010ac07
80103cca:	50                   	push   %eax
80103ccb:	e8 63 17 00 00       	call   80105433 <safestrcpy>
80103cd0:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103cd3:	83 ec 0c             	sub    $0xc,%esp
80103cd6:	68 10 ac 10 80       	push   $0x8010ac10
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
80103cf1:	e8 c4 12 00 00       	call   80104fba <acquire>
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
80103d1a:	e8 88 0b 00 00       	call   801048a7 <enqueue>
80103d1f:	83 c4 10             	add    $0x10,%esp

  release(&ptable.lock);
80103d22:	83 ec 0c             	sub    $0xc,%esp
80103d25:	68 00 4e 19 80       	push   $0x80194e00
80103d2a:	e8 f9 12 00 00       	call   80105028 <release>
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
80103d67:	e8 b3 42 00 00       	call   8010801f <allocuvm>
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
80103d9b:	e8 84 43 00 00       	call   80108124 <deallocuvm>
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
80103dc1:	e8 7d 3f 00 00       	call   80107d43 <switchuvm>
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
80103df4:	e9 99 01 00 00       	jmp    80103f92 <fork+0x1c2>
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
80103e09:	e8 b4 44 00 00       	call   801082c2 <copyuvm>
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
80103e4c:	e9 41 01 00 00       	jmp    80103f92 <fork+0x1c2>
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
80103f03:	e8 2b 15 00 00       	call   80105433 <safestrcpy>
80103f08:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103f0b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f0e:	8b 40 10             	mov    0x10(%eax),%eax
80103f11:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103f14:	83 ec 0c             	sub    $0xc,%esp
80103f17:	68 00 4e 19 80       	push   $0x80194e00
80103f1c:	e8 99 10 00 00       	call   80104fba <acquire>
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
80103f44:	68 14 ac 10 80       	push   $0x8010ac14
80103f49:	e8 a6 c4 ff ff       	call   801003f4 <cprintf>
80103f4e:	83 c4 10             	add    $0x10,%esp
  if (mycpu()->sched_policy > 0){
80103f51:	e8 62 fa ff ff       	call   801039b8 <mycpu>
80103f56:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80103f5c:	85 c0                	test   %eax,%eax
80103f5e:	7e 1f                	jle    80103f7f <fork+0x1af>
    kernel_pstat.priority[np - ptable.proc] = 3;
80103f60:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f63:	2d 34 4e 19 80       	sub    $0x80194e34,%eax
80103f68:	c1 f8 02             	sar    $0x2,%eax
80103f6b:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80103f71:	83 e8 80             	sub    $0xffffff80,%eax
80103f74:	c7 04 85 00 42 19 80 	movl   $0x3,-0x7fe6be00(,%eax,4)
80103f7b:	03 00 00 00 
  }
   

  release(&ptable.lock);
80103f7f:	83 ec 0c             	sub    $0xc,%esp
80103f82:	68 00 4e 19 80       	push   $0x80194e00
80103f87:	e8 9c 10 00 00       	call   80105028 <release>
80103f8c:	83 c4 10             	add    $0x10,%esp

  return pid;
80103f8f:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103f92:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103f95:	5b                   	pop    %ebx
80103f96:	5e                   	pop    %esi
80103f97:	5f                   	pop    %edi
80103f98:	5d                   	pop    %ebp
80103f99:	c3                   	ret

80103f9a <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103f9a:	55                   	push   %ebp
80103f9b:	89 e5                	mov    %esp,%ebp
80103f9d:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103fa0:	e8 8b fa ff ff       	call   80103a30 <myproc>
80103fa5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103fa8:	a1 60 71 19 80       	mov    0x80197160,%eax
80103fad:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103fb0:	75 0d                	jne    80103fbf <exit+0x25>
    panic("init exiting");
80103fb2:	83 ec 0c             	sub    $0xc,%esp
80103fb5:	68 3e ac 10 80       	push   $0x8010ac3e
80103fba:	e8 ea c5 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103fbf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103fc6:	eb 3f                	jmp    80104007 <exit+0x6d>
    if(curproc->ofile[fd]){
80103fc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fcb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103fce:	83 c2 08             	add    $0x8,%edx
80103fd1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fd5:	85 c0                	test   %eax,%eax
80103fd7:	74 2a                	je     80104003 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103fd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fdc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103fdf:	83 c2 08             	add    $0x8,%edx
80103fe2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fe6:	83 ec 0c             	sub    $0xc,%esp
80103fe9:	50                   	push   %eax
80103fea:	e8 b6 d0 ff ff       	call   801010a5 <fileclose>
80103fef:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103ff2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ff5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ff8:	83 c2 08             	add    $0x8,%edx
80103ffb:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104002:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104003:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104007:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010400b:	7e bb                	jle    80103fc8 <exit+0x2e>
    }
  }

  begin_op();
8010400d:	e8 2c f0 ff ff       	call   8010303e <begin_op>
  iput(curproc->cwd);
80104012:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104015:	8b 40 68             	mov    0x68(%eax),%eax
80104018:	83 ec 0c             	sub    $0xc,%esp
8010401b:	50                   	push   %eax
8010401c:	e8 32 db ff ff       	call   80101b53 <iput>
80104021:	83 c4 10             	add    $0x10,%esp
  end_op();
80104024:	e8 a1 f0 ff ff       	call   801030ca <end_op>
  curproc->cwd = 0;
80104029:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010402c:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104033:	83 ec 0c             	sub    $0xc,%esp
80104036:	68 00 4e 19 80       	push   $0x80194e00
8010403b:	e8 7a 0f 00 00       	call   80104fba <acquire>
80104040:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104043:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104046:	8b 40 14             	mov    0x14(%eax),%eax
80104049:	83 ec 0c             	sub    $0xc,%esp
8010404c:	50                   	push   %eax
8010404d:	e8 d8 04 00 00       	call   8010452a <wakeup1>
80104052:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104055:	c7 45 f4 34 4e 19 80 	movl   $0x80194e34,-0xc(%ebp)
8010405c:	eb 37                	jmp    80104095 <exit+0xfb>
    if(p->parent == curproc){
8010405e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104061:	8b 40 14             	mov    0x14(%eax),%eax
80104064:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104067:	75 28                	jne    80104091 <exit+0xf7>
      p->parent = initproc;
80104069:	8b 15 60 71 19 80    	mov    0x80197160,%edx
8010406f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104072:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104075:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104078:	8b 40 0c             	mov    0xc(%eax),%eax
8010407b:	83 f8 05             	cmp    $0x5,%eax
8010407e:	75 11                	jne    80104091 <exit+0xf7>
        wakeup1(initproc);
80104080:	a1 60 71 19 80       	mov    0x80197160,%eax
80104085:	83 ec 0c             	sub    $0xc,%esp
80104088:	50                   	push   %eax
80104089:	e8 9c 04 00 00       	call   8010452a <wakeup1>
8010408e:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104091:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104095:	81 7d f4 34 6d 19 80 	cmpl   $0x80196d34,-0xc(%ebp)
8010409c:	72 c0                	jb     8010405e <exit+0xc4>
    }
  }

  //kerner_pstat 상태 제거
  int i = curproc - ptable.proc;
8010409e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040a1:	2d 34 4e 19 80       	sub    $0x80194e34,%eax
801040a6:	c1 f8 02             	sar    $0x2,%eax
801040a9:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
801040af:	89 45 e8             	mov    %eax,-0x18(%ebp)
  kernel_pstat.inuse[i] = 0;
801040b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801040b5:	c7 04 85 00 42 19 80 	movl   $0x0,-0x7fe6be00(,%eax,4)
801040bc:	00 00 00 00 

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801040c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040c3:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801040ca:	e8 7b 02 00 00       	call   8010434a <sched>
  panic("zombie exit");
801040cf:	83 ec 0c             	sub    $0xc,%esp
801040d2:	68 4b ac 10 80       	push   $0x8010ac4b
801040d7:	e8 cd c4 ff ff       	call   801005a9 <panic>

801040dc <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801040dc:	55                   	push   %ebp
801040dd:	89 e5                	mov    %esp,%ebp
801040df:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801040e2:	e8 49 f9 ff ff       	call   80103a30 <myproc>
801040e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801040ea:	83 ec 0c             	sub    $0xc,%esp
801040ed:	68 00 4e 19 80       	push   $0x80194e00
801040f2:	e8 c3 0e 00 00       	call   80104fba <acquire>
801040f7:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801040fa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104101:	c7 45 f4 34 4e 19 80 	movl   $0x80194e34,-0xc(%ebp)
80104108:	e9 a1 00 00 00       	jmp    801041ae <wait+0xd2>
      if(p->parent != curproc)
8010410d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104110:	8b 40 14             	mov    0x14(%eax),%eax
80104113:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104116:	0f 85 8d 00 00 00    	jne    801041a9 <wait+0xcd>
        continue;
      havekids = 1;
8010411c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104123:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104126:	8b 40 0c             	mov    0xc(%eax),%eax
80104129:	83 f8 05             	cmp    $0x5,%eax
8010412c:	75 7c                	jne    801041aa <wait+0xce>
        // Found one.
        pid = p->pid;
8010412e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104131:	8b 40 10             	mov    0x10(%eax),%eax
80104134:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413a:	8b 40 08             	mov    0x8(%eax),%eax
8010413d:	83 ec 0c             	sub    $0xc,%esp
80104140:	50                   	push   %eax
80104141:	e8 c8 e5 ff ff       	call   8010270e <kfree>
80104146:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104149:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010414c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104153:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104156:	8b 40 04             	mov    0x4(%eax),%eax
80104159:	83 ec 0c             	sub    $0xc,%esp
8010415c:	50                   	push   %eax
8010415d:	e8 86 40 00 00       	call   801081e8 <freevm>
80104162:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104168:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010416f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104172:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010417c:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104183:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010418a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010418d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104194:	83 ec 0c             	sub    $0xc,%esp
80104197:	68 00 4e 19 80       	push   $0x80194e00
8010419c:	e8 87 0e 00 00       	call   80105028 <release>
801041a1:	83 c4 10             	add    $0x10,%esp
        return pid;
801041a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801041a7:	eb 51                	jmp    801041fa <wait+0x11e>
        continue;
801041a9:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041aa:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801041ae:	81 7d f4 34 6d 19 80 	cmpl   $0x80196d34,-0xc(%ebp)
801041b5:	0f 82 52 ff ff ff    	jb     8010410d <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801041bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801041bf:	74 0a                	je     801041cb <wait+0xef>
801041c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041c4:	8b 40 24             	mov    0x24(%eax),%eax
801041c7:	85 c0                	test   %eax,%eax
801041c9:	74 17                	je     801041e2 <wait+0x106>
      release(&ptable.lock);
801041cb:	83 ec 0c             	sub    $0xc,%esp
801041ce:	68 00 4e 19 80       	push   $0x80194e00
801041d3:	e8 50 0e 00 00       	call   80105028 <release>
801041d8:	83 c4 10             	add    $0x10,%esp
      return -1;
801041db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041e0:	eb 18                	jmp    801041fa <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801041e2:	83 ec 08             	sub    $0x8,%esp
801041e5:	68 00 4e 19 80       	push   $0x80194e00
801041ea:	ff 75 ec             	push   -0x14(%ebp)
801041ed:	e8 91 02 00 00       	call   80104483 <sleep>
801041f2:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801041f5:	e9 00 ff ff ff       	jmp    801040fa <wait+0x1e>
  }
}
801041fa:	c9                   	leave
801041fb:	c3                   	ret

801041fc <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801041fc:	55                   	push   %ebp
801041fd:	89 e5                	mov    %esp,%ebp
801041ff:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104202:	e8 b1 f7 ff ff       	call   801039b8 <mycpu>
80104207:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
8010420a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010420d:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104214:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104217:	e8 5c f7 ff ff       	call   80103978 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
8010421c:	83 ec 0c             	sub    $0xc,%esp
8010421f:	68 00 4e 19 80       	push   $0x80194e00
80104224:	e8 91 0d 00 00       	call   80104fba <acquire>
80104229:	83 c4 10             	add    $0x10,%esp
    

    if (mycpu()->sched_policy == 0) {
8010422c:	e8 87 f7 ff ff       	call   801039b8 <mycpu>
80104231:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104237:	85 c0                	test   %eax,%eax
80104239:	0f 85 f1 00 00 00    	jne    80104330 <scheduler+0x134>
      // Round Robin 스케줄링
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010423f:	c7 45 f4 34 4e 19 80 	movl   $0x80194e34,-0xc(%ebp)
80104246:	eb 61                	jmp    801042a9 <scheduler+0xad>
        if(p->state != RUNNABLE)
80104248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010424b:	8b 40 0c             	mov    0xc(%eax),%eax
8010424e:	83 f8 03             	cmp    $0x3,%eax
80104251:	75 51                	jne    801042a4 <scheduler+0xa8>
          continue;
        // Switch to chosen process.  It is the process's job
        // to release ptable.lock and then reacquire it
        // before jumping back to us.
        c->proc = p;
80104253:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104256:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104259:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
        switchuvm(p);
8010425f:	83 ec 0c             	sub    $0xc,%esp
80104262:	ff 75 f4             	push   -0xc(%ebp)
80104265:	e8 d9 3a 00 00       	call   80107d43 <switchuvm>
8010426a:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;
8010426d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104270:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

        swtch(&(c->scheduler), p->context);
80104277:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010427d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104280:	83 c2 04             	add    $0x4,%edx
80104283:	83 ec 08             	sub    $0x8,%esp
80104286:	50                   	push   %eax
80104287:	52                   	push   %edx
80104288:	e8 18 12 00 00       	call   801054a5 <swtch>
8010428d:	83 c4 10             	add    $0x10,%esp
        switchkvm();
80104290:	e8 95 3a 00 00       	call   80107d2a <switchkvm>

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
80104295:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104298:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010429f:	00 00 00 
801042a2:	eb 01                	jmp    801042a5 <scheduler+0xa9>
          continue;
801042a4:	90                   	nop
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042a5:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801042a9:	81 7d f4 34 6d 19 80 	cmpl   $0x80196d34,-0xc(%ebp)
801042b0:	72 96                	jb     80104248 <scheduler+0x4c>
      }
      // wait_ticks 누적
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042b2:	c7 45 f4 34 4e 19 80 	movl   $0x80194e34,-0xc(%ebp)
801042b9:	eb 6a                	jmp    80104325 <scheduler+0x129>
        if(p->state == RUNNABLE && p != c->proc){
801042bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042be:	8b 40 0c             	mov    0xc(%eax),%eax
801042c1:	83 f8 03             	cmp    $0x3,%eax
801042c4:	75 5b                	jne    80104321 <scheduler+0x125>
801042c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042c9:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801042cf:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801042d2:	74 4d                	je     80104321 <scheduler+0x125>
          int i = p - ptable.proc;
801042d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d7:	2d 34 4e 19 80       	sub    $0x80194e34,%eax
801042dc:	c1 f8 02             	sar    $0x2,%eax
801042df:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
801042e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
          kernel_pstat.wait_ticks[i][kernel_pstat.priority[i]]++;
801042e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042eb:	83 e8 80             	sub    $0xffffff80,%eax
801042ee:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
801042f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801042f8:	c1 e2 02             	shl    $0x2,%edx
801042fb:	01 c2                	add    %eax,%edx
801042fd:	81 c2 00 02 00 00    	add    $0x200,%edx
80104303:	8b 14 95 00 42 19 80 	mov    -0x7fe6be00(,%edx,4),%edx
8010430a:	83 c2 01             	add    $0x1,%edx
8010430d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80104310:	c1 e1 02             	shl    $0x2,%ecx
80104313:	01 c8                	add    %ecx,%eax
80104315:	05 00 02 00 00       	add    $0x200,%eax
8010431a:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104321:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104325:	81 7d f4 34 6d 19 80 	cmpl   $0x80196d34,-0xc(%ebp)
8010432c:	72 8d                	jb     801042bb <scheduler+0xbf>
8010432e:	eb 05                	jmp    80104335 <scheduler+0x139>
        }
      }
    } else {
      // TODO: MLFQ로 넘기기
      run_mlfq();
80104330:	e8 e2 09 00 00       	call   80104d17 <run_mlfq>
    }  

    release(&ptable.lock);
80104335:	83 ec 0c             	sub    $0xc,%esp
80104338:	68 00 4e 19 80       	push   $0x80194e00
8010433d:	e8 e6 0c 00 00       	call   80105028 <release>
80104342:	83 c4 10             	add    $0x10,%esp
    sti();
80104345:	e9 cd fe ff ff       	jmp    80104217 <scheduler+0x1b>

8010434a <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
8010434a:	55                   	push   %ebp
8010434b:	89 e5                	mov    %esp,%ebp
8010434d:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104350:	e8 db f6 ff ff       	call   80103a30 <myproc>
80104355:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104358:	83 ec 0c             	sub    $0xc,%esp
8010435b:	68 00 4e 19 80       	push   $0x80194e00
80104360:	e8 90 0d 00 00       	call   801050f5 <holding>
80104365:	83 c4 10             	add    $0x10,%esp
80104368:	85 c0                	test   %eax,%eax
8010436a:	75 0d                	jne    80104379 <sched+0x2f>
    panic("sched ptable.lock");
8010436c:	83 ec 0c             	sub    $0xc,%esp
8010436f:	68 57 ac 10 80       	push   $0x8010ac57
80104374:	e8 30 c2 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
80104379:	e8 3a f6 ff ff       	call   801039b8 <mycpu>
8010437e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104384:	83 f8 01             	cmp    $0x1,%eax
80104387:	74 0d                	je     80104396 <sched+0x4c>
    panic("sched locks");
80104389:	83 ec 0c             	sub    $0xc,%esp
8010438c:	68 69 ac 10 80       	push   $0x8010ac69
80104391:	e8 13 c2 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
80104396:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104399:	8b 40 0c             	mov    0xc(%eax),%eax
8010439c:	83 f8 04             	cmp    $0x4,%eax
8010439f:	75 0d                	jne    801043ae <sched+0x64>
    panic("sched running");
801043a1:	83 ec 0c             	sub    $0xc,%esp
801043a4:	68 75 ac 10 80       	push   $0x8010ac75
801043a9:	e8 fb c1 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801043ae:	e8 b5 f5 ff ff       	call   80103968 <readeflags>
801043b3:	25 00 02 00 00       	and    $0x200,%eax
801043b8:	85 c0                	test   %eax,%eax
801043ba:	74 0d                	je     801043c9 <sched+0x7f>
    panic("sched interruptible");
801043bc:	83 ec 0c             	sub    $0xc,%esp
801043bf:	68 83 ac 10 80       	push   $0x8010ac83
801043c4:	e8 e0 c1 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
801043c9:	e8 ea f5 ff ff       	call   801039b8 <mycpu>
801043ce:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801043d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801043d7:	e8 dc f5 ff ff       	call   801039b8 <mycpu>
801043dc:	8b 40 04             	mov    0x4(%eax),%eax
801043df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043e2:	83 c2 1c             	add    $0x1c,%edx
801043e5:	83 ec 08             	sub    $0x8,%esp
801043e8:	50                   	push   %eax
801043e9:	52                   	push   %edx
801043ea:	e8 b6 10 00 00       	call   801054a5 <swtch>
801043ef:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801043f2:	e8 c1 f5 ff ff       	call   801039b8 <mycpu>
801043f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043fa:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104400:	90                   	nop
80104401:	c9                   	leave
80104402:	c3                   	ret

80104403 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104403:	55                   	push   %ebp
80104404:	89 e5                	mov    %esp,%ebp
80104406:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104409:	83 ec 0c             	sub    $0xc,%esp
8010440c:	68 00 4e 19 80       	push   $0x80194e00
80104411:	e8 a4 0b 00 00       	call   80104fba <acquire>
80104416:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104419:	e8 12 f6 ff ff       	call   80103a30 <myproc>
8010441e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104425:	e8 20 ff ff ff       	call   8010434a <sched>
  release(&ptable.lock);
8010442a:	83 ec 0c             	sub    $0xc,%esp
8010442d:	68 00 4e 19 80       	push   $0x80194e00
80104432:	e8 f1 0b 00 00       	call   80105028 <release>
80104437:	83 c4 10             	add    $0x10,%esp
}
8010443a:	90                   	nop
8010443b:	c9                   	leave
8010443c:	c3                   	ret

8010443d <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010443d:	55                   	push   %ebp
8010443e:	89 e5                	mov    %esp,%ebp
80104440:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104443:	83 ec 0c             	sub    $0xc,%esp
80104446:	68 00 4e 19 80       	push   $0x80194e00
8010444b:	e8 d8 0b 00 00       	call   80105028 <release>
80104450:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104453:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104458:	85 c0                	test   %eax,%eax
8010445a:	74 24                	je     80104480 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010445c:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104463:	00 00 00 
    iinit(ROOTDEV);
80104466:	83 ec 0c             	sub    $0xc,%esp
80104469:	6a 01                	push   $0x1
8010446b:	e8 11 d2 ff ff       	call   80101681 <iinit>
80104470:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104473:	83 ec 0c             	sub    $0xc,%esp
80104476:	6a 01                	push   $0x1
80104478:	e8 a2 e9 ff ff       	call   80102e1f <initlog>
8010447d:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104480:	90                   	nop
80104481:	c9                   	leave
80104482:	c3                   	ret

80104483 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104483:	55                   	push   %ebp
80104484:	89 e5                	mov    %esp,%ebp
80104486:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104489:	e8 a2 f5 ff ff       	call   80103a30 <myproc>
8010448e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104491:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104495:	75 0d                	jne    801044a4 <sleep+0x21>
    panic("sleep");
80104497:	83 ec 0c             	sub    $0xc,%esp
8010449a:	68 97 ac 10 80       	push   $0x8010ac97
8010449f:	e8 05 c1 ff ff       	call   801005a9 <panic>

  if(lk == 0)
801044a4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801044a8:	75 0d                	jne    801044b7 <sleep+0x34>
    panic("sleep without lk");
801044aa:	83 ec 0c             	sub    $0xc,%esp
801044ad:	68 9d ac 10 80       	push   $0x8010ac9d
801044b2:	e8 f2 c0 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801044b7:	81 7d 0c 00 4e 19 80 	cmpl   $0x80194e00,0xc(%ebp)
801044be:	74 1e                	je     801044de <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
801044c0:	83 ec 0c             	sub    $0xc,%esp
801044c3:	68 00 4e 19 80       	push   $0x80194e00
801044c8:	e8 ed 0a 00 00       	call   80104fba <acquire>
801044cd:	83 c4 10             	add    $0x10,%esp
    release(lk);
801044d0:	83 ec 0c             	sub    $0xc,%esp
801044d3:	ff 75 0c             	push   0xc(%ebp)
801044d6:	e8 4d 0b 00 00       	call   80105028 <release>
801044db:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801044de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e1:	8b 55 08             	mov    0x8(%ebp),%edx
801044e4:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801044e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ea:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801044f1:	e8 54 fe ff ff       	call   8010434a <sched>

  // Tidy up.
  p->chan = 0;
801044f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f9:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104500:	81 7d 0c 00 4e 19 80 	cmpl   $0x80194e00,0xc(%ebp)
80104507:	74 1e                	je     80104527 <sleep+0xa4>
    release(&ptable.lock);
80104509:	83 ec 0c             	sub    $0xc,%esp
8010450c:	68 00 4e 19 80       	push   $0x80194e00
80104511:	e8 12 0b 00 00       	call   80105028 <release>
80104516:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104519:	83 ec 0c             	sub    $0xc,%esp
8010451c:	ff 75 0c             	push   0xc(%ebp)
8010451f:	e8 96 0a 00 00       	call   80104fba <acquire>
80104524:	83 c4 10             	add    $0x10,%esp
  }
}
80104527:	90                   	nop
80104528:	c9                   	leave
80104529:	c3                   	ret

8010452a <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010452a:	55                   	push   %ebp
8010452b:	89 e5                	mov    %esp,%ebp
8010452d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104530:	c7 45 fc 34 4e 19 80 	movl   $0x80194e34,-0x4(%ebp)
80104537:	eb 24                	jmp    8010455d <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104539:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010453c:	8b 40 0c             	mov    0xc(%eax),%eax
8010453f:	83 f8 02             	cmp    $0x2,%eax
80104542:	75 15                	jne    80104559 <wakeup1+0x2f>
80104544:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104547:	8b 40 20             	mov    0x20(%eax),%eax
8010454a:	39 45 08             	cmp    %eax,0x8(%ebp)
8010454d:	75 0a                	jne    80104559 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010454f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104552:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104559:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
8010455d:	81 7d fc 34 6d 19 80 	cmpl   $0x80196d34,-0x4(%ebp)
80104564:	72 d3                	jb     80104539 <wakeup1+0xf>
}
80104566:	90                   	nop
80104567:	90                   	nop
80104568:	c9                   	leave
80104569:	c3                   	ret

8010456a <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010456a:	55                   	push   %ebp
8010456b:	89 e5                	mov    %esp,%ebp
8010456d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104570:	83 ec 0c             	sub    $0xc,%esp
80104573:	68 00 4e 19 80       	push   $0x80194e00
80104578:	e8 3d 0a 00 00       	call   80104fba <acquire>
8010457d:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104580:	83 ec 0c             	sub    $0xc,%esp
80104583:	ff 75 08             	push   0x8(%ebp)
80104586:	e8 9f ff ff ff       	call   8010452a <wakeup1>
8010458b:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010458e:	83 ec 0c             	sub    $0xc,%esp
80104591:	68 00 4e 19 80       	push   $0x80194e00
80104596:	e8 8d 0a 00 00       	call   80105028 <release>
8010459b:	83 c4 10             	add    $0x10,%esp
}
8010459e:	90                   	nop
8010459f:	c9                   	leave
801045a0:	c3                   	ret

801045a1 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801045a1:	55                   	push   %ebp
801045a2:	89 e5                	mov    %esp,%ebp
801045a4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801045a7:	83 ec 0c             	sub    $0xc,%esp
801045aa:	68 00 4e 19 80       	push   $0x80194e00
801045af:	e8 06 0a 00 00       	call   80104fba <acquire>
801045b4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045b7:	c7 45 f4 34 4e 19 80 	movl   $0x80194e34,-0xc(%ebp)
801045be:	eb 45                	jmp    80104605 <kill+0x64>
    if(p->pid == pid){
801045c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c3:	8b 40 10             	mov    0x10(%eax),%eax
801045c6:	39 45 08             	cmp    %eax,0x8(%ebp)
801045c9:	75 36                	jne    80104601 <kill+0x60>
      p->killed = 1;
801045cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ce:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801045d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d8:	8b 40 0c             	mov    0xc(%eax),%eax
801045db:	83 f8 02             	cmp    $0x2,%eax
801045de:	75 0a                	jne    801045ea <kill+0x49>
        p->state = RUNNABLE;
801045e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801045ea:	83 ec 0c             	sub    $0xc,%esp
801045ed:	68 00 4e 19 80       	push   $0x80194e00
801045f2:	e8 31 0a 00 00       	call   80105028 <release>
801045f7:	83 c4 10             	add    $0x10,%esp
      return 0;
801045fa:	b8 00 00 00 00       	mov    $0x0,%eax
801045ff:	eb 22                	jmp    80104623 <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104601:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104605:	81 7d f4 34 6d 19 80 	cmpl   $0x80196d34,-0xc(%ebp)
8010460c:	72 b2                	jb     801045c0 <kill+0x1f>
    }
  }
  release(&ptable.lock);
8010460e:	83 ec 0c             	sub    $0xc,%esp
80104611:	68 00 4e 19 80       	push   $0x80194e00
80104616:	e8 0d 0a 00 00       	call   80105028 <release>
8010461b:	83 c4 10             	add    $0x10,%esp
  return -1;
8010461e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104623:	c9                   	leave
80104624:	c3                   	ret

80104625 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104625:	55                   	push   %ebp
80104626:	89 e5                	mov    %esp,%ebp
80104628:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010462b:	c7 45 f0 34 4e 19 80 	movl   $0x80194e34,-0x10(%ebp)
80104632:	e9 d7 00 00 00       	jmp    8010470e <procdump+0xe9>
    if(p->state == UNUSED)
80104637:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010463a:	8b 40 0c             	mov    0xc(%eax),%eax
8010463d:	85 c0                	test   %eax,%eax
8010463f:	0f 84 c4 00 00 00    	je     80104709 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104645:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104648:	8b 40 0c             	mov    0xc(%eax),%eax
8010464b:	83 f8 05             	cmp    $0x5,%eax
8010464e:	77 23                	ja     80104673 <procdump+0x4e>
80104650:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104653:	8b 40 0c             	mov    0xc(%eax),%eax
80104656:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010465d:	85 c0                	test   %eax,%eax
8010465f:	74 12                	je     80104673 <procdump+0x4e>
      state = states[p->state];
80104661:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104664:	8b 40 0c             	mov    0xc(%eax),%eax
80104667:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
8010466e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104671:	eb 07                	jmp    8010467a <procdump+0x55>
    else
      state = "???";
80104673:	c7 45 ec ae ac 10 80 	movl   $0x8010acae,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010467a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010467d:	8d 50 6c             	lea    0x6c(%eax),%edx
80104680:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104683:	8b 40 10             	mov    0x10(%eax),%eax
80104686:	52                   	push   %edx
80104687:	ff 75 ec             	push   -0x14(%ebp)
8010468a:	50                   	push   %eax
8010468b:	68 b2 ac 10 80       	push   $0x8010acb2
80104690:	e8 5f bd ff ff       	call   801003f4 <cprintf>
80104695:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104698:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010469b:	8b 40 0c             	mov    0xc(%eax),%eax
8010469e:	83 f8 02             	cmp    $0x2,%eax
801046a1:	75 54                	jne    801046f7 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801046a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046a6:	8b 40 1c             	mov    0x1c(%eax),%eax
801046a9:	8b 40 0c             	mov    0xc(%eax),%eax
801046ac:	83 c0 08             	add    $0x8,%eax
801046af:	89 c2                	mov    %eax,%edx
801046b1:	83 ec 08             	sub    $0x8,%esp
801046b4:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801046b7:	50                   	push   %eax
801046b8:	52                   	push   %edx
801046b9:	e8 bc 09 00 00       	call   8010507a <getcallerpcs>
801046be:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801046c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801046c8:	eb 1c                	jmp    801046e6 <procdump+0xc1>
        cprintf(" %p", pc[i]);
801046ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cd:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801046d1:	83 ec 08             	sub    $0x8,%esp
801046d4:	50                   	push   %eax
801046d5:	68 bb ac 10 80       	push   $0x8010acbb
801046da:	e8 15 bd ff ff       	call   801003f4 <cprintf>
801046df:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801046e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801046e6:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801046ea:	7f 0b                	jg     801046f7 <procdump+0xd2>
801046ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ef:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801046f3:	85 c0                	test   %eax,%eax
801046f5:	75 d3                	jne    801046ca <procdump+0xa5>
    }
    cprintf("\n");
801046f7:	83 ec 0c             	sub    $0xc,%esp
801046fa:	68 bf ac 10 80       	push   $0x8010acbf
801046ff:	e8 f0 bc ff ff       	call   801003f4 <cprintf>
80104704:	83 c4 10             	add    $0x10,%esp
80104707:	eb 01                	jmp    8010470a <procdump+0xe5>
      continue;
80104709:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010470a:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
8010470e:	81 7d f0 34 6d 19 80 	cmpl   $0x80196d34,-0x10(%ebp)
80104715:	0f 82 1c ff ff ff    	jb     80104637 <procdump+0x12>
  }
}
8010471b:	90                   	nop
8010471c:	90                   	nop
8010471d:	c9                   	leave
8010471e:	c3                   	ret

8010471f <getpinfo>:

//현재 커널의 프로세스 상태들을 pstat에 담아서 유저에게 전달해주는 시스템 콜
int getpinfo(struct pstat *pstat) {
8010471f:	55                   	push   %ebp
80104720:	89 e5                	mov    %esp,%ebp
80104722:	53                   	push   %ebx
80104723:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80104726:	83 ec 0c             	sub    $0xc,%esp
80104729:	68 00 4e 19 80       	push   $0x80194e00
8010472e:	e8 87 08 00 00       	call   80104fba <acquire>
80104733:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
80104736:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010473d:	e9 e6 00 00 00       	jmp    80104828 <getpinfo+0x109>
    pstat->inuse[i] = kernel_pstat.inuse[i];
80104742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104745:	8b 0c 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%ecx
8010474c:	8b 45 08             	mov    0x8(%ebp),%eax
8010474f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104752:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
    pstat->pid[i] = kernel_pstat.pid[i];
80104755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104758:	83 c0 40             	add    $0x40,%eax
8010475b:	8b 14 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%edx
80104762:	8b 45 08             	mov    0x8(%ebp),%eax
80104765:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104768:	83 c1 40             	add    $0x40,%ecx
8010476b:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    pstat->priority[i] = kernel_pstat.priority[i];
8010476e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104771:	83 e8 80             	sub    $0xffffff80,%eax
80104774:	8b 14 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%edx
8010477b:	8b 45 08             	mov    0x8(%ebp),%eax
8010477e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104781:	83 e9 80             	sub    $0xffffff80,%ecx
80104784:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    pstat->state[i] = ptable.proc[i].state; // proc에서 유일하게 읽기 가능
80104787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478a:	6b c0 7c             	imul   $0x7c,%eax,%eax
8010478d:	05 40 4e 19 80       	add    $0x80194e40,%eax
80104792:	8b 00                	mov    (%eax),%eax
80104794:	89 c1                	mov    %eax,%ecx
80104796:	8b 45 08             	mov    0x8(%ebp),%eax
80104799:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010479c:	81 c2 c0 00 00 00    	add    $0xc0,%edx
801047a2:	89 0c 90             	mov    %ecx,(%eax,%edx,4)

    for (int j = 0; j < 4; j++) {
801047a5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047ac:	eb 70                	jmp    8010481e <getpinfo+0xff>
      pstat->ticks[i][j] = kernel_pstat.ticks[i][j];
801047ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801047b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047bb:	01 d0                	add    %edx,%eax
801047bd:	05 00 01 00 00       	add    $0x100,%eax
801047c2:	8b 14 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%edx
801047c9:	8b 45 08             	mov    0x8(%ebp),%eax
801047cc:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801047cf:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
801047d6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801047d9:	01 d9                	add    %ebx,%ecx
801047db:	81 c1 00 01 00 00    	add    $0x100,%ecx
801047e1:	89 14 88             	mov    %edx,(%eax,%ecx,4)
      pstat->wait_ticks[i][j] = kernel_pstat.wait_ticks[i][j];
801047e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801047ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047f1:	01 d0                	add    %edx,%eax
801047f3:	05 00 02 00 00       	add    $0x200,%eax
801047f8:	8b 14 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%edx
801047ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104802:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80104805:	8d 1c 8d 00 00 00 00 	lea    0x0(,%ecx,4),%ebx
8010480c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010480f:	01 d9                	add    %ebx,%ecx
80104811:	81 c1 00 02 00 00    	add    $0x200,%ecx
80104817:	89 14 88             	mov    %edx,(%eax,%ecx,4)
    for (int j = 0; j < 4; j++) {
8010481a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010481e:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80104822:	7e 8a                	jle    801047ae <getpinfo+0x8f>
  for (int i = 0; i < NPROC; i++) {
80104824:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104828:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010482c:	0f 8e 10 ff ff ff    	jle    80104742 <getpinfo+0x23>
    }
  }
  release(&ptable.lock);
80104832:	83 ec 0c             	sub    $0xc,%esp
80104835:	68 00 4e 19 80       	push   $0x80194e00
8010483a:	e8 e9 07 00 00       	call   80105028 <release>
8010483f:	83 c4 10             	add    $0x10,%esp
  return 0;
80104842:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104847:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010484a:	c9                   	leave
8010484b:	c3                   	ret

8010484c <set_sched_policy>:

int
set_sched_policy(int policy)
{
8010484c:	55                   	push   %ebp
8010484d:	89 e5                	mov    %esp,%ebp
8010484f:	83 ec 08             	sub    $0x8,%esp
  if (policy < 0 || policy > 3)
80104852:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104856:	78 06                	js     8010485e <set_sched_policy+0x12>
80104858:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
8010485c:	7e 07                	jle    80104865 <set_sched_policy+0x19>
    return -1;
8010485e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104863:	eb 1d                	jmp    80104882 <set_sched_policy+0x36>

  pushcli(); 
80104865:	e8 bb 08 00 00       	call   80105125 <pushcli>
  mycpu()->sched_policy = policy;
8010486a:	e8 49 f1 ff ff       	call   801039b8 <mycpu>
8010486f:	8b 55 08             	mov    0x8(%ebp),%edx
80104872:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
  popcli();
80104878:	e8 f5 08 00 00       	call   80105172 <popcli>

  return 0;
8010487d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104882:	c9                   	leave
80104883:	c3                   	ret

80104884 <get_sched_policy>:
int
get_sched_policy(void)
{
80104884:	55                   	push   %ebp
80104885:	89 e5                	mov    %esp,%ebp
80104887:	83 ec 18             	sub    $0x18,%esp
  pushcli();  
8010488a:	e8 96 08 00 00       	call   80105125 <pushcli>
  int policy = mycpu()->sched_policy;
8010488f:	e8 24 f1 ff ff       	call   801039b8 <mycpu>
80104894:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010489a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();   
8010489d:	e8 d0 08 00 00       	call   80105172 <popcli>
  return policy;
801048a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801048a5:	c9                   	leave
801048a6:	c3                   	ret

801048a7 <enqueue>:
struct proc* mlfq_queues[4][NPROC];
int q_front[4] = {0};
int q_back[4] = {0};

// Enqueue 함수
void enqueue(struct proc *p, int level) {
801048a7:	55                   	push   %ebp
801048a8:	89 e5                	mov    %esp,%ebp
801048aa:	83 ec 18             	sub    $0x18,%esp
  for (int i = 0; i < NPROC; i++) {
801048ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801048b4:	eb 39                	jmp    801048ef <enqueue+0x48>
    if (mlfq_queues[level][i] == p) {
801048b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801048b9:	c1 e0 06             	shl    $0x6,%eax
801048bc:	89 c2                	mov    %eax,%edx
801048be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c1:	01 d0                	add    %edx,%eax
801048c3:	8b 04 85 40 6d 19 80 	mov    -0x7fe692c0(,%eax,4),%eax
801048ca:	39 45 08             	cmp    %eax,0x8(%ebp)
801048cd:	75 1c                	jne    801048eb <enqueue+0x44>
      cprintf("[ENQUEUE] DUP PID %d already in Q%d\n", p->pid, level);
801048cf:	8b 45 08             	mov    0x8(%ebp),%eax
801048d2:	8b 40 10             	mov    0x10(%eax),%eax
801048d5:	83 ec 04             	sub    $0x4,%esp
801048d8:	ff 75 0c             	push   0xc(%ebp)
801048db:	50                   	push   %eax
801048dc:	68 c4 ac 10 80       	push   $0x8010acc4
801048e1:	e8 0e bb ff ff       	call   801003f4 <cprintf>
801048e6:	83 c4 10             	add    $0x10,%esp
      return;
801048e9:	eb 7b                	jmp    80104966 <enqueue+0xbf>
  for (int i = 0; i < NPROC; i++) {
801048eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801048ef:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801048f3:	7e c1                	jle    801048b6 <enqueue+0xf>
    }
  }
  for (int i = 0; i < NPROC; i++) {
801048f5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801048fc:	eb 4f                	jmp    8010494d <enqueue+0xa6>
    if (mlfq_queues[level][i] == 0) {
801048fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80104901:	c1 e0 06             	shl    $0x6,%eax
80104904:	89 c2                	mov    %eax,%edx
80104906:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104909:	01 d0                	add    %edx,%eax
8010490b:	8b 04 85 40 6d 19 80 	mov    -0x7fe692c0(,%eax,4),%eax
80104912:	85 c0                	test   %eax,%eax
80104914:	75 33                	jne    80104949 <enqueue+0xa2>
      mlfq_queues[level][i] = p;
80104916:	8b 45 0c             	mov    0xc(%ebp),%eax
80104919:	c1 e0 06             	shl    $0x6,%eax
8010491c:	89 c2                	mov    %eax,%edx
8010491e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104921:	01 c2                	add    %eax,%edx
80104923:	8b 45 08             	mov    0x8(%ebp),%eax
80104926:	89 04 95 40 6d 19 80 	mov    %eax,-0x7fe692c0(,%edx,4)
      cprintf("[ENQUEUE] PID %d → Q%d (inserted)\n", p->pid, level);
8010492d:	8b 45 08             	mov    0x8(%ebp),%eax
80104930:	8b 40 10             	mov    0x10(%eax),%eax
80104933:	83 ec 04             	sub    $0x4,%esp
80104936:	ff 75 0c             	push   0xc(%ebp)
80104939:	50                   	push   %eax
8010493a:	68 ec ac 10 80       	push   $0x8010acec
8010493f:	e8 b0 ba ff ff       	call   801003f4 <cprintf>
80104944:	83 c4 10             	add    $0x10,%esp
      return;
80104947:	eb 1d                	jmp    80104966 <enqueue+0xbf>
  for (int i = 0; i < NPROC; i++) {
80104949:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010494d:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80104951:	7e ab                	jle    801048fe <enqueue+0x57>
    }
  }
  cprintf("[ENQUEUE] Failed: Q%d full\n", level);
80104953:	83 ec 08             	sub    $0x8,%esp
80104956:	ff 75 0c             	push   0xc(%ebp)
80104959:	68 11 ad 10 80       	push   $0x8010ad11
8010495e:	e8 91 ba ff ff       	call   801003f4 <cprintf>
80104963:	83 c4 10             	add    $0x10,%esp
}
80104966:	c9                   	leave
80104967:	c3                   	ret

80104968 <dequeue>:

struct proc* dequeue(int level) {
80104968:	55                   	push   %ebp
80104969:	89 e5                	mov    %esp,%ebp
8010496b:	83 ec 10             	sub    $0x10,%esp
  struct proc* p = 0;
8010496e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

  for (int i = 0; i < NPROC; i++) {
80104975:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010497c:	e9 81 00 00 00       	jmp    80104a02 <dequeue+0x9a>
    if (mlfq_queues[level][i] != 0) {
80104981:	8b 45 08             	mov    0x8(%ebp),%eax
80104984:	c1 e0 06             	shl    $0x6,%eax
80104987:	89 c2                	mov    %eax,%edx
80104989:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010498c:	01 d0                	add    %edx,%eax
8010498e:	8b 04 85 40 6d 19 80 	mov    -0x7fe692c0(,%eax,4),%eax
80104995:	85 c0                	test   %eax,%eax
80104997:	74 65                	je     801049fe <dequeue+0x96>
      p = mlfq_queues[level][i];
80104999:	8b 45 08             	mov    0x8(%ebp),%eax
8010499c:	c1 e0 06             	shl    $0x6,%eax
8010499f:	89 c2                	mov    %eax,%edx
801049a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801049a4:	01 d0                	add    %edx,%eax
801049a6:	8b 04 85 40 6d 19 80 	mov    -0x7fe692c0(,%eax,4),%eax
801049ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
      for (int j = i; j < NPROC - 1; j++)
801049b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801049b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801049b6:	eb 2d                	jmp    801049e5 <dequeue+0x7d>
        mlfq_queues[level][j] = mlfq_queues[level][j + 1];
801049b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049bb:	8d 50 01             	lea    0x1(%eax),%edx
801049be:	8b 45 08             	mov    0x8(%ebp),%eax
801049c1:	c1 e0 06             	shl    $0x6,%eax
801049c4:	01 d0                	add    %edx,%eax
801049c6:	8b 04 85 40 6d 19 80 	mov    -0x7fe692c0(,%eax,4),%eax
801049cd:	8b 55 08             	mov    0x8(%ebp),%edx
801049d0:	89 d1                	mov    %edx,%ecx
801049d2:	c1 e1 06             	shl    $0x6,%ecx
801049d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049d8:	01 ca                	add    %ecx,%edx
801049da:	89 04 95 40 6d 19 80 	mov    %eax,-0x7fe692c0(,%edx,4)
      for (int j = i; j < NPROC - 1; j++)
801049e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801049e5:	83 7d f4 3e          	cmpl   $0x3e,-0xc(%ebp)
801049e9:	7e cd                	jle    801049b8 <dequeue+0x50>
      mlfq_queues[level][NPROC - 1] = 0;
801049eb:	8b 45 08             	mov    0x8(%ebp),%eax
801049ee:	c1 e0 08             	shl    $0x8,%eax
801049f1:	05 3c 6e 19 80       	add    $0x80196e3c,%eax
801049f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      break;
801049fc:	eb 0e                	jmp    80104a0c <dequeue+0xa4>
  for (int i = 0; i < NPROC; i++) {
801049fe:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104a02:	83 7d f8 3f          	cmpl   $0x3f,-0x8(%ebp)
80104a06:	0f 8e 75 ff ff ff    	jle    80104981 <dequeue+0x19>
    }
  }
  return p;
80104a0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104a0f:	c9                   	leave
80104a10:	c3                   	ret

80104a11 <apply_priority_boosting>:

// Boosting 조건 검사
void apply_priority_boosting(void) {
80104a11:	55                   	push   %ebp
80104a12:	89 e5                	mov    %esp,%ebp
80104a14:	83 ec 18             	sub    $0x18,%esp
  for (int i = 0; i < NPROC; i++) {
80104a17:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a1e:	e9 5a 01 00 00       	jmp    80104b7d <apply_priority_boosting+0x16c>
    if (!kernel_pstat.inuse[i]) continue;
80104a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a26:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104a2d:	85 c0                	test   %eax,%eax
80104a2f:	0f 84 43 01 00 00    	je     80104b78 <apply_priority_boosting+0x167>
    int q = kernel_pstat.priority[i];
80104a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a38:	83 e8 80             	sub    $0xffffff80,%eax
80104a3b:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104a42:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int waited = kernel_pstat.wait_ticks[i][q];
80104a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a48:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a52:	01 d0                	add    %edx,%eax
80104a54:	05 00 02 00 00       	add    $0x200,%eax
80104a59:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104a60:	89 45 ec             	mov    %eax,-0x14(%ebp)

    if (q == 0 && waited >= 500) {
80104a63:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104a67:	75 70                	jne    80104ad9 <apply_priority_boosting+0xc8>
80104a69:	81 7d ec f3 01 00 00 	cmpl   $0x1f3,-0x14(%ebp)
80104a70:	7e 67                	jle    80104ad9 <apply_priority_boosting+0xc8>
      kernel_pstat.priority[i] = 1;
80104a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a75:	83 e8 80             	sub    $0xffffff80,%eax
80104a78:	c7 04 85 00 42 19 80 	movl   $0x1,-0x7fe6be00(,%eax,4)
80104a7f:	01 00 00 00 
      kernel_pstat.wait_ticks[i][0] = 0;
80104a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a86:	83 e8 80             	sub    $0xffffff80,%eax
80104a89:	c1 e0 04             	shl    $0x4,%eax
80104a8c:	05 00 42 19 80       	add    $0x80194200,%eax
80104a91:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      cprintf("[BOOST] PID %d Q0→Q1\n", kernel_pstat.pid[i]);
80104a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9a:	83 c0 40             	add    $0x40,%eax
80104a9d:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104aa4:	83 ec 08             	sub    $0x8,%esp
80104aa7:	50                   	push   %eax
80104aa8:	68 2d ad 10 80       	push   $0x8010ad2d
80104aad:	e8 42 b9 ff ff       	call   801003f4 <cprintf>
80104ab2:	83 c4 10             	add    $0x10,%esp
      enqueue(&ptable.proc[i], 1);
80104ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab8:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104abb:	83 c0 30             	add    $0x30,%eax
80104abe:	05 00 4e 19 80       	add    $0x80194e00,%eax
80104ac3:	83 c0 04             	add    $0x4,%eax
80104ac6:	83 ec 08             	sub    $0x8,%esp
80104ac9:	6a 01                	push   $0x1
80104acb:	50                   	push   %eax
80104acc:	e8 d6 fd ff ff       	call   801048a7 <enqueue>
80104ad1:	83 c4 10             	add    $0x10,%esp
80104ad4:	e9 a0 00 00 00       	jmp    80104b79 <apply_priority_boosting+0x168>
    } else if ((q == 1 && waited >= 320) || (q == 2 && waited >= 160)) {
80104ad9:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
80104add:	75 09                	jne    80104ae8 <apply_priority_boosting+0xd7>
80104adf:	81 7d ec 3f 01 00 00 	cmpl   $0x13f,-0x14(%ebp)
80104ae6:	7f 13                	jg     80104afb <apply_priority_boosting+0xea>
80104ae8:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
80104aec:	0f 85 87 00 00 00    	jne    80104b79 <apply_priority_boosting+0x168>
80104af2:	81 7d ec 9f 00 00 00 	cmpl   $0x9f,-0x14(%ebp)
80104af9:	7e 7e                	jle    80104b79 <apply_priority_boosting+0x168>
      kernel_pstat.priority[i] = q + 1;
80104afb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104afe:	8d 50 01             	lea    0x1(%eax),%edx
80104b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b04:	83 e8 80             	sub    $0xffffff80,%eax
80104b07:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
      kernel_pstat.wait_ticks[i][q] = 0;
80104b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b11:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104b18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b1b:	01 d0                	add    %edx,%eax
80104b1d:	05 00 02 00 00       	add    $0x200,%eax
80104b22:	c7 04 85 00 42 19 80 	movl   $0x0,-0x7fe6be00(,%eax,4)
80104b29:	00 00 00 00 
      cprintf("[BOOST] PID %d Q%d→Q%d\n", kernel_pstat.pid[i], q, q + 1);
80104b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b30:	8d 50 01             	lea    0x1(%eax),%edx
80104b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b36:	83 c0 40             	add    $0x40,%eax
80104b39:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104b40:	52                   	push   %edx
80104b41:	ff 75 f0             	push   -0x10(%ebp)
80104b44:	50                   	push   %eax
80104b45:	68 45 ad 10 80       	push   $0x8010ad45
80104b4a:	e8 a5 b8 ff ff       	call   801003f4 <cprintf>
80104b4f:	83 c4 10             	add    $0x10,%esp
      enqueue(&ptable.proc[i], q + 1);
80104b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b55:	8d 50 01             	lea    0x1(%eax),%edx
80104b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b5b:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104b5e:	83 c0 30             	add    $0x30,%eax
80104b61:	05 00 4e 19 80       	add    $0x80194e00,%eax
80104b66:	83 c0 04             	add    $0x4,%eax
80104b69:	83 ec 08             	sub    $0x8,%esp
80104b6c:	52                   	push   %edx
80104b6d:	50                   	push   %eax
80104b6e:	e8 34 fd ff ff       	call   801048a7 <enqueue>
80104b73:	83 c4 10             	add    $0x10,%esp
80104b76:	eb 01                	jmp    80104b79 <apply_priority_boosting+0x168>
    if (!kernel_pstat.inuse[i]) continue;
80104b78:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104b79:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104b7d:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80104b81:	0f 8e 9c fe ff ff    	jle    80104a23 <apply_priority_boosting+0x12>
    }
  }
}
80104b87:	90                   	nop
80104b88:	90                   	nop
80104b89:	c9                   	leave
80104b8a:	c3                   	ret

80104b8b <get_time_slice>:

// Time slice 계산
int get_time_slice(int level) {
80104b8b:	55                   	push   %ebp
80104b8c:	89 e5                	mov    %esp,%ebp
  if (level == 3) return 8;
80104b8e:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80104b92:	75 07                	jne    80104b9b <get_time_slice+0x10>
80104b94:	b8 08 00 00 00       	mov    $0x8,%eax
80104b99:	eb 1f                	jmp    80104bba <get_time_slice+0x2f>
  if (level == 2) return 16;
80104b9b:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
80104b9f:	75 07                	jne    80104ba8 <get_time_slice+0x1d>
80104ba1:	b8 10 00 00 00       	mov    $0x10,%eax
80104ba6:	eb 12                	jmp    80104bba <get_time_slice+0x2f>
  if (level == 1) return 32;
80104ba8:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
80104bac:	75 07                	jne    80104bb5 <get_time_slice+0x2a>
80104bae:	b8 20 00 00 00       	mov    $0x20,%eax
80104bb3:	eb 05                	jmp    80104bba <get_time_slice+0x2f>
  return -1; // FIFO (Q0)
80104bb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104bba:	5d                   	pop    %ebp
80104bbb:	c3                   	ret

80104bbc <run_process>:

// 프로세스 실행 로직
void run_process(struct proc* p, int q, int slice) {
80104bbc:	55                   	push   %ebp
80104bbd:	89 e5                	mov    %esp,%ebp
80104bbf:	83 ec 18             	sub    $0x18,%esp
  
  struct cpu *c = mycpu();
80104bc2:	e8 f1 ed ff ff       	call   801039b8 <mycpu>
80104bc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->proc = p;
80104bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bcd:	8b 55 08             	mov    0x8(%ebp),%edx
80104bd0:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
  switchuvm(p);
80104bd6:	83 ec 0c             	sub    $0xc,%esp
80104bd9:	ff 75 08             	push   0x8(%ebp)
80104bdc:	e8 62 31 00 00       	call   80107d43 <switchuvm>
80104be1:	83 c4 10             	add    $0x10,%esp
  p->state = RUNNING;
80104be4:	8b 45 08             	mov    0x8(%ebp),%eax
80104be7:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

  int i = p - ptable.proc;
80104bee:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf1:	2d 34 4e 19 80       	sub    $0x80194e34,%eax
80104bf6:	c1 f8 02             	sar    $0x2,%eax
80104bf9:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80104bff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cprintf("[MLFQ] Running PID %d at Q%d with slice %d\n", p->pid, q, slice);
80104c02:	8b 45 08             	mov    0x8(%ebp),%eax
80104c05:	8b 40 10             	mov    0x10(%eax),%eax
80104c08:	ff 75 10             	push   0x10(%ebp)
80104c0b:	ff 75 0c             	push   0xc(%ebp)
80104c0e:	50                   	push   %eax
80104c0f:	68 60 ad 10 80       	push   $0x8010ad60
80104c14:	e8 db b7 ff ff       	call   801003f4 <cprintf>
80104c19:	83 c4 10             	add    $0x10,%esp

  // 기존 tick 값 기억
  cprintf("[RUN] PID %d at Q%d (slice %d)\n", p->pid, q, slice);
80104c1c:	8b 45 08             	mov    0x8(%ebp),%eax
80104c1f:	8b 40 10             	mov    0x10(%eax),%eax
80104c22:	ff 75 10             	push   0x10(%ebp)
80104c25:	ff 75 0c             	push   0xc(%ebp)
80104c28:	50                   	push   %eax
80104c29:	68 8c ad 10 80       	push   $0x8010ad8c
80104c2e:	e8 c1 b7 ff ff       	call   801003f4 <cprintf>
80104c33:	83 c4 10             	add    $0x10,%esp
  int prev_ticks = kernel_pstat.ticks[i][q];
80104c36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c39:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c40:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c43:	01 d0                	add    %edx,%eax
80104c45:	05 00 01 00 00       	add    $0x100,%eax
80104c4a:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104c51:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // 실제 프로세스를 실행 (문맥 전환)
  swtch(&(c->scheduler), p->context);
80104c54:	8b 45 08             	mov    0x8(%ebp),%eax
80104c57:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c5d:	83 c2 04             	add    $0x4,%edx
80104c60:	83 ec 08             	sub    $0x8,%esp
80104c63:	50                   	push   %eax
80104c64:	52                   	push   %edx
80104c65:	e8 3b 08 00 00       	call   801054a5 <swtch>
80104c6a:	83 c4 10             	add    $0x10,%esp
  // 유저 공간에서 실행이 끝나고 다시 돌아옴
  switchkvm();
80104c6d:	e8 b8 30 00 00       	call   80107d2a <switchkvm>
  c->proc = 0;
80104c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c75:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104c7c:	00 00 00 

  // 실제 실행된 tick 수를 기반으로 demotion 판단 (pstat 값이 올라간 상태여야 함)
  int delta = kernel_pstat.ticks[i][q] - prev_ticks;
80104c7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c82:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c89:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c8c:	01 d0                	add    %edx,%eax
80104c8e:	05 00 01 00 00       	add    $0x100,%eax
80104c93:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104c9a:	2b 45 ec             	sub    -0x14(%ebp),%eax
80104c9d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  // Demotion 조건
  if (slice != -1 && delta >= slice && q > 0) {
80104ca0:	83 7d 10 ff          	cmpl   $0xffffffff,0x10(%ebp)
80104ca4:	74 5c                	je     80104d02 <run_process+0x146>
80104ca6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104ca9:	3b 45 10             	cmp    0x10(%ebp),%eax
80104cac:	7c 54                	jl     80104d02 <run_process+0x146>
80104cae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104cb2:	7e 4e                	jle    80104d02 <run_process+0x146>
    kernel_pstat.priority[i] = q - 1;
80104cb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cb7:	8d 50 ff             	lea    -0x1(%eax),%edx
80104cba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cbd:	83 e8 80             	sub    $0xffffff80,%eax
80104cc0:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
    cprintf("[DEMOTE] PID %d Q%d → Q%d (delta=%d)\n", p->pid, q, q - 1, delta);
80104cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cca:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd0:	8b 40 10             	mov    0x10(%eax),%eax
80104cd3:	83 ec 0c             	sub    $0xc,%esp
80104cd6:	ff 75 e8             	push   -0x18(%ebp)
80104cd9:	52                   	push   %edx
80104cda:	ff 75 0c             	push   0xc(%ebp)
80104cdd:	50                   	push   %eax
80104cde:	68 ac ad 10 80       	push   $0x8010adac
80104ce3:	e8 0c b7 ff ff       	call   801003f4 <cprintf>
80104ce8:	83 c4 20             	add    $0x20,%esp
    enqueue(p, q - 1);
80104ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cee:	83 e8 01             	sub    $0x1,%eax
80104cf1:	83 ec 08             	sub    $0x8,%esp
80104cf4:	50                   	push   %eax
80104cf5:	ff 75 08             	push   0x8(%ebp)
80104cf8:	e8 aa fb ff ff       	call   801048a7 <enqueue>
80104cfd:	83 c4 10             	add    $0x10,%esp
80104d00:	eb 12                	jmp    80104d14 <run_process+0x158>
  } else {
    enqueue(p, q); // 다시 같은 큐로
80104d02:	83 ec 08             	sub    $0x8,%esp
80104d05:	ff 75 0c             	push   0xc(%ebp)
80104d08:	ff 75 08             	push   0x8(%ebp)
80104d0b:	e8 97 fb ff ff       	call   801048a7 <enqueue>
80104d10:	83 c4 10             	add    $0x10,%esp
  }
}
80104d13:	90                   	nop
80104d14:	90                   	nop
80104d15:	c9                   	leave
80104d16:	c3                   	ret

80104d17 <run_mlfq>:


// MLFQ 스케줄러 진입점
void run_mlfq(void) {
80104d17:	55                   	push   %ebp
80104d18:	89 e5                	mov    %esp,%ebp
80104d1a:	83 ec 28             	sub    $0x28,%esp
  
  apply_priority_boosting();
80104d1d:	e8 ef fc ff ff       	call   80104a11 <apply_priority_boosting>
  
  for (int q = 3; q >= 0; q--) {
80104d22:	c7 45 f4 03 00 00 00 	movl   $0x3,-0xc(%ebp)
80104d29:	eb 75                	jmp    80104da0 <run_mlfq+0x89>
    for (int i = 0; i < NPROC; i++) {
80104d2b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104d32:	eb 62                	jmp    80104d96 <run_mlfq+0x7f>
      struct proc *p = mlfq_queues[q][i];
80104d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d37:	c1 e0 06             	shl    $0x6,%eax
80104d3a:	89 c2                	mov    %eax,%edx
80104d3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d3f:	01 d0                	add    %edx,%eax
80104d41:	8b 04 85 40 6d 19 80 	mov    -0x7fe692c0(,%eax,4),%eax
80104d48:	89 45 e8             	mov    %eax,-0x18(%ebp)
      //cprintf("[MLFQ_LOOP] Q%d index %d: pid %d, state %d\n", q, i,
        //p ? p->pid : -1, p ? p->state : -1);
      if (p == 0 || p->state != RUNNABLE)
80104d4b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104d4f:	74 40                	je     80104d91 <run_mlfq+0x7a>
80104d51:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104d54:	8b 40 0c             	mov    0xc(%eax),%eax
80104d57:	83 f8 03             	cmp    $0x3,%eax
80104d5a:	75 35                	jne    80104d91 <run_mlfq+0x7a>
        continue;
      
      // 실행할 프로세스는 dequeue
      dequeue(q);
80104d5c:	83 ec 0c             	sub    $0xc,%esp
80104d5f:	ff 75 f4             	push   -0xc(%ebp)
80104d62:	e8 01 fc ff ff       	call   80104968 <dequeue>
80104d67:	83 c4 10             	add    $0x10,%esp
 
      int slice = get_time_slice(q);
80104d6a:	83 ec 0c             	sub    $0xc,%esp
80104d6d:	ff 75 f4             	push   -0xc(%ebp)
80104d70:	e8 16 fe ff ff       	call   80104b8b <get_time_slice>
80104d75:	83 c4 10             	add    $0x10,%esp
80104d78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      run_process(p, q, slice);
80104d7b:	83 ec 04             	sub    $0x4,%esp
80104d7e:	ff 75 e4             	push   -0x1c(%ebp)
80104d81:	ff 75 f4             	push   -0xc(%ebp)
80104d84:	ff 75 e8             	push   -0x18(%ebp)
80104d87:	e8 30 fe ff ff       	call   80104bbc <run_process>
80104d8c:	83 c4 10             	add    $0x10,%esp
      goto tick_update; // 한 번만 실행
80104d8f:	eb 16                	jmp    80104da7 <run_mlfq+0x90>
        continue;
80104d91:	90                   	nop
    for (int i = 0; i < NPROC; i++) {
80104d92:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104d96:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80104d9a:	7e 98                	jle    80104d34 <run_mlfq+0x1d>
  for (int q = 3; q >= 0; q--) {
80104d9c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80104da0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104da4:	79 85                	jns    80104d2b <run_mlfq+0x14>
    }
  }

tick_update:
80104da6:	90                   	nop
  // wait tick 증가 (실행 안 된 RUNNABLE 프로세스만)
  for (int i = 0; i < NPROC; i++) {
80104da7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104dae:	eb 7d                	jmp    80104e2d <run_mlfq+0x116>
    struct proc* p = &ptable.proc[i];
80104db0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104db3:	6b c0 7c             	imul   $0x7c,%eax,%eax
80104db6:	83 c0 30             	add    $0x30,%eax
80104db9:	05 00 4e 19 80       	add    $0x80194e00,%eax
80104dbe:	83 c0 04             	add    $0x4,%eax
80104dc1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!kernel_pstat.inuse[i]) continue;
80104dc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104dc7:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104dce:	85 c0                	test   %eax,%eax
80104dd0:	74 56                	je     80104e28 <run_mlfq+0x111>
    if (p->state == RUNNABLE) {
80104dd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104dd5:	8b 40 0c             	mov    0xc(%eax),%eax
80104dd8:	83 f8 03             	cmp    $0x3,%eax
80104ddb:	75 4c                	jne    80104e29 <run_mlfq+0x112>
      int q = kernel_pstat.priority[i];
80104ddd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104de0:	83 e8 80             	sub    $0xffffff80,%eax
80104de3:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104dea:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kernel_pstat.wait_ticks[i][q]++;
80104ded:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104df0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104df7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104dfa:	01 d0                	add    %edx,%eax
80104dfc:	05 00 02 00 00       	add    $0x200,%eax
80104e01:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80104e08:	8d 50 01             	lea    0x1(%eax),%edx
80104e0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e0e:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80104e15:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104e18:	01 c8                	add    %ecx,%eax
80104e1a:	05 00 02 00 00       	add    $0x200,%eax
80104e1f:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
80104e26:	eb 01                	jmp    80104e29 <run_mlfq+0x112>
    if (!kernel_pstat.inuse[i]) continue;
80104e28:	90                   	nop
  for (int i = 0; i < NPROC; i++) {
80104e29:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104e2d:	83 7d ec 3f          	cmpl   $0x3f,-0x14(%ebp)
80104e31:	0f 8e 79 ff ff ff    	jle    80104db0 <run_mlfq+0x99>
    }
  }
}
80104e37:	90                   	nop
80104e38:	90                   	nop
80104e39:	c9                   	leave
80104e3a:	c3                   	ret

80104e3b <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104e3b:	55                   	push   %ebp
80104e3c:	89 e5                	mov    %esp,%ebp
80104e3e:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104e41:	8b 45 08             	mov    0x8(%ebp),%eax
80104e44:	83 c0 04             	add    $0x4,%eax
80104e47:	83 ec 08             	sub    $0x8,%esp
80104e4a:	68 fe ad 10 80       	push   $0x8010adfe
80104e4f:	50                   	push   %eax
80104e50:	e8 43 01 00 00       	call   80104f98 <initlock>
80104e55:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104e58:	8b 45 08             	mov    0x8(%ebp),%eax
80104e5b:	8b 55 0c             	mov    0xc(%ebp),%edx
80104e5e:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104e61:	8b 45 08             	mov    0x8(%ebp),%eax
80104e64:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80104e6d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104e74:	90                   	nop
80104e75:	c9                   	leave
80104e76:	c3                   	ret

80104e77 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104e77:	55                   	push   %ebp
80104e78:	89 e5                	mov    %esp,%ebp
80104e7a:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80104e80:	83 c0 04             	add    $0x4,%eax
80104e83:	83 ec 0c             	sub    $0xc,%esp
80104e86:	50                   	push   %eax
80104e87:	e8 2e 01 00 00       	call   80104fba <acquire>
80104e8c:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104e8f:	eb 15                	jmp    80104ea6 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104e91:	8b 45 08             	mov    0x8(%ebp),%eax
80104e94:	83 c0 04             	add    $0x4,%eax
80104e97:	83 ec 08             	sub    $0x8,%esp
80104e9a:	50                   	push   %eax
80104e9b:	ff 75 08             	push   0x8(%ebp)
80104e9e:	e8 e0 f5 ff ff       	call   80104483 <sleep>
80104ea3:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea9:	8b 00                	mov    (%eax),%eax
80104eab:	85 c0                	test   %eax,%eax
80104ead:	75 e2                	jne    80104e91 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb2:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104eb8:	e8 73 eb ff ff       	call   80103a30 <myproc>
80104ebd:	8b 50 10             	mov    0x10(%eax),%edx
80104ec0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec3:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec9:	83 c0 04             	add    $0x4,%eax
80104ecc:	83 ec 0c             	sub    $0xc,%esp
80104ecf:	50                   	push   %eax
80104ed0:	e8 53 01 00 00       	call   80105028 <release>
80104ed5:	83 c4 10             	add    $0x10,%esp
}
80104ed8:	90                   	nop
80104ed9:	c9                   	leave
80104eda:	c3                   	ret

80104edb <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104edb:	55                   	push   %ebp
80104edc:	89 e5                	mov    %esp,%ebp
80104ede:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee4:	83 c0 04             	add    $0x4,%eax
80104ee7:	83 ec 0c             	sub    $0xc,%esp
80104eea:	50                   	push   %eax
80104eeb:	e8 ca 00 00 00       	call   80104fba <acquire>
80104ef0:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104ef3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104efc:	8b 45 08             	mov    0x8(%ebp),%eax
80104eff:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104f06:	83 ec 0c             	sub    $0xc,%esp
80104f09:	ff 75 08             	push   0x8(%ebp)
80104f0c:	e8 59 f6 ff ff       	call   8010456a <wakeup>
80104f11:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104f14:	8b 45 08             	mov    0x8(%ebp),%eax
80104f17:	83 c0 04             	add    $0x4,%eax
80104f1a:	83 ec 0c             	sub    $0xc,%esp
80104f1d:	50                   	push   %eax
80104f1e:	e8 05 01 00 00       	call   80105028 <release>
80104f23:	83 c4 10             	add    $0x10,%esp
}
80104f26:	90                   	nop
80104f27:	c9                   	leave
80104f28:	c3                   	ret

80104f29 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104f29:	55                   	push   %ebp
80104f2a:	89 e5                	mov    %esp,%ebp
80104f2c:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f32:	83 c0 04             	add    $0x4,%eax
80104f35:	83 ec 0c             	sub    $0xc,%esp
80104f38:	50                   	push   %eax
80104f39:	e8 7c 00 00 00       	call   80104fba <acquire>
80104f3e:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104f41:	8b 45 08             	mov    0x8(%ebp),%eax
80104f44:	8b 00                	mov    (%eax),%eax
80104f46:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104f49:	8b 45 08             	mov    0x8(%ebp),%eax
80104f4c:	83 c0 04             	add    $0x4,%eax
80104f4f:	83 ec 0c             	sub    $0xc,%esp
80104f52:	50                   	push   %eax
80104f53:	e8 d0 00 00 00       	call   80105028 <release>
80104f58:	83 c4 10             	add    $0x10,%esp
  return r;
80104f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f5e:	c9                   	leave
80104f5f:	c3                   	ret

80104f60 <readeflags>:
{
80104f60:	55                   	push   %ebp
80104f61:	89 e5                	mov    %esp,%ebp
80104f63:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104f66:	9c                   	pushf
80104f67:	58                   	pop    %eax
80104f68:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104f6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f6e:	c9                   	leave
80104f6f:	c3                   	ret

80104f70 <cli>:
{
80104f70:	55                   	push   %ebp
80104f71:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104f73:	fa                   	cli
}
80104f74:	90                   	nop
80104f75:	5d                   	pop    %ebp
80104f76:	c3                   	ret

80104f77 <sti>:
{
80104f77:	55                   	push   %ebp
80104f78:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104f7a:	fb                   	sti
}
80104f7b:	90                   	nop
80104f7c:	5d                   	pop    %ebp
80104f7d:	c3                   	ret

80104f7e <xchg>:
{
80104f7e:	55                   	push   %ebp
80104f7f:	89 e5                	mov    %esp,%ebp
80104f81:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104f84:	8b 55 08             	mov    0x8(%ebp),%edx
80104f87:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f8d:	f0 87 02             	lock xchg %eax,(%edx)
80104f90:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104f93:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f96:	c9                   	leave
80104f97:	c3                   	ret

80104f98 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104f98:	55                   	push   %ebp
80104f99:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f9e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fa1:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104fad:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104fb7:	90                   	nop
80104fb8:	5d                   	pop    %ebp
80104fb9:	c3                   	ret

80104fba <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104fba:	55                   	push   %ebp
80104fbb:	89 e5                	mov    %esp,%ebp
80104fbd:	53                   	push   %ebx
80104fbe:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104fc1:	e8 5f 01 00 00       	call   80105125 <pushcli>
  if(holding(lk)){
80104fc6:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc9:	83 ec 0c             	sub    $0xc,%esp
80104fcc:	50                   	push   %eax
80104fcd:	e8 23 01 00 00       	call   801050f5 <holding>
80104fd2:	83 c4 10             	add    $0x10,%esp
80104fd5:	85 c0                	test   %eax,%eax
80104fd7:	74 0d                	je     80104fe6 <acquire+0x2c>
    panic("acquire");
80104fd9:	83 ec 0c             	sub    $0xc,%esp
80104fdc:	68 09 ae 10 80       	push   $0x8010ae09
80104fe1:	e8 c3 b5 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104fe6:	90                   	nop
80104fe7:	8b 45 08             	mov    0x8(%ebp),%eax
80104fea:	83 ec 08             	sub    $0x8,%esp
80104fed:	6a 01                	push   $0x1
80104fef:	50                   	push   %eax
80104ff0:	e8 89 ff ff ff       	call   80104f7e <xchg>
80104ff5:	83 c4 10             	add    $0x10,%esp
80104ff8:	85 c0                	test   %eax,%eax
80104ffa:	75 eb                	jne    80104fe7 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104ffc:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105001:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105004:	e8 af e9 ff ff       	call   801039b8 <mycpu>
80105009:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010500c:	8b 45 08             	mov    0x8(%ebp),%eax
8010500f:	83 c0 0c             	add    $0xc,%eax
80105012:	83 ec 08             	sub    $0x8,%esp
80105015:	50                   	push   %eax
80105016:	8d 45 08             	lea    0x8(%ebp),%eax
80105019:	50                   	push   %eax
8010501a:	e8 5b 00 00 00       	call   8010507a <getcallerpcs>
8010501f:	83 c4 10             	add    $0x10,%esp
}
80105022:	90                   	nop
80105023:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105026:	c9                   	leave
80105027:	c3                   	ret

80105028 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105028:	55                   	push   %ebp
80105029:	89 e5                	mov    %esp,%ebp
8010502b:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010502e:	83 ec 0c             	sub    $0xc,%esp
80105031:	ff 75 08             	push   0x8(%ebp)
80105034:	e8 bc 00 00 00       	call   801050f5 <holding>
80105039:	83 c4 10             	add    $0x10,%esp
8010503c:	85 c0                	test   %eax,%eax
8010503e:	75 0d                	jne    8010504d <release+0x25>
    panic("release");
80105040:	83 ec 0c             	sub    $0xc,%esp
80105043:	68 11 ae 10 80       	push   $0x8010ae11
80105048:	e8 5c b5 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
8010504d:	8b 45 08             	mov    0x8(%ebp),%eax
80105050:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105057:	8b 45 08             	mov    0x8(%ebp),%eax
8010505a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105061:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105066:	8b 45 08             	mov    0x8(%ebp),%eax
80105069:	8b 55 08             	mov    0x8(%ebp),%edx
8010506c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105072:	e8 fb 00 00 00       	call   80105172 <popcli>
}
80105077:	90                   	nop
80105078:	c9                   	leave
80105079:	c3                   	ret

8010507a <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010507a:	55                   	push   %ebp
8010507b:	89 e5                	mov    %esp,%ebp
8010507d:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105080:	8b 45 08             	mov    0x8(%ebp),%eax
80105083:	83 e8 08             	sub    $0x8,%eax
80105086:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105089:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105090:	eb 38                	jmp    801050ca <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105092:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105096:	74 53                	je     801050eb <getcallerpcs+0x71>
80105098:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010509f:	76 4a                	jbe    801050eb <getcallerpcs+0x71>
801050a1:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801050a5:	74 44                	je     801050eb <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801050a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050aa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801050b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801050b4:	01 c2                	add    %eax,%edx
801050b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050b9:	8b 40 04             	mov    0x4(%eax),%eax
801050bc:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801050be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050c1:	8b 00                	mov    (%eax),%eax
801050c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801050c6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801050ca:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801050ce:	7e c2                	jle    80105092 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
801050d0:	eb 19                	jmp    801050eb <getcallerpcs+0x71>
    pcs[i] = 0;
801050d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801050dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801050df:	01 d0                	add    %edx,%eax
801050e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801050e7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801050eb:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801050ef:	7e e1                	jle    801050d2 <getcallerpcs+0x58>
}
801050f1:	90                   	nop
801050f2:	90                   	nop
801050f3:	c9                   	leave
801050f4:	c3                   	ret

801050f5 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801050f5:	55                   	push   %ebp
801050f6:	89 e5                	mov    %esp,%ebp
801050f8:	53                   	push   %ebx
801050f9:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801050fc:	8b 45 08             	mov    0x8(%ebp),%eax
801050ff:	8b 00                	mov    (%eax),%eax
80105101:	85 c0                	test   %eax,%eax
80105103:	74 16                	je     8010511b <holding+0x26>
80105105:	8b 45 08             	mov    0x8(%ebp),%eax
80105108:	8b 58 08             	mov    0x8(%eax),%ebx
8010510b:	e8 a8 e8 ff ff       	call   801039b8 <mycpu>
80105110:	39 c3                	cmp    %eax,%ebx
80105112:	75 07                	jne    8010511b <holding+0x26>
80105114:	b8 01 00 00 00       	mov    $0x1,%eax
80105119:	eb 05                	jmp    80105120 <holding+0x2b>
8010511b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105120:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105123:	c9                   	leave
80105124:	c3                   	ret

80105125 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105125:	55                   	push   %ebp
80105126:	89 e5                	mov    %esp,%ebp
80105128:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010512b:	e8 30 fe ff ff       	call   80104f60 <readeflags>
80105130:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105133:	e8 38 fe ff ff       	call   80104f70 <cli>
  if(mycpu()->ncli == 0)
80105138:	e8 7b e8 ff ff       	call   801039b8 <mycpu>
8010513d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105143:	85 c0                	test   %eax,%eax
80105145:	75 14                	jne    8010515b <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80105147:	e8 6c e8 ff ff       	call   801039b8 <mycpu>
8010514c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010514f:	81 e2 00 02 00 00    	and    $0x200,%edx
80105155:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
8010515b:	e8 58 e8 ff ff       	call   801039b8 <mycpu>
80105160:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105166:	83 c2 01             	add    $0x1,%edx
80105169:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
8010516f:	90                   	nop
80105170:	c9                   	leave
80105171:	c3                   	ret

80105172 <popcli>:

void
popcli(void)
{
80105172:	55                   	push   %ebp
80105173:	89 e5                	mov    %esp,%ebp
80105175:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105178:	e8 e3 fd ff ff       	call   80104f60 <readeflags>
8010517d:	25 00 02 00 00       	and    $0x200,%eax
80105182:	85 c0                	test   %eax,%eax
80105184:	74 0d                	je     80105193 <popcli+0x21>
    panic("popcli - interruptible");
80105186:	83 ec 0c             	sub    $0xc,%esp
80105189:	68 19 ae 10 80       	push   $0x8010ae19
8010518e:	e8 16 b4 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80105193:	e8 20 e8 ff ff       	call   801039b8 <mycpu>
80105198:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010519e:	83 ea 01             	sub    $0x1,%edx
801051a1:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801051a7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801051ad:	85 c0                	test   %eax,%eax
801051af:	79 0d                	jns    801051be <popcli+0x4c>
    panic("popcli");
801051b1:	83 ec 0c             	sub    $0xc,%esp
801051b4:	68 30 ae 10 80       	push   $0x8010ae30
801051b9:	e8 eb b3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801051be:	e8 f5 e7 ff ff       	call   801039b8 <mycpu>
801051c3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801051c9:	85 c0                	test   %eax,%eax
801051cb:	75 14                	jne    801051e1 <popcli+0x6f>
801051cd:	e8 e6 e7 ff ff       	call   801039b8 <mycpu>
801051d2:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801051d8:	85 c0                	test   %eax,%eax
801051da:	74 05                	je     801051e1 <popcli+0x6f>
    sti();
801051dc:	e8 96 fd ff ff       	call   80104f77 <sti>
}
801051e1:	90                   	nop
801051e2:	c9                   	leave
801051e3:	c3                   	ret

801051e4 <stosb>:
{
801051e4:	55                   	push   %ebp
801051e5:	89 e5                	mov    %esp,%ebp
801051e7:	57                   	push   %edi
801051e8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801051e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801051ec:	8b 55 10             	mov    0x10(%ebp),%edx
801051ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801051f2:	89 cb                	mov    %ecx,%ebx
801051f4:	89 df                	mov    %ebx,%edi
801051f6:	89 d1                	mov    %edx,%ecx
801051f8:	fc                   	cld
801051f9:	f3 aa                	rep stos %al,%es:(%edi)
801051fb:	89 ca                	mov    %ecx,%edx
801051fd:	89 fb                	mov    %edi,%ebx
801051ff:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105202:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105205:	90                   	nop
80105206:	5b                   	pop    %ebx
80105207:	5f                   	pop    %edi
80105208:	5d                   	pop    %ebp
80105209:	c3                   	ret

8010520a <stosl>:
{
8010520a:	55                   	push   %ebp
8010520b:	89 e5                	mov    %esp,%ebp
8010520d:	57                   	push   %edi
8010520e:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010520f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105212:	8b 55 10             	mov    0x10(%ebp),%edx
80105215:	8b 45 0c             	mov    0xc(%ebp),%eax
80105218:	89 cb                	mov    %ecx,%ebx
8010521a:	89 df                	mov    %ebx,%edi
8010521c:	89 d1                	mov    %edx,%ecx
8010521e:	fc                   	cld
8010521f:	f3 ab                	rep stos %eax,%es:(%edi)
80105221:	89 ca                	mov    %ecx,%edx
80105223:	89 fb                	mov    %edi,%ebx
80105225:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105228:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010522b:	90                   	nop
8010522c:	5b                   	pop    %ebx
8010522d:	5f                   	pop    %edi
8010522e:	5d                   	pop    %ebp
8010522f:	c3                   	ret

80105230 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105230:	55                   	push   %ebp
80105231:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105233:	8b 45 08             	mov    0x8(%ebp),%eax
80105236:	83 e0 03             	and    $0x3,%eax
80105239:	85 c0                	test   %eax,%eax
8010523b:	75 43                	jne    80105280 <memset+0x50>
8010523d:	8b 45 10             	mov    0x10(%ebp),%eax
80105240:	83 e0 03             	and    $0x3,%eax
80105243:	85 c0                	test   %eax,%eax
80105245:	75 39                	jne    80105280 <memset+0x50>
    c &= 0xFF;
80105247:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010524e:	8b 45 10             	mov    0x10(%ebp),%eax
80105251:	c1 e8 02             	shr    $0x2,%eax
80105254:	89 c1                	mov    %eax,%ecx
80105256:	8b 45 0c             	mov    0xc(%ebp),%eax
80105259:	c1 e0 18             	shl    $0x18,%eax
8010525c:	89 c2                	mov    %eax,%edx
8010525e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105261:	c1 e0 10             	shl    $0x10,%eax
80105264:	09 c2                	or     %eax,%edx
80105266:	8b 45 0c             	mov    0xc(%ebp),%eax
80105269:	c1 e0 08             	shl    $0x8,%eax
8010526c:	09 d0                	or     %edx,%eax
8010526e:	0b 45 0c             	or     0xc(%ebp),%eax
80105271:	51                   	push   %ecx
80105272:	50                   	push   %eax
80105273:	ff 75 08             	push   0x8(%ebp)
80105276:	e8 8f ff ff ff       	call   8010520a <stosl>
8010527b:	83 c4 0c             	add    $0xc,%esp
8010527e:	eb 12                	jmp    80105292 <memset+0x62>
  } else
    stosb(dst, c, n);
80105280:	8b 45 10             	mov    0x10(%ebp),%eax
80105283:	50                   	push   %eax
80105284:	ff 75 0c             	push   0xc(%ebp)
80105287:	ff 75 08             	push   0x8(%ebp)
8010528a:	e8 55 ff ff ff       	call   801051e4 <stosb>
8010528f:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105292:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105295:	c9                   	leave
80105296:	c3                   	ret

80105297 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105297:	55                   	push   %ebp
80105298:	89 e5                	mov    %esp,%ebp
8010529a:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010529d:	8b 45 08             	mov    0x8(%ebp),%eax
801052a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801052a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801052a9:	eb 2e                	jmp    801052d9 <memcmp+0x42>
    if(*s1 != *s2)
801052ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052ae:	0f b6 10             	movzbl (%eax),%edx
801052b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052b4:	0f b6 00             	movzbl (%eax),%eax
801052b7:	38 c2                	cmp    %al,%dl
801052b9:	74 16                	je     801052d1 <memcmp+0x3a>
      return *s1 - *s2;
801052bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052be:	0f b6 00             	movzbl (%eax),%eax
801052c1:	0f b6 d0             	movzbl %al,%edx
801052c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052c7:	0f b6 00             	movzbl (%eax),%eax
801052ca:	0f b6 c0             	movzbl %al,%eax
801052cd:	29 c2                	sub    %eax,%edx
801052cf:	eb 1a                	jmp    801052eb <memcmp+0x54>
    s1++, s2++;
801052d1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801052d5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
801052d9:	8b 45 10             	mov    0x10(%ebp),%eax
801052dc:	8d 50 ff             	lea    -0x1(%eax),%edx
801052df:	89 55 10             	mov    %edx,0x10(%ebp)
801052e2:	85 c0                	test   %eax,%eax
801052e4:	75 c5                	jne    801052ab <memcmp+0x14>
  }

  return 0;
801052e6:	ba 00 00 00 00       	mov    $0x0,%edx
}
801052eb:	89 d0                	mov    %edx,%eax
801052ed:	c9                   	leave
801052ee:	c3                   	ret

801052ef <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801052ef:	55                   	push   %ebp
801052f0:	89 e5                	mov    %esp,%ebp
801052f2:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801052f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801052f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801052fb:	8b 45 08             	mov    0x8(%ebp),%eax
801052fe:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105301:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105304:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105307:	73 54                	jae    8010535d <memmove+0x6e>
80105309:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010530c:	8b 45 10             	mov    0x10(%ebp),%eax
8010530f:	01 d0                	add    %edx,%eax
80105311:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105314:	73 47                	jae    8010535d <memmove+0x6e>
    s += n;
80105316:	8b 45 10             	mov    0x10(%ebp),%eax
80105319:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010531c:	8b 45 10             	mov    0x10(%ebp),%eax
8010531f:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105322:	eb 13                	jmp    80105337 <memmove+0x48>
      *--d = *--s;
80105324:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105328:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010532c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010532f:	0f b6 10             	movzbl (%eax),%edx
80105332:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105335:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105337:	8b 45 10             	mov    0x10(%ebp),%eax
8010533a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010533d:	89 55 10             	mov    %edx,0x10(%ebp)
80105340:	85 c0                	test   %eax,%eax
80105342:	75 e0                	jne    80105324 <memmove+0x35>
  if(s < d && s + n > d){
80105344:	eb 24                	jmp    8010536a <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105346:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105349:	8d 42 01             	lea    0x1(%edx),%eax
8010534c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010534f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105352:	8d 48 01             	lea    0x1(%eax),%ecx
80105355:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105358:	0f b6 12             	movzbl (%edx),%edx
8010535b:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010535d:	8b 45 10             	mov    0x10(%ebp),%eax
80105360:	8d 50 ff             	lea    -0x1(%eax),%edx
80105363:	89 55 10             	mov    %edx,0x10(%ebp)
80105366:	85 c0                	test   %eax,%eax
80105368:	75 dc                	jne    80105346 <memmove+0x57>

  return dst;
8010536a:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010536d:	c9                   	leave
8010536e:	c3                   	ret

8010536f <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010536f:	55                   	push   %ebp
80105370:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105372:	ff 75 10             	push   0x10(%ebp)
80105375:	ff 75 0c             	push   0xc(%ebp)
80105378:	ff 75 08             	push   0x8(%ebp)
8010537b:	e8 6f ff ff ff       	call   801052ef <memmove>
80105380:	83 c4 0c             	add    $0xc,%esp
}
80105383:	c9                   	leave
80105384:	c3                   	ret

80105385 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105385:	55                   	push   %ebp
80105386:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105388:	eb 0c                	jmp    80105396 <strncmp+0x11>
    n--, p++, q++;
8010538a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010538e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105392:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105396:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010539a:	74 1a                	je     801053b6 <strncmp+0x31>
8010539c:	8b 45 08             	mov    0x8(%ebp),%eax
8010539f:	0f b6 00             	movzbl (%eax),%eax
801053a2:	84 c0                	test   %al,%al
801053a4:	74 10                	je     801053b6 <strncmp+0x31>
801053a6:	8b 45 08             	mov    0x8(%ebp),%eax
801053a9:	0f b6 10             	movzbl (%eax),%edx
801053ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801053af:	0f b6 00             	movzbl (%eax),%eax
801053b2:	38 c2                	cmp    %al,%dl
801053b4:	74 d4                	je     8010538a <strncmp+0x5>
  if(n == 0)
801053b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053ba:	75 07                	jne    801053c3 <strncmp+0x3e>
    return 0;
801053bc:	ba 00 00 00 00       	mov    $0x0,%edx
801053c1:	eb 14                	jmp    801053d7 <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
801053c3:	8b 45 08             	mov    0x8(%ebp),%eax
801053c6:	0f b6 00             	movzbl (%eax),%eax
801053c9:	0f b6 d0             	movzbl %al,%edx
801053cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801053cf:	0f b6 00             	movzbl (%eax),%eax
801053d2:	0f b6 c0             	movzbl %al,%eax
801053d5:	29 c2                	sub    %eax,%edx
}
801053d7:	89 d0                	mov    %edx,%eax
801053d9:	5d                   	pop    %ebp
801053da:	c3                   	ret

801053db <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801053db:	55                   	push   %ebp
801053dc:	89 e5                	mov    %esp,%ebp
801053de:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801053e1:	8b 45 08             	mov    0x8(%ebp),%eax
801053e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801053e7:	90                   	nop
801053e8:	8b 45 10             	mov    0x10(%ebp),%eax
801053eb:	8d 50 ff             	lea    -0x1(%eax),%edx
801053ee:	89 55 10             	mov    %edx,0x10(%ebp)
801053f1:	85 c0                	test   %eax,%eax
801053f3:	7e 2c                	jle    80105421 <strncpy+0x46>
801053f5:	8b 55 0c             	mov    0xc(%ebp),%edx
801053f8:	8d 42 01             	lea    0x1(%edx),%eax
801053fb:	89 45 0c             	mov    %eax,0xc(%ebp)
801053fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105401:	8d 48 01             	lea    0x1(%eax),%ecx
80105404:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105407:	0f b6 12             	movzbl (%edx),%edx
8010540a:	88 10                	mov    %dl,(%eax)
8010540c:	0f b6 00             	movzbl (%eax),%eax
8010540f:	84 c0                	test   %al,%al
80105411:	75 d5                	jne    801053e8 <strncpy+0xd>
    ;
  while(n-- > 0)
80105413:	eb 0c                	jmp    80105421 <strncpy+0x46>
    *s++ = 0;
80105415:	8b 45 08             	mov    0x8(%ebp),%eax
80105418:	8d 50 01             	lea    0x1(%eax),%edx
8010541b:	89 55 08             	mov    %edx,0x8(%ebp)
8010541e:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105421:	8b 45 10             	mov    0x10(%ebp),%eax
80105424:	8d 50 ff             	lea    -0x1(%eax),%edx
80105427:	89 55 10             	mov    %edx,0x10(%ebp)
8010542a:	85 c0                	test   %eax,%eax
8010542c:	7f e7                	jg     80105415 <strncpy+0x3a>
  return os;
8010542e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105431:	c9                   	leave
80105432:	c3                   	ret

80105433 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105433:	55                   	push   %ebp
80105434:	89 e5                	mov    %esp,%ebp
80105436:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105439:	8b 45 08             	mov    0x8(%ebp),%eax
8010543c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010543f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105443:	7f 05                	jg     8010544a <safestrcpy+0x17>
    return os;
80105445:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105448:	eb 32                	jmp    8010547c <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
8010544a:	90                   	nop
8010544b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010544f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105453:	7e 1e                	jle    80105473 <safestrcpy+0x40>
80105455:	8b 55 0c             	mov    0xc(%ebp),%edx
80105458:	8d 42 01             	lea    0x1(%edx),%eax
8010545b:	89 45 0c             	mov    %eax,0xc(%ebp)
8010545e:	8b 45 08             	mov    0x8(%ebp),%eax
80105461:	8d 48 01             	lea    0x1(%eax),%ecx
80105464:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105467:	0f b6 12             	movzbl (%edx),%edx
8010546a:	88 10                	mov    %dl,(%eax)
8010546c:	0f b6 00             	movzbl (%eax),%eax
8010546f:	84 c0                	test   %al,%al
80105471:	75 d8                	jne    8010544b <safestrcpy+0x18>
    ;
  *s = 0;
80105473:	8b 45 08             	mov    0x8(%ebp),%eax
80105476:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105479:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010547c:	c9                   	leave
8010547d:	c3                   	ret

8010547e <strlen>:

int
strlen(const char *s)
{
8010547e:	55                   	push   %ebp
8010547f:	89 e5                	mov    %esp,%ebp
80105481:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105484:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010548b:	eb 04                	jmp    80105491 <strlen+0x13>
8010548d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105491:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105494:	8b 45 08             	mov    0x8(%ebp),%eax
80105497:	01 d0                	add    %edx,%eax
80105499:	0f b6 00             	movzbl (%eax),%eax
8010549c:	84 c0                	test   %al,%al
8010549e:	75 ed                	jne    8010548d <strlen+0xf>
    ;
  return n;
801054a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054a3:	c9                   	leave
801054a4:	c3                   	ret

801054a5 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801054a5:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801054a9:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801054ad:	55                   	push   %ebp
  pushl %ebx
801054ae:	53                   	push   %ebx
  pushl %esi
801054af:	56                   	push   %esi
  pushl %edi
801054b0:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801054b1:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801054b3:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801054b5:	5f                   	pop    %edi
  popl %esi
801054b6:	5e                   	pop    %esi
  popl %ebx
801054b7:	5b                   	pop    %ebx
  popl %ebp
801054b8:	5d                   	pop    %ebp
  ret
801054b9:	c3                   	ret

801054ba <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801054ba:	55                   	push   %ebp
801054bb:	89 e5                	mov    %esp,%ebp
801054bd:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801054c0:	e8 6b e5 ff ff       	call   80103a30 <myproc>
801054c5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801054c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054cb:	8b 00                	mov    (%eax),%eax
801054cd:	39 45 08             	cmp    %eax,0x8(%ebp)
801054d0:	73 0f                	jae    801054e1 <fetchint+0x27>
801054d2:	8b 45 08             	mov    0x8(%ebp),%eax
801054d5:	8d 50 04             	lea    0x4(%eax),%edx
801054d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054db:	8b 00                	mov    (%eax),%eax
801054dd:	39 d0                	cmp    %edx,%eax
801054df:	73 07                	jae    801054e8 <fetchint+0x2e>
    return -1;
801054e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054e6:	eb 0f                	jmp    801054f7 <fetchint+0x3d>
  *ip = *(int*)(addr);
801054e8:	8b 45 08             	mov    0x8(%ebp),%eax
801054eb:	8b 10                	mov    (%eax),%edx
801054ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801054f0:	89 10                	mov    %edx,(%eax)
  return 0;
801054f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054f7:	c9                   	leave
801054f8:	c3                   	ret

801054f9 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801054f9:	55                   	push   %ebp
801054fa:	89 e5                	mov    %esp,%ebp
801054fc:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801054ff:	e8 2c e5 ff ff       	call   80103a30 <myproc>
80105504:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105507:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010550a:	8b 00                	mov    (%eax),%eax
8010550c:	39 45 08             	cmp    %eax,0x8(%ebp)
8010550f:	72 07                	jb     80105518 <fetchstr+0x1f>
    return -1;
80105511:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105516:	eb 41                	jmp    80105559 <fetchstr+0x60>
  *pp = (char*)addr;
80105518:	8b 55 08             	mov    0x8(%ebp),%edx
8010551b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010551e:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105520:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105523:	8b 00                	mov    (%eax),%eax
80105525:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105528:	8b 45 0c             	mov    0xc(%ebp),%eax
8010552b:	8b 00                	mov    (%eax),%eax
8010552d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105530:	eb 1a                	jmp    8010554c <fetchstr+0x53>
    if(*s == 0)
80105532:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105535:	0f b6 00             	movzbl (%eax),%eax
80105538:	84 c0                	test   %al,%al
8010553a:	75 0c                	jne    80105548 <fetchstr+0x4f>
      return s - *pp;
8010553c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010553f:	8b 10                	mov    (%eax),%edx
80105541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105544:	29 d0                	sub    %edx,%eax
80105546:	eb 11                	jmp    80105559 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80105548:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010554c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010554f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105552:	72 de                	jb     80105532 <fetchstr+0x39>
  }
  return -1;
80105554:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105559:	c9                   	leave
8010555a:	c3                   	ret

8010555b <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010555b:	55                   	push   %ebp
8010555c:	89 e5                	mov    %esp,%ebp
8010555e:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105561:	e8 ca e4 ff ff       	call   80103a30 <myproc>
80105566:	8b 40 18             	mov    0x18(%eax),%eax
80105569:	8b 40 44             	mov    0x44(%eax),%eax
8010556c:	8b 55 08             	mov    0x8(%ebp),%edx
8010556f:	c1 e2 02             	shl    $0x2,%edx
80105572:	01 d0                	add    %edx,%eax
80105574:	83 c0 04             	add    $0x4,%eax
80105577:	83 ec 08             	sub    $0x8,%esp
8010557a:	ff 75 0c             	push   0xc(%ebp)
8010557d:	50                   	push   %eax
8010557e:	e8 37 ff ff ff       	call   801054ba <fetchint>
80105583:	83 c4 10             	add    $0x10,%esp
}
80105586:	c9                   	leave
80105587:	c3                   	ret

80105588 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105588:	55                   	push   %ebp
80105589:	89 e5                	mov    %esp,%ebp
8010558b:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
8010558e:	e8 9d e4 ff ff       	call   80103a30 <myproc>
80105593:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105596:	83 ec 08             	sub    $0x8,%esp
80105599:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010559c:	50                   	push   %eax
8010559d:	ff 75 08             	push   0x8(%ebp)
801055a0:	e8 b6 ff ff ff       	call   8010555b <argint>
801055a5:	83 c4 10             	add    $0x10,%esp
801055a8:	85 c0                	test   %eax,%eax
801055aa:	79 07                	jns    801055b3 <argptr+0x2b>
    return -1;
801055ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055b1:	eb 3b                	jmp    801055ee <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801055b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055b7:	78 1f                	js     801055d8 <argptr+0x50>
801055b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055bc:	8b 00                	mov    (%eax),%eax
801055be:	8b 55 f0             	mov    -0x10(%ebp),%edx
801055c1:	39 c2                	cmp    %eax,%edx
801055c3:	73 13                	jae    801055d8 <argptr+0x50>
801055c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055c8:	89 c2                	mov    %eax,%edx
801055ca:	8b 45 10             	mov    0x10(%ebp),%eax
801055cd:	01 c2                	add    %eax,%edx
801055cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d2:	8b 00                	mov    (%eax),%eax
801055d4:	39 d0                	cmp    %edx,%eax
801055d6:	73 07                	jae    801055df <argptr+0x57>
    return -1;
801055d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055dd:	eb 0f                	jmp    801055ee <argptr+0x66>
  *pp = (char*)i;
801055df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055e2:	89 c2                	mov    %eax,%edx
801055e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801055e7:	89 10                	mov    %edx,(%eax)
  return 0;
801055e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055ee:	c9                   	leave
801055ef:	c3                   	ret

801055f0 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801055f0:	55                   	push   %ebp
801055f1:	89 e5                	mov    %esp,%ebp
801055f3:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801055f6:	83 ec 08             	sub    $0x8,%esp
801055f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055fc:	50                   	push   %eax
801055fd:	ff 75 08             	push   0x8(%ebp)
80105600:	e8 56 ff ff ff       	call   8010555b <argint>
80105605:	83 c4 10             	add    $0x10,%esp
80105608:	85 c0                	test   %eax,%eax
8010560a:	79 07                	jns    80105613 <argstr+0x23>
    return -1;
8010560c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105611:	eb 12                	jmp    80105625 <argstr+0x35>
  return fetchstr(addr, pp);
80105613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105616:	83 ec 08             	sub    $0x8,%esp
80105619:	ff 75 0c             	push   0xc(%ebp)
8010561c:	50                   	push   %eax
8010561d:	e8 d7 fe ff ff       	call   801054f9 <fetchstr>
80105622:	83 c4 10             	add    $0x10,%esp
}
80105625:	c9                   	leave
80105626:	c3                   	ret

80105627 <syscall>:
[SYS_getSchedPolicy]    sys_getSchedPolicy,
};

void
syscall(void)
{
80105627:	55                   	push   %ebp
80105628:	89 e5                	mov    %esp,%ebp
8010562a:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
8010562d:	e8 fe e3 ff ff       	call   80103a30 <myproc>
80105632:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105635:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105638:	8b 40 18             	mov    0x18(%eax),%eax
8010563b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010563e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105641:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105645:	7e 2f                	jle    80105676 <syscall+0x4f>
80105647:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010564a:	83 f8 19             	cmp    $0x19,%eax
8010564d:	77 27                	ja     80105676 <syscall+0x4f>
8010564f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105652:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105659:	85 c0                	test   %eax,%eax
8010565b:	74 19                	je     80105676 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
8010565d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105660:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105667:	ff d0                	call   *%eax
80105669:	89 c2                	mov    %eax,%edx
8010566b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010566e:	8b 40 18             	mov    0x18(%eax),%eax
80105671:	89 50 1c             	mov    %edx,0x1c(%eax)
80105674:	eb 2c                	jmp    801056a2 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105679:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010567c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010567f:	8b 40 10             	mov    0x10(%eax),%eax
80105682:	ff 75 f0             	push   -0x10(%ebp)
80105685:	52                   	push   %edx
80105686:	50                   	push   %eax
80105687:	68 37 ae 10 80       	push   $0x8010ae37
8010568c:	e8 63 ad ff ff       	call   801003f4 <cprintf>
80105691:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105694:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105697:	8b 40 18             	mov    0x18(%eax),%eax
8010569a:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801056a1:	90                   	nop
801056a2:	90                   	nop
801056a3:	c9                   	leave
801056a4:	c3                   	ret

801056a5 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801056a5:	55                   	push   %ebp
801056a6:	89 e5                	mov    %esp,%ebp
801056a8:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801056ab:	83 ec 08             	sub    $0x8,%esp
801056ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056b1:	50                   	push   %eax
801056b2:	ff 75 08             	push   0x8(%ebp)
801056b5:	e8 a1 fe ff ff       	call   8010555b <argint>
801056ba:	83 c4 10             	add    $0x10,%esp
801056bd:	85 c0                	test   %eax,%eax
801056bf:	79 07                	jns    801056c8 <argfd+0x23>
    return -1;
801056c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c6:	eb 4f                	jmp    80105717 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801056c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056cb:	85 c0                	test   %eax,%eax
801056cd:	78 20                	js     801056ef <argfd+0x4a>
801056cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d2:	83 f8 0f             	cmp    $0xf,%eax
801056d5:	7f 18                	jg     801056ef <argfd+0x4a>
801056d7:	e8 54 e3 ff ff       	call   80103a30 <myproc>
801056dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056df:	83 c2 08             	add    $0x8,%edx
801056e2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801056e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056ed:	75 07                	jne    801056f6 <argfd+0x51>
    return -1;
801056ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f4:	eb 21                	jmp    80105717 <argfd+0x72>
  if(pfd)
801056f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801056fa:	74 08                	je     80105704 <argfd+0x5f>
    *pfd = fd;
801056fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105702:	89 10                	mov    %edx,(%eax)
  if(pf)
80105704:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105708:	74 08                	je     80105712 <argfd+0x6d>
    *pf = f;
8010570a:	8b 45 10             	mov    0x10(%ebp),%eax
8010570d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105710:	89 10                	mov    %edx,(%eax)
  return 0;
80105712:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105717:	c9                   	leave
80105718:	c3                   	ret

80105719 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105719:	55                   	push   %ebp
8010571a:	89 e5                	mov    %esp,%ebp
8010571c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010571f:	e8 0c e3 ff ff       	call   80103a30 <myproc>
80105724:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105727:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010572e:	eb 2a                	jmp    8010575a <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80105730:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105733:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105736:	83 c2 08             	add    $0x8,%edx
80105739:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010573d:	85 c0                	test   %eax,%eax
8010573f:	75 15                	jne    80105756 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105741:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105744:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105747:	8d 4a 08             	lea    0x8(%edx),%ecx
8010574a:	8b 55 08             	mov    0x8(%ebp),%edx
8010574d:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105754:	eb 0f                	jmp    80105765 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80105756:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010575a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010575e:	7e d0                	jle    80105730 <fdalloc+0x17>
    }
  }
  return -1;
80105760:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105765:	c9                   	leave
80105766:	c3                   	ret

80105767 <sys_dup>:

int
sys_dup(void)
{
80105767:	55                   	push   %ebp
80105768:	89 e5                	mov    %esp,%ebp
8010576a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010576d:	83 ec 04             	sub    $0x4,%esp
80105770:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105773:	50                   	push   %eax
80105774:	6a 00                	push   $0x0
80105776:	6a 00                	push   $0x0
80105778:	e8 28 ff ff ff       	call   801056a5 <argfd>
8010577d:	83 c4 10             	add    $0x10,%esp
80105780:	85 c0                	test   %eax,%eax
80105782:	79 07                	jns    8010578b <sys_dup+0x24>
    return -1;
80105784:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105789:	eb 31                	jmp    801057bc <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010578b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010578e:	83 ec 0c             	sub    $0xc,%esp
80105791:	50                   	push   %eax
80105792:	e8 82 ff ff ff       	call   80105719 <fdalloc>
80105797:	83 c4 10             	add    $0x10,%esp
8010579a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010579d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057a1:	79 07                	jns    801057aa <sys_dup+0x43>
    return -1;
801057a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057a8:	eb 12                	jmp    801057bc <sys_dup+0x55>
  filedup(f);
801057aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ad:	83 ec 0c             	sub    $0xc,%esp
801057b0:	50                   	push   %eax
801057b1:	e8 9e b8 ff ff       	call   80101054 <filedup>
801057b6:	83 c4 10             	add    $0x10,%esp
  return fd;
801057b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801057bc:	c9                   	leave
801057bd:	c3                   	ret

801057be <sys_read>:

int
sys_read(void)
{
801057be:	55                   	push   %ebp
801057bf:	89 e5                	mov    %esp,%ebp
801057c1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801057c4:	83 ec 04             	sub    $0x4,%esp
801057c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057ca:	50                   	push   %eax
801057cb:	6a 00                	push   $0x0
801057cd:	6a 00                	push   $0x0
801057cf:	e8 d1 fe ff ff       	call   801056a5 <argfd>
801057d4:	83 c4 10             	add    $0x10,%esp
801057d7:	85 c0                	test   %eax,%eax
801057d9:	78 2e                	js     80105809 <sys_read+0x4b>
801057db:	83 ec 08             	sub    $0x8,%esp
801057de:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057e1:	50                   	push   %eax
801057e2:	6a 02                	push   $0x2
801057e4:	e8 72 fd ff ff       	call   8010555b <argint>
801057e9:	83 c4 10             	add    $0x10,%esp
801057ec:	85 c0                	test   %eax,%eax
801057ee:	78 19                	js     80105809 <sys_read+0x4b>
801057f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f3:	83 ec 04             	sub    $0x4,%esp
801057f6:	50                   	push   %eax
801057f7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801057fa:	50                   	push   %eax
801057fb:	6a 01                	push   $0x1
801057fd:	e8 86 fd ff ff       	call   80105588 <argptr>
80105802:	83 c4 10             	add    $0x10,%esp
80105805:	85 c0                	test   %eax,%eax
80105807:	79 07                	jns    80105810 <sys_read+0x52>
    return -1;
80105809:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010580e:	eb 17                	jmp    80105827 <sys_read+0x69>
  return fileread(f, p, n);
80105810:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105813:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105819:	83 ec 04             	sub    $0x4,%esp
8010581c:	51                   	push   %ecx
8010581d:	52                   	push   %edx
8010581e:	50                   	push   %eax
8010581f:	e8 c0 b9 ff ff       	call   801011e4 <fileread>
80105824:	83 c4 10             	add    $0x10,%esp
}
80105827:	c9                   	leave
80105828:	c3                   	ret

80105829 <sys_write>:

int
sys_write(void)
{
80105829:	55                   	push   %ebp
8010582a:	89 e5                	mov    %esp,%ebp
8010582c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010582f:	83 ec 04             	sub    $0x4,%esp
80105832:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105835:	50                   	push   %eax
80105836:	6a 00                	push   $0x0
80105838:	6a 00                	push   $0x0
8010583a:	e8 66 fe ff ff       	call   801056a5 <argfd>
8010583f:	83 c4 10             	add    $0x10,%esp
80105842:	85 c0                	test   %eax,%eax
80105844:	78 2e                	js     80105874 <sys_write+0x4b>
80105846:	83 ec 08             	sub    $0x8,%esp
80105849:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010584c:	50                   	push   %eax
8010584d:	6a 02                	push   $0x2
8010584f:	e8 07 fd ff ff       	call   8010555b <argint>
80105854:	83 c4 10             	add    $0x10,%esp
80105857:	85 c0                	test   %eax,%eax
80105859:	78 19                	js     80105874 <sys_write+0x4b>
8010585b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010585e:	83 ec 04             	sub    $0x4,%esp
80105861:	50                   	push   %eax
80105862:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105865:	50                   	push   %eax
80105866:	6a 01                	push   $0x1
80105868:	e8 1b fd ff ff       	call   80105588 <argptr>
8010586d:	83 c4 10             	add    $0x10,%esp
80105870:	85 c0                	test   %eax,%eax
80105872:	79 07                	jns    8010587b <sys_write+0x52>
    return -1;
80105874:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105879:	eb 17                	jmp    80105892 <sys_write+0x69>
  return filewrite(f, p, n);
8010587b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010587e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105884:	83 ec 04             	sub    $0x4,%esp
80105887:	51                   	push   %ecx
80105888:	52                   	push   %edx
80105889:	50                   	push   %eax
8010588a:	e8 0d ba ff ff       	call   8010129c <filewrite>
8010588f:	83 c4 10             	add    $0x10,%esp
}
80105892:	c9                   	leave
80105893:	c3                   	ret

80105894 <sys_close>:

int
sys_close(void)
{
80105894:	55                   	push   %ebp
80105895:	89 e5                	mov    %esp,%ebp
80105897:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010589a:	83 ec 04             	sub    $0x4,%esp
8010589d:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058a0:	50                   	push   %eax
801058a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058a4:	50                   	push   %eax
801058a5:	6a 00                	push   $0x0
801058a7:	e8 f9 fd ff ff       	call   801056a5 <argfd>
801058ac:	83 c4 10             	add    $0x10,%esp
801058af:	85 c0                	test   %eax,%eax
801058b1:	79 07                	jns    801058ba <sys_close+0x26>
    return -1;
801058b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058b8:	eb 27                	jmp    801058e1 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801058ba:	e8 71 e1 ff ff       	call   80103a30 <myproc>
801058bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058c2:	83 c2 08             	add    $0x8,%edx
801058c5:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801058cc:	00 
  fileclose(f);
801058cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058d0:	83 ec 0c             	sub    $0xc,%esp
801058d3:	50                   	push   %eax
801058d4:	e8 cc b7 ff ff       	call   801010a5 <fileclose>
801058d9:	83 c4 10             	add    $0x10,%esp
  return 0;
801058dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058e1:	c9                   	leave
801058e2:	c3                   	ret

801058e3 <sys_fstat>:

int
sys_fstat(void)
{
801058e3:	55                   	push   %ebp
801058e4:	89 e5                	mov    %esp,%ebp
801058e6:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801058e9:	83 ec 04             	sub    $0x4,%esp
801058ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058ef:	50                   	push   %eax
801058f0:	6a 00                	push   $0x0
801058f2:	6a 00                	push   $0x0
801058f4:	e8 ac fd ff ff       	call   801056a5 <argfd>
801058f9:	83 c4 10             	add    $0x10,%esp
801058fc:	85 c0                	test   %eax,%eax
801058fe:	78 17                	js     80105917 <sys_fstat+0x34>
80105900:	83 ec 04             	sub    $0x4,%esp
80105903:	6a 14                	push   $0x14
80105905:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105908:	50                   	push   %eax
80105909:	6a 01                	push   $0x1
8010590b:	e8 78 fc ff ff       	call   80105588 <argptr>
80105910:	83 c4 10             	add    $0x10,%esp
80105913:	85 c0                	test   %eax,%eax
80105915:	79 07                	jns    8010591e <sys_fstat+0x3b>
    return -1;
80105917:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591c:	eb 13                	jmp    80105931 <sys_fstat+0x4e>
  return filestat(f, st);
8010591e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105924:	83 ec 08             	sub    $0x8,%esp
80105927:	52                   	push   %edx
80105928:	50                   	push   %eax
80105929:	e8 5f b8 ff ff       	call   8010118d <filestat>
8010592e:	83 c4 10             	add    $0x10,%esp
}
80105931:	c9                   	leave
80105932:	c3                   	ret

80105933 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105933:	55                   	push   %ebp
80105934:	89 e5                	mov    %esp,%ebp
80105936:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105939:	83 ec 08             	sub    $0x8,%esp
8010593c:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010593f:	50                   	push   %eax
80105940:	6a 00                	push   $0x0
80105942:	e8 a9 fc ff ff       	call   801055f0 <argstr>
80105947:	83 c4 10             	add    $0x10,%esp
8010594a:	85 c0                	test   %eax,%eax
8010594c:	78 15                	js     80105963 <sys_link+0x30>
8010594e:	83 ec 08             	sub    $0x8,%esp
80105951:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105954:	50                   	push   %eax
80105955:	6a 01                	push   $0x1
80105957:	e8 94 fc ff ff       	call   801055f0 <argstr>
8010595c:	83 c4 10             	add    $0x10,%esp
8010595f:	85 c0                	test   %eax,%eax
80105961:	79 0a                	jns    8010596d <sys_link+0x3a>
    return -1;
80105963:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105968:	e9 68 01 00 00       	jmp    80105ad5 <sys_link+0x1a2>

  begin_op();
8010596d:	e8 cc d6 ff ff       	call   8010303e <begin_op>
  if((ip = namei(old)) == 0){
80105972:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105975:	83 ec 0c             	sub    $0xc,%esp
80105978:	50                   	push   %eax
80105979:	e8 a7 cb ff ff       	call   80102525 <namei>
8010597e:	83 c4 10             	add    $0x10,%esp
80105981:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105984:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105988:	75 0f                	jne    80105999 <sys_link+0x66>
    end_op();
8010598a:	e8 3b d7 ff ff       	call   801030ca <end_op>
    return -1;
8010598f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105994:	e9 3c 01 00 00       	jmp    80105ad5 <sys_link+0x1a2>
  }

  ilock(ip);
80105999:	83 ec 0c             	sub    $0xc,%esp
8010599c:	ff 75 f4             	push   -0xc(%ebp)
8010599f:	e8 4e c0 ff ff       	call   801019f2 <ilock>
801059a4:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801059a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059aa:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059ae:	66 83 f8 01          	cmp    $0x1,%ax
801059b2:	75 1d                	jne    801059d1 <sys_link+0x9e>
    iunlockput(ip);
801059b4:	83 ec 0c             	sub    $0xc,%esp
801059b7:	ff 75 f4             	push   -0xc(%ebp)
801059ba:	e8 64 c2 ff ff       	call   80101c23 <iunlockput>
801059bf:	83 c4 10             	add    $0x10,%esp
    end_op();
801059c2:	e8 03 d7 ff ff       	call   801030ca <end_op>
    return -1;
801059c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059cc:	e9 04 01 00 00       	jmp    80105ad5 <sys_link+0x1a2>
  }

  ip->nlink++;
801059d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801059d8:	83 c0 01             	add    $0x1,%eax
801059db:	89 c2                	mov    %eax,%edx
801059dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e0:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801059e4:	83 ec 0c             	sub    $0xc,%esp
801059e7:	ff 75 f4             	push   -0xc(%ebp)
801059ea:	e8 26 be ff ff       	call   80101815 <iupdate>
801059ef:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801059f2:	83 ec 0c             	sub    $0xc,%esp
801059f5:	ff 75 f4             	push   -0xc(%ebp)
801059f8:	e8 08 c1 ff ff       	call   80101b05 <iunlock>
801059fd:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105a00:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a03:	83 ec 08             	sub    $0x8,%esp
80105a06:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105a09:	52                   	push   %edx
80105a0a:	50                   	push   %eax
80105a0b:	e8 31 cb ff ff       	call   80102541 <nameiparent>
80105a10:	83 c4 10             	add    $0x10,%esp
80105a13:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a1a:	74 71                	je     80105a8d <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105a1c:	83 ec 0c             	sub    $0xc,%esp
80105a1f:	ff 75 f0             	push   -0x10(%ebp)
80105a22:	e8 cb bf ff ff       	call   801019f2 <ilock>
80105a27:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2d:	8b 10                	mov    (%eax),%edx
80105a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a32:	8b 00                	mov    (%eax),%eax
80105a34:	39 c2                	cmp    %eax,%edx
80105a36:	75 1d                	jne    80105a55 <sys_link+0x122>
80105a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3b:	8b 40 04             	mov    0x4(%eax),%eax
80105a3e:	83 ec 04             	sub    $0x4,%esp
80105a41:	50                   	push   %eax
80105a42:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105a45:	50                   	push   %eax
80105a46:	ff 75 f0             	push   -0x10(%ebp)
80105a49:	e8 40 c8 ff ff       	call   8010228e <dirlink>
80105a4e:	83 c4 10             	add    $0x10,%esp
80105a51:	85 c0                	test   %eax,%eax
80105a53:	79 10                	jns    80105a65 <sys_link+0x132>
    iunlockput(dp);
80105a55:	83 ec 0c             	sub    $0xc,%esp
80105a58:	ff 75 f0             	push   -0x10(%ebp)
80105a5b:	e8 c3 c1 ff ff       	call   80101c23 <iunlockput>
80105a60:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105a63:	eb 29                	jmp    80105a8e <sys_link+0x15b>
  }
  iunlockput(dp);
80105a65:	83 ec 0c             	sub    $0xc,%esp
80105a68:	ff 75 f0             	push   -0x10(%ebp)
80105a6b:	e8 b3 c1 ff ff       	call   80101c23 <iunlockput>
80105a70:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105a73:	83 ec 0c             	sub    $0xc,%esp
80105a76:	ff 75 f4             	push   -0xc(%ebp)
80105a79:	e8 d5 c0 ff ff       	call   80101b53 <iput>
80105a7e:	83 c4 10             	add    $0x10,%esp

  end_op();
80105a81:	e8 44 d6 ff ff       	call   801030ca <end_op>

  return 0;
80105a86:	b8 00 00 00 00       	mov    $0x0,%eax
80105a8b:	eb 48                	jmp    80105ad5 <sys_link+0x1a2>
    goto bad;
80105a8d:	90                   	nop

bad:
  ilock(ip);
80105a8e:	83 ec 0c             	sub    $0xc,%esp
80105a91:	ff 75 f4             	push   -0xc(%ebp)
80105a94:	e8 59 bf ff ff       	call   801019f2 <ilock>
80105a99:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a9f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105aa3:	83 e8 01             	sub    $0x1,%eax
80105aa6:	89 c2                	mov    %eax,%edx
80105aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aab:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105aaf:	83 ec 0c             	sub    $0xc,%esp
80105ab2:	ff 75 f4             	push   -0xc(%ebp)
80105ab5:	e8 5b bd ff ff       	call   80101815 <iupdate>
80105aba:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105abd:	83 ec 0c             	sub    $0xc,%esp
80105ac0:	ff 75 f4             	push   -0xc(%ebp)
80105ac3:	e8 5b c1 ff ff       	call   80101c23 <iunlockput>
80105ac8:	83 c4 10             	add    $0x10,%esp
  end_op();
80105acb:	e8 fa d5 ff ff       	call   801030ca <end_op>
  return -1;
80105ad0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ad5:	c9                   	leave
80105ad6:	c3                   	ret

80105ad7 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105ad7:	55                   	push   %ebp
80105ad8:	89 e5                	mov    %esp,%ebp
80105ada:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105add:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105ae4:	eb 40                	jmp    80105b26 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae9:	6a 10                	push   $0x10
80105aeb:	50                   	push   %eax
80105aec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105aef:	50                   	push   %eax
80105af0:	ff 75 08             	push   0x8(%ebp)
80105af3:	e8 e6 c3 ff ff       	call   80101ede <readi>
80105af8:	83 c4 10             	add    $0x10,%esp
80105afb:	83 f8 10             	cmp    $0x10,%eax
80105afe:	74 0d                	je     80105b0d <isdirempty+0x36>
      panic("isdirempty: readi");
80105b00:	83 ec 0c             	sub    $0xc,%esp
80105b03:	68 53 ae 10 80       	push   $0x8010ae53
80105b08:	e8 9c aa ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105b0d:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105b11:	66 85 c0             	test   %ax,%ax
80105b14:	74 07                	je     80105b1d <isdirempty+0x46>
      return 0;
80105b16:	b8 00 00 00 00       	mov    $0x0,%eax
80105b1b:	eb 1b                	jmp    80105b38 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b20:	83 c0 10             	add    $0x10,%eax
80105b23:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b26:	8b 45 08             	mov    0x8(%ebp),%eax
80105b29:	8b 40 58             	mov    0x58(%eax),%eax
80105b2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b2f:	39 c2                	cmp    %eax,%edx
80105b31:	72 b3                	jb     80105ae6 <isdirempty+0xf>
  }
  return 1;
80105b33:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105b38:	c9                   	leave
80105b39:	c3                   	ret

80105b3a <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105b3a:	55                   	push   %ebp
80105b3b:	89 e5                	mov    %esp,%ebp
80105b3d:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105b40:	83 ec 08             	sub    $0x8,%esp
80105b43:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105b46:	50                   	push   %eax
80105b47:	6a 00                	push   $0x0
80105b49:	e8 a2 fa ff ff       	call   801055f0 <argstr>
80105b4e:	83 c4 10             	add    $0x10,%esp
80105b51:	85 c0                	test   %eax,%eax
80105b53:	79 0a                	jns    80105b5f <sys_unlink+0x25>
    return -1;
80105b55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b5a:	e9 bf 01 00 00       	jmp    80105d1e <sys_unlink+0x1e4>

  begin_op();
80105b5f:	e8 da d4 ff ff       	call   8010303e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105b64:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105b67:	83 ec 08             	sub    $0x8,%esp
80105b6a:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105b6d:	52                   	push   %edx
80105b6e:	50                   	push   %eax
80105b6f:	e8 cd c9 ff ff       	call   80102541 <nameiparent>
80105b74:	83 c4 10             	add    $0x10,%esp
80105b77:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b7e:	75 0f                	jne    80105b8f <sys_unlink+0x55>
    end_op();
80105b80:	e8 45 d5 ff ff       	call   801030ca <end_op>
    return -1;
80105b85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b8a:	e9 8f 01 00 00       	jmp    80105d1e <sys_unlink+0x1e4>
  }

  ilock(dp);
80105b8f:	83 ec 0c             	sub    $0xc,%esp
80105b92:	ff 75 f4             	push   -0xc(%ebp)
80105b95:	e8 58 be ff ff       	call   801019f2 <ilock>
80105b9a:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105b9d:	83 ec 08             	sub    $0x8,%esp
80105ba0:	68 65 ae 10 80       	push   $0x8010ae65
80105ba5:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ba8:	50                   	push   %eax
80105ba9:	e8 0b c6 ff ff       	call   801021b9 <namecmp>
80105bae:	83 c4 10             	add    $0x10,%esp
80105bb1:	85 c0                	test   %eax,%eax
80105bb3:	0f 84 49 01 00 00    	je     80105d02 <sys_unlink+0x1c8>
80105bb9:	83 ec 08             	sub    $0x8,%esp
80105bbc:	68 67 ae 10 80       	push   $0x8010ae67
80105bc1:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105bc4:	50                   	push   %eax
80105bc5:	e8 ef c5 ff ff       	call   801021b9 <namecmp>
80105bca:	83 c4 10             	add    $0x10,%esp
80105bcd:	85 c0                	test   %eax,%eax
80105bcf:	0f 84 2d 01 00 00    	je     80105d02 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105bd5:	83 ec 04             	sub    $0x4,%esp
80105bd8:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105bdb:	50                   	push   %eax
80105bdc:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105bdf:	50                   	push   %eax
80105be0:	ff 75 f4             	push   -0xc(%ebp)
80105be3:	e8 ec c5 ff ff       	call   801021d4 <dirlookup>
80105be8:	83 c4 10             	add    $0x10,%esp
80105beb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bf2:	0f 84 0d 01 00 00    	je     80105d05 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105bf8:	83 ec 0c             	sub    $0xc,%esp
80105bfb:	ff 75 f0             	push   -0x10(%ebp)
80105bfe:	e8 ef bd ff ff       	call   801019f2 <ilock>
80105c03:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c09:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c0d:	66 85 c0             	test   %ax,%ax
80105c10:	7f 0d                	jg     80105c1f <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105c12:	83 ec 0c             	sub    $0xc,%esp
80105c15:	68 6a ae 10 80       	push   $0x8010ae6a
80105c1a:	e8 8a a9 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105c1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c22:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105c26:	66 83 f8 01          	cmp    $0x1,%ax
80105c2a:	75 25                	jne    80105c51 <sys_unlink+0x117>
80105c2c:	83 ec 0c             	sub    $0xc,%esp
80105c2f:	ff 75 f0             	push   -0x10(%ebp)
80105c32:	e8 a0 fe ff ff       	call   80105ad7 <isdirempty>
80105c37:	83 c4 10             	add    $0x10,%esp
80105c3a:	85 c0                	test   %eax,%eax
80105c3c:	75 13                	jne    80105c51 <sys_unlink+0x117>
    iunlockput(ip);
80105c3e:	83 ec 0c             	sub    $0xc,%esp
80105c41:	ff 75 f0             	push   -0x10(%ebp)
80105c44:	e8 da bf ff ff       	call   80101c23 <iunlockput>
80105c49:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105c4c:	e9 b5 00 00 00       	jmp    80105d06 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105c51:	83 ec 04             	sub    $0x4,%esp
80105c54:	6a 10                	push   $0x10
80105c56:	6a 00                	push   $0x0
80105c58:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105c5b:	50                   	push   %eax
80105c5c:	e8 cf f5 ff ff       	call   80105230 <memset>
80105c61:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105c64:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105c67:	6a 10                	push   $0x10
80105c69:	50                   	push   %eax
80105c6a:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105c6d:	50                   	push   %eax
80105c6e:	ff 75 f4             	push   -0xc(%ebp)
80105c71:	e8 bd c3 ff ff       	call   80102033 <writei>
80105c76:	83 c4 10             	add    $0x10,%esp
80105c79:	83 f8 10             	cmp    $0x10,%eax
80105c7c:	74 0d                	je     80105c8b <sys_unlink+0x151>
    panic("unlink: writei");
80105c7e:	83 ec 0c             	sub    $0xc,%esp
80105c81:	68 7c ae 10 80       	push   $0x8010ae7c
80105c86:	e8 1e a9 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
80105c8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c8e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105c92:	66 83 f8 01          	cmp    $0x1,%ax
80105c96:	75 21                	jne    80105cb9 <sys_unlink+0x17f>
    dp->nlink--;
80105c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c9b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c9f:	83 e8 01             	sub    $0x1,%eax
80105ca2:	89 c2                	mov    %eax,%edx
80105ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca7:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105cab:	83 ec 0c             	sub    $0xc,%esp
80105cae:	ff 75 f4             	push   -0xc(%ebp)
80105cb1:	e8 5f bb ff ff       	call   80101815 <iupdate>
80105cb6:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105cb9:	83 ec 0c             	sub    $0xc,%esp
80105cbc:	ff 75 f4             	push   -0xc(%ebp)
80105cbf:	e8 5f bf ff ff       	call   80101c23 <iunlockput>
80105cc4:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105cc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cca:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105cce:	83 e8 01             	sub    $0x1,%eax
80105cd1:	89 c2                	mov    %eax,%edx
80105cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd6:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105cda:	83 ec 0c             	sub    $0xc,%esp
80105cdd:	ff 75 f0             	push   -0x10(%ebp)
80105ce0:	e8 30 bb ff ff       	call   80101815 <iupdate>
80105ce5:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105ce8:	83 ec 0c             	sub    $0xc,%esp
80105ceb:	ff 75 f0             	push   -0x10(%ebp)
80105cee:	e8 30 bf ff ff       	call   80101c23 <iunlockput>
80105cf3:	83 c4 10             	add    $0x10,%esp

  end_op();
80105cf6:	e8 cf d3 ff ff       	call   801030ca <end_op>

  return 0;
80105cfb:	b8 00 00 00 00       	mov    $0x0,%eax
80105d00:	eb 1c                	jmp    80105d1e <sys_unlink+0x1e4>
    goto bad;
80105d02:	90                   	nop
80105d03:	eb 01                	jmp    80105d06 <sys_unlink+0x1cc>
    goto bad;
80105d05:	90                   	nop

bad:
  iunlockput(dp);
80105d06:	83 ec 0c             	sub    $0xc,%esp
80105d09:	ff 75 f4             	push   -0xc(%ebp)
80105d0c:	e8 12 bf ff ff       	call   80101c23 <iunlockput>
80105d11:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d14:	e8 b1 d3 ff ff       	call   801030ca <end_op>
  return -1;
80105d19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d1e:	c9                   	leave
80105d1f:	c3                   	ret

80105d20 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105d20:	55                   	push   %ebp
80105d21:	89 e5                	mov    %esp,%ebp
80105d23:	83 ec 38             	sub    $0x38,%esp
80105d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105d29:	8b 55 10             	mov    0x10(%ebp),%edx
80105d2c:	8b 45 14             	mov    0x14(%ebp),%eax
80105d2f:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105d33:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105d37:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105d3b:	83 ec 08             	sub    $0x8,%esp
80105d3e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d41:	50                   	push   %eax
80105d42:	ff 75 08             	push   0x8(%ebp)
80105d45:	e8 f7 c7 ff ff       	call   80102541 <nameiparent>
80105d4a:	83 c4 10             	add    $0x10,%esp
80105d4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d50:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d54:	75 0a                	jne    80105d60 <create+0x40>
    return 0;
80105d56:	b8 00 00 00 00       	mov    $0x0,%eax
80105d5b:	e9 90 01 00 00       	jmp    80105ef0 <create+0x1d0>
  ilock(dp);
80105d60:	83 ec 0c             	sub    $0xc,%esp
80105d63:	ff 75 f4             	push   -0xc(%ebp)
80105d66:	e8 87 bc ff ff       	call   801019f2 <ilock>
80105d6b:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105d6e:	83 ec 04             	sub    $0x4,%esp
80105d71:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d74:	50                   	push   %eax
80105d75:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d78:	50                   	push   %eax
80105d79:	ff 75 f4             	push   -0xc(%ebp)
80105d7c:	e8 53 c4 ff ff       	call   801021d4 <dirlookup>
80105d81:	83 c4 10             	add    $0x10,%esp
80105d84:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d87:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d8b:	74 50                	je     80105ddd <create+0xbd>
    iunlockput(dp);
80105d8d:	83 ec 0c             	sub    $0xc,%esp
80105d90:	ff 75 f4             	push   -0xc(%ebp)
80105d93:	e8 8b be ff ff       	call   80101c23 <iunlockput>
80105d98:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105d9b:	83 ec 0c             	sub    $0xc,%esp
80105d9e:	ff 75 f0             	push   -0x10(%ebp)
80105da1:	e8 4c bc ff ff       	call   801019f2 <ilock>
80105da6:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105da9:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105dae:	75 15                	jne    80105dc5 <create+0xa5>
80105db0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105db3:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105db7:	66 83 f8 02          	cmp    $0x2,%ax
80105dbb:	75 08                	jne    80105dc5 <create+0xa5>
      return ip;
80105dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc0:	e9 2b 01 00 00       	jmp    80105ef0 <create+0x1d0>
    iunlockput(ip);
80105dc5:	83 ec 0c             	sub    $0xc,%esp
80105dc8:	ff 75 f0             	push   -0x10(%ebp)
80105dcb:	e8 53 be ff ff       	call   80101c23 <iunlockput>
80105dd0:	83 c4 10             	add    $0x10,%esp
    return 0;
80105dd3:	b8 00 00 00 00       	mov    $0x0,%eax
80105dd8:	e9 13 01 00 00       	jmp    80105ef0 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105ddd:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de4:	8b 00                	mov    (%eax),%eax
80105de6:	83 ec 08             	sub    $0x8,%esp
80105de9:	52                   	push   %edx
80105dea:	50                   	push   %eax
80105deb:	e8 4f b9 ff ff       	call   8010173f <ialloc>
80105df0:	83 c4 10             	add    $0x10,%esp
80105df3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105df6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dfa:	75 0d                	jne    80105e09 <create+0xe9>
    panic("create: ialloc");
80105dfc:	83 ec 0c             	sub    $0xc,%esp
80105dff:	68 8b ae 10 80       	push   $0x8010ae8b
80105e04:	e8 a0 a7 ff ff       	call   801005a9 <panic>

  ilock(ip);
80105e09:	83 ec 0c             	sub    $0xc,%esp
80105e0c:	ff 75 f0             	push   -0x10(%ebp)
80105e0f:	e8 de bb ff ff       	call   801019f2 <ilock>
80105e14:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105e17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e1a:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105e1e:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e25:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105e29:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e30:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105e36:	83 ec 0c             	sub    $0xc,%esp
80105e39:	ff 75 f0             	push   -0x10(%ebp)
80105e3c:	e8 d4 b9 ff ff       	call   80101815 <iupdate>
80105e41:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105e44:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105e49:	75 6a                	jne    80105eb5 <create+0x195>
    dp->nlink++;  // for ".."
80105e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e52:	83 c0 01             	add    $0x1,%eax
80105e55:	89 c2                	mov    %eax,%edx
80105e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e5a:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105e5e:	83 ec 0c             	sub    $0xc,%esp
80105e61:	ff 75 f4             	push   -0xc(%ebp)
80105e64:	e8 ac b9 ff ff       	call   80101815 <iupdate>
80105e69:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105e6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e6f:	8b 40 04             	mov    0x4(%eax),%eax
80105e72:	83 ec 04             	sub    $0x4,%esp
80105e75:	50                   	push   %eax
80105e76:	68 65 ae 10 80       	push   $0x8010ae65
80105e7b:	ff 75 f0             	push   -0x10(%ebp)
80105e7e:	e8 0b c4 ff ff       	call   8010228e <dirlink>
80105e83:	83 c4 10             	add    $0x10,%esp
80105e86:	85 c0                	test   %eax,%eax
80105e88:	78 1e                	js     80105ea8 <create+0x188>
80105e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8d:	8b 40 04             	mov    0x4(%eax),%eax
80105e90:	83 ec 04             	sub    $0x4,%esp
80105e93:	50                   	push   %eax
80105e94:	68 67 ae 10 80       	push   $0x8010ae67
80105e99:	ff 75 f0             	push   -0x10(%ebp)
80105e9c:	e8 ed c3 ff ff       	call   8010228e <dirlink>
80105ea1:	83 c4 10             	add    $0x10,%esp
80105ea4:	85 c0                	test   %eax,%eax
80105ea6:	79 0d                	jns    80105eb5 <create+0x195>
      panic("create dots");
80105ea8:	83 ec 0c             	sub    $0xc,%esp
80105eab:	68 9a ae 10 80       	push   $0x8010ae9a
80105eb0:	e8 f4 a6 ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb8:	8b 40 04             	mov    0x4(%eax),%eax
80105ebb:	83 ec 04             	sub    $0x4,%esp
80105ebe:	50                   	push   %eax
80105ebf:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ec2:	50                   	push   %eax
80105ec3:	ff 75 f4             	push   -0xc(%ebp)
80105ec6:	e8 c3 c3 ff ff       	call   8010228e <dirlink>
80105ecb:	83 c4 10             	add    $0x10,%esp
80105ece:	85 c0                	test   %eax,%eax
80105ed0:	79 0d                	jns    80105edf <create+0x1bf>
    panic("create: dirlink");
80105ed2:	83 ec 0c             	sub    $0xc,%esp
80105ed5:	68 a6 ae 10 80       	push   $0x8010aea6
80105eda:	e8 ca a6 ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105edf:	83 ec 0c             	sub    $0xc,%esp
80105ee2:	ff 75 f4             	push   -0xc(%ebp)
80105ee5:	e8 39 bd ff ff       	call   80101c23 <iunlockput>
80105eea:	83 c4 10             	add    $0x10,%esp

  return ip;
80105eed:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105ef0:	c9                   	leave
80105ef1:	c3                   	ret

80105ef2 <sys_open>:

int
sys_open(void)
{
80105ef2:	55                   	push   %ebp
80105ef3:	89 e5                	mov    %esp,%ebp
80105ef5:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105ef8:	83 ec 08             	sub    $0x8,%esp
80105efb:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105efe:	50                   	push   %eax
80105eff:	6a 00                	push   $0x0
80105f01:	e8 ea f6 ff ff       	call   801055f0 <argstr>
80105f06:	83 c4 10             	add    $0x10,%esp
80105f09:	85 c0                	test   %eax,%eax
80105f0b:	78 15                	js     80105f22 <sys_open+0x30>
80105f0d:	83 ec 08             	sub    $0x8,%esp
80105f10:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f13:	50                   	push   %eax
80105f14:	6a 01                	push   $0x1
80105f16:	e8 40 f6 ff ff       	call   8010555b <argint>
80105f1b:	83 c4 10             	add    $0x10,%esp
80105f1e:	85 c0                	test   %eax,%eax
80105f20:	79 0a                	jns    80105f2c <sys_open+0x3a>
    return -1;
80105f22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f27:	e9 61 01 00 00       	jmp    8010608d <sys_open+0x19b>

  begin_op();
80105f2c:	e8 0d d1 ff ff       	call   8010303e <begin_op>

  if(omode & O_CREATE){
80105f31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f34:	25 00 02 00 00       	and    $0x200,%eax
80105f39:	85 c0                	test   %eax,%eax
80105f3b:	74 2a                	je     80105f67 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105f3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f40:	6a 00                	push   $0x0
80105f42:	6a 00                	push   $0x0
80105f44:	6a 02                	push   $0x2
80105f46:	50                   	push   %eax
80105f47:	e8 d4 fd ff ff       	call   80105d20 <create>
80105f4c:	83 c4 10             	add    $0x10,%esp
80105f4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105f52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f56:	75 75                	jne    80105fcd <sys_open+0xdb>
      end_op();
80105f58:	e8 6d d1 ff ff       	call   801030ca <end_op>
      return -1;
80105f5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f62:	e9 26 01 00 00       	jmp    8010608d <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105f67:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f6a:	83 ec 0c             	sub    $0xc,%esp
80105f6d:	50                   	push   %eax
80105f6e:	e8 b2 c5 ff ff       	call   80102525 <namei>
80105f73:	83 c4 10             	add    $0x10,%esp
80105f76:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f79:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f7d:	75 0f                	jne    80105f8e <sys_open+0x9c>
      end_op();
80105f7f:	e8 46 d1 ff ff       	call   801030ca <end_op>
      return -1;
80105f84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f89:	e9 ff 00 00 00       	jmp    8010608d <sys_open+0x19b>
    }
    ilock(ip);
80105f8e:	83 ec 0c             	sub    $0xc,%esp
80105f91:	ff 75 f4             	push   -0xc(%ebp)
80105f94:	e8 59 ba ff ff       	call   801019f2 <ilock>
80105f99:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f9f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105fa3:	66 83 f8 01          	cmp    $0x1,%ax
80105fa7:	75 24                	jne    80105fcd <sys_open+0xdb>
80105fa9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fac:	85 c0                	test   %eax,%eax
80105fae:	74 1d                	je     80105fcd <sys_open+0xdb>
      iunlockput(ip);
80105fb0:	83 ec 0c             	sub    $0xc,%esp
80105fb3:	ff 75 f4             	push   -0xc(%ebp)
80105fb6:	e8 68 bc ff ff       	call   80101c23 <iunlockput>
80105fbb:	83 c4 10             	add    $0x10,%esp
      end_op();
80105fbe:	e8 07 d1 ff ff       	call   801030ca <end_op>
      return -1;
80105fc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fc8:	e9 c0 00 00 00       	jmp    8010608d <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105fcd:	e8 15 b0 ff ff       	call   80100fe7 <filealloc>
80105fd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fd5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fd9:	74 17                	je     80105ff2 <sys_open+0x100>
80105fdb:	83 ec 0c             	sub    $0xc,%esp
80105fde:	ff 75 f0             	push   -0x10(%ebp)
80105fe1:	e8 33 f7 ff ff       	call   80105719 <fdalloc>
80105fe6:	83 c4 10             	add    $0x10,%esp
80105fe9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105fec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105ff0:	79 2e                	jns    80106020 <sys_open+0x12e>
    if(f)
80105ff2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ff6:	74 0e                	je     80106006 <sys_open+0x114>
      fileclose(f);
80105ff8:	83 ec 0c             	sub    $0xc,%esp
80105ffb:	ff 75 f0             	push   -0x10(%ebp)
80105ffe:	e8 a2 b0 ff ff       	call   801010a5 <fileclose>
80106003:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106006:	83 ec 0c             	sub    $0xc,%esp
80106009:	ff 75 f4             	push   -0xc(%ebp)
8010600c:	e8 12 bc ff ff       	call   80101c23 <iunlockput>
80106011:	83 c4 10             	add    $0x10,%esp
    end_op();
80106014:	e8 b1 d0 ff ff       	call   801030ca <end_op>
    return -1;
80106019:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010601e:	eb 6d                	jmp    8010608d <sys_open+0x19b>
  }
  iunlock(ip);
80106020:	83 ec 0c             	sub    $0xc,%esp
80106023:	ff 75 f4             	push   -0xc(%ebp)
80106026:	e8 da ba ff ff       	call   80101b05 <iunlock>
8010602b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010602e:	e8 97 d0 ff ff       	call   801030ca <end_op>

  f->type = FD_INODE;
80106033:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106036:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010603c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106042:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106045:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106048:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010604f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106052:	83 e0 01             	and    $0x1,%eax
80106055:	85 c0                	test   %eax,%eax
80106057:	0f 94 c0             	sete   %al
8010605a:	89 c2                	mov    %eax,%edx
8010605c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010605f:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106062:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106065:	83 e0 01             	and    $0x1,%eax
80106068:	85 c0                	test   %eax,%eax
8010606a:	75 0a                	jne    80106076 <sys_open+0x184>
8010606c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010606f:	83 e0 02             	and    $0x2,%eax
80106072:	85 c0                	test   %eax,%eax
80106074:	74 07                	je     8010607d <sys_open+0x18b>
80106076:	b8 01 00 00 00       	mov    $0x1,%eax
8010607b:	eb 05                	jmp    80106082 <sys_open+0x190>
8010607d:	b8 00 00 00 00       	mov    $0x0,%eax
80106082:	89 c2                	mov    %eax,%edx
80106084:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106087:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010608a:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010608d:	c9                   	leave
8010608e:	c3                   	ret

8010608f <sys_mkdir>:

int
sys_mkdir(void)
{
8010608f:	55                   	push   %ebp
80106090:	89 e5                	mov    %esp,%ebp
80106092:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106095:	e8 a4 cf ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010609a:	83 ec 08             	sub    $0x8,%esp
8010609d:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060a0:	50                   	push   %eax
801060a1:	6a 00                	push   $0x0
801060a3:	e8 48 f5 ff ff       	call   801055f0 <argstr>
801060a8:	83 c4 10             	add    $0x10,%esp
801060ab:	85 c0                	test   %eax,%eax
801060ad:	78 1b                	js     801060ca <sys_mkdir+0x3b>
801060af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b2:	6a 00                	push   $0x0
801060b4:	6a 00                	push   $0x0
801060b6:	6a 01                	push   $0x1
801060b8:	50                   	push   %eax
801060b9:	e8 62 fc ff ff       	call   80105d20 <create>
801060be:	83 c4 10             	add    $0x10,%esp
801060c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060c8:	75 0c                	jne    801060d6 <sys_mkdir+0x47>
    end_op();
801060ca:	e8 fb cf ff ff       	call   801030ca <end_op>
    return -1;
801060cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d4:	eb 18                	jmp    801060ee <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801060d6:	83 ec 0c             	sub    $0xc,%esp
801060d9:	ff 75 f4             	push   -0xc(%ebp)
801060dc:	e8 42 bb ff ff       	call   80101c23 <iunlockput>
801060e1:	83 c4 10             	add    $0x10,%esp
  end_op();
801060e4:	e8 e1 cf ff ff       	call   801030ca <end_op>
  return 0;
801060e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060ee:	c9                   	leave
801060ef:	c3                   	ret

801060f0 <sys_mknod>:

int
sys_mknod(void)
{
801060f0:	55                   	push   %ebp
801060f1:	89 e5                	mov    %esp,%ebp
801060f3:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801060f6:	e8 43 cf ff ff       	call   8010303e <begin_op>
  if((argstr(0, &path)) < 0 ||
801060fb:	83 ec 08             	sub    $0x8,%esp
801060fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106101:	50                   	push   %eax
80106102:	6a 00                	push   $0x0
80106104:	e8 e7 f4 ff ff       	call   801055f0 <argstr>
80106109:	83 c4 10             	add    $0x10,%esp
8010610c:	85 c0                	test   %eax,%eax
8010610e:	78 4f                	js     8010615f <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80106110:	83 ec 08             	sub    $0x8,%esp
80106113:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106116:	50                   	push   %eax
80106117:	6a 01                	push   $0x1
80106119:	e8 3d f4 ff ff       	call   8010555b <argint>
8010611e:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80106121:	85 c0                	test   %eax,%eax
80106123:	78 3a                	js     8010615f <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80106125:	83 ec 08             	sub    $0x8,%esp
80106128:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010612b:	50                   	push   %eax
8010612c:	6a 02                	push   $0x2
8010612e:	e8 28 f4 ff ff       	call   8010555b <argint>
80106133:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80106136:	85 c0                	test   %eax,%eax
80106138:	78 25                	js     8010615f <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010613a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010613d:	0f bf c8             	movswl %ax,%ecx
80106140:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106143:	0f bf d0             	movswl %ax,%edx
80106146:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106149:	51                   	push   %ecx
8010614a:	52                   	push   %edx
8010614b:	6a 03                	push   $0x3
8010614d:	50                   	push   %eax
8010614e:	e8 cd fb ff ff       	call   80105d20 <create>
80106153:	83 c4 10             	add    $0x10,%esp
80106156:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80106159:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010615d:	75 0c                	jne    8010616b <sys_mknod+0x7b>
    end_op();
8010615f:	e8 66 cf ff ff       	call   801030ca <end_op>
    return -1;
80106164:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106169:	eb 18                	jmp    80106183 <sys_mknod+0x93>
  }
  iunlockput(ip);
8010616b:	83 ec 0c             	sub    $0xc,%esp
8010616e:	ff 75 f4             	push   -0xc(%ebp)
80106171:	e8 ad ba ff ff       	call   80101c23 <iunlockput>
80106176:	83 c4 10             	add    $0x10,%esp
  end_op();
80106179:	e8 4c cf ff ff       	call   801030ca <end_op>
  return 0;
8010617e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106183:	c9                   	leave
80106184:	c3                   	ret

80106185 <sys_chdir>:

int
sys_chdir(void)
{
80106185:	55                   	push   %ebp
80106186:	89 e5                	mov    %esp,%ebp
80106188:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010618b:	e8 a0 d8 ff ff       	call   80103a30 <myproc>
80106190:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106193:	e8 a6 ce ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106198:	83 ec 08             	sub    $0x8,%esp
8010619b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010619e:	50                   	push   %eax
8010619f:	6a 00                	push   $0x0
801061a1:	e8 4a f4 ff ff       	call   801055f0 <argstr>
801061a6:	83 c4 10             	add    $0x10,%esp
801061a9:	85 c0                	test   %eax,%eax
801061ab:	78 18                	js     801061c5 <sys_chdir+0x40>
801061ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061b0:	83 ec 0c             	sub    $0xc,%esp
801061b3:	50                   	push   %eax
801061b4:	e8 6c c3 ff ff       	call   80102525 <namei>
801061b9:	83 c4 10             	add    $0x10,%esp
801061bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061c3:	75 0c                	jne    801061d1 <sys_chdir+0x4c>
    end_op();
801061c5:	e8 00 cf ff ff       	call   801030ca <end_op>
    return -1;
801061ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061cf:	eb 68                	jmp    80106239 <sys_chdir+0xb4>
  }
  ilock(ip);
801061d1:	83 ec 0c             	sub    $0xc,%esp
801061d4:	ff 75 f0             	push   -0x10(%ebp)
801061d7:	e8 16 b8 ff ff       	call   801019f2 <ilock>
801061dc:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801061df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061e2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801061e6:	66 83 f8 01          	cmp    $0x1,%ax
801061ea:	74 1a                	je     80106206 <sys_chdir+0x81>
    iunlockput(ip);
801061ec:	83 ec 0c             	sub    $0xc,%esp
801061ef:	ff 75 f0             	push   -0x10(%ebp)
801061f2:	e8 2c ba ff ff       	call   80101c23 <iunlockput>
801061f7:	83 c4 10             	add    $0x10,%esp
    end_op();
801061fa:	e8 cb ce ff ff       	call   801030ca <end_op>
    return -1;
801061ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106204:	eb 33                	jmp    80106239 <sys_chdir+0xb4>
  }
  iunlock(ip);
80106206:	83 ec 0c             	sub    $0xc,%esp
80106209:	ff 75 f0             	push   -0x10(%ebp)
8010620c:	e8 f4 b8 ff ff       	call   80101b05 <iunlock>
80106211:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80106214:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106217:	8b 40 68             	mov    0x68(%eax),%eax
8010621a:	83 ec 0c             	sub    $0xc,%esp
8010621d:	50                   	push   %eax
8010621e:	e8 30 b9 ff ff       	call   80101b53 <iput>
80106223:	83 c4 10             	add    $0x10,%esp
  end_op();
80106226:	e8 9f ce ff ff       	call   801030ca <end_op>
  curproc->cwd = ip;
8010622b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106231:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106234:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106239:	c9                   	leave
8010623a:	c3                   	ret

8010623b <sys_exec>:

int
sys_exec(void)
{
8010623b:	55                   	push   %ebp
8010623c:	89 e5                	mov    %esp,%ebp
8010623e:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106244:	83 ec 08             	sub    $0x8,%esp
80106247:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010624a:	50                   	push   %eax
8010624b:	6a 00                	push   $0x0
8010624d:	e8 9e f3 ff ff       	call   801055f0 <argstr>
80106252:	83 c4 10             	add    $0x10,%esp
80106255:	85 c0                	test   %eax,%eax
80106257:	78 18                	js     80106271 <sys_exec+0x36>
80106259:	83 ec 08             	sub    $0x8,%esp
8010625c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106262:	50                   	push   %eax
80106263:	6a 01                	push   $0x1
80106265:	e8 f1 f2 ff ff       	call   8010555b <argint>
8010626a:	83 c4 10             	add    $0x10,%esp
8010626d:	85 c0                	test   %eax,%eax
8010626f:	79 0a                	jns    8010627b <sys_exec+0x40>
    return -1;
80106271:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106276:	e9 c6 00 00 00       	jmp    80106341 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
8010627b:	83 ec 04             	sub    $0x4,%esp
8010627e:	68 80 00 00 00       	push   $0x80
80106283:	6a 00                	push   $0x0
80106285:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010628b:	50                   	push   %eax
8010628c:	e8 9f ef ff ff       	call   80105230 <memset>
80106291:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106294:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010629b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010629e:	83 f8 1f             	cmp    $0x1f,%eax
801062a1:	76 0a                	jbe    801062ad <sys_exec+0x72>
      return -1;
801062a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a8:	e9 94 00 00 00       	jmp    80106341 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801062ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b0:	c1 e0 02             	shl    $0x2,%eax
801062b3:	89 c2                	mov    %eax,%edx
801062b5:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801062bb:	01 c2                	add    %eax,%edx
801062bd:	83 ec 08             	sub    $0x8,%esp
801062c0:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801062c6:	50                   	push   %eax
801062c7:	52                   	push   %edx
801062c8:	e8 ed f1 ff ff       	call   801054ba <fetchint>
801062cd:	83 c4 10             	add    $0x10,%esp
801062d0:	85 c0                	test   %eax,%eax
801062d2:	79 07                	jns    801062db <sys_exec+0xa0>
      return -1;
801062d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d9:	eb 66                	jmp    80106341 <sys_exec+0x106>
    if(uarg == 0){
801062db:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801062e1:	85 c0                	test   %eax,%eax
801062e3:	75 27                	jne    8010630c <sys_exec+0xd1>
      argv[i] = 0;
801062e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e8:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801062ef:	00 00 00 00 
      break;
801062f3:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801062f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f7:	83 ec 08             	sub    $0x8,%esp
801062fa:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106300:	52                   	push   %edx
80106301:	50                   	push   %eax
80106302:	e8 83 a8 ff ff       	call   80100b8a <exec>
80106307:	83 c4 10             	add    $0x10,%esp
8010630a:	eb 35                	jmp    80106341 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
8010630c:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106312:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106315:	c1 e2 02             	shl    $0x2,%edx
80106318:	01 c2                	add    %eax,%edx
8010631a:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106320:	83 ec 08             	sub    $0x8,%esp
80106323:	52                   	push   %edx
80106324:	50                   	push   %eax
80106325:	e8 cf f1 ff ff       	call   801054f9 <fetchstr>
8010632a:	83 c4 10             	add    $0x10,%esp
8010632d:	85 c0                	test   %eax,%eax
8010632f:	79 07                	jns    80106338 <sys_exec+0xfd>
      return -1;
80106331:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106336:	eb 09                	jmp    80106341 <sys_exec+0x106>
  for(i=0;; i++){
80106338:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
8010633c:	e9 5a ff ff ff       	jmp    8010629b <sys_exec+0x60>
}
80106341:	c9                   	leave
80106342:	c3                   	ret

80106343 <sys_pipe>:

int
sys_pipe(void)
{
80106343:	55                   	push   %ebp
80106344:	89 e5                	mov    %esp,%ebp
80106346:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106349:	83 ec 04             	sub    $0x4,%esp
8010634c:	6a 08                	push   $0x8
8010634e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106351:	50                   	push   %eax
80106352:	6a 00                	push   $0x0
80106354:	e8 2f f2 ff ff       	call   80105588 <argptr>
80106359:	83 c4 10             	add    $0x10,%esp
8010635c:	85 c0                	test   %eax,%eax
8010635e:	79 0a                	jns    8010636a <sys_pipe+0x27>
    return -1;
80106360:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106365:	e9 ae 00 00 00       	jmp    80106418 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
8010636a:	83 ec 08             	sub    $0x8,%esp
8010636d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106370:	50                   	push   %eax
80106371:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106374:	50                   	push   %eax
80106375:	e8 f3 d1 ff ff       	call   8010356d <pipealloc>
8010637a:	83 c4 10             	add    $0x10,%esp
8010637d:	85 c0                	test   %eax,%eax
8010637f:	79 0a                	jns    8010638b <sys_pipe+0x48>
    return -1;
80106381:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106386:	e9 8d 00 00 00       	jmp    80106418 <sys_pipe+0xd5>
  fd0 = -1;
8010638b:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106392:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106395:	83 ec 0c             	sub    $0xc,%esp
80106398:	50                   	push   %eax
80106399:	e8 7b f3 ff ff       	call   80105719 <fdalloc>
8010639e:	83 c4 10             	add    $0x10,%esp
801063a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063a8:	78 18                	js     801063c2 <sys_pipe+0x7f>
801063aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063ad:	83 ec 0c             	sub    $0xc,%esp
801063b0:	50                   	push   %eax
801063b1:	e8 63 f3 ff ff       	call   80105719 <fdalloc>
801063b6:	83 c4 10             	add    $0x10,%esp
801063b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063c0:	79 3e                	jns    80106400 <sys_pipe+0xbd>
    if(fd0 >= 0)
801063c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063c6:	78 13                	js     801063db <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
801063c8:	e8 63 d6 ff ff       	call   80103a30 <myproc>
801063cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063d0:	83 c2 08             	add    $0x8,%edx
801063d3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801063da:	00 
    fileclose(rf);
801063db:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063de:	83 ec 0c             	sub    $0xc,%esp
801063e1:	50                   	push   %eax
801063e2:	e8 be ac ff ff       	call   801010a5 <fileclose>
801063e7:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801063ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063ed:	83 ec 0c             	sub    $0xc,%esp
801063f0:	50                   	push   %eax
801063f1:	e8 af ac ff ff       	call   801010a5 <fileclose>
801063f6:	83 c4 10             	add    $0x10,%esp
    return -1;
801063f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063fe:	eb 18                	jmp    80106418 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80106400:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106403:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106406:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106408:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010640b:	8d 50 04             	lea    0x4(%eax),%edx
8010640e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106411:	89 02                	mov    %eax,(%edx)
  return 0;
80106413:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106418:	c9                   	leave
80106419:	c3                   	ret

8010641a <sys_getpinfo>:

#include "pstat.h"

int getpinfo(struct pstat *ps);

int sys_getpinfo(void) {
8010641a:	55                   	push   %ebp
8010641b:	89 e5                	mov    %esp,%ebp
8010641d:	83 ec 18             	sub    $0x18,%esp
  struct pstat *ps;
  if (argptr(0, (char**)&ps, sizeof(struct pstat)) < 0)
80106420:	83 ec 04             	sub    $0x4,%esp
80106423:	68 00 0c 00 00       	push   $0xc00
80106428:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010642b:	50                   	push   %eax
8010642c:	6a 00                	push   $0x0
8010642e:	e8 55 f1 ff ff       	call   80105588 <argptr>
80106433:	83 c4 10             	add    $0x10,%esp
80106436:	85 c0                	test   %eax,%eax
80106438:	79 07                	jns    80106441 <sys_getpinfo+0x27>
    return -1;
8010643a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010643f:	eb 0f                	jmp    80106450 <sys_getpinfo+0x36>
  return getpinfo(ps);
80106441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106444:	83 ec 0c             	sub    $0xc,%esp
80106447:	50                   	push   %eax
80106448:	e8 d2 e2 ff ff       	call   8010471f <getpinfo>
8010644d:	83 c4 10             	add    $0x10,%esp
}
80106450:	c9                   	leave
80106451:	c3                   	ret

80106452 <sys_setSchedPolicy>:

extern int set_sched_policy(int);
int
sys_setSchedPolicy(void)
{
80106452:	55                   	push   %ebp
80106453:	89 e5                	mov    %esp,%ebp
80106455:	83 ec 18             	sub    $0x18,%esp
  int policy;
  if(argint(0, &policy) < 0)
80106458:	83 ec 08             	sub    $0x8,%esp
8010645b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010645e:	50                   	push   %eax
8010645f:	6a 00                	push   $0x0
80106461:	e8 f5 f0 ff ff       	call   8010555b <argint>
80106466:	83 c4 10             	add    $0x10,%esp
80106469:	85 c0                	test   %eax,%eax
8010646b:	79 07                	jns    80106474 <sys_setSchedPolicy+0x22>
    return -1;
8010646d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106472:	eb 23                	jmp    80106497 <sys_setSchedPolicy+0x45>
  cprintf("[SYSCALL] setSchedPolicy called with %d\n", policy);
80106474:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106477:	83 ec 08             	sub    $0x8,%esp
8010647a:	50                   	push   %eax
8010647b:	68 b8 ae 10 80       	push   $0x8010aeb8
80106480:	e8 6f 9f ff ff       	call   801003f4 <cprintf>
80106485:	83 c4 10             	add    $0x10,%esp
  return set_sched_policy(policy);
80106488:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010648b:	83 ec 0c             	sub    $0xc,%esp
8010648e:	50                   	push   %eax
8010648f:	e8 b8 e3 ff ff       	call   8010484c <set_sched_policy>
80106494:	83 c4 10             	add    $0x10,%esp
}
80106497:	c9                   	leave
80106498:	c3                   	ret

80106499 <sys_getSchedPolicy>:

extern int get_sched_policy(void);

int
sys_getSchedPolicy(void)
{
80106499:	55                   	push   %ebp
8010649a:	89 e5                	mov    %esp,%ebp
8010649c:	83 ec 08             	sub    $0x8,%esp
  return get_sched_policy();
8010649f:	e8 e0 e3 ff ff       	call   80104884 <get_sched_policy>
}
801064a4:	c9                   	leave
801064a5:	c3                   	ret

801064a6 <sys_yield>:
int
sys_yield(void)
{
801064a6:	55                   	push   %ebp
801064a7:	89 e5                	mov    %esp,%ebp
801064a9:	83 ec 08             	sub    $0x8,%esp
  yield(); // 커널 내부 yield 함수
801064ac:	e8 52 df ff ff       	call   80104403 <yield>
  return 0;
801064b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064b6:	c9                   	leave
801064b7:	c3                   	ret

801064b8 <sys_fork>:

int
sys_fork(void)
{
801064b8:	55                   	push   %ebp
801064b9:	89 e5                	mov    %esp,%ebp
801064bb:	83 ec 08             	sub    $0x8,%esp
  return fork();
801064be:	e8 0d d9 ff ff       	call   80103dd0 <fork>
}
801064c3:	c9                   	leave
801064c4:	c3                   	ret

801064c5 <sys_exit>:

int
sys_exit(void)
{
801064c5:	55                   	push   %ebp
801064c6:	89 e5                	mov    %esp,%ebp
801064c8:	83 ec 08             	sub    $0x8,%esp
  exit();
801064cb:	e8 ca da ff ff       	call   80103f9a <exit>
  return 0;  // not reached
801064d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064d5:	c9                   	leave
801064d6:	c3                   	ret

801064d7 <sys_wait>:

int
sys_wait(void)
{
801064d7:	55                   	push   %ebp
801064d8:	89 e5                	mov    %esp,%ebp
801064da:	83 ec 08             	sub    $0x8,%esp
  return wait();
801064dd:	e8 fa db ff ff       	call   801040dc <wait>
}
801064e2:	c9                   	leave
801064e3:	c3                   	ret

801064e4 <sys_kill>:

int
sys_kill(void)
{
801064e4:	55                   	push   %ebp
801064e5:	89 e5                	mov    %esp,%ebp
801064e7:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801064ea:	83 ec 08             	sub    $0x8,%esp
801064ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064f0:	50                   	push   %eax
801064f1:	6a 00                	push   $0x0
801064f3:	e8 63 f0 ff ff       	call   8010555b <argint>
801064f8:	83 c4 10             	add    $0x10,%esp
801064fb:	85 c0                	test   %eax,%eax
801064fd:	79 07                	jns    80106506 <sys_kill+0x22>
    return -1;
801064ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106504:	eb 0f                	jmp    80106515 <sys_kill+0x31>
  return kill(pid);
80106506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106509:	83 ec 0c             	sub    $0xc,%esp
8010650c:	50                   	push   %eax
8010650d:	e8 8f e0 ff ff       	call   801045a1 <kill>
80106512:	83 c4 10             	add    $0x10,%esp
}
80106515:	c9                   	leave
80106516:	c3                   	ret

80106517 <sys_getpid>:

int
sys_getpid(void)
{
80106517:	55                   	push   %ebp
80106518:	89 e5                	mov    %esp,%ebp
8010651a:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010651d:	e8 0e d5 ff ff       	call   80103a30 <myproc>
80106522:	8b 40 10             	mov    0x10(%eax),%eax
}
80106525:	c9                   	leave
80106526:	c3                   	ret

80106527 <sys_sbrk>:

int
sys_sbrk(void)
{
80106527:	55                   	push   %ebp
80106528:	89 e5                	mov    %esp,%ebp
8010652a:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010652d:	83 ec 08             	sub    $0x8,%esp
80106530:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106533:	50                   	push   %eax
80106534:	6a 00                	push   $0x0
80106536:	e8 20 f0 ff ff       	call   8010555b <argint>
8010653b:	83 c4 10             	add    $0x10,%esp
8010653e:	85 c0                	test   %eax,%eax
80106540:	79 07                	jns    80106549 <sys_sbrk+0x22>
    return -1;
80106542:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106547:	eb 27                	jmp    80106570 <sys_sbrk+0x49>
  addr = myproc()->sz;
80106549:	e8 e2 d4 ff ff       	call   80103a30 <myproc>
8010654e:	8b 00                	mov    (%eax),%eax
80106550:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106553:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106556:	83 ec 0c             	sub    $0xc,%esp
80106559:	50                   	push   %eax
8010655a:	e8 d6 d7 ff ff       	call   80103d35 <growproc>
8010655f:	83 c4 10             	add    $0x10,%esp
80106562:	85 c0                	test   %eax,%eax
80106564:	79 07                	jns    8010656d <sys_sbrk+0x46>
    return -1;
80106566:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010656b:	eb 03                	jmp    80106570 <sys_sbrk+0x49>
  return addr;
8010656d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106570:	c9                   	leave
80106571:	c3                   	ret

80106572 <sys_sleep>:

int
sys_sleep(void)
{
80106572:	55                   	push   %ebp
80106573:	89 e5                	mov    %esp,%ebp
80106575:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106578:	83 ec 08             	sub    $0x8,%esp
8010657b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010657e:	50                   	push   %eax
8010657f:	6a 00                	push   $0x0
80106581:	e8 d5 ef ff ff       	call   8010555b <argint>
80106586:	83 c4 10             	add    $0x10,%esp
80106589:	85 c0                	test   %eax,%eax
8010658b:	79 07                	jns    80106594 <sys_sleep+0x22>
    return -1;
8010658d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106592:	eb 76                	jmp    8010660a <sys_sleep+0x98>
  acquire(&tickslock);
80106594:	83 ec 0c             	sub    $0xc,%esp
80106597:	68 80 79 19 80       	push   $0x80197980
8010659c:	e8 19 ea ff ff       	call   80104fba <acquire>
801065a1:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801065a4:	a1 b4 79 19 80       	mov    0x801979b4,%eax
801065a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801065ac:	eb 38                	jmp    801065e6 <sys_sleep+0x74>
    if(myproc()->killed){
801065ae:	e8 7d d4 ff ff       	call   80103a30 <myproc>
801065b3:	8b 40 24             	mov    0x24(%eax),%eax
801065b6:	85 c0                	test   %eax,%eax
801065b8:	74 17                	je     801065d1 <sys_sleep+0x5f>
      release(&tickslock);
801065ba:	83 ec 0c             	sub    $0xc,%esp
801065bd:	68 80 79 19 80       	push   $0x80197980
801065c2:	e8 61 ea ff ff       	call   80105028 <release>
801065c7:	83 c4 10             	add    $0x10,%esp
      return -1;
801065ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065cf:	eb 39                	jmp    8010660a <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
801065d1:	83 ec 08             	sub    $0x8,%esp
801065d4:	68 80 79 19 80       	push   $0x80197980
801065d9:	68 b4 79 19 80       	push   $0x801979b4
801065de:	e8 a0 de ff ff       	call   80104483 <sleep>
801065e3:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801065e6:	a1 b4 79 19 80       	mov    0x801979b4,%eax
801065eb:	2b 45 f4             	sub    -0xc(%ebp),%eax
801065ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065f1:	39 d0                	cmp    %edx,%eax
801065f3:	72 b9                	jb     801065ae <sys_sleep+0x3c>
  }
  release(&tickslock);
801065f5:	83 ec 0c             	sub    $0xc,%esp
801065f8:	68 80 79 19 80       	push   $0x80197980
801065fd:	e8 26 ea ff ff       	call   80105028 <release>
80106602:	83 c4 10             	add    $0x10,%esp
  return 0;
80106605:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010660a:	c9                   	leave
8010660b:	c3                   	ret

8010660c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010660c:	55                   	push   %ebp
8010660d:	89 e5                	mov    %esp,%ebp
8010660f:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106612:	83 ec 0c             	sub    $0xc,%esp
80106615:	68 80 79 19 80       	push   $0x80197980
8010661a:	e8 9b e9 ff ff       	call   80104fba <acquire>
8010661f:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106622:	a1 b4 79 19 80       	mov    0x801979b4,%eax
80106627:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010662a:	83 ec 0c             	sub    $0xc,%esp
8010662d:	68 80 79 19 80       	push   $0x80197980
80106632:	e8 f1 e9 ff ff       	call   80105028 <release>
80106637:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010663a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010663d:	c9                   	leave
8010663e:	c3                   	ret

8010663f <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010663f:	1e                   	push   %ds
  pushl %es
80106640:	06                   	push   %es
  pushl %fs
80106641:	0f a0                	push   %fs
  pushl %gs
80106643:	0f a8                	push   %gs
  pushal
80106645:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106646:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010664a:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010664c:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010664e:	54                   	push   %esp
  call trap
8010664f:	e8 d7 01 00 00       	call   8010682b <trap>
  addl $4, %esp
80106654:	83 c4 04             	add    $0x4,%esp

80106657 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106657:	61                   	popa
  popl %gs
80106658:	0f a9                	pop    %gs
  popl %fs
8010665a:	0f a1                	pop    %fs
  popl %es
8010665c:	07                   	pop    %es
  popl %ds
8010665d:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010665e:	83 c4 08             	add    $0x8,%esp
  iret
80106661:	cf                   	iret

80106662 <lidt>:
{
80106662:	55                   	push   %ebp
80106663:	89 e5                	mov    %esp,%ebp
80106665:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106668:	8b 45 0c             	mov    0xc(%ebp),%eax
8010666b:	83 e8 01             	sub    $0x1,%eax
8010666e:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106672:	8b 45 08             	mov    0x8(%ebp),%eax
80106675:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106679:	8b 45 08             	mov    0x8(%ebp),%eax
8010667c:	c1 e8 10             	shr    $0x10,%eax
8010667f:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106683:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106686:	0f 01 18             	lidtl  (%eax)
}
80106689:	90                   	nop
8010668a:	c9                   	leave
8010668b:	c3                   	ret

8010668c <rcr2>:

static inline uint
rcr2(void)
{
8010668c:	55                   	push   %ebp
8010668d:	89 e5                	mov    %esp,%ebp
8010668f:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106692:	0f 20 d0             	mov    %cr2,%eax
80106695:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106698:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010669b:	c9                   	leave
8010669c:	c3                   	ret

8010669d <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010669d:	55                   	push   %ebp
8010669e:	89 e5                	mov    %esp,%ebp
801066a0:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801066a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801066aa:	e9 c3 00 00 00       	jmp    80106772 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801066af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b2:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
801066b9:	89 c2                	mov    %eax,%edx
801066bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066be:	66 89 14 c5 80 71 19 	mov    %dx,-0x7fe68e80(,%eax,8)
801066c5:	80 
801066c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c9:	66 c7 04 c5 82 71 19 	movw   $0x8,-0x7fe68e7e(,%eax,8)
801066d0:	80 08 00 
801066d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d6:	0f b6 14 c5 84 71 19 	movzbl -0x7fe68e7c(,%eax,8),%edx
801066dd:	80 
801066de:	83 e2 e0             	and    $0xffffffe0,%edx
801066e1:	88 14 c5 84 71 19 80 	mov    %dl,-0x7fe68e7c(,%eax,8)
801066e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066eb:	0f b6 14 c5 84 71 19 	movzbl -0x7fe68e7c(,%eax,8),%edx
801066f2:	80 
801066f3:	83 e2 1f             	and    $0x1f,%edx
801066f6:	88 14 c5 84 71 19 80 	mov    %dl,-0x7fe68e7c(,%eax,8)
801066fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106700:	0f b6 14 c5 85 71 19 	movzbl -0x7fe68e7b(,%eax,8),%edx
80106707:	80 
80106708:	83 e2 f0             	and    $0xfffffff0,%edx
8010670b:	83 ca 0e             	or     $0xe,%edx
8010670e:	88 14 c5 85 71 19 80 	mov    %dl,-0x7fe68e7b(,%eax,8)
80106715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106718:	0f b6 14 c5 85 71 19 	movzbl -0x7fe68e7b(,%eax,8),%edx
8010671f:	80 
80106720:	83 e2 ef             	and    $0xffffffef,%edx
80106723:	88 14 c5 85 71 19 80 	mov    %dl,-0x7fe68e7b(,%eax,8)
8010672a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010672d:	0f b6 14 c5 85 71 19 	movzbl -0x7fe68e7b(,%eax,8),%edx
80106734:	80 
80106735:	83 e2 9f             	and    $0xffffff9f,%edx
80106738:	88 14 c5 85 71 19 80 	mov    %dl,-0x7fe68e7b(,%eax,8)
8010673f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106742:	0f b6 14 c5 85 71 19 	movzbl -0x7fe68e7b(,%eax,8),%edx
80106749:	80 
8010674a:	83 ca 80             	or     $0xffffff80,%edx
8010674d:	88 14 c5 85 71 19 80 	mov    %dl,-0x7fe68e7b(,%eax,8)
80106754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106757:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
8010675e:	c1 e8 10             	shr    $0x10,%eax
80106761:	89 c2                	mov    %eax,%edx
80106763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106766:	66 89 14 c5 86 71 19 	mov    %dx,-0x7fe68e7a(,%eax,8)
8010676d:	80 
  for(i = 0; i < 256; i++)
8010676e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106772:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106779:	0f 8e 30 ff ff ff    	jle    801066af <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010677f:	a1 88 f1 10 80       	mov    0x8010f188,%eax
80106784:	66 a3 80 73 19 80    	mov    %ax,0x80197380
8010678a:	66 c7 05 82 73 19 80 	movw   $0x8,0x80197382
80106791:	08 00 
80106793:	0f b6 05 84 73 19 80 	movzbl 0x80197384,%eax
8010679a:	83 e0 e0             	and    $0xffffffe0,%eax
8010679d:	a2 84 73 19 80       	mov    %al,0x80197384
801067a2:	0f b6 05 84 73 19 80 	movzbl 0x80197384,%eax
801067a9:	83 e0 1f             	and    $0x1f,%eax
801067ac:	a2 84 73 19 80       	mov    %al,0x80197384
801067b1:	0f b6 05 85 73 19 80 	movzbl 0x80197385,%eax
801067b8:	83 c8 0f             	or     $0xf,%eax
801067bb:	a2 85 73 19 80       	mov    %al,0x80197385
801067c0:	0f b6 05 85 73 19 80 	movzbl 0x80197385,%eax
801067c7:	83 e0 ef             	and    $0xffffffef,%eax
801067ca:	a2 85 73 19 80       	mov    %al,0x80197385
801067cf:	0f b6 05 85 73 19 80 	movzbl 0x80197385,%eax
801067d6:	83 c8 60             	or     $0x60,%eax
801067d9:	a2 85 73 19 80       	mov    %al,0x80197385
801067de:	0f b6 05 85 73 19 80 	movzbl 0x80197385,%eax
801067e5:	83 c8 80             	or     $0xffffff80,%eax
801067e8:	a2 85 73 19 80       	mov    %al,0x80197385
801067ed:	a1 88 f1 10 80       	mov    0x8010f188,%eax
801067f2:	c1 e8 10             	shr    $0x10,%eax
801067f5:	66 a3 86 73 19 80    	mov    %ax,0x80197386

  initlock(&tickslock, "time");
801067fb:	83 ec 08             	sub    $0x8,%esp
801067fe:	68 e4 ae 10 80       	push   $0x8010aee4
80106803:	68 80 79 19 80       	push   $0x80197980
80106808:	e8 8b e7 ff ff       	call   80104f98 <initlock>
8010680d:	83 c4 10             	add    $0x10,%esp
}
80106810:	90                   	nop
80106811:	c9                   	leave
80106812:	c3                   	ret

80106813 <idtinit>:

void
idtinit(void)
{
80106813:	55                   	push   %ebp
80106814:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106816:	68 00 08 00 00       	push   $0x800
8010681b:	68 80 71 19 80       	push   $0x80197180
80106820:	e8 3d fe ff ff       	call   80106662 <lidt>
80106825:	83 c4 08             	add    $0x8,%esp
}
80106828:	90                   	nop
80106829:	c9                   	leave
8010682a:	c3                   	ret

8010682b <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010682b:	55                   	push   %ebp
8010682c:	89 e5                	mov    %esp,%ebp
8010682e:	57                   	push   %edi
8010682f:	56                   	push   %esi
80106830:	53                   	push   %ebx
80106831:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106834:	8b 45 08             	mov    0x8(%ebp),%eax
80106837:	8b 40 30             	mov    0x30(%eax),%eax
8010683a:	83 f8 40             	cmp    $0x40,%eax
8010683d:	75 3b                	jne    8010687a <trap+0x4f>
    if(myproc()->killed)
8010683f:	e8 ec d1 ff ff       	call   80103a30 <myproc>
80106844:	8b 40 24             	mov    0x24(%eax),%eax
80106847:	85 c0                	test   %eax,%eax
80106849:	74 05                	je     80106850 <trap+0x25>
      exit();
8010684b:	e8 4a d7 ff ff       	call   80103f9a <exit>
    myproc()->tf = tf;
80106850:	e8 db d1 ff ff       	call   80103a30 <myproc>
80106855:	8b 55 08             	mov    0x8(%ebp),%edx
80106858:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010685b:	e8 c7 ed ff ff       	call   80105627 <syscall>
    if(myproc()->killed)
80106860:	e8 cb d1 ff ff       	call   80103a30 <myproc>
80106865:	8b 40 24             	mov    0x24(%eax),%eax
80106868:	85 c0                	test   %eax,%eax
8010686a:	0f 84 8d 02 00 00    	je     80106afd <trap+0x2d2>
      exit();
80106870:	e8 25 d7 ff ff       	call   80103f9a <exit>
    return;
80106875:	e9 83 02 00 00       	jmp    80106afd <trap+0x2d2>
  }

  switch(tf->trapno){
8010687a:	8b 45 08             	mov    0x8(%ebp),%eax
8010687d:	8b 40 30             	mov    0x30(%eax),%eax
80106880:	83 e8 20             	sub    $0x20,%eax
80106883:	83 f8 1f             	cmp    $0x1f,%eax
80106886:	0f 87 3c 01 00 00    	ja     801069c8 <trap+0x19d>
8010688c:	8b 04 85 8c af 10 80 	mov    -0x7fef5074(,%eax,4),%eax
80106893:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106895:	e8 03 d1 ff ff       	call   8010399d <cpuid>
8010689a:	85 c0                	test   %eax,%eax
8010689c:	75 3d                	jne    801068db <trap+0xb0>
      acquire(&tickslock);
8010689e:	83 ec 0c             	sub    $0xc,%esp
801068a1:	68 80 79 19 80       	push   $0x80197980
801068a6:	e8 0f e7 ff ff       	call   80104fba <acquire>
801068ab:	83 c4 10             	add    $0x10,%esp
      ticks++;
801068ae:	a1 b4 79 19 80       	mov    0x801979b4,%eax
801068b3:	83 c0 01             	add    $0x1,%eax
801068b6:	a3 b4 79 19 80       	mov    %eax,0x801979b4
      wakeup(&ticks);
801068bb:	83 ec 0c             	sub    $0xc,%esp
801068be:	68 b4 79 19 80       	push   $0x801979b4
801068c3:	e8 a2 dc ff ff       	call   8010456a <wakeup>
801068c8:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801068cb:	83 ec 0c             	sub    $0xc,%esp
801068ce:	68 80 79 19 80       	push   $0x80197980
801068d3:	e8 50 e7 ff ff       	call   80105028 <release>
801068d8:	83 c4 10             	add    $0x10,%esp
    }
    //현재 실행 중인 프로세스에 대해 tick 누적
    struct proc* p = myproc();
801068db:	e8 50 d1 ff ff       	call   80103a30 <myproc>
801068e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0 && p->state == RUNNING) {
801068e3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801068e7:	74 6a                	je     80106953 <trap+0x128>
801068e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068ec:	8b 40 0c             	mov    0xc(%eax),%eax
801068ef:	83 f8 04             	cmp    $0x4,%eax
801068f2:	75 5f                	jne    80106953 <trap+0x128>
      int idx = myproc() - ptable.proc;
801068f4:	e8 37 d1 ff ff       	call   80103a30 <myproc>
801068f9:	2d 34 4e 19 80       	sub    $0x80194e34,%eax
801068fe:	c1 f8 02             	sar    $0x2,%eax
80106901:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
80106907:	89 45 e0             	mov    %eax,-0x20(%ebp)
      int q = kernel_pstat.priority[idx];
8010690a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010690d:	83 e8 80             	sub    $0xffffff80,%eax
80106910:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80106917:	89 45 dc             	mov    %eax,-0x24(%ebp)
      kernel_pstat.ticks[idx][q]++;  //  실제 실행 시간 증가
8010691a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010691d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106924:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106927:	01 d0                	add    %edx,%eax
80106929:	05 00 01 00 00       	add    $0x100,%eax
8010692e:	8b 04 85 00 42 19 80 	mov    -0x7fe6be00(,%eax,4),%eax
80106935:	8d 50 01             	lea    0x1(%eax),%edx
80106938:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010693b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80106942:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106945:	01 c8                	add    %ecx,%eax
80106947:	05 00 01 00 00       	add    $0x100,%eax
8010694c:	89 14 85 00 42 19 80 	mov    %edx,-0x7fe6be00(,%eax,4)
      //cprintf("[TIMER] PID %d ticked on Q%d, total = %d\n",myproc()->pid, q, kernel_pstat.ticks[idx][q]);
    }

    lapiceoi();
80106953:	e8 c6 c1 ff ff       	call   80102b1e <lapiceoi>
    break;
80106958:	e9 20 01 00 00       	jmp    80106a7d <trap+0x252>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010695d:	e8 da 3e 00 00       	call   8010a83c <ideintr>
    lapiceoi();
80106962:	e8 b7 c1 ff ff       	call   80102b1e <lapiceoi>
    break;
80106967:	e9 11 01 00 00       	jmp    80106a7d <trap+0x252>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010696c:	e8 f8 bf ff ff       	call   80102969 <kbdintr>
    lapiceoi();
80106971:	e8 a8 c1 ff ff       	call   80102b1e <lapiceoi>
    break;
80106976:	e9 02 01 00 00       	jmp    80106a7d <trap+0x252>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010697b:	e8 51 03 00 00       	call   80106cd1 <uartintr>
    lapiceoi();
80106980:	e8 99 c1 ff ff       	call   80102b1e <lapiceoi>
    break;
80106985:	e9 f3 00 00 00       	jmp    80106a7d <trap+0x252>
  case T_IRQ0 + 0xB:
    i8254_intr();
8010698a:	e8 76 2b 00 00       	call   80109505 <i8254_intr>
    lapiceoi();
8010698f:	e8 8a c1 ff ff       	call   80102b1e <lapiceoi>
    break;
80106994:	e9 e4 00 00 00       	jmp    80106a7d <trap+0x252>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106999:	8b 45 08             	mov    0x8(%ebp),%eax
8010699c:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010699f:	8b 45 08             	mov    0x8(%ebp),%eax
801069a2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801069a6:	0f b7 d8             	movzwl %ax,%ebx
801069a9:	e8 ef cf ff ff       	call   8010399d <cpuid>
801069ae:	56                   	push   %esi
801069af:	53                   	push   %ebx
801069b0:	50                   	push   %eax
801069b1:	68 ec ae 10 80       	push   $0x8010aeec
801069b6:	e8 39 9a ff ff       	call   801003f4 <cprintf>
801069bb:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801069be:	e8 5b c1 ff ff       	call   80102b1e <lapiceoi>
    break;
801069c3:	e9 b5 00 00 00       	jmp    80106a7d <trap+0x252>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801069c8:	e8 63 d0 ff ff       	call   80103a30 <myproc>
801069cd:	85 c0                	test   %eax,%eax
801069cf:	74 11                	je     801069e2 <trap+0x1b7>
801069d1:	8b 45 08             	mov    0x8(%ebp),%eax
801069d4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801069d8:	0f b7 c0             	movzwl %ax,%eax
801069db:	83 e0 03             	and    $0x3,%eax
801069de:	85 c0                	test   %eax,%eax
801069e0:	75 39                	jne    80106a1b <trap+0x1f0>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069e2:	e8 a5 fc ff ff       	call   8010668c <rcr2>
801069e7:	89 c3                	mov    %eax,%ebx
801069e9:	8b 45 08             	mov    0x8(%ebp),%eax
801069ec:	8b 70 38             	mov    0x38(%eax),%esi
801069ef:	e8 a9 cf ff ff       	call   8010399d <cpuid>
801069f4:	8b 55 08             	mov    0x8(%ebp),%edx
801069f7:	8b 52 30             	mov    0x30(%edx),%edx
801069fa:	83 ec 0c             	sub    $0xc,%esp
801069fd:	53                   	push   %ebx
801069fe:	56                   	push   %esi
801069ff:	50                   	push   %eax
80106a00:	52                   	push   %edx
80106a01:	68 10 af 10 80       	push   $0x8010af10
80106a06:	e8 e9 99 ff ff       	call   801003f4 <cprintf>
80106a0b:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106a0e:	83 ec 0c             	sub    $0xc,%esp
80106a11:	68 42 af 10 80       	push   $0x8010af42
80106a16:	e8 8e 9b ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a1b:	e8 6c fc ff ff       	call   8010668c <rcr2>
80106a20:	89 c6                	mov    %eax,%esi
80106a22:	8b 45 08             	mov    0x8(%ebp),%eax
80106a25:	8b 40 38             	mov    0x38(%eax),%eax
80106a28:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106a2b:	e8 6d cf ff ff       	call   8010399d <cpuid>
80106a30:	89 c3                	mov    %eax,%ebx
80106a32:	8b 45 08             	mov    0x8(%ebp),%eax
80106a35:	8b 48 34             	mov    0x34(%eax),%ecx
80106a38:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106a3b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a3e:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106a41:	e8 ea cf ff ff       	call   80103a30 <myproc>
80106a46:	8d 50 6c             	lea    0x6c(%eax),%edx
80106a49:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106a4c:	e8 df cf ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a51:	8b 40 10             	mov    0x10(%eax),%eax
80106a54:	56                   	push   %esi
80106a55:	ff 75 d4             	push   -0x2c(%ebp)
80106a58:	53                   	push   %ebx
80106a59:	ff 75 d0             	push   -0x30(%ebp)
80106a5c:	57                   	push   %edi
80106a5d:	ff 75 cc             	push   -0x34(%ebp)
80106a60:	50                   	push   %eax
80106a61:	68 48 af 10 80       	push   $0x8010af48
80106a66:	e8 89 99 ff ff       	call   801003f4 <cprintf>
80106a6b:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106a6e:	e8 bd cf ff ff       	call   80103a30 <myproc>
80106a73:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106a7a:	eb 01                	jmp    80106a7d <trap+0x252>
    break;
80106a7c:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106a7d:	e8 ae cf ff ff       	call   80103a30 <myproc>
80106a82:	85 c0                	test   %eax,%eax
80106a84:	74 23                	je     80106aa9 <trap+0x27e>
80106a86:	e8 a5 cf ff ff       	call   80103a30 <myproc>
80106a8b:	8b 40 24             	mov    0x24(%eax),%eax
80106a8e:	85 c0                	test   %eax,%eax
80106a90:	74 17                	je     80106aa9 <trap+0x27e>
80106a92:	8b 45 08             	mov    0x8(%ebp),%eax
80106a95:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a99:	0f b7 c0             	movzwl %ax,%eax
80106a9c:	83 e0 03             	and    $0x3,%eax
80106a9f:	83 f8 03             	cmp    $0x3,%eax
80106aa2:	75 05                	jne    80106aa9 <trap+0x27e>
    exit();
80106aa4:	e8 f1 d4 ff ff       	call   80103f9a <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106aa9:	e8 82 cf ff ff       	call   80103a30 <myproc>
80106aae:	85 c0                	test   %eax,%eax
80106ab0:	74 1d                	je     80106acf <trap+0x2a4>
80106ab2:	e8 79 cf ff ff       	call   80103a30 <myproc>
80106ab7:	8b 40 0c             	mov    0xc(%eax),%eax
80106aba:	83 f8 04             	cmp    $0x4,%eax
80106abd:	75 10                	jne    80106acf <trap+0x2a4>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106abf:	8b 45 08             	mov    0x8(%ebp),%eax
80106ac2:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106ac5:	83 f8 20             	cmp    $0x20,%eax
80106ac8:	75 05                	jne    80106acf <trap+0x2a4>
    yield();
80106aca:	e8 34 d9 ff ff       	call   80104403 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106acf:	e8 5c cf ff ff       	call   80103a30 <myproc>
80106ad4:	85 c0                	test   %eax,%eax
80106ad6:	74 26                	je     80106afe <trap+0x2d3>
80106ad8:	e8 53 cf ff ff       	call   80103a30 <myproc>
80106add:	8b 40 24             	mov    0x24(%eax),%eax
80106ae0:	85 c0                	test   %eax,%eax
80106ae2:	74 1a                	je     80106afe <trap+0x2d3>
80106ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80106ae7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106aeb:	0f b7 c0             	movzwl %ax,%eax
80106aee:	83 e0 03             	and    $0x3,%eax
80106af1:	83 f8 03             	cmp    $0x3,%eax
80106af4:	75 08                	jne    80106afe <trap+0x2d3>
    exit();
80106af6:	e8 9f d4 ff ff       	call   80103f9a <exit>
80106afb:	eb 01                	jmp    80106afe <trap+0x2d3>
    return;
80106afd:	90                   	nop
}
80106afe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b01:	5b                   	pop    %ebx
80106b02:	5e                   	pop    %esi
80106b03:	5f                   	pop    %edi
80106b04:	5d                   	pop    %ebp
80106b05:	c3                   	ret

80106b06 <inb>:
{
80106b06:	55                   	push   %ebp
80106b07:	89 e5                	mov    %esp,%ebp
80106b09:	83 ec 14             	sub    $0x14,%esp
80106b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80106b0f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106b13:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106b17:	89 c2                	mov    %eax,%edx
80106b19:	ec                   	in     (%dx),%al
80106b1a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106b1d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106b21:	c9                   	leave
80106b22:	c3                   	ret

80106b23 <outb>:
{
80106b23:	55                   	push   %ebp
80106b24:	89 e5                	mov    %esp,%ebp
80106b26:	83 ec 08             	sub    $0x8,%esp
80106b29:	8b 55 08             	mov    0x8(%ebp),%edx
80106b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b2f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106b33:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b36:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106b3a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106b3e:	ee                   	out    %al,(%dx)
}
80106b3f:	90                   	nop
80106b40:	c9                   	leave
80106b41:	c3                   	ret

80106b42 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106b42:	55                   	push   %ebp
80106b43:	89 e5                	mov    %esp,%ebp
80106b45:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106b48:	6a 00                	push   $0x0
80106b4a:	68 fa 03 00 00       	push   $0x3fa
80106b4f:	e8 cf ff ff ff       	call   80106b23 <outb>
80106b54:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106b57:	68 80 00 00 00       	push   $0x80
80106b5c:	68 fb 03 00 00       	push   $0x3fb
80106b61:	e8 bd ff ff ff       	call   80106b23 <outb>
80106b66:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106b69:	6a 0c                	push   $0xc
80106b6b:	68 f8 03 00 00       	push   $0x3f8
80106b70:	e8 ae ff ff ff       	call   80106b23 <outb>
80106b75:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106b78:	6a 00                	push   $0x0
80106b7a:	68 f9 03 00 00       	push   $0x3f9
80106b7f:	e8 9f ff ff ff       	call   80106b23 <outb>
80106b84:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106b87:	6a 03                	push   $0x3
80106b89:	68 fb 03 00 00       	push   $0x3fb
80106b8e:	e8 90 ff ff ff       	call   80106b23 <outb>
80106b93:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106b96:	6a 00                	push   $0x0
80106b98:	68 fc 03 00 00       	push   $0x3fc
80106b9d:	e8 81 ff ff ff       	call   80106b23 <outb>
80106ba2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106ba5:	6a 01                	push   $0x1
80106ba7:	68 f9 03 00 00       	push   $0x3f9
80106bac:	e8 72 ff ff ff       	call   80106b23 <outb>
80106bb1:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106bb4:	68 fd 03 00 00       	push   $0x3fd
80106bb9:	e8 48 ff ff ff       	call   80106b06 <inb>
80106bbe:	83 c4 04             	add    $0x4,%esp
80106bc1:	3c ff                	cmp    $0xff,%al
80106bc3:	74 61                	je     80106c26 <uartinit+0xe4>
    return;
  uart = 1;
80106bc5:	c7 05 b8 79 19 80 01 	movl   $0x1,0x801979b8
80106bcc:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106bcf:	68 fa 03 00 00       	push   $0x3fa
80106bd4:	e8 2d ff ff ff       	call   80106b06 <inb>
80106bd9:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106bdc:	68 f8 03 00 00       	push   $0x3f8
80106be1:	e8 20 ff ff ff       	call   80106b06 <inb>
80106be6:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106be9:	83 ec 08             	sub    $0x8,%esp
80106bec:	6a 00                	push   $0x0
80106bee:	6a 04                	push   $0x4
80106bf0:	e8 41 ba ff ff       	call   80102636 <ioapicenable>
80106bf5:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106bf8:	c7 45 f4 0c b0 10 80 	movl   $0x8010b00c,-0xc(%ebp)
80106bff:	eb 19                	jmp    80106c1a <uartinit+0xd8>
    uartputc(*p);
80106c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c04:	0f b6 00             	movzbl (%eax),%eax
80106c07:	0f be c0             	movsbl %al,%eax
80106c0a:	83 ec 0c             	sub    $0xc,%esp
80106c0d:	50                   	push   %eax
80106c0e:	e8 16 00 00 00       	call   80106c29 <uartputc>
80106c13:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106c16:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c1d:	0f b6 00             	movzbl (%eax),%eax
80106c20:	84 c0                	test   %al,%al
80106c22:	75 dd                	jne    80106c01 <uartinit+0xbf>
80106c24:	eb 01                	jmp    80106c27 <uartinit+0xe5>
    return;
80106c26:	90                   	nop
}
80106c27:	c9                   	leave
80106c28:	c3                   	ret

80106c29 <uartputc>:

void
uartputc(int c)
{
80106c29:	55                   	push   %ebp
80106c2a:	89 e5                	mov    %esp,%ebp
80106c2c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106c2f:	a1 b8 79 19 80       	mov    0x801979b8,%eax
80106c34:	85 c0                	test   %eax,%eax
80106c36:	74 53                	je     80106c8b <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c38:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c3f:	eb 11                	jmp    80106c52 <uartputc+0x29>
    microdelay(10);
80106c41:	83 ec 0c             	sub    $0xc,%esp
80106c44:	6a 0a                	push   $0xa
80106c46:	e8 ee be ff ff       	call   80102b39 <microdelay>
80106c4b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c4e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c52:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106c56:	7f 1a                	jg     80106c72 <uartputc+0x49>
80106c58:	83 ec 0c             	sub    $0xc,%esp
80106c5b:	68 fd 03 00 00       	push   $0x3fd
80106c60:	e8 a1 fe ff ff       	call   80106b06 <inb>
80106c65:	83 c4 10             	add    $0x10,%esp
80106c68:	0f b6 c0             	movzbl %al,%eax
80106c6b:	83 e0 20             	and    $0x20,%eax
80106c6e:	85 c0                	test   %eax,%eax
80106c70:	74 cf                	je     80106c41 <uartputc+0x18>
  outb(COM1+0, c);
80106c72:	8b 45 08             	mov    0x8(%ebp),%eax
80106c75:	0f b6 c0             	movzbl %al,%eax
80106c78:	83 ec 08             	sub    $0x8,%esp
80106c7b:	50                   	push   %eax
80106c7c:	68 f8 03 00 00       	push   $0x3f8
80106c81:	e8 9d fe ff ff       	call   80106b23 <outb>
80106c86:	83 c4 10             	add    $0x10,%esp
80106c89:	eb 01                	jmp    80106c8c <uartputc+0x63>
    return;
80106c8b:	90                   	nop
}
80106c8c:	c9                   	leave
80106c8d:	c3                   	ret

80106c8e <uartgetc>:

static int
uartgetc(void)
{
80106c8e:	55                   	push   %ebp
80106c8f:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106c91:	a1 b8 79 19 80       	mov    0x801979b8,%eax
80106c96:	85 c0                	test   %eax,%eax
80106c98:	75 07                	jne    80106ca1 <uartgetc+0x13>
    return -1;
80106c9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c9f:	eb 2e                	jmp    80106ccf <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106ca1:	68 fd 03 00 00       	push   $0x3fd
80106ca6:	e8 5b fe ff ff       	call   80106b06 <inb>
80106cab:	83 c4 04             	add    $0x4,%esp
80106cae:	0f b6 c0             	movzbl %al,%eax
80106cb1:	83 e0 01             	and    $0x1,%eax
80106cb4:	85 c0                	test   %eax,%eax
80106cb6:	75 07                	jne    80106cbf <uartgetc+0x31>
    return -1;
80106cb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cbd:	eb 10                	jmp    80106ccf <uartgetc+0x41>
  return inb(COM1+0);
80106cbf:	68 f8 03 00 00       	push   $0x3f8
80106cc4:	e8 3d fe ff ff       	call   80106b06 <inb>
80106cc9:	83 c4 04             	add    $0x4,%esp
80106ccc:	0f b6 c0             	movzbl %al,%eax
}
80106ccf:	c9                   	leave
80106cd0:	c3                   	ret

80106cd1 <uartintr>:

void
uartintr(void)
{
80106cd1:	55                   	push   %ebp
80106cd2:	89 e5                	mov    %esp,%ebp
80106cd4:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106cd7:	83 ec 0c             	sub    $0xc,%esp
80106cda:	68 8e 6c 10 80       	push   $0x80106c8e
80106cdf:	e8 f2 9a ff ff       	call   801007d6 <consoleintr>
80106ce4:	83 c4 10             	add    $0x10,%esp
}
80106ce7:	90                   	nop
80106ce8:	c9                   	leave
80106ce9:	c3                   	ret

80106cea <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106cea:	6a 00                	push   $0x0
  pushl $0
80106cec:	6a 00                	push   $0x0
  jmp alltraps
80106cee:	e9 4c f9 ff ff       	jmp    8010663f <alltraps>

80106cf3 <vector1>:
.globl vector1
vector1:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $1
80106cf5:	6a 01                	push   $0x1
  jmp alltraps
80106cf7:	e9 43 f9 ff ff       	jmp    8010663f <alltraps>

80106cfc <vector2>:
.globl vector2
vector2:
  pushl $0
80106cfc:	6a 00                	push   $0x0
  pushl $2
80106cfe:	6a 02                	push   $0x2
  jmp alltraps
80106d00:	e9 3a f9 ff ff       	jmp    8010663f <alltraps>

80106d05 <vector3>:
.globl vector3
vector3:
  pushl $0
80106d05:	6a 00                	push   $0x0
  pushl $3
80106d07:	6a 03                	push   $0x3
  jmp alltraps
80106d09:	e9 31 f9 ff ff       	jmp    8010663f <alltraps>

80106d0e <vector4>:
.globl vector4
vector4:
  pushl $0
80106d0e:	6a 00                	push   $0x0
  pushl $4
80106d10:	6a 04                	push   $0x4
  jmp alltraps
80106d12:	e9 28 f9 ff ff       	jmp    8010663f <alltraps>

80106d17 <vector5>:
.globl vector5
vector5:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $5
80106d19:	6a 05                	push   $0x5
  jmp alltraps
80106d1b:	e9 1f f9 ff ff       	jmp    8010663f <alltraps>

80106d20 <vector6>:
.globl vector6
vector6:
  pushl $0
80106d20:	6a 00                	push   $0x0
  pushl $6
80106d22:	6a 06                	push   $0x6
  jmp alltraps
80106d24:	e9 16 f9 ff ff       	jmp    8010663f <alltraps>

80106d29 <vector7>:
.globl vector7
vector7:
  pushl $0
80106d29:	6a 00                	push   $0x0
  pushl $7
80106d2b:	6a 07                	push   $0x7
  jmp alltraps
80106d2d:	e9 0d f9 ff ff       	jmp    8010663f <alltraps>

80106d32 <vector8>:
.globl vector8
vector8:
  pushl $8
80106d32:	6a 08                	push   $0x8
  jmp alltraps
80106d34:	e9 06 f9 ff ff       	jmp    8010663f <alltraps>

80106d39 <vector9>:
.globl vector9
vector9:
  pushl $0
80106d39:	6a 00                	push   $0x0
  pushl $9
80106d3b:	6a 09                	push   $0x9
  jmp alltraps
80106d3d:	e9 fd f8 ff ff       	jmp    8010663f <alltraps>

80106d42 <vector10>:
.globl vector10
vector10:
  pushl $10
80106d42:	6a 0a                	push   $0xa
  jmp alltraps
80106d44:	e9 f6 f8 ff ff       	jmp    8010663f <alltraps>

80106d49 <vector11>:
.globl vector11
vector11:
  pushl $11
80106d49:	6a 0b                	push   $0xb
  jmp alltraps
80106d4b:	e9 ef f8 ff ff       	jmp    8010663f <alltraps>

80106d50 <vector12>:
.globl vector12
vector12:
  pushl $12
80106d50:	6a 0c                	push   $0xc
  jmp alltraps
80106d52:	e9 e8 f8 ff ff       	jmp    8010663f <alltraps>

80106d57 <vector13>:
.globl vector13
vector13:
  pushl $13
80106d57:	6a 0d                	push   $0xd
  jmp alltraps
80106d59:	e9 e1 f8 ff ff       	jmp    8010663f <alltraps>

80106d5e <vector14>:
.globl vector14
vector14:
  pushl $14
80106d5e:	6a 0e                	push   $0xe
  jmp alltraps
80106d60:	e9 da f8 ff ff       	jmp    8010663f <alltraps>

80106d65 <vector15>:
.globl vector15
vector15:
  pushl $0
80106d65:	6a 00                	push   $0x0
  pushl $15
80106d67:	6a 0f                	push   $0xf
  jmp alltraps
80106d69:	e9 d1 f8 ff ff       	jmp    8010663f <alltraps>

80106d6e <vector16>:
.globl vector16
vector16:
  pushl $0
80106d6e:	6a 00                	push   $0x0
  pushl $16
80106d70:	6a 10                	push   $0x10
  jmp alltraps
80106d72:	e9 c8 f8 ff ff       	jmp    8010663f <alltraps>

80106d77 <vector17>:
.globl vector17
vector17:
  pushl $17
80106d77:	6a 11                	push   $0x11
  jmp alltraps
80106d79:	e9 c1 f8 ff ff       	jmp    8010663f <alltraps>

80106d7e <vector18>:
.globl vector18
vector18:
  pushl $0
80106d7e:	6a 00                	push   $0x0
  pushl $18
80106d80:	6a 12                	push   $0x12
  jmp alltraps
80106d82:	e9 b8 f8 ff ff       	jmp    8010663f <alltraps>

80106d87 <vector19>:
.globl vector19
vector19:
  pushl $0
80106d87:	6a 00                	push   $0x0
  pushl $19
80106d89:	6a 13                	push   $0x13
  jmp alltraps
80106d8b:	e9 af f8 ff ff       	jmp    8010663f <alltraps>

80106d90 <vector20>:
.globl vector20
vector20:
  pushl $0
80106d90:	6a 00                	push   $0x0
  pushl $20
80106d92:	6a 14                	push   $0x14
  jmp alltraps
80106d94:	e9 a6 f8 ff ff       	jmp    8010663f <alltraps>

80106d99 <vector21>:
.globl vector21
vector21:
  pushl $0
80106d99:	6a 00                	push   $0x0
  pushl $21
80106d9b:	6a 15                	push   $0x15
  jmp alltraps
80106d9d:	e9 9d f8 ff ff       	jmp    8010663f <alltraps>

80106da2 <vector22>:
.globl vector22
vector22:
  pushl $0
80106da2:	6a 00                	push   $0x0
  pushl $22
80106da4:	6a 16                	push   $0x16
  jmp alltraps
80106da6:	e9 94 f8 ff ff       	jmp    8010663f <alltraps>

80106dab <vector23>:
.globl vector23
vector23:
  pushl $0
80106dab:	6a 00                	push   $0x0
  pushl $23
80106dad:	6a 17                	push   $0x17
  jmp alltraps
80106daf:	e9 8b f8 ff ff       	jmp    8010663f <alltraps>

80106db4 <vector24>:
.globl vector24
vector24:
  pushl $0
80106db4:	6a 00                	push   $0x0
  pushl $24
80106db6:	6a 18                	push   $0x18
  jmp alltraps
80106db8:	e9 82 f8 ff ff       	jmp    8010663f <alltraps>

80106dbd <vector25>:
.globl vector25
vector25:
  pushl $0
80106dbd:	6a 00                	push   $0x0
  pushl $25
80106dbf:	6a 19                	push   $0x19
  jmp alltraps
80106dc1:	e9 79 f8 ff ff       	jmp    8010663f <alltraps>

80106dc6 <vector26>:
.globl vector26
vector26:
  pushl $0
80106dc6:	6a 00                	push   $0x0
  pushl $26
80106dc8:	6a 1a                	push   $0x1a
  jmp alltraps
80106dca:	e9 70 f8 ff ff       	jmp    8010663f <alltraps>

80106dcf <vector27>:
.globl vector27
vector27:
  pushl $0
80106dcf:	6a 00                	push   $0x0
  pushl $27
80106dd1:	6a 1b                	push   $0x1b
  jmp alltraps
80106dd3:	e9 67 f8 ff ff       	jmp    8010663f <alltraps>

80106dd8 <vector28>:
.globl vector28
vector28:
  pushl $0
80106dd8:	6a 00                	push   $0x0
  pushl $28
80106dda:	6a 1c                	push   $0x1c
  jmp alltraps
80106ddc:	e9 5e f8 ff ff       	jmp    8010663f <alltraps>

80106de1 <vector29>:
.globl vector29
vector29:
  pushl $0
80106de1:	6a 00                	push   $0x0
  pushl $29
80106de3:	6a 1d                	push   $0x1d
  jmp alltraps
80106de5:	e9 55 f8 ff ff       	jmp    8010663f <alltraps>

80106dea <vector30>:
.globl vector30
vector30:
  pushl $0
80106dea:	6a 00                	push   $0x0
  pushl $30
80106dec:	6a 1e                	push   $0x1e
  jmp alltraps
80106dee:	e9 4c f8 ff ff       	jmp    8010663f <alltraps>

80106df3 <vector31>:
.globl vector31
vector31:
  pushl $0
80106df3:	6a 00                	push   $0x0
  pushl $31
80106df5:	6a 1f                	push   $0x1f
  jmp alltraps
80106df7:	e9 43 f8 ff ff       	jmp    8010663f <alltraps>

80106dfc <vector32>:
.globl vector32
vector32:
  pushl $0
80106dfc:	6a 00                	push   $0x0
  pushl $32
80106dfe:	6a 20                	push   $0x20
  jmp alltraps
80106e00:	e9 3a f8 ff ff       	jmp    8010663f <alltraps>

80106e05 <vector33>:
.globl vector33
vector33:
  pushl $0
80106e05:	6a 00                	push   $0x0
  pushl $33
80106e07:	6a 21                	push   $0x21
  jmp alltraps
80106e09:	e9 31 f8 ff ff       	jmp    8010663f <alltraps>

80106e0e <vector34>:
.globl vector34
vector34:
  pushl $0
80106e0e:	6a 00                	push   $0x0
  pushl $34
80106e10:	6a 22                	push   $0x22
  jmp alltraps
80106e12:	e9 28 f8 ff ff       	jmp    8010663f <alltraps>

80106e17 <vector35>:
.globl vector35
vector35:
  pushl $0
80106e17:	6a 00                	push   $0x0
  pushl $35
80106e19:	6a 23                	push   $0x23
  jmp alltraps
80106e1b:	e9 1f f8 ff ff       	jmp    8010663f <alltraps>

80106e20 <vector36>:
.globl vector36
vector36:
  pushl $0
80106e20:	6a 00                	push   $0x0
  pushl $36
80106e22:	6a 24                	push   $0x24
  jmp alltraps
80106e24:	e9 16 f8 ff ff       	jmp    8010663f <alltraps>

80106e29 <vector37>:
.globl vector37
vector37:
  pushl $0
80106e29:	6a 00                	push   $0x0
  pushl $37
80106e2b:	6a 25                	push   $0x25
  jmp alltraps
80106e2d:	e9 0d f8 ff ff       	jmp    8010663f <alltraps>

80106e32 <vector38>:
.globl vector38
vector38:
  pushl $0
80106e32:	6a 00                	push   $0x0
  pushl $38
80106e34:	6a 26                	push   $0x26
  jmp alltraps
80106e36:	e9 04 f8 ff ff       	jmp    8010663f <alltraps>

80106e3b <vector39>:
.globl vector39
vector39:
  pushl $0
80106e3b:	6a 00                	push   $0x0
  pushl $39
80106e3d:	6a 27                	push   $0x27
  jmp alltraps
80106e3f:	e9 fb f7 ff ff       	jmp    8010663f <alltraps>

80106e44 <vector40>:
.globl vector40
vector40:
  pushl $0
80106e44:	6a 00                	push   $0x0
  pushl $40
80106e46:	6a 28                	push   $0x28
  jmp alltraps
80106e48:	e9 f2 f7 ff ff       	jmp    8010663f <alltraps>

80106e4d <vector41>:
.globl vector41
vector41:
  pushl $0
80106e4d:	6a 00                	push   $0x0
  pushl $41
80106e4f:	6a 29                	push   $0x29
  jmp alltraps
80106e51:	e9 e9 f7 ff ff       	jmp    8010663f <alltraps>

80106e56 <vector42>:
.globl vector42
vector42:
  pushl $0
80106e56:	6a 00                	push   $0x0
  pushl $42
80106e58:	6a 2a                	push   $0x2a
  jmp alltraps
80106e5a:	e9 e0 f7 ff ff       	jmp    8010663f <alltraps>

80106e5f <vector43>:
.globl vector43
vector43:
  pushl $0
80106e5f:	6a 00                	push   $0x0
  pushl $43
80106e61:	6a 2b                	push   $0x2b
  jmp alltraps
80106e63:	e9 d7 f7 ff ff       	jmp    8010663f <alltraps>

80106e68 <vector44>:
.globl vector44
vector44:
  pushl $0
80106e68:	6a 00                	push   $0x0
  pushl $44
80106e6a:	6a 2c                	push   $0x2c
  jmp alltraps
80106e6c:	e9 ce f7 ff ff       	jmp    8010663f <alltraps>

80106e71 <vector45>:
.globl vector45
vector45:
  pushl $0
80106e71:	6a 00                	push   $0x0
  pushl $45
80106e73:	6a 2d                	push   $0x2d
  jmp alltraps
80106e75:	e9 c5 f7 ff ff       	jmp    8010663f <alltraps>

80106e7a <vector46>:
.globl vector46
vector46:
  pushl $0
80106e7a:	6a 00                	push   $0x0
  pushl $46
80106e7c:	6a 2e                	push   $0x2e
  jmp alltraps
80106e7e:	e9 bc f7 ff ff       	jmp    8010663f <alltraps>

80106e83 <vector47>:
.globl vector47
vector47:
  pushl $0
80106e83:	6a 00                	push   $0x0
  pushl $47
80106e85:	6a 2f                	push   $0x2f
  jmp alltraps
80106e87:	e9 b3 f7 ff ff       	jmp    8010663f <alltraps>

80106e8c <vector48>:
.globl vector48
vector48:
  pushl $0
80106e8c:	6a 00                	push   $0x0
  pushl $48
80106e8e:	6a 30                	push   $0x30
  jmp alltraps
80106e90:	e9 aa f7 ff ff       	jmp    8010663f <alltraps>

80106e95 <vector49>:
.globl vector49
vector49:
  pushl $0
80106e95:	6a 00                	push   $0x0
  pushl $49
80106e97:	6a 31                	push   $0x31
  jmp alltraps
80106e99:	e9 a1 f7 ff ff       	jmp    8010663f <alltraps>

80106e9e <vector50>:
.globl vector50
vector50:
  pushl $0
80106e9e:	6a 00                	push   $0x0
  pushl $50
80106ea0:	6a 32                	push   $0x32
  jmp alltraps
80106ea2:	e9 98 f7 ff ff       	jmp    8010663f <alltraps>

80106ea7 <vector51>:
.globl vector51
vector51:
  pushl $0
80106ea7:	6a 00                	push   $0x0
  pushl $51
80106ea9:	6a 33                	push   $0x33
  jmp alltraps
80106eab:	e9 8f f7 ff ff       	jmp    8010663f <alltraps>

80106eb0 <vector52>:
.globl vector52
vector52:
  pushl $0
80106eb0:	6a 00                	push   $0x0
  pushl $52
80106eb2:	6a 34                	push   $0x34
  jmp alltraps
80106eb4:	e9 86 f7 ff ff       	jmp    8010663f <alltraps>

80106eb9 <vector53>:
.globl vector53
vector53:
  pushl $0
80106eb9:	6a 00                	push   $0x0
  pushl $53
80106ebb:	6a 35                	push   $0x35
  jmp alltraps
80106ebd:	e9 7d f7 ff ff       	jmp    8010663f <alltraps>

80106ec2 <vector54>:
.globl vector54
vector54:
  pushl $0
80106ec2:	6a 00                	push   $0x0
  pushl $54
80106ec4:	6a 36                	push   $0x36
  jmp alltraps
80106ec6:	e9 74 f7 ff ff       	jmp    8010663f <alltraps>

80106ecb <vector55>:
.globl vector55
vector55:
  pushl $0
80106ecb:	6a 00                	push   $0x0
  pushl $55
80106ecd:	6a 37                	push   $0x37
  jmp alltraps
80106ecf:	e9 6b f7 ff ff       	jmp    8010663f <alltraps>

80106ed4 <vector56>:
.globl vector56
vector56:
  pushl $0
80106ed4:	6a 00                	push   $0x0
  pushl $56
80106ed6:	6a 38                	push   $0x38
  jmp alltraps
80106ed8:	e9 62 f7 ff ff       	jmp    8010663f <alltraps>

80106edd <vector57>:
.globl vector57
vector57:
  pushl $0
80106edd:	6a 00                	push   $0x0
  pushl $57
80106edf:	6a 39                	push   $0x39
  jmp alltraps
80106ee1:	e9 59 f7 ff ff       	jmp    8010663f <alltraps>

80106ee6 <vector58>:
.globl vector58
vector58:
  pushl $0
80106ee6:	6a 00                	push   $0x0
  pushl $58
80106ee8:	6a 3a                	push   $0x3a
  jmp alltraps
80106eea:	e9 50 f7 ff ff       	jmp    8010663f <alltraps>

80106eef <vector59>:
.globl vector59
vector59:
  pushl $0
80106eef:	6a 00                	push   $0x0
  pushl $59
80106ef1:	6a 3b                	push   $0x3b
  jmp alltraps
80106ef3:	e9 47 f7 ff ff       	jmp    8010663f <alltraps>

80106ef8 <vector60>:
.globl vector60
vector60:
  pushl $0
80106ef8:	6a 00                	push   $0x0
  pushl $60
80106efa:	6a 3c                	push   $0x3c
  jmp alltraps
80106efc:	e9 3e f7 ff ff       	jmp    8010663f <alltraps>

80106f01 <vector61>:
.globl vector61
vector61:
  pushl $0
80106f01:	6a 00                	push   $0x0
  pushl $61
80106f03:	6a 3d                	push   $0x3d
  jmp alltraps
80106f05:	e9 35 f7 ff ff       	jmp    8010663f <alltraps>

80106f0a <vector62>:
.globl vector62
vector62:
  pushl $0
80106f0a:	6a 00                	push   $0x0
  pushl $62
80106f0c:	6a 3e                	push   $0x3e
  jmp alltraps
80106f0e:	e9 2c f7 ff ff       	jmp    8010663f <alltraps>

80106f13 <vector63>:
.globl vector63
vector63:
  pushl $0
80106f13:	6a 00                	push   $0x0
  pushl $63
80106f15:	6a 3f                	push   $0x3f
  jmp alltraps
80106f17:	e9 23 f7 ff ff       	jmp    8010663f <alltraps>

80106f1c <vector64>:
.globl vector64
vector64:
  pushl $0
80106f1c:	6a 00                	push   $0x0
  pushl $64
80106f1e:	6a 40                	push   $0x40
  jmp alltraps
80106f20:	e9 1a f7 ff ff       	jmp    8010663f <alltraps>

80106f25 <vector65>:
.globl vector65
vector65:
  pushl $0
80106f25:	6a 00                	push   $0x0
  pushl $65
80106f27:	6a 41                	push   $0x41
  jmp alltraps
80106f29:	e9 11 f7 ff ff       	jmp    8010663f <alltraps>

80106f2e <vector66>:
.globl vector66
vector66:
  pushl $0
80106f2e:	6a 00                	push   $0x0
  pushl $66
80106f30:	6a 42                	push   $0x42
  jmp alltraps
80106f32:	e9 08 f7 ff ff       	jmp    8010663f <alltraps>

80106f37 <vector67>:
.globl vector67
vector67:
  pushl $0
80106f37:	6a 00                	push   $0x0
  pushl $67
80106f39:	6a 43                	push   $0x43
  jmp alltraps
80106f3b:	e9 ff f6 ff ff       	jmp    8010663f <alltraps>

80106f40 <vector68>:
.globl vector68
vector68:
  pushl $0
80106f40:	6a 00                	push   $0x0
  pushl $68
80106f42:	6a 44                	push   $0x44
  jmp alltraps
80106f44:	e9 f6 f6 ff ff       	jmp    8010663f <alltraps>

80106f49 <vector69>:
.globl vector69
vector69:
  pushl $0
80106f49:	6a 00                	push   $0x0
  pushl $69
80106f4b:	6a 45                	push   $0x45
  jmp alltraps
80106f4d:	e9 ed f6 ff ff       	jmp    8010663f <alltraps>

80106f52 <vector70>:
.globl vector70
vector70:
  pushl $0
80106f52:	6a 00                	push   $0x0
  pushl $70
80106f54:	6a 46                	push   $0x46
  jmp alltraps
80106f56:	e9 e4 f6 ff ff       	jmp    8010663f <alltraps>

80106f5b <vector71>:
.globl vector71
vector71:
  pushl $0
80106f5b:	6a 00                	push   $0x0
  pushl $71
80106f5d:	6a 47                	push   $0x47
  jmp alltraps
80106f5f:	e9 db f6 ff ff       	jmp    8010663f <alltraps>

80106f64 <vector72>:
.globl vector72
vector72:
  pushl $0
80106f64:	6a 00                	push   $0x0
  pushl $72
80106f66:	6a 48                	push   $0x48
  jmp alltraps
80106f68:	e9 d2 f6 ff ff       	jmp    8010663f <alltraps>

80106f6d <vector73>:
.globl vector73
vector73:
  pushl $0
80106f6d:	6a 00                	push   $0x0
  pushl $73
80106f6f:	6a 49                	push   $0x49
  jmp alltraps
80106f71:	e9 c9 f6 ff ff       	jmp    8010663f <alltraps>

80106f76 <vector74>:
.globl vector74
vector74:
  pushl $0
80106f76:	6a 00                	push   $0x0
  pushl $74
80106f78:	6a 4a                	push   $0x4a
  jmp alltraps
80106f7a:	e9 c0 f6 ff ff       	jmp    8010663f <alltraps>

80106f7f <vector75>:
.globl vector75
vector75:
  pushl $0
80106f7f:	6a 00                	push   $0x0
  pushl $75
80106f81:	6a 4b                	push   $0x4b
  jmp alltraps
80106f83:	e9 b7 f6 ff ff       	jmp    8010663f <alltraps>

80106f88 <vector76>:
.globl vector76
vector76:
  pushl $0
80106f88:	6a 00                	push   $0x0
  pushl $76
80106f8a:	6a 4c                	push   $0x4c
  jmp alltraps
80106f8c:	e9 ae f6 ff ff       	jmp    8010663f <alltraps>

80106f91 <vector77>:
.globl vector77
vector77:
  pushl $0
80106f91:	6a 00                	push   $0x0
  pushl $77
80106f93:	6a 4d                	push   $0x4d
  jmp alltraps
80106f95:	e9 a5 f6 ff ff       	jmp    8010663f <alltraps>

80106f9a <vector78>:
.globl vector78
vector78:
  pushl $0
80106f9a:	6a 00                	push   $0x0
  pushl $78
80106f9c:	6a 4e                	push   $0x4e
  jmp alltraps
80106f9e:	e9 9c f6 ff ff       	jmp    8010663f <alltraps>

80106fa3 <vector79>:
.globl vector79
vector79:
  pushl $0
80106fa3:	6a 00                	push   $0x0
  pushl $79
80106fa5:	6a 4f                	push   $0x4f
  jmp alltraps
80106fa7:	e9 93 f6 ff ff       	jmp    8010663f <alltraps>

80106fac <vector80>:
.globl vector80
vector80:
  pushl $0
80106fac:	6a 00                	push   $0x0
  pushl $80
80106fae:	6a 50                	push   $0x50
  jmp alltraps
80106fb0:	e9 8a f6 ff ff       	jmp    8010663f <alltraps>

80106fb5 <vector81>:
.globl vector81
vector81:
  pushl $0
80106fb5:	6a 00                	push   $0x0
  pushl $81
80106fb7:	6a 51                	push   $0x51
  jmp alltraps
80106fb9:	e9 81 f6 ff ff       	jmp    8010663f <alltraps>

80106fbe <vector82>:
.globl vector82
vector82:
  pushl $0
80106fbe:	6a 00                	push   $0x0
  pushl $82
80106fc0:	6a 52                	push   $0x52
  jmp alltraps
80106fc2:	e9 78 f6 ff ff       	jmp    8010663f <alltraps>

80106fc7 <vector83>:
.globl vector83
vector83:
  pushl $0
80106fc7:	6a 00                	push   $0x0
  pushl $83
80106fc9:	6a 53                	push   $0x53
  jmp alltraps
80106fcb:	e9 6f f6 ff ff       	jmp    8010663f <alltraps>

80106fd0 <vector84>:
.globl vector84
vector84:
  pushl $0
80106fd0:	6a 00                	push   $0x0
  pushl $84
80106fd2:	6a 54                	push   $0x54
  jmp alltraps
80106fd4:	e9 66 f6 ff ff       	jmp    8010663f <alltraps>

80106fd9 <vector85>:
.globl vector85
vector85:
  pushl $0
80106fd9:	6a 00                	push   $0x0
  pushl $85
80106fdb:	6a 55                	push   $0x55
  jmp alltraps
80106fdd:	e9 5d f6 ff ff       	jmp    8010663f <alltraps>

80106fe2 <vector86>:
.globl vector86
vector86:
  pushl $0
80106fe2:	6a 00                	push   $0x0
  pushl $86
80106fe4:	6a 56                	push   $0x56
  jmp alltraps
80106fe6:	e9 54 f6 ff ff       	jmp    8010663f <alltraps>

80106feb <vector87>:
.globl vector87
vector87:
  pushl $0
80106feb:	6a 00                	push   $0x0
  pushl $87
80106fed:	6a 57                	push   $0x57
  jmp alltraps
80106fef:	e9 4b f6 ff ff       	jmp    8010663f <alltraps>

80106ff4 <vector88>:
.globl vector88
vector88:
  pushl $0
80106ff4:	6a 00                	push   $0x0
  pushl $88
80106ff6:	6a 58                	push   $0x58
  jmp alltraps
80106ff8:	e9 42 f6 ff ff       	jmp    8010663f <alltraps>

80106ffd <vector89>:
.globl vector89
vector89:
  pushl $0
80106ffd:	6a 00                	push   $0x0
  pushl $89
80106fff:	6a 59                	push   $0x59
  jmp alltraps
80107001:	e9 39 f6 ff ff       	jmp    8010663f <alltraps>

80107006 <vector90>:
.globl vector90
vector90:
  pushl $0
80107006:	6a 00                	push   $0x0
  pushl $90
80107008:	6a 5a                	push   $0x5a
  jmp alltraps
8010700a:	e9 30 f6 ff ff       	jmp    8010663f <alltraps>

8010700f <vector91>:
.globl vector91
vector91:
  pushl $0
8010700f:	6a 00                	push   $0x0
  pushl $91
80107011:	6a 5b                	push   $0x5b
  jmp alltraps
80107013:	e9 27 f6 ff ff       	jmp    8010663f <alltraps>

80107018 <vector92>:
.globl vector92
vector92:
  pushl $0
80107018:	6a 00                	push   $0x0
  pushl $92
8010701a:	6a 5c                	push   $0x5c
  jmp alltraps
8010701c:	e9 1e f6 ff ff       	jmp    8010663f <alltraps>

80107021 <vector93>:
.globl vector93
vector93:
  pushl $0
80107021:	6a 00                	push   $0x0
  pushl $93
80107023:	6a 5d                	push   $0x5d
  jmp alltraps
80107025:	e9 15 f6 ff ff       	jmp    8010663f <alltraps>

8010702a <vector94>:
.globl vector94
vector94:
  pushl $0
8010702a:	6a 00                	push   $0x0
  pushl $94
8010702c:	6a 5e                	push   $0x5e
  jmp alltraps
8010702e:	e9 0c f6 ff ff       	jmp    8010663f <alltraps>

80107033 <vector95>:
.globl vector95
vector95:
  pushl $0
80107033:	6a 00                	push   $0x0
  pushl $95
80107035:	6a 5f                	push   $0x5f
  jmp alltraps
80107037:	e9 03 f6 ff ff       	jmp    8010663f <alltraps>

8010703c <vector96>:
.globl vector96
vector96:
  pushl $0
8010703c:	6a 00                	push   $0x0
  pushl $96
8010703e:	6a 60                	push   $0x60
  jmp alltraps
80107040:	e9 fa f5 ff ff       	jmp    8010663f <alltraps>

80107045 <vector97>:
.globl vector97
vector97:
  pushl $0
80107045:	6a 00                	push   $0x0
  pushl $97
80107047:	6a 61                	push   $0x61
  jmp alltraps
80107049:	e9 f1 f5 ff ff       	jmp    8010663f <alltraps>

8010704e <vector98>:
.globl vector98
vector98:
  pushl $0
8010704e:	6a 00                	push   $0x0
  pushl $98
80107050:	6a 62                	push   $0x62
  jmp alltraps
80107052:	e9 e8 f5 ff ff       	jmp    8010663f <alltraps>

80107057 <vector99>:
.globl vector99
vector99:
  pushl $0
80107057:	6a 00                	push   $0x0
  pushl $99
80107059:	6a 63                	push   $0x63
  jmp alltraps
8010705b:	e9 df f5 ff ff       	jmp    8010663f <alltraps>

80107060 <vector100>:
.globl vector100
vector100:
  pushl $0
80107060:	6a 00                	push   $0x0
  pushl $100
80107062:	6a 64                	push   $0x64
  jmp alltraps
80107064:	e9 d6 f5 ff ff       	jmp    8010663f <alltraps>

80107069 <vector101>:
.globl vector101
vector101:
  pushl $0
80107069:	6a 00                	push   $0x0
  pushl $101
8010706b:	6a 65                	push   $0x65
  jmp alltraps
8010706d:	e9 cd f5 ff ff       	jmp    8010663f <alltraps>

80107072 <vector102>:
.globl vector102
vector102:
  pushl $0
80107072:	6a 00                	push   $0x0
  pushl $102
80107074:	6a 66                	push   $0x66
  jmp alltraps
80107076:	e9 c4 f5 ff ff       	jmp    8010663f <alltraps>

8010707b <vector103>:
.globl vector103
vector103:
  pushl $0
8010707b:	6a 00                	push   $0x0
  pushl $103
8010707d:	6a 67                	push   $0x67
  jmp alltraps
8010707f:	e9 bb f5 ff ff       	jmp    8010663f <alltraps>

80107084 <vector104>:
.globl vector104
vector104:
  pushl $0
80107084:	6a 00                	push   $0x0
  pushl $104
80107086:	6a 68                	push   $0x68
  jmp alltraps
80107088:	e9 b2 f5 ff ff       	jmp    8010663f <alltraps>

8010708d <vector105>:
.globl vector105
vector105:
  pushl $0
8010708d:	6a 00                	push   $0x0
  pushl $105
8010708f:	6a 69                	push   $0x69
  jmp alltraps
80107091:	e9 a9 f5 ff ff       	jmp    8010663f <alltraps>

80107096 <vector106>:
.globl vector106
vector106:
  pushl $0
80107096:	6a 00                	push   $0x0
  pushl $106
80107098:	6a 6a                	push   $0x6a
  jmp alltraps
8010709a:	e9 a0 f5 ff ff       	jmp    8010663f <alltraps>

8010709f <vector107>:
.globl vector107
vector107:
  pushl $0
8010709f:	6a 00                	push   $0x0
  pushl $107
801070a1:	6a 6b                	push   $0x6b
  jmp alltraps
801070a3:	e9 97 f5 ff ff       	jmp    8010663f <alltraps>

801070a8 <vector108>:
.globl vector108
vector108:
  pushl $0
801070a8:	6a 00                	push   $0x0
  pushl $108
801070aa:	6a 6c                	push   $0x6c
  jmp alltraps
801070ac:	e9 8e f5 ff ff       	jmp    8010663f <alltraps>

801070b1 <vector109>:
.globl vector109
vector109:
  pushl $0
801070b1:	6a 00                	push   $0x0
  pushl $109
801070b3:	6a 6d                	push   $0x6d
  jmp alltraps
801070b5:	e9 85 f5 ff ff       	jmp    8010663f <alltraps>

801070ba <vector110>:
.globl vector110
vector110:
  pushl $0
801070ba:	6a 00                	push   $0x0
  pushl $110
801070bc:	6a 6e                	push   $0x6e
  jmp alltraps
801070be:	e9 7c f5 ff ff       	jmp    8010663f <alltraps>

801070c3 <vector111>:
.globl vector111
vector111:
  pushl $0
801070c3:	6a 00                	push   $0x0
  pushl $111
801070c5:	6a 6f                	push   $0x6f
  jmp alltraps
801070c7:	e9 73 f5 ff ff       	jmp    8010663f <alltraps>

801070cc <vector112>:
.globl vector112
vector112:
  pushl $0
801070cc:	6a 00                	push   $0x0
  pushl $112
801070ce:	6a 70                	push   $0x70
  jmp alltraps
801070d0:	e9 6a f5 ff ff       	jmp    8010663f <alltraps>

801070d5 <vector113>:
.globl vector113
vector113:
  pushl $0
801070d5:	6a 00                	push   $0x0
  pushl $113
801070d7:	6a 71                	push   $0x71
  jmp alltraps
801070d9:	e9 61 f5 ff ff       	jmp    8010663f <alltraps>

801070de <vector114>:
.globl vector114
vector114:
  pushl $0
801070de:	6a 00                	push   $0x0
  pushl $114
801070e0:	6a 72                	push   $0x72
  jmp alltraps
801070e2:	e9 58 f5 ff ff       	jmp    8010663f <alltraps>

801070e7 <vector115>:
.globl vector115
vector115:
  pushl $0
801070e7:	6a 00                	push   $0x0
  pushl $115
801070e9:	6a 73                	push   $0x73
  jmp alltraps
801070eb:	e9 4f f5 ff ff       	jmp    8010663f <alltraps>

801070f0 <vector116>:
.globl vector116
vector116:
  pushl $0
801070f0:	6a 00                	push   $0x0
  pushl $116
801070f2:	6a 74                	push   $0x74
  jmp alltraps
801070f4:	e9 46 f5 ff ff       	jmp    8010663f <alltraps>

801070f9 <vector117>:
.globl vector117
vector117:
  pushl $0
801070f9:	6a 00                	push   $0x0
  pushl $117
801070fb:	6a 75                	push   $0x75
  jmp alltraps
801070fd:	e9 3d f5 ff ff       	jmp    8010663f <alltraps>

80107102 <vector118>:
.globl vector118
vector118:
  pushl $0
80107102:	6a 00                	push   $0x0
  pushl $118
80107104:	6a 76                	push   $0x76
  jmp alltraps
80107106:	e9 34 f5 ff ff       	jmp    8010663f <alltraps>

8010710b <vector119>:
.globl vector119
vector119:
  pushl $0
8010710b:	6a 00                	push   $0x0
  pushl $119
8010710d:	6a 77                	push   $0x77
  jmp alltraps
8010710f:	e9 2b f5 ff ff       	jmp    8010663f <alltraps>

80107114 <vector120>:
.globl vector120
vector120:
  pushl $0
80107114:	6a 00                	push   $0x0
  pushl $120
80107116:	6a 78                	push   $0x78
  jmp alltraps
80107118:	e9 22 f5 ff ff       	jmp    8010663f <alltraps>

8010711d <vector121>:
.globl vector121
vector121:
  pushl $0
8010711d:	6a 00                	push   $0x0
  pushl $121
8010711f:	6a 79                	push   $0x79
  jmp alltraps
80107121:	e9 19 f5 ff ff       	jmp    8010663f <alltraps>

80107126 <vector122>:
.globl vector122
vector122:
  pushl $0
80107126:	6a 00                	push   $0x0
  pushl $122
80107128:	6a 7a                	push   $0x7a
  jmp alltraps
8010712a:	e9 10 f5 ff ff       	jmp    8010663f <alltraps>

8010712f <vector123>:
.globl vector123
vector123:
  pushl $0
8010712f:	6a 00                	push   $0x0
  pushl $123
80107131:	6a 7b                	push   $0x7b
  jmp alltraps
80107133:	e9 07 f5 ff ff       	jmp    8010663f <alltraps>

80107138 <vector124>:
.globl vector124
vector124:
  pushl $0
80107138:	6a 00                	push   $0x0
  pushl $124
8010713a:	6a 7c                	push   $0x7c
  jmp alltraps
8010713c:	e9 fe f4 ff ff       	jmp    8010663f <alltraps>

80107141 <vector125>:
.globl vector125
vector125:
  pushl $0
80107141:	6a 00                	push   $0x0
  pushl $125
80107143:	6a 7d                	push   $0x7d
  jmp alltraps
80107145:	e9 f5 f4 ff ff       	jmp    8010663f <alltraps>

8010714a <vector126>:
.globl vector126
vector126:
  pushl $0
8010714a:	6a 00                	push   $0x0
  pushl $126
8010714c:	6a 7e                	push   $0x7e
  jmp alltraps
8010714e:	e9 ec f4 ff ff       	jmp    8010663f <alltraps>

80107153 <vector127>:
.globl vector127
vector127:
  pushl $0
80107153:	6a 00                	push   $0x0
  pushl $127
80107155:	6a 7f                	push   $0x7f
  jmp alltraps
80107157:	e9 e3 f4 ff ff       	jmp    8010663f <alltraps>

8010715c <vector128>:
.globl vector128
vector128:
  pushl $0
8010715c:	6a 00                	push   $0x0
  pushl $128
8010715e:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107163:	e9 d7 f4 ff ff       	jmp    8010663f <alltraps>

80107168 <vector129>:
.globl vector129
vector129:
  pushl $0
80107168:	6a 00                	push   $0x0
  pushl $129
8010716a:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010716f:	e9 cb f4 ff ff       	jmp    8010663f <alltraps>

80107174 <vector130>:
.globl vector130
vector130:
  pushl $0
80107174:	6a 00                	push   $0x0
  pushl $130
80107176:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010717b:	e9 bf f4 ff ff       	jmp    8010663f <alltraps>

80107180 <vector131>:
.globl vector131
vector131:
  pushl $0
80107180:	6a 00                	push   $0x0
  pushl $131
80107182:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107187:	e9 b3 f4 ff ff       	jmp    8010663f <alltraps>

8010718c <vector132>:
.globl vector132
vector132:
  pushl $0
8010718c:	6a 00                	push   $0x0
  pushl $132
8010718e:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107193:	e9 a7 f4 ff ff       	jmp    8010663f <alltraps>

80107198 <vector133>:
.globl vector133
vector133:
  pushl $0
80107198:	6a 00                	push   $0x0
  pushl $133
8010719a:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010719f:	e9 9b f4 ff ff       	jmp    8010663f <alltraps>

801071a4 <vector134>:
.globl vector134
vector134:
  pushl $0
801071a4:	6a 00                	push   $0x0
  pushl $134
801071a6:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801071ab:	e9 8f f4 ff ff       	jmp    8010663f <alltraps>

801071b0 <vector135>:
.globl vector135
vector135:
  pushl $0
801071b0:	6a 00                	push   $0x0
  pushl $135
801071b2:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801071b7:	e9 83 f4 ff ff       	jmp    8010663f <alltraps>

801071bc <vector136>:
.globl vector136
vector136:
  pushl $0
801071bc:	6a 00                	push   $0x0
  pushl $136
801071be:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801071c3:	e9 77 f4 ff ff       	jmp    8010663f <alltraps>

801071c8 <vector137>:
.globl vector137
vector137:
  pushl $0
801071c8:	6a 00                	push   $0x0
  pushl $137
801071ca:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801071cf:	e9 6b f4 ff ff       	jmp    8010663f <alltraps>

801071d4 <vector138>:
.globl vector138
vector138:
  pushl $0
801071d4:	6a 00                	push   $0x0
  pushl $138
801071d6:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801071db:	e9 5f f4 ff ff       	jmp    8010663f <alltraps>

801071e0 <vector139>:
.globl vector139
vector139:
  pushl $0
801071e0:	6a 00                	push   $0x0
  pushl $139
801071e2:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801071e7:	e9 53 f4 ff ff       	jmp    8010663f <alltraps>

801071ec <vector140>:
.globl vector140
vector140:
  pushl $0
801071ec:	6a 00                	push   $0x0
  pushl $140
801071ee:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801071f3:	e9 47 f4 ff ff       	jmp    8010663f <alltraps>

801071f8 <vector141>:
.globl vector141
vector141:
  pushl $0
801071f8:	6a 00                	push   $0x0
  pushl $141
801071fa:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801071ff:	e9 3b f4 ff ff       	jmp    8010663f <alltraps>

80107204 <vector142>:
.globl vector142
vector142:
  pushl $0
80107204:	6a 00                	push   $0x0
  pushl $142
80107206:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010720b:	e9 2f f4 ff ff       	jmp    8010663f <alltraps>

80107210 <vector143>:
.globl vector143
vector143:
  pushl $0
80107210:	6a 00                	push   $0x0
  pushl $143
80107212:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107217:	e9 23 f4 ff ff       	jmp    8010663f <alltraps>

8010721c <vector144>:
.globl vector144
vector144:
  pushl $0
8010721c:	6a 00                	push   $0x0
  pushl $144
8010721e:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107223:	e9 17 f4 ff ff       	jmp    8010663f <alltraps>

80107228 <vector145>:
.globl vector145
vector145:
  pushl $0
80107228:	6a 00                	push   $0x0
  pushl $145
8010722a:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010722f:	e9 0b f4 ff ff       	jmp    8010663f <alltraps>

80107234 <vector146>:
.globl vector146
vector146:
  pushl $0
80107234:	6a 00                	push   $0x0
  pushl $146
80107236:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010723b:	e9 ff f3 ff ff       	jmp    8010663f <alltraps>

80107240 <vector147>:
.globl vector147
vector147:
  pushl $0
80107240:	6a 00                	push   $0x0
  pushl $147
80107242:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107247:	e9 f3 f3 ff ff       	jmp    8010663f <alltraps>

8010724c <vector148>:
.globl vector148
vector148:
  pushl $0
8010724c:	6a 00                	push   $0x0
  pushl $148
8010724e:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107253:	e9 e7 f3 ff ff       	jmp    8010663f <alltraps>

80107258 <vector149>:
.globl vector149
vector149:
  pushl $0
80107258:	6a 00                	push   $0x0
  pushl $149
8010725a:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010725f:	e9 db f3 ff ff       	jmp    8010663f <alltraps>

80107264 <vector150>:
.globl vector150
vector150:
  pushl $0
80107264:	6a 00                	push   $0x0
  pushl $150
80107266:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010726b:	e9 cf f3 ff ff       	jmp    8010663f <alltraps>

80107270 <vector151>:
.globl vector151
vector151:
  pushl $0
80107270:	6a 00                	push   $0x0
  pushl $151
80107272:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107277:	e9 c3 f3 ff ff       	jmp    8010663f <alltraps>

8010727c <vector152>:
.globl vector152
vector152:
  pushl $0
8010727c:	6a 00                	push   $0x0
  pushl $152
8010727e:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107283:	e9 b7 f3 ff ff       	jmp    8010663f <alltraps>

80107288 <vector153>:
.globl vector153
vector153:
  pushl $0
80107288:	6a 00                	push   $0x0
  pushl $153
8010728a:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010728f:	e9 ab f3 ff ff       	jmp    8010663f <alltraps>

80107294 <vector154>:
.globl vector154
vector154:
  pushl $0
80107294:	6a 00                	push   $0x0
  pushl $154
80107296:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010729b:	e9 9f f3 ff ff       	jmp    8010663f <alltraps>

801072a0 <vector155>:
.globl vector155
vector155:
  pushl $0
801072a0:	6a 00                	push   $0x0
  pushl $155
801072a2:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801072a7:	e9 93 f3 ff ff       	jmp    8010663f <alltraps>

801072ac <vector156>:
.globl vector156
vector156:
  pushl $0
801072ac:	6a 00                	push   $0x0
  pushl $156
801072ae:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801072b3:	e9 87 f3 ff ff       	jmp    8010663f <alltraps>

801072b8 <vector157>:
.globl vector157
vector157:
  pushl $0
801072b8:	6a 00                	push   $0x0
  pushl $157
801072ba:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801072bf:	e9 7b f3 ff ff       	jmp    8010663f <alltraps>

801072c4 <vector158>:
.globl vector158
vector158:
  pushl $0
801072c4:	6a 00                	push   $0x0
  pushl $158
801072c6:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801072cb:	e9 6f f3 ff ff       	jmp    8010663f <alltraps>

801072d0 <vector159>:
.globl vector159
vector159:
  pushl $0
801072d0:	6a 00                	push   $0x0
  pushl $159
801072d2:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801072d7:	e9 63 f3 ff ff       	jmp    8010663f <alltraps>

801072dc <vector160>:
.globl vector160
vector160:
  pushl $0
801072dc:	6a 00                	push   $0x0
  pushl $160
801072de:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801072e3:	e9 57 f3 ff ff       	jmp    8010663f <alltraps>

801072e8 <vector161>:
.globl vector161
vector161:
  pushl $0
801072e8:	6a 00                	push   $0x0
  pushl $161
801072ea:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801072ef:	e9 4b f3 ff ff       	jmp    8010663f <alltraps>

801072f4 <vector162>:
.globl vector162
vector162:
  pushl $0
801072f4:	6a 00                	push   $0x0
  pushl $162
801072f6:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801072fb:	e9 3f f3 ff ff       	jmp    8010663f <alltraps>

80107300 <vector163>:
.globl vector163
vector163:
  pushl $0
80107300:	6a 00                	push   $0x0
  pushl $163
80107302:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107307:	e9 33 f3 ff ff       	jmp    8010663f <alltraps>

8010730c <vector164>:
.globl vector164
vector164:
  pushl $0
8010730c:	6a 00                	push   $0x0
  pushl $164
8010730e:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107313:	e9 27 f3 ff ff       	jmp    8010663f <alltraps>

80107318 <vector165>:
.globl vector165
vector165:
  pushl $0
80107318:	6a 00                	push   $0x0
  pushl $165
8010731a:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010731f:	e9 1b f3 ff ff       	jmp    8010663f <alltraps>

80107324 <vector166>:
.globl vector166
vector166:
  pushl $0
80107324:	6a 00                	push   $0x0
  pushl $166
80107326:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010732b:	e9 0f f3 ff ff       	jmp    8010663f <alltraps>

80107330 <vector167>:
.globl vector167
vector167:
  pushl $0
80107330:	6a 00                	push   $0x0
  pushl $167
80107332:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107337:	e9 03 f3 ff ff       	jmp    8010663f <alltraps>

8010733c <vector168>:
.globl vector168
vector168:
  pushl $0
8010733c:	6a 00                	push   $0x0
  pushl $168
8010733e:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107343:	e9 f7 f2 ff ff       	jmp    8010663f <alltraps>

80107348 <vector169>:
.globl vector169
vector169:
  pushl $0
80107348:	6a 00                	push   $0x0
  pushl $169
8010734a:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010734f:	e9 eb f2 ff ff       	jmp    8010663f <alltraps>

80107354 <vector170>:
.globl vector170
vector170:
  pushl $0
80107354:	6a 00                	push   $0x0
  pushl $170
80107356:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010735b:	e9 df f2 ff ff       	jmp    8010663f <alltraps>

80107360 <vector171>:
.globl vector171
vector171:
  pushl $0
80107360:	6a 00                	push   $0x0
  pushl $171
80107362:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107367:	e9 d3 f2 ff ff       	jmp    8010663f <alltraps>

8010736c <vector172>:
.globl vector172
vector172:
  pushl $0
8010736c:	6a 00                	push   $0x0
  pushl $172
8010736e:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107373:	e9 c7 f2 ff ff       	jmp    8010663f <alltraps>

80107378 <vector173>:
.globl vector173
vector173:
  pushl $0
80107378:	6a 00                	push   $0x0
  pushl $173
8010737a:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010737f:	e9 bb f2 ff ff       	jmp    8010663f <alltraps>

80107384 <vector174>:
.globl vector174
vector174:
  pushl $0
80107384:	6a 00                	push   $0x0
  pushl $174
80107386:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010738b:	e9 af f2 ff ff       	jmp    8010663f <alltraps>

80107390 <vector175>:
.globl vector175
vector175:
  pushl $0
80107390:	6a 00                	push   $0x0
  pushl $175
80107392:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107397:	e9 a3 f2 ff ff       	jmp    8010663f <alltraps>

8010739c <vector176>:
.globl vector176
vector176:
  pushl $0
8010739c:	6a 00                	push   $0x0
  pushl $176
8010739e:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801073a3:	e9 97 f2 ff ff       	jmp    8010663f <alltraps>

801073a8 <vector177>:
.globl vector177
vector177:
  pushl $0
801073a8:	6a 00                	push   $0x0
  pushl $177
801073aa:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801073af:	e9 8b f2 ff ff       	jmp    8010663f <alltraps>

801073b4 <vector178>:
.globl vector178
vector178:
  pushl $0
801073b4:	6a 00                	push   $0x0
  pushl $178
801073b6:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801073bb:	e9 7f f2 ff ff       	jmp    8010663f <alltraps>

801073c0 <vector179>:
.globl vector179
vector179:
  pushl $0
801073c0:	6a 00                	push   $0x0
  pushl $179
801073c2:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801073c7:	e9 73 f2 ff ff       	jmp    8010663f <alltraps>

801073cc <vector180>:
.globl vector180
vector180:
  pushl $0
801073cc:	6a 00                	push   $0x0
  pushl $180
801073ce:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801073d3:	e9 67 f2 ff ff       	jmp    8010663f <alltraps>

801073d8 <vector181>:
.globl vector181
vector181:
  pushl $0
801073d8:	6a 00                	push   $0x0
  pushl $181
801073da:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801073df:	e9 5b f2 ff ff       	jmp    8010663f <alltraps>

801073e4 <vector182>:
.globl vector182
vector182:
  pushl $0
801073e4:	6a 00                	push   $0x0
  pushl $182
801073e6:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801073eb:	e9 4f f2 ff ff       	jmp    8010663f <alltraps>

801073f0 <vector183>:
.globl vector183
vector183:
  pushl $0
801073f0:	6a 00                	push   $0x0
  pushl $183
801073f2:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801073f7:	e9 43 f2 ff ff       	jmp    8010663f <alltraps>

801073fc <vector184>:
.globl vector184
vector184:
  pushl $0
801073fc:	6a 00                	push   $0x0
  pushl $184
801073fe:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107403:	e9 37 f2 ff ff       	jmp    8010663f <alltraps>

80107408 <vector185>:
.globl vector185
vector185:
  pushl $0
80107408:	6a 00                	push   $0x0
  pushl $185
8010740a:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010740f:	e9 2b f2 ff ff       	jmp    8010663f <alltraps>

80107414 <vector186>:
.globl vector186
vector186:
  pushl $0
80107414:	6a 00                	push   $0x0
  pushl $186
80107416:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010741b:	e9 1f f2 ff ff       	jmp    8010663f <alltraps>

80107420 <vector187>:
.globl vector187
vector187:
  pushl $0
80107420:	6a 00                	push   $0x0
  pushl $187
80107422:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107427:	e9 13 f2 ff ff       	jmp    8010663f <alltraps>

8010742c <vector188>:
.globl vector188
vector188:
  pushl $0
8010742c:	6a 00                	push   $0x0
  pushl $188
8010742e:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107433:	e9 07 f2 ff ff       	jmp    8010663f <alltraps>

80107438 <vector189>:
.globl vector189
vector189:
  pushl $0
80107438:	6a 00                	push   $0x0
  pushl $189
8010743a:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010743f:	e9 fb f1 ff ff       	jmp    8010663f <alltraps>

80107444 <vector190>:
.globl vector190
vector190:
  pushl $0
80107444:	6a 00                	push   $0x0
  pushl $190
80107446:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010744b:	e9 ef f1 ff ff       	jmp    8010663f <alltraps>

80107450 <vector191>:
.globl vector191
vector191:
  pushl $0
80107450:	6a 00                	push   $0x0
  pushl $191
80107452:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107457:	e9 e3 f1 ff ff       	jmp    8010663f <alltraps>

8010745c <vector192>:
.globl vector192
vector192:
  pushl $0
8010745c:	6a 00                	push   $0x0
  pushl $192
8010745e:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107463:	e9 d7 f1 ff ff       	jmp    8010663f <alltraps>

80107468 <vector193>:
.globl vector193
vector193:
  pushl $0
80107468:	6a 00                	push   $0x0
  pushl $193
8010746a:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010746f:	e9 cb f1 ff ff       	jmp    8010663f <alltraps>

80107474 <vector194>:
.globl vector194
vector194:
  pushl $0
80107474:	6a 00                	push   $0x0
  pushl $194
80107476:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010747b:	e9 bf f1 ff ff       	jmp    8010663f <alltraps>

80107480 <vector195>:
.globl vector195
vector195:
  pushl $0
80107480:	6a 00                	push   $0x0
  pushl $195
80107482:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107487:	e9 b3 f1 ff ff       	jmp    8010663f <alltraps>

8010748c <vector196>:
.globl vector196
vector196:
  pushl $0
8010748c:	6a 00                	push   $0x0
  pushl $196
8010748e:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107493:	e9 a7 f1 ff ff       	jmp    8010663f <alltraps>

80107498 <vector197>:
.globl vector197
vector197:
  pushl $0
80107498:	6a 00                	push   $0x0
  pushl $197
8010749a:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010749f:	e9 9b f1 ff ff       	jmp    8010663f <alltraps>

801074a4 <vector198>:
.globl vector198
vector198:
  pushl $0
801074a4:	6a 00                	push   $0x0
  pushl $198
801074a6:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801074ab:	e9 8f f1 ff ff       	jmp    8010663f <alltraps>

801074b0 <vector199>:
.globl vector199
vector199:
  pushl $0
801074b0:	6a 00                	push   $0x0
  pushl $199
801074b2:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801074b7:	e9 83 f1 ff ff       	jmp    8010663f <alltraps>

801074bc <vector200>:
.globl vector200
vector200:
  pushl $0
801074bc:	6a 00                	push   $0x0
  pushl $200
801074be:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801074c3:	e9 77 f1 ff ff       	jmp    8010663f <alltraps>

801074c8 <vector201>:
.globl vector201
vector201:
  pushl $0
801074c8:	6a 00                	push   $0x0
  pushl $201
801074ca:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801074cf:	e9 6b f1 ff ff       	jmp    8010663f <alltraps>

801074d4 <vector202>:
.globl vector202
vector202:
  pushl $0
801074d4:	6a 00                	push   $0x0
  pushl $202
801074d6:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801074db:	e9 5f f1 ff ff       	jmp    8010663f <alltraps>

801074e0 <vector203>:
.globl vector203
vector203:
  pushl $0
801074e0:	6a 00                	push   $0x0
  pushl $203
801074e2:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801074e7:	e9 53 f1 ff ff       	jmp    8010663f <alltraps>

801074ec <vector204>:
.globl vector204
vector204:
  pushl $0
801074ec:	6a 00                	push   $0x0
  pushl $204
801074ee:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801074f3:	e9 47 f1 ff ff       	jmp    8010663f <alltraps>

801074f8 <vector205>:
.globl vector205
vector205:
  pushl $0
801074f8:	6a 00                	push   $0x0
  pushl $205
801074fa:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801074ff:	e9 3b f1 ff ff       	jmp    8010663f <alltraps>

80107504 <vector206>:
.globl vector206
vector206:
  pushl $0
80107504:	6a 00                	push   $0x0
  pushl $206
80107506:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010750b:	e9 2f f1 ff ff       	jmp    8010663f <alltraps>

80107510 <vector207>:
.globl vector207
vector207:
  pushl $0
80107510:	6a 00                	push   $0x0
  pushl $207
80107512:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107517:	e9 23 f1 ff ff       	jmp    8010663f <alltraps>

8010751c <vector208>:
.globl vector208
vector208:
  pushl $0
8010751c:	6a 00                	push   $0x0
  pushl $208
8010751e:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107523:	e9 17 f1 ff ff       	jmp    8010663f <alltraps>

80107528 <vector209>:
.globl vector209
vector209:
  pushl $0
80107528:	6a 00                	push   $0x0
  pushl $209
8010752a:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010752f:	e9 0b f1 ff ff       	jmp    8010663f <alltraps>

80107534 <vector210>:
.globl vector210
vector210:
  pushl $0
80107534:	6a 00                	push   $0x0
  pushl $210
80107536:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010753b:	e9 ff f0 ff ff       	jmp    8010663f <alltraps>

80107540 <vector211>:
.globl vector211
vector211:
  pushl $0
80107540:	6a 00                	push   $0x0
  pushl $211
80107542:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107547:	e9 f3 f0 ff ff       	jmp    8010663f <alltraps>

8010754c <vector212>:
.globl vector212
vector212:
  pushl $0
8010754c:	6a 00                	push   $0x0
  pushl $212
8010754e:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107553:	e9 e7 f0 ff ff       	jmp    8010663f <alltraps>

80107558 <vector213>:
.globl vector213
vector213:
  pushl $0
80107558:	6a 00                	push   $0x0
  pushl $213
8010755a:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010755f:	e9 db f0 ff ff       	jmp    8010663f <alltraps>

80107564 <vector214>:
.globl vector214
vector214:
  pushl $0
80107564:	6a 00                	push   $0x0
  pushl $214
80107566:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010756b:	e9 cf f0 ff ff       	jmp    8010663f <alltraps>

80107570 <vector215>:
.globl vector215
vector215:
  pushl $0
80107570:	6a 00                	push   $0x0
  pushl $215
80107572:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107577:	e9 c3 f0 ff ff       	jmp    8010663f <alltraps>

8010757c <vector216>:
.globl vector216
vector216:
  pushl $0
8010757c:	6a 00                	push   $0x0
  pushl $216
8010757e:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107583:	e9 b7 f0 ff ff       	jmp    8010663f <alltraps>

80107588 <vector217>:
.globl vector217
vector217:
  pushl $0
80107588:	6a 00                	push   $0x0
  pushl $217
8010758a:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010758f:	e9 ab f0 ff ff       	jmp    8010663f <alltraps>

80107594 <vector218>:
.globl vector218
vector218:
  pushl $0
80107594:	6a 00                	push   $0x0
  pushl $218
80107596:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010759b:	e9 9f f0 ff ff       	jmp    8010663f <alltraps>

801075a0 <vector219>:
.globl vector219
vector219:
  pushl $0
801075a0:	6a 00                	push   $0x0
  pushl $219
801075a2:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801075a7:	e9 93 f0 ff ff       	jmp    8010663f <alltraps>

801075ac <vector220>:
.globl vector220
vector220:
  pushl $0
801075ac:	6a 00                	push   $0x0
  pushl $220
801075ae:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801075b3:	e9 87 f0 ff ff       	jmp    8010663f <alltraps>

801075b8 <vector221>:
.globl vector221
vector221:
  pushl $0
801075b8:	6a 00                	push   $0x0
  pushl $221
801075ba:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801075bf:	e9 7b f0 ff ff       	jmp    8010663f <alltraps>

801075c4 <vector222>:
.globl vector222
vector222:
  pushl $0
801075c4:	6a 00                	push   $0x0
  pushl $222
801075c6:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801075cb:	e9 6f f0 ff ff       	jmp    8010663f <alltraps>

801075d0 <vector223>:
.globl vector223
vector223:
  pushl $0
801075d0:	6a 00                	push   $0x0
  pushl $223
801075d2:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801075d7:	e9 63 f0 ff ff       	jmp    8010663f <alltraps>

801075dc <vector224>:
.globl vector224
vector224:
  pushl $0
801075dc:	6a 00                	push   $0x0
  pushl $224
801075de:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801075e3:	e9 57 f0 ff ff       	jmp    8010663f <alltraps>

801075e8 <vector225>:
.globl vector225
vector225:
  pushl $0
801075e8:	6a 00                	push   $0x0
  pushl $225
801075ea:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801075ef:	e9 4b f0 ff ff       	jmp    8010663f <alltraps>

801075f4 <vector226>:
.globl vector226
vector226:
  pushl $0
801075f4:	6a 00                	push   $0x0
  pushl $226
801075f6:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801075fb:	e9 3f f0 ff ff       	jmp    8010663f <alltraps>

80107600 <vector227>:
.globl vector227
vector227:
  pushl $0
80107600:	6a 00                	push   $0x0
  pushl $227
80107602:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107607:	e9 33 f0 ff ff       	jmp    8010663f <alltraps>

8010760c <vector228>:
.globl vector228
vector228:
  pushl $0
8010760c:	6a 00                	push   $0x0
  pushl $228
8010760e:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107613:	e9 27 f0 ff ff       	jmp    8010663f <alltraps>

80107618 <vector229>:
.globl vector229
vector229:
  pushl $0
80107618:	6a 00                	push   $0x0
  pushl $229
8010761a:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010761f:	e9 1b f0 ff ff       	jmp    8010663f <alltraps>

80107624 <vector230>:
.globl vector230
vector230:
  pushl $0
80107624:	6a 00                	push   $0x0
  pushl $230
80107626:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010762b:	e9 0f f0 ff ff       	jmp    8010663f <alltraps>

80107630 <vector231>:
.globl vector231
vector231:
  pushl $0
80107630:	6a 00                	push   $0x0
  pushl $231
80107632:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107637:	e9 03 f0 ff ff       	jmp    8010663f <alltraps>

8010763c <vector232>:
.globl vector232
vector232:
  pushl $0
8010763c:	6a 00                	push   $0x0
  pushl $232
8010763e:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107643:	e9 f7 ef ff ff       	jmp    8010663f <alltraps>

80107648 <vector233>:
.globl vector233
vector233:
  pushl $0
80107648:	6a 00                	push   $0x0
  pushl $233
8010764a:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010764f:	e9 eb ef ff ff       	jmp    8010663f <alltraps>

80107654 <vector234>:
.globl vector234
vector234:
  pushl $0
80107654:	6a 00                	push   $0x0
  pushl $234
80107656:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010765b:	e9 df ef ff ff       	jmp    8010663f <alltraps>

80107660 <vector235>:
.globl vector235
vector235:
  pushl $0
80107660:	6a 00                	push   $0x0
  pushl $235
80107662:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107667:	e9 d3 ef ff ff       	jmp    8010663f <alltraps>

8010766c <vector236>:
.globl vector236
vector236:
  pushl $0
8010766c:	6a 00                	push   $0x0
  pushl $236
8010766e:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107673:	e9 c7 ef ff ff       	jmp    8010663f <alltraps>

80107678 <vector237>:
.globl vector237
vector237:
  pushl $0
80107678:	6a 00                	push   $0x0
  pushl $237
8010767a:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010767f:	e9 bb ef ff ff       	jmp    8010663f <alltraps>

80107684 <vector238>:
.globl vector238
vector238:
  pushl $0
80107684:	6a 00                	push   $0x0
  pushl $238
80107686:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010768b:	e9 af ef ff ff       	jmp    8010663f <alltraps>

80107690 <vector239>:
.globl vector239
vector239:
  pushl $0
80107690:	6a 00                	push   $0x0
  pushl $239
80107692:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107697:	e9 a3 ef ff ff       	jmp    8010663f <alltraps>

8010769c <vector240>:
.globl vector240
vector240:
  pushl $0
8010769c:	6a 00                	push   $0x0
  pushl $240
8010769e:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801076a3:	e9 97 ef ff ff       	jmp    8010663f <alltraps>

801076a8 <vector241>:
.globl vector241
vector241:
  pushl $0
801076a8:	6a 00                	push   $0x0
  pushl $241
801076aa:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801076af:	e9 8b ef ff ff       	jmp    8010663f <alltraps>

801076b4 <vector242>:
.globl vector242
vector242:
  pushl $0
801076b4:	6a 00                	push   $0x0
  pushl $242
801076b6:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801076bb:	e9 7f ef ff ff       	jmp    8010663f <alltraps>

801076c0 <vector243>:
.globl vector243
vector243:
  pushl $0
801076c0:	6a 00                	push   $0x0
  pushl $243
801076c2:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801076c7:	e9 73 ef ff ff       	jmp    8010663f <alltraps>

801076cc <vector244>:
.globl vector244
vector244:
  pushl $0
801076cc:	6a 00                	push   $0x0
  pushl $244
801076ce:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801076d3:	e9 67 ef ff ff       	jmp    8010663f <alltraps>

801076d8 <vector245>:
.globl vector245
vector245:
  pushl $0
801076d8:	6a 00                	push   $0x0
  pushl $245
801076da:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801076df:	e9 5b ef ff ff       	jmp    8010663f <alltraps>

801076e4 <vector246>:
.globl vector246
vector246:
  pushl $0
801076e4:	6a 00                	push   $0x0
  pushl $246
801076e6:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801076eb:	e9 4f ef ff ff       	jmp    8010663f <alltraps>

801076f0 <vector247>:
.globl vector247
vector247:
  pushl $0
801076f0:	6a 00                	push   $0x0
  pushl $247
801076f2:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801076f7:	e9 43 ef ff ff       	jmp    8010663f <alltraps>

801076fc <vector248>:
.globl vector248
vector248:
  pushl $0
801076fc:	6a 00                	push   $0x0
  pushl $248
801076fe:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107703:	e9 37 ef ff ff       	jmp    8010663f <alltraps>

80107708 <vector249>:
.globl vector249
vector249:
  pushl $0
80107708:	6a 00                	push   $0x0
  pushl $249
8010770a:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010770f:	e9 2b ef ff ff       	jmp    8010663f <alltraps>

80107714 <vector250>:
.globl vector250
vector250:
  pushl $0
80107714:	6a 00                	push   $0x0
  pushl $250
80107716:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010771b:	e9 1f ef ff ff       	jmp    8010663f <alltraps>

80107720 <vector251>:
.globl vector251
vector251:
  pushl $0
80107720:	6a 00                	push   $0x0
  pushl $251
80107722:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107727:	e9 13 ef ff ff       	jmp    8010663f <alltraps>

8010772c <vector252>:
.globl vector252
vector252:
  pushl $0
8010772c:	6a 00                	push   $0x0
  pushl $252
8010772e:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107733:	e9 07 ef ff ff       	jmp    8010663f <alltraps>

80107738 <vector253>:
.globl vector253
vector253:
  pushl $0
80107738:	6a 00                	push   $0x0
  pushl $253
8010773a:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010773f:	e9 fb ee ff ff       	jmp    8010663f <alltraps>

80107744 <vector254>:
.globl vector254
vector254:
  pushl $0
80107744:	6a 00                	push   $0x0
  pushl $254
80107746:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010774b:	e9 ef ee ff ff       	jmp    8010663f <alltraps>

80107750 <vector255>:
.globl vector255
vector255:
  pushl $0
80107750:	6a 00                	push   $0x0
  pushl $255
80107752:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107757:	e9 e3 ee ff ff       	jmp    8010663f <alltraps>

8010775c <lgdt>:
{
8010775c:	55                   	push   %ebp
8010775d:	89 e5                	mov    %esp,%ebp
8010775f:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107762:	8b 45 0c             	mov    0xc(%ebp),%eax
80107765:	83 e8 01             	sub    $0x1,%eax
80107768:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010776c:	8b 45 08             	mov    0x8(%ebp),%eax
8010776f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107773:	8b 45 08             	mov    0x8(%ebp),%eax
80107776:	c1 e8 10             	shr    $0x10,%eax
80107779:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010777d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107780:	0f 01 10             	lgdtl  (%eax)
}
80107783:	90                   	nop
80107784:	c9                   	leave
80107785:	c3                   	ret

80107786 <ltr>:
{
80107786:	55                   	push   %ebp
80107787:	89 e5                	mov    %esp,%ebp
80107789:	83 ec 04             	sub    $0x4,%esp
8010778c:	8b 45 08             	mov    0x8(%ebp),%eax
8010778f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107793:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107797:	0f 00 d8             	ltr    %eax
}
8010779a:	90                   	nop
8010779b:	c9                   	leave
8010779c:	c3                   	ret

8010779d <lcr3>:

static inline void
lcr3(uint val)
{
8010779d:	55                   	push   %ebp
8010779e:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801077a0:	8b 45 08             	mov    0x8(%ebp),%eax
801077a3:	0f 22 d8             	mov    %eax,%cr3
}
801077a6:	90                   	nop
801077a7:	5d                   	pop    %ebp
801077a8:	c3                   	ret

801077a9 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801077a9:	55                   	push   %ebp
801077aa:	89 e5                	mov    %esp,%ebp
801077ac:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801077af:	e8 e9 c1 ff ff       	call   8010399d <cpuid>
801077b4:	69 c0 b4 00 00 00    	imul   $0xb4,%eax,%eax
801077ba:	05 c0 79 19 80       	add    $0x801979c0,%eax
801077bf:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801077c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c5:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801077cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ce:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801077d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d7:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801077db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077de:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801077e2:	83 e2 f0             	and    $0xfffffff0,%edx
801077e5:	83 ca 0a             	or     $0xa,%edx
801077e8:	88 50 7d             	mov    %dl,0x7d(%eax)
801077eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ee:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801077f2:	83 ca 10             	or     $0x10,%edx
801077f5:	88 50 7d             	mov    %dl,0x7d(%eax)
801077f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077fb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801077ff:	83 e2 9f             	and    $0xffffff9f,%edx
80107802:	88 50 7d             	mov    %dl,0x7d(%eax)
80107805:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107808:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010780c:	83 ca 80             	or     $0xffffff80,%edx
8010780f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107815:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107819:	83 ca 0f             	or     $0xf,%edx
8010781c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010781f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107822:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107826:	83 e2 ef             	and    $0xffffffef,%edx
80107829:	88 50 7e             	mov    %dl,0x7e(%eax)
8010782c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107833:	83 e2 df             	and    $0xffffffdf,%edx
80107836:	88 50 7e             	mov    %dl,0x7e(%eax)
80107839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107840:	83 ca 40             	or     $0x40,%edx
80107843:	88 50 7e             	mov    %dl,0x7e(%eax)
80107846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107849:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010784d:	83 ca 80             	or     $0xffffff80,%edx
80107850:	88 50 7e             	mov    %dl,0x7e(%eax)
80107853:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107856:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010785a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785d:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107864:	ff ff 
80107866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107869:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107870:	00 00 
80107872:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107875:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010787c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107886:	83 e2 f0             	and    $0xfffffff0,%edx
80107889:	83 ca 02             	or     $0x2,%edx
8010788c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107895:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010789c:	83 ca 10             	or     $0x10,%edx
8010789f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078af:	83 e2 9f             	and    $0xffffff9f,%edx
801078b2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078bb:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078c2:	83 ca 80             	or     $0xffffff80,%edx
801078c5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ce:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078d5:	83 ca 0f             	or     $0xf,%edx
801078d8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078e8:	83 e2 ef             	and    $0xffffffef,%edx
801078eb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078fb:	83 e2 df             	and    $0xffffffdf,%edx
801078fe:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107907:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010790e:	83 ca 40             	or     $0x40,%edx
80107911:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107921:	83 ca 80             	or     $0xffffff80,%edx
80107924:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010792a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792d:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107937:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010793e:	ff ff 
80107940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107943:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
8010794a:	00 00 
8010794c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794f:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107959:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107960:	83 e2 f0             	and    $0xfffffff0,%edx
80107963:	83 ca 0a             	or     $0xa,%edx
80107966:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010796c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107976:	83 ca 10             	or     $0x10,%edx
80107979:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010797f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107982:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107989:	83 ca 60             	or     $0x60,%edx
8010798c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107995:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010799c:	83 ca 80             	or     $0xffffff80,%edx
8010799f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801079a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801079af:	83 ca 0f             	or     $0xf,%edx
801079b2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801079b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079bb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801079c2:	83 e2 ef             	and    $0xffffffef,%edx
801079c5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801079cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ce:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801079d5:	83 e2 df             	and    $0xffffffdf,%edx
801079d8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801079de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801079e8:	83 ca 40             	or     $0x40,%edx
801079eb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801079f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801079fb:	83 ca 80             	or     $0xffffff80,%edx
801079fe:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a07:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a11:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107a18:	ff ff 
80107a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1d:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107a24:	00 00 
80107a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a29:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a33:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a3a:	83 e2 f0             	and    $0xfffffff0,%edx
80107a3d:	83 ca 02             	or     $0x2,%edx
80107a40:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a49:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a50:	83 ca 10             	or     $0x10,%edx
80107a53:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a63:	83 ca 60             	or     $0x60,%edx
80107a66:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a76:	83 ca 80             	or     $0xffffff80,%edx
80107a79:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a82:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a89:	83 ca 0f             	or     $0xf,%edx
80107a8c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a95:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a9c:	83 e2 ef             	and    $0xffffffef,%edx
80107a9f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107aaf:	83 e2 df             	and    $0xffffffdf,%edx
80107ab2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ac2:	83 ca 40             	or     $0x40,%edx
80107ac5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ace:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ad5:	83 ca 80             	or     $0xffffff80,%edx
80107ad8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae1:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aeb:	83 c0 70             	add    $0x70,%eax
80107aee:	83 ec 08             	sub    $0x8,%esp
80107af1:	6a 30                	push   $0x30
80107af3:	50                   	push   %eax
80107af4:	e8 63 fc ff ff       	call   8010775c <lgdt>
80107af9:	83 c4 10             	add    $0x10,%esp
}
80107afc:	90                   	nop
80107afd:	c9                   	leave
80107afe:	c3                   	ret

80107aff <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107aff:	55                   	push   %ebp
80107b00:	89 e5                	mov    %esp,%ebp
80107b02:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107b05:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b08:	c1 e8 16             	shr    $0x16,%eax
80107b0b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b12:	8b 45 08             	mov    0x8(%ebp),%eax
80107b15:	01 d0                	add    %edx,%eax
80107b17:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b1d:	8b 00                	mov    (%eax),%eax
80107b1f:	83 e0 01             	and    $0x1,%eax
80107b22:	85 c0                	test   %eax,%eax
80107b24:	74 14                	je     80107b3a <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b29:	8b 00                	mov    (%eax),%eax
80107b2b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b30:	05 00 00 00 80       	add    $0x80000000,%eax
80107b35:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b38:	eb 42                	jmp    80107b7c <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107b3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107b3e:	74 0e                	je     80107b4e <walkpgdir+0x4f>
80107b40:	e8 63 ac ff ff       	call   801027a8 <kalloc>
80107b45:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b48:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107b4c:	75 07                	jne    80107b55 <walkpgdir+0x56>
      return 0;
80107b4e:	b8 00 00 00 00       	mov    $0x0,%eax
80107b53:	eb 3e                	jmp    80107b93 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107b55:	83 ec 04             	sub    $0x4,%esp
80107b58:	68 00 10 00 00       	push   $0x1000
80107b5d:	6a 00                	push   $0x0
80107b5f:	ff 75 f4             	push   -0xc(%ebp)
80107b62:	e8 c9 d6 ff ff       	call   80105230 <memset>
80107b67:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6d:	05 00 00 00 80       	add    $0x80000000,%eax
80107b72:	83 c8 07             	or     $0x7,%eax
80107b75:	89 c2                	mov    %eax,%edx
80107b77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b7a:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b7f:	c1 e8 0c             	shr    $0xc,%eax
80107b82:	25 ff 03 00 00       	and    $0x3ff,%eax
80107b87:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b91:	01 d0                	add    %edx,%eax
}
80107b93:	c9                   	leave
80107b94:	c3                   	ret

80107b95 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107b95:	55                   	push   %ebp
80107b96:	89 e5                	mov    %esp,%ebp
80107b98:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ba3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107ba6:	8b 55 0c             	mov    0xc(%ebp),%edx
80107ba9:	8b 45 10             	mov    0x10(%ebp),%eax
80107bac:	01 d0                	add    %edx,%eax
80107bae:	83 e8 01             	sub    $0x1,%eax
80107bb1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107bb9:	83 ec 04             	sub    $0x4,%esp
80107bbc:	6a 01                	push   $0x1
80107bbe:	ff 75 f4             	push   -0xc(%ebp)
80107bc1:	ff 75 08             	push   0x8(%ebp)
80107bc4:	e8 36 ff ff ff       	call   80107aff <walkpgdir>
80107bc9:	83 c4 10             	add    $0x10,%esp
80107bcc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107bcf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107bd3:	75 07                	jne    80107bdc <mappages+0x47>
      return -1;
80107bd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bda:	eb 47                	jmp    80107c23 <mappages+0x8e>
    if(*pte & PTE_P)
80107bdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bdf:	8b 00                	mov    (%eax),%eax
80107be1:	83 e0 01             	and    $0x1,%eax
80107be4:	85 c0                	test   %eax,%eax
80107be6:	74 0d                	je     80107bf5 <mappages+0x60>
      panic("remap");
80107be8:	83 ec 0c             	sub    $0xc,%esp
80107beb:	68 14 b0 10 80       	push   $0x8010b014
80107bf0:	e8 b4 89 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107bf5:	8b 45 18             	mov    0x18(%ebp),%eax
80107bf8:	0b 45 14             	or     0x14(%ebp),%eax
80107bfb:	83 c8 01             	or     $0x1,%eax
80107bfe:	89 c2                	mov    %eax,%edx
80107c00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c03:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c08:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107c0b:	74 10                	je     80107c1d <mappages+0x88>
      break;
    a += PGSIZE;
80107c0d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107c14:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107c1b:	eb 9c                	jmp    80107bb9 <mappages+0x24>
      break;
80107c1d:	90                   	nop
  }
  return 0;
80107c1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c23:	c9                   	leave
80107c24:	c3                   	ret

80107c25 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107c25:	55                   	push   %ebp
80107c26:	89 e5                	mov    %esp,%ebp
80107c28:	53                   	push   %ebx
80107c29:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107c2c:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107c33:	a1 84 7a 19 80       	mov    0x80197a84,%eax
80107c38:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107c3d:	29 c2                	sub    %eax,%edx
80107c3f:	89 d0                	mov    %edx,%eax
80107c41:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107c44:	a1 7c 7a 19 80       	mov    0x80197a7c,%eax
80107c49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107c4c:	8b 15 7c 7a 19 80    	mov    0x80197a7c,%edx
80107c52:	a1 84 7a 19 80       	mov    0x80197a84,%eax
80107c57:	01 d0                	add    %edx,%eax
80107c59:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107c5c:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c66:	83 c0 30             	add    $0x30,%eax
80107c69:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107c6c:	89 10                	mov    %edx,(%eax)
80107c6e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107c71:	89 50 04             	mov    %edx,0x4(%eax)
80107c74:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107c77:	89 50 08             	mov    %edx,0x8(%eax)
80107c7a:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107c7d:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107c80:	e8 23 ab ff ff       	call   801027a8 <kalloc>
80107c85:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c88:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c8c:	75 07                	jne    80107c95 <setupkvm+0x70>
    return 0;
80107c8e:	b8 00 00 00 00       	mov    $0x0,%eax
80107c93:	eb 78                	jmp    80107d0d <setupkvm+0xe8>
  }
  memset(pgdir, 0, PGSIZE);
80107c95:	83 ec 04             	sub    $0x4,%esp
80107c98:	68 00 10 00 00       	push   $0x1000
80107c9d:	6a 00                	push   $0x0
80107c9f:	ff 75 f0             	push   -0x10(%ebp)
80107ca2:	e8 89 d5 ff ff       	call   80105230 <memset>
80107ca7:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107caa:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107cb1:	eb 4e                	jmp    80107d01 <setupkvm+0xdc>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb6:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbc:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc2:	8b 58 08             	mov    0x8(%eax),%ebx
80107cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc8:	8b 40 04             	mov    0x4(%eax),%eax
80107ccb:	29 c3                	sub    %eax,%ebx
80107ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd0:	8b 00                	mov    (%eax),%eax
80107cd2:	83 ec 0c             	sub    $0xc,%esp
80107cd5:	51                   	push   %ecx
80107cd6:	52                   	push   %edx
80107cd7:	53                   	push   %ebx
80107cd8:	50                   	push   %eax
80107cd9:	ff 75 f0             	push   -0x10(%ebp)
80107cdc:	e8 b4 fe ff ff       	call   80107b95 <mappages>
80107ce1:	83 c4 20             	add    $0x20,%esp
80107ce4:	85 c0                	test   %eax,%eax
80107ce6:	79 15                	jns    80107cfd <setupkvm+0xd8>
      freevm(pgdir);
80107ce8:	83 ec 0c             	sub    $0xc,%esp
80107ceb:	ff 75 f0             	push   -0x10(%ebp)
80107cee:	e8 f5 04 00 00       	call   801081e8 <freevm>
80107cf3:	83 c4 10             	add    $0x10,%esp
      return 0;
80107cf6:	b8 00 00 00 00       	mov    $0x0,%eax
80107cfb:	eb 10                	jmp    80107d0d <setupkvm+0xe8>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107cfd:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107d01:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80107d08:	72 a9                	jb     80107cb3 <setupkvm+0x8e>
    }
  return pgdir;
80107d0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107d0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107d10:	c9                   	leave
80107d11:	c3                   	ret

80107d12 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107d12:	55                   	push   %ebp
80107d13:	89 e5                	mov    %esp,%ebp
80107d15:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107d18:	e8 08 ff ff ff       	call   80107c25 <setupkvm>
80107d1d:	a3 bc 79 19 80       	mov    %eax,0x801979bc
  switchkvm();
80107d22:	e8 03 00 00 00       	call   80107d2a <switchkvm>
}
80107d27:	90                   	nop
80107d28:	c9                   	leave
80107d29:	c3                   	ret

80107d2a <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107d2a:	55                   	push   %ebp
80107d2b:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107d2d:	a1 bc 79 19 80       	mov    0x801979bc,%eax
80107d32:	05 00 00 00 80       	add    $0x80000000,%eax
80107d37:	50                   	push   %eax
80107d38:	e8 60 fa ff ff       	call   8010779d <lcr3>
80107d3d:	83 c4 04             	add    $0x4,%esp
}
80107d40:	90                   	nop
80107d41:	c9                   	leave
80107d42:	c3                   	ret

80107d43 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107d43:	55                   	push   %ebp
80107d44:	89 e5                	mov    %esp,%ebp
80107d46:	56                   	push   %esi
80107d47:	53                   	push   %ebx
80107d48:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107d4b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107d4f:	75 0d                	jne    80107d5e <switchuvm+0x1b>
    panic("switchuvm: no process");
80107d51:	83 ec 0c             	sub    $0xc,%esp
80107d54:	68 1a b0 10 80       	push   $0x8010b01a
80107d59:	e8 4b 88 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107d5e:	8b 45 08             	mov    0x8(%ebp),%eax
80107d61:	8b 40 08             	mov    0x8(%eax),%eax
80107d64:	85 c0                	test   %eax,%eax
80107d66:	75 0d                	jne    80107d75 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107d68:	83 ec 0c             	sub    $0xc,%esp
80107d6b:	68 30 b0 10 80       	push   $0x8010b030
80107d70:	e8 34 88 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107d75:	8b 45 08             	mov    0x8(%ebp),%eax
80107d78:	8b 40 04             	mov    0x4(%eax),%eax
80107d7b:	85 c0                	test   %eax,%eax
80107d7d:	75 0d                	jne    80107d8c <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107d7f:	83 ec 0c             	sub    $0xc,%esp
80107d82:	68 45 b0 10 80       	push   $0x8010b045
80107d87:	e8 1d 88 ff ff       	call   801005a9 <panic>

  pushcli();
80107d8c:	e8 94 d3 ff ff       	call   80105125 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107d91:	e8 22 bc ff ff       	call   801039b8 <mycpu>
80107d96:	89 c3                	mov    %eax,%ebx
80107d98:	e8 1b bc ff ff       	call   801039b8 <mycpu>
80107d9d:	83 c0 08             	add    $0x8,%eax
80107da0:	89 c6                	mov    %eax,%esi
80107da2:	e8 11 bc ff ff       	call   801039b8 <mycpu>
80107da7:	83 c0 08             	add    $0x8,%eax
80107daa:	c1 e8 10             	shr    $0x10,%eax
80107dad:	88 45 f7             	mov    %al,-0x9(%ebp)
80107db0:	e8 03 bc ff ff       	call   801039b8 <mycpu>
80107db5:	83 c0 08             	add    $0x8,%eax
80107db8:	c1 e8 18             	shr    $0x18,%eax
80107dbb:	89 c2                	mov    %eax,%edx
80107dbd:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107dc4:	67 00 
80107dc6:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107dcd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107dd1:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107dd7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107dde:	83 e0 f0             	and    $0xfffffff0,%eax
80107de1:	83 c8 09             	or     $0x9,%eax
80107de4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107dea:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107df1:	83 c8 10             	or     $0x10,%eax
80107df4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107dfa:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e01:	83 e0 9f             	and    $0xffffff9f,%eax
80107e04:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e0a:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107e11:	83 c8 80             	or     $0xffffff80,%eax
80107e14:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107e1a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e21:	83 e0 f0             	and    $0xfffffff0,%eax
80107e24:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e2a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e31:	83 e0 ef             	and    $0xffffffef,%eax
80107e34:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e3a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e41:	83 e0 df             	and    $0xffffffdf,%eax
80107e44:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e4a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e51:	83 c8 40             	or     $0x40,%eax
80107e54:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e5a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107e61:	83 e0 7f             	and    $0x7f,%eax
80107e64:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107e6a:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107e70:	e8 43 bb ff ff       	call   801039b8 <mycpu>
80107e75:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107e7c:	83 e2 ef             	and    $0xffffffef,%edx
80107e7f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107e85:	e8 2e bb ff ff       	call   801039b8 <mycpu>
80107e8a:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107e90:	8b 45 08             	mov    0x8(%ebp),%eax
80107e93:	8b 40 08             	mov    0x8(%eax),%eax
80107e96:	89 c3                	mov    %eax,%ebx
80107e98:	e8 1b bb ff ff       	call   801039b8 <mycpu>
80107e9d:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107ea3:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107ea6:	e8 0d bb ff ff       	call   801039b8 <mycpu>
80107eab:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107eb1:	83 ec 0c             	sub    $0xc,%esp
80107eb4:	6a 28                	push   $0x28
80107eb6:	e8 cb f8 ff ff       	call   80107786 <ltr>
80107ebb:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107ebe:	8b 45 08             	mov    0x8(%ebp),%eax
80107ec1:	8b 40 04             	mov    0x4(%eax),%eax
80107ec4:	05 00 00 00 80       	add    $0x80000000,%eax
80107ec9:	83 ec 0c             	sub    $0xc,%esp
80107ecc:	50                   	push   %eax
80107ecd:	e8 cb f8 ff ff       	call   8010779d <lcr3>
80107ed2:	83 c4 10             	add    $0x10,%esp
  popcli();
80107ed5:	e8 98 d2 ff ff       	call   80105172 <popcli>
}
80107eda:	90                   	nop
80107edb:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107ede:	5b                   	pop    %ebx
80107edf:	5e                   	pop    %esi
80107ee0:	5d                   	pop    %ebp
80107ee1:	c3                   	ret

80107ee2 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107ee2:	55                   	push   %ebp
80107ee3:	89 e5                	mov    %esp,%ebp
80107ee5:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107ee8:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107eef:	76 0d                	jbe    80107efe <inituvm+0x1c>
    panic("inituvm: more than a page");
80107ef1:	83 ec 0c             	sub    $0xc,%esp
80107ef4:	68 59 b0 10 80       	push   $0x8010b059
80107ef9:	e8 ab 86 ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107efe:	e8 a5 a8 ff ff       	call   801027a8 <kalloc>
80107f03:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107f06:	83 ec 04             	sub    $0x4,%esp
80107f09:	68 00 10 00 00       	push   $0x1000
80107f0e:	6a 00                	push   $0x0
80107f10:	ff 75 f4             	push   -0xc(%ebp)
80107f13:	e8 18 d3 ff ff       	call   80105230 <memset>
80107f18:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1e:	05 00 00 00 80       	add    $0x80000000,%eax
80107f23:	83 ec 0c             	sub    $0xc,%esp
80107f26:	6a 06                	push   $0x6
80107f28:	50                   	push   %eax
80107f29:	68 00 10 00 00       	push   $0x1000
80107f2e:	6a 00                	push   $0x0
80107f30:	ff 75 08             	push   0x8(%ebp)
80107f33:	e8 5d fc ff ff       	call   80107b95 <mappages>
80107f38:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107f3b:	83 ec 04             	sub    $0x4,%esp
80107f3e:	ff 75 10             	push   0x10(%ebp)
80107f41:	ff 75 0c             	push   0xc(%ebp)
80107f44:	ff 75 f4             	push   -0xc(%ebp)
80107f47:	e8 a3 d3 ff ff       	call   801052ef <memmove>
80107f4c:	83 c4 10             	add    $0x10,%esp
}
80107f4f:	90                   	nop
80107f50:	c9                   	leave
80107f51:	c3                   	ret

80107f52 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107f52:	55                   	push   %ebp
80107f53:	89 e5                	mov    %esp,%ebp
80107f55:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107f58:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f5b:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f60:	85 c0                	test   %eax,%eax
80107f62:	74 0d                	je     80107f71 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107f64:	83 ec 0c             	sub    $0xc,%esp
80107f67:	68 74 b0 10 80       	push   $0x8010b074
80107f6c:	e8 38 86 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107f71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f78:	e9 8f 00 00 00       	jmp    8010800c <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107f7d:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f83:	01 d0                	add    %edx,%eax
80107f85:	83 ec 04             	sub    $0x4,%esp
80107f88:	6a 00                	push   $0x0
80107f8a:	50                   	push   %eax
80107f8b:	ff 75 08             	push   0x8(%ebp)
80107f8e:	e8 6c fb ff ff       	call   80107aff <walkpgdir>
80107f93:	83 c4 10             	add    $0x10,%esp
80107f96:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f99:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f9d:	75 0d                	jne    80107fac <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107f9f:	83 ec 0c             	sub    $0xc,%esp
80107fa2:	68 97 b0 10 80       	push   $0x8010b097
80107fa7:	e8 fd 85 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107fac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107faf:	8b 00                	mov    (%eax),%eax
80107fb1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fb6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107fb9:	8b 45 18             	mov    0x18(%ebp),%eax
80107fbc:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107fbf:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107fc4:	77 0b                	ja     80107fd1 <loaduvm+0x7f>
      n = sz - i;
80107fc6:	8b 45 18             	mov    0x18(%ebp),%eax
80107fc9:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107fcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107fcf:	eb 07                	jmp    80107fd8 <loaduvm+0x86>
    else
      n = PGSIZE;
80107fd1:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107fd8:	8b 55 14             	mov    0x14(%ebp),%edx
80107fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fde:	01 d0                	add    %edx,%eax
80107fe0:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107fe3:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107fe9:	ff 75 f0             	push   -0x10(%ebp)
80107fec:	50                   	push   %eax
80107fed:	52                   	push   %edx
80107fee:	ff 75 10             	push   0x10(%ebp)
80107ff1:	e8 e8 9e ff ff       	call   80101ede <readi>
80107ff6:	83 c4 10             	add    $0x10,%esp
80107ff9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107ffc:	74 07                	je     80108005 <loaduvm+0xb3>
      return -1;
80107ffe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108003:	eb 18                	jmp    8010801d <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80108005:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010800c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800f:	3b 45 18             	cmp    0x18(%ebp),%eax
80108012:	0f 82 65 ff ff ff    	jb     80107f7d <loaduvm+0x2b>
  }
  return 0;
80108018:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010801d:	c9                   	leave
8010801e:	c3                   	ret

8010801f <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010801f:	55                   	push   %ebp
80108020:	89 e5                	mov    %esp,%ebp
80108022:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108025:	8b 45 10             	mov    0x10(%ebp),%eax
80108028:	85 c0                	test   %eax,%eax
8010802a:	79 0a                	jns    80108036 <allocuvm+0x17>
    return 0;
8010802c:	b8 00 00 00 00       	mov    $0x0,%eax
80108031:	e9 ec 00 00 00       	jmp    80108122 <allocuvm+0x103>
  if(newsz < oldsz)
80108036:	8b 45 10             	mov    0x10(%ebp),%eax
80108039:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010803c:	73 08                	jae    80108046 <allocuvm+0x27>
    return oldsz;
8010803e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108041:	e9 dc 00 00 00       	jmp    80108122 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80108046:	8b 45 0c             	mov    0xc(%ebp),%eax
80108049:	05 ff 0f 00 00       	add    $0xfff,%eax
8010804e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108053:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108056:	e9 b8 00 00 00       	jmp    80108113 <allocuvm+0xf4>
    mem = kalloc();
8010805b:	e8 48 a7 ff ff       	call   801027a8 <kalloc>
80108060:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108063:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108067:	75 2e                	jne    80108097 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80108069:	83 ec 0c             	sub    $0xc,%esp
8010806c:	68 b5 b0 10 80       	push   $0x8010b0b5
80108071:	e8 7e 83 ff ff       	call   801003f4 <cprintf>
80108076:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108079:	83 ec 04             	sub    $0x4,%esp
8010807c:	ff 75 0c             	push   0xc(%ebp)
8010807f:	ff 75 10             	push   0x10(%ebp)
80108082:	ff 75 08             	push   0x8(%ebp)
80108085:	e8 9a 00 00 00       	call   80108124 <deallocuvm>
8010808a:	83 c4 10             	add    $0x10,%esp
      return 0;
8010808d:	b8 00 00 00 00       	mov    $0x0,%eax
80108092:	e9 8b 00 00 00       	jmp    80108122 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80108097:	83 ec 04             	sub    $0x4,%esp
8010809a:	68 00 10 00 00       	push   $0x1000
8010809f:	6a 00                	push   $0x0
801080a1:	ff 75 f0             	push   -0x10(%ebp)
801080a4:	e8 87 d1 ff ff       	call   80105230 <memset>
801080a9:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801080ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080af:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801080b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b8:	83 ec 0c             	sub    $0xc,%esp
801080bb:	6a 06                	push   $0x6
801080bd:	52                   	push   %edx
801080be:	68 00 10 00 00       	push   $0x1000
801080c3:	50                   	push   %eax
801080c4:	ff 75 08             	push   0x8(%ebp)
801080c7:	e8 c9 fa ff ff       	call   80107b95 <mappages>
801080cc:	83 c4 20             	add    $0x20,%esp
801080cf:	85 c0                	test   %eax,%eax
801080d1:	79 39                	jns    8010810c <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
801080d3:	83 ec 0c             	sub    $0xc,%esp
801080d6:	68 cd b0 10 80       	push   $0x8010b0cd
801080db:	e8 14 83 ff ff       	call   801003f4 <cprintf>
801080e0:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801080e3:	83 ec 04             	sub    $0x4,%esp
801080e6:	ff 75 0c             	push   0xc(%ebp)
801080e9:	ff 75 10             	push   0x10(%ebp)
801080ec:	ff 75 08             	push   0x8(%ebp)
801080ef:	e8 30 00 00 00       	call   80108124 <deallocuvm>
801080f4:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801080f7:	83 ec 0c             	sub    $0xc,%esp
801080fa:	ff 75 f0             	push   -0x10(%ebp)
801080fd:	e8 0c a6 ff ff       	call   8010270e <kfree>
80108102:	83 c4 10             	add    $0x10,%esp
      return 0;
80108105:	b8 00 00 00 00       	mov    $0x0,%eax
8010810a:	eb 16                	jmp    80108122 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
8010810c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108116:	3b 45 10             	cmp    0x10(%ebp),%eax
80108119:	0f 82 3c ff ff ff    	jb     8010805b <allocuvm+0x3c>
    }
  }
  return newsz;
8010811f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108122:	c9                   	leave
80108123:	c3                   	ret

80108124 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108124:	55                   	push   %ebp
80108125:	89 e5                	mov    %esp,%ebp
80108127:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010812a:	8b 45 10             	mov    0x10(%ebp),%eax
8010812d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108130:	72 08                	jb     8010813a <deallocuvm+0x16>
    return oldsz;
80108132:	8b 45 0c             	mov    0xc(%ebp),%eax
80108135:	e9 ac 00 00 00       	jmp    801081e6 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
8010813a:	8b 45 10             	mov    0x10(%ebp),%eax
8010813d:	05 ff 0f 00 00       	add    $0xfff,%eax
80108142:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108147:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010814a:	e9 88 00 00 00       	jmp    801081d7 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010814f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108152:	83 ec 04             	sub    $0x4,%esp
80108155:	6a 00                	push   $0x0
80108157:	50                   	push   %eax
80108158:	ff 75 08             	push   0x8(%ebp)
8010815b:	e8 9f f9 ff ff       	call   80107aff <walkpgdir>
80108160:	83 c4 10             	add    $0x10,%esp
80108163:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108166:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010816a:	75 16                	jne    80108182 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010816c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816f:	c1 e8 16             	shr    $0x16,%eax
80108172:	83 c0 01             	add    $0x1,%eax
80108175:	c1 e0 16             	shl    $0x16,%eax
80108178:	2d 00 10 00 00       	sub    $0x1000,%eax
8010817d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108180:	eb 4e                	jmp    801081d0 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108182:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108185:	8b 00                	mov    (%eax),%eax
80108187:	83 e0 01             	and    $0x1,%eax
8010818a:	85 c0                	test   %eax,%eax
8010818c:	74 42                	je     801081d0 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
8010818e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108191:	8b 00                	mov    (%eax),%eax
80108193:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108198:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010819b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010819f:	75 0d                	jne    801081ae <deallocuvm+0x8a>
        panic("kfree");
801081a1:	83 ec 0c             	sub    $0xc,%esp
801081a4:	68 e9 b0 10 80       	push   $0x8010b0e9
801081a9:	e8 fb 83 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
801081ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081b1:	05 00 00 00 80       	add    $0x80000000,%eax
801081b6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801081b9:	83 ec 0c             	sub    $0xc,%esp
801081bc:	ff 75 e8             	push   -0x18(%ebp)
801081bf:	e8 4a a5 ff ff       	call   8010270e <kfree>
801081c4:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801081c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081ca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
801081d0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801081d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081da:	3b 45 0c             	cmp    0xc(%ebp),%eax
801081dd:	0f 82 6c ff ff ff    	jb     8010814f <deallocuvm+0x2b>
    }
  }
  return newsz;
801081e3:	8b 45 10             	mov    0x10(%ebp),%eax
}
801081e6:	c9                   	leave
801081e7:	c3                   	ret

801081e8 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801081e8:	55                   	push   %ebp
801081e9:	89 e5                	mov    %esp,%ebp
801081eb:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801081ee:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801081f2:	75 0d                	jne    80108201 <freevm+0x19>
    panic("freevm: no pgdir");
801081f4:	83 ec 0c             	sub    $0xc,%esp
801081f7:	68 ef b0 10 80       	push   $0x8010b0ef
801081fc:	e8 a8 83 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108201:	83 ec 04             	sub    $0x4,%esp
80108204:	6a 00                	push   $0x0
80108206:	68 00 00 00 80       	push   $0x80000000
8010820b:	ff 75 08             	push   0x8(%ebp)
8010820e:	e8 11 ff ff ff       	call   80108124 <deallocuvm>
80108213:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108216:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010821d:	eb 48                	jmp    80108267 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
8010821f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108222:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108229:	8b 45 08             	mov    0x8(%ebp),%eax
8010822c:	01 d0                	add    %edx,%eax
8010822e:	8b 00                	mov    (%eax),%eax
80108230:	83 e0 01             	and    $0x1,%eax
80108233:	85 c0                	test   %eax,%eax
80108235:	74 2c                	je     80108263 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108237:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010823a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108241:	8b 45 08             	mov    0x8(%ebp),%eax
80108244:	01 d0                	add    %edx,%eax
80108246:	8b 00                	mov    (%eax),%eax
80108248:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010824d:	05 00 00 00 80       	add    $0x80000000,%eax
80108252:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108255:	83 ec 0c             	sub    $0xc,%esp
80108258:	ff 75 f0             	push   -0x10(%ebp)
8010825b:	e8 ae a4 ff ff       	call   8010270e <kfree>
80108260:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108263:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108267:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010826e:	76 af                	jbe    8010821f <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80108270:	83 ec 0c             	sub    $0xc,%esp
80108273:	ff 75 08             	push   0x8(%ebp)
80108276:	e8 93 a4 ff ff       	call   8010270e <kfree>
8010827b:	83 c4 10             	add    $0x10,%esp
}
8010827e:	90                   	nop
8010827f:	c9                   	leave
80108280:	c3                   	ret

80108281 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108281:	55                   	push   %ebp
80108282:	89 e5                	mov    %esp,%ebp
80108284:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108287:	83 ec 04             	sub    $0x4,%esp
8010828a:	6a 00                	push   $0x0
8010828c:	ff 75 0c             	push   0xc(%ebp)
8010828f:	ff 75 08             	push   0x8(%ebp)
80108292:	e8 68 f8 ff ff       	call   80107aff <walkpgdir>
80108297:	83 c4 10             	add    $0x10,%esp
8010829a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010829d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801082a1:	75 0d                	jne    801082b0 <clearpteu+0x2f>
    panic("clearpteu");
801082a3:	83 ec 0c             	sub    $0xc,%esp
801082a6:	68 00 b1 10 80       	push   $0x8010b100
801082ab:	e8 f9 82 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
801082b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b3:	8b 00                	mov    (%eax),%eax
801082b5:	83 e0 fb             	and    $0xfffffffb,%eax
801082b8:	89 c2                	mov    %eax,%edx
801082ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082bd:	89 10                	mov    %edx,(%eax)
}
801082bf:	90                   	nop
801082c0:	c9                   	leave
801082c1:	c3                   	ret

801082c2 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801082c2:	55                   	push   %ebp
801082c3:	89 e5                	mov    %esp,%ebp
801082c5:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801082c8:	e8 58 f9 ff ff       	call   80107c25 <setupkvm>
801082cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801082d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082d4:	75 0a                	jne    801082e0 <copyuvm+0x1e>
    return 0;
801082d6:	b8 00 00 00 00       	mov    $0x0,%eax
801082db:	e9 eb 00 00 00       	jmp    801083cb <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
801082e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082e7:	e9 b7 00 00 00       	jmp    801083a3 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801082ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ef:	83 ec 04             	sub    $0x4,%esp
801082f2:	6a 00                	push   $0x0
801082f4:	50                   	push   %eax
801082f5:	ff 75 08             	push   0x8(%ebp)
801082f8:	e8 02 f8 ff ff       	call   80107aff <walkpgdir>
801082fd:	83 c4 10             	add    $0x10,%esp
80108300:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108303:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108307:	75 0d                	jne    80108316 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80108309:	83 ec 0c             	sub    $0xc,%esp
8010830c:	68 0a b1 10 80       	push   $0x8010b10a
80108311:	e8 93 82 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80108316:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108319:	8b 00                	mov    (%eax),%eax
8010831b:	83 e0 01             	and    $0x1,%eax
8010831e:	85 c0                	test   %eax,%eax
80108320:	75 0d                	jne    8010832f <copyuvm+0x6d>
      panic("copyuvm: page not present");
80108322:	83 ec 0c             	sub    $0xc,%esp
80108325:	68 24 b1 10 80       	push   $0x8010b124
8010832a:	e8 7a 82 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
8010832f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108332:	8b 00                	mov    (%eax),%eax
80108334:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108339:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010833c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010833f:	8b 00                	mov    (%eax),%eax
80108341:	25 ff 0f 00 00       	and    $0xfff,%eax
80108346:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108349:	e8 5a a4 ff ff       	call   801027a8 <kalloc>
8010834e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108351:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108355:	74 5d                	je     801083b4 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108357:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010835a:	05 00 00 00 80       	add    $0x80000000,%eax
8010835f:	83 ec 04             	sub    $0x4,%esp
80108362:	68 00 10 00 00       	push   $0x1000
80108367:	50                   	push   %eax
80108368:	ff 75 e0             	push   -0x20(%ebp)
8010836b:	e8 7f cf ff ff       	call   801052ef <memmove>
80108370:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108373:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108376:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108379:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010837f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108382:	83 ec 0c             	sub    $0xc,%esp
80108385:	52                   	push   %edx
80108386:	51                   	push   %ecx
80108387:	68 00 10 00 00       	push   $0x1000
8010838c:	50                   	push   %eax
8010838d:	ff 75 f0             	push   -0x10(%ebp)
80108390:	e8 00 f8 ff ff       	call   80107b95 <mappages>
80108395:	83 c4 20             	add    $0x20,%esp
80108398:	85 c0                	test   %eax,%eax
8010839a:	78 1b                	js     801083b7 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
8010839c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a6:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083a9:	0f 82 3d ff ff ff    	jb     801082ec <copyuvm+0x2a>
      goto bad;
  }
  return d;
801083af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083b2:	eb 17                	jmp    801083cb <copyuvm+0x109>
      goto bad;
801083b4:	90                   	nop
801083b5:	eb 01                	jmp    801083b8 <copyuvm+0xf6>
      goto bad;
801083b7:	90                   	nop

bad:
  freevm(d);
801083b8:	83 ec 0c             	sub    $0xc,%esp
801083bb:	ff 75 f0             	push   -0x10(%ebp)
801083be:	e8 25 fe ff ff       	call   801081e8 <freevm>
801083c3:	83 c4 10             	add    $0x10,%esp
  return 0;
801083c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083cb:	c9                   	leave
801083cc:	c3                   	ret

801083cd <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801083cd:	55                   	push   %ebp
801083ce:	89 e5                	mov    %esp,%ebp
801083d0:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801083d3:	83 ec 04             	sub    $0x4,%esp
801083d6:	6a 00                	push   $0x0
801083d8:	ff 75 0c             	push   0xc(%ebp)
801083db:	ff 75 08             	push   0x8(%ebp)
801083de:	e8 1c f7 ff ff       	call   80107aff <walkpgdir>
801083e3:	83 c4 10             	add    $0x10,%esp
801083e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801083e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ec:	8b 00                	mov    (%eax),%eax
801083ee:	83 e0 01             	and    $0x1,%eax
801083f1:	85 c0                	test   %eax,%eax
801083f3:	75 07                	jne    801083fc <uva2ka+0x2f>
    return 0;
801083f5:	b8 00 00 00 00       	mov    $0x0,%eax
801083fa:	eb 22                	jmp    8010841e <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
801083fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ff:	8b 00                	mov    (%eax),%eax
80108401:	83 e0 04             	and    $0x4,%eax
80108404:	85 c0                	test   %eax,%eax
80108406:	75 07                	jne    8010840f <uva2ka+0x42>
    return 0;
80108408:	b8 00 00 00 00       	mov    $0x0,%eax
8010840d:	eb 0f                	jmp    8010841e <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
8010840f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108412:	8b 00                	mov    (%eax),%eax
80108414:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108419:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010841e:	c9                   	leave
8010841f:	c3                   	ret

80108420 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108420:	55                   	push   %ebp
80108421:	89 e5                	mov    %esp,%ebp
80108423:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108426:	8b 45 10             	mov    0x10(%ebp),%eax
80108429:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010842c:	eb 7f                	jmp    801084ad <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010842e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108431:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108436:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108439:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010843c:	83 ec 08             	sub    $0x8,%esp
8010843f:	50                   	push   %eax
80108440:	ff 75 08             	push   0x8(%ebp)
80108443:	e8 85 ff ff ff       	call   801083cd <uva2ka>
80108448:	83 c4 10             	add    $0x10,%esp
8010844b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010844e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108452:	75 07                	jne    8010845b <copyout+0x3b>
      return -1;
80108454:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108459:	eb 61                	jmp    801084bc <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010845b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010845e:	2b 45 0c             	sub    0xc(%ebp),%eax
80108461:	05 00 10 00 00       	add    $0x1000,%eax
80108466:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108469:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010846c:	39 45 14             	cmp    %eax,0x14(%ebp)
8010846f:	73 06                	jae    80108477 <copyout+0x57>
      n = len;
80108471:	8b 45 14             	mov    0x14(%ebp),%eax
80108474:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108477:	8b 45 0c             	mov    0xc(%ebp),%eax
8010847a:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010847d:	89 c2                	mov    %eax,%edx
8010847f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108482:	01 d0                	add    %edx,%eax
80108484:	83 ec 04             	sub    $0x4,%esp
80108487:	ff 75 f0             	push   -0x10(%ebp)
8010848a:	ff 75 f4             	push   -0xc(%ebp)
8010848d:	50                   	push   %eax
8010848e:	e8 5c ce ff ff       	call   801052ef <memmove>
80108493:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108499:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010849c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010849f:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801084a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084a5:	05 00 10 00 00       	add    $0x1000,%eax
801084aa:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801084ad:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801084b1:	0f 85 77 ff ff ff    	jne    8010842e <copyout+0xe>
  }
  return 0;
801084b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084bc:	c9                   	leave
801084bd:	c3                   	ret

801084be <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
801084be:	55                   	push   %ebp
801084bf:	89 e5                	mov    %esp,%ebp
801084c1:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801084c4:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
801084cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801084ce:	8b 40 08             	mov    0x8(%eax),%eax
801084d1:	05 00 00 00 80       	add    $0x80000000,%eax
801084d6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
801084d9:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
801084e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e3:	8b 40 24             	mov    0x24(%eax),%eax
801084e6:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
801084eb:	c7 05 74 7a 19 80 00 	movl   $0x0,0x80197a74
801084f2:	00 00 00 

  while(i<madt->len){
801084f5:	e9 bc 00 00 00       	jmp    801085b6 <mpinit_uefi+0xf8>
    uchar *entry_type = ((uchar *)madt)+i;
801084fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108500:	01 d0                	add    %edx,%eax
80108502:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80108505:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108508:	0f b6 00             	movzbl (%eax),%eax
8010850b:	0f b6 c0             	movzbl %al,%eax
8010850e:	83 f8 05             	cmp    $0x5,%eax
80108511:	0f 87 9f 00 00 00    	ja     801085b6 <mpinit_uefi+0xf8>
80108517:	8b 04 85 40 b1 10 80 	mov    -0x7fef4ec0(,%eax,4),%eax
8010851e:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80108520:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108523:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108526:	a1 74 7a 19 80       	mov    0x80197a74,%eax
8010852b:	85 c0                	test   %eax,%eax
8010852d:	7f 28                	jg     80108557 <mpinit_uefi+0x99>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
8010852f:	8b 15 74 7a 19 80    	mov    0x80197a74,%edx
80108535:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108538:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010853c:	69 d2 b4 00 00 00    	imul   $0xb4,%edx,%edx
80108542:	81 c2 c0 79 19 80    	add    $0x801979c0,%edx
80108548:	88 02                	mov    %al,(%edx)
          ncpu++;
8010854a:	a1 74 7a 19 80       	mov    0x80197a74,%eax
8010854f:	83 c0 01             	add    $0x1,%eax
80108552:	a3 74 7a 19 80       	mov    %eax,0x80197a74
        }
        i += lapic_entry->record_len;
80108557:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010855a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010855e:	0f b6 c0             	movzbl %al,%eax
80108561:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108564:	eb 50                	jmp    801085b6 <mpinit_uefi+0xf8>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108566:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108569:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
8010856c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010856f:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108573:	a2 78 7a 19 80       	mov    %al,0x80197a78
        i += ioapic->record_len;
80108578:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010857b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010857f:	0f b6 c0             	movzbl %al,%eax
80108582:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108585:	eb 2f                	jmp    801085b6 <mpinit_uefi+0xf8>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108587:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010858a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
8010858d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108590:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108594:	0f b6 c0             	movzbl %al,%eax
80108597:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010859a:	eb 1a                	jmp    801085b6 <mpinit_uefi+0xf8>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
8010859c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010859f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801085a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085a5:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801085a9:	0f b6 c0             	movzbl %al,%eax
801085ac:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801085af:	eb 05                	jmp    801085b6 <mpinit_uefi+0xf8>

      case 5:
        i = i + 0xC;
801085b1:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
801085b5:	90                   	nop
  while(i<madt->len){
801085b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b9:	8b 40 04             	mov    0x4(%eax),%eax
801085bc:	39 45 fc             	cmp    %eax,-0x4(%ebp)
801085bf:	0f 82 35 ff ff ff    	jb     801084fa <mpinit_uefi+0x3c>
    }
  }

}
801085c5:	90                   	nop
801085c6:	90                   	nop
801085c7:	c9                   	leave
801085c8:	c3                   	ret

801085c9 <inb>:
{
801085c9:	55                   	push   %ebp
801085ca:	89 e5                	mov    %esp,%ebp
801085cc:	83 ec 14             	sub    $0x14,%esp
801085cf:	8b 45 08             	mov    0x8(%ebp),%eax
801085d2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801085d6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801085da:	89 c2                	mov    %eax,%edx
801085dc:	ec                   	in     (%dx),%al
801085dd:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801085e0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801085e4:	c9                   	leave
801085e5:	c3                   	ret

801085e6 <outb>:
{
801085e6:	55                   	push   %ebp
801085e7:	89 e5                	mov    %esp,%ebp
801085e9:	83 ec 08             	sub    $0x8,%esp
801085ec:	8b 55 08             	mov    0x8(%ebp),%edx
801085ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801085f2:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801085f6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801085f9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801085fd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108601:	ee                   	out    %al,(%dx)
}
80108602:	90                   	nop
80108603:	c9                   	leave
80108604:	c3                   	ret

80108605 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108605:	55                   	push   %ebp
80108606:	89 e5                	mov    %esp,%ebp
80108608:	83 ec 28             	sub    $0x28,%esp
8010860b:	8b 45 08             	mov    0x8(%ebp),%eax
8010860e:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108611:	6a 00                	push   $0x0
80108613:	68 fa 03 00 00       	push   $0x3fa
80108618:	e8 c9 ff ff ff       	call   801085e6 <outb>
8010861d:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108620:	68 80 00 00 00       	push   $0x80
80108625:	68 fb 03 00 00       	push   $0x3fb
8010862a:	e8 b7 ff ff ff       	call   801085e6 <outb>
8010862f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108632:	6a 0c                	push   $0xc
80108634:	68 f8 03 00 00       	push   $0x3f8
80108639:	e8 a8 ff ff ff       	call   801085e6 <outb>
8010863e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108641:	6a 00                	push   $0x0
80108643:	68 f9 03 00 00       	push   $0x3f9
80108648:	e8 99 ff ff ff       	call   801085e6 <outb>
8010864d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108650:	6a 03                	push   $0x3
80108652:	68 fb 03 00 00       	push   $0x3fb
80108657:	e8 8a ff ff ff       	call   801085e6 <outb>
8010865c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010865f:	6a 00                	push   $0x0
80108661:	68 fc 03 00 00       	push   $0x3fc
80108666:	e8 7b ff ff ff       	call   801085e6 <outb>
8010866b:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010866e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108675:	eb 11                	jmp    80108688 <uart_debug+0x83>
80108677:	83 ec 0c             	sub    $0xc,%esp
8010867a:	6a 0a                	push   $0xa
8010867c:	e8 b8 a4 ff ff       	call   80102b39 <microdelay>
80108681:	83 c4 10             	add    $0x10,%esp
80108684:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108688:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010868c:	7f 1a                	jg     801086a8 <uart_debug+0xa3>
8010868e:	83 ec 0c             	sub    $0xc,%esp
80108691:	68 fd 03 00 00       	push   $0x3fd
80108696:	e8 2e ff ff ff       	call   801085c9 <inb>
8010869b:	83 c4 10             	add    $0x10,%esp
8010869e:	0f b6 c0             	movzbl %al,%eax
801086a1:	83 e0 20             	and    $0x20,%eax
801086a4:	85 c0                	test   %eax,%eax
801086a6:	74 cf                	je     80108677 <uart_debug+0x72>
  outb(COM1+0, p);
801086a8:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801086ac:	0f b6 c0             	movzbl %al,%eax
801086af:	83 ec 08             	sub    $0x8,%esp
801086b2:	50                   	push   %eax
801086b3:	68 f8 03 00 00       	push   $0x3f8
801086b8:	e8 29 ff ff ff       	call   801085e6 <outb>
801086bd:	83 c4 10             	add    $0x10,%esp
}
801086c0:	90                   	nop
801086c1:	c9                   	leave
801086c2:	c3                   	ret

801086c3 <uart_debugs>:

void uart_debugs(char *p){
801086c3:	55                   	push   %ebp
801086c4:	89 e5                	mov    %esp,%ebp
801086c6:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801086c9:	eb 1b                	jmp    801086e6 <uart_debugs+0x23>
    uart_debug(*p++);
801086cb:	8b 45 08             	mov    0x8(%ebp),%eax
801086ce:	8d 50 01             	lea    0x1(%eax),%edx
801086d1:	89 55 08             	mov    %edx,0x8(%ebp)
801086d4:	0f b6 00             	movzbl (%eax),%eax
801086d7:	0f be c0             	movsbl %al,%eax
801086da:	83 ec 0c             	sub    $0xc,%esp
801086dd:	50                   	push   %eax
801086de:	e8 22 ff ff ff       	call   80108605 <uart_debug>
801086e3:	83 c4 10             	add    $0x10,%esp
  while(*p){
801086e6:	8b 45 08             	mov    0x8(%ebp),%eax
801086e9:	0f b6 00             	movzbl (%eax),%eax
801086ec:	84 c0                	test   %al,%al
801086ee:	75 db                	jne    801086cb <uart_debugs+0x8>
  }
}
801086f0:	90                   	nop
801086f1:	90                   	nop
801086f2:	c9                   	leave
801086f3:	c3                   	ret

801086f4 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801086f4:	55                   	push   %ebp
801086f5:	89 e5                	mov    %esp,%ebp
801086f7:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801086fa:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108701:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108704:	8b 50 14             	mov    0x14(%eax),%edx
80108707:	8b 40 10             	mov    0x10(%eax),%eax
8010870a:	a3 7c 7a 19 80       	mov    %eax,0x80197a7c
  gpu.vram_size = boot_param->graphic_config.frame_size;
8010870f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108712:	8b 50 1c             	mov    0x1c(%eax),%edx
80108715:	8b 40 18             	mov    0x18(%eax),%eax
80108718:	a3 84 7a 19 80       	mov    %eax,0x80197a84
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
8010871d:	a1 84 7a 19 80       	mov    0x80197a84,%eax
80108722:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108727:	29 c2                	sub    %eax,%edx
80108729:	89 15 80 7a 19 80    	mov    %edx,0x80197a80
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010872f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108732:	8b 50 24             	mov    0x24(%eax),%edx
80108735:	8b 40 20             	mov    0x20(%eax),%eax
80108738:	a3 88 7a 19 80       	mov    %eax,0x80197a88
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
8010873d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108740:	8b 50 2c             	mov    0x2c(%eax),%edx
80108743:	8b 40 28             	mov    0x28(%eax),%eax
80108746:	a3 8c 7a 19 80       	mov    %eax,0x80197a8c
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
8010874b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010874e:	8b 50 34             	mov    0x34(%eax),%edx
80108751:	8b 40 30             	mov    0x30(%eax),%eax
80108754:	a3 90 7a 19 80       	mov    %eax,0x80197a90
}
80108759:	90                   	nop
8010875a:	c9                   	leave
8010875b:	c3                   	ret

8010875c <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010875c:	55                   	push   %ebp
8010875d:	89 e5                	mov    %esp,%ebp
8010875f:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108762:	8b 15 90 7a 19 80    	mov    0x80197a90,%edx
80108768:	8b 45 0c             	mov    0xc(%ebp),%eax
8010876b:	0f af d0             	imul   %eax,%edx
8010876e:	8b 45 08             	mov    0x8(%ebp),%eax
80108771:	01 d0                	add    %edx,%eax
80108773:	c1 e0 02             	shl    $0x2,%eax
80108776:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108779:	8b 15 80 7a 19 80    	mov    0x80197a80,%edx
8010877f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108782:	01 d0                	add    %edx,%eax
80108784:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108787:	8b 45 10             	mov    0x10(%ebp),%eax
8010878a:	0f b6 10             	movzbl (%eax),%edx
8010878d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108790:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108792:	8b 45 10             	mov    0x10(%ebp),%eax
80108795:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108799:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010879c:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
8010879f:	8b 45 10             	mov    0x10(%ebp),%eax
801087a2:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801087a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801087a9:	88 50 02             	mov    %dl,0x2(%eax)
}
801087ac:	90                   	nop
801087ad:	c9                   	leave
801087ae:	c3                   	ret

801087af <graphic_scroll_up>:

void graphic_scroll_up(int height){
801087af:	55                   	push   %ebp
801087b0:	89 e5                	mov    %esp,%ebp
801087b2:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801087b5:	8b 15 90 7a 19 80    	mov    0x80197a90,%edx
801087bb:	8b 45 08             	mov    0x8(%ebp),%eax
801087be:	0f af c2             	imul   %edx,%eax
801087c1:	c1 e0 02             	shl    $0x2,%eax
801087c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801087c7:	8b 15 84 7a 19 80    	mov    0x80197a84,%edx
801087cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d0:	29 c2                	sub    %eax,%edx
801087d2:	8b 0d 80 7a 19 80    	mov    0x80197a80,%ecx
801087d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087db:	01 c8                	add    %ecx,%eax
801087dd:	89 c1                	mov    %eax,%ecx
801087df:	a1 80 7a 19 80       	mov    0x80197a80,%eax
801087e4:	83 ec 04             	sub    $0x4,%esp
801087e7:	52                   	push   %edx
801087e8:	51                   	push   %ecx
801087e9:	50                   	push   %eax
801087ea:	e8 00 cb ff ff       	call   801052ef <memmove>
801087ef:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801087f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f5:	8b 0d 80 7a 19 80    	mov    0x80197a80,%ecx
801087fb:	8b 15 84 7a 19 80    	mov    0x80197a84,%edx
80108801:	01 d1                	add    %edx,%ecx
80108803:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108806:	29 d1                	sub    %edx,%ecx
80108808:	89 ca                	mov    %ecx,%edx
8010880a:	83 ec 04             	sub    $0x4,%esp
8010880d:	50                   	push   %eax
8010880e:	6a 00                	push   $0x0
80108810:	52                   	push   %edx
80108811:	e8 1a ca ff ff       	call   80105230 <memset>
80108816:	83 c4 10             	add    $0x10,%esp
}
80108819:	90                   	nop
8010881a:	c9                   	leave
8010881b:	c3                   	ret

8010881c <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
8010881c:	55                   	push   %ebp
8010881d:	89 e5                	mov    %esp,%ebp
8010881f:	53                   	push   %ebx
80108820:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108823:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010882a:	e9 b1 00 00 00       	jmp    801088e0 <font_render+0xc4>
    for(int j=14;j>-1;j--){
8010882f:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108836:	e9 97 00 00 00       	jmp    801088d2 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
8010883b:	8b 45 10             	mov    0x10(%ebp),%eax
8010883e:	83 e8 20             	sub    $0x20,%eax
80108841:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108844:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108847:	01 d0                	add    %edx,%eax
80108849:	0f b7 84 00 60 b1 10 	movzwl -0x7fef4ea0(%eax,%eax,1),%eax
80108850:	80 
80108851:	0f b7 d0             	movzwl %ax,%edx
80108854:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108857:	bb 01 00 00 00       	mov    $0x1,%ebx
8010885c:	89 c1                	mov    %eax,%ecx
8010885e:	d3 e3                	shl    %cl,%ebx
80108860:	89 d8                	mov    %ebx,%eax
80108862:	21 d0                	and    %edx,%eax
80108864:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108867:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010886a:	ba 01 00 00 00       	mov    $0x1,%edx
8010886f:	89 c1                	mov    %eax,%ecx
80108871:	d3 e2                	shl    %cl,%edx
80108873:	89 d0                	mov    %edx,%eax
80108875:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108878:	75 2b                	jne    801088a5 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
8010887a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010887d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108880:	01 c2                	add    %eax,%edx
80108882:	b8 0e 00 00 00       	mov    $0xe,%eax
80108887:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010888a:	89 c1                	mov    %eax,%ecx
8010888c:	8b 45 08             	mov    0x8(%ebp),%eax
8010888f:	01 c8                	add    %ecx,%eax
80108891:	83 ec 04             	sub    $0x4,%esp
80108894:	68 00 f5 10 80       	push   $0x8010f500
80108899:	52                   	push   %edx
8010889a:	50                   	push   %eax
8010889b:	e8 bc fe ff ff       	call   8010875c <graphic_draw_pixel>
801088a0:	83 c4 10             	add    $0x10,%esp
801088a3:	eb 29                	jmp    801088ce <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801088a5:	8b 55 0c             	mov    0xc(%ebp),%edx
801088a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ab:	01 c2                	add    %eax,%edx
801088ad:	b8 0e 00 00 00       	mov    $0xe,%eax
801088b2:	2b 45 f0             	sub    -0x10(%ebp),%eax
801088b5:	89 c1                	mov    %eax,%ecx
801088b7:	8b 45 08             	mov    0x8(%ebp),%eax
801088ba:	01 c8                	add    %ecx,%eax
801088bc:	83 ec 04             	sub    $0x4,%esp
801088bf:	68 94 7a 19 80       	push   $0x80197a94
801088c4:	52                   	push   %edx
801088c5:	50                   	push   %eax
801088c6:	e8 91 fe ff ff       	call   8010875c <graphic_draw_pixel>
801088cb:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801088ce:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
801088d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801088d6:	0f 89 5f ff ff ff    	jns    8010883b <font_render+0x1f>
  for(int i=0;i<30;i++){
801088dc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801088e0:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801088e4:	0f 8e 45 ff ff ff    	jle    8010882f <font_render+0x13>
      }
    }
  }
}
801088ea:	90                   	nop
801088eb:	90                   	nop
801088ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801088ef:	c9                   	leave
801088f0:	c3                   	ret

801088f1 <font_render_string>:

void font_render_string(char *string,int row){
801088f1:	55                   	push   %ebp
801088f2:	89 e5                	mov    %esp,%ebp
801088f4:	53                   	push   %ebx
801088f5:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801088f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801088ff:	eb 33                	jmp    80108934 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80108901:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108904:	8b 45 08             	mov    0x8(%ebp),%eax
80108907:	01 d0                	add    %edx,%eax
80108909:	0f b6 00             	movzbl (%eax),%eax
8010890c:	0f be d8             	movsbl %al,%ebx
8010890f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108912:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108915:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108918:	89 d0                	mov    %edx,%eax
8010891a:	c1 e0 04             	shl    $0x4,%eax
8010891d:	29 d0                	sub    %edx,%eax
8010891f:	83 c0 02             	add    $0x2,%eax
80108922:	83 ec 04             	sub    $0x4,%esp
80108925:	53                   	push   %ebx
80108926:	51                   	push   %ecx
80108927:	50                   	push   %eax
80108928:	e8 ef fe ff ff       	call   8010881c <font_render>
8010892d:	83 c4 10             	add    $0x10,%esp
    i++;
80108930:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108934:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108937:	8b 45 08             	mov    0x8(%ebp),%eax
8010893a:	01 d0                	add    %edx,%eax
8010893c:	0f b6 00             	movzbl (%eax),%eax
8010893f:	84 c0                	test   %al,%al
80108941:	74 06                	je     80108949 <font_render_string+0x58>
80108943:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108947:	7e b8                	jle    80108901 <font_render_string+0x10>
  }
}
80108949:	90                   	nop
8010894a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010894d:	c9                   	leave
8010894e:	c3                   	ret

8010894f <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010894f:	55                   	push   %ebp
80108950:	89 e5                	mov    %esp,%ebp
80108952:	53                   	push   %ebx
80108953:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108956:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010895d:	eb 6b                	jmp    801089ca <pci_init+0x7b>
    for(int j=0;j<32;j++){
8010895f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108966:	eb 58                	jmp    801089c0 <pci_init+0x71>
      for(int k=0;k<8;k++){
80108968:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010896f:	eb 45                	jmp    801089b6 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108971:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108974:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897a:	83 ec 0c             	sub    $0xc,%esp
8010897d:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108980:	53                   	push   %ebx
80108981:	6a 00                	push   $0x0
80108983:	51                   	push   %ecx
80108984:	52                   	push   %edx
80108985:	50                   	push   %eax
80108986:	e8 b0 00 00 00       	call   80108a3b <pci_access_config>
8010898b:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010898e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108991:	0f b7 c0             	movzwl %ax,%eax
80108994:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108999:	74 17                	je     801089b2 <pci_init+0x63>
        pci_init_device(i,j,k);
8010899b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010899e:	8b 55 f0             	mov    -0x10(%ebp),%edx
801089a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a4:	83 ec 04             	sub    $0x4,%esp
801089a7:	51                   	push   %ecx
801089a8:	52                   	push   %edx
801089a9:	50                   	push   %eax
801089aa:	e8 37 01 00 00       	call   80108ae6 <pci_init_device>
801089af:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801089b2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801089b6:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801089ba:	7e b5                	jle    80108971 <pci_init+0x22>
    for(int j=0;j<32;j++){
801089bc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801089c0:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801089c4:	7e a2                	jle    80108968 <pci_init+0x19>
  for(int i=0;i<256;i++){
801089c6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801089ca:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801089d1:	7e 8c                	jle    8010895f <pci_init+0x10>
      }
      }
    }
  }
}
801089d3:	90                   	nop
801089d4:	90                   	nop
801089d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801089d8:	c9                   	leave
801089d9:	c3                   	ret

801089da <pci_write_config>:

void pci_write_config(uint config){
801089da:	55                   	push   %ebp
801089db:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801089dd:	8b 45 08             	mov    0x8(%ebp),%eax
801089e0:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801089e5:	89 c0                	mov    %eax,%eax
801089e7:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801089e8:	90                   	nop
801089e9:	5d                   	pop    %ebp
801089ea:	c3                   	ret

801089eb <pci_write_data>:

void pci_write_data(uint config){
801089eb:	55                   	push   %ebp
801089ec:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801089ee:	8b 45 08             	mov    0x8(%ebp),%eax
801089f1:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801089f6:	89 c0                	mov    %eax,%eax
801089f8:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801089f9:	90                   	nop
801089fa:	5d                   	pop    %ebp
801089fb:	c3                   	ret

801089fc <pci_read_config>:
uint pci_read_config(){
801089fc:	55                   	push   %ebp
801089fd:	89 e5                	mov    %esp,%ebp
801089ff:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108a02:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108a07:	ed                   	in     (%dx),%eax
80108a08:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108a0b:	83 ec 0c             	sub    $0xc,%esp
80108a0e:	68 c8 00 00 00       	push   $0xc8
80108a13:	e8 21 a1 ff ff       	call   80102b39 <microdelay>
80108a18:	83 c4 10             	add    $0x10,%esp
  return data;
80108a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108a1e:	c9                   	leave
80108a1f:	c3                   	ret

80108a20 <pci_test>:


void pci_test(){
80108a20:	55                   	push   %ebp
80108a21:	89 e5                	mov    %esp,%ebp
80108a23:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108a26:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108a2d:	ff 75 fc             	push   -0x4(%ebp)
80108a30:	e8 a5 ff ff ff       	call   801089da <pci_write_config>
80108a35:	83 c4 04             	add    $0x4,%esp
}
80108a38:	90                   	nop
80108a39:	c9                   	leave
80108a3a:	c3                   	ret

80108a3b <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108a3b:	55                   	push   %ebp
80108a3c:	89 e5                	mov    %esp,%ebp
80108a3e:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108a41:	8b 45 08             	mov    0x8(%ebp),%eax
80108a44:	c1 e0 10             	shl    $0x10,%eax
80108a47:	25 00 00 ff 00       	and    $0xff0000,%eax
80108a4c:	89 c2                	mov    %eax,%edx
80108a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a51:	c1 e0 0b             	shl    $0xb,%eax
80108a54:	0f b7 c0             	movzwl %ax,%eax
80108a57:	09 c2                	or     %eax,%edx
80108a59:	8b 45 10             	mov    0x10(%ebp),%eax
80108a5c:	c1 e0 08             	shl    $0x8,%eax
80108a5f:	25 00 07 00 00       	and    $0x700,%eax
80108a64:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108a66:	8b 45 14             	mov    0x14(%ebp),%eax
80108a69:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108a6e:	09 d0                	or     %edx,%eax
80108a70:	0d 00 00 00 80       	or     $0x80000000,%eax
80108a75:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108a78:	ff 75 f4             	push   -0xc(%ebp)
80108a7b:	e8 5a ff ff ff       	call   801089da <pci_write_config>
80108a80:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108a83:	e8 74 ff ff ff       	call   801089fc <pci_read_config>
80108a88:	8b 55 18             	mov    0x18(%ebp),%edx
80108a8b:	89 02                	mov    %eax,(%edx)
}
80108a8d:	90                   	nop
80108a8e:	c9                   	leave
80108a8f:	c3                   	ret

80108a90 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108a90:	55                   	push   %ebp
80108a91:	89 e5                	mov    %esp,%ebp
80108a93:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108a96:	8b 45 08             	mov    0x8(%ebp),%eax
80108a99:	c1 e0 10             	shl    $0x10,%eax
80108a9c:	25 00 00 ff 00       	and    $0xff0000,%eax
80108aa1:	89 c2                	mov    %eax,%edx
80108aa3:	8b 45 0c             	mov    0xc(%ebp),%eax
80108aa6:	c1 e0 0b             	shl    $0xb,%eax
80108aa9:	0f b7 c0             	movzwl %ax,%eax
80108aac:	09 c2                	or     %eax,%edx
80108aae:	8b 45 10             	mov    0x10(%ebp),%eax
80108ab1:	c1 e0 08             	shl    $0x8,%eax
80108ab4:	25 00 07 00 00       	and    $0x700,%eax
80108ab9:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108abb:	8b 45 14             	mov    0x14(%ebp),%eax
80108abe:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108ac3:	09 d0                	or     %edx,%eax
80108ac5:	0d 00 00 00 80       	or     $0x80000000,%eax
80108aca:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108acd:	ff 75 fc             	push   -0x4(%ebp)
80108ad0:	e8 05 ff ff ff       	call   801089da <pci_write_config>
80108ad5:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108ad8:	ff 75 18             	push   0x18(%ebp)
80108adb:	e8 0b ff ff ff       	call   801089eb <pci_write_data>
80108ae0:	83 c4 04             	add    $0x4,%esp
}
80108ae3:	90                   	nop
80108ae4:	c9                   	leave
80108ae5:	c3                   	ret

80108ae6 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108ae6:	55                   	push   %ebp
80108ae7:	89 e5                	mov    %esp,%ebp
80108ae9:	53                   	push   %ebx
80108aea:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108aed:	8b 45 08             	mov    0x8(%ebp),%eax
80108af0:	a2 98 7a 19 80       	mov    %al,0x80197a98
  dev.device_num = device_num;
80108af5:	8b 45 0c             	mov    0xc(%ebp),%eax
80108af8:	a2 99 7a 19 80       	mov    %al,0x80197a99
  dev.function_num = function_num;
80108afd:	8b 45 10             	mov    0x10(%ebp),%eax
80108b00:	a2 9a 7a 19 80       	mov    %al,0x80197a9a
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108b05:	ff 75 10             	push   0x10(%ebp)
80108b08:	ff 75 0c             	push   0xc(%ebp)
80108b0b:	ff 75 08             	push   0x8(%ebp)
80108b0e:	68 a4 c7 10 80       	push   $0x8010c7a4
80108b13:	e8 dc 78 ff ff       	call   801003f4 <cprintf>
80108b18:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108b1b:	83 ec 0c             	sub    $0xc,%esp
80108b1e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108b21:	50                   	push   %eax
80108b22:	6a 00                	push   $0x0
80108b24:	ff 75 10             	push   0x10(%ebp)
80108b27:	ff 75 0c             	push   0xc(%ebp)
80108b2a:	ff 75 08             	push   0x8(%ebp)
80108b2d:	e8 09 ff ff ff       	call   80108a3b <pci_access_config>
80108b32:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108b35:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b38:	c1 e8 10             	shr    $0x10,%eax
80108b3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108b3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b41:	25 ff ff 00 00       	and    $0xffff,%eax
80108b46:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b4c:	a3 9c 7a 19 80       	mov    %eax,0x80197a9c
  dev.vendor_id = vendor_id;
80108b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b54:	a3 a0 7a 19 80       	mov    %eax,0x80197aa0
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108b59:	83 ec 04             	sub    $0x4,%esp
80108b5c:	ff 75 f0             	push   -0x10(%ebp)
80108b5f:	ff 75 f4             	push   -0xc(%ebp)
80108b62:	68 d8 c7 10 80       	push   $0x8010c7d8
80108b67:	e8 88 78 ff ff       	call   801003f4 <cprintf>
80108b6c:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108b6f:	83 ec 0c             	sub    $0xc,%esp
80108b72:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108b75:	50                   	push   %eax
80108b76:	6a 08                	push   $0x8
80108b78:	ff 75 10             	push   0x10(%ebp)
80108b7b:	ff 75 0c             	push   0xc(%ebp)
80108b7e:	ff 75 08             	push   0x8(%ebp)
80108b81:	e8 b5 fe ff ff       	call   80108a3b <pci_access_config>
80108b86:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108b89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b8c:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108b8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b92:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108b95:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108b98:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b9b:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108b9e:	0f b6 c0             	movzbl %al,%eax
80108ba1:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108ba4:	c1 eb 18             	shr    $0x18,%ebx
80108ba7:	83 ec 0c             	sub    $0xc,%esp
80108baa:	51                   	push   %ecx
80108bab:	52                   	push   %edx
80108bac:	50                   	push   %eax
80108bad:	53                   	push   %ebx
80108bae:	68 fc c7 10 80       	push   $0x8010c7fc
80108bb3:	e8 3c 78 ff ff       	call   801003f4 <cprintf>
80108bb8:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108bbb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bbe:	c1 e8 18             	shr    $0x18,%eax
80108bc1:	a2 a4 7a 19 80       	mov    %al,0x80197aa4
  dev.sub_class = (data>>16)&0xFF;
80108bc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bc9:	c1 e8 10             	shr    $0x10,%eax
80108bcc:	a2 a5 7a 19 80       	mov    %al,0x80197aa5
  dev.interface = (data>>8)&0xFF;
80108bd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bd4:	c1 e8 08             	shr    $0x8,%eax
80108bd7:	a2 a6 7a 19 80       	mov    %al,0x80197aa6
  dev.revision_id = data&0xFF;
80108bdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bdf:	a2 a7 7a 19 80       	mov    %al,0x80197aa7
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108be4:	83 ec 0c             	sub    $0xc,%esp
80108be7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108bea:	50                   	push   %eax
80108beb:	6a 10                	push   $0x10
80108bed:	ff 75 10             	push   0x10(%ebp)
80108bf0:	ff 75 0c             	push   0xc(%ebp)
80108bf3:	ff 75 08             	push   0x8(%ebp)
80108bf6:	e8 40 fe ff ff       	call   80108a3b <pci_access_config>
80108bfb:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108bfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c01:	a3 a8 7a 19 80       	mov    %eax,0x80197aa8
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108c06:	83 ec 0c             	sub    $0xc,%esp
80108c09:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108c0c:	50                   	push   %eax
80108c0d:	6a 14                	push   $0x14
80108c0f:	ff 75 10             	push   0x10(%ebp)
80108c12:	ff 75 0c             	push   0xc(%ebp)
80108c15:	ff 75 08             	push   0x8(%ebp)
80108c18:	e8 1e fe ff ff       	call   80108a3b <pci_access_config>
80108c1d:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108c20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c23:	a3 ac 7a 19 80       	mov    %eax,0x80197aac
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108c28:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108c2f:	75 5a                	jne    80108c8b <pci_init_device+0x1a5>
80108c31:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108c38:	75 51                	jne    80108c8b <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108c3a:	83 ec 0c             	sub    $0xc,%esp
80108c3d:	68 41 c8 10 80       	push   $0x8010c841
80108c42:	e8 ad 77 ff ff       	call   801003f4 <cprintf>
80108c47:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108c4a:	83 ec 0c             	sub    $0xc,%esp
80108c4d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108c50:	50                   	push   %eax
80108c51:	68 f0 00 00 00       	push   $0xf0
80108c56:	ff 75 10             	push   0x10(%ebp)
80108c59:	ff 75 0c             	push   0xc(%ebp)
80108c5c:	ff 75 08             	push   0x8(%ebp)
80108c5f:	e8 d7 fd ff ff       	call   80108a3b <pci_access_config>
80108c64:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108c67:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c6a:	83 ec 08             	sub    $0x8,%esp
80108c6d:	50                   	push   %eax
80108c6e:	68 5b c8 10 80       	push   $0x8010c85b
80108c73:	e8 7c 77 ff ff       	call   801003f4 <cprintf>
80108c78:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108c7b:	83 ec 0c             	sub    $0xc,%esp
80108c7e:	68 98 7a 19 80       	push   $0x80197a98
80108c83:	e8 09 00 00 00       	call   80108c91 <i8254_init>
80108c88:	83 c4 10             	add    $0x10,%esp
  }
}
80108c8b:	90                   	nop
80108c8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c8f:	c9                   	leave
80108c90:	c3                   	ret

80108c91 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108c91:	55                   	push   %ebp
80108c92:	89 e5                	mov    %esp,%ebp
80108c94:	53                   	push   %ebx
80108c95:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108c98:	8b 45 08             	mov    0x8(%ebp),%eax
80108c9b:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108c9f:	0f b6 c8             	movzbl %al,%ecx
80108ca2:	8b 45 08             	mov    0x8(%ebp),%eax
80108ca5:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108ca9:	0f b6 d0             	movzbl %al,%edx
80108cac:	8b 45 08             	mov    0x8(%ebp),%eax
80108caf:	0f b6 00             	movzbl (%eax),%eax
80108cb2:	0f b6 c0             	movzbl %al,%eax
80108cb5:	83 ec 0c             	sub    $0xc,%esp
80108cb8:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108cbb:	53                   	push   %ebx
80108cbc:	6a 04                	push   $0x4
80108cbe:	51                   	push   %ecx
80108cbf:	52                   	push   %edx
80108cc0:	50                   	push   %eax
80108cc1:	e8 75 fd ff ff       	call   80108a3b <pci_access_config>
80108cc6:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108cc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ccc:	83 c8 04             	or     $0x4,%eax
80108ccf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108cd2:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108cd5:	8b 45 08             	mov    0x8(%ebp),%eax
80108cd8:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108cdc:	0f b6 c8             	movzbl %al,%ecx
80108cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80108ce2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108ce6:	0f b6 d0             	movzbl %al,%edx
80108ce9:	8b 45 08             	mov    0x8(%ebp),%eax
80108cec:	0f b6 00             	movzbl (%eax),%eax
80108cef:	0f b6 c0             	movzbl %al,%eax
80108cf2:	83 ec 0c             	sub    $0xc,%esp
80108cf5:	53                   	push   %ebx
80108cf6:	6a 04                	push   $0x4
80108cf8:	51                   	push   %ecx
80108cf9:	52                   	push   %edx
80108cfa:	50                   	push   %eax
80108cfb:	e8 90 fd ff ff       	call   80108a90 <pci_write_config_register>
80108d00:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108d03:	8b 45 08             	mov    0x8(%ebp),%eax
80108d06:	8b 40 10             	mov    0x10(%eax),%eax
80108d09:	05 00 00 00 40       	add    $0x40000000,%eax
80108d0e:	a3 b0 7a 19 80       	mov    %eax,0x80197ab0
  uint *ctrl = (uint *)base_addr;
80108d13:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108d18:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108d1b:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108d20:	05 d8 00 00 00       	add    $0xd8,%eax
80108d25:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d2b:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d34:	8b 00                	mov    (%eax),%eax
80108d36:	0d 00 00 00 04       	or     $0x4000000,%eax
80108d3b:	89 c2                	mov    %eax,%edx
80108d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d40:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108d42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d45:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d4e:	8b 00                	mov    (%eax),%eax
80108d50:	83 c8 40             	or     $0x40,%eax
80108d53:	89 c2                	mov    %eax,%edx
80108d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d58:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d5d:	8b 10                	mov    (%eax),%edx
80108d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d62:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108d64:	83 ec 0c             	sub    $0xc,%esp
80108d67:	68 70 c8 10 80       	push   $0x8010c870
80108d6c:	e8 83 76 ff ff       	call   801003f4 <cprintf>
80108d71:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108d74:	e8 2f 9a ff ff       	call   801027a8 <kalloc>
80108d79:	a3 bc 7a 19 80       	mov    %eax,0x80197abc
  *intr_addr = 0;
80108d7e:	a1 bc 7a 19 80       	mov    0x80197abc,%eax
80108d83:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108d89:	a1 bc 7a 19 80       	mov    0x80197abc,%eax
80108d8e:	83 ec 08             	sub    $0x8,%esp
80108d91:	50                   	push   %eax
80108d92:	68 92 c8 10 80       	push   $0x8010c892
80108d97:	e8 58 76 ff ff       	call   801003f4 <cprintf>
80108d9c:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108d9f:	e8 50 00 00 00       	call   80108df4 <i8254_init_recv>
  i8254_init_send();
80108da4:	e8 69 03 00 00       	call   80109112 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108da9:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108db0:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108db3:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108dba:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108dbd:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108dc4:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108dc7:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108dce:	0f b6 c0             	movzbl %al,%eax
80108dd1:	83 ec 0c             	sub    $0xc,%esp
80108dd4:	53                   	push   %ebx
80108dd5:	51                   	push   %ecx
80108dd6:	52                   	push   %edx
80108dd7:	50                   	push   %eax
80108dd8:	68 a0 c8 10 80       	push   $0x8010c8a0
80108ddd:	e8 12 76 ff ff       	call   801003f4 <cprintf>
80108de2:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108de8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108dee:	90                   	nop
80108def:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108df2:	c9                   	leave
80108df3:	c3                   	ret

80108df4 <i8254_init_recv>:

void i8254_init_recv(){
80108df4:	55                   	push   %ebp
80108df5:	89 e5                	mov    %esp,%ebp
80108df7:	57                   	push   %edi
80108df8:	56                   	push   %esi
80108df9:	53                   	push   %ebx
80108dfa:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108dfd:	83 ec 0c             	sub    $0xc,%esp
80108e00:	6a 00                	push   $0x0
80108e02:	e8 e8 04 00 00       	call   801092ef <i8254_read_eeprom>
80108e07:	83 c4 10             	add    $0x10,%esp
80108e0a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108e0d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108e10:	a2 b4 7a 19 80       	mov    %al,0x80197ab4
  mac_addr[1] = data_l>>8;
80108e15:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108e18:	c1 e8 08             	shr    $0x8,%eax
80108e1b:	a2 b5 7a 19 80       	mov    %al,0x80197ab5
  uint data_m = i8254_read_eeprom(0x1);
80108e20:	83 ec 0c             	sub    $0xc,%esp
80108e23:	6a 01                	push   $0x1
80108e25:	e8 c5 04 00 00       	call   801092ef <i8254_read_eeprom>
80108e2a:	83 c4 10             	add    $0x10,%esp
80108e2d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108e30:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e33:	a2 b6 7a 19 80       	mov    %al,0x80197ab6
  mac_addr[3] = data_m>>8;
80108e38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e3b:	c1 e8 08             	shr    $0x8,%eax
80108e3e:	a2 b7 7a 19 80       	mov    %al,0x80197ab7
  uint data_h = i8254_read_eeprom(0x2);
80108e43:	83 ec 0c             	sub    $0xc,%esp
80108e46:	6a 02                	push   $0x2
80108e48:	e8 a2 04 00 00       	call   801092ef <i8254_read_eeprom>
80108e4d:	83 c4 10             	add    $0x10,%esp
80108e50:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108e53:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e56:	a2 b8 7a 19 80       	mov    %al,0x80197ab8
  mac_addr[5] = data_h>>8;
80108e5b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e5e:	c1 e8 08             	shr    $0x8,%eax
80108e61:	a2 b9 7a 19 80       	mov    %al,0x80197ab9
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108e66:	0f b6 05 b9 7a 19 80 	movzbl 0x80197ab9,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e6d:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108e70:	0f b6 05 b8 7a 19 80 	movzbl 0x80197ab8,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e77:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108e7a:	0f b6 05 b7 7a 19 80 	movzbl 0x80197ab7,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e81:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108e84:	0f b6 05 b6 7a 19 80 	movzbl 0x80197ab6,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e8b:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108e8e:	0f b6 05 b5 7a 19 80 	movzbl 0x80197ab5,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e95:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108e98:	0f b6 05 b4 7a 19 80 	movzbl 0x80197ab4,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e9f:	0f b6 c0             	movzbl %al,%eax
80108ea2:	83 ec 04             	sub    $0x4,%esp
80108ea5:	57                   	push   %edi
80108ea6:	56                   	push   %esi
80108ea7:	53                   	push   %ebx
80108ea8:	51                   	push   %ecx
80108ea9:	52                   	push   %edx
80108eaa:	50                   	push   %eax
80108eab:	68 b8 c8 10 80       	push   $0x8010c8b8
80108eb0:	e8 3f 75 ff ff       	call   801003f4 <cprintf>
80108eb5:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108eb8:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108ebd:	05 00 54 00 00       	add    $0x5400,%eax
80108ec2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108ec5:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108eca:	05 04 54 00 00       	add    $0x5404,%eax
80108ecf:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108ed2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108ed5:	c1 e0 10             	shl    $0x10,%eax
80108ed8:	0b 45 d8             	or     -0x28(%ebp),%eax
80108edb:	89 c2                	mov    %eax,%edx
80108edd:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108ee0:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108ee2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ee5:	0d 00 00 00 80       	or     $0x80000000,%eax
80108eea:	89 c2                	mov    %eax,%edx
80108eec:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108eef:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108ef1:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108ef6:	05 00 52 00 00       	add    $0x5200,%eax
80108efb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108efe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108f05:	eb 19                	jmp    80108f20 <i8254_init_recv+0x12c>
    mta[i] = 0;
80108f07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f0a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f11:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108f14:	01 d0                	add    %edx,%eax
80108f16:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108f1c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108f20:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108f24:	7e e1                	jle    80108f07 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108f26:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108f2b:	05 d0 00 00 00       	add    $0xd0,%eax
80108f30:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108f33:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108f36:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108f3c:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108f41:	05 c8 00 00 00       	add    $0xc8,%eax
80108f46:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108f49:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108f4c:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108f52:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108f57:	05 28 28 00 00       	add    $0x2828,%eax
80108f5c:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108f5f:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108f62:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108f68:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108f6d:	05 00 01 00 00       	add    $0x100,%eax
80108f72:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108f75:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108f78:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108f7e:	e8 25 98 ff ff       	call   801027a8 <kalloc>
80108f83:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108f86:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108f8b:	05 00 28 00 00       	add    $0x2800,%eax
80108f90:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108f93:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108f98:	05 04 28 00 00       	add    $0x2804,%eax
80108f9d:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108fa0:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108fa5:	05 08 28 00 00       	add    $0x2808,%eax
80108faa:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108fad:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108fb2:	05 10 28 00 00       	add    $0x2810,%eax
80108fb7:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108fba:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80108fbf:	05 18 28 00 00       	add    $0x2818,%eax
80108fc4:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108fc7:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108fca:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108fd0:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108fd3:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108fd5:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108fd8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108fde:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108fe1:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108fe7:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108fea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108ff0:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108ff3:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108ff9:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108ffc:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108fff:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109006:	eb 73                	jmp    8010907b <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80109008:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010900b:	c1 e0 04             	shl    $0x4,%eax
8010900e:	89 c2                	mov    %eax,%edx
80109010:	8b 45 98             	mov    -0x68(%ebp),%eax
80109013:	01 d0                	add    %edx,%eax
80109015:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
8010901c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010901f:	c1 e0 04             	shl    $0x4,%eax
80109022:	89 c2                	mov    %eax,%edx
80109024:	8b 45 98             	mov    -0x68(%ebp),%eax
80109027:	01 d0                	add    %edx,%eax
80109029:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
8010902f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109032:	c1 e0 04             	shl    $0x4,%eax
80109035:	89 c2                	mov    %eax,%edx
80109037:	8b 45 98             	mov    -0x68(%ebp),%eax
8010903a:	01 d0                	add    %edx,%eax
8010903c:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80109042:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109045:	c1 e0 04             	shl    $0x4,%eax
80109048:	89 c2                	mov    %eax,%edx
8010904a:	8b 45 98             	mov    -0x68(%ebp),%eax
8010904d:	01 d0                	add    %edx,%eax
8010904f:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80109053:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109056:	c1 e0 04             	shl    $0x4,%eax
80109059:	89 c2                	mov    %eax,%edx
8010905b:	8b 45 98             	mov    -0x68(%ebp),%eax
8010905e:	01 d0                	add    %edx,%eax
80109060:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80109064:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109067:	c1 e0 04             	shl    $0x4,%eax
8010906a:	89 c2                	mov    %eax,%edx
8010906c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010906f:	01 d0                	add    %edx,%eax
80109071:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80109077:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
8010907b:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80109082:	7e 84                	jle    80109008 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80109084:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
8010908b:	eb 57                	jmp    801090e4 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
8010908d:	e8 16 97 ff ff       	call   801027a8 <kalloc>
80109092:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80109095:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80109099:	75 12                	jne    801090ad <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
8010909b:	83 ec 0c             	sub    $0xc,%esp
8010909e:	68 d8 c8 10 80       	push   $0x8010c8d8
801090a3:	e8 4c 73 ff ff       	call   801003f4 <cprintf>
801090a8:	83 c4 10             	add    $0x10,%esp
      break;
801090ab:	eb 3d                	jmp    801090ea <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
801090ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
801090b0:	c1 e0 04             	shl    $0x4,%eax
801090b3:	89 c2                	mov    %eax,%edx
801090b5:	8b 45 98             	mov    -0x68(%ebp),%eax
801090b8:	01 d0                	add    %edx,%eax
801090ba:	8b 55 94             	mov    -0x6c(%ebp),%edx
801090bd:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801090c3:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801090c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801090c8:	83 c0 01             	add    $0x1,%eax
801090cb:	c1 e0 04             	shl    $0x4,%eax
801090ce:	89 c2                	mov    %eax,%edx
801090d0:	8b 45 98             	mov    -0x68(%ebp),%eax
801090d3:	01 d0                	add    %edx,%eax
801090d5:	8b 55 94             	mov    -0x6c(%ebp),%edx
801090d8:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801090de:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801090e0:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801090e4:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801090e8:	7e a3                	jle    8010908d <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
801090ea:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801090ed:	8b 00                	mov    (%eax),%eax
801090ef:	83 c8 02             	or     $0x2,%eax
801090f2:	89 c2                	mov    %eax,%edx
801090f4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801090f7:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801090f9:	83 ec 0c             	sub    $0xc,%esp
801090fc:	68 f8 c8 10 80       	push   $0x8010c8f8
80109101:	e8 ee 72 ff ff       	call   801003f4 <cprintf>
80109106:	83 c4 10             	add    $0x10,%esp
}
80109109:	90                   	nop
8010910a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010910d:	5b                   	pop    %ebx
8010910e:	5e                   	pop    %esi
8010910f:	5f                   	pop    %edi
80109110:	5d                   	pop    %ebp
80109111:	c3                   	ret

80109112 <i8254_init_send>:

void i8254_init_send(){
80109112:	55                   	push   %ebp
80109113:	89 e5                	mov    %esp,%ebp
80109115:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80109118:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010911d:	05 28 38 00 00       	add    $0x3828,%eax
80109122:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80109125:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109128:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
8010912e:	e8 75 96 ff ff       	call   801027a8 <kalloc>
80109133:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109136:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010913b:	05 00 38 00 00       	add    $0x3800,%eax
80109140:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80109143:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109148:	05 04 38 00 00       	add    $0x3804,%eax
8010914d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80109150:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109155:	05 08 38 00 00       	add    $0x3808,%eax
8010915a:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
8010915d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109160:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80109166:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109169:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
8010916b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010916e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80109174:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109177:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
8010917d:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109182:	05 10 38 00 00       	add    $0x3810,%eax
80109187:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
8010918a:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010918f:	05 18 38 00 00       	add    $0x3818,%eax
80109194:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80109197:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010919a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
801091a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801091a3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
801091a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801091af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801091b6:	e9 82 00 00 00       	jmp    8010923d <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
801091bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091be:	c1 e0 04             	shl    $0x4,%eax
801091c1:	89 c2                	mov    %eax,%edx
801091c3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091c6:	01 d0                	add    %edx,%eax
801091c8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
801091cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091d2:	c1 e0 04             	shl    $0x4,%eax
801091d5:	89 c2                	mov    %eax,%edx
801091d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091da:	01 d0                	add    %edx,%eax
801091dc:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
801091e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091e5:	c1 e0 04             	shl    $0x4,%eax
801091e8:	89 c2                	mov    %eax,%edx
801091ea:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091ed:	01 d0                	add    %edx,%eax
801091ef:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801091f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f6:	c1 e0 04             	shl    $0x4,%eax
801091f9:	89 c2                	mov    %eax,%edx
801091fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091fe:	01 d0                	add    %edx,%eax
80109200:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80109204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109207:	c1 e0 04             	shl    $0x4,%eax
8010920a:	89 c2                	mov    %eax,%edx
8010920c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010920f:	01 d0                	add    %edx,%eax
80109211:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80109215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109218:	c1 e0 04             	shl    $0x4,%eax
8010921b:	89 c2                	mov    %eax,%edx
8010921d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109220:	01 d0                	add    %edx,%eax
80109222:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80109226:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109229:	c1 e0 04             	shl    $0x4,%eax
8010922c:	89 c2                	mov    %eax,%edx
8010922e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109231:	01 d0                	add    %edx,%eax
80109233:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109239:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010923d:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109244:	0f 8e 71 ff ff ff    	jle    801091bb <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
8010924a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109251:	eb 57                	jmp    801092aa <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80109253:	e8 50 95 ff ff       	call   801027a8 <kalloc>
80109258:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
8010925b:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
8010925f:	75 12                	jne    80109273 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80109261:	83 ec 0c             	sub    $0xc,%esp
80109264:	68 d8 c8 10 80       	push   $0x8010c8d8
80109269:	e8 86 71 ff ff       	call   801003f4 <cprintf>
8010926e:	83 c4 10             	add    $0x10,%esp
      break;
80109271:	eb 3d                	jmp    801092b0 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80109273:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109276:	c1 e0 04             	shl    $0x4,%eax
80109279:	89 c2                	mov    %eax,%edx
8010927b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010927e:	01 d0                	add    %edx,%eax
80109280:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109283:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109289:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010928b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010928e:	83 c0 01             	add    $0x1,%eax
80109291:	c1 e0 04             	shl    $0x4,%eax
80109294:	89 c2                	mov    %eax,%edx
80109296:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109299:	01 d0                	add    %edx,%eax
8010929b:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010929e:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801092a4:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801092a6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801092aa:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801092ae:	7e a3                	jle    80109253 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
801092b0:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801092b5:	05 00 04 00 00       	add    $0x400,%eax
801092ba:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
801092bd:	8b 45 c8             	mov    -0x38(%ebp),%eax
801092c0:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
801092c6:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801092cb:	05 10 04 00 00       	add    $0x410,%eax
801092d0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
801092d3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801092d6:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
801092dc:	83 ec 0c             	sub    $0xc,%esp
801092df:	68 18 c9 10 80       	push   $0x8010c918
801092e4:	e8 0b 71 ff ff       	call   801003f4 <cprintf>
801092e9:	83 c4 10             	add    $0x10,%esp

}
801092ec:	90                   	nop
801092ed:	c9                   	leave
801092ee:	c3                   	ret

801092ef <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
801092ef:	55                   	push   %ebp
801092f0:	89 e5                	mov    %esp,%ebp
801092f2:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
801092f5:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801092fa:	83 c0 14             	add    $0x14,%eax
801092fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80109300:	8b 45 08             	mov    0x8(%ebp),%eax
80109303:	c1 e0 08             	shl    $0x8,%eax
80109306:	0f b7 c0             	movzwl %ax,%eax
80109309:	83 c8 01             	or     $0x1,%eax
8010930c:	89 c2                	mov    %eax,%edx
8010930e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109311:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80109313:	83 ec 0c             	sub    $0xc,%esp
80109316:	68 38 c9 10 80       	push   $0x8010c938
8010931b:	e8 d4 70 ff ff       	call   801003f4 <cprintf>
80109320:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80109323:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109326:	8b 00                	mov    (%eax),%eax
80109328:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
8010932b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010932e:	83 e0 10             	and    $0x10,%eax
80109331:	85 c0                	test   %eax,%eax
80109333:	75 02                	jne    80109337 <i8254_read_eeprom+0x48>
  while(1){
80109335:	eb dc                	jmp    80109313 <i8254_read_eeprom+0x24>
      break;
80109337:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80109338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010933b:	8b 00                	mov    (%eax),%eax
8010933d:	c1 e8 10             	shr    $0x10,%eax
}
80109340:	c9                   	leave
80109341:	c3                   	ret

80109342 <i8254_recv>:
void i8254_recv(){
80109342:	55                   	push   %ebp
80109343:	89 e5                	mov    %esp,%ebp
80109345:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80109348:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010934d:	05 10 28 00 00       	add    $0x2810,%eax
80109352:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109355:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
8010935a:	05 18 28 00 00       	add    $0x2818,%eax
8010935f:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109362:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109367:	05 00 28 00 00       	add    $0x2800,%eax
8010936c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
8010936f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109372:	8b 00                	mov    (%eax),%eax
80109374:	05 00 00 00 80       	add    $0x80000000,%eax
80109379:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
8010937c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010937f:	8b 10                	mov    (%eax),%edx
80109381:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109384:	8b 00                	mov    (%eax),%eax
80109386:	29 c2                	sub    %eax,%edx
80109388:	89 d0                	mov    %edx,%eax
8010938a:	25 ff 00 00 00       	and    $0xff,%eax
8010938f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109392:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109396:	7e 37                	jle    801093cf <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109398:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010939b:	8b 00                	mov    (%eax),%eax
8010939d:	c1 e0 04             	shl    $0x4,%eax
801093a0:	89 c2                	mov    %eax,%edx
801093a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093a5:	01 d0                	add    %edx,%eax
801093a7:	8b 00                	mov    (%eax),%eax
801093a9:	05 00 00 00 80       	add    $0x80000000,%eax
801093ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
801093b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093b4:	8b 00                	mov    (%eax),%eax
801093b6:	83 c0 01             	add    $0x1,%eax
801093b9:	0f b6 d0             	movzbl %al,%edx
801093bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093bf:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
801093c1:	83 ec 0c             	sub    $0xc,%esp
801093c4:	ff 75 e0             	push   -0x20(%ebp)
801093c7:	e8 13 09 00 00       	call   80109cdf <eth_proc>
801093cc:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
801093cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093d2:	8b 10                	mov    (%eax),%edx
801093d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093d7:	8b 00                	mov    (%eax),%eax
801093d9:	39 c2                	cmp    %eax,%edx
801093db:	75 9f                	jne    8010937c <i8254_recv+0x3a>
      (*rdt)--;
801093dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093e0:	8b 00                	mov    (%eax),%eax
801093e2:	8d 50 ff             	lea    -0x1(%eax),%edx
801093e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093e8:	89 10                	mov    %edx,(%eax)
  while(1){
801093ea:	eb 90                	jmp    8010937c <i8254_recv+0x3a>

801093ec <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
801093ec:	55                   	push   %ebp
801093ed:	89 e5                	mov    %esp,%ebp
801093ef:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
801093f2:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
801093f7:	05 10 38 00 00       	add    $0x3810,%eax
801093fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801093ff:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109404:	05 18 38 00 00       	add    $0x3818,%eax
80109409:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010940c:	a1 b0 7a 19 80       	mov    0x80197ab0,%eax
80109411:	05 00 38 00 00       	add    $0x3800,%eax
80109416:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80109419:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010941c:	8b 00                	mov    (%eax),%eax
8010941e:	05 00 00 00 80       	add    $0x80000000,%eax
80109423:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109426:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109429:	8b 10                	mov    (%eax),%edx
8010942b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010942e:	8b 00                	mov    (%eax),%eax
80109430:	29 c2                	sub    %eax,%edx
80109432:	0f b6 c2             	movzbl %dl,%eax
80109435:	ba 00 01 00 00       	mov    $0x100,%edx
8010943a:	29 c2                	sub    %eax,%edx
8010943c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
8010943f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109442:	8b 00                	mov    (%eax),%eax
80109444:	25 ff 00 00 00       	and    $0xff,%eax
80109449:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
8010944c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109450:	0f 8e a8 00 00 00    	jle    801094fe <i8254_send+0x112>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109456:	8b 45 08             	mov    0x8(%ebp),%eax
80109459:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010945c:	89 d1                	mov    %edx,%ecx
8010945e:	c1 e1 04             	shl    $0x4,%ecx
80109461:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109464:	01 ca                	add    %ecx,%edx
80109466:	8b 12                	mov    (%edx),%edx
80109468:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010946e:	83 ec 04             	sub    $0x4,%esp
80109471:	ff 75 0c             	push   0xc(%ebp)
80109474:	50                   	push   %eax
80109475:	52                   	push   %edx
80109476:	e8 74 be ff ff       	call   801052ef <memmove>
8010947b:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
8010947e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109481:	c1 e0 04             	shl    $0x4,%eax
80109484:	89 c2                	mov    %eax,%edx
80109486:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109489:	01 d0                	add    %edx,%eax
8010948b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010948e:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109492:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109495:	c1 e0 04             	shl    $0x4,%eax
80109498:	89 c2                	mov    %eax,%edx
8010949a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010949d:	01 d0                	add    %edx,%eax
8010949f:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
801094a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801094a6:	c1 e0 04             	shl    $0x4,%eax
801094a9:	89 c2                	mov    %eax,%edx
801094ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
801094ae:	01 d0                	add    %edx,%eax
801094b0:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801094b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801094b7:	c1 e0 04             	shl    $0x4,%eax
801094ba:	89 c2                	mov    %eax,%edx
801094bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801094bf:	01 d0                	add    %edx,%eax
801094c1:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
801094c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801094c8:	c1 e0 04             	shl    $0x4,%eax
801094cb:	89 c2                	mov    %eax,%edx
801094cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801094d0:	01 d0                	add    %edx,%eax
801094d2:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
801094d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801094db:	c1 e0 04             	shl    $0x4,%eax
801094de:	89 c2                	mov    %eax,%edx
801094e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801094e3:	01 d0                	add    %edx,%eax
801094e5:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
801094e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094ec:	8b 00                	mov    (%eax),%eax
801094ee:	83 c0 01             	add    $0x1,%eax
801094f1:	0f b6 d0             	movzbl %al,%edx
801094f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094f7:	89 10                	mov    %edx,(%eax)
    return len;
801094f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801094fc:	eb 05                	jmp    80109503 <i8254_send+0x117>
  }else{
    return -1;
801094fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109503:	c9                   	leave
80109504:	c3                   	ret

80109505 <i8254_intr>:

void i8254_intr(){
80109505:	55                   	push   %ebp
80109506:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109508:	a1 bc 7a 19 80       	mov    0x80197abc,%eax
8010950d:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109513:	90                   	nop
80109514:	5d                   	pop    %ebp
80109515:	c3                   	ret

80109516 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109516:	55                   	push   %ebp
80109517:	89 e5                	mov    %esp,%ebp
80109519:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
8010951c:	8b 45 08             	mov    0x8(%ebp),%eax
8010951f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109525:	0f b7 00             	movzwl (%eax),%eax
80109528:	66 3d 00 01          	cmp    $0x100,%ax
8010952c:	74 0a                	je     80109538 <arp_proc+0x22>
8010952e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109533:	e9 4f 01 00 00       	jmp    80109687 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010953b:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010953f:	66 83 f8 08          	cmp    $0x8,%ax
80109543:	74 0a                	je     8010954f <arp_proc+0x39>
80109545:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010954a:	e9 38 01 00 00       	jmp    80109687 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
8010954f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109552:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109556:	3c 06                	cmp    $0x6,%al
80109558:	74 0a                	je     80109564 <arp_proc+0x4e>
8010955a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010955f:	e9 23 01 00 00       	jmp    80109687 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80109564:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109567:	0f b6 40 05          	movzbl 0x5(%eax),%eax
8010956b:	3c 04                	cmp    $0x4,%al
8010956d:	74 0a                	je     80109579 <arp_proc+0x63>
8010956f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109574:	e9 0e 01 00 00       	jmp    80109687 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010957c:	83 c0 18             	add    $0x18,%eax
8010957f:	83 ec 04             	sub    $0x4,%esp
80109582:	6a 04                	push   $0x4
80109584:	50                   	push   %eax
80109585:	68 04 f5 10 80       	push   $0x8010f504
8010958a:	e8 08 bd ff ff       	call   80105297 <memcmp>
8010958f:	83 c4 10             	add    $0x10,%esp
80109592:	85 c0                	test   %eax,%eax
80109594:	74 27                	je     801095bd <arp_proc+0xa7>
80109596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109599:	83 c0 0e             	add    $0xe,%eax
8010959c:	83 ec 04             	sub    $0x4,%esp
8010959f:	6a 04                	push   $0x4
801095a1:	50                   	push   %eax
801095a2:	68 04 f5 10 80       	push   $0x8010f504
801095a7:	e8 eb bc ff ff       	call   80105297 <memcmp>
801095ac:	83 c4 10             	add    $0x10,%esp
801095af:	85 c0                	test   %eax,%eax
801095b1:	74 0a                	je     801095bd <arp_proc+0xa7>
801095b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801095b8:	e9 ca 00 00 00       	jmp    80109687 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801095bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095c0:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801095c4:	66 3d 00 01          	cmp    $0x100,%ax
801095c8:	75 69                	jne    80109633 <arp_proc+0x11d>
801095ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095cd:	83 c0 18             	add    $0x18,%eax
801095d0:	83 ec 04             	sub    $0x4,%esp
801095d3:	6a 04                	push   $0x4
801095d5:	50                   	push   %eax
801095d6:	68 04 f5 10 80       	push   $0x8010f504
801095db:	e8 b7 bc ff ff       	call   80105297 <memcmp>
801095e0:	83 c4 10             	add    $0x10,%esp
801095e3:	85 c0                	test   %eax,%eax
801095e5:	75 4c                	jne    80109633 <arp_proc+0x11d>
    uint send = (uint)kalloc();
801095e7:	e8 bc 91 ff ff       	call   801027a8 <kalloc>
801095ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801095ef:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801095f6:	83 ec 04             	sub    $0x4,%esp
801095f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801095fc:	50                   	push   %eax
801095fd:	ff 75 f0             	push   -0x10(%ebp)
80109600:	ff 75 f4             	push   -0xc(%ebp)
80109603:	e8 1f 04 00 00       	call   80109a27 <arp_reply_pkt_create>
80109608:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
8010960b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010960e:	83 ec 08             	sub    $0x8,%esp
80109611:	50                   	push   %eax
80109612:	ff 75 f0             	push   -0x10(%ebp)
80109615:	e8 d2 fd ff ff       	call   801093ec <i8254_send>
8010961a:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
8010961d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109620:	83 ec 0c             	sub    $0xc,%esp
80109623:	50                   	push   %eax
80109624:	e8 e5 90 ff ff       	call   8010270e <kfree>
80109629:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010962c:	b8 02 00 00 00       	mov    $0x2,%eax
80109631:	eb 54                	jmp    80109687 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109636:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010963a:	66 3d 00 02          	cmp    $0x200,%ax
8010963e:	75 42                	jne    80109682 <arp_proc+0x16c>
80109640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109643:	83 c0 18             	add    $0x18,%eax
80109646:	83 ec 04             	sub    $0x4,%esp
80109649:	6a 04                	push   $0x4
8010964b:	50                   	push   %eax
8010964c:	68 04 f5 10 80       	push   $0x8010f504
80109651:	e8 41 bc ff ff       	call   80105297 <memcmp>
80109656:	83 c4 10             	add    $0x10,%esp
80109659:	85 c0                	test   %eax,%eax
8010965b:	75 25                	jne    80109682 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
8010965d:	83 ec 0c             	sub    $0xc,%esp
80109660:	68 3c c9 10 80       	push   $0x8010c93c
80109665:	e8 8a 6d ff ff       	call   801003f4 <cprintf>
8010966a:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010966d:	83 ec 0c             	sub    $0xc,%esp
80109670:	ff 75 f4             	push   -0xc(%ebp)
80109673:	e8 af 01 00 00       	call   80109827 <arp_table_update>
80109678:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
8010967b:	b8 01 00 00 00       	mov    $0x1,%eax
80109680:	eb 05                	jmp    80109687 <arp_proc+0x171>
  }else{
    return -1;
80109682:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109687:	c9                   	leave
80109688:	c3                   	ret

80109689 <arp_scan>:

void arp_scan(){
80109689:	55                   	push   %ebp
8010968a:	89 e5                	mov    %esp,%ebp
8010968c:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
8010968f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109696:	eb 6f                	jmp    80109707 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80109698:	e8 0b 91 ff ff       	call   801027a8 <kalloc>
8010969d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801096a0:	83 ec 04             	sub    $0x4,%esp
801096a3:	ff 75 f4             	push   -0xc(%ebp)
801096a6:	8d 45 e8             	lea    -0x18(%ebp),%eax
801096a9:	50                   	push   %eax
801096aa:	ff 75 ec             	push   -0x14(%ebp)
801096ad:	e8 62 00 00 00       	call   80109714 <arp_broadcast>
801096b2:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
801096b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096b8:	83 ec 08             	sub    $0x8,%esp
801096bb:	50                   	push   %eax
801096bc:	ff 75 ec             	push   -0x14(%ebp)
801096bf:	e8 28 fd ff ff       	call   801093ec <i8254_send>
801096c4:	83 c4 10             	add    $0x10,%esp
801096c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801096ca:	eb 22                	jmp    801096ee <arp_scan+0x65>
      microdelay(1);
801096cc:	83 ec 0c             	sub    $0xc,%esp
801096cf:	6a 01                	push   $0x1
801096d1:	e8 63 94 ff ff       	call   80102b39 <microdelay>
801096d6:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
801096d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096dc:	83 ec 08             	sub    $0x8,%esp
801096df:	50                   	push   %eax
801096e0:	ff 75 ec             	push   -0x14(%ebp)
801096e3:	e8 04 fd ff ff       	call   801093ec <i8254_send>
801096e8:	83 c4 10             	add    $0x10,%esp
801096eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801096ee:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801096f2:	74 d8                	je     801096cc <arp_scan+0x43>
    }
    kfree((char *)send);
801096f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801096f7:	83 ec 0c             	sub    $0xc,%esp
801096fa:	50                   	push   %eax
801096fb:	e8 0e 90 ff ff       	call   8010270e <kfree>
80109700:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109703:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109707:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010970e:	7e 88                	jle    80109698 <arp_scan+0xf>
  }
}
80109710:	90                   	nop
80109711:	90                   	nop
80109712:	c9                   	leave
80109713:	c3                   	ret

80109714 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109714:	55                   	push   %ebp
80109715:	89 e5                	mov    %esp,%ebp
80109717:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
8010971a:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
8010971e:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109722:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109726:	8b 45 10             	mov    0x10(%ebp),%eax
80109729:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
8010972c:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109733:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109739:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109740:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109746:	8b 45 0c             	mov    0xc(%ebp),%eax
80109749:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010974f:	8b 45 08             	mov    0x8(%ebp),%eax
80109752:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109755:	8b 45 08             	mov    0x8(%ebp),%eax
80109758:	83 c0 0e             	add    $0xe,%eax
8010975b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
8010975e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109761:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109768:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
8010976c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010976f:	83 ec 04             	sub    $0x4,%esp
80109772:	6a 06                	push   $0x6
80109774:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109777:	52                   	push   %edx
80109778:	50                   	push   %eax
80109779:	e8 71 bb ff ff       	call   801052ef <memmove>
8010977e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109781:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109784:	83 c0 06             	add    $0x6,%eax
80109787:	83 ec 04             	sub    $0x4,%esp
8010978a:	6a 06                	push   $0x6
8010978c:	68 b4 7a 19 80       	push   $0x80197ab4
80109791:	50                   	push   %eax
80109792:	e8 58 bb ff ff       	call   801052ef <memmove>
80109797:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010979a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010979d:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801097a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097a5:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801097ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097ae:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801097b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097b5:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801097b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097bc:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
801097c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097c5:	8d 50 12             	lea    0x12(%eax),%edx
801097c8:	83 ec 04             	sub    $0x4,%esp
801097cb:	6a 06                	push   $0x6
801097cd:	8d 45 e0             	lea    -0x20(%ebp),%eax
801097d0:	50                   	push   %eax
801097d1:	52                   	push   %edx
801097d2:	e8 18 bb ff ff       	call   801052ef <memmove>
801097d7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
801097da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097dd:	8d 50 18             	lea    0x18(%eax),%edx
801097e0:	83 ec 04             	sub    $0x4,%esp
801097e3:	6a 04                	push   $0x4
801097e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801097e8:	50                   	push   %eax
801097e9:	52                   	push   %edx
801097ea:	e8 00 bb ff ff       	call   801052ef <memmove>
801097ef:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801097f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097f5:	83 c0 08             	add    $0x8,%eax
801097f8:	83 ec 04             	sub    $0x4,%esp
801097fb:	6a 06                	push   $0x6
801097fd:	68 b4 7a 19 80       	push   $0x80197ab4
80109802:	50                   	push   %eax
80109803:	e8 e7 ba ff ff       	call   801052ef <memmove>
80109808:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010980b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010980e:	83 c0 0e             	add    $0xe,%eax
80109811:	83 ec 04             	sub    $0x4,%esp
80109814:	6a 04                	push   $0x4
80109816:	68 04 f5 10 80       	push   $0x8010f504
8010981b:	50                   	push   %eax
8010981c:	e8 ce ba ff ff       	call   801052ef <memmove>
80109821:	83 c4 10             	add    $0x10,%esp
}
80109824:	90                   	nop
80109825:	c9                   	leave
80109826:	c3                   	ret

80109827 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109827:	55                   	push   %ebp
80109828:	89 e5                	mov    %esp,%ebp
8010982a:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
8010982d:	8b 45 08             	mov    0x8(%ebp),%eax
80109830:	83 c0 0e             	add    $0xe,%eax
80109833:	83 ec 0c             	sub    $0xc,%esp
80109836:	50                   	push   %eax
80109837:	e8 bc 00 00 00       	call   801098f8 <arp_table_search>
8010983c:	83 c4 10             	add    $0x10,%esp
8010983f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109842:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109846:	78 2d                	js     80109875 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109848:	8b 45 08             	mov    0x8(%ebp),%eax
8010984b:	8d 48 08             	lea    0x8(%eax),%ecx
8010984e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109851:	89 d0                	mov    %edx,%eax
80109853:	c1 e0 02             	shl    $0x2,%eax
80109856:	01 d0                	add    %edx,%eax
80109858:	01 c0                	add    %eax,%eax
8010985a:	01 d0                	add    %edx,%eax
8010985c:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109861:	83 c0 04             	add    $0x4,%eax
80109864:	83 ec 04             	sub    $0x4,%esp
80109867:	6a 06                	push   $0x6
80109869:	51                   	push   %ecx
8010986a:	50                   	push   %eax
8010986b:	e8 7f ba ff ff       	call   801052ef <memmove>
80109870:	83 c4 10             	add    $0x10,%esp
80109873:	eb 70                	jmp    801098e5 <arp_table_update+0xbe>
  }else{
    index += 1;
80109875:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109879:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010987c:	8b 45 08             	mov    0x8(%ebp),%eax
8010987f:	8d 48 08             	lea    0x8(%eax),%ecx
80109882:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109885:	89 d0                	mov    %edx,%eax
80109887:	c1 e0 02             	shl    $0x2,%eax
8010988a:	01 d0                	add    %edx,%eax
8010988c:	01 c0                	add    %eax,%eax
8010988e:	01 d0                	add    %edx,%eax
80109890:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109895:	83 c0 04             	add    $0x4,%eax
80109898:	83 ec 04             	sub    $0x4,%esp
8010989b:	6a 06                	push   $0x6
8010989d:	51                   	push   %ecx
8010989e:	50                   	push   %eax
8010989f:	e8 4b ba ff ff       	call   801052ef <memmove>
801098a4:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801098a7:	8b 45 08             	mov    0x8(%ebp),%eax
801098aa:	8d 48 0e             	lea    0xe(%eax),%ecx
801098ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801098b0:	89 d0                	mov    %edx,%eax
801098b2:	c1 e0 02             	shl    $0x2,%eax
801098b5:	01 d0                	add    %edx,%eax
801098b7:	01 c0                	add    %eax,%eax
801098b9:	01 d0                	add    %edx,%eax
801098bb:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
801098c0:	83 ec 04             	sub    $0x4,%esp
801098c3:	6a 04                	push   $0x4
801098c5:	51                   	push   %ecx
801098c6:	50                   	push   %eax
801098c7:	e8 23 ba ff ff       	call   801052ef <memmove>
801098cc:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801098cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801098d2:	89 d0                	mov    %edx,%eax
801098d4:	c1 e0 02             	shl    $0x2,%eax
801098d7:	01 d0                	add    %edx,%eax
801098d9:	01 c0                	add    %eax,%eax
801098db:	01 d0                	add    %edx,%eax
801098dd:	05 ca 7a 19 80       	add    $0x80197aca,%eax
801098e2:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801098e5:	83 ec 0c             	sub    $0xc,%esp
801098e8:	68 c0 7a 19 80       	push   $0x80197ac0
801098ed:	e8 83 00 00 00       	call   80109975 <print_arp_table>
801098f2:	83 c4 10             	add    $0x10,%esp
}
801098f5:	90                   	nop
801098f6:	c9                   	leave
801098f7:	c3                   	ret

801098f8 <arp_table_search>:

int arp_table_search(uchar *ip){
801098f8:	55                   	push   %ebp
801098f9:	89 e5                	mov    %esp,%ebp
801098fb:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801098fe:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109905:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010990c:	eb 59                	jmp    80109967 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
8010990e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109911:	89 d0                	mov    %edx,%eax
80109913:	c1 e0 02             	shl    $0x2,%eax
80109916:	01 d0                	add    %edx,%eax
80109918:	01 c0                	add    %eax,%eax
8010991a:	01 d0                	add    %edx,%eax
8010991c:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
80109921:	83 ec 04             	sub    $0x4,%esp
80109924:	6a 04                	push   $0x4
80109926:	ff 75 08             	push   0x8(%ebp)
80109929:	50                   	push   %eax
8010992a:	e8 68 b9 ff ff       	call   80105297 <memcmp>
8010992f:	83 c4 10             	add    $0x10,%esp
80109932:	85 c0                	test   %eax,%eax
80109934:	75 05                	jne    8010993b <arp_table_search+0x43>
      return i;
80109936:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109939:	eb 38                	jmp    80109973 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
8010993b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010993e:	89 d0                	mov    %edx,%eax
80109940:	c1 e0 02             	shl    $0x2,%eax
80109943:	01 d0                	add    %edx,%eax
80109945:	01 c0                	add    %eax,%eax
80109947:	01 d0                	add    %edx,%eax
80109949:	05 ca 7a 19 80       	add    $0x80197aca,%eax
8010994e:	0f b6 00             	movzbl (%eax),%eax
80109951:	84 c0                	test   %al,%al
80109953:	75 0e                	jne    80109963 <arp_table_search+0x6b>
80109955:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109959:	75 08                	jne    80109963 <arp_table_search+0x6b>
      empty = -i;
8010995b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010995e:	f7 d8                	neg    %eax
80109960:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109963:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109967:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010996b:	7e a1                	jle    8010990e <arp_table_search+0x16>
    }
  }
  return empty-1;
8010996d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109970:	83 e8 01             	sub    $0x1,%eax
}
80109973:	c9                   	leave
80109974:	c3                   	ret

80109975 <print_arp_table>:

void print_arp_table(){
80109975:	55                   	push   %ebp
80109976:	89 e5                	mov    %esp,%ebp
80109978:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010997b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109982:	e9 92 00 00 00       	jmp    80109a19 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109987:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010998a:	89 d0                	mov    %edx,%eax
8010998c:	c1 e0 02             	shl    $0x2,%eax
8010998f:	01 d0                	add    %edx,%eax
80109991:	01 c0                	add    %eax,%eax
80109993:	01 d0                	add    %edx,%eax
80109995:	05 ca 7a 19 80       	add    $0x80197aca,%eax
8010999a:	0f b6 00             	movzbl (%eax),%eax
8010999d:	84 c0                	test   %al,%al
8010999f:	74 74                	je     80109a15 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
801099a1:	83 ec 08             	sub    $0x8,%esp
801099a4:	ff 75 f4             	push   -0xc(%ebp)
801099a7:	68 4f c9 10 80       	push   $0x8010c94f
801099ac:	e8 43 6a ff ff       	call   801003f4 <cprintf>
801099b1:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801099b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801099b7:	89 d0                	mov    %edx,%eax
801099b9:	c1 e0 02             	shl    $0x2,%eax
801099bc:	01 d0                	add    %edx,%eax
801099be:	01 c0                	add    %eax,%eax
801099c0:	01 d0                	add    %edx,%eax
801099c2:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
801099c7:	83 ec 0c             	sub    $0xc,%esp
801099ca:	50                   	push   %eax
801099cb:	e8 54 02 00 00       	call   80109c24 <print_ipv4>
801099d0:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801099d3:	83 ec 0c             	sub    $0xc,%esp
801099d6:	68 5e c9 10 80       	push   $0x8010c95e
801099db:	e8 14 6a ff ff       	call   801003f4 <cprintf>
801099e0:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801099e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801099e6:	89 d0                	mov    %edx,%eax
801099e8:	c1 e0 02             	shl    $0x2,%eax
801099eb:	01 d0                	add    %edx,%eax
801099ed:	01 c0                	add    %eax,%eax
801099ef:	01 d0                	add    %edx,%eax
801099f1:	05 c0 7a 19 80       	add    $0x80197ac0,%eax
801099f6:	83 c0 04             	add    $0x4,%eax
801099f9:	83 ec 0c             	sub    $0xc,%esp
801099fc:	50                   	push   %eax
801099fd:	e8 70 02 00 00       	call   80109c72 <print_mac>
80109a02:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109a05:	83 ec 0c             	sub    $0xc,%esp
80109a08:	68 60 c9 10 80       	push   $0x8010c960
80109a0d:	e8 e2 69 ff ff       	call   801003f4 <cprintf>
80109a12:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109a15:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109a19:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109a1d:	0f 8e 64 ff ff ff    	jle    80109987 <print_arp_table+0x12>
    }
  }
}
80109a23:	90                   	nop
80109a24:	90                   	nop
80109a25:	c9                   	leave
80109a26:	c3                   	ret

80109a27 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109a27:	55                   	push   %ebp
80109a28:	89 e5                	mov    %esp,%ebp
80109a2a:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109a2d:	8b 45 10             	mov    0x10(%ebp),%eax
80109a30:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109a36:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a39:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a3f:	83 c0 0e             	add    $0xe,%eax
80109a42:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a48:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a4f:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109a53:	8b 45 08             	mov    0x8(%ebp),%eax
80109a56:	8d 50 08             	lea    0x8(%eax),%edx
80109a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a5c:	83 ec 04             	sub    $0x4,%esp
80109a5f:	6a 06                	push   $0x6
80109a61:	52                   	push   %edx
80109a62:	50                   	push   %eax
80109a63:	e8 87 b8 ff ff       	call   801052ef <memmove>
80109a68:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a6e:	83 c0 06             	add    $0x6,%eax
80109a71:	83 ec 04             	sub    $0x4,%esp
80109a74:	6a 06                	push   $0x6
80109a76:	68 b4 7a 19 80       	push   $0x80197ab4
80109a7b:	50                   	push   %eax
80109a7c:	e8 6e b8 ff ff       	call   801052ef <memmove>
80109a81:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a87:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109a8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a8f:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a98:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a9f:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aa6:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109aac:	8b 45 08             	mov    0x8(%ebp),%eax
80109aaf:	8d 50 08             	lea    0x8(%eax),%edx
80109ab2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ab5:	83 c0 12             	add    $0x12,%eax
80109ab8:	83 ec 04             	sub    $0x4,%esp
80109abb:	6a 06                	push   $0x6
80109abd:	52                   	push   %edx
80109abe:	50                   	push   %eax
80109abf:	e8 2b b8 ff ff       	call   801052ef <memmove>
80109ac4:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80109aca:	8d 50 0e             	lea    0xe(%eax),%edx
80109acd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ad0:	83 c0 18             	add    $0x18,%eax
80109ad3:	83 ec 04             	sub    $0x4,%esp
80109ad6:	6a 04                	push   $0x4
80109ad8:	52                   	push   %edx
80109ad9:	50                   	push   %eax
80109ada:	e8 10 b8 ff ff       	call   801052ef <memmove>
80109adf:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ae5:	83 c0 08             	add    $0x8,%eax
80109ae8:	83 ec 04             	sub    $0x4,%esp
80109aeb:	6a 06                	push   $0x6
80109aed:	68 b4 7a 19 80       	push   $0x80197ab4
80109af2:	50                   	push   %eax
80109af3:	e8 f7 b7 ff ff       	call   801052ef <memmove>
80109af8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109afb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109afe:	83 c0 0e             	add    $0xe,%eax
80109b01:	83 ec 04             	sub    $0x4,%esp
80109b04:	6a 04                	push   $0x4
80109b06:	68 04 f5 10 80       	push   $0x8010f504
80109b0b:	50                   	push   %eax
80109b0c:	e8 de b7 ff ff       	call   801052ef <memmove>
80109b11:	83 c4 10             	add    $0x10,%esp
}
80109b14:	90                   	nop
80109b15:	c9                   	leave
80109b16:	c3                   	ret

80109b17 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109b17:	55                   	push   %ebp
80109b18:	89 e5                	mov    %esp,%ebp
80109b1a:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109b1d:	83 ec 0c             	sub    $0xc,%esp
80109b20:	68 62 c9 10 80       	push   $0x8010c962
80109b25:	e8 ca 68 ff ff       	call   801003f4 <cprintf>
80109b2a:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109b2d:	8b 45 08             	mov    0x8(%ebp),%eax
80109b30:	83 c0 0e             	add    $0xe,%eax
80109b33:	83 ec 0c             	sub    $0xc,%esp
80109b36:	50                   	push   %eax
80109b37:	e8 e8 00 00 00       	call   80109c24 <print_ipv4>
80109b3c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109b3f:	83 ec 0c             	sub    $0xc,%esp
80109b42:	68 60 c9 10 80       	push   $0x8010c960
80109b47:	e8 a8 68 ff ff       	call   801003f4 <cprintf>
80109b4c:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80109b52:	83 c0 08             	add    $0x8,%eax
80109b55:	83 ec 0c             	sub    $0xc,%esp
80109b58:	50                   	push   %eax
80109b59:	e8 14 01 00 00       	call   80109c72 <print_mac>
80109b5e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109b61:	83 ec 0c             	sub    $0xc,%esp
80109b64:	68 60 c9 10 80       	push   $0x8010c960
80109b69:	e8 86 68 ff ff       	call   801003f4 <cprintf>
80109b6e:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109b71:	83 ec 0c             	sub    $0xc,%esp
80109b74:	68 79 c9 10 80       	push   $0x8010c979
80109b79:	e8 76 68 ff ff       	call   801003f4 <cprintf>
80109b7e:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109b81:	8b 45 08             	mov    0x8(%ebp),%eax
80109b84:	83 c0 18             	add    $0x18,%eax
80109b87:	83 ec 0c             	sub    $0xc,%esp
80109b8a:	50                   	push   %eax
80109b8b:	e8 94 00 00 00       	call   80109c24 <print_ipv4>
80109b90:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109b93:	83 ec 0c             	sub    $0xc,%esp
80109b96:	68 60 c9 10 80       	push   $0x8010c960
80109b9b:	e8 54 68 ff ff       	call   801003f4 <cprintf>
80109ba0:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80109ba6:	83 c0 12             	add    $0x12,%eax
80109ba9:	83 ec 0c             	sub    $0xc,%esp
80109bac:	50                   	push   %eax
80109bad:	e8 c0 00 00 00       	call   80109c72 <print_mac>
80109bb2:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109bb5:	83 ec 0c             	sub    $0xc,%esp
80109bb8:	68 60 c9 10 80       	push   $0x8010c960
80109bbd:	e8 32 68 ff ff       	call   801003f4 <cprintf>
80109bc2:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109bc5:	83 ec 0c             	sub    $0xc,%esp
80109bc8:	68 90 c9 10 80       	push   $0x8010c990
80109bcd:	e8 22 68 ff ff       	call   801003f4 <cprintf>
80109bd2:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80109bd8:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109bdc:	66 3d 00 01          	cmp    $0x100,%ax
80109be0:	75 12                	jne    80109bf4 <print_arp_info+0xdd>
80109be2:	83 ec 0c             	sub    $0xc,%esp
80109be5:	68 9c c9 10 80       	push   $0x8010c99c
80109bea:	e8 05 68 ff ff       	call   801003f4 <cprintf>
80109bef:	83 c4 10             	add    $0x10,%esp
80109bf2:	eb 1d                	jmp    80109c11 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80109bf7:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109bfb:	66 3d 00 02          	cmp    $0x200,%ax
80109bff:	75 10                	jne    80109c11 <print_arp_info+0xfa>
    cprintf("Reply\n");
80109c01:	83 ec 0c             	sub    $0xc,%esp
80109c04:	68 a5 c9 10 80       	push   $0x8010c9a5
80109c09:	e8 e6 67 ff ff       	call   801003f4 <cprintf>
80109c0e:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109c11:	83 ec 0c             	sub    $0xc,%esp
80109c14:	68 60 c9 10 80       	push   $0x8010c960
80109c19:	e8 d6 67 ff ff       	call   801003f4 <cprintf>
80109c1e:	83 c4 10             	add    $0x10,%esp
}
80109c21:	90                   	nop
80109c22:	c9                   	leave
80109c23:	c3                   	ret

80109c24 <print_ipv4>:

void print_ipv4(uchar *ip){
80109c24:	55                   	push   %ebp
80109c25:	89 e5                	mov    %esp,%ebp
80109c27:	53                   	push   %ebx
80109c28:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c2e:	83 c0 03             	add    $0x3,%eax
80109c31:	0f b6 00             	movzbl (%eax),%eax
80109c34:	0f b6 d8             	movzbl %al,%ebx
80109c37:	8b 45 08             	mov    0x8(%ebp),%eax
80109c3a:	83 c0 02             	add    $0x2,%eax
80109c3d:	0f b6 00             	movzbl (%eax),%eax
80109c40:	0f b6 c8             	movzbl %al,%ecx
80109c43:	8b 45 08             	mov    0x8(%ebp),%eax
80109c46:	83 c0 01             	add    $0x1,%eax
80109c49:	0f b6 00             	movzbl (%eax),%eax
80109c4c:	0f b6 d0             	movzbl %al,%edx
80109c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80109c52:	0f b6 00             	movzbl (%eax),%eax
80109c55:	0f b6 c0             	movzbl %al,%eax
80109c58:	83 ec 0c             	sub    $0xc,%esp
80109c5b:	53                   	push   %ebx
80109c5c:	51                   	push   %ecx
80109c5d:	52                   	push   %edx
80109c5e:	50                   	push   %eax
80109c5f:	68 ac c9 10 80       	push   $0x8010c9ac
80109c64:	e8 8b 67 ff ff       	call   801003f4 <cprintf>
80109c69:	83 c4 20             	add    $0x20,%esp
}
80109c6c:	90                   	nop
80109c6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109c70:	c9                   	leave
80109c71:	c3                   	ret

80109c72 <print_mac>:

void print_mac(uchar *mac){
80109c72:	55                   	push   %ebp
80109c73:	89 e5                	mov    %esp,%ebp
80109c75:	57                   	push   %edi
80109c76:	56                   	push   %esi
80109c77:	53                   	push   %ebx
80109c78:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c7e:	83 c0 05             	add    $0x5,%eax
80109c81:	0f b6 00             	movzbl (%eax),%eax
80109c84:	0f b6 f8             	movzbl %al,%edi
80109c87:	8b 45 08             	mov    0x8(%ebp),%eax
80109c8a:	83 c0 04             	add    $0x4,%eax
80109c8d:	0f b6 00             	movzbl (%eax),%eax
80109c90:	0f b6 f0             	movzbl %al,%esi
80109c93:	8b 45 08             	mov    0x8(%ebp),%eax
80109c96:	83 c0 03             	add    $0x3,%eax
80109c99:	0f b6 00             	movzbl (%eax),%eax
80109c9c:	0f b6 d8             	movzbl %al,%ebx
80109c9f:	8b 45 08             	mov    0x8(%ebp),%eax
80109ca2:	83 c0 02             	add    $0x2,%eax
80109ca5:	0f b6 00             	movzbl (%eax),%eax
80109ca8:	0f b6 c8             	movzbl %al,%ecx
80109cab:	8b 45 08             	mov    0x8(%ebp),%eax
80109cae:	83 c0 01             	add    $0x1,%eax
80109cb1:	0f b6 00             	movzbl (%eax),%eax
80109cb4:	0f b6 d0             	movzbl %al,%edx
80109cb7:	8b 45 08             	mov    0x8(%ebp),%eax
80109cba:	0f b6 00             	movzbl (%eax),%eax
80109cbd:	0f b6 c0             	movzbl %al,%eax
80109cc0:	83 ec 04             	sub    $0x4,%esp
80109cc3:	57                   	push   %edi
80109cc4:	56                   	push   %esi
80109cc5:	53                   	push   %ebx
80109cc6:	51                   	push   %ecx
80109cc7:	52                   	push   %edx
80109cc8:	50                   	push   %eax
80109cc9:	68 c4 c9 10 80       	push   $0x8010c9c4
80109cce:	e8 21 67 ff ff       	call   801003f4 <cprintf>
80109cd3:	83 c4 20             	add    $0x20,%esp
}
80109cd6:	90                   	nop
80109cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109cda:	5b                   	pop    %ebx
80109cdb:	5e                   	pop    %esi
80109cdc:	5f                   	pop    %edi
80109cdd:	5d                   	pop    %ebp
80109cde:	c3                   	ret

80109cdf <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109cdf:	55                   	push   %ebp
80109ce0:	89 e5                	mov    %esp,%ebp
80109ce2:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109ce5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ce8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80109cee:	83 c0 0e             	add    $0xe,%eax
80109cf1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cf7:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109cfb:	3c 08                	cmp    $0x8,%al
80109cfd:	75 1b                	jne    80109d1a <eth_proc+0x3b>
80109cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d02:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109d06:	3c 06                	cmp    $0x6,%al
80109d08:	75 10                	jne    80109d1a <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109d0a:	83 ec 0c             	sub    $0xc,%esp
80109d0d:	ff 75 f0             	push   -0x10(%ebp)
80109d10:	e8 01 f8 ff ff       	call   80109516 <arp_proc>
80109d15:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109d18:	eb 24                	jmp    80109d3e <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d1d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109d21:	3c 08                	cmp    $0x8,%al
80109d23:	75 19                	jne    80109d3e <eth_proc+0x5f>
80109d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d28:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109d2c:	84 c0                	test   %al,%al
80109d2e:	75 0e                	jne    80109d3e <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109d30:	83 ec 0c             	sub    $0xc,%esp
80109d33:	ff 75 08             	push   0x8(%ebp)
80109d36:	e8 8d 00 00 00       	call   80109dc8 <ipv4_proc>
80109d3b:	83 c4 10             	add    $0x10,%esp
}
80109d3e:	90                   	nop
80109d3f:	c9                   	leave
80109d40:	c3                   	ret

80109d41 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109d41:	55                   	push   %ebp
80109d42:	89 e5                	mov    %esp,%ebp
80109d44:	83 ec 04             	sub    $0x4,%esp
80109d47:	8b 45 08             	mov    0x8(%ebp),%eax
80109d4a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109d4e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109d52:	66 c1 c0 08          	rol    $0x8,%ax
}
80109d56:	c9                   	leave
80109d57:	c3                   	ret

80109d58 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109d58:	55                   	push   %ebp
80109d59:	89 e5                	mov    %esp,%ebp
80109d5b:	83 ec 04             	sub    $0x4,%esp
80109d5e:	8b 45 08             	mov    0x8(%ebp),%eax
80109d61:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109d65:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109d69:	66 c1 c0 08          	rol    $0x8,%ax
}
80109d6d:	c9                   	leave
80109d6e:	c3                   	ret

80109d6f <H2N_uint>:

uint H2N_uint(uint value){
80109d6f:	55                   	push   %ebp
80109d70:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109d72:	8b 45 08             	mov    0x8(%ebp),%eax
80109d75:	c1 e0 18             	shl    $0x18,%eax
80109d78:	25 00 00 00 0f       	and    $0xf000000,%eax
80109d7d:	89 c2                	mov    %eax,%edx
80109d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80109d82:	c1 e0 08             	shl    $0x8,%eax
80109d85:	25 00 f0 00 00       	and    $0xf000,%eax
80109d8a:	09 c2                	or     %eax,%edx
80109d8c:	8b 45 08             	mov    0x8(%ebp),%eax
80109d8f:	c1 e8 08             	shr    $0x8,%eax
80109d92:	83 e0 0f             	and    $0xf,%eax
80109d95:	01 d0                	add    %edx,%eax
}
80109d97:	5d                   	pop    %ebp
80109d98:	c3                   	ret

80109d99 <N2H_uint>:

uint N2H_uint(uint value){
80109d99:	55                   	push   %ebp
80109d9a:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109d9c:	8b 45 08             	mov    0x8(%ebp),%eax
80109d9f:	c1 e0 18             	shl    $0x18,%eax
80109da2:	89 c2                	mov    %eax,%edx
80109da4:	8b 45 08             	mov    0x8(%ebp),%eax
80109da7:	c1 e0 08             	shl    $0x8,%eax
80109daa:	25 00 00 ff 00       	and    $0xff0000,%eax
80109daf:	01 c2                	add    %eax,%edx
80109db1:	8b 45 08             	mov    0x8(%ebp),%eax
80109db4:	c1 e8 08             	shr    $0x8,%eax
80109db7:	25 00 ff 00 00       	and    $0xff00,%eax
80109dbc:	01 c2                	add    %eax,%edx
80109dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80109dc1:	c1 e8 18             	shr    $0x18,%eax
80109dc4:	01 d0                	add    %edx,%eax
}
80109dc6:	5d                   	pop    %ebp
80109dc7:	c3                   	ret

80109dc8 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109dc8:	55                   	push   %ebp
80109dc9:	89 e5                	mov    %esp,%ebp
80109dcb:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109dce:	8b 45 08             	mov    0x8(%ebp),%eax
80109dd1:	83 c0 0e             	add    $0xe,%eax
80109dd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dda:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109dde:	0f b7 d0             	movzwl %ax,%edx
80109de1:	a1 08 f5 10 80       	mov    0x8010f508,%eax
80109de6:	39 c2                	cmp    %eax,%edx
80109de8:	74 60                	je     80109e4a <ipv4_proc+0x82>
80109dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ded:	83 c0 0c             	add    $0xc,%eax
80109df0:	83 ec 04             	sub    $0x4,%esp
80109df3:	6a 04                	push   $0x4
80109df5:	50                   	push   %eax
80109df6:	68 04 f5 10 80       	push   $0x8010f504
80109dfb:	e8 97 b4 ff ff       	call   80105297 <memcmp>
80109e00:	83 c4 10             	add    $0x10,%esp
80109e03:	85 c0                	test   %eax,%eax
80109e05:	74 43                	je     80109e4a <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e0a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109e0e:	0f b7 c0             	movzwl %ax,%eax
80109e11:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e19:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109e1d:	3c 01                	cmp    $0x1,%al
80109e1f:	75 10                	jne    80109e31 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109e21:	83 ec 0c             	sub    $0xc,%esp
80109e24:	ff 75 08             	push   0x8(%ebp)
80109e27:	e8 a3 00 00 00       	call   80109ecf <icmp_proc>
80109e2c:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109e2f:	eb 19                	jmp    80109e4a <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e34:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109e38:	3c 06                	cmp    $0x6,%al
80109e3a:	75 0e                	jne    80109e4a <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109e3c:	83 ec 0c             	sub    $0xc,%esp
80109e3f:	ff 75 08             	push   0x8(%ebp)
80109e42:	e8 b3 03 00 00       	call   8010a1fa <tcp_proc>
80109e47:	83 c4 10             	add    $0x10,%esp
}
80109e4a:	90                   	nop
80109e4b:	c9                   	leave
80109e4c:	c3                   	ret

80109e4d <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109e4d:	55                   	push   %ebp
80109e4e:	89 e5                	mov    %esp,%ebp
80109e50:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109e53:	8b 45 08             	mov    0x8(%ebp),%eax
80109e56:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e5c:	0f b6 00             	movzbl (%eax),%eax
80109e5f:	83 e0 0f             	and    $0xf,%eax
80109e62:	01 c0                	add    %eax,%eax
80109e64:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109e67:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109e6e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109e75:	eb 48                	jmp    80109ebf <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109e77:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e7a:	01 c0                	add    %eax,%eax
80109e7c:	89 c2                	mov    %eax,%edx
80109e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e81:	01 d0                	add    %edx,%eax
80109e83:	0f b6 00             	movzbl (%eax),%eax
80109e86:	0f b6 c0             	movzbl %al,%eax
80109e89:	c1 e0 08             	shl    $0x8,%eax
80109e8c:	89 c2                	mov    %eax,%edx
80109e8e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e91:	01 c0                	add    %eax,%eax
80109e93:	8d 48 01             	lea    0x1(%eax),%ecx
80109e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e99:	01 c8                	add    %ecx,%eax
80109e9b:	0f b6 00             	movzbl (%eax),%eax
80109e9e:	0f b6 c0             	movzbl %al,%eax
80109ea1:	01 d0                	add    %edx,%eax
80109ea3:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109ea6:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109ead:	76 0c                	jbe    80109ebb <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109eaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109eb2:	0f b7 c0             	movzwl %ax,%eax
80109eb5:	83 c0 01             	add    $0x1,%eax
80109eb8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109ebb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109ebf:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109ec3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109ec6:	7c af                	jl     80109e77 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109ec8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ecb:	f7 d0                	not    %eax
}
80109ecd:	c9                   	leave
80109ece:	c3                   	ret

80109ecf <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109ecf:	55                   	push   %ebp
80109ed0:	89 e5                	mov    %esp,%ebp
80109ed2:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109ed5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ed8:	83 c0 0e             	add    $0xe,%eax
80109edb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ee1:	0f b6 00             	movzbl (%eax),%eax
80109ee4:	0f b6 c0             	movzbl %al,%eax
80109ee7:	83 e0 0f             	and    $0xf,%eax
80109eea:	c1 e0 02             	shl    $0x2,%eax
80109eed:	89 c2                	mov    %eax,%edx
80109eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ef2:	01 d0                	add    %edx,%eax
80109ef4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109efa:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109efe:	84 c0                	test   %al,%al
80109f00:	75 4f                	jne    80109f51 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109f02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f05:	0f b6 00             	movzbl (%eax),%eax
80109f08:	3c 08                	cmp    $0x8,%al
80109f0a:	75 45                	jne    80109f51 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109f0c:	e8 97 88 ff ff       	call   801027a8 <kalloc>
80109f11:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109f14:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109f1b:	83 ec 04             	sub    $0x4,%esp
80109f1e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109f21:	50                   	push   %eax
80109f22:	ff 75 ec             	push   -0x14(%ebp)
80109f25:	ff 75 08             	push   0x8(%ebp)
80109f28:	e8 78 00 00 00       	call   80109fa5 <icmp_reply_pkt_create>
80109f2d:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109f30:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f33:	83 ec 08             	sub    $0x8,%esp
80109f36:	50                   	push   %eax
80109f37:	ff 75 ec             	push   -0x14(%ebp)
80109f3a:	e8 ad f4 ff ff       	call   801093ec <i8254_send>
80109f3f:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109f42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f45:	83 ec 0c             	sub    $0xc,%esp
80109f48:	50                   	push   %eax
80109f49:	e8 c0 87 ff ff       	call   8010270e <kfree>
80109f4e:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109f51:	90                   	nop
80109f52:	c9                   	leave
80109f53:	c3                   	ret

80109f54 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109f54:	55                   	push   %ebp
80109f55:	89 e5                	mov    %esp,%ebp
80109f57:	53                   	push   %ebx
80109f58:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80109f5e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109f62:	0f b7 c0             	movzwl %ax,%eax
80109f65:	83 ec 0c             	sub    $0xc,%esp
80109f68:	50                   	push   %eax
80109f69:	e8 d3 fd ff ff       	call   80109d41 <N2H_ushort>
80109f6e:	83 c4 10             	add    $0x10,%esp
80109f71:	0f b7 d8             	movzwl %ax,%ebx
80109f74:	8b 45 08             	mov    0x8(%ebp),%eax
80109f77:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109f7b:	0f b7 c0             	movzwl %ax,%eax
80109f7e:	83 ec 0c             	sub    $0xc,%esp
80109f81:	50                   	push   %eax
80109f82:	e8 ba fd ff ff       	call   80109d41 <N2H_ushort>
80109f87:	83 c4 10             	add    $0x10,%esp
80109f8a:	0f b7 c0             	movzwl %ax,%eax
80109f8d:	83 ec 04             	sub    $0x4,%esp
80109f90:	53                   	push   %ebx
80109f91:	50                   	push   %eax
80109f92:	68 e3 c9 10 80       	push   $0x8010c9e3
80109f97:	e8 58 64 ff ff       	call   801003f4 <cprintf>
80109f9c:	83 c4 10             	add    $0x10,%esp
}
80109f9f:	90                   	nop
80109fa0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109fa3:	c9                   	leave
80109fa4:	c3                   	ret

80109fa5 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109fa5:	55                   	push   %ebp
80109fa6:	89 e5                	mov    %esp,%ebp
80109fa8:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109fab:	8b 45 08             	mov    0x8(%ebp),%eax
80109fae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109fb1:	8b 45 08             	mov    0x8(%ebp),%eax
80109fb4:	83 c0 0e             	add    $0xe,%eax
80109fb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109fba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fbd:	0f b6 00             	movzbl (%eax),%eax
80109fc0:	0f b6 c0             	movzbl %al,%eax
80109fc3:	83 e0 0f             	and    $0xf,%eax
80109fc6:	c1 e0 02             	shl    $0x2,%eax
80109fc9:	89 c2                	mov    %eax,%edx
80109fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fce:	01 d0                	add    %edx,%eax
80109fd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fd6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fdc:	83 c0 0e             	add    $0xe,%eax
80109fdf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109fe2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fe5:	83 c0 14             	add    $0x14,%eax
80109fe8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109feb:	8b 45 10             	mov    0x10(%ebp),%eax
80109fee:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ff7:	8d 50 06             	lea    0x6(%eax),%edx
80109ffa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ffd:	83 ec 04             	sub    $0x4,%esp
8010a000:	6a 06                	push   $0x6
8010a002:	52                   	push   %edx
8010a003:	50                   	push   %eax
8010a004:	e8 e6 b2 ff ff       	call   801052ef <memmove>
8010a009:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a00c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a00f:	83 c0 06             	add    $0x6,%eax
8010a012:	83 ec 04             	sub    $0x4,%esp
8010a015:	6a 06                	push   $0x6
8010a017:	68 b4 7a 19 80       	push   $0x80197ab4
8010a01c:	50                   	push   %eax
8010a01d:	e8 cd b2 ff ff       	call   801052ef <memmove>
8010a022:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a025:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a028:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a02c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a02f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a033:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a036:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a039:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a03c:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a040:	83 ec 0c             	sub    $0xc,%esp
8010a043:	6a 54                	push   $0x54
8010a045:	e8 0e fd ff ff       	call   80109d58 <H2N_ushort>
8010a04a:	83 c4 10             	add    $0x10,%esp
8010a04d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a050:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a054:	0f b7 15 80 7d 19 80 	movzwl 0x80197d80,%edx
8010a05b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a05e:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a062:	0f b7 05 80 7d 19 80 	movzwl 0x80197d80,%eax
8010a069:	83 c0 01             	add    $0x1,%eax
8010a06c:	66 a3 80 7d 19 80    	mov    %ax,0x80197d80
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a072:	83 ec 0c             	sub    $0xc,%esp
8010a075:	68 00 40 00 00       	push   $0x4000
8010a07a:	e8 d9 fc ff ff       	call   80109d58 <H2N_ushort>
8010a07f:	83 c4 10             	add    $0x10,%esp
8010a082:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a085:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a089:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a08c:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a090:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a093:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a097:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a09a:	83 c0 0c             	add    $0xc,%eax
8010a09d:	83 ec 04             	sub    $0x4,%esp
8010a0a0:	6a 04                	push   $0x4
8010a0a2:	68 04 f5 10 80       	push   $0x8010f504
8010a0a7:	50                   	push   %eax
8010a0a8:	e8 42 b2 ff ff       	call   801052ef <memmove>
8010a0ad:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a0b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0b3:	8d 50 0c             	lea    0xc(%eax),%edx
8010a0b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0b9:	83 c0 10             	add    $0x10,%eax
8010a0bc:	83 ec 04             	sub    $0x4,%esp
8010a0bf:	6a 04                	push   $0x4
8010a0c1:	52                   	push   %edx
8010a0c2:	50                   	push   %eax
8010a0c3:	e8 27 b2 ff ff       	call   801052ef <memmove>
8010a0c8:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a0cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0ce:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a0d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0d7:	83 ec 0c             	sub    $0xc,%esp
8010a0da:	50                   	push   %eax
8010a0db:	e8 6d fd ff ff       	call   80109e4d <ipv4_chksum>
8010a0e0:	83 c4 10             	add    $0x10,%esp
8010a0e3:	0f b7 c0             	movzwl %ax,%eax
8010a0e6:	83 ec 0c             	sub    $0xc,%esp
8010a0e9:	50                   	push   %eax
8010a0ea:	e8 69 fc ff ff       	call   80109d58 <H2N_ushort>
8010a0ef:	83 c4 10             	add    $0x10,%esp
8010a0f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0f5:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a0f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0fc:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a0ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a102:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a106:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a109:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a10d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a110:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a114:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a117:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a11b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a11e:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a122:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a125:	8d 50 08             	lea    0x8(%eax),%edx
8010a128:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a12b:	83 c0 08             	add    $0x8,%eax
8010a12e:	83 ec 04             	sub    $0x4,%esp
8010a131:	6a 08                	push   $0x8
8010a133:	52                   	push   %edx
8010a134:	50                   	push   %eax
8010a135:	e8 b5 b1 ff ff       	call   801052ef <memmove>
8010a13a:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a13d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a140:	8d 50 10             	lea    0x10(%eax),%edx
8010a143:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a146:	83 c0 10             	add    $0x10,%eax
8010a149:	83 ec 04             	sub    $0x4,%esp
8010a14c:	6a 30                	push   $0x30
8010a14e:	52                   	push   %edx
8010a14f:	50                   	push   %eax
8010a150:	e8 9a b1 ff ff       	call   801052ef <memmove>
8010a155:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a158:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a15b:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a161:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a164:	83 ec 0c             	sub    $0xc,%esp
8010a167:	50                   	push   %eax
8010a168:	e8 1c 00 00 00       	call   8010a189 <icmp_chksum>
8010a16d:	83 c4 10             	add    $0x10,%esp
8010a170:	0f b7 c0             	movzwl %ax,%eax
8010a173:	83 ec 0c             	sub    $0xc,%esp
8010a176:	50                   	push   %eax
8010a177:	e8 dc fb ff ff       	call   80109d58 <H2N_ushort>
8010a17c:	83 c4 10             	add    $0x10,%esp
8010a17f:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a182:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a186:	90                   	nop
8010a187:	c9                   	leave
8010a188:	c3                   	ret

8010a189 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a189:	55                   	push   %ebp
8010a18a:	89 e5                	mov    %esp,%ebp
8010a18c:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a18f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a192:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a195:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a19c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a1a3:	eb 48                	jmp    8010a1ed <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a1a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a1a8:	01 c0                	add    %eax,%eax
8010a1aa:	89 c2                	mov    %eax,%edx
8010a1ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1af:	01 d0                	add    %edx,%eax
8010a1b1:	0f b6 00             	movzbl (%eax),%eax
8010a1b4:	0f b6 c0             	movzbl %al,%eax
8010a1b7:	c1 e0 08             	shl    $0x8,%eax
8010a1ba:	89 c2                	mov    %eax,%edx
8010a1bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a1bf:	01 c0                	add    %eax,%eax
8010a1c1:	8d 48 01             	lea    0x1(%eax),%ecx
8010a1c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1c7:	01 c8                	add    %ecx,%eax
8010a1c9:	0f b6 00             	movzbl (%eax),%eax
8010a1cc:	0f b6 c0             	movzbl %al,%eax
8010a1cf:	01 d0                	add    %edx,%eax
8010a1d1:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a1d4:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a1db:	76 0c                	jbe    8010a1e9 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a1dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a1e0:	0f b7 c0             	movzwl %ax,%eax
8010a1e3:	83 c0 01             	add    $0x1,%eax
8010a1e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a1e9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a1ed:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a1f1:	7e b2                	jle    8010a1a5 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
8010a1f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a1f6:	f7 d0                	not    %eax
}
8010a1f8:	c9                   	leave
8010a1f9:	c3                   	ret

8010a1fa <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a1fa:	55                   	push   %ebp
8010a1fb:	89 e5                	mov    %esp,%ebp
8010a1fd:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a200:	8b 45 08             	mov    0x8(%ebp),%eax
8010a203:	83 c0 0e             	add    $0xe,%eax
8010a206:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a209:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a20c:	0f b6 00             	movzbl (%eax),%eax
8010a20f:	0f b6 c0             	movzbl %al,%eax
8010a212:	83 e0 0f             	and    $0xf,%eax
8010a215:	c1 e0 02             	shl    $0x2,%eax
8010a218:	89 c2                	mov    %eax,%edx
8010a21a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a21d:	01 d0                	add    %edx,%eax
8010a21f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a222:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a225:	83 c0 14             	add    $0x14,%eax
8010a228:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a22b:	e8 78 85 ff ff       	call   801027a8 <kalloc>
8010a230:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a233:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a23a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a23d:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a241:	0f b6 c0             	movzbl %al,%eax
8010a244:	83 e0 02             	and    $0x2,%eax
8010a247:	85 c0                	test   %eax,%eax
8010a249:	74 3d                	je     8010a288 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a24b:	83 ec 0c             	sub    $0xc,%esp
8010a24e:	6a 00                	push   $0x0
8010a250:	6a 12                	push   $0x12
8010a252:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a255:	50                   	push   %eax
8010a256:	ff 75 e8             	push   -0x18(%ebp)
8010a259:	ff 75 08             	push   0x8(%ebp)
8010a25c:	e8 a2 01 00 00       	call   8010a403 <tcp_pkt_create>
8010a261:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a264:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a267:	83 ec 08             	sub    $0x8,%esp
8010a26a:	50                   	push   %eax
8010a26b:	ff 75 e8             	push   -0x18(%ebp)
8010a26e:	e8 79 f1 ff ff       	call   801093ec <i8254_send>
8010a273:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a276:	a1 84 7d 19 80       	mov    0x80197d84,%eax
8010a27b:	83 c0 01             	add    $0x1,%eax
8010a27e:	a3 84 7d 19 80       	mov    %eax,0x80197d84
8010a283:	e9 69 01 00 00       	jmp    8010a3f1 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a288:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a28b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a28f:	3c 18                	cmp    $0x18,%al
8010a291:	0f 85 10 01 00 00    	jne    8010a3a7 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010a297:	83 ec 04             	sub    $0x4,%esp
8010a29a:	6a 03                	push   $0x3
8010a29c:	68 fe c9 10 80       	push   $0x8010c9fe
8010a2a1:	ff 75 ec             	push   -0x14(%ebp)
8010a2a4:	e8 ee af ff ff       	call   80105297 <memcmp>
8010a2a9:	83 c4 10             	add    $0x10,%esp
8010a2ac:	85 c0                	test   %eax,%eax
8010a2ae:	74 74                	je     8010a324 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a2b0:	83 ec 0c             	sub    $0xc,%esp
8010a2b3:	68 02 ca 10 80       	push   $0x8010ca02
8010a2b8:	e8 37 61 ff ff       	call   801003f4 <cprintf>
8010a2bd:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a2c0:	83 ec 0c             	sub    $0xc,%esp
8010a2c3:	6a 00                	push   $0x0
8010a2c5:	6a 10                	push   $0x10
8010a2c7:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a2ca:	50                   	push   %eax
8010a2cb:	ff 75 e8             	push   -0x18(%ebp)
8010a2ce:	ff 75 08             	push   0x8(%ebp)
8010a2d1:	e8 2d 01 00 00       	call   8010a403 <tcp_pkt_create>
8010a2d6:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a2d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a2dc:	83 ec 08             	sub    $0x8,%esp
8010a2df:	50                   	push   %eax
8010a2e0:	ff 75 e8             	push   -0x18(%ebp)
8010a2e3:	e8 04 f1 ff ff       	call   801093ec <i8254_send>
8010a2e8:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a2eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2ee:	83 c0 36             	add    $0x36,%eax
8010a2f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a2f4:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a2f7:	50                   	push   %eax
8010a2f8:	ff 75 e0             	push   -0x20(%ebp)
8010a2fb:	6a 00                	push   $0x0
8010a2fd:	6a 00                	push   $0x0
8010a2ff:	e8 5a 04 00 00       	call   8010a75e <http_proc>
8010a304:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a307:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a30a:	83 ec 0c             	sub    $0xc,%esp
8010a30d:	50                   	push   %eax
8010a30e:	6a 18                	push   $0x18
8010a310:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a313:	50                   	push   %eax
8010a314:	ff 75 e8             	push   -0x18(%ebp)
8010a317:	ff 75 08             	push   0x8(%ebp)
8010a31a:	e8 e4 00 00 00       	call   8010a403 <tcp_pkt_create>
8010a31f:	83 c4 20             	add    $0x20,%esp
8010a322:	eb 62                	jmp    8010a386 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a324:	83 ec 0c             	sub    $0xc,%esp
8010a327:	6a 00                	push   $0x0
8010a329:	6a 10                	push   $0x10
8010a32b:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a32e:	50                   	push   %eax
8010a32f:	ff 75 e8             	push   -0x18(%ebp)
8010a332:	ff 75 08             	push   0x8(%ebp)
8010a335:	e8 c9 00 00 00       	call   8010a403 <tcp_pkt_create>
8010a33a:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a33d:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a340:	83 ec 08             	sub    $0x8,%esp
8010a343:	50                   	push   %eax
8010a344:	ff 75 e8             	push   -0x18(%ebp)
8010a347:	e8 a0 f0 ff ff       	call   801093ec <i8254_send>
8010a34c:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a34f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a352:	83 c0 36             	add    $0x36,%eax
8010a355:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a358:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a35b:	50                   	push   %eax
8010a35c:	ff 75 e4             	push   -0x1c(%ebp)
8010a35f:	6a 00                	push   $0x0
8010a361:	6a 00                	push   $0x0
8010a363:	e8 f6 03 00 00       	call   8010a75e <http_proc>
8010a368:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a36b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a36e:	83 ec 0c             	sub    $0xc,%esp
8010a371:	50                   	push   %eax
8010a372:	6a 18                	push   $0x18
8010a374:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a377:	50                   	push   %eax
8010a378:	ff 75 e8             	push   -0x18(%ebp)
8010a37b:	ff 75 08             	push   0x8(%ebp)
8010a37e:	e8 80 00 00 00       	call   8010a403 <tcp_pkt_create>
8010a383:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a386:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a389:	83 ec 08             	sub    $0x8,%esp
8010a38c:	50                   	push   %eax
8010a38d:	ff 75 e8             	push   -0x18(%ebp)
8010a390:	e8 57 f0 ff ff       	call   801093ec <i8254_send>
8010a395:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a398:	a1 84 7d 19 80       	mov    0x80197d84,%eax
8010a39d:	83 c0 01             	add    $0x1,%eax
8010a3a0:	a3 84 7d 19 80       	mov    %eax,0x80197d84
8010a3a5:	eb 4a                	jmp    8010a3f1 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a3a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3aa:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a3ae:	3c 10                	cmp    $0x10,%al
8010a3b0:	75 3f                	jne    8010a3f1 <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a3b2:	a1 88 7d 19 80       	mov    0x80197d88,%eax
8010a3b7:	83 f8 01             	cmp    $0x1,%eax
8010a3ba:	75 35                	jne    8010a3f1 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a3bc:	83 ec 0c             	sub    $0xc,%esp
8010a3bf:	6a 00                	push   $0x0
8010a3c1:	6a 01                	push   $0x1
8010a3c3:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a3c6:	50                   	push   %eax
8010a3c7:	ff 75 e8             	push   -0x18(%ebp)
8010a3ca:	ff 75 08             	push   0x8(%ebp)
8010a3cd:	e8 31 00 00 00       	call   8010a403 <tcp_pkt_create>
8010a3d2:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a3d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a3d8:	83 ec 08             	sub    $0x8,%esp
8010a3db:	50                   	push   %eax
8010a3dc:	ff 75 e8             	push   -0x18(%ebp)
8010a3df:	e8 08 f0 ff ff       	call   801093ec <i8254_send>
8010a3e4:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a3e7:	c7 05 88 7d 19 80 00 	movl   $0x0,0x80197d88
8010a3ee:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a3f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3f4:	83 ec 0c             	sub    $0xc,%esp
8010a3f7:	50                   	push   %eax
8010a3f8:	e8 11 83 ff ff       	call   8010270e <kfree>
8010a3fd:	83 c4 10             	add    $0x10,%esp
}
8010a400:	90                   	nop
8010a401:	c9                   	leave
8010a402:	c3                   	ret

8010a403 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a403:	55                   	push   %ebp
8010a404:	89 e5                	mov    %esp,%ebp
8010a406:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a409:	8b 45 08             	mov    0x8(%ebp),%eax
8010a40c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a40f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a412:	83 c0 0e             	add    $0xe,%eax
8010a415:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a418:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a41b:	0f b6 00             	movzbl (%eax),%eax
8010a41e:	0f b6 c0             	movzbl %al,%eax
8010a421:	83 e0 0f             	and    $0xf,%eax
8010a424:	c1 e0 02             	shl    $0x2,%eax
8010a427:	89 c2                	mov    %eax,%edx
8010a429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a42c:	01 d0                	add    %edx,%eax
8010a42e:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a431:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a434:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a437:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a43a:	83 c0 0e             	add    $0xe,%eax
8010a43d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a440:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a443:	83 c0 14             	add    $0x14,%eax
8010a446:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a449:	8b 45 18             	mov    0x18(%ebp),%eax
8010a44c:	8d 50 36             	lea    0x36(%eax),%edx
8010a44f:	8b 45 10             	mov    0x10(%ebp),%eax
8010a452:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a454:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a457:	8d 50 06             	lea    0x6(%eax),%edx
8010a45a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a45d:	83 ec 04             	sub    $0x4,%esp
8010a460:	6a 06                	push   $0x6
8010a462:	52                   	push   %edx
8010a463:	50                   	push   %eax
8010a464:	e8 86 ae ff ff       	call   801052ef <memmove>
8010a469:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a46c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a46f:	83 c0 06             	add    $0x6,%eax
8010a472:	83 ec 04             	sub    $0x4,%esp
8010a475:	6a 06                	push   $0x6
8010a477:	68 b4 7a 19 80       	push   $0x80197ab4
8010a47c:	50                   	push   %eax
8010a47d:	e8 6d ae ff ff       	call   801052ef <memmove>
8010a482:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a485:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a488:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a48c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a48f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a493:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a496:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a499:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a49c:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a4a0:	8b 45 18             	mov    0x18(%ebp),%eax
8010a4a3:	83 c0 28             	add    $0x28,%eax
8010a4a6:	0f b7 c0             	movzwl %ax,%eax
8010a4a9:	83 ec 0c             	sub    $0xc,%esp
8010a4ac:	50                   	push   %eax
8010a4ad:	e8 a6 f8 ff ff       	call   80109d58 <H2N_ushort>
8010a4b2:	83 c4 10             	add    $0x10,%esp
8010a4b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a4b8:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a4bc:	0f b7 15 80 7d 19 80 	movzwl 0x80197d80,%edx
8010a4c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4c6:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a4ca:	0f b7 05 80 7d 19 80 	movzwl 0x80197d80,%eax
8010a4d1:	83 c0 01             	add    $0x1,%eax
8010a4d4:	66 a3 80 7d 19 80    	mov    %ax,0x80197d80
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a4da:	83 ec 0c             	sub    $0xc,%esp
8010a4dd:	6a 00                	push   $0x0
8010a4df:	e8 74 f8 ff ff       	call   80109d58 <H2N_ushort>
8010a4e4:	83 c4 10             	add    $0x10,%esp
8010a4e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a4ea:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a4ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4f1:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a4f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4f8:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a4fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4ff:	83 c0 0c             	add    $0xc,%eax
8010a502:	83 ec 04             	sub    $0x4,%esp
8010a505:	6a 04                	push   $0x4
8010a507:	68 04 f5 10 80       	push   $0x8010f504
8010a50c:	50                   	push   %eax
8010a50d:	e8 dd ad ff ff       	call   801052ef <memmove>
8010a512:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a515:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a518:	8d 50 0c             	lea    0xc(%eax),%edx
8010a51b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a51e:	83 c0 10             	add    $0x10,%eax
8010a521:	83 ec 04             	sub    $0x4,%esp
8010a524:	6a 04                	push   $0x4
8010a526:	52                   	push   %edx
8010a527:	50                   	push   %eax
8010a528:	e8 c2 ad ff ff       	call   801052ef <memmove>
8010a52d:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a530:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a533:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a539:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a53c:	83 ec 0c             	sub    $0xc,%esp
8010a53f:	50                   	push   %eax
8010a540:	e8 08 f9 ff ff       	call   80109e4d <ipv4_chksum>
8010a545:	83 c4 10             	add    $0x10,%esp
8010a548:	0f b7 c0             	movzwl %ax,%eax
8010a54b:	83 ec 0c             	sub    $0xc,%esp
8010a54e:	50                   	push   %eax
8010a54f:	e8 04 f8 ff ff       	call   80109d58 <H2N_ushort>
8010a554:	83 c4 10             	add    $0x10,%esp
8010a557:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a55a:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a55e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a561:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a565:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a568:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a56b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a56e:	0f b7 10             	movzwl (%eax),%edx
8010a571:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a574:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a578:	a1 84 7d 19 80       	mov    0x80197d84,%eax
8010a57d:	83 ec 0c             	sub    $0xc,%esp
8010a580:	50                   	push   %eax
8010a581:	e8 e9 f7 ff ff       	call   80109d6f <H2N_uint>
8010a586:	83 c4 10             	add    $0x10,%esp
8010a589:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a58c:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a58f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a592:	8b 40 04             	mov    0x4(%eax),%eax
8010a595:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a59b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a59e:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a5a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5a4:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a5a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5ab:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a5af:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5b2:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a5b6:	8b 45 14             	mov    0x14(%ebp),%eax
8010a5b9:	89 c2                	mov    %eax,%edx
8010a5bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5be:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a5c1:	83 ec 0c             	sub    $0xc,%esp
8010a5c4:	68 90 38 00 00       	push   $0x3890
8010a5c9:	e8 8a f7 ff ff       	call   80109d58 <H2N_ushort>
8010a5ce:	83 c4 10             	add    $0x10,%esp
8010a5d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a5d4:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a5d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5db:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a5e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5e4:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a5ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5ed:	83 ec 0c             	sub    $0xc,%esp
8010a5f0:	50                   	push   %eax
8010a5f1:	e8 1f 00 00 00       	call   8010a615 <tcp_chksum>
8010a5f6:	83 c4 10             	add    $0x10,%esp
8010a5f9:	83 c0 08             	add    $0x8,%eax
8010a5fc:	0f b7 c0             	movzwl %ax,%eax
8010a5ff:	83 ec 0c             	sub    $0xc,%esp
8010a602:	50                   	push   %eax
8010a603:	e8 50 f7 ff ff       	call   80109d58 <H2N_ushort>
8010a608:	83 c4 10             	add    $0x10,%esp
8010a60b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a60e:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a612:	90                   	nop
8010a613:	c9                   	leave
8010a614:	c3                   	ret

8010a615 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a615:	55                   	push   %ebp
8010a616:	89 e5                	mov    %esp,%ebp
8010a618:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a61b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a61e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a621:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a624:	83 c0 14             	add    $0x14,%eax
8010a627:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a62a:	83 ec 04             	sub    $0x4,%esp
8010a62d:	6a 04                	push   $0x4
8010a62f:	68 04 f5 10 80       	push   $0x8010f504
8010a634:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a637:	50                   	push   %eax
8010a638:	e8 b2 ac ff ff       	call   801052ef <memmove>
8010a63d:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a640:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a643:	83 c0 0c             	add    $0xc,%eax
8010a646:	83 ec 04             	sub    $0x4,%esp
8010a649:	6a 04                	push   $0x4
8010a64b:	50                   	push   %eax
8010a64c:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a64f:	83 c0 04             	add    $0x4,%eax
8010a652:	50                   	push   %eax
8010a653:	e8 97 ac ff ff       	call   801052ef <memmove>
8010a658:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a65b:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a65f:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a663:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a666:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a66a:	0f b7 c0             	movzwl %ax,%eax
8010a66d:	83 ec 0c             	sub    $0xc,%esp
8010a670:	50                   	push   %eax
8010a671:	e8 cb f6 ff ff       	call   80109d41 <N2H_ushort>
8010a676:	83 c4 10             	add    $0x10,%esp
8010a679:	83 e8 14             	sub    $0x14,%eax
8010a67c:	0f b7 c0             	movzwl %ax,%eax
8010a67f:	83 ec 0c             	sub    $0xc,%esp
8010a682:	50                   	push   %eax
8010a683:	e8 d0 f6 ff ff       	call   80109d58 <H2N_ushort>
8010a688:	83 c4 10             	add    $0x10,%esp
8010a68b:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a68f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a696:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a699:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a69c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a6a3:	eb 33                	jmp    8010a6d8 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a6a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6a8:	01 c0                	add    %eax,%eax
8010a6aa:	89 c2                	mov    %eax,%edx
8010a6ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6af:	01 d0                	add    %edx,%eax
8010a6b1:	0f b6 00             	movzbl (%eax),%eax
8010a6b4:	0f b6 c0             	movzbl %al,%eax
8010a6b7:	c1 e0 08             	shl    $0x8,%eax
8010a6ba:	89 c2                	mov    %eax,%edx
8010a6bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6bf:	01 c0                	add    %eax,%eax
8010a6c1:	8d 48 01             	lea    0x1(%eax),%ecx
8010a6c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6c7:	01 c8                	add    %ecx,%eax
8010a6c9:	0f b6 00             	movzbl (%eax),%eax
8010a6cc:	0f b6 c0             	movzbl %al,%eax
8010a6cf:	01 d0                	add    %edx,%eax
8010a6d1:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a6d4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a6d8:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a6dc:	7e c7                	jle    8010a6a5 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a6de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a6e4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a6eb:	eb 33                	jmp    8010a720 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a6ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a6f0:	01 c0                	add    %eax,%eax
8010a6f2:	89 c2                	mov    %eax,%edx
8010a6f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6f7:	01 d0                	add    %edx,%eax
8010a6f9:	0f b6 00             	movzbl (%eax),%eax
8010a6fc:	0f b6 c0             	movzbl %al,%eax
8010a6ff:	c1 e0 08             	shl    $0x8,%eax
8010a702:	89 c2                	mov    %eax,%edx
8010a704:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a707:	01 c0                	add    %eax,%eax
8010a709:	8d 48 01             	lea    0x1(%eax),%ecx
8010a70c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a70f:	01 c8                	add    %ecx,%eax
8010a711:	0f b6 00             	movzbl (%eax),%eax
8010a714:	0f b6 c0             	movzbl %al,%eax
8010a717:	01 d0                	add    %edx,%eax
8010a719:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a71c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a720:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a724:	0f b7 c0             	movzwl %ax,%eax
8010a727:	83 ec 0c             	sub    $0xc,%esp
8010a72a:	50                   	push   %eax
8010a72b:	e8 11 f6 ff ff       	call   80109d41 <N2H_ushort>
8010a730:	83 c4 10             	add    $0x10,%esp
8010a733:	66 d1 e8             	shr    $1,%ax
8010a736:	0f b7 c0             	movzwl %ax,%eax
8010a739:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a73c:	7c af                	jl     8010a6ed <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a73e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a741:	c1 e8 10             	shr    $0x10,%eax
8010a744:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a74a:	f7 d0                	not    %eax
}
8010a74c:	c9                   	leave
8010a74d:	c3                   	ret

8010a74e <tcp_fin>:

void tcp_fin(){
8010a74e:	55                   	push   %ebp
8010a74f:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a751:	c7 05 88 7d 19 80 01 	movl   $0x1,0x80197d88
8010a758:	00 00 00 
}
8010a75b:	90                   	nop
8010a75c:	5d                   	pop    %ebp
8010a75d:	c3                   	ret

8010a75e <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a75e:	55                   	push   %ebp
8010a75f:	89 e5                	mov    %esp,%ebp
8010a761:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a764:	8b 45 10             	mov    0x10(%ebp),%eax
8010a767:	83 ec 04             	sub    $0x4,%esp
8010a76a:	6a 00                	push   $0x0
8010a76c:	68 0b ca 10 80       	push   $0x8010ca0b
8010a771:	50                   	push   %eax
8010a772:	e8 65 00 00 00       	call   8010a7dc <http_strcpy>
8010a777:	83 c4 10             	add    $0x10,%esp
8010a77a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a77d:	8b 45 10             	mov    0x10(%ebp),%eax
8010a780:	83 ec 04             	sub    $0x4,%esp
8010a783:	ff 75 f4             	push   -0xc(%ebp)
8010a786:	68 1e ca 10 80       	push   $0x8010ca1e
8010a78b:	50                   	push   %eax
8010a78c:	e8 4b 00 00 00       	call   8010a7dc <http_strcpy>
8010a791:	83 c4 10             	add    $0x10,%esp
8010a794:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a797:	8b 45 10             	mov    0x10(%ebp),%eax
8010a79a:	83 ec 04             	sub    $0x4,%esp
8010a79d:	ff 75 f4             	push   -0xc(%ebp)
8010a7a0:	68 39 ca 10 80       	push   $0x8010ca39
8010a7a5:	50                   	push   %eax
8010a7a6:	e8 31 00 00 00       	call   8010a7dc <http_strcpy>
8010a7ab:	83 c4 10             	add    $0x10,%esp
8010a7ae:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a7b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a7b4:	83 e0 01             	and    $0x1,%eax
8010a7b7:	85 c0                	test   %eax,%eax
8010a7b9:	74 11                	je     8010a7cc <http_proc+0x6e>
    char *payload = (char *)send;
8010a7bb:	8b 45 10             	mov    0x10(%ebp),%eax
8010a7be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a7c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a7c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a7c7:	01 d0                	add    %edx,%eax
8010a7c9:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a7cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a7cf:	8b 45 14             	mov    0x14(%ebp),%eax
8010a7d2:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a7d4:	e8 75 ff ff ff       	call   8010a74e <tcp_fin>
}
8010a7d9:	90                   	nop
8010a7da:	c9                   	leave
8010a7db:	c3                   	ret

8010a7dc <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a7dc:	55                   	push   %ebp
8010a7dd:	89 e5                	mov    %esp,%ebp
8010a7df:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a7e2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a7e9:	eb 20                	jmp    8010a80b <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a7eb:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a7ee:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a7f1:	01 d0                	add    %edx,%eax
8010a7f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a7f6:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a7f9:	01 ca                	add    %ecx,%edx
8010a7fb:	89 d1                	mov    %edx,%ecx
8010a7fd:	8b 55 08             	mov    0x8(%ebp),%edx
8010a800:	01 ca                	add    %ecx,%edx
8010a802:	0f b6 00             	movzbl (%eax),%eax
8010a805:	88 02                	mov    %al,(%edx)
    i++;
8010a807:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a80b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a80e:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a811:	01 d0                	add    %edx,%eax
8010a813:	0f b6 00             	movzbl (%eax),%eax
8010a816:	84 c0                	test   %al,%al
8010a818:	75 d1                	jne    8010a7eb <http_strcpy+0xf>
  }
  return i;
8010a81a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a81d:	c9                   	leave
8010a81e:	c3                   	ret

8010a81f <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a81f:	55                   	push   %ebp
8010a820:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a822:	c7 05 90 7d 19 80 c2 	movl   $0x8010f5c2,0x80197d90
8010a829:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a82c:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a831:	c1 e8 09             	shr    $0x9,%eax
8010a834:	a3 8c 7d 19 80       	mov    %eax,0x80197d8c
}
8010a839:	90                   	nop
8010a83a:	5d                   	pop    %ebp
8010a83b:	c3                   	ret

8010a83c <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a83c:	55                   	push   %ebp
8010a83d:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a83f:	90                   	nop
8010a840:	5d                   	pop    %ebp
8010a841:	c3                   	ret

8010a842 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a842:	55                   	push   %ebp
8010a843:	89 e5                	mov    %esp,%ebp
8010a845:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a848:	8b 45 08             	mov    0x8(%ebp),%eax
8010a84b:	83 c0 0c             	add    $0xc,%eax
8010a84e:	83 ec 0c             	sub    $0xc,%esp
8010a851:	50                   	push   %eax
8010a852:	e8 d2 a6 ff ff       	call   80104f29 <holdingsleep>
8010a857:	83 c4 10             	add    $0x10,%esp
8010a85a:	85 c0                	test   %eax,%eax
8010a85c:	75 0d                	jne    8010a86b <iderw+0x29>
    panic("iderw: buf not locked");
8010a85e:	83 ec 0c             	sub    $0xc,%esp
8010a861:	68 4a ca 10 80       	push   $0x8010ca4a
8010a866:	e8 3e 5d ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a86b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a86e:	8b 00                	mov    (%eax),%eax
8010a870:	83 e0 06             	and    $0x6,%eax
8010a873:	83 f8 02             	cmp    $0x2,%eax
8010a876:	75 0d                	jne    8010a885 <iderw+0x43>
    panic("iderw: nothing to do");
8010a878:	83 ec 0c             	sub    $0xc,%esp
8010a87b:	68 60 ca 10 80       	push   $0x8010ca60
8010a880:	e8 24 5d ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
8010a885:	8b 45 08             	mov    0x8(%ebp),%eax
8010a888:	8b 40 04             	mov    0x4(%eax),%eax
8010a88b:	83 f8 01             	cmp    $0x1,%eax
8010a88e:	74 0d                	je     8010a89d <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a890:	83 ec 0c             	sub    $0xc,%esp
8010a893:	68 75 ca 10 80       	push   $0x8010ca75
8010a898:	e8 0c 5d ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
8010a89d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8a0:	8b 40 08             	mov    0x8(%eax),%eax
8010a8a3:	8b 15 8c 7d 19 80    	mov    0x80197d8c,%edx
8010a8a9:	39 d0                	cmp    %edx,%eax
8010a8ab:	72 0d                	jb     8010a8ba <iderw+0x78>
    panic("iderw: block out of range");
8010a8ad:	83 ec 0c             	sub    $0xc,%esp
8010a8b0:	68 93 ca 10 80       	push   $0x8010ca93
8010a8b5:	e8 ef 5c ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a8ba:	8b 15 90 7d 19 80    	mov    0x80197d90,%edx
8010a8c0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8c3:	8b 40 08             	mov    0x8(%eax),%eax
8010a8c6:	c1 e0 09             	shl    $0x9,%eax
8010a8c9:	01 d0                	add    %edx,%eax
8010a8cb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a8ce:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8d1:	8b 00                	mov    (%eax),%eax
8010a8d3:	83 e0 04             	and    $0x4,%eax
8010a8d6:	85 c0                	test   %eax,%eax
8010a8d8:	74 2b                	je     8010a905 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a8da:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8dd:	8b 00                	mov    (%eax),%eax
8010a8df:	83 e0 fb             	and    $0xfffffffb,%eax
8010a8e2:	89 c2                	mov    %eax,%edx
8010a8e4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8e7:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a8e9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8ec:	83 c0 5c             	add    $0x5c,%eax
8010a8ef:	83 ec 04             	sub    $0x4,%esp
8010a8f2:	68 00 02 00 00       	push   $0x200
8010a8f7:	50                   	push   %eax
8010a8f8:	ff 75 f4             	push   -0xc(%ebp)
8010a8fb:	e8 ef a9 ff ff       	call   801052ef <memmove>
8010a900:	83 c4 10             	add    $0x10,%esp
8010a903:	eb 1a                	jmp    8010a91f <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a905:	8b 45 08             	mov    0x8(%ebp),%eax
8010a908:	83 c0 5c             	add    $0x5c,%eax
8010a90b:	83 ec 04             	sub    $0x4,%esp
8010a90e:	68 00 02 00 00       	push   $0x200
8010a913:	ff 75 f4             	push   -0xc(%ebp)
8010a916:	50                   	push   %eax
8010a917:	e8 d3 a9 ff ff       	call   801052ef <memmove>
8010a91c:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a91f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a922:	8b 00                	mov    (%eax),%eax
8010a924:	83 c8 02             	or     $0x2,%eax
8010a927:	89 c2                	mov    %eax,%edx
8010a929:	8b 45 08             	mov    0x8(%ebp),%eax
8010a92c:	89 10                	mov    %edx,(%eax)
}
8010a92e:	90                   	nop
8010a92f:	c9                   	leave
8010a930:	c3                   	ret
