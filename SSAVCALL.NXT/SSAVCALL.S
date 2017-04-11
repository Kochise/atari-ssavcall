; //////////////////////////////////////////////////
; ///                                            ///
; ///  >>> STALLION SOFTWARE'S AES-VDI CALL <<<  ///
; ///                                            ///
; /// A KOSS Production For ATARI With 68020 Min ///
; ///                                            ///
; //////////////////////////////////////////////////
;
; AutoInstall Version 1.63
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

Start_SSAV	cmpi.w	#115,(4,SP)		; Appel du VDI
	BEQ	VDI_Control
	cmpi.w	#200,(4,SP)		; Appel de l'AES
	BEQ	AES_Control

	RTS

AES_Control	include	MODULES\AES-CTRL.SSM	; <<<
VDI_Control	include	MODULES\VDI-CTRL.SSM	; <<<

	SECTION	DATA

Cookie_Name	dc.b	"SSAV"
	include	DATAS\SSAVCALL.RSM	; <<< La ressource

	SECTION	BSS
	
; /// LES VARIABLES DE L'AES ///

AES_Handle	ds.w	1
Control	ds.w	5
Global	ds.w	14
Int_In	ds.w	16
Int_Out	ds.w	7
Addr_In	ds.l	3
Addr_Out	ds.l	1
AES_Params	ds.l	6