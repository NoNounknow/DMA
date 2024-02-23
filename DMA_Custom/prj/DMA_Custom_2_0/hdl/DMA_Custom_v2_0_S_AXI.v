
`timescale 1 ns / 1 ps

    module DMA_Custom #
    (
        parameter         C_M_TARGET_SLAVE_BASE_ADDR    = 32'h2000000,
        parameter integer C_M_AXI_BURST_LEN             = 256  ,
        parameter integer C_M_AXI_ID_WIDTH              = 1    ,
        parameter integer C_M_AXI_ADDR_WIDTH            = 32   ,
        parameter integer C_M_AXI_DATA_WIDTH            = 64   ,
        parameter integer C_M_AXI_AWUSER_WIDTH          = 0    ,
        parameter integer C_M_AXI_ARUSER_WIDTH          = 0    ,
        parameter integer C_M_AXI_WUSER_WIDTH           = 0    ,
        parameter integer C_M_AXI_RUSER_WIDTH           = 0    ,
        parameter integer C_M_AXI_BUSER_WIDTH           = 0    ,
        parameter         I_image_w                     = 1920 ,
        parameter         I_image_h                     = 1080 ,
        parameter         Pixel_byte_num                = 4    ,
        parameter         AXI_Buff_NUM                  = 3    ,
        parameter         Input_Data_width              = 24
    )
    (
        input    wire                              M_AXI_ACLK    ,
        input    wire                              M_AXI_ARESETN ,
        output   wire [C_M_AXI_ID_WIDTH-1 : 0]     M_AXI_AWID    ,
        output   wire [C_M_AXI_ADDR_WIDTH-1 : 0]   M_AXI_AWADDR  ,
        output   wire [7 : 0]                      M_AXI_AWLEN   ,
        output   wire [2 : 0]                      M_AXI_AWSIZE  ,
        output   wire [1 : 0]                      M_AXI_AWBURST ,
        output   wire                              M_AXI_AWLOCK  ,
        output   wire [3 : 0]                      M_AXI_AWCACHE ,
        output   wire [2 : 0]                      M_AXI_AWPROT  ,
        output   wire [3 : 0]                      M_AXI_AWQOS   ,
        output   wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER  ,
        output   wire                              M_AXI_AWVALID ,
        input    wire                              M_AXI_AWREADY ,

        output   wire [C_M_AXI_DATA_WIDTH-1 : 0]   M_AXI_WDATA   ,
        output   wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB   ,
        output   wire                              M_AXI_WLAST   ,
        output   wire [C_M_AXI_WUSER_WIDTH-1 : 0]  M_AXI_WUSER   ,
        output   wire                              M_AXI_WVALID  ,
        input    wire                              M_AXI_WREADY  ,

        input    wire [C_M_AXI_ID_WIDTH-1 : 0]     M_AXI_BID,
        input    wire [1 : 0]                      M_AXI_BRESP   ,
        input    wire [C_M_AXI_BUSER_WIDTH-1 : 0]  M_AXI_BUSER   ,
        input    wire                              M_AXI_BVALID  ,
        output   wire                              M_AXI_BREADY  ,

        output   wire [C_M_AXI_ID_WIDTH-1 : 0]     M_AXI_ARID    ,
        output   wire [C_M_AXI_ADDR_WIDTH-1 : 0]   M_AXI_ARADDR  ,
        output   wire [7 : 0]                      M_AXI_ARLEN   ,
        output   wire [2 : 0]                      M_AXI_ARSIZE  ,
        output   wire [1 : 0]                      M_AXI_ARBURST ,
        output   wire                              M_AXI_ARLOCK  ,
        output   wire [3 : 0]                      M_AXI_ARCACHE ,
        output   wire [2 : 0]                      M_AXI_ARPROT  ,
        output   wire [3 : 0]                      M_AXI_ARQOS   ,
        output   wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER  ,
        output   wire                              M_AXI_ARVALID ,
        input    wire                              M_AXI_ARREADY ,

        input    wire [C_M_AXI_ID_WIDTH-1 : 0]     M_AXI_RID     ,
        input    wire [C_M_AXI_DATA_WIDTH-1 : 0]   M_AXI_RDATA   ,
        input    wire [1 : 0]                      M_AXI_RRESP   ,
        input    wire                              M_AXI_RLAST   ,
        input    wire [C_M_AXI_RUSER_WIDTH-1 : 0]  M_AXI_RUSER   ,
        input    wire                              M_AXI_RVALID  ,
        output   wire                              M_AXI_RREADY  ,

        //Custom

        input    wire                              I_Pre_clk     ,
        input    wire                              I_Pre_vs      ,
        input    wire  [Input_Data_width-1:0]      I_Pre_data    ,
        input    wire                              I_Pre_de      ,        

        input    wire                              I_Post_clk   ,
        output  wire                               O_Post_Start ,
        output    wire  [Input_Data_width-1:0]     O_Post_data  ,
        input    wire                              I_Post_de    ,
        input   wire                               I_Post_vs           
    );
                     
    function integer clogb2 (input integer bit_depth);              
      begin                                                           
        for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
          bit_depth = bit_depth >> 1;                                 
        end                                                           
    endfunction                                                     
    
//========================================= Define Ports =========================================//
    localparam integer C_TRANSACTIONS_NUM   = clogb2(C_M_AXI_BURST_LEN-1)                   ;

    localparam         Awaddr_Brust_Offset  = (C_M_AXI_DATA_WIDTH)*(C_M_AXI_BURST_LEN)/8    ;
    localparam         Araddr_Brust_Offset  = (C_M_AXI_DATA_WIDTH)*(C_M_AXI_BURST_LEN)/8    ;
    localparam         Total_Frame_Offset   = I_image_w*I_image_h*Pixel_byte_num            ;
    localparam         RAM_1_start_addr     = 0                                             ;
    localparam         RAM_2_start_addr     = Total_Frame_Offset                            ;
    localparam         RAM_3_start_addr     = Total_Frame_Offset*2                          ;

    localparam         wr_burst_times       = I_image_w*I_image_h*Pixel_byte_num /Awaddr_Brust_Offset        ;    
    localparam         rd_burst_times       = I_image_w*I_image_h*Pixel_byte_num /Araddr_Brust_Offset        ;

//========================================= Define Ports =========================================//
 
    // AXI4LITE signals
    //AXI4 internal temp signals
    reg  [C_M_AXI_ADDR_WIDTH-1 : 0]  axi_awaddr      ;
    reg                              axi_awvalid     ;
  
    reg                              axi_wlast       ;
    reg                              axi_wvalid      ;
    reg  [C_TRANSACTIONS_NUM-1:0]    wr_burst_cnt    ;

    reg                              axi_bready      ;
  
    reg  [C_M_AXI_ADDR_WIDTH-1 : 0]  axi_araddr      ;
    reg                              axi_arvalid     ;
    reg                              axi_rready      ;

      //W_FIFO
    wire                              wr_fifo_wr_en    ;
    wire [C_M_AXI_DATA_WIDTH-1 : 0]   wr_fifo_wr_data  ;
    wire                              wr_fifo_rd_en    ; 
    wire [C_M_AXI_DATA_WIDTH-1 : 0]   wr_fifo_rd_data  ;
    wire                              full_w           ;
    wire                              empty_w          ;
    wire [15 : 0]                     w_rd_data_count  ;
    wire [15 : 0]                     w_wr_data_count  ;
    
      //r_FIFO
    wire                              rd_fifo_wr_en    ;
    wire [C_M_AXI_DATA_WIDTH-1 : 0]   rd_fifo_wr_data  ;

    wire                              rd_fifo_rd_en    ; 
    wire [31 : 0]                     rd_fifo_rd_data  ;

    wire [12 : 0]                     r_rd_data_count  ;
    wire [11 : 0]                     r_wr_data_count  ;
    wire                              full_r           ;
    wire                              empty_r          ;

    reg  [15:0]                       rd_hcnt          ;
    reg  [15:0]                       rd_vcnt          ;

    //I/O Connections. Write Address (AW)
    assign M_AXI_AWID       = 'b0;
    assign M_AXI_AWADDR     = C_M_TARGET_SLAVE_BASE_ADDR + axi_awaddr;
    assign M_AXI_AWLEN      = C_M_AXI_BURST_LEN - 1;
    assign M_AXI_AWSIZE     = clogb2((C_M_AXI_DATA_WIDTH/8)-1);
    assign M_AXI_AWBURST    = 2'b01;
    assign M_AXI_AWLOCK     = 1'b0;
    assign M_AXI_AWCACHE    = 4'b0010;
    assign M_AXI_AWPROT     = 3'h0;
    assign M_AXI_AWQOS      = 4'h0;
    assign M_AXI_AWUSER     = 'b1;
    assign M_AXI_AWVALID    = axi_awvalid;
    //Write Data(W)
    assign wr_fifo_rd_en    = (axi_wvalid == 1'b1)&&(M_AXI_WREADY == 1'b1);
    assign M_AXI_WDATA      = wr_fifo_rd_data;
    //All bursts are complete and aligned in this example
    assign M_AXI_WSTRB      = {(C_M_AXI_DATA_WIDTH/8){1'b1}};
    assign M_AXI_WLAST      = axi_wlast;
    assign M_AXI_WUSER      = 'b0;
    assign M_AXI_WVALID     = axi_wvalid;
    //Write Response (B)
    assign M_AXI_BREADY     = axi_bready;
    //Read Address (AR)
    assign M_AXI_ARID       = 'b0;
    assign M_AXI_ARADDR     = C_M_TARGET_SLAVE_BASE_ADDR + axi_araddr;
    assign M_AXI_ARLEN      = C_M_AXI_BURST_LEN - 1;
    assign M_AXI_ARSIZE     = clogb2((C_M_AXI_DATA_WIDTH/8)-1);
    assign M_AXI_ARBURST    = 2'b01;
    assign M_AXI_ARLOCK     = 1'b0;
    assign M_AXI_ARCACHE    = 4'b0010;
    assign M_AXI_ARPROT     = 3'h0;
    assign M_AXI_ARQOS      = 4'h0;
    assign M_AXI_ARUSER     = 'b1;
    assign M_AXI_ARVALID    = axi_arvalid;
    //Read and Read Response (R)
    assign M_AXI_RREADY     = axi_rready;

// Wr_Sync------------------------------------------------------------------------------------------//

    //W Sync Port
    //wrclk
    reg                               r1_pre_vs        ;
    wire                              Pose_pre_vs      ;
    wire                              Nege_pre_vs      ;
    wire                              Ext_Pose_pre_vs  ;
    //sysclk
    reg                               sys_pre_vs       ;
    reg                               r1_sys_pre_vs    ;
    reg                               sys_Pose_pre_vs  ;
    reg                               sys_Nege_pre_vs  ;
    reg                               r_sys_Nege_pre_vs;
    reg  [1:0]                        wr_index         ;
    reg   [C_M_AXI_ADDR_WIDTH-1 : 0]  wr_base_addr     ;
    
    always @(posedge I_Pre_clk) begin
        r1_pre_vs <= I_Pre_vs;
    end

    assign  Pose_pre_vs = (I_Pre_vs == 1'b1)&&(r1_pre_vs == 1'b0);
    assign  Nege_pre_vs = (I_Pre_vs == 1'b0)&&(r1_pre_vs == 1'b1);

    always@(posedge M_AXI_ACLK) begin
        sys_pre_vs        <= I_Pre_vs  ;
        r1_sys_pre_vs     <= sys_pre_vs;
        r_sys_Nege_pre_vs <= sys_Nege_pre_vs;
    end

    always @(posedge M_AXI_ACLK) begin
        if(M_AXI_ARESETN == 1'b0) begin
            sys_Pose_pre_vs <= 1'b0;
            sys_Nege_pre_vs <= 1'b0;
        end else if(sys_pre_vs==1'b1&&r1_sys_pre_vs==1'b0) begin
            sys_Pose_pre_vs <= 1'b1;
            sys_Nege_pre_vs <= 1'b0; 
        end else if(sys_pre_vs==1'b0&&r1_sys_pre_vs==1'b1) begin
            sys_Pose_pre_vs <= 1'b0;
            sys_Nege_pre_vs <= 1'b1; 
        end else begin
            sys_Pose_pre_vs <= 1'b0;
            sys_Nege_pre_vs <= 1'b0;
        end
    end


    Data_sync_ext Data_sync_ext_Inst0(
        .clka           ( I_Pre_clk          ),
        .rst_n          ( M_AXI_ARESETN      ),    
        .pulse_a        ( Pose_pre_vs        ),
        .ext_pulse_a    ( Ext_Pose_pre_vs    )
    );

    always@(posedge M_AXI_ACLK)
        if(M_AXI_ARESETN == 1'b0) begin
            wr_index <= 'd1;
        end else if(sys_Nege_pre_vs == 1'b1&&wr_index == AXI_Buff_NUM) begin
            wr_index <= 'd1;
        end else if(sys_Nege_pre_vs==1'b1) begin
            wr_index <= wr_index + 1'b1;
        end else begin
            wr_index <= wr_index;
        end
            
    always@(posedge M_AXI_ACLK)
        if(M_AXI_ARESETN == 1'b0) begin
            wr_base_addr <= 0;
        end    else if(sys_Nege_pre_vs == 1'b1&&wr_index == AXI_Buff_NUM) begin
            wr_base_addr <= 0;
        end else if(sys_Nege_pre_vs == 1'b1) begin
            wr_base_addr <= wr_base_addr + Total_Frame_Offset;
        end else begin
            wr_base_addr <= wr_base_addr;
        end

// Wr_Sync------------------------------------------------------------------------------------------//

    assign  wr_fifo_wr_en = I_Pre_de;
    assign  wr_fifo_wr_data = {8'h0,I_Pre_data};

    wdata_w64x1024_r64x1024 wdata_w32x4096_r64x2048 (
    .rst        ( (!M_AXI_ARESETN)|(Ext_Pose_pre_vs)),  // input wire rst
    .wr_clk     ( I_Pre_clk                         ),  // input wire wr_clk
    .rd_clk     ( M_AXI_ACLK                        ),  // input wire rd_clk
    .din        ( wr_fifo_wr_data                   ),  // input wire [63 : 0] din
    .wr_en      ( wr_fifo_wr_en                     ),  // input wire wr_en
    .rd_en      ( wr_fifo_rd_en                     ),  // input wire rd_en
    .dout       ( wr_fifo_rd_data                   ),  // output wire [63 : 0] dout
    .full       ( full_w                            ),  // output wire full
    .empty      ( empty_w                           ),  // output wire empty
    .rd_data_count(w_rd_data_count ),            // output wire [10 : 0] rd_data_count
    .wr_data_count(w_wr_data_count ),            // output wire [10 : 0] wr_data_count
    .wr_rst_busy(),                // output wire wr_rst_busy
    .rd_rst_busy()                 // output wire rd_rst_busy
    );

// w_start_control----------------------------------------------------------------------------------//

    //Control
    reg                              wr_brust_start  ;
    wire                             wr_brust_Req     ;            
    wire                             wr_brust_end    ;
    reg                              wr_brust_now     ;

    assign    wr_brust_Req = (w_rd_data_count>=C_M_AXI_BURST_LEN);
    assign    wr_brust_end = (axi_wvalid==1'b1&&M_AXI_WREADY==1'b1&&wr_burst_cnt==C_M_AXI_BURST_LEN-1);


    //多路输入的时候，wr_brust_Req输出到仲裁器中，使用仲裁器输出的aribe_req请求完成此处wr_brust_Req的工作
    always@(*)
        if(wr_brust_Req == 1'b1) begin
            wr_brust_start <= 1'b1;
        end else begin
            wr_brust_start <= 1'b0; 
        end
    
    always@(posedge M_AXI_ACLK)
        if(M_AXI_ARESETN == 1'b0) begin
            wr_brust_now <= 1'b0;
        end else if(wr_brust_end == 1'b1 && wr_brust_now == 1'b1) begin
            wr_brust_now <= 1'b0; 
        end else if(wr_brust_start == 1'b1 && wr_brust_now == 1'b0) begin
            wr_brust_now <= 1'b1;
        end else begin
            wr_brust_now <= wr_brust_now; 
        end

// w_start_control----------------------------------------------------------------------------------//

// Aw------ --------------------------------------------------------------------------------------//

 //axi_awvalid
    always@(posedge M_AXI_ACLK)
        if(M_AXI_ARESETN == 1'b0) begin
            axi_awvalid <= 1'b0;
        end else if(axi_awvalid == 1'b1 && M_AXI_AWREADY == 1'b1) begin
            axi_awvalid <= 1'b0;
        end else if(wr_brust_start == 1'b1 && wr_brust_now == 1'b0) begin
            axi_awvalid <= 1'b1; 
        end else begin
            axi_awvalid <= axi_awvalid;
        end

 //axi_awaddr
    always@(posedge M_AXI_ACLK)
        if(M_AXI_ARESETN == 1'b0) begin
            axi_awaddr <= 'd0;
        end else if(r_sys_Nege_pre_vs == 1'b1) begin
            axi_awaddr <= wr_base_addr;
        // end else if(r_sys_Nege_pre_vs == 1'b1) begin
        //     axi_awaddr <= 0;
        end else if(axi_awvalid==1'b1 && M_AXI_AWREADY==1'b1) begin
            axi_awaddr <= axi_awaddr + Awaddr_Brust_Offset ;  
        end else begin
            axi_awaddr <= axi_awaddr;
        end

// Aw---------------------------------------------------------------------------------------------//

// W----------------------------------------------------------------------------------------------//
 //axi_wvalid
    always@(posedge M_AXI_ACLK)
        if(M_AXI_ARESETN == 1'b0) begin
            axi_wvalid <= 1'b0;
        end else if(axi_wvalid==1'b1&&M_AXI_WREADY==1'b1&&wr_burst_cnt==C_M_AXI_BURST_LEN-1) begin
            axi_wvalid <= 1'b0;
        end else if(axi_awvalid==1'b1&&M_AXI_AWREADY==1'b1) begin
            axi_wvalid <= 1'b1;
        end else begin
            axi_wvalid <= axi_wvalid;
        end 

 //wr_burst_cnt
    always@(posedge M_AXI_ACLK) begin
        if(M_AXI_ARESETN == 1'b0) begin
            wr_burst_cnt <= 'd0;
        end else if(axi_wvalid==1'b1&&M_AXI_WREADY==1'b1&&wr_burst_cnt==C_M_AXI_BURST_LEN-1) begin
            wr_burst_cnt <= 'd0;
        end else if(axi_wvalid==1'b1&&M_AXI_WREADY==1'b1) begin
            wr_burst_cnt <= wr_burst_cnt + 1'b1;
        end else begin
            wr_burst_cnt <= wr_burst_cnt;
        end
    end

 //axi_wlast
    always@(posedge M_AXI_ACLK) begin
        if(M_AXI_ARESETN == 1'b0) begin
            axi_wlast <= 1'b0;
        end else if(axi_wvalid==1'b1&&M_AXI_WREADY==1'b1&&wr_burst_cnt==C_M_AXI_BURST_LEN-1'b1) begin
            axi_wlast <= 1'b0;
        end else if(axi_wvalid==1'b1&&M_AXI_WREADY==1'b1&&wr_burst_cnt==C_M_AXI_BURST_LEN-2'd2) begin
            axi_wlast <= 1'b1;
        end else begin
            axi_wlast <= axi_wlast;
        end
    end

// W----------------------------------------------------------------------------------------------//

// b----------------------------------------------------------------------------------------------//

    always @(posedge M_AXI_ACLK) begin
        if(M_AXI_ARESETN == 0) begin
            axi_bready <= 'd0;
        end else begin
            axi_bready <= 1'b1;
        end
    end

// b----------------------------------------------------------------------------------------------//

// r_start_control----------------------------------------------------------------------------------//

    //Control
    reg [7:0]                        rd_index         ;
    reg [7:0]                        rd_index_ptr     ;
    reg [C_M_AXI_ADDR_WIDTH-1 : 0]   rd_base_addr     ;

    reg                              rd_start_cycle   ;
    reg [2:0]                        rd_start_cnt     ;
    reg                              rd_brust_start   ;
    reg                              rd_brust_Req     ;            
    reg                              rd_brust_end     ;
    reg                              rd_brust_now     ;
    reg                              Post_Start       ;

    always@(posedge M_AXI_ACLK) begin
        if(M_AXI_ARESETN == 0) begin
            rd_index <= 0;
        end else if(wr_index > 1) begin
            rd_index <= wr_index - 1'b1;
        end else begin
            rd_index <= AXI_Buff_NUM;
        end
    end

    always@(posedge M_AXI_ACLK) begin
        if(M_AXI_ARESETN == 0) begin
            rd_index_ptr <= 'd0;
        end else begin
            rd_index_ptr <= rd_index - 1'b1; 
        end
    end

    always@(posedge M_AXI_ACLK) begin
        if(M_AXI_ARESETN == 0) begin
            rd_base_addr <= 'd0;
        end else begin
            rd_base_addr <= rd_index_ptr*Total_Frame_Offset; 
        end
    end

    always@(posedge M_AXI_ACLK) begin
        if(M_AXI_ARESETN == 0) begin
            rd_start_cnt <= 'd0;
        end else if(sys_Nege_pre_vs && rd_start_cnt[2] != 1'b1) begin
            rd_start_cnt <= rd_start_cnt + 1'b1;
        end else begin
            rd_start_cnt <= rd_start_cnt;
        end
    end

    always@(posedge M_AXI_ACLK) begin
        if(M_AXI_ARESETN == 0) begin
            rd_start_cycle <= 1'b0;
        end else if(rd_start_cnt[2] == 1'b1 && full_r == 1'b0) begin
            rd_start_cycle <= 1'b1;
        end else begin
            rd_start_cycle <= rd_start_cycle;
        end
    end

    always@(posedge I_Post_clk)
        if(M_AXI_ARESETN == 0) begin
            Post_Start <= 1'b0;
        end else if(rd_start_cycle == 1'b1 && r_rd_data_count >= C_M_AXI_BURST_LEN) begin
            Post_Start <= 1'b1;
        end  else begin
            Post_Start <= Post_Start;
        end

    assign  O_Post_Start   =  Post_Start;

    always @(*) begin
        if((rd_start_cycle == 1'b1) && (r_wr_data_count < C_M_AXI_BURST_LEN*4)) begin
            rd_brust_Req <= 1'b1;
        end else begin
            rd_brust_Req <= 1'b0;
        end
    end

    always@(*) begin
        if((M_AXI_RVALID == 1'b1)&&(axi_rready == 1'b1)&&(M_AXI_RLAST == 1'b1)) begin
            rd_brust_end <= 1'b1;
        end else begin
            rd_brust_end <= 1'b0;
        end
    end

    //No aribe
    always@(*) begin
        if(rd_brust_Req == 1'b1) begin
            rd_brust_start <= 1'b1;
        end else begin
            rd_brust_start <= 1'b0;
        end
    end

    always@(posedge M_AXI_ACLK)
        if(M_AXI_ARESETN == 1'b0) begin
            rd_brust_now <= 1'b0;
        end else if(rd_brust_end == 1'b1 && rd_brust_now == 1'b1) begin
            rd_brust_now <= 1'b0; 
        end else if(rd_brust_start == 1'b1 && rd_brust_now == 1'b0) begin
            rd_brust_now <= 1'b1;
        end else begin
            rd_brust_now <= rd_brust_now; 
        end

// r_start_control----------------------------------------------------------------------------------//

// ar---------------------------------------------------------------------------------------------//

    always@(posedge M_AXI_ACLK) begin
        if(M_AXI_ARESETN == 1'b0) begin
            axi_arvalid <= 1'b0;
        end else if(axi_arvalid==1'b1&&M_AXI_ARREADY==1'b1) begin
            axi_arvalid <= 1'b0;
        end else if(rd_brust_start == 1'b1 && rd_brust_now == 1'b0) begin
            axi_arvalid <= 1'b1;
        end else begin
            axi_arvalid <= axi_arvalid;
        end
    end
    always@(posedge M_AXI_ACLK) begin
        if(M_AXI_ARESETN == 1'b0) begin
            axi_araddr <= 'd0;
        end else if((M_AXI_RVALID == 1'b1)&&(axi_rready == 1'b1)&&(rd_hcnt == C_M_AXI_BURST_LEN - 1)&&(rd_vcnt == rd_burst_times - 1'b1)) begin
            axi_araddr <= rd_base_addr;
        // end else if((M_AXI_RVALID == 1'b1)&&(axi_rready == 1'b1)&&(rd_hcnt == C_M_AXI_BURST_LEN - 1)&&(rd_vcnt == rd_burst_times - 1'b1)) begin
        //     axi_araddr <= 0;
        end else if(axi_arvalid==1'b1&&M_AXI_ARREADY==1'b1) begin
            axi_araddr <= axi_araddr + Araddr_Brust_Offset;    
        end else begin
            axi_araddr <= axi_araddr;
        end
    end
// ar---------------------------------------------------------------------------------------------//

// r----------------------------------------------------------------------------------------------//

    always@(posedge M_AXI_ACLK) begin
        if(M_AXI_ARESETN == 1'b0) begin
            axi_rready <= 1'b0;
        end else if((M_AXI_RVALID == 1'b1)&&(axi_rready == 1'b1)&&(M_AXI_RLAST == 1'b1)) begin
            axi_rready <= 1'b0;
        end else if(axi_arvalid==1'b1&&M_AXI_ARREADY==1'b1) begin
            axi_rready <= 1'b1;
        end else begin
            axi_rready <= axi_rready;
        end
    end
    
// r----------------------------------------------------------------------------------------------//


// r_Sync-----------------------------------------------------------------------------------------//


    assign  rd_fifo_wr_en = (M_AXI_RVALID == 1'b1)&&(axi_rready == 1'b1);
    assign  rd_fifo_wr_data = M_AXI_RDATA;

    assign  rd_fifo_rd_en = I_Post_de && Post_Start;
    assign  O_Post_data = rd_fifo_rd_data[23:0];

    rdata_w64x2048_r32x4096 rdata_w64x2048_r32x4096 (
    .rst    ( (!M_AXI_ARESETN)&&(!rd_start_cnt[2])),  // input wire rst
    .wr_clk ( M_AXI_ACLK            ),  // input wire wr_clk
    .rd_clk ( I_Post_clk            ),  // input wire rd_clk
    .din    ( rd_fifo_wr_data       ),  // input wire [63 : 0] din
    .wr_en  ( rd_fifo_wr_en         ),  // input wire wr_en
    .rd_en  ( rd_fifo_rd_en         ),  // input wire rd_en
    .dout   ( rd_fifo_rd_data       ),  // output wire [31 : 0] dout
    .full   ( full_r                ),  // output wire full
    .empty  ( empty_r               ),  // output wire empty
    .rd_data_count( r_rd_data_count ),  // output wire [12 : 0] rd_data_count
    .wr_data_count( r_wr_data_count ),  // output wire [11 : 0] wr_data_count
    .wr_rst_busy(),                     // output wire wr_rst_busy
    .rd_rst_busy()                      // output wire rd_rst_busy
    );

//hcnt
    always@(posedge M_AXI_ACLK)begin
        if(M_AXI_ARESETN == 1'b0) begin
            rd_hcnt <= 'd0;
        end else if((M_AXI_RVALID == 1'b1)&&(axi_rready == 1'b1)&&(rd_hcnt == C_M_AXI_BURST_LEN - 1)) begin
            rd_hcnt <= 'd0;
        end else if((M_AXI_RVALID == 1'b1)&&(axi_rready == 1'b1)) begin
            rd_hcnt <= rd_hcnt + 1'b1;
        end else begin
            rd_hcnt <= rd_hcnt;
        end
    end
//vcnt
    always@(posedge M_AXI_ACLK)begin
        if(M_AXI_ARESETN == 1'b0) begin
            rd_vcnt <= 'd0;
        end else if((M_AXI_RVALID == 1'b1)&&(axi_rready == 1'b1)&&(rd_hcnt == C_M_AXI_BURST_LEN - 1)&&(rd_vcnt == rd_burst_times - 1'b1)) begin
            rd_vcnt <= 'd0;
        end else if((M_AXI_RVALID == 1'b1)&&(axi_rready == 1'b1)&&(rd_hcnt == C_M_AXI_BURST_LEN - 1)) begin
            rd_vcnt <= rd_vcnt + 1'b1;
        end else begin
            rd_vcnt <= rd_vcnt;
        end
    end

// r_Sync-----------------------------------------------------------------------------------------//

// //Test
//     reg [15:0]  Test_wr_hcnt;
//     reg [15:0]  Test_wr_vcnt;
//     reg         r_I_Pre_de;

//     always @(posedge I_Pre_clk) begin
//         r_I_Pre_de <= I_Pre_de;
//     end
//     always @(posedge I_Pre_clk) begin
//         if(M_AXI_ARESETN == 1'b0) begin
//             Test_wr_hcnt <= 'd0;
//         end else if(I_Pre_de == 1'b1 && Test_wr_hcnt == 1920-1) begin
//             Test_wr_hcnt <= 'd0;
//         end else if(I_Pre_de == 1'b1) begin
//             Test_wr_hcnt <= Test_wr_hcnt + 1'b1;
//         end else begin
//             Test_wr_hcnt <= Test_wr_hcnt;
//         end
//     end

//     always @(posedge I_Pre_clk) begin
//         if(M_AXI_ARESETN == 1'b0) begin
//             Test_wr_vcnt <= 'd0;
//         end else if(Nege_pre_vs == 1'b1) begin
//             Test_wr_vcnt <= 'd0;
//         end else if(I_Pre_de == 1'b1 && Test_wr_hcnt == 1920-1) begin
//             Test_wr_vcnt <= Test_wr_vcnt + 1'b1;
//         end else begin
//             Test_wr_vcnt <= Test_wr_vcnt;
//         end
//     end


//     reg [15:0]  Test_rd_hcnt;
//     reg [15:0]  Test_rd_vcnt;
//     reg         r_I_Post_de ;

//     always @(posedge I_Post_clk) begin
//         r_I_Post_de <= I_Post_de;
//     end
//     always @(posedge I_Post_clk) begin
//         if(M_AXI_ARESETN == 1'b0) begin
//             Test_rd_hcnt <= 'd0;
//         end else if(I_Post_vs == 1'b1) begin
//             Test_rd_hcnt <= 'd0;
//         end else if(I_Post_de == 1'b1 && Test_rd_hcnt == 1920-1) begin
//             Test_rd_hcnt <= 'd0;
//         end else if(I_Post_de == 1'b1) begin
//             Test_rd_hcnt <= Test_rd_hcnt + 1'b1;
//         end else begin
//             Test_rd_hcnt <= Test_rd_hcnt;
//         end
//     end

//     always @(posedge I_Post_clk) begin
//         if(M_AXI_ARESETN == 1'b0) begin
//             Test_rd_vcnt <= 'd0;
//         end else if(I_Post_vs == 1'b1) begin
//             Test_rd_vcnt <= 'd0;
//         end else if(I_Post_de == 1'b1&&r_I_Post_de == 1'b0) begin
//             Test_rd_vcnt <= Test_rd_vcnt + 1'b1;
//         end else begin
//             Test_rd_vcnt <= Test_rd_vcnt;
//         end
//     end

//     AXI_ILA AXI_ILA (
//     .clk(M_AXI_ACLK), // input wire clk


//     .probe0(  I_Pre_de             ), //1
//     .probe1(  wr_index             ), //2
//     .probe2(  wr_base_addr         ), //32
//     .probe3(  w_rd_data_count      ), //12
//     .probe4(  full_w               ), //1
//     .probe5(  empty_w              ), //1
//     .probe6(  wr_brust_Req         ), //1
//     .probe7(  wr_brust_end         ), //1
//     .probe8(  wr_brust_now         ), //1
//     .probe9(  axi_awvalid          ), //1
//     .probe10( axi_awaddr           ), //32 
//     .probe11( axi_wvalid           ), //1 
//     .probe12( wr_burst_cnt         ), //8 
//     .probe13( axi_wlast            ), //1 
//     .probe14( I_Post_de            ), //1
//     .probe15( I_Post_vs            ), //1
//     .probe16( I_Pre_vs             ), //1
//     .probe17( O_Post_data          ), //24
//     .probe18( rd_index_ptr         ), //8
//     .probe19( rd_base_addr         ), //32
//     .probe20( rd_start_cnt         ), //2
//     .probe21( rd_brust_Req         ), //1
//     .probe22( r_wr_data_count      ), //12
//     .probe23( axi_arvalid          ), //1
//     .probe24( axi_araddr           ), //32
//     .probe25( axi_rready           ), //1
//     .probe26( rd_fifo_wr_en        ),//1 
//     .probe27( rd_hcnt              ), //16
//     .probe28( rd_vcnt              ), //16
//     .probe29( Test_wr_hcnt         ), //16 
//     .probe30( Test_wr_vcnt         ), //16 
//     .probe31( Test_rd_hcnt         ), //16 
//     .probe32( Test_rd_vcnt         ), //16 
//     .probe33( full_r               ), //16 
//     .probe34( empty_r              )  //16 
// );

    endmodule
