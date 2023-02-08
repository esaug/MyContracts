// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenSelector is Ownable{

    mapping(uint256 => token) public tokens;

    string [] public ArraySimbols;
    uint256 [] public ArrayIdTokens;

    struct token{
        string simbol;
        string name;
        address direction;
        address oraculo;
        string red_oraculo;
    }

    uint256 public id;


    function add_token(string memory _siglas,string memory _name, address _address, address _address_oraculo, string memory _red_oraculo) external onlyOwner {

        tokens[id] = token( _siglas, _name, _address, _address_oraculo, _red_oraculo);
        ArraySimbols.push(_siglas);
        ArrayIdTokens.push(id);
        id++;

    }

    function get_token_address(uint256 _id)external view returns(address){

        return tokens[_id].direction;
    }

    function get_token_oraculo(uint256 _id)external view returns(address){

        return tokens[_id].oraculo;
    }
    

    function get_simbols()external view returns(string [] memory){
        return ArraySimbols;
    }

    function get_ArrayIdTokens()external view returns(uint256 [] memory){
        return ArrayIdTokens;
    }

} 