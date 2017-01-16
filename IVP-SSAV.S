; /// INSTALLATEUR Version >Professionelle< DE SSAV POUR VOTRE APPLICATION ///
;
; Taille incompressible : 13042 octets (assembl‚ tel quel, et STRIP‚)
;
; Veuillez suivre les conseils...
; Je n'ais volontairement pas optimis‚ cet installateur afin de vous
; permettre de le comprendre
; TAB=24 SCREEN=768/576

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
	
	move.w	#8,D5
	
Start_Reloc	lea	Reloc_Data,A0
	move.w	(A0,D5.w*2),D7
	clr.w	D6
	
Reloc_RSC	lea	Control,A0
	move.l	#$72010101,D0
	movep.l	D0,(1,A0)
	
	move.w	D6,Int_In
	lea	Rs_trindex,A0
	move.l	(A0,D5.w*4),Addr_In
	
	BSR	AES_Call
	
	addq.w	#1,D6
	
	DBF	D7,Reloc_RSC
	DBF	D5,Start_Reloc

	BRA	CHOICE_Form
	
Reloc_Data	dc.w	15,13,11,11,11,11,13,13,13

	; On gere l'arbre suivant les choix de l'utilisateur

CHOICE_Form	; On demande comment faire pour installer SSAVCALL
	; Automatiquement ou Manuellement

	move.l	Rs_trindex,TreeToDo	; Formulaire CHOICE
	BSR	Aff_Form
	cmpi.w	#13,D0
	BEQ	MANUEL_Form
	BRA	LookAt_Boot
	
; J'ai d‚cid‚ de mettre le "Clr_Form" au d‚but de chaque proc‚dure pour que le formulaire
; reste affich‚ pendant que l'ordinateur travaille. 
	
MANUEL_Form	; On dit comment faire Manuellement, et on quitte

	BSR	Clr_Form
	move.l	Rs_trindex+4,TreeToDo	; Formulaire MANUEL
	BSR	Aff_Form
	BSR	Clr_Form
	BRA	Appl_Exit

RESTART_Form	; On averti que l'ordinateur va red‚marrer, et on Boot

	BSR	Clr_Form
	move.l	Rs_trindex+8,TreeToDo	; Formulaire RESTART
	BSR	Aff_Form
	BSR	Clr_Form
	BRA	ColdBoot

NOFOUND_Form	; On dit que la version incluse de SSAVCALL n'a
	; pas ‚t‚ trouv‚e dans le r‚pertoire actuel

	BSR	Clr_Form
	move.l	Rs_trindex+12,TreeToDo	; Formulaire NOFOUND
	BSR	Aff_Form
	BRA	MANUEL_Form

NOWRITE_Form	; Erreur d'‚criture, et l'on quitte

	BSR	Clr_Form
	move.l	Rs_trindex+16,TreeToDo	; Formulaire NOWRITE
	BSR	Aff_Form
	BSR	Clr_Form
	BRA	Appl_Exit

FULLDISK_Form	; L'unit‚e est pleine, on ne peut installer SSAVCALL

	; On ferme le fichier ouvert

	move.w	D7,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP
	
	BSR	Clr_Form
	move.l	Rs_trindex+20,TreeToDo	; Formulaire FULLDISK
	BSR	Aff_Form
	BSR	Clr_Form
	BRA	Appl_Exit

OLDER_Form	; La version en place est plus vieille que la
	; version incluse. R‚activer l'ancienne version,
	; ou la remplacer par la nouvelle

	BSR	Clr_Form
	move.l	Rs_trindex+24,TreeToDo	; Formulaire OLDER
	BSR	Aff_Form
	cmpi.w	#11,D0
	BEQ	ReName_Old
	BRA	Install_New

PRXFOUND_Form	; Une version d‚sactiv‚e de SSAVCALL … ‚t‚ trouv‚e
	; dans la partition Boot. Ca peut etre un PRX, mais
	; aussi un PRG. Cela peut se produire si l'on Boot
	; en gardant Control enfonc‚.

	move.w	D0,D7	; Handle
	BSR	Clr_Form
	move.l	Rs_trindex+28,TreeToDo	; Formulaire PRXFOUND
	BSR	Aff_Form
	cmpi.w	#9,D0
	BEQ	Verify_Old
	BRA	Install_New

