; /// Original STOS Float LiBRAry - TRAP 6 ///

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


;	lea	FloatSingleNum,A0
;	move.l	(A0),D1
;	move.l	#$12345678,D2
;	move.w	#"3",D3
;	lea	EmptyBuffer,A0
;	
;	BSR	FloatAscii
;	
;	move.l	A0,-(SP)
;	move.w	#9,-(SP)
;	trap	#1
;	addq.l	#6,SP

	lea	FloatAsciiNum,A0

	BSR	AsciiFloat
	
	fmove.s	D0,FP0
	
	move.w	#7,-(SP)
	trap	#1
	addq.l	#2,SP
	
	clr.w	-(SP)
	trap	#1
	
; /// Ascii To Float ///			;
;				;
; A0 : Ascii Number			;
;				;
; D0-D1 : Retour			;
				;
AsciiFloat	lea	l1476F1(pc),a1		; Buffer 65 OCTETs
	move.l	a1,-(a7)		;
	moveq	#$12,d1		;
l14784A	move.b	(a0)+,d0		;<
	BEQ.s	l14785A		;>
	cmp.b	#$20,d0		;
	BEQ.s	l14784A		;>
	move.b	d0,(a1)+		;
	DBF	d1,l14784A		;
l14785A	clr.b	(a1)		;<
	clr.b	1(a1)		;
	BSR	l147FEE		;>
	addq.l	#4,a7		;
	move.l	#$12345678,d1		;
	RTS			;

; /// Float To Ascii ///			+
;				+
; D1-D2 : Float To Convert			+
; D3 : Ascii Number BetWeen 0-7 For Mantissa Expression	+
; A0 : Empty Buffer For Ascii Number		+
;				+
; D0 : Lenght Of The Buffer			+
; A0 : Buffer				+
;				+
FloatAscii	cmp.l	#$12345678,d2		+
	BEQ.s	l14788A		+>
	move.l	a0,-(a7)		+
	lea	BADFloatTxt(pc),a1	+
l14787C	move.b	(a1)+,(a0)+		+<
	BNE.s	l14787C		+>
	move.l	a0,d0		+
	movea.l	(a7)+,a0		+
	sub.l	a0,d0		+
	subq.l	#1,d0		+
	RTS			+

l14788A	movem.l	d1-d5/a2,-(a7)		+<
	move.l	a0,l1476CC		+ Buffer
	move.l	d1,l1476D0		+ Float
	tst.w	d5		+
	BNE.s	l1478D0		+>
	tst.w	d4		+
	BMI.s	l1478D0		+>
	cmp.w	#8,d4		+
	BCS.s	l1478AA		+>
	moveq	#7,d4		+
l1478AA	move.w	d4,-(a7)		+<
	move.l	a0,-(a7)		+
	move.l	d1,-(a7)		+
	BSR	l147DF0		+>
	lea	$A(a7),a7		+
	tst.w	d4		+
	BNE.s	l1478C6		+>
	cmpi.b	#$2E,-1(a0)		+
	BNE.s	l1478C6		+>
	clr.b	-(a0)		+
l1478C6	suba.l	d0,a0		+< D0 : Buffer
;				+ A0 : End Buffer
	exg	d0,a0		+ Normal Return
	movem.l	(a7)+,d1-d5/a2		+
	RTS			+
	
l1478D0	move.b	d1,d0		+<
	andi.b	#$7F,d0		+
	cmp.b	#$41,d0		+
	BCS.s	l1478E2		+>
	move.w	#7,-(a7)		+
	BRA.s	l1478F2		+>

l1478E2	cmp.b	#$31,d0		+<
	BCS.s	l1478EE		+>
	move.w	#$A,-(a7)		+
	BRA.s	l1478F2		+>

l1478EE	move.w	#$16,-(a7)		+<
l1478F2	pea	l1476F1(pc)		+<
	move.l	d1,-(a7)		+
	BSR	l147DF0		+>
	lea	$A(a7),a7		+
	movea.l	d0,a1		+
	cmpi.b	#$2D,(a1)		+
	BNE.s	l14790A		+>
	addq.l	#1,a1		+
l14790A	movea.l	a1,a0		+<
	cmpi.b	#$30,(a0)		+
	BEQ.s	l14793E		+>
l147912	move.b	(a0)+,d0		+
	BEQ.s	l14791C		+>
	cmp.b	#$2E,d0		+
	BNE.s	l147912		+
l14791C	suba.l	a1,a0		+<
	tst.w	d5		+
	BNE	l1479BC		+>
	moveq	#7,d0		+
	cmpa.w	#8,a0		+
	BCC	l1479BC		+>
	sub.w	a0,d0		+
	cmp.b	#5,d0		+
	BCS	l147972		+>
	moveq	#5,d0		+
	BRA	l147972		+>

l14793E	addq.l	#1,a0		+<
	addq.l	#1,a0		+
	movea.l	a0,a1		+
l147944	move.b	(a0)+,d0		+<
	BEQ.s	l14794E		+>
	cmp.b	#$30,d0		+
	BEQ.s	l147944		+>
l14794E	suba.l	a1,a0		+<
	clr.w	d0		+
	cmpa.w	#$16,a0		+
	BCS.s	l147960		+>
	movea.w	#6,a0		+
	moveq	#1,d0		+
	BRA.s	l147968		+>

l147960	cmpa.w	#4,a0		+<
	BCC	l147A68		+>
l147968	tst.w	d5		+<
	BNE	l147A68		+>
	addq.w	#6,a0		+
	move.w	a0,d0		+
