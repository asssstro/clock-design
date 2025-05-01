module stop_watch_tb;
    reg clk,rstn,isCTmode, isAlarm, isStopWatch, pause;
    reg [5:0] ct_button_in;
    wire[6:0] led_0, led_1;
    wire [5:0] led_dn;
top topp(clk ,rstn, led_0, led_1, led_dn, isCTmode, isAlarm, isStopWatch, ct_button_in, pause);

    initial begin
        isStopWatch = 1;
        isCTmode = 0;
        isAlarm = 0;
        rstn = 0;
        clk = 0;
        pause =1;
        ct_button_in =6'b000000;
        
        #5 rstn = 1;
    end
    always #5 clk=~clk;
endmodule
