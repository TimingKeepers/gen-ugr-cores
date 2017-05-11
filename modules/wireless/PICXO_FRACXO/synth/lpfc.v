//*******************************************************************************
//** Copyright © 2004,2005,2006, Xilinx, Inc. 
//** This design is confidential and proprietary of Xilinx, Inc. All Rights Reserved.
//*******************************************************************************
//**   ____  ____ 
//**  /   /\/   / 
//** /___/  \  /   Vendor: Xilinx 
//** \   \   \/    Version: 1.0
//**  \   \        Filename: lp.v 
//**  /   /        Date Last Modified: 6/22/2006 
//** /___/   /\    Date Created: 11/9/2004
//** \   \  /  \ 
//**  \___\/\___\ 
//** 
//**   
//*******************************************************************************
//**
//**  Disclaimer: LIMITED WARRANTY AND DISCLAMER. These designs are
//**              provided to you "as is." Xilinx and its licensors make and you
//**              receive no warranties or conditions, express, implied,
//**              statutory or otherwise, and Xilinx specifically disclaims any
//**              implied warranties of merchantability, noninfringement, or
//**              fitness for a particular purpose. Xilinx does not warrant that
//**              the functions contained in these designs will meet your
//**              requirements, or that the operation of these designs will be
//**              uninterrupted or error free, or that defects in the Designs
//**              will be corrected. Furthermore, Xilinx does not warrant or
//**              make any representations regarding use or the results of the
//**              use of the designs in terms of correctness, accuracy,
//**              reliability, or otherwise.
//**
//**              LIMITATION OF LIABILITY. In no event will Xilinx or its
//**              licensors be liable for any loss of data, lost profits, cost
//**              or procurement of substitute goods or services, or for any
//**              special, incidental, consequential, or indirect damages
//**              arising from the use or operation of the designs or
//**              accompanying documentation, however caused and on any theory
//**              of liability. This limitation will apply even if Xilinx
//**              has been advised of the possibility of such damage. This
//**              limitation shall apply notwithstanding the failure of the
//**              essential purpose of any limited remedies herein.
//**
//*******************************************************************************
// Patent Pending
//-----------------------------------------------------------------
//  Digital Dual Loop Filter
//
//-----------------------------------------------------------------
`timescale 1ns/100ps
`ifdef TPDA
`else
 `define TPDB #0.1
 `define TPDA #0.1
`endif

module lpfc (/*AUTOARG*/
   // Outputs
   vc, b1x, a1x, new_intx, intx,
   // Inputs
   clk, clken, error, beta, alpha, rstcnt, rstint
   );
   input clk;         // input clock
   input clken;       // clock enable to run at DAC rate
   input [20:0] error; // error input signal
   input [3:0] beta;  // controls the 1st order loop gain
   input [3:0] alpha; // controls the 2nd order loop gain
   input rstcnt;      // reset signal indicating sample
   output [21:0] vc;  // output control voltage to DAC
   input rstint;      // signal to reset integrator
   
   //TEST
   output [22:0] b1x;  // output control voltage to DAC
   output [22:0] a1x;  // output control voltage to DAC
   output [21:0] new_intx;  // output control voltage to DAC
   output [21:0] intx;  // output control voltage to DAC
   
   reg [21:0]  vc;
   reg [22:0]  b1x;
   reg [22:0]  a1x;
   reg [21:0]  new_intx;
   reg [21:0]  intx;
   reg signed [21:0]  integrator;
   reg load;
   reg signed [22:0]  b1,a1,bias;
   wire signed [21:0] new_int;
   wire signed [21:0] new_vc,new_vcx;
   
   initial begin
      integrator = 22'd0;
      vc = 22'd2097152;
      bias = 23'd2097152;
   end
 
