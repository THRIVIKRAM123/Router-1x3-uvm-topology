`include "uvm_macros.svh"
import uvm_pkg::*;

//..................have to create seperate monitors,drivers,sequencers,agents......................then the code will compile.

//....................... Config class  ..............................


class config1 extends uvm_object;

  `uvm_object_utils(config1)
  
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  int no_of_source_agents=1;
  int no_of_destination_agents=3;
  bit has_source_agent_top=1;
  bit has_destination_agent_top=1;
  bit has_score_board = 1;
  bit no_of_sources=1;
  int no_of_destinations=3;

  function new(string name="config1");
    super.new(name);
  endfunction

endclass

//...................... Source Transaction Class ............................

class src_xtn extends uvm_sequence_item;
`uvm_object_utils(src_xtn)

function new(string name="src_xtn");
super.new(name);
endfunction

endclass

//......................  Destination Transaction Class ............................

class dst_xtn extends uvm_sequence_item;
`uvm_object_utils(dst_xtn)

function new(string name="dst_xtn");
super.new(name);
endfunction

endclass



//....................... Source Driver class  ...............................


class src_driver extends uvm_driver;
  `uvm_component_utils(src_driver)
  
  function new(string name="src_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass

//....................... Destination Driver class  ...............................


class dst_driver extends uvm_driver;
  `uvm_component_utils(dst_driver)
  
  function new(string name="dst_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass


//.......................  Source Monitor class ...............................


class src_monitor extends uvm_monitor;
  `uvm_component_utils(src_monitor)
  
uvm_analysis_port#(src_xtn) s_ap;

  function new(string name="src_monitor", uvm_component parent = null);
    super.new(name, parent);
    s_ap=new("s_ap",this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass


//.......................  Destination Monitor class ...............................


class dst_monitor extends uvm_monitor;
  `uvm_component_utils(dst_monitor)
  
uvm_analysis_port#(dst_xtn) d_ap;

  function new(string name="dst_monitor", uvm_component parent = null);
    super.new(name, parent);
    d_ap=new("d_ap",this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass


//.......................  Source Sequencer class  ..............................


class src_seqr extends uvm_sequencer;
  `uvm_component_utils(src_seqr)
  
  function new(string name="src_seqr", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass

//.......................  Destination Sequencer class  ..............................


class dst_seqr extends uvm_sequencer;
  `uvm_component_utils(dst_seqr)
  
  function new(string name="dst_seqr", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass



//.......................  Source Agent class  ...................................


class src_agent extends uvm_agent;
  config1 cfg;
  src_driver drvh;
  src_monitor src_monh;
  src_seqr seqh;
  
  `uvm_component_utils(src_agent)
  
  function new(string name="src_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Retrieve the configuration for the agent
    if (!uvm_config_db#(config1)::get(this, "", "config1", cfg)) begin
      `uvm_fatal("CONFIG", "Configuration not found in agent")
    end
    
     src_monh = src_monitor::type_id::create("src_monh", this);

    if (cfg.is_active == UVM_ACTIVE) begin
      drvh = src_driver::type_id::create("drvh", this);
      seqh = src_seqr::type_id::create("seqh", this);
    end
    endfunction

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
if (cfg.is_active == UVM_ACTIVE) begin
drvh.seq_item_port.connect(seqh.seq_item_export);
end
   
  endfunction
endclass

//.......................  Destination Agent class  ...................................


class dst_agent extends uvm_agent;
  config1 cfg;
  dst_driver drvh;
  dst_monitor dst_monh;
  dst_seqr seqh;
  
  `uvm_component_utils(dst_agent)
  
  function new(string name="dst_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Retrieve the configuration for the agent
    if (!uvm_config_db#(config1)::get(this, "", "config1", cfg)) begin
      `uvm_fatal("CONFIG", "Configuration not found in agent")
    end
    
     dst_monh = dst_monitor::type_id::create("dst_monh", this);

    if (cfg.is_active == UVM_ACTIVE) begin
      drvh = dst_driver::type_id::create("drvh", this);
      seqh = dst_seqr::type_id::create("seqh", this);
    end
    endfunction

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
if (cfg.is_active == UVM_ACTIVE) begin
drvh.seq_item_port.connect(seqh.seq_item_export);
end
   
  endfunction
endclass

//..........................  Destination Agent Top .....................................


class destination_agent_top extends uvm_component;
  `uvm_component_utils(destination_agent_top)
  config1 cfg;
dst_agent d_agh[];

  //int no_of_agents=3;
  function new(string name="destination_agent_top", uvm_component parent );
    super.new(name, parent);
  endfunction
  
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
   if (!uvm_config_db#(config1)::get(this, "", "config1", cfg)) 
    begin
      `uvm_fatal("CONFIG", "Configuration not found in environment")
    end

    d_agh=new[cfg.no_of_destination_agents];
   // agh = agent::type_id::create("agh", this);
foreach(d_agh[i])
	begin
		d_agh[i] = dst_agent::type_id::create($sformatf("d_agh[%0d]",i),this);
	end

  endfunction
endclass

//..........................  Source Agent Top .....................................


class source_agent_top extends uvm_component;
  `uvm_component_utils(source_agent_top)
  config1 cfg;
src_agent s_agh[];

  //int no_of_agents=3;
  function new(string name="source_agent_top", uvm_component parent );
    super.new(name, parent);
  endfunction
  
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
   if (!uvm_config_db#(config1)::get(this, "", "config1", cfg)) 
    begin
      `uvm_fatal("CONFIG", "Configuration not found in environment")
    end

    s_agh=new[cfg.no_of_source_agents];
   // agh = agent::type_id::create("agh", this);
foreach(s_agh[i])
	begin
		s_agh[i] = src_agent::type_id::create($sformatf("s_agh[%0d]",i),this);
	end

  endfunction
endclass
//.......................... Score Board ...................................

class score_board extends uvm_scoreboard;
  `uvm_component_utils(score_board)

config1 cfg;

  uvm_tlm_analysis_fifo#(src_xtn) src_fifo[];
  uvm_tlm_analysis_fifo#(dst_xtn) dst_fifo[];

  function new(string name="score_board", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
 
    function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		if(!uvm_config_db #(config1)::get(this,"","config1",cfg))
			`uvm_fatal("config","cannot get in scoreboard")
		src_fifo = new[cfg.no_of_sources];
			foreach(src_fifo[i])
			src_fifo[i] = new($sformatf("src_fifo[%0d]",i),this);

		dst_fifo = new[cfg.no_of_destinations];
			foreach(dst_fifo[i])
			dst_fifo[i] = new($sformatf("dst_fifo[%0d]",i),this);

	endfunction
endclass

//..........................  Environment class  ............................


class env extends uvm_env;
`uvm_component_utils(env)

config1 cfg;

source_agent_top src_agh_top;
destination_agent_top dst_agh_top;
score_board sb;

function new(string name="env", uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
if (!uvm_config_db#(config1)::get(this, "", "config1", cfg)) 
    begin
      `uvm_fatal("CONFIG", "Configuration not found in environment")
    end

if(cfg.has_source_agent_top)
src_agh_top=source_agent_top::type_id::create("src_agh_top",this);

if(cfg.has_destination_agent_top)
dst_agh_top=destination_agent_top::type_id::create("dst_agh_top",this);

if(cfg.has_score_board)
sb=score_board::type_id::create("sb",this);

endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);

                                foreach (src_agh_top.s_agh[i])
					src_agh_top.s_agh[i].src_monh.s_ap.connect(sb.src_fifo[i].analysis_export);
				foreach (dst_agh_top.d_agh[i])
					dst_agh_top.d_agh[i].dst_monh.d_ap.connect(sb.dst_fifo[i].analysis_export);
                              
                           

endfunction

endclass



//..............................  Test class  ...................................


class test extends uvm_test;
  `uvm_component_utils(test)
  env env_h;
  config1 cfg;
  
  function new(string name="test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cfg = config1::type_id::create("cfg");
    env_h = env::type_id::create("env_h", this);

    uvm_config_db#(config1)::set(this, "*", "config1", cfg);
  endfunction
 
endclass



//...............................  Top-level module  ...............................
module top;
  initial
  begin
    uvm_top.enable_print_topology = 1;
    run_test("test");
  end
endmodule

