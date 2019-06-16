`timescale 1ns / 1ps

/* 
 * Definition: X is 1, O is 0
 */
`define X_TILE 1'b1
`define O_TILE 1'b0


`define GAME_ST_START	4'b0000
`define GAME_ST_TURN_X 	4'b0001
`define GAME_ST_ERR_X 	4'b0010
`define GAME_ST_CHKV_X 	4'b0011
`define GAME_ST_CHKW_X 	4'b0100
`define GAME_ST_WIN_X 	4'b0101
`define GAME_ST_TURN_O 	4'b0110
`define GAME_ST_ERR_O 	4'b0111
`define GAME_ST_CHKV_O 	4'b1000
`define GAME_ST_CHKW_O 	4'b1001
`define GAME_ST_WIN_O 	4'b1010
`define GAME_ST_CATS 	4'b1011

  /* The grid looks like this:
   * 8 | 7 | 6
   * --|---|---
   * 5 | 4 | 3
   * --|---|---
   * 2 | 1 | 0
   */

  /* 
   * Winning combinations (treys) are the following:
   * 852, 741, 630, 876, 543, 210, 840, 642
   */
  
  /* Suggestions
   * Create a module to check for a validity of a move
   * Create modules to check for a victory in the treys
   */

//checks for a valid move
module validmove(occ_square, sel_pos, valid);
  output valid;
  input [8:0] occ_square, sel_pos;
  assign valid = (~occ_square[0]&sel_pos[0])|
    (~occ_square[1]&sel_pos[1])|
    (~occ_square[2]&sel_pos[2])|
    (~occ_square[3]&sel_pos[3])|
    (~occ_square[4]&sel_pos[4])|
    (~occ_square[5]&sel_pos[5])|
    (~occ_square[6]&sel_pos[6])|
    (~occ_square[7]&sel_pos[7])|
    (~occ_square[8]&sel_pos[8]); 
endmodule 

//checks for victory
module checkvictory(occ_square, occ_player, victory);
  output[1:0] victory; //[XO]
  input [8:0] occ_square, occ_player;
  assign victory[0] = ((occ_square[0]&occ_player[0]&occ_square[1]&occ_player[1]&occ_square[2]&occ_player[2])|  						(occ_square[0]&occ_player[0]&occ_square[4]&occ_player[4]&occ_square[8]&occ_player[8])| 						(occ_square[2]&occ_player[2]&occ_square[5]&occ_player[5]&occ_square[8]&occ_player[8])|						(occ_square[7]&occ_player[7]&occ_square[4]&occ_player[4]&occ_square[1]&occ_player[1])| 
    				(occ_square[0]&occ_player[0]&occ_square[3]&occ_player[3]&occ_square[6]&occ_player[6])| 
    				(occ_square[6]&occ_player[6]&occ_square[7]&occ_player[7]&occ_square[8]&occ_player[8])| 
    				(occ_square[3]&occ_player[3]&occ_square[4]&occ_player[4]&occ_square[5]&occ_player[5])| 
                    (occ_square[6]&occ_player[6]&occ_square[4]&occ_player[4]&occ_square[2]&occ_player[2]));
  assign victory[1]=((occ_square[0]&~occ_player[0]&occ_square[1]&~occ_player[1]&occ_square[2]&~occ_player[2])| 
    (occ_square[0]&~occ_player[0]&occ_square[4]&~occ_player[4]&occ_square[8]&~occ_player[8])| //840
    (occ_square[2]&~occ_player[2]&occ_square[5]&~occ_player[5]&occ_square[8]&~occ_player[8])| //852
    (occ_square[7]&~occ_player[7]&occ_square[4]&~occ_player[4]&occ_square[1]&~occ_player[1])| //741
    (occ_square[0]&~occ_player[0]&occ_square[3]&~occ_player[3]&occ_square[6]&~occ_player[6])| //630
    (occ_square[6]&~occ_player[6]&occ_square[7]&~occ_player[7]&occ_square[8]&~occ_player[8])| //876
    (occ_square[3]&~occ_player[3]&occ_square[4]&~occ_player[4]&occ_square[5]&~occ_player[5])| //543
    (occ_square[6]&~occ_player[6]&occ_square[4]&~occ_player[4]&occ_square[2]&~occ_player[2]));
endmodule

module tictactoe(turnX, turnO, occ_pos, occ_square, occ_player, game_st_ascii, reset, clk, flash_clk, sel_pos, buttonX, buttonO);
  output turnX;
  output turnO;
  output [8:0] occ_pos, occ_square, occ_player;
  output [7:0] game_st_ascii;

  input reset, clk, flash_clk;
  input [8:0] sel_pos;
  input buttonX, buttonO;

  /* 
   * occ_square states if there's a tile in this square or not 
   * occ_player states which type of tile is in the square 
   * game_state is the 4 bit curent state;
   * occ_pos is the board with flashing 
   */
  reg [8:0] occ_square;
  reg [8:0] occ_player;
  reg [3:0] game_state;
  reg [8:0] occ_pos;

  reg [3:0] nx_game_state;
  reg turnX, turnO;
  reg [7:0] game_st_ascii;
  reg win1, win2, win3, win4, win5, win6, win7, win8, wincat;
  wire valid;
  reg prevalid;
  validmove validmove(occ_square, sel_pos, valid);
  wire[1:0] victory;
  checkvictory checkvictory(occ_square, occ_player, victory);
  /*
   * Registers
   *  -- game_state register is provided to get you started
   */ 
  always @(*) begin
    win1 =(occ_square[0]&occ_player[0]&occ_square[1]&occ_player[1]&occ_square[2]&occ_player[2])|(occ_square[0]&~occ_player[0]&occ_square[1]&~occ_player[1]&occ_square[2]&~occ_player[2]);
    win2 = (occ_square[0]&occ_player[0]&occ_square[4]&occ_player[4]&occ_square[8]&occ_player[8])|(occ_square[0]&~occ_player[0]&occ_square[4]&~occ_player[4]&occ_square[8]&~occ_player[8]);
    win3 = (occ_square[2]&occ_player[2]&occ_square[5]&occ_player[5]&occ_square[8]&occ_player[8])|(occ_square[2]&~occ_player[2]&occ_square[5]&~occ_player[5]&occ_square[8]&~occ_player[8]);
    win4 = (occ_square[7]&occ_player[7]&occ_square[4]&occ_player[4]&occ_square[1]&occ_player[1])|(occ_square[7]&~occ_player[7]&occ_square[4]&~occ_player[4]&occ_square[1]&~occ_player[1]);
    win5=(occ_square[0]&occ_player[0]&occ_square[3]&occ_player[3]&occ_square[6]&occ_player[6])|(occ_square[6]&~occ_player[6]&occ_square[7]&~occ_player[7]&occ_square[8]&~occ_player[8]);
    win6=(occ_square[6]&occ_player[6]&occ_square[7]&occ_player[7]&occ_square[8]&occ_player[8])|(occ_square[6]&~occ_player[6]&occ_square[7]&~occ_player[7]&occ_square[8]&~occ_player[8]);
    win7=(occ_square[3]&occ_player[3]&occ_square[4]&occ_player[4]&occ_square[5]&occ_player[5])|(occ_square[3]&~occ_player[3]&occ_square[4]&~occ_player[4]&occ_square[5]&~occ_player[5]);
    win8=(occ_square[6]&occ_player[6]&occ_square[4]&occ_player[4]&occ_square[2]&occ_player[2])|(occ_square[6]&~occ_player[6]&occ_square[4]&~occ_player[4]&occ_square[2]&~occ_player[2]);
    wincat=(occ_square[0]&occ_square[1]&occ_square[2]&occ_square[3]&occ_square[4]&occ_square[5]&occ_square[6]&occ_square[7]&occ_square[8]);
  end 
  
  always @(posedge flash_clk) begin
    if(game_st_ascii == 8'b01011000 || game_st_ascii == 8'b01001111) begin
      if (occ_pos == 9'b000000000) begin
        if(win1) begin occ_pos = 9'b000000111; end 
        else if (win2) begin occ_pos = 9'b100010001; end
        else if (win3) begin occ_pos = 9'b100100100 ; end
        else if (win4) begin occ_pos = 9'b010010010 ; end
        else if (win5) begin occ_pos = 9'b001001001 ; end
        else if (win6) begin occ_pos = 9'b111000000; end
        else if (win7) begin occ_pos = 9'b000111000; end
        else if (win8) begin occ_pos = 9'b001010100; end
      end 
    end
    else if(game_st_ascii == 8'b01000011) begin
      if(win1) begin occ_pos = 9'b000000111; end 
        if (win2) begin occ_pos = 9'b100010001; end
        if (win3) begin occ_pos = 9'b100100100 ; end
        if (win4) begin occ_pos = 9'b010010010 ; end
        if (win5) begin occ_pos = 9'b001001001 ; end
        if (win6) begin occ_pos = 9'b111000000; end
        if (win7) begin occ_pos = 9'b000111000; end
        if (win8) begin occ_pos = 9'b001010100; end
    end 
    else begin occ_pos =  9'b000000000; end
  end 
  
  always @(posedge clk) begin
    if(reset)
      begin
      	game_state <= `GAME_ST_START;
        occ_square = 9'b000000000;
        occ_player = 9'b000000000;
        occ_pos = 9'b000000000;
        prevalid = 1'b0;
      end
    else
      game_state <= nx_game_state;
  end
  
  always @(*) begin
    if(!(game_st_ascii == 8'b01011000 || game_st_ascii == 8'b01001111))
      begin
      if(flash_clk == 1'b0) begin occ_pos = (~occ_square~|occ_player); end
      else if (flash_clk == 1'b1) begin occ_pos = (occ_square & occ_player); end
    end
  end 
  
  always @(*) begin
    case (game_state)
      `GAME_ST_TURN_X,
      `GAME_ST_ERR_X: begin
        turnX = 1'b1;
      end
      `GAME_ST_TURN_O,
      `GAME_ST_ERR_O: begin
        turnO = 1'b1;
      end
      default: begin
        turnX = 1'b0;
        turnO = 1'b0;
      end
    endcase
  end
  always @(*) begin
    case(game_state)
      `GAME_ST_START:
        begin
       	  nx_game_state = `GAME_ST_TURN_X;
          game_st_ascii <= 8'b01101110;
          //game_st_ascii = 8'b01000011;
        end
      `GAME_ST_TURN_X:
        begin 
          game_st_ascii <= 8'b01101110;
          if(buttonX) //only button X is pressed
            begin
              nx_game_state = `GAME_ST_CHKV_X;
              prevalid = 1'b0;
            end 
          else if(buttonO) //error O should not be pressed
            begin 
              nx_game_state = `GAME_ST_ERR_X;
            end 
          else //no button is pressed
            begin
              nx_game_state = `GAME_ST_TURN_X; 
            end 
        end 
      `GAME_ST_ERR_X:
        begin 
          game_st_ascii <= 8'b01000101; 
          prevalid = 1'b0;
          if(buttonX) //detect correct input 
            begin
              nx_game_state = `GAME_ST_CHKV_X;
            end 
          else
            begin
              nx_game_state = `GAME_ST_ERR_X;
            end 
        end 
      `GAME_ST_CHKV_X:
        begin
          game_st_ascii <= 8'b01101110;
          if(valid||prevalid) 
          begin
            prevalid = 1'b1;
            nx_game_state = `GAME_ST_CHKW_X;
            occ_square = (occ_square|sel_pos); //mark occupied location
            occ_player = (occ_player|sel_pos); //mark occupied player
          end
          if(~valid&&~prevalid) begin 
            nx_game_state = `GAME_ST_ERR_X;
          end 
        end 
      `GAME_ST_CHKW_X:
        begin
          game_st_ascii <= 8'b01101110;
          if(wincat)
            nx_game_state = `GAME_ST_CATS;
          else
            begin
          case(victory) 
            2'b01: //X wins
              begin
                nx_game_state = `GAME_ST_WIN_X;
                //need to flash
              end 
            2'b10: //O wins
              begin
                nx_game_state = `GAME_ST_WIN_O;
                //need to flash
              end 
            2'b00:
              begin
                nx_game_state = `GAME_ST_TURN_O;
              end 
          endcase 
            end
          
        end 
      `GAME_ST_WIN_X:
        begin
          game_st_ascii <= 8'b01011000;
          nx_game_state = `GAME_ST_WIN_X;
        end
      `GAME_ST_TURN_O:
        begin
          game_st_ascii <= 8'b01101110;
          prevalid = 1'b0;
          if(buttonO) //only button O is pressed
            begin
              nx_game_state = `GAME_ST_CHKV_O;
            end 
          else if(buttonX) //error X should not be pressed
            begin 
              nx_game_state = `GAME_ST_ERR_O;
            end 
          else //no button is pressed
            begin
              nx_game_state = `GAME_ST_TURN_O;
            end 
        end 
      `GAME_ST_ERR_O:
        begin 
          prevalid = 1'b0;
          game_st_ascii <= 8'b01000101; 
          if(buttonO) //detect correct input 
            begin
              nx_game_state = `GAME_ST_CHKV_O;
            end 
          else
            begin
              nx_game_state = `GAME_ST_ERR_O;
            end 
        end 
      `GAME_ST_CHKV_O:
        begin
          game_st_ascii <= 8'b01101110;
          if(valid||prevalid) begin
            occ_square = (occ_square|sel_pos); //mark occupied location
            nx_game_state = `GAME_ST_CHKW_O;

            prevalid = 1'b1;
          end
          if(~valid&&~prevalid)
            nx_game_state = `GAME_ST_ERR_O;
        end
     `GAME_ST_CHKW_O:
        begin
          game_st_ascii <= 8'b01101110;
          if(wincat)
            nx_game_state = `GAME_ST_CATS;
          else begin
          case(victory)
            2'b01: 
              begin
                nx_game_state = `GAME_ST_WIN_X;
                //need to flash
              end 
            2'b10: //O wins
              begin
                nx_game_state = `GAME_ST_WIN_O;
                //need to flash
              end 
            2'b00:
              begin
                nx_game_state = `GAME_ST_TURN_X;
              end 
          endcase 
          end
        end 
      `GAME_ST_WIN_O:
        begin
          game_st_ascii <= 8'b01001111;
          nx_game_state = `GAME_ST_WIN_O;
        end
      `GAME_ST_CATS:
        begin
          game_st_ascii <= 8'b01000011;
          nx_game_state = `GAME_ST_CATS;
        end
     endcase 
  end
endmodule

