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

        lda #$00                ; Setting black Playfield color
        sta COLUPF
        lda frame_cnt
        sta ptr0                 ; Initializing color

        ldy #87
.head_loop:
        sta WSYNC
        lda ptr0
        sta COLUBK
        inc ptr0
        dey
        bpl .head_loop

        ldy #3                  ; 4 lines
.outer:
        ldx #15                 ; 16 lines thick
.inner:
        sta WSYNC
        lda ptr0
        sta COLUBK
        lda pf_flush_sync_p0,Y
        sta PF0
        lda pf_flush_sync_p1,Y
        sta PF1
        lda pf_flush_sync_p2,Y
        sta PF2
        lda pf_flush_sync_p3,Y
        sta PF0
        lda pf_flush_sync_p4,Y
        sta PF1
        lda pf_flush_sync_p5,Y
        sta PF2
        inc ptr0
	dex
	bpl .inner
	dey
	bpl .outer

        sta WSYNC
        lda ptr0
        sta COLUBK
        inc ptr0

        lda #0
        sta PF0
        sta PF1
        sta PF2

        ldy #86
.foot_loop:
        sta WSYNC
        lda ptr0
        sta COLUBK
        inc ptr0
        dey
        bpl .foot_loop

        sta WSYNC
        lda #0
        sta COLUBK
        rts

sync_overscan:
        rts
