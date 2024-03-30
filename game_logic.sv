module game_logic (
	input logic vga_clk,
	input logic update_clk,
	input logic reset,
	input logic [1:0] direction,
	input logic [9:0] x_in,
	input logic [8:0] y_in,
	input logic [11:0] count,
	output logic [1:0] pic_type,
	output logic game_over,
	output logic game_win,
	output logic [7:0] gift_count,
	input logic sw_i
);
	logic [5:0] curr_x;
	logic [5:0] curr_y;
	
	logic [5:0] grinch_x;
	logic [5:0] grinch_y;
	logic [5:0] gift_x;
	logic [5:0] gift_y;
	
	logic is_wall;
	
	logic [11:0] walls [0:127];
	
	logic [5:0] num_x;
	logic [5:0] num_y;
	
	initial begin	
		gift_x <= 20;
		gift_y <= 20;
		grinch_x <= 10;
		grinch_y <= 10;
		gift_count <= 0;
		game_win <= 0;
		game_over <= 0;
	end
	
	assign curr_x = (x_in / 16);
	assign curr_y = (y_in / 16);
	
	always @(posedge vga_clk) begin
		num_x <= count % 36;
		num_y <= count % 26;
		if (curr_x == grinch_x && curr_y == grinch_y) begin
			pic_type <= 2'b01;
		end
		else if (curr_x == gift_x && curr_y == gift_y) begin
			pic_type <= 2'b00;
		end
		else if (is_wall) begin
			pic_type <= 2'b10;
		end
		else pic_type <= 2'b11;
	end

	always @(posedge vga_clk or negedge reset) begin 
		integer i;
		if (~reset) begin
			game_over = 0;
		end
		else begin
			is_wall = 0;
			for (i = 0; i < 128; i = i + 1) begin
				if (i < gift_count) begin 
					if (sw_i) begin
						if (walls[i] == {num_x, num_y}) begin
							is_wall = 1;
						end	
					end
					else begin
						if (walls[i] == {curr_x, curr_y}) begin
							is_wall = 1;
						end
					end
					
					if (walls[i] == {grinch_x, grinch_y} | game_win) begin
						game_over = 1;
					end
				end
			end
		end
	end
	
	always @(posedge update_clk or negedge reset) begin
		if (~reset) begin
			grinch_x <= 16;
			grinch_y <= 16;
		end
		else begin 
			if (~game_over) begin
				case (direction)
					2'b00: begin 
						grinch_x <= (grinch_x == 0) ? 39 : grinch_x - 1;
					end
					2'b01: begin 
						grinch_y <= (grinch_y == 0) ? 29 : grinch_y - 1;
					end
					2'b10: begin 
						grinch_x <= (grinch_x == 39) ? 0 : grinch_x + 1;
					end
					2'b11: begin 
						grinch_y <= (grinch_y == 29) ? 0 : grinch_y + 1;
					end
				endcase
			end
		end
	end
	
	always @(posedge update_clk or negedge reset) begin
		if (~reset) begin
			gift_x = 20;
			gift_y = 20;
			gift_count <= 0;
		end
		else begin 
			if (grinch_x == gift_x && grinch_y == gift_y) begin
				if (gift_count < 128) begin
					walls[gift_count] <= {grinch_x, grinch_y};
					gift_count <= gift_count + 1;
				end
				if (sw_i) begin
					if (~is_wall) begin
						gift_x <= count % 36;
						gift_y <= count % 26;
					end
				end
				else begin
					if (~is_wall) begin
						gift_x <= num_x;
						gift_y <= num_y;
					end
				end
			end
		end
	end
	
	always @(posedge update_clk or negedge reset) begin
		if (~reset) begin
			game_win <= 0;
		end
		else if (gift_count == 10) begin
			game_win <= 1;
		end
	end
	
endmodule
