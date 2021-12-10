# AS-DOS Makefile
# Copyright (c) 2021 AkidukiSystems All Rights Reserved.

# How to use?
# 1. Make floppy image file and execute its file...
#    Run command ' $ make '
# 2. Make floppy image file and debug binary system file...
#    Run command ' $ make nrm '
# 3. Make floppy image file... ( Not execute )
#    Run command ' $ make release '
#    If you copied its file, please run this command. ( Cleaning binary system file )
#    Command:    ' $ make clean '
#
# What does this word mean?
# - Binary system file...
#   Files required to run the system. ( BOOT.BIN, ASDOS.SYS, DOS.SYS 
#   This files will be copied in the floppy image file. )
#   ( BOOT.BIN will be stored in the boot sector. )
# - Floppy image file...
#   This is the file that qemu will execute directly. ( FLOPPY.IMG )


FLIMG		= floppy.img
BOOTSECT	= boot.bin
SYSTEM		= asdos.sys
DOS			= dos.sys

aBOOTSECT	= boot.asm
aSYSTEM		= asdos.asm
aDOS		= dos.asm
iFLIST		= filelist.inc
iLIB		= library.inc

SRC			= $(aBOOTSECT) $(aSYSTEM) $(aDOS) $(iFLIST) $(iLIB)
FILE		= $(FLIMG) $(BOOTSECT) $(SYSTEM) $(DOS)



default: Makefile
	make -r run
	make -r clean

nrm: Makefile
	make -r run

release: Makefile
	make -r $(FLIMG)



$(BOOTSECT): $(aBOOTSECT) $(iFLIST) Makefile
	nasm -f bin $(aBOOTSECT) -o $(BOOTSECT)

$(SYSTEM): $(aSYSTEM) $(iFLIST) $(iLIB) Makefile
	nasm -f bin $(aSYSTEM) -o $(SYSTEM)

$(DOS): $(aDOS) $(iFLIST) $(iLIB) Makefile
	nasm -f bin $(aDOS) -o $(DOS)

$(FLIMG): $(BOOTSECT) $(SYSTEM) $(DOS) Makefile
	make -r $(BOOTSECT)
	make -r $(DOS)
	mformat -f 1440 -C -v AS-DOS -I 12 -B $(BOOTSECT) -i $(FLIMG) ::
#   Coping system files
	mcopy -i $(FLIMG) $(SYSTEM) ::
	mcopy -i $(FLIMG) $(DOS) ::

	
run: $(FLIMG) Makefile
	make -r clean
	make -r $(FLIMG)
	qemu-system-i386 -drive file=$(FLIMG),format=raw,if=floppy -monitor stdio
	
clean: Makefile
	rm -f $(FILE)