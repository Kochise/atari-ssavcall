; ////////////////////////////////////////
; /// SSAV Testing Rout By KOSS - 1997 ///
; ////////////////////////////////////////
; /// Let Your Mind Explode The Limits ///
;
; Set Tab To 16 In A Screen Of 768 Pixel Wide
; Great Falcon Screen, You Help Me A Lot SomeTimes

	SECTION	TEXT

; > Initialisation du programme

Init_PRG_Mem	movea.l	4(SP),A6		; Adresse de la BasePage
	move.l	$C(A6),D0		; Taille du SEGMENT TEXT
	add.l	$14(A6),D0		; Additionne la taille du SEGMENT DATA … D0
	add.l	$1C(A6),D0		; Additionne la taille du SEGMENT BSS … D0
	addi.l	#$100,D0		; Additionne la taille de la BasePage … D0
	addi.l	#$400,D0		; Additionne la taille de la future PILE (Ici, 256 mots longs (1 Ko))
	move.l	D0,D1		; Copie D0 dans D1 (Taille … r‚server)
	add.l	A6,D1		; Additionne l'adresse du d‚but du programme avec D1 (La taille … r‚server)
	andi.l	#-2,D1		; Rend D1 pair (Au cas o— il ne l'‚tait pas)
	movea.l	D1,SP		; Installe l'adresse de fin du programme+place nouvelle PILE dans la PILE
	move.l	A6,4(SP)		; Adresse de la BasePage
	move.l	D0,-(SP)		; EmPILE la taille … reserver	\
	move.l	A6,-(SP)		; EmPILE l'adresse du programme |-> Rend le reste de la m‚moire au systŠme
	clr.w	-(SP)		; R‚serv‚                       |
	move.w	#$4A,-(SP)		; - M_SHRINK -                  |
	trap	#1		; *** GEMDOS ***                /
	lea	12(SP),SP

	tst	D0		; Si D0<>0, problŠme grave
	BNE	TOS_Warp

	lea	AES_Params,A0		; On pr‚pare … la main les tableaux du GEM
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

; > Initialisation des differentes routines

Init_Prog	BSR	SSAV_INSTALL
	tst.w	D0
	BMI	TOS_Warp
	BSR	APPL_INIT

	clr.w	D0		; Pointeur normal
	BSR	GRAF_MOUSE

; > D‚but de la gestion (Quoi! on y est d‚j…, aprŠs si peu de lignes?)

Main_Prog	move.l	#RSC_Name,-(SP)
	BSR	RSRC_LOAD		; Je charge
	addq.l	#4,SP

	BSR	Init_SSAVMenu

	BSR	Watch_Reso		; On v‚rifie que l'on … un 640*400 minimum
	BMI	Take_Exit
	
	BSR	Disp_VerNum		; On place le num‚ro de version
	
	clr.l	D0		; Premier Arbre (le logo SSAV)
	BSR	Aff_SingleForm		; Gestion simpliste d'un formulaire
	
	cmpi.w	#6,D0		; La touche "RETURN TO TOS"
	BEQ	Clr_Before_Quit		; Histoire d'avoir de la gueule sous MultiTOS

	BSR	Clr_SingleForm		; On efface

; > En enlevant le ;Sound qui pr‚cedent les lignes suivantes, vous sonorisez le programme (utilisez Search/Replace All)
	
;Sound	pea	Welcome_SPL		; Sinon trompette
;Sound	clr.w	-(SP)
;Sound	clr.w	-(SP)
;Sound	move.w	#1,-(SP)		; Normal
;Sound	pea	AES_Params
;Sound	move.w	#59,-(SP)		; - SSForm_Sound -
;Sound	move.w	#200,-(SP)		; *** AES ***
;Sound	JSR	([SSAV_Adr])
;Sound	lea	(18,SP),SP
	
	move.l	#$10000,D0		; Deuxieme Arbre (y'a ma tˆte)

	BSR	Aff_SingleForm		; On se fatigue pas trop
	
	BSR	Clr_SingleForm		; De toute maniere, le seul bouton sert … continuer

; > Comme tout … l'heure (y'en a d'autre au cours du programme, cherchez les)

