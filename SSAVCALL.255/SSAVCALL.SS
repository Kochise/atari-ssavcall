;                  >>> STALLION SOFTWARE's AES/VDI CALL <<<
;
; ///  SSAVCALL Project Version 2.55 - KOSS 1996/1999 - Plug-In Extended  ///
;
; AutoInstall Version 1.73
; Cookie "SSAV" -> Start_SSAV
; XBRA   "SSAV" -> New_TRAP2

	comment	HEAD=7	; FastLoad

	SECTION	TEXT

	BRA	StartUp

; Table d'OffSet	
	dc.l	Start_SSAV	; Pour commencer
	ds.b	1020	; Pour les versions futures

; L'inSStalleur
StartUp	include	LIBRARY\AUTOINST.SSM	; <<<
	
; SSAVPROG_Info
SSAV_Info	dc.w	$255	; Version 2.55
	dc.w	%10011000110101	; 21 Janvier 1999
	ds.w	1	; Compteur

; SSAVCALL_Start
Start_SSAV	tst.w	(4,SP)	; Appel aux Fonctions SystŠmes
	BEQ	SYS_Control
	cmpi.w	#115,(4,SP)	; Appel du VDI
	BEQ	VDI_Control
	cmpi.w	#200,(4,SP)	; Appel de l'AES
	BEQ	AES_Control

	; Un peu limit‚, hein? Mais faut d'la place pour les
	; modules "Plug-In" qui suivront...

	RTS

; Nouvelles BibliothŠques
SYS_Control	include	LIBRARY\SYS-CTRL.SSM	; <<<
VDI_Control	include	LIBRARY\VDI-CTRL.SSM	; <<<
AES_Control	include	LIBRARY\AES-CTRL.SSM	; <<<

; **********************************************************************************
	SECTION	DATA
; **********************************************************************************

AES_Params	dc.l	Control
	dc.l	Global
	dc.l	Int_In
	dc.l	Int_Out
	dc.l	Addr_In
	dc.l	Addr_Out

SSAV_Title	dc.b	" SSAVCALL $$.$$ - KOSS Prod (**/**/**) ",0

SSAVBOOT_PCTxt	dc.b	"  >Configuration Minimale<",13,10,0
SSAVBOOT_OKTxt	dc.b	"   Installation correcte...      8-)",13,10,0
SSAVBOOT_NOTxt	dc.b	"   Installation d‚fectueuse...   8-(",13,10,0
SSAVBOOT_ARTxt	dc.b	"   D‚j… install‚...              8-|",13,10,0

; **********************************************************************************
	SECTION	BSS
; **********************************************************************************
	
START_Tab	ds.w	1	; AP_ID
	ds.l	1	; Prog_Size
	ds.l	1	; Prog_End
	ds.l	1	; Memo_DynaDescriptor

TKR_Buffer	ds.b	40	; Texte
	ds.b	10	; Buffer nombre

; /// Les variables de l'AES ///

Control	ds.w	5
Global	ds.w	14
Int_In	ds.w	16
Int_Out	ds.w	7
Addr_In	ds.l	3
Addr_Out	ds.l	1

; /// La Pile Accessoire ///

	ds.l	$100
AccStack	ds.l	2