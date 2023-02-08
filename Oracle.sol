// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract priceConsumer {

    AggregatorV3Interface internal priceFeed;

    address constant priceFeedAddress = 0x116EeB23384451C78ed366D4f67D5AD44eE771A0;

    constructor() {
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function getLastPrice() public view returns(int){
        (
            uint roundId,
            int answer,
            uint startedAt,
            uint updatedAt,
            uint answeredInRound
        ) = priceFeed.latestRoundData();

        return answer;

    }

} 