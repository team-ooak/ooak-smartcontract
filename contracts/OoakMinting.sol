// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.5.0;


import "./ownership/Ownable.sol";

import "./token/KIP17/KIP17Token.sol";

contract OoakMinting is Ownable {

    uint256 public lastTokenId;
    uint256 constant firstPreSaleLimit = 1000;
    address NftContract;

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

    mapping(string => TwitchUser) IdToUser;         // Twitch ID to User struct
    mapping(address => TwitchUser) AddressToUser;   // Public Address to User struct
    mapping(uint256 => OoakToken) TokenIdToToken;        // (Token ID from Users' MyTokenIds) --> (OoakToken struct)
    mapping(string => bool) IsNameTagExist;         // True if Name Tag is already used


    constructor() public {
        lastTokenId = 0;
    }

    function registerNameTag(string memory twitchId, address publicKey, string memory nameTag) onlyOwner public {
        //require(bytes(getNameTag(twitchId)).length == 0, "already register nameTag");
        require(!IsNameTagExist[nameTag], "this nameTag already exist");
        require(lastTokenId < firstPreSaleLimit, "The first presale is sold out");

        lastTokenId++;

        uint256[] memory _rawList;
        uint256[] memory _mintedList;

        if(IdToUser[twitchId].RawTokenIds.length==0 && IdToUser[twitchId].MintedTokenIds.length==0) {   // When User with the Twitch ID does not exist : create new user
            TwitchUser memory newUser = TwitchUser(twitchId, publicKey, _rawList, _mintedList);
            IdToUser[twitchId] = newUser;
            AddressToUser[publicKey] = newUser;
        }
        
        IdToUser[twitchId].RawTokenIds.push(lastTokenId);       // Push new TokenId to not-minted array

        OoakToken memory newToken = OoakToken(lastTokenId, nameTag, "", false);    // Create new Token with empty URI
        TokenIdToToken[lastTokenId] = newToken;

        IsNameTagExist[nameTag] = true;
    }

    function getAddress(string memory twitchId) public view returns (address) {
        return IdToUser[twitchId].PublicAddress;
    }

    function getRawTokenNumber(string memory twitchId) public view returns (uint256) { 
        //require(IdToUser[twitchId], "address do not exist");
        return IdToUser[twitchId].RawTokenIds.length;
    }
    
    function getRawTokenIds(string memory twitchId) public view returns (uint256[] memory) { 
        //require(IdToUser[twitchId], "address do not exist");
        return IdToUser[twitchId].RawTokenIds;
    }

    function getMintedTokenNumber(string memory twitchId) public view returns (uint256) { 
        //require(IdToUser[twitchId], "address do not exist");
        return IdToUser[twitchId].MintedTokenIds.length;
    }

    function getMintedTokenIds(string memory twitchId) public view returns (uint256[] memory) { 
        //require(IdToUser[twitchId], "address do not exist");
        return IdToUser[twitchId].MintedTokenIds;
    }

    function getNameTagWithTokenId(uint256 tokenId) public view returns (string memory) {
        //require(TokenIdToToken[tokenId], "token do not exist");
        return(TokenIdToToken[tokenId].NameTag);
    }

    function getTokenURIWithTokenId(uint256 tokenId) public view returns (string memory) {
        //require(TokenIdToToken[tokenId], "token do not exist");
        return(TokenIdToToken[tokenId].TokenURI);
    }

    // get 기능
    // get all Nametags(tokens) of user
    // get all NFTs of user
    

    function mintNFTWithTokenURI(string memory twitchId, string memory tokenURI) onlyOwner public {
        //require(IdToUser[twitchId], "address do not exist");
        require(getRawTokenNumber(twitchId) != 0, "No empty TokenId left to Mint");
        address publicKey = getAddress(twitchId);
        uint256[] memory tokenIds = getRawTokenIds(twitchId);
        uint256 tokenId = tokenIds[tokenIds.length-1];

        //가스비를 아끼기 위해 rawtokenIds 중 마지막 tokenId 이용
        KIP17Token(NftContract).mintWithTokenURI(publicKey, tokenId, tokenURI);
        IdToUser[twitchId].MintedTokenIds.push(tokenId);            // mintedtokenIds 배열에 추가
        TokenIdToToken[tokenId].TokenURI = tokenURI;                // token struct의 tokenURI에 URI 추가
        TokenIdToToken[tokenId].isMinted = true;                    // isMinted = true
        delete IdToUser[twitchId].RawTokenIds[tokenIds.length-1];   // rawtokenIds 배열에서 삭제
        IdToUser[twitchId].RawTokenIds.length--;
    }

    function setNFTContract(address nftContract) onlyOwner public {
        NftContract = nftContract;
    }
    
    
    function changeOwnerOfToken(address srcAddress, address dstAddress, uint256 tokenId) public {
        require(msg.sender == NftContract, "sender does not match NFTcontract");
        //require(AddressToUser[srcAddress], "source address user do not exist");
        //require(AddressToUser[dstAddress], "destination address user do not exist");
        //require(TokenIdToToken[tokenId], "TokenID does not exist");

        if (TokenIdToToken[tokenId].isMinted == true) {
            for (uint256 i=0; i<AddressToUser[srcAddress].MintedTokenIds.length; i++) {
                if (AddressToUser[srcAddress].MintedTokenIds[i] == tokenId){
                    delete AddressToUser[srcAddress].MintedTokenIds[i];
                    AddressToUser[srcAddress].MintedTokenIds[i] = AddressToUser[srcAddress].MintedTokenIds[AddressToUser[srcAddress].MintedTokenIds.length - 1];    // Swap last item to deleted space
                    AddressToUser[srcAddress].MintedTokenIds.length--;
                    AddressToUser[dstAddress].MintedTokenIds.push(tokenId);
                    break;
                }
            }
        } else {
            for (uint256 i=0; i<AddressToUser[srcAddress].RawTokenIds.length; i++) {
                if (AddressToUser[srcAddress].RawTokenIds[i] == tokenId){
                    delete AddressToUser[srcAddress].RawTokenIds[i];
                    AddressToUser[srcAddress].RawTokenIds[i] = AddressToUser[srcAddress].RawTokenIds[AddressToUser[srcAddress].RawTokenIds.length - 1];    // Swap last item to deleted space
                    AddressToUser[srcAddress].RawTokenIds.length--;
                    AddressToUser[dstAddress].RawTokenIds.push(tokenId);
                    break;
                }
            }
        }
    }
}
