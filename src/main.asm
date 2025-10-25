; HackNotts 25 Submission
; much taken from nesdoug (thanks for carrying us, lol)
;
.p816
.smart

.include "regs.inc.asm"
.include "variables.asm"
.include "macros.inc.asm"
.include "init.asm"

.segment "CODE"

; enters here in forced blank
Main:
.a16 ; the setting from init code
.i16
	phk
	plb
	
    stz level

; DMA from BG_Palette to CGRAM
	A8
	stz CGADD ; $2121 cgram address = zero
	
	stz $4300 ; transfer mode 0 = 1 register write once
	lda #$22  ; $2122
	sta $4301 ; destination, cgram data
	ldx #.loword(BG_Palette)
	stx $4302 ; source
	lda #^BG_Palette
	sta $4304 ; bank
	ldx #256
	stx $4305 ; length
	lda #1
	sta MDMAEN ; $420b start dma, channel 0
	
	
; DMA from Tiles to VRAM	
	lda #V_INC_1 ; the value $80
	sta VMAIN  ; $2115 = set the increment mode +1
	ldx #$0000
	stx VMADDL ; $2116 set an address in the vram of $0000
	
	lda #1
	sta $4300 ; transfer mode, 2 registers 1 write
			  ; $2118 and $2119 are a pair Low/High
	lda #$18  ; $2118
	sta $4301 ; destination, vram data
	ldx #.loword(Tiles)
	stx $4302 ; source
	lda #^Tiles
	sta $4304 ; bank
	ldx #(End_Tiles-Tiles)
	stx $4305 ; length
	lda #1
	sta MDMAEN ; $420b start dma, channel 0
	
	
	
; DMA from Tilemap to VRAM	
	ldx #$6000
	stx VMADDL ; $2116 set an address in the vram of $6000
	
	lda #1
	sta $4300 ; transfer mode, 2 registers 1 write
			  ; $2118 and $2119 are a pair Low/High
	lda #$18  ; $2118
	sta $4301 ; destination, vram data
	ldx #.loword(SplashScreen)
	stx $4302 ; source
	lda #^SplashScreen
	sta $4304 ; bank
	ldx #$700
	stx $4305 ; length
	lda #1
	sta MDMAEN ; $420b start dma, channel 0	
	
	
; a is still 8 bit.
	lda #1 ; mode 1, tilesize 8x8 all
	sta BGMODE ; $2105
	
; 210b = tilesets for bg 1 and bg 2
; (210c for bg 3 and bg 4)
; steps of $1000 -321-321... bg2 bg1
	stz BG12NBA ; $210b BG 1 and 2 TILES at VRAM address $0000
	
	; 2107 map address bg 1, steps of $400... -54321yx
	; y/x = map size... 0,0 = 32x32 tiles
	; $6000 / $100 = $60
	lda #$60 ; bg1 map at VRAM address $6000
	sta BG1SC ; $2107

	lda #BG1_ON	; $01 = only bg 1 is active
	sta TM ; $212c
	
    lda #$05 ; $0f = turn the screen on (end forced blank)
	stz INIDISP ; $2100

    lda #NMI_ON
    sta NMITIMEN

;    stz INIDISP
    
    ldx #0
    ldy #0

    ; y = counter, once it reaches 30 (half a second), increase x
    ; x = brightness, once we reach full brightness, exit loop
    

@fade_in:
    A8
    XY16
    jsr Wait_NMI    
    XY8
 
    iny 
    cpy #05 
    bne @fade_in

    ldy #0

    inx
    
    stx INIDISP
    cpx #$0f
    bne @fade_in

@splash_stall:
    XY16
    jsr Wait_NMI
    XY8

    iny
    cpy #100
    bne @splash_stall
    
    ldy #0
@fade_out:
    A8
    XY16
    jsr Wait_NMI    
    XY8
 
    iny 
    cpy #05 
    bne @fade_out

    ldy #0

    dex
    
    stx INIDISP
    cpx #0
    bne @fade_out

; load first level?
    lda #FULL_BRIGHT
    sta INIDISP

    jsr Wait_NMI
    jsr NextLevel
Infinite_Loop:	
	A8
	XY16
	jsr Wait_NMI
	
	;code goes here

	jmp Infinite_Loop


	
Wait_NMI:
.a8
.i16
;should work fine regardless of size of A
	lda in_nmi ;load A register with previous in_nmi
@check_again:	
	WAI ;wait for an interrupt
	cmp in_nmi	;compare A to current in_nmi
				;wait for it to change
				;make sure it was an nmi interrupt
	beq @check_again
	rts
	

; load in the next level
; 
; increment the level counter
; get the pointer to the next tilemap from zero page table
; get the pointer to the next collision map from zero page table
; DMA for background map
; return

NextLevel:
.a8
.i16
    A8
    XY16
    ldx #$6000
	stx VMADDL ; $2116 set an address in the vram of $6000
	
	lda #1
	sta $4300 ; transfer mode, 2 registers 1 write
			  ; $2118 and $2119 are a pair Low/High
	lda #$18  ; $2118
	sta $4301 ; destination, vram data

    ldy level
    ldx tilemap_table, y

;    ldx #.loword(Level1TM)
	stx $4302 ; source
    
 ;   lda #^Level1TM
    lda tilemap_bank_table, y
	sta $4304 ; bank
	ldx #$700
	stx $4305 ; length
	lda #1
	sta MDMAEN ; $420b start dma, channel 0	
	
	
; a is still 8 bit.
	lda #1 ; mode 1, tilesize 8x8 all
	sta BGMODE ; $2105
	
; 210b = tilesets for bg 1 and bg 2
; (210c for bg 3 and bg 4)
; steps of $1000 -321-321... bg2 bg1
	stz BG12NBA ; $210b BG 1 and 2 TILES at VRAM address $0000
	
	; 2107 map address bg 1, steps of $400... -54321yx
	; y/x = map size... 0,0 = 32x32 tiles
	; $6000 / $100 = $60
	lda #$60 ; bg1 map at VRAM address $6000
	sta BG1SC ; $2107

	lda #BG1_ON	; $01 = only bg 1 is active
	sta TM ; $212c
	
    ldx level
    inx
    stx level

    rts	

.include "header.asm"	


.segment "RODATA1"

BG_Palette:
; 256 bytes
.incbin "assets/palette.pal"

Tiles:
; 4bpp tileset
.incbin "assets/tiles.chr"
End_Tiles:

Level1TM:
; $700 bytes
.incbin "assets/level1.map"

Level2TM:
.incbin "assets/level2.map"

SplashScreen:
.incbin "assets/splash.map"
