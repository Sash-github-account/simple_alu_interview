class output_monitor extends uvm_monitor;
   
   `uvm_component_utils(output_monitor)


   // Constructor //
   function new(string name="output_monitor", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new
   //_____________________//



   // Declarations //
   uvm_analysis_port  #(comp_reslt) comp_reslt_analysis_port;
   virtual output_intf o_vif;
   //_____________________//



   // Build phase //
   virtual function void build_phase(uvm_phase phase);
      
      super.build_phase(phase);
      
      if (!uvm_config_db#(virtual output_intf)::get(this, "", "output_intf", o_vif))
	`uvm_fatal("MON", "Could not get o_vif")
      
      comp_reslt_analysis_port = new ("comp_reslt_analysis_port", this);
      
   endfunction // build_phase
   //_____________________//



   // Run phase //
   virtual task run_phase(uvm_phase phase);
      
      super.run_phase(phase);
      
      fork
	 sample_port("Thread0");
      join
      
   endtask // run_phase
   //_____________________//


   
   // Task monitoring the activity on the interfaces //   
   virtual task sample_port(string tag="");

      forever begin
	 @(posedge o_vif.clk);
	 
         if (o_vif.result.vld) begin
            comp_reslt item = new;
	    item.result.vld = 1;	    
            item.result.data = o_vif.result.data;
            `uvm_info("MON", $sformatf("T=%0t [Monitor] %s First part over",$time, tag), UVM_LOW)
            comp_reslt_analysis_port.write(item);
            `uvm_info("MON", $sformatf("T=%0t [Monitor] %s Second part over, item:",$time, tag), UVM_LOW)
            item.print();
	 end // if ( vif.done)

      end
   endtask // sample_port
   //_____________________//


   
endclass // output_monitor

