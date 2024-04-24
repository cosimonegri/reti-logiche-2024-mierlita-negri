library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity memoria is
port(
    clk  : in std_logic;
    we   : in std_logic;
    en   : in std_logic;
    addr : in std_logic_vector(15 downto 0);
    di   : in std_logic_vector(7 downto 0);
    do   : out std_logic_vector(7 downto 0)
);
end memoria;

architecture memoria_arch of memoria is
type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);
signal RAM : ram_type;
begin
    process(clk)
        begin
        if clk'event and clk = '1' then
            if en = '1' then
                if we = '1' then
                    RAM(conv_integer(addr)) <= di;
                    do                      <= di after 2ns;
                else
                    do <= RAM(conv_integer(addr)) after 2ns;
                end if;
            end if;
        end if;
    end process;
end memoria_arch;
