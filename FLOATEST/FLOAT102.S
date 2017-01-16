; /// Original STOS Float LiBRAry - TRAP 6 ///

	BRA	InstallTRAP

JumpRoutArea	dc.b	AddFloat,SubFloat
	dc.b	MulFloat,DivFloat
	dc.b	SinFloat,CosFloat
	dc.b	TanFloat,ExpFloat
	dc.b	LogFloat,Log10Float
	dc.b	SqrFloat,AsciiFloat
	dc.b	FloatAscii,FloatInteger
	dc.b	IntegerFloat,EqualFloat
	dc.b	NEqualFloat,GEqualFloat
	dc.b	LThanFloat,LEqualFloat
	dc.b	ASinFloat,ACosFloat
	dc.b	ATanFloat,HSinFloat
	dc.b	HCosFloat,HTanFloat
	dc.b	Integering,PowFloat
	dc.b	l147BE6,l147B9E

SpecialArea	dc.b	0,MutateFlag
	dc.b	MagicAsk,l14779A
	dc.b	l1477C0,l1477E6

l1476CC	dc.l	0		+
l1476D0	dc.l	0		+

FloatMaskNum	dc.b	"0.0000000",0

BADFloatTxt	dc.b	$15," BAD FLOAT TRAP ",$12,0

l1476F1	dc.b	65		;

; /// TRAP Installation ///

InstallTRAP	pea	TRAPWrite(pc)
	move.w	#$26,-(a7)		; - SupExec -
	trap	#14		; *** XBIOS ***
	addq.l	#6,a7
	lea	l148B78(pc),a0
	RTS
	
; /// TRAP 6 Write (SuperVisor Mode Only) ///
	
TRAPWrite	lea	TRAPJumper(pc),a0
	move.l	a0,$98		; TRAP 6
	RTS
	
; /// TRAP Called Jumper ///
	
TRAPJumper	lsl.w	#2,d0		; Multiplie par 4
	BMI.s	SpecialJumper		; Sup‚rieur … 8192
	lea	JumpRoutArea(pc),a1
	movea.l	0(a1,d0.w),a1
	JMP	(a1)		; Et zou...

; /// Special Code Called Jumper ///

SpecialJumper	tst.b	d0
	BEQ.s	FlagChange
	andi.w	#$FF,d0		; On garde l'octet faible
	lea	SpecialArea(pc),a1
	movea.l	0(a1,d0.w),a1
	JMP	(a1)

; /// Flag Changer ///

FlagChange	bchg	#7,d3
	RTE

; /// Special 1 : Mutate Flag ///

MutateFlag	tst.l	d3
	BEQ.s	FalseFlag
	btst	#7,d3
	BNE.s	TrueFlag
	moveq	#1,d0
	RTE

TrueFlag	moveq	#-1,d0
	RTE

FalseFlag	moveq	#0,d0
	RTE

; /// Special 2 : Magic Ask ///

MagicAsk	move.l	#$C90FD942,d3
	move.l	#$12345678,d4
	RTE
	
; /// Special 3 ///

l14779A	move.l	#$C90FC942,-(a7)
	move.l	d3,-(a7)
	BSR	l1488FC
	addq.l	#8,a7
	move.l	d0,-(a7)
	move.l	#$B4000048,-(a7)
	BSR	l14891C
	addq.l	#8,a7
	move.l	d0,d3
	move.l	#$12345678,d4
	RTE

l1477C0	move.l	#$B4000048,-(a7)
	move.l	d3,-(a7)
	BSR	l1488FC
	addq.l	#8,a7
	move.l	d0,-(a7)
	move.l	#$C90FC942,-(a7)
	BSR	l14891C
	addq.l	#8,a7
	move.l	d0,d3
	move.l	#$12345678,d4
	RTE

l1477E6	moveq	#0,d3
	move.l	#$12345678,d4
	RTE
	
; /// Add To Float ///	
;
; D1-D2 : Float 1
; D3-D4 : Float 2
;
; D0-D1 : Retour

AddFloat	move.l	d3,-(a7)
	move.l	d1,-(a7)
	BSR	l1488BE
	addq.l	#8,a7
	move.l	#$12345678,d1
	RTE
	
; /// Sub To Float ///
;
; D1-D2 : Float 1
; D3-D4 : Float 2
;
; D0-D1 : Retour
	
SubFloat	move.l	d3,-(a7)
	move.l	d1,-(a7)
	BSR	l14893C
	addq.l	#8,a7
	move.l	#$12345678,d1
	RTE
	
; /// Mul To Float ///
;
; D1-D2 : Float 1
; D3-D4 : Float 2
;
; D0-D1 : Retour
	
MulFloat	move.l	d3,-(a7)
	move.l	d1,-(a7)
	BSR	l14891C
	addq.l	#8,a7
	move.l	#$12345678,d1
	RTE
	
; /// Div To Float ///
;
; D1-D2 : Float 1
; D3-D4 : Float 2
;
; D0-D1 : Retour
	
DivFloat	tst.l	d3
	BEQ.s	l14783C
	move.l	d3,-(a7)
	move.l	d1,-(a7)
	BSR	l1488FC
	addq.l	#8,a7
	move.l	#$12345678,d1
	RTE

l14783C	divu.w	#0,d1
	RTE
	
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
	RTE			;

; /// Float To Ascii ///			+
;				+
; D1-D2 : Float To Convert			+
; D3 : Ascii Number BetWeen 0-7 For Mantissa Expression	+
; A0 : Empty Buffer For Ascii Number		+
;				+
; D0 : Lenght Of The Buffer			+
; A0 : Buffer				+
				+
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
	RTE			+

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
				+ A0 : End Buffer
	exg	d0,a0		+ Normal Return
	movem.l	(a7)+,d1-d5/a2		+
	RTE			+
	
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
	RTE			+

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
	RTE			+

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

; /// Transform Float InTo Integer Form ///
;
; D1-D2 : Float
;
; D0 : Integer Form

FloatInteger	move.l	d1,-(a7)
	BSR	l148836
	addq.l	#4,a7
	RTE
	
; /// Transform Integer InTo Float ///
;
; D1 : Integer
;
; D0-D1 : Float
	
IntegerFloat	move.l	d1,-(a7)
	BSR	l1487A6
	addq.l	#4,a7
	move.l	#$12345678,d1
	RTE
	
; /// Equal Two Float ///
;
; D1-D2 : Float 1
; D3-D4 : Float 2
;
; D0 : 1 si ‚gaux, sinon 0

EqualFloat	move.l	d3,-(a7)
	move.l	d1,-(a7)
	BSR	l1488DE
	addq.l	#8,a7
	BEQ.s	l147B2E
l147B2A	moveq	#0,d0
	RTE

l147B2E	moveq	#-1,d0
	RTE

; /// NEqual Two Float ///
;
; D1-D2 : Float 1
; D3-D4 : Float 2
;
; D0 : 1 si le premier est plus grand que le second, sinon 0

NEqualFloat	move.l	d3,-(a7)
	move.l	d1,-(a7)
	BSR	l1488DE
	addq.l	#8,a7
	BNE.s	l147B2E
	BRA.s	l147B2A
	
; /// LEqual Two Float ///
;
; D1-D2 : Float 1
; D3-D4 : Float 2
;
; D0 : 1 si le premier est inf‚rieur ou ‚gal au second, sinon 0
	
LEqualFloat	move.l	d3,-(a7)
	move.l	d1,-(a7)
	BSR	l1488DE
	addq.l	#8,a7
	BLT.s	l147B2E
	BRA.s	l147B2A

; /// ArcSinus of a Float ///
;
; D1-D2 : Float
;
; D0-D1 : Retour

ASinFloat	move.l	d3,-(a7)
	move.l	d1,-(a7)
	BSR	l1488DE
	addq.l	#8,a7
	BLE.s	l147B2E
	BRA.s	l147B2A

; /// GEqual Two Float ///
;
; D1-D2 : Float 1
; D3-D4 : Float 2
;
; D0 : 1 si le premier est plus grand ou ‚gal au second, sinon 0

GEqualFloat	move.l	d3,-(a7)
	move.l	d1,-(a7)
	BSR	l1488DE
	addq.l	#8,a7
	BGT.s	l147B2E
	BRA.s	l147B2A

; /// LThan Two Float ///
;
; D1-D2 : Float 1
; D3-D4 : Float 2
;
; D0 : 1 si le premier est plus petit que le second, sinon 0

LThanFloat	move.l	d3,-(a7)
	move.l	d1,-(a7)
	BSR	l1488DE
	addq.l	#8,a7
	BGE.s	l147B2E
	BRA.s	l147B2A

; /// Tangente of a Float ///
;
; D1-D2 : Float
;
; D0-D1 : Retour

TanFloat	move.l	d1,-(a7)
	BSR	l147C26
	move.l	d0,l1476D0
	BSR	l147BCC
	move.l	d0,(a7)
	move.l	l1476D0,-(a7)
	BSR	l1488FC
	addq.l	#8,a7
	move.l	#$12345678,d1
	RTE

l147B9E	move.l	d1,d0
	bclr	#7,d0
	move.l	#$12345678,d1
	RTE

