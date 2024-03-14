; TIATracker music player
; Copyright 2016 Andre "Kylearan" Wichmann
; Website: https://bitbucket.org/kylearan/tiatracker
; Email: andre.wichmann@gmx.de
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;   http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

; Song author: 
; Song name: 

; @com.wudsn.ide.asm.hardware=ATARI2600

; =====================================================================
; TIATracker melodic and percussion instruments, patterns and sequencer
; data.
; =====================================================================
tt_TrackDataStart:

; =====================================================================
; Melodic instrument definitions (up to 7). tt_envelope_index_c0/1 hold
; the index values into these tables for the current instruments played
; in channel 0 and 1.
; 
; Each instrument is defined by:
; - tt_InsCtrlTable: the AUDC value
; - tt_InsADIndexes: the index of the start of the ADSR envelope as
;       defined in tt_InsFreqVolTable
; - tt_InsSustainIndexes: the index of the start of the Sustain phase
;       of the envelope
; - tt_InsReleaseIndexes: the index of the start of the Release phase
; - tt_InsFreqVolTable: The AUDF frequency and AUDV volume values of
;       the envelope
; =====================================================================

; Instrument master CTRL values
tt_InsCtrlTable:
        dc.b $0c, $04, $0c, $04, $0c, $04, $0c


; Instrument Attack/Decay start indexes into ADSR tables.
tt_InsADIndexes:
        dc.b $00, $07, $07, $1a, $1a, $22, $2a


; Instrument Sustain start indexes into ADSR tables
tt_InsSustainIndexes:
        dc.b $03, $16, $16, $1e, $1e, $26, $32


; Instrument Release start indexes into ADSR tables
; Caution: Values are stored with an implicit -1 modifier! To get the
; real index, add 1.
tt_InsReleaseIndexes:
        dc.b $04, $17, $17, $1f, $1f, $27, $33


; AUDVx and AUDFx ADSR envelope values.
; Each byte encodes the frequency and volume:
; - Bits 7..4: Freqency modifier for the current note ([-8..7]),
;       8 means no change. Bit 7 is the sign bit.
; - Bits 3..0: Volume
; Between sustain and release is one byte that is not used and
; can be any value.
; The end of the release phase is encoded by a 0.
tt_InsFreqVolTable:
; 0: Tidou
        dc.b $82, $84, $86, $80, $00, $80, $00
; 1+2: Lead
        dc.b $89, $81, $88, $81, $87, $81, $86, $81
        dc.b $85, $81, $84, $81, $83, $81, $82, $80
        dc.b $00, $80, $00
; 3+4: Lead2
        dc.b $85, $85, $85, $85, $81, $00, $80, $00
; 5: NewLead
        dc.b $86, $74, $83, $71, $80, $00, $80, $00
; 6: Dakatoum
        dc.b $89, $56, $38, $65, $86, $a3, $d4, $a1
        dc.b $80, $00, $80, $00



; =====================================================================
; Percussion instrument definitions (up to 15)
;
; Each percussion instrument is defined by:
; - tt_PercIndexes: The index of the first percussion frame as defined
;       in tt_PercFreqTable and tt_PercCtrlVolTable
; - tt_PercFreqTable: The AUDF frequency value
; - tt_PercCtrlVolTable: The AUDV volume and AUDC values
; =====================================================================

; Indexes into percussion definitions signifying the first frame for
; each percussion in tt_PercFreqTable.
; Caution: Values are stored with an implicit +1 modifier! To get the
; real index, subtract 1.
tt_PercIndexes:
        dc.b $01, $19, $31, $37, $3e, $49, $54, $5f
        dc.b $6a, $72


; The AUDF frequency values for the percussion instruments.
; If the second to last value is negative (>=128), it means it's an
; "overlay" percussion, i.e. the player fetches the next instrument note
; immediately and starts it in the sustain phase next frame. (Needs
; TT_USE_OVERLAY)
tt_PercFreqTable:
; 0: BassA
        dc.b $19, $19, $19, $19, $19, $19, $19, $19
        dc.b $19, $19, $19, $19, $19, $19, $19, $19
        dc.b $19, $19, $19, $19, $19, $19, $19, $00
