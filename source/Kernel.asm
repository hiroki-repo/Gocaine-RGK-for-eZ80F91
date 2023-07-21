		CPU	= EZ80F91
		.ORG 0
        .ASSUME ADL=0
		di
		stmix
		jp.lil init
		nop
		nop
		nop
		jp.lil syscall
		nop
		nop
		nop
		jp.lil nohandler
		nop
		nop
		nop
		jp.lil nohandler
		nop
		nop
		nop
		jp.lil nohandler
		nop
		nop
		nop
		jp.lil nohandler
		nop
		nop
		nop
		jp.lil nohandler
		nop
		nop
		nop
		jp.lil nohandler
		;0x40 - EMAC Rx
		DL nohandler4i
		;0x44 - EMAC Tx
		DL nohandler4i
		;0x48 - EMAC SYS
		DL nohandler4i
		;0x4C -  PLL
		DL nohandler4i
		;0x50 - Flash
		DL nohandler4i
		;0x54 - Timer 0
		DL contextswitch
		;0x58 - Timer 1
		DL nohandler4i
		;0x5C - Timer 2
		DL nohandler4i
		;0x60 - Timer 3
		DL nohandler4i
		;NMI Handler
		DW 0
		jp.lil nmihandler
		DB 0
		;0x6C -  RTC
		DL nohandler4i
		;0x70 - UART 0
		DL nohandler4i
		;0x74 - UART 1
		DL nohandler4i
		;0x78 -  I2C
		DL nohandler4i
		;0x7C -  SPI
		DL nohandler4i
		;0x80 - Port A 0
		DL nohandler4i
		;0x84 - Port A 1
		DL nohandler4i
		;0x88 - Port A 2
		DL nohandler4i
		;0x8C - Port A 3
		DL nohandler4i
		;0x90 - Port A 4
		DL nohandler4i
		;0x94 - Port A 5
		DL nohandler4i
		;0x98 - Port A 6
		DL nohandler4i
		;0x9C - Port A 7
		DL nohandler4i
		;0xA0 - Port B 0
		DL nohandler4i
		;0xA4 - Port B 1
		DL nohandler4i
		;0xA8 - Port B 2
		DL nohandler4i
		;0xAC - Port B 3
		DL nohandler4i
		;0xB0 - Port B 4
		DL nohandler4i
		;0xB4 - Port B 5
		DL nohandler4i
		;0xB8 - Port B 6
		DL nohandler4i
		;0xBC - Port B 7
		DL nohandler4i
		;0xC0 - Port C 0
		DL nohandler4i
		;0xC4 - Port C 1
		DL nohandler4i
		;0xC8 - Port C 2
		DL nohandler4i
		;0xCC - Port C 3
		DL nohandler4i
		;0xD0 - Port C 4
		DL nohandler4i
		;0xD4 - Port C 5
		DL nohandler4i
		;0xD8 - Port C 6
		DL nohandler4i
		;0xDC - Port C 7
		DL nohandler4i
		;0xE0 - Port D 0
		DL nohandler4i
		;0xE4 - Port D 1
		DL nohandler4i
		;0xE8 - Port D 2
		DL nohandler4i
		;0xEC - Port D 3
		DL nohandler4i
		;0xF0 - Port D 4
		DL nohandler4i
		;0xF4 - Port D 5
		DL nohandler4i
		;0xF8 - Port D 6
		DL nohandler4i
		;0xFC - Port D 7
		DL nohandler4i
        .ASSUME ADL=1
rkmastart		EQU 0C00000h
contextarea		EQU 10000h + rkmastart
contexttmpflag	EQU D000h + rkmastart
semaphorebool_val EQU D800h + rkmastart
contexttmpfp	EQU C040h + rkmastart
contexttmp		EQU C000h + rkmastart
stackarea4rtos	EQU 8000h + rkmastart

