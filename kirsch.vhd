
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.util.all;
use work.kirsch_synth_pkg.all;

-- package state_pkg is
--   subtype state_ty is std_logic_vector(2 downto 0);
--   constant mem_0 : state_ty := "001";
--   constant mem_1 : state_ty := "010";
--   constant mem_2 : state_ty := "100";
--   constant init  : state_ty := "000";
--   constant wr_mem    : state_ty := "101";
--   constant calc  : state_ty := "111";
-- end state_pkg;

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
begin  
  
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