; 1: BassB
        dc.b $16, $16, $16, $16, $16, $16, $16, $16
        dc.b $16, $16, $16, $16, $16, $16, $16, $16
        dc.b $16, $16, $16, $16, $16, $16, $16, $00
; 2: KickShort
        dc.b $05, $09, $0c, $0f, $19, $00
; 3: SnareShort
        dc.b $05, $1c, $08, $02, $01, $82, $00
; 4: BassTwing1
        dc.b $05, $03, $05, $03, $05, $03, $05, $03
        dc.b $05, $05, $00
; 5: BassTwing2
        dc.b $04, $03, $04, $03, $04, $03, $04, $03
        dc.b $04, $03, $00
; 6: BassTwing3
        dc.b $03, $02, $03, $02, $03, $02, $03, $02
        dc.b $03, $03, $00
; 7: BassTwing4
        dc.b $08, $07, $08, $07, $08, $07, $08, $07
        dc.b $08, $08, $00
; 8: BeepA
        dc.b $09, $09, $09, $09, $09, $09, $09, $00
; 9: BeepB
        dc.b $0e, $0e, $0e, $0e, $0e, $0e, $0e, $00


; The AUDCx and AUDVx volume values for the percussion instruments.
; - Bits 7..4: AUDC value
; - Bits 3..0: AUDV value
; 0 means end of percussion data.
tt_PercCtrlVolTable:
; 0: BassA
        dc.b $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b
        dc.b $6a, $67, $64, $63, $63, $63, $63, $63
        dc.b $63, $62, $62, $61, $61, $60, $60, $00
; 1: BassB
        dc.b $6b, $6b, $6b, $6b, $6b, $6b, $6b, $6b
        dc.b $6b, $6a, $67, $64, $63, $63, $63, $63
        dc.b $63, $62, $62, $61, $61, $60, $60, $00
; 2: KickShort
        dc.b $6f, $6d, $6b, $69, $61, $00
; 3: SnareShort
        dc.b $8f, $cf, $6e, $8b, $87, $84, $00
; 4: BassTwing1
        dc.b $19, $11, $16, $11, $14, $11, $13, $11
        dc.b $12, $10, $00
; 5: BassTwing2
        dc.b $19, $11, $13, $11, $13, $11, $13, $11
        dc.b $12, $10, $00
; 6: BassTwing3
        dc.b $19, $11, $13, $11, $13, $11, $13, $11
        dc.b $12, $10, $00
; 7: BassTwing4
        dc.b $19, $11, $13, $11, $13, $11, $13, $11
        dc.b $12, $10, $00
; 8: BeepA
        dc.b $cf, $cf, $cf, $ce, $cc, $c8, $c3, $00
; 9: BeepB
        dc.b $cf, $cf, $cf, $ce, $cc, $c8, $c3, $00


        
; =====================================================================
; Track definition
; The track is defined by:
; - tt_PatternX (X=0, 1, ...): Pattern definitions
; - tt_PatternPtrLo/Hi: Pointers to the tt_PatternX tables, serving
;       as index values
; - tt_SequenceTable: The order in which the patterns should be played,
;       i.e. indexes into tt_PatternPtrLo/Hi. Contains the sequences
;       for all channels and sub-tracks. The variables
;       tt_cur_pat_index_c0/1 hold an index into tt_SequenceTable for
;       each channel.
;
; So tt_SequenceTable holds indexes into tt_PatternPtrLo/Hi, which
; in turn point to pattern definitions (tt_PatternX) in which the notes
; to play are specified.
; =====================================================================

