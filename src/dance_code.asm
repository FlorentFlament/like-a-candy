BEAT_TIMER_INITVAL = 27


dance_init:        SUBROUTINE
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
        rts

dance_vblank:
        jsr tia_player      ; play TIA
        ldy #80             ; middle of the screen
        lda beat_cnt
        and #$08
        tax
        jsr fx_sprite_prepare
        rts

dance_overscan:
        sta WSYNC
        ;; Black background color needed during overscan and vblank for proper TV sync
        lda #$00
        sta COLUBK

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
        sta COLUBK              ; Set background color asap
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

        ldx #(120 - 16 - 1)
        ldy #1
        lda beat_cnt
        and #$08
        beq .single_size_sprites
        ldx #(120 - 32 - 1)
        ldy #3
.single_size_sprites:
        sty ptr3
        ldy #15

.loop:
        sta WSYNC
        dex
        bpl .loop

        jsr fx_sprite_draw_2sprites
        rts
