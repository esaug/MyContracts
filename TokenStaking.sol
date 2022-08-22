// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16 <0.9.0;

interface token{
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);

}

contract StakingCSY {

    address public owner;
    address public csy;


    address [] public stakers;

    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaked;


    constructor(address _csy) public{
        owner = msg.sender;
        csy = _csy;
    }


    function despositeToken(uint _amount) public {

        // Transfer Tokens to the contract

        token(csy).transferFrom(msg.sender, address(this), _amount);
    
        // Update Staking Balance

        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        if(!hasStaked[msg.sender]){
            stakers.push(msg.sender);
        }

        //staking status

        isStaked[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }


    //issue Tokens Reward

    function issueTokens() public {
        require(msg.sender == owner, "caller is not the owner");
        for(uint i=0; i<stakers.length; i++){
            address recipient = stakers[i];
            uint balance = stakingBalance[recipient];
            if(balance > 0){
                token(csy).transfer(recipient, balance);
            }
        }
    }


    //Unstake Tokens

    function unstakeTokens() public {
        
        uint balance = stakingBalance[msg.sender];
        require(balance > 0, "Staking balance cant be less than zero");

        // TRANSFER TOKENS

        token(csy).transfer(msg.sender, balance);

        // RESET STAKING BALANCE
        stakingBalance[msg.sender] = 0;

        //Update Staking update
        isStaking[msg.sender] = false;
        

    }

}
