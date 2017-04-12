; Routine de conversion d'un nombre r‚el en virgule flottate
; en sa repr‚sentation ASCII

; En entr‚e: D0.l Mantisse du nombre r‚el
;            D1.w Exposant du nombre r‚el
;            A0.l Pointeur du tampon d'‚criture

; En sortie: A0.l Pointeur inchang‚
;            A1.l Pointe sur le caractŠre suivant dans le code ASCII
; Les autres registres sont sauvegard‚s

; ---

; Table contenant les comparateurs et les rapports d'ajustement
; n‚cessaires … la routine 'ajuste'

TabVF	dc.w	$A0A1,$F000,$801B	; R‚el -100 000 000
	dc.w	$6666,$6666,$7FFD	; R‚el 0.1
	dc.w	$B3B4,$C000,$8018	; R‚el  -10 000 000
	dc.w	$5000,$0000,$8004	; R‚el 10
	
; ---

; Routine ajustant la valeur du r‚el entre 10^7 et 10^8
; Entr‚e: D0.l Mantisse du r‚el
;         D1.w Exposant du r‚el
;         D2.w Exposant d'‚dition
;         D3.l Incr‚ment de l'exposant d'‚dition
;              =1 si on divise le r‚el par 10
;              =-1 si on multiplie le r‚el par 10
;              (bit 31 reflŠte le sens de la comparaison)

; Sortie: D0.l Mantisse du nombre r‚el ajust‚
;         D1.w Exposant du nombre r‚el ajust‚
;         D2.w Exposant d'‚dition mis … jour
;         A1.l Pointe sur le rapport d'ajustement de la table
; Les autres registres sont inchang‚s

Ajuste	move.w	D1,-(A3)	; Sauvegarde du r‚el actuel
	move.l	D0,-(A3)
	
	move.l	(A1)+,D0	; Installer l'oppos‚ du nombre … comparer
	move.w	(A1)+,D1
	
	BSR	VFAdd	; Additionner et consid‚rer le signe

	subq.l	#6,A3	; R‚cuperer le r‚el du d‚but
	eor.l	D3,D0	; Si signe diff‚rent du signe de
	BMI	FinAj	; l'incr‚ment, alors ajustement fini
	
	add.w	D3,D2	; Sinon changer l'exposant d'‚dition
	
	move.l	(A1)+,D0	; Changer le rapport d'ajustement
	move.w	(A1),D1
	BSR	VFMul	; Ajuster le r‚el un peu plus
	
	lea	(-10,A1),A1	; Se recaler sur le comparateur
	BRA	Ajuste
	
FinAj	move.l	(A3)+,D0
	move.w	(A3)+,D1
	
	RTS
	
; ---

CvVFAsc	movem.l	D0-5/A0,-(SP)

	moveq.l	#7,D2	; Initialise l'exposant d'‚dition
	moveq.l	#"0",D5	; Code ASCII de 0
	
	tst.l	D0	; Nombre nul?
	BEQ	AscNul
	
	BPL	VFPos	; S'il est n‚gatif
	move.b	#"-",(A0)+	; ‚crire le signe '-'
	BSR	VFOpp	; et prendre l'oppos‚
	
VFPos	moveq.l	#1,D3	; Ajuster le r‚el
	lea	TabVF	; pour qu'il soit inf‚rieur … 10^8
	BSR	Ajuste
	
	moveq.l	#-1,D3	; Et s'il est sup‚rieur ou ‚gal … 10^7
	lea	(12,A1),A1
	BSR	Ajuste
	
	move.w	#$801F,D3	; D‚terminer la valeur significative
	sub.w	D1,D3	; de la mantisse par d‚calage
	lsr.l	D3,D0
	
	lea	(9,A0),A1	; Pointer aprŠs le codage ASCII
	moveq.l	#7,D3	; du nombre et ‚crire 8 chiffres
			; de droite … gauche
			
EnChif	moveq.l	#0,D4	; Diviser par 10 l'entier long D0.l
	swap	D0
	move.w	D0,D4
	divi.w	#10,D4
	swap	D4
	move.w	D4,D0
	swap	D0
	divu.w	#10,D0
	move.w	D0,D4	; D4.l Quotient de la division
	swap	D0	; D0.w Reste de la division
	
	add.b	D5,D0	; Code ASCII du chiffre
	move.b	D0,-(A1)	; l'installer dans le tampon
	
	move;l	D4,D0	; Passer le quotient dans
	DBRA	D3,EnChif	; le registre de calcul et
			; traiter le chiffre suivant
			
	moveq.l	#0,D4	; Supposer la notation non scientifique
	
	cmp.w	D3.D2	; Mais si l'exposant d'‚dition n'est
	BLT	Change	; pas entre -1 et 5, alors passer …
	cmpi.w	#5,D2	; cette notation
	BLE	PasChg
	
Change	exg	D2,D4	; Si la notation est
			; Scientifique, alors
			; D4 Exposant d'‚dition
			; D2 0 Nb de chiffres … d‚caler
			; avant de mettre le point d‚cimal
			
PasChg	addq.w	#1,D2	; Pr‚parer les d‚calages pour le DBRA
	subq.l	#1,A1
	BRA	DebDcl
	
AscNul	movea.l	A0,A1	; Ecrire "0" dans le tampon
	move.b	D5,(A1)+
	bra	FinFAsc
	
DclCar	move.b	(1,A1),(A1)+	; D‚caler un chiffre sur la gauche
DebDcl	DBRA	D2,DclCar	; et recommencer

	moveq.b	#".",D2	; Point d‚cimal
	move.b	D2,(A1)	; et le placer dans le tampon
	
	lea	(9,A0),A1	; Se placer en fin de tampon
Laisse0	cmp.b	-(A1),D5	; et rechercher le 1er caractere
	BEQ	Laisse0	; diff‚rent du codde de 0
	
	cmp.b	(A1),D2	; Si point d‚cimal, l'effacer
	BEQ	OTept	
	addq.l	#1,A1	; Si un chiffre, se d‚caler
	
OTept	tst.w	D4	; Si notation scientifique
	BEQ	FinFAsc
	
	move.b	#"E",(A1)+	; Ecrire E
	
	move.w	D4,D2	; Puis l'entier exposant d'‚dition
	movea.l	A1,A0
	BSR	CVentAsc
	
FinFAsc	movem.l	(SP)+,D0-5/A0	; Restitue le contexte

	RTS
	
	
	
	


	
	
	
	
	
	
	
	