l147972	move.w	d0,-(a7)		+<
	pea	l1476F1(pc)		+ Buffer 65 OCTETs
	move.l	l1476D0(pc),-(a7)	+
	BSR	l147DF0		+>
	lea	$A(a7),a7		+
	movea.l	d0,a0		+
	movea.l	l1476CC(pc),a1		+
l14798A	move.b	(a0)+,d0		+<
	BEQ.s	l1479AC		+>
	move.b	d0,(a1)+		+
	cmp.b	#$2E,d0		+
	BNE.s	l14798A		+>
	lea	-1(a1),a2		+
l14799A	move.b	(a0)+,d0		+<
	BEQ.s	l1479AA		+>
	move.b	d0,(a1)+		+
	cmp.b	#$30,d0		+
	BEQ.s	l14799A		+>
	movea.l	a1,a2		+
	BRA.s	l14799A		+>

l1479AA	movea.l	a2,a1		+<
l1479AC	clr.b	(a1)		+<
	movea.l	l1476CC(pc),a0		+
	suba.l	a0,a1		+
	move.l	a1,d0		+
	movem.l	(a7)+,d1-d5/a2		+
	RTS			+

l1479BC	move.w	a0,d2		+<
	subq.w	#2,d2		+
	cmpa.w	#7,a0		+
	BCS.s	l1479CA		+>
	movea.w	#7,a0		+
l1479CA	moveq	#9,d0		+<
	sub.w	a0,d0		+
	move.w	d0,-(a7)		+
	pea	l1476F1(pc)		+
	move.l	l1476D0(pc),-(a7)	+
	BSR	l147DF0		+>
	lea	$A(a7),a7		+
	lea	l1476F1(pc),a0		+
	movea.l	l1476CC(pc),a1		+
	cmpi.b	#$2D,(a0)		+
	BNE.s	l1479F0		+>
	move.b	(a0)+,(a1)+		+
l1479F0	move.b	(a0)+,(a1)+		+<
	move.b	#$2E,(a1)+		+
	lea	-1(a1),a2		+
	move.w	d4,d1		+
	BPL.s	l147A02		+>
	moveq	#5,d1		+
	BRA.s	l147A0A		+>

l147A02	cmp.w	#5,d1		+<
	BCS.s	l147A0A		+>
	moveq	#5,d1		+
l147A0A	move.b	(a0)+,d0		+<
	BEQ.s	l147A1A		+>
	cmp.b	#$2E,d0		+
	BEQ.s	l147A0A		+>
	move.b	d0,(a1)+		+
	subq.w	#1,d1		+
	BNE.s	l147A0A		+>
l147A1A	clr.b	(a1)		+<
	tst.w	d4		+
	BPL.s	l147A34		+>
	lea	1(a2),a0		+
l147A24	move.b	(a0)+,d0		+<
	BEQ.s	l147A32		+>
	cmp.b	#$30,d0		+
	BEQ.s	l147A24		+>
	movea.l	a0,a2		+
	BRA.s	l147A24		+>

l147A32	movea.l	a2,a1		+<
l147A34	move.b	#$45,(a1)+		+<
	move.b	#$2B,(a1)+		+
	move.b	#$30,(a1)+		+
l147A40	cmp.b	#$A,d2		+<
	BCS.s	l147A52		+>
	addi.b	#1,-1(a1)		+
	subi.w	#$A,d2		+
	BRA.s	l147A40		+>

l147A52	addi.b	#$30,d2		+<
	move.b	d2,(a1)+		+
	clr.b	(a1)		+
	movea.l	l1476CC(pc),a0		+
	suba.l	a0,a1		+
	move.l	a1,d0		+
	movem.l	(a7)+,d1-d5/a2		+
	RTS			+

l147A68	tst.w	d0		+<
	BEQ.s	l147A76		+>
	clr.w	d2		+
	moveq	#1,d3		+
	lea	FloatMaskNum(pc),a0	+
	BRA.s	l147A92		+>

l147A76	clr.w	d3		+<
	move.w	a0,d2		+
	addq.l	#6,a0		+
	move.w	a0,-(a7)		+
	pea	l1476F1(pc)		+
	move.l	l1476D0(pc),-(a7)	+
	BSR	l147DF0		+>
	lea	$A(a7),a7		+
	lea	l1476F1(pc),a0		+
l147A92	movea.l	l1476CC(pc),a1		+<
	cmpi.b	#$2D,(a0)		+
	BNE.s	l147A9E		+>
	move.b	(a0)+,(a1)+		+
l147A9E	lea	2(a0),a2		+<
l147AA2	move.b	(a0)+,d0		+<
	BEQ.s	l147AB4		+>
	cmp.b	#$2E,d0		+
	BEQ.s	l147AA2		+>
	cmp.b	#$30,d0		+
	BEQ.s	l147AA2		+>
	BRA.s	l147AB8		+>

l147AB4	movea.l	a2,a0		+<
	moveq	#$30,d0		+
l147AB8	move.w	d4,d1		+<
	BPL.s	l147AC0		+>
	moveq	#6,d1		+
	BRA.s	l147AC8		+>

l147AC0	cmp.w	#6,d1		+<
	BCS.s	l147AC8		+
	moveq	#6,d1		+
l147AC8	move.b	d0,(a1)+		+<
	move.b	#$2E,(a1)+		+
	lea	-1(a1),a2		+
	tst.w	d1		+
	BEQ.s	l147AE8		+>