;Sound	pea	Start_SPL		; Pouet pouet
;Sound	clr.w	-(SP)
;Sound	clr.w	-(SP)
;Sound	move.w	#1,-(SP)		; Normal
;Sound	pea	AES_Params
;Sound	move.w	#59,-(SP)		; - SSForm_Sound -
;Sound	move.w	#200,-(SP)		; *** AES ***
;Sound	JSR	([SSAV_Adr])
;Sound	lea	(18,SP),SP

; > D‚but des hostilit‚s : on va dans la boucle de gestion du menu g‚n‚ral

	BSR	Desk_Loop		; On en resortira plus tard, et on tombera sur la sortie

Take_Exit
;Sound	pea	Exit_SPL		; Shade Song From WinDaube (comme quoi nous aussi on peut le faire...)
;Sound	clr.w	-(SP)
;Sound	clr.w	-(SP)
;Sound	move.w	#1,-(SP)		; Normal
;Sound	pea	AES_Params
;Sound	move.w	#59,-(SP)		; - SSForm_Sound -
;Sound	move.w	#200,-(SP)		; *** AES ***
;Sound	JSR	([SSAV_Adr])
;Sound	lea	(18,SP),SP

; > On nettoie tout correctement derriere soit, histoire de laisser l'endroit comme on l'avait trouv‚

	BSR	RSRC_FREE		; On efface la ressource
	BSR	APPL_EXIT		; On dit que c'est tout pour aujourd'hui
	BSR	SSAV_EXIT		; On fait revenir SSAV … son stade initial

;Sound	move.w	#2,-(SP)		; D‚sinstallle
;Sound	pea	AES_Params
;Sound	move.w	#59,-(SP)		; - SSForm_Sound -
;Sound	move.w	#200,-(SP)		; *** AES ***
;Sound	JSR	([SSAV_Adr])
;Sound	lea	(10,SP),SP
	
	clr.w	D1
TOS_Warp	move.w	D1,-(SP)		
	move.w	#$4C,-(SP)		; - P_TERM -
	trap	#1		; *** GEMDOS ***

; > On efface l'arbre si l'on d‚sire sortir des le premier formulaire

Clr_Before_Quit	clr.l	D0		; Premier Arbre (le logo SSAV)
				; Cette routine ne sert que pour effacer
				; pr‚maturement le premier formulaire
	BSR	Clr_SingleForm		; On efface
	
	BRA	Take_Exit		; On s'casse

; > V‚rification de la r‚solution. Le nombre renvoy‚ par la fonction XBIOS ne sert … rien.
;   Ici, on demande le nombre de pixels verticalement et horizontalement.

Watch_Reso	BSR	GRAF_HANDLE		; On cherche le Handle de la station VDI actuelle (le bureau)
	
	move.l	D0,A0
	move.w	(A0),D0		; VDI Handle
	
	BSR	VQ_EXTND		; On demande les infos
	
	move.l	D1,A0
	move.w	(A0),D0
	cmpi.w	#639,D0
	BLT	Reso_Error		; Reso trop faible
	move.w	(2,A0),D0
	cmpi.w	#399,D0
	BLT	Reso_Error		; Reso trop faible

	BRA	Exit_Watching		; No Problem

Reso_Error	moveq.l	#5,D0		; Alerte
	BSR	RSRC_GADDR
	BEQ	Watch_Error
	BSR	FORM_ALERT
	
	cmpi.w	#1,D0
	BNE	Watch_Error
;	BNE	Exit_Watching
	
Watch_Error	move.w	#-1,D0		; Retour au Bureau

Exit_Watching	RTS

; > Sert … inscrire le num‚ro de version de SSAV dans le premier formulaire.
;   Exemple d'utilisation des nombres BCD (voyez CONV_DISPNUM, X AES 60)

Disp_VerNum	move.l	#8,D0		; Adresse du pointeur du premier TE_PTEXT
	BSR	RSRC_GADDR
	
	move.l	D0,A0		; Adresse du pointeur
	move.l	(A0),A0		; On pointe le TE_PTEXT
	
Look_EmptyChar	move.b	(A0),D0
	cmpi.b	#45,D0		; -
	BEQ	Next_EmptyChar
	addq.l	#1,A0
	BRA	Look_EmptyChar
	
Next_EmptyChar	move.w	(-6,[SSAV_Adr]),D1	; Num‚ro de version de SSAV en m‚moire

	BSR	Rol_VerNum		; Premier chiffre

	BNE	Write_VerNum0
	move.b	#32,(A0)+
	BRA	LooK_VerNum1

