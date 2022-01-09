
// SPDX-License-Identifier: UNLICENSED

pragma solidity >= 0.5.0 < 0.9.0;

contract CroudFunding{
    
    mapping(address => uint) public contributors;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;
    address public manager;
    
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfvoters;
        mapping(address => bool) voters;
    }
    
    mapping( uint => Request) public requests;
    uint public numRequests;
    
    constructor(uint _target, uint _deadline){
        target = _target;
        deadline = block.timestamp + _deadline;
        minimumContribution = 1 ether;
        manager = msg.sender;
    }
    
    function amountTest() public view returns(uint){
        return contributors[msg.sender];
    }
    
    function sendEther() public payable{
        require( block.timestamp < deadline, "deadline has Passed");
        require( msg.value >= minimumContribution, " minimum Contribution should be 100 wei " );
        
        if(contributors[msg.sender] == 0){
            noOfContributors++ ;
        }
        contributors[msg.sender] = contributors[msg.sender] + msg.value ;
        raisedAmount += msg.value;
    }
    
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
    
    function refund() public {
        require(block.timestamp > deadline && raisedAmount < target, "You are not eligible");
        require(contributors[msg.sender] > 0);
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }
    
    modifier onlyManager(){
        
        require(msg.sender == manager, "only manager can call this function");
        _;
        
    }
    
    function createRequest(string memory _description, address payable _recipient, uint _value) public {
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfvoters = 0;
    }
    
    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0, "you must be contributor");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender] == false , "you have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfvoters++;
    }
    
    function makePayment(uint _requestNo) public onlyManager {
        require(raisedAmount>=target);
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed == false, "The request has been completed.");
        require(thisRequest.noOfvoters > noOfContributors/2, "Majority does not support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;
    }
}