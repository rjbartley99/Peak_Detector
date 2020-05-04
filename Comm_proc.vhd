library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.common_pack.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity cmdProc is
port(
 clk:		in std_logic;
 reset:		in std_logic;
 rxnow:		in std_logic;
 rxData:    in std_logic_vector (7 downto 0);
 txData:	out std_logic_vector (7 downto 0);
 rxdone:	out std_logic;
 ovErr:		in std_logic;
 framErr:	in std_logic;
 txnow:		out std_logic;
 txdone:	in std_logic;
 start:     out std_logic;
 numWords_bcd:out BCD_ARRAY_TYPE(2 downto 0);
 dataReady: in std_logic;
 byte:      in std_logic_vector(7 downto 0);
 maxIndex:  in BCD_ARRAY_TYPE(2 downto 0);
 dataResults:in CHAR_ARRAY_TYPE(0 to RESULT_BYTE_NUM-1);
 seqDone:   in std_logic
  );
end;

ARCHITECTURE myarch OF cmdProc IS

  COMPONENT counter
	PORT(
	     clk: in std_logic;
             rst: in std_logic;
       	     en: in std_logic;
             cntOut: out std_logic_vector(5 downto 0)
	     );
  END COMPONENT;
  SIGNAL rst0, en0:STD_LOGIC;
  SIGNAL cnt0Out:STD_LOGIC_VECTOR(5 downto 0);
  
  COMPONENT reg
    PORT(
	 clk: in std_logic;
	 regreset: in std_logic;
         load: in std_logic;
         D: in std_logic_vector(7 downto 0);
         Q: out std_logic_vector(7 downto 0)
         );
    END COMPONENT;
	SIGNAL regreset0, load0: std_logic;
	SIGNAL D0, Q0: std_logic_vector(7 downto 0);
	
	COMPONENT shift
	   PORT (
        shift_in : in std_logic_vector(7 downto 0); -- DATA IN
        en_shift : in std_logic; -- CHIP ENABLE
        load_shift : in std_logic;
        clk : in std_logic; -- CLOCK
        shift_out : out BCD_ARRAY_TYPE(2 downto 0) -- SHIFTER OUTPUT
        );
    END COMPONENT;
    SIGNAL shift_in: std_logic_vector(7 downto 0);              
    SIGNAL shift_out: BCD_ARRAY_TYPE(2 downto 0);
    SIGNAL en1, load1 : std_logic;
   
  COMPONENT byteMux
     Port ( 
    clk : in std_logic;
    data : in std_logic_vector(3 downto 0);
    address : in std_logic_vector(5 downto 0);
    q: out  std_logic_vector(7 downto 0)
);
  END COMPONENT;   
  SIGNAL data: std_logic_vector(3 downto 0);
  SIGNAL address: std_logic_vector(5 downto 0);   
  SIGNAL q: std_logic_vector(7 downto 0);
     
     
  FOR cnt0: counter USE ENTITY work.myCounter(Behavioral); 
  FOR reg0: reg USE ENTITY work.myRegister(Behavioral);
  FOR shift0: shift USE ENTITY work.shift(shift_arch);  
  FOR mux1: bytemux USE ENTITY work.bytemux(mux);
 
  TYPE state_type IS (STATE1,INIT,COUNT_CHECK, A_CHECK, NUM_CHECK, ERROR, CORRECT_WORD, 
  SHIFTER, WAIT_SHIFT, FORMAT1, SPACE , EQUALS, SLASH, nSTATE, rSTATE, FORMAT2, FORMAT3, 
  WAIT_FORMAT, START1, DATA_WAIT, WAIT_BYTE, LOAD_BYTE, BYTE1, TRANSMIT1, WAIT_TX, LOAD_BYTE2, BYTE2, TRANSMIT2, SEQ_CHECK); 
  SIGNAL curState, nextState: state_type;


