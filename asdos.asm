; asdos.asm
; This file is AS-DOS System file.

%include	"filelist.inc"

[BITS 16]
	ORG		FILE_INDEX + FILE_ASDOS

	JMP		SHORT	Entry

Entry:

;_/_/_/_/	Reset Registers
	XOR		AX, AX
	MOV		BX, AX
	MOV		CX, AX
	MOV		DX, AX
	MOV		ES, AX
	MOV		DS, AX
	MOV		DI, AX
	MOV		SI, AX
	

;_/_/_/_/	Check Installed Memorys

	MOV		AX, 0xE801				; Get memory size ( 64KB )
	INT		0x15
	JC		CannotGetMemSize		; if "Carry Flag" is true, Skip store memory size process.

	MOV		WORD [0x0502], DX		; Store DI for [0x0502]

	MOV		BX, 0x0502				; Convert binary to ascii code.
	MOV		SI, 0x0510
	CALL	Hex2AsciiMW

	MOV		SI, 0x0510
	CALL	print

CannotGetMemSize:

	MOV		AH, 0x0F			; Get video parameter
	INT		0x10

	MOV		WORD [0x0520], AX
	MOV		BYTE [0x0522], BH

	
	XOR		AX, AX
	MOV		BX, AX
	MOV		CX, AX
	MOV		DX, AX

	
	MOV		SI, MSG
	CALL	print

	JMP		FILE_INDEX + FILE_DOS

Hang:
	HLT
	JMP		SHORT	Hang
	


%include	"library.inc"


	
MSG:	DB	"Loaded ASDOS.SYS", 0x0D, 0x0A, 0x00

