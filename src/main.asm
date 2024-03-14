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

.vblank:
	; 34 VBlank lines (76 cycles/line)
	lda #39			; (/ (* 34.0 76) 64) = 40.375
	sta TIM64T
        jsr main_vblank
	jsr wait_timint

.kernel:
	; 248 Kernel lines
	lda #19			; (/ (* 248.0 76) 1024) = 18.40
	sta T1024T
        jsr main_kernel
	jsr wait_timint		; scanline 289 - cycle 30

.overscan:
	; 26 Overscan lines
	lda #22			; (/ (* 26.0 76) 64) = 30.875
	sta TIM64T
        jsr main_overscan
	jsr wait_timint

	jmp main_loop		; main_loop is far - scanline 308 - cycle 15

; X register must contain the number of scanlines to skip
; X register will have value 0 on exit
wait_timint:
	lda TIMINT
	beq wait_timint
	rts
	echo "CODE size:", (* - CODE_START)d, "bytes"
	echo "Used ROM:", (* - $F000)d, "bytes"
	echo "Remaining ROM:", ($FFFC - *)d, "bytes"

;;;-----------------------------------------------------------------------------
;;; Reset Vector
	SEG reset
	ORG $FFFC
	DC.W init
	DC.W init
