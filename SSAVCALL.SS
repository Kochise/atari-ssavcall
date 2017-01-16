;                  >>> STALLION SOFTWARE's AES/VDI CALL <<<
;
; ///  SSAVCALL Project Version 3.00 - KOSS 1996/1999 - Plug-In Extended  ///
;
; AutoInstall Version 1.86
; Cookie "SSAV" -> SSAV_Info
; XBRA   "SSAV" -> SSAV_Start

	comment	HEAD=7	; FastLoad

	SECTION	TEXT

	BRA	StartUp

; Table d'OffSet	
	dc.l	SSAV_Start	; Pour commencer
	dc.l	SSAV_Info
	ds.b	1016	; Pour les versions futures

; L'inSStalleur
StartUp	include	AUTOINST.SS	; <<<
	
; SSAVPROG_Info
SSAV_Info	dc.w	$300	; Version 3.00
	;	 AAAAAmmmmJJJJJ
	dc.w	%10011001010010	; 18 F‚vrier 1999
	dc.l	AES_Control	; PlugList (1er)
	dc.b	"SSAVCALL",0	; ProgName
	dc.b	"KOSS",0	; ProgAuthor

; SSAVCALL_Start (Short XBRA)
	dc.b	"XBRA"
	dc.b	"SSAV"
OldTRAP3	ds.l	1
SSAV_Start	cmpi.w	#-1,(SP)
	BEQ	SSAV_InMemory

	RTE

SSAV_UnValid	JMP	([OldTRAP3])	; Zou...

SSAV_InMemory	move.l	#"SSAV",D0
	
	; PROG_Shrink
	
	RTE

; Nouvelles BibliothŠques
AES_Control	include	AES-CTRL.SSM	; <<<
CONFIG_Manager	include	CNF-MANA.SSM	; <<<
COOKIE_Manager	include	CUK-MANA.SSM	; <<<
FILE_Manager	include	FIL-MANA.SSM	; <<<
MEMORY_Control	include	MEM-CTRL.SSM	; <<<
PINS_Manager	include	PIN-MANA.SSM	; <<<
PROGRAM_Control	include	PRG-CTRL.SSM	; <<<
VDI_Control	include	VDI-CTRL.SSM	; <<<
XBRA_Manager	include	XBR-MANA.SSM	; <<<

; **********************************************************************************
	SECTION	DATA
; **********************************************************************************

SSAVBOOT_PCTxt	dc.b	"  >Configuration Minimale<",13,10,0
SSAVBOOT_OKTxt	dc.b	"   Installation correcte...      8-)",13,10,0
SSAVBOOT_NOTxt	dc.b	"   Installation d‚fectueuse...   8-(",13,10,0
SSAVBOOT_ARTxt	dc.b	"   D‚j… install‚...              8-|",13,10,0

; **********************************************************************************
	SECTION	BSS
; **********************************************************************************
	
; /// La Pile Accessoire ///

	ds.l	$100
AccStack	ds.l	2