WHATDO_Form	; Que faire avant de disparaitre
	; Red‚marrer l'ordinateur, ou sortir sur le bureau

	BSR	Clr_Form
	move.l	Rs_trindex+32,TreeToDo	; Formulaire WHATDO
	BSR	Aff_Form
	cmpi.w	#9,D0
	BEQ	RESTART_Form
	BSR	Clr_Form

	; APPL_EXIT

Appl_Exit	lea	Control,A0
	move.l	#$13000100,D0
	movep.l	D0,(1,A0)
	
	BSR	AES_Call

	; P_TERM0 = Kassos

P_Term0	clr.w	-(SP)
	trap	#1
	
LookAt_Boot	; On regarde l'unit‚e de Boot

	pea	Booted_Drive
	move.w	#$26,-(SP)	; - SUPEXEC -
	trap	#14	; *** XBIOS ***
	addq.l	#6,SP
	
	move.w	D0,Boot_Drive
	
	BSR	Correct_RSC

	; On regarde l'unit‚e courante (celle … l'execution de ce programme)
	
	move.w	#$19,-(SP)	; - D_GETDRV -
	trap	#1	; *** GEMDOS ***
	addq.l	#2,SP
	
	move.w	D0,D1
	addq.w	#1,D1
	move.w	D1,-(SP)
	
	move.w	D0,Current_Drive
	
	; On regarde le chemin de ce programme … son execution
	
	pea	Free2_Buffer
	move.w	#$47,-(SP)	; - D_GETPATH -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	
	; On s‚lectionne l'unit‚e de Boot
	
	move.w	Boot_Drive,-(SP)
	move.w	#$E,-(SP)	; - D_SETDRV -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP
	
	; On s‚lectionne le dossier AUTO
	
	pea	AUTO_Folder
	move.w	#$3B,-(SP)	; - D_SETPATH -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	; S'il n'existe pas, on le cr‚er
	
	tst.w	D0
	BNE	Creat_AUTO
	
	; On cherche si le programme SSAVCALL.PRX existe
	
	lea	SSAV_Type,A0
	move.b	#"X",(-2,A0)		
	
	clr.w	-(SP)
	pea	SSAV_Name
	move.w	#$3D,-(SP)	; - F_OPEN -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	
	; Si le Handle est positif, c'est bon
	
	tst.w	D0
	BPL	PRXFOUND_Form
		
	; On cherche si le programme SSAVCALL.PRG existe
	; (n'oubliez pas que si cette partie est execut‚e,
	; c'est que SSAVCALL.PRG n'est pas en m‚moire)
		
	lea	SSAV_Type,A0
	move.b	#"G",(-2,A0)		
	
	clr.w	-(SP)
	pea	SSAV_Name
	move.w	#$3D,-(SP)	; - F_OPEN -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP

	; Si le Handle est positif, c'est bon

	tst.w	D0
	BPL	PRXFOUND_Form
	
	; S'il n'a pas ‚t‚ trouv‚, on l'installe
	
	BRA	Install_New
	
Booted_Drive	move.w	$446.w,D0	; _BootDev

	RTS
	
AUTO_Folder	dc.b	"\AUTO",0
SSAV_Name	dc.b	"SSAVCALL.PRx",0
SSAV_Type	dc.b	0

	EVEN
	
Creat_AUTO	; On cr‚er le dossier AUTO

	pea	AUTO_Folder
	move.w	#$39,-(SP)	; - D_CREATE -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	tst.w	D0
	BNE	NOWRITE_Form

	; Si c'est bon, on installe SSAVCALL.PRG

