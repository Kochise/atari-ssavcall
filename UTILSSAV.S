; /////////////////////////////////////////////////////////////////////////
; /////////////////////////////////////////////////////////////////////////
; /////////////////////////////////////////////////////////////////////////
; ///                                                                   ///
; ///        >>> "STALLION SOFTWARE'S AES-VDI CALL"¿ INSTALL <<<        ///
; ///                                                                   ///
; /////////////////////////////////////////////////////////////////////////
; ///                                                                   ///
; /// ROUTINE D'INSTALLATION ET D'INITIALISATION DE SSAV, UN ADAPTATEUR ///
; /// D'APPELS AU GEM VIA L'ASSEMBLEUR. SE REFERER ¶ "SSAVCALL.DOC", LE ///
; /// MANUEL D'UTILISATION DE L'ADAPTATEUR AVEC AIDES AU DEVELOPPEMENT. ///
; ///                                                                   ///
; /////////////////////////////////////////////////////////////////////////
; ///                                                                   ///
; /// PROGRAMM PAR KOCH DAVID (IDFRAKOCH-9508851003894DAVID-7803118M5) ///
; ///           EN ASSEMBLEUR 68030 AVEC DEVPAC V3.1 DE HISOFT          ///
; ///           SUR UN ATARI FALCON030 (Y44A02-4005369) 4Mo/540Meg/FP82 ///
; ///                                                                   ///
; /////////////////////////////////////////////////////////////////////////
; ///                                                                   ///
; /// ATTENTION : Cette routine N'EST PAS du domaine publique, il est   ///
; ///             donc formellement proscrit de modifier le source      ///
; ///             original sans m'avoir demand‚ mon avis au pr‚alable   ///
; ///             (je tiens … garantir une certaine coh‚sion entre les  ///
; ///             diff‚rentes versions qui sont en circulation, car les ///
; ///             versions sauvages risquent juste de faire revenir la  ///
; ///             simplicit‚ d'emploi que j'avais r‚ussi … obtenir au   ///
; ///             niveau de la complication d'utilisation du GEM …      ///
; ///             l'origine). Il est cependant conseill‚ de diffuser le ///
; ///             plus possible cette routine, au cas o— quelques       ///
; ///             personnes puissent y trouver leur bonheur.            ///
; ///                                                                   ///
; ///                                                        KOCHISE    ///
; ///                                                                   ///
; /////////////////////////////////////////////////////////////////////////
; ///                                                                   ///
; /// THANKS TO : ATARI FOR THE FALCON, GREATEST COMPUTER OF THE WORLD  ///
; ///             MOTOROLA FOR THEIR POWERFULL 68000 CHIPS FAMILLY      ///
; ///             DIGITAL RESEARCH FOR THEIR FAILING BUT GOOD TOS 4.04  ///
; ///             HISOFT FOR THEIR EXCELLENT DEVPAC 3.1 AND DSP         ///
; ///                                                                   ///
; /////////////////////////////////////////////////////////////////////////
; /////////////////////////////////////////////////////////////////////////
; /////////////////////////////////////////////////////////////////////////
;

; /// SCHEMA D'UNE APPLICATION AES-VDI TYPE AVEC SSAV ///
;
;               M_SHRINK (Initialisation normale)
; SSAV_INSTALL  ... (Passage par SSAV_INSTALL)
;               APPL_INIT (Appel fa‡on SSAV, en empilant)
;               ... (M_ALLOC, Ouvrir la Station de Travail, ...)
; GESTION_PRINC ... (Fenˆtres, Formulaires, ...)
;               ...
; EXIT          ... (Fermer les fenˆtres, la Station de Travail, M_FREE, ...)
;               APPL_EXIT (Appel fa‡on SSAV)
; SSAV_EXIT     ... (Passage par ...)
;               P_TERM(0) (A vous de voir lequel des deux est le mieux pour vous)

	SECTION	TEXT		; Programme...
	

; /// CE QUE FONT Start_Prog ET Copy_File_Name ///
;
; Start_Prog et Copy_File_Name regardent si l'on … d‚pos‚ 
; un fichier sur l'icone du programme par le principe du Drag'n Drop,
; et dans ce cas, copie le chemin et le nom du fichier dans Tempo_Path


