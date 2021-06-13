`include "input_intf.sv"
`include "seq_item.sv"



class op_pkt_driver extends uvm_driver #(op_pkt);
   
   `uvm_component_utils(op_pkt_driver)
   
   // Constructor//
   function new(string name = "op_pkt_driver", uvm_component parent=null);
      super.new(name, parent);
   endfunction
   //-----------//
   
   
   
   // Declarations //
   uvm_analysis_port#(op_pkt) oppkt2scrbd_ap;

   virtual op_a_intf op_a_vintf;
   virtual op_b_intf op_b_vintf;
   virtual alu_cmd_intf alu_cmd_vintf;
   virtual output_intf comp_reslt_vintf;
   //----------------//
   
   
   
   // Build virtual interfaces to DUT and analysis port to scoreboard //
   virtual function void build_phase(uvm_phase phase);
      
      super.build_phase(phase);
      
      if (!uvm_config_db#(virtual op_a_intf)::get(this, "", "op_a_intf", op_a_vintf))
	`uvm_fatal("DRV", "Could not get vif")
      
      if (!uvm_config_db#(virtual op_b_intf)::get(this, "", "op_b_intf", op_b_vintf))
	`uvm_fatal("DRV", "Could not get vif")
      
      if (!uvm_config_db#(virtual alu_cmd_intf)::get(this,  "", "alu_cmd_intf", alu_cmd_vintf))
	`uvm_fatal("DRV", "Could not get vif") 
      
      if (!uvm_config_db#(virtual output_intf)::get(this,  "", "output_intf",comp_reslt_vintf))
	`uvm_fatal("DRV", "Could not get vif") 
      
      oppkt2scrbd_ap = new("op_pkt_analysis_port", this);
   endfunction
   //---------//
   
   
   
   
   // Run phase- get next command/data item to be sent//      
   virtual task run_phase(uvm_phase phase);
      
      super.run_phase(phase);
      
      forever begin
	 op_pkt m_item;
	 `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_LOW)
	 seq_item_port.get_next_item(m_item);
	 drive_item(m_item);
         `uvm_info("DRV", $sformatf("Waiting for item from result for DUT"), UVM_LOW)
         oppkt2scrbd_ap.write(m_item);
         
         if(m_item.alu_cmd.opcode == 4) begin
            integer num_words = m_item.alu_cmd.num_words;
            seq_item_port.item_done(m_item);
            for (int i=0; i < num_words; i=i+1) begin
               op_pkt op_a_item;
               seq_item_port.get_next_item(op_a_item);
               drive_for_mean(op_a_item);
               oppkt2scrbd_ap.write(op_a_item);
               if(i == num_words-1) begin 
		  make_bus_zero(op_a_item);
		  wait_for_result(0, op_a_item);
               end
               seq_item_port.item_done(op_a_item);
            end
         end
         
      end
      
   endtask
   //--------//

   
   virtual task make_bus_zero(op_pkt op_a_item);
      @ (posedge alu_cmd_vintf.clk);
      op_a_vintf.op_a_in <= 0;
      op_a_vintf.op_a_in.vld <= 0;      
   endtask
   
   virtual task drive_for_mean(op_pkt op_a_item);
      
      @ (posedge alu_cmd_vintf.clk);
      op_a_vintf.op_a_in <= op_a_item.operand_a;
      op_a_vintf.op_a_in.vld <= 1;  
   endtask
   

   // drive command, operand_a and operand_b into the DUT
   // Wait for result to be generated before sending out item_done()
   virtual task drive_item(op_pkt m_item);

      
      // Drive DUT inputs  // 
      @ (posedge alu_cmd_vintf.clk);
      alu_cmd_vintf.cmd_in <= 0;
      op_a_vintf.op_a_in <= 0;   
      op_b_vintf.op_b_in <= 0;     
      
      @ (posedge alu_cmd_vintf.clk);
      alu_cmd_vintf.cmd_in <= m_item.alu_cmd;
      alu_cmd_vintf.cmd_in.vld <= 1;    
      
      if(m_item.alu_cmd.opcode != 4) begin
	 op_a_vintf.op_a_in <= m_item.operand_a;
    	 op_a_vintf.op_a_in.vld <= 1;   
	 op_b_vintf.op_b_in <= m_item.operand_b;
    	 op_b_vintf.op_b_in.vld <= 1;
      end
      else begin
	 op_b_vintf.op_b_in <= 0;
    	 op_b_vintf.op_b_in.vld <= 0;
	 op_a_vintf.op_a_in <= 0;
    	 op_a_vintf.op_a_in.vld <= 0;
      end
      
      @ (posedge alu_cmd_vintf.clk);
      alu_cmd_vintf.cmd_in <= 0;
      op_a_vintf.op_a_in <= 0;   	
      op_b_vintf.op_b_in <= 0;
      //----------------//
      
      wait_for_result(alu_cmd_vintf.cmd_in.vld, m_item);

   endtask
   //------//
   
   
   // Wait for end of computation //
   virtual task wait_for_result(bit is_mean_cmd, op_pkt m_item);

      `uvm_info("DRV", $sformatf("Entered wait for result, is_mean_cmd = %0d",is_mean_cmd), UVM_LOW)
      // exit the loop based on opcode, and if operation is MEAN, check if the command - 
      //- is being driven or if waiting for result after final operand has been sent 
      do begin
	 @ (posedge alu_cmd_vintf.clk);  
	 if( m_item.alu_cmd.opcode != 4) begin  
            if(comp_reslt_vintf.result.vld ) seq_item_port.item_done(m_item);
       	    //continue;
	 end
	 else  begin
            `uvm_info("DRV", $sformatf("ENTER WAIT FOR RESULT LOOP"), UVM_LOW)

            if(is_mean_cmd)  break;
            
            else begin
               if(comp_reslt_vintf.result.vld )  continue;
            end
	 end
      end while(!comp_reslt_vintf.result.vld );
      //-------//
      
   endtask
   //-------//

endclass
