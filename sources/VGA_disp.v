`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/20 15:21:51
// Design Name: 
// Module Name: VGA_disp
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

//行时序宏定义
`define HSYNC_A	16'd128
`define HSYNC_B	16'd216
`define HSYNC_C	16'd1016
`define HSYNC_D	16'd1056

//列时序宏定义
`define VSYNC_O	16'd4
`define VSYNC_P	16'd27
`define VSYNC_Q	16'd627
`define VSYNC_R	16'd628

//颜色定义
`define WHITE 12'Hfff
`define BLACK 12'H000

module VGA_disp(
    //输入：使能信号、复位信号和时钟
    input rst,//复位信号，高电平有效
    input CLK_100M,
    input [1:0] hour_high,
    input [3:0] hour_low,
    input [2:0] minute_high,
    input [3:0] minute_low,
    input [2:0] second_high,
    input [3:0] second_low, 
    
    //输出：VGA颜色分量
    output reg VSYNC,
    output reg HSYNC,
    output reg [11:0] VGA_DATA
    );
    
    reg[15:0] hsync_cnt;		//水平扫描计数器
    reg[15:0] vsync_cnt;        //垂直扫描计数器
    reg CLK_50M;
    reg vga_data_valid;            //RGB数据信号有效区使能信号 
    //水平扫描(扫描1056个点)
    always@(posedge(CLK_100M))
        begin
            CLK_50M <= ~CLK_50M;
        end
    always@(posedge CLK_50M or posedge rst)
    begin
        if(rst)
            hsync_cnt <= 16'd0;
        else if(hsync_cnt == `HSYNC_D)
            hsync_cnt <= 16'd0;
        else
            hsync_cnt <= hsync_cnt + 16'd1;
    end
    
    
    //垂直扫描(扫描628个点)
    always@(posedge CLK_50M or posedge rst)
    begin
        if(rst)
            vsync_cnt <= 16'd0;
        else if((vsync_cnt == `VSYNC_R) && (hsync_cnt == `HSYNC_D))
            vsync_cnt <= 16'd0;
        else if(hsync_cnt == `HSYNC_D)
            vsync_cnt <= vsync_cnt + 16'd1;
        else 
            vsync_cnt <= vsync_cnt;
    end
    
    //行时序
    always@(posedge CLK_50M or posedge rst)
    begin
        if(rst)
            HSYNC <= 1'b0;
        else if(hsync_cnt < `HSYNC_A)    //a域为0
            HSYNC <= 1'b0;
        else
            HSYNC <= 1'b1;                //其他域为1
    end
    
    //列时序
    always@(posedge CLK_50M or posedge rst)
    begin
        if(rst)
            VSYNC <= 1'b0;
        else if(vsync_cnt < `VSYNC_O)    //o域为0
            VSYNC <= 1'b0;
        else
            VSYNC <= 1'b1;                //其他域为1
    end
    
    //提取显示有效区(q域+c域)
    always@(posedge CLK_50M or posedge rst)
    begin
        if(rst)
            vga_data_valid <= 1'b0;
        else if((hsync_cnt > `HSYNC_B && hsync_cnt < `HSYNC_C) && (vsync_cnt >  `VSYNC_P && vsync_cnt < `VSYNC_Q))    //数据有效区
            vga_data_valid <= 1'b1;
        else
            vga_data_valid <= 1'b0;
    end

    always@(*)
    begin
        if(vga_data_valid)
        begin
            if(vsync_cnt >`VSYNC_P)//显示区
            begin
                if((hsync_cnt>(`HSYNC_B+16'd100))&&(hsync_cnt<(`HSYNC_B+16'd175)))//小时高位显示
                begin
                    if(hour_high==2'd0)//小时高位为0
                    begin
                        if(((hsync_cnt >= (`HSYNC_B+16'd100+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd100+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                        ||((hsync_cnt >= (`HSYNC_B+16'd100+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd100+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                        ||((hsync_cnt >=(`HSYNC_B+16'd100+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd100+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                        ||((hsync_cnt >=(`HSYNC_B+16'd100+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd100+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA<=`WHITE;
                        else
                            VGA_DATA<=`BLACK;
                    end
                    else if(hour_high==2'd1)//小时高位为1
                    begin
                        if((hsync_cnt >= (`HSYNC_B+16'd100+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd100+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            VGA_DATA <= `WHITE;            //显示白色
                        else
                            VGA_DATA <= `BLACK;        //显示黑色
                    end
                    else if(hour_high==2'd2)//小时高位为2
                    begin
                        if(((hsync_cnt >= (`HSYNC_B+16'd100+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd100+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                        ||((hsync_cnt >= (`HSYNC_B+16'd100+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd100+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                        ||((hsync_cnt >=(`HSYNC_B+16'd100+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd100+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                        ||((hsync_cnt >=(`HSYNC_B+16'd100+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd100+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                        ||((hsync_cnt >=(`HSYNC_B+16'd100+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd100+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                             VGA_DATA <= `WHITE;            //显示白色
                        else
                             VGA_DATA <= `BLACK;        //显示黑色 
                    end
                    else
                        VGA_DATA<=`BLACK;
                end
                else if((hsync_cnt>(`HSYNC_B+16'd175))&&(hsync_cnt<(`HSYNC_B+16'd250)))//小时低位显示
                begin   
                   if(hour_low==4'd0)//小时低位为0
                   begin
                        if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA<=`WHITE;
                        else
                            VGA_DATA<=`BLACK;
                   end
                   else if(hour_low==4'd1)//小时低位为1
                   begin
                        if((hsync_cnt >= (`HSYNC_B+16'd175+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            VGA_DATA <= `WHITE;            //显示白色
                        else
                            VGA_DATA <= `BLACK;        //显示黑色 
                   end
                   else if(hour_low==4'd2)//小时低位为2
                   begin
                       if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA <= `WHITE;            //显示白色
                       else
                            VGA_DATA <= `BLACK;        //显示黑色 
                   end
                   else if(hour_low==4'd3)//小时低位为3
                   begin
                       if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA <= `WHITE;            //显示白色
                       else
                            VGA_DATA <= `BLACK;        //显示黑色 
                   end
                   else if(hour_low==4'd4)//小时低位为4
                   begin
                       if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72))))
                            VGA_DATA <= `WHITE;            //显示白色
                       else
                            VGA_DATA <= `BLACK;        //显示黑色 
                      end
                   else if(hour_low==4'd5)//小时低位为5
                   begin
                       if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA <= `WHITE;            //显示白色
                       else
                            VGA_DATA <= `BLACK;        //显示黑色 
                     end
                   else if(hour_low==4'd6)//小时低位为6
                    begin
                        if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                        ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                        ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                        ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                        ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                             VGA_DATA <= `WHITE;            //显示白色
                        else
                             VGA_DATA <= `BLACK;        //显示黑色 
                      end
                   else if(hour_low==4'd7)//小时低位为7
                     begin
                          if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                         ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20))))
                              VGA_DATA<=`WHITE;
                          else
                              VGA_DATA<=`BLACK;
                     end
                   else if(hour_low==4'd8)//小时低位为8
                     begin
                         if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                         ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                         ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                         ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                         ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                              VGA_DATA <= `WHITE;            //显示白色
                         else
                              VGA_DATA <= `BLACK;        //显示黑色 
                       end
                       else if(hour_low==4'd9)//小时低位为9
                        begin
                            if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                            ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                            ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                            ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                                 VGA_DATA <= `WHITE;            //显示白色
                            else
                                 VGA_DATA <= `BLACK;        //显示黑色 
                          end
                   else
                        VGA_DATA<=`BLACK;
                end
                else if((hsync_cnt>(`HSYNC_B+16'd250))&&(hsync_cnt<(`HSYNC_B+16'd325)))//小时与分钟之间的冒号显示
                begin
                    if(((hsync_cnt >= (`HSYNC_B+16'd250+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd250+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd50))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd55)))
                    ||((hsync_cnt >= (`HSYNC_B+16'd250+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd250+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd100))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd105))))
                        VGA_DATA<=`WHITE;       //显示白色
                    else
                        VGA_DATA<=`BLACK;          //显示黑色
                end
                else if((hsync_cnt>(`HSYNC_B+16'd325))&&(hsync_cnt<(`HSYNC_B+16'd400)))//分钟高位显示
                begin   
                   if(minute_high==3'd0)//分钟高位为0
                   begin
                        if(((hsync_cnt >= (`HSYNC_B+16'd325+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd325+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA<=`WHITE;
                        else
                            VGA_DATA<=`BLACK;
                   end
                   else if(minute_high==3'd1)//分钟高位为1
                   begin
                        if((hsync_cnt >= (`HSYNC_B+16'd325+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            VGA_DATA <= `WHITE;            //红色        1110_0000
                        else
                            VGA_DATA <= `BLACK;        //黑色        0000_0000
                   end
                   else if(minute_high==3'd2)//分钟高位为2
                  begin
                      if(((hsync_cnt >= (`HSYNC_B+16'd325+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                      ||((hsync_cnt >= (`HSYNC_B+16'd325+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                           VGA_DATA <= `WHITE;            //显示白色
                      else
                           VGA_DATA <= `BLACK;        //显示黑色 
                  end
                  else if(minute_high==3'd3)//分钟高位为3
                  begin
                      if(((hsync_cnt >= (`HSYNC_B+16'd325+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                      ||((hsync_cnt >= (`HSYNC_B+16'd325+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                           VGA_DATA <= `WHITE;            //显示白色
                      else
                           VGA_DATA <= `BLACK;        //显示黑色 
                  end
                  else if(minute_high==3'd4)//分钟高位为4
                  begin
                      if(((hsync_cnt >= (`HSYNC_B+16'd325+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                      ||((hsync_cnt >= (`HSYNC_B+16'd325+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >= (`HSYNC_B+16'd325+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd325+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72))))
                           VGA_DATA <= `WHITE;            //显示白色
                      else
                           VGA_DATA <= `BLACK;        //显示黑色 
                     end
                  else if(minute_high==4'd5)//分钟高位为5
                  begin
                      if(((hsync_cnt >= (`HSYNC_B+16'd325+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                      ||((hsync_cnt >= (`HSYNC_B+16'd325+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd325+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                           VGA_DATA <= `WHITE;            //显示白色
                      else
                           VGA_DATA <= `BLACK;        //显示黑色 
                    end
                   else
                        VGA_DATA<=`BLACK;
                end
                else if((hsync_cnt>(`HSYNC_B+16'd400))&&(hsync_cnt<(`HSYNC_B+16'd475)))//分钟低位显示
                begin   
                   if(minute_low==0)//分钟低位为0
                   begin
                        if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA<=`WHITE;
                        else
                            VGA_DATA<=`BLACK;
                   end
                   else if(minute_low==4'd1)//分钟低位为1
                   begin
                        if((hsync_cnt >= (`HSYNC_B+16'd400+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            VGA_DATA <= `WHITE;            //红色        1110_0000
                        else
                            VGA_DATA <= `BLACK;        //黑色        0000_0000
                   end
                   else if(minute_low==4'd2)//分钟低位为2
                      begin
                          if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                          ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                               VGA_DATA <= `WHITE;            //显示白色
                          else
                               VGA_DATA <= `BLACK;        //显示黑色 
                      end
                      else if(minute_low==4'd3)//分钟低位为3
                      begin
                          if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                          ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                               VGA_DATA <= `WHITE;            //显示白色
                          else
                               VGA_DATA <= `BLACK;        //显示黑色 
                      end
                      else if(minute_low==4'd4)//分钟低位为4
                      begin
                          if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                          ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72))))
                               VGA_DATA <= `WHITE;            //显示白色
                          else
                               VGA_DATA <= `BLACK;        //显示黑色 
                         end
                      else if(minute_low==4'd5)//分钟低位为5
                      begin
                          if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                          ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                               VGA_DATA <= `WHITE;            //显示白色
                          else
                               VGA_DATA <= `BLACK;        //显示黑色 
                        end
                      else if(minute_low==4'd6)//分钟低位为6
                       begin
                           if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                           ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                           ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                           ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                           ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                                VGA_DATA <= `WHITE;            //显示白色
                           else
                                VGA_DATA <= `BLACK;        //显示黑色 
                         end
                      else if(minute_low==4'd7)//分钟低位为7
                        begin
                             if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20))))
                                 VGA_DATA<=`WHITE;
                             else
                                 VGA_DATA<=`BLACK;
                        end
                      else if(minute_low==4'd8)//分钟低位为8
                        begin
                            if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                            ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                            ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                                 VGA_DATA <= `WHITE;            //显示白色
                            else
                                 VGA_DATA <= `BLACK;        //显示黑色 
                          end
                          else if(minute_low==4'd9)//分钟低位为9
                           begin
                               if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                               ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                               ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                               ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                               ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                                    VGA_DATA <= `WHITE;            //显示白色
                               else
                                    VGA_DATA <= `BLACK;        //显示黑色 
                             end
                   else
                        VGA_DATA<=`BLACK;
                end
                else if((hsync_cnt>(`HSYNC_B+16'd475))&&(hsync_cnt<(`HSYNC_B+16'd550)))//分钟和秒钟之间的冒号
                begin
                    if(((hsync_cnt >= (`HSYNC_B+16'd475+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd475+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd50))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd55)))
                    ||((hsync_cnt >= (`HSYNC_B+16'd475+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd475+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd100))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd105))))
                        VGA_DATA<=`WHITE;
                    else
                        VGA_DATA<=`BLACK;
                end
                else if((hsync_cnt>(`HSYNC_B+16'd550))&&(hsync_cnt<(`HSYNC_B+16'd625)))//秒钟高位显示
                begin   
                   if(second_high==0)//秒钟高位为0
                   begin
                        if(((hsync_cnt >= (`HSYNC_B+16'd550+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd550+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA<=`WHITE;
                        else
                            VGA_DATA<=`BLACK;
                   end
                   else if(second_high==3'd1)//秒钟高位为1
                   begin
                        if((hsync_cnt >= (`HSYNC_B+16'd550+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            VGA_DATA <= `WHITE;            //红色        1110_0000
                        else
                            VGA_DATA <= `BLACK;        //黑色        0000_0000
                   end
                   else if(second_high==3'd2)//秒钟高位为2
                    begin
                     if(((hsync_cnt >= (`HSYNC_B+16'd550+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd550+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                          VGA_DATA <= `WHITE;            //显示白色
                     else
                          VGA_DATA <= `BLACK;        //显示黑色 
                 end
                 else if(second_high==3'd3)//秒钟高位为3
                 begin
                     if(((hsync_cnt >= (`HSYNC_B+16'd550+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd550+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                          VGA_DATA <= `WHITE;            //显示白色
                     else
                          VGA_DATA <= `BLACK;        //显示黑色 
                 end
                 else if(second_high==3'd4)//秒钟高位为4
                 begin
                     if(((hsync_cnt >= (`HSYNC_B+16'd550+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd550+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd550+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd550+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72))))
                          VGA_DATA <= `WHITE;            //显示白色
                     else
                          VGA_DATA <= `BLACK;        //显示黑色 
                    end
                 else if(second_high==4'd5)//秒钟高位为5
                 begin
                     if(((hsync_cnt >= (`HSYNC_B+16'd550+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd550+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd550+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                          VGA_DATA <= `WHITE;            //显示白色
                     else
                          VGA_DATA <= `BLACK;        //显示黑色 
                   end
                   else
                        VGA_DATA<=`BLACK;
                        
                end
                else if((hsync_cnt>(`HSYNC_B+16'd625))&&(hsync_cnt<(`HSYNC_B+16'd700)))//秒钟低位显示
                begin   
                   if(second_low==0)
                   begin
                        if(((hsync_cnt >= (`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA<=`WHITE;
                        else
                            VGA_DATA<=`BLACK;
                   end
                   else if(second_low==4'd1)
                   begin
                        if((hsync_cnt >= (`HSYNC_B+16'd625+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            VGA_DATA <= `WHITE;            //红色        1110_0000
                        else
                            VGA_DATA <= `BLACK;        //黑色        0000_0000
                   end
                   else if(second_low==4'd2)//秒钟低位为2
                 begin
                     if(((hsync_cnt >= (`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                          VGA_DATA <= `WHITE;            //显示白色
                     else
                          VGA_DATA <= `BLACK;        //显示黑色 
                 end
                 else if(second_low==4'd3)//秒钟低位为3
                 begin
                     if(((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                          VGA_DATA <= `WHITE;            //显示白色
                     else
                          VGA_DATA <= `BLACK;        //显示黑色 
                 end
                 else if(second_low==4'd4)//秒钟低位为4
                 begin
                     if(((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72))))
                          VGA_DATA <= `WHITE;            //显示白色
                     else
                          VGA_DATA <= `BLACK;        //显示黑色 
                    end
                 else if(second_low==4'd5)//秒钟低位为5
                 begin
                     if(((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                          VGA_DATA <= `WHITE;            //显示白色
                     else
                          VGA_DATA <= `BLACK;        //显示黑色 
                   end
                 else if(second_low==4'd6)//秒钟低位为6
                  begin
                      if(((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                      ||((hsync_cnt >= (`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                           VGA_DATA <= `WHITE;            //显示白色
                      else
                           VGA_DATA <= `BLACK;        //显示黑色 
                    end
                 else if(second_low==4'd7)//秒钟低位为7
                   begin
                        if(((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20))))
                            VGA_DATA<=`WHITE;
                        else
                            VGA_DATA<=`BLACK;
                   end
                 else if(second_low==4'd8)//秒钟低位为8
                   begin
                       if(((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA <= `WHITE;            //显示白色
                       else
                            VGA_DATA <= `BLACK;        //显示黑色 
                     end
                     else if(second_low==4'd9)//秒钟低位为9
                      begin
                          if(((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                          ||((hsync_cnt >= (`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                               VGA_DATA <= `WHITE;            //显示白色
                          else
                               VGA_DATA <= `BLACK;        //显示黑色 
                        end
                   else
                        VGA_DATA<=`BLACK;
                end
                else
                VGA_DATA<=`BLACK;
            end
            else
            VGA_DATA <= `BLACK;            //黑色
        end
       else
       VGA_DATA <= `BLACK;                //黑色
    end

    
    
endmodule
