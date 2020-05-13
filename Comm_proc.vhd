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
 -- MAIN COUNTER FOR SYSTEM, used in ANNN and for iterating through the FORMATMUX lookup table
  COMPONENT counter
	PORT (
     clk: in std_logic;
     rst: in std_logic;
     rst_to_4 : in std_logic;
     en: in std_logic;
     cntOut: out std_logic_vector(5 downto 0)
     );
     END COMPONENT;
     SIGNAL rst0,rstcnt_to_4, en0:STD_LOGIC; 
     SIGNAL cnt0Out:STD_LOGIC_VECTOR(5 downto 0);

 --OUTPUT REGISTER to store values for outputting to Tx
  COMPONENT reg
    PORT (
	 clk: in std_logic;
	 regreset: in std_logic;
     load: in std_logic;
     D: in std_logic_vector(7 downto 0);
     Q: out std_logic_vector(7 downto 0)
     );
     END COMPONENT;
     SIGNAL regreset0, load0: std_logic;
     SIGNAL D0, Q0: std_logic_vector(7 downto 0);
	
  --SHIFT REGISTER to store NNN and output to NUMWORDs
  COMPONENT shift
	 PORT (
      shift_in : in std_logic_vector(7 downto 0); -- DATA IN
      en_shift : in std_logic; -- CHIP ENABLE
      load_shift : in std_logic;
      clk : in std_logic; -- CLOCK
      shift_out : out BCD_ARRAY_TYPE(2 downto 0); -- SHIFTER OUTPUT
      shift_reset : in std_logic
      );
      END COMPONENT;
      SIGNAL shift_in: std_logic_vector(7 downto 0);              
      SIGNAL shift_out: BCD_ARRAY_TYPE(2 downto 0);
      SIGNAL en1, load1, shift_reset : std_logic;
      
  --SECOND COUNTER used to signify final iterations of state machine
  COMPONENT seqdonecounter
    PORT(
     clk : in std_logic;
     rst : in std_logic;
     en : in std_logic;
     SEQcntOut : out std_logic_vector(1 downto 0)
     );
     END COMPONENT;
     SIGNAL rst_SeqDone, en_SeqDone:STD_LOGIC; 
     SIGNAL SEQcntOut:STD_LOGIC_VECTOR(1 downto 0);
      
  -- ASCII look up table for converting 4 bit hexadecimal numbers from byte signal to ASCII
  COMPONENT byteMux
     PORT ( 
      clk : in std_logic;
      data : in std_logic_vector(3 downto 0);
      loadDATA : in std_logic;
      q: out  std_logic_vector(7 downto 0)
      );
      END COMPONENT;   
      SIGNAL data: std_logic_vector(3 downto 0);
      SIGNAL loadDATA: std_logic;   
      SIGNAL q: std_logic_vector(7 downto 0);
      
  -- ASCII look up table for which is used to ouput various different sequences to FORMAT the PuTTY console
  COMPONENT formatmux is
    PORT ( 
        clk : in std_logic;
        countIn : in std_logic_vector(5 downto 0);
        formatout: out std_logic_vector(7 downto 0)
        );
        END COMPONENT; 
        SIGNAL countIn: std_logic_vector(5 downto 0);   
        SIGNAL formatout: std_logic_vector(7 downto 0);
     
     
  FOR cnt0: counter USE ENTITY work.myCounter(Behavioral); 
  FOR reg0: reg USE ENTITY work.myRegister(Behavioral);
  FOR shift0: shift USE ENTITY work.shift(shift_arch);  
  FOR Seqcnt: seqdonecounter USE ENTITY work.seqdonecounter(Behavioral);
  FOR mux1: bytemux USE ENTITY work.bytemux(mux);
  FOR mux2: formatmux USE ENTITY work.formatmux(Behavioral);
 
  TYPE state_type IS (INIT, RXNOW_WAIT, COUNT_CHECK, A_CHECK, NUM_CHECK, ERROR, CORRECT_WORD,  SHIFTER, WAIT_SHIFT, 
  FORMAT1, FORMAT2, FORMAT3, WAIT_FORMAT, FORMAT_CHECK, SEQ_CHECK,NEW_LINE, FINAL_FORMAT,
  START1,DATA_WAIT,WAIT_BYTE, LOAD_BYTE, LAST_BYTE,TRANSMIT1, WAIT_TX, LOAD_BYTE2, TRANSMIT2, WAIT_TX2 ); 
  SIGNAL curState, nextState: state_type;