; /// Pow of Two Float ///
;
; D1-D2 : Float 1
; D3-D4 : Float 2
;
; D0-D1 : Retour

PowFloat	move.l	d1,-(a7)
	BSR	l1495DA
	addq.l	#4,a7
	move.l	#$12345678,d1
	RTE

; /// Coinus of a Float ///
;
; D1-D2 : Float
;
; D0-D1 : Retour

CosFloat	move.l	d1,-(a7)
	BSR	l147BCC
	addq.l	#4,a7
	move.l	#$12345678,d1
	RTE

l147BCC	link	a6,#-4
	movem.l	d3-d7,-(a7)
	move.l	8(a6),d7
	BSR	l148EDE
	move.l	d7,d0
	movem.l	(a7)+,d3-d7
	unlk	a6
	RTS

l147BE6	move.l	d3,-(a7)
	move.l	d1,-(a7)
	BSR	l147BF8
	addq.l	#8,a7
	move.l	#$12345678,d1
	RTE

l147BF8	link	a6,#-4
	movem.l	d3-d7,-(a7)
	move.l	8(a6),d7
	move.l	$C(a6),d6
	BSR	l148EA8
	move.l	d7,d0
	movem.l	(a7)+,d3-d7
	unlk	a6
	RTS

; /// Sinus of a Float ///
;
; D1-D2 : Float
;
; D0-D1 : Retour

SinFloat	move.l	d1,-(a7)
	BSR	l147C26
	addq.l	#4,a7
	move.l	#$12345678,d1
	RTE

l147C26	link	a6,#-4
	movem.l	d3-d7,-(a7)
	move.l	8(a6),d7
	BSR	l148EF0
	move.l	d7,d0
	movem.l	(a7)+,d3-d7
	unlk	a6
	RTS

; /// Square of a Float ///
;
; D1-D2 : Float
;
; D0-D1 : Retour

SqrFloat	move.l	d1,-(a7)
	BSR	l147C50
	addq.l	#4,a7
	move.l	#$12345678,d1
	RTE

l147C50	link	a6,#-4
	movem.l	d3-d7,-(a7)
	move.l	8(a6),d7
	BSR	l149056
	move.l	d7,d0
	movem.l	(a7)+,d3-d7
	unlk	a6
	RTS

; /// Exponant of a Float ///
;
; D1-D2 : Float
;
; D0-D1 : Retour

ExpFloat	move.l	d1,-(a7)
	BSR	l147C7A
	addq.l	#4,a7
	move.l	#$12345678,d1
	RTE

l147C7A	link	a6,#-4
	movem.l	d7,-(a7)
	move.l	8(a6),d7
	JSR	l1492A8
	move.l	d7,d0
	movem.l	(a7)+,d7
	unlk	a6
	RTS

; /// Log of a Float ///
;
; D1-D2 : Float (Strictly Positive Only)
;
; D0-D1 : Retour

LogFloat	move.l	d1,-(a7)
	BSR	l147CA6
	addq.l	#4,a7
	move.l	#$12345678,d1
	RTE

l147CA6	link	a6,#-4
	movem.l	d7,-(a7)
	move.l	8(a6),d7
	BSR	l149382
	move.l	d7,d0
	movem.l	(a7)+,d7
	unlk	a6
	RTS

; /// Log10 of a Float ///
;
; D1-D2 : Float (Strictly Positive Only)
;
; D0-D1 : Retour

Log10Float	move.l	d1,-(a7)
	BSR	l147CA6
	move.l	#$935D8D42,(a7)
	move.l	d0,-(a7)
	BSR	l1488FC
	addq.l	#8,a7
	move.l	#$12345678,d1
	RTE

; /// HypSinus of a Float ///
;
; D1-D2 : Float
;
; D0-D1 : Retour

HSinFloat	move.l	d1,-(a7)
	BSR	l147CEC
	addq.l	#4,a7
	move.l	#$12345678,d1
	RTE

l147CEC	link	a6,#-4
	move.l	d7,-(a7)
	move.l	8(a6),d7
	JSR	l148D40

; /// ArcCosinus of a Float ///
;
; D1-D2 : Float
;
; D0-D1 : Retour

ACosFloat	move.l	d7,d0
	move.l	(a7)+,d7
	unlk	a6
	RTS

l147D	BSR	l147D10
	move.l	#$12345678,d1
	RTE

l147D10	move.l	d1,d7
	move.l	d1,-(a7)
	move.l	d1,-(a7)
	BSR	l14891C
	addq.l	#8,a7
	bchg	#7,d0
	move.l	d0,-(a7)
	move.l	#$80000041,-(a7)
	BSR	l1488BE
	addq.l	#8,a7
	btst	#7,d0
	BNE	l147D4A
	move.l	d0,-(a7)
	move.l	d7,-(a7)
	BSR	l1488FC
	addq.l	#8,a7
	move.l	d0,-(a7)
	BSR	l147CEC
	addq.l	#4,a7
	RTS

l147D4A	moveq	#0,d0
	RTS

; /// ArcTangente of a Float ///
;
; D1-D2 : Float
;
; D0-D1 : Retour

ATanFloat	BSR	l147D10
	move.l	d0,-(a7)
	move.l	#$C90FD941,-(a7)
	BSR	l14893C
	addq.l	#8,a7
	move.l	#$12345678,d1
	RTE

; /// HypCosinus of a Float ///
;
; D1-D2 : Float
;
; D0-D1 : Retour

HCosFloat	move.l	d1,-(a7)
	BSR	l147D78
	addq.l	#4,a7
	move.l	#$12345678,d1
	RTE

l147D78	link	a6,#-4
	move.l	d7,-(a7)
	move.l	8(a6),d7
	BSR	l148E06
	move.l	d7,d0
	move.l	(a7)+,d7
	unlk	a6
	RTS

; /// HypTangente of a Float ///
;
; D1-D2 : Float
;
; D0-D1 : Retour

HTanFloat	move.l	d1,-(a7)
	BSR	l147C7A
	move.l	d0,l1476D0
	move.l	(a7),d0
	bchg	#7,d0
	move.l	d0,(a7)
	BSR	l147C7A
	move.l	d0,(a7)
	move.l	l1476D0,-(a7)
	BSR	l1488BE
	addq.l	#8,a7
	move.l	#$80000042,-(a7)
	move.l	d0,-(a7)
	BSR	l1488FC
	addq.l	#8,a7
	move.l	#$12345678,d1
	RTE

; /// Take the Integer Part of the Float - Round ///
;
; D1-D2 : Float
;
; D0-D1 : Retour

Integering	move.l	d1,-(a7)
	BSR	l147DDA
	addq.l	#4,a7
	move.l	#$12345678,d1
	RTE

l147DDA	link	a6,#-4
	move.l	d7,-(a7)
	move.l	8(a6),d7
	BSR	l148E40
	move.l	d7,d0
	move.l	(a7)+,d7
	unlk	a6
	RTS

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

l147E8A	move.l	#$A0000044,-(a7)
	move.l	8(a6),-(a7)
	JSR	l14837E
	addq.l	#8,a7
	move.l	d0,8(a6)
	addq.w	#1,d7
l147EA2	move.l	#$A0000044,-(a7)
	move.l	8(a6),-(a7)
	JSR	l148360
	addq.l	#8,a7
	BGE.s	l147E8A
	add.w	d7,d4
	moveq	#1,d6
	move.w	d6,d0
	ext.l	d0
	move.l	d0,-(a7)
	JSR	l14839E
	addq.l	#4,a7
	move.l	d0,-8(a6)
	BRA.s	l147EE6

l147ECE	move.l	#$A0000044,-(a7)
	move.l	-8(a6),-(a7)
	JSR	l14837E
	addq.l	#8,a7
	move.l	d0,-8(a6)
	addq.w	#1,d6
l147EE6	cmp.w	d4,d6
	BLT.s	l147ECE
	move.l	#$80000042,-(a7)
	move.l	-8(a6),-(a7)
	JSR	l14837E
	addq.l	#8,a7
	move.l	d0,-(a7)
	move.l	8(a6),-(a7)
	JSR	l148340
	addq.l	#8,a7
	move.l	d0,8(a6)
	move.l	#$A0000044,-(a7)
	move.l	8(a6),-(a7)
	JSR	l148360
	addq.l	#8,a7
	BLT.s	l147F2C
	move.l	#$80000041,8(a6)
	addq.w	#1,d7
l147F2C	tst.w	d7
	BGE.s	l147F64
	movea.l	$C(a6),a0
	move.b	#$30,(a0)
	addq.l	#1,$C(a6)
	movea.l	$C(a6),a0
	move.b	#$2E,(a0)
	addq.l	#1,$C(a6)
	tst.w	d4
	BGE.s	l147F4E
	sub.w	d4,d7
l147F4E	moveq	#-1,d6
	BRA.s	l147F60

l147F52	movea.l	$C(a6),a0
	move.b	#$30,(a0)
	addq.l	#1,$C(a6)
	subq.w	#1,d6
l147F60	cmp.w	d7,d6
	BGT.s	l147F52
l147F64	clr.w	d6
	BRA.s	l147FD2

