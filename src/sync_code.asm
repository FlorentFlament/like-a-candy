sync_vblank SUBROUTINE
        lda frame_cnt + 1
        cmp #2                  ; Next FX after 512 frames
        bne .continue
        inc current_fx
.continue:
        rts

    MAC PADDING_LOOP
        ldy #((KERNEL_HEIGHT - 68) / 2)
.head_loop:
        sta WSYNC
        lda ptr0
        sta COLUBK
        inc ptr0
        dey
        bpl .head_loop
    ENDM

padding_loop SUBROUTINE
        PADDING_LOOP
        rts

sync_kernel SUBROUTINE
        lda #$00                ; Setting black Playfield color
        sta COLUPF
        lda frame_cnt
        sta ptr0                 ; Initializing color

        jsr padding_loop

        ldy #3                  ; 4 lines - Total of 64 lines
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

        jsr padding_loop

        sta WSYNC
        lda #0
        sta COLUBK
sync_overscan SUBROUTINE
        rts