l147AD6	move.b	(a0)+,d0		+<
	BEQ.s	l147AE4		+>
	move.b	d0,(a1)+		+
	cmp.b	#$30,d0		+
	BEQ.s	l147AE4		+>
	movea.l	a1,a2		+
l147AE4	subq.w	#1,d1		+<
	BNE.s	l147AD6		+>
l147AE8	tst.w	d4		+<
	BPL.s	l147AEE		+>
	movea.l	a2,a1		+
l147AEE	tst.w	d3		+<
	BNE	l147A34		+>
	move.b	#$45,(a1)+		+
	move.b	#$2D,(a1)+		+
	move.b	#$30,(a1)+		+
	BRA	l147A40		+>

l147DF0	link	a6,#-8		+<
	movem.l	d3-d7,-(a7)		+
	move.l	$C(a6),-4(a6)		+
	tst.w	$10(a6)		+
	BGT.s	l147E08		+>
	moveq	#1,d0		+
	BRA.s	l147E1A		+>

l147E08	cmpi.w	#$16,$10(a6)		+<
	BLE.s	l147E14		+>
	moveq	#$17,d0		+
	BRA.s	l147E1A		+>

l147E14	move.w	$10(a6),d0		+<
	addq.w	#1,d0		+
l147E1A	move.w	d0,d4		+<
	clr.w	d7		+
	clr.l	-(a7)		+
	move.l	8(a6),-(a7)		+
	JSR	l148360		+>
	addq.l	#8,a7		+
	BGE.s	l147E4A		+>
	movea.l	$C(a6),a0		+
	move.b	#$2D,(a0)		+
	addq.l	#1,$C(a6)		+
	move.l	8(a6),-(a7)		+
	JSR	l1484D6		+>-
	addq.l	#4,a7		+
	move.l	d0,8(a6)		+
l147E4A	clr.l	-(a7)		+<
	move.l	8(a6),-(a7)		+
	JSR	l148360		+>-
	addq.l	#8,a7		+
	BLE.s	l147E88		+>
	BRA.s	l147E74		+>

l147E5C	move.l	#$A0000044,-(a7)	+<
	move.l	8(a6),-(a7)		+
	JSR	l1484B6		+>-
	addq.l	#8,a7		+
	move.l	d0,8(a6)		+
	subq.w	#1,d7		+
l147E74	move.l	#$80000041,-(a7)	+<
	move.l	8(a6),-(a7)		+
	JSR	l148360		+>
	addq.l	#8,a7		+
	BLT.s	l147E5C		+>
l147E88	BRA.s	l147EA2		+<>

l147E8A	move.l	#$A0000044,-(a7)	+<
	move.l	8(a6),-(a7)		+
	JSR	l14837E		+>
	addq.l	#8,a7		+
	move.l	d0,8(a6)		+
	addq.w	#1,d7		+
l147EA2	move.l	#$A0000044,-(a7)	+<
	move.l	8(a6),-(a7)		+
	JSR	l148360		+>
	addq.l	#8,a7		+
	BGE.s	l147E8A		+>
	add.w	d7,d4		+
	moveq	#1,d6		+
	move.w	d6,d0		+
	ext.l	d0		+
	move.l	d0,-(a7)		+
	JSR	l14839E		+>
	addq.l	#4,a7		+
	move.l	d0,-8(a6)		+
	BRA.s	l147EE6		+>

l147ECE	move.l	#$A0000044,-(a7)	+<
	move.l	-8(a6),-(a7)		+
	JSR	l14837E		+>
	addq.l	#8,a7		+
	move.l	d0,-8(a6)		+
	addq.w	#1,d6		+
l147EE6	cmp.w	d4,d6		+<
	BLT.s	l147ECE		+>
	move.l	#$80000042,-(a7)	+
	move.l	-8(a6),-(a7)		+
	JSR	l14837E		+>
	addq.l	#8,a7		+
	move.l	d0,-(a7)		+
	move.l	8(a6),-(a7)		+
	JSR	l148340		+>
	addq.l	#8,a7		+
	move.l	d0,8(a6)		+
	move.l	#$A0000044,-(a7)	+
	move.l	8(a6),-(a7)		+
	JSR	l148360		+>
	addq.l	#8,a7		+
	BLT.s	l147F2C		+>
	move.l	#$80000041,8(a6)	+
	addq.w	#1,d7		+
l147F2C	tst.w	d7		+<
	BGE.s	l147F64		+>
	movea.l	$C(a6),a0		+
	move.b	#$30,(a0)		+
	addq.l	#1,$C(a6)		+
	movea.l	$C(a6),a0		+
	move.b	#$2E,(a0)		+
	addq.l	#1,$C(a6)		+
	tst.w	d4		+
	BGE.s	l147F4E		+>
	sub.w	d4,d7		+
l147F4E	moveq	#-1,d6		+<
	BRA.s	l147F60		+>

l147F52	movea.l	$C(a6),a0		+<
	move.b	#$30,(a0)		+
	addq.l	#1,$C(a6)		+
	subq.w	#1,d6		+
l147F60	cmp.w	d7,d6		+<
	BGT.s	l147F52		+>
l147F64	clr.w	d6		+<
	BRA.s	l147FD2		+>

l147F68	move.l	8(a6),-(a7)		+<
	JSR	l14842E		+>
	addq.l	#4,a7		+
	move.w	d0,d5		+
	move.w	d5,d0		+
	addi.w	#$30,d0		+
	movea.l	$C(a6),a1		+
	move.b	d0,(a1)		+
	addq.l	#1,$C(a6)		+
	cmp.w	d7,d6		+
	BNE.s	l147F96		+>
	movea.l	$C(a6),a0		+
	move.b	#$2E,(a0)		+
	addq.l	#1,$C(a6)		+
