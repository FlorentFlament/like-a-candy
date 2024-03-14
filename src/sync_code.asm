sync_vblank:
        lda frame_cnt + 1
        cmp #2                  ; Next FX after 512 frames
        bne .continue
        inc current_fx
.continue:        
        rts
        
sync_kernel:    SUBROUTINE
        REPEAT 4
        sta WSYNC
        REPEND
        
        ldy #240
.loop:
        sta WSYNC
        lda frame_cnt
        lsr
        sta COLUBK
        dey
        bne .loop

        sta WSYNC
        lda #0
        sta COLUBK
        rts

sync_overscan:
        rts
