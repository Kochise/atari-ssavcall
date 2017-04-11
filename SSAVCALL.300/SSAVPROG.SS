; /// SSAVCALL Project 3.xx >Program< - KOSS 1999 ///

	comment	HEAD=7
	
	SECTION	TEXT
	
	dc.b	"ðSEA"	; Valid   SSAVCALL Program
	dc.b	"SSAV"	; Valid   SSAVCALL Signature
	dc.w	$300	; Minimal SSAVCALL Version
	dc.l	SEA_PlugList	; Plug-In List
	dc.l	SEA_Boot	; Boot Session Code
	dc.l	SEA_Desk	; Desk Session Code
	dc.w	$100	; Program Version
	dc.w	$0	; Program Date
	dc.b	"Your Program's Name",0 ; Program Name
	dc.b	"Your Name, Coder",0	; Program Author

		
	
	SECTION	DATA
	
	
	SECTION	BSS