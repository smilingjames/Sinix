######################
# Makefile for Sinix#
######################



# Entry point of Sinix 
# It must be as same as 'KernelEntryPointPhyAddr' in load.inc!!!
ENTRYPOINT	= 0x1000

# Offset of entry point in kernel file
# It depends on ENTRYPOINT
ENTRYOFFSET	=   0x400


# Programs, flags, etc.
ASM		= nasm
DASM		= ndisasm
CC		= gcc 
LD		= ld 
ASMBFLAGS	= -I ./boot/include
ASMKFLAGS	= -I include -f elf
CFLAGS		= -I include/ -I include/sys/ -c -fno-builtin -Wall -ffreestanding -nostdlib -m32
#CFLAGS		= -I include -c -fno-builtin -ffreestanding -nostdlib
#LDFLAGS		= -s -Ttext $(ENTRYPOINT)
#DASMFLAGS	= -u -o $(ENTRYPOINT) -e $(ENTRYOFFSET)
LDFLAGS		= -Ttext $(ENTRYPOINT) -Map krnl.map -m elf_i386
DASMFLAGS	= -D 

# This Program
SINIXBOOT	= boot/boot.bin boot/loader.bin
SINIXKERNEL	= kernel.bin
LIB			= lib/sinixcrt.a

OBJS		= kernel/kernel.o kernel/start.o kernel/main.o\
			kernel/clock.o kernel/keyboard.o kernel/tty.o kernel/console.o\
			kernel/i8259.o kernel/global.o kernel/protect.o kernel/proc.o\
			kernel/systask.o kernel/hd.o\
			kernel/kliba.o kernel/klib.o\
			lib/syslog.o\
			mm/main.o mm/forkexit.o mm/exec.o\
			fs/main.o fs/open.o fs/misc.o fs/read_write.o\
			fs/link.o\
			fs/disklog.o
LOBJS		=  lib/syscall.o\
			lib/printf.o lib/vsprintf.o\
			lib/string.o lib/misc.o\
			lib/open.o lib/read.o lib/write.o lib/close.o lib/unlink.o\
			lib/lseek.o\
			lib/getpid.o lib/stat.o\
			lib/fork.o lib/exit.o lib/wait.o lib/exec.o
DASMOUTPUT	= kernel.bin.asm

# All Phony Targets
.PHONY : everything final image clean distclean disasm all buildimg

# Default starting position
everything : $(SINIXBOOT) $(SINIXKERNEL)

all : distclean everything

final : all clean

image : final buildimg

clean :
	rm -f $(OBJS) $(LOBJS)

distclean :
	rm -f $(OBJS) $(LOBJS) $(LIB) $(SINIXBOOT) $(SINIXKERNEL)

disasm :
	$(DASM) $(DASMFLAGS) $(SINIXKERNEL) > $(DASMOUTPUT)

# Write "boot.bin" & "loader.bin" into floppy image "SINIX.IMG"
# We assume that "SINIX.IMG" exists in current folder
buildimg :
	sudo mount /home/james/Sinix/SINIX.IMG /home/james/Sinix/floppy -o loop
	sudo cp -f boot/loader.bin /home/james/Sinix/floppy/
	sudo cp -f kernel.bin /home/james/Sinix/floppy
	sleep 1
	sudo umount  /home/james/Sinix/floppy

boot/boot.bin : boot/boot.asm boot/include/load.inc boot/include/fat12hdr.inc
	$(ASM) $(ASMBFLAGS) -o $@ $<

boot/loader.bin : boot/loader.asm boot/include/load.inc boot/include/fat12hdr.inc boot/include/pm.inc
	$(ASM) $(ASMBFLAGS) -o $@ $<

$(SINIXKERNEL) : $(OBJS) $(LIB)
	$(LD) $(LDFLAGS) -o $(SINIXKERNEL) $^

$(LIB) : $(LOBJS)
	$(AR) $(ARFLAGS) $@ $^

