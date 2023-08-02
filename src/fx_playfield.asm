fx_playfield_init:	SUBROUTINE
	;; Copy 6 pointers i.e 12 bytes to pfpic memory address
	ldy #11
.loop:
	lda pf_bambamhacko_ptr,Y
	sta pfpic_p0,Y
	dey
	bpl .loop
fx_playfield_vblank:
fx_playfield_overscan:
	rts

fx_playfield_kernel:	SUBROUTINE
	;; Intialize colors
	lda #$fe
	sta COLUPF
	ldy #39			; 30 lines. Y can be used to indirect fetch
.outer:
	ldx #5			; 6 lines thick graphic lines (40 graphic lines)
.inner:
	sta WSYNC
	lda (pfpic_p0),Y
	sta PF0
	lda (pfpic_p1),Y
	sta PF1
	lda (pfpic_p2),Y
	sta PF2
	lda (pfpic_p3),Y
	sta PF0
	lda (pfpic_p4),Y
	sta PF1
	lda (pfpic_p5),Y
	sta PF2
	dex
	bpl .inner
	dey
	bpl .outer

	sta WSYNC
	lda #$00
	sta PF0
	sta PF1
	sta PF2
	sta COLUPF
	rts

;;;
;;; DATA
;;;
pf_bambamhacko_p0:
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $c0
	dc.b $40, $c0, $40, $40, $40, $00, $00, $00
pf_bambamhacko_p1:
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $08
	dc.b $09, $2a, $39, $28, $08, $00, $02, $1a
	dc.b $ab, $1a, $00, $00, $00, $00, $00, $00
pf_bambamhacko_p2:
	dc.b $00, $00, $00, $06, $08, $ac, $aa, $2c
	dc.b $20, $20, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $59, $c5, $59, $40, $40, $00, $04, $35
	dc.b $56, $34, $10, $10, $10, $00, $00, $00
pf_bambamhacko_p3:
	dc.b $00, $00, $00, $80, $80, $b0, $a0, $30
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $d0, $40, $d0, $00, $00, $00, $00, $60
	dc.b $50, $60, $00, $00, $00, $00, $00, $00
pf_bambamhacko_p4:
	dc.b $00, $00, $00, $00, $00, $9c, $15, $dd
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $80, $80, $80, $00, $00, $00, $88, $a8
	dc.b $d8, $88, $00, $00, $00, $00, $00, $00
pf_bambamhacko_p5:
	dc.b $00, $00, $00, $00, $20, $2b, $1a, $2a
	dc.b $08, $08, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $00, $00, $00, $00
pf_bambamhacko_ptr:
	dc.w pf_bambamhacko_p0
	dc.w pf_bambamhacko_p1
	dc.w pf_bambamhacko_p2
	dc.w pf_bambamhacko_p3
	dc.w pf_bambamhacko_p4
	dc.w pf_bambamhacko_p5
