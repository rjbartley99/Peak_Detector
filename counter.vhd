----------------------------------------------------------------------------------
--
-- Engineer: Oscar Munday and Will Myers
-- 
-- Create Date: 06.05.2020 00:09:09
-- Design Name: main counter for command processor
-- Module Name: mycounter - Behavioral
-- Project Name: Peak Dectector -- Command Processor
-- Description: A 6 bit, edge dependent counter which counts when the enable signal is set high.
-- There are 2 asynchronous resets, one to initalise it and one to set the count to four for use formatting.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity myCounter is
port(
    clk : in std_logic;
    rst : in std_logic;
    rst_to_4 : in std_logic;
    en : in std_logic;
    cntOut : out std_logic_vector(5 downto 0)
    );
end myCounter;

architecture Behavioral of myCounter is
    signal counter, counter_next : std_logic_vector(5 downto 0);
begin
    --aysnchronous reset and reset to four
    --synchronous process to ensure counter is edge driven
    process(clk,rst,rst_to_4)
    begin
           if rst = '1' then
              counter <= "000000";
           elsif rst_to_4 = '1' then
              counter <= "000100";   
           elsif clk'EVENT AND clk='1' then
              counter <= counter_next;
           end if;
    end process;
   
   -- asynchronous enable to increment counter
    counter_comb : process(counter, en)
    begin
        if en = '0' then
              counter_next <= counter;
        elsif counter = "111111" then
              counter_next<= counter;
        else
              counter_next <= std_logic_vector(unsigned(counter) + 1);
        end if;
    end process;
   --output register to prevent glitching
    cntOut_comb : process(counter)
    begin
        cntOut <= counter;
    end process;
end Behavioral;