Write_VerNum0	BSR	Correct_ASCII	

LooK_VerNum1	BSR	Rol_VerNum		; Deuxieme chiffre
	BSR	Correct_ASCII	
	
	addq.l	#1,A0		; On passe le point

	BSR	Rol_VerNum		; Troisieme chiffre
	BSR	Correct_ASCII	

	BSR	Rol_VerNum		; Quatrieme chiffre
	BSR	Correct_ASCII

	RTS

Rol_VerNum	rol.w	#4,D1
	move.b	D1,D0
	andi.b	#%1111,D0


	RTS
	
Correct_ASCII	add.b	#48,D0		; 0
	move.b	D0,(A0)+	

	RTS

; /// Le menu g‚n‚ral ///

; > La boucle d'attente d'un ‚venement qui nous interesse.

Desk_Loop	move.l	#$30000,D0		; Le Premier Menu
	BSR	Aff_Menu

	BSR	Wait_Desk		; On attend ... patiement

	move.l	#$30000,D0		; Le Premier Menu
	BSR	Clr_Menu

	RTS

Wait_Desk	move.l	#Messag_Tab,D0
	BSR	EVNT_MESAG		; Attend un Mess-Age
	
	lea	Messag_Tab,A0
	move.w	(A0),D0		; Le type
	cmpi.w	#10,D0		; Un evenement Menu?
	BNE	Wait_Desk
	
	BSR	Wait_Loop
	tst.w	D0
	BMI	Exit_Wait		; Quoi que ce soit d'autre
	
	BRA	Wait_Desk		; Qui a dit que l'on voulait sortir?

Exit_Wait	RTS

; > Le grand saut suivant l'‚venement re‡u.

Wait_Loop	pea	Menu_Return		; On se pr‚pare au retour

	lea	Messag_Tab,A0
	move.w	(8,A0),D0		; Le num‚ro de l'Entr‚e
	cmpi.w	#23,D0		
	BGE	Menu_Exit		; Oups...
	lea	Menu_Jump,A1
	JMP	(A1,D0.w*4)		; Warp (un BRA prend 4 octets)
	RTS			; On met un filet, au cas ou

Menu_Jump	BRA	Menu_Exit		; c'est quoi l'Objet 0?
	BRA	Menu_Exit		; Et le 1?
	BRA	Menu_Exit		; Et le 2?
	BRA	Menu_Exit		; ATARI
	BRA	Menu_Exit		; Gestion
	BRA	Menu_Exit		; Try YourSelf
	BRA	Menu_Exit		; I-Box
	BRA	Menu_Exit		; La Box ATARI
	BRA	Desk_Infos		; A Propos De...
	BRA	Menu_Exit		; La ligne
	BRA	Menu_Exit		; Acc 1
	BRA	Menu_Exit		; Acc 2
	BRA	Menu_Exit		; Acc 3
	BRA	Menu_Exit		; Acc 4
	BRA	Menu_Exit		; Acc 5
	BRA	Menu_Exit		; Acc 6
	BRA	Menu_Exit		; La Box Gestion
	BRA	Philo		; Philosophie
	BRA	Menu_Exit		; La ligne
	BRA	Quit		; Quitter
	BRA	Menu_Exit		; La Box Try YourSelf
	BRA	Menu_AES		; AES
	BRA	Menu_VDI		; VDI
                
Menu_Return	move.w	D0,-(SP)
	lea	Messag_Tab,A0
	move.w	(6,A0),D0       
	BSR	MENU_TNORMAL
	move.w	(SP)+,D0

Menu_Exit	RTS			; On sort de la gestion

; > Le formulaire d'information.

Desk_Infos	
;Sound	pea	Rythm_SPL		; Un peu de RAP...
;Sound	clr.w	-(SP)
;Sound	clr.w	-(SP)
;Sound	move.w	#3,-(SP)		; Loop
;Sound	pea	AES_Params
;Sound	move.w	#59,-(SP)		; - SSForm_Sound -
;Sound	move.w	#200,-(SP)		; *** AES ***
;Sound	JSR	([SSAV_Adr])
;Sound	lea	(18,SP),SP

	move.l	#$20000,D0		; Troisieme Arbre
	BSR	Aff_SingleForm		; On se fatigue pas trop
	BSR	Clr_SingleForm		; De toute maniere, le seul bouton sert … continuer

