library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use ieee.numeric_std.all;

use work.util.all;
use work.kirsch_synth_pkg.all;

entity kirsch is
  port(
    clk        : in  std_logic;                      
    reset      : in  std_logic;                      
    i_valid    : in  std_logic;                 
    i_pixel    : in  unsigned(7 downto 0);
    o_valid    : out std_logic;                 
    o_edge     : out std_logic;	                     
    o_dir      : out direction_ty;
    o_mode     : out mode_ty;
    o_row      : out unsigned(7 downto 0);
    o_col      : out unsigned(7 downto 0)
  );  
end entity;


architecture main of kirsch is
  -- Signal for state
  -- signal state      : std_logic_vector(7 downto 0);
  signal state 	  	: state_ty;

  -- indexes to track location in 256 * 256 array
  signal index_x		: unsigned (7 downto 0);
  signal index_y		: unsigned (7 downto 0);

  
  -- Variables for storing memory blocks
  signal mem_en     : std_logic_vector(2 downto 0) := "001"; 
  --------------------------------------------------------------
  -- should be moved to the init state 
  --------------------------------------------------------------
  signal mem0	   	  : std_logic_vector(7 downto 0);
  signal mem0_wen   : std_logic;
  
  signal mem1		    : std_logic_vector(7 downto 0);
  signal mem1_wen   : std_logic;
  
  signal mem2	  	  : std_logic_vector(7 downto 0);
  signal mem2_wen   : std_logic;

  --------------------------------------------------------------
  -- Temp var for storing current pixel value
  signal cur_pixel  : unsigned(7 downto 0);  
  --------------------------------------------------------------
  

begin  
  mem0_wen <= mem_en(0) and i_valid;
  mem1_wen <= mem_en(1) and i_valid;
  mem2_wen <= mem_en(2) and i_valid;

  o_row <= index_y;
  
  mem_blk_0 : entity work.mem(main)
	  port map (
		  address 	=> 	index_x,
		  clock  		=>	clk,
		  data   	  =>	std_logic_vector(i_pixel),
		  wren		  =>	mem0_wen,
		  q   	    => 	mem0
	  );
		
	mem_blk_1 : entity work.mem(main)
	  port map (
		  address 	=> 	index_x,
		  clock  		=>	clk,
		  data   	  =>	std_logic_vector(i_pixel),
		  wren		  =>	mem1_wen,	
		  q   	    => 	mem1
	  );
	
	mem_blk_2 : entity work.mem(main)
	  port map (
		  address 	=> 	index_x,
		  clock  		=>	clk,
		  data   	  =>	std_logic_vector(i_pixel),
		  wren		  =>	mem2_wen,	
		  q   	    => 	mem2
    ); 

    dfd  : process  
    begin 
    wait until rising_edge(clk);

      if reset = '1' then
        index_x <= "00000000";
        index_y <= "00000000";
        mem_en  <= "001";
        
        state <= idle;
      else 

      case state is 
        when idle =>
          if i_valid = '0' then 
            state <= idle;
          else 
            cur_pixel <= i_pixel;
            state <= state0;
          end if; 
        
        when state0 =>
          state <= state1;
        when state1 =>
          state <= state2;
        when state2 =>
          state <= state3;
        when state3 =>
          state <= state4;
        when state4 =>
          state <= state5;
        when state5 =>
          state <= state6;
        when state6 =>
          state <= state7;
        when state7 =>
        
          if index_x = "11111111" AND index_y = "11111111" then 
            o_valid <= '1';
            index_x <= "00000000"; 
            index_y <= "00000000";
            mem_en <= "001";

          elsif index_x = "11111111" then
            index_y <= index_y + 1; 
            index_x <= "00000000"; 
            if mem_en = "100" then
              mem_en <= "001";
            else 
              mem_en <= std_logic_vector(unsigned(mem_en) sll 1);
            end if;
          else 
            index_x <= index_x + 1;
          end if;
          state <= idle;

        when others =>
            state <= idle;
      end case;

      end if;
      
    end process;
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.util.all;
use work.kirsch_synth_pkg.all;

entity max is 
  port(
    input_1   : in unsigned(7 downto 0);
    input_2   : in unsigned(7 downto 0);
    inp1_dir  : in direction_ty;
    inp2_dir  : in direction_ty;
   
    out_val   : out unsigned(7 downto 0);
    out_dir   : out direction_ty
  );
end entity;

architecture main of max is 
begin 

  process(input_1, input_2) begin
    if input_1 >= input_2 then 
      out_val <= input_1; 
      out_dir <= inp1_dir; 
    else 
      out_val <= input_2; 
      out_dir <= inp2_dir; 
    end if;
  end process; 

end architecture;