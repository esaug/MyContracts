// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./ERC721full.sol";
import "@openzeppelin/contracts/utils/Strings.sol";



interface BEP20Base {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract NFT is ERC721{

    //Contract Addres
    address contrato;
    //Owner
    address _owner;
    
    // Receiver
    address _receiver = 0xece6fFFF5Ad61A2dC2e2DcF94a46554c0933d549;
    
    //Guardar armas NFT
    weapon [] public weapons;
    

   // Max SUPPLY 
    uint256 public supplyMax = 9999;
    uint public maxMintAmount = 20;
   

    // Wallet by NFT 
    mapping(address => uint256[]) private ownerByTokenId;
    mapping(uint => address) private tokenIdByOwner;

    // REVEALED 

    bool public revealed = true;
    string public notRevealedUri;

    //Badse URI
    string baseURI;
    string public baseExtension = ".json";



    // NFT PRICES 

    uint commond_price = 10000000000000000000;
    uint rare_price = 20000000000000000000;
    uint epic_price = 40000000000000000000;
    uint legendary_price = 80000000000000000000;
    uint supreme_price = 160000000000000000000;

    //NONCES

    uint nonce;
    uint nonce1 = 2;
    uint nonce2 = 3;
    uint nonce3 = 4;
    uint nonce4 = 1;


    //Contador NFT
    uint public counterNFT = 0 ;
    //Activador
    bool public active = false;
    //Cuerpo del NFT

    
    
    struct weapon{
        uint id;
        uint stars;
        string name;
        string tpe;
        string class;
        string rarity;    
    }
    
    // Token

    address public _token;

    //minting event

    event whoMinted(address, uint);

    constructor() ERC721("NFT", "CSTORYNFT") payable{
        contrato = address(this);
        _owner = msg.sender;
        _token = 0x98C8c519a2F19687B94F2011A0a2F5380a0e5f56;

    }

    function onlyOwner() private view{
        require(msg.sender == _owner, "N/O");
    }

     function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
    
    function mint (uint _rarity, uint _value,uint _amount) public payable{
    

        //requerimientos
        require(active == true, "SN/o A");
        require(_rarity > 0, "N/R"); 

        if(msg.sender != _owner){
            NFTPrice(_rarity, _value, _amount);
            
        }

        


        uint randNum = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 100;
       
        nonce++;
        

       
        //////////


        //Ririties
        string [5] memory rarities = ["Commond", "Rare", "Epic", "Legendary", "Supreme"];

        
        // STARS
    
        uint stars = Stars(randNum);

        //Create Stats of a weapon
        

        //Save NFT weapons
        weapon memory newWeapon = weapon(counterNFT, stars, nombres(randNum, _rarity), "sword", "warrior", rarities[_rarity-1]);
        weapons.push(newWeapon);

        //Reference WALLET to ID - ID to WALLET
        ownerByTokenId[msg.sender].push(counterNFT);
        tokenIdByOwner[counterNFT] = msg.sender;

        //minteo
        _mint(msg.sender, counterNFT);
        // quien minteo?
        emit whoMinted(msg.sender, counterNFT);

        // URI CHANGER

        URI_Changer(_rarity);

        //contador     
        counterNFT++;

    }



    // Precios de los NFT

    function NFTPrice(uint _rarity, uint _value, uint256 _amount)internal {
        
        uint precio;

        if(_rarity == 1){

            require(_value >= commond_price);
            precio= _value * _amount;
            BEP20Base(_token).transferFrom(msg.sender, _receiver, precio);
        }
        else if(_rarity == 2){
            
            require(_value >= rare_price);
            precio= _value * _amount;
            BEP20Base(_token).transferFrom(msg.sender, _receiver, precio);
        }
        else if(_rarity == 3){
            
            require(_value >= epic_price);
            precio= _value * _amount;
            BEP20Base(_token).transferFrom(msg.sender, _receiver, precio);
        }               
        else if(_rarity == 4){

            require(_value >= legendary_price);
            precio= _value * _amount;
            BEP20Base(_token).transferFrom(msg.sender, _receiver, precio);
            
        }
        else {
            require(_value >= supreme_price);
            precio= _value * _amount;
            BEP20Base(_token).transferFrom(msg.sender, _receiver, precio);
        }
    }

    // NFT nombres

    function nombres(uint _name, uint _rarity)internal pure returns(string memory _nombre){

        string memory nombre;
        string [10] memory names = ["Sword", "Benemic", "Samurai", "Katum", "Ruined King", "Vampire", "Joyeuse", "Blood drop", "Dragon Bone", "Havoc"];

        if(_rarity == 1){
            if(_name < 65){
                return nombre = names[0]; 
            } else{
                return nombre = names[1];
            }
        }else if(_rarity == 2){
            if(_name < 50){
                return nombre = names[2];
            } else{
                return nombre = names[3];
            }
        }else if(_rarity == 3){
            if(_name < 50){
                return nombre = names[4];
            } else {
                return nombre = names[5];
            }
        }else if(_rarity == 4){
            if(_name < 50){
                return nombre = names[6];
            } else{
                return nombre = names[7];
            }
        }else{
            if(_name < 50){
                return nombre = names[8];
            } else{
                return nombre = names[9];
            }
        }
    }


