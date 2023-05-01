`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/20 13:58:42
// Design Name: 
// Module Name: Calculate_time
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


module calculate_time(
    //输入时钟、复位信号和使能信号
    input CLK_100M,
    input ena,
    input rst,
    //输入电子钟状态变化所需要的输入信号
    input change,//手动计时
    input switch,//时、分、秒手动计时切换所需的信号
    input time_count,//对于手动计时，需要对其进行加一操作
    //输出时、分、秒的各位
    output [1:0] hour_high,
    output [3:0] hour_low,
    output [2:0] minute_high,
    output [3:0] minute_low,
    output [2:0] second_high,
    output [3:0] second_low
    
    );
    reg [4:0] hour;
    reg [5:0] minute;
    reg [5:0] second;
    parameter num_div=1_0000_0000;
    reg [31:0] count;
    reg CLK_1;
    
    reg [4:0] hour_hand;
    reg [5:0] minute_hand;
    reg [5:0] second_hand;
    
    always@(posedge CLK_100M)
    if(rst)
    begin
        count<=0;
        CLK_1<=0;
    end
    else if(count==num_div/2-1)
        begin
        count<=0;
        CLK_1<=~CLK_1;
        end
    else
        begin
        count<=count+1;
        end
     
        
    always@(posedge CLK_1 or posedge rst)
    if(ena)
    begin
        if(rst)
            begin
                hour<=0;
                minute<=0;
                second<=0;
            end
        else if(change==0)
        begin
            if(second==6'd59)
            begin
                second<=0;
                minute<=minute+1;
                if(minute==6'd59)
                begin
                    minute<=0;
                    hour<=hour+1;
                    if(hour==5'd24)
                    begin
                        hour<=0;
                    end
                    else
                    ;
                end
                else
                ;
            end
            else
            second<=second+1;
        end
        else if(change==1)
        begin
        hour<=hour_hand;
        minute<=minute_hand;
        second<=second_hand;
        end
        end
    else
        begin
        hour<=0;
        minute<=0;
        second<=0;
        end

    reg [2:0] switch_reg;
    
    always@(posedge switch or posedge rst)
    if(rst)
        switch_reg<=0;
    else
    begin
        if(switch_reg==3'd3)
            switch_reg<=0;
        else
            switch_reg<=switch_reg+1;
    end
    
    always@(posedge time_count or posedge rst)
    if(rst)
    begin
        hour_hand<=0;
        minute_hand<=0;
        second_hand<=0;
    end
    else if(change==1)
    begin
        if(switch_reg==0)
        begin
            if(hour_hand==5'd23)
                hour_hand<=0;
            else
                hour_hand<=hour_hand+1;
        end
        else if(switch_reg==3'd1)
        begin
            if(minute_hand==6'd59)
                minute_hand<=0;
            else
                minute_hand<=minute_hand+1;
        end
        else if(switch_reg==3'd2)
        begin
            if(second_hand==6'd59)
                second_hand<=0;
            else
                second_hand<=second_hand+1;
        end
    end
    else
    ;
    
    
    
    assign hour_high=change? hour_hand/5'd10:hour/5'd10;
    assign hour_low=change? hour_hand%5'd10:hour%5'd10;
    assign minute_high=change? minute_hand/6'd10: minute/6'd10;
    assign minute_low=change? minute_hand%6'd10:minute%6'd10;
    assign second_high=change? second_hand/6'd10:second/6'd10;
    assign second_low=change? second_hand%6'd10:second%6'd10;

    
endmodule