BEGIN 
 cnt0: counter PORT MAP(clk, rst0, en0, cnt0Out);
 reg0: reg PORT MAP(clk, regreset0, load0, D0, Q0); 
 shift0: shift PORT MAP(shift_in,en1,load1,clk,shift_out);
 mux1: ByteMUX PORT MAP(clk,data,address,q);
 
 combi_nextState: PROCESS(curState, rxNow, rxData, cnt0Out,txdone,dataready)
  BEGIN    
    CASE curState IS
	
	WHEN STATE1 =>
	nextState <= INIT;
	
	WHEN INIT =>
	 if rxNow = '1' then 
		nextState <= COUNT_CHECK;
	 else 
		nextState <= curState;
	 end if; 
	 
	WHEN COUNT_CHECK =>
	 if cnt0Out = "000000" then
	    nextState <= A_CHECK;
	 else
		nextState <= NUM_CHECK;
	 end if;
	 
	WHEN A_CHECK =>
	 if rxData = "01000001" then --if dataIn = A
	    nextState <= CORRECT_WORD;
	 elsif rxData = "01100001" then --if dataIn = a
	    nextState <= CORRECT_WORD;
	 else
		nextState<= ERROR;
	 end if;
	 
	WHEN NUM_CHECK =>
	 if rxData = "00110000" then  --0
		nextState <= CORRECT_WORD;
	elsif rxData = "00110001" then --1
		nextState <= CORRECT_WORD;
	elsif rxData = "00110010" then --2
		nextState <= CORRECT_WORD;
	elsif rxData = "00110011" then --3
		nextState <= CORRECT_WORD;
	elsif rxData = "00110100" then --4
		nextState <= CORRECT_WORD;
	elsif rxData = "00110101" then --5
		nextState <= CORRECT_WORD;
	elsif rxData = "00110110" then --6
		nextState <= CORRECT_WORD;
	elsif rxData = "00110111" then --7
		nextState <= CORRECT_WORD;
	elsif rxData = "00111000" then --8
		nextState <= CORRECT_WORD;
	elsif rxData = "00111001" then --9
		nextState <= CORRECT_WORD;
	else 
		nextState <= INIT;
	end if; 
	
	WHEN ERROR => 
		nextState <= INIT;
	
	WHEN CORRECT_WORD =>
	  if (cnt0Out <= "000011") and (cnt0Out > "000000" ) then
	  nextState <= SHIFTER;                                 
	  elsif 
      cnt0Out = "000000" then 
      nextState <= INIT;
	  else
	  nextState <= curState;
	  end if; 
 
   WHEN SHIFTER =>
	 if cnt0Out >= "000100" then 
	 NextState <= WAIT_SHIFT;        
	 else  
	   nextState <= INIT;
	 end if;
	
	WHEN WAIT_SHIFT =>
	  nextState <= FORMAT1;

	WHEN FORMAT1 =>
	  if txdone = '0' then
	  NextState <= curState; 
	  elsif cnt0Out = "000000" then
	  NextState <= SPACE;
	  elsif cnt0Out = "000001" then
	  NextState <= EQUALS;
	  elsif cnt0Out = "000010" OR cnt0Out = "000100" then
	  NextState <= SLASH;
	  elsif cnt0Out = "000011" then
	  NextState <= nSTATE;
	  elsif cnt0Out = "000101" then
	  NextState <= rSTATE;
	  end if;
	
	WHEN SPACE =>
	  nextState <= FORMAT2;
	
	WHEN EQUALS =>
	  nextState <= FORMAT2;
	
	WHEN SLASH =>
	  nextState <= FORMAT2;
	
	WHEN nSTATE =>
	  nextState <= FORMAT2;
	
	WHEN rSTATE =>
	  nextState <= FORMAT2;
	
	WHEN FORMAT2 =>
	  nextState <= FORMAT3;
	   
	WHEN FORMAT3 =>         
	   if cnt0Out <= "000101" then
	   nextState <= FORMAT1;
	   else
	   nextState <= WAIT_FORMAT;
	   end if;
    
    WHEN WAIT_FORMAT =>
       if txdone = '1' then 
       nextState <= START1;
       else    
	   nextState <= curState; 
	   end if;                
	
	WHEN START1 =>
	  nextState <= DATA_WAIT; 
	
	WHEN DATA_WAIT =>
	  if dataready = '1' then
	  nextState <= WAIT_BYTE;
	  else 
	  nextState <= CurState;
   	  end if;
   	
   	WHEN WAIT_BYTE =>
   	  nextState <= LOAD_BYTE;
   	
   	WHEN LOAD_BYTE =>
   	  nextState <= BYTE1;
   	
   	WHEN BYTE1 =>
	  nextState <= TRANSMIT1;
	  
	WHEN TRANSMIT1 =>
	  nextState <= WAIT_TX; 
          	
	WHEN WAIT_TX =>
	  if txDone = '1' then      
 	    nextState <= LOAD_BYTE2;
	  else
	    nextState <= curState;
	  end if; 
	
	WHEN LOAD_BYTE2 =>
	  nextState <= BYTE2;
	
	WHEN BYTE2 =>
	  nextState <= TRANSMIT2; 
	  
	WHEN TRANSMIT2 =>      
	   nextState <= SEQ_CHECK; 
	
	 WHEN SEQ_CHECK =>    
	    if txDone = '1' then      
 	    nextState <= START1;
	  else
	    nextState <= curState;
	  end if; 
	 
	 WHEN others =>
	   nextState <= INIT;
	
    end CASE;
  end PROCESS; 

  combi_out: PROCESS(curState)
  BEGIN
  
  --inital conditions 
  en0 <= '0';
  rst0 <= '0';
  regreset0 <= '0';
  load0 <= '0';
  load1 <= '0';
  rxdone <= '0';
  txData <= Q0;
  txnow <= '0';
  en1 <= '0';
  shift_in <= rxdata;
  start <= '0';
  numWords_bcd <= shift_out;
  address <= cnt0Out;
  --if curState = INIT then 
  --INITIAL CONDITIONS 
  --end if;
  if curState = STATE1 then
  rst0 <= '1';
  end if;
  
  if curState = COUNT_CHECK then
  D0 <= rxData;
  end if;
  
  if curState = A_CHECK then 
  load0 <= '1';
  end if; 
  
  if curState = NUM_CHECK then 
  load0 <= '1'; 
  end if; 
  
  if curState = ERROR then 
  rst0 <= '1';
  rxdone <= '1';
  txnow <= '0';
  end if; 
  
  if curState = CORRECT_WORD then 
  en0 <= '1';
  rxdone <= '1';-- need to find number of clock cycles for when there are 3 numbers. 
  txnow <= '1';
  end if; 
  
  
  if curState = SHIFTER then
  en1 <= '1';
  end if;

  if curState = WAIT_SHIFT then 
  load1 <= '1'; 
  rst0 <= '1';
  --NNN
  end if; 
  
  if curState = SPACE then
  D0 <= "00100000";
  en0 <= '1';
  end if;
  
  if curState = EQUALS then
  D0 <= "00111101";
  en0 <= '1';
  end if; 
  
  if curState = SLASH then
  D0 <= "01011100";
  en0 <= '1';
  end if;                 
              
  if curState = nSTATE then            
  D0 <= "01101110";
  en0 <= '1';
  end if; 
  
  if curState = rSTATE then
  D0 <= "01110010";
  en0 <= '1';
  end if;                  
                                  
  if curState = FORMAT2 then
  load0 <= '1';
  END IF;
  
  if curState = FORMAT3 then               
  txnow <= '1';              
  END IF;    
                  
  if curState = START1 then  
  start <= '1'; 
  load1 <= '1';              
  rst0 <= '1';
  end if; 
  
  if curState = DATA_WAIT then
  end if;
  
  if curState = WAIT_BYTE then
  data <= byte(7 downto 4);
  end if;
  
  if curState = LOAD_BYTE then
  D0 <= q;
  end if;
  
  if curState = BYTE1 then 
  load0 <= '1';
  end if; 
  
  if curState = TRANSMIT1 then
  txnow <= '1';
  en0 <= '1';
  end if;                 
  
  if curState = WAIT_TX then
  data <= byte(3 downto 0);
  end if;
  
  if curState = LOAD_BYTE2 then
  D0 <= q;
  end if;
  
  if curState = BYTE2 then
  load0 <= '1';
  end if;      
  
  if curState = TRANSMIT2 then
  txnow <= '1';
  end if;                                
                              
  END PROCESS; 

  seq_state: PROCESS (clk, reset)
  BEGIN
    if reset = '1' then
      curState <= STATE1;
    elsif clk'EVENT AND clk='1' then
      curState <= nextState;
    end if;
  end PROCESS;
end;