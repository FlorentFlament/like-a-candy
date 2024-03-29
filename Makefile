INCDIRS=inc src
DFLAGS=$(patsubst %,-I%,$(INCDIRS)) -f3 -d

# asm files
SRC=$(wildcard src/*.asm)

all: main-hw.bin main-emu.bin

main-emu.bin: src/main.asm $(SRC)
	dasm $< -o$@ -lmain.lst -smain.sym $(DFLAGS)

main-hw.bin: src/main.asm $(SRC)
	dasm $< -o$@ -lmain.lst -smain.sym $(DFLAGS) -DHARDWARE

run: main-emu.bin
	stella $<

clean:
	rm -f main-emu.bin main-hw.bin main.lst main.sym
