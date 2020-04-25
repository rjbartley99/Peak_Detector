library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Comm_Proc is
port(
  clk: in std_ulogic;
  reset: in std_ulogic;
  dataReady: in std_ulogic;
  seqDone: in std_ulogic;
  rxNow: in std_ulogic;
  ovErr: in std_ulogic;
  framErr: in std_ulogic;
  txDone: in std_ulogic;
  byte: in std_ulogic_vector(7 downto 0);
  maxIndex: in std_ulogic_vector(11 downto 0);
  dataResults: in std_ulogic_vector(55 downto 0);
  rxData: in std_ulogic_vector(7 downto 0);
  start: out std_ulogic;
  rxDone: out std_ulogic;
  txNow: out std_ulogic;
  numWords_bcd: out std_ulogic_vector(11 downto 0);
  txData: out std_ulogic_vector(7 downto 0)
  );
end;

ARCHITECTURE myarch OF Comm_Proc IS

  COMPONENT counter
	PORT(
	     clk: in std_ulogic;
             rst: in std_ulogic;
       	     en: in std_ulogic;
             cntOut: out std_ulogic_vector(5 downto 0)
	     );
  END COMPONENT;
  SIGNAL rst0, en0:STD_uLOGIC;
  SIGNAL cnt0Out:STD_uLOGIC_VECTOR(5 downto 0);
  
  COMPONENT reg
    PORT(
	 clk: in std_ulogic;
	 regreset: in std_ulogic;
         load: in std_ulogic;
         D: in std_ulogic_vector(7 downto 0);
         Q: out std_ulogic_vector(7 downto 0)
         );
    END COMPONENT;
	SIGNAL regreset0, load0: std_ulogic;
	SIGNAL D0, Q0: std_ulogic_vector(7 downto 0);
  
  FOR cnt0: counter USE ENTITY work.myCounter(Behavioral);
  FOR reg0: reg USE ENTITY work.myRegister(Behavioral);
  
  TYPE state_type IS (INIT, TRANSMIT1, valid_wait, Num_Recog, Word_Num, START1, data_wait, TRANSMIT2, TRANSMIT2_OFF, data_check, Data_Ready); 
  SIGNAL curState, nextState: state_type;


BEGIN
 cnt0: counter PORT MAP(clk, rst0, en0, cnt0Out);
 reg0: reg PORT MAP(clk, regreset0, load0, D0, Q0);
 combi_nextState: PROCESS(curState)
 
   BEGIN
    CASE curState IS
	
	WHEN INIT =>
	 if rxNow = '1' then 
		nextState <= TRANSMIT1;
	 elsif rxNow = '0' then 
		nextState <= INIT;
	 end if; 
	 
	WHEN TRANSMIT1 =>
	 if rxData = "01000001" then --if dataIn = A
	    nextState <= valid_wait;
	 elsif rxData = "01100001" then --if dataIn = a
	    nextState <= valid_wait;
	 else
		nextState <= INIT;
	 end if;
	
	WHEN valid_wait =>
	 if rxNow = '1' then 
		nextState <= Num_Recog;
	 else 
		nextState <= valid_wait;
	 end if;
	 
	WHEN Num_Recog =>
	 if rxData = "00110000" then  --0
		nextState <= Word_Num;
	elsif rxData = "00110001" then --1
		nextState <= Word_Num;
	elsif rxData = "00110010" then --2
		nextState <= Word_Num;
	elsif rxData = "00110011" then --3
		nextState <= Word_Num;
	elsif rxData = "00110100" then --4
		nextState <= Word_Num;
	elsif rxData = "00110101" then --5
		nextState <= Word_Num;
	elsif rxData = "00110110" then --6
		nextState <= Word_Num;
	elsif rxData = "00110111" then --7
		nextState <= Word_Num;
	elsif rxData = "00111000" then --8
		nextState <= Word_Num;
	elsif rxData = "00111001" then --9
		nextState <= Word_Num;
	else 
		nextState <= INIT;
	end if; 
	
	WHEN Word_Num =>
	  if cnt0Out >= "000011" then 
		nextState <= START1;
	  elsif 
             cnt0Out < "000011" then 
		nextState <= valid_wait;
	  end if; 
	  
	WHEN START1 =>
	  nextState <= data_wait;

	WHEN data_wait =>
	  if dataReady = '1' then 
		nextState <= TRANSMIT2; 
	  else 
		null;
          end if;
		
	WHEN TRANSMIT2 =>
	  nextState <= TRANSMIT2_OFF;
	  
	WHEN TRANSMIT2_OFF =>
	  if txDone = '1' then 
	    nextState <= data_check;
	  else 
	    null; 
          end if;
		
	WHEN data_check =>
	  if seqDone = '1' then 
 	    nextState <= Data_Ready; 
	  else 
	    nextState <= TRANSMIT2_OFF;
	  end if; 
	
	WHEN Data_Ready =>
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
  D0 <= "00000000";

  if curState = INIT then 
  --INITIAL CONDITIONS 
  end if;
  
  if curState = TRANSMIT1 then 
  txNow <= '1';
  end if; 
  
  if curState = Num_Recog then 
  txNow <= '1'; 
  end if; 
  
  if curState = Word_Num then 
  load0 <= '1';
  D0 <= rxData;
  en0 <= '1'; -- need to find number of clock cycles for when there are 3 numbers. 
  end if; 
  
  if curState = START1 then 
  start <= '1'; 
  txData <= byte; --NNN
  end if; 
  
  if curState = TRANSMIT2 then 
  txNow <= '1'; 
  end if; 
  
  if curState = TRANSMIT2_OFF then 
  txNow <= '0'; 
  end if; 
  
  END PROCESS; 

  seq_state: PROCESS (clk, reset)
  BEGIN
    if reset = '0' then
      curState <= INIT;
    elsif clk'EVENT AND clk='1' then
      curState <= nextState;
    end if;
  end PROCESS;
end;