kernel/kernel.o : kernel/kernel.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<

lib/syscall.o : lib/syscall.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<

kernel/start.o: kernel/start.c
	$(CC) $(CFLAGS) -o $@ $<

kernel/main.o: kernel/main.c
	$(CC) $(CFLAGS) -o $@ $<

kernel/clock.o: kernel/clock.c
	$(CC) $(CFLAGS) -o $@ $<

kernel/keyboard.o: kernel/keyboard.c
	$(CC) $(CFLAGS) -o $@ $<

kernel/tty.o: kernel/tty.c
	$(CC) $(CFLAGS) -o $@ $<

kernel/console.o: kernel/console.c
	$(CC) $(CFLAGS) -o $@ $<

kernel/i8259.o: kernel/i8259.c
	$(CC) $(CFLAGS) -o $@ $<

kernel/global.o: kernel/global.c
	$(CC) $(CFLAGS) -o $@ $<

kernel/protect.o: kernel/protect.c
	$(CC) $(CFLAGS) -o $@ $<

kernel/proc.o: kernel/proc.c
	$(CC) $(CFLAGS) -o $@ $<

lib/printf.o: lib/printf.c
	$(CC) $(CFLAGS) -o $@ $<

lib/vsprintf.o: lib/vsprintf.c
	$(CC) $(CFLAGS) -o $@ $<

kernel/systask.o: kernel/systask.c
	$(CC) $(CFLAGS) -o $@ $<

kernel/hd.o: kernel/hd.c
	$(CC) $(CFLAGS) -o $@ $<

kernel/kliba.o : kernel/kliba.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<

kernel/klib.o: kernel/klib.c
	$(CC) $(CFLAGS) -o $@ $<

lib/misc.o: lib/misc.c
	$(CC) $(CFLAGS) -o $@ $<

lib/string.o : lib/string.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<

lib/open.o: lib/open.c
	$(CC) $(CFLAGS) -o $@ $<

lib/read.o: lib/read.c
	$(CC) $(CFLAGS) -o $@ $<

lib/write.o: lib/write.c
	$(CC) $(CFLAGS) -o $@ $<

lib/close.o: lib/close.c
	$(CC) $(CFLAGS) -o $@ $<

lib/unlink.o: lib/unlink.c
	$(CC) $(CFLAGS) -o $@ $<

lib/getpid.o: lib/getpid.c
	$(CC) $(CFLAGS) -o $@ $<

lib/syslog.o: lib/syslog.c
	$(CC) $(CFLAGS) -o $@ $<

lib/fork.o: lib/fork.c
	$(CC) $(CFLAGS) -o $@ $<

lib/exit.o: lib/exit.c
	$(CC) $(CFLAGS) -o $@ $<

lib/wait.o: lib/wait.c
	$(CC) $(CFLAGS) -o $@ $<

lib/exec.o: lib/exec.c
	$(CC) $(CFLAGS) -o $@ $<

lib/stat.o: lib/stat.c
	$(CC) $(CFLAGS) -o $@ $<

lib/lseek.o: lib/lseek.c
	$(CC) $(CFLAGS) -o $@ $<

mm/main.o: mm/main.c
	$(CC) $(CFLAGS) -o $@ $<

mm/forkexit.o: mm/forkexit.c
	$(CC) $(CFLAGS) -o $@ $<

mm/exec.o: mm/exec.c
	$(CC) $(CFLAGS) -o $@ $<

fs/main.o: fs/main.c
	$(CC) $(CFLAGS) -o $@ $<

fs/open.o: fs/open.c
	$(CC) $(CFLAGS) -o $@ $<

fs/read_write.o: fs/read_write.c
	$(CC) $(CFLAGS) -o $@ $<


fs/link.o: fs/link.c
	$(CC) $(CFLAGS) -o $@ $<

fs/disklog.o: fs/disklog.c
	$(CC) $(CFLAGS) -o $@ $<
