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

; Song author: Glafouk
; Song name: BamBamHacko

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
        dc.b $06, $0c, $04, $04, $0c


; Instrument Attack/Decay start indexes into ADSR tables.
tt_InsADIndexes:
        dc.b $00, $04, $10, $16, $16


; Instrument Sustain start indexes into ADSR tables
tt_InsSustainIndexes:
        dc.b $00, $0c, $12, $1a, $1a


; Instrument Release start indexes into ADSR tables
; Caution: Values are stored with an implicit -1 modifier! To get the
; real index, add 1.
tt_InsReleaseIndexes:
        dc.b $01, $0d, $13, $1d, $1d


; AUDVx and AUDFx ADSR envelope values.
; Each byte encodes the frequency and volume:
; - Bits 7..4: Freqency modifier for the current note ([-8..7]),
;       8 means no change. Bit 7 is the sign bit.
; - Bits 3..0: Volume
; Between sustain and release is one byte that is not used and
; can be any value.
; The end of the release phase is encoded by a 0.
tt_InsFreqVolTable:
; 0: bass
        dc.b $8b, $00, $8b, $00
; 1: Toututi
        dc.b $88, $87, $86, $85, $84, $83, $82, $81
        dc.b $80, $00, $80, $00
; 2: HighBeep
        dc.b $83, $83, $80, $00, $80, $00
; 3+4: Lead
        dc.b $82, $86, $82, $85, $82, $85, $82, $00
        dc.b $80, $00



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
        dc.b $01, $05, $09


; The AUDF frequency values for the percussion instruments.
; If the second to last value is negative (>=128), it means it's an
; "overlay" percussion, i.e. the player fetches the next instrument note
; immediately and starts it in the sustain phase next frame. (Needs
; TT_USE_OVERLAY)
tt_PercFreqTable:
; 0: KickShort
        dc.b $05, $09, $8c, $00
; 1: HiHat
        dc.b $00, $02, $01, $00
; 2: SnareShort
        dc.b $05, $1c, $08, $02, $01, $82, $00


; The AUDCx and AUDVx volume values for the percussion instruments.
; - Bits 7..4: AUDC value
; - Bits 3..0: AUDV value
; 0 means end of percussion data.
tt_PercCtrlVolTable:
; 0: KickShort
        dc.b $6f, $6d, $69, $00
; 1: HiHat
        dc.b $82, $82, $81, $00
; 2: SnareShort
        dc.b $8f, $cf, $6e, $8b, $87, $84, $00


        
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

; K+B0a
tt_pattern0:
        dc.b $11, $3b, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $10, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $00

; K+B0a+Mel0a
tt_pattern1:
        dc.b $11, $3b, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $53, $08
        dc.b $4e, $08, $08, $08, $53, $08, $51, $08
        dc.b $08, $08, $51, $08, $57, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $00

; K+B0a+Mel0b
tt_pattern2:
        dc.b $11, $3b, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $53, $08
        dc.b $4e, $08, $08, $08, $53, $08, $51, $08
        dc.b $08, $08, $51, $08, $4e, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $00

; K+B0a+Mel0c
tt_pattern3:
        dc.b $11, $3b, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $4e, $08
        dc.b $51, $08, $08, $08, $53, $08, $53, $08
        dc.b $08, $08, $51, $08, $4e, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $00

; K+B0a+Mel0d
tt_pattern4:
        dc.b $11, $3b, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $4e, $08
        dc.b $4b, $08, $08, $08, $53, $08, $53, $08
        dc.b $08, $08, $51, $08, $57, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $00

; K+B0b+Mel0b
tt_pattern5:
        dc.b $11, $34, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $53, $08
        dc.b $4e, $08, $08, $08, $53, $08, $51, $08
        dc.b $08, $08, $51, $08, $4e, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $00

; K+B0b+Mel0a
tt_pattern6:
        dc.b $11, $36, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $53, $08
        dc.b $4e, $08, $08, $08, $53, $08, $51, $08
        dc.b $08, $08, $51, $08, $57, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $00

