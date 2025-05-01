module led_clk_div(clk, rstn, div_clk);
    input clk, rstn;
    output div_clk;
    reg[17:0] clk_reg;
    assign div_clk = clk_reg[17];
    
    always@(posedge clk)begin
    if(!rstn)
        clk_reg <= 18'b0;
    else
        clk_reg <= clk_reg+1;
    end    
endmodule

module led_display(clk, rstn, hour, minute, second, led_0, led_1, led_dn, alarmNotSet, mode);
    input clk, rstn, alarmNotSet,mode;
    input [6:0] hour, minute, second;
    output reg[6:0] led_0, led_1;
    output reg[5:0] led_dn;
    
    always@(posedge clk or negedge rstn) 
     if(!rstn)
        led_dn <= 6'b1;
     else
        led_dn <= {led_dn[4:0], led_dn[5]};
    
    reg[3:0] cur_led0;
    reg[3:0] cur_led1;
    
    always@(*) begin
     if(led_dn[0] == 1)
        cur_led0 <= second%10;
     else if(led_dn[1] == 1)
        cur_led0 <= second/10;
     else if(led_dn[2] == 1)
        cur_led0 <= minute%10;
     else if(led_dn[3] == 1)
        cur_led0 <= minute/10;
     else
        cur_led0 <= 0;
     end
    
    always@(*)
     if(led_dn[3] == 1)
        cur_led1 <= minute/10;
     else if(led_dn[4] ==1)
        cur_led1 <= hour%10;
     else
        cur_led1 <= 0;
        
    always@(*) begin
        if(alarmNotSet ==1 && mode ==2'b10)
            led_0 =7'b0000001;
        else
        case(cur_led0)
        0: led_0 = 7'b1111110;
        1: led_0 = 7'b0110000;
        2: led_0 = 7'b1101101;
        3: led_0 = 7'b1111001;
        4: led_0 = 7'b0110011;
        5: led_0 = 7'b1011011;
        6: led_0 = 7'b1011111;
        7: led_0 = 7'b1110000;
        8: led_0 = 7'b1111111;
        9: led_0 = 7'b1111011;
        default: led_0 = 7'b0000000;
     endcase
    end
    always@(*) begin
        if(alarmNotSet ==1 && mode ==2'b10)
            led_1 =7'b0000001;
        else
        case(cur_led1)
        0: led_1 = 7'b1111110;
        1: led_1 = 7'b0110000;
        2: led_1 = 7'b1101101;
        3: led_1 = 7'b1111001;
        4: led_1 = 7'b0110011;
        5: led_1 = 7'b1011011;
        6: led_1 = 7'b1011111;
        7: led_1 = 7'b1110000;
        8: led_1 = 7'b1111111;
        9: led_1 = 7'b1111011;
        default: led_1 = 7'b0000000;
     endcase
    end
    
endmodule
    
module debounce(clk, rstn, button_in, button_out);
    input clk, rstn, button_in;
    output button_out;

    reg button_out;
    reg button_reg;
    reg[15:0] counter;
    //reg counter;

    always @(posedge clk or negedge rstn)
    	if (!rstn)
    		counter <= 0;
    	else if (button_reg != button_in || |counter)
    		counter <= counter + 1;
    	else
    		counter <= 0;

    always @(posedge clk or negedge rstn)
    	if (!rstn)
    	    button_out <= 0;
    	else if (|counter)
    	    button_out <= button_out;
    	else
    		button_out <= button_reg;

    always @(posedge clk or negedge rstn)
    	if (!rstn)
    		button_reg <= 0;
    	else if (|counter)
    		button_reg <= button_reg;
    	else
    		button_reg <= button_in;

 endmodule
 
module time_counter(clk, rstn, hour, minute, second, mode, change_time);
    input clk, rstn;
    input [1:0] mode;
    input [5:0] change_time;
    output[6:0] hour, minute, second;
    
    reg [5:0] last_change_time;
    //调时
    integer k;
    always @(posedge clk or negedge rstn)
        if(!rstn) begin
            k <=0;
            last_change_time <= 6'b0;
        end
        else begin
            last_change_time <= change_time;
            if(change_time[0]==1 && last_change_time[0]==0 && mode==2'b01)
                k <= k+1;
            else if(change_time[1]==1 && last_change_time[1]==0 && mode==2'b01)
                k <= k-1;
             else if(change_time[2]==1 && last_change_time[2]==0 && mode==2'b01)
                 k <= k+60;
             else if(change_time[3]==1 && last_change_time[3]==0 && mode==2'b01)
                 k <= k-60;
             else if(change_time[4]==1 && last_change_time[4]==0 && mode==2'b01)
                 k <= k+3600;
             else if(change_time[5]==1 && last_change_time[5]==0 && mode==2'b01)
                 k <= (k-3600>=0)?(k-3600):0;
        end
        
       //计时
        integer j;
        always@(posedge clk or negedge rstn) begin
          if(!rstn)
               j <= 0;
          else if(j >= 100000000)
               j <= 0;
          else if(mode != 2'b01)      // 模式不为调时时计时
               j <= j+1;
        end
        integer i;
        always@(posedge clk or negedge rstn)
           if(!rstn)
               i <= 0;
           else if(j==100000000)
               i <= i+1;
       integer ii;
       always@(*) begin
            ii = i+k;
        //if(ii < 0) ii=0;
        end
       assign hour = ii/3600;
       assign minute = (ii%3600)/60;
       assign second = (ii%3600)%60;
endmodule

module stop_watch(clk, rstn, mode, pause, reset, hour, minute, second);
    input clk, rstn, pause, reset;
    input[1:0] mode;
    output[6:0] hour, minute, second;
    
     integer j;
     always@(posedge clk or negedge rstn) begin
         if(!rstn)
             j <= 0;
         else if(mode == 2'b11)begin
            if(reset==1)
                j <= 0;
            else if(j>=1000000)
                j <= 0;
            else if(pause != 0)
                j <= j+1;
         end
         else
            j <= 0;  
     end
       
     integer i;
     always@(posedge clk or negedge rstn) begin
         if(!rstn)
             i <= 0;
         else if(mode ==2'b11)begin
            if(reset==1)
                i <= 0;
            else if(j==1000000)
                i <= i+1;
        end
     end
     
     assign second = i%100;
     assign hour = (i)/6000;
     assign minute =(i%6000)/100;
     
endmodule

module alarm(clk, rstn, mode, change_time, resetAlarm, hour, minute, second, alarmNotSet);
    input clk, rstn, resetAlarm;
    input[1:0] mode;
    input[5:0] change_time;
    output reg alarmNotSet ;
    output [6:0] hour,minute, second;
    
    reg [5:0] last_change_time;
    integer k;
    always@(posedge clk or negedge rstn)
        if(!rstn) begin
            k <= 0;
            last_change_time <=0;
            alarmNotSet <= 1;
        end
        else if(mode == 2'b10) begin
            if(resetAlarm ==1) begin
                k <=0;
                last_change_time <= 6'b0;
                alarmNotSet <=1;
            end
            else begin
                last_change_time <= change_time;
                if(change_time[0]==1 && last_change_time[0] == 0 && mode == 2'b10) begin
                    k <= k+1;
                    alarmNotSet <= 0; end
                else if(change_time[1]==1 && last_change_time[1] == 0 && mode == 2'b10) begin
                    k <= (k-1>=0)?(k-1):0;
                    alarmNotSet <= 0;end
                else if(change_time[2]==1 && last_change_time[2] == 0 && mode == 2'b10) begin
                     k <= k+60;
                     alarmNotSet <= 0;end
                else if(change_time[3]==1 && last_change_time[3] == 0 && mode == 2'b10) begin
                     k <= (k-60>=0)?(k-60):0;
                     alarmNotSet <= 0;end
                else if(change_time[4]==1 && last_change_time[4] == 0 && mode == 2'b10) begin
                     k <= k+3600;
                     alarmNotSet <= 0;end 
                else if(change_time[5]==1 && last_change_time[5] == 0 && mode == 2'b10) begin
                     k <= (k-3600>=0)?(k-3600):0;
                     alarmNotSet <= 0;end        
            end
        end
    assign hour = k/3600;
    assign minute = (k%3600)/60;
    assign second = (k%3600)%60;
endmodule

module alarm_display(clk, rstn, hour_now, minute_now, second_now, hour_set, minute_set, second_set, closeAlarm, mode, led);
    input clk, rstn, closeAlarm;
    input [1:0] mode;
    
    input [6:0] hour_now, minute_now, second_now, hour_set, minute_set, second_set;//now为当前， set为设定时间
    output led;
    
    assign led =(closeAlarm == 1)?0:(mode == 2'b00 && hour_now == hour_set && minute_now == minute_set && second_now == second_set)?1:0;
endmodule

module top(clk ,rstn, led_0, led_1, led_dn, isCTmode, isAlarm, isStopWatch, ct_button_in, pause, resetAlarm, alarm_led, closeAlarm);
    input clk, rstn, isCTmode, isAlarm, isStopWatch,resetAlarm, closeAlarm;
    input [5:0] ct_button_in;
    input pause;
    output[6:0] led_0;
    output[6:0] led_1;
    output[5:0] led_dn;
    output alarm_led;
    
    wire[1:0] mode;
    assign mode =(isCTmode == 1)? 2'b01:(isAlarm == 1)?2'b10:(isStopWatch==1)?2'b11:2'b00;
    
    wire [6:0] hour_tc, minute_tc, second_tc;
    wire led_clk;
    led_clk_div lcd(clk, rstn, led_clk);
    wire [5:0]ct_button_out;
    debounce db0(clk, rstn, ct_button_in[0], ct_button_out[0]), db1(clk, rstn, ct_button_in[1], ct_button_out[1]), db2(clk, rstn, ct_button_in[2], ct_button_out[2]), db3(clk, rstn, ct_button_in[3], ct_button_out[3]), db4(clk, rstn, ct_button_in[4], ct_button_out[4]), db5(clk, rstn, ct_button_in[5], ct_button_out[5]);
    time_counter tctr(clk, rstn, hour_tc, minute_tc, second_tc, mode, ct_button_out);
    
    wire [6:0] hour_sw,minute_sw, second_sw;
    stop_watch sw(clk, rstn, mode, pause, ct_button_out[4], hour_sw, minute_sw, second_sw);
    
    wire [6:0] hour_am,minute_am,second_am;
    wire alarmNotSet;
    alarm am(clk, rstn, mode, ct_button_out, resetAlarm, hour_am, minute_am, second_am, alarmNotSet);
    alarm_display ady(clk, rstn, hour_tc,minute_tc, second_tc, hour_am, minute_am, second_am, closeAlarm, mode, alarm_led);
    
    wire [6:0] hour, minute,second;
    assign hour = (mode ==2'b11)?hour_sw:(mode == 2'b10)?hour_am:hour_tc;
    assign minute =(mode ==2'b11)?minute_sw:(mode == 2'b10)?minute_am:minute_tc;
    assign second = (mode ==2'b11)?second_sw:(mode == 2'b10)?second_am:second_tc;
    led_display ldy(led_clk, rstn, hour, minute, second, led_0, led_1, led_dn, alarmNotSet, mode);
endmodule