; /// SSAVCALL Init (2.55 compatible) - KOSS 1999-2001 ///

; To use SSAVINIT, just change :
;  - SSAV_DATA_INFO
;  - SSAV_DATA_TITLE
;  - Place your code somewhere, at the right place

; *** Equates Zone ************************************************************

	; *** Equates for Assembly

ASMEQU_DAY:	EQU	6	
ASMEQU_MONTH:	EQU	6
ASMEQU_YEAR:	EQU	2001
	; Date Format :	%AAAAAAAmmmmJJJJJ
ASMEQU_DATE:	EQU	((ASMEQU_YEAR-1980)<<9)|(ASMEQU_MONTH<<5)|(ASMEQU_DAY)

	; *** Commands for Assembly

	OPT	p=68030/68882
	comment	HEAD=7	; FastLoad

; /////////////////////////////////////////////////////////////////////////////	
	SECTION	TEXT
; /////////////////////////////////////////////////////////////////////////////	

	; ATTENTION - Les lignes suivante (-> SSAV_TEXT_INIT_BOOT)
	;               NE DOIVENT JAMAIS ˆtres modifi‚es.
	;           - Il est IMPERATIF de commencer par PROG_INIT.
	;           - NE TOUCHEZ JAMAIS … A0 avant PROG_INIT.

	move.l	#"SSAV",D0
	trap	#2	; *** AES/VDI ***
	
	cmpi.l	#"SSAV",D0
	BEQ	SSAV_TEXT_INIT_UNINST	; On travaille normalement

	move.l	D0,SSAV_BSS_SSAV_ADDR
		; On garde l'adresse
	
	move.l	SP,D0	; Si SP=0, ACC
	BNE	SSAV_TEXT_INIT_BOOT
	lea	SSAV_BSS_ACCSTACK,SP
	
SSAV_TEXT_INIT_BOOT:	move.w	#$100,-(SP)	; 100 LongWord for the NewStackFrame
	clr.w	-(SP)	; SHRINK
	pea	SSAV_BSS_INFO
	pea	SSAV_DATA_PARAMS_TAB
	move.l	#-1,-(SP)	; -1 : "BOOT Only" if AES, DEMO_TEXT_START_GEM
	move.l	#-1,-(SP)	; -1 : "BOOT Only" if AES, DEMO_TEXT_START_ACC
	pea	DEMO_TEXT_START_BOOT	; -1 : Bypass if BOOT
	clr.w	-(SP)	; - PROG_INIT -
	clr.w	-(SP)	; *** SYS ***
	JSR	([SSAV_BSS_SSAV_ADDR])
	lea	(28,SP),SP

	BRA	SSAV_TEXT_INIT_EXIT

SSAV_TEXT_INIT_UNINST:	; Si on arrive l…, c'est que SSAVCALL n'a pas ‚t‚
	; trouv‚, donc il faut en avertir l'utilisateur et
	; quitter

	pea	SSAV_DATA_UNINST_TEXT
	move.w	#9,-(SP)	; - C_CONWS -
	trap	#1	; *** GEMDOS ***
	addq.	#6,SP
	
	move.w	#7,-(SP)	; - C_RAWCIN -
	trap	#1	; *** GEMDOS ***
	addq.l	#2,SP
	
SSAV_TEXT_INIT_EXIT:	; Si on passe par l…, c'est qu'on est en phase de BOOT,
	; et que l'on demande de ne rien faire (DEMO_TEXT_START_BOOT … -1 : Bypass if BOOT)...
	
	clr.w	-(SP)	; - P_TERM0 -
	TRAP	#1	; *** GEMDOS ***
	
; *** SSAVCALL PROGRAM ********************************************************

DEMO_TEXT_START_GEM:	; A ce niveau, le GEM est d‚j… initialis‚ par PROG_INIT
	; La souris est … nouveau normale	
	
	; - PROG_GLARINGEM -

DEMO_TEXT_START_ACC:	; A ce niveau, le GEM est d‚j… initialis‚ par PROG_INIT
	; La souris est … nouveau normale
	
	; - PROG_ACCESSORY -

DEMO_TEXT_START_BOOT:	; En phase de BOOT, il est conseill‚ de faire ce qui suit...
	; Cette fonction va remplir la ligne de titre (SSAV_DATA_TITLE)
	; avec la Version (en $$.$$) et la Date (en **/**/**), va
	; l'afficher, puis executer la routine de BOOT (SSAV_PROG_BOOT_CODE).
	; Au la fin, elle affichera une ligne d'information sur
	; la r‚servation m‚moire ‚ventuellement effectu‚e (TKR), puis
	; continuera la phase de BOOT.
	
	clr.w	-(SP)	; SAVE MEMORY
	pea	SSAV_BSS_INFO
	pea	SSAV_DATA_TITLE
	pea	SSAV_BSS_NUMCONV
	pea	SSAV_DATA_INFO
	pea	DEMO_TEXT_BOOT_CODE
	move.w	#2,-(SP)	; - PROG_BOOTER -
	clr.w	-(SP)	; *** SYS ***
	JSR	([SSAV_BSS_SSAV_ADDR])
		
	; L… on n'y passe plus!		

