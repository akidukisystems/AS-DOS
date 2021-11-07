; boot.asm
; Please write this file for Floppy Image Boot Sector.

CYLS		EQU	10
INIV		EQU	1

%include	"filelist.inc"

[BITS 16]

	ORG		0x7C00

	JMP		Entry

	TIMES	0x80-($-$$)	DB	0


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

;_/_/_/_/   MemTest
MemTest:
	MOV 	DI, 0x7E00
	MOV 	SI, DI
	MOV 	CX, 0x7FFF-0x7E00					; Memtest 0x7E00 to 0x7FFF
	
MemTestLoop:
	MOV 	AX, 0xFF
	STOSB										; Write Memory
	LODSB										; Load Memory
	CMP 	AL, 0xFF
	DEC 	CX
	JNP 	SHORT	MemTestLoop





;_/_/_/_/   Init Video
	MOV		AX, INIV
	OR		AX, AX
	JNZ		InitVideo
	
	MOV		SI, MSG_NoInitVideo
	CALL	print
	
	JMP		NoInitVideo
	
InitVideo:
	XOR 	AH, AH
	MOV 	AL, 0x02
	INT 	0x10

	XOR		AX, AX
	
NoInitVideo:



;_/_/_/_/   Print BootMessage
	MOV 	SI, MSG
	CALL 	print

;_/_/_/_/   Init Memory at 0x7E00 to 0x7FFF
	XOR 	AX, AX
	MOV 	DI, 0x7E00
	MOV 	CX, 0x7FFF-0x7E00
	REP 	STOSB							; Write Memory

;_/_/_/_/	Read Floppy disk
	MOV 	AX, 0x0820						; Read on memory at 0x8200
	MOV 	ES, AX
	XOR 	CH, CH
	XOR 	DH, DH
	MOV 	CL, 0x02

FloppyReadLoop:
	XOR		SI, SI
FloppyReadRetry:
	MOV		AH, 0x02
	MOV		AL, 0x01
	XOR		BX, BX
	XOR		DL, DL
	INT		0x13
	JNC		SHORT	FloppyReadNext
	ADD		SI, 0x01
	CMP		SI, 0x05
	JAE		SHORT	FloppyReadError
	XOR		AH, AH
	XOR		DL, DL
	INT		0x13
	JMP		SHORT	FloppyReadRetry
FloppyReadNext:
	MOV		AX, ES
	ADD		AX, 0x0020
	MOV		ES, AX
	ADD		CL, 0x01
	CMP		CL, 18
	JBE		SHORT	FloppyReadLoop
	MOV		CL, 0x01
	ADD		DH, 0x01
	CMP		DH, 0x02
	JB		SHORT	FloppyReadLoop
	XOR		DH, DH
	ADD		CH, 0x01
	CMP		CH, CYLS
	JB		SHORT	FloppyReadLoop
	
	
	
	MOV		[0x0500], CH
	JMP		FILE_INDEX + FILE_ASDOS				; 0x8000 + 0x4200 = 0xC200		Jump to ASDOS.SYS
	
FloppyReadError:
	MOV		SI, MSGERR
	CALL	print
	INT		0x18





;_/_/_/_/_/_/_/_/ Function: print
;_/_/ Input
;AX = Not Using
;BX = 
;     BL = Color Code	( Initalized video-display 4bit color )
;CX = Not Using
;DX = Not Using
;SI = String Adress

print:
	PUSH	AX
	MOV		AH, 0x0E

.print_loop:
	LODSB
	OR		AL, AL
	JZ		.print_ret
	INT		 0x10
	JMP		SHORT	.print_loop

.print_ret:
	POP		AX
	RET





;_/_/_/_/   Messages
MSG:
	DB		"Booting AS-DOS...", 0x0D, 0x0A, 0x00

MSG_CRLF:
	DB		0x0D, 0x0A, 0x00
	
MSGERR:
	DB		"WARN: Cannot read and boot AS-DOS. Changing ROM-BASIC mode...", 0x0D, 0x0A, 0x00
	
MSG_NoInitVideo:
	DB		"WARN: AS-DOS is not initialized video-display.", 0x0D, 0x0A, 0x00





TIMES 510-($-$$) DB 0x00
	DB		0x55
	DB		0xAA