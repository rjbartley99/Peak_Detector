LIBRARY ieee; 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity myRegister is 
port(
  clk: in std_ulogic;
  regreset: in std_ulogic;
  load: in std_ulogic;
  D: in std_ulogic_vector(7 downto 0);
  Q: out std_ulogic_vector(7 downto 0)
  );
end myRegister; 

ARCHITECTURE Behavioral of myRegister is

begin
    PROCESS(clk, load)
    begin
     if rising_edge(clk) and load = '1' then 
       Q <= D;
     else 
       null;
     end if;
   end PROCESS;
end ;