// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

abstract contract Recoverable is Ownable {
    using SafeERC20 for IERC20;

    receive() external virtual payable {
    }

    function recover(address toAddr) public virtual onlyOwner {
        Address.sendValue(payable(toAddr), address(this).balance);
    }

    function recoverToken(IERC20 token, address toAddr) public virtual onlyOwner {
        token.safeTransfer(toAddr, token.balanceOf(address(this)));
    }

    function recoverNftToken(IERC721 nftToken, address toAddr, uint256[] calldata tokenIds) public virtual onlyOwner {
        for (uint256 index = 0; index < tokenIds.length; index++) {
            nftToken.safeTransferFrom(address(this), toAddr, tokenIds[index]);   
        }
    }
}