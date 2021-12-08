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

DM_CommandAdress			EQU	0x0600
DM_DOS_SYS_Memory_Start		EQU 0x0540
DM_DOS_SYS_Memory_End		EQU 0x07FF
DM_DOS_SYS_Memory_Spaces	EQU	DM_DOS_SYS_Memory_End - DM_DOS_SYS_Memory_Start

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

	MOV		CX, 0x0007
	MOV		DX, 0xA120
	CALL	Waitf


;_/_/_/_/   Print BootMessage
	MOV		SI, MSG_BOOT
	CALL	print
	MOV		SI, MSG_BOOTED
	CALL	print
	MOV 	SI, MSG_DOSPRMPT
	CALL 	print

;_/_/_/_/   Reset using memory
	XOR		AX, AX
	MOV		DI, DM_DOS_SYS_Memory_Start
	MOV		CX, DM_DOS_SYS_Memory_Spaces
	REP		STOSB

	MOV		DI, DM_CommandAdress

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

	MOV		SI, DM_CommandAdress
	MOV		DI, 0x0700
	XOR		AX, AX

KeySplit:

	LODSB						; Load ES:SI from AL

	OR		AL, AL				; if AL = null
	JZ		KeySplitDone

	CMP		AL, 0x20
	JE		KeySplit_SP

									; Buffer Over Run Protect
	CMP		BYTE [0x0542], 0x1F		; if writed letter count is 0x1F
	JE		KeySplit_SP

	STOSB

	INC		BYTE [0x0542]

;	MOV		BL, BYTE [0x0542]	; writed letter count
;	INC		BL
;	MOV		BYTE [0x0542], BL

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
	OR		AL, AL
	JZ		ReturnAdrs

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

	MOV		BX, _CMD_NAME
	MOV		SI, DCMD_MEM
	CALL	Command

	MOV		BX, _CMD_NAME
	MOV		SI, DCMD_INFO
	CALL	Command

	MOV		BX, _CMD_NAME
	MOV		SI, DCMD_TIME
	CALL	Command

	OR		AX, AX
	JNZ		SHORT	Key_CMDNTFUND

;_/_/_/_/ Command Return Point!
ReturnAdrs:

	POPA

	MOV 	SI, MSG_DOSPRMPT
	CALL	print

	;Clear commands
	XOR 	AX, AX
	MOV 	DI, DM_DOS_SYS_Memory_Start
	MOV 	CX, DM_DOS_SYS_Memory_Spaces
	REP 	STOSB

	MOV 	DI, DM_CommandAdress

	JMP 	DOS

Key_CMDNTFUND:
;_/_/_/_/	Put command text
	MOV 	SI, DM_CommandAdress
	CALL	print

	MOV 	SI, MSG_CMDNTFUND
	CALL	print
	JMP 	SHORT	ReturnAdrs



KeyDel:
	CMP		DI, DM_CommandAdress						; Check text cursor ( guard buffer over run )
	JNE 	SHORT	KeyDel_
	JMP 	DOS

