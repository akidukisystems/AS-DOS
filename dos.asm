; dos.asm
; This file is AS-DOS default DOS-Shell.

%include		"filelist.inc"

_CMD_NAME	EQU	0x0700
_CMD_PRM0	EQU	0x0720
_CMD_PRM1	EQU	0x0740
_CMD_PRM2	EQU	0x0760
_CMD_PRM3	EQU	0x0780
_CMD_PRM4	EQU	0x07A0
_CMD_PRM5	EQU	0x07C0
_CMD_PRM6	EQU	0x07E0

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
	MOV		SI, MSG_BOOT
	CALL	print
	MOV		SI, MSG_BOOTED
	CALL	print
	MOV 	SI, MSG_DOSPRMPT
	CALL 	print

;_/_/_/_/   Reset using memory
	XOR		AX, AX
	MOV		DI, 0x0540
	MOV		CX, 0x07FF-0x0540
	REP		STOSB
	
	MOV		DI, 0x0600
	
	XOR		CX, CX



;**************** DOS Prompt Routine
DOS:
;_/_/_/_/   Get pushed key code
	XOR 	AH, AH
	INT 	0x16
	CMP 	AL, 0x00    				; NULL code
	JE		SHORT	DOS
	CMP 	AL, 13      				; Return code
	JE		KeyPut
	CMP		AL, 8       				; BackSpace
	JE		KeyDel
;_/_/_/_/   Check OVER RUN
	CMP 	DI, 0x06FE  ; If ( DI = 0x06FE )
	JE 		SHORT	DOS

;_/_/_/_/   Output key code for memory (ES:DI)
	MOV 	AH, 0x0E
	XOR 	BX, BX
	INT 	0x10

	STOSB

	HLT

	JMP		SHORT	DOS



;_/_/_/_/ Pushed Enter Key
KeyPut:
	MOV 	SI, MSG_CRLF
	CALL 	print

;_/_/_/_/_/_/_/_/ Command Split

	MOV		SI, 0x0600
	MOV		DI, 0x0700
	XOR		AX, AX

KeySplit:

	LODSB						; Load ES:SI from AL

	OR		AL, AL				; if AL = null
	JZ		KeySplitDone

	CMP		AL, 0x20
	JE		KeySplit_SP

	MOV		BL, BYTE [0x0542]	; Buffer Over Run
	CMP		BL, 0x1F			; if writed letter count is 0x1F
	JE		KeySplit_SP

	STOSB

	MOV		BL, BYTE [0x0542]	; writed letter count
	INC		BL
	MOV		BYTE [0x0542], BL

	JMP		KeySplit

KeySplit_SP:

	MOV		BH, BYTE [0x0542]	; Next parameter
	MOV		BL, 0x20			; DI = DI + ( BH - 0x20 )
	SUB		BL, BH				; BH is writed letter count
	XOR		BH, BH				; DI is Parameter Index

	MOV		BYTE [0x0542], BH

	ADD		DI, BX
	JMP		SHORT	KeySplit

KeySplitDone:

;_/_/_/_/_/_/_/_/ Commands!
	PUSHA

	MOV 	BX, _CMD_NAME
	MOV 	SI, MSG_NULL
	CALL	Compare
	OR		AX, AX
	JZ		Key_Ret

	MOV		BX, _CMD_NAME
	MOV		SI, DCMD_RESET
	CALL	Command
	
	MOV		BX, _CMD_NAME
	MOV		SI, DCMD_HELP
	CALL	Command

	MOV		BX, _CMD_NAME
	MOV		SI, DCMD_ROMB
	CALL	Command

	MOV		BX, _CMD_NAME
	MOV		SI, DCMD_LFCHK
	CALL	Command

	MOV		BX, _CMD_NAME
	MOV		SI, DCMD_EXIT
	CALL	Command

	MOV		BX, _CMD_NAME
	MOV		SI, DCMD_CLS
	CALL	Command

;	MOV 	BX, _CMD_NAME
;	MOV 	SI, CMD_RESET
;	CALL	Compare
;	OR		AX, AX
;	JZ		DCMD_RESET
;
;	MOV 	BX, _CMD_NAME
;	MOV 	SI, CMD_HELP
;	CALL	Compare
;	OR		AX, AX
;	JZ		DCMD_HELP
;
;	MOV 	BX, _CMD_NAME
;	MOV 	SI, CMD_ROMB
;	CALL	Compare
;	OR		AX, AX
;	JZ		DCMD_ROMB
;	
;	MOV 	BX, _CMD_NAME
;	MOV 	SI, CMD_LFCHK
;	CALL	Compare
;	OR		AX, AX
;	JZ		DCMD_LFCHK
;
;	MOV 	BX, _CMD_NAME
;	MOV 	SI, CMD_EXIT
;	CALL	Compare
;	OR		AX, AX
;	JZ		DCMD_EXIT
;
;	MOV 	BX, _CMD_NAME
;	MOV 	SI, CMD_CLS
;	CALL	Compare
;	OR		AX, AX
;	JZ		DCMD_CLS

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
	MOV 	CX, 0x07FF-0x0540
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

	XOR 	AL, AL							; Delete Memory Text
	DEC 	DI
	STOSB
	DEC 	DI

	JMP 	DOS

;================================

;_/_/_/_/   Hang up
Hang:
	HLT
	JMP 	SHORT	Hang





;**************** Command Process
DCMD_RESET:
	DB		"reset"
	TIMES	12-5	DB	0x00

	INT 	0x19
	RET

DCMD_HANG:
	DB		"hang"
	TIMES	12-4	DB	0x00

	JMP 	SHORT	Hang

DCMD_HELP:
	DB		"help"
	TIMES	12-4	DB	0x00

%include	"dos_help.asm"
	

DCMD_ROMB:
	DB		"romb"
	TIMES	12-4	DB	0x00

	INT 	0x18
	JMP 	Hang
	
DCMD_LFCHK:
	DB		"lfchk"
	TIMES	12-5	DB	0x00

	MOV		SI, DCMD_LFCHK_MSG
	CALL	print
	MOV		BX, 0x0500
	MOV		SI, 0x0508
	CALL	Hex2Ascii
	MOV		SI, 0x0508
	CALL	print
	MOV		SI, MSG_CRLF
	CALL	print
	MOV		SI, MSG_CRLF
	CALL	print
	JMP		Key_Ret
	
DCMD_LFCHK_MSG:
	DB		"Loaded sector = 0x", 0x00

DCMD_EXIT:
	DB		"exit"
	TIMES	12-4	DB	0x00

	INT 	0x18
	JMP 	Hang

DCMD_CLS:
	DB		"cls"
	TIMES	12-3	DB	0x00

	XOR 	AH, AH
	MOV 	AL, 0x02
	INT 	0x10

	MOV		SI, MSG_BOOTED
	CALL	print

	JMP		Key_Ret
	
	
	
%include	"library.inc"
	
	
	
;_/_/_/_/   Messages
MSG_BOOT:
	DB		"Loading DOS prompt...", 0x0D, 0x0A

MSG_NULL:
	DB		0x00

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
	DB		"AS-DOS Ver.0.4", 0x0D, 0x0A, "Copyright (c) 2021 AkidukiSystems All Rights Reserved.", 0x0A, 0x0D, 0x00
