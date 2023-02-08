// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


interface IERC20 {
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);


}

interface tokensSelector{

    function add_token(string memory _siglas,string memory _name, address _address)external;
    function get_token_address(uint256 _id)external view returns(address);
    function get_simbols()external view returns(string [] memory);
    function Cantidad_tokens()external view returns(uint256);
    function get_Simbols()external view returns(string [] memory);
    function all_directions()external view returns(address [] memory );

    
}

contract faucet is Ownable {

    IERC20 token;
    tokensSelector all_tokens;
    address public _owner;
    address public token_holder = 0xD7E024b704A32022596a15c853d4682248482bE8;
    uint public amountAllowed = 100000000000000000000;

    mapping(address => uint) public lockTime;


    struct token_array{
        string simbol;
        address direction;
    }

    constructor(){
        _owner = msg.sender;
    }

    function set_amountAllowed(uint256 _amount)public onlyOwner{
        amountAllowed = _amount;
    }

    function resquestPayable(uint256 _id, address _address)public{

        //SELECTOKEN 

        token = IERC20(tokensSelector(all_tokens).get_token_address(_id));

        require(block.timestamp > lockTime[_address], "lock time has not expired. Please try again later");
        require(token.balanceOf(address(this)) > amountAllowed, "Not enough funds in the faucet. Please donate");

        token.transfer(_address ,amountAllowed);

        lockTime[_address] = block.timestamp + 1 days;
    }

    function balance_contract() public view returns(uint256){

        uint256 balance = token.balanceOf(address(this));
        uint256 balanceConverted = balance / 10**18;
        return balanceConverted; 
    
    
    }

    function set_tokenSelector(address _address)public onlyOwner{
        all_tokens = tokensSelector(_address); 
    }

    function cantidadTokens()public view returns(uint256){
        return tokensSelector(all_tokens).Cantidad_tokens();
    }


}