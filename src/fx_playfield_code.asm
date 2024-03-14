fx_playfield_kernel:	SUBROUTINE
	;; Intialize colors
	lda #$fe
	sta COLUPF
	ldy #PF_LINES_COUNT-1   ; 40 lines. Y can be used to indirect fetch
.outer:
	ldx #PF_LINES_THICKNESS-1 ; 6 lines thick graphic lines (40 graphic lines)
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
