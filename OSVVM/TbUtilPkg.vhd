--
--  File Name:         TbUtilPkg.vhd
--  Design Unit Name:  TbUtilPkg
--  Revision:          STANDARD VERSION,  revision 2013.04
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com 
--  Contributor(s):            
--     Jim Lewis      email:  jim@synthworks.com   
--
--  Package Defines
--    
--  Developed for: 
--        SynthWorks Design Inc. 
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    11/1999:  0.1        Initial revision
--                         Numerous revisions for VHDL Testbenches and Verification
--    02/2009:  1.0        First Public Released Version
--    10/2013   2013.10    Split out Text Utilities
--
--
--  Copyright (c) 1999 - 2013 by SynthWorks Design Inc.  All rights reserved.
--
--  Verbatim copies of this source file may be used and 
--  distributed without restriction.   
-- 								 
--  This source file is free software; you can redistribute it  
--  and/or modify it under the terms of the ARTISTIC License 
--  as published by The Perl Foundation; either version 2.0 of 
--  the License, or (at your option) any later version. 						 
-- 								 
--  This source is distributed in the hope that it will be 	 
--  useful, but WITHOUT ANY WARRANTY; without even the implied  
--  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 	 
--  PURPOSE. See the Artistic License for details. 							 
-- 								 
--  You should have received a copy of the license with this source.
--  If not download it from, 
--     http://www.perlfoundation.org/artistic_license_2_0
--
  use std.textio.all ;

library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.std_logic_textio.all ;


package TbUtilPkg is

  -- constant SIM_RES : time := std.env.resolution_limit ;  -- VHDL-2008
  constant SIM_RES : time := 1 ns ;                         -- temporary value

  ------------------------------------------------------------
  -- ZeroOneHot:  
  -- return false when more than one value is a 1
  ------------------------------------------------------------
  function ZeroOneHot (
    constant  val       : in    std_logic_vector
  ) return boolean ;  


  ------------------------------------------------------------
  procedure RequestTransaction (
  ------------------------------------------------------------
    signal Rdy  : Out std_logic ;
    signal Ack  : In  std_logic 
  ) ;


  ------------------------------------------------------------
  procedure WaitForTransaction (
  ------------------------------------------------------------
    signal Clk  : In  std_logic ;
    signal Rdy  : In  std_logic ;
    signal Ack  : Out std_logic 
  ) ;


  ------------------------------------------------------------
  procedure WaitForTransaction (
  -- For clockless models
  ------------------------------------------------------------
    signal Rdy  : In  std_logic ;
    signal Ack  : Out std_logic 
  ) ;


  ------------------------------------------------------------
  procedure StartTransaction (
  -- Set Ack to Model Starting Transaction 
  -- Used for models that switch between multiple record sources 
  --     Example: CPU Normal Cycles  vs Interrupt Handler Cycles
  ------------------------------------------------------------
    signal Ack  : Out std_logic 
  ) ;


  ------------------------------------------------------------
  procedure FinishTransaction (
  -- Set Ack to Model Finished Transaction 
  -- Used for models that switch between multiple record sources 
  --     Example: CPU Normal Cycles  vs Interrupt Handler Cycles
  ------------------------------------------------------------
    signal Ack  : Out std_logic 
  ) ;


  ------------------------------------------------------------
  procedure WaitForTransactionOrIrq (
  -- Wait for Transaction Request or Interrupt
  -- No Ack signaling since if IntReq, need
  ------------------------------------------------------------
    signal Clk     : In  std_logic ;
    signal Rdy     : In  std_logic ;
    signal IntReq  : In  std_logic 
  ) ;


  ------------------------------------------------------------
  Function TransactionPending (
  -- If a transaction is pending, return true
  ------------------------------------------------------------
    signal Rdy     : In  std_logic 
  ) return boolean ;


  ------------------------------------------------------------
  procedure ToggleHS (
  -- Used for openloop, single event handshaking
  ------------------------------------------------------------
    signal Sig  : InOut std_logic 
  ) ;


  ------------------------------------------------------------
  procedure Toggle (
  -- Used for synchronization between processes
  ------------------------------------------------------------
    signal Sig         : InOut std_logic ;
    constant DelayVal  : time := 0 ns 
  ) ;


  ------------------------------------------------------------
  function IsToggle (
  -- Used for openloop, single event handshaking
  ------------------------------------------------------------
    signal Sig  : In std_logic 
  ) return boolean ; 

  ------------------------------------------------------------
  procedure WaitForToggle (
  -- Used for openloop, single event handshaking
  ------------------------------------------------------------
    signal Sig  : In std_logic 
  ) ;

  ------------------------------------------------------------
  procedure WayPointBlock (
  -- Stop until multiple processes have all set Sig to 'H'
  ------------------------------------------------------------
    signal Sig    : InOut std_logic 
  ) ;


  ------------------------------------------------------------
  procedure SyncToClk (  
  -- Wait for a period of time and align to Clk
  ------------------------------------------------------------
    signal Clk        : in std_logic ;
    constant delay    : in time
  ) ; 


  ------------------------------------------------------------
  procedure SyncTo (
  -- Synchronize two processes until both have called SyncTo
  -- Uses multiple signals
  ------------------------------------------------------------
    signal SyncOut   : out std_logic ;
    signal SyncIn    : in  std_logic 
  ) ;


  ------------------------------------------------------------
  procedure SyncTo (
  -- Synchronize two processes until both have called SyncTo
  -- Uses multiple signals
  ------------------------------------------------------------
    signal SyncOut   : out std_logic ;
    signal SyncIn    : in  std_logic_vector 
  ) ;


