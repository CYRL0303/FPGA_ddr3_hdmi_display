module hdmi_top(
        // system signals
        input		fast_clk	,       
		input		low_clk		,
        input		s_rst_n 	,       
		
        //FIFO
		output wire				fifo_rd_en		,
		input			[15:0]	fifo_rd_data	,
			
			
		// HDMI	
        output  wire            hdmi_clk_p  	,       
        output  wire            hdmi_clk_n  	,       
        output  wire    [2:0]   hdmi_data_p 	,       
        output  wire    [2:0]   hdmi_data_n 	       
);

//internal signals
wire    [7:0]		vga_r     	;       
wire    [7:0]		vga_g     	;       
wire    [7:0]		vga_b     	;       
wire         	 vga_hsync 	;       
wire         	 vga_vsync 	;       
		
wire         	 clk_25m   	;       
wire    [9:0]		ch0_10bit 	;
wire    [9:0]		ch1_10bit 	;
wire    [9:0]		ch2_10bit 	;
wire         	 vga_de    	;       
		
wire         	 pll_locked	;       







assign  vga_r	= 	{fifo_rd_data[15:11], 3'h0};
assign  vga_g	= 	{fifo_rd_data[10:05], 2'h0};
assign  vga_b	= 	{fifo_rd_data[04:00], 3'h0};
assign fifo_rd_en	=	vga_de;


v_tc_0 v_tc_0_inst (				//PIXEL CLK : 74.25Mhz for 1080p
  .clk(low_clk),                            // input wire clk
  .clken(1'b1),                        // input wire clken
  .gen_clken(1'b1),                // input wire gen_clken
  .sof_state(1'b0),                // input wire sof_state
  .hsync_out(vga_hsync),                // output wire hsync_out
  .hblank_out(		),              // output wire hblank_out
  .vsync_out(vga_vsync),                // output wire vsync_out
  .vblank_out(		),              // output wire vblank_out
  .active_video_out(vga_de),  // output wire active_video_out
  .resetn(s_rst_n),                      // input wire resetn
  .fsync_out(		)                // output wire [0 : 0] fsync_out
);


TMDSEncoder     TMDSEncoder_CH0(
        .D_I                    (vga_b                  ),
        .C0_I                   (vga_vsync              ),
        .C1_I                   (vga_hsync              ),
        .DE_I                   (vga_de                 ),
        .CLK_I                  (low_clk                ),
        .D_O                    (ch0_10bit              )
);

TMDSEncoder     TMDSEncoder_CH1(
        .D_I                    (vga_g                  ),
        .C0_I                   (1'b0                   ),
        .C1_I                   (1'b0                   ),
        .DE_I                   (vga_de                 ),
        .CLK_I                  (low_clk                ),
        .D_O                    (ch1_10bit              )
);

TMDSEncoder     TMDSEncoder_CH2(
        .D_I                    (vga_r                  ),
        .C0_I                   (1'b0                   ),
        .C1_I                   (1'b0                   ),
        .DE_I                   (vga_de                 ),
        .CLK_I                  (low_clk                ),
        .D_O                    (ch2_10bit              )
);

selectio_wiz_0  selectio_CH0(
        .data_out_from_device   (ch0_10bit              ), // input [9:0] data_out_from_device
        .data_out_to_pins_p     (hdmi_data_p[0]         ), // output [0:0] data_out_to_pins_p
        .data_out_to_pins_n     (hdmi_data_n[0]         ), // output [0:0] data_out_to_pins_n
        .clk_in                 (fast_clk               ), // input clk_in                            
        .clk_div_in             (clk_25m                ), // input clk_div_in                        
        .io_reset               (~s_rst_n	            )// input io_reset
); 

selectio_wiz_0  selectio_CH1(
        .data_out_from_device   (ch1_10bit              ), // input [9:0] data_out_from_device
        .data_out_to_pins_p     (hdmi_data_p[1]         ), // output [0:0] data_out_to_pins_p
        .data_out_to_pins_n     (hdmi_data_n[1]         ), // output [0:0] data_out_to_pins_n
        .clk_in                 (fast_clk               ), // input clk_in                            
        .clk_div_in             (low_clk                ), // input clk_div_in                        
        .io_reset               (~s_rst_n	           )// input io_reset
); 

selectio_wiz_0  selectio_CH2(
        .data_out_from_device   (ch2_10bit              ), // input [9:0] data_out_from_device
        .data_out_to_pins_p     (hdmi_data_p[2]         ), // output [0:0] data_out_to_pins_p
        .data_out_to_pins_n     (hdmi_data_n[2]         ), // output [0:0] data_out_to_pins_n
        .clk_in                 (fast_clk               ), // input clk_in                            
        .clk_div_in             (low_clk                ), // input clk_div_in                        
        .io_reset               (~s_rst_n	            )// input io_reset
); 

OBUFDS
      #(.IOSTANDARD ("TMDS_33"))
obufds_inst(
        .O                      (hdmi_clk_p             ),
        .OB                     (hdmi_clk_n             ),
        .I                      (low_clk                )
);

endmodule
