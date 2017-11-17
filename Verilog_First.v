module Verilog_First
(
	//输入端口
	CLK_24M,RST_N,
	//my9262控制接口
	my9262_Lat,my9262_Dclk,my9262_Gck,my9262_Di,
);

input					CLK_24M;
input			 		RST_N;
output           	my9262_Lat;
output           	my9262_Dclk;
output           	my9262_Gck;                             
output          	my9262_Di;

wire					CLK_60M;

my9262 my9262_Init
(
    .CLK_60M		(CLK_60M),
    .RST_N			(RST_N),
    .my9262_Lat	(my9262_Lat),
	 .my9262_Dclk	(my9262_Dclk),
	 .my9262_Gck	(my9262_Gck),
	 .my9262_Di		(my9262_Di)
);

PLL	PLL_inst 
(
	.inclk0 ( CLK_24M ),
	.c0 	  ( CLK_60M )
);
endmodule
		
