 module my9262
(
	//输入端口
	CLK_60M,RST_N,
	//my9262控制接口
	my9262_Lat,my9262_Dclk,my9262_Gck,my9262_Di,
	//用户逻辑输入与输出
//	my9262_Data,send_start,send_finish
);

 
//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
//input 					send_start; 
//output 				send_finish; 
input						CLK_60M;			
input						RST_N;			
output       reg    	my9262_Lat;
output       reg    	my9262_Dclk;
output           		my9262_Gck;
output          		my9262_Di;
//input			[15:0]	my9262_Data;				
//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg			[ 3:0]	my9262_Fsm_Cs;		
reg			[ 3:0]	my9262_Fsm_Ns;
reg			[ 3:0]	lat_Fsm_Cs;		
reg			[ 3:0]	lat_Fsm_Ns;			
reg			[ 9:0]	bit_cnt;		
reg			[ 9:0]	bit_cnt_n;		
reg			[15:0]	shift_reg;			
reg			[15:0]	shift_reg_n;		
reg			[ 1:0]	time_cnt;			
reg			[ 1:0]	time_cnt_n;		
reg						my9262_Lat_N;		
reg						my9262_Dclk_N;		
//reg						my9262_Di_N;		
//reg						my9262_Command;			
//reg						my9262_Command_N;
reg						my9262_Pwm;
reg						my9262_Pwm_N;			
reg			[1:0]		pwm_Count;				
reg			[1:0]		pwm_Count_N;				
//reg			[9:0]		grayScaleLatch;				
//reg			[9:0]		grayScaleLatch_N;				
reg			[4:0]		overrallLatch;				
reg			[4:0]		overrallLatch_N;			

parameter				Period = 2'd1;		

parameter				my9262_Fsm_Idle 			= 3'h0;		
parameter				my9262_Fsm_Ready 			= 3'h1;			
parameter				my9262_Fsm_Send_Data 	= 3'h2;
parameter				my9262_Fsm_Finish			= 3'h3;

parameter				lat_Fsm_Idle 				= 3'h0;				
parameter				lat_Fsm_Wait				= 3'h1;
parameter				lat_Fsm_GrayScale_Latch = 3'h2;
parameter				lat_Fsm_Overrall_Latch 	= 3'h3;
			
//
//parameter		Write_Data  	 = 4'h0;		
//parameter		Write_GrayScale = 4'h1;			
//parameter		Write_Config  	 = 4'h2;			
//parameter		Read_Config 	 = 4'h4;			

reg			[9:0]		lat_Time;
reg			[9:0]		lat_Time_N;		

//时序电路,用来给time_cnt寄存器赋值
always @ (posedge CLK_60M or negedge RST_N)
begin
	if(!RST_N)					
		time_cnt <= 2'h0;		
	else
		time_cnt <= time_cnt_n;		
end

//组合电路,用于记录时钟个数的计数器   
always @ (*)
begin
	if(my9262_Fsm_Cs != my9262_Fsm_Ns)				
		time_cnt_n = 2'h0;				
	else
		time_cnt_n = time_cnt + 2'h1;
end

//时序电路,用来给bit_cnt寄存器赋值
always @ (posedge CLK_60M or negedge RST_N)
begin
	if(!RST_N)						
		bit_cnt	<= 10'h0;			
	else
		bit_cnt	<= bit_cnt_n;		
end

//组合电路,用来记录数据发送个数的计数器
always @ (*)
begin
	if(my9262_Fsm_Cs != my9262_Fsm_Send_Data)
		bit_cnt_n = 10'h0;				
	else if(my9262_Dclk && (!my9262_Dclk_N))
		bit_cnt_n = bit_cnt + 10'h1;
	else
		bit_cnt_n = bit_cnt;		
end

//时序电路,用来给shift_reg寄存器赋值
always @ (posedge CLK_60M or negedge RST_N)
begin
	if(!RST_N)							
		shift_reg <= 16'h0;			
	else
		shift_reg <= shift_reg_n;	
end

