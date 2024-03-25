#!/usr/bin/env python3
import math
from asmlib import *

TABLE_LEN = 64
MAX_VAL = 21.0

data = [round(MAX_VAL/2*(1+math.sin(x * 2*math.pi / TABLE_LEN))) for x in range(0,TABLE_LEN)]
print(lst2asm(data))
