; //////////////////////////////////////////////////
; ///                                            ///
; ///  >>> STALLION SOFTWARE'S AES-VDI CALL <<<  ///
; ///                                            ///
; /// A KOSS Production For ATARI With 68020 Min ///
; ///                                            ///
; //////////////////////////////////////////////////
;
; AutoInstall Version 1.63
; Cookie SSAV -> Start_SSAV
;
; /// SSAVCALL Version 2.31 ///
;

	output	SSAVCALL.PRG

	SECTION	TEXT

	BRA	StartUp
	
	dc.l	Start_SSAV	; Pour commencer
	ds.b	1020	; Pour les versions futures

StartUp	include	MODULES\AUTOINST.SSM	; <<<
	
	dc.w	$231	; Version 2.31
	dc.w	%10010100001000	; 8 Aout 1998
	ds.w	1	; Compteur

Start_SSAV	cmpi.w	#115,(4,SP)	; Appel du VDI
	BEQ	VDI_Control
	cmpi.w	#200,(4,SP)	; Appel de l'AES
	BEQ	AES_Control

	; Un peu limit‚, hein? Mais faut d'la place pour les
	; modules "Plug-In" qui suivront...

	RTS

AES_Control	include	MODULES\AES-CTRL.SSM	; <<<
VDI_Control	include	MODULES\VDI-CTRL.SSM	; <<<

	SECTION	DATA
	
	SECTION	BSS