l147F68	move.l	8(a6),-(a7)
	JSR	l14842E
	addq.l	#4,a7
	move.w	d0,d5
	move.w	d5,d0
	addi.w	#$30,d0
	movea.l	$C(a6),a1
	move.b	d0,(a1)
	addq.l	#1,$C(a6)
	cmp.w	d7,d6
	BNE.s	l147F96
	movea.l	$C(a6),a0
	move.b	#$2E,(a0)
	addq.l	#1,$C(a6)
l147F96	move.w	d5,d0
	ext.l	d0
	move.l	d0,-(a7)
	JSR	l14839E
	addq.l	#4,a7
	move.l	d0,-8(a6)
	move.l	d0,-(a7)
	move.l	8(a6),-(a7)
	JSR	l1484F2
	addq.l	#8,a7
	move.l	d0,8(a6)
	move.l	#$A0000044,-(a7)
	move.l	8(a6),-(a7)
	JSR	l1484B6
	addq.l	#8,a7
	move.l	d0,8(a6)
	addq.w	#1,d6
l147FD2	cmp.w	d4,d6
	BLT.s	l147F68
	movea.l	$C(a6),a0
	clr.b	(a0)
	addq.l	#1,$C(a6)
	move.l	-4(a6),d0
	tst.l	(a7)+
	movem.l	(a7)+,d4-d7
	unlk	a6
	RTS

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
	movem.l	d4-d7,-(a7)
	move.l	8(a6),d0
	andi.l	#$7F,d0
	addi.l	#$FFFFFFC0,d0
	move.w	d0,d6
	tst.l	8(a6)
	BEQ.s	l148452
	tst.w	d6
	BGE.s	l148456
l148452	clr.l	d0
	BRA.s	l1484AC

l148456	move.l	8(a6),d0
	andi.l	#$80,d0
	move.w	d0,d5
	cmp.w	#$1F,d6
	BLE.s	l14847C
	tst.w	d5
	BEQ.s	l148474
	move.l	#$80000000,d0
	BRA.s	l14847A

l148474	move.l	#$7FFFFFFF,d0
l14847A	BRA.s	l1484AC

l14847C	move.l	8(a6),d7
	asr.l	#8,d7
	andi.l	#$FFFFFF,d7
	subi.w	#$18,d6
	BRA.s	l148492

l14848E	asr.l	#1,d7
	addq.w	#1,d6
l148492	tst.w	d6
	BLT.s	l14848E
	BRA.s	l14849C

l148498	asl.l	#1,d7
	subq.w	#1,d6
l14849C	tst.w	d6
	BGT.s	l148498
	tst.w	d5
	BEQ.s	l1484AA
	move.l	d7,d0
	neg.l	d0
	move.l	d0,d7
l1484AA	move.l	d7,d0
l1484AC	tst.l	(a7)+
	movem.l	(a7)+,d5-d7
	unlk	a6
	RTS

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
l14853C	RTS			; +

l14853E	move.b	d6,d4
	BEQ.s	l148594
	eori.b	#$80,d4
	BMI.s	l1485B2
	move.b	d7,d5
	BMI.s	l1485B8
	BNE.s	l14855C
	BRA.s	l14858E

l148550	move.b	d6,d4		;
	BMI.s	l1485B2		;
	BEQ.s	l148594		;
	move.b	d7,d5		;
	BMI.s	l1485B8		;
	BEQ.s	l14858E		;
l14855C	sub.b	d4,d5		;
	BMI.s	l148598		;
	move.b	d7,d4		;
	cmp.b	#$18,d5		;
	BCC.s	l148594		;
	move.l	d6,d3		;
	clr.b	d3		;
	lsr.l	d5,d3		;
	move.b	#$80,d7		;
	add.l	d3,d7		;
	BCS.s	l14857A		;
l148576	move.b	d4,d7		;
	RTS			;

l14857A	roxr.l	#1,d7		;
	addq.b	#1,d4		;
	bvs.s	l148582		;
	BCC.s	l148576		;
l148582	moveq	#-1,d7		;
	subq.b	#1,d4		;
	move.b	d4,d7		;
	ori.b	#2,ccr		;
	RTS			;

l14858E	move.l	d6,d7		;
	move.b	d4,d7		;
	RTS			;

l148594	tst.b	d7		;
	RTS			;

l148598	cmp.b	#$E8,d5		;
	BLE.s	l14858E		;
	neg.b	d5		;
	move.l	d6,d3		;
	clr.b	d7		;
	lsr.l	d5,d7		;
	move.b	#$80,d3		;
	add.l	d3,d7		;
	BCS.s	l14857A		;
	move.b	d4,d7		;
	RTS			;

l1485B2	move.b	d7,d5		;
	BMI.s	l14855C		;
	BEQ.s	l14858E		;
l1485B8	moveq	#-$80,d3		;
	eor.b	d3,d5		;
	sub.b	d4,d5		;
	BEQ.s	l148610		;
	BMI.s	l1485FE		;
	cmp.b	#$18,d5		;
	BCC.s	l148594		;
	move.b	d7,d4		;
	move.b	d3,d7		;
	move.l	d6,d3		;
l1485CE	clr.b	d3		;
	lsr.l	d5,d3		;
	sub.l	d3,d7		;
	BMI.s	l148576		;
l1485D6	move.b	d4,d5		;
l1485D8	clr.b	d7		;
	subq.b	#1,d4		;
	cmp.l	#$7FFF,d7		;
	bhi.s	l1485EA		;
	swap	d7		;
	subi.b	#$10,d4		;
l1485EA	add.l	d7,d7		;
	dBMI	d4,l1485EA		;
	eor.b	d4,d5		;
	BMI.s	l1485FA		;
	move.b	d4,d7		;
	BEQ.s	l1485FA		;
	RTS			;

l1485FA	moveq	#0,d7		;
	RTS			;

l1485FE	cmp.b	#$E8,d5		;
	BLE.s	l14858E		;
	neg.b	d5		;
	move.l	d7,d3		;
	move.l	d6,d7		;
	move.b	#$80,d7		;
	BRA.s	l1485CE		;

l148610	move.b	d7,d5		;
	exg	d5,d4		;
	move.b	d6,d7		;
	sub.l	d6,d7		;
	BEQ.s	l1485FA		;
	BPL.s	l1485D6		;
	neg.l	d7		;
	move.b	d5,d4		;
	BRA.s	l1485D8		;

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
	BLE.s	l148776		;>>
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

l1487A6	link	a6,#0
	movem.l	d5-d7,-(a7)
	tst.l	8(a6)
	BGE.s	l1487C2
	moveq	#1,d6
	move.l	8(a6),d0
	neg.l	d0
	move.l	d0,8(a6)
	BRA.s	l1487C4

l1487C2	clr.w	d6
l1487C4	tst.l	8(a6)
	BNE.s	l1487CE
	clr.l	d0
	BRA.s	l14882C

l1487CE	moveq	#$18,d7
	BRA.s	l1487DE

l1487D2	move.l	8(a6),d0
	asr.l	#1,d0
	move.l	d0,8(a6)
	addq.l	#1,d7
l1487DE	move.l	8(a6),d0
	andi.l	#$7F000000,d0
	BNE.s	l1487D2
	BRA.s	l1487F8

l1487EC	move.l	8(a6),d0
	asl.l	#1,d0
	move.l	d0,8(a6)
	subq.l	#1,d7
l1487F8	btst	#7,9(a6)
	BEQ.s	l1487EC
	move.l	8(a6),d0
	asl.l	#8,d0
	move.l	d0,8(a6)
	addi.l	#$40,d7
	move.l	d7,d0
	andi.l	#$7F,d0
	or.l	d0,8(a6)
	tst.w	d6
	BEQ.s	l148828
	ori.l	#$80,8(a6)
l148828	move.l	8(a6),d0
l14882C	tst.l	(a7)+
	movem.l	(a7)+,d6-d7
	unlk	a6
	RTS

l148836	link	a6,#0
	movem.l	d4-d7,-(a7)
	move.l	8(a6),d0
	andi.l	#$7F,d0
	addi.l	#$FFFFFFC0,d0
	move.w	d0,d6
	tst.l	8(a6)
	BEQ.s	l14885A
	tst.w	d6
	BGE.s	l14885E
l14885A	clr.l	d0
	BRA.s	l1488B4

l14885E	move.l	8(a6),d0
	andi.l	#$80,d0
	move.w	d0,d5
	cmp.w	#$1F,d6
	BLE.s	l148884
	tst.w	d5
	BEQ.s	l14887C
	move.l	#$80000000,d0
	BRA.s	l148882

l14887C	move.l	#$7FFFFFFF,d0
l148882	BRA.s	l1488B4

l148884	move.l	8(a6),d7
	asr.l	#8,d7
	andi.l	#$FFFFFF,d7
	subi.w	#$18,d6
	BRA.s	l14889A

l148896	asr.l	#1,d7
	addq.w	#1,d6
l14889A	tst.w	d6
	BLT.s	l148896
	BRA.s	l1488A4

l1488A0	asl.l	#1,d7
	subq.w	#1,d6
