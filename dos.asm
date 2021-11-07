; dos.asm
; This file is AS-DOS default DOS-Shell.

%include		"filelist.inc"

[BITS 16]
	ORG		FILE_INDEX + FILE_DOS

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
	

;_/_/_/_/   Print BootMessage
	MOV		SI, MSG_BOOTED
	CALL	print
	MOV 	SI, MSG_DOSPRMPT
	CALL 	print

;_/_/_/_/   Reset using memory
	XOR		AX, AX
	MOV		DI, 0x0540
	MOV		CX, 0x06FF-0x0540
	REP		STOSB
	
	MOV		DI, 0x0600
	
	XOR		CX, CX



;**************** DOS Prompt Routine
DOS:
;_/_/_/_/   Get pushed key code
	XOR 	AH, AH
	INT 	0x16
	CMP 	AL, 0x00    ; NULL code
	JE		DOS
	CMP 	AL, 13      ; Return code
	JE		KeyPut
	CMP		AL, 8       ; BackSpace
	JE		KeyDel
;================================ Unused Code
;	CMP		AL, 9		; Tab (Split On/Off)
;	JE		SHORT	KeySOF
;	CMP		AL, 0x20	; Space (Split)
;	JE		SHORT	KeySplit
;
;_/_/_/_/   Check OVER RUN
;	CMP 	DI, 0x0620  ; If ( DI >= 0x0620 )
;	JAE 	SHORT	DOS
;================================
;_/_/_/_/   Output key code for memory (ES:DI)
	MOV 	AH, 0x0E
	XOR 	BX, BX
	INT 	0x10

	STOSB

	HLT

	JMP		SHORT	DOS



;================================ Unused Code
;KeySOF:
;KeySplit:
;	MOV		BX, [0x0540]
;	OR		BX, BX
;	JZ		SHORT	KeySplitDo
;	JMP		SHORT	DOS
;	
;KeySplitDo:
;	MOV		BX, [0x0541]
;	INC		BX
;	CMP		BX, 0x08
;	JNE		SHORT	KeySplitDoCount
;	JMP		SHORT	DOS
;	
;KeySplitDoCount:
;	MOV		[0x0541], BX
;	MOV		AX, 0x20		; AX = AX x BX
;	MUL		BX
;	MOV		DI, 0x0600
;	ADD		DI, AX
;	
;	MOV		AH, 0x0E
;	MOV		AL, 0x20
;	XOR		BX, BX
;	INT		0x10
;	
;	JMP		SHORT	DOS
;================================	

;_/_/_/_/ Pushed Enter Key
KeyPut:
	MOV 	SI, MSG_CRLF
	CALL 	print

;_/_/_/_/_/_/_/_/ Commands!
	PUSHA

	MOV 	BX, 0x0600
	MOV 	SI, CMD_RESET
	CALL	Compare
	OR		AX, AX
	JZ		DCMD_RESET

	MOV 	BX, 0x0600
	MOV 	SI, CMD_HANG
	CALL	Compare
	OR		AX, AX
	JZ		DCMD_HANG

	MOV 	BX, 0x0600
	MOV 	SI, CMD_HELP
	CALL	Compare
	OR		AX, AX
	JZ		DCMD_HELP

	MOV 	BX, 0x0600
	MOV 	SI, CMD_ROMB
	CALL	Compare
	OR		AX, AX
	JZ		DCMD_ROMB
	
	MOV 	BX, 0x0600
	MOV 	SI, CMD_LFCHK
	CALL	Compare
	OR		AX, AX
	JZ		DCMD_LFCHK

	OR		AX, AX
	JNZ		SHORT	Key_CMDNTFUND

;_/_/_/_/ Command Return Point!
Key_Ret:

	POPA

	MOV 	SI, MSG_DOSPRMPT
	CALL	print

	;Clear commands
	XOR 	AX, AX
	MOV 	DI, 0x0540
	MOV 	CX, 0x06FF-0x0540
	REP 	STOSB

	MOV 	DI, 0x0600

	JMP 	DOS