l147F96	move.w	d5,d0		+<
	ext.l	d0		+
	move.l	d0,-(a7)		+
	JSR	l14839E		+>
	addq.l	#4,a7		+
	move.l	d0,-8(a6)		+
	move.l	d0,-(a7)		+
	move.l	8(a6),-(a7)		+
	JSR	l1484F2		+>
	addq.l	#8,a7		+
	move.l	d0,8(a6)		+
	move.l	#$A0000044,-(a7)	+
	move.l	8(a6),-(a7)		+
	JSR	l1484B6		+>
	addq.l	#8,a7		+
	move.l	d0,8(a6)		+
	addq.w	#1,d6		+
l147FD2	cmp.w	d4,d6		+<
	BLT.s	l147F68		+>
	movea.l	$C(a6),a0		+
	clr.b	(a0)		+
	addq.l	#1,$C(a6)		+
	move.l	-4(a6),d0		+
	tst.l	(a7)+		+
	movem.l	(a7)+,d4-d7		+
	unlk	a6		+
	RTS			+

l147FEE	link	a6,#-$2E		;<
	movem.l	d7/a4-a5,-(a7)		;
	lea	-$14(a6),a5		;
	lea	-$18(a6),a4		;
	clr.w	-$1E(a6)		;
	clr.w	-$26(a6)		;
	BRA.s	l14800C		;>

l148008	addq.l	#1,8(a6)		;<
l14800C	movea.l	8(a6),a0		;<
	cmpi.b	#$20,(a0)		;
	BEQ.s	l148008		;>
	movea.l	8(a6),a0		;
	cmpi.b	#9,(a0)		;
	BEQ.s	l148008		;>
	movea.l	8(a6),a0		;
	cmpi.b	#$2D,(a0)		;
	BEQ.s	l14802E		;>
	clr.w	d0		;
	BRA.s	l148030		;>

l14802E	moveq	#1,d0		;<
l148030	move.w	d0,-$22(a6)		;<
	movea.l	8(a6),a0		;
	cmpi.b	#$2D,(a0)		;
	BEQ.s	l148048		;>
	movea.l	8(a6),a0		;
	cmpi.b	#$2B,(a0)		;
	BNE.s	l14804C		;>
l148048	addq.l	#1,8(a6)		;<
l14804C	BRA.s	l148072		;<>

l14804E	movea.l	8(a6),a0		;<
	cmpi.b	#$2E,(a0)		;
	BNE.s	l14805E		;>
	addq.w	#1,-$1E(a6)		;
	BRA.s	l14806E		;>

l14805E	movea.l	8(a6),a0		;<
	move.b	(a0),(a5)+		;
	tst.w	-$1E(a6)		;
	BEQ.s	l14806E		;>
	addq.w	#1,-$26(a6)		;
l14806E	addq.l	#1,8(a6)		;<
l148072	movea.l	8(a6),a0		;<
	tst.b	(a0)		;
	BEQ.s	l14808E		;>
	movea.l	8(a6),a0		;
	cmpi.b	#$65,(a0)		;
	BEQ.s	l14808E		;>
	movea.l	8(a6),a0		;
	cmpi.b	#$45,(a0)		;
	BNE.s	l14804E		;>
l14808E	clr.b	(a5)		;<
	movea.l	8(a6),a0		;
	cmpi.b	#$65,(a0)		;
	BEQ.s	l1480A4		;>
	movea.l	8(a6),a0		;
	cmpi.b	#$45,(a0)		;
	BNE.s	l1480E8		;>
l1480A4	addq.l	#1,8(a6)		;<
	movea.l	8(a6),a0		;
	cmpi.b	#$2D,(a0)		;
	BEQ.s	l1480B6		;>
	clr.w	d0		;
	BRA.s	l1480B8		;>

l1480B6	moveq	#1,d0		;<
l1480B8	move.w	d0,-$20(a6)		;<
	movea.l	8(a6),a0		;
	cmpi.b	#$2D,(a0)		;
	BEQ.s	l1480D0		;>
	movea.l	8(a6),a0		;
	cmpi.b	#$2B,(a0)		;
	BNE.s	l1480D4		;>
l1480D0	addq.l	#1,8(a6)		;<
l1480D4	BRA.s	l1480E0		;<>

l1480D6	movea.l	8(a6),a0		;<
	move.b	(a0),(a4)+		;
	addq.l	#1,8(a6)		;
l1480E0	movea.l	8(a6),a0		;<
	tst.b	(a0)		;
	BNE.s	l1480D6		;>
l1480E8	clr.b	(a4)		;<
	move.l	a6,(a7)		;
	addi.l	#$FFFFFFEC,(a7)		;
	BSR	l1481D6		;>
	move.l	d0,-$2A(a6)		;
	move.l	a6,(a7)		;
	addi.l	#$FFFFFFE8,(a7)		;
	JSR	l14873E		;>
	move.w	d0,-$24(a6)		;
	tst.w	-$20(a6)		;
	BEQ.s	l14811E		;
	move.w	-$24(a6),d0		;
	neg.w	d0		;
	sub.w	-$26(a6),d0		;
	BRA.s	l148126		;

l14811E	move.w	-$24(a6),d0		;<
	sub.w	-$26(a6),d0		;
