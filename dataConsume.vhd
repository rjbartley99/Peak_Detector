----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.04.2020 16:48:04
-- Design Name: 
-- Module Name: dataConsume - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: dataConsume.vhd
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
use work.common_pack.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dataConsume is
    Port (clk:		in std_logic;
		reset:		in std_logic; -- synchronous reset
		start: in std_logic; -- goes high to signal data transfer
		numWords_bcd: in BCD_ARRAY_TYPE(2 downto 0);
		ctrlIn: in std_logic;
		ctrlOut: out std_logic;
		data: in std_logic_vector(7 downto 0);
		dataReady: out std_logic;
		byte: out std_logic_vector(7 downto 0);
		seqDone: out std_logic;
		maxIndex: out BCD_ARRAY_TYPE(2 downto 0);
		dataResults: out CHAR_ARRAY_TYPE(0 to RESULT_BYTE_NUM-1) -- index 3 holds the peak
    );
end dataConsume;

architecture Behavioral of dataConsume is
type state_type is (IDLE,FETCH,WAIT_DATA,DATA_READY,RECIEVE_DATA,SEQ_DONE);
signal currentstate,nextstate : state_type;
signal data_reg: CHAR_ARRAY_TYPE(0 to 6);
signal maxIndex_Reg: BCD_ARRAY_TYPE(2 downto 0);
signal byteReg: CHAR_ARRAY_TYPE(0 to 3);
signal ctrlIn_delayed, ctrlIn_detected, ctrlOut_reg,numWordCount,Peakdetect,enable_peakcount,Reset_Peakcount,reset_shifter,reset_register,load_left,load_right: std_logic;
signal numWords: BCD_ARRAY_TYPE(2 downto 0);
signal numWords_int,bytecount: integer range 0 to 999;
signal PeakCount: integer range 0 to 4;
begin

-----------------------------------------------------------------------------------------
--STATE PROCESSES

StateTransitions: process(currentState,start,ctrlIn_Detected,numWordCount) 
begin
reset_shifter<='0';
reset_register<='0';
	 -- assign defaults at the beginning to avoid assigning in every branch
    case currentState is
        
        when IDLE => 
        reset_shifter<='1';
        reset_register<='1';
            if start = '1' then
            --Start two phase protocol
                nextState <= FETCH;
            else 
            --Wait for start = 1
                nextState <= IDLE;
            end if;            
            
        when FETCH =>
        --Change CtrlOut and proceed to wait for change in CtrlIn
        nextState <= WAIT_DATA;         
        
        when WAIT_DATA => 
            if ctrlIn_Detected <= '1' then
            --Data on btye line is valid
                nextState <= RECIEVE_DATA;
            else 
            --Wait for change in CtrlIn
                nextState <= WAIT_DATA;
            end if;           
            
        when RECIEVE_DATA =>
            nextState <= DATA_READY;
                        
        when DATA_READY =>
        if numWordcount = '1' then 
            nextState <= SEQ_DONE;
            elsif start ='1' then
            --Requests another byte
                nextState <= FETCH; 
            else 
            --Halts data retrieval while Command Processor communicates with PC
                nextState <= DATA_READY;
            end if;
                       
        when SEQ_DONE =>
        --Restarts system
        nextState <= IDLE;        
        
        when others =>
        nextState <= IDLE;
        end case;       
                
end process;


StateOutputs:	process (currentState)
begin 
case currentState IS
 when DATA_READY => 
 --Update output lines, signal data is valid 
	dataReady <= '1';
	byte <= byteReg(3);
 when SEQ_DONE =>
 --Tell Command Processor all bytes processed and peak found
    seqDone <= '1';
    dataResults<=data_Reg;
    maxIndex <= maxIndex_reg;
 when others =>
    dataReady <='0';
    seqDone <= '0';
  end case;

end process;


StateRegister:	process (clk)
begin
		if rising_edge (clk) then
			if (reset = '1') then
				currentState <= IDLE;
			else
				currentState <= nextState;
			end if;	
		end if;
end process;

-------------------------------------------------------------------------------------
--DATA RETRIEVAL PROCESSES

RequestData: process(clk)
Begin
    if rising_edge(clk) then 
        if reset='1' then
            ctrlOut_reg<='0';
        else
            if currentState = FETCH then
            --Chane on CtrlOut to start hand-shaking protocol
                ctrlOut_reg <= not ctrlOut_reg;
            else
            --No change in CtrlOut
                ctrlOut_reg<= ctrlOut_reg;
            
            end if;
        end if;
end if;
end process;


