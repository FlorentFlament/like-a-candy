bambamhako_init:        SUBROUTINE
        INCLUDE "bambamhako_trackinit.asm"

        ;; Initialize fx_playfield with pf_bambamhacko data
	;; Copy 6 pointers i.e 12 bytes to pfpic memory address
	ldy #11
.loop:
	lda pf_bambamhacko_ptr,Y
	sta pfpic_p0,Y
	dey
	bpl .loop
        rts

bambamhako_vblank:
        lda tt_cur_pat_index_c0
        cmp #54                 ; Stop music when last pattern reached
        bne .play_music
        ;; turn off volume, then skip music player
        lda #0
        sta AUDV0
        sta AUDV1
        jmp .end_vblank
.play_music:
        jsr tia_player      ; play TIA
.end_vblank:
        ;; call the init function
        ;; move to the next FX
        rts

bambamhako_overscan:
        rts

bambamhako_kernel:
        jsr fx_playfield_kernel
        rts
        
