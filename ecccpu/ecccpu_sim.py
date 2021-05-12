#!/usr/bin/env python

class EccCPU_SIM():
    reg = [0,0,0,0]
    ram = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    pc  = 0
    flags = 0
    rom = ""
    step = False
    code = []
    symbols = {}

    flag_bits = {'zero': 1, 'neg': 2, 'carry': 4,
                 '>u':  8, '<u':  16, '=': 32,
                 '>s': 64, '<s': 128}

    def run(self):
        self.clean()
        self.findSymbols()
        # for line in self.code:
        while self.pc < len(code) - 1:
            line = self.code[self.pc]
            try:
                # print(f"{self.pc:3d}: {line}")
                self.decode(line)
            except Exception as e:
                self.printInfo()
                print(e)
                exit(1)
            if self.step or line == ";break":
                self.printInfo()
                input(": ")
        self.printInfo()

    def clean(self):
        new_code = []
        for line_i in range(len(self.code)):
            if self.code[line_i] != "":
                new_code.append(self.code[line_i].strip())
        self.code = new_code[:]

    def findSymbols(self):
        line_i = 0;
        for line in self.code:
            if line.split(' ')[0][-1] == ":":
                # print("Found symbol: {}={}".format(line[:-1], line_i))
                self.symbols[line[:-1]] = line_i
            line_i = line_i + 1
        pass

    def decode(self, instr):
        if instr[0] == ";":
            self.pc = self.pc + 1
            return
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
        self.execute(op, arg1, arg2)
        self.pc = self.pc + 1

    def execute(self, op, arg1, arg2):
        if   (op[:-1] in self.symbols):
            return
        elif (op == "nop"):
            pass
        elif (op == "and"):
            self.reg[arg1] = self.reg[arg1] & self.reg[arg2]
        elif (op == "or"):
            self.reg[arg1] = self.reg[arg1] | self.reg[arg2]
        elif (op == "add"):
            self.flags = 0;
            if self.reg[arg1] + self.reg[arg2] > 255:
                self.flags = self.flags | self.flag_bits['carry']
            self.reg[arg1] = (self.reg[arg1] + self.reg[arg2]) % 256
        elif (op == "sub"):
            self.flags = 0;
            if self.reg[arg1] + self.reg[arg2] < 255:
                self.flags = self.flags | flag_bits['carry']
            self.reg[arg1] = (self.reg[arg1] - self.reg[arg2]) % 256
        elif (op == "inc"):
            self.reg[arg1] = (self.reg[arg1] + 1) % 256
        elif (op == "dec"):
            self.reg[arg1] = (self.reg[arg1] - 1) % 256
        elif (op == "cmp"):
            self.flags = 0;
            if self.reg[arg1] > self.reg[arg2]:
                self.flags = self.flags | self.flag_bits['>u']
            if self.reg[arg1] < self.reg[arg2]:
                self.flags = self.flags | self.flag_bits['<u']
            if ((-1)**(1+(self.reg[arg1] & 128)))*(self.reg[arg1] % 128) > \
               ((-1)**(1+(self.reg[arg2] & 128)))*(self.reg[arg2] % 128):
                self.flags = self.flags | self.flag_bits['>s']
            if ((-1)**(1+(self.reg[arg1] & 128)))*(self.reg[arg1] % 128) < \
               ((-1)**(1+(self.reg[arg2] & 128)))*(self.reg[arg2] % 128):
                self.flags = self.flags | self.flag_bits['<s']
            if self.reg[arg1] == self.reg[arg2]:
                self.flags = self.flags | self.flag_bits['=']
        elif (op == "ldd"):
            self.reg[arg1] = self.ram[arg2 % 16]
        elif (op == "ldr"):
            self.reg[arg1] = self.ram[self.reg[arg2] % 16]
        elif (op == "std"):
            self.ram[arg2 % 16] = self.reg[arg1]
        elif (op == "str"):
            self.ram[self.reg[arg2] % 16] = self.reg[arg1]
        elif (op == "jmp"):
            if arg2 == "" or self.checkFlags(arg2):
                self.pc = self.reg[arg1]
        elif (op == "ldi"):
            self.reg[arg1] = arg2 % 256
        else:
            print("Unknown instruction: {}".format(op))

        if op in ['and', 'or', 'add', 'sub', 'cmp', 'inc', 'dec']:
            self.setFlags(arg1)

    def setFlags(self, arg1):
        if self.reg[arg1] == 0:
            self.flags = self.flags | self.flag_bits['zero']
        if self.reg[arg1] > 127:
            self.flags = self.flags | self.flag_bits['neg']

    def checkFlags(self, arg2):
        if   arg2 == 0:
            return True
        elif arg2 == 1 and ((self.flags & self.flag_bits['zero']) == 1):
            return True
        elif arg2 == 2 and ((self.flags & self.flag_bits['neg']) == 2):
            return True
        elif arg2 == 4 and ((self.flags & self.flag_bits['carry']) == 4):
            return True
        else:
            return False

    def printInfo(self):
        print(f"PC:  {self.pc:08b}")
        print(f"FLG: {self.flags:08b}\n"
               "     <>=<>cnz")
        print(f"REG: {self.reg[0]:08b} {self.reg[1]:08b} {self.reg[2]:08b} {self.reg[3]:08b}")
        print(f"RAM: {self.ram[ 0]:08b} {self.ram[ 1]:08b} {self.ram[ 2]:08b} {self.ram[ 3]:08b}\n"
              f"     {self.ram[ 4]:08b} {self.ram[ 5]:08b} {self.ram[ 6]:08b} {self.ram[ 7]:08b}\n"
              f"     {self.ram[ 8]:08b} {self.ram[ 9]:08b} {self.ram[10]:08b} {self.ram[11]:08b}\n"
              f"     {self.ram[12]:08b} {self.ram[13]:08b} {self.ram[14]:08b} {self.ram[15]:08b}")

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--file')
    parser.add_argument('--step', action="store_true")

    args = parser.parse_args()

    cpu = EccCPU_SIM()
    if args.step:
        cpu.step = args.step
    if args.file:
        code = open(args.file).read().replace('\r','').split('\n')
        # print(code)
        cpu.code = code
        try:
            cpu.run()
        except KeyboardInterrupt:
            exit(1)
        pass
    else:
        while(True):
            cpu.printInfo()
            try:
                inCode = input(": ")
            except KeyboardInterrupt:
                exit(1)
            cpu.decode(inCode)
