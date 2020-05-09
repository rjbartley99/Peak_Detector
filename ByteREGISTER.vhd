library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity ByteREG is
Port ( 
    int1 : in std_logic_vector(7 downto 0);
    int2 : in std_logic_vector(7 downto 0);
    address : in std_logic_vector(7 downto 0);
    q: out std_logic_vector(7 downto 0)
);
end ByteREG;