;Sound	clr.w	-(SP)		; Stop
;Sound	pea	AES_Params
;Sound	move.w	#59,-(SP)		; - SSForm_Sound -
;Sound	move.w	#200,-(SP)		; *** AES ***
;Sound	JSR	([SSAV_Adr])
;Sound	lea	(10,SP),SP

	RTS
	
Quit	move.w	#-1,D0
	RTS

; > Le formulaire sur la philosophie du GEM.
	
Philo	
	RTS

; > On change de menu => Menu AES

Menu_AES	BSR	HiMenu

	move.l	#$30000,D0		; Le Premier Menu
	BSR	Clr_Menu

	BSR	RSRC_FREE

	move.l	#AES_Name,-(SP)
	BSR	RSRC_LOAD		; Je charge
	addq.l	#4,SP

	BSR	Init_AESMenu

	clr.l	D0		; Le Menu AES
	BSR	Aff_Menu

	BSR	Wait_AES		; On saute … la gestion du Menu AES

	BSR	ByeMenu		; On ferme des portes

	clr.l	D0
	BSR	Clr_Menu
	
	BSR	RSRC_FREE
	
	move.l	#RSC_Name,-(SP)
	BSR	RSRC_LOAD		; Je charge
	addq.l	#4,SP

	BSR	Init_SSAVMenu

	move.l	#$30000,D0		; Le Menu G‚n‚ral
	BSR	Aff_Menu

	lea	Messag_Tab,A0
	move.w	#5,(6,A0)		; Histoire que le Titre Try YourSelf revienne en normal

	RTS
	
; > On change de menu => Menu VDI
	
Menu_VDI	BSR	HiMenu		; Un petit son

	move.l	#$30000,D0		; Le Premier Menu
	BSR	Clr_Menu
	
	BSR	RSRC_FREE
	
	move.l	#VDI_Name,-(SP)
	BSR	RSRC_LOAD		; Je charge
	addq.l	#4,SP

	BSR	Init_VDIMenu

	clr.l	D0		; Le Menu VDI
	BSR	Aff_Menu

	BSR	Wait_VDI		; On saute … la gestion du Menu VDI

	BSR	ByeMenu

	clr.l	D0
	BSR	Clr_Menu
	
	BSR	RSRC_FREE
	
	move.l	#RSC_Name,-(SP)
	BSR	RSRC_LOAD		; Je charge
	addq.l	#4,SP

	BSR	Init_SSAVMenu

	move.l	#$30000,D0		; Le Menu G‚n‚ral
	BSR	Aff_Menu

	lea	Messag_Tab,A0
	move.w	#5,(6,A0)		; Histoire que le Titre Try YourSelf revienne en normal

	RTS

; > On pr‚pare le menu SSAV.

Init_SSAVMenu	move.w	#1,D2
	lea	SSAVMenu_Txt,A6

Copy_SSAVMenu	BSR	AccMenu_Copy

	DBF	D2,Copy_SSAVMenu
	
	RTS
	
; > On pr‚pare le menu AES.

Init_AESMenu	lea	AESMenu_Txt,A6
	
	BSR	AccMenu_Copy

	RTS
	
; > On pr‚pare le menu VDI.

Init_VDIMenu	move.w	#13,D2
	lea	VDIMenu_Txt,A6

Copy_VDIMenu	BSR	AccMenu_Copy

	DBF	D2,Copy_VDIMenu

	RTS

; > Copie du mot dans la ligne des accessoires.

AccMenu_Copy	move.w	(A6)+,D0
	swap	D0
	move.w	#7,D0		; R_OBSPEC
	BSR	RSRC_GADDR
	
	move.l	D0,A0
	move.l	(A0),A0
	addq.l	#2,A0
	
	BSR	CharCopy

	RTS
	
; > Copie du texte dans la ligne de s‚paration.
	
CharCopy	move.b	(A6)+,D0
	BEQ	Exit_CharCopy
	move.b	D0,(A0)+
	
	BRA	CharCopy
	
Exit_CharCopy	RTS

; /// Le menu AES ///

Wait_AES	include	TESTMAES.SM

; /// Le menu VDI ///

Wait_VDI	include	TESTMVDI.SM

; /// Les routines de fonction des menus ///

Aff_Menu	BSR	RSRC_GADDR		; J'obtient l'adresse
	move.l	D0,Menu_Adr
	move.w	#1,D1		; Affiche
	BSR	MENU_BAR

	RTS

