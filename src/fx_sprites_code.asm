;;; Draw a picture using 2 sprites
;;; Parameters:
;;; ptr0 - Pointer to sprite0
;;; ptr1 - Pointer to sprite1
;;; ptr2 - Pointer to colors
;;; ptr3 - line_thickness -1
;;; Y - Picture lines count -1
fx_sprite_draw_2sprites: SUBROUTINE
.loop:
        lda (ptr2),Y
        sta COLUP0
        sta COLUP1
        lda (ptr0),Y
        sta GRP0
        lda (ptr1),Y
        sta GRP1

        ldx ptr3
.line_loop:
        sta WSYNC
        dex
        bpl .line_loop

        dey
        bpl .loop

        lda #$00
        sta GRP0
        sta GRP1
        rts


; Position the sprites
; 12*8 = 96 pixels for the text
; i.ie 32 pixels on each side (160 - 96)/2
; +68 HBLANK = 100 pixels for RESP0
; Must be aligned !
	ALIGN 8
fx_sprite_position SUBROUTINE
	sta WSYNC
        ; Rough P0 position = 15*x - 51
        ; Rough P1 position = 15*x - 51 + 9
	ldx #8                  ; 15*8 - 51 = 69
.posit	dex		; 2
	bne .posit	; 2** (3 if branching)
	sta RESP0
	sta RESP1
	lda #$d0		; -> Pos SP1 72
	sta HMP0
	lda #$e0                ; -> Pos SP2 88
	sta HMP1
	sta WSYNC
	sta HMOVE

	; Don't touch HMPx for 24 cycles
	ldx #4
.dont_hmp	dex
	bpl .dont_hmp
	rts
