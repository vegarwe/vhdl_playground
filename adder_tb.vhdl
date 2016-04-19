library ieee;
    use ieee.numeric_std.all;
    use ieee.std_logic_1164.all;

library OSVVM ;
    use OSVVM.TbUtilPkg.all;
    use OSVVM.CoveragePkg.all;
    use OSVVM.AlertLogPkg.all;
    use OSVVM.TranscriptPkg.all;

library std;
    use std.textio.all;
    use std.env.all;

--  A testbench has no ports.
entity adder_tb is
end adder_tb;

architecture behav of adder_tb is
    --  Declaration of the component that will be instantiated.
    component adder
        port (i0, i1 : in bit; ci : in bit; s : out bit; co : out bit);
    end component;
    --  Specifies which entity is bound with the component.
    for adder_0: adder use entity work.adder;
    signal i0, i1, ci, s, co : bit;
begin
    --  Component instantiation.
    adder_0: adder port map (i0 => i0, i1 => i1, ci => ci,
                            s => s, co => co);

    --  This process does the real job.
    process
        type pattern_type is record
            --  The inputs of the adder.
            i0, i1, ci : bit;
            --  The expected outputs of the adder.
            s, co : bit;
        end record;
        --  The patterns to apply.
        type pattern_array is array (natural range <>) of pattern_type;
        constant patterns : pattern_array :=
                (('0', '0', '0', '0', '0'),
                 ('0', '0', '1', '1', '0'),
                 ('0', '1', '0', '1', '0'),
                 ('0', '1', '1', '0', '1'),
                 ('1', '0', '0', '1', '0'),
                 ('1', '0', '1', '0', '1'),
                 ('1', '1', '0', '0', '1'),
                 ('1', '1', '1', '1', '1'));
        variable l : line;
    begin
        TranscriptOpen("transript");
        SetTranscriptMirror;
        SetAlertLogJustify;
        SetLogEnable(AlertLogId => ALERTLOG_BASE_ID, Level => DEBUG,  Enable => TRUE, DescendHierarchy => TRUE);
        SetLogEnable(AlertLogId => ALERTLOG_BASE_ID, Level => INFO ,  Enable => TRUE, DescendHierarchy => TRUE);
        SetLogEnable(AlertLogId => ALERTLOG_BASE_ID, Level => FINAL,  Enable => TRUE, DescendHierarchy => TRUE);
        SetLogEnable(AlertLogId => ALERTLOG_BASE_ID, Level => PASSED, Enable => TRUE, DescendHierarchy => TRUE);

        Log(ALERTLOG_BASE_ID, "TCR-adsf", FINAL);

        --  Check each pattern.
        for i in patterns'range loop
            --  Set the inputs.
            i0 <= patterns(i).i0;
            i1 <= patterns(i).i1;
            ci <= patterns(i).ci;
            --  Wait for the results.
            wait for 1 ns;
            --  Check the outputs.
            assert s = patterns(i).s
                report "bad sum value" severity error;
            assert co = patterns(i).co
                report "bad carray out value" severity error;
        end loop;

        TranscriptClose;
        std.env.stop(0); --! Gracefully stops the simulation
        --  Wait forever; this will finish the simulation.
        wait;
    end process;
end behav;
