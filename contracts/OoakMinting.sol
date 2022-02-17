// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.5.0;

import "./ownership/Ownable.sol";

import "./token/KIP17/KIP17Token.sol";

contract OoakMinting is Ownable {


    // twitch ID to public address
    mapping(string => address) IdToAddress;


    // TODO : 여러 개의 NFT를 가지도록
    //mapping(address => uint256) AddressToTokenId;
    mapping(address => uint256[]) AddressToTokenIds;


    // NFT TokenId to NameTag
    mapping(uint256 => string) TokenIdToNameTag;
    // twitch ID(streamer) to public address
    mapping(string => address) StreamerToAddress;
    // TokenId to tokenURI
    mapping(uint256 => string) TokenIdToTokenURI;
    // check nameTag already exist
    mapping(string => bool) isNameTagExist; 

    uint256 public lastTokenId;
    uint256 constant firstPreSaleLimit = 1000;
    address NftContract;

    constructor() public {
        lastTokenId = 0;
    }

    function registerNameTag(string memory twitchId, address publicKey, string memory nameTag) onlyOwner public {
        require(bytes(getNameTag(twitchId)).length == 0, "already register nameTag");
        require(!isNameTagExist[nameTag], "this nameTag already exist");
        require(lastTokenId < firstPreSaleLimit, "The first presale is sold out");

        lastTokenId++;

        IdToAddress[twitchId] = publicKey;
        //AddressToTokenId[publicKey] = lastTokenId;
        AddressToTokenIds[publicKey].push(lastTokenId);
        TokenIdToNameTag[lastTokenId] = nameTag;
        isNameTagExist[nameTag] = true;
    }

    // function getNameTag(string memory twitchId) public view returns (string memory) {
    //     uint256 _tokenId = getTokenId(twitchId);
    //     return getNameTagWithTokenId(_tokenId);
    // }
    function getNameTags(string memory twitchId) public view returns (string[] memory) {
        uint256[] _tokenIds = getTokenIds(twitchId);
        string[] _nameTags;
        for (uint i=0; i<_tokenIds.length; i++) _nameTags.push(getNameTagWithTokenId(_tokenIds[i]));
        
        return _nameTags;
    }

    function getNameTagWithTokenId(uint256 tokenId) public view returns (string memory) {
        return TokenIdToNameTag[tokenId];
    }

    function getAddress(string memory twitchId) public view returns (address) {
        return IdToAddress[twitchId];
    }

    // function getTokenURI(string memory twitchId) public view returns (string memory) {
    //     require(IdToAddress[twitchId] != address(0), "address do not exist");
    //     address _address = IdToAddress[twitchId];
    //     uint256 _tokenId = AddressToTokenId[_address];
    //     return TokenIdToTokenURI[_tokenId];
    // }
    function getTokenURIs(string memory twitchId) public view returns (string[] memory) {
        require(IdToAddress[twitchId] != address(0), "address do not exist");
        address _address = IdToAddress[twitchId];
        uint256[] _tokenIds = AddressToTokenIds[_address];
        string[] _tokenURIs;
        for (uint i=0; i<_tokenIds.length; i++) _tokenURIs.push(TokenIdToTokenURI[_tokenId[i]]);
        return _tokenURIs;
    }

    // function getTokenId(string memory twitchId) public view returns (uint256) {
    //     address _address = IdToAddress[twitchId];
    //     return AddressToTokenId[_address];
    // }
    function getTokenIds(string memory twitchId) public view returns (uint256[]) {
        address _address = IdToAddress[twitchId];
        return AddressToTokenIds[_address];
    }
    
    // function mintNFTWithTokenURI(string memory twitchId, string memory tokenURI) onlyOwner public {
    //     require(IdToAddress[twitchId] != address(0), "address do not exist");
    //     address publicKey = IdToAddress[twitchId];
    //     uint256 tokenId = AddressToTokenId[publicKey];
    //     KIP17Token(NftContract).mintWithTokenURI(publicKey, tokenId, tokenURI);
    //     TokenIdToTokenURI[tokenId] = tokenURI;
    // }

    // TODO 확인 필요
    function mintNFTWithTokenURI(string memory twitchId, string memory tokenURI) onlyOwner public {
        require(IdToAddress[twitchId] != address(0), "address do not exist");
        address publicKey = IdToAddress[twitchId];
        uint256[] tokenIds = AddressToTokenIds[publicKey];
        KIP17Token(NftContract).mintWithTokenURI(publicKey, tokenIds[tokenIds.length-1], tokenURI); //tokenIds 중 마지막 tokenId 이용
        TokenIdToTokenURI[tokenId] = tokenURI;
    }


    function setNFTContract(address nftContract) onlyOwner public {
        NftContract = nftContract;
    }
    
    
    // function changeOwnerOfNameTag(address srcAddress, address dstAddress, uint256 tokenId) public {
    //     require(msg.sender == NftContract);
    //     delete AddressToTokenId[srcAddress];
    //     AddressToTokenId[dstAddress] = tokenId;
    // }
    function changeOwnerOfNameTag(address srcAddress, address dstAddress, uint256 tokenId) public {
        require(msg.sender == NftContract);
        
        //tokenId가 있는 자리 delete
        uint deletedPlace = 0;
        for(uint i=0; i<AddressToTokenId[srcAddress].length; i++){
            if(AddressToTokenId[srcAddress][i] == tokenId){
                delete AddressToTokenId[srcAddress][i];
                deletedPlace = i;
                break;
            }
        }
        //delete 한 자리 뒤 쪽 앞으로 당기기
        for(uint i=deletedPlace; i<AddressToTokenId[srcAddress].length-1; i++){
            
            AddressToTokenId[srcAddress][i] = AddressToTokenId[srcAddress][i+1];
        }
        AddressToTokenId[srcAddress].pop;

        //dstAddress 뒤에 tokenId 추가
        AddressToTokenIds[dstAddress][AddressToTokenIds[dstAddress].length] = tokenId;
    }
}