; ---------------------------------------------------------------------
; Pattern definitions, one table per pattern. tt_cur_note_index_c0/1
; hold the index values into these tables for the current pattern
; played in channel 0 and 1.
;
; A pattern is a sequence of notes (one byte per note) ending with a 0.
; A note can be either:
; - Pause: Put melodic instrument into release. Must only follow a
;       melodic instrument.
; - Hold: Continue to play last note (or silence). Default "empty" note.
; - Slide (needs TT_USE_SLIDE): Adjust frequency of last melodic note
;       by -7..+7 and keep playing it
; - Play new note with melodic instrument
; - Play new note with percussion instrument
; - End of pattern
;
; A note is defined by:
; - Bits 7..5: 1-7 means play melodic instrument 1-7 with a new note
;       and frequency in bits 4..0. If bits 7..5 are 0, bits 4..0 are
;       defined as:
;       - 0: End of pattern
;       - [1..15]: Slide -7..+7 (needs TT_USE_SLIDE)
;       - 8: Hold
;       - 16: Pause
;       - [17..31]: Play percussion instrument 1..15
;
; The tracker must ensure that a pause only follows a melodic
; instrument or a hold/slide.
; ---------------------------------------------------------------------
TT_FREQ_MASK    = %00011111
TT_INS_HOLD     = 8
TT_INS_PAUSE    = 16
TT_FIRST_PERC   = 17

; B0a
tt_pattern0:
        dc.b $11, $08, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $00

; B0a+D-intro
tt_pattern1:
        dc.b $13, $11, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $13, $08, $08
        dc.b $13, $08, $11, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $13, $08, $08
        dc.b $00

; B0a+D-intro2
tt_pattern2:
        dc.b $13, $11, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $13, $08, $08
        dc.b $13, $11, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $13, $08, $08, $13
        dc.b $08, $08, $14, $08, $08, $14, $08, $08
        dc.b $00

; B0a+D0a
tt_pattern3:
        dc.b $13, $11, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $14, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $13, $08, $08
        dc.b $13, $11, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $14, $08, $08, $08
        dc.b $08, $08, $13, $08, $08, $08, $08, $08
        dc.b $00

; B0a+D0b
tt_pattern4:
        dc.b $13, $11, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $14, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $13, $08, $08
        dc.b $13, $11, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $14, $08, $08, $08
        dc.b $08, $08, $13, $08, $08, $13, $08, $08
        dc.b $00

; B0a+D0c
tt_pattern5:
        dc.b $13, $11, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $14, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $13, $08, $08
        dc.b $13, $11, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $13, $08, $08
        dc.b $00

; B0a+D0a+TW0a
tt_pattern6:
        dc.b $13, $11, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $14, $08, $08, $15
        dc.b $08, $08, $16, $08, $08, $13, $08, $08
        dc.b $13, $11, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $14, $08, $08, $17
        dc.b $08, $08, $13, $08, $08, $16, $08, $08
        dc.b $00

; B0a+D0a+TW0b
tt_pattern7:
        dc.b $13, $11, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $14, $08, $08, $16
        dc.b $08, $08, $15, $08, $08, $13, $08, $08
        dc.b $13, $11, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $14, $08, $08, $18
        dc.b $08, $08, $13, $08, $08, $13, $15, $08
        dc.b $00

; B0a+D0b+TW0c
tt_pattern8:
        dc.b $13, $11, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $14, $08, $08, $18
        dc.b $08, $08, $15, $08, $08, $13, $08, $08
        dc.b $13, $11, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $15
        dc.b $08, $08, $18, $08, $08, $16, $08, $08
        dc.b $00

; vide
tt_pattern9:
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $00

; Mel0a-Intro
tt_pattern10:
        dc.b $08, $08, $08, $3d, $08, $08, $08, $08
        dc.b $08, $3d, $08, $08, $08, $08, $08, $3d
        dc.b $08, $08, $08, $08, $08, $3d, $08, $08
        dc.b $08, $08, $08, $3d, $08, $08, $08, $08
        dc.b $08, $3d, $08, $08, $08, $08, $08, $3d
        dc.b $08, $08, $38, $08, $08, $3d, $08, $08
        dc.b $00

