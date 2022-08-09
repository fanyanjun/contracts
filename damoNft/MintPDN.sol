pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../libs/Initializable.sol";
import "../libs/Permission.sol";
import "./IdaMo.sol";
import "./IWishDaMo.sol";


contract MintPDN is Ownable,Initializable,Permission
{
     using Counters for Counters.Counter;
     Counters.Counter private _tokenIdTracker;
     using SafeMath for uint256; 
     using Strings for uint256;
     bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    IdaMo daMoContract;
    IWishDaMo wishDaMoContract;
   
   //price
    uint256 donateUint = 1*(10**18);
    
    address treasuryAddress;
    uint8 period = 1;
    uint8 freeMintmax = 3 ;
    uint256 total = 1000;
    uint256 sq = 0;

    mapping(address => uint8) mintWhilte; //frree mint number
    mapping(address => uint8) addressMap; //minted number

    //bool isPublicMint = false;
    bool isPriveFreeMint = false;
    uint256 startMintTime = 0;

    mapping(address => uint8) mintLocks;
    event mintEvt(address indexed,uint256 tokenId);
    event mintCardEvt(address indexed,uint256 tokenId);
    event airdropWishDamoEvt(string);
    event freeMintDamoEvt(address indexed,string);

    constructor(){
        //treasuryAddress = 0x6a9F14b8a95c65b65D4dff7659274Bf77D9f0A96;
        initWhilte();
    }

    modifier mintLock() {
        require(mintLocks[_msgSender()] == 0, "Locked");
        mintLocks[_msgSender()] == 1;
        _;
        mintLocks[_msgSender()] == 0;
    }

    function init(IdaMo _idaMo,IWishDaMo _iWishDaMo) public onlyOwner {
        daMoContract = _idaMo;
        wishDaMoContract = _iWishDaMo;
        initialized = true;
    }

    function setDonateUint(uint256 uintvalue) public onlyRole(MINTER_ROLE){
        donateUint = uintvalue;
    }

    function setTotal(uint256 _total) public onlyRole(MINTER_ROLE){
        total = _total;
    }

    function setIsPublicMint(bool _isPublicMint) public onlyRole(MINTER_ROLE) {
        //isPublicMint = _isPublicMint;
    }

    function getCount(address _addr) public view returns(uint8){
        return mintWhilte[_addr] ;
    }

    function setStart() public onlyRole(MINTER_ROLE) {
        isPriveFreeMint = true;
        startMintTime = block.timestamp;
    }

     function setStatus(bool b) public onlyRole(MINTER_ROLE) {
        isPriveFreeMint = b;
    }

    function setWhilte(address[] memory addrs,uint8[] memory counts) public onlyRole(MINTER_ROLE){
        require(addrs.length == counts.length,"params error");
        for (uint256 index = 0; index < addrs.length; index++) {
            uint8 number = mintWhilte[addrs[index]];
            mintWhilte[addrs[index]] = number+counts[index];
            require(number+counts[index] <= freeMintmax);
        }
    }

    function freeMint(uint8 number) public  needInit mintLock{
        require(number>0,"number error");
        require(isPriveFreeMint==true,"not start");
        require(tx.origin==msg.sender,"forbid");
        uint8 myTotals = getCanMintNumber(msg.sender);
        require(number<=myTotals,"not enough");
        string memory tokenIdStr = "";
        uint256 tokenId = 0;
        if(number>0){
            for (uint256 i = 0; i < uint256(number); i++) {
                tokenId = wishDaMoContract.mintNFT(msg.sender,1,1); //许愿达摩1代
                tokenIdStr = string(abi.encodePacked(tokenIdStr,tokenId.toString(),","));
            }
            //count
            addressMap[msg.sender] = addressMap[msg.sender]+number ;
            sq = sq +number;
            require(sq<=total,"not enough");
            emit freeMintDamoEvt(msg.sender,tokenIdStr);
        }
    }

    function getCanMintNumber(address addr) public view returns(uint8){
         uint8 max = 0;
         uint256 tspan = block.timestamp.sub(startMintTime) ;
         uint8 hasmintd = addressMap[addr];
         
         if(isPriveFreeMint && tspan<86400){
           max = mintWhilte[addr];
         }else if(isPriveFreeMint && tspan>86400){
           max = freeMintmax;
         }
         if(max<=hasmintd){
            return 0;
         }
         uint8 leftNumber = max-hasmintd;
         if(sq.add(uint256(leftNumber))>total){
            return uint8(total.sub(sq)) ;
         }
         return leftNumber;
    }   

    /**
    func：free airdropDamo
     */
    function airdropDamo(address[] memory addrs,uint8[] memory counts,uint8[] memory genes) public  onlyRole(MINTER_ROLE){
         require(addrs.length == counts.length,"params error");
         require(addrs.length == genes.length,"params error");
          for (uint256 index = 0; index < addrs.length; index++) {
              uint8 number = counts[index];
              require(sq+number<=total,"airdrop not enough");
              if(number>0){
                    for (uint256 i = 0; i < uint256(number); i++) {
                        daMoContract.mintNFT(addrs[index],genes[index]);
                    }
                    sq = sq+number;
              }
          }
    }

    function initWhilte() private{
        //mintWhilte[0x6a9F14b8a95c65b65D4dff7659274Bf77D9f0A96]=2;
    }

 
}