INTERVAL		EQU	50
timercount		EQU 50000000/1000/16*INTERVAL/16
init:
		ld a,0
		ld i,a
		im 2
		ld sp,stackarea4rtos
		ld a,8dh
		out0 (060h),a
		ld a,1
		out0 (061h),a
		ld a,timercount & 0ffh
		out0 (063h),a
		ld a,timercount >> 8
		out0 (064h),a
		ld a,1
		ld (contexttmp+(3*12)+1),a
		ei
		jp 10000h
lplp:	jr lplp
contextswitch:
		di
		ld (contexttmp+(3*10)),sp
		ld sp,contexttmp+3
		push af
		ld (contexttmp+(3*1)),bc
		ld (contexttmp+(3*2)),de
		ld (contexttmp+(3*3)),hl
		ex af,af'
		exx
		ld sp,contexttmp+15
		push af
		ld (contexttmp+(3*5)),bc
		ld (contexttmp+(3*6)),de
		ld (contexttmp+(3*7)),hl
		exx
		ex af,af'
		ld (contexttmp+(3*8)),ix
		ld (contexttmp+(3*9)),iy
		ld hl,0
		add.sis hl,sp
		ld (contexttmp+(3*11)),hl
		ld a,mb
		ld (contexttmp+(3*12)+0),a
		;change a context
		ld a,(contexttmpflag)
		ld d,a
		ld e,64
		mlt de
		ld hl,contextarea
		add hl,de
		ex de,hl
		ld hl,contexttmp
		ld bc,64
		ldir
		ex de,hl
reloadcontext:
		ld a,(contexttmpflag)
		inc a
		ld (contexttmpflag),a
		ld d,a
		ld e,64
		mlt de
		ld hl,contextarea
		add hl,de
		ld de,contexttmp
		ld bc,64
		ldir
		ld a,(contexttmp+(3*12)+1)
		bit 0,a
		jr z,reloadcontext
		;acknowlege the timer
		in0 a,(062h)
		halt
		in0 a,(062h)
		;set for other context
		ld hl,(contexttmp+(3*11))
		ld.sis sp,hl
		ld a,(contexttmp+(3*12)+0)
		ld mb,a
		ld sp,contexttmp+0
		pop af
		ld bc,(contexttmp+(3*1))
		ld de,(contexttmp+(3*2))
		ld hl,(contexttmp+(3*3))
		ex af,af'
		exx
		ld sp,contexttmp+12
		pop af
		ld bc,(contexttmp+(3*5))
		ld de,(contexttmp+(3*6))
		ld hl,(contexttmp+(3*7))
		exx
		ex af,af'
		ld ix,(contexttmp+(3*8))
		ld iy,(contexttmp+(3*9))
		ld sp,(contexttmp+(3*10))
		ei
		ret.l
newprocess:
		di
		ld (contexttmp+(3*10)),sp
		ld sp,contexttmp+3
		push af
		ld (contexttmp+(3*1)),bc
		ld (contexttmp+(3*2)),de
		ld (contexttmp+(3*3)),hl
		ex af,af'
		exx
		ld sp,contexttmp+15
		push af
		ld (contexttmp+(3*5)),bc
		ld (contexttmp+(3*6)),de
		ld (contexttmp+(3*7)),hl
		exx
		ex af,af'
		ld (contexttmp+(3*8)),ix
		ld (contexttmp+(3*9)),iy
		ld hl,0
		add.sis hl,sp
		ld (contexttmp+(3*11)),hl
		ld a,mb
		ld (contexttmp+(3*12)+0),a
		;save a current context
		ld a,(contexttmpflag)
		ld d,a
		ld e,64
		mlt de
		ld hl,contextarea
		add hl,de
		ex de,hl
		ld hl,contexttmp
		ld bc,64
		ldir
		ex de,hl
		xor a,a
		ld (contexttmpflag+1),a
