; /// Real 68882 _FPU Cookie - KOSS Production 1997 ///

	SECTION	TEXT

	movea.l	4(SP),A6	; Adresse de la BASEPAGE
	move.l	$C(A6),D0	; Taille du SEGMENT TEXT
	add.l	$14(A6),D0	; Additionne la taille du SEGMENT DATA … D0
	add.l	$1C(A6),D0	; Additionne la taille du SEGMENT BSS … D0
	addi.l	#$100,D0	; Additionne la taille de la BASEPAGE … D0
	addi.l	#$400,D0	; Additionne la taille de la future PILE (Ici, 256 positions longues (1024 OCTETS))
	move.l	D0,D1	; Copie D0 dans D1 (Taille … r‚server)
	move.l	D0,D7
	add.l	A6,D1	; Additionne l'adresse du d‚but du programme avec D1 (La taille … r‚server)
	andi.l	#-2,D1	; Rend D1 pair (Au cas o— il ne l'‚tait pas)
	movea.l	D1,SP	; Installe l'adresse de fin du programme+place nouvelle PILE dans la PILE
	move.l	D0,-(SP)	; EmPILE la taille … reserver   \
	move.l	A6,-(SP)	; EmPILE l'adresse du programme |-> Rend le reste de la m‚moire au systŠme
	clr.w	-(SP)	; R‚serv‚                       |
	move.w	#$4A,-(SP)	; - M_SHRINK -                  |
	trap	#1	; *** GEMDOS ***                /
	lea	12(SP),SP
	
	tst	D0	; Si D0<>0, problŠme grave
	BNE	P_Term

	pea	Cookie_Hacker
	move.w	#$26,-(SP)	; - SupExec -
	trap	#14	; *** XBIOS ***
	addq.l	#6,SP

	pea	FPU_Text
	move.w	#9,-(SP)	; - C_CONWS -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
P_Term	move.w	D0,-(SP)	
	move.w	#$4C,-(SP)	; - P_Term -
	trap	#1	; *** GEMDOS ***

Cookie_Hacker	move.l	$5A0.w,D0	; L'adresse de la Cookie-Jar
	BEQ	End_Hacking
	
	movea.l	D0,A0

FPU_Find	move.l	(A0,D3.w*8),D0
	BEQ	End_Hacking
	
	cmpi.l	#"_FPU",D0
	BEQ	Change_FPU
	
	addq.w	#1,D3
	
	BRA	FPU_Find
	
Change_FPU	move.l	#$60000,(4,A0,D3.w*8)	; 68882

End_Hacking	RTS

	SECTION	DATA
	
FPU_Text	dc.b	13,10,27,"p"," Real 68882 _FPU Cookie - KOSS Production 1997 ",27,"q",13,10,0