// SPDX-License-Identifier: UNLICENSED

pragma solidity >= 0.5.0 < 0.9.0;

/**
* @title Staking Token (STK)
* @author Alberto Cuesta Canada
* @notice Implements a basic ERC20 staking token with incentive distribution.
*/

contract StakingToken{

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    address public owner;


    // minting
    function _mint(address account, uint256 amount) public 
    {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
    }

    // burning 
    function _burn(address account, uint256 amount) public {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
    }

    // function to get Balance
    function balanceOf(address account) view public returns(uint){
        require(account != address(0), "not appropriate account");
        return _balances[account];
    }


    /**
    * @notice The constructor for the Staking Token.
    * @param _owner The address to receive all tokens on construction.
    * @param _supply The amount of tokens to mint on construction.
    */
   constructor(address _owner, uint256 _supply) 
   {
       owner = _owner;
       _mint(_owner, _supply);
   }



    // modifier
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    } 


    /**
     * @notice We usually require to know who are all the stakeholders.
     */
    address[] internal stakeholders;


    function isStakeholder(address _address) public view returns(bool, uint256)
    {
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           if (_address == stakeholders[s]) return (true, s);
       }
       return (false, 0);
   }

   /**
    * @notice A method to add a stakeholder.
    * @param _stakeholder The stakeholder to add.
    */
   function addStakeholder(address _stakeholder) public
   {
       (bool _isStakeholder, ) = isStakeholder(_stakeholder);
       if(!_isStakeholder) stakeholders.push(_stakeholder);
   }

   /**
    * @notice A method to remove a stakeholder.
    * @param _stakeholder The stakeholder to remove.
    */
   function removeStakeholder(address _stakeholder) public
   {
       (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
       if( _isStakeholder ){
           stakeholders[s] = stakeholders[stakeholders.length - 1];
           stakeholders.pop();
       }
   }

   /**
    * @notice The stakes for each stakeholder.
    */
   mapping(address => uint256) internal stakes;
   mapping(address => uint) meturityDeadlineRegister;

    /**
    * @notice A method to retrieve the stake for a stakeholder.
    * @param _stakeholder The stakeholder to retrieve the stake for.
    * @return uint256 The amount of wei staked.
    */
   function stakeOf(address _stakeholder) public view returns(uint256)
   {
       return stakes[_stakeholder];
   }

   /**
    * @notice A method to the aggregated stakes from all stakeholders.
    * @return uint256 The aggregated stakes from all stakeholders.
    */
   function totalStakes() public view returns(uint256)
   {
       uint256 _totalStakes = 0;
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           _totalStakes = _totalStakes + stakes[stakeholders[s]];
       }
       return _totalStakes;
   }

    /**
    * @notice A method for a stakeholder to create a stake.
    * @param _stake The size of the stake to be created.
    */
   function createStake(uint256 _stake) public
   {
       require(_stake >= 1000 , "stake value can't be zero" );
       _burn(msg.sender, _stake);
       if(stakes[msg.sender] == 0) 
       {
            addStakeholder(msg.sender);
            meturityDeadlineRegister[msg.sender] = 2 minutes; 
       }
       stakes[msg.sender] = stakes[msg.sender] + _stake;
   }

   /**
    * @notice A method for a stakeholder to remove a stake.
    * @param _stake The size of the stake to be removed.
    */

   function removeStake(uint256 _stake) public
   {
        require(block.timestamp > meturityDeadlineRegister[msg.sender], "Your Policy is not matured ..!");
        stakes[msg.sender] = stakes[msg.sender] - _stake ;
        if(stakes[msg.sender] == 0) removeStakeholder(msg.sender);
        _mint(msg.sender, _stake);
    }

    /**
    * @notice The accumulated rewards for each stakeholder.
    */
   mapping(address => uint256) internal rewards;
  
   /**
    * @notice A method to allow a stakeholder to check his rewards.
    * @param _stakeholder The stakeholder to check rewards for.
    */
   function rewardOf(address _stakeholder) public view returns(uint256)
   {
       return rewards[_stakeholder];
   }

   /**
    * @notice A method to the aggregated rewards from all stakeholders.
    * @return uint256 The aggregated rewards from all stakeholders.
    */
   function totalRewards() public view returns(uint256)
   {
       uint256 _totalRewards = 0;
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           _totalRewards = _totalRewards + rewards[stakeholders[s]];
       }
       return _totalRewards;
   }

   /**
    * @notice A simple method that calculates the rewards for each stakeholder.
    * @param _stakeholder The stakeholder to calculate rewards for.
    */
   function calculateReward(address _stakeholder) public view returns(uint256)
   {
       uint calculatedReward = 0;
       if(block.timestamp > meturityDeadlineRegister[_stakeholder] + 5 minutes){
           calculatedReward = stakes[_stakeholder] * 10/100;
       }
       else if( block.timestamp > meturityDeadlineRegister[_stakeholder]   || block.timestamp < meturityDeadlineRegister[_stakeholder] + 5 minutes )
       {
           calculatedReward = stakes[_stakeholder] * 5/100; 
       }
       else if(block.timestamp <= meturityDeadlineRegister[_stakeholder]){
           calculatedReward = stakes[_stakeholder] / 100;
       }
       return calculatedReward;
   }

   /**
    * @notice A method to distribute rewards to all stakeholders.
    */
   function distributeRewards() public onlyOwner
   {
       for (uint256 s = 0; s < stakeholders.length; s += 1)
       {

            address stakeholder = stakeholders[s];
            uint256 reward = calculateReward(stakeholder);
            rewards[stakeholder] = rewards[stakeholder] + reward;
       }
   }

   /**
    * @notice A method to allow a stakeholder to withdraw his rewards.
    */
   function withdrawReward() public
   {
       require(block.timestamp > meturityDeadlineRegister[msg.sender], "Your Policy is not matured ..!");
       uint256 reward = rewards[msg.sender];
       rewards[msg.sender] = 0;
       _mint(msg.sender, reward);
   }

}