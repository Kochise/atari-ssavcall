; //////////////////////////////////////////////////
; ///                                            ///
; ///  >>> STALLION SOFTWARE'S AES-VDI CALL <<<  ///
; ///                                            ///
; /// A KOSS Production For ATARI With 68020 Min ///
; ///                                            ///
; //////////////////////////////////////////////////
;
; AutoInstall Version 1.07
; Cookie SSAV -> START_SSAV
;
; /// VERSION 1.11 ///
;

	SECTION	TEXT

	movea.l	4(SP),A6		; Adresse de la BASEPAGE
	move.l	$C(A6),D0		; Taille du SEGMENT TEXT
	add.l	$14(A6),D0		; Additionne la taille du SEGMENT DATA … D0
	add.l	$1C(A6),D0		; Additionne la taille du SEGMENT BSS … D0
	addi.l	#$100,D0		; Additionne la taille de la BASEPAGE … D0
	addi.l	#$400,D0		; Additionne la taille de la future PILE (Ici, 256 positions longues (1024 OCTETS))
	move.l	D0,D1		; Copie D0 dans D1 (Taille … r‚server)
	move.l	D0,D7
	add.l	A6,D1		; Additionne l'adresse du d‚but du programme avec D1 (La taille … r‚server)
	andi.l	#-2,D1		; Rend D1 pair (Au cas o— il ne l'‚tait pas)
	movea.l	D1,SP		; Installe l'adresse de fin du programme+place nouvelle PILE dans la PILE
	move.l	D0,-(SP)		; EmPILE la taille … reserver	\
	move.l	A6,-(SP)		; EmPILE l'adresse du programme |-> Rend le reste de la m‚moire au systŠme
	clr.w	-(SP)		; R‚serv‚                       |
	move.w	#$4A,-(SP)		; - M_SHRINK -                  |
	trap	#1		; *** GEMDOS ***                /
	lea	12(SP),SP
	tst	D0		; Si D0<>0, problŠme grave
	BNE	P_Term

	clr.l	-(SP)
	move.w	#$20,-(SP)		; - SUPER -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	move.l	D0,D6

	move.l	$5A0.w,D0
	BEQ	KO_Install
	
	movea.l	D0,A0
	move.l	D0,D1

	suba.l	#4,A0
	
Look_For_Null	addq.l	#1,D3
	adda.l	#4,A0
	move.l	(A0)+,D0
	BNE	Look_For_Null
	
	move.l	(A0),D2
	cmp.l	D2,D3
	BGE	KO_Install
	
	movea.l	D1,A0
	
	suba.l	#4,A0
	move.l	Cookie_Name,D1
		
Look_For_SSAV	subq.l	#1,D3
	BEQ	Install_Rout
	adda.l	#4,A0
	move.l	(A0)+,D0
	cmp.l	D1,D0
	BNE	Look_For_SSAV

	pea	AlReady_Install
	move.w	#9,-(SP)		; - C_CONWS -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP

	BRA	P_Term

Install_Rout	adda.l	#4,A0
	move.l	D1,(A0)+
	move.l	#START_SSAV,(A0)+
	clr.l	(A0)+
	move.l	D2,(A0)
	
	BRA	OK_Install
		
KO_Install	move.l	D6,-(SP)
	move.w	#$20,-(SP)		; - SUPER -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP

	pea	Bad_Install
	move.w	#9,-(SP)		; - C_CONWS -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP

	BRA	P_Term
	
OK_Install	move.l	D6,-(SP)
	move.w	#$20,-(SP)		; - SUPER -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP

	pea	Good_Install
	move.w	#9,-(SP)		; - C_CONWS -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	
P_TermRes	clr.w	-(SP)
	move.l	D7,-(SP)
	move.w	#$31,-(SP)		; - P_TermRes -
	trap	#1		; *** GEMDOS ***
	addq.l	#8,SP
	
P_Term	move.w	D0,-(SP)
	move.w	#$4C,-(SP)		; - P_Term -
	trap	#1		; *** GEMDOS ***
	
	dc.w	$111		; Version 1.11
	dc.w	%10001100001000		; 8 Aout 1997
	ds.w	1		; Compteur

START_SSAV	cmpi.w	#115,(4,SP)		; Appel du VDI
	BEQ	VDI_CONTROL
	cmpi.w	#200,(4,SP)		; Appel de l'AES
	BEQ	AES_CONTROL
	RTS

; *** GESTION DE L'AES ***

AES_CONTROL	move.w	(6,SP),D0
	cmpi.w	#131,D0
	BGT	AES_ERROR		; Au dessus de AES 130, y'a rien
	move.l	(8,SP),A1		; AES_PARAMS
	lea	AES_JUMP(PC),A2		; Le fun...
	JMP	(A2,D0.w*4)
	
AES_ERROR	RTS
	
AES_JUMP	BRA	UnDefAES0
	BRA	UnDefAES1
	BRA	UnDefAES2
	BRA	UnDefAES3
	BRA	UnDefAES4
	BRA	UnDefAES5
	BRA	UnDefAES6
	BRA	UnDefAES7
	BRA	UnDefAES8
	BRA	UnDefAES9
	BRA	Appl_Init		; AES  10
	BRA	Appl_Read		; AES  11
	BRA	Appl_Write		; AES  12
	BRA	Appl_Find		; AES  13
	BRA	Appl_TPlay		; AES  14
	BRA	Appl_TRecord		; AES  15
	BRA	UnDefAES16
	BRA	UnDefAES17
	BRA	Appl_Search		; AES  18
	BRA	Appl_Exit		; AES  19
	BRA	Evnt_KeyBd		; AES  20
	BRA	Evnt_Button		; AES  21
	BRA	Evnt_Mouse		; AES  22
	BRA	Evnt_Mesag		; AES  23
	BRA	Evnt_Timer		; AES  24
	BRA	Evnt_Multi		; AES  25
	BRA	Evnt_DClick		; AES  26
	BRA	UnDefAES27
	BRA	UnDefAES28
	BRA	UnDefAES29
	BRA	Menu_Bar		; AES  30
	BRA	Menu_ICheck		; AES  31
	BRA	Menu_IEnable		; AES  32
	BRA	Menu_TNormal		; AES  33
	BRA	Menu_Text		; AES  34
	BRA	Menu_Register		; AES  35
	BRA	Menu_PopUp		; AES  36
	BRA	Menu_Attach		; AES  37
	BRA	Menu_IStart		; AES  38
	BRA	Menu_Setting		; AES  39
	BRA	Objc_Add		; AES  40
	BRA	Objc_Delete		; AES  41
	BRA	Objc_Draw		; AES  42
	BRA	Objc_Find		; AES  43
	BRA	Objc_OffSet		; AES  44
	BRA	Objc_Order		; AES  45
	BRA	Objc_Edit		; AES  46
	BRA	Objc_Change		; AES  47
	BRA	Objc_SysVar		; AES  48
	BRA	UnDefAES49
	BRA	Form_Do		; AES  50
	BRA	Form_Dial		; AES  51
	BRA	Form_Alert		; AES  52
	BRA	Form_Error		; AES  53
	BRA	Form_Center		; AES  54
	BRA	Form_KeyBd		; AES  55
	BRA	Form_Button		; AES  56
	BRA	SSX2Form_Do		; AES  57 X
	BRA	SSForm_Process		; AES  58 X
	BRA	SSForm_Sound		; AES  59 X
	BRA	Conv_DispNum		; AES  60 X
	BRA	Conv_Rsc2Wk		; AES  61 X
	BRA	Conv_Rsc2Lang		; AES  62 X
	BRA	Conv_ColorPic		; AES  63 X
	BRA	UnDefAES64
	BRA	UnDefAES65
	BRA	UnDefAES66
	BRA	UnDefAES67
	BRA	UnDefAES68
	BRA	UnDefAES69
	BRA	Graf_RubberBox		; AES  70
	BRA	Graf_DragBox		; AES  71
	BRA	Graf_MoveBox		; AES  72
	BRA	Graf_GrowBox		; AES  73
	BRA	Graf_ShrinkBox		; AES  74
	BRA	Graf_WatchBox		; AES  75
	BRA	Graf_SlideBox		; AES  76
	BRA	Graf_Handle		; AES  77
	BRA	Graf_Mouse		; AES  78
	BRA	Graf_MkState		; AES  79
	BRA	Scrp_Read		; AES  80
	BRA	Scrp_Write		; AES  81
	BRA	UnDefAES82
	BRA	UnDefAES83
	BRA	UnDefAES84
	BRA	UnDefAES85
	BRA	UnDefAES86
	BRA	UnDefAES87
	BRA	UnDefAES88
	BRA	UnDefAES89
	BRA	FSel_Input		; AES  90
	BRA	FSel_ExInput		; AES  91
	BRA	UnDefAES92
	BRA	UnDefAES93
	BRA	UnDefAES94
	BRA	UnDefAES95
	BRA	UnDefAES96
	BRA	UnDefAES97
	BRA	UnDefAES98
	BRA	UnDefAES99
	BRA	Wind_Create		; AES 100
	BRA	Wind_Open		; AES 101
	BRA	Wind_Close		; AES 102
	BRA	Wind_Delete		; AES 103
	BRA	Wind_Get		; AES 104
	BRA	Wind_Set		; AES 105
	BRA	Wind_Find		; AES 106
	BRA	Wind_UpDate		; AES 107
	BRA	Wind_Calc		; AES 108
	BRA	Wind_New		; AES 109
	BRA	Rsrc_Load		; AES 110
	BRA	Rsrc_Free		; AES 111
	BRA	Rsrc_GAddr		; AES 112
	BRA	Rsrc_SAddr		; AES 113
	BRA	Rsrc_ObFix		; AES 114
	BRA	Rsrc_RcFix		; AES 115
	BRA	UnDefAES116
	BRA	UnDefAES117
	BRA	UnDefAES118
	BRA	UnDefAES119
	BRA	Shel_Read		; AES 120
	BRA	Shel_Write		; AES 121
	BRA	Shel_Get		; AES 122
	BRA	Shel_Put		; AES 123
	BRA	Shel_Find		; AES 124
	BRA	Shel_Envrn		; AES 125
	BRA	UnDefAES126
	BRA	UnDefAES127
	BRA	UnDefAES128
	BRA	UnDefAES129
	BRA	Appl_GetInfo		; AES 130
	BRA	Appl_Memory
	
; /// AES   0 : Non d‚finit ///

UnDefAES0
	RTS

; /// AES   1 : Non d‚finit ///

UnDefAES1
	RTS
	
; /// AES   2 : Non d‚finit ///

UnDefAES2
	RTS
	
; /// AES   3 : Non d‚finit ///

UnDefAES3
	RTS
	
; /// AES   4 : Non d‚finit ///

UnDefAES4
	RTS
	
; /// AES   5 : Non d‚finit ///

UnDefAES5
	RTS
	
; /// AES   6 : Non d‚finit ///

UnDefAES6
	RTS
	
; /// AES   7 : Non d‚finit ///

UnDefAES7
	RTS
	
; /// AES   8 : Non d‚finit ///

UnDefAES8
	RTS

; /// AES   9 : Non d‚finit ///

UnDefAES9
	RTS
		
; /// AES  10 : APPL_INIT ///

Appl_Init	move.w	#10,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1
	
	move.w	([12,A1]),D0		; APP_ID
	
	RTS

; /// AES  11 : APPL_READ ///

Appl_Read	move.w	(16,SP),([8,A1])	; APP_ID dans Int_In0
	move.w	(14,SP),([8,A1],2)	; Longeur dans Int_In1
	move.l	(12,SP),([16,A1])	; Adresse dans Addr_In0

	move.w	#11,([A1])		; OpCode dans Control0
	move.w	#2,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1
	
	move.w	([12,A1]),D0		; R‚sultat

	RTS

; /// AES  12 : APPL_WRITE ///

Appl_Write	move.w	(16,SP),([8,A1])	; APP_ID dans Int_In0
	move.w	(14,SP),([8,A1],2)	; Longeur dans Int_In1
	move.l	(12,SP),([16,A1])	; Adresse dans Addr_In0

	move.w	#12,([A1])		; OpCode dans Control0
	move.w	#2,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  13 : APPL_FIND ///

Appl_Find	move.l	(12,SP),([16,A1])	; Adresse dans Addr_In0

	move.w	#13,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1
	
	move.w	([12,A1]),D0		; APP_ID

	RTS
	
; /// AES  14 : APPL_TPLAY ///

Appl_TPlay	move.w	(14,SP),([8,A1])	; Nombre dans Int_In0
	move.w	(12,SP),([8,A1],2)	; Vitesse dans Int_In1
	move.l	(16,SP),([16,A1])	; Adresse dans Addr_In0

	move.w	#14,([A1])		; OpCode dans Control0
	move.w	#2,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1
	
	RTS
	
; /// AES  15 : APPL_TRECORD ///

Appl_TRecord	move.w	(12,SP),([8,A1])	; Nombre dans Int_In0
	move.l	(14,SP),([16,A1])	; Adresse dans Addr_In0

	move.w	#15,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS

; /// AES  16 : Non D‚finit ///

UnDefAES16
	RTS

; /// AES  17 : Non D‚finit ///

UnDefAES17
	RTS
	
; /// AES  18 : APPL_SEARCH ///

Appl_Search	move.w	(16,SP),([8,A1])	; Mode dans Int_In0
	move.l	(12,SP),([16,A1])	; Adresse dans Addr_In0

	move.w	#18,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#3,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  19 : APPL_EXIT ///

Appl_Exit	move.w	#19,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1
	
	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  20 : EVNT_KEYBD ///

Evnt_KeyBd	move.w	#20,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Code de la touche

	RTS
	
; /// AES  21 : EVNT_BUTTON ///

Evnt_Button	move.w	(16,SP),([8,A1])	; Nombre dans Int_In0
	move.w	(14,SP),([8,A1],2)	; Masque dans Int_In1
	move.w	(12,SP),([8,A1],4)	; Statut dans Int_In2	

	move.w	#21,([A1])		; OpCode dans Control0
	move.w	#3,([A1],2)		; Control1
	move.w	#5,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	(12,A1),D0		; Int_Out

	RTS
	
; /// AES  22 : EVNT_MOUSE ///

Evnt_Mouse	move.w	(20,SP),([8,A1])	; Masque dans Int_In0
	move.w	(18,SP),([8,A1],2)	; X dans Int_In1
	move.w	(16,SP),([8,A1],4)	; Y dans Int_In2	
	move.w	(14,SP),([8,A1],6)	; Largeur dans Int_In3
	move.w	(12,SP),([8,A1],8)	; Hauteur dans Int_In4

	move.w	#22,([A1])		; OpCode dans Control0
	move.w	#5,([A1],2)		; Control1
	move.w	#5,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	(12,A1),D0		; Int_Out

	RTS
	
; /// AES  23 : EVNT_MESAG ///

Evnt_Mesag	move.l	(12,SP),([16,A1])	; Adresse dans Addr_In0

	move.w	#23,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// AES  24 : EVNT_TIMER ///

Evnt_Timer	move.w	(14,SP),([8,A1])	; Temps Bas dans Int_In0
	move.w	(12,SP),([8,A1],2)	; Temps Haut dans Int_In1

	move.w	#24,([A1])		; OpCode dans Control0
	move.w	#2,([A1],2)		; Control1
	move.w	#3,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// AES  25 : EVNT_MULTI ///

