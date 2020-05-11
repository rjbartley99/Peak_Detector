
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
          WHEN "0000" => 
       q1 <= "00110000";
          
          WHEN "0001" =>
       q1 <= "00110001";
           
          WHEN "0010" => 
       q1<= "00110010";
         
          WHEN "0011" =>
       q1 <= "00110011";
         
          WHEN "0100" =>
       q1 <= "00110100";
           
          WHEN "0101" => 
       q1 <= "00110101";
         
          WHEN "0110" =>
       q1 <= "00110110";
           
          WHEN "0111" => 
       q1 <= "00110111";
          
          WHEN "1000" =>
       q1 <= "00111000";
          
          WHEN "1001" =>
       q1 <= "00111001";
           
          WHEN "1010" => --a    
       q1 <= "01100001";
         
          WHEN "1011" => --b
       q1 <= "01100010";
           
          WHEN "1100" => --c
       q1 <= "01100011";
         
          WHEN "1101" => --d
       q1 <= "01100100";
          
          WHEN "1110" => --e
       q1 <= "01100101";
         
          WHEN "1111" => --f
       q1 <= "01100110";
                
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