; K+B0b+Mel0c
tt_pattern7:
        dc.b $11, $3e, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $3b, $08
        dc.b $08, $08, $08, $08, $08, $08, $4e, $08
        dc.b $51, $08, $08, $08, $53, $08, $53, $08
        dc.b $08, $08, $51, $08, $4e, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $00

; K+B0b+Mel0d
tt_pattern8:
        dc.b $11, $3b, $08, $08, $34, $08, $08, $08
        dc.b $08, $08, $36, $08, $08, $08, $08, $08
        dc.b $3b, $08, $3e, $08, $08, $08, $4e, $08
        dc.b $4b, $08, $08, $08, $53, $08, $53, $08
        dc.b $08, $08, $51, $08, $57, $08, $08, $08
        dc.b $3b, $08, $08, $08, $34, $08, $36, $08
        dc.b $00

; K+B0a+Mel1a
tt_pattern9:
        dc.b $11, $3b, $08, $08, $7a, $3b, $75, $3b
        dc.b $71, $3b, $73, $3b, $6e, $3b, $71, $3b
        dc.b $08, $08, $08, $08, $08, $08, $b7, $08
        dc.b $bd, $08, $08, $08, $68, $08, $6b, $08
        dc.b $ba, $08, $08, $08, $b3, $08, $08, $08
        dc.b $69, $08, $69, $08, $69, $08, $08, $08
        dc.b $00

; K+B0b+Mel1a
tt_pattern10:
        dc.b $11, $36, $08, $08, $7a, $36, $75, $36
        dc.b $71, $36, $73, $36, $6e, $36, $71, $36
        dc.b $08, $08, $08, $08, $08, $08, $b7, $08
        dc.b $bd, $08, $08, $08, $68, $08, $6b, $08
        dc.b $ba, $08, $08, $08, $b3, $08, $08, $08
        dc.b $69, $08, $69, $08, $69, $08, $08, $08
        dc.b $00

; K+B0c+Mel1a
tt_pattern11:
        dc.b $11, $34, $08, $08, $7a, $34, $75, $34
        dc.b $71, $34, $73, $34, $6e, $34, $71, $34
        dc.b $08, $08, $08, $08, $08, $08, $b7, $08
        dc.b $bd, $08, $08, $08, $68, $08, $6b, $08
        dc.b $ba, $08, $08, $08, $b3, $08, $08, $08
        dc.b $69, $08, $69, $08, $69, $08, $08, $08
        dc.b $00

; K+B0d+Mel1a
tt_pattern12:
        dc.b $11, $3e, $08, $08, $7a, $3e, $75, $3e
        dc.b $71, $3b, $73, $3b, $6e, $3b, $71, $3b
        dc.b $08, $08, $08, $08, $08, $08, $b7, $08
        dc.b $bd, $08, $08, $08, $6b, $08, $6a, $08
        dc.b $ba, $08, $08, $08, $b3, $08, $08, $08
        dc.b $68, $08, $6b, $08, $69, $08, $08, $08
        dc.b $00

; K+B0a+Mel2a
tt_pattern13:
        dc.b $11, $3b, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $75, $08
        dc.b $73, $08, $08, $08, $7d, $08, $08, $08
        dc.b $75, $08, $08, $08, $7a, $08, $08, $08
        dc.b $b1, $08, $08, $08, $b3, $08, $08, $08
        dc.b $00

; K+B0a+Mel2b
tt_pattern14:
        dc.b $11, $3b, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $75, $08
        dc.b $73, $08, $08, $08, $7d, $08, $08, $08
        dc.b $75, $08, $08, $08, $7a, $08, $08, $08
        dc.b $ae, $08, $08, $08, $b1, $08, $08, $08
        dc.b $00

