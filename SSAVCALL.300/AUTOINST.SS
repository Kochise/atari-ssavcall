; /// SSAV AutoInstaller v1.86 - KOSS 1998 ///
;
; Cookie "SSAV" -> SSAV_Info
; XBRA   "SSAV" -> SSAV_Start
	
	move.l	SP,D0
	BNE	SSAVBOOT_Install
	
	lea	AccStack,SP	; Si ACC, SP=0
	
SSAVBOOT_Install	movem.l	D0-7/A0-6,-(SP)

	pea	SSAVBOOT_TRAP3
	move.w	#$26,-(SP)	; - SUPEXEC -
	trap	#14	; *** XBIOS ***
	addq.l	#6,SP

	movem.l	(SP)+,D0-7/A0-6
	
	; Prog_Shrink (on n'a pas besoin des PINS Utilisateur)
	;move.w	#-1,-(SP)	; SSAV_Init
	;trap	#3
	;addq.l	#6,SP
	
	;SI BOOT 
	; Charger PINS Utilisateurs
	;Extension PIN
	
	; Booter PINS
	
SSAVBOOT_TRAP3	move.l	$8C.w,OldTRAP3
	move.l	#SSAV_Start,$8C.w
	
	RTS