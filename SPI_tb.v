`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2021 07:21:25 AM
// Design Name: 
// Module Name: SPI_tb
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


module SPI_tb(   );
reg  CLK ;
reg  DI  ;
reg  DO  ;
reg  CS  ;
SPI_Master DUT
    (
    .CLK(  ),
    .DI (  ),
    .DO (  ),
    .CS (  )
    );
initial begin
    forever begin
    CLK = 1; #10;
    CLK = 0; #10;
    end 
    end 
// SPI transfer data
reg CLK_Polarity = 0;
reg CLK_Phase    = 0;
reg[7:0] i = 0;
reg[7:0] loop = 0;
reg[7:0] data_DO = 0;
initial begin
    CS = 1; #500;
    @(negedge CLK);
    // start transfer data, LSB is the first
    //forever begin
    data_DO = 0;
    for(loop = 0; loop < 200; loop = loop + 1) begin
        @(negedge CLK);
        CS = 0;
        for(i = 0; i < 8; i = i + 1) begin
        DO = data_DO[i];
        @(negedge CLK);
        end 
        CS = 1; 
        data_DO = data_DO + 1;        
        #500;    
        end 
    #1000;
    $stop;
    //end 
    end
// checker for SPI transmit data
reg[7:0] i1, i2;
reg[7:0] data_test = 0;
initial begin
    for(i1 = 0; i1 < 200; i1 = i1 + 1) begin
    @(negedge CS);
    for(i2 = 0; i2 < 8; i2 = i2 + 1) begin
        @(posedge CLK);
        data_test[i2] = DO;
        end 
    // check
    if(data_test == data_DO) begin
        $display("test pass data_DO = %d, data_test = %d", data_DO, data_test);
        end 
    else begin
        $display("test fail data_DO = %d, data_test = %d", data_DO, data_test);
        $stop;
        end 
    end 
end 
    
initial begin
    #500000;
    $stop;
    end 
endmodule












