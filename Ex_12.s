            TTL Program Title for Listing Header Goes Here
;****************************************************************
;Descriptive comment header goes here.
;A game of scrable where the user tries to unscramble
;letters to make the correct word.
;Name:  Camille Lea
;Date:  <>
;Class:  CMPE-250
;Section:  <L1, Tuesday, 11am>
;---------------------------------------------------------------
;Keil Template for KL05
;R. W. Melton
;September 13, 2020
;****************************************************************
;Assembler directives
            THUMB
            OPT    64  ;Turn on listing macro expansions
;****************************************************************
;Include files
            GET  MKL05Z4.s     ;Included by start.s
            OPT  1   			;Turn on listing
;****************************************************************
;EQUates
CR          EQU  0x0D
LF          EQU  0x0A
NULL        EQU  0x00
n			EQU  6				;amount of items that I want in my array
ACCUM       EQU  1	
	
MAX_EAS		EQU  6				;maximum number of characters entered (+1 for null termination)	
MAX_MED		EQU	 7
MAX_HAR     EQU	 10	
MAX_STRING	EQU  200	
	
Y_ascii		EQU	 0x59
N_ascii		EQU  0x4e
	
D_ascii     EQU	 0x44
E_ascii     EQU  0x45
H_ascii     EQU  0x48
P_ascii     EQU	 0x50
T_ascii     EQU	 0x54
	
Rx_Q_REC    EQU  18
Tx_Q_REC    EQU  18
	
Tx_Q_BUF    EQU  80
Rx_Q_BUF	EQU  80

Q_BUF_SZ    EQU   4   ;Queue contents
Q_REC_SZ    EQU   18  ;Queue management record
	
IN_PTR      EQU   0
OUT_PTR     EQU   4
BUF_STRT    EQU   8
BUF_PAST    EQU   12
BUF_SIZE    EQU   16
NUM_ENQD    EQU   17
	
