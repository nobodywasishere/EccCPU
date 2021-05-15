library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
    port (
        operation  :  in unsigned(3 downto 0) := (others => '0');
        arg1, arg2 :  in unsigned(7 downto 0) := (others => '0');
        result     : out unsigned(7 downto 0) := (others => '0');
        flags      : out unsigned(7 downto 0) := (others => '0')
    );
end entity alu;

architecture rtl of alu is

begin

    with operation select
        result <= (arg1 and arg2) when "0000",
                  (arg1  or arg2) when "0001",
                  (arg1   + arg2) when "0010",
                  (arg1   - arg2) when "0011",
                  (arg1   +  '1') when "0100",
                  (arg1   -  '1') when "0101",
                  (others => '0') when others;

    flags(0) <= '1' when (result = 8d"0") else '0';
    flags(1) <= '1' when (result(7) = '1') else '0';
    flags(2) <= '1' when (result < arg1 and operation = "0010") or (result > arg1 and operation = "0011") else '0';
    flags(3) <= '1' when (arg1 > arg2) else '0';
    flags(4) <= '1' when (arg1 < arg2) else '0';
    flags(5) <= '1' when (arg1 = arg2) else '0';
    flags(6) <= '1' when (signed(arg1) > signed(arg2)) else '0';
    flags(7) <= '1' when (signed(arg1) < signed(arg2)) else '0';

end;
