; library.inc
; Please include file footer.



;_/_/_/_/_/_/_/_/ Function List
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
;_/_/ Input
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
;_/_/ Input
;AX = Not Using
;BX = Compare Adrs
;CX = Not Using
;DX = Not Using
;SI = Compare Adrs
;_/_/ Output
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
;_/_/ Input
;BX = Input Hex Adress
;SI = Output Ascii Adress
;_/_/ Output
;[SI] = Output Ascii code

Hex2Ascii:
	PUSH	AX
	PUSH	CX
	PUSH	DX
						; Set NULL code
	ADD		SI, 0x04	; SI + 4
	XOR		AX, AX		
	MOV		[SI], AX	; Adress SI = 0
	DEC		SI
	
.loop:
						; Load Higher 8bit Adress BX
	MOV		AL, [BX]	; AL = Adress BX
	AND		AL, 0xF0	; Mask Higher 8bit
	SHR		AL, 4		; Bit shift  L -> R (4bits)

						; Load Lower 8bit Adress BX
	MOV		DL, [BX]	; DL = Adress BX
	AND		DL, 0x0F	; Mask Lower 8bit
	INC		BX
	INC		CX
						; If converted 16bit binary value, go to fin: .
	CMP		CX, 0x02
	JA		SHORT	.fin	; if ( CX > 0x02 )

	ADD		AL, 0x30	; AL += 0x30 ( binary value 0x01 -> ASCII value 0x31 '1' )
	CMP		AL, 0x3A	; 0x09 + 0x30 = 0x39 '9', 0x0A + 0x30 = 0x3A. 0x3A is not 'A'. 'A' is 0x41.
	JAE		SHORT	.alpAL	; if ( CX >= 0x3A )
.alpALret:
	ADD		DL, 0x30	; next process. ( register DL )
	CMP		DL, 0x3A
	JAE		SHORT	.alpDL	; if ( CX >= 0x3A )
.alpDLret:
						; Write result for memory.
	MOV		[SI], DL
	DEC		SI
	MOV		[SI], AL
	DEC		SI
	
	JMP		SHORT	.loop
	
.alpAL:
	ADD		AL, 0x07			; The difference between '9' and 'A' is 0x07.
	JMP		SHORT	.alpALret
	
.alpDL:
	ADD		DL, 0x07			; The difference between '9' and 'A' is 0x07.
	JMP		SHORT	.alpDLret
	
.fin:
	POP		AX
	POP		CX
	POP		DX
	
	RET 
	