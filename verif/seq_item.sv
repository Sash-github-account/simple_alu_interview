import uvm_pkg::*;


// input command and data packet //
class op_mean_a extends uvm_sequence_item; 
   
   // Declarations //
   rand  uint_vld_t operand_a;
   //-------// 
   
   
   // Use utility macros to implement standard functions
   // like print, copy, clone, etc
   `uvm_object_utils_begin(op_mean_a)
      `uvm_field_int (operand_a, UVM_DEFAULT)
   `uvm_object_utils_end
   //-------------//
   

   // Constructor //
   function new(string name = "op_mean_a");
      super.new(name);
   endfunction // new
   //----------//
   
endclass // op_mean_a
//--------//



// input command and data packet //
class op_pkt extends uvm_sequence_item; 
   
   // Declarations //
   rand  alu_cmd_t alu_cmd;
   rand  uint_vld_t operand_a;
   rand  uint_vld_t operand_b;
   //-------// 
   

   // Constraints for opcode and number of data words for mean computation //
   constraint c_cmd_opcode { alu_cmd.opcode inside {[0:4]}; }
   constraint c_cmd_num_words { alu_cmd.num_words inside {[10:10]}; }
   constraint c_operand_a_data { operand_a.data inside {[0:255]}; }
   constraint c_operand_b_data { operand_b.data inside {[0:255]}; }
   //---------// 
   
   
   // Use utility macros to implement standard functions
   // like print, copy, clone, etc
   `uvm_object_utils_begin(op_pkt)
      `uvm_field_int (alu_cmd, UVM_DEFAULT)
      `uvm_field_int (operand_a, UVM_DEFAULT)
      `uvm_field_int (operand_b, UVM_DEFAULT)
   `uvm_object_utils_end
   //-------------//
   

   // Constructor //
   function new(string name = "op_pkt");
      super.new(name);
   endfunction // new
   //----------//
   
endclass // op_pkt
//--------//



// result object //
class comp_reslt extends uvm_sequence_item;
   
   // Declarations //
   uint_vld_t result;
   //---------// 
   
   // Use utility macros to implement standard functions
   // like print, copy, clone, etc
   `uvm_object_utils_begin(comp_reslt)
      `uvm_field_int (result,     UVM_DEFAULT)
   `uvm_object_utils_end
   //------------//
   
   
   // Constructor //
   function new(string name = "comp_reslt");
      super.new(name);
   endfunction // new
   //-----------//
   
endclass // comp_reslt
//--------//

