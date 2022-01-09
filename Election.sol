// SPDX-License-Identifier: UNLICENSED

pragma solidity >= 0.5.0 < 0.9.0;

contract Election{
    
    address electionCommission;
    uint public numRequests;
    address winningNominee;
    uint public deadline;

    event approve_nominee(address owner);

    constructor(){
        electionCommission = msg.sender;
    }

    struct NomineeRequest{
        address NomineeAddress; 
        string NomineeName;   
        uint age;
    } 

    struct Nominee{
        address NomineeAddress;
        string NomineeName;
        uint NomineeAge;
        uint noOfVote;
        string symbol;
        uint BallotNumber;
    }
    
    mapping( uint => NomineeRequest) public requests;
    mapping( address => bool) public voterRegister ;
    mapping( address => Nominee) public selectedNominee;
    mapping( address => bool) private RequestRegister;
    mapping(address=>bool) private ApprovedNominee; 

    modifier onlyElectionCommission(){
        require(msg.sender == electionCommission, "only manager can call this function");
        _;
    }  

    function startingVoting(uint _deadline) public {
        deadline = block.timestamp + _deadline;
    }

    function requestForNomineeRequest(string memory name , uint age) public {
        require(RequestRegister[msg.sender] == false , "You have already Registered" );
        require(age >= 18 , "You are not eligible for NomineeRequest ..!" );
        NomineeRequest storage newRequest = requests[numRequests++];
            newRequest.NomineeName = name;
            newRequest.NomineeAddress = msg.sender;
            newRequest.age = age;
            RequestRegister[msg.sender] = true;
    }

    function approveNominee( uint requestNo , string memory _symbol, uint _ballotNo ) public {
        require(electionCommission == msg.sender, "only ellection commission can access ..!");
        NomineeRequest storage Request = requests[requestNo];  
        require(ApprovedNominee[Request.NomineeAddress] == false, "already approved ..!");
        Nominee storage newNominee = selectedNominee[Request.NomineeAddress];
        newNominee.NomineeName = Request.NomineeName;
        newNominee.NomineeAge = Request.age;
        newNominee.symbol = _symbol;
        newNominee.BallotNumber = _ballotNo;
        ApprovedNominee[Request.NomineeAddress] = true;
        emit approve_nominee(msg.sender);
    }

    function casteVote( address nomineeAddress) public{
        require(block.timestamp < deadline, "Time has Passed ..!" );
        require( voterRegister[msg.sender] == false, "You have already casted the Vote ..!" );
        require( ApprovedNominee[nomineeAddress] == true, "Nominee is not selected ..!" );
        Nominee storage nominee = selectedNominee[nomineeAddress];
        nominee.noOfVote += 1;
        if(nominee.noOfVote > selectedNominee[winningNominee].noOfVote){
            winningNominee = nomineeAddress;
        }
        voterRegister[msg.sender] = true;
    }    

    function selectWinner() public view onlyElectionCommission returns(string memory){
        require(block.timestamp > deadline, "Voting is going on ..!" );
        address winner = winningNominee ;
        Nominee storage nominee = selectedNominee[winner];
        return nominee.NomineeName;
    }
}