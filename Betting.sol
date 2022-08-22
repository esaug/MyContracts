// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface BEP20 {
     
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
}
 


contract Apuestas is Ownable {

    address public _owner;
    address public _contract;
    address public pool1 = 0xD7E024b704A32022596a15c853d4682248482bE8;
    address public tokenBUSD = 0x98C8c519a2F19687B94F2011A0a2F5380a0e5f56;
    address public cobro_casa = 0x678A693f339Ab10437ca01FD9C6715BBAED5c381;

    // Activation 

    bool public activation = false;

    uint public minimo_de_retiro = 10000000000000000000;
    uint public minimi_de_deposito = 10000000000000000000;
    uint public porcentaje = 5;


    constructor() {
        _owner = msg.sender;
        _contract = address(this);

    }

    // Events

    event _transfer(address indexed from, address indexed to, uint value);
    event _withdraw(address indexed pool, address indexed receiver, uint256 value);

    // Activation

    function Activation(bool _value)public onlyOwner returns(bool){

        activation = _value;
        return activation;
    }


    //Transfer Token to a Wallet

    function Deposito(uint _value, uint _tipe)public returns(bool _done){
        
        MultiTransferToken(_value, _tipe);
        emit _transfer(msg.sender, pool1, _value);
        return true;
    }

    //Multi tokens 

    function MultiTransferToken(uint _value, uint _tipe)public returns(bool _done){

        if(_tipe == 1){
                require(_value > minimi_de_deposito);
                BEP20(tokenBUSD).transferFrom(msg.sender, pool1, _value);
            return true;
        }
    }

    //WITHDRAW

    function Withdraw(address _receiver,uint _value)public onlyOwner returns(bool _done){

        uint enviar = _value;
        uint lo_deLaCasa = enviar * porcentaje / 100;
        uint transferir_Persona  = enviar - lo_deLaCasa;

        require(_value > minimo_de_retiro,"You dont have enough Balance");
        BEP20(tokenBUSD).transferFrom(pool1, _receiver, transferir_Persona);
        BEP20(tokenBUSD).transferFrom(pool1, cobro_casa, lo_deLaCasa);
        emit _withdraw(pool1, _receiver, _value);
        return true;
    }

    //Balance 

    function balance(address _address)public view returns(uint) {
        uint balance_Address = BEP20(tokenBUSD).balanceOf(_address);
        return balance_Address;
    }

    //Paidment Address 

    function billetera_cobro(address _address)public onlyOwner returns(bool){
        cobro_casa = _address;
        return true;
    }
    
}