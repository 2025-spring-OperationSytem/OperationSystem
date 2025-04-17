qemu-system-x86_64 \
    -bios ./ovmf/OVMF.fd \
    -drive if=ide,file=fat:rw:image,index=0,media=disk \
    -m 2048 -smp 4 \
    -serial mon:stdio \
    -vga std
