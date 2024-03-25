BEAT_TIMER_INITVAL = 27
SPRITE_LINES = 23              ; +1
SINTABLE_LEN = 64
SINTABLE_MAX = 21

dance_init SUBROUTINE
        INCLUDE "chloe-eclot_trackinit.asm"
        ;; Beat timer
        lda #BEAT_TIMER_INITVAL
        sta beat_timer
        ;; Beat counter
        ;; This determines the state of the animation
        ;; bit  0  : picture to display (0 or 1)
        ;; bits 2-3: colors to use
        ;; bit  3  : size of sprite
        lda #$00
        sta beat_cnt

        ;; init dance bars
        lda #0
        sta dancebar_pos
        lda #$80
        sta dancebar_col
        lda #(SINTABLE_LEN/3)
        sta dancebar_pos+1
        lda #$90
        sta dancebar_col+1
        lda #(2*SINTABLE_LEN/3)
        sta dancebar_pos+2
        lda #$20
        sta dancebar_col+2

        ;; set Playfield on
        lda #$ff
        sta PF0
        sta PF1
        sta PF2
        ;; Set colors to black though
        lda #$00
        sta COLUPF
        rts

dance_vblank SUBROUTINE
        jsr tia_player      ; play TIA
        ldy #80             ; middle of the screen
        lda beat_cnt
        and #$08
        tax
        jsr fx_sprite_prepare

;;; Clear background
        lda beat_cnt
        lsr
        lsr
        and #$03
        tax
        lda background_color,X
        ldx #SPRITE_LINES
.clear_bg_loop:
        sta dance_bg,X
        dex
        bpl .clear_bg_loop

        ldx #0
        jsr draw_raster
        ldx #1
        jsr draw_raster
        ldx #2
        jsr draw_raster
        rts

sort_3dancebars SUBROUTINE
        lda frame_cnt
        lsr
        adc dancebar_pos
        adc #(SINTABLE_LEN / 4) ; deep
        lda frame_cnt
        lsr
        adc dancebar_pos
        adc #(SINTABLE_LEN / 4) ; deep
        rts

;;; X dancebar index (0, 1, 2, ...)
;;; Uses ptr0
;;; returns dancebar depth in [0, SINTABLE_MAX[
get_dancebar_depth:
        lda dancebar_pos,X
        sta ptr0
        lda frame_cnt
        lsr
        clc
        adc ptr0
        adc #(SINTABLE_LEN / 4)
        and #$3f        ; table length is 64 (Change if Length changes)
        tax
        lda dance_sintable,X
        rts

;;; X dancebar index (0, 1, 2, ...)
;;; Uses ptr0
;;; returns dancebar height in [0, SINTABLE_MAX[
get_dancebar_height:
        lda dancebar_pos,X
        sta ptr0
        lda frame_cnt
        lsr
        clc
        adc ptr0
        and #$3f        ; table length is 64 (Change if Length changes)
        tax
        lda dance_sintable,X
        rts

;;; X: dancebar index
;;; Draw raster on background
draw_raster SUBROUTINE
        stx ptr1                ; save dancebar index in ptr1
        jsr get_dancebar_depth
        ldy #$00
        cmp #(SINTABLE_MAX / 2)
        bpl .other_side
        ldy #$01
.other_side:
        sty ptr2                 ; store other_side flag in ptr2

        ldx ptr1
        jsr get_dancebar_height
        tax
        ldy ptr1
        lda dancebar_col,Y      ; bar chrominance in a
        ora #$08                ; add luminance
        ora ptr2                ; add other_side flag
        sta dance_bg,X          ; store in dance_bg
        sta dance_bg+2,X
        lda dancebar_col,Y      ; bar chrominance in a
        ora #$0a                ; add luminance
        ora ptr2                ; add other_side flag
        sta dance_bg+1,X
        rts

dance_overscan SUBROUTINE
        sta WSYNC
        ;; Black background color needed during overscan and vblank for proper TV sync
        lda #$00
        sta COLUPF

        ;; Beat counter update
        dec beat_timer
        bpl .continue
        lda #BEAT_TIMER_INITVAL
        sta beat_timer
        inc beat_cnt
.continue:
        rts

dance_kernel SUBROUTINE
        lda beat_cnt
        lsr
        lsr
        and #$03
        tax
        lda background_color,X
        sta WSYNC
        sta ptr3+1
        sta COLUPF
        lda dance_color_low,X
        sta ptr2
        lda dance_color_high,X
        sta ptr2+1

        lda beat_cnt
        and #$01
        tax
        lda sp1_bonhomme_low,X
        sta ptr0
        lda sp1_bonhomme_high,X
        sta ptr0+1
        lda sp2_bonhomme_low,X
        sta ptr1
        lda sp2_bonhomme_high,X
        sta ptr1+1

        ldx #(120 - SPRITE_LINES)
        ldy #0
        lda beat_cnt
        and #$08
        beq .single_size_sprites
        ldx #(120 - 2*SPRITE_LINES)
        ldy #2
.single_size_sprites:
        sty ptr3

        lda #<dance_bg
        sta ptr4
        lda #>dance_bg
        sta ptr4+1
        ldy #SPRITE_LINES                 ; lines count

.loop:
        sta WSYNC
        dex
        bpl .loop

        jsr fx_sprite_draw_2sprites
        rts
