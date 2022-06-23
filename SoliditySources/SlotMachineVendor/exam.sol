// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract SlotMachineVendor {

    address payable public owner; 

    constructor() {
        owner = payable(msg.sender); 
    }

    function buySlot(uint wheels, uint totalMatches, uint minBet) external payable returns(address){
        require(wheels >= 3, "min. 3 wheels"); 
        require(totalMatches >= 5, "min 5 matches"); 
        require(minBet > 0, "min 1 wei bet");
        uint slotCost = calcSlotPrice(wheels, totalMatches); 
        require(msg.value >= slotCost, "Insufficient credit."); 
        uint residual = slotCost - msg.value;
        uint realCost = msg.value - residual; 
        uint slotCredit = realCost / 2; 
        uint vendorEarn = realCost / 2 + residual;  
        owner.transfer(vendorEarn); 
        SlotMachine slot = new SlotMachine{value: slotCredit}(msg.sender, wheels, totalMatches, minBet);      
        return address(slot);  
    }

    function calcSlotPrice(uint wheels, uint matches) internal pure returns(uint) {
        return 1_000_000_000_000_000_000 * wheels + 1_000_000_000_000_000 * matches;  
    }

}


contract SlotMachine {

    address payable public owner; 
    uint wheels; 
    uint matches; 
    uint minbet; 

    constructor(address _owner, uint _wheels, uint _matches, uint _minbet) payable {
        require(owner != address(0), "Must select an existing address."); 
        owner = payable(_owner); 
        wheels = _wheels; 
        matches = _matches; 
        minbet = _minbet; 
    }

}