; Mel0a
tt_pattern11:
        dc.b $08, $08, $08, $3d, $08, $08, $38, $08
        dc.b $08, $3d, $08, $08, $19, $08, $08, $3d
        dc.b $08, $08, $38, $08, $08, $3d, $08, $08
        dc.b $08, $08, $08, $3d, $08, $08, $38, $08
        dc.b $08, $3d, $08, $08, $1a, $08, $08, $3d
        dc.b $08, $08, $38, $08, $08, $3d, $08, $08
        dc.b $00

; Mel1a
tt_pattern12:
        dc.b $55, $08, $08, $3d, $08, $08, $58, $08
        dc.b $08, $5d, $08, $08, $19, $58, $08, $5d
        dc.b $08, $08, $38, $08, $08, $6a, $08, $08
        dc.b $35, $08, $08, $08, $6b, $08, $08, $08
        dc.b $08, $3d, $08, $1a, $6e, $08, $08, $3d
        dc.b $08, $08, $38, $08, $08, $3d, $08, $08
        dc.b $00

; Mel1b
tt_pattern13:
        dc.b $5d, $08, $08, $3d, $08, $08, $58, $08
        dc.b $08, $5d, $08, $08, $19, $55, $08, $58
        dc.b $08, $08, $38, $08, $08, $6a, $08, $08
        dc.b $35, $08, $08, $08, $6b, $08, $38, $08
        dc.b $08, $3d, $08, $08, $1a, $6e, $08, $3d
        dc.b $08, $08, $38, $08, $08, $3d, $08, $08
        dc.b $00

; Mel1c
tt_pattern14:
        dc.b $6a, $08, $08, $3d, $08, $08, $5d, $08
        dc.b $08, $58, $08, $08, $19, $55, $08, $58
        dc.b $08, $08, $38, $08, $08, $6a, $08, $08
        dc.b $35, $08, $08, $08, $5d, $08, $08, $08
        dc.b $08, $3d, $08, $08, $1a, $58, $08, $3d
        dc.b $08, $08, $38, $08, $08, $3d, $08, $08
        dc.b $00

; Mel1d
tt_pattern15:
        dc.b $6a, $08, $08, $3d, $08, $08, $5d, $08
        dc.b $08, $6a, $08, $08, $19, $6e, $08, $5d
        dc.b $08, $08, $38, $08, $08, $6a, $08, $08
        dc.b $35, $08, $08, $08, $5d, $08, $08, $08
        dc.b $08, $3d, $08, $08, $1a, $55, $08, $3d
        dc.b $08, $08, $52, $08, $08, $3d, $08, $08
        dc.b $00

; Mel1a+Beep0a
tt_pattern16:
        dc.b $55, $08, $b5, $b3, $08, $08, $58, $08
        dc.b $ae, $5d, $08, $b0, $19, $58, $b0, $5d
        dc.b $08, $08, $ae, $b3, $08, $6a, $08, $08
        dc.b $b0, $08, $08, $b3, $6b, $08, $08, $08
        dc.b $08, $b5, $08, $08, $1a, $6e, $08, $8e
        dc.b $08, $08, $90, $bd, $08, $95, $b8, $08
        dc.b $00

; Mel1b+Beep0b
tt_pattern17:
        dc.b $5d, $08, $bd, $3d, $08, $08, $58, $b8
        dc.b $08, $5d, $08, $08, $19, $55, $b3, $58
        dc.b $b5, $08, $38, $b3, $08, $6a, $08, $08
        dc.b $35, $b0, $08, $08, $6b, $b3, $38, $08
        dc.b $08, $3d, $b5, $08, $1a, $6e, $08, $90
        dc.b $08, $08, $8e, $bd, $08, $90, $b8, $08
        dc.b $00

; Mel1c+Beep0c
tt_pattern18:
        dc.b $6a, $08, $b5, $3d, $08, $08, $5d, $ae
        dc.b $08, $58, $b0, $08, $19, $55, $ae, $58
        dc.b $08, $08, $38, $b0, $08, $6a, $b8, $08
        dc.b $35, $b5, $08, $b3, $5d, $08, $b0, $08
        dc.b $08, $3d, $aa, $08, $1a, $58, $08, $8a
        dc.b $08, $08, $8a, $bd, $08, $8e, $b8, $08
        dc.b $00

