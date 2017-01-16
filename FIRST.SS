; /// >  - KOSS 2002 < ///

	OPT	p=68030/68882
	COMMENT	HEAD=7	; FastLoad

BS:	EQU	1	; Bytes size
WS:	EQU	2
LS:	EQU	4

BB:	EQU	BS*8	; Bits size
WB:	EQU	WS*8
LB:	EQU	LS*8

FALSE:	EQU	0
TRUE:	EQU	1

; --- EQUATE ASSEMBLY (EA) ----------------------------------------------------

; --- EQUATE DATA (ED) --------------------------------------------------------

PROG_ED_MAJOR_VERSION:	EQU	$01
PROG_ED_MINOR_VERSION:	EQU	$00
PROG_ED_ASSEMBLY_VERSION:	EQU	(PROG_ED_MAJOR_VERSION<<8)|PROG_ED_MINOR_VERSION

PROG_ED_DAY:	EQU	16	; Binary Date Format
PROG_ED_MONTH:	EQU	03	;  FEDC BA98 7654 3210
PROG_ED_YEAR:	EQU	2002	; %YYYY YYYM MMMD DDDD
PROG_ED_ASSEMBLY_DATE:	EQU	((PROG_ED_YEAR-1980)<<9)|(PROG_ED_MONTH<<5)|(PROG_ED_DAY)

; --- EQUATE INDEX (EI) -------------------------------------------------------

; --- EQUATE SYSTEM (ES) ------------------------------------------------------

; /////////////////////////////////////////////////////////////////////////////	
	SECTION	TEXT
; /////////////////////////////////////////////////////////////////////////////	
	
;	BRA	PROG_TUI_START
	
;	dc.b	"ProgHEAD"	; ProgHEADER
;	dc.w	PROG_ED_ASSEMBLY_VERSION	; ProgVERSION
;	dc.w	PROG_ED_ASSEMBLY_DATE	; ProgDATE
;	dc.b	"First Prog",0	; ProgNAME
;	dc.b	"Kochise",0	; ProgAUTHOR
	
; --- TEXT USER INIT (TUI) ----------------------------------------------------
	
PROG_TUI_START:	movea.l	(4,SP),A6	; ADDR PROG BLOCK START (BASEPAGE)
	move.l	(12,A6),D0	; SIZE SECTION TEXT
	add.l	(20,A6),D0	; SIZE SECTION DATA +
	add.l	(28,A6),D0	; SIZE SECTION BSS  +
	addi.l	#$100,D0	; SIZE BASEPAGE     +
	addi.l	#$400,D0	; SIZE NEW STACK    +
	move.l	D0,D1	; SIZE PROG BLOCK   =
	move.l	D0,D7
	add.l	A6,D1	; ADDR PROG BLOCK END                  (NEW STACK BLOCK END)
	andi.l	#-2,D1	; ADDR PROG BLOCK END                  (EVEN ADDR)              
	subq.l	#8,D1	; ADDR NEW STACK BLOCK END - 8         (NEW STACK POINTER START)
	move.l	(4,SP),D2	; ADDR PROG BLOCK START        SAVE    (BASEPAGE)
	movea.l	D1,SP	; ADDR NEW STACK POINTER START INSTALL
	move.l	D2,(4,SP)	; ADDR PROG BLOCK START        RESTORE (BASEPAGE)
	move.l	D0,-(SP)	; SIZE PROG BLOCK              RESERVE
	move.l	A6,-(SP)	; ADDR PROG BLOCK START        RESERVE
	clr.w	-(SP)	; RESERVED
	move.w	#$4A,-(SP)	; - M_SHRINK -
	TRAP	#1	; *** GEMDOS ***
	lea	(12,SP),SP

; --- TEXT USER MAIN (TUM) ----------------------------------------------------

; /--> Place your Program HERE <--/

; --- TEXT USER EXIT (TUE) ----------------------------------------------------

PROG_TUE_NO_ERROR:	clr.w	D0	; 0 = NO ERROR
PROG_TUE_PTERM:	move.w	D0,-(SP)
	move.w	#$4C,-(SP)	; - P_TERM -
	TRAP	#1	; *** GEMDOS ***

; --- TEXT USER SUB (TUS) -----------------------------------------------------

; =============================================================================

; --- TEXT SUPER MAIN (TSM) ---------------------------------------------------

; --- TEXT SUPER SUB (TSS) ----------------------------------------------------

; /////////////////////////////////////////////////////////////////////////////	
	SECTION	DATA
; /////////////////////////////////////////////////////////////////////////////	
	
; --- DATA ADDRESS TABLE (DAT) ------------------------------------------------
	
; --- DATA DEFINED ARRAY (DDA) ------------------------------------------------
	
; /////////////////////////////////////////////////////////////////////////////	
	SECTION	BSS
; /////////////////////////////////////////////////////////////////////////////	

; --- BSS DATA BUFFER (BDB) ---------------------------------------------------

; --- BSS FLAG BUFFER (BFB) ---------------------------------------------------
