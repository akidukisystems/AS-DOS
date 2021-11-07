; asdos.asm
; This file is AS-DOS System file.

%include	"filelist.inc"

[BITS 16]
	ORG		FILE_INDEX + FILE_ASDOS

	JMP		SHORT	Entry

Entry:

;\_\_\_\_	Reset Registers
	XOR		AX, AX
	MOV		BX, AX
	MOV		CX, AX
	MOV		DX, AX
	MOV		ES, AX
	MOV		DS, AX
	MOV		DI, AX
	MOV		SI, AX
	

;\_\_\_\_	Check Installed Memorys
	INT		0x12
	MOV		BX, AX
	MOV		WORD [0x0502], BX
	
	XOR		AX, AX

	
	MOV		SI, MSG
	CALL	print
	
	JMP		FILE_INDEX + FILE_DOS

Hang:
	HLT
	JMP		SHORT	Hang
	


%include	"library.inc"


	
MSG:	DB	"Loaded ASDOS.SYS", 0x0D, 0x0A, 0x00