// register the control voltage(vc) and integrator  
   always@(posedge clk) begin
      if ((rstcnt))
	 load <= `TPDB 1;
      else if(clken)
	 load <= `TPDB 0;
      if (rstint) 
	 integrator <= `TPDB 32'h00000000;
      else if(load & clken) begin
	 integrator <= `TPDB new_int;
	 vc <= `TPDB new_vc;
	 b1x <= `TPDB b1;
	 a1x <= `TPDB a1;
	 new_intx <= `TPDB new_int;
	 intx <= `TPDB integrator;
      end
   end

//   always@(posedge clk) begin
//      if ((b1 + a1) > 23'd0)
//     assign new_vc = 2097152;
//      else if ((b1 + a1 + bias + bias) < 23'd0)
//     assign new_vc = -2097145;
//      else
//     assign new_vc = (b1 + a1 + bias);
//   end
      
   assign new_vc = ((b1 + a1) > 23'd0)               ? 22'h1FFFFF :
                   ((b1 + a1 + bias + bias) < 23'd0) ? 22'h200001 :
                                                  (b1 + a1 + bias);
   // sum first and second order outputs
   //assign new_vc = (b1 + a1 + bias);

   assign new_int = integrator - error;
   
   // Simple way to saturate the Control Voltage similar to what an Analog filter would do.
   //  assign `TPDA vc_new = (vc[11:8] == 4'hf & new_vc[11:8] == 4'h0) ? 16'h0FFF : (vc[11:8] == 4'h0 & new_vc[11:8] == 4'hf) ? 16'h0000 : {4'h0,new_vc[11:0]};
   
   
//-----------------------------------------------------------------
// Gain Stages
//-----------------------------------------------------------------

   always@(posedge clk)
      case(beta)
	 4'h0 : b1 = {{2{~error[20]}},error}; // keep sign
	 4'h1 : b1 = {{3{~error[20]}},error[20:1]};
	 4'h2 : b1 = {{4{~error[20]}},error[20:2]};
	 4'h3 : b1 = {{5{~error[20]}},error[20:3]};
	 4'h4 : b1 = {{6{~error[20]}},error[20:4]};
	 4'h5 : b1 = {{7{~error[20]}},error[20:5]};
	 4'h6 : b1 = {{8{~error[20]}},error[20:6]};
	 4'h7 : b1 = {{9{~error[20]}},error[20:7]};
	 4'h8 : b1 = {{10{~error[20]}},error[20:8]};
	 4'h9 : b1 = 22'h0; // not valid
	 4'ha : b1 = 22'h0; // {{6{error[8]}},error,8'h0};
	 4'hb : b1 = 22'h0; //{{5{error[8]}},error,9'h0};
	 4'hc : b1 = 22'h0; //{{4{error[8]}},error,10'h0};
	 4'hd : b1 = 22'h0; //{{3{error[8]}},error,11'h0};
	 4'he : b1 = 22'h0; //{{2{error[8]}},error,12'h0};
	 4'hf : b1 = 22'h0; //{error[8],error,13'h0}; //16'h0;
      endcase // case(beta)
   always@(posedge clk)
      case(alpha)
	 4'h0 : a1 = {new_int[21], new_int[21:0]}; // keep sign
	 4'h1 : a1 = {{2{new_int[21]}},new_int[21:1]};
	 4'h2 : a1 = {{3{new_int[21]}},new_int[21:2]};
	 4'h3 : a1 = {{4{new_int[21]}},new_int[21:3]};
	 4'h4 : a1 = {{5{new_int[21]}},new_int[21:4]};
	 4'h5 : a1 = {{6{new_int[21]}},new_int[21:5]};
	 4'h6 : a1 = {{7{new_int[21]}},new_int[21:6]};
	 4'h7 : a1 = {{8{new_int[21]}},new_int[21:7]};
	 4'h8 : a1 = {{9{new_int[21]}},new_int[21:8]};
	 4'h9 : a1 = {{10{new_int[21]}},new_int[21:9]};
	 4'ha : a1 = {{11{new_int[21]}},new_int[21:10]};
	 4'hb : a1 = {{12{new_int[21]}},new_int[21:11]};
	 4'hc : a1 = {{13{new_int[21]}},new_int[21:12]};
	 4'hd : a1 = {{14{new_int[21]}},new_int[21:13]};
	 4'he : a1 = {{15{new_int[21]}},new_int[21:14]};
	 4'hf : a1 = {{16{new_int[21]}},new_int[21:15]};
      endcase // case(alpha)
   

endmodule // div8
