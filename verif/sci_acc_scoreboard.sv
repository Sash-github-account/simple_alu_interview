class sci_acc_scoreboard extends uvm_scoreboard;
   
   `uvm_component_utils(sci_acc_scoreboard)
   `uvm_analysis_imp_decl(_port_a)
   `uvm_analysis_imp_decl(_port_b)

   
   // TLM ports and internal variable declarations//
   bit[7:0] expted_res_q[$];
   bit [7:0] res;
   bit [7:0] act_comptd_res_q[$];
   string    opcode[$];
   bit [7:0] popd_expted_res;
   bit [7:0] popd_act_comptd_res;
   bit [7:0] accum [integer];
   bit [7:0] sum;
   logic [NUM_WORD_WIDTH-1:0] num_words_int=0;
   integer 		      cnt_mean_terms = 0;
   
   uvm_analysis_imp_port_b #(comp_reslt, sci_acc_scoreboard) comp_reslt_analysis_imp;
   uvm_analysis_imp_port_a #(op_pkt, sci_acc_scoreboard) op_pkt_analysis_imp;
   //---------------//
   

   
   //Constructor for the scoreboard//
   function new(string name="sci_acc_scoreboard", uvm_component parent=null);
      super.new(name, parent);
   endfunction
   //-----------//
   
   
   
   // build analysis ports for input and output interface//
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      comp_reslt_analysis_imp = new("comp_reslt_analysis_imp", this);
      op_pkt_analysis_imp = new("op_pkt_analysis_imp", this);
   endfunction // build_phase
   //---------------//
   
   
   
   //Get the command, operand_a, operand_b; compute expected result based -
   //- on opcode of command and push into expected data queue
   virtual function write_port_a(op_pkt item);
      
      `uvm_info("write",$sformatf("DATA1 :%0d, DATA2: %0d",item.operand_a.data, item.operand_b.data), UVM_MEDIUM);
      
      if(item.alu_cmd.opcode == 0) begin 
	 res = item.operand_a.data + item.operand_b.data;
	 expted_res_q.push_back(res);
	 opcode.push_back("ADD");
      end
      
      else if(item.alu_cmd.opcode == 1) begin
	 res = item.operand_a.data - item.operand_b.data;
	 expted_res_q.push_back(res);
	 opcode.push_back("SUB");      
      end
      
      else if(item.alu_cmd.opcode == 2) begin 
	 res = item.operand_a.data * item.operand_b.data;
	 expted_res_q.push_back(res);
	 opcode.push_back("MULT");      
      end
      
      else if(item.alu_cmd.opcode == 3) begin 
	 res = item.operand_a.data / item.operand_b.data;
	 expted_res_q.push_back(res);
	 opcode.push_back("DIV");      
      end
      
      else if(item.alu_cmd.opcode == 4) begin
	 if(item.alu_cmd.vld) begin
	    num_words_int = item.alu_cmd.num_words;
	 end
	 else begin
	    cnt_mean_terms = cnt_mean_terms + 1;
	    accum[cnt_mean_terms] = item.operand_a.data;
	    `uvm_info("mean_exec",$sformatf("OPCODE :%0d, cnt_mean_terms=%0d, num_words_int=%0d, DATA:%0d",item.alu_cmd.opcode, cnt_mean_terms, num_words_int, item.operand_a.data), UVM_MEDIUM);
	    
	    if (num_words_int === cnt_mean_terms) begin
               `uvm_info("mean_exit",$sformatf("Exiting mean, ar=%p, sum=%0d, num_words=%0d", accum, accum.sum(), num_words_int), UVM_MEDIUM);
               sum = accum.sum();
               res = accum.sum() / num_words_int;
      	       expted_res_q.push_back(res);
      	       opcode.push_back("MEAN"); 
               cnt_mean_terms = 0;
               accum.delete();
	    end
	 end
      end
      
      
      
      `uvm_info("write",$sformatf("OPCODE :%0d, DATA1: %0d, DATA2: %0d, expted_res: %0d",item.alu_cmd.opcode, item.operand_a.data, item.operand_b.data, res), UVM_MEDIUM);

   endfunction // write_port_a   
   //---------------//
   
   
   
   // get computed result from DUT and push into its queue
   virtual function write_port_b(comp_reslt c_item);
      
      `uvm_info("write",$sformatf("Data:",c_item.result.data), UVM_MEDIUM);
      act_comptd_res_q.push_back(c_item.result.data);
      
   endfunction // write_port_a   
   //--------------//
   
   
   
   
   //Pop from queues and compare result vs expected  //
   virtual function void check_phase(uvm_phase phase);
      
      if(expted_res_q.size() != act_comptd_res_q.size()) begin
	 
	 `uvm_error("SCBD", $sformatf(" dut_res_q = %p, dut_res_q_size=%0d,\n expted_q=%p, expted_q_size=%0d", act_comptd_res_q, act_comptd_res_q.size(), expted_res_q, expted_res_q.size()))
	 
      end
      
      else begin
	 
	 integer size_of_q;
	 size_of_q = act_comptd_res_q.size();
	 
	 `uvm_info("SCBD", $sformatf(" dut_res_q = %p, dut_res_q_size=%0d,\n expted_q=%p, expted_q_size=%0d", act_comptd_res_q, act_comptd_res_q.size(), expted_res_q, expted_res_q.size()), UVM_LOW)
	 
	 for (int i=0; i<size_of_q; i=i+1) begin
            
            popd_expted_res = expted_res_q.pop_front();
      	    popd_act_comptd_res = act_comptd_res_q.pop_front();
            
            
            if( popd_expted_res == popd_act_comptd_res) begin
               `uvm_info("SCBD", $sformatf("PASS! OperationNumber: %0d, Opcode: %0s, dut_res=%0d, expted=%0d", i, opcode.pop_front(), popd_act_comptd_res, popd_expted_res), UVM_LOW)
	    end
            else begin
               `uvm_error("SCBD", $sformatf("UVM_ERROR! OperationNumber: %0d, Opcode: %0s, dut_res=%0d, expted=%0d", i, opcode.pop_front(), popd_act_comptd_res, popd_expted_res))
            end
	 end
      end
   endfunction
   //----------------//
   
   
endclass // sci_acc_scoreboard

