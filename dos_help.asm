
    OR      BYTE [_CMD_PRM0], 0x00
    JNZ     DCMD_HELP_detail

    MOV 	SI, DCMD_HELP_MSG1
	CALL	print

	JMP 	ReturnAdrs

DCMD_HELP_MSG1:
	DB		"Active commands :", 0x0D, 0x0A
    DB      " reset    romb     help     exit    ", 0x0D, 0x0A
    DB      " cls      info     time     date", 0x0D, 0x0A, 0x0D, 0x0A, 0x00

DCMD_HELP_detail:

    MOV		BX, _CMD_PRM0
	MOV		SI, DCMD_RESET
	CALL	Compare
    OR      AL, AL
    JZ      DCMD_RESET + 12

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_HELP
    CALL    Compare
    OR      AL, AL
    JZ      DCMD_HELP + 12

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_ROMB
    CALL    Compare
    OR      AL, AL
    JZ      DCMD_ROMB + 12

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_EXIT
    CALL    Compare
    OR      AL, AL
    JZ      DCMD_EXIT + 12

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_CLS
    CALL    Compare
    OR      AL, AL
    JZ      DCMD_CLS + 12

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_INFO
    CALL    Compare
    OR      AL, AL
    JZ      DCMD_INFO + 12

    MOV     BX, _CMD_PRM0
    MOV     SI, DCMD_TIME
    CALL    Compare
    OR      AL, AL
    JZ      DCMD_TIME + 12

    JMP     ReturnAdrs