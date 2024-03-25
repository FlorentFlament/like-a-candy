;;; Position a sprite
;;; Argument: Id for the sprite (0 or 1)
;;; A : must contain Horizontal position
;;; At the end:
;;; A: is destroyed
    MAC POSITION_SPRITE
	sta WSYNC
	SLEEP 14

        ;;;;; Rough position of sprite ;;;;;
	sec
.rough_loop:
	; The rough_loop consumes 15 (5*3) pixels
	sbc #$0f	      ; 2 cycles
	bcs .rough_loop ; 3 cycles
	sta RESP{1}

        ;;;;; Fine position of sprite ;;;;;
	;; A register has value in [-15 .. -1]
	clc
	adc #$07 ; A in [-8 .. 6]
	eor #$ff ; A in [-7 .. 7]
    REPEAT 4
	asl
    REPEND
	sta HMP{1} ; Fine position of missile or sprite
    ENDM

;;; Draw a picture using 2 sprites
;;; Parameters:
;;; ptr0 - Pointer to sprite0
;;; ptr1 - Pointer to sprite1
;;; ptr2 - Pointer to sprite colors
;;; ptr3 - sprites size (0 for single size or 1 for double size)
;;; ptr3+1 - background color
fx_sprite_draw_2sprites SUBROUTINE
        ldx #(BG_LINES - 1)
        ldy #(SPRITE_LINES - 1)

.loop:
        sta WSYNC
        lda dance_bg,X
        sta COLUPF
        and #$01
        asl
        asl
        sta CTRLPF
        lda (ptr2),Y
        sta COLUP0
        sta COLUP1
        lda (ptr0),Y
        sta GRP0
        lda (ptr1),Y
        sta GRP1

        lda ptr3
        beq .single_size_1
        sta WSYNC
.single_size_1

        ;; Intermediate background line
        dex
        sta WSYNC
        lda dance_bg,X
        sta COLUPF
        and #$01
        asl
        asl
        sta CTRLPF

        lda ptr3
        beq .single_size_2
        sta WSYNC
.single_size_2

        dex
        dey
        bpl .loop
        sta WSYNC

        lda ptr3+1
        sta COLUPF
        lda #$00
        sta GRP0
        sta GRP1
        rts

;;; Y should be 1 or 2 (for single or double size)
fx_sprite_size SUBROUTINE
        lda #$00
        cpy #2
        bne .single_size
        lda #$05
.single_size:
        sta NUSIZ0
        sta NUSIZ1
        rts

;;; Position the scale the sprites
;;; Y contains the position of the middle of the sprite
;;; X contains the size of the sprites (0 single - non-0 double)
fx_sprite_prepare SUBROUTINE
        lda #8                  ; single size sprites
        cpx #0
        beq .single_size
        lda #16                 ; double size sprites
.single_size:
        sta ptr0
        tya
        sec
        sbc ptr0
        POSITION_SPRITE 0
        tya
        POSITION_SPRITE 1
	sta WSYNC
	sta HMOVE		; Commit sprites fine tuning

        ;; Scale the sprites appropriately
        lda #$00
        cpx #0
        beq .scale_single_size
        lda #$05
.scale_single_size:
        sta NUSIZ0
        sta NUSIZ1
        rts
