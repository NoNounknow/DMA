
`timescale 1 ns / 1 ps

	module DMA_Custom_v2_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Master Bus Interface S_AXI
		parameter  		  C_S_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h2000000,
		parameter integer G_S_AXI_BURST_LEN					= 256		,
		parameter integer C_S_AXI_ID_WIDTH					= 1			,
		parameter integer C_S_AXI_ADDR_WIDTH				= 32		,
		parameter integer C_S_AXI_DATA_WIDTH				= 64		,
		parameter integer C_S_AXI_AWUSER_WIDTH				= 0			,
		parameter integer C_S_AXI_ARUSER_WIDTH				= 0			,
		parameter integer C_S_AXI_WUSER_WIDTH				= 0			,
		parameter integer C_S_AXI_RUSER_WIDTH				= 0			,
		parameter integer C_S_AXI_BUSER_WIDTH				= 0         ,
        parameter         Input_Data_width                  = 24        ,
        parameter         I_image_w                         = 1920      ,
        parameter         I_image_h                         = 1080      ,
        parameter         Pixel_byte_num                    = 4         ,
		parameter		  AXI_Buff_NUM						= 3		    
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Master Bus Interface S_AXI

		input  wire  						 	 s_axi_aclk     ,
		input  wire  						 	 s_axi_aresetn  ,
		output wire [C_S_AXI_ID_WIDTH-1 : 0] 	 s_axi_awid     ,
		output wire [C_S_AXI_ADDR_WIDTH-1 : 0]	 s_axi_awaddr   ,
		output wire [7 : 0]                      s_axi_awlen    ,
		output wire [2 : 0]                      s_axi_awsize   ,
		output wire [1 : 0]                      s_axi_awburst  ,
		output wire                              s_axi_awlock   ,
		output wire [3 : 0]                      s_axi_awcache  ,
		output wire [2 : 0]                      s_axi_awprot   ,
		output wire [3 : 0]                      s_axi_awqos    ,
		output wire [C_S_AXI_AWUSER_WIDTH-1 : 0] s_axi_awuser   ,
		output wire                              s_axi_awvalid  ,
		input  wire                              s_axi_awready  ,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0]   s_axi_wdata    ,
		output wire [C_S_AXI_DATA_WIDTH/8-1 : 0] s_axi_wstrb    ,
		output wire                              s_axi_wlast    ,
		output wire [C_S_AXI_WUSER_WIDTH-1 : 0]  s_axi_wuser    ,
		output wire                              s_axi_wvalid   ,
		input  wire                              s_axi_wready   ,
		input  wire [C_S_AXI_ID_WIDTH-1 : 0]     s_axi_bid      ,
		input  wire [1 : 0]                      s_axi_bresp    ,
		input  wire [C_S_AXI_BUSER_WIDTH-1 : 0]  s_axi_buser    ,
		input  wire                              s_axi_bvalid   ,
		output wire                              s_axi_bready   ,
		output wire [C_S_AXI_ID_WIDTH-1 : 0]     s_axi_arid     ,
		output wire [C_S_AXI_ADDR_WIDTH-1 : 0]   s_axi_araddr   ,
		output wire [7 : 0]                      s_axi_arlen    ,
		output wire [2 : 0]                      s_axi_arsize   ,
		output wire [1 : 0]                      s_axi_arburst  ,
		output wire                              s_axi_arlock   ,
		output wire [3 : 0]                      s_axi_arcache  ,
		output wire [2 : 0]                      s_axi_arprot   ,
		output wire [3 : 0]                      s_axi_arqos    ,
		output wire [C_S_AXI_ARUSER_WIDTH-1 : 0] s_axi_aruser   ,
		output wire                              s_axi_arvalid  ,
		input  wire                              s_axi_arready  ,
		input  wire [C_S_AXI_ID_WIDTH-1 : 0]     s_axi_rid      ,
		input  wire [C_S_AXI_DATA_WIDTH-1 : 0]   s_axi_rdata    ,
		input  wire [1 : 0]                      s_axi_rresp    ,
		input  wire                              s_axi_rlast    ,
		input  wire [C_S_AXI_RUSER_WIDTH-1 : 0]  s_axi_ruser    ,
		input  wire                              s_axi_rvalid   ,
		output wire                              s_axi_rready   ,

        //Custom Control
        input  wire                              Enabled        ,
        // Ports of Input Data
        input  wire                              I_Pre_clk      ,
        input  wire                              I_Pre_vs       ,
        input  wire [Input_Data_width-1:0]       I_Pre_data     ,
        input  wire                              I_Pre_de       ,

		input  wire							     I_Post_clk     ,
		output wire							     O_Post_Start   ,
		output wire [Input_Data_width-1:0]	     O_Post_data    ,
		input  wire							     I_Post_de	 	,
		input  wire                              I_Post_vs		,
        //Aribe
        output wire  							 O_wr_req          	,
        input  wire  							 I_Aribe_wr_enable 	,
        output wire  							 O_wr_brust_now    	,
        output wire  							 O_wr_brust_end    	,             
 
        output wire  							 O_rd_req          	,
        input  wire  							 I_Aribe_rd_enable 	,
        output wire  							 O_rd_brust_now    	,
        output wire  							 O_rd_brust_end    	
	);

// Instantiation of Axi Bus Interface S_AXI
	DMA_Custom_Mult # ( 
		.C_M_TARGET_SLAVE_BASE_ADDR	( C_S_AXI_TARGET_SLAVE_BASE_ADDR),
		.C_M_AXI_BURST_LEN			( G_S_AXI_BURST_LEN				),
		.C_M_AXI_ID_WIDTH			( C_S_AXI_ID_WIDTH				),
		.C_M_AXI_ADDR_WIDTH			( C_S_AXI_ADDR_WIDTH			),
		.C_M_AXI_DATA_WIDTH			( C_S_AXI_DATA_WIDTH			),
		.C_M_AXI_AWUSER_WIDTH		( C_S_AXI_AWUSER_WIDTH			),
		.C_M_AXI_ARUSER_WIDTH		( C_S_AXI_ARUSER_WIDTH			),
		.C_M_AXI_WUSER_WIDTH		( C_S_AXI_WUSER_WIDTH			),
		.C_M_AXI_RUSER_WIDTH		( C_S_AXI_RUSER_WIDTH			),
		.C_M_AXI_BUSER_WIDTH		( C_S_AXI_BUSER_WIDTH			),
        .I_image_w                  ( I_image_w                     ),
        .I_image_h                  ( I_image_h                     ),
        .Pixel_byte_num             ( Pixel_byte_num                ),
		.AXI_Buff_NUM				( AXI_Buff_NUM					),
        .Input_Data_width           ( Input_Data_width              )
	) DMA_Custom (
		
		//Aribe
		.O_wr_req          ( O_wr_req          ),
		.I_Aribe_wr_enable ( I_Aribe_wr_enable ),
		.O_wr_brust_now    ( O_wr_brust_now    ),
		.O_wr_brust_end    ( O_wr_brust_end    ),
		.O_rd_req          ( O_rd_req          ),
		.I_Aribe_rd_enable ( I_Aribe_rd_enable ),
		.O_rd_brust_now    ( O_rd_brust_now    ),
		.O_rd_brust_end    ( O_rd_brust_end    ),

        .I_Pre_clk    ( I_Pre_clk   ),  
        .I_Pre_vs     ( I_Pre_vs    ),  
        .I_Pre_data   ( I_Pre_data  ),  
        .I_Pre_de	  ( I_Pre_de    ),      

        .I_Post_clk   ( I_Post_clk  ),     
        .O_Post_Start ( O_Post_Start),     
        .O_Post_data  ( O_Post_data ),     
        .I_Post_de	  ( I_Post_de	),     
		.I_Post_vs	  ( I_Post_vs	),

		.M_AXI_ACLK   (	s_axi_aclk		),
		.M_AXI_ARESETN(	s_axi_aresetn&&(!Enabled)),
		.M_AXI_AWID	  (	s_axi_awid		),
		.M_AXI_AWADDR (	s_axi_awaddr	),
		.M_AXI_AWLEN  (	s_axi_awlen		),
		.M_AXI_AWSIZE (	s_axi_awsize	),
		.M_AXI_AWBURST(	s_axi_awburst	),
		.M_AXI_AWLOCK (	s_axi_awlock	),
		.M_AXI_AWCACHE(	s_axi_awcache	),
		.M_AXI_AWPROT (	s_axi_awprot	),
		.M_AXI_AWQOS  (	s_axi_awqos		),
		.M_AXI_AWUSER (	s_axi_awuser	),
		.M_AXI_AWVALID(	s_axi_awvalid	),
		.M_AXI_AWREADY(	s_axi_awready	),
		.M_AXI_WDATA  ( s_axi_wdata		),
		.M_AXI_WSTRB  ( s_axi_wstrb		),
		.M_AXI_WLAST  ( s_axi_wlast		),
		.M_AXI_WUSER  ( s_axi_wuser		),
		.M_AXI_WVALID ( s_axi_wvalid	),
		.M_AXI_WREADY ( s_axi_wready	),
		.M_AXI_BID	  ( s_axi_bid		),
		.M_AXI_BRESP  ( s_axi_bresp		),
		.M_AXI_BUSER  ( s_axi_buser		),
		.M_AXI_BVALID ( s_axi_bvalid	),
		.M_AXI_BREADY ( s_axi_bready	),
		.M_AXI_ARID	  ( s_axi_arid		),
		.M_AXI_ARADDR ( s_axi_araddr	),
		.M_AXI_ARLEN  ( s_axi_arlen		),
		.M_AXI_ARSIZE ( s_axi_arsize	),
		.M_AXI_ARBURST( s_axi_arburst	),
		.M_AXI_ARLOCK ( s_axi_arlock	),
		.M_AXI_ARCACHE( s_axi_arcache	),
		.M_AXI_ARPROT ( s_axi_arprot	),
		.M_AXI_ARQOS  ( s_axi_arqos		),
		.M_AXI_ARUSER ( s_axi_aruser	),
		.M_AXI_ARVALID( s_axi_arvalid	),
		.M_AXI_ARREADY( s_axi_arready	),
		.M_AXI_RID	  ( s_axi_rid		),
		.M_AXI_RDATA  ( s_axi_rdata		),
		.M_AXI_RRESP  ( s_axi_rresp		),
		.M_AXI_RLAST  ( s_axi_rlast		),
		.M_AXI_RUSER  ( s_axi_ruser		),
		.M_AXI_RVALID ( s_axi_rvalid	),
		.M_AXI_RREADY ( s_axi_rready    )
	);

	// Add user logic here

	// User logic ends

	endmodule
