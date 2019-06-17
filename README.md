# TicTacToe
Verilog Implementation of 3x3 TicTacToe
Game takes in the following inputs:
  A reset signal starts the game.
  A clk signal for running the game state machine.
  A flash_clk signal 
  9-bit 1-hot signal, sel_pos[8:0] to indicate which square is selected as move.
  2 buttons to indicate a player making the move.
Game module outputs the following signals:
  2 signals to indicate player's turn.
  Two 9-bit signals, occ_square[8:0] and occ_player[8:0], to indicate whether a square is occupied and which player is occupying the square.
  9-bit signal to represent the player board, occ_pos[8:0].This signal combines the information of the 2 9-bit outputs above and indicates when a winning position is detected. Each occ_pos signal is 1’b0 to indicate unoccupied, 1’b1 to indicate occupied by X, and flashing 1’b1 at a rate of ½ flash_clk to indicate occupied by O. If a winning position is detected, the winning row/column/diagonal flashes at a rate of flash_clk.
