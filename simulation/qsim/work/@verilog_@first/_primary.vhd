library verilog;
use verilog.vl_types.all;
entity Verilog_First is
    port(
        altera_reserved_tms: in     vl_logic;
        altera_reserved_tck: in     vl_logic;
        altera_reserved_tdi: in     vl_logic;
        altera_reserved_tdo: out    vl_logic;
        CLK_50M         : in     vl_logic;
        RST_N           : in     vl_logic;
        LED1            : out    vl_logic
    );
end Verilog_First;
