class gen_op_pkt_seq extends uvm_sequence;
   
   `uvm_object_utils(gen_op_pkt_seq)
   
   // Constructor //
   function new(string name="gen_op_pkt_seq");
      super.new(name);
   endfunction
   //----------//
   

   // Constraint and variable declarations // 
   rand int num; 	// Config total number of items to be sent

   constraint c1 { num inside {[10:10]}; } // Minimum and maximum no. of commands to produce   
   //------------//
   

   // Generate sequence //
   virtual task body();
      
      for (int i = 0; i < num; i ++) begin
    	 op_pkt m_item = op_pkt::type_id::create("m_item");
    	 start_item(m_item);
    	 m_item.randomize();
         `uvm_info("SEQ", $sformatf("Generate new item: Opcode = %0d", m_item.alu_cmd.opcode), UVM_LOW)
    	 m_item.print();
         
         if(m_item.alu_cmd.opcode == 4) begin
            integer num_words = m_item.alu_cmd.num_words;
            integer opcode = m_item.alu_cmd.opcode;
            m_item.alu_cmd.vld = 1;
            finish_item(m_item);
            for (int i=0; i< num_words; i= i+1) begin
               op_pkt op_a_item = op_pkt::type_id::create("op_a_item");
               start_item(op_a_item);
    	       op_a_item.randomize();
               op_a_item.alu_cmd.vld = 0;
               op_a_item.alu_cmd.opcode = opcode;
               op_a_item.alu_cmd.num_words = num_words;
               `uvm_info("SEQ", $sformatf("Generate new data for mean: num = %0d, Tot_req= %0d", i+1, num_words), UVM_LOW)
    	       op_a_item.print();
               finish_item(op_a_item);
            end
         end
         else begin
      	    finish_item(m_item);
         end
      end
      `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
      
   endtask
   //-------//
   
endclass
