// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC20.sol";


 contract loteria is Ownable{

    ERC20Basic private token; 

    address public _owner;
    address public contrato;
    uint  tokens = 10000;

    constructor ()   {

        token = new ERC20Basic(tokens);
        _owner = msg.sender;
        contrato = address(this);
    }

    //Buying token event / evento de compra de tokens

    event buyingTokens(uint, address);
    event boleto_ganador(uint);
    event tokens_devueltos(uint, address);

    //---------------------------------Token -----------------------------------/

    // set precie of tokens 

 function priceTokens(uint _numTokens) internal pure returns(uint){
     return _numTokens *(1 ether);
 }

 
    // increase number of tokens / incrementar numero de tokens


 function increseTokenSupply(uint _numTokens) public onlyOwn(msg.sender) {
     token.increaseTotalSupply(_numTokens);
 }

  modifier onlyOwn(address _address){
      require(_address == _owner, "You dont have enough permission");
      _;
  }

  // comprar tokens para loteria / buying tokens for the lottery

 function buyTokens(uint _numTokens)public payable{
     
     address _to = msg.sender;
     //calculador de coste del token / calculate the cost of a token 
     uint coste = priceTokens(_numTokens);
     // Se requiere que el valor de coste de ether a pagar sean igual al coste / it require that ether value to be equal to the pay cost
     require(msg.value >= coste, "You dont have enough money");
     // Diferencia a pagar
     // Difference of the paidment 
     uint returnValue = msg.value - coste; 
     // Different transfer 
     // Diferencia de la transferencia
     payable(_to).transfer(returnValue);
     // Contract balance
     //balance del contrato
     uint Balance = TokensAvailable();
     // Filtro para evaluar los tokens disponibles 
     // filter for tokens availability
     require(_numTokens <= Balance, "Compra un numero de tokens adecuados");
     // transferencia de tokens al comprador
     // Transfer tokens to the buyer
     token.transfer(msg.sender, _numTokens);
    //Emit buying tokens event
    //Evento de compra de tokens
     emit buyingTokens(_numTokens, msg.sender);

 }


// Balance del contrato de loteria
//Contract lottery balance 

 function TokensAvailable() public view returns(uint) {

     return token.balanceOf(contrato);

 }

 // Obtener cantidad de tokens acumulados en el bote 
 //obtain quantity of acumulate tokens

  function Bote() public view returns(uint) {
      return token.balanceOf(_owner);
  }

  // Balance de tokens de una persona 
  // Balance of tokens of a human wallet 

  function myTokens()public view returns(uint){
      return token.balanceOf(msg.sender);
  }
    

    //---------------------------------Lottery -----------------------------------/

    
    //precio del boleto en tokens
    //ticket price in tokens
    uint public ticketPrice = 5;
    // mapping relacion persona
    //relation mapping  
    mapping(address => uint[]) idPersona_boletos;
    // Relacion necesaria para identificar al ganador
    // Relations for identifying winners
    mapping(uint => address) ADN_boleto;
    //Numero aleatorio
    //Random number
    uint randNonce = 0;
    //Boletos generados
    //Generated Tickets
    uint [] boletos_comprados;
    //Eventos
    //Events
    event boleto_comprado(uint, address); // evento cuando se compra un boleto // Events when a person bought a ticket
    event boleto_ganador(uint, address); // evento del ganador // Event of the winner 

    // funcion para comprar boletos de loteria // function for buying lottery tickets

    function BuyTickets(uint _tickets) public {
        //precio total de los boletos a comprar
        // total price of the tickets
        uint totalPrice = _tickets * ticketPrice;
        //Filtrado de los tokens a pagar
        //tokens filters
        require(totalPrice <= myTokens(), "You dont have enough tokens");
        token.lottery_transfer(msg.sender, _owner, totalPrice);

        // Lo que esto hace es tomar la marca de tiempo actual del mesg.sender y un nounce
        //What this does is to take the current timestamp from the mesg.sender and a nounce

        for(uint i = 0; i < _tickets; i++){
            uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 1000;
            randNonce ++;
            //Almacenar los datos de los boletos 
            // storage ticket data
            idPersona_boletos[msg.sender].push(random);
            //Numero de boletos comprados
            //Number of bought tickets 
            boletos_comprados.push(random);
            //Asignar ADN del boleto a la persona
            // asing ticket ADN to a wallet
            ADN_boleto[random] = msg.sender;
            // Emitir evento de boleto comprado
            //Event emit when someone bouth a ticket
            emit boleto_comprado(random, msg.sender);

        }
    }

    // Visualizar el numero deboletos de una personas
    //visualize the number of tickets of a person

    function yourTickets()public view returns (uint [] memory){
        return idPersona_boletos[msg.sender];
    }



    // Funcion Ganador
    // Winner function  

    function generateWinner()public onlyOwn(msg.sender){
        //Deben haber boletos comprados 
        //you should haver tickets bought 
        require(boletos_comprados.length > 0, "Noone hasbeen bought tickets");
        // Declaracion de longitud del array 
        // array longitud declaration
        uint longitud = boletos_comprados.length;
        // Aleatoriamente elijo un numero entre 0 y la longitud
        //random numbers 0 to the array longitud
        uint position_array = uint(uint(keccak256(abi.encodePacked(block.timestamp)))%longitud);
        //posicion del array
        //array position
        uint eleccion = boletos_comprados[position_array];
        //Emitir evento ganador
        //Emit generator event
        emit boleto_ganador(eleccion);
        // Direccion del ganador
        //Winner address
        address winner_direction = ADN_boleto[eleccion];
        //Enviar premio
        //Send prize
        token.lottery_transfer(msg.sender, winner_direction, Bote());

    }

    // Cambiar tokens por ethers
    // Change tokens for ethers 

    function devolverTokens(uint _numberTokens)public payable{
        address _to= msg.sender;
        // numero de tokens de devolver debe ser mayor a 0
        // the number of tokens should greater than 0
        require(_numberTokens > 0, "You dont have tokens");
        // el usuario debe tener la cantidad de tokens que quiere devolver 
        // the user should have the quantity of tokens to change
        require(_numberTokens <= myTokens(), "You dont have enough tokens");

        //Devolucion // change tokens
        //1. El cliente devuelve los tokens // the client change the tokens
        //2. La loteria paga los tokens devueltos en ethers // the lottery pay the change tokens 
        token.lottery_transfer(msg.sender,address(this), _numberTokens);
        payable(_to).transfer(priceTokens(_numberTokens));
        //Quien devuelve
        // who change the tokens
        emit tokens_devueltos(_numberTokens, msg.sender);
    }

 }

    