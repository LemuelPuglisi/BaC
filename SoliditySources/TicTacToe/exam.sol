// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract TicTacToe {

    // TODO: provide a mechanism to prevent player going AFK

    enum Signs { X, O, E }

    address payable playerX; 
    address payable playerO;     
    Signs currentPlayer;  

    bool public gameCompleted; 

    Signs[3][3] public gameBoard = [ 
        [Signs.E, Signs.E, Signs.E],
        [Signs.E, Signs.E, Signs.E],
        [Signs.E, Signs.E, Signs.E]
    ]; 

    // This variable will be updated at each move
    // with the amount of WEIs sent by the player. 
    // The next player should INCREASE this fee. 
    uint256 public minimumFeePerMove; 


    modifier isturn() {
        require (
            (msg.sender == playerX && currentPlayer == Signs.X) ||
            (msg.sender == playerO && currentPlayer == Signs.O), 
            "It's not your turn."
        );
        _; 
    }


    modifier emptyCell(uint r, uint c) {
        require(gameBoard[r][c] == Signs.E, "Cell is not empty."); 
        _; 
    }


    modifier running() {
        string memory winner = currentPlayer == Signs.X ? "X" : "O"; 
        require(!gameCompleted, string.concat("Game is completed. Winner is ", winner)); 
        _; 
    }


    modifier requireFee() {
        require(msg.value > minimumFeePerMove, "Provide a greater fee.");
        _;
    }


    constructor(address _playerX, address _playerO, uint startingFee) {
        
        require(_playerX != _playerO   && 
                _playerX != address(0) &&
                _playerO != address(0), 
                "Insert valid players."); 
        
        playerX = payable(_playerX);
        playerO = payable(_playerO); 
        minimumFeePerMove = startingFee; 
        currentPlayer = Signs.X; 
        gameCompleted = false; 
    }


    function makeMove(uint row, uint col) external payable running isturn emptyCell(row, col) requireFee {
        gameBoard[row][col] = currentPlayer; 
        if (!checkVictory()) {
            currentPlayer = Signs((uint8(currentPlayer) + 1) % 2);
            minimumFeePerMove = msg.value;     
        }
    }


    function checkVictory() internal returns(bool) {
        if (!currentPlayerWon()) return false; 
        gameCompleted = true; 
        return true; 
    }


    // explicit check is (gas-)cheaper than looping.
    function currentPlayerWon() internal view returns(bool) {
        Signs[3][3] storage gb = gameBoard; 
        return ( 
            (gb[0][0] != Signs.E && gb[0][0] == gb[0][1] && gb[0][1] == gb[0][2]) ||
            (gb[1][0] != Signs.E && gb[1][0] == gb[1][1] && gb[1][1] == gb[1][2]) ||
            (gb[2][0] != Signs.E && gb[2][0] == gb[2][1] && gb[2][1] == gb[2][2]) ||
            (gb[0][0] != Signs.E && gb[0][0] == gb[1][0] && gb[1][0] == gb[2][0]) ||
            (gb[0][1] != Signs.E && gb[0][1] == gb[1][1] && gb[1][1] == gb[2][1]) ||
            (gb[0][2] != Signs.E && gb[0][2] == gb[1][2] && gb[1][2] == gb[2][2]) ||
            (gb[0][0] != Signs.E && gb[0][0] == gb[1][1] && gb[1][1] == gb[2][2]) ||
            (gb[0][2] != Signs.E && gb[0][2] == gb[1][1] && gb[1][1] == gb[2][0])
        ); 
    }

}