main:
    LDI 0 1
    LDI 1 1
    LDI 2 fib
    LDI 3 0
    STR 0 3
    INC 3
    STR 1 3
    DEC 3
fib:
    LDR 0 3
    INC 3
    LDR 1 3
    ADD 1 0
    JMP end 4
    ; break
    INC 3
    STR 1 3
    DEC 3
    JMP fib
end:
    NOP
