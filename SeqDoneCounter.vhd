----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.05.2020 20:02:09
-- Design Name: 
-- Module Name: SeqDoneCounter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seqdonecounter is
port(
    clk : in std_logic;
    rst : in std_logic;
    en : in std_logic;
    SEQcntOut : out std_logic_vector(1 downto 0)
    );
end seqdonecounter;

architecture Behavioral of seqdonecounter is
    signal counter, counter_next : std_logic_vector(1 downto 0);
begin
    process(clk,rst)
    begin
           if rst = '1' then
              counter <= "00";
           elsif clk'EVENT AND clk='1' then
              counter <= counter_next;
           end if;
    end process;

    counter_comb : process(counter, en)
    begin
        if en = '0' then
              counter_next <= counter;
        elsif counter = "11" then
              counter_next<= counter;
        else
              counter_next <= std_logic_vector(unsigned(counter) + 1);
        end if;
    end process;

    cntOut_comb : process(counter)
    begin
        SEQcntOut <= counter;
    end process;
end Behavioral;

