#!/usr/bin/env python3
import math

VBLANK_COMPUTE = 33 # scanlines
OVERSCAN_COMPUTE = 47 # scanlines (worst observed sort case)

CLOCKS_PER_LINE = 76

# PAL official timings:
# VBLANK   :  48 scanlines
# KERNAL   : 228 scanlines
# OVERSCAN :  36 scanlines
# TOTAL    : 312 scanlines
VERTICAL_SYNC = 4 # scanlines vertical sync signal
MIN_VBLANK = 47 # scanlines (+1 WSYNC added after each wait loop)
MIN_OVERSCAN = 35 - VERTICAL_SYNC # scanlines
TOTAL_SCANLINES = 312

# Possible timers resolution:
# TIM1T  : 1 clock interval
# TIM8T  : 8 clock interval
# TIM64T : 64 clock interval
# T1024T : 1024 clock interval
VBLANK_TIMER_RES = 64
OVERSCAN_TIMER_RES = 64
KERNAL_TIMER_RES = 64

def get_timer(scanlines_cnt, timer_res):
    timer = math.ceil(CLOCKS_PER_LINE * scanlines_cnt / timer_res)
    return (timer, scanlines_cnt+1)

def compute(vblank_cpu=0, overscan_cpu=0):
    vblank_timer, vblank_lines = get_timer(max(MIN_VBLANK, vblank_cpu), VBLANK_TIMER_RES)
    print(vblank_timer, vblank_lines)

    overscan_timer, overscan_lines = get_timer(max(MIN_OVERSCAN, overscan_cpu), OVERSCAN_TIMER_RES)
    print(overscan_timer, overscan_lines)

    kernal_lines_remain = TOTAL_SCANLINES - vblank_lines - overscan_lines - VERTICAL_SYNC - 1
    kernal_timer, kernal_lines = get_timer(kernal_lines_remain, KERNAL_TIMER_RES)
    print(kernal_timer, kernal_lines)

    print(f";;; {vblank_lines} vblank scanlines")
    print(f"\tlda #{vblank_timer}")
    print("\tsta TIM64T")
    print()
    print(f";;; {kernal_lines} kernal scanlines")
    print(f"\tlda #{kernal_timer}")
    print("\tsta TIM64T")
    print()
    print(f";;; {overscan_lines}+{VERTICAL_SYNC} overscan scanlines (+ vertical sync)")
    print(f"\tlda #{overscan_timer}")
    print("\tsta TIM64T")

compute(VBLANK_COMPUTE, OVERSCAN_COMPUTE)
