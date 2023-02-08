    // SPDX-License-Identifier: MIT

    pragma solidity >=0.7.0 <0.9.0;

    import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
    import "@openzeppelin/contracts/utils/math/SafeMath.sol";

    contract foundme{

        address owner;
        address [] public funders;

        constructor(){

            owner = msg.sender;
        }

        mapping(address => uint256) public addressToFoundMe;

        function fund(uint256 _value)public payable{

            uint256 minimunUSD = 50 * 10 ** 18;
            require(get_convertionRate(msg.value) >= minimunUSD, "You need to spend More ETH!");
            addressToFoundMe[msg.sender] += _value;
            funders.push(msg.sender);
        }

        function getVersion()public view returns(uint256){
            AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
            return priceFeed.version();
        }

        function getPrice()public view returns(uint256){
            AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
            (
                ,
                int price,
                ,
                ,
            )= priceFeed.latestRoundData();

            return uint256(price * 10000000000);
        }

        function get_convertionRate(uint256 _Ethamount)public view returns(uint256){
            uint256 ethPrice = getPrice();
            uint256 ethAmountInUsd = (ethPrice * _Ethamount)/ 1000000000000000000;
            return ethAmountInUsd;
        }

        // Modifier

        modifier onlyOwner{
            require(msg.sender == owner , "isnt the owner");
            _;
        }


        function withdraw() public onlyOwner{
            payable(msg.sender).transfer(address(this).balance);

            for(uint256 funderIndex; funderIndex < funders.length; funderIndex ++){
                address funder = funders[funderIndex];
                addressToFoundMe[funder] = 0;
            }

            funders = new address[](0);
        
        }


    }