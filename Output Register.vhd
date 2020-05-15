----------------------------------------------------------------------------------
--
-- Engineer: Oscar Munday and Oscar Fuller
-- 
-- Create Date: 27.03.2020
-- Design Name: Outptut register 
-- Module Name: myRegister - Behavioral
-- Project Name: Peak Dectector -- Command Processor
-- Description: An edge driven register with enable, which has its ouput to connected to the transmitter so that the transmitter
-- may hold the desired output values without requiring the use of latches.
----------------------------------------------------------------------------------


LIBRARY ieee; 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity myRegister is 
port(
  clk: in std_logic;
  regreset: in std_logic;
  load: in std_logic;
  D: in std_logic_vector(7 downto 0);
  Q: out std_logic_vector(7 downto 0)
  );
end myRegister; 

ARCHITECTURE Behavioral of myRegister is
-- sequential process with asynchronous reset and synchronous load for the register
begin
    PROCESS(clk,regreset)
    begin
     if regreset ='1' then
     Q <="11111111";
     elsif rising_edge(clk) and load = '1' then 
       Q <= D;
     else 
       null;
     end if;
   end PROCESS;
end ;