pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../libs/Permission.sol";

contract damoLib is 
    Ownable,
    Permission{

    mapping(address => uint256[]) tokenIds; 
       
}