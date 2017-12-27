module  my9262
(
	//时钟复位
	csi_clk,rsi_reset_n,
	//Avalon-MM从端口
	avs_address,avs_write,avs_writedata,
	//外设管脚输出，my9262控制接口
	coe_clk_240m,coe_my9262_Lat,coe_my9262_Dclk,coe_my9262_Gck,coe_my9262_Di
);

input         			csi_clk;				//系统时钟
input         			rsi_reset_n;		//系统复位
input 		[ 1:0]	avs_address;		//Avalon地址总线
input						avs_write;			//Avalon写请求信号
input			[31:0]	avs_writedata;		//Avalon写数据总线

input						coe_clk_240m;
output           		coe_my9262_Lat;
output           		coe_my9262_Dclk;
output           		coe_my9262_Gck;                             
output          		coe_my9262_Di;

wire 			[15:0]	my9262_Data;		//my9262发送的16位数据
wire						my9262_Start;

my9262_logic	my9262_logic_init
(
	.CLK_240M		(coe_clk_240m		),	//系统时钟
	.RST_N			(rsi_reset_n		),	//系统复位
	.my9262_Lat		(coe_my9262_Lat	),	//my9262的时钟信号	
	.my9262_Dclk	(coe_my9262_Dclk	),	//my9262的时钟信号
	.my9262_Gck		(coe_my9262_Gck	),	//my9262的数据信号
	.my9262_Di		(coe_my9262_Di		),	//my9262的片选信号
	.my9262_Data	(my9262_Data		),	//my9262发送的16位数据
	.my9262_Start	(my9262_Start		)	//my9262发送开始位
);

my9262_register	my9262_register_init
(
	.csi_clk			(csi_clk				),	//系统时钟
	.rsi_reset_n	(rsi_reset_n		),	//系统复位
	.avs_address	(avs_address		),	//Avalon地址总线
	.avs_write		(avs_write			),	//Avalon写请求信号
	.avs_writedata	(avs_writedata		),	//Avalon写数据总线
	.my9262_Data	(my9262_Data		),	//my9262发送的16位数据
	.my9262_Start	(my9262_Start		)	//my9262发送开始位
);

endmodule
