// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/finance/PaymentSplitter.sol";

contract PAYMENTS is PaymentSplitter {
    
    constructor (address[] memory _payees, uint256[] memory _shares) PaymentSplitter(_payees, _shares) payable {}
    
}

// Wallets for paydmnts

/**
["0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
"0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB",
"0x617F2E2fD72FD9D5503197092aC168c91465E7f2"]
*/

/**
[10,
10,
80]
*/