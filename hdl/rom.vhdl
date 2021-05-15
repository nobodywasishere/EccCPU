library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity rom is
    generic (
        addr_width : natural := 8;
        data_width : natural := 16;
        rom_file   : string  := "rom.bin"
    );
    port (
        clk  :  in std_logic;
        addr :  in unsigned(addr_width - 1 downto 0) := (others => '0');
        data : out unsigned(data_width - 1 downto 0) := (others => '0')
    );
end entity rom;

architecture rtl of rom is

    type rom_type is array ((2** addr_width) - 1 downto 0) of unsigned(data_width - 1 downto 0);

    -- https://vhdlwhiz.com/initialize-ram-from-file/
    impure function init_rom return rom_type is
        file text_file : text open read_mode is rom_file;
        variable text_line : line;
        variable ram_content : rom_type;
    begin
        for i in 0 to (2**addr_width) - 2 loop
            readline(text_file, text_line);
            hread(text_line, ram_content(i));
        end loop;

        return ram_content;
    end function;

    signal rom_data : rom_type := init_rom;

begin

    process (clk) begin
        if (rising_edge(clk)) then
            data <= rom_data(to_integer(addr));
        end if;
    end process;

end;
