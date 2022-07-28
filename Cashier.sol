// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Cashier is ERC721URIStorage ,Ownable{

    using Strings for uint256;

    // CURRENCIES STOCK 

    uint256 [5] public stocks = [50, 5, 2, 2, 20];

    //Id NFT
    uint256 idNFT = 0;

    //Transaction ID

    uint256 trans = 0;

    //Owner Contract

    address _owner;
    address _contract;

    //Activador
    bool public active = false;

    uint256 [] billetes;

    //Badse URI
    string baseURI;
    string public baseExtension = ".json";

    //Transacction per USER 
   
    mapping (address => uint256[]) owner_NFT;
    mapping (uint256 => uint256) bill_per_id;


    //URIS

    mapping(uint256 => string) private _tokenURIs;

    string Uril = "2";

    constructor()ERC721("Cashier", "Cash"){
        _owner = msg.sender;
        _contract = address(this);
    }


    event mint_event(address, uint256);

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function ConvertDenom(uint256 _value) public payable returns(uint256 [] memory){

        require(active == true, "SN/o A");
        require(_value <= Saldo_Cashier(), "N/Enough/Tickets" );
        require(_value > 0, "C/Not/N");
        
        //RESET ARRAY PER TX

        delete billetes;

        uint cantidad = _value;
        string memory numUri;

        //DENOMINACIONES

        uint [] memory arr_currencies = new uint[](5);
        arr_currencies[0] = 100;
        arr_currencies[1] = 50;
        arr_currencies[2] = 20;
        arr_currencies[3] = 5;
        arr_currencies[4] = 1;


        for(uint256 i = 0; i < arr_currencies.length; i++){

            if(cantidad >= arr_currencies[i] && stocks[i] != 0) {
                
                while(cantidad >= arr_currencies[i]){

                    billetes.push(arr_currencies[i]);
                    owner_NFT[msg.sender].push(idNFT);
                    bill_per_id[idNFT] = arr_currencies[i];
                    
                    // SALDO CAJERO
                    cantidad -= arr_currencies[i];

                    // SET URI
                    if(arr_currencies[i]== 100){
                        numUri = "5";
                    }else if(arr_currencies[i]== 50){
                        numUri = "4";
                    } else if(arr_currencies[i]== 20){
                        numUri = "3";
                    }else if(arr_currencies[i]== 5){
                        numUri = "1";
                    }else if(arr_currencies[i]== 1){
                        numUri = "0";
                    }

                    //RESTA SUPPLY
                    resta_supply(arr_currencies[i]);

                    //Mint

                    _mint(msg.sender, idNFT);
                    _setTokenURI(idNFT, numUri);
                    emit mint_event(msg.sender, idNFT);
                    idNFT ++;
                }
            }
        }

        trans ++;

        return billetes;
    }

    function resta_supply(uint256 billete) internal {
        if(billete == 100){
            stocks[4] --;
        }else if(billete == 50){
            stocks[3] --;
        }else if(billete == 20){
            stocks[2] --;
        }else if(billete == 5){
            stocks[1] --;
        }else if(billete == 1){
            stocks[0] --;
        }
    }

   function billetes_return () public view returns(uint256 [] memory){
        return billetes;
    } 

    // Calculo de saldo

    function Saldo_Cashier() public  view returns(uint256 _saldo){
        uint256 saldo = (100 * stocks[4]) + (50 * stocks[3]) + (20 * stocks[2]) + (5* stocks[1]) + (1 * stocks[0]);
        return saldo;
    }

 
    // Activacion del minteo

    function activacion()public onlyOwner{
        
        active = !active;
    }

    // SET OWNER 

    // SET CURRENCIES SUPPLY
    function ChangeStock(uint _100, uint _50, uint _20, uint _5, uint _1) public onlyOwner{

        stocks[0] = _1;
        stocks[1] = _5;
        stocks[2] = _20;
        stocks[3] = _50;
        stocks[4] = _100;
      
    }
    
    //BURN
    function burneable(uint256 _tokenId) public  onlyOwner returns(bool){
        
        _burn(_tokenId);
        return true;
    }

    //GET NFT 

    function get_OWNERNFT(address _address)public view returns(uint256 [] memory){
        return owner_NFT[_address];
    }

    function get_bill_per_id(uint256 _id)public view returns(uint256){
        return bill_per_id[_id];
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
    function set_BaseURI(string memory _newBaseURI) public onlyOwner returns(bool){
        
        baseURI = _newBaseURI;
        return true;
    }

    //BASE EXTENSION

    function set_BaseExtension(string memory _newBaseExtension) public onlyOwner {
       
        baseExtension = _newBaseExtension;
    }

    function get_stock() public view returns(uint256 [5] memory){
        return stocks;
    }
  

}