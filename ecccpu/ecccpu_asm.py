#!/usr/bin/env python

class EccCPU_ASM():
    symbols = {}
    code = []
    verbose = False

    def assemble(self, code, verbose):
        self.code = code
        self.verbose = verbose
        self.findSymbols()
        self.clean()
        line_i = 0
        bin = []
        for line in self.code:
            op, arg1, arg2 = self.parse(line)
            mach = self.encode(op, arg1, arg2)
            parity = self.parity(mach)
            hex = f'{int(parity, 2):04x}'
            if self.verbose:
                for sym in self.symbols:
                    if line_i == self.symbols[sym]:
                        print(f'      {sym}:')
                print(f'{hex}    {line}')
            bin.append(hex)
            line_i = line_i + 1
        while (line_i < 256):
            bin.append("0000")
            line_i = line_i + 1
        return bin

    def findSymbols(self):
        line_i = 0;
        for line in self.code:
            line = line.split(';')[0].strip()
            if line == "":
                pass
            elif line.split(' ')[0][-1] == ":":
                # print("Found symbol: {}={}".format(line[:-1], line_i))
                self.symbols[line[:-1]] = line_i
            else:
                line_i = line_i + 1

    def clean(self):
        new_code = []
        for line_i in range(len(self.code)):
            line = self.code[line_i].split(';')[0].strip()
            if line != "" and ":" not in line:
                new_code.append(line)
        self.code = new_code[:]

    def parse(self, instr):
        op = instr.split(' ')[0].lower()
        arg1 = ""
        arg2 = ""
        if len(instr.split(' ')) > 1:
            if instr.split(' ')[1].isnumeric():
                arg1 = int(instr.split(' ')[1].lower())
            elif instr.split(' ')[1].lower() in self.symbols:
                arg1 = self.symbols[instr.split(' ')[1].lower()]
            else:
                print("Error: Unknown arg: {}".format(instr.split(' ')[1]))
        if len(instr.split(' ')) > 2:
            if instr.split(' ')[2].isnumeric():
                arg2 = int(instr.split(' ')[2].lower())
            elif instr.split(' ')[2].lower() in self.symbols:
                arg2 = self.symbols[instr.split(' ')[2].lower()]
            else:
                print("Error: Unknown arg: {}".format(instr.split(' ')[2]))
        # print("instr: {} {} {}".format(op, arg1, arg2))
        return op, arg1, arg2

    def encode(self, op, arg1, arg2):
        asm = ''
        if (op == "nop"):
            asm = f'{0:011b}'
        elif (op == "and"):
            asm = f'0010000{arg1:02b}{arg2:02b}'
        elif (op == "or"):
            asm = f'0010001{arg1:02b}{arg2:02b}'
        elif (op == "add"):
            asm = f'0010010{arg1:02b}{arg2:02b}'
        elif (op == "sub"):
            asm = f'0010011{arg1:02b}{arg2:02b}'
        elif (op == "inc"):
            asm = f'001010000{arg1:02b}'
        elif (op == "dec"):
            asm = f'001010100{arg1:02b}'
        elif (op == "cmp"):
            asm = f'0011000{arg1:02b}{arg2:02b}'
        elif (op == "ldd"):
            asm = f'010{arg2:04b}00{arg1:02b}'
        elif (op == "ldr"):
            asm = f'01000{arg2:02b}01{arg1:02b}'
        elif (op == "std"):
            asm = f'010{arg2:04b}10{arg1:02b}'
        elif (op == "str"):
            asm = f'01000{arg2:02b}11{arg1:02b}'
        elif (op == "jmp"):
            if arg2 == "":
                asm = f'011000000{arg1:02b}'
            else:
                asm = f'011{arg2:04b}00{arg1:02b}'
        elif (op == "ldi"):
            asm = f'1{arg1:02b}{arg2:08b}'
        else:
            print("Unknown instruction: {}".format(op))
            exit(1)
        return asm

    def parity(self, instr):
        # P H H I H I I I H I I I I I I I
        # MSB                         LSB
        instr_l = list(instr)
        instr_l.reverse()
        out = instr_l[0:7] + ['0'] + instr_l[7:10] + ['0'] + [instr_l[10]] + ['0', '0', '0']
        out.reverse()

        check = [[3,  5,  7,  9, 11, 13, 15],
                 [3,  6,  7, 10, 11, 14, 15],
                 [5,  6,  7, 12, 13, 14, 15],
                 [9, 10, 11, 12, 13, 14, 15]]

        c = 1
        for i in check:
            parity = 0
            for j in i:
                parity = parity ^ int(out[j])
            out[c] = str(parity)
            c = c*2

        parity = 0
        for i in out:
            parity = parity ^ int(i)
        out[0] = str(parity)
        return ''.join(out)

if __name__=="__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument('-i', help="assembly infile",required=True)
    parser.add_argument('-o', help="binary outfile", required=True)
    parser.add_argument('--verbose', action="store_true")

    args = parser.parse_args()

    asm = EccCPU_ASM()
    code = open(args.i).read().replace('\r','').split('\n')
    hex = asm.assemble(code, args.verbose)

    open(args.o, 'w+').write('\n'.join(hex))
