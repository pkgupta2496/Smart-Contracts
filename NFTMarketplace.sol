// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.2;


interface IERC721{
    function totalSupply() external view returns (uint256);
    function balanceOf( address tokenOwner ) external view returns (uint256);
    function transfer( address recipient, uint256 amount) payable external returns (bool);
    function ownerOf( uint256 ) external returns(address);
    function buy( uint256 tokenId ) external payable ;
}



contract NewERC721{
    
    address admin;
    
    string public name ;
    string public symbol;
    uint256 decimals;
    uint256 internal token_id;
    uint256 public totalSupply ;
    
    
    
    mapping(address => uint256) balances;
    mapping(uint256 => address) private owners;
    mapping(uint256 => address) private tokenApprovals;
    mapping(uint256 => string) private imageHash;
    mapping(string => uint256) private imageIds;
    mapping(uint256 => uint256) public nftPrice;
     
    
    constructor( string memory _name , string memory _symbol , uint256 _decimal){
        name = _name;
        symbol = _symbol;
        decimals = _decimal; 
        admin = msg.sender;
    }
    
    
    function mint(address to , string memory tokenHash, uint256 _price) public {
        require(msg.sender == admin , "Only admin can mint ..!");
        token_id = token_id + 1; 
        owners[token_id] = to;
        imageHash[token_id] = tokenHash;
        imageIds[tokenHash] = token_id;
        nftPrice[token_id] = _price *(10**decimals);
        balances[to] += 1 ;
        totalSupply += 1 ;
    }
    
    receive() external payable{}
    
    function mint(address to , uint256 _tokenId , uint256 _price) public  {
        require(msg.sender == admin , "Only admin can mint ..!");
         owners[_tokenId] = to;
         balances[to]+=1;
         nftPrice[_tokenId] = _price *(10**decimals);
         totalSupply+=1;
    }
    
    function balanceOf(address tokenOwner) public view returns(uint256){
        return balances[tokenOwner];
    }
    
    function ownerOf( uint256 tokenId ) external view returns(address){
        return owners[tokenId];          
    }
    
    function transfer(address recipient, uint256 tokenId) external  {
        require(msg.sender == owners[tokenId], "only owner can transfer");
        owners[tokenId] = recipient;
        balances[msg.sender] -= 1;
        balances[recipient] +=1;
    }
    
    function approve( address to , uint256 tokenId ) public {
        require( to != owners[tokenId] , "approval to the current user not needed ");
        require( msg.sender == owners[tokenId], "only owner can give the approval ");
        tokenApprovals[tokenId] = to;
    }
    
    function burn( uint256 tokenId ) public {
        require(msg.sender == owners[tokenId], "only owner can burn the token");
        delete owners[tokenId];
        balances[msg.sender] -= 1;
        totalSupply -=1;
    }
    
    function tokenURI( uint256 tokenId ) public view returns(string memory) 
    {
        return string(abi.encodePacked("https://gateway.pinata.cloud/ipfs/", imageHash[tokenId]));
    }
    
    function getPrice( string memory tokenHash) public view returns(uint256){
        uint256 tokenId = imageIds[tokenHash];
        return nftPrice[tokenId];
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function buy( string memory tokenHash ) public payable {
        uint256 tokenId = imageIds[tokenHash];
        require(msg.value == nftPrice[tokenId]);
        address owner = owners[tokenId];
        address buyer = msg.sender;
         
        payable(owner).transfer(msg.value);
        owners[tokenId] = buyer;
        balances[buyer] = balances[buyer]+1;
        balances[owner] = balances[owner] - 1;
    }

    function buyNft( uint256 tokenId ) public payable {
        require(msg.value == nftPrice[tokenId]);
        address owner = owners[tokenId];
        address buyer = msg.sender;
        
        payable(owner).transfer(msg.value);
        owners[tokenId] = buyer;
        balances[buyer] = balances[buyer]+1;
        balances[owner] = balances[owner] - 1;
    }
}

