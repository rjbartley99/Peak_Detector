
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity bytemux is
    Port ( 
        clk : in std_logic;
        data : in std_logic_vector(3 downto 0);
        loadDATA : in std_logic;
        q: out std_logic_vector(7 downto 0)
        );
end bytemux;

architecture mux of bytemux is
signal q1 : std_logic_vector(7 downto 0); 

begin

ascii_look : process (data)
begin
    CASE data is
          WHEN "0000" => -- 0
       q1 <= "00110000";
          
          WHEN "0001" => -- 1
       q1 <= "00110001";
           
          WHEN "0010" => -- 2
       q1<= "00110010";
         
          WHEN "0011" => -- 3
       q1 <= "00110011";
         
          WHEN "0100" => -- 4
       q1 <= "00110100";
           
          WHEN "0101" => -- 5
       q1 <= "00110101";
         
          WHEN "0110" => -- 6
       q1 <= "00110110";
           
          WHEN "0111" => -- 7
       q1 <= "00110111";
          
          WHEN "1000" => -- 8
       q1 <= "00111000";
          
          WHEN "1001" => -- 9
       q1 <= "00111001";
           
          WHEN "1010" => --A   
       q1 <= "01000001";
         
          WHEN "1011" => --B
       q1 <= "01000010";
           
          WHEN "1100" => --C
       q1 <= "01000011";
         
          WHEN "1101" => --D
       q1 <= "01000100";
          
          WHEN "1110" => --E
       q1 <= "01000101";
         
          WHEN "1111" => --F
       q1 <= "01000110";
                
           WHEN others =>
           null;
       end case;
end process ascii_look;

    PROCESS(clk)
    begin
     if rising_edge(clk) and  loadDATA = '1' then 
       q <= q1;
     else 
       null;
     end if;
   end PROCESS;

end mux;

