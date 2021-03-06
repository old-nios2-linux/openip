# TCL File Generated by Component Editor 7.2sp1 on:
# Thu Mar 13 15:32:25 PDT 2008
# DO NOT MODIFY

set_source_file "tpo_lcd_controller.v"
set_module "tpo_lcd_controller"
set_module_property displayName "TPO TD043MTEA1 LCD Controller"
set_module_description "TPO TD043MTEA1 LCD Controller"
set_module_property "editable" "true"
set_module_property author "Nathan Knight"
set_module_property "group" "Display"
set_module_property "instantiateInSystemModule" "true"
set_module_property "version" "8.0"

# Module parameters
add_parameter "NUM_COLUMNS" "integer" "800" ""
set_parameter_property "NUM_COLUMNS" displayName "Display Width"
set_parameter_property "NUM_COLUMNS" allowedRanges { 400:400 800:800 }

add_parameter "NUM_ROWS" "integer" "480" ""
set_parameter_property "NUM_ROWS" displayName "Display Height"
set_parameter_property "NUM_ROWS" allowedRanges { 240:240 480:480 }

add_parameter "FIFO_DEPTH" "integer" "1024" "Width of the video stream fifo"
set_parameter_property "FIFO_DEPTH" displayName "FIFO Depth"
set_parameter_property "FIFO_DEPTH" allowedRanges { 512:512 1024:1024 2048:2048 4096:4096 8192:8192 }

add_parameter "DMA_DATA_WIDTH" "integer" "32" "Width of DMA Data Master"
set_parameter_property "DMA_DATA_WIDTH" displayName "DMA Data Width"
set_parameter_property "DMA_DATA_WIDTH" allowedRanges { 32:32 64:64 }


# Interface global_signals_clock
add_interface "global_signals_clock" "clock" "sink" "asynchronous"
# Ports in interface global_signals_clock
add_port_to_interface "global_signals_clock" "clk" "clk"
add_port_to_interface "global_signals_clock" "reset_n" "reset_n"

# Interface avalon_slave
add_interface "avalon_slave" "avalon" "slave" "global_signals_clock"
set_interface_property "avalon_slave" "isNonVolatileStorage" "false"
set_interface_property "avalon_slave" "burstOnBurstBoundariesOnly" "false"
set_interface_property "avalon_slave" "readLatency" "0"
set_interface_property "avalon_slave" "holdTime" "0"
set_interface_property "avalon_slave" "printableDevice" "false"
set_interface_property "avalon_slave" "readWaitTime" "1"
set_interface_property "avalon_slave" "setupTime" "0"
set_interface_property "avalon_slave" "addressAlignment" "DYNAMIC"
set_interface_property "avalon_slave" "writeWaitTime" "1"
set_interface_property "avalon_slave" "timingUnits" "Cycles"
set_interface_property "avalon_slave" "minimumUninterruptedRunLength" "1"
set_interface_property "avalon_slave" "isMemoryDevice" "true"
set_interface_property "avalon_slave" "linewrapBursts" "false"
set_interface_property "avalon_slave" "writeWaitStates" "1"
set_interface_property "avalon_slave" "maximumPendingReadTransactions" "0"
# Ports in interface avalon_slave
add_port_to_interface "avalon_slave" "slave_address" "address"
add_port_to_interface "avalon_slave" "slave_readdata" "readdata"
add_port_to_interface "avalon_slave" "slave_writedata" "writedata"
add_port_to_interface "avalon_slave" "slave_write" "write"
add_port_to_interface "avalon_slave" "slave_chipselect" "chipselect"

# Interface avalon_slave_irq
add_interface "avalon_slave_irq" "interrupt" "sender" "global_signals_clock"
set_interface_property "avalon_slave_irq" "associatedAddressablePoint" "avalon_slave"
# Ports in interface avalon_slave_irq
add_port_to_interface "avalon_slave_irq" "slave_irq" "irq"

# Interface avalon_master
add_interface "avalon_master" "avalon" "master" "global_signals_clock"
set_interface_property "avalon_master" "burstOnBurstBoundariesOnly" "false"
set_interface_property "avalon_master" "doStreamReads" "false"
set_interface_property "avalon_master" "linewrapBursts" "false"
set_interface_property "avalon_master" "doStreamWrites" "false"
# Ports in interface avalon_master
add_port_to_interface "avalon_master" "master_address" "address"
add_port_to_interface "avalon_master" "master_readdata" "readdata"
add_port_to_interface "avalon_master" "master_read" "read"
add_port_to_interface "avalon_master" "master_waitrequest" "waitrequest"
add_port_to_interface "avalon_master" "master_data_valid" "readdatavalid"
add_port_to_interface "avalon_master" "master_byteenable" "byteenable"

# Interface avalon_master_export
add_interface "avalon_master_export" "conduit" "start" "global_signals_clock"
# Ports in interface avalon_master_export
add_port_to_interface "avalon_master_export" "RGB" "export"
add_port_to_interface "avalon_master_export" "NCLK" "export"
add_port_to_interface "avalon_master_export" "HD" "export"
add_port_to_interface "avalon_master_export" "VD" "export"
add_port_to_interface "avalon_master_export" "DEN" "export"
add_port_to_interface "avalon_master_export" "SERIAL_SDA" "export"
add_port_to_interface "avalon_master_export" "SERIAL_SCL" "export"
add_port_to_interface "avalon_master_export" "SERIAL_SCEN" "export"
add_port_to_interface "avalon_master_export" "LCD_RESET" "export"
add_port_to_interface "avalon_master_export" "lcd_clk_in" "export"