; Mel1d+Beep0d
tt_pattern19:
        dc.b $6a, $08, $bd, $3d, $08, $08, $5d, $08
        dc.b $08, $6a, $b8, $08, $19, $6e, $b3, $5d
        dc.b $08, $08, $38, $b8, $08, $6a, $b5, $08
        dc.b $35, $b5, $08, $b0, $08, $08, $b5, $08
        dc.b $b3, $3d, $08, $08, $1a, $55, $08, $b8
        dc.b $08, $08, $95, $b5, $08, $92, $b8, $08
        dc.b $00

; Mel2a
tt_pattern20:
        dc.b $4a, $08, $08, $3d, $4e, $08, $38, $08
        dc.b $50, $3d, $08, $08, $19, $4e, $08, $3d
        dc.b $08, $52, $38, $08, $08, $3d, $50, $08
        dc.b $08, $55, $08, $08, $08, $08, $38, $08
        dc.b $08, $3d, $08, $08, $1a, $4e, $08, $3d
        dc.b $50, $08, $38, $50, $08, $3d, $4e, $08
        dc.b $00

; Mel2b
tt_pattern21:
        dc.b $55, $08, $08, $3d, $52, $08, $38, $08
        dc.b $50, $3d, $08, $08, $19, $4e, $08, $3d
        dc.b $08, $52, $38, $08, $08, $3d, $50, $08
        dc.b $08, $55, $08, $08, $08, $08, $38, $08
        dc.b $08, $3d, $08, $08, $1a, $50, $08, $3d
        dc.b $52, $08, $38, $08, $08, $3d, $4e, $08
        dc.b $00

; Mel2c
tt_pattern22:
        dc.b $52, $08, $08, $3d, $50, $08, $38, $08
        dc.b $4e, $3d, $08, $08, $19, $4a, $08, $3d
        dc.b $08, $4e, $38, $08, $08, $3d, $50, $08
        dc.b $08, $4e, $08, $08, $08, $08, $38, $08
        dc.b $08, $3d, $55, $08, $1a, $55, $08, $3d
        dc.b $50, $08, $38, $55, $08, $3d, $52, $08
        dc.b $00

; Mel2d
tt_pattern23:
        dc.b $58, $08, $08, $3d, $08, $55, $38, $08
        dc.b $08, $3d, $58, $08, $19, $5d, $08, $3d
        dc.b $6a, $08, $38, $08, $5d, $3d, $08, $08
        dc.b $55, $08, $08, $08, $08, $08, $38, $08
        dc.b $08, $3d, $08, $08, $1a, $50, $08, $3d
        dc.b $50, $08, $38, $52, $08, $3d, $08, $08
        dc.b $00

; Mel2a+Beep1a
tt_pattern24:
        dc.b $4a, $d5, $08, $b0, $4e, $08, $38, $d5
        dc.b $50, $3d, $08, $08, $19, $4e, $08, $3d
        dc.b $d5, $52, $38, $d5, $08, $3d, $50, $08
        dc.b $08, $55, $d2, $08, $08, $08, $38, $08
        dc.b $08, $3d, $dd, $08, $1a, $4e, $08, $3d
        dc.b $50, $08, $38, $50, $ce, $3d, $4e, $08
        dc.b $00

; Mel2b+Beep1b
tt_pattern25:
        dc.b $55, $d5, $08, $3d, $52, $08, $38, $d5
        dc.b $50, $3d, $08, $08, $19, $4e, $08, $3d
        dc.b $d5, $52, $38, $d5, $08, $3d, $50, $08
        dc.b $08, $d8, $08, $08, $08, $08, $38, $08
        dc.b $08, $dd, $08, $08, $1a, $50, $08, $3d
        dc.b $52, $08, $38, $d8, $d5, $3d, $d8, $08
        dc.b $00

