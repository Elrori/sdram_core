module gram
(
   input             clk_50M,
   input             rst_n,
	
   output            S_CLK,
   output   [12:0]   S_ADDR,
   output   [1:0]    S_BA,
   output            S_CAS_N,
   output            S_CKE,
   output            S_CS_N,
   inout    [15:0]   S_DQ,
   output   [1:0]    S_DQM,
   output            S_RAS_N,
   output            S_WE_N,

	output            rd_allow,
	output   [15:0]   rd_data,
	output            clk_200M,
	
   input             KEY_1,
   output   reg[7:0]    LED


);
wire rst_n_,clk_ref,clk_100M;
reg     [1:0 ]bank_addr;
reg     [12:0]row_addr;
reg     [8:0 ]col_addr;
reg     [15:0]wr_data;
//reg     wr_request;
wire    wr_allow;

//wire    [15:0]rd_data;
//reg     rd_request;
//wire    rd_allow;



pll pll_0
(
	.areset(~rst_n),
	.inclk0(clk_50M),
	.c0(clk_100M),
	.c1(S_CLK),
	.c2(clk_200M),
	.locked(rst_n_)
);
reg [31:0]cnt;
always@(posedge clk_100M or negedge rst_n_)begin
    if(!rst_n_)begin
        cnt <= 'd0;
		  row_addr <= 'd0;
    end else if(cnt == 32'd10_000_0)begin
	     cnt <= 'd0;
	 end else
        cnt <= cnt  + 1'd1;
end
reg f;
always@(posedge clk_100M or negedge rst_n_)begin
    if(!rst_n_)begin
        f <= 'd0;
    end else if(cnt == 32'd6_000_0)begin
	     f <= 'd1;
	 end else
        f <= f;
end
wire wr_request = ((cnt == 32'd5_000_0) && (f == 0));//write once
wire rd_request = cnt == 32'd10_000_0;
always@(posedge clk_100M or negedge rst_n_)begin
    if(!rst_n_)
        wr_data<=16'haaaa;
    else if(wr_allow)
        wr_data <= ~wr_data;
end
//check
always@(posedge clk_100M or negedge rst_n_)begin
    if(!rst_n_)
        LED[0] <= 0;
    else if(rd_allow)
        LED[0] <= (rd_data==16'haaaa ||rd_data==16'h5555)?LED[0]:1;
end
reg bk;
always@(posedge clk_100M or negedge rst_n_)
    if(!rst_n_)
	     bk <= 1;
    else if(KEY_1 == 0)
	     bk <= ~bk;
sdram_core  sdram_core_0
(
    .clk(clk_100M),
    .clk_ref(),
    .rst_n(rst_n_),
    
    .wr_addr({2'd1,row_addr,9'd0}),//{bank_addr,row_addr,col_addr}
    .wr_num(10'd512),
    .wr_data(wr_data),           //only 16bits
    .wr_request(wr_request),              //user发出写请求，此时wr_addr将被写入。进入写状态
    .wr_allow(wr_allow),                //enbale:@posedge clk,data<=wr_data
 
    .rd_addr({{1'd0,bk},row_addr,9'd0}),//{bank_addr,row_addr,col_addr}
    .rd_num(10'd512),
    .rd_data(rd_data),           //only 16bits
    .rd_request(rd_request),              //user发出写请求，此时rd_addr将被写入。进入读状态
    .rd_allow(rd_allow),                //enbale:@posedge clk,rd_data<=data
    
    .busy(),
	 .state_fly_error(),
 
    .sdram_addr(S_ADDR)     ,//(init,read,write)
    .sdram_bkaddr(S_BA)   ,//(init,read,write)
    .sdram_data(S_DQ)     ,//only 16bits (read,write)
    .sdram_clk()      ,
    
    .sdram_cke(S_CKE)      ,//always 1
    .sdram_cs_n(S_CS_N)     ,//always 0
    .sdram_ras_n(S_RAS_N)    ,
    .sdram_cas_n(S_CAS_N)    ,
    .sdram_we_n(S_WE_N)     ,
    
    .sdram_dqml(S_DQM[0])     ,//not use,always 0
    .sdram_dqmh(S_DQM[1])      //not use,always 0
);

endmodule