l1488A4	tst.w	d6
	BGT.s	l1488A0
	tst.w	d5
	BEQ.s	l1488B2
	move.l	d7,d0
	neg.l	d0
	move.l	d0,d7
l1488B2	move.l	d7,d0
l1488B4	tst.l	(a7)+
	movem.l	(a7)+,d5-d7
	unlk	a6
	RTS

l1488BE	link	a6,#-4
	movem.l	d3-d7,-(a7)
	move.l	8(a6),d7
	move.l	$C(a6),d6
	JSR	l14898A
	move.l	d7,d0
	movem.l	(a7)+,d3-d7
	unlk	a6
	RTS

l1488DE	link	a6,#-4
	movem.l	d3-d7,-(a7)
	move.l	8(a6),d7
	move.l	$C(a6),d6
	JSR	l14895C
	movem.l	(a7)+,d3-d7
	unlk	a6
	RTS

l1488FC	link	a6,#-4
	movem.l	d3-d7,-(a7)
	move.l	8(a6),d7
	move.l	$C(a6),d6
	JSR	l148A80
	move.l	d7,d0
	movem.l	(a7)+,d3-d7
	unlk	a6
	RTS

l14891C	link	a6,#-4
	movem.l	d3-d7,-(a7)
	move.l	8(a6),d7
	move.l	$C(a6),d6
	JSR	l148AF2
	move.l	d7,d0
	movem.l	(a7)+,d3-d7
	unlk	a6
	RTS

l14893C	link	a6,#-4
	movem.l	d3-d7,-(a7)
	move.l	8(a6),d7
	move.l	$C(a6),d6
	JSR	l148978
	move.l	d7,d0
	movem.l	(a7)+,d3-d7
	unlk	a6
	RTS

l14895C	tst.b	d6
	BPL.s	l14896C
	tst.b	d7
	BPL.s	l14896C
	cmp.b	d7,d6
	BNE.s	l148972
	cmp.l	d7,d6
	RTS

l14896C	cmp.b	d6,d7
	BNE.s	l148972
	cmp.l	d6,d7
l148972	RTS

	tst.b	d7
	RTS

l148978	move.b	d6,d4
	BEQ.s	l1489CE
	eori.b	#$80,d4
	BMI.s	l1489EC
	move.b	d7,d5
	BMI.s	l1489F2
	BNE.s	l148996
	BRA.s	l1489C8

l14898A	move.b	d6,d4
	BMI.s	l1489EC
	BEQ.s	l1489CE
	move.b	d7,d5
	BMI.s	l1489F2
	BEQ.s	l1489C8
l148996	sub.b	d4,d5
	BMI.s	l1489D2
	move.b	d7,d4
	cmp.b	#$18,d5
	BCC.s	l1489CE
	move.l	d6,d3
	clr.b	d3
	lsr.l	d5,d3
	move.b	#$80,d7
	add.l	d3,d7
	BCS.s	l1489B4
l1489B0	move.b	d4,d7
	RTS

l1489B4	roxr.l	#1,d7
	addq.b	#1,d4
	bvs.s	l1489BC
	BCC.s	l1489B0
l1489BC	moveq	#-1,d7
	subq.b	#1,d4
	move.b	d4,d7
	ori.b	#2,ccr
	RTS

l1489C8	move.l	d6,d7
	move.b	d4,d7
	RTS

l1489CE	tst.b	d7
	RTS

l1489D2	cmp.b	#$E8,d5
	BLE.s	l1489C8
	neg.b	d5
	move.l	d6,d3
	clr.b	d7
	lsr.l	d5,d7
	move.b	#$80,d3
	add.l	d3,d7
	BCS.s	l1489B4
	move.b	d4,d7
	RTS

l1489EC	move.b	d7,d5
	BMI.s	l148996
	BEQ.s	l1489C8
l1489F2	moveq	#-$80,d3
	eor.b	d3,d5
	sub.b	d4,d5
	BEQ.s	l148A4A
	BMI.s	l148A38
	cmp.b	#$18,d5
	BCC.s	l1489CE
	move.b	d7,d4
	move.b	d3,d7
	move.l	d6,d3
l148A08	clr.b	d3
	lsr.l	d5,d3
	sub.l	d3,d7
	BMI.s	l1489B0
l148A10	move.b	d4,d5
l148A12	clr.b	d7
	subq.b	#1,d4
	cmp.l	#$7FFF,d7
	bhi.s	l148A24
	swap	d7
	subi.b	#$10,d4
l148A24	add.l	d7,d7
	dBMI	d4,l148A24
	eor.b	d4,d5
	BMI.s	l148A34
	move.b	d4,d7
	BEQ.s	l148A34
	RTS

l148A34	moveq	#0,d7
	RTS

l148A38	cmp.b	#$E8,d5
	BLE.s	l1489C8
	neg.b	d5
	move.l	d7,d3
	move.l	d6,d7
	move.b	#$80,d7
	BRA.s	l148A08

l148A4A	move.b	d7,d5
	exg	d5,d4
	move.b	d6,d7
	sub.l	d6,d7
	BEQ.s	l148A34
	BPL.s	l148A10
	neg.l	d7
	move.b	d5,d4
	BRA.s	l148A12

l148A5C	divu.w	#0,d7
	tst.l	d6
	BNE.s	l148A80
l148A64	ori.l	#$FFFFFF7F,d7
	tst.b	d7
	ori.b	#2,ccr
l148A70	RTS

l148A72	swap	d6
	swap	d7
l148A76	eor.b	d6,d7
	BRA.s	l148A64

l148A7A	BMI.s	l148A76
l148A7C	moveq	#0,d7
	RTS

l148A80	move.b	d6,d5
	BEQ.s	l148A5C
	move.l	d7,d4
	BEQ.s	l148A70
	moveq	#-$80,d3
	add.w	d5,d5
	add.w	d4,d4
	eor.b	d3,d5
	eor.b	d3,d4
	sub.b	d5,d4
	bvs.s	l148A7A
	clr.b	d7
	swap	d7
	swap	d6
	cmp.w	d6,d7
	BMI.s	l148AA6
	addq.b	#2,d4
	bvs.s	l148A72
	ror.l	#1,d7
l148AA6	swap	d7
	move.b	d3,d5
	eor.w	d5,d4
	lsr.w	#1,d4
	move.l	d7,d3
	divu.w	d6,d3
	move.w	d3,d5
	mulu.w	d6,d3
	sub.l	d3,d7
	swap	d7
	swap	d6
	move.w	d6,d3
	clr.b	d3
	mulu.w	d5,d3
	sub.l	d3,d7
	BCC.s	l148ACE
	move.l	d6,d3
	clr.b	d3
	add.l	d3,d7
	subq.w	#1,d5
l148ACE	move.l	d6,d3
	swap	d3
	clr.w	d7
	divu.w	d3,d7
	swap	d5
	BMI.s	l148AE2
	move.w	d7,d5
	add.l	d5,d5
	subq.b	#1,d4
	move.w	d5,d7
l148AE2	move.w	d7,d5
	addi.l	#$80,d5
	move.l	d5,d7
	move.b	d4,d7
	BEQ.s	l148A7C
	RTS

l148AF2	move.b	d7,d5
	BEQ.s	l148B48
	move.b	d6,d4
	BEQ.s	l148B62
	add.w	d5,d5
	add.w	d4,d4
	moveq	#-$80,d3
	eor.b	d3,d4
	eor.b	d3,d5
	add.b	d4,d5
	bvs.s	l148B66
	move.b	d3,d4
	eor.w	d4,d5
	ror.w	#1,d5
	swap	d5
	move.w	d6,d5
	clr.b	d7
	clr.b	d5
	move.w	d5,d4
	mulu.w	d7,d4
	swap	d4
	move.l	d7,d3
	swap	d3
	mulu.w	d5,d3
	add.l	d3,d4
	swap	d6
	move.l	d6,d3
	mulu.w	d7,d3
	add.l	d3,d4
	clr.w	d4
	addx.b	d4,d4
	swap	d4
	swap	d7
	mulu.w	d6,d7
	swap	d6
	swap	d5
	add.l	d4,d7
	BPL.s	l148B4A
	addi.l	#$80,d7
	move.b	d5,d7
	BEQ.s	l148B62
l148B48	RTS

l148B4A	subq.b	#1,d5
	bvs.s	l148B62
	BCS.s	l148B62
	moveq	#$40,d4
	add.l	d4,d7
	add.l	d7,d7
	BCC.s	l148B5C
	roxr.l	#1,d7
	addq.b	#1,d5
l148B5C	move.b	d5,d7
	BEQ.s	l148B62
	RTS

l148B62	moveq	#0,d7
	RTS

l148B66	BPL.s	l148B62
	eor.b	d6,d7
	ori.l	#$FFFFFF7F,d7
	tst.b	d7
	ori.b	#2,ccr
	RTS

