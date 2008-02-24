module openeth ( /*AUTOARG*/
   // Outputs
   s_readdata, s_waitrequest, m_address, m_byteenable, m_read,
   m_write, m_writedata, tx_d, tx_en, tx_err, md_c, s_irq,
   // Inouts
   md_io,
   // Inputs
   clk, reset, s_address, s_chipselect, s_write, s_read, s_byteenable,
   s_writedata, m_readdata, m_waitrequest, tx_clk, rx_clk, rx_d,
   rx_dv, rx_err, rx_col, rx_crs
   );

   input clk;
   input reset;
   // slave
   input  [9: 0]  s_address;
   input  	  s_chipselect;
   input 	  s_write;
   input 	  s_read;
   input  [ 3: 0] s_byteenable;
   input  [31: 0] s_writedata;
   output [31: 0] s_readdata;
   output 	  s_waitrequest;
   // memory master
   output [31: 0] m_address;
   output [ 3: 0] m_byteenable;
   output 	  m_read;
   output 	  m_write;
   output [31: 0] m_writedata;
   input  [31: 0] m_readdata;
   input 	  m_waitrequest;
   // TX
   input 	  tx_clk;
   output [3:0]   tx_d;
   output 	  tx_en;
   output 	  tx_err;
   // RX
   input 	  rx_clk;
   input [3:0] 	  rx_d;
   input 	  rx_dv;
   input 	  rx_err;
   input 	  rx_col;
   input 	  rx_crs;
   // MIIM
   output 	  md_c;
   inout 	  md_io;
   // irq
   output 	  s_irq;
 	  
   wire 	  m_stb;
   assign 	  m_read = m_stb & ~m_write;

   wire 	  ack_o;
   assign 	  s_waitrequest = ~ack_o;

   wire 	  md_out;
   wire 	  md_oe;
   wire 	  md_in;
   assign 	  md_in = md_io;
   assign 	  md_io = md_oe ? md_out : 1'bz;

eth_top the_eth
(
  // WISHBONE common
  .wb_clk_i (clk), 
  .wb_rst_i (reset),

  // WISHBONE slave
  .wb_dat_i (s_writedata),
  .wb_dat_o (s_readdata), 
  .wb_adr_i (s_address),
  .wb_sel_i (s_byteenable),
  .wb_we_i  (s_write),
  .wb_cyc_i (s_chipselect),
  .wb_stb_i (s_chipselect),
  .wb_ack_o (ack_o),

  // WISHBONE master
  .m_wb_adr_o (m_address),
  .m_wb_sel_o (m_byteenable),
  .m_wb_we_o  (m_write), 
  .m_wb_dat_o (m_writedata),
  .m_wb_dat_i (m_readdata),
  .m_wb_stb_o (m_stb),
  .m_wb_ack_i (~m_waitrequest),
  .m_wb_err_i (1'b0), 

  //TX
  .mtx_clk_pad_i (tx_clk),
  .mtxd_pad_o (tx_d),
  .mtxen_pad_o (tx_en),
  .mtxerr_pad_o (tx_err),

  //RX
  .mrx_clk_pad_i (rx_clk),
  .mrxd_pad_i (rx_d),
  .mrxdv_pad_i (rx_dv),
  .mrxerr_pad_i (rx_err),
  .mcoll_pad_i (rx_col),
  .mcrs_pad_i (rx_crs), 
  
  // MIIM
  .mdc_pad_o (md_c),
  .md_pad_i (md_in),
  .md_pad_o (md_out),
  .md_padoe_o (md_oe),

  .int_o (s_irq)

);




   
endmodule // openeth
