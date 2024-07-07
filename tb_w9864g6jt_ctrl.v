/*
 *  tb_w9864g6jt_ctrl - A sdram controller TESTBENCH
 *
 *  Copyright (C) 2024  <@.>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 * 
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

`timescale 1ns / 1ps
//modelsim quartus prime 18.1 10.5b

module tb_w9864g6jt_ctrl;

    // Testbench signals
    reg clk;
    reg resetn;
	
    reg [21:0] addr;
    reg [31:0] din;
    reg [3:0] wmask;
    reg valid;
    wire [31:0] dout;
    wire ready;

    //SDRAM chip connections
    wire sdram_clk;
    wire sdram_cke;
    wire [11:0] sdram_addr;
    wire [1:0] sdram_ba;
    wire sdram_csn;
    wire sdram_wen;
    wire sdram_rasn;
    wire sdram_casn;
    wire [15:0] sdram_dq;
	wire [1:0] sdram_dqm;  
	
    // Instantiate the SDRAM w9864g6jt_ctrl  	
    w9864g6jt_ctrl uut (
	
        .clk(clk),
        .resetn(resetn),
		
        .addr(addr),
        .din(din),
        .wmask(wmask),
        .valid(valid),
        .dout(dout),
        .ready(ready),
		
        .sdram_clk(sdram_clk),
        .sdram_cke(sdram_cke),
        .sdram_dqm(sdram_dqm),
        .sdram_addr(sdram_addr),
        .sdram_ba(sdram_ba),
        .sdram_csn(sdram_csn),
        .sdram_wen(sdram_wen),
        .sdram_rasn(sdram_rasn),
        .sdram_casn(sdram_casn),
        .sdram_dq(sdram_dq)	
	);
 
    // Instantiate the SDRAM chip model
    W9825G6KH sdram (
        .Dq(sdram_dq), 
        .Addr({1'b0,sdram_addr}), 
        .Bs(sdram_ba), 
        .Clk(sdram_clk), 
        .Cke(sdram_cke), 
        .Cs_n(sdram_csn), 
        .Ras_n(sdram_rasn), 
        .Cas_n(sdram_casn), 
        .We_n(sdram_wen), 
        .Dqm(sdram_dqm)
    );

    // Clock generation 
    initial begin
        clk = 0;
        forever #10  clk = ~clk;  //70MHz 7.1428571 !!! 10= 50 MHz clock
    end

    // Test sequence
    initial begin
        // Initialize inputs
        resetn = 0;
        addr = 0;
        din = 0;
        wmask = 0;
        valid = 0;

        // Apply reset
        #20;
        resetn = 1;
		
//////////////////////////////////////////////

        // Write operation
        #203000;
        addr = 22'h3FFF9C; //h3FFF9C; test address
        din = 32'hAABBCCDD;
        wmask = 4'b1111;
        valid = 1;


        // Wait for the write operation to complete
        wait(ready);
        valid = 0;
		
        // Read operation
        #200;
        addr = 22'h3FFF9C; //h3FFF9C; test address
		wmask = 4'b0000;
        valid = 1;
        //#20;


        // Wait for the read operation to complete
        wait(ready);
        valid = 0;
		
        // Check the output data
        #1000;
        if (dout != 32'hAABBCCDD) begin
            $display("ERROR: Read data mismatch! Expected: AABBCCDD, Got: %h", dout);
        end else begin
            $display("Read data correct: %h", dout);
        end

//////////////////////////////////////////////

        // Write operation
        #200;
        addr = 22'h00001;
        din = 32'hAABBCCDD;
        wmask = 4'b1001;
        valid = 1;


        // Wait for the write operation to complete
        wait(ready);
        valid = 0;

        // Read operation
        #200;
        addr = 22'h000001;
		wmask = 4'b0000;
        valid = 1;
        //#20;


        // Wait for the read operation to complete
        wait(ready);
        valid = 0;
		
        // Check the output data
        #1000;
        if (dout != 32'hAAxxxxDD) begin
            $display("ERROR: Read data mismatch! Expected: AAxxxxD, Got: %h", dout);
        end else begin
            $display("Read data correct: %h", dout);
        end
//////////////////////////////////////////////

        // Finish the simulation
        #50;
        $finish;
    end

    // Monitor signals
    initial begin
        $monitor("       DEBUG ===>Time: %0t, resetn: %b, addr: %h, din: %h, wmask: %b, valid: %b, dout: %h, ready: %b", 
                 $time, resetn, addr, din, wmask, valid, dout, ready);
    end

endmodule
