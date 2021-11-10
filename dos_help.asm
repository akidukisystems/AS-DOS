    
    OR      BYTE [_CMD_PRM0], 0x00
    JNZ     DCMD_HELP_detail

    MOV 	SI, DCMD_HELP_MSG1
	CALL	print

DCMD_HELP_detail_NotMatch:
	MOV		SI, MSG_CRLF
	CALL	print
	JMP 	Key_Ret

DCMD_HELP_MSG1:
	DB		"Active commands :", 0x0D, 0x0A
	DB		" reset     romb     help     lfchk    exit     cls     ", 0x0D, 0x0A, 0x00

DCMD_HELP_detail:

    MOV		BX, _CMD_PRM0
	MOV		SI, DCMD_RESET
	CALL	Compare
    OR      AX, AX
    JZ      DCMD_HELP_detail_RESET

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_HELP
    CALL    Compare
    OR      AX, AX
    JZ      DCMD_HELP_detail_HELP

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_ROMB
    CALL    Compare
    OR      AX, AX
    JZ      DCMD_HELP_detail_ROMB

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_LFCHK
    CALL    Compare
    OR      AX, AX
    JZ      DCMD_HELP_detail_LFCHK

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_EXIT
    CALL    Compare
    OR      AX, AX
    JZ      DCMD_HELP_detail_EXIT

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_CLS
    CALL    Compare
    OR      AX, AX
    JZ      DCMD_HELP_detail_CLS

    JMP     DCMD_HELP_detail_NotMatch



DCMD_HELP_detail_RESET:
    MOV     SI, DCMD_HELP_detail_RESET_MSG
    CALL    print
    
    JMP     DCMD_HELP_detail_NotMatch

DCMD_HELP_detail_RESET_MSG:
    DB      "Reset and boot AS-DOS.", 0x0D, 0x0A, " > reset", 0x0D, 0x0A, 0x00

DCMD_HELP_detail_HELP:
    MOV     SI, DCMD_HELP_detail_HELP_MSG
    CALL    print
    
    JMP     DCMD_HELP_detail_NotMatch

DCMD_HELP_detail_HELP_MSG:
    DB      "Type command help.", 0x0D, 0x0A, " > help <command name>", 0x0D, 0x0A, 0x00

DCMD_HELP_detail_ROMB:
    MOV     SI, DCMD_HELP_detail_ROMB_MSG
    CALL    print
    
    JMP     DCMD_HELP_detail_NotMatch

DCMD_HELP_detail_ROMB_MSG:
    DB      "Change ROM-BASIC mode.", 0x0D, 0x0A, " > romb", 0x0D, 0x0A, 0x00

DCMD_HELP_detail_LFCHK:
    MOV     SI, DCMD_HELP_detail_LFCHK_MSG
    CALL    print
    
    JMP     DCMD_HELP_detail_NotMatch

DCMD_HELP_detail_LFCHK_MSG:
    DB      "Type loaded floppy disk sector.", 0x0D, 0x0A, " > lfchk", 0x0D, 0x0A, 0x00

DCMD_HELP_detail_EXIT:
    MOV     SI, DCMD_HELP_detail_EXIT_MSG
    CALL    print
    
    JMP     DCMD_HELP_detail_NotMatch

DCMD_HELP_detail_EXIT_MSG:
    DB      "Exit AS-DOS.", 0x0D, 0x0A, " > exit", 0x0D, 0x0A, 0x00

DCMD_HELP_detail_CLS:
    MOV     SI, DCMD_HELP_detail_CLS_MSG
    CALL    print
    
    JMP     DCMD_HELP_detail_NotMatch

DCMD_HELP_detail_CLS_MSG:
    DB      "Clear screen.", 0x0D, 0x0A, " > cls", 0x0D, 0x0A, 0x00
