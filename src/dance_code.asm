;;; No parameters
;;; Returns rasters count in A
    MAC GET_RASTERS_COUNT
        lda beat_cnt
        REPEAT 3
        lsr
        REPEND
        and #$0f
        tax
        lda dancebar_data_count,X
    ENDM

;;; X: dancebar index
;;; Draw raster on background
;;; Uses ptr0, ptr1 and ptr2
    MAC DRAW_RASTER
        stx ptr1                ; save dancebar index in ptr1
        GET_DANCEBAR_DEPTH
        ldy #$00
        cmp #(SINTABLE_MAX / 2)
        bpl .other_side
        ldy #$01
.other_side:
        sty ptr2                 ; store other_side flag in ptr2

        ldx ptr1
        GET_DANCEBAR_HEIGHT
        tax
        ldy ptr1
        lda dancebar_col,Y      ; bar chrominance in a
        ora #$02                ; add luminance
        ora ptr2                ; add other_side flag
        sta dance_bg,X          ; store in dance_bg
        sta dance_bg+8,X
        lda dancebar_col,Y      ; bar chrominance in a
        ora #$04                ; add luminance
        ora ptr2                ; add other_side flag
        sta dance_bg+1,X
        sta dance_bg+7,X
        lda dancebar_col,Y      ; bar chrominance in a
        ora #$06                ; add luminance
        ora ptr2                ; add other_side flag
        sta dance_bg+2,X
        sta dance_bg+6,X
        lda dancebar_col,Y      ; bar chrominance in a
        ora #$08                ; add luminance
        ora ptr2                ; add other_side flag
        sta dance_bg+3,X
        sta dance_bg+5,X
        lda dancebar_col,Y      ; bar chrominance in a
        ora #$0a                ; add luminance
        ora ptr2                ; add other_side flag
        sta dance_bg+4,X
    ENDM

;;; Y number of bars
    MAC DANCEBARS_INIT
        dey
        bmi .end
        lda dancebar_data_pos_low,Y
        sta ptr0
        lda dancebar_data_pos_high,Y
        sta ptr0+1
.loop:
        lda (ptr0),Y
        sta dancebar_pos,Y
        lda dancebar_data_cols,Y
        sta dancebar_col,Y
        dey
        bpl .loop
.end:
    ENDM

;;; X dancebar index (0, 1, 2, ...)
;;; Uses ptr0
;;; returns dancebar height in [0, SINTABLE_MAX[
    MAC GET_DANCEBAR_HEIGHT
        lda dancebar_pos,X
        sta ptr0
        lda frame_cnt
        clc
        adc ptr0
        and #$7f        ; table length is 128 (Change if SINTABLE_LEN changes)
        tax
        lda dance_sintable,X
    ENDM

;;; X dancebar index (0, 1, 2, ...)
;;; Uses ptr0
;;; returns dancebar depth in [0, SINTABLE_MAX[
    MAC GET_DANCEBAR_DEPTH
        lda dancebar_pos,X
        sta ptr0
        lda frame_cnt
        clc
        adc ptr0
        adc #(SINTABLE_LEN / 4)
        and #$7f        ; table length is 128 (Change if SINTABLE_LEN changes)
        tax
        lda dance_sintable,X
    ENDM

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
        ;; bits 3-6: rasters count
        lda #$00
        sta beat_cnt

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
;;; Sort rasters
        ;; jsr sort_3dancebars

;;; Draw rasters on buffer
        GET_RASTERS_COUNT
        sta ptr3
        dec ptr3
        bmi .no_rasters
.rasters_loop:
        ldx ptr3
        DRAW_RASTER
        dec ptr3
        bpl .rasters_loop
.no_rasters:
        rts

;; ;;; Uses ptr0 and ptr1
;; sort_3dancebars SUBROUTINE
;;         ldx #0
;;         ldy #1
;;         jsr compare_and_swap
;;         ldx #1
;;         ldy #2
;;         jsr compare_and_swap
;;         ldx #0
;;         ldy #1
;;         jsr compare_and_swap
;;         rts

;;; X: index of first dancebar
;;; Y: index of seconde dancebar
;;; Uses ptr0, ptr1 and ptr2
compare_and_swap SUBROUTINE
        stx ptr2                ; saves index of first dancebar in ptr2
        GET_DANCEBAR_DEPTH
        sta ptr1                ; depth of first dancebar in ptr1
        tya
        tax
        GET_DANCEBAR_DEPTH      ; depth of second dancebar in A
        cmp ptr1
        bpl .sorted

        ldx ptr2
        ;; Swap dancebars pos
        lda dancebar_pos,X      ; first dancebar pos
        sta ptr1
        lda dancebar_pos,Y      ; second dancebar pos
        sta dancebar_pos,X
        lda ptr1
        sta dancebar_pos,Y
        ;; Swap dancebars col
        lda dancebar_col,X      ; first dancebar pos
        sta ptr1
        lda dancebar_col,Y      ; second dancebar pos
        sta dancebar_col,X
        lda ptr1
        sta dancebar_col,Y
.sorted:
        rts


dance_overscan SUBROUTINE
    ;; Black background color needed during overscan and vblank for proper TV sync
        sta WSYNC
        lda #$00
        sta COLUPF

    ;; Play the music
        jsr tia_player

    ;; Beat counter update
        dec beat_timer
        bpl .continue
        lda #BEAT_TIMER_INITVAL
        sta beat_timer
        inc beat_cnt
.continue:

    ;; Initialize dance bars
        lda beat_cnt            ; bits 3-6: rasters count
        and #$07
        bne .no_init_dance_bars
        GET_RASTERS_COUNT
        tay
        DANCEBARS_INIT
.no_init_dance_bars:

    ;;; Clear dance background
        lda beat_cnt            ; bit 2-3 colors to use
        lsr
        lsr
        and #$03
        tax
        lda background_color,X
        ldx #(BG_LINES - 1)
.clear_bg_loop:
        sta dance_bg,X
        dex
        bpl .clear_bg_loop

    ;;; Position dancer sprites
        ldy #80                 ; Horizontal middle of screen
        lda beat_cnt
        and #$08
        tax                     ; Sprite size
        jsr fx_sprite_prepare

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

.loop:
        sta WSYNC
        dex
        bpl .loop

        jsr fx_sprite_draw
        rts
