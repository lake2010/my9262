module my9262_register
(
	//时钟复位
	csi_clk,rsi_reset_n,
	//Avalon-MM从端口
	avs_address,avs_write,avs_writedata,
	//用户逻辑输入与输出
	my9262_Data,my9262_Start
);
 
input 					csi_clk;		
input						rsi_reset_n;	
input			[ 1:0]	avs_address;	
input						avs_write;		
input			[31:0]	avs_writedata;

output reg 	[15:0]	my9262_Data;	
reg			[15:0]	my9262_Data_N;	
output reg				my9262_Start;	
reg						my9262_Start_N;
		
//时序电路,用于给tlc5615发送开始位进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)						
		my9262_Start <= 1'b0;					
	else
		my9262_Start <= my9262_Start_N;			
end

//组合电路，用来判断tlc5615发送开始位
always @ (*)
begin
	if((avs_write) && (avs_address == 2'b00))
		my9262_Start_N = 1'b1;			
	else
		my9262_Start_N = 1'b0;				
end

//时序电路,用于给数据寄存器进行赋值的
always @ (posedge csi_clk or negedge rsi_reset_n)
begin
	if(!rsi_reset_n)				
		my9262_Data <= 16'h0000;				
	else
		my9262_Data <= my9262_Data_N;				
end
	
//组合电路，用来给地址偏移量0，也就是我们的数据寄存器写16位的数据
always @ (*)
begin
	if((avs_write) && (avs_address == 2'b01))
		my9262_Data_N = avs_writedata[15:0];
	else
		my9262_Data_N = my9262_Data;					
end

endmodule
