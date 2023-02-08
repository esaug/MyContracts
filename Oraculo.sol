// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface tokens{

    function get_token(uint256 _id)external view returns(address);
    function get_token_oraculo(uint256 _id)external view returns(address);
    function get_simbols()external view returns(string [] memory);
    function get_ArrayIdTokens()external view returns(uint256 [] memory);

}


contract OraculoPrecios is Ownable{

    address _AllTokens;

    // ADD ALAMCEN DE TOKENS

    function set_tokens(address _address)public onlyOwner{
        _AllTokens = _address;
    }

    // INDIVIDUAL TOKEN PRICE

    function get_price(uint256 _id)public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(tokens(_AllTokens).get_token_oraculo(_id));
        (
            ,
            int price,
            ,
            ,
        )= priceFeed.latestRoundData();

        return uint256(price * 10000000000);
    }

    // CONVERTION PAIDMENT PRICE IN TOKEN WEI PRICE 

    function get_convertionRate(uint256 _amount, uint256 _id)external view returns(uint256){
        uint256 amount_wei = _amount * 1000000000000000000;
        uint256 division = ((amount_wei * 1000)/get_price(_id));
        return division * 1000000000000000;
    }


}