--
--  Deprecated, retained for older code
--
  alias RequestAction is RequestTransaction [std_logic, std_logic] ;
  alias WaitForRequest is WaitForTransaction [std_logic, std_logic, std_logic] ;
  alias WaitOnToggle is WaitForToggle [std_logic] ;

  ------------------------------------------------------------
  procedure WaitForAck (
  -- For models which run open loop
  ------------------------------------------------------------
    signal Ack  : In  std_logic 
  ) ;


  ------------------------------------------------------------
  procedure StrobeAck (
  -- For models that run open loop
  ------------------------------------------------------------
    signal Ack  : Out std_logic 
  ) ;


end TbUtilPkg ;


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
package body TbUtilPkg is 
  type stdulogic_indexby_stdulogic is array (std_ulogic) of std_ulogic;
  constant toggle_sl_table : stdulogic_indexby_stdulogic := (
      '0'     => '1', 
      'L'     => '1', 
      others  => '0' 
  ); 


  ------------------------------------------------------------
  -- ZeroOneHot:  
  -- return false when more than one value is a 1
  ------------------------------------------------------------
  function ZeroOneHot (
    constant  val       : in    std_logic_vector
  ) return boolean is  
    variable found_one : boolean := FALSE ;
  begin
    for i in val'range loop 
      if val(i) = '1' or val(i) = 'H' then 
        if found_one then 
          return FALSE ; 
        end if ; 
        found_one := TRUE ;
      end if ; 
    end loop ;
    return TRUE ; 
  end function ZeroOneHot ; 


  ------------------------------------------------------------
  procedure RequestTransaction (
  -- Indicate Transaction is Ready in the Record 
  ------------------------------------------------------------
    signal Rdy  : Out std_logic ;
    signal Ack  : In  std_logic 
  ) is
  begin
    -- Record contains new transaction
    Rdy        <= '1' ;

    -- Find Ack low = '0' 
    wait until Ack = '0' ;

    -- Prepare for Next Transaction
    Rdy        <= '0' ;

    -- Transaction Done
    wait until Ack = '1' ;        
  end procedure ;


  ------------------------------------------------------------
  procedure WaitForTransaction (
  -- Wait for Transaction Request
  ------------------------------------------------------------
    signal Clk  : In  std_logic ;
    signal Rdy  : In  std_logic ;
    signal Ack  : Out std_logic 
  ) is
    variable AckTime : time ; 
  begin
    -- End of Previous Cycle.  Signal Done
    Ack        <= '1' ;               --  #6
    AckTime    := NOW ; 

    -- Find Start of Transaction
    if Rdy /= '1' then                --   #2
      wait until Rdy = '1' ; 
    else
      wait for 0 ns ; -- allow Ack to update
    end if ; 
   
    -- align to clock if needed (not back-to-back transactions)
    if NOW /= AckTime then 
      wait until Clk = '1' ;
    end if ; 

    -- Model active and owns the record
    Ack        <= '0' ;               --  #3
  end procedure ;

  
  ------------------------------------------------------------
  procedure WaitForTransaction (
  -- Clockless 
  ------------------------------------------------------------
    signal Rdy  : In  std_logic ;
    signal Ack  : Out std_logic 
  ) is
    variable AckTime : time ; 
  begin
    -- End of Previous Cycle.  Signal Done
    Ack        <= '1' ;               --  #6

    -- Find Start of Transaction
    if Rdy /= '1' then                --   #2
      wait until Rdy = '1' ; 
    else
      wait for 0 ns ; -- allow Ack to update
    end if ; 
   
    -- Model active and owns the record
    Ack        <= '0' ;               --  #3
  end procedure ;


  ------------------------------------------------------------
  procedure WaitForTransactionOrIrq (
  -- Wait for Transaction Request or Interrupt
  -- No Ack signaling since if IntReq, need
  ------------------------------------------------------------
    signal Clk     : In  std_logic ;
    signal Rdy     : In  std_logic ;
    signal IntReq  : In  std_logic 
  ) is
    variable AckTime : time ; 
  begin
    AckTime    := NOW ; 

    -- Find Ready or Interrupt Request
    if (Rdy /= '1' and IntReq /= '1') then 
      wait until Rdy = '1' or IntReq = '1' ; 
    else
      wait for 0 ns ; -- allow Ack to update
   end if ; 

    -- align to clock if Rdy or IntReq does not happen within delta cycles from Ack
    if NOW /= AckTime then 
      wait until Clk = '1' ;
    end if ; 
  end procedure ;

  ------------------------------------------------------------
  Function TransactionPending (
  -- If a transaction is pending, return true
  ------------------------------------------------------------
    signal Rdy     : In  std_logic 
  ) return boolean is
  begin
    return Rdy = '1' ; 
  end function ;

  ------------------------------------------------------------
  procedure StartTransaction (
  -- Set Ack to Model Starting Transaction 
  -- Used for models that switch between multiple record sources 
  --     Example: CPU Normal Cycles  vs Interrupt Handler Cycles
  ------------------------------------------------------------
    signal Ack  : Out std_logic 
  ) is
  begin
    Ack        <= '0' ;
  end procedure ;

  ------------------------------------------------------------
  procedure FinishTransaction (
  -- Set Ack to Model Finished Transaction 
  -- Used for models that switch between multiple record sources 
  --     Example: CPU Normal Cycles  vs Interrupt Handler Cycles
  ------------------------------------------------------------
    signal Ack  : Out std_logic 
  ) is
  begin
    -- End of Cycle
    Ack        <= '1' ;
  end procedure ;


  ------------------------------------------------------------
  procedure ToggleHS (
  -- Used for openloop, single event handshaking
  ------------------------------------------------------------
    signal Sig  : InOut std_logic 
  ) is
  begin
    Sig    <= toggle_sl_table(Sig) ;
    wait for 0 ns ;  -- Sig toggles
    wait for 0 ns ;  -- new values updated into record
  end procedure ;


  ------------------------------------------------------------
  procedure Toggle (
  -- Used for synchronization between processes
  ------------------------------------------------------------
    signal Sig         : InOut std_logic ;
    constant DelayVal  : time := 0 ns 
  ) is
    variable iDelayVal : time ;
  begin
    iDelayVal := DelayVal ; 
    if iDelayVal > SIM_RES then 
      iDelayVal := iDelayVal - SIM_RES ; 
    end if ; 
    case Sig is 
      when '0' | 'L' =>      Sig <= '1' after iDelayVal ;
      when others    =>      Sig <= '0' after iDelayVal ;
    end case ; 

  end procedure ;


  ------------------------------------------------------------
  function IsToggle (
  -- Used for openloop, single event handshaking
  ------------------------------------------------------------
    signal Sig  : In std_logic 
  ) return boolean is 
  begin
    return Sig'event ; 
  end function ;

  ------------------------------------------------------------
  procedure WaitForToggle (
  -- Used for openloop, single event handshaking
  ------------------------------------------------------------
    signal Sig  : In std_logic 
  ) is
  begin
    Wait on Sig ;
  end procedure ;


  ------------------------------------------------------------
  procedure WayPointBlock (
  -- Stop until multiple processes have all set Sig to 'H'
  ------------------------------------------------------------
    signal Sig    : InOut std_logic 
  ) is
  begin
    Sig <= 'H' ; 

    -- Wait until all processes set Sig to H  
    -- Level check not necessary since local value /= H yet
    wait until Sig = 'H' ;

    -- Deactivate and propagate to allow back to back calls
    Sig <= '0' ;
    wait for 0 ns ; 
  end procedure WayPointBlock ; 


  ------------------------------------------------------------
  procedure SyncToClk (  
  -- Wait for a period of time and align to Clk
  ------------------------------------------------------------
    signal Clk        : in std_logic ;
    constant delay    : in time
  ) is
  begin
    if delay > SIM_RES then
      wait for delay - SIM_RES ; 
    end if ; 
    wait until Clk = '1' ;
  end procedure ; -- SyncToClk 


  ------------------------------------------------------------
  procedure SyncTo (  
  -- Synchronize two processes until both have called SyncTo
  -- Uses multiple signals
  ------------------------------------------------------------
    signal SyncOut   : out std_logic ;
    signal SyncIn    : in  std_logic
  ) is
  begin
    -- Activate Rdy 
    SyncOut <= '1' ; 

    -- Make sure our Rdy is seen
    wait for 0 ns ; 

    -- Wait until other process' Rdy is at level 1
    if SyncIn /= '1' then 
       wait until SyncIn = '1' ;
    end if ;

    -- Deactivate Rdy
    SyncOut <= '0' ;
  end ; -- procedure SyncTo


  ------------------------------------------------------------
  procedure SyncTo (  
  -- Synchronize two processes until both have called SyncTo
  -- Uses multiple signals
  ------------------------------------------------------------
    signal SyncOut   : out std_logic ;
    signal SyncIn    : in  std_logic_vector 
  ) is
    constant ALL_ONE : std_logic_vector(SyncIn'Range) := (others => '1');
  begin
    -- Activate Rdy 
    SyncOut <= '1' ; 

    -- Make sure our Rdy is seen
    wait for 0 ns ; 

    -- Wait until all other process' Rdy is at level 1
    if SyncIn /= ALL_ONE then 
       wait until SyncIn = ALL_ONE ;
    end if ;

    -- Deactivate Rdy
    SyncOut <= '0' ;
  end ; -- procedure SyncTo


--
--  Deprecated
--
  ------------------------------------------------------------
  procedure WaitForAck (  -- See Toggle and WaitOnToggle
  -- Pause until Transaction results are in the Record 
  -- Openloop handshanking, only BFM can do flow control 
  ------------------------------------------------------------
    signal Ack  : In  std_logic 
  ) is
  begin
    -- Wait for Model to be done
    wait until Ack = '1' ;  

  end procedure ;

  ------------------------------------------------------------
  procedure StrobeAck ( -- See Toggle and WaitOnToggle
  -- Indicate Transaction results are in the Record 
  -- Openloop handshanking, only BFM can do flow control 
  -- ??Long term, replace with ToggleHS?
  ------------------------------------------------------------
    signal Ack  : Out std_logic 
  ) is
  begin
    -- Model done, drive rising edge on Ack
    Ack        <= '0' ;
    wait for 0 ns ;
    Ack        <= '1' ;
  end procedure ;



end TbUtilPkg ;

