library verilog;
use verilog.vl_types.all;
entity Verilog_First is
    generic(
        SET_TIME_1S     : vl_logic_vector(0 to 26) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi1, Hi0, Hi0, Hi0, Hi1)
    );
    port(
        CLK_50M         : in     vl_logic;
        RST_N           : in     vl_logic;
        LED1            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SET_TIME_1S : constant is 1;
end Verilog_First;
