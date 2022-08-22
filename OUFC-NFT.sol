// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./ERC721full.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TESTPOLYGON is ERC721, Ownable{

    address public contrato;
    address ownerContract;

    // AMOUNT OF NFT
    uint public maxMintAmount = 20;
    uint public maxSupply = 10000;
    uint public specialSaleSuply = 2000;
    uint public whitelistSupply = 500;
    uint  restantes = 0;
    bool public restante = true;
    uint public Nft_Restantes = 10000;

    // PAUSE MINTERS
    bool public activar = false;
    bool public onlyWhitelisted = true;
    
    // COUNTERS

    uint public counter = 0;
    uint public counterWhiterlist = 0;
    
    // REVEALED 

    bool public revealed = true;
    string public notRevealedUri;

    //Cost in MATIC
 
    uint256 limit_matic_whitelist = 1730000000000000000;
    uint256 limit_matic_special = 380000000000000000000;
    uint256 limit_matic_normal = 480000000000000000000;

    uint256 limit_eth_whitelist = 20000000000000000; 
    uint256 limit_eth_special = 150000000000000000;
    uint256 limit_eth_normal = 200000000000000000;

    //Badse URI
    string baseURI;
    string public baseExtension = ".json";

    // Mapping Whitelist

    address [] public WhiteListedlistAddresses;
    mapping(address => uint256) public addressMintedBalance;
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Evento de minteo

    event whoMint(address, uint);
    
    // Paidment Smart Contract

    address public tokenContract;
    address public wallet_receiver;

    // Mapping of owners to an array of all the tokens they own
    mapping(address => uint256[]) private ownerByTokenId;
    mapping(uint256 => address) private tokenIdOfOwner;

    constructor(

    )ERC721("Test Polygon MAinnet","TEST") payable {
        contrato = address(this);
        ownerContract = msg.sender;
        tokenContract = 0xD7E024b704A32022596a15c853d4682248482bE8;

    }

    //INTERNAL

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // FUNCION DE MINTEO DEL NFT 

    function Mint(uint tipo, uint _mintAmount,uint256 _cost) public payable{
    
        //Requerimientos 
        require(activar == true, "Private sale isnt Activate");
        require(_mintAmount > 0, "Need to Mint at least 1 NFT");
        require(_mintAmount <= maxMintAmount, "You cant mint that quantity of NFT");
        require(counter + _mintAmount <= maxSupply , "You are passing the limit of NFT");
        require(counter < maxSupply, "We have minted 10000 NFT!");

        if(msg.sender != owner()){

            if(onlyWhitelisted == true){
                    require(isWhitelisted(msg.sender), "User isnt whitelisted");
                    counterWhiterlist++;
                    if( counterWhiterlist >= whitelistSupply){
                        Activar_Whitelist(false);
                    }
                    require(counter < whitelistSupply, "whitelist touch the maximun you can mint");
                    multiTokensTransfer(wallet_receiver, tipo, _mintAmount, counter, _cost);
            }
           
         multiTokensTransfer(wallet_receiver, tipo, _mintAmount, counter, _cost);
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
        
        
        //Minteo
        _mint(msg.sender, counter);
        emit whoMint(msg.sender, counter); 

        // Assign the token to the owner
        ownerByTokenId[msg.sender].push(counter);
        tokenIdOfOwner[counter] = msg.sender;
        counter ++;
        Nft_Restantes --;       
        }
     }

     // MultiMINT TOKENS SYSTEM 

    function multiTokensTransfer(address _to, uint _type, uint _amount, uint _counter, uint256 _cost) public payable{
        if(_type == 1){
            if(onlyWhitelisted == true){
                require(msg.value >= limit_matic_whitelist * _amount, "You dont have enough balance");
            }else if(_counter < specialSaleSuply){
                require(msg.value >= limit_matic_special * _amount, "You dont have enough balance");
            }else if(_counter >= specialSaleSuply){
                require(msg.value >= limit_matic_normal * _amount, "You dont have enough balance");
            }

        }else if (_type == 2){
            if(onlyWhitelisted == true){
                require(_cost >= limit_eth_whitelist);
                uint256 precio = _cost * _amount;
                IERC20(tokenContract).transferFrom(msg.sender, _to, precio);
            }else if(_counter < specialSaleSuply){
                require(_cost >= limit_eth_special);
                uint256 precio = _cost * _amount;
                IERC20(tokenContract).transferFrom(msg.sender, _to, precio);
            }else if(_counter >= specialSaleSuply){
                require(_cost >= limit_eth_normal);
                uint256 precio = _cost * _amount;
                IERC20(tokenContract).transferFrom(msg.sender, _to, precio);
            }
        }
    }

    //GET TOKENS OWNER 

     function get_OwnerTokens(address _owner) public view returns (uint256[] memory) {
      return ownerByTokenId[_owner];
    }

    //GET TOKEN ID 

    function get_tokenIdOwner(uint256 _tokenId) public view returns(address _address){
        return tokenIdOfOwner[_tokenId];
    }

    //TOKEN BY INDEX

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }
    
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
    
    //WhiteList Function

    function isWhitelisted(address _user) public view returns(bool _pause){
        for(uint256 i=0; i< WhiteListedlistAddresses.length; i++){
            if(WhiteListedlistAddresses[i] == _user){
                return true;
            }

        }
        return false; 
    }

    //NFT RESTANTES

    function NFTrestantes_whitelist() public view returns(uint256) {
        return whitelistSupply - counterWhiterlist; 
        
    }

    // CONTRACT BALANCE 

    function balanceContract() public view returns(uint){
        return address(this).balance;
    }
  
    // ------------- ONLY OWNER --------------

    // Whitelist User
    
    function Whitelist_Users(address [] calldata _users) public onlyOwner returns(bool){
        delete WhiteListedlistAddresses;
       WhiteListedlistAddresses = _users;
       return true;
    }

    function transfer(address _from, address _to, uint256 _tokenId) public  returns(bool){
        _transfer(_from, _to, _tokenId);
        delete ownerByTokenId[_from][_tokenId];
        ownerByTokenId[_to].push(_tokenId);
        return true;
    }

    //SET ACTIVATION

    function Activar_Mint(bool _state) public onlyOwner returns(bool){
        activar = _state;
        return _state;
    }

    //SET MAX PER TRANSFER 

    function set_AmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner returns(bool){
        maxMintAmount = _maxMintAmountPerTx;
        return true;
    }

    //SET PAIDMENT ADDRESS

    function set_PaidmentAddress (address _add) public onlyOwner returns(bool){
        wallet_receiver = _add;
        return true;
    }

    //SHOW WHITELIST

    function Whitelist_AllUsers()public view  returns(address[]memory){
        return WhiteListedlistAddresses;
    }

    //SET ACTIVATION WHITELIST 

    function Activar_Whitelist (bool _state) public onlyOwner{
        onlyWhitelisted = _state;
        if(restante == true){
            specialSaleSuply += NFTrestantes_whitelist();
            restante = false;
      }
    }

    //SET URI

    function set_BaseURI(string memory _newBaseURI) public onlyOwner returns(bool){
        baseURI = _newBaseURI;
        return true;
    }

    function set_BaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    // ---------------SET TOKEN SUPPLY--------------

    // SET MAX SUPPLY
    function set_MaxSupply(uint256 _maxSupply) public onlyOwner returns(bool){
        maxSupply = _maxSupply;
        return true;
    }

    // SET WHITELIST SUPPLY
    function set_Whitelist_Supply(uint256 _supply) public onlyOwner returns(bool){
        whitelistSupply = _supply;
        return true;
    }

    // SET ESPECIAL MINT SUPPLY
    function set_SpecialPrice_Supply(uint256 _supply)public onlyOwner returns(bool){
        specialSaleSuply = _supply;
        return true;
    }

    function set_Token(address _tokens)public onlyOwner returns(bool){
        tokenContract = _tokens;
        return true;
    }

    // RETIRAR DEL CONTRATO

    function Withdraw() public payable onlyOwner {

        //Other token
        //IERC20(tokenContract).transferFrom(msg.sender, msg.sender, costNormal);

        //ETHER BALANCE
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        
        require(os);
    }

    // --- set TOKEN PRICE

    //-- MATIC

    function set_LimiMatic_whitelist (uint256 _amount) public onlyOwner returns(bool){
        limit_matic_whitelist = _amount;
        return true;
    }

    function set_LimiMatic_special (uint256 _amount) public onlyOwner returns(bool){
        limit_matic_special = _amount;
        return true;
    }

    function set_LimiMatic_normal (uint256 _amount) public onlyOwner returns(bool){
        limit_matic_normal = _amount;
        return true;
    }

    function set_Limit_ETH_whitelist(uint256 _amount) public onlyOwner returns(bool){
        limit_eth_whitelist = _amount;
        return true;
    }

    function set_Limi_Eth_special(uint256 _amount) public onlyOwner returns(bool){
        limit_eth_special = _amount;
        return true;
    }

    function set_LimiEth_normal(uint256 _amount) public onlyOwner returns(bool){
        limit_eth_normal = _amount;
        return true;
    }

}

