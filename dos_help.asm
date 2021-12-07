
    OR      BYTE [_CMD_PRM0], 0x00
    JNZ     DCMD_HELP_detail

    MOV 	SI, DCMD_HELP_MSG1
	CALL	print

DCMD_HELP_detail_NotMatch:
	MOV		SI, MSG_CRLF
	CALL	print
	JMP 	ReturnAdrs

DCMD_HELP_MSG1:
	DB		"Active commands :", 0x0D, 0x0A
    DB      " reset    romb     help     lfchk    exit    ", 0x0D, 0x0A
    DB      " cls      mem      info", 0x0D, 0x0A, 0x00

DCMD_HELP_detail:

    MOV		BX, _CMD_PRM0
	MOV		SI, DCMD_RESET
	CALL	Compare
    OR      AL, AL
    JZ      DCMD_HELP_detail_RESET

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_HELP
    CALL    Compare
    OR      AL, AL
    JZ      DCMD_HELP_detail_HELP

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_ROMB
    CALL    Compare
    OR      AL, AL
    JZ      DCMD_HELP_detail_ROMB

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_LFCHK
    CALL    Compare
    OR      AL, AL
    JZ      DCMD_HELP_detail_LFCHK

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_EXIT
    CALL    Compare
    OR      AL, AL
    JZ      DCMD_HELP_detail_EXIT

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_CLS
    CALL    Compare
    OR      AL, AL
    JZ      DCMD_HELP_detail_CLS

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_MEM
    CALL    Compare
    OR      AL, AL
    JZ      DCMD_HELP_detail_MEM

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_INFO
    CALL    Compare
    OR      AL, AL
    JZ      DCMD_HELP_detail_INFO

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
    DB      "Print loaded floppy disk sector.", 0x0D, 0x0A, " > lfchk", 0x0D, 0x0A, 0x00

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

DCMD_HELP_detail_MEM:
    MOV     SI, DCMD_HELP_detail_MEM_MSG
    CALL    print
    
    JMP     DCMD_HELP_detail_NotMatch

DCMD_HELP_detail_MEM_MSG:
    DB      "Print installed memory size. (64KB)", 0x0D, 0x0A, " > mem", 0x0D, 0x0A, 0x00

DCMD_HELP_detail_INFO:
    MOV     SI, DCMD_HELP_detail_INFO_MSG
    CALL    print
    
    JMP     DCMD_HELP_detail_NotMatch

DCMD_HELP_detail_INFO_MSG:
    DB      "Print infomation data.", 0x0D, 0x0A, " > info <type>", 0x0D, 0x0A
    DB      " <type> parameter...", 0x0D, 0x0A
    DB      "        lfchk = Print loaded floppy disk sector.", 0x0D, 0x0A
    DB      "        mem   = Print installed memory size.", 0x0D, 0x0A, 0x00