l148B78	ori.b	#0,d0
l148B7C	move.l	-$10(a6),-(a7)
	move.l	-4(a6),-(a7)
	JSR	l148D20
	addq.l	#8,a7
	move.l	d0,-4(a6)
	clr.l	-(a7)
	move.l	-$10(a6),-(a7)
	move.l	-4(a6),-(a7)
	JSR	l148D20
	addq.l	#8,a7
	move.l	d0,-(a7)
	JSR	l148BEA
	addq.l	#8,a7
	BGE.s	l148B7C
	move.l	-4(a6),-(a7)
	JSR	l148C98
	addq.l	#4,a7
	move.l	d0,d7
	clr.l	-(a7)
	move.l	8(a6),-(a7)
	JSR	l148BEA
	addq.l	#8,a7
	BGE.s	l148BCE
	neg.l	d7
l148BCE	move.l	d7,-(a7)
	JSR	l148C08
	addq.l	#4,a7
	move.l	d0,-8(a6)
	move.l	-8(a6),d0
	tst.l	(a7)+
	movem.l	(a7)+,d7
	unlk	a6
	RTS

l148BEA	link	a6,#-4
	movem.l	d3-d7,-(a7)
	move.l	8(a6),d7
	move.l	$C(a6),d6
	JSR	l148E8C
	movem.l	(a7)+,d3-d7
	unlk	a6
	RTS

l148C08	link	a6,#0
	movem.l	d5-d7,-(a7)
	tst.l	8(a6)
	BGE.s	l148C24
	moveq	#1,d6
	move.l	8(a6),d0
	neg.l	d0
	move.l	d0,8(a6)
	BRA.s	l148C26

l148C24	clr.w	d6
l148C26	tst.l	8(a6)
	BNE.s	l148C30
	clr.l	d0
	BRA.s	l148C8E

l148C30	moveq	#$18,d7
	BRA.s	l148C40

l148C34	move.l	8(a6),d0
	asr.l	#1,d0
	move.l	d0,8(a6)
	addq.l	#1,d7
l148C40	move.l	8(a6),d0
	andi.l	#$7F000000,d0
	BNE.s	l148C34
	BRA.s	l148C5A

l148C4E	move.l	8(a6),d0
	asl.l	#1,d0
	move.l	d0,8(a6)
	subq.l	#1,d7
l148C5A	btst	#7,9(a6)
	BEQ.s	l148C4E
	move.l	8(a6),d0
	asl.l	#8,d0
	move.l	d0,8(a6)
	addi.l	#$40,d7
	move.l	d7,d0
	andi.l	#$7F,d0
	or.l	d0,8(a6)
	tst.w	d6
	BEQ.s	l148C8A
	ori.l	#$80,8(a6)
l148C8A	move.l	8(a6),d0
l148C8E	tst.l	(a7)+
	movem.l	(a7)+,d6-d7
	unlk	a6
	RTS

l148C98	link	a6,#0
	movem.l	d4-d7,-(a7)
	move.l	8(a6),d0
	andi.l	#$7F,d0
	addi.l	#$FFFFFFC0,d0
	move.w	d0,d6
	tst.l	8(a6)
	BEQ.s	l148CBC
	tst.w	d6
	BGE.s	l148CC0
l148CBC	clr.l	d0
	BRA.s	l148D16

l148CC0	move.l	8(a6),d0
	andi.l	#$80,d0
	move.w	d0,d5
	cmp.w	#$1F,d6
	BLE.s	l148CE6
	tst.w	d5
	BEQ.s	l148CDE
	move.l	#$80000000,d0
	BRA.s	l148CE4

l148CDE	move.l	#$7FFFFFFF,d0
l148CE4	BRA.s	l148D16

l148CE6	move.l	8(a6),d7
	asr.l	#8,d7
	andi.l	#$FFFFFF,d7
	subi.w	#$18,d6
	BRA.s	l148CFC

l148CF8	asr.l	#1,d7
	addq.w	#1,d6
l148CFC	tst.w	d6
	BLT.s	l148CF8
	BRA.s	l148D06

l148D02	asl.l	#1,d7
	subq.w	#1,d6
l148D06	tst.w	d6
	BGT.s	l148D02
	tst.w	d5
	BEQ.s	l148D14
	move.l	d7,d0
	neg.l	d0
	move.l	d0,d7
l148D14	move.l	d7,d0
l148D16	tst.l	(a7)+
	movem.l	(a7)+,d5-d7
	unlk	a6
	RTS

l148D20	link	a6,#-4
	movem.l	d3-d7,-(a7)
	move.l	8(a6),d7
	move.l	$C(a6),d6
	JSR	l149108
	move.l	d7,d0
	movem.l	(a7)+,d3-d7
	unlk	a6
	RTS

l148D40	movem.l	d1-d6/a0,-(a7)
	move.b	d7,-(a7)
	andi.b	#$7F,d7
	move.l	#$80000041,d6
	clr.b	-(a7)
	cmp.b	d6,d7
	BCS.s	l148D66
	bhi.s	l148D5C
	cmp.l	d6,d7
	bls.s	l148D66
l148D5C	not.b	(a7)
	exg	d6,d7
	JSR	l149210
l148D66	subi.b	#$43,d7
	neg.b	d7
	cmp.b	#$1F,d7
	bls.s	l148D76
	moveq	#0,d6
	BRA.s	l148DAE

l148D76	lsr.l	d7,d7
	moveq	#0,d6
	move.l	#$20000000,d5
	lea	l1494DC,a0
	moveq	#$18,d1
	moveq	#1,d2
	BRA.s	l148D92

l148D8C	asr.l	d2,d4
	add.l	d4,d5
	add.l	(a0),d6
l148D92	move.l	d7,d4
	move.l	d5,d3
	asr.l	d2,d3
l148D98	sub.l	d3,d7
	BPL.s	l148D8C
	move.l	d4,d7
	addq.l	#4,a0
	addq.b	#1,d2
	lsr.l	#1,d3
	DBF	d1,l148D98
	JSR	l149544
l148DAE	move.l	d6,d7
	tst.b	(a7)+
	BEQ.s	l148DC0
	move.l	#$C90FDB41,d7
	JSR	l149108
l148DC0	move.b	(a7)+,d6
	tst.b	d7
	BEQ.s	l148DCC
	andi.b	#$80,d6
	or.b	d6,d7
l148DCC	movem.l	(a7)+,d1-d6/a0
	RTS

	move.l	d6,-(a7)
	andi.b	#$7F,d7
	JSR	l1492A8
	bvs.s	l148E00
	move.l	d7,-(a7)
	move.l	d7,d6
	move.l	#$80000041,d7
	JSR	l149210
	move.l	(a7)+,d6
	JSR	l14911A
	BEQ.s	l148E00
	subq.b	#1,d7
	bvc.s	l148E00
	moveq	#0,d7
l148E00	movem.l	(a7)+,d6
	RTS

l148E06	move.l	d6,-(a7)
	JSR	l1492A8
	bvs.s	l148E3A
	move.l	d7,-(a7)
	move.l	d7,d6
	move.l	#$80000041,d7
	JSR	l149210
	move.l	(a7),d6
	JSR	l14911A
	BEQ.s	l148E30
	subq.b	#1,d7
	bvc.s	l148E30
	moveq	#0,d7
l148E30	move.l	d7,d6
	move.l	(a7)+,d7
	JSR	l149108
l148E3A	movem.l	(a7)+,d6
	RTS

l148E40	move.l	d6,-(a7)
	tst.b	d7
	BEQ.s	l148E76
	addq.b	#1,d7
	bvs.s	l148E7A
	JSR	l1492A8
	bvs.s	l148E84
	move.l	d7,-(a7)
	move.l	#$80000041,d6
	JSR	l14911A
	move.l	d7,-(a7)
	move.l	4(a7),d7
	JSR	l149108
	move.l	(a7)+,d6
	JSR	l149210
	addq.l	#4,a7
l148E76	move.l	(a7)+,d6
	RTS

l148E7A	move.l	#$80000082,d7
	roxr.b	#1,d7
	BRA.s	l148E76

l148E84	move.l	#$80000041,d7
	BRA.s	l148E76

l148E8C	tst.b	d6
	BPL.s	l148E9C
	tst.b	d7
	BPL.s	l148E9C
	cmp.b	d7,d6
	BNE.s	l148EA2
	cmp.l	d7,d6
	RTS

l148E9C	cmp.b	d6,d7
	BNE.s	l148EA2
	cmp.l	d6,d7
l148EA2	RTS

	tst.b	d7
	RTS

l148EA8	tst.b	d7
	BPL.s	l148EB8
	andi.b	#$7F,d7
	BSR.s	l148EB8
	ori.b	#2,ccr
	RTS

l148EB8	JSR	l149382
	movem.l	d3-d5,-(a7)
	JSR	l149452
	movem.l	(a7)+,d3-d5
	JMP	l1492A8

	move.w	#$FFFE,-(a7)
	BRA.s	l148EFC

	move.w	#$FFFF,-(a7)
	BRA.s	l148EF2

l148EDE	move.w	#1,-(a7)
	BRA.s	l148EFC

l148EE4	cmp.b	#$B8,d7
	bhi.s	l148EFC
l148EEA	addq.l	#2,a7
	tst.b	d7
	RTS

l148EF0	clr.w	-(a7)
l148EF2	tst.b	d7
	BMI.s	l148EE4
	cmp.b	#$38,d7
	bls.s	l148EEA