; K+B0a+Mel2c
tt_pattern15:
        dc.b $11, $3b, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $75, $08
        dc.b $73, $08, $08, $08, $7d, $08, $08, $08
        dc.b $75, $08, $08, $08, $7a, $08, $08, $08
        dc.b $ba, $08, $08, $08, $b7, $08, $08, $08
        dc.b $00

; K+B0a+Mel2d
tt_pattern16:
        dc.b $11, $3b, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $75, $08
        dc.b $73, $08, $08, $08, $7d, $08, $08, $08
        dc.b $75, $08, $08, $08, $7a, $08, $08, $08
        dc.b $b3, $08, $08, $08, $bd, $08, $08, $08
        dc.b $00

; vide
tt_pattern17:
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $00

; HH0a
tt_pattern18:
        dc.b $08, $08, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $12, $08, $08, $08, $08, $08
        dc.b $00

; HH0c
tt_pattern19:
        dc.b $08, $08, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $12, $08, $12, $08, $08, $08
        dc.b $08, $08, $12, $12, $12, $08, $12, $08
        dc.b $00

; HH0b
tt_pattern20:
        dc.b $08, $08, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $12, $08, $08, $08, $12, $08
        dc.b $00

; S+K0a
tt_pattern21:
        dc.b $08, $08, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $13, $08, $08, $08
        dc.b $08, $08, $12, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $08, $08, $11, $08
        dc.b $08, $08, $08, $08, $13, $08, $08, $08
        dc.b $08, $08, $12, $08, $08, $08, $12, $08
        dc.b $00

; S+K0b
tt_pattern22:
        dc.b $08, $08, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $13, $08, $08, $08
        dc.b $08, $08, $12, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $11, $08, $11, $08
        dc.b $08, $08, $08, $08, $13, $08, $08, $08
        dc.b $08, $08, $11, $08, $12, $08, $12, $08
        dc.b $00

; S+K0c
tt_pattern23:
        dc.b $08, $08, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $13, $08, $08, $08
        dc.b $08, $08, $12, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $11, $08, $11, $08
        dc.b $08, $08, $08, $08, $13, $08, $12, $12
        dc.b $12, $08, $11, $08, $12, $08, $13, $08
        dc.b $00

; S+K0d
tt_pattern24:
        dc.b $08, $08, $08, $08, $08, $08, $12, $08
        dc.b $08, $08, $08, $08, $08, $08, $08, $08
        dc.b $08, $08, $12, $08, $08, $08, $08, $08
        dc.b $08, $08, $08, $08, $11, $08, $11, $08
        dc.b $08, $08, $08, $08, $13, $08, $12, $12
        dc.b $12, $08, $11, $08, $12, $08, $13, $08
        dc.b $00

; S+K0a+Mel0a
tt_pattern25:
        dc.b $9a, $08, $08, $08, $ab, $08, $12, $08
        dc.b $08, $08, $ae, $08, $13, $08, $08, $08
        dc.b $08, $08, $12, $08, $08, $08, $08, $08
        dc.b $9f, $08, $9d, $08, $08, $08, $11, $08
        dc.b $08, $08, $9a, $08, $13, $08, $08, $08
        dc.b $95, $08, $12, $08, $08, $08, $12, $08
        dc.b $00

; S+K0b+Mel0a
tt_pattern26:
        dc.b $9a, $08, $08, $08, $ab, $08, $12, $08
        dc.b $08, $08, $ae, $08, $13, $08, $08, $08
        dc.b $b1, $08, $12, $08, $08, $08, $ab, $08
        dc.b $9d, $08, $08, $08, $11, $08, $11, $08
        dc.b $ae, $08, $ab, $08, $13, $08, $08, $08
        dc.b $9a, $08, $11, $08, $12, $08, $12, $08
        dc.b $00

