// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.5.0;

import "./ownership/Ownable.sol";

contract OoakMinting is Ownable {
    // twitch ID to nameTag
    mapping(string => string) IdToNameTag;
    // twitch ID to public address
    mapping(string => address) IdToAddress;
    // twitch ID(streamer) to public address
    mapping(string => address) StreamerToAddress;
    // address to tokenURI
    mapping(address => string) AddressToTokenURI;
    // check nameTag already exist
    mapping(string => bool) isNameTagExist; 

    function registerNameTag(string memory twitchId, address publicKey, string memory nameTag) onlyOwner public {
        
        require(bytes(IdToNameTag[twitchId]).length == 0, "already register nameTag");
        require(!isNameTagExist[nameTag], "this nameTag already exist");
        IdToNameTag[twitchId]=nameTag;
        IdToAddress[twitchId]=publicKey;
        isNameTagExist[nameTag]=true;
    
    }

    function getNameTag(string memory twitchId) public view returns (string memory) {
        return IdToNameTag[twitchId];
    }

    function getAddress(string memory twitchId) public view returns (address) {
        return IdToAddress[twitchId];
    }

    function getStreamerAddress(string memory twitchId) public view returns (address) {
        return StreamerToAddress[twitchId];
    }

    function getTokenURI(address publicKey) public view returns (string memory) {
        return AddressToTokenURI[publicKey];
    }

}