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
;	Oprint
;		Desc	: Print text with AL register.
;		Input	:
;					BL	= Print ASCII code.
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
;					AL	= Result
;						0x00 : Match
;						0x01 : Not Match
;
;================================================================
;
;	Hex2AsciiMW
;		Desc	: Convert hex to ascii code.
;		Input	:
;					BX	= Input hex adress
;					SI	= Output ascii code adress
;		Output	:
;					SI  = Ascii code adress
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
	PUSH	BX
	MOV 	AH, 0x0E
	XOR		BX, BX
	MOV		BL, 0x06

.print_loop:
	LODSB
	OR		AL, AL
	JZ		SHORT	.print_ret
	INT 	0x10
	JMP 	SHORT	.print_loop

.print_ret:
	POP 	BX
	POP		AX
	RET

Oprint:
	PUSH	AX
	MOV		AL, BL
	MOV		AH, 0x0E
	PUSH	BX
	XOR		BX, BX
	INT		0x10
	POP		BX
	POP		AX
	RET



;**************** Func: Compare
;_/_/ Input
;AX = Not Using
;BX = Compare Adrs
;CX = Not Using
;DX = Not Using
;SI = Compare Adrs
;_/_/ Output
;AL = Result ( 0x00 = Match, 0x01 = Not Match )

Compare:
	PUSH	DX

.Compare_Read:
	MOV 	DH, BYTE [BX]		; Load [BX] to DH, [SI] to DL
	MOV 	DL, BYTE [SI]
	INC 	BX					; Increment BX, SI
	INC		SI
	CMP 	DH, DL          ; If ( DH != DL )
	JNE 	SHORT	.Compare_Not
	OR		DH, DL
	JZ  	SHORT	.Compare_Fin
	JMP 	SHORT	.Compare_Read

.Compare_Not:
	MOV 	AL, 0x01
	POP 	DX
	RET

.Compare_Fin:
	XOR		AL, AL
	POP 	DX
	RET
	


;**************** Func: Hex2AsciiMW
;_/_/ Input
;BX = Input Hex Adress
;SI = Output Ascii Adress
;_/_/ Output
;[SI] = Output Ascii code

Hex2AsciiMW:
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
	POP		DX
	POP		CX
	POP		AX
	
	RET 




;**************** Func: Hex2AsciiMW
;_/_/ Input
;BX = Input Hex Adress
;SI = Output Ascii Adress
;_/_/ Output
;[SI] = Output Ascii code

Hex2AsciiMB:
	PUSH	AX
	PUSH	CX
	PUSH	DX
						; Set NULL code
	ADD		SI, 0x02	; SI + 2
	XOR		AX, AX		
	MOV		[SI], AX	; Memory [SI] = 0
	DEC		SI
	
.loop:
						; Load Higher 8bit Adress BX
	MOV		AL, [BX]	; AL = Adress BX
	AND		AL, 0xF0	; Mask Higher 8bit
	SHR		AL, 4		; Bit shift  L -> R (4bits)

						; Load Lower 8bit Adress BX
	MOV		DL, [BX]	; DL = Adress BX
	AND		DL, 0x0F	; Mask Lower 8bit

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
	
	JMP		SHORT	.fin
	
.alpAL:
	ADD		AL, 0x07			; The difference between '9' and 'A' is 0x07.
	JMP		SHORT	.alpALret
	
.alpDL:
	ADD		DL, 0x07			; The difference between '9' and 'A' is 0x07.
	JMP		SHORT	.alpDLret
	
.fin:
	POP		DX
	POP		CX
	POP		AX
	
	RET 


	
; BX = Command Name Adress
; SI = Command Struct Adress
; AL = Execute Command Flag ( 0x00 = not execute : 0x01 = excute )
;return
; AL = Status ( 0x00 = good : 0x01 = fail )

Command:
	PUSH	DI

	MOV		DI, SI	; Compare "Command Name" and "Command Struct -> Command Name"
	CALL	Compare
	OR		AL, AL
	JZ		.yes

	POP		DI

	RET

.yes:
	ADD		DI, 12	; Call Adress "Command Struct -> Command Process"
	JMP		FAR		DI

	POP		DI

	RET

; wait
; CX = waiting time ( micro sec, upper 16 bits )
; DX = waiting time ( micro sec, lower 16 bits )
; 

Waitf:

	PUSH	AX

	MOV		AH, 0x86
	INT		0x15

	POP		AX
	RET