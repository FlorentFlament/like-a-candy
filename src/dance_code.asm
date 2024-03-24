BEAT_CNT_INITVAL = 27

dance_init:        SUBROUTINE
        INCLUDE "chloe-eclot_trackinit.asm"
        lda #BEAT_CNT_INITVAL
        sta beat_cnt
        rts

dance_vblank:
        jsr tia_player      ; play TIA
        rts

dance_overscan:
        dec beat_cnt
        bpl .continue
        lda #BEAT_CNT_INITVAL
        sta beat_cnt
        lda anim_state
        eor #$01
        sta anim_state
.continue:
        rts

dance_kernel SUBROUTINE
        ldx #103
.loop:
        sta WSYNC
        dex
        bpl .loop

        lda anim_state
        bne .bonhomme2
        lda #<sp_bonhomme_1_bw_16x16_0
        sta ptr0
        lda #>sp_bonhomme_1_bw_16x16_0
        sta ptr0+1
        lda #<sp_bonhomme_1_bw_16x16_1
        sta ptr1
        lda #>sp_bonhomme_1_bw_16x16_1
        sta ptr1+1
        jmp .continue
.bonhomme2:
        lda #<sp_bonhomme_2_bw_16x16_0
        sta ptr0
        lda #>sp_bonhomme_2_bw_16x16_0
        sta ptr0+1
        lda #<sp_bonhomme_2_bw_16x16_1
        sta ptr1
        lda #>sp_bonhomme_2_bw_16x16_1
        sta ptr1+1

.continue:
        lda #<dance_color
        sta ptr2
        lda #>dance_color
        sta ptr2+1
        lda #0
        sta ptr3
        lda #1
        sta ptr4
        ldy #15
        jsr fx_sprite_draw_2sprites
        rts
