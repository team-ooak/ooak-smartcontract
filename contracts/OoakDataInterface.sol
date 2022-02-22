// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.5.0;

contract OoakDataInterface {

    struct TwitchUser {
        string TwitchId;        // Users' Twitch ID (user & streamer)
        address PublicAddress;  // Wallet Public Address
        // My Token IDs ([One Wallet --> Many Tokens])
        uint256[] RawTokenIds;     // Token IDs not minted yet
        uint256[] MintedTokenIds;  // Minted Token IDs  
    }

    struct OoakToken {
        uint256 TokenId;        // Token ID
        string NameTag;         // Token NameTag
        string TokenURI;        // Token URI for NFT
        bool isMinted;          // True if Minted, used to find nametag from user efficiently (ex. changeOwnerOfToken)
    }
}