library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cpu is
    port (
        clk : in std_logic
    );
end entity cpu;

architecture rtl of cpu is

    -- signal clk : std_logic := '0';
    signal instr : unsigned(15 downto 0) := (others => '0');
    signal instr_dec : unsigned(10 downto 0) := (others => '0');
    signal pc, flags : unsigned(7 downto 0) := (others => '0');

    type reg_type is array (3 downto 0) of unsigned(7 downto 0);
    signal reg : reg_type := (others => (others => '0'));

    type ram_type is array (15 downto 0) of unsigned(7 downto 0);
    signal ram : ram_type := (others => (others => '0'));

    signal error_location : unsigned(3 downto 0) := (others => '0');
    signal error_double : std_logic := '0';

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


    process (clk) begin
        if (rising_edge(clk)) then
            if (instr_dec(10) = '1') then
                reg(to_integer(instr_dec(9 downto 8))) <= instr_dec(7 downto 0);
            elsif (instr_dec(10 downto 8) = "001") then
                case instr_dec(7 downto 4) is
                    when "0000" => -- AND
                        reg(to_integer(instr_dec(3 downto 2))) <= reg(to_integer(instr_dec(3 downto 2))) and reg(to_integer(instr_dec(1 downto 0)));
                    when "0001" => -- OR
                        reg(to_integer(instr_dec(3 downto 2))) <= reg(to_integer(instr_dec(3 downto 2))) or reg(to_integer(instr_dec(1 downto 0)));
                    when "0010" => -- ADD
                        reg(to_integer(instr_dec(3 downto 2))) <= reg(to_integer(instr_dec(3 downto 2))) + reg(to_integer(instr_dec(1 downto 0)));
                    when "0011" => -- SUB
                        reg(to_integer(instr_dec(3 downto 2))) <= reg(to_integer(instr_dec(3 downto 2))) - reg(to_integer(instr_dec(1 downto 0)));
                    when others =>
                end case;
            elsif (instr_dec(10 downto 8) = "010") then
                case instr_dec(3 downto 2) is
                    when "00" => -- LDD
                    when "01" => -- LDR
                    when "10" => -- STD
                    when "11" => -- STR
                        ram(to_integer(reg(to_integer(instr_dec(5 downto 4))))) <= reg(to_integer(instr_dec(1 downto 0)));
                    when others =>
                end case;
            end if;
            pc <= pc + '1';
        end if;
    end process;

end;
