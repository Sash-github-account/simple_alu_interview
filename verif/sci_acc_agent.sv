`include "op_pkt_driver.sv"
`include "output_monitor.sv"



class sci_acc_agent extends uvm_agent;
   
   `uvm_component_utils(sci_acc_agent)
   
   // Constructor //
   function new(string name="sci_acc_agent", uvm_component parent=null);
      super.new(name, parent);
   endfunction
   //----------//

   
   //Declarations //
   op_pkt_driver 		d0; 		// Driver handle
   output_monitor 		m0; 		// Monitor handle
   uvm_sequencer #(op_pkt)	s0; 		// Sequencer Handle
   //-------------//

   
   // Build Monitor, Driver and Sequencer //
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      s0 = uvm_sequencer#(op_pkt)::type_id::create("s0", this);
      d0 = op_pkt_driver::type_id::create("d0", this);
      m0 = output_monitor::type_id::create("m0", this);
   endfunction
   //---------//
   
   
   // Connect driver item port to sequencer export //
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      d0.seq_item_port.connect(s0.seq_item_export);
   endfunction
   //----------//
   
   
endclass