l148EFC	movem.l	d1-d6/a0,-(a7)
	move.l	d7,d2
	add.b	d7,d7
	cmp.b	#$8A,d7
	bls.s	l148F5A
	cmp.b	#$A8,d7
	bls.s	l148F1C
	ori.b	#2,ccr
	movem.l	(a7)+,d1-d6/a0
	addq.l	#2,a7
	RTS

l148F1C	move.l	#$A2F9833E,d6
	move.l	d2,d7
	JSR	l149452
	move.b	d7,d5
	andi.b	#$7F,d5
	subi.b	#$58,d5
	neg.b	d5
	moveq	#-1,d4
	clr.b	d4
	lsl.l	d5,d4
	ori.b	#$FF,d4
	and.l	d4,d7
	move.l	#$C90FDB43,d6
	JSR	l149452
	move.l	d7,d6
	move.l	d2,d7
	JSR	l149108
	move.l	d7,d2
l148F5A	move.l	#$C90FDAA,d4
	move.l	d2,d7
	clr.b	d7
	tst.b	d2
	BMI.s	l148F82
	subi.b	#$46,d2
	neg.b	d2
	cmp.b	#$1F,d2
	bls.s	l148F76
	moveq	#0,d7
l148F76	lsr.l	d2,d7
l148F78	cmp.l	d4,d7
	BLE.s	l148FA0
	sub.l	d4,d7
	sub.l	d4,d7
	BRA.s	l148F78

l148F82	subi.b	#$C6,d2
	neg.b	d2
	cmp.b	#$1F,d2
	bls.s	l148F90
	moveq	#0,d7
l148F90	lsr.l	d2,d7
	neg.l	d7
	neg.l	d4
l148F96	cmp.l	d4,d7
	BGE.s	l148FA0
	sub.l	d4,d7
	sub.l	d4,d7
	BRA.s	l148F96

l148FA0	moveq	#0,d5
	move.l	#$EC916240,d6
	move.l	#$3243F6A8,d4
	asl.l	#3,d7
	BMI.s	l148FB6
	neg.l	d6
	neg.l	d4
l148FB6	add.l	d4,d7
	lea	l1494D8,a0
	moveq	#$17,d1
	moveq	#-1,d2
l148FC2	addq.w	#1,d2
	move.l	d5,d3
	move.l	d6,d4
	asr.l	d2,d3
	asr.l	d2,d4
	tst.l	d7
	BMI.s	l148FDC
	sub.l	d4,d5
	add.l	d3,d6
	sub.l	(a0)+,d7
	DBF	d1,l148FC2
	BRA.s	l148FE6

l148FDC	add.l	d4,d5
	sub.l	d3,d6
	add.l	(a0)+,d7
	DBF	d1,l148FC2
l148FE6	move.w	$1C(a7),d1
	BPL.s	l14900E
	addq.b	#1,d1
	BNE.s	l149020
	BSR.s	l14902C
	move.l	d6,d7
	move.l	d5,d6
	BSR.s	l14902C
	BEQ.s	l149008
	JSR	l149210
l149000	movem.l	(a7)+,d1-d6/a0
	addq.l	#2,a7
	RTS

l149008	dc.w	$FFFF
	dc.w	$FF7F
	BRA.s	l149000

l14900E	BEQ.s	l149012
	move.l	d5,d6
l149012	BSR.s	l14902C
	move.l	d6,d7
	tst.b	d7
	movem.l	(a7)+,d1-d6/a0
	addq.l	#2,a7
	RTS

l149020	move.l	d5,-(a7)
	BSR.s	l14902C
	move.l	d6,$18(a7)
	move.l	(a7)+,d6
	BRA.s	l149012

l14902C	move.l	d6,d4
	BMI.s	l14903C
	cmp.l	#$FF,d6
	bhi.s	l149044
l149038	moveq	#0,d6
	RTS

l14903C	asr.l	#8,d4
	addq.l	#1,d4
	BNE.s	l149044
	BRA.s	l149038

l149044	JMP	l149544

l14904A	andi.b	#$7F,d7
	BSR.s	l149056
	ori.b	#2,ccr
	RTS

l149056	move.b	d7,d3
	BEQ.s	l1490AA
	BMI.s	l14904A
	lsr.b	#1,d3
	BCC.s	l149064
	addq.b	#1,d3
	lsr.l	#1,d7
l149064	addi.b	#$20,d3
	swap	d3
	move.w	#$17,d3
	lsr.l	#7,d7
	move.l	d7,d4
	move.l	d7,d5
	move.l	a0,d6
	lea	l1490AC(pc),a0
	move.l	#$800000,d7
	sub.l	d7,d4
	subi.l	#$1200000,d5
	BRA.s	l149096

l14908A	bset	d3,d7
	move.l	d5,d4
l14908E	add.l	d4,d4
	move.l	d4,d5
	sub.l	(a0)+,d5
	sub.l	d7,d5
l149096	dBMI	d3,l14908A
	dBPL	d3,l14908E
	bls.s	l1490A2
	addq.l	#1,d7
l1490A2	lsl.l	#8,d7
	movea.l	d6,a0
	swap	d3
	move.b	d3,d7
l1490AA	RTS

l1490AC	dc.b	0,$10,0,0,0,8,0,0
	dc.b	0,4,0,0,0,2,0,0
	dc.b	0,1,0,0,0,0,$80,0
	dc.b	0,0,$40,0,0,0,$20,0
	dc.b	0,0,$10,0,0,0,8,0
	dc.b	0,0,4,0,0,0,2,0
	dc.b	0,0,1,0,0,0,0,$80
	dc.b	0,0,0,$40,0,0,0,$20
	dc.b	0,0,0,$10,0,0,0,8
	dc.b	0,0,0,4,0,0,0,2
	dc.b	0,0,0,1,0,0,0,0
	dc.b	0,0,0,0

l149108	move.b	d6,d4
	BEQ.s	l14915E
	eori.b	#$80,d4
	BMI.s	l14917C
	move.b	d7,d5
	BMI.s	l149182
	BNE.s	l149126
	BRA.s	l149158

l14911A	move.b	d6,d4
	BMI.s	l14917C
	BEQ.s	l14915E
	move.b	d7,d5
	BMI.s	l149182
	BEQ.s	l149158
l149126	sub.b	d4,d5
	BMI.s	l149162
	move.b	d7,d4
	cmp.b	#$18,d5
	BCC.s	l14915E
	move.l	d6,d3
	clr.b	d3
	lsr.l	d5,d3
	move.b	#$80,d7
	add.l	d3,d7
	BCS.s	l149144
l149140	move.b	d4,d7
	RTS

l149144	roxr.l	#1,d7
	addq.b	#1,d4
	bvs.s	l14914C
	BCC.s	l149140
l14914C	moveq	#-1,d7
	subq.b	#1,d4
	move.b	d4,d7
	ori.b	#2,ccr
	RTS

l149158	move.l	d6,d7
	move.b	d4,d7
	RTS

l14915E	tst.b	d7
	RTS

l149162	cmp.b	#$E8,d5
	BLE.s	l149158
	neg.b	d5
	move.l	d6,d3
	clr.b	d7
	lsr.l	d5,d7
	move.b	#$80,d3
	add.l	d3,d7
	BCS.s	l149144
	move.b	d4,d7
	RTS

l14917C	move.b	d7,d5
	BMI.s	l149126
	BEQ.s	l149158
l149182	moveq	#-$80,d3
	eor.b	d3,d5
	sub.b	d4,d5
	BEQ.s	l1491DA
	BMI.s	l1491C8
	cmp.b	#$18,d5
	BCC.s	l14915E
	move.b	d7,d4
	move.b	d3,d7
	move.l	d6,d3
l149198	clr.b	d3
	lsr.l	d5,d3
	sub.l	d3,d7
	BMI.s	l149140
l1491A0	move.b	d4,d5
l1491A2	clr.b	d7
	subq.b	#1,d4
	cmp.l	#$7FFF,d7
	bhi.s	l1491B4
	swap	d7
	subi.b	#$10,d4
l1491B4	add.l	d7,d7
	dBMI	d4,l1491B4
	eor.b	d4,d5
	BMI.s	l1491C4
	move.b	d4,d7
	BEQ.s	l1491C4
	RTS

l1491C4	moveq	#0,d7
	RTS

l1491C8	cmp.b	#$E8,d5
	BLE.s	l149158
	neg.b	d5
	move.l	d7,d3
	move.l	d6,d7
	move.b	#$80,d7
	BRA.s	l149198

l1491DA	move.b	d7,d5
	exg	d5,d4
	move.b	d6,d7
	sub.l	d6,d7
	BEQ.s	l1491C4
	BPL.s	l1491A0
	neg.l	d7
	move.b	d5,d4
	BRA.s	l1491A2

l1491EC	divu.w	#0,d7
	tst.l	d6
	BNE.s	l149210
l1491F4	ori.l	#$FFFFFF7F,d7
	tst.b	d7
	ori.b	#2,ccr
l149200	RTS

l149202	swap	d6
	swap	d7
l149206	eor.b	d6,d7
	BRA.s	l1491F4

l14920A	BMI.s	l149206
l14920C	moveq	#0,d7
	RTS

