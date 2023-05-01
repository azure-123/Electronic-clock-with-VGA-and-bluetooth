module bluetooth(
    input clk,
    input rst,
    input get,
    output reg [4:0] output_clock
);
    reg [7:0] out;
    parameter bps=10417;
    reg [14:0] count_1;//每一位中的计数器
    reg [3:0] count_2;//每一组数据的计数器
    reg filter_0,filter_1,filter_2;//除去滤波
    wire filter_en;//检测到边沿
    reg add_en;//加法使能信号

    always @ (posedge clk)
    begin
        if(rst)
        begin
            filter_0<=1;
            filter_1<=1;
            filter_2<=1;
        end
        else
        begin
            filter_0<=get;
            filter_1<=filter_0;
            filter_2<=filter_1;
        end
    end

    assign filter_en=filter_2&~filter_1;

    always @ (posedge clk)
    begin
        if(rst)
        begin
            count_1<=0;
        end
        else if(add_en)
        begin
            if(count_1==bps-1)
            begin
                count_1<=0;
            end
            else
            begin
                count_1<=count_1+1;
            end
        end
    end

    always @ (posedge clk)
    begin
        if(rst)
        begin
            count_2<=0;
        end
        else if(add_en&&count_1==bps-1)//如果每一位加
        begin
            if(count_2==8)
            begin
                count_2<=0;
            end
            else
            begin
                count_2<=count_2+1;
            end
        end
    end

    always @ (posedge clk)
    begin
        if(rst)
        begin
            add_en<=0;
        end
        else if(filter_en)
        begin
            add_en<=1;
        end
        else if(add_en&&count_2==8&&count_1==bps-1)
        begin
            add_en<=0;
        end
    end
    
    always @ (posedge clk)
    begin
        if(rst)
        begin
            out<=0;
        end
        else if(add_en&&count_1==bps/2-1&&count_2!=0)
        begin
            out[count_2-1]<=get;
        end
    end
    
    always@(*)
        begin
        case(out)
            8'd48: output_clock<=5'd0;
            8'd49: output_clock<=5'd1;
            8'd50: output_clock<=5'd2;
            8'd51: output_clock<=5'd3;    
            8'd52: output_clock<=5'd4;    
            8'd53: output_clock<=5'd5;    
            8'd54: output_clock<=5'd6;
            8'd55: output_clock<=5'd7;
            8'd56: output_clock<=5'd8;
            8'd57: output_clock<=5'd9;
            8'd65: output_clock<=5'd10;
            8'd66: output_clock<=5'd11;
            8'd67: output_clock<=5'd12;
            8'd68: output_clock<=5'd13;
            8'd69: output_clock<=5'd14;
            8'd70: output_clock<=5'd15;
            8'd71: output_clock<=5'd16;
            8'd72: output_clock<=5'd17;
            8'd73: output_clock<=5'd18;
            8'd74: output_clock<=5'd19;
            8'd75: output_clock<=5'd20;
            8'd76: output_clock<=5'd21;
            8'd77: output_clock<=5'd22;
            8'd78: output_clock<=5'd23;
            default: ;
        endcase
        end
    
endmodule