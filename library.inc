; library.inc
; Please include file footer.



;\_\_\_\_\_\_\_\_ Function List
;
;================================================================
;
;	print
;		Desc	: Print message with memory.
;		Input	: 
;					SI	= Message Adress
;		Output	: 
;					None
;
;================================================================
;
;	Compare
;		Desc	: Compare string with memory.
;		Input	:
;					BX	= Compare String Adress
;					SI	= Compare String Adress
;		Output	:
;					AX	= Result
;						0x00 : Match
;						0x01 : Not Match
;
;================================================================
;
;	Hex2Ascii
;		Desc	: Convert hex to ascii code.
;		Input	:
;					BX	= Input hex adress
;					SI	= Output ascii code adress
;		Output	:
;					SI = Ascii code adress
;
;================================================================



;*************** Func: print
;\_\_ Input
;AX = Not Using
;BX = Not Using
;CX = Not Using
;DX = Not Using
;SI = String Adress

print:
	PUSH	AX
	MOV 	AH, 0x0E

.print_loop:
	LODSB
	OR		AL, AL
	JZ		SHORT	.print_ret
	INT 	0x10
	JMP 	SHORT	.print_loop

.print_ret:
	POP 	AX
	RET



;**************** Func: Compare
;\_\_ Input
;AX = Not Using
;BX = Compare Adrs
;CX = Not Using
;DX = Not Using
;SI = Compare Adrs
;\_\_ Output
;AX = Result ( 0x00 = Match, 0x01 = Not Match )

Compare:
	PUSH	DX

.Compare_Read:
	MOV 	DH, [BX]
	MOV 	DL, [SI]
	INC 	BX
	INC		SI
	CMP 	DH, DL          ; If ( DH != DL )
	JNE 	SHORT	.Compare_Not
	OR		DH, DL
	JZ  	SHORT	.Compare_Fin
	JMP 	SHORT	.Compare_Read

.Compare_Not:
	MOV 	AX, 0x01
	POP 	DX
	RET

.Compare_Fin:
	XOR		AX, AX
	POP 	DX
	RET
	


;**************** Func: Hex2Ascii
;\_\_ Input
;BX = Input Hex Adress
;SI = Output Ascii Adress
;\_\_ Output
;[SI] = Output Ascii code

Hex2Ascii:
	PUSH	AX
	PUSH	CX
	PUSH	DX
	ADD		SI, 0x04
	XOR		AX, AX
	MOV		[SI], AX
	DEC		SI
	
.loop:
	MOV		AL, [BX]
	AND		AL, 0xF0
	SHR		AL, 4		; Bit shift  L -> R (4bits)
	MOV		DL, [BX]
	AND		DL, 0x0F
	INC		BX
	INC		CX
	CMP		CX, 0x02	; If ( CX > 0x02 )
	JA		SHORT	.fin
	ADD		AL, 0x30
	CMP		AL, 0x3A	; If ( AL >= 0x3A )
	JAE		SHORT	.alpAL
.alpALret:
	ADD		DL, 0x30
	CMP		DL, 0x3A	; If ( DL >= 0x3A )
	JAE		SHORT	.alpDL
.alpDLret:
	MOV		[SI], DL
	DEC		SI
	MOV		[SI], AL
	DEC		SI
	
	JMP		SHORT	.loop
	
.alpAL:
	ADD		AL, 0x07
	JMP		SHORT	.alpALret
	
.alpDL:
	ADD		DL, 0x07
	JMP		SHORT	.alpDLret
	
.fin:
	POP		AX
	POP		CX
	POP		DX
	
	RET