Start_Prog	move.l	4(SP),A6		; Adresse de la BASEPAGE
	lea	$80(A6),A6		; Adresse de la COMMAND-TAIL
	move.b	(A6)+,D0		; Taille de la COMMAND-TAIL (ATTENTION : Format PASCAL)
	lea	Tempo_Path,A5
	BNE	Copy_File_Name		; Si la COMMAND-TAIL existe...
	move.b	#0,(A5)+		; Pas de COMMAND-TAIL
	BRA	Init_PRG_Mem

Copy_File_Name	move.b	(A6)+,(A5)+		; Copie de la COMMAND-TAIL
	subq.b	#1,D0
	bne	Copy_File_Name
	clr.b	(A5)		; Mets un OCTET nul … la fin de la chaine (ATTENTION : Transformation au format C)


; /// CE QUE FAIT Init_PRG_Mem ///
;
; Init_PRG_Name coupe toute la partie inutile de la RAM, et la rend
; au systeme d'exploitation pour que l'on puisse ult‚rieurement y
; faire proprement appel via un Malloc, appeller l'AES (ce qui est
; le but de SSAV), et d'autres choses trŠs interressantes...
; Il installe aussi les tableaux de parametres du GEM.

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
	BNE	Error_Code

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

; /// CE QUE FAIT SSAV_INSTALL ///
; 
; Cette petite routine cherche le Cookie "SSAV". 
; S'il n'y a pas de Cookies, elle charge la routine SSAV pour le programme
; pŠre (le votre), sans que d'autres puisse y acc‚der.
; Si elle trouve le Cookie "SSAV", elle prend l'adresse de la routine et
; modifie le compteur de tƒches externes.
; Si la version de SSAV en m‚moire est inf‚rieur … celle que vous avez besoin,
; cette routine charge la version pr‚sente avec votre programme (celle-ci doit
; donc correspondre … vos besoin).

SSAV_INSTALL	clr.l	-(SP)
	move.w	#$20,-(SP)		; - SUPER -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	move.l	D0,D6

	move.l	$5A0.w,D1
	BEQ	Error_SSAV
	
	movea.l	D1,A0		; On pointe le premier Cookie

	clr.w	D3
	suba.l	#4,A0
	
Look_For_Null	addq.w	#1,D3
	adda.l	#4,A0
	move.l	(A0)+,D0
	BNE	Look_For_Null		; On cherche le Cookie NULL (0)
				; ATTENTION : Le Cookie NULL, dont
				; l'information est le nombre de Cookie
				; install‚s, n'a pas de nom. Ne cherchez
				; pas un Cookie au nom de "NULL", mais le
				; Cookie vide suivant le dernier Cookie.
				; Ce Cookie, dont le nom est un mot long
				; vide, est le Cookie "NULL". 
	
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
	
	lea	Tempo_Path,A0
Search_Null	addq.l	#1,A0
	move.b	(A0),D0
	BNE	Search_Null
	
	move.b	#92,(A0)+
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
	move.l	D0,D6		; Il est plus interessant
				; De travailler comme ‡a.
				; On peut se placer en fin de
				; fichier avec F_Seek pour
				; obtenir sa taille, mais
				; on ne connait pas la
				; longueur de la SECTION BSS
				; car c'est la zone des
				; donn‚es non initialis‚es
				; qui est ajout‚e en fin du
				; programme lors de son
				; chargement. Si l'on ne procede
				; pas comme cela, on risque
				; d'avoir une taille trop
				; juste, et un autre programme
				; (le votre par exemple), en
				; r‚servant sa m‚moire, ne
				; sait pas qu'il empiete sur
				; la SECTION BSS de SSAVCALL.
				; Une erreur dont je me suis rendus
				; compte lors d'un de mes tests.
				; SSAV n'‚tait pas install‚
				; au chargement, et je laissait
				; … la routine SSAV_Init le
				; soin de s'en occuper. Mais
				; vu que je prenais la taille
				; du fichier, je ne reservait
				; pas assez de m‚moire, et
				; lors de l'utilisation de
				; SSForm_Sound, un probleme
				; apparaissait, car utilise la
				; SECTION BSS, et TestSSAV y
				; mettait la ressource.

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
	
	add.l	#$128,D5		; ATTENTION : Constante entre le d‚but
				; du File Header de SSAV et la routine
				; SSAV, et donc pas la routine de mise
				; en m‚moire et d'installation de SSAV
				; et de son Cookie.
	move.l	D5,SSAV_Adr				 	
	
Closer	move.w	D7,-(SP)
	move.w	#$3E,-(SP)		; - F_CLOSE -
	trap	#1		; *** GEMDOS ***
	addq.l	#4,SP
	
End_Install	RTS

