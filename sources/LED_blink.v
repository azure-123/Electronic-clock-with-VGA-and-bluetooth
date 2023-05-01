`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/01 17:02:42
// Design Name: 
// Module Name: LED_blink
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module LED_blink(
    //时钟
    input CLK_100M,
    //小时位
    input [1:0] hour_high,
    input [3:0] hour_low,
    input [2:0] minute_high,
    input [3:0] minute_low,
    input [4:0] alarm,
    //闪动的led灯
    output reg blink
    );
   reg CLK_1;
   reg [10:0] count;
   parameter num_div=1_0000_0000;
   always@(posedge CLK_100M)
   if((hour_high*10+hour_low==alarm)&&minute_high==0&&minute_low==0)
   begin
      blink<=1;
   end
   else
   blink<=0;
endmodule
