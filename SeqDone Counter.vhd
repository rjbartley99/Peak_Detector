----------------------------------------------------------------------------------
-- Engineer: Will Myers
-- 
-- Create Date: 21.04.2020
-- Design Name: SeqDone Counter
-- Module Name: seqdonecounter - Behavioral
-- Project Name:Peak Detector - Command Processor
-- Description: 2 bit counter used in the command processor to drive decisions which involve ending the 
-- outputting of bytes and returning the fsm to the initial state ready to recive more input commands

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
    --aysnchronous reset and reset to four
    --synchronous process to ensure counter is edge driven
    process(clk,rst)
    begin
           if rst = '1' then
              counter <= "00";
           elsif clk'EVENT AND clk='1' then
              counter <= counter_next;
           end if;
    end process;
    
   -- asynchronous enable to increment counter
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
    --output register to prevent glitching
    cntOut_comb : process(counter)
    begin
        SEQcntOut <= counter;
    end process;
end Behavioral;