; /// CE QUE FAIT APPL_INIT ///
;
; APPL_INIT sert … indiquer votre pr‚sence au GEM, et vous permet d'utiliser
; une interface graphique. Si votre interface se limite … du textuel, n'utilisez
; pas le GEM, le TOS suffit.

APPL_INIT	pea	AES_Params		; Pour que le GEM puisse travailler
	move.w	#10,-(SP)		; - APPL_INIT -
	move.w	#200,-(SP)		; *** AES ***
	jsr	([SSAV_Adr])		; SSAV
	addq.l	#8,SP		; H‚ oui, coco, c'est comme ‡a maintenant...
	
	move.w	D0,AES_Handle		; Le Handle dont le GEM nous gratifie
	
	RTS

; Avouez que d'utiliser le GEM de cette maniŠre, c'est assez fantastique...

; /// CE QUE FAIT Define_ClipPath ///
;
; Define_ClipPath va automatiquement d‚finir le v‚ritable chemin du ClipBoard,
; ou va l'installer s'il n'existe pas. 

Define_ClipPath	move.w	#10,-(SP)		; - DRVMAP -
	trap	#13		; *** BIOS ***
	addq.l	#2,SP
	
	lea	Tempo_Path,A0
	
	btst.l	#2,D0		; BOOT sur C?
	BNE	On_HD_Boot
	
	move.b	#65,(A0)+		; A
	BRA	Next_Boot_Path

On_HD_Boot	move.b	#67,(A0)+		; C
Next_Boot_Path	move.b	#58,(A0)+		; :
	move.b	#92,(A0)+		; \
	
	lea	ClipBoard_Name,A1
Copy_ClipName	move.b	(A1)+,(A0)+
	BNE	Copy_ClipName
	
	move.b	#92,(-1,A0)		; \
		
	pea	Tempo_Path
	move.w	#$3B,-(SP)		; - D_SETPATH -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	
	tst.w	D0
	BEQ	Init_Scrap_Path		; Le dossier existe d‚j…

	pea	Tempo_Path
	move.w	#$39,-(SP)		; - D_CREATE -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	
	tst.w	D0
	BNE	Exit_Scrap_Init
	
Init_Scrap_Path	pea	Tempo_Path
	pea	AES_Params
	move.w	#81,-(SP)		; - SCRP_WRITE -
	move.w	#200		; *** AES ***
	JSR	([SSAV_Adr])
	lea	(12,SP),SP
	
Exit_Scrap_Init	RTS
	
; /// CE QUE FAIT Define_CurrPath ///
; 
; Define_CurrPath va automatiquement vous d‚finir le chemin actuel, au lancement
; de votre programme. Ainsi, si vous avez besoin de travailler avec des fichiers
; de votre cru, il vous suffit de r‚cup‚rer le chemin de Tempo_Path, d'ajouter
; le nom de votre fichier pr‚alablement r‚cup‚r‚ dans la DTA, et ... voil….

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

; /// CE QUE FAIT APPL_EXIT ///
; 
; APPL_EXIT va indiquer au GEM votre soif de libert‚, et il va gentiment vous
; lacher dans la nature aprŠs avoir repris les choses en mains.

APPL_EXIT 	pea	AES_Params		; Pour que le GEM puisse travailler
	move.w	#19,-(SP)		; - APPL_EXIT -
	move.w	#200,-(SP)		; *** AES ***
	jsr	([SSAV_Adr])		; SSAV
	addq.l	#8,SP		; Zoup...
	
	RTS

; /// CE QUE FAIT SSAV_EXIT ///
;
; Cette petite routine se d‚barasse de la routine SSAV.
; Si le Cookie "SSAV" existe, elle regarde le compteur de tƒches externe.
; Si il est sup‚rieur … 0, elle r‚duit de compteur de 1.
; S'il n'y a pas de Cookie, elle efface la routine charg‚e

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


	
; /// LES ERREURS (A VOUS DE LES GERER) ///	

Error_Open	nop
Error_MemAlloc	nop
Error_SSAV	nop
Error_Code	nop


	SECTION	DATA		; Constantes...

Cookie_Name	dc.b	"SSAV"		; Le nom du Cookie
SSAV_Name	dc.b	"SSAVCALL.PRG",0	; Le nom de la routine
SSAV_Version	dc.w	$0108		; La version minimum neccesaire
ClipBoard_Name	dc.b	"CLIPBRD",0		; Le nom officiel du ClipBoard

	SECTION	BSS		; Variables...

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