Install_New	; On ferme le fichier ouvert

	move.w	D7,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP

	; On s‚lectionne l'unit‚e d'execution de ce programme

	move.w	Current_Drive,-(SP)
	move.w	#$E,-(SP)	; - D_SETDRV -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP
	
	; On s‚lectionne le r‚pertoire d'execution
	
	pea	Free2_Buffer
	move.w	#$3B,-(SP)	; - D_SETPATH -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	lea	SSAV_Type,A0
	move.b	#"G",(-2,A0)
	
	; On ouvre SSAVCALL.PRG
	
	clr.w	-(SP)
	pea	SSAV_Name
	move.w	#$3D,-(SP)	; - F_OPEN -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	
	tst.w	D0
	BMI	NOFOUND_Form
	
	move.w	D0,D7
	
	; On se place … la fin pour connaitre la taille du fichier
	
	move.w	#2,-(SP)
	move.w	D0,-(SP)
	clr.l	-(SP)
	move.w	#$42,-(SP)	; - F_SEEK -
	trap	#1	; *** GEMDOS ***
	lea	(10,SP),SP
	
	move.l	D0,D6	; Taille du fichier SSAVCALL.PRG

	move.w	Boot_Drive,D0
	addq.w	#1,D0
	
	; On demande la place disponible sur l'unit‚e Boot
	
	move.w	D0,-(SP)
	pea	Free1_Buffer
	move.w	#$36,-(SP)	; - D_FREE -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	
	lea	Free1_Buffer,A0
	move.l	(A0),D0	; Nb Cluster Libres
	move.l	(12,A0),D1	; Taille Cluster /Secteur
	mulu.l	D1,D0	; Nb Secteur Libres
	move.l	(8,A0),D1	; Taille Secteur /Octet
	mulu.l	D1,D0	; Nb Octets Libres
	
	cmp.l	D0,D6
	BPL	FULLDISK_Form
	
	; S'il y a assez de place, on r‚serve de la m‚moire
	
	move.w	#3,-(SP)
	move.l	D6,-(SP)
	move.w	#$44,-(SP)	; - M_XALLOC -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP

	tst.l	D0
	BEQ	NOWRITE_Form
	move.l	D0,D5
	
	; On se replace au d‚but du fichier SSAVCALL.PRG
	
	clr.w	-(SP)
	move.w	D7,-(SP)
	clr.l	-(SP)
	move.w	#$42,-(SP)	; - F_SEEK -
	trap	#1	; *** GEMDOS ***
	lea	(10,SP),SP
	
	; On lit le fichier en entier
	
	move.l	D5,-(SP)
	move.l	D6,-(SP)
	move.w	D7,-(SP)
	move.w	#$3F,-(SP)	; - F_READ -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP
	
	cmp.l	D0,D6
	BNE	NOWRITE_Form
	
	; On ferme le fichier
	
	move.w	D7,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP
	
	; On s‚lectionne l'unit‚e de Boot
	
	move.w	Boot_Drive,-(SP)
	move.w	#$E,-(SP)	; - D_SETDRV -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP
	
	; On ouvre le dossier AUTO
	
	pea	AUTO_Folder
	move.w	#$3B,-(SP)	; - D_SETPATH -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	; On ouvre le fichier SSAVCALL.PRG
	
	clr.w	-(SP)
	pea	SSAV_Name
	move.w	#$3D,-(SP)	; - F_OPEN -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	
	tst.w	D0
	BMI	Creat_SSAV
	
	; S'il existe, on d‚truit la pr‚c‚dente version
	
	pea	SSAV_Name
	move.w	#$41,-(SP)	; - F_DELETE -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP

	tst.w	D0
	BNE	NOWRITE_Form
	
	; On cr‚er le fichier SSAVCALL.PRG
	
Creat_SSAV	clr.w	-(SP)
	pea	SSAV_Name
	move.w	#$3C,-(SP)	; - F_CREATE -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	
	tst.w	D0
	BMI	NOWRITE_Form
	
	move.w	D0,D7
	
	; On ‚crit le programme
	
	move.l	D5,-(SP)
	move.l	D6,-(SP)
	move.w	D7,-(SP)
	move.w	#$40,-(SP)	; - F_WRITE -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP
	
	cmp.l	D0,D6
	BNE	NOWRITE_Form
	
	; On ferme le fichier
	
	move.w	D7,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP
	
	; On libŠre la m‚moire
	
	move.l	D5,-(SP)
	move.w	#$49,-(SP)	; - M_FREE -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	; On demande comment red‚marrer
	
	BRA	WHATDO_Form

