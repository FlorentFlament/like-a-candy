INCDIRS=inc src
DFLAGS=$(patsubst %,-I%,$(INCDIRS)) -f3 -d

# asm files
SRC=$(wildcard src/*.asm)

all: main.bin

main.bin: src/main.asm $(SRC)
	dasm $< -o$@ -lmain.lst -smain.sym $(DFLAGS)

run: main.bin
	stella $<

clean:
	rm -f main.bin main.lst main.sym
