library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity registro is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        
        new_value : in std_logic_vector(7 downto 0);
        enable : in std_logic;
        value : out std_logic_vector(7 downto 0)
    );
end registro;

architecture registro_arch of registro is
    signal stored_value : std_logic_vector(7 downto 0);
begin
    
    value <= stored_value;
    
    process (i_clk, i_rst)
    begin
    
        if i_rst = '1' then
            stored_value <= "00000000"; 
        elsif i_clk'event and i_clk = '1' then
            if enable = '1' then
                stored_value <= new_value;
            end if;
        end if;
        
    end process;

end registro_arch;