l148126	move.w	d0,-$26(a6)		;
	move.l	-$2A(a6),-(a7)		;
	move.w	-$26(a6),-(a7)		;
	BSR.s	l14816E		;>
	addq.l	#2,a7		;
	move.l	d0,-(a7)		;
	JSR	l1484B6		;>
	addq.l	#8,a7		;
	move.l	d0,-$2E(a6)		;
	move.l	-$2E(a6),(a7)		;
	JSR	l148244		;>
	move.l	d0,-$1C(a6)		;
	tst.w	-$22(a6)		;
	BEQ.s	l148160		;>
	ori.l	#$80,-$1C(a6)		;
l148160	move.l	-$1C(a6),d0		;<
	tst.l	(a7)+		;
	movem.l	(a7)+,a4-a5		;
	unlk	a6		;
	RTS			;

l14816E	link	a6,#-8		;<
	tst.w	8(a6)		;
	BGE.s	l1481A4		;>
	move.l	#$80000041,-4(a6)	;
	BRA.s	l14819C		;>

l148182	move.l	#$A0000044,-(a7)	;<
	move.l	-4(a6),-(a7)		;
	JSR	l14837E		;>
	addq.l	#8,a7		;
	move.l	d0,-4(a6)		;
	addq.w	#1,8(a6)		;
l14819C	tst.w	8(a6)		;<
	BLT.s	l148182		;>
	BRA.s	l1481CE		;>

l1481A4	move.l	#$80000041,-4(a6)	;<
	BRA.s	l1481C8		;
l1481AE	move.l	#$A0000044,-(a7)	;<
	move.l	-4(a6),-(a7)		;
	JSR	l1484B6		;>
	addq.l	#8,a7		;
	move.l	d0,-4(a6)		;
	subq.w	#1,8(a6)		;
l1481C8	tst.w	8(a6)		;<
	BGT.s	l1481AE		;>
l1481CE	move.l	-4(a6),d0		;<
	unlk	a6		;
	RTS			;

l1481D6	link	a6,#-8		;<
	move.l	#0,-4(a6)		;
	BRA.s	l148228		;>

l1481E4	move.l	#$A0000044,-(a7)	;<
	move.l	-4(a6),-(a7)		;
	JSR	l1484B6		;>
	addq.l	#8,a7		;
	move.l	d0,-4(a6)		;
	move.l	-4(a6),-(a7)		;
	movea.l	8(a6),a0		;
	move.b	(a0),d0		;
	ext.w	d0		;
	addi.w	#$FFD0,d0		;
	ext.l	d0		;
	move.l	d0,-(a7)		;
	JSR	l14839E		;>
	addq.l	#4,a7		;
	move.l	d0,-(a7)		;
	JSR	l148340		;
	addq.l	#8,a7		;
	move.l	d0,-4(a6)		;
	addq.l	#1,8(a6)		;
l148228	movea.l	8(a6),a0		;<
	cmpi.b	#$30,(a0)		;
	BLT.s	l14823C		;>
	movea.l	8(a6),a0		;
	cmpi.b	#$39,(a0)		;
	BLE.s	l1481E4		;>
l14823C	move.l	-4(a6),d0		;<
	unlk	a6		;
	RTS			;

l148244	link	a6,#-4		;<
	movem.l	d4-d7,-(a7)		;
	clr.l	-(a7)		;
	move.l	8(a6),-(a7)		;
	JSR	l148360		;>
	addq.l	#8,a7		;
	BNE.s	l148262		;>
	clr.l	d0		;
	BRA	l148336		;>

l148262	clr.l	-(a7)		;<
	move.l	8(a6),-(a7)		;
	JSR	l148360		;>
	addq.l	#8,a7		;
	BGE.s	l148286		;>
	move.l	8(a6),-(a7)		;
	JSR	l1484D6		;>
	addq.l	#4,a7		;
	move.l	d0,8(a6)		;
	moveq	#1,d5		;
	BRA.s	l148288		;>

l148286	clr.w	d5		;<
l148288	clr.w	d7		;<
	BRA.s	l1482A4		;>

l14828C	addq.w	#1,d7		;<
	move.l	#$80000042,-(a7)	;
	move.l	8(a6),-(a7)		;
	JSR	l14837E		;
	addq.l	#8,a7		;
	move.l	d0,8(a6)		;
l1482A4	move.l	#$80000041,-(a7)	;<
	move.l	8(a6),-(a7)		;
	JSR	l148360		;>
	addq.l	#8,a7		;
	BGE.s	l14828C		;>
	BRA.s	l1482D2		;>

l1482BA	subq.w	#1,d7		;<
	move.l	#$80000042,-(a7)	;
	move.l	8(a6),-(a7)		;
	JSR	l1484B6		;>
	addq.l	#8,a7		;
	move.l	d0,8(a6)		;
l1482D2	move.l	#$80000040,-(a7)	;<
	move.l	8(a6),-(a7)		;
	JSR	l148360		;>
	addq.l	#8,a7		;
	BLT.s	l1482BA		;>
	move.l	#$80000059,-(a7)	;
	move.l	8(a6),-(a7)		;
	JSR	l1484B6		;>
	addq.l	#8,a7		;
	move.l	d0,8(a6)		;
	move.l	8(a6),-(a7)		;
	JSR	l14842E		;>
	addq.l	#4,a7		;
	move.l	d0,-4(a6)		;
	move.l	-4(a6),d0		;
	asl.l	#8,d0		;
	move.l	d0,-4(a6)		;
	addi.w	#$40,d7		;
	move.w	d7,d0		;
	andi.w	#$7F,d0		;
	ext.l	d0		;
	or.l	d0,-4(a6)		;
	tst.w	d5		;
	BEQ.s	l148332		;>
	ori.l	#$80,-4(a6)		;