;---------------------------------------------------------------
;NVIC_ICER
;31-00:CLRENA=masks for HW IRQ sources;
;             read:   0 = unmasked;   1 = masked
;             write:  0 = no effect;  1 = mask
;22:PIT IRQ mask
;12:UART0 IRQ mask
NVIC_ICER_PIT_MASK    EQU  PIT_IRQ_MASK
NVIC_ICER_UART0_MASK  EQU  UART0_IRQ_MASK
;---------------------------------------------------------------
;NVIC_ICPR
;31-00:CLRPEND=pending status for HW IRQ sources;
;             read:   0 = not pending;  1 = pending
;             write:  0 = no effect;
;                     1 = change status to not pending
;22:PIT IRQ pending status
;12:UART0 IRQ pending status
NVIC_ICPR_PIT_MASK    EQU  PIT_IRQ_MASK
NVIC_ICPR_UART0_MASK  EQU  UART0_IRQ_MASK
;---------------------------------------------------------------
;NVIC_IPR0-NVIC_IPR7
;2-bit priority:  00 = highest; 11 = lowest
;--PIT--------------------
PIT_IRQ_PRIORITY    EQU  0
NVIC_IPR_PIT_MASK   EQU  (3 << PIT_PRI_POS)
NVIC_IPR_PIT_PRI_0  EQU  (PIT_IRQ_PRIORITY << PIT_PRI_POS)
;--UART0--------------------
UART0_IRQ_PRIORITY    EQU  3
NVIC_IPR_UART0_MASK   EQU (3 << UART0_PRI_POS)
NVIC_IPR_UART0_PRI_3  EQU (UART0_IRQ_PRIORITY << UART0_PRI_POS)
;---------------------------------------------------------------
;NVIC_ISER
;31-00:SETENA=masks for HW IRQ sources;
;             read:   0 = masked;     1 = unmasked
;             write:  0 = no effect;  1 = unmask
;22:PIT IRQ mask
;12:UART0 IRQ mask
NVIC_ISER_PIT_MASK    EQU  PIT_IRQ_MASK
NVIC_ISER_UART0_MASK  EQU  UART0_IRQ_MASK
;---------------------------------------------------------------
;PIT_LDVALn:  PIT load value register n
;31-00:TSV=timer start value (period in clock cycles - 1)
;Clock ticks for 0.01 s at ~24 MHz count rate
;0.01 s * ~24,000,000 Hz = ~240,000
;TSV = ~240,000 - 1
;Clock ticks for 0.01 s at 23,986,176 Hz count rate
;0.01 s * 23,986,176 Hz = 239,862
;TSV = 239,862 - 1
PIT_LDVAL_10ms  EQU  239861
;---------------------------------------------------------------
;PIT_MCR:  PIT module control register
;1-->    0:FRZ=freeze (continue'/stop in debug mode)
;0-->    1:MDIS=module disable (PIT section)
;               RTI timer not affected
;               must be enabled before any other PIT setup
PIT_MCR_EN_FRZ  EQU  PIT_MCR_FRZ_MASK
;---------------------------------------------------------------
;PIT_TCTRL:  timer control register
;0-->   2:CHN=chain mode (enable)
;1-->   1:TIE=timer interrupt enable
;1-->   0:TEN=timer enable
PIT_TCTRL_CH_IE  EQU  (PIT_TCTRL_TEN_MASK :OR: PIT_TCTRL_TIE_MASK)
;---------------------------------------------------------------
;PORTx_PCRn (Port x pin control register n [for pin n])
;___->10-08:Pin mux control (select 0 to 8)
;Use provided PORT_PCR_MUX_SELECT_2_MASK
;---------------------------------------------------------------
;Port B
PORT_PCR_SET_PTB2_UART0_RX  EQU  (PORT_PCR_ISF_MASK :OR: \
                                  PORT_PCR_MUX_SELECT_2_MASK)
PORT_PCR_SET_PTB1_UART0_TX  EQU  (PORT_PCR_ISF_MASK :OR: \
                                  PORT_PCR_MUX_SELECT_2_MASK)
;---------------------------------------------------------------
;SIM_SCGC4
;1->10:UART0 clock gate control (enabled)
;Use provided SIM_SCGC4_UART0_MASK
;---------------------------------------------------------------
;SIM_SCGC5
;1->09:Port A clock gate control (enabled)
;Use provided SIM_SCGC5_PORTA_MASK
;---------------------------------------------------------------
;SIM_SCGC6
;1->23:PIT clock gate control (enabled)
;Use provided SIM_SCGC6_PIT_MASK
;---------------------------------------------------------------
;SIM_SOPT2
;01=27-26:UART0SRC=UART0 clock source select (MCGFLLCLK)
;---------------------------------------------------------------
SIM_SOPT2_UART0SRC_MCGFLLCLK  EQU  \
                                 (1 << SIM_SOPT2_UART0SRC_SHIFT)
;---------------------------------------------------------------
;SIM_SOPT5
; 0->   16:UART0 open drain enable (disabled)
; 0->   02:UART0 receive data select (UART0_RX)
;00->01-00:UART0 transmit data select source (UART0_TX)
SIM_SOPT5_UART0_EXTERN_MASK_CLEAR  EQU  \
                               (SIM_SOPT5_UART0ODE_MASK :OR: \
                                SIM_SOPT5_UART0RXSRC_MASK :OR: \
                                SIM_SOPT5_UART0TXSRC_MASK)
;---------------------------------------------------------------
;UART0_BDH
;    0->  7:LIN break detect IE (disabled)
;    0->  6:RxD input active edge IE (disabled)
;    0->  5:Stop bit number select (1)
;00001->4-0:SBR[12:0] (UART0CLK / [9600 * (OSR + 1)]) 
;UART0CLK is MCGPLLCLK/2
;MCGPLLCLK is 96 MHz
;MCGPLLCLK/2 is 48 MHz
;SBR = 48 MHz / (9600 * 16) = 312.5 --> 312 = 0x138
UART0_BDH_9600  EQU  0x01
;---------------------------------------------------------------
;UART0_BDL
;26->7-0:SBR[7:0] (UART0CLK / [9600 * (OSR + 1)])
;UART0CLK is MCGPLLCLK/2
;MCGPLLCLK is 96 MHz
;MCGPLLCLK/2 is 48 MHz
;SBR = 48 MHz / (9600 * 16) = 312.5 --> 312 = 0x138
UART0_BDL_9600  EQU  0x38
;---------------------------------------------------------------
;UART0_C1
;0-->7:LOOPS=loops select (normal)
;0-->6:DOZEEN=doze enable (disabled)
;0-->5:RSRC=receiver source select (internal--no effect LOOPS=0)
;0-->4:M=9- or 8-bit mode select 
;        (1 start, 8 data [lsb first], 1 stop)
;0-->3:WAKE=receiver wakeup method select (idle)
;0-->2:IDLE=idle line type select (idle begins after start bit)
;0-->1:PE=parity enable (disabled)
;0-->0:PT=parity type (even parity--no effect PE=0)
UART0_C1_8N1  EQU  0x00
;---------------------------------------------------------------
;UART0_C2
;0-->7:TIE=transmit IE for TDRE (disabled)
;0-->6:TCIE=transmission complete IE for TC (disabled)
;0-->5:RIE=receiver IE for RDRF (disabled)
;0-->4:ILIE=idle line IE for IDLE (disabled)
;1-->3:TE=transmitter enable (enabled)
;1-->2:RE=receiver enable (enabled)
;0-->1:RWU=receiver wakeup control (normal)
;0-->0:SBK=send break (disabled, normal)
UART0_C2_T_R    EQU  (UART0_C2_TE_MASK :OR: UART0_C2_RE_MASK)
UART0_C2_T_RI   EQU  (UART0_C2_RIE_MASK :OR: UART0_C2_T_R)
UART0_C2_TI_RI  EQU  (UART0_C2_TIE_MASK :OR: UART0_C2_T_RI)
;---------------------------------------------------------------
;UART0_C3
;0-->7:R8T9=9th data bit for receiver (not used M=0)
;           10th data bit for transmitter (not used M10=0)
;0-->6:R9T8=9th data bit for transmitter (not used M=0)
;           10th data bit for receiver (not used M10=0)
;0-->5:TXDIR=UART_TX pin direction in single-wire mode
;            (no effect LOOPS=0)
;0-->4:TXINV=transmit data inversion (not inverted)
;0-->3:ORIE=overrun IE for OR (disabled)
;0-->2:NEIE=noise error IE for NF (disabled)
;0-->1:FEIE=framing error IE for FE (disabled)
;0-->0:PEIE=parity error IE for PF (disabled)
UART0_C3_NO_TXINV  EQU  0x00
;---------------------------------------------------------------
;UART0_C4
;    0-->  7:MAEN1=match address mode enable 1 (disabled)
;    0-->  6:MAEN2=match address mode enable 2 (disabled)
;    0-->  5:M10=10-bit mode select (not selected)
;01111-->4-0:OSR=over sampling ratio (16)
;               = 1 + OSR for 3 <= OSR <= 31
;               = 16 for 0 <= OSR <= 2 (invalid values)
UART0_C4_OSR_16           EQU  0x0F
UART0_C4_NO_MATCH_OSR_16  EQU  UART0_C4_OSR_16
;---------------------------------------------------------------
;UART0_C5
;  0-->  7:TDMAE=transmitter DMA enable (disabled)
;  0-->  6:Reserved; read-only; always 0
;  0-->  5:RDMAE=receiver full DMA enable (disabled)
;000-->4-2:Reserved; read-only; always 0
;  0-->  1:BOTHEDGE=both edge sampling (rising edge only)
;  0-->  0:RESYNCDIS=resynchronization disable (enabled)
UART0_C5_NO_DMA_SSR_SYNC  EQU  0x00
;---------------------------------------------------------------
;UART0_S1
;0-->7:TDRE=transmit data register empty flag; read-only
;0-->6:TC=transmission complete flag; read-only
;0-->5:RDRF=receive data register full flag; read-only
;1-->4:IDLE=idle line flag; write 1 to clear (clear)
;1-->3:OR=receiver overrun flag; write 1 to clear (clear)
;1-->2:NF=noise flag; write 1 to clear (clear)
;1-->1:FE=framing error flag; write 1 to clear (clear)
;1-->0:PF=parity error flag; write 1 to clear (clear)
UART0_S1_CLEAR_FLAGS  EQU  (UART0_S1_IDLE_MASK :OR: \
                            UART0_S1_OR_MASK :OR: \
                            UART0_S1_NF_MASK :OR: \
                            UART0_S1_FE_MASK :OR: \
                            UART0_S1_PF_MASK)
;---------------------------------------------------------------
;UART0_S2
;1-->7:LBKDIF=LIN break detect interrupt flag (clear)
;             write 1 to clear
;1-->6:RXEDGIF=RxD pin active edge interrupt flag (clear)
;              write 1 to clear
;0-->5:(reserved); read-only; always 0
;0-->4:RXINV=receive data inversion (disabled)
;0-->3:RWUID=receive wake-up idle detect
;0-->2:BRK13=break character generation length (10)
;0-->1:LBKDE=LIN break detect enable (disabled)
;0-->0:RAF=receiver active flag; read-only
UART0_S2_NO_RXINV_BRK10_NO_LBKDETECT_CLEAR_FLAGS  EQU  \
        (UART0_S2_LBKDIF_MASK :OR: UART0_S2_RXEDGIF_MASK)
;---------------------------------------------------------------
POS_RED EQU 8
POS_GREEN EQU 9
POS_BLUE EQU 10
PORTB_LED_RED_MASK EQU (1 << POS_RED)
PORTB_LED_GREEN_MASK EQU (1 << POS_GREEN)
PORTB_LED_BLUE_MASK EQU (1 << POS_BLUE)
	
PORTB_LEDS_MASK EQU (PORTB_LED_RED_MASK :OR: \
					 PORTB_LED_GREEN_MASK :OR: \
					 PORTB_LED_BLUE_MASK)

;Port B Pin 8: Red LED
PORT_PCR_SET_PTB8_GPIO EQU (PORT_PCR_ISF_MASK :OR: \
							PORT_PCR_MUX_SELECT_1_MASK)
;Port B Pin 9: Green LED
PORT_PCR_SET_PTB9_GPIO EQU (PORT_PCR_ISF_MASK :OR: \
							PORT_PCR_MUX_SELECT_1_MASK)
;Port B Pin 10: Blue LED
PORT_PCR_SET_PTB10_GPIO EQU (PORT_PCR_ISF_MASK :OR: \
							 PORT_PCR_MUX_SELECT_1_MASK)

;---------------------------------------------------------------
				MACRO
				MOVC	$Value
;---------------------------------------------------------------
;Puts $Value in C bit of PSR
				PUSH	{R0}
				MOVS	R0,$Value
				LSRS	R0,R0,#1
				POP		{R0}
;---------------------------------------------------------------
				MEND
;****************************************************************
;Program
;Linker requires Reset_Handler
            AREA    MyCode,CODE,READONLY
            ENTRY
            EXPORT  Reset_Handler
            IMPORT  Startup
				
			;Lab Exercise 7 main queue test command loop
            IMPORT  QTest
;Lab Exercise 7 subroutines
            IMPORT  Dequeue
            IMPORT  Enqueue
            IMPORT  InitQueue
            IMPORT  PutNumHex
            IMPORT  PutNumUB
;Lab Exercise 6 subroutines
            ;IMPORT  GetStringSB
            IMPORT  PutNumU
            ;IMPORT  PutStringSB
;Lab Exercise 5 subroutines
            ;IMPORT  GetChar
            IMPORT  Init_UART0_Polling
            IMPORT  PutChar
			IMPORT  GetChar
;Lab Exercise 4 subroutine
            IMPORT  DIVU	
				
Reset_Handler  PROC  {}
main
;---------------------------------------------------------------
;Mask interrupts
            CPSID   I
;KL05 system startup with 48-MHz system clock
            BL      Startup
;---------------------------------------------------------------
;>>>>> begin main program code <<<<<
			
			BL   Init_UART0_Polling				;intialize polling
			
			BL	Init_UART0_IRQ
			BL  Init_PIT_IRQ
			
			CPSIE I
			
			LDR  R0, =Normal_Array				;Normal Array in R0
			LDR  R1, =Scramble_Array			;Scramble Array in R1
			BL   Init_Array
			BL   Init_LED
			BL   All_Off
			
			MOVS R1,#MAX_STRING
			LDR  R0,=welcome_prompt				;printing a ton of promtps
			BL   PutStringSB
			
			BL   Line_enter
			
			LDR  R0,=directions_prompt_p1
			BL	 PutStringSB
			
			BL	 Line_enter
			
			LDR  R0,=directions_prompt_p2
			BL   PutStringSB
			
			BL   Line_enter
			
			LDR  R0,=directions_prompt_p3
			BL   PutStringSB
			
			BL   Line_enter
			
			LDR  R0,=good_luck
			BL   PutStringSB
			
			BL   Line_enter
			
			LDR  R0, =dashed_lines
			BL   PutStringSB
			
Loop		BL   Line_enter
			
			LDR  R0, =Start_question			;gives options of Y, N, or H
			BL   PutStringSB
			
			BL   GetChar				;gets the character of the user
			BL   PutChar	
			
			BL   Line_enter
						
;check values input

;Possible Values:
;D = Directions
;H = Help		

;E = End
;P = Play (goes back to beginning)

;Checks for lowercase
		
			CMP	R0, #'a'
			BHS check_z
			B   is_Lower
			
check_z     CMP R0, #'z'
			BLS convert_Upper
			B   is_Lower
			
convert_Upper

			SUBS R0, R0, #32		;converts the lowercase value to uppercase
			
is_Lower	

;Check for Y or H

check_help	CMP R0, #H_ascii
			BEQ ask_help
			B	check_yes
	
check_yes	CMP R0, #Y_ascii
			BEQ ask_play
			B   invalid
			
			
ask_play    LDR  R1,=Scramble_Array
			LDR  R2,=Normal_Array
			
			LDR  R6,=GAME_BUFFER
			MOVS R5, #0
			STR	 R5,[R6,#0]
			
			LDR  R7,=GAMES_PASSED
			STR  R5,[R7,#0]
			
			BL All_Off
			
			LDR R0,=StopWatch		;make sure stopwatch is off
			MOVS R1, #0
			STR R1, [R0, #0]
			
			LDR R3, =Count
			STR R1, [R3, #0]		;make sure count is zero
			
			MOVS R3, #1				
			STR R3, [R0, #0]		;start the stopwatch
			
		    BL Play_Game
			
			MOVS R1, #0				;stop the stopwatch
            LDR R0, =StopWatch
			STR R1, [R0, #0]
			
			BL Blue_On
			
			LDR  R0,=end_game
			BL   PutStringSB
			
			BL   Line_enter
			LDR  R0,=time
			BL   PutStringSB
			
			LDR R0, =Count
			LDR R0, [R0,#0]
			BL  PutNumU
			
			LDR R0,=seconds
			BL  PutStringSB	

			B  Loop
			
ask_help	LDR  R0,=help_prompt
			BL   PutStringSB
			BL   GetChar
			BL   PutChar
			
			CMP	R0, #'a'
			BHS check_other
			B   lower
			
check_other CMP R0, #'z'
			BLS upper
			B   lower
			
upper

			SUBS R0, R0, #32		;converts the lowercase value to uppercase
			
lower
			
			BL   Line_enter

;Check for help characters

check_D		CMP R0, #D_ascii
			BNE	check_H
			
			LDR  R0,=directions_prompt_p1
			BL	 PutStringSB
			
			BL	 Line_enter
			
			LDR  R0,=directions_prompt_p2
			BL   PutStringSB
			
			BL   Line_enter
			
			LDR  R0,=directions_prompt_p3
			BL   PutStringSB
			
			BL   Line_enter
			B    Loop
				
check_H		CMP  R0, #H_ascii
			BNE  check_E
			
			LDR  R0,=help_prompt
			BL   PutStringSB
			
			BL   Line_enter
			B	 Loop
			
check_E		CMP  R0, #E_ascii
			BNE  check_P
			
			LDR  R0, =goodbye
			BL   PutStringSB
			
			B    end_of_program
			
check_P		CMP  R0, #P_ascii
			BNE  invalid
			
			;goes back to the beginning
			B    Loop 
			
invalid
			LDR  R0, =invalid_character
			BL	 PutStringSB
			
			B    Loop



;after checking each value, the user will be taken to where
;they wanted to go

;Playing the game: There will be a time limit for the user
;to properly guess the regular word. 
;If the the time runs out, the user loses the game and the LED
;will turn red and they will be shown the losing screen"
			
			
			
;>>>>>   end main program code <<<<<
;Stay here
end_of_program
            B       .
			LTORG
            ENDP
;>>>>> begin subroutine code <<<<<

Init_Array 	PROC	{R2-R14}
;Initializes two arrays, the Normal and Scramble Arrays. 
;Inputs: 
; 		R0 = Normal Array Address
;       R1 = Scramble Array Address
;Outputs: None

			PUSH{R0-R3,LR}
			MOVS R3, #0			;initialize counter
								;is moved manually
			
			LDR R2,=hello_normal
			STR R2, [R0, R3]	;store the normal word into the normal array
			LDR R2,=hello_scramble
			STR R2, [R1, R3]	;store the scramble word into the scramble array
			ADDS R3, R3, #4		;increment the counter
			
			LDR R2,=tiger_normal
			STR R2, [R0, R3]
			LDR R2,=tiger_scramble
			STR R2, [R1, R3]
			ADDS R3, R3, #4		;increment
			
			;Start of medium mode
			;Coutner, R3 = 2
			
			LDR R2,=matcha_normal
			STR R2, [R0, R3]
			LDR R2,=matcha_scramble
			STR R2, [R1, R3]
			ADDS R3, R3, #4		;increment
			
			LDR R2,=french_normal
			STR R2, [R0, R3]
			LDR R2,=french_scramble
			STR R2, [R1, R3]
			ADDS R3, R3, #4		;increment
			
			;Start of hard mode
			;Counter, R3 = 4
			
			LDR R2,=accessory_normal
			STR R2, [R0, R3]  
			LDR R2,=accessory_scramble
			STR R2, [R1, R3]
			ADDS R3, R3, #4		;increment
			
			LDR R2,=pistachio_normal
			STR R2, [R0, R3]
			LDR R2,=pistachio_scramble
			STR R2, [R1, R3]
			
			POP{R0-R3, PC}
			ENDP
			LTORG
			
Init_LED	PROC	{R2-R14}
;Enable clock for PORT B module and configure the pin connections
			PUSH{R1-R3,LR}
			
			;Enable PORT B
			LDR	R1,=SIM_SCGC5
			LDR R2,=(SIM_SCGC5_PORTB_MASK)
			LDR	R3,[R1,#0]
			ORRS R3,R3,R2
			STR R3,[R1,#0]
			
			;Configure pin connections
			
			LDR R1,=PORTB_BASE
			;Select PORT B Pin 8 for GPIO to red LED
			LDR R2,=PORT_PCR_SET_PTB8_GPIO
			STR R2,[R1,#PORTB_PCR8_OFFSET]
			;Select PORT B Pin 9 for GPIO to green LED
			LDR R2,=PORT_PCR_SET_PTB9_GPIO
			STR R2,[R1,#PORTB_PCR9_OFFSET]
			;Select PORT B Pin 10 for GPIO to blue LED
			LDR R2,=PORT_PCR_SET_PTB10_GPIO
			STR R2,[R1,#PORTB_PCR10_OFFSET]
			
			LDR R1,=FGPIOB_BASE
			LDR R2,=PORTB_LEDS_MASK
			STR R2,[R1,#GPIO_PDDR_OFFSET]
			
			POP{R1-R3,PC}
			ENDP
		
All_Off		PROC	{R2-R14}
;Turn all the LEDs OFF
			PUSH{R1-R3,LR}
			
			LDR R1,=FGPIOB_BASE
			;Turn off red LED
			LDR R2,=PORTB_LED_RED_MASK
			STR	R2,[R1,#GPIO_PSOR_OFFSET]
			;Turn off green LED
			LDR R2,=PORTB_LED_GREEN_MASK
			STR R2,[R1,#GPIO_PSOR_OFFSET]
			;Turn off blue LED
			LDR R2,=PORTB_LED_BLUE_MASK
			STR R2,[R1,#GPIO_PSOR_OFFSET]
			
			POP{R1-R3,PC}
			ENDP
				
Red_On		PROC	{R2-R14}
;Turn only the RED LED on
			PUSH{R1-R3,LR}
			
			LDR R1,=FGPIOB_BASE
			
			LDR  R2,=PORTB_LED_RED_MASK
			STR  R2,[R1,#GPIO_PCOR_OFFSET]
			
			POP{R1-R3,PC}
			ENDP
				
Green_On	PROC	{R2-R14}
;Turn only the GREEN LED on		
			PUSH{R1-R3,LR}
			
			LDR R1,=FGPIOB_BASE
			
			LDR  R2,=PORTB_LED_GREEN_MASK
			STR  R2,[R1,#GPIO_PCOR_OFFSET]
			
			POP{R1-R3,PC}
			ENDP
				
Blue_On	PROC	{R2-R14}
;Turn only the GREEN LED on		
			PUSH{R1-R3,LR}
			
			LDR R1,=FGPIOB_BASE
			
			LDR  R2,=PORTB_LED_BLUE_MASK
			STR  R2,[R1,#GPIO_PCOR_OFFSET]
			
			POP{R1-R3,PC}
			ENDP
				
Toggle_Green PROC	{R2-R14}
;Toggle the Green LED
			PUSH{R1-R3,LR}
			
			LDR R1,=FGPIOB_BASE
			
			LDR R2,=PORTB_LED_GREEN_MASK
			STR R2,[R1,#GPIO_PTOR_OFFSET]
			
			POP{R1-R3,PC}
			ENDP
				
Toggle_Red	PROC	{R2-R14}
;Toggle the RED LED	
			PUSH{R1-R3,LR}
			
			LDR R1,=FGPIOB_BASE
			
			LDR R2,=PORTB_LED_RED_MASK
			STR R2,[R1,#GPIO_PTOR_OFFSET]
			
			POP{R1-R3,PC}
			ENDP
				
	LTORG			
Play_Game	PROC 	{R2-R14}
;Gets the scrambled word first depending on the GAME_BUFFER
;Displays messages telling the user what mode they're on (hard,medium,easy)
;Keeps the score
;Has the timer and the LED functionality
;Inputs:
;		R1 = Scamble Array
;		R2 = Normal Array

			
			PUSH{R0-R7,LR}

;beginning of Round 1, Easy loop
			
			LDR R0,=round_one			;loads round 1 prompt
			BL  PutStringSB				;prints round 1 prompt
			
			BL   Line_enter				;enter
			
			LDR R7,=GAME_BUFFER			;loads the address of GAME_BUFFER
			LDR R7,[R7, #0]				;loads the contents of GAME_BUFFER into R7
			
			LDR R3,=GAMES_PASSED		;loads the address of the GAMES_PASSED
			LDR R3,[R3,#0]				;loads the contents of the GAMES_PASSED into R3
			
top_loop	CMP  R3, #2					;checks the number of games passed
			BEQ  round2					;goes to another loop for round 2
			
			LDR  R1,=Scramble_Array		;reloads the adddresses because they get changed for GetString
			LDR  R2,=Normal_Array
			
			BL   Line_enter				;enter
			
try_again	
			
			LDR  R1,=Scramble_Array		;reloads the adddresses because they get changed for GetString
			LDR  R2,=Normal_Array
				
			BL   Line_enter			

			MOVS R0,#'>'				;helps denote what the actual word is
			BL  PutChar
			
			LDR R4,[R1, R7]				;gets the word at the offset of the game buffer from the scramble array
			MOVS R0, R4					;makes a copy of the scrambled word
			BL   PutStringSB			;prints the string to the terminal
			
			BL   Line_enter
			
			MOVS R1, #MAX_EAS			;length of all easy words
			LDR  R2,=STRING
			BL   GetStringSB

			BL Comparator				;compare the two strings
			BCS wrong_answer
			
			;BL  Red_On
			
			LDR R1,=FGPIOB_BASE
			LDR R1,[R1,#GPIO_PDOR_OFFSET]
			LDR R2,=PORTB_LEDS_MASK
			LDR R5,=PORTB_LED_RED_MASK
			ANDS R1, R1, R5					;R1 is only red led
			CMP	R1,#0						;if the LED is on (0) then branch and toggle
			BNE green_only
			
			BL  Toggle_Red
			
green_only	BL  Green_On
			BL	Line_enter
			LDR R0, =correct			;prints correct to the terminal
			MOVS R1, #MAX_STRING
			BL  PutStringSB			
			
			ADDS R3, R3, #1				;increment the number of games passed
			LDR  R6,=GAMES_PASSED
			STR  R3,[R6,#0]
			
			ADDS R7, R7, #4				;increment the game buffer to get another scramble word
			LDR  R5,=GAME_BUFFER
			STR  R7,[R5,#0]
			
			B	top_loop				;branches to the top of the loop
			
wrong_answer
			LDR R1,=FGPIOB_BASE
			LDR R1,[R1,#GPIO_PDOR_OFFSET]
			LDR R2,=PORTB_LEDS_MASK
			LDR R5,=PORTB_LED_GREEN_MASK
			ANDS R1, R1, R5					;R1 is only red led
			CMP	R1,#0						;if the LED is on (0) then branch and toggle
			BNE red_only
			
			BL  Toggle_Green
			
red_only	BL  Red_On
			
			BL  Line_enter
			LDR R0,=incorrect			;prints incorrect to the terminal
			BL  PutStringSB				
			
			B	try_again				;branches to the top but skips round 1 prompt

;--------------------------------------------------------------------------------------------------
;Beginning of Round 2, Medium loops		
		
round2		BL  Line_enter

			LDR R0,=round_two
			BL  PutStringSB
			
			LDR R3,=GAMES_PASSED
			LDR R3,[R3,#0]
			
mid_loop	;MOVS R3, #GAME_BUFFER		;load the game buffer
			CMP  R3, #4					;checks the number of games passed
			BEQ	 round3					;goes to round 3
			
			LDR  R1,=Scramble_Array		;reloads the adddresses because they get changed for GetString
			LDR  R2,=Normal_Array
			
			BL   Line_enter				;enter

try_medium	LDR  R1,=Scramble_Array		;reloads the adddresses because they get changed for GetString
			LDR  R2,=Normal_Array
				
			BL   Line_enter	

			MOVS R0,#'>'				;helps denote what the actual word is
			BL  PutChar
			
			LDR R4, [R1, R7]			;gets the word at the offset of the game buffer from the scramble array
			MOVS R0, R4					;makes a copy of the scrambled word
			BL   PutStringSB			;prints the string to the terminal
			
			BL   Line_enter
			
			MOVS R4, #MAX_MED			;length of all easy words
			LDR  R2,=STRING
			BL   GetStringSB

			BL   Comparator
			BCS  wrong_medium
			
			LDR R1,=FGPIOB_BASE
			LDR R1,[R1,#GPIO_PDOR_OFFSET]
			LDR R2,=PORTB_LEDS_MASK
			LDR R5,=PORTB_LED_RED_MASK
			ANDS R1, R1, R5					;R1 is only red led
			CMP	R1,#0						;if the LED is on (0) then branch and toggle
			BNE green_med
			
			BL  Toggle_Red
		
green_med	BL  Green_On
			BL	Line_enter
			LDR R0, =correct			;prints correct to the terminal
			MOVS R1, #MAX_STRING
			BL  PutStringSB		
				
			BL	Line_enter
			
			ADDS R3, R3, #1				;increment the number of games passed
			LDR  R6,=GAMES_PASSED
			STR  R3,[R6,#0]
			
			ADDS R7, R7, #4				;increment the game buffer to get another scramble word
			LDR  R5,=GAME_BUFFER
			STR  R7,[R5,#0]

			B    mid_loop
			
wrong_medium	
			LDR R1,=FGPIOB_BASE
			LDR R1,[R1,#GPIO_PDOR_OFFSET]
			LDR R2,=PORTB_LEDS_MASK
			LDR R5,=PORTB_LED_GREEN_MASK
			ANDS R1, R1, R5					;R1 is only red led
			CMP	R1,#0						;if the LED is on (0) then branch and toggle
			BNE red_med
			
			BL  Toggle_Green
			
red_med		BL  Red_On
			BL  Line_enter
			LDR R0,=incorrect			;prints incorrect to the terminal
			BL  PutStringSB				
			
			B	try_medium				;branches to the top but skips round 1 prompt

;-----------------------------------------------------------------------------------------------
;Beginning of Round 3, Hard loops				
round3		LDR  R1,=Scramble_Array		;reloads the adddresses because they get changed for GetString
			LDR  R2,=Normal_Array

			BL  Line_enter

			LDR R0,=round_three
			BL  PutStringSB
			
			BL   Line_enter				;enter
			
bot_loop	;MOVS R3, #GAME_BUFFER		;load the game buffer
			CMP  R3, #6				;checks the number of games passed
			BEQ	 endof_game
			
try_hard	LDR  R1,=Scramble_Array		;reloads the adddresses because they get changed for GetString
			LDR  R2,=Normal_Array

			MOVS R0,#'>'				;helps denote what the actual word is
			BL  PutChar
			
			LDR R4, [R1, R7]			;gets the word at the offset of the game buffer from the scramble array
			MOVS R0, R4					;makes a copy of the scrambled word
			BL   PutStringSB			;prints the string to the terminal
			
			BL  Line_enter
			
			MOVS R4, #MAX_HAR			;length of all easy words
			LDR  R2,=STRING
			BL   GetStringSB

			BL Comparator				;compare the two strings
			BCS wrong_hard
			
			LDR R1,=FGPIOB_BASE
			LDR R1,[R1,#GPIO_PDOR_OFFSET]
			LDR R2,=PORTB_LEDS_MASK
			LDR R5,=PORTB_LED_RED_MASK
			ANDS R1, R1, R5					;R1 is only red led
			CMP	R1,#0						;if the LED is on (0) then branch and toggle
			BNE green_hard
			
			BL  Toggle_Red

green_hard	BL  Green_On
			BL	Line_enter
			LDR R0, =correct			;prints correct to the terminal
			MOVS R1, #MAX_STRING
			BL  PutStringSB		
				
			BL	Line_enter
			
			ADDS R3, R3, #1				;increment the number of games passed
			LDR  R6,=GAMES_PASSED
			STR  R3,[R6,#0]
			
			ADDS R7, R7, #4				;increment the game buffer to get another scramble word
			LDR  R5,=GAME_BUFFER
			STR  R7,[R5,#0]
			
			B    bot_loop
			BL   Line_enter
		
wrong_hard	
			LDR R1,=FGPIOB_BASE
			LDR R1,[R1,#GPIO_PDOR_OFFSET]
			LDR R2,=PORTB_LEDS_MASK
			LDR R5,=PORTB_LED_GREEN_MASK
			ANDS R1, R1, R5					;R1 is only red led
			CMP	R1,#0						;if the LED is on (0) then branch and toggle
			BNE red_hard
			
			BL  Toggle_Green
			
red_hard	BL  Red_On

			BL  Line_enter
			LDR R0,=incorrect			;prints incorrect to the terminal
			BL  PutStringSB	
			BL  Line_enter
			B   try_hard
			
endof_game

			POP{R0-R7,PC}
			ENDP

Scramblizer PROC 	{R2-R14}
;TODO: Word scrambling function.
;Using some randomizing, the subroutine will be called for every
;unscrambled word currently in the array. The subroutine will check
;if the new scrambled word is the same as the original and if it is 
;it will scramble and rearrange the letter indexes again until the
;word is sufficiently scrambled.

			ENDP
				
Comparator	PROC 	{R2-R14}
;Compares the normal string and the string entererd by the user
;Inputs: 
;		R1 = User input
;		R2 = Normal_Array
;       R4 = SIZE
;Outputs
;C Bit:
;	Clear when the user answers correctly
; 	Set when the user answers incorrectly

			PUSH {R0-R7, LR}
			
			MOVS R6, #0				;passed tests
			MOVS R7, #0				;counter
			LDR  R3,=GAME_BUFFER	;load the GAME_BUFFER
			LDR  R3,[R3,#0]			;load the contents of the GAME_BUFFER
			
			
			LDR R4,=Normal_Array	;puts the address of the normal array into R4
			LDR R2,[R4, R3]			;loads the word in the normal array at offset GAME_BUFFER
			LDR R1,=STRING
			MOVS R5,R2
			MOVS R3,R1
			
			;Compare the values of each piece, R1 and R2
	
	
check_again	
			LDRB R1,[R3,R7]			;get the letter of the user input
			LDRB R2,[R5,R7]			;get the letter of the normal word
			
			CMP R1,R2				;compare the two letters
			BNE Set_C				;if they're not equal that is not correct
			
			ADDS R6, R6, #1
		
			CMP R1, #NULL			;if the user input reaches a null pointer then leave
									;null pointer is automatically added at the end of GetStringSB
			BEQ leave_compare
			
			ADDS R7, R7, #ACCUM 		;increment the counter
			B   check_again
				
leave_compare

			;CMP R6, R4					;checking if the sizes of both strings are correct?
			;BNE	Set_C		
			
Clr_C		MRS  R4, APSR				;after the end of the while loop, the bit is cleared
			MOVS R5, #0x20				
			LSLS R5, R5, #24
			BICS R4, R4, R5
			MSR  APSR, R4	
			B 	 _POP

			 		
Set_C		MRS  R4, APSR				;Sets the C bit if the result is invalid
			MOVS R5, #0x20
			LSLS R5, R5, #24
			ORRS R4, R4, R5
			MSR  APSR, R4
			B    _POP

_POP
			POP{R0-R7, PC}
			ENDP
				
UART0_ISR 	PROC	{R2-R14}	
;ISR Functionality
;Inputs: None
;Outputs: None

;Mask other interrupts

			CPSID I
			PUSH {R0-R7, LR}
			
			LDR R6,=UART0_BASE
			
			LDRB R2, [R6,#UART0_C2_OFFSET]
			MOVS R3, #UART0_C2_TIE_MASK
			TST  R3, R2
			BEQ	 Check_Receive
			
			MOVS R2, #UART0_S1_TDRE_MASK			
			LDRB R5, [R6, #UART0_S1_OFFSET]
			TST  R5, R2
			BEQ  Check_Receive
			
			LDR  R1,=TxRecord
			BL   Dequeue
			
			BCS  fail_deq
			
			STRB R0, [R6, #UART0_D_OFFSET]
			B    Check_Receive
			
fail_deq	MOVS R5,#UART0_C2_T_RI
			STRB R5, [R6, #UART0_C2_OFFSET]
			
Check_Receive
			MOVS R5,#UART0_S1_RDRF_MASK
			LDRB R7, [R6, #UART0_S1_OFFSET]
			TST  R7, R5
			BEQ	 Leave
			
			LDRB R0, [R6, #UART0_D_OFFSET]
			LDR  R1,=RxRecord
			BL	 Enqueue
			
Leave		
			CPSIE	I
			POP {R0-R7, PC}
			ENDP
				
PIT_ISR 	PROC 	{R0-R14}
;Stopwatch loop stuff
			CPSID	I
			PUSH	{R0-R2,LR}
			
			;Get stopwatch to compare
			LDR		R0,=StopWatch
			LDR		R0,[R0,#0]
			
			CMP 	R0,#0
			BEQ		clearPIT
			
			LDR 	R1,=Count
			LDR		R2,[R1, #0]
			
			ADDS	R2,R2,#1
			STR		R2,[R1,#0]
			
clearPIT	
			LDR 	R0,=PIT_CH0_BASE
			LDR		R1,=PIT_TFLG_TIF_MASK
			STR		R1,[R0,#PIT_TFLG_OFFSET]
			CPSIE	I
			POP		{R0-R2, PC}
			ENDP
				
Line_enter	PROC	{R2-R14}
;Prints a CR and LF to the terminal
			
			PUSH{R0, LR}
			
			MOVS R0, #LF
			BL   PutChar
			MOVS R0, #CR
			BL   PutChar
			
			POP{R0, PC}
			ENDP
				
Init_NVIC     PROC      {R0-R14}

            LDR     R0,=UART0_IPR
            ;LDR     R1,=NVIC_IDR_UARTO_MASK
            LDR     R2,=NVIC_IPR_UART0_PRI_3
            LDR     R3,[R0,#0]
            ;BICS    R3,R3,R1,
            ORRS    R3,R3,R2
            STR     R3,[R0,#0]
            
            ;clesr any pending varto interrupts
            LDR     R0,=NVIC_ICPR
            LDR     R1,=NVIC_ICPR_UART0_MASK
            STR     R1,[R0,#0]
            ;unmask vartointerrupts
            LDR     R0,=NVIC_ISER
            LDR     R1,=NVIC_ICER_UART0_MASK
            STR     R1,[R0,#0]

            ENDP

Init_PIT_IRQ	PROC {R0-R14}
;Enable the PIT
;
			PUSH	{R0-R2, LR}
			
			LDR R0,=SIM_SCGC6
			LDR R1,=SIM_SCGC6_PIT_MASK
			LDR R2,[R0,#0]
			ORRS R2,R2,R1
			STR R2,[R0,#0]
						
						
						;Diable PIT Timer
						
			LDR R0,=PIT_CH0_BASE
			LDR R1,=PIT_TCTRL_TEN_MASK
			LDR R2,[R0,#PIT_TCTRL_OFFSET]
			BICS R2,R2,R1
			STR R2,[R0,#PIT_TCTRL_OFFSET]			
				
			
						;Set PIT Interrupt PR0oR0ty
						
			LDR R0,=PIT_IPR
			LDR R1,=NVIC_IPR_PIT_MASK
			;LDR R2,=NVIC_IPR_PIT_PR0_0
			LDR R1,[R0,#0]
			BICS R1,R1,R2
			;ORRS Rl,Rl,R2
			STR R1,[R0,#0]
			
						;Clear any pending PIT interrupts
						
			LDR R0,=NVIC_ICPR
			LDR R1,=NVIC_ICPR_PIT_MASK
			STR R1,[R0,#0]
			;Unmask PIT interrupts
			LDR R0,=NVIC_ISER
			LDR R1,=NVIC_ISER_PIT_MASK
			STR R1,[R0,#0]
			
						;Enable PIT Module
						
			LDR R0,=PIT_BASE
			LDR R1,=PIT_MCR_EN_FRZ
			STR R1,[R0,#PIT_MCR_OFFSET]
			;Set PIT timer 0 peR0od for 0.01 s
			LDR R0,=PIT_CH0_BASE
			LDR R1,=PIT_LDVAL_10ms
			STR R1,[R0,#PIT_LDVAL_OFFSET]
			;Enable PIT timer 0 interrupt
			LDR R1,=PIT_TCTRL_CH_IE
			STR R1,[R0,#PIT_TCTRL_OFFSET]
			
			POP	{R0-R2, PC}
			ENDP
				
Init_UART0_IRQ PROC {R0-R14}				
;Initializes the UART0 and makes
;it wait for instructions on what
;to do next

			PUSH {R0-R3, LR}
			
			LDR R0, =RxBuffer
			LDR R1,=RxRecord
			MOVS R2, #Rx_Q_BUF
			BL  InitQueue
			LDR R0, =TxBuffer
			LDR R1, =TxRecord
			MOVS R2, #Tx_Q_BUF
			BL  InitQueue
			
			;Select MCGFLLCLK as UART0 clock source
			LDR R1,=SIM_SOPT2
			LDR R2,=SIM_SOPT2_UART0SRC_MASK
			LDR R3,[R1,#0]
			BICS R3,R3,R2
			LDR R2,=SIM_SOPT2_UART0SRC_MCGFLLCLK
			ORRS R3,R3,R2
			STR R3,[R1,#0]
			
			;Set UART0 for external connection
			LDR R1,=SIM_SOPT5
			LDR R2,=SIM_SOPT5_UART0_EXTERN_MASK_CLEAR
			LDR R3,[R1,#0]
			BICS R3,R3,R2
			STR R3,[R1,#0]
			
			;Enable UART0 module clock
			LDR R1,=SIM_SCGC4
			LDR R2,=SIM_SCGC4_UART0_MASK
			LDR R3,[R1,#0]
			ORRS R3,R3,R2
			STR R3,[R1,#0]
			
			;Enable PORT B module clock
			LDR R1,=SIM_SCGC5
			LDR R2,=SIM_SCGC5_PORTB_MASK
			LDR R3,[R1,#0]
			ORRS R3,R3,R2
			STR R3,[R1,#0]
		
			;Select PORT B Pin 2 (D0) for UART0 RX (J8 Pin 01)
			LDR R1,=PORTB_PCR2
			LDR R2,=PORT_PCR_SET_PTB2_UART0_RX
			STR R2,[R1,#0]
			
			; Select PORT B Pin 1 (D1) for UART0 TX (J8 Pin 02)
			LDR R1,=PORTB_PCR1
			LDR R2,=PORT_PCR_SET_PTB1_UART0_TX
			STR R2,[R1,#0]
			
			;Disable UART0 receiver and transmitter
			LDR R1,=UART0_BASE
			MOVS R2,#UART0_C2_T_R
			LDRB R3,[R1,#UART0_C2_OFFSET]
			BICS R3,R3,R2
			STRB R3,[R1,#UART0_C2_OFFSET]
			
			;Set UART0 IRQ Priority
			LDR  R0, =UART0_IPR
			;LDR R1, =NVIC_IPR_UART0_MASK
			LDR	 R2, =NVIC_IPR_UART0_PRI_3
			LDR  R3, [R0, #0]
			
			ORRS R3, R3, R2
			STR  R3, [R0, #0]
;Clear any pending UART0 interrupts			
			LDR  R0, =NVIC_ICPR
			LDR  R1, =NVIC_ICPR_UART0_MASK
			STR  R1, [R0,#0]
			
;Unmask UART0 interrupts
			LDR  R0, =NVIC_ISER
			LDR  R1, =NVIC_ISER_UART0_MASK
			STR  R1,[R0, #0]
			
			
			;Set UART0 for 9600 baud, 8N1 protocol
			LDR  R1, =UART0_BASE
			MOVS R2,#UART0_BDH_9600
			STRB R2,[R1,#UART0_BDH_OFFSET]
			MOVS R2,#UART0_BDL_9600
			STRB R2,[R1,#UART0_BDL_OFFSET]
			MOVS R2,#UART0_C1_8N1
			STRB R2,[R1,#UART0_C1_OFFSET]
			MOVS R2,#UART0_C3_NO_TXINV
			
			STRB R2,[R1,#UART0_C3_OFFSET]
			MOVS R2,#UART0_C4_NO_MATCH_OSR_16
			STRB R2,[R1,#UART0_C4_OFFSET]
			MOVS R2,#UART0_C5_NO_DMA_SSR_SYNC
			STRB R2,[R1,#UART0_C5_OFFSET]
			MOVS R2,#UART0_S1_CLEAR_FLAGS
			STRB R2,[R1,#UART0_S1_OFFSET]
			MOVS R2, #UART0_S2_NO_RXINV_BRK10_NO_LBKDETECT_CLEAR_FLAGS
			STRB R2,[R1,#UART0_S2_OFFSET]
			
			;Enable UART0 receiver and transmitter
			LDR  R1, =UART0_BASE
			MOVS R2,#UART0_C2_T_R
			STRB R2,[R1,#UART0_C2_OFFSET]
			
			POP {R0-R3, PC}
			ENDP
				
PutStringSB	PROC	{R2-R14}
; Displays a null-terminated string from memory,
; starting at the address where R0 points, to the
; terminal screen.
; Parameters
; 			Input: R0: Pointer to source string
; 			Modify: APSR
; Uses:
; 			PutChar
;R0 = char
;R1 = MAX_STRING size
;R2 = String pointer/counter
			
			PUSH {R3, R4, LR}

			MOVS R2, #0				;intialize counter
			MOVS R4, #MAX_STRING		
			SUBS R4, R4, #1			;Actual buffer size
			
put_another			
			CMP R2, R4
			BEQ	Put_Terminate
			
			PUSH {R0}				;save address onto stack
			
			LDRB R0, [R0, R2] 		;load the first value of the string
			CMP R0, #NULL
			BEQ Put_Terminate		;if the value is null then terminate
			
			BL  PutChar
			
			POP {R0}				;resets the og string
			
			ADDS R2, R2, #1			;increment counter
			B   put_another
			
Put_Terminate
			POP{R3, R4, R0, PC}
			ENDP
				
GetStringSB PROC	{R2-R14}
;Inputs a string from the user keyboard and saves it to
;memory starting at the address R0 and adds null termination
;Cannot input more than MAX_STRING capacity
;R0 = char value
;R1 = buffer
;R2 = pointer to String
;R3 = counter
;R4 = max_length of string before null
;Parameters
; 		Input: R0: Pointer to destination string
; 		Modify: APSR
; Uses:
; 		GetChar, PutChar
			
			PUSH{R3, R4, LR}	
				
			MOVS R3, #0				;initialize counter
			MOVS R4, R1
			SUBS R4, R4, #1			;actual size of buffer without null
			
			;MOVS R2, R0				;temp reg for string
			LDR  R2,=STRING
			
another_Char
			CMP R3, R4				;if the counter = the max_length of the string then null terminate
			BEQ get_forever
			
			
			BL GetChar				;gets character
			CMP R0, #CR				;checks if enter was input
			BEQ Null_Terminate		;terminates if enter was input
			BL PutChar
			
			STRB R0, [R2, R3]		;Store whatever was in R0 into the string R2 with an offset of R3
			ADDS R3, R3, #ACCUM		;increment the counter
			B 	another_Char		;loop to get another character
			
Null_Terminate
			MOVS R0, #NULL			;adds null to R0
			STRB R0, [R2, R3]		;adds null to the end of the string
									;Stores the null into R2 with an offset of the MAX_STRING
			B    byebye

get_forever 
			BL   GetChar
			CMP  R0, #CR
			BEQ  Null_Terminate
			B    get_forever
			

byebye		POP {R3, R4, PC}
			ENDP
				


;>>>>>   end subroutine code <<<<<
            ALIGN
;****************************************************************
;Vector Table Mapped to Address 0 at Reset
;Linker requires __Vectors to be exported
            AREA    RESET, DATA, READONLY
            EXPORT  __Vectors
            EXPORT  __Vectors_End
            EXPORT  __Vectors_Size
            IMPORT  __initial_sp
            IMPORT  Dummy_Handler
            IMPORT  HardFault_Handler
__Vectors 
                                      ;ARM core vectors
            DCD    __initial_sp       ;00:end of stack
            DCD    Reset_Handler      ;01:reset vector
            DCD    Dummy_Handler      ;02:NMI
            DCD    HardFault_Handler  ;03:hard fault
            DCD    Dummy_Handler      ;04:(reserved)
            DCD    Dummy_Handler      ;05:(reserved)
            DCD    Dummy_Handler      ;06:(reserved)
            DCD    Dummy_Handler      ;07:(reserved)
            DCD    Dummy_Handler      ;08:(reserved)
            DCD    Dummy_Handler      ;09:(reserved)
            DCD    Dummy_Handler      ;10:(reserved)
            DCD    Dummy_Handler      ;11:SVCall (supervisor call)
            DCD    Dummy_Handler      ;12:(reserved)
            DCD    Dummy_Handler      ;13:(reserved)
            DCD    Dummy_Handler      ;14:PendSV (PendableSrvReq)
                                      ;   pendable request 
                                      ;   for system service)
            DCD    Dummy_Handler      ;15:SysTick (system tick timer)
            DCD    Dummy_Handler      ;16:DMA channel 0 transfer 
                                      ;   complete/error
            DCD    Dummy_Handler      ;17:DMA channel 1 transfer
                                      ;   complete/error
            DCD    Dummy_Handler      ;18:DMA channel 2 transfer
                                      ;   complete/error
            DCD    Dummy_Handler      ;19:DMA channel 3 transfer
                                      ;   complete/error
            DCD    Dummy_Handler      ;20:(reserved)
            DCD    Dummy_Handler      ;21:FTFA command complete/
                                      ;   read collision
            DCD    Dummy_Handler      ;22:low-voltage detect;
                                      ;   low-voltage warning
            DCD    Dummy_Handler      ;23:low leakage wakeup
            DCD    Dummy_Handler      ;24:I2C0
            DCD    Dummy_Handler      ;25:(reserved)
            DCD    Dummy_Handler      ;26:SPI0
            DCD    Dummy_Handler      ;27:(reserved)
            DCD    UART0_ISR      	  ;28:UART0 (status; error)
            DCD    Dummy_Handler      ;29:(reserved)
            DCD    Dummy_Handler      ;30:(reserved)
            DCD    Dummy_Handler      ;31:ADC0
            DCD    Dummy_Handler      ;32:CMP0
            DCD    Dummy_Handler      ;33:TPM0
            DCD    Dummy_Handler      ;34:TPM1
            DCD    Dummy_Handler      ;35:(reserved)
            DCD    Dummy_Handler      ;36:RTC (alarm)
            DCD    Dummy_Handler      ;37:RTC (seconds)
            DCD    PIT_ISR      	  ;38:PIT
            DCD    Dummy_Handler      ;39:(reserved)
            DCD    Dummy_Handler      ;40:(reserved)
            DCD    Dummy_Handler      ;41:DAC0
            DCD    Dummy_Handler      ;42:TSI0
            DCD    Dummy_Handler      ;43:MCG
            DCD    Dummy_Handler      ;44:LPTMR0
            DCD    Dummy_Handler      ;45:(reserved)
            DCD    Dummy_Handler      ;46:PORTA
            DCD    Dummy_Handler      ;47:PORTB
__Vectors_End
__Vectors_Size  EQU     __Vectors_End - __Vectors
            ALIGN
;****************************************************************
;Constants
            AREA    MyConst,DATA,READONLY
;>>>>> begin constants here <<<<<
welcome_prompt 		 DCB 	"Welcome to Scramble!!!!",0
help_prompt   		 DCB 	"Here are the possible commands: Directions (D), Restart (R), End (E), Play (P): ",0
directions_prompt_p1 DCB	"You will be shown a word with the letters rearranged.",0
directions_prompt_p2 DCB	"Your job is to decode the scrambled as fast as you can. Your time will be shown once you complete the game.",0
directions_prompt_p3 DCB	"If you are correct a green light will appear, if you are wrong a red light will appear and you will have to try again.",0
good_luck 			 DCB	"Good Luck!",0
dashed_lines 		 DCB    "---------------------------------------------------------------------------",0

Start_question		 DCB 	"Would you like to start a game? Yes(Y) Help(H): ",0 
goodbye				 DCB    "Thanks for playing! :P",0
invalid_character 	 DCB    "Please enter a valid character.",0
enter_help			 DCB	"Please enter a help command.",0

;Play_Game Prompts
round_one			DCB		"Round 1: Easy",0
round_two			DCB		"Round 2: Medium",0
round_three			DCB		"Round 3: Hard",0

correct				DCB		"Correct!",0
incorrect			DCB		"Wrong :(",0

play_again			DCB		"Would you like to play again?",0
loser				DCB		"Sorry, you lost!",0
continue			DCB 	"Would you like to continue?",0

end_game			DCB		"Congratulations! You have reached the end of the game. Thanks for playing!!",0
time				DCB		"It took you ",0
seconds				DCB		" mili-seconds",0

;Normal & Scramble counterparts
;Easy mode
hello_normal		DCB		"hello",0
		ALIGN
hello_scramble		DCB		"olelh",0
		ALIGN
			
tiger_normal		DCB		"tiger",0
		ALIGN
tiger_scramble		DCB		"itreg",0
		ALIGN

;Medium mode
matcha_normal		DCB		"matcha",0
		ALIGN

matcha_scramble		DCB		"athcam",0
		ALIGN

french_normal		DCB		"french",0
		ALIGN
			
french_scramble		DCB		"nhrfce",0
		ALIGN
;Hard mode
accessory_normal 	DCB     "accessory",0
		ALIGN
accessory_scramble	DCB		"scoseayrc",0
		ALIGN

pistachio_normal 	DCB		"pistachio",0
		ALIGN

pistachio_scramble	DCB     "hpsoitica",0
		ALIGN


;>>>>>   end constants here <<<<<
            ALIGN
;****************************************************************
;Variables
            AREA    MyData,DATA,READWRITE
;>>>>> begin variables here <<<<<
Normal_Array	SPACE (60)
	ALIGN
Scramble_Array	SPACE (60)
	ALIGN
		
GAME_BUFFER		SPACE   4	;this offset corresponds to the game number that is being played, not corresponding with memory ranges 
	ALIGN
	
GAMES_PASSED	SPACE 	4	;numbers of games that the user has passed
	ALIGN		
		
STRING			SPACE	79
	ALIGN	
		
StopWatch 	SPACE	1
			ALIGN
Count		SPACE	4
			ALIGN
				
RxBuffer	space  	Rx_Q_BUF
			ALIGN
RxRecord	space	Rx_Q_REC
			ALIGN
TxBuffer	space	Tx_Q_BUF
			ALIGN
TxRecord	space	Tx_Q_REC
			ALIGN
;>>>>>   end variables here <<<<<

            ALIGN
            END