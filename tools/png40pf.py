#!/usr/bin/env python3
# Based on m/tools/png2logo.py

# This script converts a Black and White 40x40 picture from png format
# to dasm format; to be used for Atari VCS 2600 demos.

from os.path import basename
import sys
import argparse

from PIL import Image

import asmlib
from imglib import *

def sanity_check(im):
    """Checks that the image has the appropriate format:
    * width is a multiple of 8

    """
    w,h = im.size
    msg = None
    if w%8 != 0:
        msg = "Image width is not a multiple of 8: {}".format(w)
    if msg:
        raise BadImageException(msg)

def playfields(l):
    pfs = []
    pfs.append(list(reversed(l[0:4])) + 4*[False])
    pfs.append(l[4:12])
    pfs.append(list(reversed(l[12:20])))
    pfs.append(list(reversed(l[20:24])) + 4*[False])
    pfs.append(l[24:32])
    pfs.append(list(reversed(l[32:40])))
    return flatten(pfs)

def main():
    parser = argparse.ArgumentParser(description="Converts a black and white png image to dasm data usable by an Atari 2600 program.")
    parser.add_argument("fname", type=str, help="Path to png image file")
    parser.add_argument("-c", "--compact", action="store_true", help="Prints output data in a compact form")
    parser.add_argument("-r", "--revert", action="store_true", help="Reverts the black and white")
    args = parser.parse_args()

    fname = args.fname
    compact = args.compact
    revert = args.revert
    # Convert to 1 byte in {0,255} per pixel
    im   = Image.open(fname)

    # Beware im.convert('1') seems to introduce bugs !
    # To be troubleshooted and fixed upstream !
    # In the mean time using im.convert('L') instead
    grey = im.convert('L')
    sanity_check(grey)
    arr   = bool_array(grey)
    lines = [arr[i:i+40] for i in range(0, len(arr), 40)]
    pfs   = [playfields(l) for l in lines]
    pack  = pack_bytes(flatten(pfs))
    if revert:
        pack = [~v & 0xff for v in pack]
    img_name = basename(fname).split(".")[0].replace("-","_")
    if compact:
        print(f"pf_{img_name}:")
        print(asmlib.lst2asm(pack, 6))
    else:
        for i in range(6): # 6 platfield registers
            pack_pfs = reversed(pack[i:40*6:6]) # 40 lines
            # Beware: reversing the lines to display them from end to start in Atari code
            # There's a little gain of doing that.
            print(f"pf_{img_name}_p{i}:")
            print(asmlib.lst2asm(pack_pfs, 8))
        # Print pointers
        print(f"pf_{img_name}_ptr:")
        for i in range(6):
            print(f"\tdc.w pf_{img_name}_p{i}")

if __name__ == "__main__":
    main()
