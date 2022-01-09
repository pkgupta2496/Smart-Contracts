// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract cricket {

    address teamManager;
    // uint deadline;
    uint overs;
    string winner;
    uint totalSupply;
    address currentPlayer;
    address umpire;
    bool start = false; 
    
    struct Player{
        string playerName;
        string teamName;
        uint256 playerRun;
        // enum playerStatus{ Played, NotPlayed, Playing };
        string playerStatus;
    }    

    struct Team {
        string teamName;
        uint teamRun;
        string [] players;
        string teamCaptain;
        address teamCaptainAddress;     
    }

    // events
    event Transfer(address indexed from , address indexed to, uint tokens);
    

    mapping( address => Player ) public PlayersRecord ;
    mapping( string => Team ) public TeamsRecord  ;
    mapping( string => bool ) private Teams;
    mapping( address => uint256) public balances;
    mapping( address => bool ) public playerRegistered;
    modifier onlyManager(){
        require(msg.sender == teamManager, "only manager can call this function");
        _;
    }

    modifier onlyUmpire(){
        require(msg.sender == umpire, "only umpire can call this function");
        _;
    }
    
    function mint(uint256 _qty) private{
        totalSupply = totalSupply + _qty;
        balances[msg.sender] = balances[msg.sender] + _qty *(10**18) ;      
    }

    function transfer(address receiver, uint256 numTokens) private{
        numTokens = numTokens * (10**18);
        require(numTokens<=balances[msg.sender]);
        balances[msg.sender] -= numTokens ;
        
        balances[receiver] += numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
    }
  

    constructor() {
        teamManager = msg.sender; 
        mint(5);
    }

    function registerPlayer( string memory _playerName , string memory _teamName, address _playerAddress) onlyManager public {
        require(playerRegistered[_playerAddress] == false , "player is already registered ..!" );
        require(Teams[_teamName] == true , "This team is not registered ..!"  );
        require( (keccak256(abi.encodePacked( _teamName ))) != ( keccak256(abi.encodePacked(""))), "teamName is required" );
        require( _playerAddress  != address(0) , "playerAddress is required" );
        require( (keccak256(abi.encodePacked( _playerName ))) != ( keccak256(abi.encodePacked(""))), "playerName is required" );        
        Player storage newPlayer = PlayersRecord[_playerAddress] ;
        newPlayer.playerName = _playerName;
        newPlayer.teamName = _teamName;
        newPlayer.playerStatus = "Not Played";
        playerRegistered[_playerAddress] = true;
        PlayersRecord[_playerAddress] = newPlayer;
        Team storage team = TeamsRecord[_teamName];
        team.players.push(_playerName);
    }

    
    function createTeam( string memory _teamName , string memory _teamCaptain, address _teamCaptainAddress ) public onlyManager{
        require( (keccak256(abi.encodePacked( _teamName ))) != ( keccak256(abi.encodePacked(""))), "teamName is required" );
        require( (keccak256(abi.encodePacked( _teamCaptain ))) != ( keccak256(abi.encodePacked(""))), "teamCaptain is required" );
        
        require( _teamCaptainAddress  != address(0) , "playerAddress is required ..!" );
        
        Team storage newTeam = TeamsRecord[_teamName];
        newTeam.teamName = _teamName;
        newTeam.teamCaptain = _teamCaptain;
        newTeam.teamCaptainAddress = _teamCaptainAddress;
        newTeam.players.push(_teamCaptain);
        Teams[_teamName] = true;
        registerPlayer( _teamCaptain ,  _teamName, _teamCaptainAddress);

    }

    function startGame(address _umpire) onlyManager public {
        umpire = _umpire;    
        start = true;
    }

    function startPlayer(address _playerAddress) public{
        
        require(_playerAddress != address(0), "playerAddress is required" );
        require( currentPlayer == address(0), "Player is already Playing");
        
        require((keccak256(abi.encodePacked( PlayersRecord[_playerAddress].playerStatus ))) == (keccak256(abi.encodePacked( "Not Played" ))), "Player is not Playing");
        require( start == true, "Game is not started"); 
        currentPlayer = _playerAddress;
        PlayersRecord[_playerAddress].playerStatus = "Playing" ; 
    }

    function One() onlyUmpire public {
        require( currentPlayer != address(0), "Player is not Playing");
        PlayersRecord[currentPlayer].playerRun += 1;
        TeamsRecord[PlayersRecord[currentPlayer].teamName].teamRun += 1 ; 
    }

    function Two() onlyUmpire public {
        require( currentPlayer != address(0), "Player is not Playing");
        PlayersRecord[currentPlayer].playerRun += 2;
        TeamsRecord[PlayersRecord[currentPlayer].teamName].teamRun += 2 ; 
    }

    function Three() onlyUmpire public {
        require( currentPlayer != address(0), "Player is not Playing");
        PlayersRecord[currentPlayer].playerRun += 3;
        TeamsRecord[PlayersRecord[currentPlayer].teamName].teamRun += 3 ; 
    }

    function Four() onlyUmpire public {
        require( currentPlayer != address(0), "Player is not Playing");
        PlayersRecord[currentPlayer].playerRun += 4;
        TeamsRecord[PlayersRecord[currentPlayer].teamName].teamRun += 4 ; 
    }

     function Six() onlyUmpire public {
        require( currentPlayer != address(0), "Player is not Playing");
        PlayersRecord[currentPlayer].playerRun += 6;
        TeamsRecord[PlayersRecord[currentPlayer].teamName].teamRun += 6 ; 
    }


    function outPlayer() onlyUmpire public{
        require( currentPlayer != address(0), "Player is not Playing");
        require((keccak256(abi.encodePacked( PlayersRecord[currentPlayer].playerStatus ))) == (keccak256(abi.encodePacked( "Playing" ))), "Player is  not Playing");
        PlayersRecord[currentPlayer].playerStatus = "Played";
        currentPlayer = address(0);
    }

    function selectWinner( string memory _teamName1 , string memory _teamName2 ) public payable returns(string memory){
        require( (keccak256(abi.encodePacked( _teamName1 ))) != ( keccak256(abi.encodePacked(""))), "teamName1 is required" );
        require( (keccak256(abi.encodePacked( _teamName2 ))) != ( keccak256(abi.encodePacked(""))), "teamName2 is required" );
        require(Teams[_teamName1] == true , "This team is not registered ..!"  );
        require(Teams[_teamName2] == true , "This team is not registered ..!"  );
        Team memory team1 = TeamsRecord[ _teamName1 ];
        Team memory team2 = TeamsRecord[ _teamName1 ];
        address winnerAddress;
        if(team1.teamRun > team2.teamRun){
            payable(team1.teamCaptainAddress).transfer(msg.value);
            winner =  _teamName1;
            winnerAddress = team1.teamCaptainAddress;
        }
        else{
            payable(team2.teamCaptainAddress).transfer(msg.value);
            winner = _teamName2;
            winnerAddress = team2.teamCaptainAddress;
        }
        transfer(winnerAddress, 5);
        return winner;
    }
}