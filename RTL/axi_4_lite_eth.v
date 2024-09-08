module axi_4_lite_eth(input wire clk,
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
output wire wr_adrrdy,
output wire wr_dtardy,
///////////////////
//read oriented axii 4 lite interface
input wire radrval,
input wire [31:0]raddr,
output wire r_addr_rdy,
output wire [31:0]r_dta,
output wire r_dta_val,
input wire rd_dta_rsp_rdy,//by master

/////////////////////
//response signals
output wire [1:0]wr_resp,
output wire wr_resp_val,
output wire [1:0]rd_resp,
input wire wr_resp_rdy_mas,//master can accept write response
////////////////////axiiiend
output wire [31:0] in_reg1,//dest ip
output wire [31:0]in_reg2,//src & dest port
output wire [31:0]in_reg3,// payload data
output wire [31:0]in_reg4,// payload length
/////// stat indication
output wire slv_reg1_loaded,
output wire slv_reg2_loaded,
output wire slv_reg3_loaded,
output wire slv_reg4_loaded,
input wire dip_got,
input wire src_dest_prt_got,
input wire payload_got,
input wire payload_length_got
);
/////////////////////////////////////////////////////for axii
reg [31:0] slv_reg1;//dest ip
reg [31:0] slv_reg2;// src & dest port
reg [31:0] slv_reg3;// payload data
reg [31:0] slv_reg4;//payload length


wire [31:0] rd_reg1;//dest ip
wire [31:0] rd_reg2;// src & dest port
wire [31:0] rd_reg3;// payload data
wire [31:0] rd_reg4;//payload length

reg [31:0]reg_data_out;//rd_data
reg aw_en;//address write enable
wire slv_reg_rden;
wire slv_reg_wren;
reg slv_reg1_loaded_reg;
reg slv_reg2_loaded_reg;
reg slv_reg3_loaded_reg;
reg slv_reg4_loaded_reg;
///////////////////////////////////
//udp_hdr part and dest ip
/*
reg1-destip 20'h40000
reg2-srcprt & reg3-dprt 20'h40008
reg3-udp_payload 20'h40016
reg4-udp payload length 20'h40024 
*/
reg [31:0]wr_addr_reg;
reg wr_adddr_rdy_reg;
reg wr_dta_rdy_reg;
reg [1:0]wr_resp_reg;
reg wr_resp_val_reg;
reg [31:0]raddr_reg;
reg r_addr_rdy_reg;
reg [31:0]r_dta_reg;
reg [1:0]rd_resp_reg;
reg r_dta_val_reg;
///////////////////////////////////
// ila_0 chk_reg(
// clk,
// slv_reg1,
// slv_reg2,
// slv_reg3,
// slv_reg4
// );
///////////////////////////////////
assign wr_adrrdy = wr_adddr_rdy_reg;
assign wr_dtardy = wr_dta_rdy_reg;
assign wr_resp = wr_resp_reg;
assign wr_resp_val = wr_resp_val_reg;
assign r_addr_rdy = r_addr_rdy_reg;
assign r_dta = r_dta_reg;
assign rd_resp = rd_resp_reg;
assign r_dta_val = r_dta_val_reg;
// stat
assign slv_reg1_loaded = slv_reg1_loaded_reg;
assign slv_reg2_loaded = slv_reg2_loaded_reg;
assign slv_reg3_loaded = slv_reg3_loaded_reg;
assign slv_reg4_loaded = slv_reg4_loaded_reg;

