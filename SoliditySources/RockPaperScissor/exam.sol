// SPDX-License-Identifier: None 
pragma solidity ^0.8.0; 
 
import "./specs.sol"; 
 
contract abstractTrustworthyRockPaperScissorsTournament is TrustworthyRockPaperScissorsTournamentSpecs{ 

    enum Move{ Paper, Scissor, Rock } 
    
    address payable immutable owner; 
    address payable public immutable firstPlayer; 
    address payable public immutable secondPlayer; 
 
    // index 0: player 1 moves as a dinamyc array
    // index 1: player 2 moves as a dinamyc array
    Move[][2] public moves;

    // index 0: wins of player 1
    // index 1: wins of player 2
    uint[2] public wins;

    uint8 public disputedMatches = 0; 

    uint8 public immutable targetWins;
    uint256 public immutable singleMatchFee; 
 
    constructor(address payable _firstPlayer, address payable _secondPlayer, uint8 _targetWins, uint256 _singleMatchFee){ 
        require(_firstPlayer != address(0) && _secondPlayer != address(0), "All the players must be specified.");
        require(_firstPlayer != _secondPlayer, "Players must be different."); 
        require(_targetWins > 0, "Target wins must be non-negative"); 
 
        targetWins = _targetWins; 
        singleMatchFee = _singleMatchFee; 
        firstPlayer = _firstPlayer; 
        secondPlayer = _secondPlayer; 
        owner = payable(msg.sender); 
    } 
 
    modifier requireFee(){ 
        require(msg.value >= singleMatchFee, "Must pay the required fee."); 
        _; 
    } 
 
    modifier onlyPlayers(){ 
        require(
            msg.sender == firstPlayer || msg.sender == secondPlayer, 
            "Only the players can interact with the game."
        ); 
        _; 
    } 
     
    function moveRock() external payable requireFee onlyPlayers override{ 
        move(Move.Rock); 
    } 
 
    function movePaper() external payable requireFee onlyPlayers override{ 
        move(Move.Paper); 
    } 
     
    function moveScissor() external payable requireFee onlyPlayers override{ 
        move(Move.Scissor); 
    } 
 
    function move(Move actualMove) internal{ 
        uint8 player = (msg.sender == firstPlayer ? 0 : 1); 
        moves[player].push(actualMove); 
        checkMoves(); 
    } 

    function checkMoves() internal {
        while (moves[0].length > 0 && moves[1].length > 0) {
            Move p1move = stackPop(moves[0]); 
            Move p2move = stackPop(moves[1]);  
            disputedMatches++; 
            if (p1move == p2move) continue; 
            if ((p1move == Move.Paper   && p2move == Move.Rock)     ||
                (p1move == Move.Rock    && p2move == Move.Scissor)  ||
                (p1move == Move.Scissor && p2move == Move.Paper)    ){
                wins[0]++;
                emit MatchWonBy(Player.First, disputedMatches); 
            }
            else { 
                wins[1]++;
                emit MatchWonBy(Player.Second, disputedMatches);
            }
            if (gameOver()) return; 
        }
    }

    function stackPop(Move[] storage stack) internal returns(Move) {
        Move elementPopped = stack[0]; 
        for (uint i = 1; i < stack.length; i++) stack[i-1] = stack[i]; 
        stack.pop(); 
        return elementPopped; 
    }

    function gameOver() internal returns(bool) {
        Player winningPlayer = wins[0] > wins[1] ? Player.First : Player.Second;
        if (wins[uint(winningPlayer)] < targetWins) return false;
        address payable winner = winningPlayer == Player.Second ? secondPlayer : firstPlayer;
        winner.transfer(address(this).balance);  
        emit TournamentWonBy(winningPlayer);
        selfdestruct(owner);
        return true; 
    }
 
}