module game_logic (
	input logic vga_clk,
	input logic update_clk,
	input logic reset,
	input logic [1:0] direction,
	input logic [9:0] x_in,
	input logic [8:0] y_in,
	output logic [1:0] entity,
	output logic game_over,
	output logic game_won,
	output logic [7:0] tail_count
);
	logic [5:0] curr_x;
	logic [5:0] curr_y;
	
	logic [9:0] snake_head_x;
	logic [8:0] snake_head_y;
	logic [9:0] fruit_x;
	logic [8:0] fruit_y;
	
	logic is_tail;
	
	logic [11:0] tails [0:127];
	
	logic [5:0] rand_num_x_orig, rand_num_x_fit;
	logic [5:0] rand_num_y_orig, rand_num_y_fit;
	
	assign rand_num_x_fit = 10 % 640;
	assign rand_num_y_fit = 10 % 480;
	
	initial begin
		fruit_x <= 20;
		fruit_y <= 20;
		snake_head_x <= 10;
		snake_head_y <= 10;
		tail_count <= 0;
		game_won <= 0;
		game_over <= 0;
	end
	
	assign curr_x = (x_in / 16);
	assign curr_y = (y_in / 16);
	
	always @(posedge vga_clk) begin 
		if (curr_x == snake_head_x && curr_y == snake_head_y) begin
			entity <= 2'b00;
		end
		else if (curr_x == fruit_x && curr_y == fruit_y) begin
			entity <= 2'b01;
		end
		else if (is_tail) begin
			entity <= 2'b10;
		end
		else entity <= 2'b11;
	end

	always @(posedge vga_clk or negedge reset) begin 
		integer i;
		if (reset) begin
			game_over = 0;
		end
		else begin
			is_tail = 0;
			for (i = 0; i < 128; i++) begin
				if (i < tail_count) begin 
					if (tails[i] == {curr_x, curr_y}) begin
						is_tail = 1;
					end
					
					if (tails[i] == {snake_head_x, snake_head_y}) begin
						game_over = 1;
					end
				end
			end
		end
	end
	
	always @(posedge update_clk or negedge reset) begin
		if (reset) begin
			snake_head_x <= 10;
			snake_head_y <= 10;
		end
		else begin 
			if (~game_over) begin
				case (direction)
					2'b00: begin 
						snake_head_x <= (snake_head_x == 0) ? 639 : snake_head_x - 1;
					end
					2'b01: begin 
						snake_head_y <= (snake_head_y == 479) ? 0 : snake_head_y + 1;
					end
					2'b10: begin 
						snake_head_x <= (snake_head_x == 639) ? 0 : snake_head_x + 1;
					end
					2'b10: begin 
						snake_head_y <= (snake_head_y == 0) ? 479 : snake_head_x - 1;
					end
				endcase
			end
		end
	end
	
	always @(posedge update_clk or negedge reset) begin
		integer i;
		if (reset) begin
			fruit_x = 20;
			fruit_y = 20;
			tail_count <= 0;
		end
		else begin 
			if (snake_head_x == fruit_x && snake_head_y == fruit_y) begin
				if (tail_count < 128) begin
					tails[tail_count] <= {snake_head_x, snake_head_y};
					tail_count <= tail_count + 1;
				end
				fruit_x <= rand_num_x_fit;
				fruit_y <= rand_num_y_fit;
			end
			else begin
				for (i = 0; i < 128; i++) begin
					if (i == (tail_count - 1)) begin
						tails[i] <= {snake_head_x, snake_head_y};
					end
					if (i != 127) begin
						tails[i] <= tails[i + 1];
					end
				end
			end
		end
	end
	
	always @(posedge update_clk or negedge reset) begin
		if (reset) begin
			game_won <= 0;
		end
		else if (tail_count == 128) begin
			game_won <= 1;
		end
	end
	
endmodule
