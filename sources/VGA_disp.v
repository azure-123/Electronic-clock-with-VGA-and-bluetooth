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

//��ʱ��궨��
`define HSYNC_A	16'd128
`define HSYNC_B	16'd216
`define HSYNC_C	16'd1016
`define HSYNC_D	16'd1056

//��ʱ��궨��
`define VSYNC_O	16'd4
`define VSYNC_P	16'd27
`define VSYNC_Q	16'd627
`define VSYNC_R	16'd628

//��ɫ����
`define WHITE 12'Hfff
`define BLACK 12'H000

module VGA_disp(
    //���룺ʹ���źš���λ�źź�ʱ��
    input rst,//��λ�źţ��ߵ�ƽ��Ч
    input CLK_100M,
    input [1:0] hour_high,
    input [3:0] hour_low,
    input [2:0] minute_high,
    input [3:0] minute_low,
    input [2:0] second_high,
    input [3:0] second_low, 
    
    //�����VGA��ɫ����
    output reg VSYNC,
    output reg HSYNC,
    output reg [11:0] VGA_DATA
    );
    
    reg[15:0] hsync_cnt;		//ˮƽɨ�������
    reg[15:0] vsync_cnt;        //��ֱɨ�������
    reg CLK_50M;
    reg vga_data_valid;            //RGB�����ź���Ч��ʹ���ź� 
    //ˮƽɨ��(ɨ��1056����)
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
    
    
    //��ֱɨ��(ɨ��628����)
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
    
    //��ʱ��
    always@(posedge CLK_50M or posedge rst)
    begin
        if(rst)
            HSYNC <= 1'b0;
        else if(hsync_cnt < `HSYNC_A)    //a��Ϊ0
            HSYNC <= 1'b0;
        else
            HSYNC <= 1'b1;                //������Ϊ1
    end
    
    //��ʱ��
    always@(posedge CLK_50M or posedge rst)
    begin
        if(rst)
            VSYNC <= 1'b0;
        else if(vsync_cnt < `VSYNC_O)    //o��Ϊ0
            VSYNC <= 1'b0;
        else
            VSYNC <= 1'b1;                //������Ϊ1
    end
    
    //��ȡ��ʾ��Ч��(q��+c��)
    always@(posedge CLK_50M or posedge rst)
    begin
        if(rst)
            vga_data_valid <= 1'b0;
        else if((hsync_cnt > `HSYNC_B && hsync_cnt < `HSYNC_C) && (vsync_cnt >  `VSYNC_P && vsync_cnt < `VSYNC_Q))    //������Ч��
            vga_data_valid <= 1'b1;
        else
            vga_data_valid <= 1'b0;
    end

    always@(*)
    begin
        if(vga_data_valid)
        begin
            if(vsync_cnt >`VSYNC_P)//��ʾ��
            begin
                if((hsync_cnt>(`HSYNC_B+16'd100))&&(hsync_cnt<(`HSYNC_B+16'd175)))//Сʱ��λ��ʾ
                begin
                    if(hour_high==2'd0)//Сʱ��λΪ0
                    begin
                        if(((hsync_cnt >= (`HSYNC_B+16'd100+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd100+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                        ||((hsync_cnt >= (`HSYNC_B+16'd100+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd100+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                        ||((hsync_cnt >=(`HSYNC_B+16'd100+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd100+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                        ||((hsync_cnt >=(`HSYNC_B+16'd100+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd100+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA<=`WHITE;
                        else
                            VGA_DATA<=`BLACK;
                    end
                    else if(hour_high==2'd1)//Сʱ��λΪ1
                    begin
                        if((hsync_cnt >= (`HSYNC_B+16'd100+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd100+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            VGA_DATA <= `WHITE;            //��ʾ��ɫ
                        else
                            VGA_DATA <= `BLACK;        //��ʾ��ɫ
                    end
                    else if(hour_high==2'd2)//Сʱ��λΪ2
                    begin
                        if(((hsync_cnt >= (`HSYNC_B+16'd100+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd100+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                        ||((hsync_cnt >= (`HSYNC_B+16'd100+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd100+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                        ||((hsync_cnt >=(`HSYNC_B+16'd100+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd100+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                        ||((hsync_cnt >=(`HSYNC_B+16'd100+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd100+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                        ||((hsync_cnt >=(`HSYNC_B+16'd100+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd100+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                             VGA_DATA <= `WHITE;            //��ʾ��ɫ
                        else
                             VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                    end
                    else
                        VGA_DATA<=`BLACK;
                end
                else if((hsync_cnt>(`HSYNC_B+16'd175))&&(hsync_cnt<(`HSYNC_B+16'd250)))//Сʱ��λ��ʾ
                begin   
                   if(hour_low==4'd0)//Сʱ��λΪ0
                   begin
                        if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA<=`WHITE;
                        else
                            VGA_DATA<=`BLACK;
                   end
                   else if(hour_low==4'd1)//Сʱ��λΪ1
                   begin
                        if((hsync_cnt >= (`HSYNC_B+16'd175+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            VGA_DATA <= `WHITE;            //��ʾ��ɫ
                        else
                            VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                   end
                   else if(hour_low==4'd2)//Сʱ��λΪ2
                   begin
                       if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA <= `WHITE;            //��ʾ��ɫ
                       else
                            VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                   end
                   else if(hour_low==4'd3)//Сʱ��λΪ3
                   begin
                       if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA <= `WHITE;            //��ʾ��ɫ
                       else
                            VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                   end
                   else if(hour_low==4'd4)//Сʱ��λΪ4
                   begin
                       if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72))))
                            VGA_DATA <= `WHITE;            //��ʾ��ɫ
                       else
                            VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                      end
                   else if(hour_low==4'd5)//Сʱ��λΪ5
                   begin
                       if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA <= `WHITE;            //��ʾ��ɫ
                       else
                            VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                     end
                   else if(hour_low==4'd6)//Сʱ��λΪ6
                    begin
                        if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                        ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                        ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                        ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                        ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                             VGA_DATA <= `WHITE;            //��ʾ��ɫ
                        else
                             VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                      end
                   else if(hour_low==4'd7)//Сʱ��λΪ7
                     begin
                          if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                         ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20))))
                              VGA_DATA<=`WHITE;
                          else
                              VGA_DATA<=`BLACK;
                     end
                   else if(hour_low==4'd8)//Сʱ��λΪ8
                     begin
                         if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                         ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                         ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                         ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                         ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                              VGA_DATA <= `WHITE;            //��ʾ��ɫ
                         else
                              VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                       end
                       else if(hour_low==4'd9)//Сʱ��λΪ9
                        begin
                            if(((hsync_cnt >= (`HSYNC_B+16'd175+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            ||((hsync_cnt >= (`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd175+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                            ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                            ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                            ||((hsync_cnt >=(`HSYNC_B+16'd175+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd175+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                                 VGA_DATA <= `WHITE;            //��ʾ��ɫ
                            else
                                 VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                          end
                   else
                        VGA_DATA<=`BLACK;
                end
                else if((hsync_cnt>(`HSYNC_B+16'd250))&&(hsync_cnt<(`HSYNC_B+16'd325)))//Сʱ�����֮���ð����ʾ
                begin
                    if(((hsync_cnt >= (`HSYNC_B+16'd250+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd250+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd50))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd55)))
                    ||((hsync_cnt >= (`HSYNC_B+16'd250+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd250+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd100))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd105))))
                        VGA_DATA<=`WHITE;       //��ʾ��ɫ
                    else
                        VGA_DATA<=`BLACK;          //��ʾ��ɫ
                end
                else if((hsync_cnt>(`HSYNC_B+16'd325))&&(hsync_cnt<(`HSYNC_B+16'd400)))//���Ӹ�λ��ʾ
                begin   
                   if(minute_high==3'd0)//���Ӹ�λΪ0
                   begin
                        if(((hsync_cnt >= (`HSYNC_B+16'd325+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd325+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA<=`WHITE;
                        else
                            VGA_DATA<=`BLACK;
                   end
                   else if(minute_high==3'd1)//���Ӹ�λΪ1
                   begin
                        if((hsync_cnt >= (`HSYNC_B+16'd325+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            VGA_DATA <= `WHITE;            //��ɫ        1110_0000
                        else
                            VGA_DATA <= `BLACK;        //��ɫ        0000_0000
                   end
                   else if(minute_high==3'd2)//���Ӹ�λΪ2
                  begin
                      if(((hsync_cnt >= (`HSYNC_B+16'd325+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                      ||((hsync_cnt >= (`HSYNC_B+16'd325+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                           VGA_DATA <= `WHITE;            //��ʾ��ɫ
                      else
                           VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                  end
                  else if(minute_high==3'd3)//���Ӹ�λΪ3
                  begin
                      if(((hsync_cnt >= (`HSYNC_B+16'd325+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                      ||((hsync_cnt >= (`HSYNC_B+16'd325+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                           VGA_DATA <= `WHITE;            //��ʾ��ɫ
                      else
                           VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                  end
                  else if(minute_high==3'd4)//���Ӹ�λΪ4
                  begin
                      if(((hsync_cnt >= (`HSYNC_B+16'd325+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                      ||((hsync_cnt >= (`HSYNC_B+16'd325+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >= (`HSYNC_B+16'd325+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd325+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72))))
                           VGA_DATA <= `WHITE;            //��ʾ��ɫ
                      else
                           VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                     end
                  else if(minute_high==4'd5)//���Ӹ�λΪ5
                  begin
                      if(((hsync_cnt >= (`HSYNC_B+16'd325+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                      ||((hsync_cnt >= (`HSYNC_B+16'd325+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd325+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd325+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd325+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                           VGA_DATA <= `WHITE;            //��ʾ��ɫ
                      else
                           VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                    end
                   else
                        VGA_DATA<=`BLACK;
                end
                else if((hsync_cnt>(`HSYNC_B+16'd400))&&(hsync_cnt<(`HSYNC_B+16'd475)))//���ӵ�λ��ʾ
                begin   
                   if(minute_low==0)//���ӵ�λΪ0
                   begin
                        if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA<=`WHITE;
                        else
                            VGA_DATA<=`BLACK;
                   end
                   else if(minute_low==4'd1)//���ӵ�λΪ1
                   begin
                        if((hsync_cnt >= (`HSYNC_B+16'd400+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            VGA_DATA <= `WHITE;            //��ɫ        1110_0000
                        else
                            VGA_DATA <= `BLACK;        //��ɫ        0000_0000
                   end
                   else if(minute_low==4'd2)//���ӵ�λΪ2
                      begin
                          if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                          ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                               VGA_DATA <= `WHITE;            //��ʾ��ɫ
                          else
                               VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                      end
                      else if(minute_low==4'd3)//���ӵ�λΪ3
                      begin
                          if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                          ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                               VGA_DATA <= `WHITE;            //��ʾ��ɫ
                          else
                               VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                      end
                      else if(minute_low==4'd4)//���ӵ�λΪ4
                      begin
                          if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                          ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72))))
                               VGA_DATA <= `WHITE;            //��ʾ��ɫ
                          else
                               VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                         end
                      else if(minute_low==4'd5)//���ӵ�λΪ5
                      begin
                          if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                          ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                               VGA_DATA <= `WHITE;            //��ʾ��ɫ
                          else
                               VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                        end
                      else if(minute_low==4'd6)//���ӵ�λΪ6
                       begin
                           if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                           ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                           ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                           ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                           ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                                VGA_DATA <= `WHITE;            //��ʾ��ɫ
                           else
                                VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                         end
                      else if(minute_low==4'd7)//���ӵ�λΪ7
                        begin
                             if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20))))
                                 VGA_DATA<=`WHITE;
                             else
                                 VGA_DATA<=`BLACK;
                        end
                      else if(minute_low==4'd8)//���ӵ�λΪ8
                        begin
                            if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                            ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                            ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                                 VGA_DATA <= `WHITE;            //��ʾ��ɫ
                            else
                                 VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                          end
                          else if(minute_low==4'd9)//���ӵ�λΪ9
                           begin
                               if(((hsync_cnt >= (`HSYNC_B+16'd400+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                               ||((hsync_cnt >= (`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd400+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                               ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                               ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                               ||((hsync_cnt >=(`HSYNC_B+16'd400+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd400+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                                    VGA_DATA <= `WHITE;            //��ʾ��ɫ
                               else
                                    VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                             end
                   else
                        VGA_DATA<=`BLACK;
                end
                else if((hsync_cnt>(`HSYNC_B+16'd475))&&(hsync_cnt<(`HSYNC_B+16'd550)))//���Ӻ�����֮���ð��
                begin
                    if(((hsync_cnt >= (`HSYNC_B+16'd475+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd475+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd50))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd55)))
                    ||((hsync_cnt >= (`HSYNC_B+16'd475+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd475+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd100))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd105))))
                        VGA_DATA<=`WHITE;
                    else
                        VGA_DATA<=`BLACK;
                end
                else if((hsync_cnt>(`HSYNC_B+16'd550))&&(hsync_cnt<(`HSYNC_B+16'd625)))//���Ӹ�λ��ʾ
                begin   
                   if(second_high==0)//���Ӹ�λΪ0
                   begin
                        if(((hsync_cnt >= (`HSYNC_B+16'd550+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd550+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA<=`WHITE;
                        else
                            VGA_DATA<=`BLACK;
                   end
                   else if(second_high==3'd1)//���Ӹ�λΪ1
                   begin
                        if((hsync_cnt >= (`HSYNC_B+16'd550+16'd35)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd40))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                            VGA_DATA <= `WHITE;            //��ɫ        1110_0000
                        else
                            VGA_DATA <= `BLACK;        //��ɫ        0000_0000
                   end
                   else if(second_high==3'd2)//���Ӹ�λΪ2
                    begin
                     if(((hsync_cnt >= (`HSYNC_B+16'd550+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd550+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                          VGA_DATA <= `WHITE;            //��ʾ��ɫ
                     else
                          VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                 end
                 else if(second_high==3'd3)//���Ӹ�λΪ3
                 begin
                     if(((hsync_cnt >= (`HSYNC_B+16'd550+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd550+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                          VGA_DATA <= `WHITE;            //��ʾ��ɫ
                     else
                          VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                 end
                 else if(second_high==3'd4)//���Ӹ�λΪ4
                 begin
                     if(((hsync_cnt >= (`HSYNC_B+16'd550+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd550+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd550+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd550+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72))))
                          VGA_DATA <= `WHITE;            //��ʾ��ɫ
                     else
                          VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                    end
                 else if(second_high==4'd5)//���Ӹ�λΪ5
                 begin
                     if(((hsync_cnt >= (`HSYNC_B+16'd550+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd550+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd550+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd550+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd550+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                          VGA_DATA <= `WHITE;            //��ʾ��ɫ
                     else
                          VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                   end
                   else
                        VGA_DATA<=`BLACK;
                        
                end
                else if((hsync_cnt>(`HSYNC_B+16'd625))&&(hsync_cnt<(`HSYNC_B+16'd700)))//���ӵ�λ��ʾ
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
                            VGA_DATA <= `WHITE;            //��ɫ        1110_0000
                        else
                            VGA_DATA <= `BLACK;        //��ɫ        0000_0000
                   end
                   else if(second_low==4'd2)//���ӵ�λΪ2
                 begin
                     if(((hsync_cnt >= (`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                          VGA_DATA <= `WHITE;            //��ʾ��ɫ
                     else
                          VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                 end
                 else if(second_low==4'd3)//���ӵ�λΪ3
                 begin
                     if(((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                          VGA_DATA <= `WHITE;            //��ʾ��ɫ
                     else
                          VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                 end
                 else if(second_low==4'd4)//���ӵ�λΪ4
                 begin
                     if(((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72))))
                          VGA_DATA <= `WHITE;            //��ʾ��ɫ
                     else
                          VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                    end
                 else if(second_low==4'd5)//���ӵ�λΪ5
                 begin
                     if(((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                     ||((hsync_cnt >= (`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                     ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                          VGA_DATA <= `WHITE;            //��ʾ��ɫ
                     else
                          VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                   end
                 else if(second_low==4'd6)//���ӵ�λΪ6
                  begin
                      if(((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd72))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                      ||((hsync_cnt >= (`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                      ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                           VGA_DATA <= `WHITE;            //��ʾ��ɫ
                      else
                           VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                    end
                 else if(second_low==4'd7)//���ӵ�λΪ7
                   begin
                        if(((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20))))
                            VGA_DATA<=`WHITE;
                        else
                            VGA_DATA<=`BLACK;
                   end
                 else if(second_low==4'd8)//���ӵ�λΪ8
                   begin
                       if(((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >= (`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                       ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                            VGA_DATA <= `WHITE;            //��ʾ��ɫ
                       else
                            VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                     end
                     else if(second_low==4'd9)//���ӵ�λΪ9
                      begin
                          if(((hsync_cnt >= (`HSYNC_B+16'd625+16'd60)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15)))
                          ||((hsync_cnt >= (`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <=(`HSYNC_B+16'd625+16'd10))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd15))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd20)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5))&& (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd225+16'd67))&&(vsync_cnt<=(`VSYNC_P+16'd225+16'd72)))
                          ||((hsync_cnt >=(`HSYNC_B+16'd625+16'd5)) && (hsync_cnt <= (`HSYNC_B+16'd625+16'd65))&&(vsync_cnt>=(`VSYNC_P+16'd375-16'd20))&&(vsync_cnt<=(`VSYNC_P+16'd375-16'd15))))
                               VGA_DATA <= `WHITE;            //��ʾ��ɫ
                          else
                               VGA_DATA <= `BLACK;        //��ʾ��ɫ 
                        end
                   else
                        VGA_DATA<=`BLACK;
                end
                else
                VGA_DATA<=`BLACK;
            end
            else
            VGA_DATA <= `BLACK;            //��ɫ
        end
       else
       VGA_DATA <= `BLACK;                //��ɫ
    end

    
    
endmodule
