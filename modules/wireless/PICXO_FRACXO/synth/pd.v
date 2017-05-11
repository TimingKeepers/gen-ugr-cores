//*******************************************************************************
//** Copyright © 2004,2005,2006, Xilinx, Inc. 
//** This design is confidential and proprietary of Xilinx, Inc. All Rights Reserved.
//*******************************************************************************
//**   ____  ____ 
//**  /   /\/   / 
//** /___/  \  /   Vendor: Xilinx 
//** \   \   \/    Version: 1.0
//**  \   \        Filename: pd.v 
//**  /   /        Date Last Modified: 6/22/2006 
//** /___/   /\    Date Created: 12/23/2004
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
//  Accumulating Bang-Bang Phase Detector circuit
//
//-----------------------------------------------------------------
`timescale 1ns/100ps
`ifdef TPDA
`else
 `define TPDB #0.1
 `define TPDA #0.1
`endif

module pd (/*AUTOARG*/
   // Outputs
   data, phase_error, 
   // Inputs
   refsig, rstcnt, vcoclk, reset
   );
   input refsig;             // reference signal (can be data signal)
   input rstcnt;             // Reset signal for accumulators and sampler
   input vcoclk;             // Clock signal from VCO
   output data;              // output data signal if refsig is a data signal
   output [20:0] phase_error; // phase error signal
   input  reset;             // global reset signal
   
   reg a,b,t,ta;
   reg up, down;
   wire data;
   reg [20:0] phase_error;
   reg [11:0] upcnt,dncnt;
   wire signed [20:0] new_pe;
   
   initial begin
      upcnt = 0;
      dncnt = 0;
      phase_error = 0;
   end
   
   assign data =  a;

   
//-----------------------------------------------------------------
// Standard Bang-Bang Phase Detector
//-----------------------------------------------------------------
   
   always@(negedge vcoclk or posedge reset)
      if(reset) begin
	 ta <= `TPDB 0;
      end
      else begin
	 ta <= `TPDB refsig;
      end
   
   always@(posedge vcoclk or posedge reset)
      if(reset) begin
	 a <= `TPDB 0;
	 b <= `TPDB 0;
	 t <= `TPDB 0;
      end
      else begin
	 b <= `TPDB refsig;
	 a <= `TPDB b;
 	 t <= `TPDB ta;
     end

//-----------------------------------------------------------------
// Decode phase detector outputs
//-----------------------------------------------------------------

   always@(a or b or t)
      case({a,t,b})
	 3'b000 : begin // no trans
	    up = 0;
	    down = 0;
	 end
	 3'b001 : begin // too fast
	    up = 0;
	    down = 1;
	 end
	 3'b010 : begin // invalid
	    up = 1;
	    down = 1;
	    $display("Error in PFD %b %b %b %t",a,t,b,$time);
	 end
	 3'b011 : begin // too slow
	    up = 1;
	    down = 0;
	 end
	 3'b100 : begin // too slow
	    up = 1;
	    down = 0;
	 end
	 3'b101 : begin // invalid
	    up = 1;
	    down = 1;
	    $display("Error in PFD %b %b %b %t",a,t,b,$time);
	 end
	 3'b110 : begin // too fast
	    up = 0;
	    down = 1;
	 end
	 3'b111 : begin // no trans
	    up = 0;
	    down = 0;
	 end
      endcase // case(a,t,b)
   
   
//-----------------------------------------------------------------
// Up and Down Accumulators
//-----------------------------------------------------------------

   always@(posedge vcoclk) begin
      if(rstcnt) begin
	 upcnt <= `TPDB 12'h0000;
	 dncnt <= `TPDB 12'h0000;
	 phase_error  <= `TPDB {new_pe[20],new_pe[19:0]};
      end
      else if(up & !down)
	 upcnt <= `TPDB upcnt + 1;
      else if(down & !up)
	 dncnt <= `TPDB dncnt + 1;
   end

   assign new_pe = upcnt - dncnt;
   
endmodule // pd
