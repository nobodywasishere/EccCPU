# EccCPU - Error Correcting Code Central Processing Unit

This is an 8-bit CPU with hamming(16,11) instructions. It is meant as a proof-of-concept. It was designed with the minimum capability of calculating the Fibonacci sequence to 233, the maximum number in 8-bit representation.

`asm` contains example assembly code for the assembler. Currently it only contains the code for the Fibonacci sequence.

`ecccpu` contains the simulator and assembler for the CPU.

`hdl` contains the VHDL code for describing one example implementation of the CPU.

## Design

The CPU was designed with 4 8-bit registers, 16 8-bit slots of RAM, and a limit of 256 16-bit instructions. It has 15 instructions in total. The basic instructions are in the table below.

| instr.        | operation                      | mach. code      | flag |
|:-------------:|:------------------------------:|:---------------:|:----:|
| `NOP`         | No operation                   | `000_XXXX_XXXX` |      |
| `AND RR SS`   | And S and R, store in R        | `001_0000_RRSS` |   x  |
| `OR  RR SS`   | Or S and R, store in R         | `001_0001_RRSS` |   x  |
| `ADD RR SS`   | Add R to S, store in R         | `001_0010_RRSS` |   x  |
| `SUB RR SS`   | Sub S from R, store in R       | `001_0011_RRSS` |   x  |
| `INC RR`      | Increment R                    | `001_0100_RR00` |   x  |
| `DEC RR`      | Decrement R                    | `001_0101_RR00` |   x  |
| `CMP RR SS`   | Compare R with S               | `001_1000_RRSS` |   x  |
| `LDD RR DD`   | Load from data D into R        | `010_DDDD_00RR` |      |
| `LDR RR SS`   | Load from D based on S into R  | `010_00SS_01RR` |      |
| `STD RR DD`   | Store R in data D              | `010_DDDD_10RR` |      |
| `STR RR SS`   | Store R in addr by 4 bits of S | `010_00SS_11RR` |      |
| `JMP RR`      | Jump to address in R           | `011_0000_00RR` |      |
| `JMP RR CC`   | Jump to address in R if C      | `011_CCCC_00RR` |      |
| `LDI RR VV`   | Load immediate V into R        | `1RR_VVVV_VVVV` |      |

These are the values given to JMP for a conditional jump.

| CMP | CCCC | int |
|:---:|:----:|:---:|
| any         | `0000` |  0 |
| zero        | `0001` |  1 |
| negative    | `0010` |  2 |
| carry       | `0011` |  3 |
| >  (unsign) | `0100` |  4 |
| <  (unsign) | `0101` |  5 |
| >= (unsign) | `0110` |  6 |
| <= (unsign) | `0111` |  7 |
| =           | `1000` |  8 |
| >  (signed) | `1100` | 12 |
| <  (signed) | `1101` | 13 |
| >= (signed) | `1110` | 14 |
| <= (signed) | `1111` | 15 |

## Where does the ECC come in?

With hamming codes built into the instruction set, one of the bits in any instruction can be flipped, and the CPU will still understand the instruction and execute it. For 16 bit instructions, this isn't practical for a real processor as the hamming codes take up 5 bits. For 64 bits or 128 bits though, this is a lot more feasible, requiring only 7 and 8 bits for hamming codes respectively.

## Simulator

Here is a video of the simulator in action:

[![asciicast](https://asciinema.org/a/JdwLGYkS3BQHdIZEEA3ueJbco.svg)](https://asciinema.org/a/JdwLGYkS3BQHdIZEEA3ueJbco)

Pass in an assembly file using `--file FILENAME`. Break points can be added to the code specifically for simulation by adding a `;break`. To step through each line of the code, pass `--step` to the program.
```
$ ./ecccpu_sim.py --help

usage: ecccpu_sim.py [-h] [-f FILE] [--step]

optional arguments:
  -h, --help            show this help message and exit
  -f FILE, --file FILE
  --step
```

## Assembler

Basic assembler that takes in assembly code and turns it into an ASCII hex file. Passing in `--verbose` will make it print out the pre-hamming instructions, post-hamming instructions, and the assembly.

```
$ ./ecccpu_asm.py --help

usage: ecccpu_asm.py [-h] -i I -o O [--verbose]

optional arguments:
  -h, --help  show this help message and exit
  -i I        assembly infile
  -o O        hex outfile
  --verbose
```

```
$ ./ecccpu_asm.py -i ../asm/fib.asm -o ../hdl/rom.bin --verbose

           main:
401  8118    LDI 0 1
501  a00a    LDI 1 1
60a  c0a6    LDI 2 fib
700  e111    LDI 3 0
23c  47d1    STR 0 3
2e8  5c90    STD 0 14
14c  28d7    INC 3
23d  47de    STR 1 3
2e9  5c9f    STD 1 14
15c  2bd4    DEC 3
           fib:
234  4747    LDR 0 3
14c  28d7    INC 3
235  4748    LDR 1 3
124  2442    ADD 1 0
616  c366    LDI 2 end
332  6633    JMP 2 3
14c  28d7    INC 3
23d  47de    STR 1 3
2e9  5c9f    STD 1 14
15c  2bd4    DEC 3
60a  c0a6    LDI 2 fib
302  6035    JMP 2
           end:
302  6035    JMP 2
```

## HDL

VHDL code that implements a CPU following this ISA. There are four parts to it, the ROM, hamming decoder, ALU, and CPU itself.

### rom

The ROM reads the `rom.bin` hex file into itself holding the instructions for the processor.

![](hdl/svg/rom.svg)

### hamming decoder

The hamming decoder decodes the instructions, correcting any errors.

![](hdl/svg/hamming_detect.svg)

![](hdl/svg/hamming_correct.svg)

### alu

The ALU takes in an operation and several arguments, then returns a value.

![](hdl/svg/alu.svg)

### cpu

The CPU reads instructions from ROM, passes them to the hamming decoder, then determines what the isntruction is asking it to do, executes that, then goes on to the next instruction.

![](hdl/svg/cpu.svg)

## Helpful sources

- [dcode](https://www.dcode.fr/hamming-error-correction) was really helpful in debugging my hamming code implementation
- The assembler makes use of the [hamming-codec](https://github.com/dantrim/hamming-codec) python library written by [Daniel Antrim ](https://github.com/dantrim).
- 3Blue1Brown's video on [hamming codes](https://www.youtube.com/watch?v=X8jsijhllIA)
- BenEater's video on [hamming codes in hardware](https://www.youtube.com/watch?v=h0jloehRKas), from which I borrowed the schematic for how to encode / decode hamming codes in hardware
