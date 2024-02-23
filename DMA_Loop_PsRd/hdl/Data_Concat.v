`timescale 1ns / 1ps

module Data_Concat #(
	parameter IW_WIDTH=32,
	parameter OW_WIDTH=64
)
(	
	input 						I_Clk		,
	input                   	I_Rst_n		,
	input           			I_Data_De   ,
	input 		 [IW_WIDTH-1:0]	I_Data		,
	output  reg     			O_Data_De   ,            
	output  reg  [OW_WIDTH-1:0] O_Data		
);

			reg  [7:0] 			cnt;


localparam Num = OW_WIDTH/IW_WIDTH;

always@(posedge I_Clk)
	if(I_Rst_n == 1'b0)
		cnt <= 8'd0;
	else if(cnt==Num-1 && I_Data_De == 1'b1)
		cnt <= 8'd0;
	else if(I_Data_De==1'b1 && Num>1 )
		cnt <= cnt + 1'b1;
	else
		cnt <= cnt;

always@(posedge I_Clk)
	if(I_Rst_n == 1'b0)
		O_Data <= {OW_WIDTH{1'b0}};
	else if(I_Data_De == 1'b1 && Num>1 )
		O_Data <= {O_Data[OW_WIDTH-IW_WIDTH-1:0],I_Data};
	else if(Num==1)
		O_Data <= I_Data;
	else
		O_Data <= O_Data;
		
always@(posedge I_Clk)
	if(I_Rst_n == 1'b0)
		O_Data_De <= 1'b0;
	else if(cnt==Num-1&&I_Data_De&&Num>1)
		O_Data_De <= 1'b1;
	else if(Num==1)
		O_Data_De <= I_Data_De;		
	else
		O_Data_De <= 1'b0;	


endmodule
