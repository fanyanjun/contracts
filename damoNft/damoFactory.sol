pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "../libs/Initializable.sol";
import "../libs/Permission.sol";
import "./IdaMo.sol";
import "./IWishDaMo.sol";
import "./IFactory.sol";

contract damoFactory is Ownable,Initializable,Permission,IFactory
{
     using SafeMath for uint256; 
     using Strings for uint256;
     bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    IdaMo daMoContract;
    IWishDaMo wishDaMoContract;

    bool isStart = true;
    event mintEvt(address indexed,uint256 tokenId); 
    event mintDamoEvt(address indexed,uint8,uint8,string);
    event batchMintDamoEvt(uint8,string);
    constructor(){}

    modifier IsStart() {
        require(isStart == true, "no Permission");
        _;
    }

    function init(IdaMo _idaMo,IWishDaMo _iWishDaMo) public onlyOwner {
        daMoContract = _idaMo;
        wishDaMoContract = _iWishDaMo;
        initialized = true;
    }

    function setIsStart(bool _isStart) public onlyOwner {
        isStart = _isStart;
    }

    function batchMintDamo(uint8 damoType,address[] memory tos,uint256[] memory tokenIds,uint8[] memory gens) public override needInit IsStart() onlyRole(MINTER_ROLE) returns(uint256[] memory){
         require(tos.length == gens.length,"len error");
         require(tos.length == tokenIds.length,"len error");
         uint256 tokenId = 0;
         string memory tokenIdStr = "";
          uint256[] memory  tokenIdArray  = new uint256[](tos.length);
         for (uint index = 0; index < tos.length; index++) {
             if(damoType==1){
                tokenId = daMoContract.mintNFT(tos[index],gens[index]);
             }else if(damoType==2){
                tokenId = wishDaMoContract.mintNFT(tos[index],gens[index],1);
             }
             tokenIdStr = string(abi.encodePacked(tokenIdStr,tokenIds[index].toString(),"-",tokenId.toString(),","));
             tokenIdArray[index] = tokenId;
         }
        emit batchMintDamoEvt(damoType,tokenIdStr);
        return tokenIdArray;
    }

    //source: 1 reward 2:give
    function mintDamo(address to,uint8 damoType,uint8 genera,uint8 numbers,uint8 source) public override IsStart() onlyRole(MINTER_ROLE) returns(uint256[] memory) {
        require(genera>0,"genera error");
        uint256[] memory  tokenIds  = new uint256[](uint256(numbers));
        string memory tokenIdStr = "";
        uint256 tokenId = 0;
        for (uint index = 0; index < uint256(numbers); index++) {
                if(damoType==1){
                    tokenId = daMoContract.mintNFT(to,genera);
                }else if(damoType==2){
                    tokenId = wishDaMoContract.mintNFT(to,genera,source);
                }
                tokenIds[index] = tokenId;
                tokenIdStr = string(abi.encodePacked(tokenIdStr,tokenId.toString(),","));
        }   
        emit mintDamoEvt(to,damoType,genera,tokenIdStr);
        return tokenIds;
    }

    function tokenDetail(uint8 damoType,uint256 tokenId) public override view returns (uint8,uint8,string memory) {
             if(damoType==1){
                 return daMoContract.tokenDetail(tokenId);
             }else{
                 return wishDaMoContract.tokenDetail(tokenId);
             }
    }
}