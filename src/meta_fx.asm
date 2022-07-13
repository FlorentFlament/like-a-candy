;;; Calls appropriate FX subroutines
;;; unique argument is the address to call (bg_vblanks, bg_kernels, bg_overscans)
;;; ex: call_current_background bg_vblanks
;;; current_fx is the id of the FX (starting from 0)
    MAC CALL_CURRENT_FX
	lda current_fx
	asl
	tax
	lda {1}+1,X
	pha
	lda {1},X
	pha
	rts
    ENDM

fx_init:	SUBROUTINE
	jsr fx_playfield_init
	jsr fx_sprite_init
	rts
	
meta_fx_init:	SUBROUTINE
	CALL_CURRENT_FX fx_inits
meta_fx_vblank:	SUBROUTINE
	CALL_CURRENT_FX fx_vblanks
meta_fx_kernel:	SUBROUTINE
	CALL_CURRENT_FX fx_kernels
meta_fx_call_overscan:	SUBROUTINE
	CALL_CURRENT_FX fx_overscans
meta_fx_overscan:	SUBROUTINE
	;; Additional indirection to perform some update before going back to main
	jsr meta_fx_call_overscan
	lda framecnt+1
	and #$01
	sta current_fx
	rts

;;; FXs pointers
fx_inits:
	.word fx_playfield_init - 1
	.word fx_sprite_init - 1
fx_vblanks:
	.word fx_playfield_vblank - 1
	.word fx_sprite_vblank - 1
fx_kernels:
	.word fx_playfield_kernel - 1
	.word fx_sprite_kernel - 1
fx_overscans:
	.word fx_playfield_overscan - 1
	.word fx_sprite_overscan - 1