Verify_Old	; Le fichier dans le dossier AUTO est ouvert, Handle dans D7
	; On se place sur le pointeur de la routine

	clr.w	-(SP)
	move.w	D7,-(SP)
	move.l	#32,-(SP)
	move.w	#$42,-(SP)	; - F_SEEK -
	trap	#1	; *** GEMDOS ***
	lea	(10,SP),SP
	
	clr.l	-(SP)
	
	; On lit le pointeur
	
	move.l	SP,-(SP)
	move.l	#4,-(SP)
	move.w	D7,-(SP)
	move.w	#$3F,-(SP)	; - F_READ -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP
	
	move.l	(SP)+,D0
	add.l	#22,D0
	
	; On se place sur la version de la routine
	
	clr.w	-(SP)
	move.w	D7,-(SP)
	move.l	D0,-(SP)
	move.w	#$42,-(SP)	; - F_SEEK -
	trap	#1	; *** GEMDOS ***
	lea	(10,SP),SP
	
	clr.w	-(SP)
	
	; On lit la version de SSAVCALL du dossier AUTO
	
	move.l	SP,-(SP)
	move.l	#2,-(SP)
	move.w	D7,-(SP)
	move.w	#$3F,-(SP)	; - F_READ -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP
	
	move.w	(SP)+,D6
	
	; On ferme le fichier du dossier AUTO
	
	move.w	D7,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP
	
	; On s‚lectionne l'unit‚e d'execution de ce programme

	move.w	Current_Drive,-(SP)
	move.w	#$E,-(SP)	; - D_SETDRV -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP
	
	; On s‚lectionne le r‚pertoire d'execution
	
	pea	Free2_Buffer
	move.w	#$3B,-(SP)	; - D_SETPATH -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	lea	SSAV_Type,A0
	move.b	#"G",(-2,A0)
	
	; On ouvre SSAVCALL.PRG
	
	clr.w	-(SP)
	pea	SSAV_Name
	move.w	#$3D,-(SP)	; - F_OPEN -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	
	tst.w	D0
	BMI	NOFOUND_Form
	
	move.w	D0,D7
	
	; On se positionne sur le pointeur de la routine
	
	clr.w	-(SP)
	move.w	D7,-(SP)
	move.l	#32,-(SP)
	move.w	#$42,-(SP)	; - F_SEEK -
	trap	#1	; *** GEMDOS ***
	lea	(10,SP),SP
	
	clr.l	-(SP)
	
	; On lit le pointeur
	
	move.l	SP,-(SP)
	move.l	#4,-(SP)
	move.w	D7,-(SP)
	move.w	#$3F,-(SP)	; - F_READ -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP
	
	move.l	(SP)+,D0
	add.l	#22,D0
	
	; On se place sur la version de la routine
	
	clr.w	-(SP)
	move.w	D7,-(SP)
	move.l	D0,-(SP)
	move.w	#$42,-(SP)	; - F_SEEK -
	trap	#1	; *** GEMDOS ***
	lea	(10,SP),SP
	
	clr.w	-(SP)
	
	; On lit la version de SSAVCALL du dossier AUTO
	
	move.l	SP,-(SP)
	move.l	#2,-(SP)
	move.w	D7,-(SP)
	move.w	#$3F,-(SP)	; - F_READ -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP
			
	move.w	(SP)+,D0
	
	; On v‚rifie les versions
	
	cmp.w	D0,D6
	BMI	OLDER_Form	
	
	; On renomme la version dans le dossier AUTO

ReName_Old	; On ferme le fichier ouvert

	move.w	D7,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP

	; On s‚lectionne l'unit‚e de Boot
	
	move.w	Boot_Drive,-(SP)
	move.w	#$E,-(SP)	; - D_SETDRV -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP
	
	; On s‚lectionne le dossier AUTO
	
	pea	AUTO_Folder
	move.w	#$3B,-(SP)	; - D_SETPATH -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP

	lea	SSAV_Type,A0
	move.b	#"G",(-2,A0)
	
	; On v‚rifie si le fichier SSAVCALL.PRG existe
	
	clr.w	-(SP)
	pea	SSAV_Name
	move.w	#$3D,-(SP)	; - F_OPEN -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
			
	; Si existe, on s'en va demander comment red‚marrer
			
	tst.w	D0
	BPL	Installed
	
	; Si n'existe pas, v‚rifie si SSAVCALL.PRX existe
	
	lea	SSAV_Type,A0
	move.b	#"X",(-2,A0)
	
	clr.w	-(SP)
	pea	SSAV_Name
	move.w	#$3D,-(SP)	; - F_OPEN -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	
	tst.w	D0
	BMI	NOWRITE_Form
	
	; On ferme SSAVCALL.PRX
	
	move.w	D0,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP

	; On copie le nom

	lea	SSAV_Name,A0
	lea	Free1_Buffer,A1