BEGIN 
 cnt0: counter PORT MAP(clk, rst0, rstcnt_to_4, en0, cnt0Out);
 reg0: reg PORT MAP(clk, regreset0, load0, D0, Q0); 
 shift0: shift PORT MAP(shift_in,en1,load1,clk,shift_out,shift_reset);
 Seqcnt: SeqDoneCounter PORT MAP(clk,rst_SeqDone,en_SeqDone,SEQcntOut);
 mux1: ByteMUX PORT MAP(clk,data,loadDATA,q);
 mux2: formatmux PORT MAP(clk,countIn,formatout);
 
 combi_nextState: PROCESS(curState, rxNow, rxData, cnt0Out,txdone,dataready,SEQcntOut)
  BEGIN    
    CASE curState IS
	
	WHEN INIT =>
	nextState <= RXNOW_WAIT;
	
	WHEN RXNOW_WAIT =>
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
	 if (rxData >= "00110000") and (rxData <= "00111001") then  --0
		nextState <= CORRECT_WORD;
	else 
		nextState <= ERROR;
	end if; 
	
	WHEN ERROR => 
     nextState <= RXNOW_WAIT;
	  
	WHEN CORRECT_WORD =>
	  if (cnt0Out <= "000011") and (cnt0Out > "000000" ) then
	  nextState <= SHIFTER;                                 
	  elsif 
      cnt0Out = "000000" then 
      nextState <= RXNOW_WAIT;
	  else
	  nextState <= curState;
	  end if; 
 
   WHEN SHIFTER =>
	 if cnt0Out >= "000100"  then 
	 NextState <= WAIT_SHIFT;        
	 else  
	   nextState <= RXNOW_WAIT;
	 end if;
	
	WHEN WAIT_SHIFT => -- waiting for the transmitter to finish transmitting last N from ANNN before outputting 
	 if txdone ='1' then
	  nextState <= FORMAT1;
    else
	  nextState <= curState;
	  end if; 
	  
	WHEN FORMAT1 =>
	  nextState <= FORMAT2;
	   
	WHEN FORMAT2 =>         
	   nextState <= FORMAT3;
	   
	WHEN FORMAT3 =>         
	   nextState <= WAIT_FORMAT;
    
    WHEN WAIT_FORMAT => -- waiting for the transmitter to finish transmitting 
       if txdone = '1' then 
       nextState <= FORMAT_CHECK;
       else    
	   nextState <= curState; 
	   end if;
	
	WHEN FORMAT_CHECK =>
	  if SEQcntOut = "10" and (cnt0Out = "001000") then --waits until "\r\n" has been outputted in Tx until returning to intialised state
	    nextState <= INIT;
	  elsif cnt0Out > "001000" then -- loops in intial formatting states until cnt = 8 and " == \r\n " is outputted and then outputs just a space between bytes        
	   nextState <= SEQ_CHECK;
	   else
	   nextState <= FORMAT1;
	   end if; 
	
	WHEN SEQ_CHECK =>    
	  if SEQcntOut = "01" then
	    nextState <= FINAL_FORMAT;
	  elsif cnt0Out = "011101" then --IF COUNT == 29, THERE HAVE BEEN 20 BYTES => NEW LINE FOR BYTES IN PUTTY 
	    nextState <= NEW_LINE;
	  else
	    nextState <= START1; 
	  end if;                 
	
	WHEN NEW_LINE =>
	   nextState <= FORMAT1;
	
	WHEN FINAL_FORMAT =>
	   nextState <= FORMAT1;
	
	WHEN START1 =>
	  nextState <= DATA_WAIT; 
	
	WHEN DATA_WAIT => -- waiting for byte signal to be ready 
	  if dataready = '1' then
	  nextState <= WAIT_BYTE;
	  else 
	  nextState <= CurState;
   	  end if;
   	
   	WHEN WAIT_BYTE =>   -- important delay state to prevent outputting the intialised value of "dd" in the byte line to the transmitter
   	  nextState <= LOAD_BYTE;
   	  
   	WHEN LOAD_BYTE => -- checking if this is the last byte from the data processor
   	  if seqDone = '1' then
	  nextState <= LAST_BYTE; 
	  else
   	  nextState <= TRANSMIT1;
   	  end if;
   	
   	WHEN LAST_BYTE =>
   	  nextState <= TRANSMIT1;
   	 
	WHEN TRANSMIT1 =>
	  nextState <= WAIT_TX; 
          	
	WHEN WAIT_TX => -- waiting for the transmitter to finish transmitting 
	  if txDone = '1' then      
 	    nextState <= LOAD_BYTE2;
	  else
	    nextState <= curState;
	  end if; 
	
	WHEN LOAD_BYTE2 =>
	  nextState <= TRANSMIT2;
	
	WHEN TRANSMIT2 =>      
	   nextState <= WAIT_TX2; 
	
	WHEN WAIT_TX2 => -- waiting for the transmitter to finish transmitting 
	  if txDone = '1' then      
 	    nextState <= FORMAT1;
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
  en1 <= '0';
  en_SeqDone <= '0';
  
  rst0 <= '0';
  rstcnt_to_4 <= '0';
  regreset0 <= '0';
  shift_reset <= '0';
  rst_SeqDone <= '0';
  
  load0 <= '0';
  load1 <= '0';
  loadDATA <= '0';
  
  data <= "0000";
  D0 <= "00000000";
  numWords_bcd <= shift_out;
  shift_in <= rxdata;
  rxdone <= '0';
  txData <= Q0;
  txnow <= '0';
  start <= '0';
  countIn <= cnt0Out;
 
  --INITILASE COMPONENTS
  if curState = INIT then
  rst0 <= '1';
  rst_SeqDone <= '1';
  shift_reset <= '1';
  regreset0 <= '1';
  end if;
  
  --LOAD OUTPUT REGISTER WITH RXINPUT
  if curState = COUNT_CHECK then
  D0 <= rxData;
  load0 <= '1';
  end if;
  
  --SEND TXD to computer
  if curState = A_CHECK then 
  txnow <= '1';
  end if; 
  
  --SEND TXD to computer
  if curState = NUM_CHECK then 
  txnow <= '1'; 
  end if; 
  
  --SIGNAL to reciver that data has been processed
  if curState = ERROR then 
  rxdone <= '1';
    end if; 
  
  --SIGNAL to reciver that data has been processed and count once 
  if curState = CORRECT_WORD then 
  en0 <= '1';
  rxdone <= '1';-- need to find number of clock cycles for when there are 3 numbers. 
    end if; 
  
  -- LOAD current recieved nuumber to shift register LSB and shift previous numbers to left
  if curState = SHIFTER then
  en1 <= '1';
  end if;

