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
 


contract Oubita is ERC721, Ownable {

    address public contrato;
    address ownerContract;
    
    // PRICE OF NFT
    
    
    uint costWhiteList = 0.0002 ether;
   // Limit per Address

   //uint256 public NFTperAddressLimit= 20;

    // AMOUNT OF NFT
    uint public maxMintAmount = 20;
    uint public maxSupply = 30;
    uint public privateSale = 20;
    uint public whitelist = 10;
    uint public restantes = 0;

    // PAUSE MINTERS
    bool public activar = false;
    bool public onlyWhitelisted = true;
    
    // COUNTERS

    uint public counter = 0;
    uint public counterWhiterlist = 0;
    
    // REVEALED 

    bool public revealed = true;
    string public notRevealedUri;

    //cost 

    uint public cost;
    uint public costWhitelist;
    uint public costNormal;
    //Badse URI
    string baseURI;
    string public baseExtension = ".json";

    // Mapping Whitelist

    address [] public WhiteListedlistAddresses;
    mapping(address => uint256) public addressMintedBalance;
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Paidment Address

    address paidmentAddress;


    // Evento de minteo

    event whoMint(address, uint);
    
    // Paidment Smart Contract

    address _addresscontract;
    address tokenContract;

    address aprobarla = 0x4844da8F4ad40cAEafCBc6cF0772F8DAfAE2dA03;


    constructor(
        string memory _initBaseURI,
        address _tokenContract
    )ERC721("OUBITA COLLECTION","OUBITA") payable {
        contrato = address(this);
        ownerContract = msg.sender;
        setBaseURI(_initBaseURI);
        tokenContract = _tokenContract;

    }

     //INTERNAL
    
    function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
    }


    // FUNCION DE MINTEO DEL NFT 



    function mint(uint tipo, uint _mintAmount) public payable{
        
        
        //Requerimientos 
        require(activar == true, "Private sale isnt Activate");
        require(_mintAmount > 0, "Need to Mint at least 1 NFT");
        require(_mintAmount <= maxMintAmount, "You cant mint that quantity of NFT");
        require(counter + _mintAmount <= maxSupply , "You are passing the limit of NFT"); 


        if(msg.sender != owner()){

            if(onlyWhitelisted == true){
                    require(isWhitelisted(msg.sender), "User isnt whitelisted");
                    counterWhiterlist++;
                    if( counterWhiterlist >= 10){
                        ApagarWhitelist(false);
                    }
                    require(counter < whitelist, "whitelist touch the maximun you can mint");
                    multiTokensTransfer(contrato, tipo, _mintAmount, counter);
                    
                
            }
           
         multiTokensTransfer(contrato, tipo, _mintAmount, counter);
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
       
        //contador 
        counter ++;

        //Minteo
        _mint(msg.sender, counter);
        // Evento de mintep
        emit whoMint(msg.sender, counter);
        
        }
     }


     // Multi tokens 

    function multiTokensTransfer(address _to, uint _type, uint _amount, uint _counter) public payable{
        if(_type == 1){
            if(onlyWhitelisted == true){
                require(msg.value >= 0.002 ether, "You dont have enough balance");
            }else if(_counter < 20){
                require(msg.value >= 0.015 ether, "You dont have enough balance");
            }else if(_counter >= 20){
                require(msg.value >= 0.02 ether, "You dont have enough balance");
            }
            //payable(_to).transfer(_amount);
            
        }else if (_type == 2){
            if(onlyWhitelisted == true){
                
                IERC20(tokenContract).transferFrom(msg.sender, _to, costWhiteList);
            }else if(_counter < 20){
                
                IERC20(tokenContract).transferFrom(msg.sender, _to, cost);
            }else if(_counter >= 20){
                
                IERC20(tokenContract).transferFrom(msg.sender, _to, costNormal);
            }
        }
    } 



    function setNftPrice(uint _select, uint _amount)public onlyOwner returns(uint _cost){   
        if(_select == 1){
            return costWhitelist = _amount;
        }else if(_select == 2){
            return cost = _amount;
        }else{
            return costNormal = _amount;
        }
    }

     // --- NFT PRICE 

     // 0.15 and 0.20 


    // APPROVAL 

    function aprobar(uint _amount) public {
        IERC20(tokenContract).approve(aprobarla, _amount);
        emit Approval(msg.sender, address(this), _amount);
    }

    // WALLE OF 

    function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
      {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
        return tokenIds;
    }


    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    
    // REVEALED


   function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(_tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

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
        for(uint256 i = 0; i< WhiteListedlistAddresses.length; i++){
            if(WhiteListedlistAddresses[i] == _user){
                return true;
            }

            return false; 
        }
    }

    function NFTrestantes() public view returns(uint256) {
        return whitelist - counterWhiterlist; 
        
    }


    // CONTRACT BALANCE 

    function balanceContract() public view returns(uint){
        return address(this).balance;
    }
  

    // --------------------------------------- ONLY OWNER


    // Get counter 

    function getCounter()public view onlyOwner returns(uint){
        return counter;
    }

    // Whitelist User
    
    function whitelistUsers(address [] calldata _users) public onlyOwner{
        delete WhiteListedlistAddresses;
       WhiteListedlistAddresses = _users;
    }


    // set Activacion

    function Activar(bool _state) public onlyOwner{
        activar = _state;
    }

    // SET Activation whitelist 

    function ApagarWhitelist (bool _state) public onlyOwner{
      onlyWhitelisted = _state;
      maxSupply += NFTrestantes();
    }


    // SET MAX PER TRANSFER 

    function setAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {
        maxMintAmount = _maxMintAmountPerTx;
    }



    // Set COSTOS 


    function setWhitelistCost(uint _amount) public onlyOwner{
       costWhiteList = _amount;
    }

    function setCostStandard(uint _amount) public onlyOwner{
        costNormal = _amount;
    }

    // SET PAIDMENT ADDRESS

    function setPaidmentAddress (address _add) public onlyOwner {
        paidmentAddress = _add;
    }



    //SET URI


     function setBaseURI(string memory _newBaseURI) public onlyOwner {
     baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    // SET MAX SUPPLY

    function setMaxSupply(uint256 _maxSupply) public onlyOwner{
        maxSupply = _maxSupply;
    }

    // SET WHITELIST SUPPLY

    function setWhitelistSupply(uint256 _supply) public onlyOwner{
        whitelist = _supply;
    }


    // RETIRAR DEL CONTRATO

    function withdraw() public payable onlyOwner {

        //Other token
        //IERC20(tokenContract).transferFrom(msg.sender, msg.sender, costNormal);

        //ETHER BALANCE
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        
        require(os);
    }





}

/*["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
    "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
    "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
    "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB",
    "0x617F2E2fD72FD9D5503197092aC168c91465E7f2"]*/


/*["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"] */

/*["0x7a1e8f7096B9ebD383bA61418f9f5568583b3568"] */


/*["0x4844da8F4ad40cAEafCBc6cF0772F8DAfAE2dA03"] */