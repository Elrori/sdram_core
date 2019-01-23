`timescale 1 ns / 100 ps
`define TT  10
`define DEG 80.0//clk 超前clk_ref的度数 clk leads the degree of clk_ref
//DEG 
module sdram_core_tb();
reg     clk,clk_ref,rst_n;


reg     [1:0 ]bank_addr;
reg     [12:0]row_addr;
reg     [8:0 ]col_addr;
reg     [15:0]wr_data;
reg     wr_request;
wire    wr_allow;

wire    [15:0]rd_data;
reg     rd_request;
wire    rd_allow;

wire    sdram_clk,
        sdram_cke,
        sdram_cs_n,
        sdram_ras_n,
        sdram_cas_n,
        sdram_we_n,
        sdram_dqmh,
        sdram_dqml;
wire    [12:0]sdram_addr;
wire    [1:0 ]sdram_bkaddr;
wire    [15:0]sdram_data;



//wire       #(`TT*(`DEG/360)) clk;
//assign     clk_ref = clk;
initial begin 
    clk_ref = 1;
    #(`TT*(`DEG/360.0))
    forever #(`TT/2)  clk_ref = ~clk_ref ;
end 
initial begin
    $dumpfile("wave.vcd");              //for iverilog gtkwave.exe
    $dumpvars(0,sdram_core_tb);           //for iverilog select signal   
    clk = 1;
    rst_n = 1;
    wr_request = 0;
    rd_request = 0;
    bank_addr  = 0;
    row_addr   = 0;
    col_addr   = 0;
    
    #(`TT*10)
    rst_n = 0;#(`TT*10) rst_n = 1;
    
    //write 
    #(`TT*1250)
    wr_request = 1;#(`TT*1) wr_request = 0;
    #(`TT*1250)
    
    //write read in same time for 3 times
    row_addr = 1;
    bank_addr= 1;
    #(`TT*1250)
    wr_request = 1;rd_request = 1;#(`TT*1) wr_request = 0;rd_request = 0;
    #(`TT*100)
    wr_request = 1;rd_request = 1;#(`TT*1) wr_request = 0;rd_request = 0;
    #(`TT*100)
    wr_request = 1;rd_request = 1;#(`TT*1) wr_request = 0;rd_request = 0;
    #(`TT*1250)   
    
    
    //read
    row_addr = 0;
    bank_addr= 0;
    #(`TT*1250)
    rd_request = 1;#(`TT*1) rd_request = 0;
    #(`TT*1250)
    
    //read
    row_addr = 1;
    bank_addr= 1;
    #(`TT*1250)
    rd_request = 1;#(`TT*1) rd_request = 0;
    #(`TT*1250)   
    
    //write when read request 
    #(`TT*1250)
    wr_request = 1;#(`TT*1) wr_request = 0;
    #(`TT*0)
    rd_request = 1;#(`TT*1) rd_request = 0;
    #(`TT*1250)
    //read when write request 
    #(`TT*1250)
    rd_request = 1;#(`TT*1) rd_request = 0;
    #(`TT*0)
    wr_request = 1;#(`TT*1) wr_request = 0;
    #(`TT*1250)
    //write and read in same time ,and next read in illegal area
    wr_request = 1;rd_request = 1;#(`TT*1) wr_request = 0;rd_request = 0;
    #(`TT*34)
    rd_request = 1;#(`TT*1) rd_request = 0;
    #(`TT*34)
    rd_request = 1;#(`TT*1) rd_request = 0;
    #(`TT*1250)
    //read when write request,and read in illegal area
    wr_request = 1;#(`TT*1) wr_request = 0;
    #(`TT*32)
    wr_request = 1;#(`TT*1) wr_request = 0;  
    #(`TT*2)
    rd_request = 1;#(`TT*1) rd_request = 0;
    #(`TT*1250)
    
    $finish;
    

    
end

always begin #(`TT/2)clk = ~clk; end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        wr_data<=16'haaaa;
    else if(wr_allow)
        wr_data <= ~wr_data;
end
sdram_core  sdram_core_0
(
    .clk(clk),
    .clk_ref(clk_ref),
    .rst_n(rst_n),
    
    .wr_addr({bank_addr,row_addr,col_addr}),//{bank_addr,row_addr,col_addr}
    .wr_num(10'd4),
    .wr_data(wr_data),           //only 16bits
    .wr_request(wr_request),              //user发出写请求，此时wr_addr将被写入。进入写状态
    .wr_allow(wr_allow),                //enbale:@posedge clk,data<=wr_data
 
    .rd_addr({bank_addr,row_addr,col_addr}),//{bank_addr,row_addr,col_addr}
    .rd_num(10'd4),
    .rd_data(rd_data),           //only 16bits
    .rd_request(rd_request),              //user发出写请求，此时rd_addr将被写入。进入读状态
    .rd_allow(rd_allow),                //enbale:@posedge clk,rd_data<=data
    
    .busy(),
 
    .sdram_addr(sdram_addr)     ,//(init,read,write)
    .sdram_bkaddr(sdram_bkaddr)   ,//(init,read,write)
    .sdram_data(sdram_data)     ,//only 16bits (read,write)
    .sdram_clk(sdram_clk)      ,
    
    .sdram_cke(sdram_cke)      ,//always 1
    .sdram_cs_n(sdram_cs_n)     ,//always 0
    .sdram_ras_n(sdram_ras_n)    ,
    .sdram_cas_n(sdram_cas_n)    ,
    .sdram_we_n(sdram_we_n)     ,
    
    .sdram_dqml(sdram_dqml)     ,//not use,always 0
    .sdram_dqmh(sdram_dqmh)      //not use,always 0
);
mt48lc16m16a2 mt48lc16m16a2_0
(
    .Dq(sdram_data),
    .Addr(sdram_addr),
    .Ba(sdram_bkaddr),
    .Clk(sdram_clk),
    .Cke(sdram_cke),
    .Cs_n(sdram_cs_n),
    .Ras_n(sdram_ras_n),
    .Cas_n(sdram_cas_n),
    .We_n(sdram_we_n),
    .Dqm({sdram_dqmh,sdram_dqml})
);
endmodule