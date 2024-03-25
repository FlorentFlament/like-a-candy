sp_bonhomme_1_bw_16x16_0:
        dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $1b, $0d, $0d, $06, $06, $0f, $0f, $0f
	dc.b $0f, $3f, $7f, $4f, $03, $03, $03, $03
sp_bonhomme_1_bw_16x16_1:
        dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $00, $80, $80, $c0, $c0, $e0, $e0, $e0
	dc.b $e0, $f8, $fc, $e4, $80, $80, $80, $80
sp_bonhomme_2_bw_16x16_0:
        dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $01, $03, $03, $06, $06, $0f, $0f, $0f
	dc.b $4f, $7f, $3f, $0f, $03, $03, $03, $03
sp_bonhomme_2_bw_16x16_1:
        dc.b $00, $00, $00, $00, $00, $00, $00, $00
	dc.b $b0, $60, $60, $c0, $c0, $e0, $e0, $e0
	dc.b $e4, $fc, $f8, $e0, $80, $80, $80, $80
dance_color_1:
        dc.b $00, $00, $00, $00, $00, $00, $00, $00
        dc.b $fe, $5a, $fe, $fe, $fe, $fe, $fe, $fe
        dc.b $fe, $fe, $fe, $fe, $fe, $fe, $5a, $fe
dance_color_2:
        dc.b $00, $00, $00, $00, $00, $00, $00, $00
        dc.b $00, $5a, $00, $00, $00, $00, $00, $00
        dc.b $00, $00, $00, $00, $00, $00, $5a, $00
dance_color_3:
        dc.b $00, $00, $00, $00, $00, $00, $00, $00
        dc.b $fe, $2a, $fe, $fe, $fe, $fe, $fe, $fe
        dc.b $fe, $fe, $fe, $fe, $fe, $fe, $2a, $fe
dance_color_4:
        dc.b $00, $00, $00, $00, $00, $00, $00, $00
        dc.b $00, $2a, $00, $00, $00, $00, $00, $00
        dc.b $00, $00, $00, $00, $00, $00, $2a, $00
padding:
        dc.b $00, $00, $00, $00, $00, $00, $00, $00
background_color:
        dc.b $00, $fe, $00, $fe

sp1_bonhomme_low:
        dc.b <sp_bonhomme_1_bw_16x16_0
        dc.b <sp_bonhomme_2_bw_16x16_0
sp1_bonhomme_high:
        dc.b >sp_bonhomme_1_bw_16x16_0
        dc.b >sp_bonhomme_2_bw_16x16_0
sp2_bonhomme_low:
        dc.b <sp_bonhomme_1_bw_16x16_1
        dc.b <sp_bonhomme_2_bw_16x16_1
sp2_bonhomme_high:
        dc.b >sp_bonhomme_1_bw_16x16_1
        dc.b >sp_bonhomme_2_bw_16x16_1
dance_color_low:
        dc.b <dance_color_1
        dc.b <dance_color_2
        dc.b <dance_color_3
        dc.b <dance_color_4
dance_color_high:
        dc.b >dance_color_1
        dc.b >dance_color_2
        dc.b >dance_color_3
        dc.b >dance_color_4

dance_sintable:
	dc.b $1c, $1d, $1e, $20, $21, $22, $23, $25
	dc.b $26, $27, $28, $2a, $2b, $2c, $2d, $2e
	dc.b $2f, $30, $31, $32, $32, $33, $34, $34
	dc.b $35, $35, $36, $36, $36, $37, $37, $37
	dc.b $37, $37, $37, $37, $36, $36, $36, $35
	dc.b $35, $34, $34, $33, $32, $32, $31, $30
	dc.b $2f, $2e, $2d, $2c, $2b, $2a, $28, $27
	dc.b $26, $25, $23, $22, $21, $20, $1e, $1d
	dc.b $1c, $1a, $19, $17, $16, $15, $14, $12
	dc.b $11, $10, $0f, $0d, $0c, $0b, $0a, $09
	dc.b $08, $07, $06, $05, $05, $04, $03, $03
	dc.b $02, $02, $01, $01, $01, $00, $00, $00
	dc.b $00, $00, $00, $00, $01, $01, $01, $02
	dc.b $02, $03, $03, $04, $05, $05, $06, $07
	dc.b $08, $09, $0a, $0b, $0c, $0d, $0f, $10
	dc.b $11, $12, $14, $15, $16, $17, $19, $1a
