library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.util.all;
use work.kirsch_synth_pkg.all;

entity max is 
  port(
    input_1   : in unsigned(8 downto 0);
    input_2   : in unsigned(8 downto 0);
    inp1_dir  : in direction_ty;
    inp2_dir  : in direction_ty;
   
    out_val   : out unsigned(8 downto 0);
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
  -- Signal for state (valid-bit encoding)
  signal v          : std_logic_vector(7 downto 0);

  -- indexes to track location in 256 * 256 array
  signal index_x		: unsigned (7 downto 0);
  signal index_y		: unsigned (7 downto 0);

  
  -- Variables for storing memory blocks
  signal mem_en     : std_logic_vector(2 downto 0); 
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
  -- Inputs for the DFD
  signal a, b, c, d, e, f, g, h         : unsigned(7 downto 0);
  -- registers 
  signal r1, r2, r3, r4, r5, r6, r7     : unsigned(8 downto 0);
  signal dir_reg, dir_reg_2             : direction_ty;
  --------------------------------------------------------------
  -- Signals for max components
  signal max_1_1, max_1_2, max_1_3           : unsigned(8 downto 0);
  signal max_2_1, max_2_2, max_2_3           : unsigned(8 downto 0);
  signal inpd_1_1, inpd_1_2, inpd_1_3        : direction_ty;
  signal inpd_2_1, inpd_2_2, inpd_2_3        : direction_ty;
  
  signal out_vmax_1, out_vmax_2, out_vmax_3  : unsigned(8 downto 0);
  signal out_dmax_1, out_dmax_2, out_dmax_3  : direction_ty;
  --------------------------------------------------------------
  -- Direction signals
  signal dir_max_1, dir_max_2, dir_max_3  : direction_ty;
  --------------------------------------------------------------


begin  
  mem0_wen <= mem_en(0) and i_valid;
  mem1_wen <= mem_en(1) and i_valid;
  mem2_wen <= mem_en(2) and i_valid;
  
  v(0) <= i_valid;

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

    max_1 : entity work.max(main)
      port map (
        input_1   => max_1_1,
        input_2   => max_2_1,
        inp1_dir  => inpd_1_1,
        inp2_dir  => inpd_2_1,
      
        out_val   => out_vmax_1,
        out_dir   => out_dmax_1
      );    

    max_2 : entity work.max(main)
      port map (
        input_1   => max_1_2,
        input_2   => max_2_2,
        inp1_dir  => inpd_1_2,
        inp2_dir  => inpd_2_2,
      
        out_val   => out_vmax_2,
        out_dir   => out_dmax_2
      ); 

    max_3 : entity work.max(main)
      port map (
        input_1   => max_1_3,
        input_2   => max_2_3,
        inp1_dir  => inpd_1_3,
        inp2_dir  => inpd_2_3,
      
        out_val   => out_vmax_3,
        out_dir   => out_dmax_3
      ); 

    process begin 
      wait until rising_edge(clk);

      if reset = '1' then
        index_x <= "00000000";
        index_y <= "00000000";
        mem_en  <= "001";
      else
      
        if v(0) = '1' then
          cur_pixel <= i_pixel;
          if index_y >= 2 then
            
            if mem_en(0) = '1' then
              if index_x mod 3 = "000" then 
                a <= unsigned(mem0); 
                h <= unsigned(mem1);
                g <= unsigned(mem2); 
              elsif index_x mod 3 = "001" then
                b <= unsigned(mem0);
                f <= unsigned(mem2);
              else 
                c <= unsigned(mem0); 
                d <= unsigned(mem1);
                e <= unsigned(mem2);
              end if; 
            elsif mem_en(1) = '1' then 
              if index_x mod 3 = "000" then 
                b <= unsigned(mem0);
                f <= unsigned(mem2);
              elsif index_x mod 3 = "001" then
                c <= unsigned(mem0); 
                d <= unsigned(mem1);
                e <= unsigned(mem2);
              else 
                a <= unsigned(mem0); 
                h <= unsigned(mem1);
                g <= unsigned(mem2); 
            end if; 
            else 
              if index_x mod 3 = "000" then 
                c <= unsigned(mem0); 
                d <= unsigned(mem1);
                e <= unsigned(mem2);
              elsif index_x mod 3 = "001" then
                a <= unsigned(mem0); 
                h <= unsigned(mem1);
                g <= unsigned(mem2); 
              else 
                b <= unsigned(mem0);
                f <= unsigned(mem2);
              end if; 
            end if; 
          end if;
          
          r1 <= ('0' & a) + ('0' & h); 
         
          -- Sending max(g, b); 
          max_1_1 <= '0' & g;
          max_2_1 <= '0' & b;
          inpd_1_1 <= dir_w;
          inpd_2_1 <= dir_nw; 
          
          r2 <= out_vmax_1 + ('0' & a) + ('0' & h);
          dir_max_1 <= out_dmax_1;

          index_x <= index_x + 1;
          
          elsif v(1) = '1' then
            r1 <= r1 + ('0' & b) + ('0' & c);
            r3 <= r2; 
            -- Sending max(a, d) --> max2; 
            max_1_2 <= '0' & a;
            max_2_2 <= '0' & d;
            inpd_1_2 <= dir_n;
            inpd_2_2 <= dir_ne; 
          
            r2 <= out_vmax_2 + ('0' & b) + ('0' & c);
            dir_max_2 <= out_dmax_2; 
        elsif v(2) = '1' then

          r1 <= r1 + ('0' & d) + ('0' & e);
          -- Sending max(r3, r2) --> max2; 
          max_1_2 <= r3;
          max_2_2 <= r2;
          inpd_1_2 <= dir_max_1;
          inpd_2_2 <= dir_max_2; 
        
          r3 <= out_vmax_2;
          dir_max_2 <= out_dmax_2;
          dir_reg_2 <= out_dmax_2;
          -- Sending max(f, c) --> max1; 
          max_1_1 <= '0' & f;
          max_2_1 <= '0' & c;
          inpd_1_1 <= dir_se;
          inpd_2_1 <= dir_e; 
        
          r2 <= out_vmax_1 + ('0' & d) + ('0' & e);
          dir_max_1 <= out_dmax_1; 
          dir_reg <= out_dmax_1; 
          
        elsif v(3) = '1' then
          r4 <= r1 + ('0' & f) + ('0' & g);
          r5 <= r3; 
          -- Sending max(e, h) --> max1; 
          max_1_1 <= '0' & e;
          max_2_1 <= '0' & h;
          inpd_1_1 <= dir_s;
          inpd_2_1 <= dir_sw; 
        
          r6 <= out_vmax_1 + ('0' & f) + ('0' & g);
          dir_max_1 <= out_dmax_1; 

          r7 <= r2; 
        end if;

        if v(4) = '1' then
          
          r4 <= r4 + (r4 sll 1); 
          r5 <= r5; 
          -- Sending max(r6, r7) --> max3; 
           max_1_3 <= r6;
           max_2_3 <= r7;
           inpd_1_3 <= dir_max_1;
           inpd_2_3 <= dir_reg; 
         
           r6 <= out_vmax_3;
           dir_max_3 <= out_dmax_3; 
 
        elsif v(5) = '1' then
          r5 <= r4; 
          
          -- Sending max(r5, r6) --> max3; 
          max_1_3 <= r5;
          max_2_3 <= r6;
          inpd_1_3 <= out_dmax_3;
          inpd_2_3 <= dir_reg_2; 

          r4 <= out_vmax_3 sll 3;
          dir_max_3 <= out_dmax_3; 

        elsif v(6) = '1' then
          r4 <= r5 - r4; 
        elsif v(7) = '1' then
          if r4 >= 383 then 
            o_valid <= '1'; 
            o_edge <= '1';
            o_dir <= dir_max_3; 
          else 
            o_valid <= '1';
            o_edge  <= '0'; 
            o_dir   <= "000"; 
          end if; 

          if index_x = "11111111" AND index_y = "11111111" then 
            o_valid <= '1';
            index_x <= "00000000"; 
            index_y <= "00000000";
            mem_en <= "001";

          elsif index_x = "11111111" and index_y < "11111111" then
            index_y <= index_y + 1; 
            index_x <= "00000000"; 
            if mem_en = "100" then
              mem_en <= "001";
            else 
              mem_en <= std_logic_vector(unsigned(mem_en) sll 1);
            end if;  
          end if;
        end if;
      end if;
      v(7 downto 1) <= v(6 downto 0);	
  
      
      
    end process;
end architecture;


