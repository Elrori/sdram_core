
top   
--------------  

sdram_core.v

-------------- 
Description  

a simple SDRAM controller in full page burst mode,该模块意指在使用最简单的状态转换机的前提下完成CMOS->VGA的图像缓存任务，SDRAM设置为简单的全页读写模

式，由于中间不能被refresh打断，为保证最短刷新时间，读写前后都有 失选和刷新。读写个数越大效率越高，但不能超过列数; 模块流程 : 固定的初始化后，用户设置起
                
始bank、行、列地址，发送请求进行固定长度连续单页读写(请求必然导致读写操作！即发一次读写请求后用户必须依照xx_allow信号去读写一次)，到达规定个数(wr_num)，
                
该模块将xx_busy置低，读写请求可以同时发生。注意：sdram_core.v读写完全独立user依据wr_xxx端口信号进行控制无需知道rd_xxx的信号，同样，依据rd_xxx端口信号
                
进行控制无需知道wr_xxx的信号。

注意：xx_request有效时间应当小于8个clk
                
注意：读一次后必须等rd_busy置低再进行下一次读操作，写也是一样。注意：该模块仅读取单页(一行，读写字数可控,需要读取另一行，必更换地址)。该模
                
块将SDRAM当成显存来用。不支持随机读写(wr_num==1时可以实现随机读写，但是效率较低)。该模块不含FIFO。
                      
CAS==3;clk leads the 80 degree of sdram_clk(Different results for different boards).Recommended sdram_clk phase shift -80 degrees.
                
Note:xx_request effective time should less than 8 clk,and do not Repeat xx_request until xx_busy deasserted(wr_xxx rd_xxx independent).
                
wr_data no pre-fetch need!

HOST interface
--------------

```
    //HOST
    input   wire    [HADDR_WIDTH-1:0]wr_addr,       //{bank_addr,row_addr,col_addr}
    input   wire    [COL_WIDTH    :0]wr_num,//1024  //写入这行的字数(pls <= 2^COL_WIDTH,一般小于等于512)
    input   wire    wr_request,                     //_|~|____________________________________________//Effective time should less than 8,and do not Repeat request until wr_busy==0.
    input   wire    [15:0]wr_data,                  //XXXXXXXX| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |XXXX
    output  reg     wr_allow,                       //____|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|____________
    output  wire    wr_busy,                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|___
    
    input   wire    [HADDR_WIDTH-1:0]rd_addr,       //{bank_addr,row_addr,col_addr}
    input   wire    [COL_WIDTH    :0]rd_num,//1024  //读取这行的字数(pls <= 2^COL_WIDTH,一般小于等于512)
    input   wire    rd_request,                     //_|~|____________________________________________//Effective time should less than 8,and do not Repeat request until rd_busy==0.
    output  reg     [15:0]rd_data,                  //XXXX| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |XXXX
    output  reg     rd_allow,                       //____|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|____________
    output  wire    rd_busy,                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|___
    output  wire    init_done,
```

Origin   
--------------   
  
190119

190122

190124 - add init_done

Author 
-------------- 
     
helrori2011@gmail.com

License    
--------------

MIT
  
