// Code your design here

//Importing the package that has been provided -that contains bus type definitions-
//-and system parameters

//ADDED for simulation in eda playground//
`include "alu_pkg.svh"
import alu_pkg::*;
`include "add.sv"
`include "sub.sv"
`include "div.sv"
`include "mul.sv"
//_____________//


module alu
  (

   input  clk,
   input  reset_n,

   input  alu_cmd_t alu_cmd,
   input  uint_vld_t operand_a,
   input  uint_vld_t operand_b,

   output uint_vld_t result

   );
   
   
   
   //  QUESTIONS AND ASSUMPTIONS: //
   // 1. Assuming ALU cannot recieve a new command till result is generated for the previous command

   // 2. Assuming individual commands and each individual operand will remain valid for one cycle-
   //    - designed internal register to hold these values till end of execution and generation of result.
   
   // 3. Regarding Arithmetic mean operation:
   //    are we expected to compute arithmetic mean of only operands a,b? - assuming no
   //    -or-
   //    does the field of the input signal 'alu_cmd.num_words' indicate the number of operands involed in 
   //    computng the mean? - assuming yes, the design would expect data on operand_a for no. of cycles = 'num_words'
   //     sender ie. test bench should send out the same no. of data before expecting a result to be generated
   //    - or -
   //    will valid data arrive on both buses 'operand_a' and 'operand_b'? - assuming no, data should arrive
   //    only on bus operand_a

   // 3. Will command and all operands arrive the same cycle? - assuming no, since both command bus and 
   //    each of the operand's bus have their own valid signal.
   
   //------------------------------//

   
   
   

   // FSM encoding //
   typedef enum logic [2:0] {
			     IDLE,
			     EXEC,
			     SEND_OUT_RES,
			     SEND_OUT_MEAN
			     } ALU_FSM;
   //---------//


   
   // Definion of internal wires and registers for ALU //
   ALU_FSM cur_state;
   ALU_FSM nxt_state;
   uint_t add_operand_1;
   uint_t add_operand_2;
   uint_t sub_operand_1;
   uint_t sub_operand_2;
   uint_t mul_operand_1;
   uint_t mul_operand_2;
   uint_t div_operand_1;
   uint_t div_operand_2;

   uint_t adder_out;
   uint_t sub_out;
   uint_t mult_out;
   uint_t div_out;
   uint_t div_remainder;
   
   logic 	op_done;
   logic [NUM_WORD_WIDTH-1:0] cnt;
   //-----------//

   

   //capture incoming command //
   logic 		      cmd_int__vld;
   ALU_OP_E cmd_int__opcode;
   logic [NUM_WORD_WIDTH-1:0] cmd_int__num_words;
   
   always_ff @(posedge clk) begin
      if(reset_n) begin
	 cmd_int__vld <= 0;
	 cmd_int__opcode <= 0;
	 cmd_int__num_words <= 0;
      end
      else begin		 
	 
	 if(alu_cmd.vld) begin
	    cmd_int__vld <= alu_cmd.vld;
       	    cmd_int__opcode <= alu_cmd.opcode;
	    cmd_int__num_words <= alu_cmd.num_words;

	 end
	 else begin 
	    cmd_int__vld <= cmd_int__vld;
	    cmd_int__opcode <= cmd_int__opcode;
	    cmd_int__num_words <= cmd_int__num_words;
	 end
         
	 if(op_done) begin
	    cmd_int__vld <= 0;
	    cmd_int__opcode <= 0;
	    cmd_int__num_words <= 0;
	 end
         
      end // else: !if(reset_n)
   end // always_ff @ (posedge clk)
   //---------//
   

   
   // capture incoming operand_a // 
   uint_vld_t op_a_int;
   
   always_ff @(posedge clk) begin
      if(reset_n) begin
	 op_a_int.vld <= 0;
	 op_a_int.data <= 0;
      end
      else begin
	 
	 
	 //if(cmd_int__opcode != 4) begin
	 if(operand_a.vld) begin
	    op_a_int <= operand_a;
	 end
	 else op_a_int <= op_a_int;
         
         if(op_done) begin
	    op_a_int.vld <= 0;
	    op_a_int.data <= 0;
	 end	 
         
      end
      //else begin op_a_int <= operand_a; end
      //end // else: !if(reset_n)
   end // always_ff @ (posedge clk)
   //---------//
   

   
   // capture incoming operand_b //
   uint_vld_t op_b_int;
   
   always_ff @(posedge clk) begin
      if(reset_n) begin
	 op_b_int.vld <= 0;
	 op_b_int.data <= 0;
      end
      else begin 
	 
	 if(operand_b.vld) begin
	    op_b_int <= operand_b;
	 end
	 else op_b_int <= op_b_int;
         
	 if(op_done) begin
	    op_b_int.vld <= 0;
	    op_b_int.data <= 0;
	 end	
      end // else: !if(reset_n)
   end // always_ff @ (posedge clk)
   //---------------//
   
   
   
   //ALU Execution FSM //
   // FSM output generation //
   always_ff@(posedge clk)begin
      if(reset_n)begin
	 cur_state <= IDLE;	
	 cnt <= 0;
	 result.vld <= 0;
	 result.data <= 0;
	 op_done <= 0;
	 add_operand_1 <= 0;
   	 add_operand_2 <= 0;
   	 sub_operand_1 <= 0;
	 sub_operand_2 <= 0;
	 mul_operand_1 <= 0;
	 mul_operand_2 <= 0;
	 div_operand_1 <= 0;
	 div_operand_2 <= 1;
      end
      else begin
	 cur_state <= nxt_state;
	 
	 if(cur_state == EXEC) begin
	    // Input control and MUXING //
	    case(cmd_int__opcode)
	      ADD: begin
		 add_operand_1 <= op_a_int.data;	      
		 add_operand_2 <= op_b_int.data;
		 op_done <= 1;
	      end

	      SUB: begin
		 sub_operand_1 <= op_a_int.data;	      
		 sub_operand_2 <= op_b_int.data;
		 op_done <= 1;
	      end
	      
	      MUL: begin
		 mul_operand_1 <= op_a_int.data;	      
		 mul_operand_2 <= op_b_int.data;
		 op_done <= 1;
	      end
	      
	      DIV: begin
		 div_operand_1 <= op_a_int.data;	      
		 div_operand_2 <= op_b_int.data;
		 op_done <= 1;
	      end

	      MEAN: begin
		 op_done <= 0;
          	 
		 if(op_a_int.vld) begin
		    cnt <= cnt + 1;
		    add_operand_1 <= op_a_int.data;
		    add_operand_2 <= adder_out;		   
		 end
		 else begin
		    cnt <= cnt;
		    add_operand_1 <= 0;
		    add_operand_2 <= adder_out;
		 end
		 
		 
	      end // case: MEAN	      
	      
	      default: begin
		 result.vld <= 0;
		 result.data <= 0;
		 op_done <= 0;	 
		 add_operand_1 <= 0;
   		 add_operand_2 <= 0;
   		 sub_operand_1 <= 0;
		 sub_operand_2 <= 0;
		 mul_operand_1 <= 0;
		 mul_operand_2 <= 0;
		 div_operand_1 <= 0;
		 div_operand_2 <= 1;
	      end // case: default
	    endcase
	    //--------//
	 end // if (cur_state == EXEC)
         
	 else if (cur_state == SEND_OUT_RES) begin
	    // Output MUX //
	    case (cmd_int__opcode)		   
	      ADD: begin
		 result.vld <= 1;
		 result.data <= adder_out;		      
	      end
	      
	      SUB:begin
		 result.vld <= 1;
		 result.data <= sub_out;
	      end
	      
	      MUL:begin
		 result.vld <= 1;
		 result.data <= mult_out;
	      end
	      
	      DIV: begin
		 result.vld <= 1;
		 result.data <= div_out;
	      end
	      
	      MEAN: begin
		 cnt <= 0;
		 op_done <= 1;
		 div_operand_1 <= adder_out;
		 div_operand_2 <= cmd_int__num_words;	        
	      end
	      default: begin
		 result.vld <= 0;
		 result.data <= 0;
	      end
	    endcase // case (alu_cmd.opcode)
       	    //------//
	    
	 end // if (cur_state == SEND_OUT_RES)
	 
	 else if(cur_state == SEND_OUT_MEAN) begin
            op_done <=0;           
       	    result.vld <= 1;
	    result.data <= div_out;
	 end
	 
	 else  begin
	    cur_state <= nxt_state;	    
	    result.vld <= 0;
	    result.data <= 0;
	    op_done <= 0;	 
	    add_operand_1 <= 0;
   	    add_operand_2 <= 0;
   	    sub_operand_1 <= 0;
	    sub_operand_2 <= 0;
	    mul_operand_1 <= 0;
	    mul_operand_2 <= 0;
	    div_operand_1 <= 0;
	    div_operand_2 <= 1;
	 end	 
	 
      end // else: !if(reset_n)
   end // always_ff@ (posedge clk)
   //---------//
   
   
   
   // State transitions//
   always@(*) begin
      nxt_state = IDLE;
      
      case (cur_state)
	IDLE : begin
	   if(cmd_int__vld) begin
	      nxt_state = EXEC;	      
	   end // if (alu_cmd.vld)
	   else begin
	      nxt_state = IDLE;
	   end // else: !if(alu_cmd.vld)
	end // case: IDLE

	EXEC: begin
	   if(op_a_int.vld & op_b_int.vld & cmd_int__opcode != MEAN) begin
	      nxt_state = SEND_OUT_RES;
	   end
	   
	   else if (cmd_int__opcode == MEAN) begin
              if(cnt == cmd_int__num_words-1) begin
		 nxt_state = SEND_OUT_RES;		 
	      end
	      else nxt_state = EXEC;
	   end
	   else begin
	      nxt_state = EXEC;
	   end
	end
	
	
	SEND_OUT_RES: begin
	   if(cmd_int__opcode == MEAN ) begin
              nxt_state = SEND_OUT_MEAN;
	   end
	   else begin
      	      nxt_state = IDLE;
	   end
	end	
        
	SEND_OUT_MEAN: begin
           nxt_state = IDLE;
	end

	default: nxt_state = IDLE;
      endcase // case (cur_state)
   end // always@ (*)
   //End of FSM //
   //----------//
   

   
   // Instantiation of provided ALU modules
   add i_add(
	     .a(add_operand_1),
	     .b(add_operand_2),
     	     .out(adder_out)
	     );

   sub i_sub(
	     .a(sub_operand_1),
	     .b(sub_operand_2),
	     .out(sub_out)
	     );

   mult i_mul(
	      .a(mul_operand_1),
	      .b(mul_operand_2),
     	      .out(mult_out)
	      );

   div i_div(
	     .a(div_operand_1),
	     .b(div_operand_2),
	     .out(div_out),
	     .remainder(div_remainder)
	     );

   
endmodule