Clr_Menu	BSR	RSRC_GADDR		; J'obtient l'adresse
	move.l	D0,Menu_Adr
	clr.w	D1		; Efface
	BSR	MENU_BAR

	RTS

Title_Normal	BSR	RSRC_GADDR		; J'obtient l'adresse
	move.l	D0,Tree_Adr
	move.w	D2,D0		; Le Titre
	BSR	MENU_TNORMAL		; On deselectionne le Titre
	
	RTS

; /// Les differentes routines d'applications ///

; > On pr‚pare SSAV.

SSAV_INSTALL	clr.l	-(SP)
	move.w	#$20,-(SP)		; - SUPER -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	move.l	D0,D6

	move.l	$5A0.w,D1
	BEQ	Any_SSAV
	
	movea.l	D1,A0		; On pointe le premier Cookie

	clr.w	D3
	suba.l	#4,A0
	
Look_For_Null	addq.w	#1,D3
	adda.l	#4,A0
	move.l	(A0)+,D0
	BNE	Look_For_Null		; On cherche le Cookie NULL (0)
				
	move.l	(A0),D2		; Nombre de Cookie
	
	movea.l	D1,A0		; On recommence...
	
	suba.l	#4,A0
	move.l	SSAV_Name,D1
		
Look_For_SSAV	subq.l	#1,D3
	BMI	Any_SSAV
	adda.l	#4,A0
	move.l	(A0)+,D0
	cmp.l	D1,D0
	BNE	Look_For_SSAV
	
	move.l	A0,D4
	subq.l	#4,D4		; Adresse du Cookie
	move.l	(A0),D5		; Adresse de la routine
	movea.l	D5,A0
	suba.l	#6,A0
	
	move.w	(A0),D0		; Le num‚ro de Version
	move.w	SSAV_Version,D1
	cmp.w	D0,D1
	BGT	Any_SSAV		; La Version est obsolŠte

	move.l	D5,SSAV_Adr		; C'est tout bon...
	move.l	D4,Cookie_Adr
	movea.l	D5,A0
	suba.l	#2,A0
	move.w	(A0),D0
	addq.w	#1,D0		; On pr‚cise qu'une nouvelle tƒche arrive
	move.w	D0,(A0)
	
	move.l	D6,-(SP)
	move.w	#$20,-(SP)		; - SUPER -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP

	BRA	End_Install
	
Any_SSAV	move.l	D6,-(SP)
	move.w	#$20,-(SP)		; - SUPER -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP

	move.l	#-1,Cookie_Adr		; Y'a Pas

	BSR	Define_CurrPath
		
	BSR	Take_Path
	
	lea	SSAV_Name,A1
Next_SSAV_Path	move.b	(A1)+,(A0)+
	BNE	Next_SSAV_Path		; On obtient le chemin complet
	
	clr.w	-(SP)		; Lecture
	pea	Tempo_Path
	move.w	#$3D,-(SP)		; - F_OPEN -
	trap	#1		; *** GEMDOS ***
	addq.l	#8,SP
	move.w	D0,D7

	clr.w	-(SP)		; D‚but
	move.w	D0,-(SP)
	move.l	#2,-(SP)		; Longueur des SECTIONs
	move.w	#$42,-(SP)		; - F_SEEK -
	trap	#1		; *** GEMDOS ***
	lea	10(SP),SP

	pea	Tempo_Path
	move.l	#$C,-(SP)		; Les 3 LONGs
	move.w	D7,-(SP)
	move.w	#$3F,-(SP)		; - F_READ -
	trap	#1		; *** GEMDOS ***
	lea	(12,SP),SP
	
	lea	Tempo_Path,A0
	move.l	(A0)+,D0		; Longueur de la SECTION TEXT
	add.l	(A0)+,D0		; Longueur de la SECTION DATA
	add.l	(A0)+,D0		; Longueur de la SECTION BSS
	add.l	#$1C,D0		; La taille du File Header
	move.l	D0,D6

	move.l	D0,-(SP)
	move.w	#$48,-(SP)		; - M_ALLOC -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	tst.l	D0
	BEQ	Error_MemAlloc
	move.l	D0,D5		; Adresse

	clr.w	-(SP)		; D‚but
	move.w	D7,-(SP)
	clr.l	-(SP)		; D‚but du fichier
	move.w	#$42,-(SP)		; - F_SEEK -
	trap	#1		; *** GEMDOS ***
	lea	10(SP),SP

	move.l	D5,-(SP)		; Adresse du FIELD
	move.l	D6,-(SP)		; Taille du fichier
	move.w	D7,-(SP)		; Handle
	move.w	#$3F,-(SP)		; - F_READ -
	trap	#1		; *** GEMDOS ***
	lea	(12,SP),SP
	
	add.l	#$128,D5		
	move.l	D5,SSAV_Adr				 	
	
