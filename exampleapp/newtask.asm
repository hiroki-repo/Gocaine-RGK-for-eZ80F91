.org 010000h
.assume ADL=1
	ld a,0
	ld de,0428000h
	ld hl,testtask1
	rst.lil 08h
	ld a,0
	ld de,0438000h
	ld hl,testtask2
	rst.lil 08h
lplp:	jr lplp
testtask1:
		ld b,0
waitaftersvc:
		djnz waitaftersvc
		ld a,3
		out0 (0d3h),a
		ld a,7
		out0 (0d2h),a
		xor a,a
loop4exampleapp:
		ld hl,mesofhelloworld
loop4exampleapp_0:
		ld a,(hl)
		out0 (0d0h),a
		inc hl
		and a,a
		jr nz,loop4exampleapp_0
		ld b,0
loop4exampleapp_1:
		exx
		ld b,0
loop4exampleapp_2:
		daa
		daa
		daa
		daa
		daa
		daa
		daa
		daa
		daa
		daa
		daa
		daa
		daa
		daa
		daa
		daa
		djnz loop4exampleapp_2
		exx
		djnz loop4exampleapp_1
		jp loop4exampleapp
mesofhelloworld:	.db "Hello, World!",0dh,0ah,00h
testtask2:
		ld a,3
		out0 (0c3h),a
		ld a,7
		out0 (0c2h),a
		ld a,044h
		ld mb,a
		ld hl,0020000h
		ld de,0448000h
		ld bc,128
		di
		ldir
		ei
		jp.sis 08000h
		