; Mel2c+Beep1c
tt_pattern26:
        dc.b $52, $d5, $08, $3d, $50, $08, $38, $d5
        dc.b $4e, $3d, $08, $08, $19, $4a, $08, $08
        dc.b $d5, $4e, $38, $d5, $08, $3d, $50, $08
        dc.b $08, $4e, $d2, $08, $08, $08, $38, $08
        dc.b $08, $dd, $55, $08, $1a, $55, $08, $3d
        dc.b $50, $08, $38, $55, $d8, $3d, $52, $d0
        dc.b $00

; Mel2d+Beep1d
tt_pattern27:
        dc.b $58, $dd, $08, $3d, $08, $55, $38, $dd
        dc.b $08, $3d, $58, $08, $19, $5d, $08, $3d
        dc.b $6a, $d5, $38, $d2, $5d, $3d, $dd, $08
        dc.b $55, $08, $d5, $08, $08, $08, $38, $d8
        dc.b $08, $3d, $08, $08, $1a, $50, $08, $3d
        dc.b $50, $d8, $38, $52, $08, $3d, $d5, $08
        dc.b $00

; Mel3a
tt_pattern28:
        dc.b $73, $08, $08, $3d, $95, $08, $38, $70
        dc.b $08, $f3, $08, $aa, $19, $6e, $08, $3d
        dc.b $5d, $08, $38, $08, $08, $3d, $f3, $08
        dc.b $6a, $f0, $08, $3d, $08, $95, $38, $f8
        dc.b $08, $3d, $58, $08, $1a, $d0, $d0, $3d
        dc.b $5d, $d8, $38, $aa, $d5, $3d, $6e, $08
        dc.b $00

; Mel3b
tt_pattern29:
        dc.b $73, $08, $08, $3d, $aa, $08, $38, $70
        dc.b $08, $3d, $08, $b3, $19, $75, $08, $3d
        dc.b $73, $08, $38, $08, $08, $3d, $ee, $08
        dc.b $6e, $f5, $08, $3d, $08, $95, $38, $f8
        dc.b $08, $3d, $70, $08, $1a, $d5, $d5, $3d
        dc.b $58, $d8, $38, $92, $d5, $3d, $5d, $08
        dc.b $00

; Mel3c
tt_pattern30:
        dc.b $70, $08, $08, $3d, $98, $d2, $38, $70
        dc.b $08, $3d, $08, $ae, $19, $6e, $08, $3d
        dc.b $73, $08, $38, $08, $08, $3d, $ee, $08
        dc.b $75, $f8, $08, $3d, $73, $92, $38, $08
        dc.b $08, $3d, $78, $08, $1a, $f3, $f3, $3d
        dc.b $78, $d5, $38, $ae, $d5, $3d, $b5, $08
        dc.b $00

; Mel3d
tt_pattern31:
        dc.b $70, $08, $08, $3d, $6e, $d0, $38, $70
        dc.b $08, $3d, $08, $aa, $19, $73, $08, $3d
        dc.b $08, $08, $38, $08, $08, $3d, $e9, $08
        dc.b $58, $08, $08, $3d, $73, $6a, $38, $08
        dc.b $08, $3d, $5d, $08, $1a, $6e, $f3, $3d
        dc.b $08, $ca, $38, $90, $ee, $3d, $8a, $08
        dc.b $00

; Mel2a+Beep2a
tt_pattern32:
        dc.b $4a, $ef, $08, $3d, $4e, $08, $38, $08
        dc.b $50, $3d, $ee, $08, $19, $4e, $08, $3d
        dc.b $08, $52, $38, $d5, $d2, $3d, $50, $f3
        dc.b $08, $55, $ee, $08, $08, $f3, $38, $d8
        dc.b $d5, $3d, $ee, $08, $1a, $4e, $08, $3d
        dc.b $50, $08, $38, $50, $08, $3d, $4e, $08
        dc.b $00