; S+K0c+Mel0a
tt_pattern27:
        dc.b $9a, $08, $08, $08, $95, $08, $12, $08
        dc.b $08, $08, $9a, $08, $13, $08, $08, $08
        dc.b $ab, $08, $12, $08, $08, $08, $9f, $08
        dc.b $9d, $08, $08, $08, $11, $08, $11, $08
        dc.b $9a, $08, $9d, $08, $13, $08, $12, $12
        dc.b $12, $08, $11, $08, $12, $08, $13, $08
        dc.b $00

; S+K0c+Mel0b
tt_pattern28:
        dc.b $9a, $08, $08, $08, $91, $08, $12, $08
        dc.b $08, $08, $93, $08, $08, $08, $08, $08
        dc.b $95, $08, $12, $08, $08, $08, $9d, $08
        dc.b $9a, $08, $95, $08, $11, $08, $11, $08
        dc.b $9a, $08, $ab, $08, $13, $08, $12, $08
        dc.b $12, $08, $13, $08, $13, $08, $13, $08
        dc.b $00

; S+K0a+Mel1a
tt_pattern29:
        dc.b $91, $08, $6c, $08, $9a, $08, $12, $08
        dc.b $69, $08, $95, $08, $13, $08, $6e, $08
        dc.b $9d, $08, $12, $08, $6c, $08, $9d, $08
        dc.b $9a, $08, $68, $08, $95, $08, $11, $08
        dc.b $ab, $08, $9f, $08, $13, $08, $68, $08
        dc.b $91, $08, $12, $08, $69, $08, $12, $08
        dc.b $00

; S+K0b+Mel1b
tt_pattern30:
        dc.b $9d, $08, $6e, $08, $9a, $08, $12, $08
        dc.b $71, $08, $9a, $08, $13, $08, $6c, $08
        dc.b $9a, $08, $12, $08, $6a, $08, $9a, $08
        dc.b $91, $08, $6c, $08, $11, $08, $11, $08
        dc.b $9a, $08, $9d, $08, $13, $08, $69, $08
        dc.b $ab, $08, $11, $08, $12, $08, $12, $08
        dc.b $00

; S+K0c+mel1a
tt_pattern31:
        dc.b $9a, $08, $69, $08, $9d, $08, $12, $08
        dc.b $68, $08, $95, $08, $13, $08, $6e, $08
        dc.b $93, $08, $12, $08, $6a, $08, $9d, $08
        dc.b $9a, $08, $93, $08, $11, $08, $11, $08
        dc.b $ab, $08, $9d, $08, $13, $08, $12, $12
        dc.b $12, $08, $11, $08, $12, $08, $13, $08
        dc.b $00

; S+K0c+mel1d
tt_pattern32:
        dc.b $95, $08, $69, $08, $93, $08, $12, $08
        dc.b $6a, $08, $91, $08, $08, $08, $6c, $08
        dc.b $9a, $08, $12, $08, $63, $64, $9d, $08
        dc.b $9a, $08, $69, $08, $11, $08, $11, $08
        dc.b $95, $08, $6e, $08, $13, $08, $12, $12
        dc.b $12, $08, $13, $08, $13, $08, $13, $08
        dc.b $00

; S+K0a+Mel2a
tt_pattern33:
        dc.b $b7, $08, $08, $08, $71, $08, $12, $08
        dc.b $08, $08, $71, $08, $13, $08, $b3, $08
        dc.b $08, $08, $12, $08, $7a, $08, $7a, $08
        dc.b $b1, $08, $08, $08, $73, $08, $11, $08
        dc.b $ba, $08, $7d, $08, $13, $08, $b3, $08
        dc.b $08, $08, $12, $08, $08, $08, $12, $08
        dc.b $00

; S+K0b+Mel2a
tt_pattern34:
        dc.b $b7, $08, $08, $08, $75, $08, $12, $08
        dc.b $08, $08, $73, $08, $13, $08, $b3, $08
        dc.b $08, $08, $12, $08, $6c, $08, $6e, $08
        dc.b $b3, $08, $b1, $08, $11, $08, $11, $08
        dc.b $71, $08, $9d, $08, $13, $08, $ab, $08
        dc.b $71, $08, $11, $08, $12, $08, $12, $08
        dc.b $00

