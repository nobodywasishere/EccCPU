library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu_tb is
end entity alu_tb;

architecture test of alu_tb is

    signal operation  : unsigned(3 downto 0) := (others => '0');
    signal arg1, arg2 : unsigned(7 downto 0) := (others => '0');
    signal result     : unsigned(7 downto 0) := (others => '0');
    signal flags      : unsigned(7 downto 0) := (others => '0');

begin
    alu1: entity work.alu(rtl)
    port map (
        operation,
        arg1,
        arg2,
        result,
        flags
    );

    process begin
        wait for 1 ns;
        for J in 0 to 15 loop
            arg1 <= to_unsigned(J, 8);
            wait for 1 ns;
            -- report "op:     " & to_string(operation);
            -- report "arg1:   " & to_string(arg1);
            -- report "arg2:   " & to_string(arg2);
            -- report "flags:  " & to_string(flags);
            -- report "result: " & to_string(result);
            -- report "";
            -- wait for 1 ns;
        end loop;
        wait;
    end process;

end;