//axii write address ready generation
always @(posedge clk)begin
if(rst)begin
wr_adddr_rdy_reg <= 1'b0;
aw_en <= 1'b1;
end
else if((wr_adddr_rdy_reg==1'b0) && (w_addr_val==1'b1) && (w_dta_val==1'b1) && (aw_en==1'b1)) begin
wr_adddr_rdy_reg <= 1'b1;
end
else if((wr_resp_rdy_mas==1'b1) && (wr_resp_val_reg==1'b1)) begin
wr_adddr_rdy_reg <= 1'b0;
aw_en <= 1'b1;
end
else begin
wr_adddr_rdy_reg <= 1'b0;
end
end
//////////// write address latching
always@(posedge clk)begin
if(rst) begin
wr_addr_reg <= 32'b0;
end
else if((wr_adddr_rdy_reg==1'b0) && (w_addr_val==1'b1) && (w_dta_val==1'b1) && (aw_en==1'b1)) begin
wr_addr_reg <= wr_addr;
end
end
///////// write data ready generation
always@(posedge clk) begin
if(rst) begin
wr_dta_rdy_reg <= 1'b0;
end
else if((wr_dta_rdy_reg==1'b0) && (w_addr_val==1'b1) && (w_dta_val==1'b1) && (aw_en==1'b1)) begin
wr_dta_rdy_reg <= 1'b1;
end
else begin
wr_dta_rdy_reg <= 1'b0;
end
end
///////
/*always @(posedge clk) begin
if(dip_got && src_dest_prt_got && payload_length_got ) begin
slv_reg1_loaded_reg <= 1'b0;
slv_reg4_loaded_reg <= 1'b0;
slv_reg2_loaded_reg <= 1'b0;
end

else if(payload_got) begin
slv_reg3_loaded_reg <= 1'b0;
end

end*/
////////
/// memory mapped register select and write logic
assign slv_reg_wren = (wr_dta_rdy_reg) & (wr_adddr_rdy_reg) & (w_addr_val) & (w_dta_val);
always @(posedge clk)begin
if(rst) begin
slv_reg1<=32'b0;
slv_reg2<=32'b0;
slv_reg3<=32'b0;
slv_reg4<=32'b0;
end
else if(slv_reg_wren==1'b1) begin
	case(wr_addr)
	32'h00044000: begin
		if((wr_strb == 4'b1111) && !dip_got )begin
			slv_reg1 <= wr_data;
			slv_reg1_loaded_reg <= 1'b1;
		end
		
	end
	32'h00044008:begin
		if((wr_strb == 4'b1111) && !src_dest_prt_got)begin
			slv_reg2 <= wr_data;
			slv_reg2_loaded_reg <= 1'b1;
		end
		
	end
	32'h00044016:begin
		if((wr_strb == 4'b1111) && !payload_got)begin
			slv_reg3 <= wr_data;
			slv_reg3_loaded_reg <= 1'b1;
		end

	end
	32'h00044024:begin
		if((wr_strb == 4'b1111) && !payload_length_got)begin
			slv_reg4 <= wr_data;
			slv_reg4_loaded_reg <= 1'b1;
		end
	end
	default: begin
		slv_reg1 <= 32'b0;
		slv_reg2 <= 32'b0;
		slv_reg3 <= 32'b0;
		slv_reg4 <= 32'b0;
	end
	endcase
end
else if(dip_got && src_dest_prt_got && payload_length_got ) begin
slv_reg1_loaded_reg <= 1'b0;
slv_reg4_loaded_reg <= 1'b0;
slv_reg2_loaded_reg <= 1'b0;
end

else if(payload_got) begin
slv_reg3_loaded_reg <= 1'b0;
end


end

//////////// write response logic generation

always @(posedge clk) begin
if(rst) begin
wr_resp_reg <= 2'b00;
wr_resp_val_reg <= 1'b0;
end
else if((wr_dta_rdy_reg == 1'b1) && (wr_adddr_rdy_reg == 1'b1) && (w_addr_val == 1'b1) && (w_dta_val == 1'b1) && (wr_resp_val_reg == 1'b0)) begin
wr_resp_reg <= 2'b00;
wr_resp_val_reg <= 1'b1;
end
else if((wr_resp_rdy_mas == 1'b1) && (wr_resp_val_reg == 1'b1))begin
wr_resp_val_reg <= 1'b0;
end
end

/////////////// read address ready generation
 
always @(posedge clk) begin
if(rst) begin
r_addr_rdy_reg <= 1'b0;
raddr_reg <= 32'hffffffff;
end
else if((r_addr_rdy_reg == 1'b0) && (radrval == 1'b1))begin
r_addr_rdy_reg <= 1'b1;
raddr_reg <= raddr;
end
else begin
r_addr_rdy_reg <= 1'b0;
end
end


//////////// read addr valid generation
always @(posedge clk) begin
if(rst) begin
r_dta_val_reg <= 1'b0;
rd_resp_reg <= 2'b00;
end
else if((r_addr_rdy_reg == 1'b1) && (radrval == 1'b1) && (r_dta_val_reg == 1'b0)) begin
r_dta_val_reg <= 1'b1;
rd_resp_reg <= 2'b00;
end
else if ((r_dta_val_reg == 1'b1) && (rd_dta_rsp_rdy == 1'b1)) begin
r_dta_val_reg <= 1'b0;
end
end
////////// reaad_reg assignments
assign rd_reg1 = slv_reg1;
assign rd_reg2 = slv_reg2;
assign rd_reg3 = slv_reg3;
assign rd_reg4 = slv_reg4;

///// memory mapped select register and read logic generation
assign slv_reg_rden = (r_addr_rdy_reg) & (radrval) & (!r_dta_val_reg);
always @(slv_reg_rden, raddr, rst)begin
case(raddr)
32'h44032: begin
reg_data_out = rd_reg1;
end
32'h44040: begin
reg_data_out = rd_reg2;
end
32'h44048: begin
reg_data_out = rd_reg3;
end
32'h44056: begin
reg_data_out = rd_reg4;
end
default: begin
reg_data_out = reg_data_out;
end
endcase
end

// Output register or memory read data
always @(posedge clk) begin
if(rst) begin
r_dta_reg <= 32'b0;
end
else if(slv_reg_rden == 1'b1) begin
r_dta_reg <= reg_data_out;
end
end
assign in_reg1 = slv_reg1;
assign in_reg2 = slv_reg2;
assign in_reg3 = slv_reg3;
assign in_reg4 = slv_reg4;
endmodule