newprocess_reloadcontext:
		ld a,(contexttmpflag+1)
		inc a
		ld (contexttmpflag+1),a
		ld d,a
		ld e,64
		mlt de
		ld hl,contextarea
		add hl,de
		ld de,contexttmpfp
		ld bc,64
		ldir
		ld a,(contexttmpfp+(3*12)+1)
		bit 0,a
		jr nz,newprocess_reloadcontext
		set 0,a
		ld (contexttmpfp+(3*12)+1),a
		ld sp,(contexttmp+(3*10))
		ld a,(contexttmpflag+1)
		ld d,a
		ld e,64
		mlt de
		ld hl,contextarea
		add hl,de
		ld (hl),0
		push hl
		pop de
		inc de
		ld bc,64
		ldir
		ld de,(contexttmp+(3*2))
		ld hl,(contexttmp+(3*3))
		ld (contexttmpfp+(3*10)),de
		ex de,hl
		ld (hl),3
		inc hl
		ld (hl),de
		ex de,hl
		ld a,(contexttmpflag+1)
		ld d,a
		ld e,64
		mlt de
		ld hl,contextarea
		add hl,de
		ex de,hl
		ld hl,contexttmpfp
		ld bc,64
		ldir
		ex de,hl
		;restore callee
		ld a,(contexttmpflag)
		ld d,a
		ld e,64
		mlt de
		ld hl,contextarea
		add hl,de
		ld de,contexttmp
		ld bc,64
		ldir
		ld hl,(contexttmp+(3*11))
		ld.sis sp,hl
		ld a,(contexttmp+(3*12)+0)
		ld mb,a
		ld sp,contexttmp+0
		pop af
		ld bc,(contexttmp+(3*1))
		ld de,(contexttmp+(3*2))
		ld hl,(contexttmp+(3*3))
		ex af,af'
		exx
		ld sp,contexttmp+12
		pop af
		ld bc,(contexttmp+(3*5))
		ld de,(contexttmp+(3*6))
		ld hl,(contexttmp+(3*7))
		exx
		ex af,af'
		ld ix,(contexttmp+(3*8))
		ld iy,(contexttmp+(3*9))
		ld sp,(contexttmp+(3*10))
		ei
		ret.l
terminateprocess:
		di
		ld a,(contexttmp+(3*12)+1)
		res 0,a
		ld (contexttmp+(3*12)+1),a
		jp contextswitch
terminateotherprocess:
		di
		ld d,e
		ld e,64
		mlt de
		ld hl,contextarea + (3*12) + 1
		add hl,de
		res 0,(hl)
		ret.l
getprocessid:
		di
		ld a,(contexttmpflag)
		ld hl,0
		ld l,a
		ei
		ret.l
syscall:
		di
		and a,a
		jp z,newprocess
		cp a,1
		jp z,terminateprocess
		cp a,2
		jp z,getprocessid
		cp a,3
		jp z,terminateotherprocess
		cp a,4
		jp z,semaphorebool
		cp a,5
		jp z,semaphorechk
		ld hl,-1
		ei
		ret.l
semaphorebool:
		di
		ld de,semaphorebool_val
		ld a,b
		sra b
		sra b
		sra b
		ld hl,0
		res 5,b
		res 6,b
		res 7,b
		ld l,b
		add hl,de
		and a,07h
		ld b,a
		ld a,c
		jr z,semaphorebool__
		and a,1
semaphorebool_:
		sla a
		djnz semaphorebool_
		jr semaphorebool___
semaphorebool__:
		and a,1
semaphorebool___:
		ld c,a
		xor a,0ffh
		ld b,a
		ld a,(hl)
		and a,b
		or a,c
		ld (hl),a
		ei
		ret.l
semaphorechk:
		di
		ld de,semaphorebool_val
		ld a,b
		sra b
		sra b
		sra b
		ld hl,0
		res 5,b
		res 6,b
		res 7,b
		ld l,b
		add hl,de
		and a,07h
		ld b,a
		ld a,(hl)
		jr z,semaphorechk__
semaphorechk_:
		sra a
		djnz semaphorechk_
semaphorechk__:
		and a,1
		ld hl,0
		ld l,a
		ei
		ret.l
nohandler:
		ret.l
nohandler4i:
		ei
		reti.l
nmihandler:
		retn.l

		.ORG 10000h
		halt
		END