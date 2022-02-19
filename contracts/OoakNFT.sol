// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.5.0;

import "./token/KIP17/KIP17Token.sol";
import "./OoakMinting.sol";
import "./ownership/Ownable.sol";

contract OoakNFT is KIP17Token("OoakNFT","OOAK"), Ownable {
    address OoakContract;

    function setOoakContract(address _OoakContract) onlyOwner public {
        OoakContract = _OoakContract;
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        super.safeTransferFrom(from, to, tokenId);
        OoakMinting(OoakContract).changeOwnerOfNameTag(from, to, tokenId);
    }
}