Closer	move.w	D7,-(SP)
	move.w	#$3E,-(SP)		; - F_CLOSE -
	trap	#1		; *** GEMDOS ***
	addq.l	#4,SP
	
	BSR	Clr_Tempo_Path		; Important pour RSRC_LOAD
	
	clr.w	D0		; On fait gaffe (… cause du DBF (on termine avec -1 dans D0.w))
	
End_Install	RTS

; > On cherche le chemin courant.

Define_CurrPath	move.w	#$19,-(SP)		; - D_GETDRV -
	trap	#1		; *** GEMDOS ***
	addq.l	#2,SP

	lea	Tempo_Path,A0
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

; > Usine … gaz pour charger correctement une ressource.
	
RSRC_LOAD	BSR	Define_CurrPath

	BSR	Take_Path

	movea.l	(4,SP),A1
Copy_RSC_Name	move.b	(A1)+,(A0)+
	BNE	Copy_RSC_Name
	
	pea	Tempo_Path
	pea	AES_Params
	move.w	#110,-(SP)		; - RSRC_LOAD -
	move.w	#200,-(SP)		; *** AES ***
	JSR	([SSAV_Adr])
	lea	(12,SP),SP

	RTS

; > On se place au bon endroit.

Take_Path	lea	Tempo_Path,A0
Search_Null	addq.l	#1,A0
	move.b	(A0),D0
	BNE	Search_Null
	
	move.b	#92,(A0)+

	RTS

; > Affiche simplement un formulaire, et le gere sans se prendre la tˆte.

Aff_SingleForm	BSR	RSRC_GADDR		; J'obtient l'adresse du premier arbre
	move.l	D0,Tree_Adr
	BSR	FORM_CENTER		; Je centre
	move.l	D0,D7		; Int_Out1-...
	clr.w	D1
	BSR	FORM_DIAL		; Je r‚serve
	move.l	D7,D0
	BSR	OBJC_DRAW		; Je trace
	move.l	Tree_Adr,D0
	BSR	FORM_DO
	
	move.w	D0,Clicked_Button
	BSR	OBJC_CHANGE		; On deselectionne l'objet
	move.w	Clicked_Button,D0

	RTS

; > Efface le formulaire.
	
Clr_SingleForm	move.l	D7,D0
	move.w	#3,D1
	BSR	FORM_DIAL		; On libere

	RTS

; > Efface le buffer de travail, histoire qu'il n'y ait pas de problemes.
	
Clr_Tempo_Path	lea	Tempo_Path,A0
	move.w	#63,D0
Clr_Path	clr.l	(A0)+
	DBF	D0,Clr_Path
	
	RTS

; > Un petit son pour l'ouverture d'un nouveau menu.

HiMenu	
;Sound	pea	OpenMenu_SPL
;Sound	clr.w	-(SP)
;Sound	clr.w	-(SP)
;Sound	move.w	#1,-(SP)		; Normal
;Sound	pea	AES_Params
;Sound	move.w	#59,-(SP)		; - SSForm_Sound -
;Sound	move.w	#200,-(SP)		; *** AES ***
;Sound	JSR	([SSAV_Adr])
;Sound	lea	(18,SP),SP

	RTS

; > On ferme le menu.

ByeMenu	
;Sound	pea	CloseMenu_SPL
;Sound	clr.w	-(SP)
;Sound	clr.w	-(SP)
;Sound	move.w	#1,-(SP)		; Normal
;Sound	pea	AES_Params
;Sound	move.w	#59,-(SP)		; - SSForm_Sound -
;Sound	move.w	#200,-(SP)		; *** AES ***
;Sound	JSR	([SSAV_Adr])
;Sound	lea	(18,SP),SP

	RTS

