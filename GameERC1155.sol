// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";


contract game is ERC1155{

    // ITEMS 

    uint256 public constant GOLD;
    uint256 public constant SILVER;
    uint256 public constant SWORD;
    uint256 public constant SHIELD;
    uint256 public constant HELMET; 


    constructor() ERC1155("https://game.example/api/item/{id}.json"){
        
        // MINT ITEMS FUNGIBLES AND NO FUNGILES

        _mint(msg.sender, GOLD, 10**18,"");
         _mint(msg.sender, SILVER, 10**27,"");
          _mint(msg.sender, SWORD, 10,"");
           _mint(msg.sender, SHIELD, 10**9,"");
            _mint(msg.sender, HELMET, 10**9,"");
        
    }
}
