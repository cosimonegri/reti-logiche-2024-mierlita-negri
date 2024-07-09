library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Contatore per il valore di credibilità
entity counter is
    port (
        i_clk : in std_logic; -- segnale di clock
        i_rst : in std_logic; -- segnale di reset per portare il contatore a 31
        
        count : out std_logic_vector(7 downto 0); -- valore del contatore
        decrement : in std_logic; -- segnale per decrementare il contatore
        zero : in std_logic -- segnale per portare il contatore a 0
    );
end counter;

architecture counter_arch of counter is
    signal stored_value : std_logic_vector(7 downto 0); -- valore interno collegato all'output
begin

    count <= stored_value;
    
    process (i_clk, i_rst)
    begin
        if i_rst = '1' then
            stored_value <= "00011111";
            
        elsif i_clk'event and i_clk = '1' then
            
            -- decrementa il contatore se ancora non ha raggiunto lo zero
            if decrement = '1' and stored_value /= "00000000" then
                stored_value <= std_logic_vector(unsigned(stored_value) - "00000001");
            -- porta il contatore a zero
            elsif zero = '1' then
                stored_value <= "00000000";
            end if;
            
        end if;
        
    end process;      

end counter_arch;





library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Automa contenente gran parte della logica di funzionamento
entity fsa is
    port(
        i_clk : in std_logic; -- segnale di clock
        i_rst : in std_logic; -- segnale di reset
        i_start : in std_logic; -- segnale di inizio elaborazione
        i_add : in std_logic_vector(15 downto 0); -- indirizzo della memria in cui comincia la sequenza di dati
        i_k : in std_logic_vector(9 downto 0); -- lunghezza della sequenza
            
        o_done : out std_logic; -- segnale di fine elaborazione
            
        o_mem_addr : out std_logic_vector(15 downto 0); -- indirizzo inviato alla memoria
        i_mem_data : in std_logic_vector(7 downto 0); -- dato ricevuto dalla memoria
        o_mem_data : out std_logic_vector(7 downto 0); -- dato inviato alla memoria
        o_mem_we : out std_logic; -- segnale di enable della memoria
        o_mem_en : out std_logic; -- 0 per leggere della memoria, 1 per scrivere in memoria
           
        counter_count : in std_logic_vector(7 downto 0); -- valore nel contatore
        counter_decr : out std_logic; -- segnale per decrementare il contatore
        counter_reset : out std_logic; -- segnale per portare il contatore a 31
        counter_zero : out std_logic -- segnale per portare il contatore a 0
    );
end fsa;

architecture fsa_arch of fsa is
    type state_type is ( RESET, WAIT_RAM, READ_RAM, WRITE_VAL, WRITE_CRED, REQ_RAM, DONE); -- tutti i possibili stati dell'automa
    signal state : state_type; -- stato corrente dell'automa
    signal mem_offset : unsigned(15 downto 0); -- spostamento corrente rispetto all'indirizzo iniziale della memoria
    signal last_value :  std_logic_vector(7 downto 0); -- ultimo valore letto dalla memoria

