; /// INSTALLATEUR Version >Normale< DE SSAV POUR VOTRE APPLICATION ///
;
; Taille incompressible : 4833 octets (assembl‚ tel quel, et STRIP‚)
;
; Veuillez suivre les conseils...
; TAB=24 SCREEN=768/576

	output	MONPROG.PRG

	SECTION	TEXT	; Le programme
	
; On commence par demander si SSAV est l…...
; Si au retour, on retrouve "SSAV", c'est que la routine n'est pas install‚e.
; Sinon on obtient l'adresse de la routine dans D0, … la place de "SSAV".

	move.l	#"SSAV",D0
	trap	#2	; *** AES/VDI ***
	
	cmpi.l	#"SSAV",D0
	BEQ	Not_Installed	; On travaille normalement

	move.l	D0,SSAV_Adr	; On garde l'adresse

	JSR	Init_Tabs

	include	MONPROG.S

; ***
; Mettez votre programme ICI
; ***
		
; Ici, on va tout faire normalement, vu que SSAVCALL n'est pas install‚,
; et on va l'en avertir l'utilisateur … travers une petite interface GEM.
; Vous allez voir comment on fait en assembleur sans SSAVCALL.

Not_Installed	movea.l	4(SP),A6	; Adresse de la BasePage
	move.l	$C(A6),D0	; Taille du SEGMENT TEXT
	add.l	$14(A6),D0	; Additionne la taille du SEGMENT DATA … D0
	add.l	$1C(A6),D0	; Additionne la taille du SEGMENT BSS … D0
	addi.l	#$100,D0	; Additionne la taille de la BasePage … D0
	addi.l	#$400,D0	; Additionne la taille de la future PILE (Ici, 256 mots longs (1 Ko))
	move.l	D0,D1	; Copie D0 dans D1 (Taille … r‚server)
	add.l	A6,D1	; Additionne l'adresse du d‚but du programme avec D1 (La taille … r‚server)
	andi.l	#-2,D1	; Rend D1 pair (Au cas o— il ne l'‚tait pas)
	movea.l	D1,SP	; Installe l'adresse de fin du programme+place nouvelle PILE dans la PILE
	move.l	A6,4(SP)	; Adresse de la BasePage
	move.l	D0,-(SP)	; EmPILE la taille … reserver	\
	move.l	A6,-(SP)	; EmPILE l'adresse du programme |-> Rend le reste de la m‚moire au systŠme
	clr.w	-(SP)	; R‚serv‚                       |
	move.w	#$4A,-(SP)	; - M_SHRINK -                  |
	trap	#1	; *** GEMDOS ***                /
	lea	12(SP),SP

	JSR	Init_Tabs
		
	; APPL_INIT	

	lea	Control,A0
	move.l	#$A000100,D0
	movep.l	D0,(1,A0)
	
	BSR	AES_Call
	
	lea	Int_Out,A0
	move.w	(A0),D0
	BMI	P_Term0	; Si echec
	
	move.w	D0,AES_Handle	; L'AP_ID

	; GRAF_MOUSE, pour rendre l'aspect normal … la souris
	
	lea	Control,A0
	move.l	#$4E010100,D0
	movep.l	D0,(1,A0)
	
	move.w	#0,Int_In
	
	BSR	AES_Call

	; RSRC_OBFIX, on reloge la ressource,
	; et on corrige les infos
	
	move.w	#13,D7
	clr.w	D6
	
