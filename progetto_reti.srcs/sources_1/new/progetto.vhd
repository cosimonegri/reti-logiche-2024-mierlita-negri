library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity progetto is
    port (
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
        o_mem_en : out std_logic
    );
end progetto;

architecture progetto_arch of progetto is
    component contatore is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        zero : in std_logic;
        decrement : in std_logic;
        count : out std_logic_vector(7 downto 0)
    );
    end component contatore;
    
    component registro is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        new_value : in std_logic_vector(7 downto 0);
        enable : in std_logic;
        value : out std_logic_vector(7 downto 0)
    );
    end component registro;
    
    component automa is
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
    end component automa;
    
    signal counter : STD_LOGIC_VECTOR(7 downto 0);
    signal counter_reset : STD_LOGIC;
    signal counter_decr : STD_LOGIC;
    signal counter_zero : STD_LOGIC;
    signal total_counter_rst : std_logic;
    
    signal reg_en : STD_LOGIC;
    signal reg_value : STD_LOGIC_VECTOR(7 downto 0);
    signal reg_new_value : STD_LOGIC_VECTOR(7 downto 0);
    
begin
    
    total_counter_rst <= i_rst or counter_reset;
    
    cont : contatore port map(
        i_clk => i_clk,
        i_rst => total_counter_rst,
        zero => counter_zero,
        decrement => counter_decr,
        count => counter
    );
    
    reg : registro port map(
        i_clk => i_clk,
        i_rst => i_rst,
        new_value => reg_new_value,
        enable => reg_en,
        value => reg_value
    );
    
    asf : automa port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_start => i_start,
        i_add => i_add,
        i_k => i_k,
        o_done => o_done,
        o_mem_addr => o_mem_addr,
        i_mem_data => i_mem_data,
        o_mem_data => o_mem_data,
        o_mem_we => o_mem_we,
        o_mem_en => o_mem_en,
        reg_en => reg_en,
        reg_value => reg_value,
        reg_new_value => reg_new_value,
        counter => counter,
        counter_reset => counter_reset,
        counter_decr => counter_decr,
        counter_zero => counter_zero
    );

end progetto_arch;
