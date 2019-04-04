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
  -- Signal for state (valid-bit encoding)
  signal v          : std_logic_vector(6 downto 0);

  -- indexes to track location in 256 * 256 array
  signal index_x		: unsigned (7 downto 0);
  signal index_y		: unsigned (7 downto 0);
  
  -- Variables for storing memory blocks
  signal mem_en     : std_logic_vector(2 downto 0); 

  signal mem0	   	  : std_logic_vector(7 downto 0);
  signal mem0_wen   : std_logic;
  
  signal mem1		    : std_logic_vector(7 downto 0);
  signal mem1_wen   : std_logic;
  
  signal mem2	  	  : std_logic_vector(7 downto 0);
  signal mem2_wen   : std_logic;

  -- Inputs for the DFD
  signal a, b, c, d, e, f, g, h, i         : unsigned(11 downto 0);
  -- registers 
  signal r1, r2, r3, r4, r5, r6, r7     : unsigned(11 downto 0);
  signal dir_reg, dir_reg_2             : direction_ty;

  -- Direction signals
  signal dir_max_1, dir_max_2, dir_max_3  : direction_ty;

begin  
  mem0_wen <= mem_en(0) and i_valid;
  mem1_wen <= mem_en(1) and i_valid;
  mem2_wen <= mem_en(2) and i_valid;

  o_row <= index_y;
	o_col <= index_x;
  
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
			
		process begin
			wait until rising_edge(clk);
				if reset = '1' then
					index_x <= "00000000";
					index_y <= "00000000";
          mem_en  <= "001";
          o_mode <= m_reset;
				else
					if i_valid = '1' then
							a <= b;
							b <= c;
							h <= i;
							i <= d;
							g <= f;
							f <= e;
              e <= "0000" & i_pixel;
              
							if mem_en(0) = '1' then
								c <= "0000" & unsigned(mem1);
								d <= "0000" & unsigned(mem2);
							elsif mem_en(1) = '1' then 
								c <= "0000" & unsigned(mem2);
								d <= "0000" & unsigned(mem0);
							else 
								c <= "0000" & unsigned(mem0);
								d <= "0000" & unsigned(mem1);
							end if;
								
							if index_x = "11111111" AND index_y = "11111111" then 
								index_x <= "00000000"; 
								index_y <= "00000000";
                mem_en <= mem_en rol 1;
                o_mode <= m_idle;

							elsif index_x = "11111111" then
								index_y <= index_y + 1; 
                index_x <= "00000000"; 
                mem_en <= mem_en rol 1;
                o_mode <= m_busy;
              else 
                index_x <= index_x + 1;
                o_mode <= m_busy;
							end if;
					end if;
			end if;
		end process;
		
    process begin 
      wait until rising_edge(clk);
        if v(0) = '1' then
							r1 <= a + h; 
							if g >= b then 
								r2 <= g + a + h;	
								dir_max_1 <= dir_w;															
							else 
								r2 <= b + a + h;								
								dir_max_1 <= dir_nw;		
							end if;
        elsif v(1) = '1' then
						r1 <= r1 + b + c;
            r3 <= r2; 
   
						if a >= d then 
							r2 <= a + b + c;	
							dir_max_2 <= dir_n;															
						else 
							r2 <= d + b + c;								
							dir_max_2 <= dir_ne;		
						end if;
        elsif v(2) = '1' then
						r1 <= r1 + d + e;				
						if r3 >= r2 then 
							r3 <= r3;	
							dir_reg_2 <= dir_max_1;
						else 
							r3 <= r2;	
							dir_reg_2 <= dir_max_2;
						end if;
						if c >= f then 
              r2 <= c + d + e;									
              dir_reg <= dir_e;
						else 
              r2 <= f + d + e;	
              dir_reg	<= dir_se	;
						end if;						
        elsif v(3) = '1' then						
						r4 <= r1 + f + g;
						r5 <= r3; 
						if e >= h then 
							r6 <= e + f + g;
							dir_max_1 <= dir_s;		
						else 
							r6 <= h + f + g;
							dir_max_1 <= dir_sw;		
						end if;
						r7 <= r2; 
        end if;

        if v(4) = '1' then 
						r4 <= r4 + (r4 sll 1); 
						r5 <= r5; 							 
             if r7 >= r6 then 
              r6 <= r7;
							dir_max_3 <= dir_reg;	
						else 
              r6 <= r6;
              dir_max_3 <= dir_max_1;	
						end if;
        elsif v(5) = '1' then
							r5 <= r4; 					
							if r5 >= r6 then 
								r4 <= r5 sll 3;
								dir_max_3 <= dir_reg_2;		
							else 
								r4 <= r6 sll 3;
								dir_max_3 <= dir_max_3;		
							end if;
        elsif v(6) = '1' then
              if (r4 - r5) > "000101111111" then -- This number is 383 represented in 12 bits
                o_valid <= '1'; 
                o_edge <= '1';
                o_dir <= dir_max_3; 
              else 
                o_valid <= '1';
                o_edge  <= '0'; 
                o_dir   <= "000"; 
              end if; 
				end if;
      	if v(6) /= '1' then
						o_valid <= '0'; 
					end if;
    end process;
		
		process begin 
      wait until rising_edge(clk);	
			if index_x >= 2 and index_y >= 2 then
        v(0) <= i_valid;	
      else 
        v(0) <= '0';
			end if;
      v(6 downto 1) <= v(5 downto 0);	
		end process;
		
end architecture;