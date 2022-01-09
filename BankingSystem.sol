// SPDX-License-Identifier: UNLICENSED


pragma solidity >= 0.5.0 < 0.9.0;

contract BankingSystem {
    
    uint256 decimals;
    uint256 public totalBankFund;
    address public BankAdmin;

    struct Account {
        string holderName;
        string permanentAddress;
        string ifsc_code;
        uint256 balance;
        uint256 mobile;
        string accountNumber;
    }
    
    struct Branch{
        string branchName;
        string branch_ifsc;
        string branch_manager_name;
        uint256 branchFund;  
        address branch_manager;
    }


    uint256 numBranches;
    mapping(string => Branch) public BranchDetails;

    uint256 public totalAccounts;

    mapping(string => Account) public AccountDetails;
   
    
    constructor() payable {
        decimals = 10**18; 
        totalBankFund = msg.value * decimals;
        BankAdmin = msg.sender;
    }


    function openAccount(string memory _name , string memory _permanentAddress, 
                         string memory _ifsc_code,  uint256 _mobile, string memory _accountNumber) payable public {                             

                              
        Account storage newAccount = AccountDetails[ _accountNumber ];
        // newAccount.accountHolder =msg.sender
        newAccount.holderName = _name;
        newAccount.permanentAddress = _permanentAddress;
        newAccount.ifsc_code = _ifsc_code;
        newAccount.balance = msg.value * decimals;
        newAccount.mobile = _mobile;
        newAccount.accountNumber = _accountNumber;
        // totalBankFund += (msg.value * decimals); 
        Branch storage thisBranch = BranchDetails[_ifsc_code];
        thisBranch.branchFund += (msg.value * decimals);
        totalAccounts++;

    }

    function getAccountNumber(string memory _name, string memory _ifsc_code, uint256 _mobile) public view returns(bytes32)
    {
        bytes32 accountNumber = keccak256(abi.encodePacked( block.timestamp, _name, _ifsc_code, _mobile ));
        return accountNumber;
    }

    function transfer( string memory from_account, string memory to_account ) public payable {
        Account storage from_Account = AccountDetails[from_account];
        Account storage to_Account = AccountDetails[to_account];

        uint256 balance = (msg.value)*decimals;

        require(from_Account.balance >= balance , " does not have required Balance ");
        require(to_Account.balance > 0 , "This balance is required" );

        from_Account.balance = from_Account.balance - balance ; 
        to_Account.balance = to_Account.balance + balance ;
    }

    function withDraw( string memory from_account ) public payable{
       
        Account storage from_Account = AccountDetails[from_account];
        require(from_Account.balance > 0, "Account Does not exist ..!");
        uint256 balance = msg.value*decimals;
        require(from_Account.balance >= balance," required balance exceeds");
        payable(msg.sender).transfer(balance);
        totalBankFund -= msg.value * decimals;
    }

    function Deposit( string memory to_account ) public payable{

        Account storage to_Account = AccountDetails[to_account];
        require(to_Account.balance>0 , "account does not exist" );
        to_Account.balance = to_Account.balance + msg.value * decimals; 
        totalBankFund += msg.value * decimals; 
    }


    // admin access

     modifier onlyAdmin(){
        require(msg.sender == BankAdmin, "only manager can call this function");
        _;
    }

    function createBranch( string memory _branchName , string memory _branchIFSC , string memory _branchManagerName, uint256 _amount, address _branchManager ) public payable onlyAdmin {
        Branch storage newBranch = BranchDetails[_branchIFSC];              
        newBranch.branchName = _branchName ;
        newBranch.branch_ifsc = _branchIFSC ;
        newBranch.branch_manager_name = _branchManagerName ;
        newBranch.branchFund = _amount * decimals ; 
        newBranch.branch_manager = _branchManager ;
        totalBankFund = totalBankFund - _amount * decimals;
    }

    function editBranchManager( string memory _branchIFSC , string memory _newManagerName ,address _newBranchManager ) onlyAdmin public {
        Branch storage thisBranch = BranchDetails[_branchIFSC];
        thisBranch.branch_manager_name = _newManagerName;
        thisBranch.branch_manager = _newBranchManager;
    }

    function transferFund_BankToBranch( string memory _branchIFSC, uint256 amount ) public onlyAdmin {
        Branch storage thisBranch = BranchDetails[_branchIFSC];
        thisBranch.branchFund += amount * decimals;  
        totalBankFund = totalBankFund - (amount * decimals);
    }


    // admin and Manager access
    
    function transferFund_BranchToBank ( string memory _branchIFSC , uint256 amount ) public{
        Branch storage thisBranch = BranchDetails[ _branchIFSC ];
        require(thisBranch.branch_manager == msg.sender || BankAdmin == msg.sender ) ;
        totalBankFund = totalBankFund + (amount * decimals);
        thisBranch.branchFund = thisBranch.branchFund - (amount * decimals);
    }

    function BranchFund( string memory _branchIFSC ) public view returns(uint256){
        Branch storage thisBranch = BranchDetails[ _branchIFSC ];
        require(thisBranch.branch_manager == msg.sender || BankAdmin == msg.sender ) ;
        return thisBranch.branchFund;
    }
}