; S+K0c+mel2a
tt_pattern35:
        dc.b $bd, $08, $08, $08, $6e, $08, $12, $08
        dc.b $08, $08, $71, $08, $13, $08, $ba, $08
        dc.b $7a, $08, $12, $08, $75, $08, $bd, $08
        dc.b $b7, $08, $b3, $08, $11, $08, $11, $08
        dc.b $ab, $08, $b7, $08, $13, $08, $12, $12
        dc.b $12, $08, $11, $08, $12, $08, $13, $08
        dc.b $00

; S+K0c+mel2b
tt_pattern36:
        dc.b $bd, $08, $08, $08, $7a, $08, $12, $08
        dc.b $08, $08, $b7, $08, $08, $08, $71, $08
        dc.b $b1, $08, $12, $08, $6e, $08, $ba, $08
        dc.b $b7, $08, $bd, $08, $11, $08, $11, $08
        dc.b $ba, $08, $68, $08, $13, $08, $12, $12
        dc.b $12, $08, $13, $08, $13, $08, $13, $08
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
        dc.b <tt_pattern32, <tt_pattern33, <tt_pattern34, <tt_pattern35
        dc.b <tt_pattern36
tt_PatternPtrHi:
        dc.b >tt_pattern0, >tt_pattern1, >tt_pattern2, >tt_pattern3
        dc.b >tt_pattern4, >tt_pattern5, >tt_pattern6, >tt_pattern7
        dc.b >tt_pattern8, >tt_pattern9, >tt_pattern10, >tt_pattern11
        dc.b >tt_pattern12, >tt_pattern13, >tt_pattern14, >tt_pattern15
        dc.b >tt_pattern16, >tt_pattern17, >tt_pattern18, >tt_pattern19
        dc.b >tt_pattern20, >tt_pattern21, >tt_pattern22, >tt_pattern23
        dc.b >tt_pattern24, >tt_pattern25, >tt_pattern26, >tt_pattern27
        dc.b >tt_pattern28, >tt_pattern29, >tt_pattern30, >tt_pattern31
        dc.b >tt_pattern32, >tt_pattern33, >tt_pattern34, >tt_pattern35
        dc.b >tt_pattern36        


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
        dc.b $00, $00, $00, $00, $01, $02, $01, $03
        dc.b $01, $02, $01, $04, $01, $02, $01, $03
        dc.b $01, $02, $01, $04, $01, $02, $01, $03
        dc.b $01, $02, $01, $04, $01, $05, $06, $07
        dc.b $01, $05, $06, $08, $01, $05, $06, $07
        dc.b $01, $05, $06, $08, $01, $01, $01, $07
        dc.b $01, $01, $01, $08, $09, $09, $0a, $0b
        dc.b $09, $09, $0a, $0c, $0d, $0e, $0d, $0f
        dc.b $0d, $0e, $0d, $10, $00, $00, $00, $00
        dc.b $11

        
        ; ---------- Channel 1 ----------
        dc.b $11, $11, $11, $11, $12, $12, $12, $13
        dc.b $12, $12, $12, $14, $12, $12, $12, $13
        dc.b $15, $16, $15, $17, $15, $16, $15, $18
        dc.b $15, $16, $15, $18, $19, $1a, $19, $1b
        dc.b $19, $1a, $19, $1c, $19, $1a, $19, $1b
        dc.b $19, $1a, $19, $1c, $1d, $1e, $1d, $1f
        dc.b $1d, $1e, $1d, $20, $21, $22, $21, $23
        dc.b $21, $22, $21, $24, $21, $22, $21, $23
        dc.b $21, $22, $21, $24, $15, $16, $15, $17
        dc.b $12, $12, $12, $14, $12, $12, $12, $13
        dc.b $11, $11, $11, $11, $11, $11, $11, $11
        dc.b $11


        echo "Track size: ", *-tt_TrackDataStart
