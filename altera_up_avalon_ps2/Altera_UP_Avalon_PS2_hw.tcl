# TCL File Generated by Altera University Program
# DO NOT MODIFY

# +-----------------------------------
# | module altera_up_avalon_ps2
# | 
set_module_property DESCRIPTION "PS2 controller of the DE boards"
set_module_property NAME altera_up_avalon_ps2
set_module_property VERSION 8.0.0.1
set_module_property GROUP "University Program/Generic IO"
set_module_property AUTHOR "Altera University Program"
set_module_property DISPLAY_NAME "PS2 Controller"
set_module_property DATASHEET_URL doc/Altera_UP_PS2_Controller.pdf
#set_module_property TOP_LEVEL_HDL_FILE Altera_UP_Avalon_PS2.v
set_module_property TOP_LEVEL_HDL_MODULE Altera_UP_Avalon_PS2
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property SIMULATION_MODEL_IN_VERILOG false
set_module_property SIMULATION_MODEL_IN_VHDL false
set_module_property SIMULATION_MODEL_HAS_TULIPS false
set_module_property SIMULATION_MODEL_IS_OBFUSCATED false
set_module_property GENERATION_CALLBACK generate
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
#add_file Altera_UP_Avalon_PS2.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_reset
# | 
add_interface clock_reset clock end
set_interface_property clock_reset ptfSchematicName ""

add_interface_port clock_reset clk clk Input 1
add_interface_port clock_reset reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_ps2_slave
# | 
add_interface avalon_ps2_slave avalon end
set_interface_property avalon_ps2_slave holdTime 0
set_interface_property avalon_ps2_slave linewrapBursts false
set_interface_property avalon_ps2_slave minimumUninterruptedRunLength 1
set_interface_property avalon_ps2_slave bridgesToMaster ""
set_interface_property avalon_ps2_slave isMemoryDevice false
set_interface_property avalon_ps2_slave burstOnBurstBoundariesOnly false
set_interface_property avalon_ps2_slave addressSpan 8
set_interface_property avalon_ps2_slave timingUnits Cycles
set_interface_property avalon_ps2_slave setupTime 0
set_interface_property avalon_ps2_slave writeWaitTime 0
set_interface_property avalon_ps2_slave isNonVolatileStorage false
set_interface_property avalon_ps2_slave addressAlignment DYNAMIC
set_interface_property avalon_ps2_slave maximumPendingReadTransactions 0
set_interface_property avalon_ps2_slave readWaitStates 0
set_interface_property avalon_ps2_slave readWaitTime 0
set_interface_property avalon_ps2_slave readLatency 1
set_interface_property avalon_ps2_slave printableDevice false

set_interface_property avalon_ps2_slave ASSOCIATED_CLOCK clock_reset

add_interface_port avalon_ps2_slave address address Input 1
add_interface_port avalon_ps2_slave chipselect chipselect Input 1
add_interface_port avalon_ps2_slave byteenable byteenable Input 4
add_interface_port avalon_ps2_slave read read Input 1
add_interface_port avalon_ps2_slave write write Input 1
add_interface_port avalon_ps2_slave writedata writedata Input 32
add_interface_port avalon_ps2_slave readdata readdata Output 32
add_interface_port avalon_ps2_slave waitrequest waitrequest Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point external_interface
# | 
add_interface external_interface conduit end

set_interface_property external_interface ASSOCIATED_CLOCK clock_reset

add_interface_port external_interface PS2_CLK export Bidir 1
add_interface_port external_interface PS2_DAT export Bidir 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point interrupt
# | 
add_interface interrupt interrupt end
set_interface_property interrupt associatedAddressablePoint avalon_ps2_slave

set_interface_property interrupt ASSOCIATED_CLOCK clock_reset

add_interface_port interrupt irq irq Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | Generation function
# | 
proc generate {} {
	send_message info "Starting Generation of PS2 Controller"

	# get generation settings
	set language [ get_generation_setting HDL_LANGUAGE ] 
	set outdir [ get_generation_setting OUTPUT_DIRECTORY ] 
	set outname [ get_generation_setting OUTPUT_NAME ] 

	# get perl's path
	set qdr [ get_project_property QUARTUS_ROOTDIR ]
	set perl bin/perl/bin/perl.exe
	set perl "$qdr$perl"
	set perl_include sopc_builder/bin/perl_lib/
	if { [ file executable $perl ] } {
		set perl_include "-I$qdr$perl_include"
	} else {
		# But if it doesn't, maybe it can be found in the path:
		set perl "perl"
		set perl_include ""
	}

	# get parameter values

	# set arguments
	set files "Altera_UP_Avalon_PS2.v;Altera_UP_PS2.v;Altera_UP_PS2_Command_Out.v;Altera_UP_PS2_Data_In.v"

	# Generate HDL with perl
	exec $perl $perl_include UP_IP_Core_Generator.pl lang=$language dir=$outdir name=$outname files=$files
}
# | 
# +-----------------------------------