Delay_CtrlIn: process(clk)     
begin
    if rising_edge(clk) then
    --Used in XOR to detect a change in CtrlIn
      ctrlIn_delayed <= ctrlIn;
    end if;
end process;  


NumWordsToInteger: process(numwords)
Begin
--Convert BCD to Integer
numWords_int<=100*TO_INTEGER(unsigned(numwords(2)))+10*TO_INTEGER(unsigned(numwords(1)))+TO_INTEGER(unsigned(numwords(0)));
end process;


ByteCounter : process (clk)
begin
	if rising_edge(clk) then
		if reset ='1' then
		--Reset counter
			byteCount <= 0;
		else 	
		    if (byteCount = numWords_int) then
		    --Reset counter
		      byteCount <= 0;
		     elsif currentState = RECIEVE_DATA then
		     --New valid byte received
				    byteCount <= byteCount + 1;
				else 
				--Wait for new byte
				    byteCount <= byteCount;
				end if;
			end if;
		end if;
end process;


SequenceComplete: process(byteCount,numWords_int)
begin 
 if (bytecount = numWords_int) then 
 --Byte Number = NumWords
            numWordCount <= '1';
     else 
     --Byte Number /= NumWords
        numWordCount <= '0';
end if;

end process;

--------------------------------------------------------------------------------------------
--PEAK DETECTION PROCESSES

dataShift: process(clk)
begin
if rising_edge(clk) then  
   if reset = '1' then
   for j in 0 to 3 loop
    byteReg(j) <= (others => '0');
    end loop;
    else 
        if currentState = RECIEVE_DATA then
             byteReg <= byteReg(1 to 3) & data;
        elsif reset_shifter = '1' then 
            for k in 0 to 3 loop
            byteReg(k) <= (others => '0');
            end loop;
        end if;
    end if;
end if;
end process;


dataLatch: process(clk)
begin
if rising_edge(clk) then  
   if reset = '1' then
   for i in 0 to 6 loop
    data_reg(i) <= (others => '0');
    end loop;
    else 
        if load_left = '1' then 
        data_reg(0 to 3) <= byteReg;
        elsif load_right ='1' then 
            data_Reg(4 to 6) <= byteReg(1 to 3);
        elsif reset_register = '1' then 
            for l in 0 to 6 loop
            data_Reg(l) <= (others => '0');
            end loop;
        end if;
    end if;
  end if;
end process;


SignalOutput: process(reset,PeakDetect,PeakCount) 
begin
load_right<='0';
    if reset = '1' then 
        enable_PeakCount <= '0';
        reset_PeakCount <= '0';
    else    
        if Peakdetect ='1' then 
            Enable_peakCount <= '1';
         else 
            if PeakCount = 3 then
                load_right<='1';
                Enable_peakCount<='0';
                Reset_PeakCount <= '1';
            else
                Reset_PeakCount<='0';
            end if;
       end if;
      end if;
end process;


DataCounter: process(clk) 
begin 
if rising_edge(clk) then
    if reset = '1' or PeakDetect = '1' then 
        PeakCount<=0;
     else  
        if reset_peakCount = '1' then 
            peakCount<=0;
        else
            if Enable_PeakCount = '1' then 
                if currentState = RECIEVE_DATA then 
                    PeakCount<=PeakCount+1;
                end if;
        end if;
        end if;
     end if;
 end if;
end process;   
     
     
Comparator: process(byteReg,data_reg,reset) 
begin
load_left<='0';
Peakdetect <= '0';
if TO_INTEGER(unsigned(byteReg(3))) > TO_INTEGER(unsigned(data_reg(3))) then 
    Peakdetect <= '1';
    load_left<='1';
end if;
end process;


Peak_index: process(clk)
begin
if rising_edge(clk) then 
    if reset = '1' then 
    for m in 0 to 2 loop
        maxIndex_Reg(m)<= (others=>'0');
    end loop;
    else    
        if PeakDetect = '1' then 
            MaxIndex_Reg(2) <= std_logic_vector(TO_UNSIGNED(((byteCount-1)/100),4));
            MaxIndex_Reg(1) <= std_logic_vector(TO_UNSIGNED((((byteCount-1) mod 100)/10),4));
            MaxIndex_Reg(0) <= std_logic_vector(TO_UNSIGNED(((byteCount-1) mod 10),4));
         end if;
   end if;
 end if;
end process;
       



  
--High of CtrlIn changes
ctrlIn_detected <= ctrlIn xor ctrlIn_delayed;
--Output to dataGen
ctrlOut <= ctrlOut_reg;
--Sends input to be converted to integer
numWords<=numwords_bcd;

end Behavioral;
