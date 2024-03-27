#!/usr/bin/env python3
import math

VBLANK_COMPUTE = 63 # 61 scanlines in Stella
OVERSCAN_COMPUTE = 19 # 17 scanlines in Stella

CLOCKS_PER_LINE = 76

# PAL official timings:
# VBLANK   :  48 scanlines
# KERNAL   : 228 scanlines
# OVERSCAN :  36 scanlines
# TOTAL    : 312 scanlines
VERTICAL_SYNC = 4 # scanlines vertical sync signal
MIN_VBLANK = 48 # scanlines
MIN_OVERSCAN = 36 - VERTICAL_SYNC # scanlines
TOTAL_SCANLINES = 312

# Possible timers resolution:
# TIM1T  : 1 clock interval
# TIM8T  : 8 clock interval
# TIM64T : 64 clock interval
# T1024T : 1024 clock interval
VBLANK_TIMER_RES = 64
OVERSCAN_TIMER_RES = 64
KERNAL_TIMER_RES = 1024

def compute(vblank_cpu=0, overscan_cpu=0):
    vblank_clocks = CLOCKS_PER_LINE * max(MIN_VBLANK, vblank_cpu)
    vblank_timer = math.ceil(vblank_clocks / VBLANK_TIMER_RES)
    vblank_lines = math.ceil((vblank_timer * VBLANK_TIMER_RES) / CLOCKS_PER_LINE)

    overscan_clocks = CLOCKS_PER_LINE * max(MIN_OVERSCAN, overscan_cpu)
    overscan_timer = math.ceil(overscan_clocks / OVERSCAN_TIMER_RES)
    overscan_lines = math.ceil((overscan_timer * OVERSCAN_TIMER_RES) / CLOCKS_PER_LINE)

    kernal_lines_total = TOTAL_SCANLINES - vblank_lines - overscan_lines - VERTICAL_SYNC
    kernal_clocks = CLOCKS_PER_LINE * kernal_lines_total
    kernal_timer = math.floor(kernal_clocks / KERNAL_TIMER_RES)
    kernal_lines_timer = math.ceil((kernal_timer * KERNAL_TIMER_RES) / CLOCKS_PER_LINE)
    kernal_lines_diff = kernal_lines_total - kernal_lines_timer

    # Recomputing overscan clocks, adding missing scanlines
    overscan_clocks = CLOCKS_PER_LINE * (max(MIN_OVERSCAN, overscan_cpu) + kernal_lines_diff)
    overscan_timer = math.floor(overscan_clocks / OVERSCAN_TIMER_RES)
    overscan_lines = math.ceil((overscan_timer * OVERSCAN_TIMER_RES) / CLOCKS_PER_LINE)

    print(f";;; {vblank_lines} vblank scanlines")
    print(f"\tlda #{vblank_timer}")
    print("\tsta TIM64T")
    print()
    print(f";;; {kernal_lines_timer} kernal scanlines")
    print(f"\tlda #{kernal_timer}")
    print("\tsta T1024T")
    print()
    print(f";;; {overscan_lines + VERTICAL_SYNC} overscan scanlines (inc. vertical sync)")
    print(f"\tlda #{overscan_timer}")
    print("\tsta TIM64T")
    
compute(VBLANK_COMPUTE, OVERSCAN_COMPUTE)