l149210	move.b	d6,d5
	BEQ.s	l1491EC
	move.l	d7,d4
	BEQ.s	l149200
	moveq	#-$80,d3
	add.w	d5,d5
	add.w	d4,d4
	eor.b	d3,d5
	eor.b	d3,d4
	sub.b	d5,d4
	bvs.s	l14920A
	clr.b	d7
	swap	d7
	swap	d6
	cmp.w	d6,d7
	BMI.s	l149236
	addq.b	#2,d4
	bvs.s	l149202
	ror.l	#1,d7
l149236	swap	d7
	move.b	d3,d5
	eor.w	d5,d4
	lsr.w	#1,d4
	move.l	d7,d3
	divu.w	d6,d3
	move.w	d3,d5
	mulu.w	d6,d3
	sub.l	d3,d7
	swap	d7
	swap	d6
	move.w	d6,d3
	clr.b	d3
	mulu.w	d5,d3
	sub.l	d3,d7
	BCC.s	l14925E
	move.l	d6,d3
	clr.b	d3
	add.l	d3,d7
	subq.w	#1,d5
l14925E	move.l	d6,d3
	swap	d3
	clr.w	d7
	divu.w	d3,d7
	swap	d5
	BMI.s	l149272
	move.w	d7,d5
	add.l	d5,d5
	subq.b	#1,d4
	move.w	d5,d7
l149272	move.w	d7,d5
	addi.l	#$80,d5
	move.l	d5,d7
	move.b	d4,d7
	BEQ.s	l14920C
	RTS

l149282	move.w	(a7)+,d6
	tst.b	d6
	BPL.s	l14928C
	moveq	#0,d7
	BRA.s	l149294

l14928C	moveq	#-1,d7
	lsr.b	#1,d7
	ori.b	#2,ccr
l149294	movem.l	(a7)+,d1-d6/a0
	RTS

l14929A	move.l	#$80000041,d7
	lea	$1E(a7),a7
	tst.b	d7
	RTS

l1492A8	movem.l	d1-d6/a0,-(a7)
	move.w	d7,-(a7)
	BEQ.s	l14929A
	andi.b	#$7F,d7
	move.l	d7,d2
	move.l	#$B8AA3B41,d6
	JSR	l149452
	bvs.s	l149282
	move.b	d7,d5
	move.b	d7,d6
	subi.b	#$60,d5
	neg.b	d5
	cmp.b	#$18,d5
	BLE.s	l149282
	cmp.b	#$20,d5
	BGE.s	l1492FC
	lsr.l	d5,d7
	move.b	d7,(a7)
	lsl.l	d5,d7
	move.b	d6,d7
	move.l	#$B1721840,d6
	JSR	l149452
	move.l	d7,d6
	move.l	d2,d7
	JSR	l149108
	move.l	d7,d2
	BRA.s	l149300

l1492FC	clr.b	(a7)
	move.l	d2,d7
l149300	clr.b	d7
	subi.b	#$43,d2
	neg.b	d2
	cmp.b	#$1F,d2
	bls.s	l149310
	moveq	#0,d7
l149310	lsr.l	d2,d7
	moveq	#0,d5
	move.l	#$26A3D100,d6
	lea	l14957A,a0
	moveq	#0,d2
	moveq	#3,d1
	BSR.s	l14935C
	subq.l	#4,a0
	subq.w	#1,d2
	moveq	#9,d1
	BSR.s	l14935C
	subq.l	#4,a0
	subq.w	#1,d2
	moveq	#$A,d1
	BSR.s	l14935C
	tst.b	1(a7)
	BPL.s	l149340
	neg.l	d5
	neg.b	(a7)
l149340	add.l	d5,d6
	JSR	l149544
	move.l	d6,d7
	add.b	(a7),d7
	BMI	l149282
	BEQ	l149282
	addq.l	#2,a7
	movem.l	(a7)+,d1-d6/a0
	RTS

l14935C	addq.w	#1,d2
	move.l	d5,d3
	move.l	d6,d4
	asr.l	d2,d3
	asr.l	d2,d4
	tst.l	d7
	BMI.s	l149376
	add.l	d4,d5
	add.l	d3,d6
	sub.l	(a0)+,d7
	DBF	d1,l14935C
	RTS

l149376	sub.l	d4,d5
	sub.l	d3,d6
	add.l	(a0)+,d7
	DBF	d1,l14935C
	RTS

l149382	tst.b	d7
	BEQ.s	l149394
	BPL.s	l14939C
	andi.b	#$7F,d7
	BSR.s	l14939C

l14938E	ori.b	#2,ccr
	RTS

l149394	moveq	#-1,d7
	JMP	l14938E

l14939C	movem.l	d1-d6/a0,-(a7)
	move.b	d7,-(a7)
	move.b	#$41,d7
	move.l	#$80000041,d6
	move.l	d7,d2
	JSR	l14911A
	exg	d7,d2
	JSR	l149108
	move.l	d2,d6
	JSR	l149210
	BEQ.s	l149414
	subi.b	#$43,d7
	neg.b	d7
	cmp.b	#$1F,d7
	bls.s	l1493D4
	moveq	#0,d7
l1493D4	lsr.l	d7,d7
	moveq	#0,d6
	move.l	#$20000000,d5
	lea	l14957A,a0
	moveq	#$16,d1
	moveq	#1,d2
	BRA.s	l1493F0

l1493EA	asr.l	d2,d4
	sub.l	d4,d5
	add.l	(a0),d6
l1493F0	move.l	d7,d4
	move.l	d5,d3
	asr.l	d2,d3
l1493F6	sub.l	d3,d7
	BPL.s	l1493EA
	move.l	d4,d7
	addq.l	#4,a0
	addq.b	#1,d2
	lsr.l	#1,d3
	DBF	d1,l1493F6
	moveq	#0,d7
	JSR	l149544
	BEQ.s	l149414
	addq.b	#1,d6
	move.l	d6,d7
l149414	move.l	d7,d2
	moveq	#0,d6
	move.b	(a7)+,d6
	subi.b	#$41,d6
	BEQ.s	l14944C
	move.b	d6,d1
	BPL.s	l149426
	neg.b	d6
l149426	ror.l	#8,d6
	moveq	#$47,d5
l14942A	add.l	d6,d6
	dBMI	d5,l14942A
	move.b	d5,d6
	andi.b	#$80,d1
	or.b	d1,d6
	move.l	#$B1721840,d7
	JSR	l149452
	move.l	d2,d6
	JSR	l14911A
l14944C	movem.l	(a7)+,d1-d6/a0
	RTS

l149452	move.b	d7,d5
	BEQ.s	l1494A8
	move.b	d6,d4
	BEQ.s	l1494C2
	add.w	d5,d5
	add.w	d4,d4
	moveq	#-$80,d3
	eor.b	d3,d4
	eor.b	d3,d5
	add.b	d4,d5
	bvs.s	l1494C6
	move.b	d3,d4
	eor.w	d4,d5
	ror.w	#1,d5
	swap	d5
	move.w	d6,d5
	clr.b	d7
	clr.b	d5
	move.w	d5,d4
	mulu.w	d7,d4
	swap	d4
	move.l	d7,d3
	swap	d3
	mulu.w	d5,d3
	add.l	d3,d4
	swap	d6
	move.l	d6,d3
	mulu.w	d7,d3
	add.l	d3,d4
	clr.w	d4
	addx.b	d4,d4
	swap	d4
	swap	d7
	mulu.w	d6,d7
	swap	d6
	swap	d5
	add.l	d4,d7
	BPL.s	l1494AA
	addi.l	#$80,d7
	move.b	d5,d7
	BEQ.s	l1494C2
l1494A8	RTS

l1494AA	subq.b	#1,d5
	bvs.s	l1494C2
	BCS.s	l1494C2
	moveq	#$40,d4
	add.l	d4,d7
	add.l	d7,d7
	BCC.s	l1494BC
	roxr.l	#1,d7
	addq.b	#1,d5
l1494BC	move.b	d5,d7
	BEQ.s	l1494C2
	RTS

l1494C2	moveq	#0,d7
	RTS

l1494C6	BPL.s	l1494C2
	eor.b	d6,d7
	or.l	#$FFFFFF7F,d7
	tst.b	d7
	ori.b	#2,ccr
	RTS

l1494D8	dc.b	$19,$21,$FB,$54
l1494DC	dc.b	$E,$D6,$33,$82,7,$D6,$DD,$7E
	dc.b	3,$FA,$B7,$53,1,$FF,$55,$BB
	dc.b	0,$FF,$EA,$AD,0,$7F,$FD,$55
	dc.b	0,$3F,$FF,$AA,0,$1F,$FF,$F5
	dc.b	0,$F,$FF,$FE,0,7,$FF,$FF
	dc.b	0,3,$FF,$FF,0,1,$FF,$FF
	dc.b	0,0,$FF,$FF,0,0,$7F,$FF
	dc.b	0,0,$3F,$FF,0,0,$1F,$FF
	dc.b	0,0,$F,$FF,0,0,7,$FF
	dc.b	0,0,3,$FF,0,0,1,$FF
	dc.b	0,0,0,$FF,0,0,0,$7F
	dc.b	0,0,0,$3F,0,0,0,$1F
	dc.b	0,0,0,$F,0,0,0,7

