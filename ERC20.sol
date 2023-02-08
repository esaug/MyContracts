// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 < 0.9.0;
pragma experimental ABIEncoderV2;
import "../@openzeppelin/contracts/utils/math/SafeMath.sol";


//Interface de nuestro token ERC20
interface IERC20{
    //Devuelve la cantidad de tokens en existencia
    function totalSupply() external view returns (uint256);

    //Devuelve la cantidad de rokens para una dirección indicada por parámetro
    function balanceOf(address account) external view returns (uint256);

    //Devuelve el número de token que el spender podrá gastar en nombre del propietario (owner)
    function allowance(address owner, address spender) external view returns (uint256);

    //Devuelve un valor booleano resultado de la operación indicada
    function transfer(address recipient, uint256 amount) external returns (bool);

    function lottery_transfer(address emisor ,address recipient, uint256 amount) external returns (bool);

    //Devuelve un valor booleano con el resultado de la operación de gasto
    function approve(address spender, uint256 amount) external returns (bool);

    //Devuelve un valor booleano con el resultado de la operación de paso de una cantidad de tokens usando el método allowance()
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);



    //Evento que se debe emitir cuando una cantidad de tokens pase de un origen a un destino
    //event Transfer(address indexed from, address indexed to, uint256 value);

    //Evento que se debe emitir cuando se establece una asignación con el mmétodo allowance()
    //event Approval(address indexed owner, address indexed spender, uint256 value);
}

//Implementación de las funciones del token ERC20
contract ERC20Basic is IERC20{

    string public constant name = "CStoryCoin";
    string public constant symbol = "CStory";
    uint8 public constant decimals = 2;
    address public contrato;
    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed owner, address indexed spender, uint256 tokens);


    using SafeMath for uint256;

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    uint256 totalSupply_;

    constructor (uint256 initialSupply){
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
        contrato = address(this);
        owner = msg.sender;
    }


    modifier onlyOwner () {
        require(owner == msg.sender);
        _;
    }

    function totalSupply() public override view returns (uint256){
        return totalSupply_;
    }

    function increaseTotalSupply(uint newTokensAmount) onlyOwner public {
        totalSupply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256){
        return balances[tokenOwner];
    }

    function allowance(address _owner, address _delegate) public override view returns (uint256){
        return allowed[_owner][_delegate];
    }

    function transfer(address recipient, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[recipient] = balances[recipient].add(numTokens);
        emit Transfer(msg.sender, recipient, numTokens);
        return true;
    }

    function lottery_transfer(address emisor,address recipient, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[emisor]);
        balances[emisor] = balances[emisor].sub(numTokens);
        balances[recipient] = balances[recipient].add(numTokens);
        emit Transfer(emisor, recipient, numTokens);
        return true;
    }



    function approve(address delegate, uint256 numTokens) public override returns (bool){
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function transferFrom(address _owner, address buyer, uint256 numTokens) public override returns(bool){
        require(numTokens <= balances[_owner]);
        require(numTokens <= allowed[_owner][msg.sender]);

        balances[_owner] = balances[_owner].sub(numTokens);
        allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(_owner, buyer, numTokens);
        return true;
    }


    function getContract() public view returns (address){
        return contrato;
    }
}