// SPDX-License-Identifier: UNLICENSED

pragma solidity >= 0.5.0 < 0.9.0;

contract Lottery{
    
    address public manager;
    address payable[] public participants;
    
    constructor(){
        manager = msg.sender;
    }
    
    receive() external payable
    {
        require(msg.value >= 1 ether);
        participants.push(payable(msg.sender));
    }
    
    function getBalance() public view returns(uint)
    {
        require(msg.sender == manager , "caller should be manager" );
        return address(this).balance;
    }
    
    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
    }
    
    function selectWinner() payable public returns(address) {
        require(msg.sender == manager);
        require(participants.length>=3 , "participants should be greater than three");
        uint256 r = random();
        address payable winner;
        uint index = r % participants.length;
        winner = participants[index];
        winner.transfer(getBalance());
        participants = new address payable[](0);
        return winner;
    }
}