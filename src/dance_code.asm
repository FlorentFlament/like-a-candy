BEAT_TIMER_INITVAL = 27
SPRITE_LINES = 23              ; +1

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

        ;; set Playfield on
        lda #$ff
        sta PF0
        sta PF1
        sta PF2
        ;; Set colors to black though
        lda #$00
        sta COLUPF
        rts

dance_vblank:
        jsr tia_player      ; play TIA
        ldy #80             ; middle of the screen
        lda beat_cnt
        and #$08
        tax
        jsr fx_sprite_prepare

        ;; Clear background
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

        lda frame_cnt
        clc
        adc #(64 / 4)
        and #$3f
        tax
        ldy #$00
        lda dance_sintable,X
        cmp #8
        bpl .other_side
        ldy #$01
.other_side:
        sty ptr0                 ; temporary variable

        lda frame_cnt
        and #$3f                ; table length is 64
        tax
        lda dance_sintable,X
        tax
        lda #$68
        ora ptr0
        sta dance_bg,X
        sta dance_bg+2,X
        lda #$6a
        ora ptr0
        sta dance_bg+1,X
        
        rts

dance_overscan:
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