l148332	move.l	-4(a6),d0		;<
l148336	tst.l	(a7)+		;<
	movem.l	(a7)+,d5-d7		;
	unlk	a6		;
	RTS			;

l148340	link	a6,#-4		;
	movem.l	d3-d7,-(a7)		;
	move.l	8(a6),d7		;
	move.l	$C(a6),d6		;
	JSR	l148550		;>
	move.l	d7,d0		;
	movem.l	(a7)+,d3-d7		;
	unlk	a6		;
	RTS			;

l148360	link	a6,#-4		;<+
	movem.l	d3-d7,-(a7)		; +
	move.l	8(a6),d7		; +
	move.l	$C(a6),d6		; +
	JSR	l148512		;>+
	movem.l	(a7)+,d3-d7		; +
	unlk	a6		; +
	RTS			; +

l14837E	link	a6,#-4		;
	movem.l	d3-d7,-(a7)		;
	move.l	8(a6),d7		;
	move.l	$C(a6),d6		;
	JSR	l148646		;>
	move.l	d7,d0		;
	movem.l	(a7)+,d3-d7		;
	unlk	a6		;
	RTS			;

l14839E	link	a6,#0		;<
	movem.l	d5-d7,-(a7)		;
	tst.l	8(a6)		;
	BGE.s	l1483BA		;>
	moveq	#1,d6		;
	move.l	8(a6),d0		;
	neg.l	d0		;
	move.l	d0,8(a6)		;
	BRA.s	l1483BC		;>

l1483BA	clr.w	d6		;<
l1483BC	tst.l	8(a6)		;<
	BNE.s	l1483C6		;>
	clr.l	d0		;
	BRA.s	l148424		;>

l1483C6	moveq	#$18,d7		;<
	BRA.s	l1483D6		;>

l1483CA	move.l	8(a6),d0		;<
	asr.l	#1,d0		;
	move.l	d0,8(a6)		;
	addq.l	#1,d7		;
l1483D6	move.l	8(a6),d0		;<
	andi.l	#$7F000000,d0		;
	BNE.s	l1483CA		;>
	BRA.s	l1483F0		;>

l1483E4	move.l	8(a6),d0		;<
	asl.l	#1,d0		;
	move.l	d0,8(a6)		;
	subq.l	#1,d7		;
l1483F0	btst	#7,9(a6)		;
	BEQ.s	l1483E4		;>
	move.l	8(a6),d0		;
	asl.l	#8,d0		;
	move.l	d0,8(a6)		;
	addi.l	#$40,d7		;
	move.l	d7,d0		;
	andi.l	#$7F,d0		;
	or.l	d0,8(a6)		;
	tst.w	d6		;
	BEQ.s	l148420		;>
	ori.l	#$80,8(a6)		;
l148420	move.l	8(a6),d0		;<
l148424	tst.l	(a7)+		;<
	movem.l	(a7)+,d6-d7		;
	unlk	a6		;
	RTS			;

l14842E	link	a6,#0		;<
	movem.l	d4-d7,-(a7)		;
	move.l	8(a6),d0		;
	andi.l	#$7F,d0		;
	addi.l	#$FFFFFFC0,d0		;
	move.w	d0,d6		;
	tst.l	8(a6)		;
	BEQ.s	l148452		;>
	tst.w	d6		;
	BGE.s	l148456		;>
l148452	clr.l	d0		;<
	BRA.s	l1484AC		;>

l148456	move.l	8(a6),d0		;<
	andi.l	#$80,d0		;
	move.w	d0,d5		;
	cmp.w	#$1F,d6		;
	BLE.s	l14847C		;>
	tst.w	d5		;
	BEQ.s	l148474		;>
	move.l	#$80000000,d0		;
	BRA.s	l14847A		;>

l148474	move.l	#$7FFFFFFF,d0		;<
l14847A	BRA.s	l1484AC		;<>

l14847C	move.l	8(a6),d7		;<
	asr.l	#8,d7		;
	andi.l	#$FFFFFF,d7		;
	subi.w	#$18,d6		;
	BRA.s	l148492		;>

l14848E	asr.l	#1,d7		;<
	addq.w	#1,d6		;
l148492	tst.w	d6		;<
	BLT.s	l14848E		;>
	BRA.s	l14849C		;>

l148498	asl.l	#1,d7		;<
	subq.w	#1,d6		;
l14849C	tst.w	d6		;<
	BGT.s	l148498		;>
	tst.w	d5		;
	BEQ.s	l1484AA		;>
	move.l	d7,d0		;
	neg.l	d0		;
	move.l	d0,d7		;
l1484AA	move.l	d7,d0		;<
l1484AC	tst.l	(a7)+		;
	movem.l	(a7)+,d5-d7		;
	unlk	a6		;
	RTS			;

l1484B6	link	a6,#-4		;<+
	movem.l	d3-d7,-(a7)		; +
	move.l	8(a6),d7		; +
	move.l	$C(a6),d6		; +
	JSR	l1486B8		;>+
	move.l	d7,d0		; +
	movem.l	(a7)+,d3-d7		; +
	unlk	a6		; +
	RTS			; +

l1484D6	link	a6,#-4		;<+
	movem.l	d3-d7,-(a7)		; +
	move.l	8(a6),d7		; +
	JSR	l148534		;>+
	move.l	d7,d0		; +
	movem.l	(a7)+,d3-d7		; +
	unlk	a6		; +
	RTS			; +

