BEAT_CNT_INITVAL = 27

dance_init:        SUBROUTINE
        INCLUDE "chloe-eclot_trackinit.asm"
        lda #BEAT_CNT_INITVAL
        sta beat_cnt
        rts

dance_vblank:
        jsr tia_player      ; play TIA
        jsr fx_sprite_position
        rts

dance_overscan:
        ;; Black background color needed during overscan and vblank for proper TV sync
        lda #$00
        sta COLUBK

        dec beat_cnt
        bpl .continue
        lda #BEAT_CNT_INITVAL
        sta beat_cnt
        inc anim_state
.continue:
        rts

dance_kernel SUBROUTINE
        lda anim_state
        lsr
        lsr
        and #$03
        tax
        lda background_color,X
        sta WSYNC
        sta COLUBK              ; Set background color asap
        lda dance_color_low,X
        sta ptr2
        lda dance_color_high,X
        sta ptr2+1

        lda anim_state
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

        lda #1
        sta ptr3
        ldy #15

        ldx #103
.loop:
        sta WSYNC
        dex
        bpl .loop

        jsr fx_sprite_draw_2sprites
        rts
