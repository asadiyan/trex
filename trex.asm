	processor 6502
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; include required files with VCS register memory maping and macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include "vcs.h"
        include "macro.h"
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; declare variables starting from memory address $80
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	seg.u Variables
        org $80
        
TrexXPos	byte		; player0 X-Pos
TrexYPos	byte		; player0 Y-Pos
CactusXPos	byte		; player1 X-Pos
CactusYPos	byte		; player1 Y-Pos
TrexSpritePtr	word		; pointer to player0 sprite lookup table
TrexColorPtr	word		; pointer to player0 color lookup table
CactusSpritePtr	word		; pointer to player1 sprite lookup table
CactusColorPtr	word		; pointer to player1 color lookup table

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; start our ROM code at memory address $F000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	seg Code
        org $F000
        
Reset:
	CLEAN_START		; call macro to reset memory and registers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; initialize RAM variables and TIA register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda #5
        sta TrexYPos		; trex y-pos  = 5
        
        lda #10
        sta TrexXPos		; trex x-pos = 10
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; initialize the pointers to the correct lookup table address
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #<TrexSprite
        sta TrexSpritePtr	; lo-byte pointer for Trex sprite lookup table
        lda #>TrexSprite
        sta TrexSpritePtr+1	; hi-byte pointer for Trex sprite lookup table
        
        lda #<TrexColor
        sta TrexColorPtr	; lo-byte pointer for Trex color lookup table
        lda #>TrexColor
        sta TrexColorPtr+1	; hi-byte pointer for Trex color lookup table

	lda #<CactusSprite
        sta CactusSpritePtr	; lo-byte pointer for Trex sprite lookup table
        lda #>CactusSprite
        sta CactusSpritePtr+1	; hi-byte pointer for Trex sprite lookup table
        
        lda #<CactusColor
        sta CactusColorPtr	; lo-byte pointer for Trex color lookup table
        lda #>CactusColor
        sta CactusColorPtr+1	; hi-byte pointer for Trex color lookup table


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; start the main display loop and frame rendering
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; display VSYNC and VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda #2
	sta VBLANK		; turn on VBLANK
	sta VSYNC		; turn on VSYNC
	REPEAT 3
		sta WSYNC	; display 3 recommended line of VSYNC
	REPEND
        lda #0
        sta VSYNC		; turn off VSYNC
        REPEAT 37
        	sta WSYNC	; display 37 recommended line of VBLANK
	REPEND            	
        sta VBLANK
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; display the 192 visible scanline of our main game
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameVisibleScanline:
	lda #$0E		
        sta COLUBK		; set color background to white
        
        ldx #161		; x = 192(the x counts the number of remaining scanline
.GameLineLoop:
	sta WSYNC
        dex			; x--
        bne .GameLineLoop	; jump to .GameLineLoop until x <= 0
        
        ldx #1
.SetOneLineBlack:
	
        ldy #$00
        sty COLUBK		; set background color to black just for 1 line 
	
        sta WSYNC
        dex
        bne .etOneLineBlack
        
        lda #$0E		; set background color to white again
        sta COLUBK
        
        ldx #30
.NextRemainingScanline:
	sta WSYNC
        dex
        bne .NextRemainingScanline
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; display overscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #2
        sta VBLANK		; turn VBLANK on
        REPEAT 30
        	sta WSYNC	; display 30 recommended lines of VBLANK overscan
	REPEND               
        lda #0
        sta VBLANK		; turn of VBLANK
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; loop back to start a brand new frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        jmp StartFrame		; continue to display the next frame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; declare Rom lookup table
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TrexSprite:
	.byte #%00000000;$0E
        .byte #%11101100;$0E
        .byte #%11001001;$0E
        .byte #%11011011;$0E
        .byte #%10111100;$0E
        .byte #%10000011;$0E
        .byte #%11111111;$0E
        .byte #%01111101;$0E
        .byte #%00111111;$0E

TrexColor:
	.byte #$00;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        .byte #$0E;
        

CactusSprite:
        .byte #%00111000;$00
        .byte #%00010000;$00
        .byte #%00111000;$00
        .byte #%01010100;$00
        .byte #%00010000;$00
        .byte #%00111000;$00
        .byte #%01010100;$00
        .byte #%00010000;$00


CactusColor:
        .byte #$00;
        .byte #$00;
        .byte #$00;
        .byte #$00;
        .byte #$00;
        .byte #$00;
        .byte #$00;
        .byte #$00;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; complete the ROM size with exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        org $FFFC		; move to position FFFC
        word Reset		; write 2 byte with the program reset address
        word Reset		; write 2 byte with the interuption vectorS