Evnt_Multi	move.w	(46,SP),([8,A1])	; Type dans Int_In0
	move.w	(44,SP),([8,A1],2)	; Nombre dans Int_In1
	move.w	(42,SP),([8,A1],4)	; Masque dans Int_In2
	move.w	(40,SP),([8,A1],6)	; Statut dans Int_In3
	move.w	(38,SP),([8,A1],8)	; Masque1 dans Int_In4
	move.w	(36,SP),([8,A1],10)	; X1 dans Int_In5
	move.w	(34,SP),([8,A1],12)	; Y1 dans Int_In6
	move.w	(32,SP),([8,A1],14)	; Largeur1 dans Int_In7
	move.w	(30,SP),([8,A1],16)	; Hauteur1 dans Int_In8
	move.w	(28,SP),([8,A1],18)	; Masque2 dans Int_In9
	move.w	(26,SP),([8,A1],20)	; X2 dans Int_In10
	move.w	(24,SP),([8,A1],22)	; Y2 dans Int_In11
	move.w	(22,SP),([8,A1],24)	; Largeur2 dans Int_In12
	move.w	(20,SP),([8,A1],26)	; Hauteur2 dans Int_In13
	move.w	(18,SP),([8,A1],28)	; Temps Bas dans Int_In14
	move.w	(16,SP),([8,A1],30)	; Temps Haut dans Int_In15
	move.l	(12,SP),([16,A1])	; Adresse dans Addr_In0

	move.w	#25,([A1])		; OpCode dans Control0
	move.w	#16,([A1],2)		; Control1
	move.w	#7,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	(12,A1),D0		; Int_Out

	RTS
	
; /// AES  26 : EVNT_DCLICK ///

Evnt_DClick	move.w	(14,SP),([8,A1])	; Vitesse dans Int_In0
	move.w	(12,SP),([8,A1],2)	; Mode dans Int_In1

	move.w	#26,([A1])		; OpCode dans Control0
	move.w	#2,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Vitesse

	RTS

; /// AES  27 : Non D‚finit ///

UnDefAES27
	RTS

; /// AES  28 : Non D‚finit ///

UnDefAES28
	RTS

; /// AES  29 : Non D‚finit ///

UnDefAES29
	RTS

; /// AES  30 : MENU_BAR ///

