; /// ASCII/Float (c) F. BRET & KOSS 1999 ///

	comment	HEAD=7
	
	SECTION	TEXT

	


	clr.w	-(SP)
	trap	#1	; *** GEMDOS ***

	SECTION	DATA

	
; Filly Basic Convert String (ASCII Float to BINARY Float)
{
	{%asg}~{%fsg}
	{%uan}~{%fip}
	{.[%uan]}~{%fmp}
	{%asc(de)[%san]|%pow}~{%fep}
}A2B_FloatDescriptor		
	
; Filly Basic Convert String (BINARY Float to ASCII Float)
{
	{%fsg}~{%bsg}
	{%fip}~{%ubn}
	{%fmp}~{.[%ubn]}
	{%fep}~{E[%sbn]!Sci!|%pow!Eng!}
}B2A_FloatDescriptor
	
; Filly Basic Convert String (BINARY Float to ASCII Float)
{
	{%fsg}~{%bit(31)}
	{%fep+127}~{%bfield(23-30)}
	{(%fip++%fmp)<<1}~{%bfield(0-22)}
}IEEE_SinglePrecision

{
	{%fsg}~{%bit(63)}
	{%fep+1023}~{%bfield(52-62)}
	{(%fip++%fmp)<<1}~{%bfield(0-51)}
}IEEE_DoublePrecision

{
	{%fsg}~{%bit(95)}
	{%fep+16383}~{%bfield(80-94)}
	{(%fip++%fmp)<<1}~{%bfield(0-63)}
}IEEE_ExtendedPrecision

{
	{%fep([0|$FF])}-{[[(%fsg&&%fip&&%fmp)==0][]|[(%fip&&%fmp)==0][]]}
}IEEE_MagicExpo

{
	{%alist(AfpnumkMGTPE,$MOD(%fep,E3),$RESTRICT_POW_LIST)}
}FLOAT_EngPower



asc	()
%uan	"0"
%san	"+-"
%ubn
%sbn
%sci	(Sci|Eng)

%fip
%fmp
%fep

%cos	()
%sin	()
%tan	()

%ch	()
%sh	()


Error - Translator - Too few parameters
                   - Missing
      - Syntax     - Unknown command
                   - Bad structure
      
	
	
	SECTION	BSS