l1484F2	link	a6,#-4
	movem.l	d3-d7,-(a7)
	move.l	8(a6),d7
	move.l	$C(a6),d6
	JSR	l14853E
	move.l	d7,d0
	movem.l	(a7)+,d3-d7
	unlk	a6
	RTS

l148512	tst.b	d6		;<
	BPL.s	l148522		;>
	tst.b	d7		;
	BPL.s	l148522		;>
	cmp.b	d7,d6		;
	BNE.s	l148528		;>
	cmp.l	d7,d6		;
	RTS			;

l148522	cmp.b	d6,d7		;<
	BNE.s	l148528		;>
	cmp.l	d6,d7		;
l148528	RTS			;<

	tst.b	d7
	RTS

	andi.b	#$7F,d7
	RTS

l148534	tst.b	d7		;<+
	BEQ.s	l14853C		;>+
	eori.b	#$80,d7		; +
l14853C	RTS			;<+

l14853E	move.b	d6,d4
	BEQ.s	l148594
	eori.b	#$80,d4
	BMI.s	l1485B2
	move.b	d7,d5
	BMI.s	l1485B8
	BNE.s	l14855C
	BRA.s	l14858E

l148550	move.b	d6,d4		;<
	BMI.s	l1485B2		;>
	BEQ.s	l148594		;>
	move.b	d7,d5		;
	BMI.s	l1485B8		;>
	BEQ.s	l14858E		;>
l14855C	sub.b	d4,d5		;<
	BMI.s	l148598		;>
	move.b	d7,d4		;
	cmp.b	#$18,d5		;
	BCC.s	l148594		;>
	move.l	d6,d3		;
	clr.b	d3		;
	lsr.l	d5,d3		;
	move.b	#$80,d7		;
	add.l	d3,d7		;
	BCS.s	l14857A		;>
l148576	move.b	d4,d7		;<
	RTS			;

l14857A	roxr.l	#1,d7		;<
	addq.b	#1,d4		;
	bvs.s	l148582		;>
	BCC.s	l148576		;>
l148582	moveq	#-1,d7		;<
	subq.b	#1,d4		;
	move.b	d4,d7		;
	ori.b	#2,ccr		;
	RTS			;

l14858E	move.l	d6,d7		;<
	move.b	d4,d7		;
	RTS			;

l148594	tst.b	d7		;<
	RTS			;

l148598	cmp.b	#$E8,d5		;<
	BLE.s	l14858E		;>
	neg.b	d5		;
	move.l	d6,d3		;
	clr.b	d7		;
	lsr.l	d5,d7		;
	move.b	#$80,d3		;
	add.l	d3,d7		;
	BCS.s	l14857A		;>
	move.b	d4,d7		;
	RTS			;

l1485B2	move.b	d7,d5		;<
	BMI.s	l14855C		;>
	BEQ.s	l14858E		;>
l1485B8	moveq	#-$80,d3		;<
	eor.b	d3,d5		;
	sub.b	d4,d5		;
	BEQ.s	l148610		;>
	BMI.s	l1485FE		;>
	cmp.b	#$18,d5		;
	BCC.s	l148594		;>
	move.b	d7,d4		;
	move.b	d3,d7		;
	move.l	d6,d3		;
l1485CE	clr.b	d3		;<
	lsr.l	d5,d3		;
	sub.l	d3,d7		;
	BMI.s	l148576		;>
l1485D6	move.b	d4,d5		;<
l1485D8	clr.b	d7		;<
	subq.b	#1,d4		;
	cmp.l	#$7FFF,d7		;
	bhi.s	l1485EA		;>
	swap	d7		;
	subi.b	#$10,d4		;
l1485EA	add.l	d7,d7		;<
	dBMI	d4,l1485EA		;>
	eor.b	d4,d5		;
	BMI.s	l1485FA		;>
	move.b	d4,d7		;
	BEQ.s	l1485FA		;>
	RTS			;

l1485FA	moveq	#0,d7		;<
	RTS			;

l1485FE	cmp.b	#$E8,d5		;<
	BLE.s	l14858E		;>
	neg.b	d5		;
	move.l	d7,d3		;
	move.l	d6,d7		;
	move.b	#$80,d7		;
	BRA.s	l1485CE		;>

l148610	move.b	d7,d5		;<
	exg	d5,d4		;
	move.b	d6,d7		;
	sub.l	d6,d7		;
	BEQ.s	l1485FA		;>
	BPL.s	l1485D6		;>
	neg.l	d7		;
	move.b	d5,d4		;
	BRA.s	l1485D8		;>

l148622	divu.w	#0,d7		;<
	tst.l	d6		;
	BNE.s	l148646		;>
l14862A	ori.l	#$FFFFFF7F,d7		;<
	tst.b	d7		;
	ori.b	#2,ccr		;
l148636	RTS			;<

l148638	swap	d6		;<
	swap	d7		;
l14863C	eor.b	d6,d7		;<
	BRA.s	l14862A		;>

l148640	BMI.s	l14863C		;<
l148642	moveq	#0,d7		;<
	RTS			;

l148646	move.b	d6,d5		;<
	BEQ.s	l148622		;>
	move.l	d7,d4		;
	BEQ.s	l148636		;>
	moveq	#-$80,d3		;
	add.w	d5,d5		;
	add.w	d4,d4		;
	eor.b	d3,d5		;
	eor.b	d3,d4		;
	sub.b	d5,d4		;
	bvs.s	l148640		;>
	clr.b	d7		;
	swap	d7		;
	swap	d6		;
	cmp.w	d6,d7		;
	BMI.s	l14866C		;>
	addq.b	#2,d4		;
	bvs.s	l148638		;>
	ror.l	#1,d7		;
