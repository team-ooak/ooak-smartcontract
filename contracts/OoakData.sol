// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.5.0;

import "./OoakDataInterface.sol";
import "./ownership/Ownable.sol";

contract OoakData is OoakDataInterface, Ownable {
    uint256 public lastTokenId;
    mapping(string => TwitchUser) IdToUser;         // Twitch ID to User struct
    mapping(address => string) AddressToId;         // Public Address to ID
    mapping(uint256 => OoakToken) TokenIdToToken;        // (Token ID from Users' MyTokenIds) --> (OoakToken struct)
    mapping(string => bool) IsNameTagExist;         // True if Name Tag is already used

    function getLastTokenId() public view returns (uint256) {
        return lastTokenId;
    }

    function incLastTokenId() public onlyOwner {
        lastTokenId++;
    } 

    function getMintedTokenIdByIndex(string memory twitchId, uint256 index) public view returns (uint256) {
        TwitchUser memory user = IdToUser[twitchId];
        return user.MintedTokenIds[index];
    }

    function getRawTokenIdByIndex(string memory twitchId, uint256 index) public view returns (uint256) {
        TwitchUser memory user = IdToUser[twitchId];
        return user.RawTokenIds[index];
    }

    function getMintedTokenListLength(string memory twitchId) public view returns (uint256) {
        TwitchUser memory user = IdToUser[twitchId];
        return user.MintedTokenIds.length;
    }

    function getRawTokenListLength(string memory twitchId) public view returns (uint256) {
        TwitchUser memory user = IdToUser[twitchId];
        return user.RawTokenIds.length;
    }

    function getAddress(string memory twitchId) public view returns (address) {
        return IdToUser[twitchId].PublicAddress;
    }
    
    function setIdToUser(string memory twitchId, address publicAddress, uint256[] memory rawTokenIds, uint256[] memory mintedTokenIds) public onlyOwner {
        TwitchUser memory newUser = TwitchUser(twitchId, publicAddress, rawTokenIds, mintedTokenIds);
        IdToUser[twitchId] = newUser;
    }

    function pushRawTokenId(string memory twitchId, uint256 tokenId) public onlyOwner {
        IdToUser[twitchId].RawTokenIds.push(tokenId);
    }

    function popRawTokenId(string memory twitchId) public onlyOwner returns (uint256) {
        require(IdToUser[twitchId].RawTokenIds.length > 0, "raw token id list not exist");
        uint256 popTokenId = IdToUser[twitchId].RawTokenIds[IdToUser[twitchId].RawTokenIds.length-1];
        IdToUser[twitchId].RawTokenIds.pop();
        return popTokenId;
    }

    function pushMintedTokenId(string memory twitchId, uint256 tokenId) public onlyOwner {
        IdToUser[twitchId].MintedTokenIds.push(tokenId);
    }

    function popMintedTokenId(string memory twitchId) public onlyOwner returns (uint256) {
        require(IdToUser[twitchId].MintedTokenIds.length > 0, "minted token id list not exist");
        uint256 popTokenId = IdToUser[twitchId].MintedTokenIds[IdToUser[twitchId].MintedTokenIds.length-1];
        IdToUser[twitchId].MintedTokenIds.pop();
        return popTokenId;
    }

    function swapMintedTokenIdInList(string memory twitchId, uint256 index1, uint256 index2) public onlyOwner {
        uint256 ogFirstTokenId = IdToUser[twitchId].MintedTokenIds[index1];
        uint256 newFirstTokenId = IdToUser[twitchId].MintedTokenIds[index2];
        IdToUser[twitchId].MintedTokenIds[index2] = ogFirstTokenId;
        IdToUser[twitchId].MintedTokenIds[index1] = newFirstTokenId;
    }

    function getId(address publicAddress) public view returns (string memory) {
        return AddressToId[publicAddress];
    }

    function setAddressToId(address publicAddress, string memory twitchId) public onlyOwner {
        AddressToId[publicAddress] = twitchId;
    }

    function getTokenNameTag(uint256 tokenId) public view returns (string memory) {
        OoakToken memory token = TokenIdToToken[tokenId];
        return token.NameTag;
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        OoakToken memory token = TokenIdToToken[tokenId];
        return token.TokenURI;
    }

    function getTokenIsMinted(uint256 tokenId) public view returns (bool) {
        OoakToken memory token = TokenIdToToken[tokenId];
        return token.isMinted;
    }

    function setTokenIdToToken(uint256 tokenId, string memory nameTag, string memory tokenURI, bool isMinted) public onlyOwner {
        OoakToken memory token = OoakToken(tokenId, nameTag, tokenURI, isMinted);
        TokenIdToToken[tokenId] = token;
    }

    function getIsNameTagExist(string memory nameTag) public view returns (bool) {
        return IsNameTagExist[nameTag];
    }

    function setIsNameTagExist(string memory nameTag, bool exist) public onlyOwner {
        IsNameTagExist[nameTag] = exist;
    }
}