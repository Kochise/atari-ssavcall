; //////////////////////////////////////////////////
; ///                                            ///
; ///  >>> STALLION SOFTWARE'S AES-VDI CALL <<<  ///
; ///                                            ///
; /// A KOSS Production For ATARI With 68020 Min ///
; ///                                            ///
; //////////////////////////////////////////////////
;
; AutoInstall Version 1.52
; Cookie SSAV -> START_SSAV
;
; /// VERSION 2.31 ///
;

	SECTION	TEXT

	BRA	StartUp
	
	dc.l	Start_SSAV		; Pour commencer
	ds.b	1020		; Pour les versions futures

StartUp	include	MODULES\AUTOINST.SSM	; <<<
	
	dc.w	$231		; Version 2.31
	dc.w	%10010100001000		; 8 Aout 1998
	ds.w	1		; Compteur

Start_SSAV	include	MODULES\SSAVXBRA.SSM	; <<<

AES_Control	include	MODULES\AES-CTRL.SSM	; <<<
VDI_Control	include	MODULES\VDI-CTRL.SSM	; <<<

	SECTION	DATA

Cookie_Name	dc.b	"SSAV"
;SSAV_Logo	incbin	SSAVBOOT\SSAVLOGO.IMG	; <<<
;SSAV_Boot	incbin	SSAVBOOT\SSAVBOOT.IMG	; <<<

	SECTION	BSS
	
	