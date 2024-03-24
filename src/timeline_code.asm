timeline_init:
        lda #$00
        sta current_fx
        rts

timeline_overscan:
	inc frame_cnt
	bne .continue
	inc frame_cnt + 1 	; if framecnt drops to 0
.continue:                              
        rts