Reloc_RSC	lea	Control,A0
	move.l	#$72010101,D0
	movep.l	D0,(1,A0)
	
	move.w	D6,Int_In
	move.l	Rs_trindex,Addr_In
	
	BSR	AES_Call
	
	addq.w	#1,D6
	
	DBF	D7,Reloc_RSC

	; FORM_CENTER, pour centrer

	lea	Control,A0
	move.l	#$36000501,D0
	movep.l	D0,(1,A0)
	
	move.l	Rs_trindex,Addr_In	; L'adresse de l'arbre
	
	BSR	AES_Call
	
	lea	Int_Out,A0
	move.l	(2,A0),-(SP)
	move.l	(6,A0),-(SP)
	
	; FORM_DIAL, pour r‚server
	; On touche pas aux valeurs renvoy‚es par FORM_CENTER
	
	lea	Control,A0
	move.l	#$33090100,D0
	movep.l	D0,(1,A0)
	
	lea	Int_In,A0
	clr.w	(A0)
	move.l	(2,A0),(10,A0)
	move.l	(6,A0),(14,A0)
	
	BSR	AES_Call	

	; OBJC_DRAW, pour tracer
	
	lea	Control,A0
	move.l	#$2A060101,D0
	movep.l	D0,(1,A0)
	
	lea	Int_In,A0
	move.l	#4,(A0)+	; Depuis l'objet 0, sur 4 niveaux
	move.l	(4,SP),(A0)+	; Les coordonn‚es de FORM_CENTER
	move.l	(SP),(A0)+	; Les dimensions de FORM_CENTER
	
	move.l	Rs_trindex,Addr_In	; L'adresse de l'arbre
	
	BSR	AES_Call
	
	; FORM_DO, pour gerer
	
	lea	Control,A0
	move.l	#$32010101,D0
	movep.l	D0,(1,A0)
	
	move.w	#-1,Int_In	; Pas de champs ‚ditables
	
	move.l	Rs_trindex,Addr_In	; L'adresse de l'arbre
	
	BSR	AES_Call
	
	; FORM_DIAL, pour effacer
	
	lea	Control,A0
	move.l	#$33090100,D0
	movep.l	D0,(1,A0)
	
	lea	Int_In,A0
	move.w	#3,(A0)+
	move.l	(4,SP),(A0)+	; Les coordonn‚es de FORM_CENTER
	move.l	(SP),(A0)+	; Les dimensions de FORM_CENTER
	move.l	(4,SP),(A0)+	; Les coordonn‚es de FORM_CENTER
	move.l	(SP),(A0)+	; Les dimensions de FORM_CENTER

	addq.l	#8,SP	; On restaure vu que l'on … plus besoin des valeurs
	
	BSR	AES_Call

	; APPL_EXIT

	lea	Control,A0
	move.l	#$13000100,D0
	movep.l	D0,(1,A0)
	
	BSR	AES_Call

	; P_TERM0

P_Term0	clr.w	-(SP)
	trap	#1

AES_Call	move.l	#200,D0
	move.l	#AES_Params,D1
	trap	#2	; *** AES/VDI ***

	RTS
	
Init_Tabs	lea	AES_Params,A0	; On pr‚pare … la main les tableaux du GEM
	move.l	#Control,(A0)+
	move.l	#Global,(A0)+
	move.l	#Int_In,(A0)+
	move.l	#Int_Out,(A0)+
	move.l	#Addr_In,(A0)+
	move.l	#Addr_Out,(A0)+
	
	lea	VDI_Params,A0
	move.l	#Contrl,(A0)+
	move.l	#IntIn,(A0)+
	move.l	#PtsIn,(A0)+
	move.l	#IntOut,(A0)+
	move.l	#PtsOut,(A0)+

	RTS

	SECTION	DATA	; Les donn‚es
	
	include	DATAS\IVN_INST.RSM	; La ressource
	
	SECTION	BSS	; Les variables
	
SSAV_Adr	ds.l	1	; L'adresse de la routine

; /// LES VARIABLES DE L'AES ///

AES_Handle	ds.w	1
Control	ds.w	5
Global	ds.w	14
Int_In	ds.w	16
Int_Out	ds.w	7
Addr_In	ds.l	3
Addr_Out	ds.l	1
AES_Params	ds.l	6

; /// LES VARIABLES DU VDI ///

VDI_Handle	ds.w	1
Contrl	ds.w	12
IntIn	ds.w	64	; Minimum 30
IntOut	ds.w	64	; Minimum 45
PtsIn	ds.w	64	; Minimum 30
PtsOut	ds.w	64	; Minimum 12
VDI_Params	ds.l	5
