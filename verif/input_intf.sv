//`include "alu_pkg.svh"
//import alu_pkg::*


// reset interface //
interface rst_intf (input clk);

   // logic Declarations //
   logic rst_n;
   //_____________//

   // Clocking Block Definition //
   clocking cb @ (posedge clk);
      default input #1step output #1ns;
      input rst_n;
   endclocking // cb
   //_____________//
   
endinterface // rst_intf
//-----------//



// DUT operand_a input interface //
interface op_a_intf (input clk);

   // logic Declarations //
   uint_vld_t op_a_in;
   //_____________//

   // Clocking Block Definition //
   clocking cb @ (posedge clk);
      default input #1step output #1ns;
      input op_a_in;
   endclocking // cb
   //_____________//
   
endinterface // input_intf
//-----------//



// DUT operand_b input interface //
interface op_b_intf (input clk);

   // logic Declarations //
   uint_vld_t op_b_in;
   //_____________//

   // Clocking Block Definition //
   clocking cb @ (posedge clk);
      default input #1step output #1ns;
      input op_b_in;
   endclocking // cb
   //_____________//
   
endinterface // input_intf
//----------//



// command input driven into the DUT //
interface alu_cmd_intf (input clk);

   // logic Declarations //
   alu_cmd_t cmd_in;
   //_____________//

   
   // Clocking Block Definition //
   clocking cb @ (posedge clk);
      default input #1step output #1ns;
      input cmd_in;
   endclocking // cb
   //_____________//
   
   
endinterface // input_intf
//------------//



// output interface of ALU which will be monitored //
interface output_intf (input clk);
   
   // logic Declarations //
   uint_vld_t result;
   //_____________//
   
   
   // Clocking Block Definition //
   clocking cb @ (posedge clk);
      output result;  
   endclocking // cb
   //_____________//
   
   
endinterface // output_intf
//----------//