; > Une librairie de macro pour SSAVCall 
;   -Pourquoi pas celles de HiSoft?
;   -Tu les as d‚j… vu?
;   -Ben oui, et...
;   -Ici c'est un exemple d'utilisation de S-S-A-V-Call...
;   -Ah oui, excuse!

	include	TESTUTIL.SM		; Les macros au secours du GEM

; > On cherche … faire le m‚nage.

SSAV_EXIT	move.l	Cookie_Adr,D1
	BMI	Try_To_Exit

	clr.l	-(SP)
	move.w	#$20,-(SP)		; - SUPER -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	move.l	D0,D6

	move.l	SSAV_Adr,D1
	movea.l	D1,A0
	suba.l	#2,A0
	move.w	(A0),D1
	
	BEQ	SSAV_Warp
	
	subq.w	#1,D1		; Compteur
	move.w	D1,(A0)

SSAV_Warp	move.l	D6,-(SP)
	move.w	#$20,-(SP)		; - SUPER -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP

	BRA	SSAV_Closing
	
Try_To_Exit	move.l	SSAV_Adr,D0
	sub.l	#$128,D0		; Header
	move.l	D0,-(SP)		; Adresse
	move.w	#$49,-(SP)		; - M_FREE -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	
SSAV_Closing	RTS
	
; /// LES ERREURS ///	

; > En principe, doit pas y'avoir d'erreurs...

Error_Read	move.w	#-11,D1
	BRA	Closer

Error_MemAlloc	move.w	#-39,D1
	BRA	Closer
	
	SECTION	DATA		; Constantes...

Cookie_Name	dc.b	"SSAV"		; Le nom du Cookie
SSAV_Name	dc.b	"SSAVCALL.PRG",0	; Le nom de la routine
SSAV_Version	dc.w	$0111		; La version minimum neccesaire
RSC_Name	dc.b	"TESTSSAV.RSC",0	; Le nom de la ressource
AES_Name	dc.b	"TESTMAES.RSC",0
VDI_Name	dc.b	"TESTMVDI.RSC",0
Welcome_SPL	dc.b	"WELCOMEJ.PRW",0
Start_SPL	dc.b	"OPENPROC.PRW",0
Exit_SPL	dc.b	"CLOSPROC.PRW",0
Rythm_SPL	dc.b	"RAPPY.PRW",0
OpenMenu_SPL	dc.b	"OPENDRWR.PRW",0
CloseMenu_SPL	dc.b	"CLOSDRWR.PRW",0
SSAVMenu_Txt	dc.b	0,71," Accessoires ",0
	dc.b	0,80," Exit ",0
AESMenu_Txt	dc.b	0,18," Accessoires ",0
VDIMenu_Txt	dc.b	0,15," Accessoires ",0
	dc.b	0,30," Text ",0
	dc.b	0,75," Text ",0
	dc.b	0,82," Line ",0
	dc.b	0,88," Marker ",0
	dc.b	0,92," Fill ",0
	dc.b	0,104," KeyBd ",0
	dc.b	0,111," Cursor ",0
	dc.b	0,114," Mouse ",0
	dc.b	0,117," VectorEx ",0
	dc.b	0,125," Line ",0
	dc.b	0,127," Marker ",0
	dc.b	0,129," Fill ",0
	dc.b	0,131," Text ",0

	SECTION	BSS		; Variables... (… 0 au chargement)

; /// LES VARIABLES DU PROGRAMME ///

Tree_Adr	ds.l	1		; L'adresse de l'arbre
Menu_Adr	ds.l	1		; L'adresse du menu actuel
Packed_Data	ds.l	1		; L'adresse des donn‚es
UnPacked_Size	ds.l	1		; Taille de l'‚chantillon
UnPacked_Data	ds.l	1		; Adresse de l'engin
Messag_Tab	ds.w	8		; The flux
Clicked_Button	ds.w	1		; Le num‚ro du bouton

; /// LES VARIABLES DE SSAV INSTALL ///

Nb_Slot	ds.l	1		; Le nombre de Cookies
Cookie_Adr	ds.l	1		; L'addresse du Cookie "SSAV"
SSAV_Adr	ds.l	1		; L'adresse de la routine
Tempo_Path	ds.l	256		; TrŠs utile pour travailler

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
IntIn	ds.w	64		; Minimum 30
IntOut	ds.w	64		; Minimum 45
PtsIn	ds.w	64		; Minimum 30
PtsOut	ds.w	64		; Minimum 12
VDI_Params	ds.l	5
