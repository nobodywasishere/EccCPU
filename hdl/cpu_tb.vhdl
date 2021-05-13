library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cpu_tb is

end entity cpu_tb;

architecture test of cpu_tb is

    signal clk : std_logic := '0';

begin
    cpu1: entity work.cpu(rtl) port map(clk);

    process begin
        for I in 0 to 20 loop
            clk <= '1';
            wait for 1 ns;
            clk <= '0';
            wait for 1 ns;
        end loop;
        wait;
    end process;

end;