KeyDel_:
	;_/_/_/_/ Screen
	MOV 	BL, 0x08						; Delete screen text
	CALL	Oprint							; ACBDEF_	( start
	MOV 	BL, 0x20						; ABCDEE    ( back cursor
	CALL	Oprint							; ABCDE _	( write space code
	MOV 	BL, 0x08						; ABCDE_	( back cursor
	CALL	Oprint

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


DCMD_HELP:
	DB		"help"
	TIMES	12-4	DB	0x00

%include	"dos_help.asm"


DCMD_ROMB:
	DB		"romb"
	TIMES	12-4	DB	0x00

	INT 	0x18

DCMD_LFCHK:
	DB		"lfchk"
	TIMES	12-5	DB	0x00

	MOV		SI, .MSG
	CALL	print
	MOV		BX, 0x0500
	MOV		SI, 0x0508
	CALL	Hex2AsciiMW
	MOV		SI, 0x0508
	CALL	print
	MOV		SI, MSG_CRLF
	CALL	print
	MOV		SI, MSG_CRLF
	CALL	print
	JMP		ReturnAdrs

.MSG:
	DB		"Loaded sector = 0x", 0x00

DCMD_EXIT:
	DB		"exit"
	TIMES	12-4	DB	0x00

	INT 	0x18

DCMD_CLS:
	DB		"cls"
	TIMES	12-3	DB	0x00

	XOR 	AH, AH
	MOV 	AL, 0x02
	INT 	0x10

	MOV		SI, MSG_BOOTED
	CALL	print

	JMP		ReturnAdrs

DCMD_MEM:
	DB		"mem"
	TIMES	12-3	DB	0x00

	MOV		SI, .MSG
	CALL	print
	MOV		BX, 0x0502
	MOV		SI, 0x0510
	CALL	Hex2AsciiMW
	MOV		SI, 0x0510
	CALL	print
	MOV		SI, MSG_CRLF
	CALL	print
	MOV		SI, MSG_CRLF
	CALL	print
	JMP		ReturnAdrs

.MSG:
	DB		"Installed memory = 0x", 0x00

DCMD_INFO:
	DB		"info"
	TIMES	12-4	DB	0x00

	MOV		BX, _CMD_PRM0
	MOV		SI, .MSG_LFCHK
	CALL	Compare
	OR		AL, AL
	JZ		.LFCHK

	MOV		BX, _CMD_PRM0
	MOV		SI, .MSG_MEM
	CALL	Compare
	OR		AL, AL
	JZ		.MEM

	JMP		ReturnAdrs

.LFCHK:
	MOV		SI, .LFCHK_MSG
	CALL	print
	MOV		BX, 0x0500
	MOV		SI, 0x0508
	CALL	Hex2AsciiMW
	MOV		SI, 0x0508
	CALL	print
	MOV		SI, MSG_CRLF
	CALL	print
	MOV		SI, MSG_CRLF
	CALL	print
	JMP		ReturnAdrs

.LFCHK_MSG:
	DB		"Loaded sector = 0x", 0x00

.MEM:
	MOV		SI, .MEM_MSG
	CALL	print
	MOV		BX, 0x0502
	MOV		SI, 0x0510
	CALL	Hex2AsciiMW
	MOV		SI, 0x0510
	CALL	print
	MOV		SI, MSG_CRLF
	CALL	print
	MOV		SI, MSG_CRLF
	CALL	print
	JMP		ReturnAdrs

.MEM_MSG:
	DB		"Installed memory = 0x", 0x00

.MSG_LFCHK:
	DB		"lfchk", 0x00

.MSG_MEM:
	DB		"mem", 0x00

DCMD_TIME:
	DB		"time"
	TIMES	12-4	DB	0x00

	MOV		AH, 0x02
	INT		0x1A
	
	; CL, CH, DL, DH ( min, hour, summertime, sec )
	MOV		WORD [0x7E00], CX
	MOV		WORD [0x7E02], DX

	MOV		BX, 0x7E00
	MOV		SI, 0x7E10
	CALL	Hex2AsciiMB

	MOV		BX, 0x7E01
	MOV		SI, 0x7E13
	CALL	Hex2AsciiMB

	MOV		BX, 0x7E02
	MOV		SI, 0x7E16
	CALL	Hex2AsciiMB

	MOV		BX, 0x7E03
	MOV		SI, 0x7E19
	CALL	Hex2AsciiMB

	MOV		SI, 0x7E13
	CALL	print
	MOV		BL, ":"
	CALL	Oprint

	MOV		SI, 0x7E10
	CALL	print
	MOV		BL, ":"
	CALL	Oprint

	MOV		SI, 0x7E19
	CALL	print

	MOV		SI, MSG_CRLF
	CALL	print
	MOV		SI, MSG_CRLF
	CALL	print

	MOV		DI, 0x7E00
	MOV		CX, 0x20
	XOR		AL, AL
	REP		STOSB

	JMP		ReturnAdrs




%include	"library.inc"



;_/_/_/_/   Messages
MSG_BOOT:
	DB		"Loading DOS prompt...", 0x0D, 0x0A

MSG_NULL:
	DB		0x00

MSG_CRLF:
	DB		0x0D, 0x0A, 0x00

MSG_DOSPRMPT:
	DB		"System @ ", 0x00

MSG_CMDNTFUND:
	DB		" is not found", 0x0D, 0x0A, 0x00

MSG_BOOTED:
	DB		"AS-DOS Ver.0.6", 0x0D, 0x0A
	DB		"Copyright (c) 2021 AkidukiSystems All Rights Reserved.", 0x0A, 0x0D, 0x00
