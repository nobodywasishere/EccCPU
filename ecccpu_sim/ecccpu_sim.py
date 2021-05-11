#!/usr/bin/env python

class EccCPU():
    reg = [0,0,0,0]
    ram = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    pc  = 0
    flags = 0
    rom = ""

    flag_bits = {'zero': 1, 'neg': 2, 'carry': 4,
                 '>u':  8, '<u':  16, '=': 32,
                 '>s': 64, '<s': 128}

    def decode(self, instr):
        op = instr.split(' ')[0].lower()
        arg1 = ""
        arg2 = ""
        if len(instr.split(' ')) > 1:
            arg1 = int(instr.split(' ')[1].lower())
        if len(instr.split(' ')) > 2:
            arg2 = int(instr.split(' ')[2].lower())
        self.execute(op, arg1, arg2)
        self.pc = self.pc + 1

    def execute(self, op, arg1, arg2):
        self.flags = 0;
        if   (op == "nop"):
            pass
        elif (op == "and"):
            self.reg[arg1] = self.reg[arg1] & self.reg[arg2]
        elif (op == "or"):
            self.reg[arg1] = self.reg[arg1] | self.reg[arg2]
        elif (op == "add"):
            if self.reg[arg1] + self.reg[arg2] > 255:
                self.flags = self.flags | self.flag_bits['carry']
            self.reg[arg1] = (self.reg[arg1] + self.reg[arg2]) % 256
        elif (op == "sub"):
            if self.reg[arg1] + self.reg[arg2] > 255:
                self.flags = self.flags | flag_bits['carry']
            self.reg[arg1] = (self.reg[arg1] - self.reg[arg2]) % 256
        elif (op == "inc"):
            self.reg[arg1] = self.reg[arg1] + 1
        elif (op == "dec"):
            self.reg[arg1] = self.reg[arg1] - 1
        elif (op == "cmp"):
            if self.reg[arg1] > self.reg[arg2]:
                self.flags = self.flags | self.flag_bits['>u']
            if self.reg[arg1] < self.reg[arg2]:
                self.flags = self.flags | self.flag_bits['<u']
            if (self.reg[arg1] % 128) > (self.reg[arg2] % 128):
                self.flags = self.flags | self.flag_bits['>s']
            if (self.reg[arg1] % 128) < (self.reg[arg2] % 128):
                self.flags = self.flags | self.flag_bits['<s']
            if self.reg[arg1] == self.reg[arg2]:
                self.flags = self.flags | self.flag_bits['=']
        elif (op == "ldd"):
            self.reg[arg1] = self.ram[arg2]
        elif (op == "ldr"):
            self.reg[arg1] = self.ram[self.reg[arg2]]
        elif (op == "std"):
            self.ram[arg2] = self.reg[arg1]
        elif (op == "str"):
            self.ram[self.reg[arg2]] = self.reg[arg1]
        elif (op == "jmp"):
            print("NOT IMPLEMENTED (YET)")
            pass
        elif (op == "ldi"):
            self.reg[arg1] = arg2 % 256
        else:
            print("Unknown instruction: {}".format(op))
        if arg1:
            if self.reg[arg1] == 0:
                self.flags = self.flags | self.flag_bits['zero']
            if self.reg[arg1] > 127:
                self.flags = self.flags | self.flag_bits['neg']

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
    cpu = EccCPU()
    while(True):
        cpu.printInfo()
        try:
            inCode = input(": ")
        except KeyboardInterrupt:
            exit(1)
        cpu.decode(inCode)
