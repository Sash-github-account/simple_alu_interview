// Top level testbench module to instantiate design, interfaces
// start clocks and run the test

`include "sci_acc_test.sv"

module tb;
   
   // Clock generation //
   reg clk;
   always #1 clk =~ clk;
   //-----/
   
   // Interface Declarations //
   op_a_intf    o_a_in(clk);
   op_b_intf    o_b_in(clk);
   alu_cmd_intf cmd_in(clk);
   output_intf 	o_if (clk);
   rst_intf 	rst_if (clk);
   //-----//

   
   // DUT instance //
   alu DUT(
	   .clk(clk),
	   .reset_n(rst_if.rst_n),
     	   .alu_cmd(cmd_in.cmd_in),
     	   .operand_a(o_a_in.op_a_in),
     	   .operand_b(o_b_in.op_b_in),
     	   .result(o_if.result)
	   );
   //--------//
   
   
   // Test instance //
   rand_test t0;
   //--------//
   

   // Capture waveforms //
   initial begin
      $dumpfile ("dump.vcd");
      $dumpvars;
   end
   //------//
   
   
   // Begin test //
   initial begin

      clk <= 0;
      uvm_config_db#(virtual op_a_intf)::set(null,"uvm_test_top", "op_a_intf",o_a_in);
      uvm_config_db#(virtual op_b_intf)::set(null,"uvm_test_top", "op_b_intf",o_b_in);
      uvm_config_db#(virtual alu_cmd_intf)::set(null,"uvm_test_top", "alu_cmd_intf",cmd_in);
      
      uvm_config_db#(virtual output_intf)::set(null,"uvm_test_top", "output_intf",o_if);
      uvm_config_db#(virtual rst_intf)::set(null,"uvm_test_top", "rst_intf",rst_if);

      run_test("rand_test");

      #500 $finish;
   end
   //-------//


endmodule
//-------//
