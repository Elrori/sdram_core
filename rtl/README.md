```
  Name         :sdram_core.v
  Description  :a simple SDRAM controller in full page burst mode,该模块意指在使用最简单的
                状态转换机的前提下完成CMOS->VGA的图像缓存任务，SDRAM设置为简单的全页读写模
                式，由于中间不能被refresh打断，为保证最短刷新时间，读写前后都有 失选和刷新。
                读写个数越大效率越高，但不能超过列数; 模块流程 : 固定的初始化后，用户设置起
                始bank、行、列地址，发送请求进行固定长度连续单页读写(请求必然导致读写操作！
                即发一次读写请求后用户必须依照xx_allow信号去读写一次)，到达规定个数(wr_num)，
                该模块将xx_busy置低，读写请求可以同时发生。
                注意：sdram_core.v读写完全独立user依据wr_xxx端口信号进行控制无需知道rd_xxx
                      的信号，同样，依据rd_xxx端口信号进行控制无需知道wr_xxx的信号。
                注意：xx_request有效时间应当小于8个clk
                注意：读一次后必须等rd_busy置低再进行下一次读操作，写也是一样。
                注意：该模块仅读取单页(一行，读写字数可控,需要读取另一行，必更换地址)。该模
                      块将SDRAM当成显存来用。不支持随机读写(wr_num==1时可以实现随机读写，但
                      是效率较低)。该模块不含FIFO。
                CAS==3;clk leads the 80 degree of sdram_clk(Different results
                for different boards).Recommended sdram_clk phase shift -80 degrees.
                Note:xx_request effective time should less than 8 clk,and do not Repeat 
                xx_request until xx_busy deasserted(wr_xxx rd_xxx independent).
                wr_data no pre-fetch need!
  Origin       :190119
                190122
                190124 - add init_done
  Author       :helrori2011@gmail.com
  Reference    :

```