module my9262
(
	//输入端口
	CLK_200M,RST_N,
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
input						CLK_200M;			
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
reg			[31:0]	shift_reg;			
reg			[31:0]	shift_reg_n;		
reg			[ 4:0]	time_cnt;			
reg			[ 4:0]	time_cnt_n;		
reg						my9262_Lat_N;		
reg						my9262_Dclk_N;		
//reg						my9262_Di_N;		
//reg						my9262_Command;			
//reg						my9262_Command_N;
reg						my9262_Pwm;
reg						my9262_Pwm_N;			
reg			[3:0]		pwm_Count;				
reg			[3:0]		pwm_Count_N;				
//reg			[9:0]		grayScaleLatch;				
//reg			[9:0]		grayScaleLatch_N;				
reg			[4:0]		overrallLatch;				
reg			[4:0]		overrallLatch_N;			
parameter				Period = 4'd5;		

parameter				twLat = 4'd10,tsuLat = 1'd1,thLat = 3'd4;
parameter				twDck = 3'd3,twDck_Half = 3'd1;
parameter				twGck = 3'd3;	
parameter				tsuDi = 1'd1,thDi = 1'd1;
parameter				thCm = 3'd3;

//parameter				single_Data = 10'd17;
reg			[9:0]		single_Data;				
reg			[9:0]		single_Data_N;	

parameter				my9262_Fsm_Idle 			= 3'd0;		
parameter				my9262_Fsm_Ready 			= 3'd1;			
parameter				my9262_Fsm_Send_Data 	= 3'd2;
parameter				my9262_Fsm_Wait 			= 3'd3;
parameter				my9262_Fsm_Latch 			= 3'd4;
parameter				my9262_Fsm_Finish			= 3'd5;

reg			[ 3:0]	command_Fsm_Cs;		
reg			[ 3:0]	command_Fsm_Ns;	
reg			[ 4:0]	lat_1_Times;
reg			[ 4:0]	lat_1_Times_N;	
reg			[ 4:0]	lat_2_Times;
reg			[ 4:0]	lat_2_Times_N;	
reg			[ 3:0]	edge_Times;
reg			[ 3:0]	edge_Times_N;	
reg			[ 5:0]	config_Times;
reg			[ 5:0]	config_Times_N;
				
parameter				command_Fsm_Config		= 3'd0;
parameter				command_Fsm_Data 			= 3'd1;				

parameter				lat_Fsm_Idle   			= 3'h0;		
parameter				lat_Fsm_Wait 				= 3'h1;
parameter				lat_Fsm_Overrall_Latch 	= 3'h2;			

parameter				data_Fsm_Config 			= 3'h0;
parameter				data_Fsm_Send 				= 3'h1;	
reg			[ 3:0]	data_Fsm_Cs;		
reg			[ 3:0]	data_Fsm_Ns;
reg			[ 4:0]	data_Times;
reg			[ 4:0]	data_Times_N;				

parameter 				my9262_Number = 6'd32;
//时序电路,用来给data_Fsm_Cs寄存器赋值
always @ (posedge CLK_200M or negedge RST_N)
begin	
	if(!RST_N)						
		data_Fsm_Cs <= data_Fsm_Config;			
	else
		data_Fsm_Cs <= data_Fsm_Ns;			
end

//组合电路,用来实现状态机
always @ (*)
begin
	case(data_Fsm_Cs)							                         
		data_Fsm_Config:
			if(data_Times == my9262_Number - 1)//
				data_Fsm_Ns = data_Fsm_Send;								
			else			
				data_Fsm_Ns = data_Fsm_Cs;		
		
		data_Fsm_Send:
			if(1)
				data_Fsm_Ns = data_Fsm_Send;								
			else			
				data_Fsm_Ns = data_Fsm_Cs;
		
		default:my9262_Fsm_Ns = command_Fsm_Config;
	endcase		
end

//时序电路,用来给data_Times寄存器赋值
always @ (posedge CLK_200M or negedge RST_N)
begin
	if(!RST_N)					
		data_Times <= 6'd0;		
	else
		data_Times <= data_Times_N;		
end

//组合电路,用于记录时钟个数的计数器   
always @ (*)
begin
	if(data_Fsm_Cs == data_Fsm_Send)				
		data_Times_N = 6'd0;
	else if(my9262_Fsm_Cs == my9262_Fsm_Finish)
		data_Times_N = data_Times + 6'd1;
	else
		data_Times_N = data_Times;
end

//时序电路,用来给command_Fsm_Cs寄存器赋值
always @ (posedge CLK_200M or negedge RST_N)
begin	
	if(!RST_N)						
		command_Fsm_Cs <= command_Fsm_Config;			
	else
		command_Fsm_Cs <= command_Fsm_Ns;			
end

//组合电路,用来实现状态机
always @ (*)
begin
	case(command_Fsm_Cs)							                         
		command_Fsm_Config:
			if(config_Times == my9262_Number)//
				command_Fsm_Ns = command_Fsm_Data;								
			else			
				command_Fsm_Ns = command_Fsm_Cs;		
		
		command_Fsm_Data:
			if(1)
				command_Fsm_Ns = command_Fsm_Data;								
			else			
				command_Fsm_Ns = command_Fsm_Cs;
		
		default:my9262_Fsm_Ns = command_Fsm_Config;
	endcase		
end

//时序电路,用来给single_Data寄存器赋值
always @ (posedge CLK_200M or negedge RST_N)
begin
	if(!RST_N)					
		single_Data <= 10'd0;		
	else
		single_Data <= single_Data_N;		
end

//组合电路,用于记录时钟个数的计数器   
always @ (*)
begin
	if(command_Fsm_Cs == command_Fsm_Config)				
		single_Data_N = 10'd17;
	else
		single_Data_N = 10'd33;//
end

//时序电路,用来给lat_Times寄存器赋值
always @ (posedge CLK_200M or negedge RST_N)
begin
	if(!RST_N)					
		lat_1_Times <= 5'd0;		
	else
		lat_1_Times <= lat_1_Times_N;		
end

//组合电路,用于记录时钟个数的计数器   
always @ (*)
begin
	if(command_Fsm_Cs == command_Fsm_Config)				
		lat_1_Times_N = 5'd1;
	else
		lat_1_Times_N = 5'd16;
end

//时序电路,用来给lat_Times寄存器赋值
always @ (posedge CLK_200M or negedge RST_N)
begin
	if(!RST_N)					
		lat_2_Times <= 5'd0;		
	else
		lat_2_Times <= lat_2_Times_N;		
end

//组合电路,用于记录时钟个数的计数器   
always @ (*)
begin
	if(command_Fsm_Cs == command_Fsm_Config)				
		lat_2_Times_N = 5'd0;
	else
		lat_2_Times_N = 5'd16;
end

//时序电路,用来给edge_Times寄存器赋值
always @ (posedge CLK_200M or negedge RST_N)
begin
	if(!RST_N)					
		edge_Times <= 4'd0;		
	else
		edge_Times <= edge_Times_N;		
end

//组合电路,用于记录时钟个数的计数器   
always @ (*)
begin
	if(command_Fsm_Cs == command_Fsm_Config)				
		edge_Times_N = 4'd11;
	else
		edge_Times_N = 4'd3;
end

//时序电路,用来给config_Times寄存器赋值
always @ (posedge CLK_200M or negedge RST_N)
begin
	if(!RST_N)					
		config_Times <= 6'd0;		
	else
		config_Times <= config_Times_N;		
end

//组合电路,用于记录时钟个数的计数器   
always @ (*)
begin
	if(command_Fsm_Cs == command_Fsm_Data)				
		config_Times_N = 6'd0;
	else if(my9262_Fsm_Cs == my9262_Fsm_Finish)
		config_Times_N = config_Times + 6'd1;
	else
		config_Times_N = config_Times;
end

//时序电路,用来给time_cnt寄存器赋值
always @ (posedge CLK_200M or negedge RST_N)
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
	else if(my9262_Dclk != my9262_Dclk_N)
		time_cnt_n = 2'h0;
	else
		time_cnt_n = time_cnt + 2'h1;
end

//时序电路,用来给bit_cnt寄存器赋值
always @ (posedge CLK_200M or negedge RST_N)
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
always @ (posedge CLK_200M or negedge RST_N)
begin
	if(!RST_N)							
		shift_reg <= 32'h0;			
	else
		shift_reg <= shift_reg_n;	
end

//组合电路,移位寄存器,将my9262_Data的数据依次移给my9262_Di
always @ (*)
begin
	if(my9262_Fsm_Cs != my9262_Fsm_Send_Data)	
		begin
			if(data_Fsm_Cs != data_Fsm_Send)	
				shift_reg_n = 32'h0EA00000;//my9262_Data//0AA0//增益101010
			else
				shift_reg_n = 32'h00FF00FF;
		end		
	else if(my9262_Dclk && (!my9262_Dclk_N))// &&  && (time_cnt == 4'h0)
		shift_reg_n = {shift_reg[30:0] , 1'h0};
	else
		shift_reg_n = shift_reg;	
end

//时序电路,用来给lat_Fsm_Cs寄存器赋值
always @ (posedge CLK_200M or negedge RST_N)
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
			if(lat_Fsm_Cs == lat_Fsm_Idle)
				lat_Fsm_Ns = lat_Fsm_Wait;	
			else
				lat_Fsm_Ns = lat_Fsm_Cs;			                         

		lat_Fsm_Wait://5'd16//10'd13
			if((overrallLatch == lat_2_Times || overrallLatch == lat_1_Times) && bit_cnt == single_Data - edge_Times)
				lat_Fsm_Ns = lat_Fsm_Overrall_Latch;								
			else			
				lat_Fsm_Ns = lat_Fsm_Cs;		
		
		lat_Fsm_Overrall_Latch:
			if(my9262_Fsm_Cs == my9262_Fsm_Latch)
				lat_Fsm_Ns = lat_Fsm_Idle;								
			else			
				lat_Fsm_Ns = lat_Fsm_Cs;
		
		default:my9262_Fsm_Ns = my9262_Fsm_Idle;
	endcase		
end

//时序电路,用来给time_cnt寄存器赋值
always @ (posedge CLK_200M or negedge RST_N)
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

//时序电路,用来给my9262_Lat寄存器赋值
always @ (posedge CLK_200M or negedge RST_N)
begin
	if(!RST_N)							
		my9262_Lat <= 1'h0;				
	else
		my9262_Lat <= my9262_Lat_N;				
end

//组合电路,用来生成my9262_Lat的片选波形
always @ (*)                             
begin
	if((lat_Fsm_Cs == lat_Fsm_Overrall_Latch) || (my9262_Fsm_Cs == my9262_Fsm_Latch))
		my9262_Lat_N = 1'h1;
	else
		my9262_Lat_N = 0;			
end

//时序电路,用来给my9262_Dclk 寄存器赋值
always @ (posedge CLK_200M or negedge RST_N)
begin
	if(!RST_N)
		my9262_Dclk <= 1'h0; 
	else
		my9262_Dclk <= my9262_Dclk_N; 
end

//组合电路,用来生成my9262_Dclk的时钟波形
always @ (*)
begin
	if(my9262_Fsm_Cs == my9262_Fsm_Send_Data && lat_Fsm_Cs != lat_Fsm_Overrall_Latch)
		begin
			if((!my9262_Dclk) && (time_cnt == twDck))
				my9262_Dclk_N = 1'h1; 
			else if((my9262_Dclk) && (time_cnt == twDck))
				my9262_Dclk_N = 1'b0; 
		end
	else if(lat_Fsm_Cs == lat_Fsm_Overrall_Latch)
		begin
			if((!my9262_Dclk) && (time_cnt == twDck + 2))
				my9262_Dclk_N = 1'h1; 
			else if((my9262_Dclk) && (time_cnt == twDck))
				my9262_Dclk_N = 1'b0; 
		end		
	else
		my9262_Dclk_N = my9262_Dclk;
end
//时序电路,用来给my9262_Fsm_Cs寄存器赋值
always @ (posedge CLK_200M or negedge RST_N)
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
			if(time_cnt == 4'h0)			
				my9262_Fsm_Ns = my9262_Fsm_Send_Data;	
			else
				my9262_Fsm_Ns = my9262_Fsm_Cs;				

		my9262_Fsm_Send_Data: 
			if((bit_cnt == single_Data - 10'd1))//
				my9262_Fsm_Ns = my9262_Fsm_Wait;				
			else
				my9262_Fsm_Ns = my9262_Fsm_Cs;
				
		my9262_Fsm_Wait: 
			if(time_cnt == 4'h1)		
				my9262_Fsm_Ns = my9262_Fsm_Latch;		
			else
				my9262_Fsm_Ns = my9262_Fsm_Cs;
				
		my9262_Fsm_Latch: 
			if(time_cnt == tsuLat + twLat + thLat)		
				my9262_Fsm_Ns = my9262_Fsm_Finish;		
			else
				my9262_Fsm_Ns = my9262_Fsm_Cs;
				
		my9262_Fsm_Finish: 
			if(time_cnt == 4'h0)
				my9262_Fsm_Ns = my9262_Fsm_Idle;		
			else
				my9262_Fsm_Ns = my9262_Fsm_Cs;		
		
		default:my9262_Fsm_Ns = my9262_Fsm_Idle;
	endcase
end

//时序电路,用来给time_cnt寄存器赋值
always @ (posedge CLK_200M or negedge RST_N)
begin
	if(!RST_N)								
		pwm_Count <= 4'b0;					
	else
		pwm_Count <= pwm_Count_N;			
end

//组合电路,判断频率,让定时器累加 
always @ (*)
begin
	if(pwm_Count == Period)						
		pwm_Count_N = 4'b0;				
	else
		pwm_Count_N = pwm_Count + 1'b1;		

end

//时序电路,用来给beep_reg寄存器赋值
always @ (posedge CLK_200M or negedge RST_N)
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
assign my9262_Di = shift_reg[31];	
//assign send_finish = (my9262_Fsm_Cs == my9262_Fsm_Idle);	

endmodule
