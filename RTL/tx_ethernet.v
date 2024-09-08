module tx_ethernet(input wire clk,
input wire rst,
input wire s_axis_tready,
input wire [31:0] d_ip ,
input wire [31:0]ports ,//src_port___dest_prt
input wire [31:0]t_data ,
input wire [31:0]payload_length,
output reg [7:0]tx_data,
output reg tlst,
output reg tvalid,
output reg [31:0]dest_ip,
output reg [15:0]src_port,
output reg [15:0]dest_port,
output wire s_axis_tuser,
output reg s_udp_hdr_valid,
///////////////////////////// chk features
input wire slv_reg1_loaded,
input wire slv_reg2_loaded,
input wire slv_reg3_loaded,
input wire slv_reg4_loaded,
output wire dip_got,
output wire src_dest_prt_got,
output wire payload_got,
output wire payload_length_got
);
/////////////////////////////////////////
reg dip_got_reg = 1'b0;
reg src_dest_prt_got_reg = 1'b0;
reg payload_got_reg = 1'b0;
reg payload_length_got_reg = 1'b0;
reg pay_rdy;
reg [10:0]cnt_pl;
reg [7:0]data_array[1499:0];
assign dip_got = dip_got_reg;
assign src_dest_prt_got = src_dest_prt_got_reg;
assign payload_got = payload_got_reg;
assign payload_length_got = payload_length_got_reg;
always @(posedge clk)begin
if(rst) begin
cnt_pl <= 11'b0;
pay_rdy <= 1'b0;
end
else begin
	if((cnt_pl < payload_length) && slv_reg3_loaded && !payload_got) begin
	{data_array[cnt_pl],data_array[cnt_pl+1'b1],data_array[cnt_pl+2'b10],data_array[cnt_pl+2'b11]} <= t_data;
	cnt_pl <= cnt_pl +3'b100;
	payload_got_reg <= 1'b1;
	end
	else if((cnt_pl < payload_length ) && (payload_got)) begin
	payload_got_reg <= 1'b0;
	end
	else if((cnt_pl == payload_length) && (payload_length!=32'b0)) begin
	pay_rdy <= 1'b1;
	cnt_pl <= cnt_pl;
	payload_got_reg <= 1'b0;
	end
end
end



//////////////////////////////////////////
integer i;
reg [10:0]cnt=11'b00000000000;
reg [2:0]cnt1=3'b000;
assign s_axis_tuser=1'b0;
always @(posedge clk)begin
if(rst)begin
dest_ip<=32'b0;
src_port<=16'b0;
dest_port<=16'b0;
cnt1 <= 3'b0;
end
else begin
	if((cnt1<3'b0011) && slv_reg1_loaded && slv_reg2_loaded && slv_reg4_loaded )begin
	dest_ip <= d_ip;
	src_port <= ports[31:16];
	dest_port <= ports[15:0];
	s_udp_hdr_valid <= 1'b1;
	cnt1<=cnt1+1'b1;
	dip_got_reg <= 1'b1;
	src_dest_prt_got_reg <= 1'b1;
	payload_length_got_reg <= 1'b1;
	end
	else begin
	dip_got_reg <= 1'b0;
	src_dest_prt_got_reg <= 1'b0;
	payload_length_got_reg <= 1'b0;
	cnt1<=cnt1;
        s_udp_hdr_valid <=1'b0;
	end
end
end
always @(posedge clk)begin
if(rst)begin
tx_data<=8'b0;
cnt <= 11'b0;
end
else if((!rst)&&(s_axis_tready)&&(pay_rdy)) begin
if(cnt<payload_length)begin
tvalid<=1'b1;
tx_data<=data_array[cnt];
	if(cnt==(payload_length - 1'b1))begin
	tlst<=1'b1;
	end
cnt<=cnt+1'b1;

end
else begin
tlst<=1'b0;
tvalid<=1'b0;
cnt<=cnt;
end
end
end

endmodule