DEMO_TEXT_BOOT_CODE:	; Mettez ici ce qui doit se passer lors de la phase de
	; BOOT. Inutile de pr‚ciser que vu que l'AES n'est 
	; pas encore install‚ … ce stade, il est donc formellement
	; interdit de l'utiliser.
	
	; Au RTS, PROG_BOOTING va afficher la ligne TKR puis
	; quitter en sauvant au besoin la m‚moire
	; Si vous aviez demander de la sauver, et qu'au dernier
	; moment vous ne voulez pas, effacez la taille
	; dans la tableau SSAV_BSS_INFO (SSAV_BSS_INFO+2.l)
	
	; *** THE DEMO TEXT ***
	
	pea	DEMO_DATA_BOOT_TEXT
	move.w	#$9,-(SP)	; - C_CONWS -
	TRAP	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	; *********************
	
	RTS

	dc.b	"XBRA"	; XBRA
	dc.b	"PROG"	; XBRA_Name (ShortXBRA)
	ds.l	1	; OldXBRA_Vector
DEMO_TEXT_XBRA_CODE:	; Mettez ici la routine de v‚rification de votre d‚tournement.
	
	RTE
		
; /////////////////////////////////////////////////////////////////////////////	
	SECTION	DATA
; /////////////////////////////////////////////////////////////////////////////	
	
SSAV_DATA_UNINST_TEXT:	; >> Au cas o— SSAVCALL n'est pas install‚, affiche ce message
	; >> Ceci dans n'importe quel mode (BOOT, ACC ou GEM)
	dc.b	27,"E",13,10,27,"p"
	dc.b	"  SSAVCALL n'est pas install‚  "
	dc.b	27,"q",13,10,0

SSAV_DATA_INFO:	dc.w	$100	; Version 1.00 (en BCD)
	dc.w	ASMEQU_DATE	; Date (format systŠme)
	dc.w	0	; R‚serv‚
	
SSAV_DATA_TITLE:	; >> Le Titre de votre programme affich‚ lors du BOOT
	; >> ATTENTION A NE PAS DEPASSER 40 CARACTERES POUR LE TITRE
	; >> le "$$.$$" et le "**/**/**" sont IMPERATIF et dans CET ORDRE !
	dc.b	" SSAVDEMO $$.$$ - KOSS (**/**/**) ",0

SSAV_DATA_PARAMS_TAB:	dc.l	SSAV_BSS_AES_CONTROL
	dc.l	SSAV_BSS_AES_GLOBAL
	dc.l	SSAV_BSS_AES_INT_IN
	dc.l	SSAV_BSS_AES_INT_OUT
	dc.l	SSAV_BSS_AES_ADDR_IN
	dc.l	SSAV_BSS_AES_ADDR_OUT
	
	; *** THE DEMO DATA ***
DEMO_DATA_BOOT_TEXT:	dc.b	27,"E",13,10,27,"p"
	dc.b	"  BOOT DEMO SSAVCALL  "
	dc.b	27,"q",13,10,0
	; *********************
	
; /////////////////////////////////////////////////////////////////////////////	
	SECTION	BSS
; /////////////////////////////////////////////////////////////////////////////	
	
SSAV_BSS_SSAV_ADDR:	ds.l	1	; L'adresse de SSAVCALL

SSAV_BSS_INFO:	ds.w	1	; AP_ID
	ds.l	1	; Prog_Size
	ds.l	1	; Prog_End
	ds.l	1	; Memo_DynaDescriptor

SSAV_BSS_NUMCONV:	ds.b	40	; Texte
	ds.b	10	; Buffer nombre
	
	; /// Les variables de l'AES ///

SSAV_BSS_AES_CONTROL:	ds.w	5
SSAV_BSS_AES_GLOBAL:	ds.w	14
SSAV_BSS_AES_INT_IN:	ds.w	16
SSAV_BSS_AES_INT_OUT:	ds.w	7
SSAV_BSS_AES_ADDR_IN:	ds.l	3
SSAV_BSS_AES_ADDR_OUT:	ds.l	1
	
	; Important, ne pas effacer SSAV_BSS_ACCSTACK...
	; Permet de lancer le programme en .ACC
	; sans plantage
	
	ds.l	$100	
SSAV_BSS_ACCSTACK:	ds.l	2	; 0.l et ->BasePage.l
			