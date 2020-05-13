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

    cntOut_comb : process(counter)
    begin
        cntOut <= counter;
    end process;
end Behavioral;