Key_CMDNTFUND:
;_/_/_/_/	Put command text
	MOV 	SI, 0x0600
	CALL	print
	
	MOV 	SI, MSG_CMDNTFUND
	CALL	print
	JMP 	SHORT	Key_Ret



KeyDel:
	CMP		DI, 0x0600						; Check text cursor ( guard buffer over run )
	JNE 	SHORT	KeyDel_
	JMP 	DOS

KeyDel_:
	;_/_/_/_/ Screen
	MOV 	SI, MSG_BS						; Delete screen text
	CALL	print							; ACBDEF_	( start
	MOV 	SI, MSG_SP						; ABCDEE    ( back cursor
	CALL	print							; ABCDE _	( write space code
	MOV 	SI, MSG_BS						; ABCDE_	( back cursor
	CALL	print
	
;================================ Unused Code
;	;_/_/_/_/ Memory
;	MOV		AX, DX
;	OR		AL, AL
;	JZ		SHORT	KeyDel_RemoveParam
;================================

	XOR 	AL, AL							; Delete Memory Text
	DEC 	DI
	STOSB
	DEC 	DI

	JMP 	DOS
	
;================================ Unused Code
;KeyDel_RemoveParam:
;	MOV		BX, [0x0541]
;	DEC		BX
;	MOV		[0x0541], BX
;	MOV		AX, 0x20
;	MUL		BX
;	MOV		DI, 0x0600
;	ADD		DI, AX
;	
;	JMP		SHORT	DOS
;================================

;_/_/_/_/   Hang up
Hang:
	HLT
	JMP 	SHORT	Hang





;**************** Command Process
DCMD_RESET:
	INT 	0x19
	JMP 	SHORT	Hang

DCMD_HANG:
	JMP 	SHORT	Hang

DCMD_HELP:
	MOV 	SI, DCMD_HELP_MSG1
	CALL	print
	JMP 	SHORT	Key_Ret

DCMD_ROMB:
	INT 	0x18
	JMP 	SHORT	Hang

DCMD_HELP_MSG1:
	DB		"  reset     hang", 0x0D, 0x0A, "  help      romb", 0x0D, 0x0A, "  lfchk", 0x0D, 0x0A, 0x00
	
DCMD_LFCHK:
	MOV		SI, DCMD_LFCHK_MSG
	CALL	print
	MOV		BX, 0x0500
	MOV		SI, 0x0508
	CALL	Hex2Ascii
	MOV		SI, 0x0508
	CALL	print
	MOV		SI, MSG_CRLF
	CALL	print
	JMP		Key_Ret
	
DCMD_LFCHK_MSG:
	DB		"Loaded sector = 0x", 0x00
	
	
	
%include	"library.inc"
	
	
	
;_/_/_/_/   Messages
MSG:
	DB		"Booting", 0x0D, 0x0A, 0x00

MSG_CRLF:
	DB		0x0D, 0x0A, 0x00

MSG_BS:
	DB		0x08, 0x00

MSG_SP:
	DB		" ", 0x00

MSG_DOSPRMPT:
	DB		"AS-DOS System> ", 0x00

MSG_CMDNTFUND:
	DB		" is not found", 0x0D, 0x0A, 0x00
	
MSG_BOOTED:
	DB		"AS-DOS Ver.0.21", 0x0D, 0x0A, "Copyright (c) AkidukiSystems All Rights Reserved.", 0x0A, 0x0D, 0x00

;_/_/_/_/ Commands
CMD_RESET:
	DB		"reset", 0x00

CMD_HANG:
	DB		"hang", 0x00

CMD_HELP:
	DB		"help", 0x00

CMD_ROMB:
	DB		"romb", 0x00
	
CMD_LFCHK:
	DB		"lfchk", 0x00

