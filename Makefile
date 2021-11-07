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



$(BOOTSECT): $(aBOOTSECT) $(iFLIST) Makefile
	nasm -f bin $(aBOOTSECT) -o $(BOOTSECT)

$(SYSTEM): $(aSYSTEM) $(iFLIST) $(iLIB) Makefile
	nasm -f bin $(aSYSTEM) -o $(SYSTEM)

$(DOS): $(aDOS) $(iFLIST) $(iLIB) Makefile
	nasm -f bin $(aDOS) -o $(DOS)

$(FLIMG): $(BOOTSECT) $(SYSTEM) $(DOS) Makefile
	make -r $(BOOTSECT)
	make -r $(DOS)
	mformat -f 1440 -C -B $(BOOTSECT) -i $(FLIMG) ::
	mcopy -i $(FLIMG) $(SYSTEM) ::
	mcopy -i $(FLIMG) $(DOS) ::

	
run: $(FLIMG) Makefile
	make -r $(FLIMG)
	qemu-system-i386 -drive file=$(FLIMG),format=raw,if=floppy -monitor stdio
	
clean: Makefile
	rm -f $(FILE)