//组合电路,移位寄存器,将my9262_Data的数据依次移给my9262_Di
always @ (*)
begin
	if(my9262_Fsm_Cs == my9262_Fsm_Idle)						
		shift_reg_n = 16'd100;//my9262_Data
	else if((my9262_Fsm_Cs == my9262_Fsm_Send_Data) && my9262_Dclk)// && (time_cnt == 4'h0)
		shift_reg_n = {shift_reg[14:0] , 1'h1};
	else
		shift_reg_n = shift_reg;	
end

//时序电路,用来给lat_Fsm_Cs寄存器赋值
always @ (posedge CLK_60M or negedge RST_N)
begin	
	if(!RST_N)						
		lat_Fsm_Cs <= lat_Fsm_Idle;			
	else
		lat_Fsm_Cs <= lat_Fsm_Ns;			
end

//组合电路,用来实现状态机
always @ (*)
begin
	case(lat_Fsm_Cs)					
		lat_Fsm_Idle: 							
			if(my9262_Fsm_Cs == my9262_Fsm_Send_Data)
				lat_Fsm_Ns = lat_Fsm_GrayScale_Latch;	
			else
				lat_Fsm_Ns = lat_Fsm_Cs;			                         

		lat_Fsm_GrayScale_Latch:
			if(overrallLatch == 5'd15)
				lat_Fsm_Ns = lat_Fsm_Overrall_Latch;								
			else			
				lat_Fsm_Ns = lat_Fsm_Cs;		
		
		lat_Fsm_Overrall_Latch:
			if(my9262_Fsm_Cs == my9262_Fsm_Finish)
				lat_Fsm_Ns = lat_Fsm_Idle;								
			else			
				lat_Fsm_Ns = lat_Fsm_Cs;
		
		default:my9262_Fsm_Ns = my9262_Fsm_Idle;
	endcase		
end

//时序电路,用来给time_cnt寄存器赋值
always @ (posedge CLK_60M or negedge RST_N)
begin
	if(!RST_N)					
		overrallLatch <= 5'd0;		
	else
		overrallLatch <= overrallLatch_N;		
end

//组合电路,用于记录时钟个数的计数器   
always @ (*)
begin
	if(lat_Fsm_Cs == lat_Fsm_Idle)				
		overrallLatch_N = 5'd0;				
	else if(my9262_Fsm_Cs == my9262_Fsm_Finish)
		overrallLatch_N = overrallLatch + 5'd1;
	else
		overrallLatch_N = overrallLatch;
end

//时序电路,用来给time_cnt寄存器赋值
always @ (posedge CLK_60M or negedge RST_N)
begin
	if(!RST_N)					
		lat_Time <= 10'd0;		
	else
		lat_Time <= lat_Time_N;		
end

//组合电路,用于记录时钟个数的计数器   
always @ (*)
begin
	if(lat_Fsm_Cs == lat_Fsm_Overrall_Latch)				
		lat_Time_N = 10'd1;//509				
	else
		lat_Time_N = 10'd0 ;//510
end

//时序电路,用来给my9262_Lat寄存器赋值
always @ (posedge CLK_60M or negedge RST_N)
begin
	if(!RST_N)							
		my9262_Lat <= 1'h0;				
	else
		my9262_Lat <= my9262_Lat_N;				
end

//组合电路,用来生成my9262_Lat的片选波形
always @ (*)                             
begin
	if((my9262_Fsm_Cs == my9262_Fsm_Idle) && (time_cnt == 4'h2))//// &&(!my9262_Dclk)    2
		my9262_Lat_N = 1'h0;
	else if((my9262_Fsm_Cs == my9262_Fsm_Idle) && (!lat_Time))//(my9262_Fsm_Cs == my9262_Fsm_Send_Data) && (bit_cnt == lat_Time) && (my9262_Dclk)	//	my9262_Dclk	
		my9262_Lat_N = 1'h1;
	else if((bit_cnt == 10'd509) && (lat_Time) && (my9262_Dclk))//(my9262_Fsm_Cs == my9262_Fsm_Send_Data)&&   
		my9262_Lat_N = 1'h1;
	else
		my9262_Lat_N = my9262_Lat;			
end

//时序电路,用来给my9262_Dclk 寄存器赋值
always @ (posedge CLK_60M or negedge RST_N)
begin
	if(!RST_N)
		my9262_Dclk <= 1'h0; 
	else
		my9262_Dclk <= my9262_Dclk_N; 
end

//组合电路,用来生成my9262_Dclk的时钟波形
always @ (*)
begin
	if((my9262_Fsm_Cs == my9262_Fsm_Send_Data))
		my9262_Dclk_N = ~my9262_Dclk; 
	else
		my9262_Dclk_N = 1'b0; 
end
//时序电路,用来给my9262_Fsm_Cs寄存器赋值
always @ (posedge CLK_60M or negedge RST_N)
begin	
	if(!RST_N)						
		my9262_Fsm_Cs <= my9262_Fsm_Idle;			
	else
		my9262_Fsm_Cs <= my9262_Fsm_Ns;			
end

//组合电路,用来实现状态机
always @ (*)
begin
	case(my9262_Fsm_Cs)					
		my9262_Fsm_Idle: 							
			if(time_cnt == 4'h2)			
				my9262_Fsm_Ns = my9262_Fsm_Ready;	
			else
				my9262_Fsm_Ns = my9262_Fsm_Cs;		
	                          
		my9262_Fsm_Ready: 
			if(time_cnt == 4'h0)		
				my9262_Fsm_Ns = my9262_Fsm_Send_Data;		
			else
				my9262_Fsm_Ns = my9262_Fsm_Cs;		

		my9262_Fsm_Send_Data: 
			if((bit_cnt == 10'd511) && (!my9262_Dclk))
				my9262_Fsm_Ns = my9262_Fsm_Finish;				
			else
				my9262_Fsm_Ns = my9262_Fsm_Cs;
		
		my9262_Fsm_Finish: 
			if(time_cnt == 4'h0)		//2
				my9262_Fsm_Ns = my9262_Fsm_Idle;		
			else
				my9262_Fsm_Ns = my9262_Fsm_Cs;		
		
		default:my9262_Fsm_Ns = my9262_Fsm_Idle;
	endcase
end

//时序电路,用来给time_cnt寄存器赋值
always @ (posedge CLK_60M or negedge RST_N)
begin
	if(!RST_N)								
		pwm_Count <= 2'b0;					
	else
		pwm_Count <= pwm_Count_N;			
end

//组合电路,判断频率,让定时器累加 
always @ (*)
begin
	if(pwm_Count == Period)						
		pwm_Count_N = 2'b0;				
	else
		pwm_Count_N = pwm_Count + 1'b1;		

end

//时序电路,用来给beep_reg寄存器赋值
always @ (posedge CLK_60M or negedge RST_N)
begin
	if(!RST_N)							
		my9262_Pwm <= 1'b0;				
	else
		my9262_Pwm <= my9262_Pwm_N;			
end

//组合电路,判断频率,使蜂鸣器发声
always @ (*)
begin
	if(pwm_Count == Period)					
		my9262_Pwm_N = ~my9262_Pwm;			
	else
		my9262_Pwm_N = my9262_Pwm;				
end

assign my9262_Gck = my9262_Pwm;
assign my9262_Di = shift_reg[15];	
//assign send_finish = (my9262_Fsm_Cs == my9262_Fsm_Idle);	

endmodule