Copy_Name	move.b	(A0)+,(A1)+
	BNE	Copy_Name

	move.b	#"G",(-2,A1)
	
	pea	Free1_Buffer
	pea	SSAV_Name
	clr.w	-(SP)
	move.w	#$56,-(SP)	; - F_RENAME -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP
	
	tst.w	D0
	BMI	NOWRITE_Form
	
	BRA	WHATDO_Form	

Installed	move.w	D0,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP

	BRA	WHATDO_Form

ColdBoot	pea	Reset
	move.w	#$26,-(SP)	; - SUPEXEC -
	trap	#14	; *** XBIOS ***
	addq.l	#6,SP

Reset	move.l	4.w,-(SP)	; Init
	
	RTS		; Let's Warp

Aff_Form	; FORM_CENTER, pour centrer

	lea	Control,A0
	move.l	#$36000501,D0
	movep.l	D0,(1,A0)
	
	move.l	TreeToDo,Addr_In	; L'adresse de l'arbre
	
	BSR	AES_Call
	
	lea	Int_Out,A0
	move.l	(2,A0),Form_SizeNPlace
	move.l	(6,A0),Form_SizeNPlace+4
	
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
	move.l	Form_SizeNPlace,(A0)+	; Les coordonn‚es de FORM_CENTER
	move.l	Form_SizeNPlace+4,(A0)+	; Les dimensions de FORM_CENTER
	
	move.l	TreeToDo,Addr_In	; L'adresse de l'arbre
	
	BSR	AES_Call
	
	; FORM_DO, pour gerer
	
	lea	Control,A0
	move.l	#$32010101,D0
	movep.l	D0,(1,A0)
	
	move.w	#-1,Int_In	; Pas de champs ‚ditables
	
	move.l	TreeToDo,Addr_In	; L'adresse de l'arbre
	
	BSR	AES_Call
	
	lea	Int_Out,A0
	move.w	(A0),D0

	RTS
	
Clr_Form	; FORM_DIAL, pour effacer
	
	lea	Control,A0
	move.l	#$33090100,D0
	movep.l	D0,(1,A0)
	
	lea	Int_In,A0
	move.w	#3,(A0)+
	move.l	Form_SizeNPlace,(A0)+	; Les coordonn‚es de FORM_CENTER
	move.l	Form_SizeNPlace+4,(A0)+	; Les dimensions de FORM_CENTER
	move.l	Form_SizeNPlace,(A0)+	; Les coordonn‚es de FORM_CENTER
	move.l	Form_SizeNPlace+4,(A0)+	; Les dimensions de FORM_CENTER
	
	BSR	AES_Call

	RTS
	
Correct_RSC	; La correction de fait ici dans tous les formulaires,
	; et de fa‡on s‚quentielle pour permettre la
	; traduction dans une autre langue

	move.w	#68,D7	; Nombre de TEDINFO
	
	move.w	Boot_Drive,D6
	add.w	#$41,D6
	
	lea	Rs_tedinfo,A1

Look_For_Teddy	move.w	D7,D4
	mulu.w	#28,D4
	
	move.l	(A1,D4.w),A0	; Adresse TE_PTEXT
	move.w	(24,A1,D4.w),D5	; TE_TXTLEN

	subq.w	#1,D5
	
Look_For_Drv	move.b	(A0,D5.w),D0
	
	cmpi.b	#"$",D0
	BNE	Next_Drv

	move.b	D6,(A0,D5.w)

Next_Drv	DBF	D5,Look_For_Drv
	
Next_Teddy	DBF	D7,Look_For_Teddy

	lea	Control,A0	; ATTENTION … RSRC_GADDR
	clr.w	(8,A0)
	
	RTS
	
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
	
	include	DATAS\IVP_INST.RSM	; La ressource
	
	SECTION	BSS	; Les variables
	
SSAV_Adr	ds.l	1	; L'adresse de la routine
TreeToDo	ds.l	1	; L'arbre … gerer
Form_SizeNPlace	ds.l	2	; Les coordonn‚es du formulaire
Boot_Drive	ds.w	1
Current_Drive	ds.w	1
Free1_Buffer	ds.b	128
Free2_Buffer	ds.b	128

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
