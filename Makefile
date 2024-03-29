INCDIRS=inc src
DFLAGS=$(patsubst %,-I%,$(INCDIRS)) -f3 -d

# asm files
SRC=$(wildcard src/*.asm)

all: main-hw.bin main-emu.bin

main-emu.bin: src/main.asm $(SRC)
	dasm $< -o$@ -l$(patsubst %.bin,%,$@).lst -s$(patsubst %.bin,%,$@).sym $(DFLAGS)
main-hw.bin: src/main.asm $(SRC)
	dasm $< -o$@ -l$(patsubst %.bin,%,$@).lst -s$(patsubst %.bin,%,$@).sym $(DFLAGS) -DHARDWARE

run: main-emu.bin
	stella $<

clean:
	rm -f \
	main-emu.bin main-emu.lst main-emu.sym \
	main-hw.bin main-hw.lst main-hw.sym
