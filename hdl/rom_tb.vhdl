library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rom_tb is

end entity rom_tb;

architecture test of rom_tb is

    signal clk : std_logic := '0';
    signal data : std_logic_vector(15 downto 0) := (others => '0');
    signal addr : integer := 0;


begin

    rom1: entity work.rom(rtl) port map(clk, addr, data);

    process begin
        for I in 0 to 20 loop
            clk <= '1';
            wait for 1 ns;
            report "data: " & to_string(data);
            addr <= addr + 1;
            clk <= '0';
            wait for 1 ns;
        end loop;

        wait;
    end process;

end;
