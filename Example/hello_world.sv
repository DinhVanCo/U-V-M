`include "uvm_pkg.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;
// Step 1: Declare a new class that derives from "uvm_test"
   class base_test extends uvm_test;
   
   	  // Step 2: Register this class with UVM Factory
      `uvm_component_utils (base_test)
      
      // Step 3: Define the "new" function 
      function new (string name, uvm_component parent = null);
         super.new (name, parent);
      endfunction

      // Step 4: Declare other testbench components
      my_env   m_top_env;              // Testbench environment
      my_cfg   m_cfg0;                 // Configuration object
      

      // Step 5: Instantiate and build components declared above
      virtual function void build_phase (uvm_phase phase);
         super.build_phase (phase);

         // [Recommended] Instantiate components using "type_id::create()" method instead of new()
         m_top_env  = my_env::type_id::create ("m_top_env", this);
         m_cfg0     = my_cfg::type_id::create ("m_cfg0", this);
      
         // [Optional] Configure testbench components if required
         set_cfg_params ();

         // [Optional] Make the cfg object available to all components in environment/agent/etc
         uvm_config_db #(my_cfg) :: set (this, "m_top_env.my_agent", "m_cfg0", m_cfg0);
      endfunction

      // [Optional] Define testbench configuration parameters, if its applicable
      virtual function void set_cfg_params ();
         // Get DUT interface from top module into the cfg object
         if (! uvm_config_db #(virtual dut_if) :: get (this, "", "dut_if", m_cfg0.vif)) begin
            `uvm_error (get_type_name (), "DUT Interface not found !")
         end
         
         // Assign other parameters to the configuration object that has to be used in testbench
         m_cfg0.m_verbosity    = UVM_HIGH;
         m_cfg0.active         = UVM_ACTIVE;
      endfunction

	  // [Recommended] By this phase, the environment is all set up so its good to just print the topology for debug
      virtual function void end_of_elaboration_phase (uvm_phase phase);
         uvm_top.print_topology ();
      endfunction

      function void start_of_simulation_phase (uvm_phase phase);
         super.start_of_simulation_phase (phase);
         
         // [Optional] Assign a default sequence to be executed by the sequencer or look at the run_phase ...
         uvm_config_db#(uvm_object_wrapper)::set(this,"m_top_env.my_agent.m_seqr0.main_phase",
                                          "default_sequence", base_sequence::type_id::get());

      endfunction
      
      // or [Recommended] start a sequence for this particular test
      virtual task run_phase (uvm_phase phase);
      	my_seq m_seq = my_seq::type_id::create ("m_seq");
      	
      	super.run_phase(phase);
      	phase.raise_objection (this);
      	m_seq.start (m_env.seqr);
      	phase.drop_objection (this);
      endtask
   endclass 