;                  >>> STALLION SOFTWARE's AES/VDI CALL <<<
;
; ///  SSAVCALL Project Version 2.56 - KOSS 1996/2004 - Plug-In Extended  ///
;
; AutoInstall Version 1.73
; Cookie "SSAV" -> Start_SSAV
; XBRA   "SSAV" -> New_TRAP2

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

PROG_ED_MAJOR_VERSION:	EQU	$02
PROG_ED_MINOR_VERSION:	EQU	$56
PROG_ED_ASSEMBLY_VERSION:	EQU	(PROG_ED_MAJOR_VERSION<<8)|PROG_ED_MINOR_VERSION

PROG_ED_YEAR:	EQU	2004	; %YYYY YYYM MMMD DDDD
PROG_ED_MONTH:	EQU	09	;  FEDC BA98 7654 3210
PROG_ED_DAY:	EQU	25	; Binary Date Format
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
;	dc.b	"SSAVCALL",0	; ProgNAME
;	dc.b	"Kochise",0	; ProgAUTHOR

; --- TEXT USER INIT (TUI) ----------------------------------------------------

	; L'inSStalleur
PROG_TUI_START:	include	LIBRARY\AUTOINST.SSM	; <<<

; --- TEXT USER MAIN (TUM) ----------------------------------------------------

; Table d'OffSet
	dc.l	SSAV_TUI_BOOT_CLEAR	; Pour commencer
	ds.b	1020	; Pour les versions futures


; SSAVPROG_Info
SSAV_TUM_INFO_TAB:	dc.w	PROG_ED_ASSEMBLY_VERSION	; Version
	dc.w	PROG_ED_ASSEMBLY_DATE	; Date
	ds.w	1	; Compteur

; SSAVCALL_Start
SSAV_TUM_DISPATCH:	tst.w	(4,SP)	; Appel aux Fonctions SystŠmes
	BEQ	SSAV_TSS_SYS_CTRL
	cmpi.w	#115,(4,SP)	; Appel du VDI
	BEQ	SSAV_TSS_VDI_CTRL
	cmpi.w	#200,(4,SP)	; Appel de l'AES
	BEQ	SSAV_TSS_AES_CTRL

	; Un peu limit‚, hein? Mais faut d'la place pour les
	; modules "Plug-In" qui suivront...

	RTS

; --- TEXT USER EXIT (TUE) ----------------------------------------------------

; --- TEXT USER SUB (TUS) -----------------------------------------------------

; =============================================================================

; --- TEXT SUPER MAIN (TSM) ---------------------------------------------------

; --- TEXT SUPER SUB (TSS) ----------------------------------------------------

; Nouvelles BibliothŠques

SSAV_TSS_SYS_CTRL:	include	LIBRARY\SYS-CTRL.SSM	; <<<
SSAV_TSS_VDI_CTRL:	include	LIBRARY\VDI-CTRL.SSM	; <<<
SSAV_TSS_AES_CTRL:	include	LIBRARY\AES-CTRL.SSM	; <<<

; /////////////////////////////////////////////////////////////////////////////
	SECTION	DATA
; /////////////////////////////////////////////////////////////////////////////

; --- DATA ADDRESS TABLE (DAT) ------------------------------------------------

SSAV_DAT_AES_PARAMS:	dc.l	SSAV_BDB_AES_CTRL
	dc.l	SSAV_BDB_AES_GLBL
	dc.l	SSAV_BDB_AES_INTI
	dc.l	SSAV_BDB_AES_INTO
	dc.l	SSAV_BDB_AES_ADRI
	dc.l	SSAV_BDB_AES_ADRO

; --- DATA DEFINED ARRAY (DDA) ------------------------------------------------

SSAV_DDA_TXT_TITLE:	dc.b	" SSAVCALL $$.$$ - KOSS Prod (**/**/**) ",0

SSAV_DDA_TXT_PC:	dc.b	"  >Configuration Minimale<",13,10,0
SSAV_DDA_TXT_OK:	dc.b	"   Installation correcte...      8-)",13,10,0
SSAV_DDA_TXT_NO:	dc.b	"   Installation d‚fectueuse...   8-(",13,10,0
SSAV_DDA_TXT_AR:	dc.b	"   D‚j… install‚...              8-|",13,10,0

; /////////////////////////////////////////////////////////////////////////////
	SECTION	BSS
; /////////////////////////////////////////////////////////////////////////////

; --- BSS DATA BUFFER (BDB) ---------------------------------------------------

SSAV_BDB_TAB_START:	ds.w	1	; AP_ID
	ds.l	1	; Prog_Size
	ds.l	1	; Prog_End
	ds.l	1	; Memo_DynaDescriptor

SSAV_BDB_TKR_BUFF:	ds.b	40	; Texte
	ds.b	10	; Buffer nombre

; /// Les variables de l'AES ///

SSAV_BDB_AES_CTRL:	ds.w	5	; Control
SSAV_BDB_AES_GLBL:	ds.w	14	; Global
SSAV_BDB_AES_INTI:	ds.w	16	; Int_In
SSAV_BDB_AES_INTO:	ds.w	7	; Int_Out
SSAV_BDB_AES_ADRI:	ds.l	3	; Addr_In
SSAV_BDB_AES_ADRO:	ds.l	1	; Addr_Out

; /// La Pile Accessoire ///

	ds.l	$100
SSAV_BDB_ACC_STACK:	ds.l	2


; --- BSS FLAG BUFFER (BFB) ---------------------------------------------------







