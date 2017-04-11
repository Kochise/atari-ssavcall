# ssavcall

Atari program to allow using the aes and vdi from assembler

* Hardware and software needed

You need the following to get this program working :

\- Atari computer with 68030 processor (original or upgraded)<br>
\- Atari computer with DMA sound<br>

* List of programs

\- SSAVCALL.PRG : TSR program to launch first<br>
\- TESTSSAV.PRG : test program that make use of SSAVCALL<br>

* How to use it

Launch the 'SSAVCALL.PRG' program first to install it into memory. Then launch the 'TESTSSAV.PRG' program to display a GEM desktop coded with SSAVCALL.

Some actions are sounded using the 'PRAWPLAY' files, so you need DMA sound system (actually a Falcon030 features both 68030 and DMA).

* Some infos

This was one of my first system program to improve the original operating system using TRAP patching.

The goal was to add the possibility to program the AES and VDI just like BIOS/XBIOS/GEMDOS by stacking values in order then calling a TRAP.

The biggest work was done on the documentation. I was young at that time an wrote light heartly, embedding several private jokes.

More improvements followed and I refactored things towards writing my own operating system. Just look for the different branches.
