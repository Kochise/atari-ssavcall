; /// FloaTest 1.02 STOS Basic Original Rout ///

	SECTION	TEXT

	movea.l	4(SP),A6		; Adresse de la BasePage
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

	tst.w	D0
	BMI	Exit

	pea	Environment
	pea	CommandLine
	pea	FloatRout
	move.w	#3,-(SP)
	move.w	#$4B,-(SP)		; - P_EXEC -
	trap	#1		; *** GEMDOS ***
	lea	16(SP),SP

	move.l	D0,A0
	move.l	(8,A0),A0
	JSR	(A0)

	lea	FloatNum,A0
	move.l	#$B,D0
	trap	#6

	move.l	D1,D2
	fmove.s	D0,FP0
	move.l	D0,D1
	move.l	#$38,D3
	lea	FloatBuff,A0
	move.l	#$C,D0
	trap	#6
	
	pea	FloatBuff
	move.w	#9,-(SP)		; - C_CONWS -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	
	move.w	#7,-(SP)		; - C_RAWCIN -
	trap	#1		; *** GEMDOS ***
	addq.l	#2,SP

	clr.w	D0
Exit	move.w	D0,-(SP)
	move.w	#$4C,-(SP)		; - P_TERM -
	trap	#1		; *** GEMDOS ***
	
	SECTION	DATA

FloatRout	dc.b	"D:\LIB'ZONE.III\SSAVCALL\FLOAT102.PRG",0
Environment	dc.b	0
CommandLine	dc.b	0
FloatNum	dc.b	"1.2856E-02",0

	SECTION	BSS

FloatBuff	ds.b	256	