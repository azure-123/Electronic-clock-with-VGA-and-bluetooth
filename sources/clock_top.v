`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/21 19:47:17
// Design Name: 
// Module Name: clock_top
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


module clock_top(
//����ʱ�ӡ���λ�źź�ʹ���ź�
    input CLK_100M,
    input ena,
    input rst,
    
//ʱ����������
    input change, 
    input switch,//ʱ���֡����ֶ���ʱ�л��������
    input time_count,//�����ֶ���ʱ����Ҫ������м�һ����
//���VGA��ɫ����
    output VSYNC,
    output HSYNC,
    output [11:0] VGA_DATA,
//��������
    input get,
    output [4:0] output_clock,
//����
    output blink
    );
    wire [1:0] hour_h;
    wire [3:0] hour_l;
    wire [2:0] minute_h;
    wire [3:0] minute_l;
    wire [2:0] second_h;
    wire [3:0] second_l;
    
    
    
    calculate_time calculate_inst(
                    .CLK_100M(CLK_100M),
                    .ena(ena),
                    .rst(rst),
                    .change(change),
                    .switch(switch),
                    .time_count(time_count),
                    .hour_high(hour_h),
                    .hour_low(hour_l),
                    .minute_high(minute_h),
                    .minute_low(minute_l),
                    .second_high(second_h),
                    .second_low(second_l)
                    );
                    
      VGA_disp vga_inst(
                    .CLK_100M(CLK_100M),
                    .rst(rst),
                    .hour_high(hour_h),
                    .hour_low(hour_l),
                    .minute_high(minute_h),
                    .minute_low(minute_l),
                    .second_high(second_h),
                    .second_low(second_l),
                    .VSYNC(VSYNC),
                    .HSYNC(HSYNC),
                    .VGA_DATA(VGA_DATA)
                    );
                    
       bluetooth blue_inst(
                    .clk(CLK_100M),
                    .rst(rst),
                    .get(get),
                    .output_clock(output_clock)
                    );
                    
        LED_blink LED_inst(
                    .CLK_100M(CLK_100M),
                    .hour_high(hour_h),
                    .hour_low(hour_l),
                    .minute_high(minute_h),
                    .minute_low(minute_l),
                    .alarm(output_clock),
                    .blink(blink)
                    );
       
endmodule
