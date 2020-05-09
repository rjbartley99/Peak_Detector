
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity bytemux is
    Port ( 
        clk : in std_logic;
        data : integer;
        address : in std_logic_vector(7 downto 0);
        q: integer
        );
end bytemux;

architecture mux of convertbyte is

begin
select_int : process (address)
begin
	if (address = "00000000") then
	q <= data/16;
	elsif (address = "00000001") then
	q <= data mod 16;
	end if;

end process select_int;
end mux;

