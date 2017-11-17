library verilog;
use verilog.vl_types.all;
entity Verilog_First_vlg_sample_tst is
    port(
        CLK_50M         : in     vl_logic;
        RST_N           : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end Verilog_First_vlg_sample_tst;
