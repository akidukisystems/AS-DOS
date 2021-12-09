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


%include		"memlist.inc"


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
	MOV		DI, DM_DOS_SYS_DOSPrompt_Memory_Start
	MOV		CX, DM_DOS_SYS_DOSPrompt_Memory_Spaces
	REP		STOSB

	MOV		DI, DM_DOS_SYS_CommandAdress

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

	MOV		SI, DM_DOS_SYS_CommandAdress
	MOV		DI, DM_DOS_SYS_SplitedCommand
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
	MOV		SI, DCMD_EXIT
	CALL	Command

	MOV		BX, _CMD_NAME
	MOV		SI, DCMD_CLS
	CALL	Command

	MOV		BX, _CMD_NAME
	MOV		SI, DCMD_INFO
	CALL	Command

	MOV		BX, _CMD_NAME
	MOV		SI, DCMD_TIME
	CALL	Command

	MOV		BX, _CMD_NAME
	MOV		SI, DCMD_DATE
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
	MOV 	DI, DM_DOS_SYS_DOSPrompt_Memory_Start
	MOV 	CX, DM_DOS_SYS_DOSPrompt_Memory_Spaces
	REP 	STOSB

	MOV 	DI, DM_DOS_SYS_CommandAdress

	JMP 	DOS

Key_CMDNTFUND:
;_/_/_/_/	Put command text
	MOV 	SI, DM_DOS_SYS_CommandAdress
	CALL	print

	MOV 	SI, MSG_CMDNTFUND
	CALL	print
	JMP 	SHORT	ReturnAdrs



KeyDel:
	CMP		DI, DM_DOS_SYS_CommandAdress						; Check text cursor ( guard buffer over run )
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
._name:
	DB		"reset"
	TIMES	12- ($-DCMD_RESET)	DB	0x00

._help:
	MOV     SI, ._help_MSG
    CALL    print
    
    JMP     ReturnAdrs

._help_MSG:
    DB      "Reset and boot AS-DOS.", 0x0D, 0x0A, " > reset", 0x0D, 0x0A, 0x0D, 0x0A, 0x00

	TIMES	0x200- ($-._help)	DB	0x00
._main:
	INT 	0x19


DCMD_HELP:
._name:
	DB		"help"
	TIMES	12- ($-DCMD_HELP)	DB	0x00

._help:
	MOV     SI, ._help_MSG
    CALL    print
    
    JMP     ReturnAdrs

._help_MSG:
    DB      "Print help infomation.", 0x0D, 0x0A, " > help <command name>", 0x0D, 0x0A, 0x0D, 0x0A, 0x00

	TIMES	0x200- ($-._help)	DB	0x00

._main:
%include	"dos_help.asm"


DCMD_ROMB:
._name:
	DB		"romb"
	TIMES	12- ($-DCMD_ROMB)	DB	0x00

._help:
	MOV     SI, ._help_MSG
    CALL    print
    
    JMP     ReturnAdrs

._help_MSG:
    DB      "Change ROM-BASIC mode.", 0x0D, 0x0A, " > romb", 0x0D, 0x0A, 0x0D, 0x0A, 0x00

	TIMES	0x200- ($-._help)	DB	0x00
._main:
	INT 	0x18

DCMD_EXIT:
._name:
	DB		"exit"
	TIMES	12- ($-DCMD_EXIT)	DB	0x00

._help:
	MOV     SI, ._help_MSG
    CALL    print
    
    JMP     ReturnAdrs

._help_MSG:
    DB      "Exit AS-DOS.", 0x0D, 0x0A, " > exit", 0x0D, 0x0A, 0x0D, 0x0A, 0x00

	TIMES	0x200- ($-._help)	DB	0x00
._main:
	INT 	0x18

DCMD_CLS:
._name:
	DB		"cls"
	TIMES	12- ($-DCMD_CLS)	DB	0x00

._help:
	MOV     SI, ._help_MSG
    CALL    print
    
    JMP     ReturnAdrs

._help_MSG:
    DB      "Clear screen.", 0x0D, 0x0A, " > cls", 0x0D, 0x0A, 0x0D, 0x0A, 0x00


	TIMES	0x200- ($-._help)	DB	0x00
._main:
	XOR 	AH, AH
	MOV 	AL, 0x02
	INT 	0x10

	MOV		SI, MSG_BOOTED
	CALL	print

	JMP		ReturnAdrs

DCMD_INFO:
._name:
	DB		"info"
	TIMES	12- ($-DCMD_INFO)	DB	0x00

._help:
	MOV     SI, ._help_MSG
    CALL    print
    
    JMP     ReturnAdrs

._help_MSG:
    DB      "Print infomation data.", 0x0D, 0x0A, " > info <type>", 0x0D, 0x0A
    DB      " <type> parameter...", 0x0D, 0x0A
    DB      "        lfchk = Print loaded floppy disk sector.", 0x0D, 0x0A
    DB      "        mem   = Print installed memory size.", 0x0D, 0x0A, 0x0D, 0x0A, 0x00

	TIMES	0x200- ($-._help)	DB	0x00

