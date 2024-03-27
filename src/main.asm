;;;-----------------------------------------------------------------------------
;;; Header

	PROCESSOR 6502
	INCLUDE "vcs.h"		; Provides RIOT & TIA memory map
	INCLUDE "macro.h"	; This file includes some helper macros
        INCLUDE "all_constants.asm"

;;;-----------------------------------------------------------------------------
;;; RAM segment
	SEG.U   ram
	ORG     $0080
RAM_START equ *
        INCLUDE "all_variables.asm"
        echo "Used RAM:", (* - RAM_START)d, "bytes"

;;;-----------------------------------------------------------------------------
;;; Code segment
	SEG code
	ORG $F000

DATA_START equ *
        INCLUDE "all_data.asm"
        echo "DATA size:", (* - DATA_START)d, "bytes"

CODE_START equ *
        INCLUDE "all_code.asm"

init:   CLEAN_START		; Initializes Registers & Memory
        jsr main_init

main_loop:	SUBROUTINE
	VERTICAL_SYNC		; 4 scanlines Vertical Sync signal

    MAC WAIT_TIMINT
.wait_timint
	lda TIMINT
	beq .wait_timint
        sta WSYNC
    ENDM

.vblank:
;;; 64 vblank scanlines
	lda #75
	sta TIM64T
        jsr main_vblank
	WAIT_TIMINT

.kernel:
;;; 203 kernal scanlines
	lda #15
	sta T1024T
        jsr main_kernel
	WAIT_TIMINT

.overscan:
;;; 45 overscan scanlines (inc. vertical sync)
	lda #48
	sta TIM64T
        jsr main_overscan
	WAIT_TIMINT

	jmp main_loop

	echo "CODE size:", (* - CODE_START)d, "bytes"
	echo "Used ROM:", (* - $F000)d, "bytes"
	echo "Remaining ROM:", ($FFFC - *)d, "bytes"

;;;-----------------------------------------------------------------------------
;;; Reset Vector
	SEG reset
	ORG $FFFC
	DC.W init
	DC.W init
