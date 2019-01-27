# sdram_core
```
  Name         :sdram_core.v
  Description  :a simple SDRAM controller in page burst mode;固定的初始化后，用户设置起始
                bank、行、列地址，进行固定长度连续单页读写，到达规定个数(wr_num)，该模块将
                给出信号。注意：该模块仅读取单页(一行，读写字数可控,需要读取另一行，必更
                换地址)。该模块将SDRAM当成显存来用(为了配合VGA)。不支持随机读写。该模块不
                含FIFO。CAS==3;clk leads the 80 degree of sdram_clk(Different results
                for different boards).Recommended sdram_clk phase shift -80 degrees.
                Note:xx_request effective time should less than 8 clk,and do not Repeat 
                xx_request until xx_allow finished.wr_data no pre-fetch need!
  Origin       :190119
                190122
  Author       :helrori2011@gmail.com
  Reference    :github.com/stffrdhrn/sdram-controller
```
read 4 words
![read 4 words](https://github.com/Elrori/sdram_core/blob/master/rd.png)
write 4 words
![write 4 words](https://github.com/Elrori/sdram_core/blob/master/wr.png)
rd_wr_in_same_tim
![rd_wr_in_same_time](https://github.com/Elrori/sdram_core/blob/master/rd_wr_in_same_time.png)
read to write
![read to write](https://github.com/Elrori/sdram_core/blob/master/rd2wr.png)