._main:
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
	MOV		SI, .LFCHK_MSG1
	CALL	print
	MOV		BX, 0x0500
	MOV		SI, 0x0508
	CALL	Hex2AsciiMW
	MOV		SI, 0x0508
	CALL	print
	MOV		SI, .LFCHK_MSG2
	CALL	print

	MOV		SI, MSG_CRLF
	CALL	print
	MOV		SI, MSG_CRLF
	CALL	print

	JMP		ReturnAdrs

.LFCHK_MSG1:
	DB		"Loaded floppy disk size = 0x", 0x00
.LFCHK_MSG2:
	DB		" Sectors", 0x00

.MEM:
	MOV		SI, .MEM_MSG1
	CALL	print
	MOV		BX, 0x0502
	MOV		SI, 0x0510
	CALL	Hex2AsciiMW
	MOV		SI, 0x0510
	CALL	print
	MOV		SI, .MEM_MSG2
	CALL	print

	MOV		SI, MSG_CRLF
	CALL	print
	MOV		SI, MSG_CRLF
	CALL	print

	JMP		ReturnAdrs

.MEM_MSG1:
	DB		"Installed memory = 0x", 0x00
.MEM_MSG2:
	DB		" x 64KiB", 0x00

.MSG_LFCHK:
	DB		"lfchk", 0x00

.MSG_MEM:
	DB		"mem", 0x00

DCMD_TIME:
._name:
	DB		"time"
	TIMES	12- ($-DCMD_TIME)	DB	0x00

._help:
	MOV     SI, ._help_MSG
    CALL    print
    
    JMP     ReturnAdrs

._help_MSG:
    DB      "Print now time.", 0x0D, 0x0A, " > time", 0x0D, 0x0A, 0x0D, 0x0A, 0x00


	TIMES	0x200- ($-._help)	DB	0x00
._main:
	MOV		AH, 0x02
	INT		0x1A
	
	; CL, CH, DL, DH ( min, hour, summertime, sec )
	MOV		WORD [0x0A00], CX
	MOV		WORD [0x0A02], DX

	MOV		BX, 0x0A00
	MOV		SI, 0x0A10
	CALL	Hex2AsciiMB

	MOV		BX, 0x0A01
	MOV		SI, 0x0A13
	CALL	Hex2AsciiMB

	MOV		BX, 0x0A02
	MOV		SI, 0x0A16
	CALL	Hex2AsciiMB

	MOV		BX, 0x0A03
	MOV		SI, 0x0A19
	CALL	Hex2AsciiMB

	MOV		SI, 0x0A13
	CALL	print
	MOV		BL, ":"
	CALL	Oprint

	MOV		SI, 0x0A10
	CALL	print
	MOV		BL, ":"
	CALL	Oprint

	MOV		SI, 0x0A19
	CALL	print

	MOV		SI, MSG_CRLF
	CALL	print
	MOV		SI, MSG_CRLF
	CALL	print

	MOV		DI, 0x0A00
	MOV		CX, 0x20
	XOR		AL, AL
	REP		STOSB

	JMP		ReturnAdrs

DCMD_DATE:
._name:
	DB		"date"
	TIMES	12- ($-DCMD_DATE)	DB	0x00

._help:
	MOV     SI, .MSG
    CALL    print
    
    JMP     ReturnAdrs

.MSG:
    DB      "Print now date.", 0x0D, 0x0A, " > date", 0x0D, 0x0A, 0x0D, 0x0A, 0x00

	TIMES	0x200- ($-._help)	DB	0x00

._main:
	MOV		AH, 0x04
	INT		0x1A

	; CL, CH, DL, DH ( LowerYear, UpperYear, Day, Month )
	MOV		WORD [0x0A00], CX
	MOV		WORD [0x0A02], DX


	MOV		BX, 0x0A00
	MOV		SI, 0x0A10
	CALL	Hex2AsciiMB

	MOV		BX, 0x0A01
	MOV		SI, 0x0A13
	CALL	Hex2AsciiMB

	MOV		BX, 0x0A02
	MOV		SI, 0x0A16
	CALL	Hex2AsciiMB

	MOV		BX, 0x0A03
	MOV		SI, 0x0A19
	CALL	Hex2AsciiMB

	MOV		SI, 0x0A13
	CALL	print
	MOV		SI, 0x0A10
	CALL	print
	MOV		BL, "/"
	CALL	Oprint

	MOV		SI, 0x0A19
	CALL	print
	MOV		BL, "/"
	CALL	Oprint

	MOV		SI, 0x0A16
	CALL	print

	MOV		SI, MSG_CRLF
	CALL	print
	MOV		SI, MSG_CRLF
	CALL	print

	MOV		DI, 0x0A00
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
