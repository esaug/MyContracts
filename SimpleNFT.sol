// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.0 <0.6.0;

import "./ERC721full.sol";

contract Color is ERC721Full {
    string [] public colors;
    mapping(string => bool) _colorExists;

    constructor() ERC721Full("Color", "COLOR") public{}

    // Por ejemplo Color = '#FFFFFF'

    function mint(string memory _color)public {
        require(!_colorExists[_color]);
        uint _id = colors.push(_color);
        _mint(msg.sender, _id);
        _colorExists[_color] = true;
    }

}