begin
    process(i_clk, i_rst)
        variable next_state : state_type; -- stato successivo dell'automa
        
        begin
            if i_rst = '1' then
                o_mem_en <= '0';
                o_mem_we <= '0';
                o_done <= '0';
                state <= RESET;
                
            elsif i_clk'event and i_clk = '1' then
                case state is
                    
                    -- stato iniziale
                    when RESET =>
                        o_mem_en <= '0';
                        o_mem_we <= '0';
                        o_done <= '0';
                        mem_offset <= (others => '0');
                        last_value <= (others => '0');
                        counter_reset <= '1';
                        counter_zero <= '0';
                        counter_decr <= '0';
                        -- l'elaborazione comincia ma la sequenza è vuota
                        if i_start = '1' and i_k = "0000000000" then
                            o_done <= '1';
                            next_state := DONE;
                        -- l'elaborazione comincia e viene richiesto il primo valore alla RAM
                        elsif i_start = '1' then
                            o_mem_en <= '1';
                            o_mem_we <= '0';
                            o_mem_addr <= std_logic_vector(unsigned(i_add) + mem_offset);
                            next_state := WAIT_RAM;
                        else
                            next_state := RESET;
                        end if;
                    
                    -- attende il valore richiesto alla RAM 
                    when WAIT_RAM =>
                        o_mem_en <= '0';
                        o_mem_we <= '0';
                        o_done <= '0';
                        next_state := READ_RAM;
                    
                    -- legge il valora richiesto alla RAM e aggiorna il contatore
                    when READ_RAM =>
                        o_mem_en <= '0';
                        o_mem_we <= '0';
                        o_done <= '0';
                        -- se il valore è nullo ed è il primo della sequenza, azzera il contatore 
                        if i_mem_data = "00000000" and last_value = "00000000" then
                            counter_reset <= '0';
                            counter_zero <= '1';
                            counter_decr <= '0';
                        -- se il valore è nullo ma non è il primo della sequenza, decrementa il contatore
                        elsif i_mem_data = "00000000" and last_value /= "00000000" then
                            counter_reset <= '0';
                            counter_zero <= '0';
                            counter_decr <= '1';
                        -- se il valore non è nullo, lo salva come ultimo valore letto e resetta il contatore 
                        else
                            counter_reset <= '1';
                            counter_zero <= '0';
                            counter_decr <= '0';
                            last_value <= i_mem_data;
                        end if;
                        next_state := WRITE_VAL;
                    
                    -- scrive l'ultimo valore non nullo nella RAM
                    when WRITE_VAL =>
                        o_mem_en <= '1';
                        o_mem_we <= '1';
                        o_mem_addr <= std_logic_vector(unsigned(i_add) + mem_offset);
                        o_mem_data <= last_value;
                        mem_offset <= mem_offset + 1;
                        counter_reset <= '0';
                        counter_zero <= '0';
                        counter_decr <= '0';
                        o_done <= '0';
                        next_state := WRITE_CRED;
                    
                    -- scrive la credibilità (valore del contatore) nella RAM
                    when WRITE_CRED =>
                        o_mem_en <= '1';
                        o_mem_we <= '1';
                        o_mem_addr <= std_logic_vector(unsigned(i_add) + mem_offset);
                        o_mem_data <= counter_count;
                        mem_offset <= mem_offset + 1;
                        counter_reset <= '0';
                        counter_zero <= '0';
                        counter_decr <= '0';
                        o_done <= '0';
                        next_state := REQ_RAM;
                    
                    -- se presente richiede il valore successivo alla RAM, altrimenti termina l'elaborazione
                    when REQ_RAM =>
                        -- continua l'elaborazione e richiede il dato successivo alla RAM
                        if mem_offset < 2 * unsigned(i_k) then
                            o_mem_en <= '1';
                            o_mem_we <= '0';
                            o_mem_addr <= std_logic_vector(unsigned(i_add) + mem_offset);                        
                            o_done <= '0';
                            
                            counter_reset <= '0';
                            counter_zero <= '0';
                            counter_decr <= '0';
                            
                            next_state := WAIT_RAM;
                        -- fine della sequenza raggiunta
                        else
                            o_mem_en <= '0';
                            o_mem_we <= '0';
                            o_done <= '1';
                            next_state := DONE;
                        end if;
                    
                    -- stato finale
                    -- imposta o_done = '1' in attesa che arrivi i_start = '0'
                    when DONE =>
                        o_mem_en <= '0';
                        o_mem_we <= '0';
                        last_value <= "00000000";
                        if i_start = '0' then
                            o_done <= '0';
                            next_state := RESET;
                        else
                            o_done <= '1';
                            next_state := DONE;
                        end if;
                end case;
            
                state <= next_state; -- aggiorna lo stato dell'automa ad ogni ciclo di clock       
            end if;
            
    end process;
end fsa_arch;





library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entitità che collega l'automa e il contatore.
entity project_reti_logiche is
    port (
        i_clk : in std_logic; -- segnale di clock
        i_rst : in std_logic; -- segnale di reset
        i_start : in std_logic; -- segnale di inizio elaborazione
        i_add : in std_logic_vector(15 downto 0); -- indirizzo della memria in cui comincia la sequenza di dati
        i_k : in std_logic_vector(9 downto 0); -- lunghezza della sequenza
        
        o_done : out std_logic; -- segnale di fine elaborazione
        
        o_mem_addr : out std_logic_vector(15 downto 0); -- indirizzo inviato alla memoria
        i_mem_data : in std_logic_vector(7 downto 0); -- dato ricevuto dalla memoria
        o_mem_data : out std_logic_vector(7 downto 0); -- dato inviato alla memoria
        o_mem_we : out std_logic; -- segnale di enable della memoria
        o_mem_en : out std_logic -- 0 per leggere della memoria, 1 per scrivere in memoria
    );
end project_reti_logiche;

architecture project_reti_logiche_arch of project_reti_logiche is
    signal counter_count : std_logic_vector(7 downto 0); -- valore del contatore
    signal counter_decr : std_logic; -- segnale per decrementare il contatore
    signal counter_zero : std_logic; -- segnale per portare il contatore a 0
    
    signal counter_reset : std_logic;  -- segnale usato dall'automa per resettare il contatore
    
    signal total_counter_rst : std_logic; -- segnale di reset del contatore, pilotato dal segnale di reset globale o dall'automa
begin
    
    total_counter_rst <= i_rst or counter_reset;
    
    -- collega project_reti_logiche al contatore
    counter : entity work.counter(counter_arch) port map (
        i_clk => i_clk,
        i_rst => total_counter_rst,
        
        count => counter_count,
        decrement => counter_decr,
        zero => counter_zero
    );
    
    -- collega project_reti_logiche all'automa
    fsa : entity work.fsa(fsa_arch) port map (
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
        
        counter_count => counter_count,
        counter_reset => counter_reset,
        counter_decr => counter_decr,
        counter_zero => counter_zero
    );

end project_reti_logiche_arch;