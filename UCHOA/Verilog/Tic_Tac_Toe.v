// top level module for project

module Tic_Tac_Toe(
	input clk, 
	input rst,
	input [8:0]move, //9 grid squares
	input AI_en, // 0 = player1 v. player2, 1 = player1 v. AI
	input mode, // level of difficulty of AI: 0 = easy, 1 = hard
	
	// grid values
	output reg [1:0]grid_A1, grid_A2, grid_A3, grid_B1, grid_B2, grid_B3, grid_C1, grid_C2, grid_C3, 
	
	// VGA outputs
	output [9:0]VGA_R,
	output [9:0]VGA_G,
	output [9:0]VGA_B,
	output VGA_HS,
	output VGA_VS,
	output VGA_BLANK,
	output VGA_SYNC,
	output VGA_CLK,
	
	// seven segment outputs
	output [6:0]seg7_lsb,
	output [6:0]seg7_msb,
	output [6:0]seg7_hund,
	output [6:0]seg7_thous
	);
	
	// variables used for vga
	reg plot = 1'b1; 
	reg [31:0]x;
	reg [31:0]y;
	reg [2:0]color;
	reg back_color = 3'b000;
	
	// counter variables used for displaying
	reg [31:0]count_x;
	reg [31:0]count_y;
	
	vga_adapter my_vga(rst, clk, color, x, y, plot, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK);
	
	// Grid:
	//       1    2    3
	//    |----|----|----|
	//    |    |    |    |
	//  A | A1 | A2 | A3 |
	//    |    |    |    |
	//    -----|----|-----
	//    |    |    |    |
	//  B | B1 | B2 | B3 |
	//    |    |    |    |
	//    -----|----|-----
	//    |    |    |    |
	//  C | C1 | C2 | C3 |
	//    |    |    |    |
	//    |----|----|----|
	
	// grid sqaures
	parameter A1 = 9'b100000000,
				 A2 = 9'b010000000,
				 A3 = 9'b001000000,
				 B1 = 9'b000100000,
				 B2 = 9'b000010000,
				 B3 = 9'b000001000,
				 C1 = 9'b000000100,
				 C2 = 9'b000000010,
				 C3 = 9'b000000001;
				 
	// variables to be used
	reg valid;
	reg [1:0]user;
	reg [2:0]outcome;
	reg [2:0]A1_color, A2_color, A3_color, B1_color, B2_color, B3_color, C1_color, C2_color, C3_color;
	
	// user moves
	reg [8:0]p1_move;
	reg [8:0]p2_move;
	
	// outcome parameters
	parameter in_progress = 3'd0,
				 p1_win = 3'd1,
				 p1_lose = 3'd2,
				 tie = 3'd3;

	// player parameters
	parameter player1 = 2'b01,
				 player2 = 2'b10,
				 default_player = 2'b00;
	
	// grid color parameters
	parameter p1_color = 3'b010,
	          p2_color = 3'b101,
	          default_color = 3'b111;
				 
	// seven segment instantiation
	four_val_display disp_four(user, seg7_lsb, seg7_msb, seg7_hund, seg7_thous);
			
	// variables used for AI implementation
	wire [8:0]AI_move;
	
	// implementing AI for computer turn
	AI_decide my_AI(grid_A1, grid_A2, grid_A3, grid_B1, grid_B2, grid_B3, grid_C1, grid_C2, grid_C3, AI_en, mode, AI_move);
	
	// state variables for FSM
	reg [7:0]S;
	reg [7:0]NS;
	
	// state parameters
	parameter 
		INIT = 8'd70,
		
		// background
		BACK_START = 8'd0,
		BACK_CHECK_Y = 8'd1,
		BACK_CHECK_X = 8'd2,
		BACK_UPDATE_Y = 8'd3,
		BACK_UPDATE_X = 8'd4,
		BACK_DRAW = 8'd5,
		BACK_END = 8'd6,
		
		// A1
		A1_START = 8'd7,
		A1_CHECK_Y = 8'd8,
		A1_CHECK_X = 8'd9,
		A1_UPDATE_Y = 8'd10,
		A1_UPDATE_X = 8'd11,
		A1_DRAW = 8'd12,
		A1_END = 8'd13,
		
		// A2
		A2_START = 8'd14,
		A2_CHECK_Y = 8'd15,
		A2_CHECK_X = 8'd16,
		A2_UPDATE_Y = 8'd17,
		A2_UPDATE_X = 8'd18,
		A2_DRAW = 8'd19,
		A2_END = 8'd20,
		
		// A3
		A3_START = 8'd21,
		A3_CHECK_Y = 8'd22,
		A3_CHECK_X = 8'd23,
		A3_UPDATE_Y = 8'd24,
		A3_UPDATE_X = 8'd25,
		A3_DRAW = 8'd26,
		A3_END = 8'd27,
		
		// B1
		B1_START = 8'd28,
		B1_CHECK_Y = 8'd29,
		B1_CHECK_X = 8'd30,
		B1_UPDATE_Y = 8'd31,
		B1_UPDATE_X = 8'd32,
		B1_DRAW = 8'd33,
		B1_END = 8'd34,
		
		// B2
		B2_START = 8'd35,
		B2_CHECK_Y = 8'd36,
		B2_CHECK_X = 8'd37,
		B2_UPDATE_Y = 8'd38,
		B2_UPDATE_X = 8'd39,
		B2_DRAW = 8'd40,
		B2_END = 8'd41,
		
		// B3
		B3_START = 8'd42,
		B3_CHECK_Y = 8'd43,
		B3_CHECK_X = 8'd44,
		B3_UPDATE_Y = 8'd45,
		B3_UPDATE_X = 8'd46,
		B3_DRAW = 8'd47,
		B3_END = 8'd48,
		
		// C1
		C1_START = 8'd49,
		C1_CHECK_Y = 8'd50,
		C1_CHECK_X = 8'd51,
		C1_UPDATE_Y = 8'd52,
		C1_UPDATE_X = 8'd53,
		C1_DRAW = 8'd54,
		C1_END = 8'd55,
		
		// C2
		C2_START = 8'd56,
		C2_CHECK_Y = 8'd57,
		C2_CHECK_X = 8'd58,
		C2_UPDATE_Y = 8'd59,
		C2_UPDATE_X = 8'd60,
		C2_DRAW = 8'd61,
		C2_END = 8'd62,
		
		// C3
		C3_START = 8'd63,
		C3_CHECK_Y = 8'd64,
		C3_CHECK_X = 8'd65,
		C3_UPDATE_Y = 8'd66,
		C3_UPDATE_X = 8'd67,
		C3_DRAW = 8'd68,
		C3_END = 8'd69,
		
		//INIT = 70
		START = 8'd71,
		P1 = 8'd72,
		GET_MOVE_P1 = 8'd73,
		CHECK_VALIDITY = 8'd74,
		UPDATE_GRID = 8'd75,
		UPDATE_BOARD = 8'd76,
		
		// A1 redraw
		RE_A1_START = 8'd77,
		RE_A1_CHECK_Y = 8'd78,
		RE_A1_CHECK_X = 8'd79,
		RE_A1_UPDATE_Y = 8'd80,
		RE_A1_UPDATE_X = 8'd81,
		RE_A1_DRAW = 8'd82,
		RE_A1_END = 8'd83,
		
		// A2 redraw
		RE_A2_START = 8'd145,
		RE_A2_CHECK_Y = 8'd84,
		RE_A2_CHECK_X = 8'd85,
		RE_A2_UPDATE_Y = 8'd86,
		RE_A2_UPDATE_X = 8'd87,
		RE_A2_DRAW = 8'd88,
		RE_A2_END = 8'd89,
		
		// A3 redraw
		RE_A3_START = 8'd90,
		RE_A3_CHECK_Y = 8'd91,
		RE_A3_CHECK_X = 8'd92,
		RE_A3_UPDATE_Y = 8'd93,
		RE_A3_UPDATE_X = 8'd94,
		RE_A3_DRAW = 8'd95,
		RE_A3_END = 8'd96,
		
		// B1 redraw
		RE_B1_START = 8'd97,
		RE_B1_CHECK_Y = 8'd98,
		RE_B1_CHECK_X = 8'd99,
		RE_B1_UPDATE_Y = 8'd100,
		RE_B1_UPDATE_X = 8'd101,
		RE_B1_DRAW = 8'd102,
		RE_B1_END = 8'd103,
		
		// B2 redraw
 		RE_B2_START = 8'd104,
		RE_B2_CHECK_Y = 8'd105,
		RE_B2_CHECK_X = 8'd106,
		RE_B2_UPDATE_Y = 8'd107,
		RE_B2_UPDATE_X = 8'd108,
		RE_B2_DRAW = 8'd109,
		RE_B2_END = 8'd110,
		
		// B3 redraw
		RE_B3_START = 8'd111,
		RE_B3_CHECK_Y = 8'd112,
		RE_B3_CHECK_X = 8'd113,
		RE_B3_UPDATE_Y = 8'd114,
		RE_B3_UPDATE_X = 8'd115,
		RE_B3_DRAW = 8'd116,
		RE_B3_END = 8'd117,
		
		// C1 redraw
		RE_C1_START = 8'd118,
		RE_C1_CHECK_Y = 8'd119,
		RE_C1_CHECK_X = 8'd120,
		RE_C1_UPDATE_Y = 8'd121,
		RE_C1_UPDATE_X = 8'd122,
		RE_C1_DRAW = 8'd123,
		RE_C1_END = 8'd124,
		
		// C2 redraw
 		RE_C2_START = 8'd125,
		RE_C2_CHECK_Y = 8'd126,
		RE_C2_CHECK_X = 8'd127,
		RE_C2_UPDATE_Y = 8'd128,
		RE_C2_UPDATE_X = 8'd129,
		RE_C2_DRAW = 8'd130,
		RE_C2_END = 8'd131,
		
		// C3 redraw
		RE_C3_START = 8'd132,
		RE_C3_CHECK_Y = 8'd133,
		RE_C3_CHECK_X = 8'd134,
		RE_C3_UPDATE_Y = 8'd135,
		RE_C3_UPDATE_X = 8'd136,
		RE_C3_DRAW = 8'd137,
		RE_C3_END = 8'd138,
		
		CHECK_OUTCOME = 8'd139,
		DETERMINE_OUTCOME = 8'd144,
		P2 = 8'd140,
		GET_MOVE_AI = 8'd146,
		GET_MOVE_P2 = 8'd141,
		END = 8'd143,
		
		// display win
		WIN_START = 8'd147,
		WIN_CHECK_Y = 8'd148,
		WIN_CHECK_X = 8'd149,
		WIN_UPDATE_Y = 8'd150,
		WIN_UPDATE_X = 8'd151,
		WIN_DRAW = 8'd152,
		WIN_END = 8'd153,
		
		ERROR = 8'hF;
			
	// changing states on clk tick		
	always @(posedge clk or negedge rst)
	begin
		if (rst == 1'b0)
			S <= INIT;
		else
			S <= NS;
	end
	
	// state travel chart
	always @(*)
	begin
	
		case(S)
			INIT: NS = BACK_START;
			
			BACK_START: NS = BACK_CHECK_Y;
			BACK_CHECK_Y: 
			begin
				if (count_y < 240)
				begin
					NS = BACK_CHECK_X;
				end
				else
				begin
					NS = BACK_END;
				end
			end
			BACK_CHECK_X:
			begin
				if (count_x < 320)
				begin
					NS = BACK_DRAW;
				end
				else
				begin
					NS = BACK_UPDATE_Y;
				end
			end
			BACK_UPDATE_Y: NS = BACK_CHECK_Y;
			BACK_UPDATE_X: NS = BACK_CHECK_X;
			BACK_DRAW: NS = BACK_UPDATE_X;
			BACK_END: NS = A1_START;
			
			// A1
			A1_START: NS = A1_CHECK_Y;
			A1_CHECK_Y: 
			begin
				if (count_y < 77)
				begin
					NS = A1_CHECK_X;
				end
				else
				begin
					NS = A1_END;
				end
			end
			A1_CHECK_X:
			begin
				if (count_x < 104)
				begin
					NS = A1_DRAW;
				end
				else
				begin
					NS = A1_UPDATE_Y;
				end
			end
			A1_UPDATE_Y: NS = A1_CHECK_Y;
			A1_UPDATE_X: NS = A1_CHECK_X;
			A1_DRAW: NS = A1_UPDATE_X;
			A1_END: NS = A2_START;
			
			// A2
			A2_START: NS = A2_CHECK_Y;
			A2_CHECK_Y: 
			begin
				if (count_y < 77)
				begin
					NS = A2_CHECK_X;
				end
				else
				begin
					NS = A2_END;
				end
			end
			A2_CHECK_X:
			begin
				if (count_x < 211)
				begin
					NS = A2_DRAW;
				end
				else
				begin
					NS = A2_UPDATE_Y;
				end
			end
			A2_UPDATE_Y: NS = A2_CHECK_Y;
			A2_UPDATE_X: NS = A2_CHECK_X;
			A2_DRAW: NS = A2_UPDATE_X;
			A2_END: NS = A3_START;
			
			// A3
			A3_START: NS = A3_CHECK_Y;
			A3_CHECK_Y: 
			begin
				if (count_y < 77)
				begin
					NS = A3_CHECK_X;
				end
				else
				begin
					NS = A3_END;
				end
			end
			A3_CHECK_X:
			begin
				if (count_x < 320)
				begin
					NS = A3_DRAW;
				end
				else
				begin
					NS = A3_UPDATE_Y;
				end
			end
			A3_UPDATE_Y: NS = A3_CHECK_Y;
			A3_UPDATE_X: NS = A3_CHECK_X;
			A3_DRAW: NS = A3_UPDATE_X;
			A3_END: NS = B1_START;
			
			// B1
			B1_START: NS = B1_CHECK_Y;
			B1_CHECK_Y: 
			begin
				if (count_y < 158)
				begin
					NS = B1_CHECK_X;
				end
				else
				begin
					NS = B1_END;
				end
			end
			B1_CHECK_X:
			begin
				if (count_x < 104)
				begin
					NS = B1_DRAW;
				end
				else
				begin
					NS = B1_UPDATE_Y;
				end
			end
			B1_UPDATE_Y: NS = B1_CHECK_Y;
			B1_UPDATE_X: NS = B1_CHECK_X;
			B1_DRAW: NS = B1_UPDATE_X;
			B1_END: NS = B2_START;
			
			// B2
			B2_START: NS = B2_CHECK_Y;
			B2_CHECK_Y: 
			begin
				if (count_y < 158)
				begin
					NS = B2_CHECK_X;
				end
				else
				begin
					NS = B2_END;
				end
			end
			B2_CHECK_X:
			begin
				if (count_x < 211)
				begin
					NS = B2_DRAW;
				end
				else
				begin
					NS = B2_UPDATE_Y;
				end
			end
			B2_UPDATE_Y: NS = B2_CHECK_Y;
			B2_UPDATE_X: NS = B2_CHECK_X;
			B2_DRAW: NS = B2_UPDATE_X;
			B2_END: NS = B3_START;
			
			// B3
			B3_START: NS = B3_CHECK_Y;
			B3_CHECK_Y: 
			begin
				if (count_y < 158)
				begin
					NS = B3_CHECK_X;
				end
				else
				begin
					NS = B3_END;
				end
			end
			B3_CHECK_X:
			begin
				if (count_x < 320)
				begin
					NS = B3_DRAW;
				end
				else
				begin
					NS = B3_UPDATE_Y;
				end
			end
			B3_UPDATE_Y: NS = B3_CHECK_Y;
			B3_UPDATE_X: NS = B3_CHECK_X;
			B3_DRAW: NS = B3_UPDATE_X;
			B3_END: NS = C1_START;
			
			// C1
			C1_START: NS = C1_CHECK_Y;
			C1_CHECK_Y: 
			begin
				if (count_y < 240)
				begin
					NS = C1_CHECK_X;
				end
				else
				begin
					NS = C1_END;
				end
			end
			C1_CHECK_X:
			begin
				if (count_x < 104)
				begin
					NS = C1_DRAW;
				end
				else
				begin
					NS = C1_UPDATE_Y;
				end
			end
			C1_UPDATE_Y: NS = C1_CHECK_Y;
			C1_UPDATE_X: NS = C1_CHECK_X;
			C1_DRAW: NS = C1_UPDATE_X;
			C1_END: NS = C2_START;
			
			// C2
			C2_START: NS = C2_CHECK_Y;
			C2_CHECK_Y: 
			begin
				if (count_y < 240)
				begin
					NS = C2_CHECK_X;
				end
				else
				begin
					NS = C2_END;
				end
			end
			C2_CHECK_X:
			begin
				if (count_x < 211)
				begin
					NS = C2_DRAW;
				end
				else
				begin
					NS = C2_UPDATE_Y;
				end
			end
			C2_UPDATE_Y: NS = C2_CHECK_Y;
			C2_UPDATE_X: NS = C2_CHECK_X;
			C2_DRAW: NS = C2_UPDATE_X;
			C2_END: NS = C3_START;
			
			// C3
			C3_START: NS = C3_CHECK_Y;
			C3_CHECK_Y: 
			begin
				if (count_y < 240)
				begin
					NS = C3_CHECK_X;
				end
				else
				begin
					NS = C3_END;
				end
			end
			C3_CHECK_X:
			begin
				if (count_x < 320)
				begin
					NS = C3_DRAW;
				end
				else
				begin
					NS = C3_UPDATE_Y;
				end
			end
			C3_UPDATE_Y: NS = C3_CHECK_Y;
			C3_UPDATE_X: NS = C3_CHECK_X;
			C3_DRAW: NS = C3_UPDATE_X;
			C3_END: NS = START;
			
			START: NS = P1;
			P1: NS = GET_MOVE_P1;
			GET_MOVE_P1: NS = CHECK_VALIDITY;
			CHECK_VALIDITY:
			begin
				if (valid == 1'b0)
				begin
					if (user == player1)
						NS = GET_MOVE_P1;
					else if ((user == player2) && (AI_en == 1'b1))
						NS = GET_MOVE_AI;
					else if ((user == player2) && (AI_en == 1'b0))
						NS = GET_MOVE_P2;
				end
				else
					NS = UPDATE_GRID;
			end
			UPDATE_GRID: NS = UPDATE_BOARD;
			UPDATE_BOARD:
			begin
				if ((p1_move == A1) || (p2_move == A1))
					NS = RE_A1_START;
				else if ((p1_move == A2) || (p2_move == A2))
					NS = RE_A2_START;
				else if ((p1_move == A3) || (p2_move == A3))	
					NS = RE_A3_START;
				else if ((p1_move == B1) || (p2_move == B1))
					NS = RE_B1_START;
				else if ((p1_move == B2) || (p2_move == B2))
					NS = RE_B2_START;
				else if ((p1_move == B3) || (p2_move == B3))
					NS = RE_B3_START;
				else if ((p1_move == C1) || (p2_move == C1))
					NS = RE_C1_START;
				else if ((p1_move == C2) || (p2_move == C2))
					NS = RE_C2_START;
				else if ((p1_move == C3) || (p2_move == C3))
					NS = RE_C3_START;
				else 
				begin
					if (user == player1)
						NS = GET_MOVE_P1;
					else if ((user == player2) && (AI_en == 1'b0))
						NS = GET_MOVE_P2; 
					else if ((user == player2) && (AI_en == 1'b1))
						NS = GET_MOVE_AI;
				end
			end
					
			// A1 redraw
			RE_A1_START: NS = RE_A1_CHECK_Y;
			RE_A1_CHECK_Y: 
			begin
				if (count_y < 77)
				begin
					NS = RE_A1_CHECK_X;
				end
				else
				begin
					NS = RE_A1_END;
				end
			end
			RE_A1_CHECK_X:
			begin
				if (count_x < 104)
				begin
					NS = RE_A1_DRAW;
				end
				else
				begin
					NS = RE_A1_UPDATE_Y;
				end
			end
			RE_A1_UPDATE_Y: NS = RE_A1_CHECK_Y;
			RE_A1_UPDATE_X: NS = RE_A1_CHECK_X;
			RE_A1_DRAW: NS = RE_A1_UPDATE_X;
			RE_A1_END: NS = CHECK_OUTCOME;
			
			// A2 redraw
			RE_A2_START: NS = RE_A2_CHECK_Y;
			RE_A2_CHECK_Y: 
			begin
				if (count_y < 77)
				begin
					NS = RE_A2_CHECK_X;
				end
				else
				begin
					NS = RE_A2_END;
				end
			end
			RE_A2_CHECK_X:
			begin
				if (count_x < 211)
				begin
					NS = RE_A2_DRAW;
				end
				else
				begin
					NS = RE_A2_UPDATE_Y;
				end
			end
			RE_A2_UPDATE_Y: NS = RE_A2_CHECK_Y;
			RE_A2_UPDATE_X: NS = RE_A2_CHECK_X;
			RE_A2_DRAW: NS = RE_A2_UPDATE_X;
			RE_A2_END: NS = CHECK_OUTCOME;
			
			// A3 redraw
			RE_A3_START: NS = RE_A3_CHECK_Y;
			RE_A3_CHECK_Y: 
			begin
				if (count_y < 77)
				begin
					NS = RE_A3_CHECK_X;
				end
				else
				begin
					NS = RE_A3_END;
				end
			end
			RE_A3_CHECK_X:
			begin
				if (count_x < 320)
				begin
					NS = RE_A3_DRAW;
				end
				else
				begin
					NS = RE_A3_UPDATE_Y;
				end
			end
			RE_A3_UPDATE_Y: NS = RE_A3_CHECK_Y;
			RE_A3_UPDATE_X: NS = RE_A3_CHECK_X;
			RE_A3_DRAW: NS = RE_A3_UPDATE_X;
			RE_A3_END: NS = CHECK_OUTCOME;
			
			// B1 redraw
			RE_B1_START: NS = RE_B1_CHECK_Y;
			RE_B1_CHECK_Y: 
			begin
				if (count_y < 158)
				begin
					NS = RE_B1_CHECK_X;
				end
				else
				begin
					NS = RE_B1_END;
				end
			end
			RE_B1_CHECK_X:
			begin
				if (count_x < 104)
				begin
					NS = RE_B1_DRAW;
				end
				else
				begin
					NS = RE_B1_UPDATE_Y;
				end
			end
			RE_B1_UPDATE_Y: NS = RE_B1_CHECK_Y;
			RE_B1_UPDATE_X: NS = RE_B1_CHECK_X;
			RE_B1_DRAW: NS = RE_B1_UPDATE_X;
			RE_B1_END: NS = CHECK_OUTCOME;
			
			// B2 redraw
			RE_B2_START: NS = RE_B2_CHECK_Y;
			RE_B2_CHECK_Y: 
			begin
				if (count_y < 158)
				begin
					NS = RE_B2_CHECK_X;
				end
				else
				begin
					NS = RE_B2_END;
				end
			end
			RE_B2_CHECK_X:
			begin
				if (count_x < 211)
				begin
					NS = RE_B2_DRAW;
				end
				else
				begin
					NS = RE_B2_UPDATE_Y;
				end
			end
			RE_B2_UPDATE_Y: NS = RE_B2_CHECK_Y;
			RE_B2_UPDATE_X: NS = RE_B2_CHECK_X;
			RE_B2_DRAW: NS = RE_B2_UPDATE_X;
			RE_B2_END: NS = CHECK_OUTCOME;
			
			// B3 redraw
			RE_B3_START: NS = RE_B3_CHECK_Y;
			RE_B3_CHECK_Y: 
			begin
				if (count_y < 158)
				begin
					NS = RE_B3_CHECK_X;
				end
				else
				begin
					NS = RE_B3_END;
				end
			end
			RE_B3_CHECK_X:
			begin
				if (count_x < 320)
				begin
					NS = RE_B3_DRAW;
				end
				else
				begin
					NS = RE_B3_UPDATE_Y;
				end
			end
			RE_B3_UPDATE_Y: NS = RE_B3_CHECK_Y;
			RE_B3_UPDATE_X: NS = RE_B3_CHECK_X;
			RE_B3_DRAW: NS = RE_B3_UPDATE_X;
			RE_B3_END: NS = CHECK_OUTCOME;
			
			// C1 redraw
			RE_C1_START: NS = RE_C1_CHECK_Y;
			RE_C1_CHECK_Y: 
			begin
				if (count_y < 240)
				begin
					NS = RE_C1_CHECK_X;
				end
				else
				begin
					NS = RE_C1_END;
				end
			end
			RE_C1_CHECK_X:
			begin
				if (count_x < 104)
				begin
					NS = RE_C1_DRAW;
				end
				else
				begin
					NS = RE_C1_UPDATE_Y;
				end
			end
			RE_C1_UPDATE_Y: NS = RE_C1_CHECK_Y;
			RE_C1_UPDATE_X: NS = RE_C1_CHECK_X;
			RE_C1_DRAW: NS = RE_C1_UPDATE_X;
			RE_C1_END: NS = CHECK_OUTCOME;
			
			// C2 redraw
			RE_C2_START: NS = RE_C2_CHECK_Y;
			RE_C2_CHECK_Y: 
			begin
				if (count_y < 240)
				begin
					NS = RE_C2_CHECK_X;
				end
				else
				begin
					NS = RE_C2_END;
				end
			end
			RE_C2_CHECK_X:
			begin
				if (count_x < 211)
				begin
					NS = RE_C2_DRAW;
				end
				else
				begin
					NS = RE_C2_UPDATE_Y;
				end
			end
			RE_C2_UPDATE_Y: NS = RE_C2_CHECK_Y;
			RE_C2_UPDATE_X: NS = RE_C2_CHECK_X;
			RE_C2_DRAW: NS = RE_C2_UPDATE_X;
			RE_C2_END: NS = CHECK_OUTCOME;
			
			// C3 redraw
			RE_C3_START: NS = RE_C3_CHECK_Y;
			RE_C3_CHECK_Y: 
			begin
				if (count_y < 240)
				begin
					NS = RE_C3_CHECK_X;
				end
				else
				begin
					NS = RE_C3_END;
				end
			end
			RE_C3_CHECK_X:
			begin
				if (count_x < 320)
				begin
					NS = RE_C3_DRAW;
				end
				else
				begin
					NS = RE_C3_UPDATE_Y;
				end
			end
			RE_C3_UPDATE_Y: NS = RE_C3_CHECK_Y;
			RE_C3_UPDATE_X: NS = RE_C3_CHECK_X;
			RE_C3_DRAW: NS = RE_C3_UPDATE_X;
			RE_C3_END: NS = CHECK_OUTCOME;
			
			CHECK_OUTCOME: NS = DETERMINE_OUTCOME;
			DETERMINE_OUTCOME:
			begin
				if ((outcome == in_progress) && (user == player1))
					NS = P2;
				else if ((outcome == in_progress) && (user == player2))
					NS = P1;
				else if (outcome != in_progress)
					NS = END;
				else
					NS = CHECK_OUTCOME;
			end
			P2: 
			begin
				if (AI_en == 1'b1)
					NS = GET_MOVE_AI;
				else
					NS = GET_MOVE_P2;
			end
			GET_MOVE_AI: NS = CHECK_VALIDITY;
			GET_MOVE_P2: NS = CHECK_VALIDITY;
			END: NS = WIN_START;
			
			// display winner
			WIN_START: NS = WIN_CHECK_Y;
			WIN_CHECK_Y: 
			begin
				if (count_y < 240)
				begin
					NS = WIN_CHECK_X;
				end
				else
				begin
					NS = WIN_END;
				end
			end
			WIN_CHECK_X:
			begin
				if (count_x < 320)
				begin
					NS = WIN_DRAW;
				end
				else
				begin
					NS = WIN_UPDATE_Y;
				end
			end
			WIN_UPDATE_Y: NS = WIN_CHECK_Y;
			WIN_UPDATE_X: NS = WIN_CHECK_X;
			WIN_DRAW: NS = WIN_UPDATE_X;
			WIN_END: NS = WIN_END;
			
			default: NS = ERROR;
		endcase
	end
	
	always @(posedge clk or negedge rst)
	begin
		if (rst == 1'b0)
		begin
			// initializing variables
			valid <= 1'b0;
			user <= default_player;
			outcome <= in_progress;
		
			// default colors for board
			A1_color <= default_color;
			A2_color <= default_color;
			A3_color <= default_color;
			B1_color <= default_color;
			B2_color <= default_color;
			B3_color <= default_color;
			C1_color <= default_color;
			C2_color <= default_color;
			C3_color <= default_color;
			
			// default values for grid squares
			grid_A1 <= default_player;
			grid_A2 <= default_player;
			grid_A3 <= default_player;
			grid_B1 <= default_player;
			grid_B2 <= default_player;
			grid_B3 <= default_player;
			grid_C1 <= default_player;
			grid_C2 <= default_player;
			grid_C3 <= default_player;
			
			// vga variables
			count_x <= 32'd0;
			count_y <= 32'd0;
			x <= 9'd0;
			y <= 8'd0;
			color <= 3'b111;
			
			// player moves
			p1_move <= 2'd0;
			p2_move <= 2'd0;
			
		end
		else
		begin		
			case(S)
				INIT:
				begin
					// initializing variables
					valid <= 1'b0;
					user <= default_player;
					outcome <= in_progress;
				
					// default colors for board
					A1_color <= default_color;
					A2_color <= default_color;
					A3_color <= default_color;
					B1_color <= default_color;
					B2_color <= default_color;
					B3_color <= default_color;
					C1_color <= default_color;
					C2_color <= default_color;
					C3_color <= default_color;
					
					// default values for grid squares
					grid_A1 <= default_player;
					grid_A2 <= default_player;
					grid_A3 <= default_player;
					grid_B1 <= default_player;
					grid_B2 <= default_player;
					grid_B3 <= default_player;
					grid_C1 <= default_player;
					grid_C2 <= default_player;
					grid_C3 <= default_player;
					
					// vga variables
					count_x <= 32'd0;
					count_y <= 32'd0;
					x <= 9'd0;
					y <= 8'd0;
					color <= 3'b111;
					
					// player moves
					p1_move <= 2'd0;
					p2_move <= 2'd0;
				end
				
				// background
				BACK_START:
				begin
					count_x <= 32'd0;
					count_y <= 32'd0;
				end
				BACK_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd0;
				end
				BACK_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				BACK_DRAW:
				begin
					color <= back_color;
					x <= count_x;
					y <= count_y;
				end
				
				// A1
				A1_START:
				begin
					count_x <= 32'd0;
					count_y <= 32'd0;
				end
				A1_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd0;
				end
				A1_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				A1_DRAW:
				begin
					color <= A1_color;
					x <= count_x;
					y <= count_y;
				end
				
				// A2
				A2_START:
				begin
					count_x <= 32'd109;
					count_y <= 32'd0;
				end
				A2_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd109;
				end
				A2_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				A2_DRAW:
				begin
					color <= A2_color;
					x <= count_x;
					y <= count_y;
				end
				
				// A3
				A3_START:
				begin
					count_x <= 32'd216;
					count_y <= 32'd0;
				end
				A3_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd216;
				end
				A3_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				A3_DRAW:
				begin
					color <= A3_color;
					x <= count_x;
					y <= count_y;
				end
				
				// B1
				B1_START:
				begin
					count_x <= 32'd0;
					count_y <= 32'd82;
				end
				B1_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd0;
				end
				B1_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				B1_DRAW:
				begin
					color <= B1_color;
					x <= count_x;
					y <= count_y;
				end
				
				// B2
				B2_START:
				begin
					count_x <= 32'd109;
					count_y <= 32'd82;
				end
				B2_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd109;
				end
				B2_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				B2_DRAW:
				begin
					color <= B2_color;
					x <= count_x;
					y <= count_y;
				end
				
				// B3
				B3_START:
				begin
					count_x <= 32'd216;
					count_y <= 32'd82;
				end
				B3_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd216;
				end
				B3_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				B3_DRAW:
				begin
					color <= B3_color;
					x <= count_x;
					y <= count_y;
				end
				
				// C1
				C1_START:
				begin
					count_x <= 32'd0;
					count_y <= 32'd163;
				end
				C1_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd0;
				end
				C1_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				C1_DRAW:
				begin
					color <= C1_color;
					x <= count_x;
					y <= count_y;
				end
				
				// C2
				C2_START:
				begin
					count_x <= 32'd109;
					count_y <= 32'd163;
				end
				C2_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd109;
				end
				C2_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				C2_DRAW:
				begin
					color <= C2_color;
					x <= count_x;
					y <= count_y;
				end
				
				// C3
				C3_START:
				begin
					count_x <= 32'd216;
					count_y <= 32'd163;
				end
				C3_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd216;
				end
				C3_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				C3_DRAW:
				begin
					color <= C3_color;
					x <= count_x;
					y <= count_y;
				end
				
				START:
				begin
					valid <= 1'b0;
					user <= default_player;
					outcome <= in_progress;
				end
				P1: 
				begin
					user <= player1;
					valid <= 1'b0;
				end
				GET_MOVE_P1:
				begin
					p1_move <= move;
					p2_move <= 9'd0;
				end
				CHECK_VALIDITY:
				begin
					
					// A1
					if ((p1_move == A1 || p2_move == A1) && (grid_A1 == default_player))
					begin
						valid <= 1'b1;
					end
					else if ((p1_move == A1 || p2_move == A1) && (grid_A1 != default_player))
						valid <= 1'b0;
					
					// A2
					if ((p1_move == A2 || p2_move == A2) && (grid_A2 == default_player))
					begin
						valid <= 1'b1;
					end
					else if ((p1_move == A2 || p2_move == A2) && (grid_A2 != default_player))
						valid <= 1'b0;
						
					// A3
					if ((p1_move == A3 || p2_move == A3) && (grid_A3 == default_player))
					begin
						valid <= 1'b1;
					end
					else if ((p1_move == A3 || p2_move == A3) && (grid_A3 != default_player))
						valid <= 1'b0;
						
					// B1
					if ((p1_move == B1 || p2_move == B1) && (grid_B1 == default_player))
					begin
						valid <= 1'b1;
					end
					else if ((p1_move == B1 || p2_move == B1) && (grid_B2 != default_player))
						valid <= 1'b0;
						
					// B2
					if ((p1_move == B2 || p2_move == B2) && (grid_B2 == default_player))
					begin
						valid <= 1'b1;
					end
					else if ((p1_move == B2 || p2_move == B2) && (grid_B2 != default_player))
						valid <= 1'b0;
						
					// B3
					if ((p1_move == B3 || p2_move == B3) && (grid_B3 == default_player))
					begin
						valid <= 1'b1;
					end
					else if ((p1_move == B3 || p2_move == B3) && (grid_B1 != default_player))
						valid <= 1'b0;
						
					// C1
					if ((p1_move == C1 || p2_move == C1) && (grid_C1 == default_player))
					begin
						valid <= 1'b1;
					end
					else if ((p1_move == C1 || p2_move == C1) && (grid_C1 != default_player))
						valid <= 1'b0;
						
					// C2
					if ((p1_move == C2 || p2_move == C2) && (grid_C2 == default_player))
					begin
						valid <= 1'b1;
					end
					else if ((p1_move == C2 || p2_move == C2) && (grid_C2 != default_player))
						valid <= 1'b0;
						
					// C3
					if ((p1_move == C3 || p2_move == C3) && (grid_C3 == default_player))
					begin
						valid <= 1'b1;
					end
					else if ((p1_move == C3 || p2_move == C3) && (grid_C3 != default_player))
						valid <= 1'b0;
						
				end
				UPDATE_GRID:
				begin
					
					// A1
					if ((p1_move == A1) || (p2_move == A1))
					begin
						grid_A1 <= user;
					end
					
					// A2
					if ((p1_move == A2) || (p2_move == A2)) 
					begin
						grid_A2 <= user;
					end
					
					// A3
					if ((p1_move == A3) || (p2_move == A3))
					begin
						grid_A3 <= user;
					end
					
					// B1
					if ((p1_move == B1) || (p2_move == B1))
					begin
						grid_B1 <= user;
					end
					
					// B2
					if ((p1_move == B2) || (p2_move == B2))
					begin
						grid_B2 <= user;
					end
					
					// B3
					if ((p1_move == B3) || (p2_move == B3))
					begin
						grid_B3 <= user;
					end
					
					// C1
					if ((p1_move == C1) || (p2_move == C1))
					begin
						grid_C1 <= user;
					end
					
					// C2
					if ((p1_move == C2) || (p2_move == C2))
					begin
						grid_C2 <= user;
					end
					
					// C3
					if ((p1_move == C3) || (p2_move == C3))
					begin
						grid_C3 <= user;
					end
				end
				UPDATE_BOARD:
				begin
					p1_move <= 2'd0;
					p2_move <= 2'd0;
					
					// A1
					if (grid_A1 == player1)
					begin
						A1_color <= p1_color;
					end
					else if (grid_A1 == player2)
					begin
						A1_color <= p2_color;
					end
					else
					begin
						A1_color <= default_color;
					end
					
					
					// A2
					if (grid_A2 == player1)
					begin
						A2_color <= p1_color;
					end
					else if (grid_A2 == player2)
					begin
						A2_color <= p2_color;
					end
					else
					begin
						A2_color <= default_color;
					end
					
					// A3
					if (grid_A3 == player1)
					begin
						A3_color <= p1_color;
					end
					else if (grid_A3 == player2)
					begin
						A3_color <= p2_color;
					end
					else
					begin
						A3_color <= default_color;
					end
					
					// B1
					if (grid_B1 == player1)
					begin
						B1_color <= p1_color;
					end
					else if (grid_B1 == player2)
					begin
						B1_color <= p2_color;
					end
					else
					begin
						B1_color <= default_color;
					end
					
					// B2
					if (grid_B2 == player1)
					begin
						B2_color <= p1_color;
					end
					else if (grid_B2 == player2)
					begin
						B2_color <= p2_color;
					end
					else
					begin
						B2_color <= default_color;
					end
					
					// B3
					if (grid_B3 == player1)
					begin
						B3_color <= p1_color;
					end
					else if (grid_B3 == player2)
					begin
						B3_color <= p2_color;
					end
					else
					begin
						B3_color <= default_color;
					end
					
					// C1
					if (grid_C1 == player1)
					begin
						C1_color <= p1_color;
					end
					else if (grid_C1 == player2)
					begin
						C1_color <= p2_color;
					end
					else
					begin
						C1_color <= default_color;
					end
					
					// C2
					if (grid_C2 == player1)
					begin
						C2_color <= p1_color;
					end
					else if (grid_C2 == player2)
					begin
						C2_color <= p2_color;
					end
					else
					begin
						C2_color <= default_color;
					end
					
					// C3
					if (grid_C3 == player1)
					begin
						C3_color <= p1_color;
					end
					else if (grid_C3 == player2)
					begin
						C3_color <= p2_color;
					end
					else
					begin
						C3_color <= default_color;
					end
					
				end
				
				// A1 redraw
				RE_A1_START:
				begin
					count_x <= 32'd0;
					count_y <= 32'd0;
				end
				RE_A1_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd0;
				end
				RE_A1_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				RE_A1_DRAW:
				begin
					color <= A1_color;
					x <= count_x;
					y <= count_y;
				end
				
				// A2 redraw
				RE_A2_START:
				begin
					count_x <= 32'd109;
					count_y <= 32'd0;
				end
				RE_A2_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd109;
				end
				RE_A2_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				RE_A2_DRAW:
				begin
					color <= A2_color;
					x <= count_x;
					y <= count_y;
				end
				
				// A3 redraw
				RE_A3_START:
				begin
					count_x <= 32'd216;
					count_y <= 32'd0;
				end
				RE_A3_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd216;
				end
				RE_A3_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				RE_A3_DRAW:
				begin
					color <= A3_color;
					x <= count_x;
					y <= count_y;
				end
				
				// B1 redraw
				RE_B1_START:
				begin
					count_x <= 32'd0;
					count_y <= 32'd82;
				end
				RE_B1_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd0;
				end
				RE_B1_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				RE_B1_DRAW:
				begin
					color <= B1_color;
					x <= count_x;
					y <= count_y;
				end
				
				// B2 redraw
				RE_B2_START:
				begin
					count_x <= 32'd109;
					count_y <= 32'd82;
				end
				RE_B2_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd109;
				end
				RE_B2_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				RE_B2_DRAW:
				begin
					color <= B2_color;
					x <= count_x;
					y <= count_y;
				end
				
				// B3 redraw
				RE_B3_START:
				begin
					count_x <= 32'd216;
					count_y <= 32'd82;
				end
				RE_B3_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd216;
				end
				RE_B3_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				RE_B3_DRAW:
				begin
					color <= B3_color;
					x <= count_x;
					y <= count_y;
				end
				
				// C1 redraw
				RE_C1_START:
				begin
					count_x <= 32'd0;
					count_y <= 32'd163;
				end
				RE_C1_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd0;
				end
				RE_C1_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				RE_C1_DRAW:
				begin
					color <= C1_color;
					x <= count_x;
					y <= count_y;
				end
				
				// C2 redraw
				RE_C2_START:
				begin
					count_x <= 32'd109;
					count_y <= 32'd163;
				end
				RE_C2_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd109;
				end
				RE_C2_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				RE_C2_DRAW:
				begin
					color <= C2_color;
					x <= count_x;
					y <= count_y;
				end
				
				// C3 redraw
				RE_C3_START:
				begin
					count_x <= 32'd216;
					count_y <= 32'd163;
				end
				RE_C3_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd216;
				end
				RE_C3_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				RE_C3_DRAW:
				begin
					color <= C3_color;
					x <= count_x;
					y <= count_y;
				end
				
				CHECK_OUTCOME:
				begin
					
					// Horizontal A row
					if ((grid_A1 == grid_A2) && (grid_A2 == grid_A3) && (grid_A3 != 2'b00))
					begin
						if (grid_A1 == 2'b01)
							outcome <= p1_win;
						else if (grid_A1 == 2'b10)
							outcome <= p1_lose;
					end
					
					// Horizontal B row
					else if ((grid_B1 == grid_B2) && (grid_B2 == grid_B3) && (grid_B3 != 2'b00))
					begin
						if (grid_B1 == 2'b01)
							outcome <= p1_win;
						else if (grid_B1 == 2'b10)
							outcome <= p1_lose;
					end
					
					// Horizontal C row
					else if ((grid_C1 == grid_C2) && (grid_C2 == grid_C3) && (grid_C3 != 2'b00))
					begin
						if (grid_C1 == 2'b01)
							outcome <= p1_win;
						else if (grid_C1 == 2'b10)
							outcome <= p1_lose;
					end
					
					// Vertical 1 column
					else if ((grid_A1 == grid_B1) && (grid_B1 == grid_C1) && (grid_C1 != 2'b00))
					begin
						if (grid_A1 == 2'b01)
							outcome <= p1_win;
						else if (grid_A1 == 2'b10)
							outcome <= p1_lose;
					end
					
					// Vertical 2 column
					else if ((grid_A2 == grid_B2) && (grid_B2 == grid_C2) && (grid_C2 != 2'b00))
					begin
						if (grid_A2 == 2'b01)
							outcome <= p1_win;
						else if (grid_A2 == 2'b10)
							outcome <= p1_lose;
					end
					
					// Vertical 3 column
					else if ((grid_A3 == grid_B3) && (grid_B3 == grid_C3) && (grid_C3 != 2'b00))
					begin
						if (grid_A3 == 2'b01)
							outcome <= p1_win;
						else if (grid_A3 == 2'b10)
							outcome <= p1_lose;
					end
					
					// Negative slope diagonal
					else if ((grid_A1 == grid_B2) && (grid_B2 == grid_C3) && (grid_C3 != 2'b00))
					begin
						if (grid_A1 == 2'b01)
							outcome <= p1_win;
						else if (grid_A1 == 2'b10)
							outcome <= p1_lose;
					end
					
					// Positive slope diagonal
					else if ((grid_A3 == grid_B2) && (grid_B2 == grid_C1) && (grid_C1 != 2'b00))
					begin
						if (grid_A3 == 2'b01)
							outcome <= p1_win;
						else if (grid_A3 == 2'b10)
							outcome <= p1_lose;
					end
					
					// non win cases
					else if ((grid_A1[0]||grid_A1[1])&&(grid_A2[0]||grid_A2[1])&&(grid_A3[0]||grid_A3[1])&&(grid_B1[0]||grid_B1[1])&&(grid_B2[0]||grid_B2[1])&&(grid_B3[0]||grid_B3[1])&&(grid_C1[0]||grid_C1[1])&&(grid_C2[0]||grid_C2[1])&&(grid_C3[0]||grid_C3[1]))
					begin
						outcome <= tie;
						user <= default_player; // added to change display to 0 if tie
					end
					else
						outcome <= in_progress;
				
				end
				P2:
				begin
					user <= player2;
					valid <= 1'b0;
					
				end
				GET_MOVE_AI:
				begin
					p2_move <= AI_move;
					p1_move <= 9'd0;
				end
				GET_MOVE_P2:
				begin
					p2_move <= move;
					p1_move <= 9'd0;
				end
				END:
				begin
				end
				
				// display win
				WIN_START:
				begin
					count_x <= 32'd0;
					count_y <= 32'd0;
				end
				WIN_UPDATE_Y:
				begin
					count_y <= count_y + 32'd1;
					count_x <= 32'd0;
				end
				WIN_UPDATE_X:
				begin
					count_x <= count_x + 32'd1;
				end
				WIN_DRAW:
				begin
					if (outcome == p1_win)
						color <= p1_color;
					else if (outcome == p1_lose)
						color <= p2_color;
					else
						color <= default_color;
						
					x <= count_x;
					y <= count_y;
				end
				
				ERROR:
				begin
				end
				default:
				begin
				end
			endcase
		end
	end
				
endmodule


/* VGA Adapter
 * ----------------
 *
 * This is an implementation of a VGA Adapter. The adapter uses VGA mode signalling to initiate
 * a 640x480 resolution mode on a computer monitor, with a refresh rate of approximately 60Hz.
 * It is designed for easy use in an early digital logic design course to facilitate student
 * projects on the Altera DE2 Educational board.
 *
 * This implementation of the VGA adapter can display images of varying colour depth at a resolution of
 * 320x240 or 160x120 superpixels. The concept of superpixels is introduced to reduce the amount of on-chip
 * memory used by the adapter. The following table shows the number of bits of on-chip memory used by
 * the adapter in various resolutions and colour depths.
 * 
 * -------------------------------------------------------------------------------------------------------------------------------
 * Resolution | Mono    | 8 colours | 64 colours | 512 colours | 4096 colours | 32768 colours | 262144 colours | 2097152 colours |
 * -------------------------------------------------------------------------------------------------------------------------------
 * 160x120    |   19200 |     57600 |     115200 |      172800 |       230400 |        288000 |         345600 |          403200 |
 * 320x240    |   78600 |    230400 | ############## Does not fit ############################################################## |
 * -------------------------------------------------------------------------------------------------------------------------------
 *
 * By default the adapter works at the resolution of 320x240 with 8 colours. To set the adapter in any of
 * the other modes, the adapter must be instantiated with specific parameters. These parameters are:
 * - RESOLUTION - a string that should be either "320x240" or "160x120".
 * - MONOCHROME - a string that should be "TRUE" if you only want black and white colours, and "FALSE"
 *                otherwise.
 * - BITS_PER_COLOUR_CHANNEL  - an integer specifying how many bits are available to describe each colour
 *                          (R,G,B). A default value of 1 indicates that 1 bit will be used for red
 *                          channel, 1 for green channel and 1 for blue channel. This allows 8 colours
 *                          to be used.
 * 
 * In addition to the above parameters, a BACKGROUND_IMAGE parameter can be specified. The parameter
 * refers to a memory initilization file (MIF) which contains the initial contents of video memory.
 * By specifying the initial contents of the memory we can force the adapter to initially display an
 * image of our choice. Please note that the image described by the BACKGROUND_IMAGE file will only
 * be valid right after your program the DE2 board. If your circuit draws a single pixel on the screen,
 * the video memory will be altered and screen contents will be changed. In order to restore the background
 * image your circuti will have to redraw the background image pixel by pixel, or you will have to
 * reprogram the DE2 board, thus allowing the video memory to be rewritten.
 *
 * To use the module connect the vga_adapter to your circuit. Your circuit should produce a value for
 * inputs X, Y and plot. When plot is high, at the next positive edge of the input clock the vga_adapter
 * will change the contents of the video memory for the pixel at location (X,Y). At the next redraw
 * cycle the VGA controller will update the contants of the screen by reading the video memory and copying
 * it over to the screen. Since the monitor screen has no memory, the VGA controller has to copy the
 * contents of the video memory to the screen once every 60th of a second to keep the image stable. Thus,
 * the video memory should not be used for other purposes as it may interfere with the operation of the
 * VGA Adapter.
 *
 * As a final note, ensure that the following conditions are met when using this module:
 * 1. You are implementing the the VGA Adapter on the Altera DE2 board. Using another board may change
 *    the amount of memory you can use, the clock generation mechanism, as well as pin assignments required
 *    to properly drive the VGA digital-to-analog converter.
 * 2. Outputs VGA_* should exist in your top level design. They should be assigned pin locations on the
 *    Altera DE2 board as specified by the DE2_pin_assignments.csv file.
 * 3. The input clock must have a frequency of 50 MHz with a 50% duty cycle. On the Altera DE2 board
 *    PIN_N2 is the source for the 50MHz clock.
 *
 * During compilation with Quartus II you may receive the following warnings:
 * - Warning: Variable or input pin "clocken1" is defined but never used
 * - Warning: Pin "VGA_SYNC" stuck at VCC
 * - Warning: Found xx output pins without output pin load capacitance assignment
 * These warnings can be ignored. The first warning is generated, because the software generated
 * memory module contains an input called "clocken1" and it does not drive logic. The second warning
 * indicates that the VGA_SYNC signal is always high. This is intentional. The final warning is
 * generated for the purposes of power analysis. It will persist unless the output pins are assigned
 * output capacitance. Leaving the capacitance values at 0 pf did not affect the operation of the module.
 *
 * If you see any other warnings relating to the vga_adapter, be sure to examine them carefully. They may
 * cause your circuit to malfunction.
 *
 * NOTES/REVISIONS:
 * July 10, 2007 - Modified the original version of the VGA Adapter written by Sam Vafaee in 2006. The module
 *		   now supports 2 different resolutions as well as uses half the memory compared to prior
 *		   implementation. Also, all settings for the module can be specified from the point
 *		   of instantiation, rather than by modifying the source code. (Tomasz S. Czajkowski)
 */

module vga_adapter(
			resetn,
			clock,
			colour,
			x, y, plot,
			/* Signals for the DAC to drive the monitor. */
			VGA_R,
			VGA_G,
			VGA_B,
			VGA_HS,
			VGA_VS,
			VGA_BLANK,
			VGA_SYNC,
			VGA_CLK);
 
	parameter BITS_PER_COLOUR_CHANNEL = 1;
	/* The number of bits per colour channel used to represent the colour of each pixel. A value
	 * of 1 means that Red, Green and Blue colour channels will use 1 bit each to represent the intensity
	 * of the respective colour channel. For BITS_PER_COLOUR_CHANNEL=1, the adapter can display 8 colours.
	 * In general, the adapter is able to use 2^(3*BITS_PER_COLOUR_CHANNEL ) colours. The number of colours is
	 * limited by the screen resolution and the amount of on-chip memory available on the target device.
	 */	
	
	parameter MONOCHROME = "FALSE";
	/* Set this parameter to "TRUE" if you only wish to use black and white colours. Doing so will reduce
	 * the amount of memory you will use by a factor of 3. */
	
	parameter RESOLUTION = "320x240";
	/* Set this parameter to "160x120" or "320x240". It will cause the VGA adapter to draw each dot on
	 * the screen by using a block of 4x4 pixels ("160x120" resolution) or 2x2 pixels ("320x240" resolution).
	 * It effectively reduces the screen resolution to an integer fraction of 640x480. It was necessary
	 * to reduce the resolution for the Video Memory to fit within the on-chip memory limits.
	 */
	
	parameter BACKGROUND_IMAGE = "background.mif";
	/* The initial screen displayed when the circuit is first programmed onto the DE2 board can be
	 * defined useing an MIF file. The file contains the initial colour for each pixel on the screen
	 * and is placed in the Video Memory (VideoMemory module) upon programming. Note that resetting the
	 * VGA Adapter will not cause the Video Memory to revert to the specified image. */


	/*****************************************************************************/
	/* Declare inputs and outputs.                                               */
	/*****************************************************************************/
	input resetn;
	input clock;
	
	/* The colour input can be either 1 bit or 3*BITS_PER_COLOUR_CHANNEL bits wide, depending on
	 * the setting of the MONOCHROME parameter.
	 */
	input [((MONOCHROME == "TRUE") ? (0) : (BITS_PER_COLOUR_CHANNEL*3-1)):0] colour;
	
	/* Specify the number of bits required to represent an (X,Y) coordinate on the screen for
	 * a given resolution.
	 */
	input [((RESOLUTION == "320x240") ? (8) : (7)):0] x; 
	input [((RESOLUTION == "320x240") ? (7) : (6)):0] y;
	
	/* When plot is high then at the next positive edge of the clock the pixel at (x,y) will change to
	 * a new colour, defined by the value of the colour input.
	 */
	input plot;
	
	/* These outputs drive the VGA display. The VGA_CLK is also used to clock the FSM responsible for
	 * controlling the data transferred to the DAC driving the monitor. */
	output [9:0] VGA_R;
	output [9:0] VGA_G;
	output [9:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK;
	output VGA_SYNC;
	output VGA_CLK;

	/*****************************************************************************/
	/* Declare local signals here.                                               */
	/*****************************************************************************/
	
	wire valid_160x120;
	wire valid_320x240;
	/* Set to 1 if the specified coordinates are in a valid range for a given resolution.*/
	
	wire writeEn;
	/* This is a local signal that allows the Video Memory contents to be changed.
	 * It depends on the screen resolution, the values of X and Y inputs, as well as 
	 * the state of the plot signal.
	 */
	
	wire [((MONOCHROME == "TRUE") ? (0) : (BITS_PER_COLOUR_CHANNEL*3-1)):0] to_ctrl_colour;
	/* Pixel colour read by the VGA controller */
	
	wire [((RESOLUTION == "320x240") ? (16) : (14)):0] user_to_video_memory_addr;
	/* This bus specifies the address in memory the user must write
	 * data to in order for the pixel intended to appear at location (X,Y) to be displayed
	 * at the correct location on the screen.
	 */
	
	wire [((RESOLUTION == "320x240") ? (16) : (14)):0] controller_to_video_memory_addr;
	/* This bus specifies the address in memory the vga controller must read data from
	 * in order to determine the colour of a pixel located at coordinate (X,Y) of the screen.
	 */
	
	wire clock_25;
	/* 25MHz clock generated by dividing the input clock frequency by 2. */
	
	wire vcc, gnd;
	
	/*****************************************************************************/
	/* Instances of modules for the VGA adapter.                                 */
	/*****************************************************************************/	
	assign vcc = 1'b1;
	assign gnd = 1'b0;
	
	vga_address_translator user_input_translator(
					.x(x), .y(y), .mem_address(user_to_video_memory_addr) );
		defparam user_input_translator.RESOLUTION = RESOLUTION;
	/* Convert user coordinates into a memory address. */

	assign valid_160x120 = (({1'b0, x} >= 0) & ({1'b0, x} < 160) & ({1'b0, y} >= 0) & ({1'b0, y} < 120)) & (RESOLUTION == "160x120");
	assign valid_320x240 = (({1'b0, x} >= 0) & ({1'b0, x} < 320) & ({1'b0, y} >= 0) & ({1'b0, y} < 240)) & (RESOLUTION == "320x240");
	assign writeEn = (plot) & (valid_160x120 | valid_320x240);
	/* Allow the user to plot a pixel if and only if the (X,Y) coordinates supplied are in a valid range. */
	
	/* Create video memory. */
	altsyncram	VideoMemory (
				.wren_a (writeEn),
				.wren_b (gnd),
				.clock0 (clock), // write clock
				.clock1 (clock_25), // read clock
				.clocken0 (vcc), // write enable clock
				.clocken1 (vcc), // read enable clock				
				.address_a (user_to_video_memory_addr),
				.address_b (controller_to_video_memory_addr),
				.data_a (colour), // data in
				.q_b (to_ctrl_colour)	// data out
				);
	defparam
		VideoMemory.WIDTH_A = ((MONOCHROME == "FALSE") ? (BITS_PER_COLOUR_CHANNEL*3) : 1),
		VideoMemory.WIDTH_B = ((MONOCHROME == "FALSE") ? (BITS_PER_COLOUR_CHANNEL*3) : 1),
		VideoMemory.INTENDED_DEVICE_FAMILY = "Cyclone II",
		VideoMemory.OPERATION_MODE = "DUAL_PORT",
		VideoMemory.WIDTHAD_A = ((RESOLUTION == "320x240") ? (17) : (15)),
		VideoMemory.NUMWORDS_A = ((RESOLUTION == "320x240") ? (76800) : (19200)),
		VideoMemory.WIDTHAD_B = ((RESOLUTION == "320x240") ? (17) : (15)),
		VideoMemory.NUMWORDS_B = ((RESOLUTION == "320x240") ? (76800) : (19200)),
		VideoMemory.OUTDATA_REG_B = "CLOCK1",
		VideoMemory.ADDRESS_REG_B = "CLOCK1",
		VideoMemory.CLOCK_ENABLE_INPUT_A = "BYPASS",
		VideoMemory.CLOCK_ENABLE_INPUT_B = "BYPASS",
		VideoMemory.CLOCK_ENABLE_OUTPUT_B = "BYPASS",
		VideoMemory.POWER_UP_UNINITIALIZED = "FALSE",
		VideoMemory.INIT_FILE = BACKGROUND_IMAGE;
		
	vga_pll mypll(clock, clock_25);
	/* This module generates a clock with half the frequency of the input clock.
	 * For the VGA adapter to operate correctly the clock signal 'clock' must be
	 * a 50MHz clock. The derived clock, which will then operate at 25MHz, is
	 * required to set the monitor into the 640x480@60Hz display mode (also known as
	 * the VGA mode).
	 */
	
	vga_controller controller(
			.vga_clock(clock_25),
			.resetn(resetn),
			.pixel_colour(to_ctrl_colour),
			.memory_address(controller_to_video_memory_addr), 
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK)				
		);
		defparam controller.BITS_PER_COLOUR_CHANNEL  = BITS_PER_COLOUR_CHANNEL ;
		defparam controller.MONOCHROME = MONOCHROME;
		defparam controller.RESOLUTION = RESOLUTION;

endmodule
	


/* This module converts a user specified coordinates into a memory address.
 * The output of the module depends on the resolution set by the user.
 */
module vga_address_translator(x, y, mem_address);

	parameter RESOLUTION = "320x240";
	/* Set this parameter to "160x120" or "320x240". It will cause the VGA adapter to draw each dot on
	 * the screen by using a block of 4x4 pixels ("160x120" resolution) or 2x2 pixels ("320x240" resolution).
	 * It effectively reduces the screen resolution to an integer fraction of 640x480. It was necessary
	 * to reduce the resolution for the Video Memory to fit within the on-chip memory limits.
	 */

	input [((RESOLUTION == "320x240") ? (8) : (7)):0] x; 
	input [((RESOLUTION == "320x240") ? (7) : (6)):0] y;	
	output reg [((RESOLUTION == "320x240") ? (16) : (14)):0] mem_address;
	
	/* The basic formula is address = y*WIDTH + x;
	 * For 320x240 resolution we can write 320 as (256 + 64). Memory address becomes
	 * (y*256) + (y*64) + x;
	 * This simplifies multiplication a simple shift and add operation.
	 * A leading 0 bit is added to each operand to ensure that they are treated as unsigned
	 * inputs. By default the use a '+' operator will generate a signed adder.
	 * Similarly, for 160x120 resolution we write 160 as 128+32.
	 */
	wire [16:0] res_320x240 = ({1'b0, y, 8'd0} + {1'b0, y, 6'd0} + {1'b0, x});
	wire [15:0] res_160x120 = ({1'b0, y, 7'd0} + {1'b0, y, 5'd0} + {1'b0, x});
	
	always @(*)
	begin
		if (RESOLUTION == "320x240")
			mem_address = res_320x240;
		else
			mem_address = res_160x120[14:0];
	end
endmodule



/* This module implements the VGA controller. It assumes a 25MHz clock is supplied as input.
 *
 * General approach:
 * Go through each line of the screen and read the colour each pixel on that line should have from
 * the Video memory. To do that for each (x,y) pixel on the screen convert (x,y) coordinate to
 * a memory_address at which the pixel colour is stored in Video memory. Once the pixel colour is
 * read from video memory its brightness is first increased before it is forwarded to the VGA DAC.
 */
module vga_controller(	vga_clock, resetn, pixel_colour, memory_address, 
		VGA_R, VGA_G, VGA_B,
		VGA_HS, VGA_VS, VGA_BLANK,
		VGA_SYNC, VGA_CLK);
	
	/* Screen resolution and colour depth parameters. */
	
	parameter BITS_PER_COLOUR_CHANNEL = 1;
	/* The number of bits per colour channel used to represent the colour of each pixel. A value
	 * of 1 means that Red, Green and Blue colour channels will use 1 bit each to represent the intensity
	 * of the respective colour channel. For BITS_PER_COLOUR_CHANNEL=1, the adapter can display 8 colours.
	 * In general, the adapter is able to use 2^(3*BITS_PER_COLOUR_CHANNEL) colours. The number of colours is
	 * limited by the screen resolution and the amount of on-chip memory available on the target device.
	 */	
	
	parameter MONOCHROME = "FALSE";
	/* Set this parameter to "TRUE" if you only wish to use black and white colours. Doing so will reduce
	 * the amount of memory you will use by a factor of 3. */
	
	parameter RESOLUTION = "320x240";
	/* Set this parameter to "160x120" or "320x240". It will cause the VGA adapter to draw each dot on
	 * the screen by using a block of 4x4 pixels ("160x120" resolution) or 2x2 pixels ("320x240" resolution).
	 * It effectively reduces the screen resolution to an integer fraction of 640x480. It was necessary
	 * to reduce the resolution for the Video Memory to fit within the on-chip memory limits.
	 */
	
	//--- Timing parameters.
	/* Recall that the VGA specification requires a few more rows and columns are drawn
	 * when refreshing the screen than are actually present on the screen. This is necessary to
	 * generate the vertical and the horizontal syncronization signals. If you wish to use a
	 * display mode other than 640x480 you will need to modify the parameters below as well
	 * as change the frequency of the clock driving the monitor (VGA_CLK).
	 */
	parameter C_VERT_NUM_PIXELS  = 10'd480;
	parameter C_VERT_SYNC_START  = 10'd493;
	parameter C_VERT_SYNC_END    = 10'd494; //(C_VERT_SYNC_START + 2 - 1); 
	parameter C_VERT_TOTAL_COUNT = 10'd525;

	parameter C_HORZ_NUM_PIXELS  = 10'd640;
	parameter C_HORZ_SYNC_START  = 10'd659;
	parameter C_HORZ_SYNC_END    = 10'd754; //(C_HORZ_SYNC_START + 96 - 1); 
	parameter C_HORZ_TOTAL_COUNT = 10'd800;	
		
	/*****************************************************************************/
	/* Declare inputs and outputs.                                               */
	/*****************************************************************************/
	
	input vga_clock, resetn;
	input [((MONOCHROME == "TRUE") ? (0) : (BITS_PER_COLOUR_CHANNEL*3-1)):0] pixel_colour;
	output [((RESOLUTION == "320x240") ? (16) : (14)):0] memory_address;
	output reg [9:0] VGA_R;
	output reg [9:0] VGA_G;
	output reg [9:0] VGA_B;
	output reg VGA_HS;
	output reg VGA_VS;
	output reg VGA_BLANK;
	output VGA_SYNC, VGA_CLK;
	
	/*****************************************************************************/
	/* Local Signals.                                                            */
	/*****************************************************************************/
	
	reg VGA_HS1;
	reg VGA_VS1;
	reg VGA_BLANK1; 
	reg [9:0] xCounter, yCounter;
	wire xCounter_clear;
	wire yCounter_clear;
	wire vcc;
	
	reg [((RESOLUTION == "320x240") ? (8) : (7)):0] x; 
	reg [((RESOLUTION == "320x240") ? (7) : (6)):0] y;	
	/* Inputs to the converter. */
	
	/*****************************************************************************/
	/* Controller implementation.                                                */
	/*****************************************************************************/

	assign vcc =1'b1;
	
	/* A counter to scan through a horizontal line. */
	always @(posedge vga_clock or negedge resetn)
	begin
		if (!resetn)
			xCounter <= 10'd0;
		else if (xCounter_clear)
			xCounter <= 10'd0;
		else
		begin
			xCounter <= xCounter + 1'b1;
		end
	end
	assign xCounter_clear = (xCounter == (C_HORZ_TOTAL_COUNT-1));

	/* A counter to scan vertically, indicating the row currently being drawn. */
	always @(posedge vga_clock or negedge resetn)
	begin
		if (!resetn)
			yCounter <= 10'd0;
		else if (xCounter_clear && yCounter_clear)
			yCounter <= 10'd0;
		else if (xCounter_clear)		//Increment when x counter resets
			yCounter <= yCounter + 1'b1;
	end
	assign yCounter_clear = (yCounter == (C_VERT_TOTAL_COUNT-1)); 
	
	/* Convert the xCounter/yCounter location from screen pixels (640x480) to our
	 * local dots (320x240 or 160x120). Here we effectively divide x/y coordinate by 2 or 4,
	 * depending on the resolution. */
	always @(*)
	begin
		if (RESOLUTION == "320x240")
		begin
			x = xCounter[9:1];
			y = yCounter[8:1];
		end
		else
		begin
			x = xCounter[9:2];
			y = yCounter[8:2];
		end
	end
	
	/* Change the (x,y) coordinate into a memory address. */
	vga_address_translator controller_translator(
					.x(x), .y(y), .mem_address(memory_address) );
		defparam controller_translator.RESOLUTION = RESOLUTION;


	/* Generate the vertical and horizontal synchronization pulses. */
	always @(posedge vga_clock)
	begin
		//- Sync Generator (ACTIVE LOW)
		VGA_HS1 <= ~((xCounter >= C_HORZ_SYNC_START) && (xCounter <= C_HORZ_SYNC_END));
		VGA_VS1 <= ~((yCounter >= C_VERT_SYNC_START) && (yCounter <= C_VERT_SYNC_END));
		
		//- Current X and Y is valid pixel range
		VGA_BLANK1 <= ((xCounter < C_HORZ_NUM_PIXELS) && (yCounter < C_VERT_NUM_PIXELS));	
	
		//- Add 1 cycle delay
		VGA_HS <= VGA_HS1;
		VGA_VS <= VGA_VS1;
		VGA_BLANK <= VGA_BLANK1;	
	end
	
	/* VGA sync should be 1 at all times. */
	assign VGA_SYNC = vcc;
	
	/* Generate the VGA clock signal. */
	assign VGA_CLK = vga_clock;
	
	/* Brighten the colour output. */
	// The colour input is first processed to brighten the image a little. Setting the top
	// bits to correspond to the R,G,B colour makes the image a bit dull. To brighten the image,
	// each bit of the colour is replicated through the 10 DAC colour input bits. For example,
	// when BITS_PER_COLOUR_CHANNEL is 2 and the red component is set to 2'b10, then the
	// VGA_R input to the DAC will be set to 10'b1010101010.
	
	integer index;
	integer sub_index;
	
	always @(pixel_colour)
	begin		
		VGA_R <= 'b0;
		VGA_G <= 'b0;
		VGA_B <= 'b0;
		if (MONOCHROME == "FALSE")
		begin
			for (index = 10-BITS_PER_COLOUR_CHANNEL; index >= 0; index = index - BITS_PER_COLOUR_CHANNEL)
			begin
				for (sub_index = BITS_PER_COLOUR_CHANNEL - 1; sub_index >= 0; sub_index = sub_index - 1)
				begin
					VGA_R[sub_index+index] <= pixel_colour[sub_index + BITS_PER_COLOUR_CHANNEL*2];
					VGA_G[sub_index+index] <= pixel_colour[sub_index + BITS_PER_COLOUR_CHANNEL];
					VGA_B[sub_index+index] <= pixel_colour[sub_index];
				end
			end	
		end
		else
		begin
			for (index = 0; index < 10; index = index + 1)
			begin
				VGA_R[index] <= pixel_colour[0:0];
				VGA_G[index] <= pixel_colour[0:0];
				VGA_B[index] <= pixel_colour[0:0];
			end	
		end
	end

endmodule


// megafunction wizard: %ALTPLL%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: altpll 

// ============================================================
// File Name: VgaPll.v
// Megafunction Name(s):
// 			altpll
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 5.0 Build 168 06/22/2005 SP 1 SJ Full Version
// ************************************************************


//Copyright (C) 1991-2005 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic       
//functions, and any output files any of the foregoing           
//(including device programming or simulation files), and any    
//associated documentation or information are expressly subject  
//to the terms and conditions of the Altera Program License      
//Subscription Agreement, Altera MegaCore Function License       
//Agreement, or other applicable license agreement, including,   
//without limitation, that your use is for the sole purpose of   
//programming logic devices manufactured by Altera and sold by   
//Altera or its authorized distributors.  Please refer to the    
//applicable agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module vga_pll (
	clock_in,
	clock_out);

	input	  clock_in;
	output	  clock_out;

	wire [5:0] clock_output_bus;
	wire [1:0] clock_input_bus;
	wire gnd;
	
	assign gnd = 1'b0;
	assign clock_input_bus = { gnd, clock_in }; 

	altpll	altpll_component (
				.inclk (clock_input_bus),
				.clk (clock_output_bus)
				);
	defparam
		altpll_component.operation_mode = "NORMAL",
		altpll_component.intended_device_family = "Cyclone II",
		altpll_component.lpm_type = "altpll",
		altpll_component.pll_type = "FAST",
		/* Specify the input clock to be a 50MHz clock. A 50 MHz clock is present
		 * on PIN_N2 on the DE2 board. We need to specify the input clock frequency
		 * in order to set up the PLL correctly. To do this we must put the input clock
		 * period measured in picoseconds in the inclk0_input_frequency parameter.
		 * 1/(20000 ps) = 0.5 * 10^(5) Hz = 50 * 10^(6) Hz = 50 MHz. */
		altpll_component.inclk0_input_frequency = 20000,
		altpll_component.primary_clock = "INCLK0",
		/* Specify output clock parameters. The output clock should have a
		 * frequency of 25 MHz, with 50% duty cycle. */
		altpll_component.compensate_clock = "CLK0",
		altpll_component.clk0_phase_shift = "0",
		altpll_component.clk0_divide_by = 2,
		altpll_component.clk0_multiply_by = 1,		
		altpll_component.clk0_duty_cycle = 50;
		
	assign clock_out = clock_output_bus[0];

endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: MIRROR_CLK0 STRING "0"
// Retrieval info: PRIVATE: PHASE_SHIFT_UNIT0 STRING "deg"
// Retrieval info: PRIVATE: OUTPUT_FREQ_UNIT0 STRING "MHz"
// Retrieval info: PRIVATE: INCLK1_FREQ_UNIT_COMBO STRING "MHz"
// Retrieval info: PRIVATE: SPREAD_USE STRING "0"
// Retrieval info: PRIVATE: SPREAD_FEATURE_ENABLED STRING "0"
// Retrieval info: PRIVATE: GLOCKED_COUNTER_EDIT_CHANGED STRING "1"
// Retrieval info: PRIVATE: GLOCK_COUNTER_EDIT NUMERIC "1048575"
// Retrieval info: PRIVATE: SRC_SYNCH_COMP_RADIO STRING "0"
// Retrieval info: PRIVATE: DUTY_CYCLE0 STRING "50.00000000"
// Retrieval info: PRIVATE: PHASE_SHIFT0 STRING "0.00000000"
// Retrieval info: PRIVATE: MULT_FACTOR0 NUMERIC "1"
// Retrieval info: PRIVATE: OUTPUT_FREQ_MODE0 STRING "1"
// Retrieval info: PRIVATE: SPREAD_PERCENT STRING "0.500"
// Retrieval info: PRIVATE: LOCKED_OUTPUT_CHECK STRING "0"
// Retrieval info: PRIVATE: PLL_ARESET_CHECK STRING "0"
// Retrieval info: PRIVATE: STICKY_CLK0 STRING "1"
// Retrieval info: PRIVATE: BANDWIDTH STRING "1.000"
// Retrieval info: PRIVATE: BANDWIDTH_USE_CUSTOM STRING "0"
// Retrieval info: PRIVATE: DEVICE_SPEED_GRADE STRING "Any"
// Retrieval info: PRIVATE: SPREAD_FREQ STRING "50.000"
// Retrieval info: PRIVATE: BANDWIDTH_FEATURE_ENABLED STRING "0"
// Retrieval info: PRIVATE: LONG_SCAN_RADIO STRING "1"
// Retrieval info: PRIVATE: PLL_ENHPLL_CHECK NUMERIC "0"
// Retrieval info: PRIVATE: LVDS_MODE_DATA_RATE_DIRTY NUMERIC "0"
// Retrieval info: PRIVATE: USE_CLK0 STRING "1"
// Retrieval info: PRIVATE: INCLK1_FREQ_EDIT_CHANGED STRING "1"
// Retrieval info: PRIVATE: SCAN_FEATURE_ENABLED STRING "0"
// Retrieval info: PRIVATE: ZERO_DELAY_RADIO STRING "0"
// Retrieval info: PRIVATE: PLL_PFDENA_CHECK STRING "0"
// Retrieval info: PRIVATE: CREATE_CLKBAD_CHECK STRING "0"
// Retrieval info: PRIVATE: INCLK1_FREQ_EDIT STRING "50.000"
// Retrieval info: PRIVATE: CUR_DEDICATED_CLK STRING "c0"
// Retrieval info: PRIVATE: PLL_FASTPLL_CHECK NUMERIC "0"
// Retrieval info: PRIVATE: ACTIVECLK_CHECK STRING "0"
// Retrieval info: PRIVATE: BANDWIDTH_FREQ_UNIT STRING "MHz"
// Retrieval info: PRIVATE: INCLK0_FREQ_UNIT_COMBO STRING "MHz"
// Retrieval info: PRIVATE: GLOCKED_MODE_CHECK STRING "0"
// Retrieval info: PRIVATE: NORMAL_MODE_RADIO STRING "1"
// Retrieval info: PRIVATE: CUR_FBIN_CLK STRING "e0"
// Retrieval info: PRIVATE: DIV_FACTOR0 NUMERIC "1"
// Retrieval info: PRIVATE: INCLK1_FREQ_UNIT_CHANGED STRING "1"
// Retrieval info: PRIVATE: HAS_MANUAL_SWITCHOVER STRING "1"
// Retrieval info: PRIVATE: EXT_FEEDBACK_RADIO STRING "0"
// Retrieval info: PRIVATE: PLL_AUTOPLL_CHECK NUMERIC "1"
// Retrieval info: PRIVATE: CLKLOSS_CHECK STRING "0"
// Retrieval info: PRIVATE: BANDWIDTH_USE_AUTO STRING "1"
// Retrieval info: PRIVATE: SHORT_SCAN_RADIO STRING "0"
// Retrieval info: PRIVATE: LVDS_MODE_DATA_RATE STRING "Not Available"
// Retrieval info: PRIVATE: CLKSWITCH_CHECK STRING "1"
// Retrieval info: PRIVATE: SPREAD_FREQ_UNIT STRING "KHz"
// Retrieval info: PRIVATE: PLL_ENA_CHECK STRING "0"
// Retrieval info: PRIVATE: INCLK0_FREQ_EDIT STRING "50.000"
// Retrieval info: PRIVATE: CNX_NO_COMPENSATE_RADIO STRING "0"
// Retrieval info: PRIVATE: INT_FEEDBACK__MODE_RADIO STRING "1"
// Retrieval info: PRIVATE: OUTPUT_FREQ0 STRING "25.000"
// Retrieval info: PRIVATE: PRIMARY_CLK_COMBO STRING "inclk0"
// Retrieval info: PRIVATE: CREATE_INCLK1_CHECK STRING "0"
// Retrieval info: PRIVATE: SACN_INPUTS_CHECK STRING "0"
// Retrieval info: PRIVATE: DEV_FAMILY STRING "Cyclone II"
// Retrieval info: PRIVATE: SWITCHOVER_COUNT_EDIT NUMERIC "1"
// Retrieval info: PRIVATE: SWITCHOVER_FEATURE_ENABLED STRING "1"
// Retrieval info: PRIVATE: BANDWIDTH_PRESET STRING "Low"
// Retrieval info: PRIVATE: GLOCKED_FEATURE_ENABLED STRING "1"
// Retrieval info: PRIVATE: USE_CLKENA0 STRING "0"
// Retrieval info: PRIVATE: LVDS_PHASE_SHIFT_UNIT0 STRING "deg"
// Retrieval info: PRIVATE: CLKBAD_SWITCHOVER_CHECK STRING "0"
// Retrieval info: PRIVATE: BANDWIDTH_USE_PRESET STRING "0"
// Retrieval info: PRIVATE: PLL_LVDS_PLL_CHECK NUMERIC "0"
// Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
// Retrieval info: CONSTANT: CLK0_DUTY_CYCLE NUMERIC "50"
// Retrieval info: CONSTANT: LPM_TYPE STRING "altpll"
// Retrieval info: CONSTANT: CLK0_MULTIPLY_BY NUMERIC "1"
// Retrieval info: CONSTANT: INCLK0_INPUT_FREQUENCY NUMERIC "20000"
// Retrieval info: CONSTANT: CLK0_DIVIDE_BY NUMERIC "2"
// Retrieval info: CONSTANT: PLL_TYPE STRING "FAST"
// Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Cyclone II"
// Retrieval info: CONSTANT: OPERATION_MODE STRING "NORMAL"
// Retrieval info: CONSTANT: COMPENSATE_CLOCK STRING "CLK0"
// Retrieval info: CONSTANT: CLK0_PHASE_SHIFT STRING "0"
// Retrieval info: USED_PORT: c0 0 0 0 0 OUTPUT VCC "c0"
// Retrieval info: USED_PORT: @clk 0 0 6 0 OUTPUT VCC "@clk[5..0]"
// Retrieval info: USED_PORT: inclk0 0 0 0 0 INPUT GND "inclk0"
// Retrieval info: USED_PORT: @extclk 0 0 4 0 OUTPUT VCC "@extclk[3..0]"
// Retrieval info: CONNECT: @inclk 0 0 1 0 inclk0 0 0 0 0
// Retrieval info: CONNECT: c0 0 0 0 0 @clk 0 0 1 0
// Retrieval info: CONNECT: @inclk 0 0 1 1 GND 0 0 0 0
// Retrieval info: GEN_FILE: TYPE_NORMAL VgaPll.v TRUE FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL VgaPll.inc FALSE FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL VgaPll.cmp FALSE FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL VgaPll.bsf FALSE FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL VgaPll_inst.v FALSE FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL VgaPll_bb.v FALSE FALSE


module AI_decide(
	input [1:0]grid_A1, grid_A2, grid_A3, grid_B1, grid_B2, grid_B3, grid_C1, grid_C2, grid_C3,
	input AI_en,
	input mode,
	output reg [8:0]AI_move
	);
	
	// Grid:
	//       1    2    3
	//    |----|----|----|
	//    |    |    |    |
	//  A | A1 | A2 | A3 |
	//    |    |    |    |
	//    -----|----|-----
	//    |    |    |    |
	//  B | B1 | B2 | B3 |
	//    |    |    |    |
	//    -----|----|-----
	//    |    |    |    |
	//  C | C1 | C2 | C3 |
	//    |    |    |    |
	//    |----|----|----|
	
	// grid sqaures
	parameter A1 = 9'b100000000,
				 A2 = 9'b010000000,
				 A3 = 9'b001000000,
				 B1 = 9'b000100000,
				 B2 = 9'b000010000,
				 B3 = 9'b000001000,
				 C1 = 9'b000000100,
				 C2 = 9'b000000010,
				 C3 = 9'b000000001;
				 
	/*
	MOVE PRIORITY:
	1. next win
	2. block opponent win
	3. fork (has 2 corners, opposite two corners are empty, place in center)
	4. block opponent fork (opponent has 2 corners, opposite two corners are empty, place in center)
	5. play center
	6. play opposite corner (opponent has corner, place opposite)
	7. empty corner
	8. empty side
	*/
				 
	always @(*)
	begin
		
		// hard mode - good AI
		if (mode == 1'b1)
		begin
		
			// 1. next win
				
				// win cases in A row
				if ((grid_A1 == 2'b10) && (grid_A2 == 2'b10) && (grid_A3 == 2'd0))
					AI_move = A3;
				else if ((grid_A1 == 2'b10) && (grid_A3 == 2'b10) && (grid_A2 == 2'd0))
					AI_move = A2;
				else if ((grid_A2 == 2'b10) && (grid_A3 == 2'b10) && (grid_A1 == 2'd0))
					AI_move = A1;
					
				// win cases in B row
				else if ((grid_B1 == 2'b10) && (grid_B2 == 2'b10) && (grid_B3 == 2'd0))
					AI_move = B3;
				else if ((grid_B1 == 2'b10) && (grid_B3 == 2'b10) && (grid_B2 == 2'd0))
					AI_move = B2;
				else if ((grid_B2 == 2'b10) && (grid_B3 == 2'b10) && (grid_B1 == 2'd0))
					AI_move = B1;
					
				// win cases in C row
				else if ((grid_C1 == 2'b10) && (grid_C2 == 2'b10) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_C1 == 2'b10) && (grid_C3 == 2'b10) && (grid_C2 == 2'd0))
					AI_move = C2;
				else if ((grid_C2 == 2'b10) && (grid_C3 == 2'b10) && (grid_C1 == 2'd0))
					AI_move = C1;
					
				// win cases in 1 column
				else if ((grid_A1 == 2'b10) && (grid_B1 == 2'b10) && (grid_C1 == 2'd0))
					AI_move = C1;
				else if ((grid_A1 == 2'b10) && (grid_C1 == 2'b10) && (grid_B1 == 2'd0))
					AI_move = B1;
				else if ((grid_B1 == 2'b10) && (grid_C1 == 2'b10) && (grid_A1 == 2'd0))
					AI_move = A1;
					
				// win cases in 2 column
				else if ((grid_A2 == 2'b10) && (grid_B2 == 2'b10) && (grid_C2 == 2'd0))
					AI_move = C2;
				else if ((grid_A2 == 2'b10) && (grid_C2 == 2'b10) && (grid_B2 == 2'd0))
					AI_move = B2;
				else if ((grid_B2 == 2'b10) && (grid_C2 == 2'b10) && (grid_A2 == 2'd0))
					AI_move = A2;
					
				// win cases in 3 column
				else if ((grid_A3 == 2'b10) && (grid_B3 == 2'b10) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_A3 == 2'b10) && (grid_C3 == 2'b10) && (grid_B3 == 2'd0))
					AI_move = B3;
				else if ((grid_B3 == 2'b10) && (grid_C3 == 2'b10) && (grid_A3 == 2'd0))
					AI_move = A3;
					
				// win cases in positive slope
				else if ((grid_C1 == 2'b10) && (grid_B2 == 2'b10) && (grid_A3 == 2'd0))
					AI_move = A3;
				else if ((grid_C1 == 2'b10) && (grid_A3 == 2'b10) && (grid_B2 == 2'd0))
					AI_move = B2;
				else if ((grid_B2 == 2'b10) && (grid_A3 == 2'b10) && (grid_C1 == 2'd0))
					AI_move = C1;
					
				// win cases in negative slope
				else if ((grid_A1 == 2'b10) && (grid_B2 == 2'b10) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_A1 == 2'b10) && (grid_C3 == 2'b10) && (grid_B2 == 2'd0))
					AI_move = B2;
				else if ((grid_B2 == 2'b10) && (grid_C3 == 2'b10) && (grid_A1 == 2'd0))
					AI_move = A1;
			
			
			// 2. block opponent win
			
				// lose cases in A row
				else if ((grid_A1 == 2'b01) && (grid_A2 == 2'b01) && (grid_A3 == 2'd0))
					AI_move = A3;
				else if ((grid_A1 == 2'b01) && (grid_A3 == 2'b01) && (grid_A2 == 2'd0))
					AI_move = A2;
				else if ((grid_A2 == 2'b01) && (grid_A3 == 2'b01) && (grid_A1 == 2'd0))
					AI_move = A1;
					
				// lose cases in B row
				else if ((grid_B1 == 2'b01) && (grid_B2 == 2'b01) && (grid_B3 == 2'd0))
					AI_move = B3;
				else if ((grid_B1 == 2'b01) && (grid_B3 == 2'b01) && (grid_B2 == 2'd0))
					AI_move = B2;
				else if ((grid_B2 == 2'b01) && (grid_B3 == 2'b01) && (grid_B1 == 2'd0))
					AI_move = B1;
					
				// lose cases in C row
				else if ((grid_C1 == 2'b01) && (grid_C2 == 2'b01) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_C1 == 2'b01) && (grid_C3 == 2'b01) && (grid_C2 == 2'd0))
					AI_move = C2;
				else if ((grid_C2 == 2'b01) && (grid_C3 == 2'b01) && (grid_C1 == 2'd0))
					AI_move = C1;
					
				// lose cases in 1 column
				else if ((grid_A1 == 2'b01) && (grid_B1 == 2'b01) && (grid_C1 == 2'd0))
					AI_move = C1;
				else if ((grid_A1 == 2'b01) && (grid_C1 == 2'b01) && (grid_B1 == 2'd0))
					AI_move = B1;
				else if ((grid_B1 == 2'b01) && (grid_C1 == 2'b01) && (grid_A1 == 2'd0))
					AI_move = A1;
					
				// lose cases in 2 column
				else if ((grid_A2 == 2'b01) && (grid_B2 == 2'b01) && (grid_C2 == 2'd0))
					AI_move = C2;
				else if ((grid_A2 == 2'b01) && (grid_C2 == 2'b01) && (grid_B2 == 2'd0))
					AI_move = B2;
				else if ((grid_B2 == 2'b01) && (grid_C2 == 2'b01) && (grid_A2 == 2'd0))
					AI_move = A2;
					
				// lose cases in 3 column
				else if ((grid_A3 == 2'b01) && (grid_B3 == 2'b01) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_A3 == 2'b01) && (grid_C3 == 2'b01) && (grid_B3 == 2'd0))
					AI_move = B3;
				else if ((grid_B3 == 2'b01) && (grid_C3 == 2'b01) && (grid_A3 == 2'd0))
					AI_move = A3;
					
				// lose cases in positive slope
				else if ((grid_C1 == 2'b01) && (grid_B2 == 2'b01) && (grid_A3 == 2'd0))
					AI_move = A3;
				else if ((grid_C1 == 2'b01) && (grid_A3 == 2'b01) && (grid_B2 == 2'd0))
					AI_move = B2;
				else if ((grid_B2 == 2'b01) && (grid_A3 == 2'b01) && (grid_C1 == 2'd0))
					AI_move = C1;
					
				// lose cases in negative slope
				else if ((grid_A1 == 2'b01) && (grid_B2 == 2'b01) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_A1 == 2'b01) && (grid_C3 == 2'b01) && (grid_B2 == 2'd0))
					AI_move = B2;
				else if ((grid_B2 == 2'b01) && (grid_C3 == 2'b01) && (grid_A1 == 2'd0))
					AI_move = A1;
			
			
			// 3. fork
			
				// fork 1 - 8 variations
				else if ((grid_B2 == 2'b10) && (grid_C3 == 2'b10) && (grid_B3 == 2'd0) && (grid_C1 == 2'd0) && (grid_A3 == 2'd0))
					AI_move = A3;
				else if ((grid_B2 == 2'b10) && (grid_C1 == 2'b10) && (grid_A1 == 2'd0) && (grid_C2 == 2'd0) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_A1 == 2'b10) && (grid_B2 == 2'b10) && (grid_A3 == 2'd0) && (grid_B1 == 2'd0) && (grid_C1 == 2'd0))
					AI_move = C1;
				else if ((grid_A3 == 2'b10) && (grid_B2 == 2'b10) && (grid_A2 == 2'd0) && (grid_C3 == 2'd0) && (grid_A1 == 2'd0))
					AI_move = A1;
				else if ((grid_B2 == 2'b10) && (grid_C1 == 2'b10) && (grid_B1 == 2'd0) && (grid_C3 == 2'd0) && (grid_A1 == 2'd0))
					AI_move = A1;
				else if ((grid_A1 == 2'b10) && (grid_B2 == 2'b10) && (grid_A2 == 2'd0) && (grid_C3 == 2'd0) && (grid_A3 == 2'd0))
					AI_move = A3;
				else if ((grid_A3 == 2'b10) && (grid_B2 == 2'b10) && (grid_A1 == 2'd0) && (grid_B3 == 2'd0) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_B2 == 2'b10) && (grid_C3 == 2'b10) && (grid_A3 == 2'd0) && (grid_C2 == 2'd0) && (grid_C1 == 2'd0))
					AI_move = C1;
					
				// fork 2 - 4 variations, 8 plays
				else if ((grid_B2 == 2'b10) && (grid_C3 == 2'b10) && (grid_A3 == 2'd0) && (grid_C1 == 2'd0) && (grid_A2 == 2'd0))
					AI_move = A2;
				else if ((grid_B2 == 2'b10) && (grid_C3 == 2'b10) && (grid_A3 == 2'd0) && (grid_C1 == 2'd0) && (grid_B1 == 2'd0))
					AI_move = B1;
				else if ((grid_B2 == 2'b10) && (grid_C1 == 2'b10) && (grid_A1 == 2'd0) && (grid_C3 == 2'd0) && (grid_B3 == 2'd0))
					AI_move = B3;
				else if ((grid_B2 == 2'b10) && (grid_C1 == 2'b10) && (grid_A1 == 2'd0) && (grid_C3 == 2'd0) && (grid_A2 == 2'd0))
					AI_move = A2;
				else if ((grid_A1 == 2'b10) && (grid_B2 == 2'b10) && (grid_A3 == 2'd0) && (grid_C1 == 2'd0) && (grid_C2 == 2'd0))
					AI_move = C2;
				else if ((grid_A1 == 2'b10) && (grid_B2 == 2'b10) && (grid_A3 == 2'd0) && (grid_C1 == 2'd0) && (grid_B3 == 2'd0))
					AI_move = B3;
				else if ((grid_A3 == 2'b10) && (grid_B2 == 2'b10) && (grid_A1 == 2'd0) && (grid_C3 == 2'd0) && (grid_B1 == 2'd0))
					AI_move = B1;
				else if ((grid_A3 == 2'b10) && (grid_B2 == 2'b10) && (grid_A1 == 2'd0) && (grid_C3 == 2'd0) && (grid_C2 == 2'd0))
					AI_move = C2;
					
				// fork 3 - 8 variations
				else if ((grid_A2 == 2'b10) && (grid_B2 == 2'b10) && (grid_A3 == 2'd0) && (grid_C2 == 2'd0) && (grid_C1 == 2'd0))
					AI_move = C1;
				else if ((grid_B2 == 2'b10) && (grid_B3 == 2'b10) && (grid_B1 == 2'd0) && (grid_C3 == 2'd0) && (grid_A1 == 2'd0))
					AI_move = A1;
				else if ((grid_B2 == 2'b10) && (grid_C2 == 2'b10) && (grid_A2 == 2'd0) && (grid_C1 == 2'd0) && (grid_A3 == 2'd0))
					AI_move = A3;
				else if ((grid_B1 == 2'b10) && (grid_B2 == 2'b10) && (grid_A1 == 2'd0) && (grid_B3 == 2'd0) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_A2 == 2'b10) && (grid_B2 == 2'b10) && (grid_A1 == 2'd0) && (grid_C2 == 2'd0) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_B2 == 2'b10) && (grid_B3 == 2'b10) && (grid_A3 == 2'd0) && (grid_B1 == 2'd0) && (grid_C1 == 2'd0))
					AI_move = C1;
				else if ((grid_B2 == 2'b10) && (grid_C2 == 2'b10) && (grid_A2 == 2'd0) && (grid_C3 == 2'd0) && (grid_A1 == 2'd0))
					AI_move = A1;
				else if ((grid_B1 == 2'b10) && (grid_B2 == 2'b10) && (grid_B3 == 2'd0) && (grid_C1 == 2'd0) && (grid_A3 == 2'd0))
					AI_move = A3;
					
				// fork 4 - 8 variations
				else if ((grid_A2 == 2'b10) && (grid_B2 == 2'b10) && (grid_A3 == 2'd0) && (grid_C3 == 2'd0) && (grid_A1 == 2'd0))
					AI_move = A1;
				else if ((grid_B2 == 2'b10) && (grid_B3 == 2'b10) && (grid_C1 == 2'd0) && (grid_C3 == 2'd0) && (grid_A3 == 2'd0))
					AI_move = A3;
				else if ((grid_B2 == 2'b10) && (grid_C2 == 2'b10) && (grid_A1 == 2'd0) && (grid_C1 == 2'd0) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_B1 == 2'b10) && (grid_B2 == 2'b10) && (grid_A1 == 2'd0) && (grid_A3 == 2'd0) && (grid_C1 == 2'd0))
					AI_move = C1;
				else if ((grid_A2 == 2'b10) && (grid_B2 == 2'b10) && (grid_A1 == 2'd0) && (grid_C1 == 2'd0) && (grid_A3 == 2'd0))
					AI_move = A3;
				else if ((grid_B2 == 2'b10) && (grid_B3 == 2'b10) && (grid_A1 == 2'd0) && (grid_A3 == 2'd0) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_B2 == 2'b10) && (grid_C2 == 2'b10) && (grid_A3 == 2'd0) && (grid_C3 == 2'd0) && (grid_C1 == 2'd0))
					AI_move = C1;
				else if ((grid_B1 == 2'b10) && (grid_B2 == 2'b10) && (grid_C1 == 2'd0) && (grid_C3 == 2'd0) && (grid_A1 == 2'd0))
					AI_move = A1;
				
				// fork 5 - 4 variations
				else if ((grid_B3 == 2'b10) && (grid_C2 == 2'b10) && (grid_A2 == 2'd0) && (grid_B1 == 2'd0) && (grid_B2 == 2'd0))
					AI_move = B2;
				else if ((grid_B1 == 2'b10) && (grid_C2 == 2'b10) && (grid_A2 == 2'd0) && (grid_B3 == 2'd0) && (grid_B2 == 2'd0))
					AI_move = B2;
				else if ((grid_A2 == 2'b10) && (grid_B1 == 2'b10) && (grid_B3 == 2'd0) && (grid_C2 == 2'd0) && (grid_B2 == 2'd0))
					AI_move = B2;
				else if ((grid_A2 == 2'b10) && (grid_B3 == 2'b10) && (grid_B1 == 2'd0) && (grid_C2 == 2'd0) && (grid_B2 == 2'd0))
					AI_move = B2;
				
				
				// fork 6 - 4 variations
				else if ((grid_A1 == 2'b10) && (grid_C3 == 2'b10) && (grid_A2 == 2'd0) && (grid_B3 == 2'd0) && (grid_A3 == 2'd0))
					AI_move = A3;
				else if ((grid_A3 == 2'b10) && (grid_C1 == 2'b10) && (grid_B3 == 2'd0) && (grid_C2 == 2'd0) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_A1 == 2'b10) && (grid_C3 == 2'b10) && (grid_B1 == 2'd0) && (grid_C2 == 2'd0) && (grid_C1 == 2'd0))
					AI_move = C1;
				else if ((grid_A3 == 2'b10) && (grid_C1 == 2'b10) && (grid_A2 == 2'd0) && (grid_B1 == 2'd0) && (grid_A1 == 2'd0))
					AI_move = A1;
					
			
			// 4. block opponent fork
			
				// fork 1 - 8 variations
				else if ((grid_B2 == 2'b01) && (grid_C3 == 2'b01) && (grid_B3 == 2'd0) && (grid_C1 == 2'd0) && (grid_A3 == 2'd0))
					AI_move = A3;
				else if ((grid_B2 == 2'b01) && (grid_C1 == 2'b01) && (grid_A1 == 2'd0) && (grid_C2 == 2'd0) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_A1 == 2'b01) && (grid_B2 == 2'b01) && (grid_A3 == 2'd0) && (grid_B1 == 2'd0) && (grid_C1 == 2'd0))
					AI_move = C1;
				else if ((grid_A3 == 2'b01) && (grid_B2 == 2'b01) && (grid_A2 == 2'd0) && (grid_C3 == 2'd0) && (grid_A1 == 2'd0))
					AI_move = A1;
				else if ((grid_B2 == 2'b01) && (grid_C1 == 2'b01) && (grid_B1 == 2'd0) && (grid_C3 == 2'd0) && (grid_A1 == 2'd0))
					AI_move = A1;
				else if ((grid_A1 == 2'b01) && (grid_B2 == 2'b01) && (grid_A2 == 2'd0) && (grid_C3 == 2'd0) && (grid_A3 == 2'd0))
					AI_move = A3;
				else if ((grid_A3 == 2'b01) && (grid_B2 == 2'b01) && (grid_A1 == 2'd0) && (grid_B3 == 2'd0) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_B2 == 2'b01) && (grid_C3 == 2'b01) && (grid_A3 == 2'd0) && (grid_C2 == 2'd0) && (grid_C1 == 2'd0))
					AI_move = C1;
					
				// fork 2 - 4 variations, 8 plays
				else if ((grid_B2 == 2'b01) && (grid_C3 == 2'b01) && (grid_A3 == 2'd0) && (grid_C1 == 2'd0) && (grid_A2 == 2'd0))
					AI_move = A2;
				else if ((grid_B2 == 2'b01) && (grid_C3 == 2'b01) && (grid_A3 == 2'd0) && (grid_C1 == 2'd0) && (grid_B1 == 2'd0))
					AI_move = B1;
				else if ((grid_B2 == 2'b01) && (grid_C1 == 2'b01) && (grid_A1 == 2'd0) && (grid_C3 == 2'd0) && (grid_B3 == 2'd0))
					AI_move = B3;
				else if ((grid_B2 == 2'b01) && (grid_C1 == 2'b01) && (grid_A1 == 2'd0) && (grid_C3 == 2'd0) && (grid_A2 == 2'd0))
					AI_move = A2;
				else if ((grid_A1 == 2'b01) && (grid_B2 == 2'b01) && (grid_A3 == 2'd0) && (grid_C1 == 2'd0) && (grid_C2 == 2'd0))
					AI_move = C2;
				else if ((grid_A1 == 2'b01) && (grid_B2 == 2'b01) && (grid_A3 == 2'd0) && (grid_C1 == 2'd0) && (grid_B3 == 2'd0))
					AI_move = B3;
				else if ((grid_A3 == 2'b01) && (grid_B2 == 2'b01) && (grid_A1 == 2'd0) && (grid_C3 == 2'd0) && (grid_B1 == 2'd0))
					AI_move = B1;
				else if ((grid_A3 == 2'b01) && (grid_B2 == 2'b01) && (grid_A1 == 2'd0) && (grid_C3 == 2'd0) && (grid_C2 == 2'd0))
					AI_move = C2;
					
				// fork 3 - 8 variations
				else if ((grid_A2 == 2'b01) && (grid_B2 == 2'b01) && (grid_A3 == 2'd0) && (grid_C2 == 2'd0) && (grid_C1 == 2'd0))
					AI_move = C1;
				else if ((grid_B2 == 2'b01) && (grid_B3 == 2'b01) && (grid_B1 == 2'd0) && (grid_C3 == 2'd0) && (grid_A1 == 2'd0))
					AI_move = A1;
				else if ((grid_B2 == 2'b01) && (grid_C2 == 2'b01) && (grid_A2 == 2'd0) && (grid_C1 == 2'd0) && (grid_A3 == 2'd0))
					AI_move = A3;
				else if ((grid_B1 == 2'b01) && (grid_B2 == 2'b01) && (grid_A1 == 2'd0) && (grid_B3 == 2'd0) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_A2 == 2'b01) && (grid_B2 == 2'b01) && (grid_A1 == 2'd0) && (grid_C2 == 2'd0) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_B2 == 2'b01) && (grid_B3 == 2'b01) && (grid_A3 == 2'd0) && (grid_B1 == 2'd0) && (grid_C1 == 2'd0))
					AI_move = C1;
				else if ((grid_B2 == 2'b01) && (grid_C2 == 2'b01) && (grid_A2 == 2'd0) && (grid_C3 == 2'd0) && (grid_A1 == 2'd0))
					AI_move = A1;
				else if ((grid_B1 == 2'b01) && (grid_B2 == 2'b01) && (grid_B3 == 2'd0) && (grid_C1 == 2'd0) && (grid_A3 == 2'd0))
					AI_move = A3;
					
				// fork 4 - 8 variations
				else if ((grid_A2 == 2'b01) && (grid_B2 == 2'b01) && (grid_A3 == 2'd0) && (grid_C3 == 2'd0) && (grid_A1 == 2'd0))
					AI_move = A1;
				else if ((grid_B2 == 2'b01) && (grid_B3 == 2'b01) && (grid_C1 == 2'd0) && (grid_C3 == 2'd0) && (grid_A3 == 2'd0))
					AI_move = A3;
				else if ((grid_B2 == 2'b01) && (grid_C2 == 2'b01) && (grid_A1 == 2'd0) && (grid_C1 == 2'd0) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_B1 == 2'b01) && (grid_B2 == 2'b01) && (grid_A1 == 2'd0) && (grid_A3 == 2'd0) && (grid_C1 == 2'd0))
					AI_move = C1;
				else if ((grid_A2 == 2'b01) && (grid_B2 == 2'b01) && (grid_A1 == 2'd0) && (grid_C1 == 2'd0) && (grid_A3 == 2'd0))
					AI_move = A3;
				else if ((grid_B2 == 2'b01) && (grid_B3 == 2'b01) && (grid_A1 == 2'd0) && (grid_A3 == 2'd0) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_B2 == 2'b01) && (grid_C2 == 2'b01) && (grid_A3 == 2'd0) && (grid_C3 == 2'd0) && (grid_C1 == 2'd0))
					AI_move = C1;
				else if ((grid_B1 == 2'b01) && (grid_B2 == 2'b01) && (grid_C1 == 2'd0) && (grid_C3 == 2'd0) && (grid_A1 == 2'd0))
					AI_move = A1;
				
				// fork 5 - 4 variations
				else if ((grid_B3 == 2'b01) && (grid_C2 == 2'b01) && (grid_A2 == 2'd0) && (grid_B1 == 2'd0) && (grid_B2 == 2'd0))
					AI_move = B2;
				else if ((grid_B1 == 2'b01) && (grid_C2 == 2'b01) && (grid_A2 == 2'd0) && (grid_B3 == 2'd0) && (grid_B2 == 2'd0))
					AI_move = B2;
				else if ((grid_A2 == 2'b01) && (grid_B1 == 2'b01) && (grid_B3 == 2'd0) && (grid_C2 == 2'd0) && (grid_B2 == 2'd0))
					AI_move = B2;
				else if ((grid_A2 == 2'b01) && (grid_B3 == 2'b01) && (grid_B1 == 2'd0) && (grid_C2 == 2'd0) && (grid_B2 == 2'd0))
					AI_move = B2;
				
				
				// fork 6 - 4 variations
				else if ((grid_A1 == 2'b01) && (grid_C3 == 2'b01) && (grid_A2 == 2'd0) && (grid_B3 == 2'd0) && (grid_A3 == 2'd0))
					AI_move = A3;
				else if ((grid_A3 == 2'b01) && (grid_C1 == 2'b01) && (grid_B3 == 2'd0) && (grid_C2 == 2'd0) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_A1 == 2'b01) && (grid_C3 == 2'b01) && (grid_B1 == 2'd0) && (grid_C2 == 2'd0) && (grid_C1 == 2'd0))
					AI_move = C1;
				else if ((grid_A3 == 2'b01) && (grid_C1 == 2'b01) && (grid_A2 == 2'd0) && (grid_B1 == 2'd0) && (grid_A1 == 2'd0))
					AI_move = A1;
					
			
			// 5. play center
				else if (grid_B2 == 2'd0)
					AI_move = B2;
			
			
			// 6. play opposite corner

				else if ((grid_A1 == 2'b01) && (grid_C3 == 2'd0))
					AI_move = C3;
				else if ((grid_A3 == 2'b01) && (grid_C1 == 2'd0))
					AI_move = C1;
				else if ((grid_C1 == 2'b01) && (grid_A3 == 2'd0))
					AI_move = A3;
				else if ((grid_C3 == 2'b01) && (grid_A1 == 2'd0))
					AI_move = A1;

			
			// 7. empty corner

				else if (grid_A1 == 2'd0)
					AI_move = A1;
				else if (grid_A3 == 2'd0)
					AI_move = A3;
				else if (grid_C1 == 2'd0)
					AI_move = C1;
				else if (grid_C3 == 2'd0)
					AI_move = C3;
					
			
			// 8. empty side

				else if (grid_A2 == 2'd0)
					AI_move = A2;
				else if (grid_B1 == 2'd0)
					AI_move = B1;
				else if (grid_B3 == 2'd0)
					AI_move = B3;
				else if (grid_C2 == 2'd0)
					AI_move = C2;
			
		end
		
		// easy mode - bad AI
		else 
		begin
			if (grid_A1 == 2'd0)
				AI_move = A1;
			else if (grid_A2 == 2'd0)
				AI_move = A2;
			else if (grid_A3 == 2'd0)
				AI_move = A3;
			else if (grid_B1 == 2'd0)
				AI_move = B1;
			else if (grid_B2 == 2'd0)
				AI_move = B2;
			else if (grid_B3 == 2'd0)
				AI_move = B3;
			else if (grid_C1 == 2'd0)
				AI_move = C1;
			else if (grid_C2 == 2'd0)
				AI_move = C2;
			else if (grid_C3 == 2'd0)
				AI_move = C3;
		end 
	end
	
endmodule


module four_val_display (
input [1:0]user,
output [6:0]seg7_lsb,
output [6:0]seg7_msb,
output [6:0]seg7_hund,
output [6:0]seg7_thous
);

reg [3:0] result_one_digit;
reg [3:0] result_ten_digit;
reg [3:0]result_hundreds_digit;
reg [3:0]result_thousands_digit;
	  

always @(*)
begin
	
	result_one_digit = {2'd0, user};
	result_ten_digit = 4'hF;
	result_hundreds_digit = 4'hE;
	result_thousands_digit = 4'hE;
	  
end

/* instantiate the modules for each of the seven seg decoders */
seven_segment ones_place(result_one_digit, seg7_lsb);
seven_segment tens_place(result_ten_digit, seg7_msb);
seven_segment hundreds_place(result_hundreds_digit, seg7_hund);
seven_segment thousands_place(result_thousands_digit, seg7_thous);

endmodule



module seven_segment (
input [3:0]i,
output reg [6:0]o
);


// HEX out - rewire DE2
//  ---a---
// |       |
// f       b
// |       |
//  ---g---
// |       |
// e       c
// |       |
//  ---d---

always @(*)
begin
	case (i)	    // abcdefg

		4'h0: o = 7'b0000001;
		4'h1: o = 7'b1001111;
		4'h2: o = 7'b0010010;
//		4'h3: o = 7'b0000110;
//		4'h4: o = 7'b1001100;
//		4'h5: o = 7'b0100100;
//		4'h6: o = 7'b0100000;
//		4'h7: o = 7'b0001111;
//		4'h8: o = 7'b0000000;
//		4'h9: o = 7'b0000100;
//		4'hA: o = 7'b0001000;
//		4'hB: o = 7'b1100000;
//		4'hC: o = 7'b0110001;
//		4'hD: o = 7'b1000010;
//		4'hE: o = 7'b0110000;
//		4'hF: o = 7'b0111000;
		
		4'hE: o = 7'b1111111; // blank display
		4'hF: o = 7'b0011000; // P
		
		default: o = 7'b1111111;
	
	endcase
end

endmodule

