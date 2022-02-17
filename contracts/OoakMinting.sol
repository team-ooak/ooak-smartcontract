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
        //require(bytes(getNameTag(twitchId)).length == 0, "already register nameTag");
        require(!isNameTagExist[nameTag], "this nameTag already exist");
        require(lastTokenId < firstPreSaleLimit, "The first presale is sold out");

        lastTokenId++;

        IdToAddress[twitchId] = publicKey;
        //AddressToTokenId[publicKey] = lastTokenId;
        AddressToTokenIds[publicKey].push(lastTokenId);
        TokenIdToNameTag[lastTokenId] = nameTag;
        isNameTagExist[nameTag] = true;
    }

    //solidity 0.8.0 버전 이하에는 ABIEncoder V2가 적용되지 않아서 string array를 사용할 수 없음
    //pragma experimental ABIEncoderV2; 를 적용하면 될 수 있지만, 보안상 취약할 수 있음
    // function getNameTags(string memory twitchId) public view returns (string[] memory) {
    //     uint256[] memory _tokenIds = getTokenIds(twitchId);
    //     string[] memory _nameTags;
    //     for (uint i=0; i<_tokenIds.length; i++) _nameTags[i] = getNameTagWithTokenId(_tokenIds[i]);
    //     return _nameTags;
    // }
    function getNameTagByIndex(string memory twitchId, uint256 index) public view returns (string memory) {
        uint256[] memory _tokenIds = getTokenIds(twitchId);
        return getNameTagWithTokenId(_tokenIds[index]);
    }
    //Name Tag 개수 가져오기
    function getNameTagNumber(string memory twitchId) public view returns (uint256) { 
        uint256[] memory _tokenIds = getTokenIds(twitchId);
        return _tokenIds.length;
    }


    function getNameTagWithTokenId(uint256 tokenId) public view returns (string memory) {
        return TokenIdToNameTag[tokenId];
    }

    function getAddress(string memory twitchId) public view returns (address) {
        return IdToAddress[twitchId];
    }

    //solidity 0.8.0 버전 이하에는 ABIEncoder V2가 적용되지 않아서 string array를 사용할 수 없음
    //pragma experimental ABIEncoderV2; 를 적용하면 될 수 있지만, 보안상 취약할 수 있음
    // function getTokenURIs(string memory twitchId) public view returns (string[] memory) {
    //     require(IdToAddress[twitchId] != address(0), "address do not exist");
    //     address _address = IdToAddress[twitchId];
    //     uint256[] memory _tokenIds = AddressToTokenIds[_address];
    //     string[] memory _tokenURIs;
    //     for (uint i=0; i<_tokenIds.length; i++) _tokenURIs[i] = TokenIdToTokenURI[_tokenIds[i]];
    //     return _tokenURIs;
    // }
    function getTokenByIndex(string memory twitchId, uint256 index) public view returns (uint256) {
        require(IdToAddress[twitchId] != address(0), "address do not exist");
        address _address = IdToAddress[twitchId];
        return AddressToTokenIds[_address][index];
    }
    //Token 개수 가져오기
    function getTokenNumber(string memory twitchId) public view returns (uint256) { 
        require(IdToAddress[twitchId] != address(0), "address do not exist");
        address _address = IdToAddress[twitchId];
        return AddressToTokenIds[_address].length;
    }


    function getTokenIds(string memory twitchId) public view returns (uint256[] memory) {
        address _address = IdToAddress[twitchId];
        return AddressToTokenIds[_address];
    }
    

    // TODO 확인 필요
    function mintNFTWithTokenURI(string memory twitchId, string memory tokenURI) onlyOwner public {
        require(IdToAddress[twitchId] != address(0), "address do not exist");
        address publicKey = IdToAddress[twitchId];
        uint256[] memory tokenIds = AddressToTokenIds[publicKey];
        KIP17Token(NftContract).mintWithTokenURI(publicKey, tokenIds[tokenIds.length-1], tokenURI); //tokenIds 중 마지막 tokenId 이용
        TokenIdToTokenURI[tokenIds.length-1] = tokenURI;
    }


    function setNFTContract(address nftContract) onlyOwner public {
        NftContract = nftContract;
    }
    
    
    function changeOwnerOfNameTag(address srcAddress, address dstAddress, uint256 tokenId) public {
        require(msg.sender == NftContract);
        
        //tokenId가 있는 자리 delete
        uint deletedPlace = 0;
        for(uint i=0; i<AddressToTokenIds[srcAddress].length; i++){
            if(AddressToTokenIds[srcAddress][i] == tokenId){
                delete AddressToTokenIds[srcAddress][i];
                deletedPlace = i;
                break;
            }
        }
        //delete 한 자리 뒤 쪽 앞으로 당기기
        for(uint i=deletedPlace; i<AddressToTokenIds[srcAddress].length-1; i++){
            
            AddressToTokenIds[srcAddress][i] = AddressToTokenIds[srcAddress][i+1];
        }
        AddressToTokenIds[srcAddress].pop;

        //dstAddress 뒤에 tokenId 추가
        AddressToTokenIds[dstAddress][AddressToTokenIds[dstAddress].length] = tokenId;
    }
}
