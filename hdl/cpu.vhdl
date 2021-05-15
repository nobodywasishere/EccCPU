library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cpu is
    port (
        clk : in std_logic
    );
end entity cpu;

architecture rtl of cpu is

    constant FLAG_Z   : integer := 0;
    constant FLAG_N   : integer := 1;
    constant FLAG_C   : integer := 2;
    constant FLAG_UGT : integer := 3;
    constant FLAG_ULT : integer := 4;
    constant FLAG_EQ  : integer := 5;
    constant FLAG_SGT : integer := 6;
    constant FLAG_SLT : integer := 7;

    signal instr : unsigned(15 downto 0) := (others => '0');
    signal instr_dec : unsigned(10 downto 0) := (others => '0');
    signal pc, flags : unsigned(7 downto 0) := (others => '1');

    type reg_type is array (3 downto 0) of unsigned(7 downto 0);
    signal reg : reg_type := (others => (others => '0'));

    type ram_type is array (15 downto 0) of unsigned(7 downto 0);
    signal ram : ram_type := (others => (others => '0'));

    signal error_location : unsigned(3 downto 0) := (others => '0');
    signal error_double : std_logic := '0';

begin

    rom1: entity work.rom(rtl)
    port map (
        clk => not clk,
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


    process (clk)
        variable arg1, arg2 : unsigned(7 downto 0) := (others => '0');
    begin
        if (rising_edge(clk)) then
            pc <= pc + '1';
            flags <= (others => '0');
            if (instr_dec(10) = '1') then
                reg(to_integer(instr_dec(9 downto 8))) <= instr_dec(7 downto 0);
            elsif (instr_dec(10 downto 8) = "001") then -- ALU
                case instr_dec(7 downto 4) is
                    when "0000" => -- AND
                        reg(to_integer(instr_dec(3 downto 2))) <= reg(to_integer(instr_dec(3 downto 2))) and reg(to_integer(instr_dec(1 downto 0)));
                    when "0001" => -- OR
                        reg(to_integer(instr_dec(3 downto 2))) <= reg(to_integer(instr_dec(3 downto 2))) or reg(to_integer(instr_dec(1 downto 0)));
                    when "0010" => -- ADD
                        reg(to_integer(instr_dec(3 downto 2))) <= reg(to_integer(instr_dec(3 downto 2))) + reg(to_integer(instr_dec(1 downto 0)));
                        if ('0' & reg(to_integer(instr_dec(3 downto 2))) + '0' & reg(to_integer(instr_dec(1 downto 0))) > 9d"255") then
                            flags(FLAG_C) <= '1';
                        end if;
                    when "0011" => -- SUB
                        reg(to_integer(instr_dec(3 downto 2))) <= reg(to_integer(instr_dec(3 downto 2))) - reg(to_integer(instr_dec(1 downto 0)));
                        if ('0' & reg(to_integer(instr_dec(3 downto 2))) - '0' & reg(to_integer(instr_dec(1 downto 0))) > 9d"255") then
                            flags(FLAG_C) <= '1';
                        end if;
                    when "0100" => -- INC
                        reg(to_integer(instr_dec(1 downto 0))) <= reg(to_integer(instr_dec(1 downto 0))) + '1';
                    when "0101" => -- DEC
                        reg(to_integer(instr_dec(1 downto 0))) <= reg(to_integer(instr_dec(1 downto 0))) - '1';
                    when "1000" => -- CMP
                        arg1 := reg(to_integer(instr_dec(3 downto 2)));
                        arg2 := reg(to_integer(instr_dec(1 downto 0)));
                        if (arg1 > arg2) then
                            flags(FLAG_UGT) <= '1';
                        end if;
                        if (arg1 < arg2) then
                            flags(FLAG_ULT) <= '1';
                        end if;
                        if (arg1 = arg2) then
                            flags(FLAG_EQ) <= '1';
                        end if;
                        if (arg1(7) = arg2(7)) then
                            if (arg1(6 downto 0) > arg2(6 downto 0)) then
                                flags(FLAG_SGT) <= '1';
                            end if;
                            if (arg1(6 downto 0) < arg2(6 downto 0)) then
                                flags(FLAG_SLT) <= '1';
                            end if;
                        else
                            if (arg1(7) < arg2(7)) then
                                flags(FLAG_SGT) <= '1';
                            else
                                flags(FLAG_SLT) <= '1';
                            end if;
                        end if;
                    when others =>
                end case;
            elsif (instr_dec(10 downto 8) = "010") then -- RAM / REG
                case instr_dec(3 downto 2) is
                    when "00" => -- LDD
                        reg(to_integer(instr_dec(1 downto 0))) <= ram(to_integer(instr_dec(7 downto 4)));
                    when "01" => -- LDR
                        reg(to_integer(instr_dec(1 downto 0))) <= ram(to_integer(reg(to_integer(instr_dec(5 downto 4)))));
                    when "10" => -- STD
                        ram(to_integer(instr_dec(7 downto 4))) <= reg(to_integer(instr_dec(1 downto 0)));
                    when "11" => -- STR
                        ram(to_integer(reg(to_integer(instr_dec(5 downto 4))))) <= reg(to_integer(instr_dec(1 downto 0)));
                    when others =>
                end case;
            elsif (instr_dec(10 downto 8) = "011") then
                case instr_dec(7 downto 4) is
                    when "0000" =>
                        pc <= reg(to_integer(instr_dec(1 downto 0)));
                    when others =>
                end case;
            end if;
        end if;
    end process;

end;
