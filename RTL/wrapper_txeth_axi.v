module wrapper_txeth_axi(input wire clk,
input wire rst,
//////////////////axiii
input wire [3:0]wr_strb,
input wire [2:0]wr_prot, 
input wire [2:0]rd_prot,
//write oriented axii 4 lite interface
input wire [31:0]wr_addr,
input wire [31:0]wr_data,
input wire w_addr_val,
input wire w_dta_val,
//read oriented axii 4 lite interface
input wire radrval,
input wire [31:0]raddr,
input wire rd_dta_rsp_rdy,//by master
input wire wr_resp_rdy_mas,//master can accept write response
////// op of tx_eth
output wire [7:0]tx_data,
output wire tlst,
output wire tvalid,
output wire [31:0]dest_ip,
output wire [15:0]src_port,
output wire [15:0]dest_port,
output wire s_axis_tuser,
output wire s_udp_hdr_valid,
// rest op communicating with axi master
output wire wr_adrrdy,
output wire wr_dtardy,
output wire r_addr_rdy,
output wire [31:0]r_dta,
output wire r_dta_val,
output wire [1:0]wr_resp,
output wire wr_resp_val,
output wire [1:0]rd_resp,
//ip to tx_eth
input wire s_axis_tready,
input wire [1:0]rd_addr_size,
input wire [1:0]wr_addr_size
);
//axi op to ip of tx_eth
 wire [31:0] in_reg1;//dest ip
 wire [31:0]in_reg2;//src & dest port
 wire [31:0]in_reg3;// payload data
 wire [31:0]in_reg4;// payload length

//stst_acknowledge
 wire slv_reg1_loaded;
 wire slv_reg2_loaded;
 wire slv_reg3_loaded;
 wire slv_reg4_loaded;
 wire dip_got;
 wire src_dest_prt_got;
 wire payload_got;
 wire payload_length_got;
///// axi inst
axi_4_lite_eth d1( clk,
 rst,
///////////////////////////////axiii
wr_strb,
wr_prot, 
rd_prot,
//write oriented axii 4 lite interface
wr_addr,
wr_data,
 w_addr_val,
 w_dta_val,
 wr_adrrdy,
 wr_dtardy,
///////////////////
//read oriented axii 4 lite interface
radrval,
raddr,
 r_addr_rdy,
r_dta,
 r_dta_val,
rd_dta_rsp_rdy,//by master

/////////////////////
//response signals
wr_resp,
 wr_resp_val,
rd_resp,
 wr_resp_rdy_mas,//master can accept write response
////////////////////axiiiend
 in_reg1,//dest ip
in_reg2,//src & dest port
in_reg3,// payload data
in_reg4,// payload length
slv_reg1_loaded,
  slv_reg2_loaded,
  slv_reg3_loaded,
  slv_reg4_loaded,
  dip_got,
  src_dest_prt_got,
  payload_got,
  payload_length_got
);
//////////////////////////// tx_eth inst
tx_ethernet d2( clk,
 rst,
 s_axis_tready,
 in_reg1 ,
in_reg2 ,//src_port___dest_prt
in_reg3 ,
in_reg4,
tx_data,
tlst,
 tvalid,
dest_ip,
src_port,
dest_port,
 s_axis_tuser,
 s_udp_hdr_valid,
slv_reg1_loaded,
  slv_reg2_loaded,
  slv_reg3_loaded,
  slv_reg4_loaded,
  dip_got,
  src_dest_prt_got,
  payload_got,
  payload_length_got
);
endmodule