l149544	moveq	#$42,d4
	tst.l	d6
	BEQ.s	l149578
	BPL.s	l149552
	neg.l	d6
	move.b	#$C2,d4
l149552	cmp.l	#$7FFF,d6
	bhi.s	l149560
	swap	d6
	subi.b	#$10,d4
l149560	add.l	d6,d6
	dBMI	d4,l149560
	tst.b	d6
	BPL.s	l149576
	addi.l	#$100,d6
	BCC.s	l149576
	roxr.l	#1,d6
	addq.b	#1,d4
l149576	move.b	d4,d6
l149578	RTS

l14957A	dc.b	$11,$93,$EA,$7A,8,$2C,$57,$7D
	dc.b	4,5,$62,$47,2,0,$AB,$11
	dc.b	1,0,$15,$58,0,$80,2,$AA
	dc.b	0,$40,0,$55,0,$20,0,$A
	dc.b	0,$10,0,1,0,8,0,0
	dc.b	0,4,0,0,0,2,0,0
	dc.b	0,1,0,0,0,0,$80,0
	dc.b	0,0,$40,0,0,0,$20,0
	dc.b	0,0,$10,0,0,0,8,0
	dc.b	0,0,4,0,0,0,2,0
	dc.b	0,0,1,0,0,0,0,$80
	dc.b	0,0,0,$40,0,0,0,$20
l1495DA	link	a6,#-4
	movem.l	d6-d7,-(a7)
	clr.l	-(a7)
	move.l	8(a6),-(a7)
	JSR	l149632
	addq.l	#8,a7
	BGE.s	l149608
	move.l	#$FFFFFE40,-(a7)
	move.l	8(a6),-(a7)
	JSR	l149768
	addq.l	#8,a7
	move.l	d0,8(a6)
l149608	move.l	8(a6),-(a7)
	JSR	l1496E0
	addq.l	#4,a7
	move.l	d0,d7
	move.l	d7,-(a7)
	JSR	l149650
	addq.l	#4,a7
	move.l	d0,-4(a6)
	move.l	-4(a6),d0
	tst.l	(a7)+
	movem.l	(a7)+,d7
	unlk	a6
	RTS

l149632	link	a6,#-4
	movem.l	d3-d7,-(a7)
	move.l	8(a6),d7
	move.l	$C(a6),d6
	JSR	l149788
	movem.l	(a7)+,d3-d7
	unlk	a6
	RTS

l149650	link	a6,#0
	movem.l	d5-d7,-(a7)
	tst.l	8(a6)
	BGE.s	l14966C
	moveq	#1,d6
	move.l	8(a6),d0
	neg.l	d0
	move.l	d0,8(a6)
	BRA.s	l14966E

l14966C	clr.w	d6
l14966E	tst.l	8(a6)
	BNE.s	l149678
	clr.l	d0
	BRA.s	l1496D6

l149678	moveq	#$18,d7
	BRA.s	l149688

l14967C	move.l	8(a6),d0
	asr.l	#1,d0
	move.l	d0,8(a6)
	addq.l	#1,d7
l149688	move.l	8(a6),d0
	andi.l	#$7F000000,d0
	BNE.s	l14967C
	BRA.s	l1496A2

l149696	move.l	8(a6),d0
	asl.l	#1,d0
	move.l	d0,8(a6)
	subq.l	#1,d7
l1496A2	btst	#7,9(a6)
	BEQ.s	l149696
	move.l	8(a6),d0
	asl.l	#8,d0
	move.l	d0,8(a6)
	addi.l	#$40,d7
	move.l	d7,d0
	andi.l	#$7F,d0
	or.l	d0,8(a6)
	tst.w	d6
	BEQ.s	l1496D2
	ori.l	#$80,8(a6)
l1496D2	move.l	8(a6),d0
l1496D6	tst.l	(a7)+
	movem.l	(a7)+,d6-d7
	unlk	a6
	RTS

l1496E0	link	a6,#0
	movem.l	d4-d7,-(a7)
	move.l	8(a6),d0
	andi.l	#$7F,d0
	addi.l	#$FFFFFFC0,d0
	move.w	d0,d6
	tst.l	8(a6)
	BEQ.s	l149704
	tst.w	d6
	BGE.s	l149708
l149704	clr.l	d0
	BRA.s	l14975E

l149708	move.l	8(a6),d0
	andi.l	#$80,d0
	move.w	d0,d5
	cmp.w	#$1F,d6
	BLE.s	l14972E
	tst.w	d5
	BEQ.s	l149726
	move.l	#$80000000,d0
	BRA.s	l14972C

l149726	move.l	#$7FFFFFFF,d0
l14972C	BRA.s	l14975E

l14972E	move.l	8(a6),d7
	asr.l	#8,d7
	andi.l	#$FFFFFF,d7
	subi.w	#$18,d6
	BRA.s	l149744

l149740	asr.l	#1,d7
	addq.w	#1,d6
l149744	tst.w	d6
	BLT.s	l149740
	BRA.s	l14974E

l14974A	asl.l	#1,d7
	subq.w	#1,d6
l14974E	tst.w	d6
	BGT.s	l14974A
	tst.w	d5
	BEQ.s	l14975C
	move.l	d7,d0
	neg.l	d0
	move.l	d0,d7
l14975C	move.l	d7,d0
l14975E	tst.l	(a7)+
	movem.l	(a7)+,d5-d7
	unlk	a6
	RTS

l149768	link	a6,#-4
	movem.l	d3-d7,-(a7)
	move.l	8(a6),d7
	move.l	$C(a6),d6
	JSR	l1497A4
	move.l	d7,d0
	movem.l	(a7)+,d3-d7
	unlk	a6
	RTS

l149788	tst.b	d6
	BPL.s	l149798
	tst.b	d7
	BPL.s	l149798
	cmp.b	d7,d6
	BNE.s	l14979E
	cmp.l	d7,d6
	RTS

l149798	cmp.b	d6,d7
	BNE.s	l14979E
	cmp.l	d6,d7
l14979E	RTS

	tst.b	d7
	RTS

l1497A4	move.b	d6,d4
	BEQ.s	l1497FA
	eori.b	#$80,d4
	BMI.s	l149818
	move.b	d7,d5
	BMI.s	l14981E
	BNE.s	l1497C2
	BRA.s	l1497F4

	move.b	d6,d4
	BMI.s	l149818
	BEQ.s	l1497FA
	move.b	d7,d5
	BMI.s	l14981E
	BEQ.s	l1497F4
l1497C2	sub.b	d4,d5
	BMI.s	l1497FE
	move.b	d7,d4
	cmp.b	#$18,d5
	BCC.s	l1497FA
	move.l	d6,d3
	clr.b	d3
	lsr.l	d5,d3
	move.b	#$80,d7
	add.l	d3,d7
	BCS.s	l1497E0
l1497DC	move.b	d4,d7
	RTS

l1497E0	roxr.l	#1,d7
	addq.b	#1,d4
	bvs.s	l1497E8
	BCC.s	l1497DC
l1497E8	moveq	#-1,d7
	subq.b	#1,d4
	move.b	d4,d7
	ori.b	#2,ccr

	RTS
l1497F4	move.l	d6,d7
	move.b	d4,d7
	RTS

l1497FA	tst.b	d7
	RTS

l1497FE	cmp.b	#$E8,d5
	BLE.s	l1497F4
	neg.b	d5
	move.l	d6,d3
	clr.b	d7
	lsr.l	d5,d7
	move.b	#$80,d3
	add.l	d3,d7
	BCS.s	l1497E0
	move.b	d4,d7
	RTS

l149818	move.b	d7,d5
	BMI.s	l1497C2
	BEQ.s	l1497F4
l14981E	moveq	#-$80,d3
	eor.b	d3,d5
	sub.b	d4,d5
	BEQ.s	l149876
	BMI.s	l149864
	cmp.b	#$18,d5
	BCC.s	l1497FA
	move.b	d7,d4
	move.b	d3,d7
	move.l	d6,d3
l149834	clr.b	d3
	lsr.l	d5,d3
	sub.l	d3,d7
	BMI.s	l1497DC
l14983C	move.b	d4,d5
l14983E	clr.b	d7
	subq.b	#1,d4
	cmp.l	#$7FFF,d7
	bhi.s	l149850
	swap	d7
	subi.b	#$10,d4
l149850	add.l	d7,d7
	dBMI	d4,l149850
	eor.b	d4,d5
	BMI.s	l149860
	move.b	d4,d7
	BEQ.s	l149860
	RTS

l149860	moveq	#0,d7
	RTS

l149864	cmp.b	#$E8,d5
	BLE.s	l1497F4
	neg.b	d5
	move.l	d7,d3
	move.l	d6,d7
	move.b	#$80,d7
	BRA.s	l149834

l149876	move.b	d7,d5
	exg	d5,d4
	move.b	d6,d7
	sub.l	d6,d7
	BEQ.s	l149860
	BPL.s	l14983C
	neg.l	d7
	move.b	d5,d4
	BRA.s	l14983E

	ds.l	400