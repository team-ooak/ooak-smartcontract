// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.5.0;

import "./ownership/Ownable.sol";
import "./token/KIP17/KIP17Token.sol";
import "./OoakNFT.sol";
import "./OoakDataInterface.sol";
import "./OoakData.sol";


contract OoakMinting is Ownable, OoakDataInterface {

    uint256 constant firstPreSaleLimit = 960;
    uint256 constant airDropEventLimit = 1000;
    OoakNFT NftContract;
    OoakData DataContract;

    function setNFTContract(address nftContract) onlyOwner public {
        NftContract = OoakNFT(nftContract);
    }

    function setDataContract(address dataContract) onlyOwner public {
        DataContract = OoakData(dataContract);
    }

    function registerNameTagForFirstPreSale(string memory twitchId, string memory nameTag) public {
        require(!DataContract.getIsNameTagExist(nameTag), "this nameTag already exist");
        require(DataContract.getLastTokenId() < firstPreSaleLimit, "The first presale is sold out");

        DataContract.incLastTokenId();
        uint256 lastTokenId = DataContract.getLastTokenId();

        // 유저가 존재하지 않을 때 생성해야 한다
        if (DataContract.getAddress(twitchId) == address(0x0)) {
            uint256[] memory _rawList;
            uint256[] memory _mintedList;
            DataContract.setIdToUser(twitchId, msg.sender, _rawList, _mintedList);
            DataContract.setAddressToId(msg.sender, twitchId);
        }
        
        DataContract.pushRawTokenId(twitchId, lastTokenId);
        DataContract.setTokenIdToToken(lastTokenId, nameTag, "", false);
        DataContract.setIsNameTagExist(nameTag, true);
    }

    function registerNameTagByOwner(string memory twitchId, address publicAddress, string memory nameTag) public onlyOwner {
        require(!DataContract.getIsNameTagExist(nameTag), "this nameTag already exist");
        require(DataContract.getLastTokenId() < airDropEventLimit, "airdrop Event end");

        DataContract.incLastTokenId();
        uint256 lastTokenId = DataContract.getLastTokenId();

        // 유저가 존재하지 않을 때 생성해야 한다
        if (DataContract.getAddress(twitchId) == address(0x0)) {
            uint256[] memory _rawList;
            uint256[] memory _mintedList;
            DataContract.setIdToUser(twitchId, publicAddress, _rawList, _mintedList);
            DataContract.setAddressToId(publicAddress, twitchId);
        }
        
        DataContract.pushRawTokenId(twitchId, lastTokenId);
        DataContract.setTokenIdToToken(lastTokenId, nameTag, "", false);
        DataContract.setIsNameTagExist(nameTag, true);
    }

    // 민팅 기회를 놓치고 추후 네임 태그를 NFT로 거래해 사려는 사람의 경우 먼저 User를 만들고 거래해야 한다
    function createUser(string memory twitchId) public {
        require(bytes(DataContract.getId(msg.sender)).length == 0, "you are already user");
        uint256[] memory _rawList;
        uint256[] memory _mintedList;

        DataContract.setIdToUser(twitchId, msg.sender, _rawList, _mintedList);
        DataContract.setAddressToId(msg.sender, twitchId);
    } 

    // nameTag가 없다면 "" 반환
    function getNameTag(string memory twitchId) public view returns (string memory) {
        if(DataContract.getMintedTokenListLength(twitchId) == 0) return "";
        uint256 tokenId = DataContract.getMintedTokenIdByIndex(twitchId, 0);
        return DataContract.getTokenNameTag(tokenId);
    }

    // nameTag가 없다면 "" 반환
    function getNameTagURI(string memory twitchId) public view returns (string memory) {
        if(DataContract.getMintedTokenListLength(twitchId) == 0) return "";
        uint256 tokenId = DataContract.getMintedTokenIdByIndex(twitchId, 0);
        return DataContract.getTokenURI(tokenId);
    }

    function setTokenIdFirst(string memory twitchId, uint256 index) public {
        require(msg.sender == DataContract.getAddress(twitchId), "sender's address must be same with twtichId's address");
        require(DataContract.getMintedTokenListLength(twitchId) != 0, "This TwitchId doesn't have any NameTag");
        
        DataContract.swapMintedTokenIdInList(twitchId, 0, index);
    }
    
    // WARNING : rawTokenIds의 마지막 tokenId를 이용해 민팅한다
    function mintNFTWithTokenURI(string memory twitchId, string memory tokenURI) onlyOwner public {
        require(DataContract.getAddress(twitchId) != address(0x0), "address do not exist");
        require(DataContract.getRawTokenListLength(twitchId) != 0, "empty TokenId left to Mint");

        uint256 tokenId = DataContract.popRawTokenId(twitchId);

        //가스비를 아끼기 위해 rawtokenIds 중 마지막 tokenId 이용
        address publicAddress = DataContract.getAddress(twitchId);
        KIP17Token(NftContract).mintWithTokenURI(publicAddress, tokenId, tokenURI);
        DataContract.pushMintedTokenId(twitchId, tokenId);

        string memory nameTag = DataContract.getTokenNameTag(tokenId);
        DataContract.setTokenIdToToken(tokenId, nameTag, tokenURI, true);
    }
    
    function changeOwnerOfToken(address srcAddress, address dstAddress, uint256 tokenId) public {
        require(msg.sender == address(NftContract), "sender does not match NFTcontract");
        require(bytes(DataContract.getId(dstAddress)).length != 0, "dstAddress is not user");

        string memory srcTwitchId = DataContract.getId(srcAddress);
        string memory dstTwitchId = DataContract.getId(dstAddress);

        uint256 mintedListLength = DataContract.getMintedTokenListLength(srcTwitchId);
        for (uint256 i=0; i < mintedListLength; i++) {
            if (DataContract.getMintedTokenIdByIndex(srcTwitchId, i) == tokenId){
                DataContract.swapMintedTokenIdInList(srcTwitchId, i, mintedListLength - 1);
                DataContract.popMintedTokenId(srcTwitchId);
                DataContract.pushMintedTokenId(dstTwitchId, tokenId);
                break;
            }
        }
    }

    function getMintedTokenIdList(string memory twitchId) public view returns (uint256[] memory ) {
        uint256 length = DataContract.getMintedTokenListLength(twitchId);
        uint256[] memory list = new uint256[](length);
        for (uint256 i=0; i < length; i++) {
            list[i] = (DataContract.getMintedTokenIdByIndex(twitchId, i));
        }
        return list;
    }

    function getRawMintedTokenIdList(string memory twitchId) public view returns (uint256[] memory) {
        uint256 length = DataContract.getRawTokenListLength(twitchId);
        uint256[] memory list = new uint256[](length);
        for (uint256 i=0; i < length; i++) {
            list[i] = (DataContract.getMintedTokenIdByIndex(twitchId, i));
        }
        return list;
    }
}