Menu_Bar	move.w	(12,SP),([8,A1])	; Mode dans Int_In0 
	move.l	(14,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#30,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  31 : MENU_ICHECK ///

Menu_ICheck	move.w	(14,SP),([8,A1])	; Num‚ro dans Int_In0
	move.w	(12,SP),([8,A1],2)	; Mode dans Int_In1
	move.l	(16,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#31,([A1])		; OpCode dans Control0
	move.w	#2,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  32 : MENU_IENABLE ///

Menu_IEnable	move.w	(14,SP),([8,A1])	; Num‚ro dans Int_In0
	move.w	(12,SP),([8,A1],2)	; Mode dans Int_In1
	move.l	(16,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#32,([A1])		; OpCode dans Control0
	move.w	#2,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  33 : MENU_TNORMAL ///

Menu_TNormal	move.w	(14,SP),([8,A1])	; Num‚ro dans Int_In0
	move.w	(12,SP),([8,A1],2)	; Mode dans Int_In1
	move.l	(16,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#33,([A1])		; OpCode dans Control0
	move.w	#2,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  34 : MENU_TEXT ///

Menu_Text	move.w	(16,SP),([8,A1])	; Num‚ro dans Int_In0
	move.l	(18,SP),([16,A1])	; Adresse dans Addr_In0
	move.l	(12,SP),([16,A1],4)	; Adresse du texte dans Addr_In1
	
	move.w	#34,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#2,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  35 : MENU_REGISTER ///

Menu_Register	move.w	(16,SP),([8,A1])	; Num‚ro dans Int_In0
	move.l	(12,SP),([16,A1])	; Adresse dans Addr_In0
		
	move.w	#35,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  36 : MENU_POPUP ///

Menu_PopUp	move.w	(18,SP),([8,A1])	; X dans Int_In0
	move.w	(16,SP),([8,A1],2)	; Y dans Int_In1
	move.l	(20,SP),([16,A1])	; Adresse dans Addr_In0
	move.l	(12,SP),([16,A1],4)	; Adresse des donn‚es dans Addr_In1
	
	move.w	#36,([A1])		; OpCode dans Control0
	move.w	#2,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#2,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  37 : MENU_ATTACH ///

Menu_Attach	move.w	(24,SP),([8,A1])	; Mode dans Int_In0
	move.l	(16,SP),([8,A1],2)	; Donn‚es dans Int_In1
	move.l	(20,SP),([16,A1])	; Adresse dans Addr_in0
	move.l	(12,SP),([16,A1],4)	; Adresse des donn‚es dans Addr_In1
	
	move.w	#37,([A1])		; OpCode dans Control0
	move.w	#2,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#2,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  38 : MENU_ISTART ///

Menu_IStart	move.w	(20,SP),([8,A1])	; Mode dans Int_In0
	move.w	(14,SP),([8,A1],2)	; Menu dans Int_In1
	move.w	(12,SP),([8,A1],4)	; Num‚ro dans Int_In2
	move.l	(16,SP),([16,SP])	; Adresse dans Addr_In0
	
	move.w	#38,([A1])		; OpCode dans Control0
	move.w	#3,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  39 : MENU_SETTING ///

Menu_Setting	move.w	(16,SP),([8,A1])	; Mode dans Int_In0
	move.l	(12,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#39,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  40 : OBJC_ADD ///

Objc_Add	move.w	(14,SP),([8,A1])	; Parent dans Int_In0
	move.w	(12,SP),([8,A1],2)	; Enfant dans Int_In1
	move.l	(16,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#40,([A1])		; OpCode dans Control0
	move.w	#2,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  41 : OBJC_DELETE ///

Objc_Delete	move.w	(12,SP),([8,A1])	; Num‚ro dans Int_In0
	move.l	(14,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#41,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  42 : OBJC_DRAW ///

Objc_Draw	move.w	(22,SP),([8,A1])	; Num‚ro dans Int_In0
	move.w	(20,SP),([8,A1],2)	; Profondeur dans Int_In1
	move.w	(18,SP),([8,A1],4)	; X dans Int_In2
	move.w	(16,SP),([8,A1],6)	; Y dans Int_In3
	move.w	(14,SP),([8,A1],8)	; Largeur dans Int_In4
	move.w	(12,SP),([8,A1],10)	; Hauteur dans Int_In5
	move.l	(24,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#42,([A1])		; OpCode dans Control0
	move.w	#6,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  43 : OBJC_FIND ///

Objc_Find	move.w	(18,SP),([8,A1])	; Num‚ro dans Int_In0
	move.w	(16,SP),([8,A1],2)	; Profondeur dans Int_In1
	move.w	(14,SP),([8,A1],4)	; X dans Int_In2
	move.w	(12,SP),([8,A1],6)	; Y dans Int_In3
	move.l	(20,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#43,([A1])		; OpCode dans Control0
	move.w	#4,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  44 : OBJC_OFFSET ///

Objc_OffSet	move.w	(12,SP),([8,A1])	; Num‚ro dans Int_In0
	move.l	(14,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#44,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#3,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat
	BEQ	Exit_AES44
	
	move.w	([12,A1],2),D0		; X
	swap	D0
	move.w	([12,A1],4),D0		; Y
	
Exit_AES44	RTS
	
; /// AES  45 : OBJC_ORDER ///

Objc_Order	move.w	(14,SP),([8,A1])	; Num‚ro dans Int_In0
	move.w	(12,SP),([8,A1],2)	; Position dans Int_In1
	move.l	(16,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#45,([A1])		; OpCode dans Control0
	move.w	#2,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  46 : OBJC_EDIT ///

Objc_Edit	move.w	(18,SP),([8,A1])	; Num‚ro dans Int_In0
	move.w	(16,SP),([8,A1],2)	; CaractŠre dans Int_In1
	move.w	(14,SP),([8,A1],4)	; Index dans Int_In2
	move.w	(12,SP),([8,A1],6)	; Mode dans Int_In3
	move.l	(20,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#46,([A1])		; OpCode dans Control0
	move.w	#4,([A1],2)		; Control1
	move.w	#2,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat
	BEQ	Exit_AES46
	
	move.w	([12,A1],2),D0	; Index

Exit_AES46	RTS
	
; /// AES  47 : OBJC_CHANGE ///

Objc_Change	move.w	(24,SP),([8,A1])	; Num‚ro dans Int_In0
	clr.w	([8,A1],2)		; 0 dans Int_In1
	move.w	(22,SP),([8,A1],4)	; X dans Int_In2
	move.w	(20,SP),([8,A1],6)	; Y dans Int_In3
	move.w	(18,SP),([8,A1],8)	; Largeur dans Int_In4
	move.w	(16,SP),([8,A1],10)	; Hauteur dans Int_In5
	move.w	(14,SP),([8,A1],12)	; Etat dans Int_In6
	move.w	(12,SP),([8,A1],14)	; Mode dans Int_In7
	move.l	(26,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#47,([A1])		; OpCode dans Control0
	move.w	#8,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  48 : OBJC_SYSVAR ///

Objc_SysVar	move.w	(18,SP),([8,A1])	; Mode dans Int_In0
	move.w	(16,SP),([8,A1],2)	; Num‚ro dans Int_In1
	move.w	(14,SP),([8,A1],4)	; Donn‚e1 dans Int_In2
	move.l	(12,SP),([8,A1],6)	; Donn‚e2 dans Int_In3
	
	move.w	#48,([A1])		; OpCode dans Control0
	move.w	#4,([A1],2)		; Control1
	move.w	#3,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS

; /// AES  49 : Non D‚finit ///

UnDefAES49
	RTS
	
; /// AES  50 : FORM_DO ///

Form_Do	move.w	(12,SP),([8,A1])	; Num‚ro dans Int_In0
	move.l	(14,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#50,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  51 : FORM_DIAL ///

Form_Dial	move.w	(28,SP),([8,A1])	; Num‚ro dans Int_In0
	move.w	(26,SP),([8,A1],2)	; X1 Position dans Int_In1
	move.w	(24,SP),([8,A1],4)	; Y1 dans Int_In2
	move.w	(22,SP),([8,A1],6)	; Largeur1 dans Int_In3
	move.w	(20,SP),([8,A1],8)	; Hauteur1 dans Int_In4
	move.w	(18,SP),([8,A1],10)	; X2 dans Int_In5
	move.w	(16,SP),([8,A1],12)	; Y2 dans Int_In6
	move.w	(14,SP),([8,A1],14)	; Largeur2 dans Int_In7
	move.w	(12,SP),([8,A1],16)	; Hauteur2 dans Int_In8
	
	move.w	#51,([A1])		; OpCode dans Control0
	move.w	#9,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  52 : FORM_ALERT ///

Form_Alert	move.w	(16,SP),([8,A1])	; Num‚ro du bouton dans Int_In0
	move.l	(12,SP),([16,A1])	; Adresse du texte dans Addr_In0
	
	move.w	#52,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  53 : FORM_ERROR ///

Form_Error	move.w	(12,SP),([8,A1])	; Num‚ro de l'erreur dans Int_In0
	
	move.w	#53,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  54 : FORM_CENTER ///

Form_Center	move.l	(12,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#54,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#5,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	(12,A1),D0		; Int_Out
	addq.l	#2,D0		; Int_Out1

	RTS
	
; /// AES  55 : FORM_KEYBD ///

Form_KeyBd	move.w	(16,SP),([8,A1])	; Num‚ro dans Int_In0
	move.w	(14,SP),([8,A1],2)	; Prochain Objet dans Int_In1
	move.w	(12,SP),([8,A1],4)	; CaractŠre dans Int_In2
	move.l	(18,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#55,([A1])		; OpCode dans Control0
	move.w	#3,([A1],2)		; Control1
	move.w	#3,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  56 : FORM_BUTTON ///

Form_Button	move.w	(14,SP),([8,A1])	; Num‚ro dans Int_In0
	move.w	(12,SP),([8,A1],2)	; Nombre de clics dans Int_In1
	move.l	(16,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#56,([A1])		; OpCode dans Control0
	move.w	#2,([A1],2)		; Control1
	move.w	#2,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  57 : SSX2FORM_DO V1.00, en cours de d‚veloppement ///

SSX2Form_Do	
	RTS

; /// AES  58 : SSFORM_PROCESS, en cours de d‚veloppement ///

SSForm_Process	
	RTS

; /// AES  59 : SSFORM_SOUND V1.08 ///

SSForm_Sound	tst.w	(12,SP)
	BEQ	Stop_DMA_Play
	move.w	(12,SP),D0
	cmpi.w	#2,D0
	BEQ	Exit_Sound

	BSR	Clr_SSAV_Wk1Buff	; On nettoie
	BSR	Define_CurrPath		; On devine o— l'on est
	BSR	Take_Path		; On complete
	
	move.l	(18,SP),A1
Copy_PRW_Name	move.b	(A1)+,(A0)+
	BNE	Copy_PRW_Name

	move.l	UnPacked_Data(PC),D0
	BEQ	UnFree_Next
	
	move.l	D0,-(SP)		; On libere le sample pr‚c‚dent
	move.w	#$49,-(SP)		; - M_FREE -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	
UnFree_Next	clr.w	-(SP)
	pea	SSAV_Wk1Buff(PC)
	move.w	#$3D,-(SP)		; - F_OPEN -
	trap	#1		; *** GEMDOS ***
	addq.l	#8,SP
	
	tst.w	D0
	BEQ	Form_Sound_Err
	move.w	D0,D7		; Handle
	
	move.w	#2,-(SP)		; Fin
	move.w	D0,-(SP)
	clr.l	-(SP)		; Fin du fichier
	move.w	#$42,-(SP)		; - F_SEEK -
	trap	#1		; *** GEMDOS ***
	lea	10(SP),SP
	move.l	D0,D6		; Taille

	clr.w	-(SP)		; D‚but
	move.w	D7,-(SP)
	clr.l	-(SP)		; D‚but du fichier
	move.w	#$42,-(SP)		; - F_SEEK -
	trap	#1		; *** GEMDOS ***
	lea	10(SP),SP

	clr.w	-(SP)		; ST-RAM
	move.l	D6,-(SP)		; Taille du fichier
	move.w	#$44,-(SP)		; - M_XALLOC -
	trap	#1		; *** GEMDOS ***
	addq.l	#8,SP
	tst.l	D0
	BEQ	Close_PRW_File
	
	lea	Packed_Data(PC),A6
	move.l	D0,(A6)
	move.l	D0,-(SP)		; Adresse du fichier
 	move.l	D6,-(SP)		; Taille du fichier
	move.w	D7,-(SP)		; Handle
	move.w	#$3F,-(SP)		; - F_READ -
	trap	#1		; *** GEMDOS ***
	lea	12(SP),SP
	
Close_PRW_File	move.w	D7,-(SP)
	move.w	#$3E,-(SP)		; - F_CLOSE -
	trap	#1		; *** GEMDOS ***
	addq.l	#4,SP

	move.l	Packed_Data(PC),D0	; Attention les yeux
	BEQ	Form_Sound_Err

	BSR	PRW_UnPack
	BSR	DMA_Play

	move.l	Packed_Data(PC),-(SP)	; On libere les donn‚es compact‚es
	move.w	#$49,-(SP)		; - M_FREE -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP

	clr.w	D0
	BRA	Form_Sound_Out

Form_Sound_Err	move.w	#-1,D0

Form_Sound_Out	RTS

PRW_UnPack	move.l	D0,A0
	movem.l	D0-A6,-(SP)
	BSR	Ice04		; Identificateur
	cmpi.l	#'Ice!',D0		; Compact‚?
	BNE	Ice03		; Non, alors sort...
	BSR	Ice04		; Taille compact‚
	lea	-8(A0,D0.l),A5
	BSR	Ice04		; Taille d‚compact‚
	move.l	D0,(SP)
	lea	UnPacked_Size(PC),A6
	move.l	D0,(A6)
	
	movem.l	D0/D2-A6,-(SP)
	
	clr.w	-(SP)		; ST-RAM
	move.l	D0,-(SP)		; Taille des donn‚es
	move.w	#$44,-(SP)		; - M_XALLOC -
	trap	#1		; *** GEMDOS ***
	addq.l	#8,SP
	move.l	D0,D1		; Car D0 d‚j… occup‚ par la taille d‚compact‚e
	
	movem.l	(SP)+,D0/D2-A6
	
	tst.l	D1
	BEQ	Ice03	
	lea	UnPacked_Data(PC),A6
	move.l	D1,(A6)
	movea.l	D1,A1
	movea.l	D1,A4		; D‚but d‚compact‚
	movea.l	D1,A6
	adda.l	D0,A6		; Fin d‚compact‚
	movea.l	A6,A3
	move.b	-(A5),D7
	BSR	Ice06
Ice03	movem.l	(SP)+,D0-A6
	RTS

Ice04	moveq	#3,D1
Ice05	lsl.l	#8,D0
	move.b	(A0)+,D0
	DBRA	D1,Ice05
	RTS

Ice06	BSR	Ice0A
	BCC	Ice09
	moveq	#0,D1
	BSR.s	Ice0A
	BCC	Ice08
	lea	Ice17(PC),A1
	moveq	#4,D3
Ice07	move.l	-(A1),D0
	BSR	Ice0C
	swap	D0
	cmp.w	D0,D1
	DBNE	D3,Ice07
	add.l	20(A1),D1
Ice08	move.b	-(A5),-(A6)
	DBRA	D1,Ice08
Ice09	cmpa.l	A4,A6
	BGT	Ice0F
	RTS

Ice0A	add.b	D7,D7
	BNE	Ice0B
	move.b	-(A5),D7
	addx.b	D7,D7
Ice0B	RTS

Ice0C	moveq	#0,D1
Ice0D	add.b	D7,D7
	BNE	Ice0E
	move.b	-(A5),D7
	addx.b	D7,D7
Ice0E	addx.w	D1,D1
	DBRA	D0,Ice0D
	RTS

Ice0F	lea	Ice18(PC),A1
	moveq	#3,D2
Ice10	BSR	Ice0A
	DBCC	D2,Ice10
	moveq	#0,D4
	moveq	#0,D1
	move.b	1(A1,D2.w),D0
	ext.w	D0
	BMI	Ice11
	BSR	Ice0C
Ice11	move.b	6(A1,D2.w),D4
	add.w	D1,D4
	BEQ	Ice13
	lea	Ice19(PC),A1
	moveq	#1,D2
Ice12	BSR	Ice0A
	DBCC	D2,Ice12
	moveq	#0,D1
	move.b	1(A1,D2.w),D0
	ext.w	D0
	BSR	Ice0C
	add.w	D2,D2
	add.w	6(A1,D2.w),D1
	BPL	Ice15
	sub.w	D4,D1
	BRA	Ice15
Ice13	moveq	#0,D1
	moveq	#5,D0
	moveq	#-1,D2
	BSR	Ice0A
	BCC	Ice14
	moveq	#8,D0
	moveq	#$3f,D2
Ice14	BSR	Ice0C
	add.w	D2,D1
Ice15	lea	2(A6,D4.w),A1
	adda.w	D1,A1
	move.b	-(A1),-(A6)
Ice16	move.b	-(A1),-(A6)
	DBRA	D4,Ice16
	BRA	Ice06
	DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
	DC.B $00,$07,$00,$02,$00,$03,$00,$01
	DC.B $00,$03,$00,$01
Ice17	DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
	DC.B $00,$00,$00,$07,$00,$00,$00,$04
	DC.B $00,$00,$00,$01
Ice18	DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
	DC.B $01,$00
Ice19	DC.B $0b,$04,$07,$00,$01,$1f,$ff,$ff
	DC.B $00,$1f

DMA_Play	clr.l	-(SP)
	move.w	#$20,-(SP)		; - SUPER -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	move.l	D0,D6

	move.l	UnPacked_Data(PC),D0
	move.l	D0,D2		; Pour la lib‚ration
	move.l	UnPacked_Size(PC),D1
	add.l	D0,D1
	addq.l	#1,D1
	andi.l	#-2,D1
	swap	D0
	swap	D1
	move.b	D0,$FFFF8903.w
	move.b	D1,$FFFF890F.w
	rol.l	#8,D0
	rol.l	#8,D1
	move.b	D0,$FFFF8905.w
	move.b	D1,$FFFF8911.w
	rol.l	#8,D0
	rol.l	#8,D1
	move.b	D0,$FFFF8907.w
	move.b	D1,$FFFF8913.w

	move.w	#%10000010,$FFFF8920.w	; Init. DMA
	move.w	(16,SP),$FFFF8900.w	; Run DMA

	move.l	D6,-(SP)
	move.w	#$20,-(SP)		; - SUPER -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP

	RTS

Stop_DMA_Play	clr.l	-(SP)
	move.w	#$20,-(SP)		; - SUPER -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	move.l	D0,D6

	clr.w	$FFFF8900.w		; On coupe tout

	move.l	D6,-(SP)
	move.w	#$20,-(SP)		; - SUPER -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP

	RTS

Exit_Sound	move.l	UnPacked_Data(PC),-(SP)
	move.w	#$49,-(SP)		; - M_FREE -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	
	lea	UnPacked_Data(PC),A6
	clr.l	(A6)
	
	RTS

Define_CurrPath	move.w	#$19,-(SP)		; - D_GETDRV -
	trap	#1		; *** GEMDOS ***
	addq.l	#2,SP

	lea	SSAV_Wk1Buff(PC),A0
	move.w	D0,D1
	add.w	#65,D0
	addq.w	#1,D1
	move.b	D0,(A0)+
	move.b	#58,(A0)+

	move.w	D1,-(SP)
	move.l	A0,-(SP)
	move.w	#$47,-(SP)		; - D_GETPATH -
	trap	#1		; *** GEMDOS ***
	addq.l	#8,SP
	
	RTS
	
Take_Path	lea	SSAV_Wk1Buff(PC),A0
Search_Null	addq.l	#1,A0
	move.b	(A0),D0
	BNE	Search_Null
	
	move.b	#92,(A0)+		; \

	RTS
	
Clr_SSAV_Wk1Buff	lea	SSAV_Wk1Buff(PC),A0
	move.w	#63,D0
Clr_Path	clr.l	(A0)+
	DBF	D0,Clr_Path
	
	RTS

Packed_Data	ds.l	1		; Adresse des donn‚es
UnPacked_Data	ds.l	1		; Adresse du sample
UnPacked_Size	ds.l	1		; Taille

; /// AES  60 : CONV_DISPNUM, en cours de d‚veloppement ///

Conv_DispNum	include	FLOASSAV.SSM

; /// AES  61 : CONV_RSC2WK, en cours de d‚veloppement ///

Conv_Rsc2Wk	
	RTS
	
; /// AES  62 : CONV_RSC2LANG, en cours de d‚veloppement ///

Conv_Rsc2Lang	
	RTS

; /// AES  63 : CONV_COLORPIC, en cours de d‚veloppement ///

Conv_ColorPic	
	RTS

; /// AES  64 : Non D‚finit ///

UnDefAES64
	RTS

; /// AES  65 : Non D‚finit ///

UnDefAES65
	RTS

; /// AES  66 : Non D‚finit ///

UnDefAES66
	RTS

; /// AES  67 : Non D‚finit ///

UnDefAES67
	RTS

; /// AES  68 : Non D‚finit ///

UnDefAES68
	RTS

; /// AES  69 : Non D‚finit ///

UnDefAES69
	RTS
	
; /// AES  70 : GRAF_RUBBERBOX ///

Graf_RubberBox	move.w	(18,SP),([8,A1])	; X dans Int_In0
	move.w	(16,SP),([8,A1],2)	; Y dans Int_In1
	move.w	(14,SP),([8,A1],4)	; Largeur dans Int_In2
	move.w	(12,SP),([8,A1],6)	; Hauteur dans Int_In3
	
	move.w	#70,([A1])		; OpCode dans Control0
	move.w	#4,([A1],2)		; Control1
	move.w	#3,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat
	BEQ	Exit_AES70
	
	move.l	([12,A1],2),D0		; Largeur - Hauteur

Exit_AES70	RTS
	
; /// AES  71 : GRAF_DRAGBOX ///

Graf_DragBox	move.w	(26,SP),([8,A1])	; Largeur de la boite dans Int_In0
	move.w	(24,SP),([8,A1],2)	; Hauteur de la boite dans Int_In1
	move.w	(22,SP),([8,A1],4)	; X de la boite dans Int_In2
	move.w	(20,SP),([8,A1],6)	; Y de la boite dans Int_In3
	move.w	(18,SP),([8,A1],8)	; X du rectangle dans Int_In4
	move.w	(16,SP),([8,A1],10)	; Y du rectangle dans Int_In5
	move.w	(14,SP),([8,A1],12)	; Largeur du rectangle dans Int_In6
	move.w	(12,SP),([8,A1],14)	; Hauteur du rectangle dans Int_In7
	
	move.w	#71,([A1])		; OpCode dans Control0
	move.w	#8,([A1],2)		; Control1
	move.w	#3,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat
	BEQ	Exit_AES71
	
	move.w	([12,A1],2),D0	; X
	swap	D0
	move.w	([12,A1],4),D0	; Y

Exit_AES71	RTS
	
; /// AES  72 : GRAF_MOVEBOX ///

Graf_MoveBox	move.w	(22,SP),([8,A1])	; Largeur dans Int_In0
	move.w	(20,SP),([8,A1],2)	; Hauteur dans Int_In1
	move.w	(18,SP),([8,A1],4)	; X D‚part dans Int_In2
	move.w	(16,SP),([8,A1],6)	; Y D‚part dans Int_In3
	move.w	(14,SP),([8,A1],8)	; X Fin dans Int_In4
	move.w	(12,SP),([8,A1],10)	; Y Fin dans Int_In5
	
	move.w	#72,([A1])		; OpCode dans Control0
	move.w	#6,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  73 : GRAF_GROWBOX ///

Graf_GrowBox	move.w	(26,SP),([8,A1])	; X D‚part dans Int_In0
	move.w	(24,SP),([8,A1],2)	; Y D‚part dans Int_In1
	move.w	(22,SP),([8,A1],4)	; Largeur D‚part dans Int_In2
	move.w	(20,SP),([8,A1],6)	; Hauteur D‚part dans Int_In3
	move.w	(18,SP),([8,A1],8)	; X Fin dans Int_In4
	move.w	(16,SP),([8,A1],10)	; Y Fin dans Int_In5
	move.w	(14,SP),([8,A1],12)	; Largeur Fin dans Int_In6
	move.w	(12,SP),([8,A1],14)	; Hauteur Fin dans Int_In7
	
	move.w	#73,([A1])		; OpCode dans Control0
	move.w	#8,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  74 : GRAF_SHRINKBOX ///

Graf_ShrinkBox	move.w	(26,SP),([8,A1])	; X Fin dans Int_In0
	move.w	(24,SP),([8,A1],2)	; Y Fin dans Int_In1
	move.w	(22,SP),([8,A1],4)	; Largeur Fin dans Int_In2
	move.w	(20,SP),([8,A1],6)	; Hauteur Fin dans Int_In3
	move.w	(18,SP),([8,A1],8)	; X D‚part dans Int_In4
	move.w	(16,SP),([8,A1],10)	; Y D‚part dans Int_In5
	move.w	(14,SP),([8,A1],12)	; Largeur D‚part dans Int_In6
	move.w	(12,SP),([8,A1],14)	; Hauteur D‚part dans Int_In7
	
	move.w	#74,([A1])		; OpCode dans Control0
	move.w	#8,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  75 : GRAF_WATCHBOX ///

Graf_WatchBox	clr.w	([8,A1])		; 0 dans Int_In0
	move.w	(16,SP),([8,A1],2)	; Num‚ro dans Int_In1
	move.w	(14,SP),([8,A1],4)	; Aspect Interne dans Int_In2
	move.w	(12,SP),([8,A1],6)	; Aspect Externe dans Int_In3
	move.l	(18,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#75,([A1])		; OpCode dans Control0
	move.w	#4,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  76 : GRAF_SLIDEBOX ///

Graf_SlideBox	move.w	(16,SP),([8,A1])	; Parent dans Int_In0
	move.w	(14,SP),([8,A1],2)	; Num‚ro dans Int_In1
	move.w	(12,SP),([8,A1],4)	; Direction dans Int_In2
	move.l	(18,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#76,([A1])		; OpCode dans Control0
	move.w	#3,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat
	
	tst.w	([12,A1],4)		; Mode
	BEQ	Exit_AES76

	ori.w	#%1000000000000000,D0

Exit_AES76	RTS
	
; /// AES  77 : GRAF_HANDLE ///

Graf_Handle	move.w	#77,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#5,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	(12,A1),D0		; Int_Out

	RTS
	
; /// AES  78 : GRAF_MOUSE ///

Graf_Mouse	move.w	(16,SP),([8,A1])	; Mode dans Int_In0
	move.l	(12,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#78,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  79 : GRAF_MKSTATE ///

Graf_MkState	move.w	#79,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#5,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	(12,A1),D0		; Int_Out

	RTS
	
; /// AES  80 : SCRP_READ ///

Scrp_Read	move.l	(12,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#80,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  81 : SCRP_WRITE ///

Scrp_Write	move.l	(12,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#81,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES  82 : Non D‚finit ///

UnDefAES82
	RTS

; /// AES  83 : Non D‚finit ///

UnDefAES83
	RTS

; /// AES  84 : Non D‚finit ///

UnDefAES84
	RTS

; /// AES  85 : Non D‚finit ///

UnDefAES85
	RTS

; /// AES  86 : Non D‚finit ///

UnDefAES86
	RTS

; /// AES  87 : Non D‚finit ///

UnDefAES87
	RTS

; /// AES  88 : Non D‚finit ///

UnDefAES88
	RTS

; /// AES  89 : Non D‚finit ///

UnDefAES89
	RTS

; /// AES  90 : FSEL_INPUT ///

FSel_Input	move.l	(16,SP),([16,A1])	; Adresse du R‚pertoire dans Addr_In0
	move.l	(12,SP),([16,A1],4)	; Adresse du Fichier dans Addr_In1
	
	move.w	#90,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#2,([A1],4)		; Control2
	move.w	#2,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat
	BEQ	Exit_AES90
	
	swap	D0
	move.w	([12,A1],2),D0		; Bouton
	swap	D0

Exit_AES90	RTS
	
; /// AES  91 : FSEL_EXINPUT ///

FSel_ExInput	move.l	(20,SP),([16,A1])	; Adresse du R‚pertoire dans Addr_In0
	move.l	(16,SP),([16,A1],4)	; Adresse du Fichier dans Addr_In0
	move.l	(12,SP),([16,A1],8)	; Adresse du Titre dans Addr_In0
	
	move.w	#91,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#2,([A1],4)		; Control2
	move.w	#3,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat
	BEQ	Exit_AES91
	
	move.w	([12,A1],2),D0		; Bouton

Exit_AES91	RTS
	
; /// AES  92 : Non D‚finit ///

UnDefAES92
	RTS

; /// AES  93 : Non D‚finit ///

UnDefAES93
	RTS

; /// AES  94 : Non D‚finit ///

UnDefAES94
	RTS

; /// AES  95 : Non D‚finit ///

UnDefAES95
	RTS

; /// AES  96 : Non D‚finit ///

UnDefAES96
	RTS

; /// AES  97 : Non D‚finit ///

UnDefAES97
	RTS

; /// AES  98 : Non D‚finit ///

UnDefAES98
	RTS

; /// AES  99 : Non D‚finit ///

UnDefAES99
	RTS

; /// AES 100 : WIND_CREATE ///

Wind_Create	move.w	(20,SP),([8,A1])	; Mode dans Int_In0
	move.w	(18,SP),([8,A1],2)	; X dans Int_In1
	move.w	(16,SP),([8,A1],4)	; Y dans Int_In2
	move.w	(14,SP),([8,A1],6)	; Largeur dans Int_In3
	move.w	(12,SP),([8,A1],8)	; Hauteur dans Int_In4
	
	move.w	#100,([A1])		; OpCode dans Control0
	move.w	#5,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES 101 : WIND_OPEN ///

Wind_Open	move.w	(20,SP),([8,A1])	; Handle dans Int_In0
	move.w	(18,SP),([8,A1],2)	; X dans Int_In1
	move.w	(16,SP),([8,A1],4)	; Y dans Int_In2
	move.w	(14,SP),([8,A1],6)	; Largeur dans Int_In3
	move.w	(12,SP),([8,A1],8)	; Hauteur dans Int_In4
	
	move.w	#101,([A1])		; OpCode dans Control0
	move.w	#5,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES 102 : WIND_CLOSE ///

Wind_Close	move.w	(12,SP),([8,A1])	; Handle dans Int_In0
	
	move.w	#102,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES 103 : WIND_DELETE ///

Wind_Delete	move.w	(12,SP),([8,A1])	; Handle dans Int_In0
	
	move.w	#103,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES 104 : WIND_GET ///

Wind_Get	move.w	(14,SP),([8,A1])	; Handle dans Int_In0
	move.w	(12,SP),([8,A1],2)	; Commande dans Int_In1
	
	move.w	#104,([A1])		; OpCode dans Control0
	move.w	#6,([A1],2)		; Control1
	move.w	#5,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat
	BEQ	Exit_AES104
	
	move.l	(12,A1),D0		; Int_Out
	addq.l	#2,D0		; Int_Out1

Exit_AES104	RTS
	
; /// AES 105 : WIND_SET ///

Wind_Set	move.w	(22,SP),([8,A1])	; Handle dans Int_In0
	move.w	(20,SP),([8,A1],2)	; Commande dans Int_In1
	move.w	(18,SP),([8,A1],4)	; In1 dans Int_In2
	move.w	(16,SP),([8,A1],6)	; In2 dans Int_In3
	move.w	(14,SP),([8,A1],8)	; In3 dans Int_In4
	move.w	(12,SP),([8,A1],10)	; In4 dans Int_In5

	move.w	#105,([A1])		; OpCode dans Control0
	move.w	#6,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES 106 : WIND_FIND ///

Wind_Find	move.w	(14,SP),([8,A1])	; X dans Int_In0
	move.w	(12,SP),([8,A1],2)	; Y dans Int_In1
	
	move.w	#106,([A1])		; OpCode dans Control0
	move.w	#2,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES 107 : WIND_UPDATE ///

Wind_UpDate	move.w	(14,SP),([8,A1])	; Commande dans Int_In0
	
	move.w	#107,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES 108 : WIND_CALC ///

Wind_Calc	move.w	(22,SP),([8,A1])	; Commande dans Int_In0
	move.w	(20,SP),([8,A1],2)	; Mode dans Int_In1
	move.w	(18,SP),([8,A1],4)	; X D‚part dans Int_In2
	move.w	(16,SP),([8,A1],6)	; Y D‚part dans Int_In3
	move.w	(14,SP),([8,A1],8)	; Largeur D‚part dans Int_In4
	move.w	(12,SP),([8,A1],10)	; Hauteur D‚part dans Int_In5
	
	move.w	#108,([A1])		; OpCode dans Control0
	move.w	#6,([A1],2)		; Control1
	move.w	#5,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat
	BEQ	Exit_AES108
	
	move.l	(12,A1),D0		; Int_Out
	addq.l	#2,D0		; Int_Out1

Exit_AES108	RTS
	
; /// AES 109 : WIND_NEW ///

Wind_New	move.w	#109,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	clr.w	([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// AES 110 : RSRC_LOAD ///

Rsrc_Load	move.l	(12,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#110,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES 111 : RSRC_FREE ///

Rsrc_Free	move.w	#111,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES 112 : RSRC_GADDR ///

Rsrc_GAddr	move.w	(14,SP),([8,A1])	; Mode dans Int_In0
	move.w	(12,SP),([8,A1],2)	; Num‚ro dans Int_In1
	
	move.w	#112,([A1])		; OpCode dans Control0
	move.w	#2,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	move.w	#1,([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat
	BEQ	Exit_AES112
	
	move.l	([20,A1]),D0		; Adresse

Exit_AES112	RTS
	
; /// AES 113 : RSRC_SADDR ///

Rsrc_SAddr	move.w	(18,SP),([8,A1])	; Mode dans Int_In0
	move.w	(16,SP),([8,A1],2)	; Num‚ro dans Int_In1
	move.l	(12,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#113,([A1])		; OpCode dans Control0
	move.w	#2,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES 114 : RSRC_OBFIX ///

Rsrc_ObFix	move.w	(12,SP),([8,A1])	; Num‚ro dans Int_In0
	move.l	(16,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#114,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// AES 115 : RSRC_RCFIX ///

Rsrc_RcFix	move.l	(12,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#115,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES 116 : Non D‚finit ///

UnDefAES116	
	RTS

; /// AES 117 : Non D‚finit ///

UnDefAES117	
	RTS

; /// AES 118 : Non D‚finit ///

UnDefAES118	
	RTS

; /// AES 119 : Non D‚finit ///

UnDefAES119	
	RTS

; /// AES 120 : SHEL_READ ///

Shel_Read	move.l	(16,SP),([16,A1])	; Adresse de la Commande dans Addr_In0
	move.l	(12,SP),([16,A1],4)	; Adresse de la Commande Supl‚mentaire dans Addr_In1
	
	move.w	#45,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#2,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES 121 : SHEL_WRITE ///

Shel_Write	move.w	(24,SP),([8,A1])	; Commande dans Int_In0
	move.w	(22,SP),([8,A1],2)	; Type dans Int_In1
	move.w	(20,SP),([8,A1],4)	; Mode dans Int_In2
	move.l	(16,SP),([16,A1])	; Adresse de la Commande dans Addr_In0
	move.l	(12,SP),([16,A1],4)	; Adresse de la Commande Supl‚mentaire dans Addr_In1

	move.w	#121,([A1])		; OpCode dans Control0
	move.w	#3,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#2,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES 122 : SHEL_GET ///

Shel_Get	move.w	(12,SP),([8,A1])	; Nombre dans Int_In0
	move.l	(14,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#122,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES 123 : SHEL_PUT ///

Shel_Put	move.w	(12,SP),([8,A1])	; Nombre dans Int_In0
	move.l	(14,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#123,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES 124 : SHEL_FIND ///

Shel_Find	move.l	(16,SP),([16,A1])	; Adresse dans Addr_In0
	
	move.w	#124,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#1,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// AES 125 : SHEL_ENVRN ///

Shel_Envrn	move.l	(16,SP),([16,A1])	; Adresse dans Addr_In0
	move.l	(12,SP),([16,A1],4)	; Adresse du Texte recherch‚ dans Addr_In0
	
	move.w	#125,([A1])		; OpCode dans Control0
	clr.w	([A1],2)		; Control1
	move.w	#1,([A1],4)		; Control2
	move.w	#3,([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// AES 126 : Non D‚finit ///

UnDefAES126
	RTS

; /// AES 127 : Non D‚finit ///

UnDefAES127
	RTS

; /// AES 128 : Non D‚finit ///

UnDefAES128
	RTS

; /// AES 129 : Non D‚finit ///

UnDefAES129
	RTS

; /// AES 130 : APPL_GETINFO ///

Appl_GetInfo	move.w	(12,SP),([8,A1])	; Type dans Int_In0
	
	move.w	#130,([A1])		; OpCode dans Control0
	move.w	#1,([A1],2)		; Control1
	move.w	#5,([A1],4)		; Control2
	clr.w	([A1],6)		; Control3
	clr.w	([A1],8)		; Control4

	move.w	#200,D0
	move.l	(8,SP),D1		; AES_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS

; /// AES 131 : APPL_MEMORY, en cours de d‚veloppement ///

Appl_Memory
	RTS
	
; *** GESTION DU VDI ***

VDI_CONTROL	move.w	(6,SP),D0
	cmpi.w	#255,D0
	BGT	VDI_ERROR		; Au dessus de VDI 255, y'a rien (sauf VDI -1)
	move.l	(8,SP),A1		; VDI_PARAMS
	lea	VDI_JUMP(PC),A2		; Le fun...
	JMP	(A2,D0.w*4)

VDI_ERROR	cmpi.w	#-1,D0
	BEQ	V_Set_App_Buff
	RTS

	BRA	V_Set_App_Buff		; VDI -1
VDI_JUMP	BRA	UnDefVDI0
	BRA	V_OpnWk		; VDI   1
	BRA	V_ClsWk		; VDI   2
	BRA	V_ClrWk		; VDI   3
	BRA	V_UpdWk		; VDI   4
	BRA	V_Escape		; VDI   5
	BRA	V_Pline		; VDI   6
	BRA	V_PMarker		; VDI   7
	BRA	V_GText		; VDI   8
	BRA	V_FillArea		; VDI   9
	BRA	V_CellArray		; VDI  10
	BRA	V_GDP		; VDI  11
	BRA	Vst_Heigh		; VDI  12
	BRA	Vst_Rotation		; VDI  13
	BRA	Vs_Color		; VDI  14
	BRA	Vsl_Type		; VDI  15
	BRA	Vsl_Width		; VDI  16
	BRA	Vsl_Color		; VDI  17
	BRA	Vsm_Type		; VDI  18
	BRA	Vsm_Height		; VDI  19
	BRA	Vsm_Color		; VDI  20
	BRA	Vst_Font		; VDI  21
	BRA	Vst_Color		; VDI  22
	BRA	Vsf_Interior		; VDI  23
	BRA	Vsf_Style		; VDI  24
	BRA	Vsf_Color		; VDI  25
	BRA	Vq_Color		; VDI  26
	BRA	Vqt_Array		; VDI  27
	BRA	Vrq_Locator		; VDI  28
	BRA	Vrq_Valuator		; VDI  29
	BRA	Vrq_Choice		; VDI  30
	BRA	Vrq_String		; VDI  31
	BRA	Vswr_Mode		; VDI  32
	BRA	VSin_Mode		; VDI  33
	BRA	UnDefVDI34
	BRA	Vql_Attributes		; VDI  35
	BRA	Vqm_Attributes		; VDI  36
	BRA	Vqf_Attributes		; VDI  37
	BRA	Vqt_Attributes		; VDI  38
	BRA	Vst_Alignment		; VDI  39
	BRA	UnDefVDI40
	BRA	UnDefVDI41
	BRA	UnDefVDI42
	BRA	UnDefVDI43
	BRA	UnDefVDI44
	BRA	UnDefVDI45
	BRA	UnDefVDI46
	BRA	UnDefVDI47
	BRA	UnDefVDI48
	BRA	UnDefVDI49
	BRA	UnDefVDI50
	BRA	UnDefVDI51
	BRA	UnDefVDI52
	BRA	UnDefVDI53
	BRA	UnDefVDI54
	BRA	UnDefVDI55
	BRA	UnDefVDI56
	BRA	UnDefVDI57
	BRA	UnDefVDI58
	BRA	UnDefVDI59
	BRA	UnDefVDI60
	BRA	UnDefVDI61
	BRA	UnDefVDI62
	BRA	UnDefVDI63
	BRA	UnDefVDI64
	BRA	UnDefVDI65
	BRA	UnDefVDI66
	BRA	UnDefVDI67
	BRA	UnDefVDI68
	BRA	UnDefVDI69
	BRA	UnDefVDI70
	BRA	UnDefVDI71
	BRA	UnDefVDI72
	BRA	UnDefVDI73
	BRA	UnDefVDI74
	BRA	UnDefVDI75
	BRA	UnDefVDI76
	BRA	UnDefVDI77
	BRA	UnDefVDI78
	BRA	UnDefVDI79
	BRA	UnDefVDI80
	BRA	UnDefVDI81
	BRA	UnDefVDI82
	BRA	UnDefVDI83
	BRA	UnDefVDI84
	BRA	UnDefVDI85
	BRA	UnDefVDI86
	BRA	UnDefVDI87
	BRA	UnDefVDI88
	BRA	UnDefVDI89
	BRA	UnDefVDI90
	BRA	UnDefVDI91
	BRA	UnDefVDI92
	BRA	UnDefVDI93
	BRA	UnDefVDI94
	BRA	UnDefVDI95
	BRA	UnDefVDI96
	BRA	UnDefVDI97
	BRA	UnDefVDI98
	BRA	UnDefVDI99
	BRA	V_OpnVWk		; VDI 100
	BRA	V_ClsVWk		; VDI 101
	BRA	Vq_Extnd		; VDI 102
	BRA	V_ContourFill		; VDI 103
	BRA	Vsf_Perimeter		; VDI 104	
	BRA	V_Get_Pixel		; VDI 105
	BRA	Vst_Effects		; VDI 106
	BRA	Vst_Point		; VDI 107
	BRA	Vsl_Ends		; VDI 108
	BRA	Vro_CpyFm		; VDI 109
	BRA	Vr_TrnFm		; VDI 110
	BRA	Vsc_Form		; VDI 111
	BRA	Vsf_UDPat		; VDI 112
	BRA	Vsl_UDSty		; VDI 113
	BRA	Vr_RectFl		; VDI 114
	BRA	UnDefVDI115
	BRA	Vqt_Extent		; VDI 116
	BRA	Vqt_Width		; VDI 117
	BRA	Vex_Timv		; VDI 118
	BRA	Vst_Load_Fonts		; VDI 119
	BRA	Vst_UnLoad_Fonts	; VDI 120
	BRA	Vrt_CpyFm		; VDI 121
	BRA	V_Show_C		; VDI 122
	BRA	V_Hide_C		; VDI 123
	BRA	Vq_Mouse		; VDI 124
	BRA	Vex_ButV		; VDI 125
	BRA	Vex_MotV		; VDI 126
	BRA	Vex_CurV		; VDI 127
	BRA	Vq_Key_S		; VDI 128
	BRA	Vs_Clip		; VDI 129
	BRA	Vqt_Name		; VDI 130
	BRA	Vqt_FontInfo		; VDI 131
	BRA	UnDefVDI132
	BRA	UnDefVDI133
	BRA	UnDefVDI134
	BRA	UnDefVDI135
	BRA	UnDefVDI136
	BRA	UnDefVDI137
	BRA	UnDefVDI138
	BRA	UnDefVDI139
	BRA	UnDefVDI140
	BRA	UnDefVDI141
	BRA	UnDefVDI142
	BRA	UnDefVDI143
	BRA	UnDefVDI144
	BRA	UnDefVDI145
	BRA	UnDefVDI146
	BRA	UnDefVDI147
	BRA	UnDefVDI148
	BRA	UnDefVDI149
	BRA	UnDefVDI150
	BRA	UnDefVDI151
	BRA	UnDefVDI152
	BRA	UnDefVDI153
	BRA	UnDefVDI154
	BRA	UnDefVDI155
	BRA	UnDefVDI156
	BRA	UnDefVDI157
	BRA	UnDefVDI158
	BRA	UnDefVDI159
	BRA	UnDefVDI160
	BRA	UnDefVDI161
	BRA	UnDefVDI162
	BRA	UnDefVDI163
	BRA	UnDefVDI164
	BRA	UnDefVDI165
	BRA	UnDefVDI166
	BRA	UnDefVDI167
	BRA	UnDefVDI168
	BRA	UnDefVDI169
	BRA	UnDefVDI170
	BRA	UnDefVDI171
	BRA	UnDefVDI172
	BRA	UnDefVDI173
	BRA	UnDefVDI174
	BRA	UnDefVDI175
	BRA	UnDefVDI176
	BRA	UnDefVDI177
	BRA	UnDefVDI178
	BRA	UnDefVDI179
	BRA	UnDefVDI180
	BRA	UnDefVDI181
	BRA	UnDefVDI182
	BRA	UnDefVDI183
	BRA	UnDefVDI184
	BRA	UnDefVDI185
	BRA	UnDefVDI186
	BRA	UnDefVDI187
	BRA	UnDefVDI188
	BRA	UnDefVDI189
	BRA	UnDefVDI190
	BRA	UnDefVDI191
	BRA	UnDefVDI192
	BRA	UnDefVDI193
	BRA	UnDefVDI194
	BRA	UnDefVDI195
	BRA	UnDefVDI196
	BRA	UnDefVDI197
	BRA	UnDefVDI198
	BRA	UnDefVDI199
	BRA	UnDefVDI200
	BRA	UnDefVDI201
	BRA	UnDefVDI202
	BRA	UnDefVDI203
	BRA	UnDefVDI204
	BRA	UnDefVDI205
	BRA	UnDefVDI206
	BRA	UnDefVDI207
	BRA	UnDefVDI208
	BRA	UnDefVDI209
	BRA	UnDefVDI210
	BRA	UnDefVDI211
	BRA	UnDefVDI212
	BRA	UnDefVDI213
	BRA	UnDefVDI214
	BRA	UnDefVDI215
	BRA	UnDefVDI216
	BRA	UnDefVDI217
	BRA	UnDefVDI218
	BRA	UnDefVDI219
	BRA	UnDefVDI220
	BRA	UnDefVDI221
	BRA	UnDefVDI222
	BRA	UnDefVDI223
	BRA	UnDefVDI224
	BRA	UnDefVDI225
	BRA	UnDefVDI226
	BRA	UnDefVDI227
	BRA	UnDefVDI228
	BRA	UnDefVDI229
	BRA	UnDefVDI230
	BRA	UnDefVDI231
	BRA	Vqt_FontHeader		; VDI 232
	BRA	UnDefVDI233
	BRA	Vqt_TrackKern		; VDI 234
	BRA	Vqt_PairKern		; VDI 235
	BRA	Vst_CharMap		; VDI 236
	BRA	Vst_Kern		; VDI 237
	BRA	UnDefVDI238 
	BRA	V_GetBitMap_Info	; VDI 239
	BRA	Vqt_F_Extent		; VDI 240
	BRA	V_FText		; VDI 241
	BRA	V_FText_OffSet		; VDI 242
	BRA	V_GetOutLine		; VDI 243
	BRA	Vst_Scratch		; VDI 244
	BRA	Vst_Error		; VDI 245
	BRA	Vst_ArbPt		; VDI 246
	BRA	Vqt_Advance		; VDI 247
	BRA	Vqt_DevInfo		; VDI 248
	BRA	V_SaveCache		; VDI 249
	BRA	V_LoadCache		; VDI 250
	BRA	V_FlushCache		; VDI 251
	BRA	Vst_SetSize		; VDI 252
	BRA	Vst_Skew		; VDI 253
	BRA	Vqt_Get_Table		; VDI 254
	BRA	Vqt_CacheSize		; VDI 255

; /// VDI   0 : Non D‚finit ///

UnDefVDI0
	RTS

; /// VDI   1 : V_OPNWK (OPEN WORKSTATION) ///

V_OpnWk	move.w	(32,SP),([4,A1])	; Num‚ro P‚riph‚rique dans IntIn0
	move.w	(30,SP),([4,A1],2)	; Type de Ligne dans IntIn1
	move.w	(28,SP),([4,A1],4)	; Index Ligne dans IntIn2
	move.w	(26,SP),([4,A1],6)	; Type de RepŠre dans IntIn3
	move.w	(24,SP),([4,A1],8)	; Index RepŠre dans IntIn4
	move.w	(22,SP),([4,A1],10)	; Fonte dans IntIn5
	move.w	(20,SP),([4,A1],12)	; Index Texte dans IntIn6
	move.w	(18,SP),([4,A1],14)	; Style dans IntIn7
	move.w	(16,SP),([4,A1],16)	; Index Style dans IntIn8
	move.w	(14,SP),([4,A1],18)	; Index Couleur dans IntIn9
	move.w	(12,SP),([4,A1],20)	; SystŠme dans IntIn10

	move.w	#1,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	move.w	#6,([A1],4)		; Contrl2
	move.w	#11,([A1],6)		; Contrl3
	move.w	#45,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([A1],12),D0		; Handle
	move.l	(12,A1),D1		; IntOut
	move.l	(16,A1),D2		; PtsOut

	RTS
	
; /// VDI   2 : V_CLSWK (CLOSE WORKSTATION) ///

V_ClsWk	move.w	(12,SP),([A1],12)	; Handle dans Contrl6

	move.w	#2,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI   3 : V_CLRWK (CLEAR WORKSTATION) ///

V_ClrWk	move.w	(12,SP),([A1],12)	; Handle dans Contrl6

	move.w	#3,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI   4 : V_UPDWK (UPDATE WORKSTATION) ///

V_UpdWk	move.w	(12,SP),([A1],12)	; Handle dans Contrl6

	move.w	#4,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI   5 : ESCAPE ///

V_Escape	move.w	#5,([A1])		; OpCode dans Contrl0
	move.w	(12,SP),D0
	cmpi.w	#19,D0
	BGT	ESC_ERROR		; Au dessus de ESC 19, y'a rien
	move.w	D0,([A1],10)		; Sous Fonction dans Contrl5
	lea	ESC_JUMP(PC),A2		; Le Very fun...
	JMP	(A2,D0.w*4)

ESC_ERROR	RTS

ESC_JUMP	BRA	UnDefESC0
	BRA	Escape1
	BRA	Escape2
	BRA	Escape3
	BRA	Escape4
	BRA	Escape5
	BRA	Escape6
	BRA	Escape7
	BRA	Escape8
	BRA	Escape9
	BRA	Escape10
	BRA	Escape11
	BRA	Escape12
	BRA	Escape13
	BRA	Escape14
	BRA	Escape15
	BRA	Escape16
	BRA	Escape17
	BRA	Escape18
	BRA	Escape19

; /// VDI   5,0 : Non d‚finit ///

UnDefESC0
	RTS

; /// VDI   5,1 : INQUIRE ADDRESSABLE ALPHA CHARACTER CELLS ///

Escape1	move.w	(14,SP),([A1],12)	; Handle dans Contrl6

	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	move.w	#2,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	([12,A1]),D0		; Ligne - Colonne

	RTS

; /// VDI   5,2 : EXIT ALPHA MODE ///

Escape2	move.w	(14,SP),([A1],12)	; Handle dans Contrl6

	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI   5,3 : ENTER ALPHA MODE ///

Escape3	move.w	(14,SP),([A1],12)	; Handle dans Contrl6

	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI   5,4 : ALPHA CURSOR UP ///

Escape4	move.w	(14,SP),([A1],12)	; Handle dans Contrl6

	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI   5,5 : ALPHA CURSOR DOWN ///

Escape5	move.w	(14,SP),([A1],12)	; Handle dans Contrl6

	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI   5,6 : ALPHA CURSOR RIGHT ///

Escape6	move.w	(14,SP),([A1],12)	; Handle dans Contrl6

	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI   5,7 : ALPHA CURSOR LEFT ///

Escape7	move.w	(14,SP),([A1],12)	; Handle dans Contrl6

	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI   5,8 : HOME ALPHA CURSOR ///

Escape8	move.w	(14,SP),([A1],12)	; Handle dans Contrl6

	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI   5,9 : ERASE TO END OF ALPHA SCREEN ///

Escape9	move.w	(14,SP),([A1],12)	; Handle dans Contrl6

	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI   5,10 : ERASE TO END OF ALPHA TEXT LINE ///

Escape10	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI   5,11 : DIRECT ALPHA CURSOR ADDRESS ///

Escape11	move.w	(18,SP),([A1],12)	; Handle dans Contrl6
	move.w	(16,SP),([4,A1])	; Ligne dans IntIn0
	move.w	(14,SP),([4,A1],2)	; Colonne dans IntIn1
	
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#2,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI   5,12 : OUTPUT CURSOR ADDRESSABLE ALPHA TEXT ///

Escape12	move.w	(20,SP),([A1],12)	; Handle dans Contrl6
	move.w	(18,SP),D0
	move.w	D0,([A1],6)		; Nombre dans Contrl3
	move.l	(14,SP),A0		; Adresse
	move.l	(4,A1),A2		; IntIn
	subq.w	#1,D0
Copy_ESC12	clr.w	D1
	move.b	(A0)+,D1
	move.w	D1,(A2)+
	DBF	D0,Copy_ESC12
	
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI   5,13 : REVERSE VIDEO ON ///

Escape13	move.w	(14,SP),([A1],12)	; Handle dans Contrl6

	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI   5,14 : REVERSE VIDEO OFF ///

Escape14	move.w	(14,SP),([A1],12)	; Handle dans Contrl6

	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI   5,15 : INQUIRE CURRENT ALPHA CURSOR ADDRESS ///

Escape15	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	move.w	#2,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	([12,A1]),D0		; Ligne - Colonne

	RTS

; /// VDI   5,16 : INQUIRE TABLET STATUS ///

Escape16	move.w	(14,SP),([A1],12)	; Handle dans Contrl6

	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Etat

	RTS

; /// VDI   5,17 : HARD COPY ///

Escape17	move.w	(14,SP),([A1],12)	; Handle dans Contrl6

	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI   5,18 : PLACE GRAPHIC CURSOR AT LOCATION ///

Escape18	move.w	(18,SP),([A1],12)	; Handle dans Contrl6
	move.w	(16,SP),([8,A1])	; X dans PtsIn0
	move.w	(14,SP),([8,A1],2)	; Y dans PtsIn1
	
	move.w	#1,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI   5,19 : REMOVE LAST GRAPHIC CURSOR ///

Escape19	move.w	(14,SP),([A1],12)	; Handle dans Contrl6

	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI   5,99 : V_BEZ_QUAL ///

V_Bez_Qual	move.w	#5,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI   6 : V_PLINE (POLYLINE) ///

V_Pline	move.w	(18,SP),([A1],12)	; Handle dans Contrl6
	move.w	(16,SP),D0		; Nb de points
	move.l	(12,SP),A0		; Adresse du tableau
	move.l	(8,A1),A2		; PtsIn
	subq.w	#1,D0
Copy_VDI6	move.l	(A0)+,(A2)+
	DBF	D0,Copy_VDI6

	move.w	#6,([A1])		; OpCode dans Contrl0
	move.w	(18,SP),([A1],2)	; Nb de points dans Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI   6,13 : V_BEZ ///

V_Bez	move.w	#6,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI   7 : V_PMARKER (POLYMARKER) ///

V_PMarker	move.w	(18,SP),([A1],12)	; Handle dans Contrl6
	move.w	(16,SP),D0		; Nb de points
	move.l	(12,SP),A0		; Adresse du tableau
	move.l	(8,A1),A2		; PtsIn
	subq.w	#1,D0
Copy_VDI7	move.l	(A0)+,(A2)+
	DBF	D0,Copy_VDI7

	move.w	#7,([A1])		; OpCode dans Contrl0
	move.w	(18,SP),([A1],2)	; Nb de points dans Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI   8 : V_GTEXT (TEXT) ///

V_GText	move.w	(22,SP),([A1],12)	; Handle dans Contrl6
	move.w	(20,SP),D0		; Nb de points
	move.w	(18,SP),([8,A1])	; X dans PtsIn0
	move.w	(16,SP),([8,A1],2)	; Y dans PtsIn1
	move.l	(12,SP),A0		; Adresse de la chaine
	move.l	(4,A1),A2		; IntIn
	subq.w	#1,D0
Copy_VDI8	clr.w	D1
	move.b	(A0)+,D1
	move.w	D1,(A2)+
	DBF	D0,Copy_VDI8

	move.w	#8,([A1])		; OpCode dans Contrl0
	move.w	(20,SP),([A1],2)	; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI   9 : V_FILLAREA (FILLED AREA) ///

V_FillArea	move.w	(18,SP),([A1],12)	; Handle dans Contrl6
	move.w	(16,SP),D0		; Nb de points
	move.l	(12,SP),A0		; Adresse du tableau
	move.l	(8,A1),A2		; PtsIn
	subq.w	#1,D0
Copy_VDI9	move.l	(A0)+,(A2)+
	DBF	D0,Copy_VDI9

	move.w	#9,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI   9,13 : V_BEZ_FILL ///

V_Bez_Fill	

	move.w	#9,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI  10 : V_CELLARRAY (CELL ARRAY) ///

V_CellArray	

	move.w	#10,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI  11 : Generalized Drawing Primitives ///

V_GDP	move.w	#11,([A1])		; OpCode dans Contrl0
	move.w	(12,SP),D0
	cmpi.w	#13,D0
	BGT	GDP_ERROR		; Au dessus de GDP 13, y'a rien
	move.w	D0,([A1],10)		; Sous Fonction dans Contrl5
	lea	GDP_JUMP(PC),A2		; Le Very fun...
	JMP	(A2,D0.w*4)

GDP_ERROR	RTS

GDP_JUMP	BRA	UnDefGDP0
	BRA	V_Bar		; GDP  1
	BRA	V_Arc		; GDP  2
	BRA	V_PieSlice		; GDP  3
	BRA	V_Circle		; GDP  4
	BRA	V_Ellipse		; GDP  5
	BRA	V_EllArc		; GDP  6
	BRA	V_EllPie		; GDP  7
	BRA	V_RBox		; GDP  8
	BRA	V_RFBox		; GDP  9
	BRA	V_Justified		; GDP 10
	BRA	UnDefGDP11
	BRA	UnDefGDP12
	BRA	V_Bez_Param		; GDP 13
		
; /// VDI  11,0 : Non d‚finit ///

UnDefGDP0
	RTS
		
; /// VDI  11,1 : V_BAR (BAR) ///

V_Bar	move.w	(22,SP),([A1],12)	; Handle dans Contrl6
	move.w	(20,SP),([8,A1])	; X1 dans PtsIn0
	move.w	(18,SP),([8,A1],2)	; Y1 dans PtsIn1
	move.w	(16,SP),([8,A1],4)	; X2 dans PtsIn2
	move.w	(14,SP),([8,A1],6)	; Y2 dans PtsIn3

	move.w	#2,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI  11,2 : V_ARC (ARC) ///

V_Arc	move.w	(24,SP),([A1],12)	; Handle dans Contrl6
	move.w	(22,SP),([4,A1])	; Angle D dans IntIn0
	move.w	(20,SP),([4,A1],2)	; Angle F dans IntIn1
	move.w	(18,SP),([8,A1])	; X dans PtsIn0
	move.w	(16,SP),([8,A1],2)	; Y dans PtsIn1
	clr.w	([8,A1],4)		; PtsIn2
	clr.w	([8,A1],6)		; PtsIn3
	clr.w	([8,A1],8)		; PtsIn4
	clr.w	([8,A1],10)		; PtsIn5
	move.w	(14,SP),([8,A1],12)	; Rayon dans PtsIn6
	clr.w	([8,A1],14)		; PtsIn7

	move.w	#4,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#2,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI  11,3 : V_PIESLICE (PIE) ///

V_PieSlice	move.w	(24,SP),([A1],12)	; Handle dans Contrl6
	move.w	(22,SP),([4,A1])	; Angle D dans IntIn0
	move.w	(20,SP),([4,A1],2)	; Angle F dans IntIn1
	move.w	(18,SP),([8,A1])	; X dans PtsIn0
	move.w	(16,SP),([8,A1],2)	; Y dans PtsIn1
	clr.w	([8,A1],4)		; PtsIn2
	clr.w	([8,A1],6)		; PtsIn3
	clr.w	([8,A1],8)		; PtsIn4
	clr.w	([8,A1],10)		; PtsIn5
	move.w	(14,SP),([8,A1],12)	; Rayon dans PtsIn6
	clr.w	([8,A1],14)		; PtsIn7

	move.w	#4,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#2,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI  11,4 : V_CIRCLE (CIRCLE) ///

V_Circle	move.w	(20,SP),([A1],12)	; Handle dans Contrl6
	move.w	(18,SP),([8,A1])	; X dans PtsIn0
	move.w	(16,SP),([8,A1],2)	; Y dans PtsIn1
	clr.w	([8,A1],4)		; PtsIn2
	clr.w	([8,A1],6)		; PtsIn3
	move.w	(14,SP),([8,A1],8)	; Rayon dansPtsIn4
	clr.w	([8,A1],10)		; PtsIn5

	move.w	#3,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI  11,5 : V_ELLIPSE (ELLIPSE) ///

V_Ellipse	move.w	(22,SP),([A1],12)	; Handle dans Contrl6
	move.w	(20,SP),([8,A1])	; X dans PtsIn0
	move.w	(18,SP),([8,A1],2)	; Y dans PtsIn1
	move.w	(16,SP),([8,A1],4)	; Rayon X dans PtsIn2
	move.w	(14,SP),([8,A1],6)	; Rayon Y dans PtsIn3

	move.w	#2,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI  11,6 : V_ELLARC (ELLIPTICAL ARC) ///

V_EllArc	move.w	(26,SP),([A1],12)	; Handle dans Contrl6
	move.w	(24,SP),([4,A1])	; Angle D dans IntIn0
	move.w	(22,SP),([4,A1],2)	; Angle F dans IntIn1
	move.w	(20,SP),([8,A1])	; X dans PtsIn0
	move.w	(18,SP),([8,A1],2)	; Y dans PtsIn1
	move.w	(16,SP),([8,A1],4)	; Rayon X dans PtsIn2
	move.w	(14,SP),([8,A1],6)	; Rayon Y dans PtsIn3

	move.w	#2,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#2,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI  11,7 : V_ELLPIE (ELLIPTICAL PIE) ///

V_EllPie	move.w	(26,SP),([A1],12)	; Handle dans Contrl6
	move.w	(24,SP),([4,A1])	; Angle D dans IntIn0
	move.w	(22,SP),([4,A1],2)	; Angle F dans IntIn1
	move.w	(20,SP),([8,A1])	; X dans PtsIn0
	move.w	(18,SP),([8,A1],2)	; Y dans PtsIn1
	move.w	(16,SP),([8,A1],4)	; Rayon X dans PtsIn2
	move.w	(14,SP),([8,A1],6)	; Rayon Y dans PtsIn3

	move.w	#2,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#2,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI  11,8 : V_RBOX (ROUNDED RECTANGLE) ///

V_RBox	move.w	(22,SP),([A1],12)	; Handle dans Contrl6
	move.w	(20,SP),([8,A1])	; X1 dans PtsIn0
	move.w	(18,SP),([8,A1],2)	; Y1 dans PtsIn1
	move.w	(16,SP),([8,A1],4)	; X2 dans PtsIn2
	move.w	(14,SP),([8,A1],6)	; Y2 dans PtsIn3

	move.w	#2,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI  11,9 : V_RFBOX (FILLED ROUNDED RECTANGLE) ///

V_RFBox	move.w	(22,SP),([A1],12)	; Handle dans Contrl6
	move.w	(20,SP),([8,A1])	; X1 dans PtsIn0
	move.w	(18,SP),([8,A1],2)	; Y1 dans PtsIn1
	move.w	(16,SP),([8,A1],4)	; X2 dans PtsIn2
	move.w	(14,SP),([8,A1],6)	; Y2 dans PtsIn3

	move.w	#2,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI  11,10 : V_JUSTIFIED (JUSTIFIED GRAPHICS TEXT) ///

V_Justified	move.w	(28,SP),([A1],12)	; Handle dans Contrl6
	move.w	(26,SP),D0		; Nb de points
	move.w	D0,D1
	addq.w	#2,D1
	move.w	D1,([A1],6)		; Nombre+2 dans Contrl3
	move.w	(24,SP),([4,A1])	; Scp mot dans IntIn0
	move.w	(22,SP),([4,A1],2)	; Scp lettre dans IntIn1
	move.w	(18,SP),([8,A1])	; X dans PtsIn0
	move.w	(16,SP),([8,A1],2)	; Y dans PtsIn1
	move.w	(14,SP),([8,A1],2)	; Longeur dans PtsIn1
	move.l	(20,SP),A0		; Adresse de la chaine
	lea	([4,A1],4),A2		; IntIn2
	subq.w	#1,D0
Copy_GDP10	clr.w	D1
	move.b	(A0)+,D1
	move.w	D1,(A2)+
	DBF	D0,Copy_GDP10

	move.w	#2,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI  11,11 : Non d‚finit ///

UnDefGDP11
	RTS
	
; /// VDI  11,12 : Non d‚finit ///

UnDefGDP12
	RTS
	
; /// VDI  11,13 : V_BEZ_PARAM ///

V_Bez_Param	move.w	(14,SP),D0
	cmpi.w	#1,D0
	BGT	BEZ_ERROR		; Au dessus de BEZ 1, y'a rien
	lea	BEZ_JUMP(PC),A2		; Le Very fun...
	JMP	(A2,D0.w*4)

BEZ_ERROR	RTS

BEZ_JUMP	BRA	V_Bez_Off
	BRA	V_Bez_On
	
; /// VDI  11,13,0 : V_BEZ_OFF ///

V_Bez_Off	

	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI  11,13,1 : V_BEZ_ON ///

V_Bez_On	

	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI  12 : VST_HEIGH (SET CHARACTER HEIGHT - ABSOLUTE MODE) ///

Vst_Heigh	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	clr.w	([8,A1])		; PtsIn0
	move.w	(12,SP),([8,A1],2)	; Hauteur dans PtsIn1

	move.w	#12,([A1])		; OpCode dans Contrl0
	move.w	#1,([A1],2)		; Contrl1
	move.w	#2,([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	(16,A1),D0		; PtsOut
	
	RTS
	
; /// VDI  13 : VST_ROTATION (SET CHARACTER BASELINE VECTOR) ///

Vst_Rotation	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Hauteur dans IntIn0

	move.w	#13,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	move.w	#2,([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	(16,A1),D0		; PtsOut
	
	RTS
	
; /// VDI  14 : VS_COLOR (SET COLOR REPRESENTATION) ///

Vs_Color	move.w	(20,SP),([A1],12)	; Handle dans Contrl6
	move.w	(18,SP),([4,A1])	; Index dans IntIn0
	move.w	(16,SP),([4,A1],2)	; Rouge dans IntIn1
	move.w	(14,SP),([4,A1],4)	; Vert dans IntIn2
	move.w	(12,SP),([4,A1],6)	; Bleu dans IntIn3

	move.w	#14,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#3,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI  15 : VSL_TYPE (SET POLYLINE LINE TYPE) ///

Vsl_Type	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Type dans IntIn0

	move.w	#15,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat
	
	RTS
	
; /// VDI  16 : VSL_WIDTH (SET POLYLINE LINE WIDTH) ///

Vsl_Width	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([8,A1])	; Largeur dans PtsIn0
	clr.w	([8,A1],2)		; PtsIn1

	move.w	#16,([A1])		; OpCode dans Contrl0
	move.w	#1,([A1],2)		; Contrl1
	move.w	#1,([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([16,A1]),D0		; Largeur
	
	RTS
	
; /// VDI  17 : VSL_COLOR (SET POLYLINE COLOR INDEX) ///

Vsl_Color	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Index dans IntIn0

	move.w	#17,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Index
	
	RTS
	
; /// VDI  18 : VSM_TYPE (SET POLYMARKER TYPE) ///

Vsm_Type	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Type dans IntIn0

	move.w	#18,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Type
	
	RTS
	
; /// VDI  19 : VSM_HEIGHT (SET POLYMARKER HEIGHT)///

Vsm_Height	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	clr.w	([8,A1])		; PtsIn0
	move.w	(12,SP),([8,A1],2)	; Type dans PtsIn1

	move.w	#19,([A1])		; OpCode dans Contrl0
	move.w	#1,([A1],2)		; Contrl1
	move.w	#1,([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([16,A1]),D0		; Largeur - Hauteur
	
	RTS
	
; /// VDI  20 : VSM_COLOR (SET POLYMARKER COLOUR INDEX) ///

Vsm_Color	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Index dans IntIn0

	move.w	#20,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Index
	
	RTS
	
; /// VDI  21 : VST_FONT (SET TEXT FACE) ///

Vst_Font	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Fonte dans IntIn0

	move.w	#21,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Fonte
	
	RTS
	
; /// VDI  22 : VST_COLOR (SET GRAPHIC TEXT COLOUR INDEX) ///

Vst_Color	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Index dans IntIn0

	move.w	#22,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Index
	
	RTS
	
; /// VDI  23 : VSF_INTERIOR (SET FILL INTERIOR STYLE) ///

Vsf_Interior	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Type dans IntIn0

	move.w	#23,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Type
	
	RTS

; /// VDI  24 : VSF_STYLE (SET FILL STYLE INDEX) ///

Vsf_Style	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Type dans IntIn0

	move.w	#24,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Type
	
	RTS
	
; /// VDI  25 : VSF_COLOR (SET FILL COLOUR INDEX) ///

Vsf_Color	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Index dans IntIn0

	move.w	#25,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Index
	
	RTS
	
; /// VDI  26 : VQ_COLOR () ///

Vq_Color	move.w	(16,SP),([A1],12)	; Handle dans Contrl6
	move.w	(14,SP),([4,A1])	; Index dans IntIn0
	move.w	(12,SP),([4,A1],2)	; Mode dans IntIn1

	move.w	#26,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#2,([A1],6)		; Contrl3
	move.w	#4,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	(12,A1),D0		; IntOut
	
	RTS
	
; /// VDI  27 : VQT_ARRAY (INQUIRE CELL ARRAY)  ///

Vqt_Array	move.w	(24,SP),([A1],12)	; Handle dans Contrl6
	move.w	(22,SP),([A1],14)	; Longueur dans Contrl7
	move.w	(20,SP),([A1],16)	; Nombre lignes dans Contrl8
	move.w	(18,SP),([8,A1])	; X1 dans PtsIn0
	move.w	(16,SP),([8,A1],2)	; Y1 dans PtsIn1
	move.w	(14,SP),([8,A1],4)	; X2 dans PtsIn2
	move.w	(12,SP),([8,A1],6)	; Y2 dans PtsIn3

	move.w	#27,([A1])		; OpCode dans Contrl0
	move.w	#2,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#2,([A1],6)		; Contrl3

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	(12,A1),D0		; IntOut
	move.l	#SSAV_Wk1Buff,D1
	movea.l	D1,A0
	move.w	([A1],8),(A0)+		; Longueur
	move.w	([A1],18),(A0)+		; Nombre
	move.w	([A1],20),(A0)+		; Lignes
	move.w	([A1],22),(A0)		; Validit‚
	
	RTS

; /// VDI  28 : VRQ_LOCATOR (INPUT LOCATOR) ///

Vrq_Locator	move.w	(16,SP),([A1],12)	; Handle dans Contrl6
	move.w	(14,SP),([8,A1])	; X dans PtsIn0
	move.w	(12,SP),([8,A1],2)	; Y dans PtsIn1

	move.w	#28,([A1])		; OpCode dans Contrl0
	move.w	#1,([A1],2)		; Contrl1
	move.w	#1,([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Code ASCII
	swap	D0
	clr.w	D0
	move.w	([A1],4),D2
	BEQ	Next1_VDI28
	bset	#0,D0
Next1_VDI28	move.w	([A1],8),D2
	BEQ	Next2_VDI28
	bset	#1,D0
Next2_VDI28	move.w	([16,A1]),D1		; X
	swap	D1
	move.w	([16,A1],2),D1		; Y
	
	RTS
	
; /// VDI  29 : VRQ_VALUATOR (INPUT VALUATOR) ///

Vrq_Valuator	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Valeur dans IntIn0

	move.w	#29,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	move.w	#2,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	([12,A1]),D0		; Valeur - Code ASCII
	move.w	([A1],8),D1		; Evenement
	
	RTS
	
; /// VDI  30 : VRQ_CHOICE (INPUT CHOICE) ///

Vrq_Choice	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),D0
	BMI	Next1_VDI30
	move.w	D0,([4,A1])		; Valeur dans IntIn0
	move.w	#1,([A1],6)		; Contrl3
	BRA	Next2_VDI30
Next1_VDI30	clr.w	([A1],6)		; Contrl3

Next2_VDI30	move.w	#30,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Code ASCII
	move.w	([A1],8),D1		; Evenement

	RTS
	
; /// VDI  31 : VRQ_STRING (INPUT STRING) ///

Vrq_String	move.w	(24,SP),([A1],12)	; Handle dans Contrl6
	move.w	(22,SP),([4,A1])	; Longueur dans IntIn0
	move.w	(20,SP),([4,A1],2)	; Mode dans IntIn1
	move.w	(18,SP),([8,A1])	; X dans PtsIn0
	move.w	(16,SP),([8,A1],2)	; Y dans PtsIn1

	move.w	#31,([A1])		; OpCode dans Contrl0
	move.w	#1,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#2,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([A1],8),D0		; Longueur
	BEQ	Exit_VDI31
	move.l	(12,A1),A0		; IntOut
	move.l	(12,SP),A2		; Tampon
	subq.w	#1,D0
Copy_VDI31	move.w	(A0)+,D1
	move.b	D1,(A2)+
	DBF	D0,Copy_VDI31
	
Exit_VDI31	RTS
	
; /// VDI  32 : VSWR_MODE (SET WRITING MODE) ///

Vswr_Mode	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Mode dans IntIn0

	move.w	#32,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Mode
	
	RTS
	
; /// VDI  33 : VSIN_MODE (SET INPUT MODE) ///

VSin_Mode	move.w	(16,SP),([A1],12)	; Handle dans Contrl6
	move.w	(14,SP),([4,A1])	; P‚riph‚rique IntIn0
	move.w	(12,SP),([4,A1],2)	; Mode dans IntIn1

	move.w	#33,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#2,([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Mode
	
	RTS
	
; /// VDI  34 : Non D‚finit ///

UnDefVDI34
	RTS
	
; /// VDI  35 : VQL_ATTRIBUTES (INQUIRE CURRENT POLYLINE ATTRIBUTES) ///

Vql_Attributes	move.w	(12,SP),([A1],12)	; Handle dans Contrl6
	
	move.w	#35,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	move.w	#1,([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	move.w	#5,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	(12,A1),D0		; IntOut
	move.w	([16,A1]),D1		; Largeur
	
	RTS
	
; /// VDI  36 : VQM_ATTRIBUTES (INQUIRE CURRENT POLYMARKER ATTRIBUTES) ///

Vqm_Attributes	move.w	(12,SP),([A1],12)	; Handle dans Contrl6
	
	move.w	#36,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	move.w	#1,([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	move.w	#3,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	(12,A1),D0		; IntOut
	move.l	([16,A1]),D1		; PtsOut0-1
	
	RTS
	
; /// VDI  37 : VQF_ATTRIBUTES (INQUIRE CURRENT FILL AREA ATTRIBUTES) ///

Vqf_Attributes	move.w	(12,SP),([A1],12)	; Handle dans Contrl6
	
	move.w	#37,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	move.w	#5,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	(12,A1),D0		; IntOut
	
	RTS
	
; /// VDI  38 : VQT_ATTRIBUTES (INQUIRE CURRENT GRAPHIC TEXT ATTRIBUTES) ///

Vqt_Attributes	move.w	(12,SP),([A1],12)	; Handle dans Contrl6
	
	move.w	#38,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	move.w	#2,([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	move.w	#6,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	(12,A1),D0		; IntOut
	move.l	(16,A1),D1		; PtsOut
	
	RTS
	
; /// VDI  39 : VST_ALIGNMENT (SET GRAPHIC TEXT ALIGNMENT) ///

Vst_Alignment	move.w	(16,SP),([A1],12)	; Handle dans Contrl6
	move.w	(14,SP),([4,A1])	; X dans IntIn0
	move.w	(12,SP),([4,A1],2)	; Y dans IntIn1

	move.w	#39,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#2,([A1],6)		; Contrl3
	move.w	#2,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	([12,A1]),D0		; IntOut0-1
	
	RTS
	
; /// VDI  40 : Non D‚finit ///

UnDefVDI40
	RTS
	
; /// VDI  41 : Non D‚finit ///

UnDefVDI41
	RTS
	
; /// VDI  42 : Non D‚finit ///

UnDefVDI42
	RTS
	
; /// VDI  43 : Non D‚finit ///

UnDefVDI43
	RTS
	
; /// VDI  44 : Non D‚finit ///

UnDefVDI44
	RTS
	
; /// VDI  45 : Non D‚finit ///

UnDefVDI45
	RTS
	
; /// VDI  46 : Non D‚finit ///

UnDefVDI46
	RTS
	
; /// VDI  47 : Non D‚finit ///

UnDefVDI47
	RTS
	
; /// VDI  48 : Non D‚finit ///

UnDefVDI48
	RTS
	
; /// VDI  49 : Non D‚finit ///

UnDefVDI49
	RTS
	
; /// VDI  50 : Non D‚finit ///

UnDefVDI50
	RTS
	
; /// VDI  51 : Non D‚finit ///

UnDefVDI51
	RTS
	
; /// VDI  52 : Non D‚finit ///

UnDefVDI52
	RTS
	
; /// VDI  53 : Non D‚finit ///

UnDefVDI53
	RTS
	
; /// VDI  54 : Non D‚finit ///

UnDefVDI54
	RTS
	
; /// VDI  55 : Non D‚finit ///

UnDefVDI55
	RTS
	
; /// VDI  56 : Non D‚finit ///

UnDefVDI56
	RTS
	
; /// VDI  57 : Non D‚finit ///

UnDefVDI57
	RTS
	
; /// VDI  58 : Non D‚finit ///

UnDefVDI58
	RTS
	
; /// VDI  59 : Non D‚finit ///

UnDefVDI59
	RTS
	
; /// VDI  60 : Non D‚finit ///

UnDefVDI60
	RTS
	
; /// VDI  61 : Non D‚finit ///

UnDefVDI61
	RTS
	
; /// VDI  62 : Non D‚finit ///

UnDefVDI62
	RTS
	
; /// VDI  63 : Non D‚finit ///

UnDefVDI63
	RTS
	
; /// VDI  64 : Non D‚finit ///

UnDefVDI64
	RTS
	
; /// VDI  65 : Non D‚finit ///

UnDefVDI65
	RTS
	
; /// VDI  66 : Non D‚finit ///

UnDefVDI66
	RTS
	
; /// VDI  67 : Non D‚finit ///

UnDefVDI67
	RTS
	
; /// VDI  68 : Non D‚finit ///

UnDefVDI68
	RTS
	
; /// VDI  69 : Non D‚finit ///

UnDefVDI69
	RTS
	
; /// VDI  70 : Non D‚finit ///

UnDefVDI70
	RTS
	
; /// VDI  71 : Non D‚finit ///

UnDefVDI71
	RTS
	
; /// VDI  72 : Non D‚finit ///

UnDefVDI72
	RTS
	
; /// VDI  73 : Non D‚finit ///

UnDefVDI73
	RTS
	
; /// VDI  74 : Non D‚finit ///

UnDefVDI74
	RTS
	
; /// VDI  75 : Non D‚finit ///

UnDefVDI75
	RTS
	
; /// VDI  76 : Non D‚finit ///

UnDefVDI76
	RTS
	
; /// VDI  77 : Non D‚finit ///

UnDefVDI77
	RTS
	
; /// VDI  78 : Non D‚finit ///

UnDefVDI78
	RTS
	
; /// VDI  79 : Non D‚finit ///

UnDefVDI79
	RTS
	
; /// VDI  80 : Non D‚finit ///

UnDefVDI80
	RTS
	
; /// VDI  81 : Non D‚finit ///

UnDefVDI81
	RTS
	
; /// VDI  82 : Non D‚finit ///

UnDefVDI82
	RTS
	
; /// VDI  83 : Non D‚finit ///

UnDefVDI83
	RTS
	
; /// VDI  84 : Non D‚finit ///

UnDefVDI84
	RTS
	
; /// VDI  85 : Non D‚finit ///

UnDefVDI85
	RTS
	
; /// VDI  86 : Non D‚finit ///

UnDefVDI86
	RTS
	
; /// VDI  87 : Non D‚finit ///

UnDefVDI87
	RTS
	
; /// VDI  88 : Non D‚finit ///

UnDefVDI88
	RTS
	
; /// VDI  89 : Non D‚finit ///

UnDefVDI89
	RTS
	
; /// VDI  90 : Non D‚finit ///

UnDefVDI90
	RTS
	
; /// VDI  91 : Non D‚finit ///

UnDefVDI91
	RTS
	
; /// VDI  92 : Non D‚finit ///

UnDefVDI92
	RTS
	
; /// VDI  93 : Non D‚finit ///

UnDefVDI93
	RTS
	
; /// VDI  94 : Non D‚finit ///

UnDefVDI94
	RTS
	
; /// VDI  95 : Non D‚finit ///

UnDefVDI95
	RTS
	
; /// VDI  96 : Non D‚finit ///

UnDefVDI96
	RTS
	
; /// VDI  97 : Non D‚finit ///

UnDefVDI97
	RTS
	
; /// VDI  98 : Non D‚finit ///

UnDefVDI98
	RTS
	
; /// VDI  99 : Non D‚finit ///

UnDefVDI99
	RTS
	
; /// VDI 100 : V_OPNVWK (OPEN VIRTUAL WORKSTATION) ///

V_OpnVWk	move.w	(34,SP),([A1],12)	; Handle dans Contrl6
	move.w	(32,SP),([4,A1])	; Num‚ro P‚riph‚rique dans IntIn0
	move.w	(30,SP),([4,A1],2)	; Type de Ligne dans IntIn1
	move.w	(28,SP),([4,A1],4)	; Index Ligne dans IntIn2
	move.w	(26,SP),([4,A1],6)	; Type de RepŠre dans IntIn3
	move.w	(24,SP),([4,A1],8)	; Index RepŠre dans IntIn4
	move.w	(22,SP),([4,A1],10)	; Fonte dans IntIn5
	move.w	(20,SP),([4,A1],12)	; Index Texte dans IntIn6
	move.w	(18,SP),([4,A1],14)	; Style dans IntIn7
	move.w	(16,SP),([4,A1],16)	; Index Style dans IntIn8
	move.w	(14,SP),([4,A1],18)	; Index Couleur dans IntIn9
	move.w	(12,SP),([4,A1],20)	; SystŠme dans IntIn10
	
	move.w	#100,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	move.w	#6,([A1],4)		; Contrl2
	move.w	#11,([A1],6)		; Contrl3
	move.w	#45,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([A1],12),D0		; Handle
	move.l	(12,A1),D1		; IntOut
	move.l	(16,A1),D2		; PtsOut

	RTS
	
; /// VDI 101 : V_CLSVWK (CLOSE VIRTUAL WORKSTATION) ///

V_ClsVWk	move.w	(12,SP),([A1],12)	; Handle dans Contrl6

	move.w	#101,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 102 : VQ_EXTND (EXTENDED INQUIRE FONCTION) ///

Vq_Extnd	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Mode dans IntIn0

	move.w	#102,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	move.w	#6,([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	move.w	#45,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([A1],12),D0		; Handle
	move.l	(12,A1),D1		; IntOut
	move.l	(16,A1),D2		; PtsOut
	
	RTS
	
; /// VDI 103 : V_CONTOURFILL (CONTOUR FILL) ///

V_ContourFill	move.w	(18,SP),([A1],12)	; Handle dans Contrl6
	move.w	(16,SP),([4,A1])	; Index dans IntIn0
	move.w	(14,SP),([8,A1])	; X dans PtsIn0
	move.w	(12,SP),([8,A1],2)	; Y dans PtsIn1

	move.w	#103,([A1])		; OpCode dans Contrl0
	move.w	#1,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 104 : VSF_PERIMETER (SET FILL PERIMETER VISIBILITY) ///

Vsf_Perimeter	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Mode dans IntIn0
	
	move.w	#104,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Mode
	
	RTS
	
; /// VDI 105 : V_GET_PIXEL (GET PIXEL) ///

V_Get_Pixel	move.w	(16,SP),([A1],12)	; Handle dans Contrl6
	move.w	(14,SP),([8,A1])	; X dans PtsIn0
	move.w	(12,SP),([8,A1],2)	; Y dans PtsIn1

	move.w	#105,([A1])		; OpCode dans Contrl0
	move.w	#1,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	move.w	#2,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	([12,A1]),D0		; Valeur - Index
		
	RTS
	
; /// VDI 106 : VST_EFFECTS (SET GRAPHIC TEXT SPECIAL EFFECTS) ///

Vst_Effects	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Mode dans IntIn0

	move.w	#106,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Mode
	
	RTS
	
; /// VDI 107 : VST_POINT (SET CHARACTER CELL HEIGHT - POINTS MODE) ///

Vst_Point	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Hauteur dans IntIn0

	move.w	#107,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	move.w	#2,([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	(16,A1),D0		; PtsOut
	
	RTS
	
; /// VDI 108 : VSL_ENDS (SET POLYLINE END STYLES) ///

Vsl_Ends	move.w	(16,SP),([A1],12)	; Handle dans Contrl6
	move.w	(14,SP),([4,A1])	; Style D dans IntIn0
	move.w	(12,SP),([4,A1],2)	; Style F dans IntIn1

	move.w	#108,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#2,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 109 : VRO_CPYFM (COPY RASTER - OPAQUE) ///

Vro_CpyFm	move.w	(38,SP),([A1],12)	; Handle dans Contrl6
	move.w	(36,SP),([4,A1])	; Op‚ration dans IntIn0
	move.w	(34,SP),([8,A1])	; X1 Source dans PtsIn0
	move.w	(32,SP),([8,A1],2)	; Y1 Source dans PtsIn1
	move.w	(30,SP),([8,A1],4)	; X2 Source dans PtsIn2
	move.w	(28,SP),([8,A1],6)	; Y2 Source dans PtsIn3
	move.w	(26,SP),([8,A1],8)	; X1 Destination dans PtsIn4
	move.w	(24,SP),([8,A1],10)	; Y1 Destination dans PtsIn5
	move.w	(22,SP),([8,A1],12)	; X2 Destination dans PtsIn6
	move.w	(20,SP),([8,A1],14)	; Y2 Destination dans PtsIn7
	move.l	(16,SP),([A1],14)	; MFDB Source dans Contrl7-8
	move.l	(12,SP),([A1],18)	; MFDB Destination dans Contrl9-10

	move.w	#109,([A1])		; OpCode dans Contrl0
	move.w	#4,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 110 : VR_TRNFM (TRANSFORM FORM) ///

Vr_TrnFm	move.w	(20,SP),([A1],12)	; Handle dans Contrl6
	move.l	(16,SP),([A1],14)	; MFDB Source dans Contrl7-8
	move.l	(12,SP),([A1],18)	; MFDB Destination dans Contrl9-10

	move.w	#110,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 111 : VSC_FORM (SET MOUSE FORM) ///

Vsc_Form	move.w	(28,SP),([A1],12)	; Handle danns Contrl6
	move.w	(26,SP),([4,A1])	; X dans IntIn0
	move.w	(24,SP),([4,A1],2)	; Y dans IntIn1
	move.w	#1,([4,A1],4)		; IntIn2
	move.w	(22,SP),([4,A1],6)	; Couleur masque dans IntIn3
	move.w	(20,SP),([4,A1],8)	; Couleur donn‚es dans IntIn4
	move.l	(16,SP),A0		; Adresse masque
	move.l	(4,SP),A2		; IntIn
	adda.l	#10,A2		; IntIn5
	move.w	#15,D0
Copy1_VDI111	move.w	(A0)+,(A2)+
	DBF	D0,Copy1_VDI111
	move.l	(12,SP),A0
	move.w	#15,D0
Copy2_VDI111	move.w	(A0)+,(A2)+
	DBF	D0,Copy2_VDI111

	move.w	#111,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#37,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 112 : VSF_UDPAT (SET USER DEFINED FILL PATTERN) ///

Vsf_UDPat	move.w	(18,SP),([A1],12)	; Handle dans Contrl6
	move.w	(16,SP),D0
	mulu.w	#16,D0
	move.w	D0,([A1],6)		; Nb plan dans Contrl3
	move.l	(12,SP),A0
	move.l	(4,A1),A2		; IntIn
	subq.w	#1,D0
Copy_VDI112	move.w	(A0)+,(A2)+
	DBF	D0,Copy_VDI112

	move.w	#112,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 113 : VSL_UDSTY (SET USER-DEFINED LINE STYLE PATTERN) ///

Vsl_UDSty	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Style dans IntIn0

	move.w	#113,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 114 : VR_RECTFL (FILL RECTANGLE) ///

Vr_RectFl	move.w	(20,SP),([A1],12)	; Handle dans Contrl6
	move.w	(18,SP),([8,A1])	; X1 dans PtsIn0
	move.w	(16,SP),([8,A1],2)	; Y1 dans PtsIn1
	move.w	(14,SP),([8,A1],4)	; X2 dans PtsIn2
	move.w	(12,SP),([8,A1],6)	; Y2 dans PtsIn3

	move.w	#114,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 115 : Non D‚finit ///

UnDefVDI115	
	RTS

; /// VDI 116 : VQT_EXTENT (INQUIRE TEXT EXTENT) ///

Vqt_Extent	move.w	(18,SP),([A1],12)	; Handle dans Contrl6
	move.w	(16,SP),D0
	move.w	D0,([A1],6)		; Contrl3
	move.l	(12,SP),A0		; Adresse
	move.l	(4,A1),A2		; IntIn
	subq.w	#1,D0
Copy_VDI116	clr.w	D1
	move.b	(A0)+,D1
	move.w	D1,(A2)+
	DBF	D0,Copy_VDI116

	move.w	#116,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	move.w	#4,([A1],4)		; Contrl2
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	(16,A1),D0		; PtsOut

	RTS
	
; /// VDI 117 : VQT_WIDTH (INQUIRE CHARACTER CELL WIDTH) ///

Vqt_Width	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Code ASCII dans IntIn0

	move.w	#117,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	move.w	#3,([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Code ASCII
	
	move.l	#SSAV_Wk1Buff,D1
	movea.l	D1,A0
	move.w	([16,A1]),(A0)+		; Largeur
	move.w	([16,A1],4),(A0)+	; Alignement Gauche
	move.w	([16,A1],8),(A0)+	; Alignement Droit
	
	RTS
	
; /// VDI 118 : VEX_TIMV (EXCHANGE TIMER INTERRUPT VECTOR) ///

Vex_Timv	move.w	(16,SP),([A1],12)	; Handle dans Contrl6
	move.l	(12,SP),([A1],14)	; Adresse dans Contrl7-8
		
	move.w	#118,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Nombre
	move.l	([A1],18),D1		; Adresse

	RTS
	
; /// VDI 119 : VST_LOAD_FONTS (LOAD FONTS) ///

Vst_Load_Fonts	clr.w	([4,A1])		; 0 dans IntIn0
	move.w	(12,SP),([A1],12)	; Handle dans Contrl6

	move.w	#119,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; R‚sultat

	RTS
	
; /// VDI 120 : VST_UNLOAD_FONTS (UNLOAD FONTS) ///

Vst_UnLoad_Fonts	clr.w	([4,A1])	; 0 dans IntIn0
	move.w	(12,SP),([A1],12)	; Handle dans Contrl6

	move.w	#120,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 121 : VRT_CPYFM (COPY RASTER - TRANSPARENT) ///

Vrt_CpyFm	move.w	(42,SP),([A1],12)	; Handle dans Contrl6
	move.w	(40,SP),([4,A1])	; Mode dans IntIn0
	move.w	(38,SP),([4,A1],2)	; Couleur Bit 1 dans IntIn1
	move.w	(36,SP),([4,A1],4)	; Couleur Bit 0 dans IntIn2
	move.w	(34,SP),([8,A1])	; X1 Source dans PtsIn0
	move.w	(32,SP),([8,A1],2)	; Y1 Source dans PtsIn1
	move.w	(30,SP),([8,A1],4)	; X2 Source dans PtsIn2
	move.w	(28,SP),([8,A1],6)	; Y2 Source dans PtsIn3
	move.w	(26,SP),([8,A1],8)	; X1 Destination dans PtsIn4
	move.w	(24,SP),([8,A1],10)	; Y1 Destination dans PtsIn5
	move.w	(22,SP),([8,A1],12)	; X2 Destination dans PtsIn6
	move.w	(20,SP),([8,A1],14)	; Y2 Destination dans PtsIn7
	move.l	(16,SP),([A1],14)	; MFDB Source dans Contrl7-8
	move.l	(12,SP),([A1],18)	; MFDB Destination dans Contrl9-10

	move.w	#121,([A1])		; OpCode dans Contrl0
	move.w	#4,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#3,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
		
; /// VDI 122 : V_SHOW_C (SHOW CURSOR) ///

V_Show_C	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Mode dans IntIn0

	move.w	#122,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 123 : V_HIDE_C (HIDE CURSOR) ///

V_Hide_C	move.w	(12,SP),([A1],12)	; Handle dans Contrl6

	move.w	#123,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI 124 : VQ_MOUSE (SAMPLE MOUSE BUTTON STATE) ///

Vq_Mouse	move.w	(12,SP),([A1],12)	; Handle dans Contrl6

	move.w	#124,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	move.w	#1,([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([16,A1]),D0		; X
	swap	D0
	move.w	([16,A1],2),D0		; Y
	move.w	([12,A1]),D1		; Boutons

	RTS
	
; /// VDI 125 : VEX_BUTV (EXCHANGE BUTTON CHANGE VECTOR) ///

Vex_ButV	move.w	(16,SP),([A1],12)	; Handle dans Contrl6
	move.l	(12,SP),([A1],14)	; Adresse dans Contrl7-8
	
	move.w	#125,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	([A1],18),D0		; Adresse

	RTS
	
; /// VDI 126 : VEX_MOTV (EXCHANGE MOUSE MOVEMENT VECTOR) ///

Vex_MotV	move.w	(16,SP),([A1],12)	; Handle dans Contrl6
	move.l	(12,SP),([A1],14)	; Adresse dans Contrl7-8

	move.w	#126,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	([A1],18),D0		; Adresse

	RTS
	
; /// VDI 127 : VEX_CURV (EXCHANGE CURSOR CHANGE VECTOR) ///

Vex_CurV	move.w	(16,SP),([A1],12)	; Handle dans Contrl6
	move.l	(12,SP),([A1],14)	; Adresse dans Contrl7-8

	move.w	#127,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	([A1],18),D0		; Adresse

	RTS
	
; /// VDI 128 : VQ_KEY_S (SAMPLE KEYBOARD STATE INFORMATION) ///

Vq_Key_S	move.w	(12,SP),([A1],12)	; Handle dans Contrl6

	move.w	#128,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	move.w	#1,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.w	([12,A1]),D0		; Touches

	RTS
	
; /// VDI 129 : VS_CLIP (SET CLIPPING RECTANGLE) ///

Vs_Clip	move.w	(22,SP),([A1],12)	; Handle dans Contrl6
	move.w	(20,SP),([4,A1])	; Mode dans IntIn0
	move.w	(18,SP),([8,A1])	; X1 dans PtsIn0
	move.w	(16,SP),([8,A1],2)	; Y1 dans PtsIn1
	move.w	(14,SP),([8,A1],4)	; X2 dans PtsIn2
	move.w	(12,SP),([8,A1],6)	; Y2 dans PtsIn3
	
	move.w	#129,([A1])		; OpCode dans Contrl0
	move.w	#2,([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 130 : VQT_NAME (INQUIRE FACE NAME & INDEX) ///

Vqt_Name	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	move.w	(12,SP),([4,A1])	; Index dans IntIn0

	move.w	#130,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	move.w	#1,([A1],6)		; Contrl3
	move.w	#33,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	(12,A1),D0		; IntOut

	RTS
	
; /// VDI 131 : VQT_FONTINFO (INQUIRE CURRENT FACE INFORMATION) ///

Vqt_FontInfo	move.w	(14,SP),([A1],12)	; Handle dans Contrl6
	
	move.w	#131,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	move.w	#5,([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	move.w	#2,([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	move.l	([12,A1]),D0		; IntOut0-1
	move.l	(16,A1),D1		; PtsOut

	RTS

; /// VDI 132 : Non D‚finit ///

UnDefVDI132
	RTS

; /// VDI 133 : Non D‚finit ///

UnDefVDI133
	RTS

; /// VDI 134 : Non D‚finit ///

UnDefVDI134
	RTS

; /// VDI 135 : Non D‚finit ///

UnDefVDI135
	RTS

; /// VDI 136 : Non D‚finit ///

UnDefVDI136
	RTS

; /// VDI 137 : Non D‚finit ///

UnDefVDI137
	RTS

; /// VDI 138 : Non D‚finit ///

UnDefVDI138
	RTS

; /// VDI 139 : Non D‚finit ///

UnDefVDI139
	RTS

; /// VDI 140 : Non D‚finit ///

UnDefVDI140
	RTS

; /// VDI 141 : Non D‚finit ///

UnDefVDI141
	RTS

; /// VDI 142 : Non D‚finit ///

UnDefVDI142
	RTS

; /// VDI 143 : Non D‚finit ///

UnDefVDI143
	RTS

; /// VDI 144 : Non D‚finit ///

UnDefVDI144
	RTS

; /// VDI 145 : Non D‚finit ///

UnDefVDI145
	RTS

; /// VDI 146 : Non D‚finit ///

UnDefVDI146
	RTS

; /// VDI 147 : Non D‚finit ///

UnDefVDI147
	RTS

; /// VDI 148 : Non D‚finit ///

UnDefVDI148
	RTS

; /// VDI 149 : Non D‚finit ///

UnDefVDI149
	RTS

; /// VDI 150 : Non D‚finit ///

UnDefVDI150
	RTS

; /// VDI 151 : Non D‚finit ///

UnDefVDI151
	RTS

; /// VDI 152 : Non D‚finit ///

UnDefVDI152
	RTS

; /// VDI 153 : Non D‚finit ///

UnDefVDI153
	RTS

; /// VDI 154 : Non D‚finit ///

UnDefVDI154
	RTS

; /// VDI 155 : Non D‚finit ///

UnDefVDI155
	RTS

; /// VDI 156 : Non D‚finit ///

UnDefVDI156
	RTS

; /// VDI 157 : Non D‚finit ///

UnDefVDI157
	RTS

; /// VDI 158 : Non D‚finit ///

UnDefVDI158
	RTS

; /// VDI 159 : Non D‚finit ///

UnDefVDI159
	RTS

; /// VDI 160 : Non D‚finit ///

UnDefVDI160
	RTS

; /// VDI 161 : Non D‚finit ///

UnDefVDI161
	RTS

; /// VDI 162 : Non D‚finit ///

UnDefVDI162
	RTS

; /// VDI 163 : Non D‚finit ///

UnDefVDI163
	RTS

; /// VDI 164 : Non D‚finit ///

UnDefVDI164
	RTS

; /// VDI 165 : Non D‚finit ///

UnDefVDI165
	RTS

; /// VDI 166 : Non D‚finit ///

UnDefVDI166
	RTS

; /// VDI 167 : Non D‚finit ///

UnDefVDI167
	RTS

; /// VDI 168 : Non D‚finit ///

UnDefVDI168
	RTS

; /// VDI 169 : Non D‚finit ///

UnDefVDI169
	RTS

; /// VDI 170 : Non D‚finit ///

UnDefVDI170
	RTS

; /// VDI 171 : Non D‚finit ///

UnDefVDI171
	RTS

; /// VDI 172 : Non D‚finit ///

UnDefVDI172
	RTS

; /// VDI 173 : Non D‚finit ///

UnDefVDI173
	RTS

; /// VDI 174 : Non D‚finit ///

UnDefVDI174
	RTS

; /// VDI 175 : Non D‚finit ///

UnDefVDI175
	RTS

; /// VDI 176 : Non D‚finit ///

UnDefVDI176
	RTS

; /// VDI 177 : Non D‚finit ///

UnDefVDI177
	RTS

; /// VDI 178 : Non D‚finit ///

UnDefVDI178
	RTS

; /// VDI 179 : Non D‚finit ///

UnDefVDI179
	RTS

; /// VDI 180 : Non D‚finit ///

UnDefVDI180
	RTS

; /// VDI 181 : Non D‚finit ///

UnDefVDI181
	RTS

; /// VDI 182 : Non D‚finit ///

UnDefVDI182
	RTS

; /// VDI 183 : Non D‚finit ///

UnDefVDI183
	RTS

; /// VDI 184 : Non D‚finit ///

UnDefVDI184
	RTS

; /// VDI 185 : Non D‚finit ///

UnDefVDI185
	RTS

; /// VDI 186 : Non D‚finit ///

UnDefVDI186
	RTS

; /// VDI 187 : Non D‚finit ///

UnDefVDI187
	RTS

; /// VDI 188 : Non D‚finit ///

UnDefVDI188
	RTS

; /// VDI 189 : Non D‚finit ///

UnDefVDI189
	RTS

; /// VDI 190 : Non D‚finit ///

UnDefVDI190
	RTS

; /// VDI 191 : Non D‚finit ///

UnDefVDI191
	RTS

; /// VDI 192 : Non D‚finit ///

UnDefVDI192
	RTS

; /// VDI 193 : Non D‚finit ///

UnDefVDI193
	RTS

; /// VDI 194 : Non D‚finit ///

UnDefVDI194
	RTS

; /// VDI 195 : Non D‚finit ///

UnDefVDI195
	RTS

; /// VDI 196 : Non D‚finit ///

UnDefVDI196
	RTS

; /// VDI 197 : Non D‚finit ///

UnDefVDI197
	RTS

; /// VDI 198 : Non D‚finit ///

UnDefVDI198
	RTS

; /// VDI 199 : Non D‚finit ///

UnDefVDI199
	RTS

; /// VDI 200 : Non D‚finit ///

UnDefVDI200
	RTS

; /// VDI 201 : Non D‚finit ///

UnDefVDI201
	RTS

; /// VDI 202 : Non D‚finit ///

UnDefVDI202
	RTS

; /// VDI 203 : Non D‚finit ///

UnDefVDI203
	RTS

; /// VDI 204 : Non D‚finit ///

UnDefVDI204
	RTS

; /// VDI 205 : Non D‚finit ///

UnDefVDI205
	RTS

; /// VDI 206 : Non D‚finit ///

UnDefVDI206
	RTS

; /// VDI 207 : Non D‚finit ///

UnDefVDI207
	RTS

; /// VDI 208 : Non D‚finit ///

UnDefVDI208
	RTS

; /// VDI 209 : Non D‚finit ///

UnDefVDI209
	RTS

; /// VDI 210 : Non D‚finit ///

UnDefVDI210
	RTS

; /// VDI 211 : Non D‚finit ///

UnDefVDI211
	RTS

; /// VDI 212 : Non D‚finit ///

UnDefVDI212
	RTS

; /// VDI 213 : Non D‚finit ///

UnDefVDI213	
	RTS

; /// VDI 214 : Non D‚finit ///

UnDefVDI214	
	RTS

; /// VDI 215 : Non D‚finit ///

UnDefVDI215	
	RTS

; /// VDI 216 : Non D‚finit ///

UnDefVDI216	
	RTS

; /// VDI 217 : Non D‚finit ///

UnDefVDI217	
	RTS

; /// VDI 218 : Non D‚finit ///

UnDefVDI218	
	RTS

; /// VDI 219 : Non D‚finit ///

UnDefVDI219	
	RTS

; /// VDI 220 : Non D‚finit ///

UnDefVDI220	
	RTS

; /// VDI 221 : Non D‚finit ///

UnDefVDI221	
	RTS

; /// VDI 222 : Non D‚finit ///

UnDefVDI222	
	RTS

; /// VDI 223 : Non D‚finit ///

UnDefVDI223	
	RTS

; /// VDI 224 : Non D‚finit ///

UnDefVDI224	
	RTS

; /// VDI 225 : Non D‚finit ///

UnDefVDI225	
	RTS

; /// VDI 226 : Non D‚finit ///

UnDefVDI226	
	RTS

; /// VDI 227 : Non D‚finit ///

UnDefVDI227	
	RTS

; /// VDI 228 : Non D‚finit ///

UnDefVDI228	
	RTS

; /// VDI 229 : Non D‚finit ///

UnDefVDI229	
	RTS

; /// VDI 230 : Non D‚finit ///

UnDefVDI230	
	RTS

; /// VDI 231 : Non D‚finit ///

UnDefVDI231	
	RTS
	
; /// VDI 232 : VQT_FONTHEADER () ///

Vqt_FontHeader	

	move.w	#232,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 233 : Non D‚finit ///

UnDefVDI233	
	RTS

; /// VDI 234 : VQT_TRACKKERN () ///

Vqt_TrackKern	

	move.w	#234,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 235 : VQT_PAIRKERN () ///

Vqt_PairKern	

	move.w	#235,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 236 : VST_CHARMAP () ///

Vst_CharMap	

	move.w	#236,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI 237 : VST_KERN () ///

Vst_Kern	

	move.w	#237,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI 238 : Non D‚finit ///

UnDefVDI238	
	RTS

; /// VDI 239 : V_GETBITMAT_INFO () ///

V_GetBitMap_Info	

	move.w	#239,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI 240 : VQT_F_EXTENT () ///

Vqt_F_Extent	

	move.w	#240,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 241 : V_FTEXT () ///

V_FText	

	move.w	#241,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 242 : V_FTEXT_OFFSET () ///

V_FText_OffSet	

	move.w	#242,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 243 : V_GETOUTLINE () ///

V_GetOutLine	

	move.w	#243,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 244 : VST_SCRATCH () ///

Vst_Scratch	

	move.w	#244,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 245 : VST_ERROR () ///

Vst_Error	

	move.w	#245,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS

; /// VDI 246 : VST_ARBPT () ///

Vst_ArbPt	

	move.w	#246,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 247 : VQT_ADVANCE () ///

Vqt_Advance	

	move.w	#247,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 248 : VQT_DEVINFO () ///

Vqt_DevInfo	

	move.w	#248,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 249 : V_SAVECACHE () ///

V_SaveCache	
	
	move.w	#249,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 250 : V_LOADCACHE () ///

V_LoadCache	

	move.w	#250,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 251 : V_FLUSHCACHE () ///

V_FlushCache	

	move.w	#251,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 252 : VST_SETSIZE() ///

Vst_SetSize	

	move.w	#252,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 253 : VST_SKEW () ///

Vst_Skew	

	move.w	#253,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 254 : VQT_GET_TABLE () ///

Vqt_Get_Table	

	move.w	#254,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI 255 : VQT_CACHESIZE () ///

Vqt_CacheSize	

	move.w	#255,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
; /// VDI -1 : V_SET_APP_BUFF ///

V_Set_App_Buff	

	move.w	#-1,([A1])		; OpCode dans Contrl0
	clr.w	([A1],2)		; Contrl1
	clr.w	([A1],4)		; Contrl2
	clr.w	([A1],6)		; Contrl3
	clr.w	([A1],8)		; Contrl4

	move.w	#115,D0
	move.l	(8,SP),D1		; VDI_PARAMS
	move.l	A1,-(SP)
	trap	#2		; *** AES/VDI ***
	move.l	(SP)+,A1

	RTS
	
	SECTION	DATA
	
Cookie_Name	dc.b	"SSAV"
Good_Install	dc.b	10,13,10,13,27,"p// STALLION SOFTWARE'S AES-VDI CALL¿ //",27,"q",10,13
	dc.b	"//////// >>> NOW Installed <<< ////////",10,13,10,13,0
Bad_Install	dc.b	10,13,10,13,27,"p// STALLION SOFTWARE'S AES-VDI CALL¿ //",27,"q",10,13
	dc.b	"//////// >>> ",27,"pNOT",27,"q Installed <<< ////////",10,13,10,13,0
AlReady_Install	dc.b	10,13,10,13,27,"p// STALLION SOFTWARE'S AES-VDI CALL¿ //",27,"q",10,13
	dc.b	"////// >>> ",27,"pALREADY",27,"q Installed <<< //////",10,13,10,13,0
NUM_PseudoFloat	dc.b	%00000000,%00000000,%00000010,%01110011	; Great 128BITs number
	dc.b	%11001110,%10011100,%10000111,%11110001	; for Floating part
	dc.b	%10100100,%00011101,%00010010,%11111111
	dc.b	%01000010,%00111101,%10101111,%11000000
	
	SECTION	BSS
	
SSAV_Wk1Buff	ds.b	256
SSAV_Wk2Buff	ds.b	256
SSAV_Wk3Buff	ds.b	64