    // CHANGE ALTERE RANDOMNESS

    function Stars( uint _randomNumber) internal pure returns(uint _star){
                
        if(_randomNumber < 50){
            return 1;
        } else if(_randomNumber > 50 && _randomNumber < 75){
            return 2;
        } else if(_randomNumber > 75 && _randomNumber <= 100){
            return 3;
        }
    }


    //Ver todos los NFT

  function getAllNFT() public view returns(weapon[]memory){
      return weapons;
  }

  

  // Armas de una direccion en especifico

  // URI CHANGER

  function URI_Changer(uint _rarity) internal{
      string [3] memory CIDs = ["ipfs://Qmf3fUtRECtERGHbPXPvLSEuZqXBZgMnAW23E84NvjRS6z/","ipfs://QmWRQBSapx6NmNuDXdE2NCr64baTFgma7KbNTkRm65ZGBX/",
      "ipfs://QmSdvuYsEiykAhU2aqTRjYoC6WvS1cdsySZS6as8oJk5Pu/"];

      if(_rarity == 1){

          set_BaseURI(CIDs[_rarity - 1]);

      }else if(_rarity == 2){

          set_BaseURI(CIDs[_rarity - 1]);

      } else if(_rarity == 3){

          set_BaseURI(CIDs[_rarity - 1]);

      }
  }



    function getOwnerArmasNFT(address _from) public view returns (weapon[] memory){
        
        weapon[] memory result = new weapon[](balanceOf(_from)); 
        uint256 counter = 0;
        for (uint256 i = 0 ; i < weapons.length; i ++){
            if(ownerOf(i) == _from) {
                result[counter] = weapons[i];
                counter ++;
            }   
        }
        return result ;

    }

     //GET TOKENS by OWNER 

     function get_ownerTokens(address _address) public view returns (uint256[] memory) {
      return ownerByTokenId[_address];
    }

     //GET Owner of a Token

     function get_tokensByOwner(uint256 _tokenId) public view returns (address) {
      return tokenIdByOwner[_tokenId];
    }


    // TRANSFER NFT 

    function transfer(address _from, address _to, uint256 _tokenId) public  returns(bool){
        _transfer(_from, _to, _tokenId);
        delete ownerByTokenId[_from][_tokenId];
        ownerByTokenId[_to].push(_tokenId);
        return true;
    }

    //  -----------------ONLY OWNER-------------------

    // Activacion del minteo

    function activacion()public{
        onlyOwner();
        active = !active;
    }


    // RETIRAR DEL CONTRATO


    function withdraw() public payable{
        onlyOwner();
        (bool os, ) = payable(_owner).call{value: address(this).balance}("");
        require(os);
    }

    

    // EDIT NFT PRICE 

    function set_Commond_price(uint _newPrice) public returns(bool){
        onlyOwner();
        commond_price = _newPrice;
        return true;
    }

    function set_Rare_price(uint _newPrice) public returns(bool){
        onlyOwner();
        rare_price = _newPrice;
        return true;
    }

    function set_Epic_price(uint _newPrice) public returns(bool){
        onlyOwner();
        epic_price = _newPrice;
        return true;
    }

    function set_Legendary_price(uint _newPrice) public returns(bool){
        onlyOwner();
        legendary_price = _newPrice;
        return true;
    }

    function set_Supreme_price(uint _newPrice) public returns(bool){
        onlyOwner();
        supreme_price = _newPrice;
        return true;
    }

    // SET TOKEn

    function set_Token(address _address)public returns(bool) {
        onlyOwner();
        _token = _address;
        return true;
    }

    function set_receiver(address _address) public returns(bool) {
        onlyOwner();
        _receiver = _address;
        return true;
    }

    // REVELED 

    // REVEALED

   function tokenURI(uint256 _tokenId) public view virtual override returns (string memory)
     {
         require(_exists(_tokenId),"ERC721Metadata: URI query for nonexistent token");

        if (revealed == false) {
            return notRevealedUri;
        }

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, Strings.toString(_tokenId), baseExtension))
        : "";
  }

   function set_BaseURI(string memory _newBaseURI) public returns(bool){
        onlyOwner();
        baseURI = _newBaseURI;
        return true;
    }

    function set_BaseExtension(string memory _newBaseExtension) public {
        onlyOwner();
        baseExtension = _newBaseExtension;
    }

    
    

}


