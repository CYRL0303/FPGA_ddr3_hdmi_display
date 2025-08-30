module  fifo_ctrl(
        // system signals
        input                   s_rst_n,                     
        // UART
        input [7:0]	uart_rx_data,               
        input                   uart_rx_vld,      

		
        // WFIFO
		input                   wfifo_wr_clk,                
        input                   wfifo_rd_clk,                
        input                   wfifo_rd_en,                 
        output  wire [127:0] wfifo_rd_data,               
        output  wire            wr_trig,

		//RFIFO
		input					rfifo_wr_clk,
		input					rfifo_wr_en,
		input [127:0]	rfifo_wr_data,
		  
		output 	wire			rd_trig,
		
		input					rfifo_rd_clk,
		input					rfifo_rd_en,
		output	wire [15:0]	rfifo_rd_data
		
);

reg                             wfifo_wr_en	;       
reg     [127:0]                 wfifo_wr_data	;
reg     [ 3:0]                  byte_cnt	;

wire    [ 4:0]                  wfifo_data_count	;
wire    [ 4:0]                  rfifo_data_count	;
 // WFIFO

assign  wr_trig =	(wfifo_data_count >= 'd16) ? 1'b1 : 1'b0;

always  @(posedge wfifo_wr_clk or negedge s_rst_n) begin
	if(s_rst_n == 1'b0)
		byte_cnt	<=	'd0;
	else if(uart_rx_vld == 1'b1 && byte_cnt == 'd15)
		byte_cnt	<=	'd0;
	else if(uart_rx_vld == 1'b1)
		byte_cnt	<=	byte_cnt + 1'b1;
end

always  @(posedge wfifo_wr_clk or negedge s_rst_n) begin
	if(s_rst_n == 1'b0)
		wfifo_wr_en     <= 	1'b0;
	else if(uart_rx_vld == 1'b1 && byte_cnt == 'd15)
		wfifo_wr_en     <=	1'b1;
	else
		wfifo_wr_en     <= 	1'b0;
end

always  @(posedge wfifo_wr_clk or negedge s_rst_n) begin
	if(s_rst_n == 1'b0)
		wfifo_wr_data   <=	128'h0;
	else if(uart_rx_vld == 1'b1)
		wfifo_wr_data   <=	{wfifo_wr_data[119:0], uart_rx_data};
end

//RFIFO
assign rd_trig = (rfifo_data_count	<	'd16) ? 1'b1 : 1'b0;










fifo_generator_0 rfifo_ip_inst (
  .rst(~s_rst_n),                      // input wire rst
  .wr_clk(rfifo_wr_clk),                // input wire wr_clk
  .rd_clk(rfifo_rd_clk),                // input wire rd_clk
  .din(rfifo_wr_data),                      // input wire [127 : 0] din
  .wr_en(rfifo_wr_en),                  // input wire wr_en
  .rd_en(rfifo_rd_en),                  // input wire rd_en
  .dout(rfifo_rd_data),                    // output wire [15 : 0] dout
  .full(	),                    // output wire full
  .empty(	),                  // output wire empty
  .wr_data_count(rfifo_data_count),  // output wire [4 : 0] wr_data_count
  .wr_rst_busy(	),      // output wire wr_rst_busy
  .rd_rst_busy(	)      // output wire rd_rst_busy
);















wfifo_ip        wfifo_ip_inst (
        .rst                    (~s_rst_n               ),                      // input wire rst
        .wr_clk                 (wfifo_wr_clk           ),                // input wire wr_clk
        .rd_clk                 (wfifo_rd_clk           ),                // input wire rd_clk
        .din                    (wfifo_wr_data          ),                      // input wire [127 : 0] din
        .wr_en                  (wfifo_wr_en            ),                  // input wire wr_en
        .rd_en                  (wfifo_rd_en            ),                  // input wire rd_en
        .dout                   (wfifo_rd_data          ),                    // output wire [127 : 0] dout
        .full                   (                       ),                    // output wire full
        .empty                  (                       ),                  // output wire empty
        .rd_data_count          (wfifo_data_count       ),  // output wire [4 : 0] rd_data_count
        .wr_rst_busy            (                       ),      // output wire wr_rst_busy
        .rd_rst_busy            (                       )// output wire rd_rst_busy
);





endmodule
