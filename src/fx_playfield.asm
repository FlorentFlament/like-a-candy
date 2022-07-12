fx_init:	SUBROUTINE
	;; Copy 6 pointers i.e 12 bytes to pfpic memory address
	ldy #11
.loop:
	lda pf_40x40_credits_ptr,Y
	sta pfpic_p0,Y
	dey
	bpl .loop
fx_vblank:
fx_overscan:
	rts

fx_kernel:	SUBROUTINE
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

pf_40x40_credits_p0:
	dc.b $00, $00, $00, $60, $f0, $30, $70, $60
	dc.b $c0, $80, $00, $00, $00, $00, $00, $00
	dc.b $00, $00, $00, $00, $f0, $30, $30, $90
	dc.b $90, $10, $10, $10, $10, $30, $30, $70
	dc.b $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0
pf_40x40_credits_p1:
	dc.b $00, $00, $01, $12, $9b, $d8, $9b, $19
	dc.b $cc, $cc, $0c, $00, $00, $22, $22, $2a
	dc.b $2a, $14, $00, $00, $ff, $ff, $fc, $f8
	dc.b $f1, $73, $33, $93, $f3, $f3, $33, $11
	dc.b $99, $ff, $ff, $ff, $ff, $ff, $ff, $ff
pf_40x40_credits_p2:
	dc.b $00, $00, $03, $27, $37, $36, $b2, $f1
	dc.b $70, $e0, $c0, $80, $00, $53, $54, $22
	dc.b $51, $56, $00, $00, $ff, $cf, $86, $e2
	dc.b $f3, $f3, $e3, $83, $f3, $f3, $c7, $8f
	dc.b $ff, $ff, $d9, $ae, $ae, $ae, $d9, $ff
pf_40x40_credits_p3:
	dc.b $00, $00, $00, $80, $c0, $c0, $d0, $80
	dc.b $00, $20, $70, $30, $00, $c0, $00, $90
	dc.b $40, $80, $00, $00, $f0, $f0, $b0, $90
	dc.b $10, $10, $10, $50, $d0, $d0, $c0, $c0
	dc.b $c0, $f0, $90, $a0, $90, $b0, $b0, $f0
pf_40x40_credits_p4:
	dc.b $00, $00, $00, $c0, $a0, $2e, $af, $ed
	dc.b $cd, $0c, $00, $00, $00, $22, $a2, $b1
	dc.b $a2, $9a, $00, $00, $ff, $f5, $70, $70
	dc.b $34, $25, $a5, $a5, $a7, $22, $22, $32
	dc.b $7f, $ff, $9f, $7f, $1f, $5f, $bf, $ff
pf_40x40_credits_p5:
	dc.b $00, $00, $00, $cc, $6c, $3c, $1c, $3d
	dc.b $59, $99, $18, $00, $00, $01, $01, $00
	dc.b $01, $01, $00, $00, $ff, $ff, $d7, $c7
	dc.b $86, $a6, $a2, $aa, $aa, $ba, $b2, $92
	dc.b $92, $ff, $ff, $ff, $ff, $ff, $ff, $ff
pf_40x40_credits_ptr:
	dc.w pf_40x40_credits_p0
	dc.w pf_40x40_credits_p1
	dc.w pf_40x40_credits_p2
	dc.w pf_40x40_credits_p3
	dc.w pf_40x40_credits_p4
	dc.w pf_40x40_credits_p5
