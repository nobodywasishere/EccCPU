BLUEBOLD=\e[1;36m
NC=\033[0m
GHDL_A=ghdl -a --std=08
GHDL_R=ghdl -r --std=08
SRC_DIR=src
TB_DIR=tb

# %:
# 	@echo -en "$(BLUEBOLD)==== Testing $@ ====$(NC)\n"
# 	-@ghdl -a $@.vhdl $@_tb.vhdl
# 	-@ghdl -r $@_tb --wave=$@_tb.ghw

rom: clean
	${GHDL_A} ${SRC_DIR}/rom.vhdl ${TB_DIR}/rom_tb.vhdl
	${GHDL_R} rom_tb --wave=rom.ghw

cpu: clean
	${GHDL_A} ${SRC_DIR}/rom.vhdl ${SRC_DIR}/hamming.vhdl ${SRC_DIR}/alu.vhdl ${SRC_DIR}/cpu.vhdl ${TB_DIR}/cpu_tb.vhdl
	${GHDL_R} cpu_tb --wave=cpu.ghw --stop-time=500ns

hamming: clean
	${GHDL_A} ${SRC_DIR}/hamming.vhdl ${TB_DIR}/hamming_tb.vhdl
	${GHDL_R} hamming_tb --wave=hamming.ghw

alu: clean
	${GHDL_A} ${SRC_DIR}/alu.vhdl ${TB_DIR}/alu_tb.vhdl
	${GHDL_R} alu_tb --wave=alu.ghw

synth:
	${GHDL_A} ${SRC_DIR}/rom.vhdl ${SRC_DIR}/hamming.vhdl ${SRC_DIR}/alu.vhdl ${SRC_DIR}/cpu.vhdl
	yosys -q -p 'ghdl --std=08 cpu; synth_ice40 -json cpu.json'
	nextpnr-ice40 --up5k --package sg48 --pcf "pins.pcf" --asc "cpu.asc" --json "cpu.json"
	icepack "cpu.asc" "cpu.bin"
	iceprog cpu.bin

svg: clean
	-mkdir svg
	${GHDL_A} ${SRC_DIR}/rom.vhdl ${SRC_DIR}/hamming.vhdl ${SRC_DIR}/alu.vhdl ${SRC_DIR}/cpu.vhdl
	for entity in rom cpu hamming_detect hamming_correct alu; do \
		yosys -q -p "ghdl --std=08 $$entity; prep -top $$entity; write_json -compat-int svg/$$entity.json"; \
		netlistsvg svg/$$entity.json -o svg/$$entity.svg; \
	done

clean:
	@echo -en "$(BLUEBOLD)==== Cleaning ====$(NC)\n"
	-@rm *.cf *.ghw

.PHONY: svg
