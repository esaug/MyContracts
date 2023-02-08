// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20Base {
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}

interface tokensSelector{

    function add_token(string memory _siglas,string memory _name, address _address)external;
    function get_token_address(uint256 _id)external view returns(address);
    function get_simbols()external view returns(string [] memory);
}

interface Oraculo{

    function get_convertionRate(uint256 _amount, uint256 _id)external view returns(uint256);
}

error Transfer_error();

contract NFT is ERC721URIStorage{

     using Strings for uint256;

    //Contract Addres
        
        address public contrato;
    
    //Owner
        
        address public _owner;
    
    // Receiver
        
        address public _receiver;

   // Max SUPPLY 
        
        uint256 public supplyMax = 9999;
        uint256 public maxMintAmount = 5;
        uint256 public minted = 0;

    // SUPPLYs

        uint256 public commond_supply =  9;
        uint256 public rare_supply =  29;
        uint256 public epic_supply =  49;
        uint256 public legendary_supply =  69;
        uint256 public supreme_supply =  89;

    // Wallet by NFT 
        
        mapping(address => uint256[]) internal ownerByTokenId;
        mapping(uint => address) internal tokenIdByOwner;

    // REVEALED 

        bool public revealed = true;
        string public notRevealedUri;

    //Badse URI
        
        string baseURI;
        string public baseExtension = ".json";

    //Activar Whitelist 

        bool public onlyWhitelisted = true;
        uint256 whitelistSupply = 9999;

    //Contador GLOBAL MINTED NFT
        
        uint public idNFT;


    //Counter per rarity

        uint256 public idCommond = 0;
        uint256 public idRare = 0;
        uint256 public idEpic = 0;
        uint256 public idLegendary = 0;
        uint256 public idSupreme = 0;
    
    //Activador
        
        bool public active = false;
    
    //whitelist

        uint256 whitelist_counter;
      
    // Token Selector

        address public _AllTokens;
        address public oraculo;
        uint256 public cantidad;

    // TOKEN

        address public token;

    //URIS

        mapping(uint256 => string) private _tokenURIs;

    // WHITELIST

        address [] public WhiteListedlistAddresses;

    //minting event

        event whoMinted(address, uint);

    constructor() ERC721("NFT", "CSTORYNFT") payable{
        contrato = address(this);
        _owner = msg.sender;

    }

    //OWNABLE

    function onlyOwner() private view{
        require(msg.sender == _owner, "N/Owner");
    }

    //BASE URI

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    //MINTER

    function mint (uint256 _rarity, uint256 id_token) public payable{
    
        string [] memory arrayNFT = tokensSelector(_AllTokens).get_simbols();
        uint256 tamanio_Array_simbols = arrayNFT.length - 1; 

        //requerimientos
        require(active == true, "SN/o A");
        require(_rarity > 0, "N/R");
        require(id_token <= tamanio_Array_simbols, "Cant/mayor");
        
        // SET PAIDMENT TOKEN
        token = tokensSelector(_AllTokens).get_token_address(id_token);
        
        //SET TOKEN PRICE

        uint256 jsonId; 

        // URI CHANGER
    
        string memory parts;


        if(_rarity == 1){

            Prueba_oraculo(150, id_token);
            parts = "commond/";
            jsonId = idCommond;
            idCommond ++;
        }else if(_rarity == 2){

            Prueba_oraculo(350, id_token);
            parts = "rare/";
            jsonId = idRare;
            idRare ++;
        }else if(_rarity == 3){

            Prueba_oraculo(550, id_token);
            parts = "epic/";
            jsonId = idEpic;
            idEpic ++;
        }else if(_rarity == 4){

            Prueba_oraculo(750, id_token);
            parts = "legendary/";
            jsonId = idLegendary;
            idLegendary ++; 
        }else if(_rarity == 5){

            Prueba_oraculo(950, id_token);
            parts = "supreme/";
            jsonId = idSupreme;
            idSupreme ++;
        }

        // IF THE NO OWNER


        if(msg.sender != _owner){
            require(balanceOf(msg.sender) <= maxMintAmount, "Y/T/L");

            if(onlyWhitelisted == true){
                require(onlyWhitelisted == true, "N/A");
                if(whitelist_counter >= whitelistSupply){
                    Apagar_Whitelist();
                     
                }
                Transferencia(cantidad);
                whitelist_counter ++;
            }
            
            Transferencia(cantidad);
        }

        
        //Reference WALLET to ID - ID to WALLET
        ownerByTokenId[msg.sender].push(idNFT);
        tokenIdByOwner[idNFT] = msg.sender;

        //minteo
        _mint(msg.sender, idNFT);
        _setTokenURI(idNFT, string(abi.encodePacked(parts,Strings.toString(jsonId))));
        // quien minteo?
        emit whoMinted(msg.sender, idNFT);

        //contador     
        minted++;
        idNFT++;
        //nonce++;
    }

    // Precios de los NFT

    function Transferencia(uint256 _value) private {
        require(IERC20Base(token).balanceOf(msg.sender) >= _value, "No/Balance");
        bool success = IERC20Base(token).transferFrom(msg.sender, _receiver, _value);
        if(!success){
            revert Transfer_error();
        }

    }

    // ORACULO

    function Prueba_oraculo(uint256 _valor, uint256 _id) private {
        cantidad = Oraculo(oraculo).get_convertionRate(_valor, _id);
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

    //-----------------ONLY OWNER-------------------

    // Activacion del minteo

    function activacion()public{
        onlyOwner();
        active = !active;
    }

    function set_receiver(address _address) public returns(bool) {
        onlyOwner();
        _receiver = _address;
        return true;
    }

    //SET TOKE URI

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual  override{
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
 
    //SHOW TOKEN URI

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI, baseExtension));
        }

        return super.tokenURI(tokenId);
    }
      
    //URI
    function set_BaseURI(string memory _newBaseURI) public returns(bool){
        onlyOwner();
        baseURI = _newBaseURI;
        return true;
    }

    //BASE EXTENSION

    function set_BaseExtension(string memory _newBaseExtension) public {
        onlyOwner();
        baseExtension = _newBaseExtension;
    }

    //BURN

    function burneable(uint256 _tokenId) public returns(bool){
        onlyOwner();
        _burn(_tokenId);
        return true;
    }

    function set_Supply(uint256 _value) public returns(bool){
        onlyOwner();
        supplyMax = _value;
        return true;
    }

    //SET MAX PER MINT 

    function set_MaxPerMint(uint256 _value) public returns(bool){
        onlyOwner();
        maxMintAmount = _value;
        return true;
    }

    //SET ACTIVATION WHITELIST 

    function Apagar_Whitelist () public {
        onlyOwner();
        onlyWhitelisted = !onlyWhitelisted;
    }

    function set_Supplies(uint256 _commond, uint256 _rare, uint256 _epic, uint256 _legendary, uint256 _supreme)public{
       
        onlyOwner();

        commond_supply = _commond;
        rare_supply = _rare;
        epic_supply = _epic;
        legendary_supply = _legendary;
        supreme_supply = _supreme;
        
    }

    //WhiteList Function

    function isWhitelisted(address _user) internal view returns(bool _pause){
        for(uint256 i=0; i< WhiteListedlistAddresses.length; i++){
            if(WhiteListedlistAddresses[i] == _user){
                return true;
            }
        }
        return false; 
    }

    // SET WHITELIST 

     function Whitelist_AllUsers()public view returns(address[]memory){
        return WhiteListedlistAddresses;
    }

    // TOKENS SELECTOR

    function set_selector(address _address) public{
        onlyOwner();
        _AllTokens = _address;
    }

    function set_oraculo(address _address) public{
        onlyOwner();
        oraculo = _address;
    }

}


