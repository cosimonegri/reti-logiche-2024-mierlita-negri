library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity automa is
    Port(
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_add : in std_logic_vector(15 downto 0);
        i_k : in std_logic_vector(9 downto 0);
       
        o_done : out std_logic;
       
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_data : out std_logic_vector(7 downto 0);
        o_mem_we : out std_logic;
        o_mem_en : out std_logic;
           
        reg_en        : out STD_LOGIC;
        reg_value     : in STD_LOGIC_VECTOR(7 downto 0);
        reg_new_value : out STD_LOGIC_VECTOR(7 downto 0);
        counter       : in STD_LOGIC_VECTOR(7 downto 0);
        counter_reset : out STD_LOGIC;
        counter_decr  : out STD_LOGIC;
        counter_zero  : out STD_LOGIC
        );
end automa;

architecture automa_arch of automa is
    type state_type is( RESET, S0, S1, S2, S3, DONE);
    signal state, next_state : state_type;
    signal j : unsigned(9 downto 0);
    
begin
    process(i_clk, i_rst)
        
        begin
            if i_rst = '1' then
                o_mem_en <= '0';
                o_mem_we <= '0';
                o_done <= '0';
                j <= "0000000000";
                
                state <= RESET;
            elsif i_clk'event and i_clk = '1' then
            case state is
                when RESET =>
                    if i_start = '1' then
                        o_mem_en <= '1';
                        o_mem_we <= '0';
                        o_mem_addr <= std_logic_vector(unsigned(i_add) + j);                        
                        o_done <= '0';
                        counter_reset <= '1';
                        counter_zero <= '0';
                        counter_decr <= '0';
                        reg_en <= '0';
                        next_state <= S0;
                    else
                        next_state <= RESET;
                    end if;
                when S0 =>
                    o_mem_en <= '0';
                    o_mem_we <= '0';
                    o_done <= '0';
                    
                    if j <= unsigned(i_k) then
                        if i_mem_data = "00000000" and reg_value = "00000000" then
                            counter_reset <= '0';
                            counter_zero <= '1';
                            counter_decr <= '0';
                            reg_en <= '0';
                        elsif i_mem_data = "00000000" and not reg_value = "00000000" then
                            counter_reset <= '0';
                            counter_zero <= '0';
                            counter_decr <= '1';
                            reg_en <= '0';
                        else
                            counter_reset <= '1';
                            counter_zero <= '0';
                            counter_decr <= '0';
                            reg_en <= '1';
                            reg_new_value <= i_mem_data;
                        end if;
                        next_state <= S1;
                    else
                        next_state <= DONE;
                    end if;
                when S1 =>
                    o_mem_en <= '1';
                    o_mem_we <= '1';
                    o_mem_addr <= std_logic_vector(unsigned(i_add) + j);
                    j <= j + 1;
                    o_mem_data <= reg_value;
                    
                    counter_reset <= '0';
                    counter_zero <= '0';
                    counter_decr <= '0';
                    reg_en <= '0';
                    o_done <= '0';
                    
                    next_state <= S2;
                when S2 =>
                    o_mem_en <= '1';
                    o_mem_we <= '1';
                    o_mem_addr <= std_logic_vector(unsigned(i_add) + j);
                    j <= j + 1;
                    o_mem_data <= counter;
                    
                    counter_reset <= '0';
                    counter_zero <= '0';
                    counter_decr <= '0';
                    reg_en <= '0';
                    o_done <= '0';
                    
                    next_state <= S3;
                when S3 =>
                    if j <= unsigned(i_k) then
                        o_mem_en <= '1';
                        o_mem_we <= '0';
                        o_mem_addr <= std_logic_vector(unsigned(i_add) + j);                        
                        o_done <= '0';
                        
                        counter_reset <= '0';
                        counter_zero <= '0';
                        counter_decr <= '0';
                        reg_en <= '0';
                        
                        next_state <= S0;
                    else
                        next_state <= DONE;
                        o_mem_en <= '0';
                        o_mem_we <= '0';
                    end if;
                when DONE =>
                    o_mem_en <= '0';
                    o_mem_we <= '0';
                    o_done <= '1';
                    reg_new_value <= "00000000";
                    next_state <= RESET;
            end case;
            state <= next_state;         
            end if;
    end process;
end automa_arch;
