library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cpu is
    port (
        clk : in std_logic;
        cpu_in : in unsigned(7 downto 0);
        cpu_out : out unsigned(7 downto 0)
    );
end entity cpu;

architecture rtl of cpu is

    signal instr : unsigned(15 downto 0) := (others => '0');
    signal instr_dec : unsigned(10 downto 0) := (others => '0');
    signal pc, flags : unsigned(7 downto 0) := (others => '1');
    constant FLAG_Z   : integer := 0; -- zero
    constant FLAG_N   : integer := 1; -- negative
    constant FLAG_C   : integer := 2; -- carry / borrow
    constant FLAG_UGT : integer := 3; -- unsigned greater than
    constant FLAG_ULT : integer := 4; -- unsigned less than
    constant FLAG_EQ  : integer := 5; -- equal
    constant FLAG_SGT : integer := 6; -- signed greater than
    constant FLAG_SLT : integer := 7; -- signed less than

    type reg_type is array (3 downto 0) of unsigned(7 downto 0);
    signal reg : reg_type := (others => (others => '0'));

    type ram_type is array (15 downto 0) of unsigned(7 downto 0);
    signal ram : ram_type := (others => (others => '0'));

    signal error_location : unsigned(3 downto 0) := (others => '0');
    signal error_double : std_logic := '0';

    signal alu_operation : unsigned(3 downto 0) := (others => '0');
    signal alu_arg1, alu_arg2, alu_result, alu_flags : unsigned(7 downto 0) := (others => '0');
    signal stage : std_logic := '0';

begin

    rom1: entity work.rom(rtl)
    port map (
        clk => clk,
        addr => pc,
        data => instr
    );
    hammd1: entity work.hamming_detect(synth)
    port map (
        data_in => instr,
        error_location => error_location,
        error_double => error_double
    );
    hammc1: entity work.hamming_correct(synth)
    port map (
        data_in => instr,
        error_location => error_location,
        data_out => instr_dec
    );

    alu1: entity work.alu(rtl)
    port map (
        operation => alu_operation,
        arg1 => alu_arg1,
        arg2 => alu_arg2,
        result => alu_result,
        flags => alu_flags
    );


    process (clk)
        variable arg1, arg2 : unsigned(7 downto 0) := (others => '0');
    begin
        if (rising_edge(clk)) then
            if (stage = '0') then
                pc <= pc + '1';
                if (instr_dec(10) = '1') then
                    reg(to_integer(instr_dec(9 downto 8))) <= instr_dec(7 downto 0);
                elsif (instr_dec(10 downto 8) = "001") then -- ALU
                    alu_operation <= instr_dec(7 downto 4);
                    alu_arg1 <= reg(to_integer(instr_dec(3 downto 2)));
                    alu_arg2 <= reg(to_integer(instr_dec(1 downto 0)));
                elsif (instr_dec(10 downto 8) = "010") then -- RAM / REG
                    case instr_dec(3 downto 2) is
                        when "00" => -- LDD
                            reg(to_integer(instr_dec(1 downto 0))) <= ram(to_integer(instr_dec(7 downto 4)));
                        when "01" => -- LDR
                            reg(to_integer(instr_dec(1 downto 0))) <= ram(to_integer(reg(to_integer(instr_dec(5 downto 4)))) rem 16);
                        when "10" => -- STD
                            ram(to_integer(instr_dec(7 downto 4))) <= reg(to_integer(instr_dec(1 downto 0)));
                        when "11" => -- STR
                            ram(to_integer(reg(to_integer(instr_dec(5 downto 4)))) rem 16) <= reg(to_integer(instr_dec(1 downto 0)));
                        when others =>
                    end case;
                elsif (instr_dec(10 downto 8) = "011") then
                    case instr_dec(7 downto 4) is
                        when "0000" => -- any
                            pc <= reg(to_integer(instr_dec(1 downto 0)));
                        when "0001" => -- zero
                            if (flags(FLAG_Z) = '1') then
                                pc <= reg(to_integer(instr_dec(1 downto 0)));
                            end if;
                        when "0010" => -- negative
                            if (flags(FLAG_N) = '1') then
                                pc <= reg(to_integer(instr_dec(1 downto 0)));
                            end if;
                        when "0011" => -- carry
                            if (flags(FLAG_C) = '1') then
                                pc <= reg(to_integer(instr_dec(1 downto 0)));
                            end if;
                        when "0100" => -- > unsigned
                            if (flags(FLAG_UGT) = '1') then
                                pc <= reg(to_integer(instr_dec(1 downto 0)));
                            end if;
                        when "0101" => -- < unsigned
                            if (flags(FLAG_ULT) = '1') then
                                pc <= reg(to_integer(instr_dec(1 downto 0)));
                            end if;
                        when "0110" => -- >= unsigned
                            if (flags(FLAG_UGT) = '1' or flags(FLAG_EQ) = '1') then
                                pc <= reg(to_integer(instr_dec(1 downto 0)));
                            end if;
                        when "0111" => -- <= unsigned
                            if (flags(FLAG_ULT) = '1' or flags(FLAG_EQ) = '1') then
                                pc <= reg(to_integer(instr_dec(1 downto 0)));
                            end if;
                        when "1000" => -- equal
                            if (flags(FLAG_EQ) = '1') then
                                pc <= reg(to_integer(instr_dec(1 downto 0)));
                            end if;
                        when "1100" => -- > signed
                            if (flags(FLAG_SGT) = '1') then
                                pc <= reg(to_integer(instr_dec(1 downto 0)));
                            end if;
                        when "1101" => -- < signed
                            if (flags(FLAG_SLT) = '1') then
                                pc <= reg(to_integer(instr_dec(1 downto 0)));
                            end if;
                        when "1110" => -- >= signed
                            if (flags(FLAG_SGT) = '1' or flags(FLAG_EQ) = '1') then
                                pc <= reg(to_integer(instr_dec(1 downto 0)));
                            end if;
                        when "1111" => -- <= signed
                            if (flags(FLAG_SLT) = '1' or flags(FLAG_EQ) = '1') then
                                pc <= reg(to_integer(instr_dec(1 downto 0)));
                            end if;
                        when others =>
                    end case;
                end if;
            elsif (stage = '1') then
                if (instr_dec(10 downto 8) = "001") then
                    flags <= alu_flags;
                    reg(to_integer(instr_dec(3 downto 2))) <= alu_result;
                end if;
                ram(13) <= cpu_in;
                cpu_out <= ram(14);
            end if;
            stage <= not stage;
        end if;
    end process;

end;
