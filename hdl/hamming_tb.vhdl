library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity hamming_tb is

end entity hamming_tb;

architecture test of hamming_tb is

    signal data_encoded : unsigned(15 downto 0) := (others => '0');
    signal data_out, data_in : unsigned(10 downto 0) := (others => '0');
    signal error_location : unsigned(3 downto 0) := (others => '0');
    signal error_double : std_logic := '0';

begin

    dut0: entity work.hamming_set(synth)
    port map (
        data_in => data_in,
        data_out => data_encoded
    );

    dut1: entity work.hamming_detect(synth)
    port map (
        data_in => data_encoded,
        error_location => error_location,
        error_double => error_double
    );

    dut2: entity work.hamming_correct(synth)
    port map (
        data_in => data_encoded,
        error_location => error_location,
        data_out => data_out
    );

    process begin
        wait for 1 ps;
        for I in 0 to 2**11 loop
            report "data_in:  " & to_string(data_in);
            report "data_enc: " & to_string(data_encoded);
            report "data_out: " & to_string(data_out);
            report "err:      " & to_string(error_location);
            report "err_d:    " & to_string(error_double);
            report "";
            wait for 1 ps;
            data_in <= data_in + '1';
            wait for 1 ps;
        end loop;

        wait;
    end process;

end;
