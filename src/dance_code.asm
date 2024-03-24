dance_init:        SUBROUTINE
        INCLUDE "chloe-eclot_trackinit.asm"

        ;; Initialize fx_playfield with pf_bambamhacko data
	;; Copy 6 pointers i.e 12 bytes to pfpic memory address
	ldy #11
.loop:
	lda pf_bambamhacko_ptr,Y
	sta pfpic_p0,Y
	dey
	bpl .loop
        rts

dance_vblank:
        jsr tia_player      ; play TIA
        rts

dance_overscan:
        rts

dance_kernel:
        jsr fx_playfield_kernel
        rts
        
