`include "sci_acc_agent.sv"
`include "sci_acc_scoreboard.sv"



class sci_acc_env extends uvm_env;
   
   `uvm_component_utils(sci_acc_env)


   // Constructor //
   function new(string name="sci_acc_env", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new
   //___________//


   
   // Declarations //
   sci_acc_agent a0; 		// Agent handle
   sci_acc_scoreboard	sb0; 		// Scoreboard handle
   //___________//



   // Build phase //
   virtual function void build_phase(uvm_phase phase);
      
      super.build_phase(phase);
      
      a0 =  sci_acc_agent::type_id::create("a0", this);
      sb0 = sci_acc_scoreboard::type_id::create("sb0", this);
      
   endfunction
   //___________//



   // Connect monitor and driver with scoreboard //
   virtual function void connect_phase(uvm_phase phase);
      
      super.connect_phase(phase);
      
      a0.m0.comp_reslt_analysis_port.connect(sb0.comp_reslt_analysis_imp);
      a0.d0.oppkt2scrbd_ap.connect(sb0.op_pkt_analysis_imp);
      
   endfunction // connect_phase
   //___________//


   
endclass // sci_acc_env

