# EccCPU - Error Correcting Code Central Processing Unit

All of the instructions of the CPU are hamming codes.

16-bit (effective 11-bit) CPU:

    P = Parity for whole instruction
    H = Hamming code bit, parity for part of instruction
    I = Instruction data

    P H H I H I I I H I I I I I I I

    0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1
        1 1 0 0 1 1 0 0 1 1 0 0 1 1
            1 1 1 1 0 0 0 0 1 1 1 1
                    1 1 1 1 1 1 1 1

    2^11 -> 2048 possible instructions

    Ex:
        III DDDD DDDD
        IIIII RRR RRR
        II AAAAAAAAA

64-bit (effective 57-bit) CPU:

    P H H I H I I I H I I I I I I I H I I I I I I I I I I I I I I I H I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I I

    0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1
        1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1
            1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1
                    1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1
                                    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
                                                                    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1

    2^57 => 1.44115188076e+17 possible instructions

Normal:
    Fetch -> Decode -> Execute

EccCPU:
    Fetch -> Parity Check -> Decode -> Execute

Caviates:
- Requires 15% more space for a comparable program due to storage of hamming codes (with hamming 16/11) (not including reduced instruction set size)
- Requires 11% more space for a comparable program (with hamming 64/57)
- Requires 33% longer instruction time due to extra cycle (unless parity check and correction can occur during fetch or decode)

## ISA

- Want a proof of concept super-simple CPU
- Write a "virtual machine" for it in python
- Write an assembler for it in python
- Write the actual CPU itself in VHDL
- ISA simple enough to be able to calculate Fibonacci sequence to 233, meaning must be 8-bits for data
- 4 registers of 8 bits each
- 16 data RAM slots of 8 bits each

| instr | operation | code | combin |
|:-----:|:---------:|:----:|:------:|
| `NOP`         | No operation                   | `000_XXXX_XXXX` |  256 |
| `AND RR SS`   | And S and R, store in R        | `001_0000_RRSS` |   16 |
| `OR  RR SS`   | Or S and R, store in R         | `001_0001_RRSS` |   16 |
| `ADD RR SS`   | Add R to S, store in R         | `001_0010_RRSS` |   16 |
| `SUB RR SS`   | Sub S from R, store in R       | `001_0011_RRSS` |   16 |
| `INC RR`      | Increment R                    | `001_0100_00RR` |    4 |
| `DEC RR`      | Decrement R                    | `001_0101_00RR` |    4 |
| `CMP RR SS`   | Compare R with S               | `001_1000_RRSS` |   16 |
| `LDD RR DD`   | Load from data D into R        | `010_DDDD_00RR` |   64 |
| `LDR RR SS`   | Load from D based on S into R  | `010_00SS_01RR` |   16 |
| `STD RR DD`   | Store R in data D              | `010_DDDD_10RR` |   64 |
| `STR RR SS`   | Store R in addr by 4 bits of S | `010_00SS_11RR` |   16 |
| `JMP RR`      | Jump to address in R           | `011_0000_00RR` |    4 |
| `JMP RR CC`   | Jump to address in R if C      | `011_CCCC_00RR` |   64 |
| `LDI RR VV`   | Load immediate V into R        | `1RR_VVVV_VVVV` | 1024 |
| ` `           |                                | `001_011X_XXXX` |   32 |
| ` `           |                                | `001_1---_XXXX` |  128 |
| ` `           |                                | `011_----_XX--` |    4 |

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


- Fibonacci in assembly:

```
assembly         |   pre-hamming   |   machine code
========         |   ===========   |   ============
main:            |                 |   
    LDI R0 1     |   10000000001   |   1000000000101100
    LDI R1 1     |   10100000001   |   1010000000100001
    LDI R2 fib   |   11000001000   |   1100000100010110
    LDI R3 0     |   11100000000   |   1110000000011100
    STR R0 R3    |   01000111100   |   0100011110011100
    INC R3       |   00101000011   |   0010100001100000
    STR R1 R3    |   01000111101   |   0100011110101111
    DEC R3       |   00101010011   |   0010101001111001
fib:             |                 |   
    LDR R0 R3    |   01000110100   |   0100011010011011
    INC R3       |   00101000011   |   0010100001100000
    LDR R1 R3    |   01000110101   |   0100011010101000
    ADD R1 R0    |   00100100100   |   0010010010000001
    INC R3       |   00101000011   |   0010100001100000
    STR R1 R3    |   01000111101   |   0100011110101111
    DEC R3       |   00101010011   |   0010101001111001
    JMP fib      |   01100000010   |   0110000001010110
```