l14866C	swap	d7		;<
	move.b	d3,d5		;
	eor.w	d5,d4		;
	lsr.w	#1,d4		;
	move.l	d7,d3		;
	divu.w	d6,d3		;
	move.w	d3,d5		;
	mulu.w	d6,d3		;
	sub.l	d3,d7		;
	swap	d7		;
	swap	d6		;
	move.w	d6,d3		;
	clr.b	d3		;
	mulu.w	d5,d3		;
	sub.l	d3,d7		;
	BCC.s	l148694		;>
	move.l	d6,d3		;
	clr.b	d3		;
	add.l	d3,d7		;
	subq.w	#1,d5		;
l148694	move.l	d6,d3		;<
	swap	d3		;
	clr.w	d7		;
	divu.w	d3,d7		;
	swap	d5		;
	BMI.s	l1486A8		;>
	move.w	d7,d5		;
	add.l	d5,d5		;
	subq.b	#1,d4		;
	move.w	d5,d7		;
l1486A8	move.w	d7,d5		;<
	addi.l	#$80,d5		;
	move.l	d5,d7		;
	move.b	d4,d7		;
	BEQ.s	l148642		;>
	RTS			;

l1486B8	move.b	d7,d5		;<
	BEQ.s	l14870E		;>
	move.b	d6,d4		;
	BEQ.s	l148728		;>
	add.w	d5,d5		;
	add.w	d4,d4		;
	moveq	#-$80,d3		;
	eor.b	d3,d4		;
	eor.b	d3,d5		;
	add.b	d4,d5		;
	bvs.s	l14872C		;>
	move.b	d3,d4		;
	eor.w	d4,d5		;
	ror.w	#1,d5		;
	swap	d5		;
	move.w	d6,d5		;
	clr.b	d7		;
	clr.b	d5		;
	move.w	d5,d4		;
	mulu.w	d7,d4		;
	swap	d4		;
	move.l	d7,d3		;
	swap	d3		;
	mulu.w	d5,d3		;
	add.l	d3,d4		;
	swap	d6		;
	move.l	d6,d3		;
	mulu.w	d7,d3		;
	add.l	d3,d4		;
	clr.w	d4		;
	addx.b	d4,d4		;
	swap	d4		;
	swap	d7		;
	mulu.w	d6,d7		;
	swap	d6		;
	swap	d5		;
	add.l	d4,d7		;
	BPL.s	l148710		;>
	addi.l	#$80,d7		;
	move.b	d5,d7		;
	BEQ.s	l148728		;
l14870E	RTS			;<

l148710	subq.b	#1,d5		;<
	bvs.s	l148728		;>
	BCS.s	l148728		;>
	moveq	#$40,d4		;
	add.l	d4,d7		;
	add.l	d7,d7		;
	BCC.s	l148722		;>
	roxr.l	#1,d7		;
	addq.b	#1,d5		;
l148722	move.b	d5,d7		;<
	BEQ.s	l148728		;>
	RTS			;

l148728	moveq	#0,d7		;<
	RTS			;

l14872C	BPL.s	l148728		;<>
	eor.b	d6,d7		;
	ori.l	#$FFFFFF7F,d7		;
	tst.b	d7		;
	ori.b	#2,ccr		;
	RTS			;

l14873E	link	a6,#0		;<
	movem.l	d5-d7/a5,-(a7)		;
	movea.l	8(a6),a5		;
	clr.w	d7		;
	clr.w	d6		;
	BRA.s	l148752		;>

	addq.l	#1,a5
l148752	move.b	(a5),d0		;<
	ext.w	d0		;
	ext.l	d0		;
	addi.l	#0,d0		;
	movea.l	d0,a0		;
	cmpi.b	#$2B,(a5)		;
	BNE.s	l14876A		;>
	addq.l	#1,a5		;
	BRA.s	l148774		;>

l14876A	cmpi.b	#$2D,(a5)		;<
	BNE.s	l148774		;>
	addq.l	#1,a5		;
	addq.w	#1,d6		;
l148774	BRA.s	l148784		;<>

l148776	muls.w	#$A,d7		;<
	move.b	(a5)+,d0		;
	ext.w	d0		;
	add.w	d0,d7		;
	addi.w	#$FFD0,d7		;
l148784	cmpi.b	#$30,(a5)		;<
	BLT.s	l148790		;>
	cmpi.b	#$39,(a5)		;
	BLE.s	l148776		;>
l148790	tst.w	d6		;<
	BEQ.s	l14879A		;>
	move.w	d7,d0		;
	neg.w	d0		;
	move.w	d0,d7		;
l14879A	move.w	d7,d0		;<
	tst.l	(a7)+		;
	movem.l	(a7)+,d6-d7/a5		;
	unlk	a6		;
	RTS			;

	SECTION	DATA

FloatSingleNum	dc.s	1245.7863
FloatAsciiNum	dc.b	"1245.7863",0

l1476CC	dc.l	0		+
l1476D0	dc.l	0		+

FloatMaskNum	dc.b	"0.0000000",0

BADFloatTxt	dc.b	$15," BAD FLOAT TRAP ",$12,0

l1476F1	dc.b	65		;

	SECTION	BSS
	
EmptyBuffer	ds.b	256