--LOAD BCD into output of shifter which is connected to numwords
  if curState = WAIT_SHIFT then 
  load1 <= '1'; 
  rst0 <= '1';
  end if; 
  
  --count up to increment adress in format table
  if curState = FORMAT1 then
  en0 <= '1';
  END IF;
  
  --load output of format table to output register                                 
  if curState = FORMAT2 then
  D0 <= formatout;
  load0 <= '1';
  END IF;
  
  --send txD to computer
  if curState = FORMAT3 then
  txnow <= '1';
  END IF;
  
  --set counter to four so that it runs through the /r/n in the format table to start a line in putty
  if curState = NEW_LINE then
  rstcnt_to_4 <= '1';
  end if;
   
  --set counter to four and count seq counter so that it gets sent back to init after the returning the last line of bytes     
  if curState = FINAL_FORMAT then
  rstcnt_to_4 <= '1';
  en_SeqDone <= '1';
  end if;
  
  if curState = START1 then  
  start <= '1';            
  end if; 
  
  if curState = WAIT_BYTE then
  data <= byte(7 downto 4); -- the four most significant bits of the byte signal which signify the first hexadecimal number being sent to the ASCII look up table in BYTEMUX
  loadDATA <= '1'; -- load output of mux with converted ascii 
  end if;
  
  if curState = LAST_BYTE then
  en_SeqDone <= '1';  -- enabling the seqdonecounter to signify this being the last byte 
  end if;
  
  if curState = LOAD_BYTE then
  D0 <= q;  --ascii output of BYTEMUX being sent to transmitter
  load0 <= '1';
  end if;
  
  if curState = TRANSMIT1 then
  txnow <= '1';
  end if;                 
  
  if curState = WAIT_TX then
  data <= byte(3 downto 0); -- the next four least significant bits of the byte signal which signify the second hexadecimal number being sent to the ASCII look up table in BYTEMUX
  loadDATA <= '1'; -- load output of mux with converted ascii 
  end if;
  
  if curState = LOAD_BYTE2 then 
  D0 <= q; -- ascii output of BYTEMUX being sent to transmitter 
  load0 <= '1';
  end if;
  
  if curState = TRANSMIT2 then
  txnow <= '1';
  end if;                                
                              
  END PROCESS; 

  seq_state: PROCESS (clk, reset) -- sequential process for state machine
  BEGIN
    if reset = '1' then
      curState <= INIT;
    elsif clk'EVENT AND clk='1' then
      curState <= nextState;
    end if;
  end PROCESS;
end;