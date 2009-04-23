//                              -*- Mode: Verilog -*-
// Filename        : gpio.v
// Description     : a bitwise gpio
// Created On      : Mon Jan 22 09:38:50 2007
// Status          : Unknown, Use with caution!

// this is a bitwise gpio to be used with i2c,spi,sdio,1 wire etc.
// it is not like Altera's pio, each access is bit by bit.
// currently up to 16 pins can be addressed.
// port pin[i] can be addressed with base+(i*4)
// the port can operate at two output modes, 
// writedata[1] : 0=open-drain (default), 1=totem-pole
// writedata[0] : output data
// readdata[0] : input data from pin


module gpio (
             /*AUTOARG*/
   // Outputs
   readdata,
   // Inouts
   bidir_port,
   // Inputs
   address, clk, reset_n, write_n, writedata
   );
   


   parameter WIDTH = 2;
   
   inout [  WIDTH-1: 0] bidir_port;
   output [  0: 0] 	readdata;
   input [  3: 0] 	address;
   input 		clk;
   input 		reset_n;
   input 		write_n;
   input [  1: 0] 	writedata;

   reg [  WIDTH-1: 0] 	bidir_port;
   reg [  0: 0] 	readdata;
   reg [  WIDTH-1: 0] 	data_mode;
   reg [  WIDTH-1: 0] 	data_outz;
   reg [  WIDTH-1: 0] 	data_mode_v;
   reg [  WIDTH-1: 0] 	data_outz_v;
   integer N;
   
   always @(data_mode or data_outz)
     for (N = 0; N <= (WIDTH-1) ; N = N+1)
       bidir_port[N] = data_mode[N]? (data_outz[N]? 1'b0:1'b1) : (data_outz[N]? 1'b0:1'bz);

   always @(/*AS*/address or bidir_port)
     readdata[0] = bidir_port[address];
   
   always @(/*AS*/address or data_outz or write_n or writedata)
     for (N = 0; N <= (WIDTH-1) ; N = N+1)
       data_outz_v[N] = (~write_n & (address == N)) ? ~writedata[0] : data_outz[N];

   always @(/*AS*/address or data_mode or write_n or writedata)
     for (N = 0; N <= (WIDTH-1) ; N = N+1)
       data_mode_v[N] = (~write_n & (address == N)) ? writedata[1] : data_mode[N];

   always @(posedge clk or negedge reset_n)
     begin
	if (reset_n == 0)
	  begin
             data_outz <= 0;
	     data_mode <=0;
	  end       
	else
	  begin
	     data_outz <= data_outz_v;
	     data_mode <= data_mode_v;	   
	  end	   
     end // always @ (posedge clk or negedge reset_n)

endmodule
   