; Individual pattern speeds (needs TT_GLOBAL_SPEED = 0).
; Each byte encodes the speed of one pattern in the order
; of the tt_PatternPtr tables below.
; If TT_USE_FUNKTEMPO is 1, then the low nibble encodes
; the even speed and the high nibble the odd speed.
    IF TT_GLOBAL_SPEED = 0
tt_PatternSpeeds:
%%PATTERNSPEEDS%%
    ENDIF


; ---------------------------------------------------------------------
; Pattern pointers look-up table.
; ---------------------------------------------------------------------
tt_PatternPtrLo:
        dc.b <tt_pattern0, <tt_pattern1, <tt_pattern2, <tt_pattern3
        dc.b <tt_pattern4, <tt_pattern5, <tt_pattern6, <tt_pattern7
        dc.b <tt_pattern8, <tt_pattern9, <tt_pattern10, <tt_pattern11
        dc.b <tt_pattern12, <tt_pattern13, <tt_pattern14, <tt_pattern15
        dc.b <tt_pattern16, <tt_pattern17, <tt_pattern18, <tt_pattern19
        dc.b <tt_pattern20, <tt_pattern21, <tt_pattern22, <tt_pattern23
        dc.b <tt_pattern24, <tt_pattern25, <tt_pattern26, <tt_pattern27
        dc.b <tt_pattern28, <tt_pattern29, <tt_pattern30, <tt_pattern31
        dc.b <tt_pattern32
tt_PatternPtrHi:
        dc.b >tt_pattern0, >tt_pattern1, >tt_pattern2, >tt_pattern3
        dc.b >tt_pattern4, >tt_pattern5, >tt_pattern6, >tt_pattern7
        dc.b >tt_pattern8, >tt_pattern9, >tt_pattern10, >tt_pattern11
        dc.b >tt_pattern12, >tt_pattern13, >tt_pattern14, >tt_pattern15
        dc.b >tt_pattern16, >tt_pattern17, >tt_pattern18, >tt_pattern19
        dc.b >tt_pattern20, >tt_pattern21, >tt_pattern22, >tt_pattern23
        dc.b >tt_pattern24, >tt_pattern25, >tt_pattern26, >tt_pattern27
        dc.b >tt_pattern28, >tt_pattern29, >tt_pattern30, >tt_pattern31
        dc.b >tt_pattern32        


; ---------------------------------------------------------------------
; Pattern sequence table. Each byte is an index into the
; tt_PatternPtrLo/Hi tables where the pointers to the pattern
; definitions can be found. When a pattern has been played completely,
; the next byte from this table is used to get the address of the next
; pattern to play. tt_cur_pat_index_c0/1 hold the current index values
; into this table for channels 0 and 1.
; If TT_USE_GOTO is used, a value >=128 denotes a goto to the pattern
; number encoded in bits 6..0 (i.e. value AND %01111111).
; ---------------------------------------------------------------------
tt_SequenceTable:
        ; ---------- Channel 0 ----------
        dc.b $00, $00, $00, $00, $00, $00, $00, $00
        dc.b $00, $00, $00, $00, $01, $02, $03, $04
        dc.b $03, $05, $06, $07, $06, $08, $06, $07
        dc.b $06, $08, $06, $07, $06, $08, $06, $07
        dc.b $06, $08, $06, $07, $06, $08, $06, $07
        dc.b $06, $08, $06, $07, $06, $08, $06, $07
        dc.b $06, $08, $06

        
        ; ---------- Channel 1 ----------
        dc.b $09, $09, $09, $09, $0a, $0a, $0b, $0b
        dc.b $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b
        dc.b $0b, $0b, $0c, $0d, $0e, $0f, $10, $11
        dc.b $12, $13, $14, $15, $16, $17, $18, $19
        dc.b $1a, $1b, $1c, $1d, $1c, $1e, $1c, $1d
        dc.b $1c, $1f, $14, $15, $16, $17, $20


        echo "Track size: ", *-tt_TrackDataStart
