// SPDX-License-Identifier: MIT

pragma solidity ^0.8;
 
 contract toke {
     
     string public name;
     string public symbol;
     uint8 public decimals;
     uint256 public totalSupply;
     mapping(address => uint256) public balanceOf;
     mapping (address => mapping(address => uint256)) public allowance;

     event _transfer(address indexed _from, address indexed _to, uint256 _value); 
     event _approval(address indexed owner, address _spender, uint256 _value);

     constructor() public {
         name = "Ethereum- prueba";
         symbol = "ETH-P";
         decimals = 18;
         totalSupply = 10000 *(uint256(10) ** decimals);
         balanceOf[msg.sender] = totalSupply;
     }

     function transfer(address _to, uint256 _value)public returns (bool _success){
         
         uint _total = _value * (uint256(10) ** decimals); 
         
         require(balanceOf[msg.sender]>= _total);
         balanceOf[msg.sender] -= _total;
         balanceOf[_to] += _total;

         emit _transfer(msg.sender, _to, _value);
     }


     function aprobar(address _spender, uint256 _value)public returns(bool _success){
         
         uint256 _total = _value * (uint256(10) ** decimals); 
         
         allowance[msg.sender][_spender] = _total;
         emit _approval(msg.sender, _spender, _value);
         return true;
     }

    function _transferFrom(address _from, address _to, uint256 _value)public returns(bool _sucees) {

        uint _total = _value * (uint256(10) ** decimals);  

        require(balanceOf[_from] >= _total);
        require(allowance[_from][msg.sender] >= _total);
        balanceOf[_from] -= _total;
        balanceOf[_to] += _total;
        allowance[_from][msg.sender] -= _total;
        emit _transfer(_from, _to, _total);
        return true;
    }


 }