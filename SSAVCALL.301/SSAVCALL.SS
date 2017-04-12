;                           >>> STALLION SOFTWARE's AES/VDI CALL <<<
;
; ///  SSAVCALL Project Version 3.01 (09/01/00) - KOSS 1996/2000 - Plug-In Extended  ///
;
; AutoInstall Version 1.88
;         Cookie "NULL" -> JarSize
;         Cookie "SSAV" -> SSAVCALL_Header
; LineA : XBRA   "SSAV" -> SSAVCALL_LINEA
; LineF : XBRA   "SSAV" -> SSAVCALL_LINEF
; TRAP3 : XBRA   "SSAV" -> SSAVCALL_TRAP3

; I REALLY think that the SSAVCALL Project is one of the most IMPORTANT of the end
; of this Century ! Please, have a look, then cry !

	; *** Equates for Assembly

ASSEMBLY_DAY	EQU	9	
ASSEMBLY_MONTH	EQU	1
ASSEMBLY_YEAR	EQU	2000

	; Date Format :	 AAAAAAAmmmmJJJJJ
ASSEMBLY_DATE	EQU	((ASSEMBLY_YEAR-1980)<<9)|(ASSEMBLY_MONTH<<5)|(ASSEMBLY_DAY)

	; *** Commands for Assembly

	OPT	p=68030/68882
	comment	HEAD=7	; FastLoad

	; *** Start of the Program

; /////////////////////////////////////////////////////////////////////////////
	SECTION	TEXT
; /////////////////////////////////////////////////////////////////////////////

; *** INSSTALLATION POUR ORDINATEURS ATARI ************************************

	include	\INCLUDES\BOOTMODS\FUJIBOOT.SSM
	
; *** Routine SuperViseur d'inSStallation *************************************

	include	\INCLUDES\BOOTMODS\SSAVBOOT.SSM


	include	\INCLUDES\MAINMODS\LINEAVEC.SSM


	include	\INCLUDES\MAINMODS\LINEFVEC.SSM

; *****************************************************************************

	; # ... : 09/01/2000 #

SSAVCALL_CreatePrgField	; >> SSAVCALL_ProgField
	; Voir pour la r‚servation de m‚moire

	include	\INCLUDES\MAINMODS\TRAP3VEC.SSM
	
; *****************************************************************************
; *** Le d‚but de SSAVCALL ****************************************************
; *****************************************************************************

	include	\INCLUDES\MAINMODS\SSAVHEAD.SSM

	
; *****************************************************************************
; *** Plug-In SystŠmes ********************************************************
; *****************************************************************************

	include	\INCLUDES\MAINMODS\LISTMODS.SSM

; /////////////////////////////////////////////////////////////////////////////
	SECTION	DATA
; /////////////////////////////////////////////////////////////////////////////
	
	; # ... : 07/01/2000 #
	
SSAVCALL_ProgField	include	\INCLUDES\BOOTMODS\SSAVPFLD.SEB

; /////////////////////////////////////////////////////////////////////////////
	SECTION	BSS
; // OK ///////////////////////////////////////////////////////////////////////

	; # OK : 07/01/2000 #

; /// La Pile Accessoire ///

	ds.l	256
BOOT_ACC_Stack	ds.l	2	; Pour la BasePage

