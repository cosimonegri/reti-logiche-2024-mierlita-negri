library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity contatore is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        
        zero : in std_logic;
        decrement : in std_logic;
        count : out std_logic_vector(7 downto 0)
    );
end contatore;

architecture contatore_arch of contatore is
    signal stored_value : std_logic_vector(7 downto 0);
begin

    count <= stored_value;
    
    process (i_clk, i_rst)
    begin
        if i_rst = '1' then
            stored_value <= "00011111";
            
        elsif i_clk'event and i_clk = '1' then
        
            if decrement = '1' and stored_value /= "00000000" then
                stored_value <= std_logic_vector(unsigned(stored_value) - "00000001");
            elsif zero = '1' then
                stored_value <= "00000000";
            end if;
            
        end if;
        
    end process;      

end contatore_arch;
