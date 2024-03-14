        INCLUDE "bambamhako_code.asm"
        INCLUDE "fx_playfield_code.asm"

;;; Music player wrapper
tia_player:   
        INCLUDE "tia_player.asm"
        rts

main_init:
        jsr bambamhako_init
        rts
        
main_vblank:
        jsr bambamhako_vblank
        rts

main_kernel:
        jsr bambamhako_kernel
        rts

main_overscan:
        rts
