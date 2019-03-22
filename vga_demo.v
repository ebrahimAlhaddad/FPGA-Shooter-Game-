`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// VGA verilog template
// Author:  Da Cheng
//////////////////////////////////////////////////////////////////////////////////
module vga_demo(ClkPort, vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b, Sw0, Sw1, btnU, btnD, btnR, btnL
	,St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar,
	An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7);
	input ClkPort, Sw0, btnU, btnD, Sw0, Sw1, btnL, btnR;
	output St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar;
	output vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b;
	output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	output LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	reg vga_r, vga_g, vga_b;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/*  LOCAL SIGNALS */
	wire	reset, start, ClkPort, board_clk, clk, button_clk;
	
	BUF BUF1 (board_clk, ClkPort); 	
	BUF BUF2 (reset, Sw0);
	BUF BUF3 (start, Sw1);
	
	reg [27:0]	DIV_CLK;
	always @ (posedge board_clk, posedge reset)  
	begin : CLOCK_DIVIDER
      if (reset)
			DIV_CLK <= 0;
      else
			DIV_CLK <= DIV_CLK + 1'b1;
	end	

	assign	button_clk = DIV_CLK[18];
	assign	clk = DIV_CLK[1];
	assign 	{St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar} = {5'b11111};
	
	wire inDisplayArea;
	wire [9:0] CounterX;
	wire [9:0] CounterY;

	hvsync_generator syncgen(.clk(clk), .reset(reset),.vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));
	
	/////PROJECT STARTS HERE/////
	wire sys_clk;
	assign sys_clk = DIV_CLK[25];
	reg [7:0] sec_count;
	reg [9:0] position;
	
	//width = 640 height = 480
	//Bullet SM
	reg [3:0] coll_cnt1;
	reg bullet_state, bullet_show;
	wire collision1;
	assign collision1 = (collision_enemy1 || collision1_0 || collision1_1 || collision1_2 || collision1_3)? 1'b1:1'b0;
	reg [9:0] bullet_pos;
	//assign bullet_en = btnU;
	reg [9:0] shooter_pos;
		
	
	reg counter_state;
	always @(posedge sys_clk)
		if(reset || btnD)
		begin
			sec_count <= 8'b00000000;
			counter_state <= 1'b0;
		end
		else
			case(counter_state)
			1'b0:
			begin
				sec_count <= sec_count+1'b1;
				if(sec_count >= 8'b00111100)
					sec_count <= 8'b00111100;
			end
			endcase
	
	reg[7:0] total_coll_cnt;
	//total_coll_cnt <= coll_cnt1[3:0] + coll_cnt2[3:0];
	always @(posedge DIV_CLK[5])
		begin 
			if(reset || btnD)
				total_coll_cnt <= 0;
			else
				total_coll_cnt <= coll_cnt1[3:0] + coll_cnt2[3:0];
		end
	
	always @(posedge DIV_CLK[21])
		begin
			if(reset || btnD)
			begin
				bullet_state <= 1'b0;
				coll_cnt1 <= 0;
			end
			else
				begin
					case(bullet_state)
					1'b0:
						begin
						//TR
						if(btnU)
							bullet_state <= 1'b1;
						//DP
						bullet_pos <= 420;
						if(btnU)
							begin
							shooter_pos <= position;
							bullet_show <= 1;
							end
						else
							bullet_show <= 0;
						end
					1'b1:
						begin
						//TR
						if(collision1 == 1 || bullet_pos <= 10)
							bullet_state <= 1'b0;
						//DP
						bullet_pos <= bullet_pos - 10;
						if(collision1 == 1)
							begin
							bullet_show <= 0;
							if(sec_count < 8'b00111100)
								coll_cnt1 <= coll_cnt1 + 1;
							end
						else if(bullet_pos == 5)
							bullet_show <= 0;
						end
					endcase 
			end
		end
		
	reg [3:0] coll_cnt2;
	reg bullet_state2, bullet_show2;
	wire collision2;
	assign collision2 = (collision_enemy2 || collision2_0 || collision2_1 || collision2_2 || collision2_3)? 1'b1:1'b0;
	reg [9:0] bullet_pos2;
	//assign bullet_en = btnU;
	reg [9:0] shooter_pos2;	
		
//second Bullet SM
	always @(posedge DIV_CLK[21])
		begin
			if(reset || btnD)
			begin
				bullet_state2 <= 1'b0;
				coll_cnt2 <= 0;
			end
			else
				begin
					case(bullet_state2)
					1'b0:
						begin
						//TR
						if(btnU && (bullet_pos <= 320))
							bullet_state2 <= 1'b1;
						//DP
						bullet_pos2 <= 420;
						if(btnU && (bullet_pos <= 320))
							begin
							shooter_pos2 <= position;
							bullet_show2 <= 1;
							end
						else
							bullet_show2 <= 0;
						end
					1'b1:
						begin
						//TR
						if(collision2 == 1 || bullet_pos2 <= 10)
							bullet_state2 <= 1'b0;
						//DP
						bullet_pos2 <= bullet_pos2 - 10;
						if(collision2 == 1)
							begin
							bullet_show2 <= 0;
							if(sec_count < 8'b00111100)
								coll_cnt2 <= coll_cnt2 + 1;
							end
						else if(bullet_pos2 == 5)
							bullet_show2 <= 0;
						end
					endcase 
			end
		end
		
	//taget SM
	reg collision1_0;
	reg collision2_0;
	wire coll_condition1_0;
	wire coll_condition2_0;
	reg [3:0] speed;
	reg [9:0] target_pos;
	reg target_state, start_tar;
	assign coll_condition1_0 = ((bullet_pos - 5)<=20 && (target_pos - 20) <= shooter_pos && (target_pos + 20)>=shooter_pos);
	assign coll_condition2_0 = ((bullet_pos2 - 5)<=20 && (target_pos - 20) <= shooter_pos2 && (target_pos + 20)>=shooter_pos2);
	always @(posedge DIV_CLK[21])
	begin
	if(reset || btnD)
	begin
		target_state <= 0;
		start_tar <= 1;
		speed <= 3;
	end
	else
		begin
		case(target_state)
			1'b0:
			begin
			//TR
				if(start_tar == 1)
					target_state <= 1;
			//DP
				target_pos <= 30;
				collision1_0 <= 0;
				collision2_0 <= 0;
				if(speed == 15)
					speed <= 3;
				else
					speed <= speed + 1;
			end
			1'b1:
			begin
			//TR
				if(coll_condition1_0 || coll_condition2_0 || (target_pos >= 600))
					target_state <= 0;
			//DP
				target_pos <= target_pos + speed;
				if(coll_condition1_0 == 1)
					collision1_0 <= 1;
				else if(coll_condition2_0 == 1)
					collision2_0 <= 1;
			end
		endcase
		end
	end
	
	
	//second target
	reg collision1_1;
	reg collision2_1;
	wire coll_condition1_1;
	wire coll_condition2_1;
	reg [3:0] speed_1;
	reg [9:0] target_pos_1;
	reg target_state_1, start_tar_1;
	assign coll_condition1_1 = (bullet_pos - 5)<=40 && (target_pos_1 - 20) <= shooter_pos && (target_pos_1 + 20)>=shooter_pos;
	assign coll_condition2_1 = (bullet_pos2 - 5)<=40 && (target_pos_1 - 20) <= shooter_pos2 && (target_pos_1 + 20)>=shooter_pos2;
	always @(posedge DIV_CLK[21])
	begin
	if(reset || btnD)
	begin
		target_state_1 <= 0;
		start_tar_1 <= 1;
		speed_1 <= 6;
	end
	else
		begin
		case(target_state_1)
			1'b0:
			begin
			//TR
				if(start_tar_1 == 1)
					target_state_1 <= 1;
			//DP
				target_pos_1 <= 30;
				collision1_1 <= 0;
				collision2_1 <= 0;
				if(speed_1 == 15)
					speed_1 <= 6;
				else
					speed_1 <= speed_1 + 1;
			end
			1'b1:
			begin
			//TR
				if(coll_condition1_1 || coll_condition2_1 || (target_pos_1 >= 600))
					target_state_1 <= 0;
			//DP
				target_pos_1 <= target_pos_1 + speed_1;
				if(coll_condition1_1 == 1)
					collision1_1 <= 1;
				else if(coll_condition2_1 == 1)
					collision2_1 <= 1;
			end
		endcase
		end
	end
	
	
	//third target
	reg collision1_2;
	reg collision2_2;
	wire coll_condition1_2;
	wire coll_condition2_2;
	reg [3:0] speed_2;
	reg [9:0] target_pos_2;
	reg target_state_2, start_tar_2;
	assign coll_condition1_2 = (bullet_pos - 5)<=60 && (target_pos_2 - 20) <= shooter_pos && (target_pos_2 + 20)>=shooter_pos;
	assign coll_condition2_2 = (bullet_pos2 - 5)<=60 && (target_pos_2 - 20) <= shooter_pos2 && (target_pos_2 + 20)>=shooter_pos2;
	always @(posedge DIV_CLK[21])
	begin
	if(reset || btnD)
	begin
		target_state_2 <= 0;
		start_tar_2 <= 1;
		speed_2 <= 4;
	end
	else
		begin
		case(target_state_2)
			1'b0:
			begin
			//TR
				if(start_tar_2 == 1)
					target_state_2 <= 1;
			//DP
				target_pos_2 <= 30;
				collision1_2 <= 0;
				collision2_2 <= 0;
				if(speed_2 == 15)
					speed_2 <= 4;
				else
					speed_2 <= speed_2 + 1;
			end
			1'b1:
			begin
			//TR
				if(coll_condition1_2 || coll_condition2_2 || (target_pos_2 >= 600))
					target_state_2 <= 0;
			//DP
				target_pos_2 <= target_pos_2 + speed_2;
				if(coll_condition1_2 == 1)
					collision1_2 <= 1;
				else if(coll_condition2_2 == 1)
					collision2_2 <= 1;
			end
		endcase
		end
	end
	
	//forth target
	reg collision1_3;
	reg collision2_3;
	wire coll_condition1_3;
	wire coll_condition2_3;
	reg [3:0] speed_3;
	reg [9:0] target_pos_3;
	reg target_state_3, start_tar_3;
	assign coll_condition1_3 = (bullet_pos - 5)<=80 && (target_pos_3 - 20) <= shooter_pos && (target_pos_3 + 20)>=shooter_pos;
	assign coll_condition2_3 = (bullet_pos2 - 5)<=80 && (target_pos_3 - 20) <= shooter_pos2 && (target_pos_3 + 20)>=shooter_pos2;
	always @(posedge DIV_CLK[21])
	begin
	if(reset || btnD)
	begin
		target_state_3 <= 0;
		start_tar_3 <= 1;
		speed_3 <= 5;
	end
	else
		begin
		case(target_state_3)
			1'b0:
			begin
			//TR
				if(start_tar_3 == 1)
					target_state_3 <= 1;
			//DP
				target_pos_3 <= 30;
				collision1_3 <= 0;
				collision2_3 <= 0;
				if(speed_3 == 15)
					speed_3 <= 5;
				else
					speed_3 <= speed_3 + 1;
			end
			1'b1:
			begin
			//TR
				if(coll_condition1_3 || coll_condition2_3 || (target_pos_3 >= 600))
					target_state_3 <= 0;
			//DP
				target_pos_3 <= target_pos_3 + speed_3;
				if(coll_condition1_3 == 1)
					collision1_3 <= 1;
				else if(coll_condition2_3 == 1)
					collision2_3 <= 1;
			end
		endcase
		end
	end
	
	//Enemy
	reg collision_enemy1;
	reg collision_enemy2;
	wire coll_condition_enemy1;
	wire coll_condition_enemy2;
	//reg [3:0] speed_2;
	reg death;
	reg [9:0] enemy_pos_x;
	reg [9:0] enemy_pos_y;
	reg enemy_state, start_enemy;
	wire death_cond;
	assign death_cond = (position >= (enemy_pos_x - 30) || position <= (enemy_pos_x + 30)	|| enemy_pos_x == position) && enemy_pos_y >= 430;
	assign coll_condition_enemy1 = (bullet_pos - 5)<=(enemy_pos_y + 30) && (enemy_pos_x - 30) <= shooter_pos && (enemy_pos_x + 30)>=shooter_pos;
	assign coll_condition_enemy2 = (bullet_pos2 - 5)<=(enemy_pos_y + 30) && (enemy_pos_x - 30) <= shooter_pos2 && (enemy_pos_x + 30)>=shooter_pos2;
	always @(posedge DIV_CLK[21])
	begin
	if(reset || btnD)
	begin
		enemy_state <= 0;
		start_enemy <= 1'b1;
		death <= 0;
		//speed_2 <= 4;
	end
	else
		begin
		case(enemy_state)
			1'b0:
			begin
			//TR
				if(start_enemy == 1)
					enemy_state <= 1;
			//DP
				enemy_pos_x <= position;
				enemy_pos_y <= 30;
				collision_enemy1 <= 0;
				collision_enemy2 <= 0;
				death <= 0;
			end
			1'b1:
			begin
			//TR
				if(collision_enemy1 || collision_enemy2 || (enemy_pos_y >= 450))
					enemy_state <= 0;
			//DP
				enemy_pos_y <= enemy_pos_y + 5;
				if(enemy_pos_x > position)
					enemy_pos_x <= enemy_pos_x - 5;
				else if(enemy_pos_x < position)
					enemy_pos_x <= enemy_pos_x + 5;
				
				if(death_cond == 1)
				begin
					death <= 1;
					enemy_state <= 0;
				end
				if(coll_condition_enemy1 == 1)
					collision_enemy1 <= 1;
				else if(coll_condition_enemy2 == 1)
					collision_enemy2 <= 1;
			end
		endcase
		end
	end
	
	
	//shooter SM
	always @(posedge DIV_CLK[21])
		begin
			if(reset || btnD)
				position<=320;
			else if(btnR && ~btnL)
			begin
				position<=position+9;
			end
			else if(btnL && ~btnR)
			begin
				position<=position-9;	
			end
			if (death)
				position <= 320;
		end

	wire R = (bullet_show&&(CounterX>=(shooter_pos - 5) && CounterX<=(shooter_pos + 5) && CounterY>=(bullet_pos -5) && CounterY<=(bullet_pos + 5)) ) || ( bullet_show2&&(CounterX>=(shooter_pos2 - 5) && CounterX<=(shooter_pos2 + 5) && CounterY>=(bullet_pos2 -5) && CounterY<=(bullet_pos2 + 5)) )  || ((CounterY >=(enemy_pos_y -30) && CounterY <=(enemy_pos_y + 30) && CounterX <= (enemy_pos_x + 30) && CounterX >= (enemy_pos_x - 30)));
	wire G = CounterX>=(target_pos - 30) && CounterX<=(target_pos + 30) && CounterY<=20 && CounterY>=10 || (CounterX>=(target_pos_1 - 30) && CounterX<=(target_pos_1 + 30) && CounterY<=40 && CounterY>=30) || (CounterX>=(target_pos_2 - 30) && CounterX<=(target_pos_2 + 30) && CounterY<=60 && CounterY>=50) || (CounterX>=(target_pos_3 - 30) && CounterX<=(target_pos_3 + 30) && CounterY<=80 && CounterY>=70);
	wire B = CounterX>=(position-(CounterY - 430)) && CounterX<=(position+(CounterY - 430)) && CounterY>=420 && CounterY<=480;
	
	always @(posedge clk)
	begin
		vga_r <= R & inDisplayArea;
		vga_g <= G & inDisplayArea;
		vga_b <= B & inDisplayArea;
	end
	
	/*
	/////////////////////////////////////////////////////////////////
	///////////////		VGA control starts here		/////////////////
	/////////////////////////////////////////////////////////////////
	reg [9:0] position;
	
	always @(posedge DIV_CLK[21])
		begin
			if(reset)
				position<=240;
			else if(btnD && ~btnU)
				position<=position+2;
			else if(btnU && ~btnD)
				position<=position-2;	
		end

	wire R = CounterY>=(position-10) && CounterY<=(position+10) && CounterX[8:5]==7;
	wire G = CounterX>100 && CounterX<200 && CounterY[5:3]==7;
	wire B = 0;
	
	always @(posedge clk)
	begin
		vga_r <= R & inDisplayArea;
		vga_g <= G & inDisplayArea;
		vga_b <= B & inDisplayArea;
	end
	*/
	/////////////////////////////////////////////////////////////////
	//////////////  	  VGA control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	`define QI 			2'b00
	`define QGAME_1 	2'b01
	`define QGAME_2 	2'b10
	`define QDONE 		2'b11
	
	reg [3:0] p2_score;
	reg [3:0] p1_score;
	reg [1:0] state;
	wire LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	
	assign LD0 = (p1_score == 4'b1010);
	assign LD1 = (p2_score == 4'b1010);
	
	assign LD2 = start;
	assign LD4 = reset;
	
	assign LD3 = (state == `QI);
	assign LD5 = (state == `QGAME_1);	
	assign LD6 = (state == `QGAME_2);
	assign LD7 = (state == `QDONE);
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control ends here 	 	////////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	reg 	[3:0]	SSD;
	wire 	[3:0]	SSD0, SSD1, SSD2, SSD3;
	wire 	[1:0] ssdscan_clk;
	
	
	assign SSD3 = total_coll_cnt[7:4];
	assign SSD2 = total_coll_cnt[3:0];
	assign SSD1 = sec_count[7:4];
	assign SSD0 = sec_count[3:0];
	
	// need a scan clk for the seven segment display 
	// 191Hz (50MHz / 2^18) works well
	assign ssdscan_clk = DIV_CLK[19:18];	
	assign An0	= !(~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 00
	assign An1	= !(~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 01
	assign An2	= !( (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 10
	assign An3	= !( (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 11
	
	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk) 
			2'b00:
					SSD = SSD0;
			2'b01:
					SSD = SSD1;
			2'b10:
					SSD = SSD2;
			2'b11:
					SSD = SSD3;
		endcase 
	end	

	// and finally convert SSD_num to ssd
	reg [7:0]  SSD_CATHODES;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES};
	// Following is Hex-to-SSD conversion
	always @ (SSD) 
	begin : HEX_TO_SSD
		case (SSD)		
			4'b0000: SSD_CATHODES = 8'b00000011; // 0
			4'b0001: SSD_CATHODES = 8'b10011111; // 1
			4'b0010: SSD_CATHODES = 8'b00100101; // 2
			4'b0011: SSD_CATHODES = 8'b00001101; // 3
			4'b0100: SSD_CATHODES = 8'b10011001; // 4
			4'b0101: SSD_CATHODES = 8'b01001001; // 5
			4'b0110: SSD_CATHODES = 8'b01000001; // 6
			4'b0111: SSD_CATHODES = 8'b00011111; // 7
			4'b1000: SSD_CATHODES = 8'b00000001; // 8
			4'b1001: SSD_CATHODES = 8'b00001001; // 9
			4'b1010: SSD_CATHODES = 8'b00010001; // A
			4'b1011: SSD_CATHODES = 8'b11000001; // B
			4'b1100: SSD_CATHODES = 8'b01100011; // C
			4'b1101: SSD_CATHODES = 8'b10000101; // D
			4'b1110: SSD_CATHODES = 8'b01100001; // E
			4'b1111: SSD_CATHODES = 8'b01110001; // F 
			default: SSD_CATHODES = 8'bXXXXXXXX ; // default is not needed as we covered all cases
		endcase
	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
endmodule

