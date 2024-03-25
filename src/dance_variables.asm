beat_timer      ds.b    1       ; timer reseting to zero every beat
beat_cnt        ds.b    1       ; Increases each beat

dancebar_pos    ds.b    RASTERS_COUNT
dancebar_col    ds.b    RASTERS_COUNT

dance_bg        ds.b    SPRITE_LINES * 2
