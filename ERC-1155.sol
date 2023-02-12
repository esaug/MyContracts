pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC1155/ERC1155.sol";

contract MyERC1155 is ERC1155 {
    constructor() public {

        // Numero del token --- Cantidad de Copias
        _mint(msg.sender, [1, 2, 3, 4, 5], [100, 200, 300, 400, 500]);
    }

    function transfer(address[] memory _to, uint256[] memory _ids, uint256[] memory _values) public {
        require(_to.length == _ids.length, "Invalid number of recipients");
        require(_to.length == _values.length, "Invalid number of amounts");
        _transferMultiple(_to, _ids, _values);
    }
} 

// EXAMPLE TOKEN 1155