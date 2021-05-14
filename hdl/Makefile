BLUEBOLD=\e[1;36m
NC=\033[0m
GHDL_A=ghdl -a --std=08
GHDL_R=ghdl -r --std=08

# %:
# 	@echo -en "$(BLUEBOLD)==== Testing $@ ====$(NC)\n"
# 	-@ghdl -a $@.vhdl $@_tb.vhdl
# 	-@ghdl -r $@_tb --wave=$@_tb.ghw

rom: clean
	${GHDL_A} rom.vhdl rom_tb.vhdl
	${GHDL_R} rom_tb --wave=rom.ghw

cpu: clean
	${GHDL_A} rom.vhdl hamming.vhdl cpu.vhdl cpu_tb.vhdl
	${GHDL_R} cpu_tb --wave=cpu.ghw --stop-time=100ns

hamming: clean
	${GHDL_A} hamming.vhdl hamming_tb.vhdl
	${GHDL_R} hamming_tb --wave=hamming.ghw

clean:
	@echo -en "$(BLUEBOLD)==== Cleaning ====$(NC)\n"
	-@rm *.cf *.ghw
