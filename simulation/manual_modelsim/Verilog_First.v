module Verilog_First
(
	//输入端口
	CLK_50M,RST_N,	
	//输出端口
	LED1		
);
	
//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input 			CLK_50M;					//时钟的端口,开发板用的50M晶振
input				RST_N;					//复位的端口,低电平复位
output			LED1;						//对应开发板上的LED

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg	[26:0]	time_cnt;				//用来控制LED闪烁频率的定时计数器
reg	[26:0]	time_cnt_n;				//time_cnt的下一个状态
reg				led_reg;					//用来控制LED亮灭的显示寄存器
reg				led_reg_n;				//led_reg的下一个状态


//设置定时器的时间为1s,计算方法为  (1*10^6)us / (1/50)us  50MHz为开发板晶振
parameter SET_TIME_1S = 27'd49;		

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//时序电路，用来给time_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)  
begin
	if(!RST_N)								//判断复位
		time_cnt  <=  27'h0;				//初始化time_cnt值
	else
		time_cnt  <=  time_cnt_n;		//用来给time_cnt赋值
end

//组合电路，实现1s的定时计数器
always @ (*)  
begin
	if(time_cnt == SET_TIME_1S)		//判断1s时间
		time_cnt_n = 27'h0;				//如果到达1s,定时计数器将会被清零
	else
		time_cnt_n = time_cnt + 27'h1;//如果未到1s,定时计数器将会继续累加
end

//---------------------------------------------------------------------------
//时序电路，用来给led_reg寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)  
begin
	if(!RST_N)								//判断复位
		led_reg <=  1'b0;					//初始化led_reg值
	else
		led_reg <=  led_reg_n;			//用来给led_reg赋值
end

//组合电路，判断时间，控制LED的亮或灭
always @ (*)  
begin
	if(time_cnt == SET_TIME_1S)		//判断1s时间
		led_reg_n = ~led_reg;			//如果到达1s,显示寄存器将会改变LED的状态
	else
		led_reg_n = led_reg;				//如果未到1s,显示寄存器将会将保持LED的原状态
end

assign LED1 = led_reg;					//最后,将显示寄存器的值赋值给端口LED1

endmodule									

