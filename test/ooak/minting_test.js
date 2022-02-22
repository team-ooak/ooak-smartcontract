const { assert } = require('chai');
const shouldFail = require('../helpers/shouldFail');

const OoakMinting = artifacts.require('OoakMinting.sol');
const OoakNFT = artifacts.require('OoakNFT.sol')
const OoakData = artifacts.require('OoakData.sol');

var mintContract
var nftContract
var dataContract
var addresses

contract('Score Test', function (accounts) {
    before(async function () {
        addresses = [
            accounts[1],
            accounts[2],
            accounts[3],
            accounts[4],
            accounts[5],
            accounts[6],
        ]
        dataContract = await OoakData.new({from : accounts[0]});
        mintContract = await OoakMinting.new({ from : accounts[0] });
        nftContract = await OoakNFT.new({ from : accounts[0]} );
        // set NFT contract
        await nftContract.setOoakContract(mintContract.address, {from : accounts[0]});
        await mintContract.setNFTContract(nftContract.address, {from : accounts[0]});
        await nftContract.addMinter(mintContract.address, {from : accounts[0]});
        // set Data contract
        await dataContract.transferOwnership(mintContract.address, {from : accounts[0]});
        await mintContract.setDataContract(dataContract.address, {from : accounts[0]});
    })

    describe('Register NameTag', function () {
        it("test for register : twitchId1, twitchId2, twitchId3", async function () {
            await mintContract.registerNameTagForFirstPreSale("twitchId1", "nameTag1", {from: addresses[0]})
            await mintContract.registerNameTagForFirstPreSale("twitchId2", "nameTag2", {from: addresses[1]})
            await mintContract.registerNameTagForFirstPreSale("twitchId3", "nameTag3", {from: addresses[2]})
        })
        it("test for register : twitchId4 have two nameTags", async function () {
            await mintContract.registerNameTagForFirstPreSale("twitchId4", "nameTag4", {from: addresses[3]})
            await mintContract.registerNameTagForFirstPreSale("twitchId4", "nameTag5", {from: addresses[3]})
        })
        it("test should fail : this nameTag already exist", async function () {
            await shouldFail.reverting.withMessage(
                mintContract.registerNameTagForFirstPreSale("twitchId4", "nameTag1", {from: addresses[3]}), 'this nameTag already exist');
        })
        it("test get nameTag when not minted yet", async function () {
            nametag = await mintContract.getNameTag("twitchId1", {from: addresses[1]});
            assert.equal(nametag, "");
        })
    })

    describe('mint NFT and Transfer', function () {
        it("mint", async function () {
            await mintContract.mintNFTWithTokenURI("twitchId1", "URI1", {from: accounts[0]});
            mintedTokenIdList = await mintContract.getMintedTokenIdList("twitchId1");
            assert.equal(addresses[0], await nftContract.ownerOf(mintedTokenIdList[0]));
            assert.equal(await mintContract.getNameTag("twitchId1"), "nameTag1");
        })
        it("transfer NFT : twitchId1 to twitchId2", async function () {
            mintedTokenIdList = await mintContract.getMintedTokenIdList("twitchId1");
            _tokenId = mintedTokenIdList[0];
            await nftContract.safeTransferFrom(addresses[0], addresses[1], _tokenId.toNumber(), {from: addresses[0]});
            mintedTokenIdList2 = await mintContract.getMintedTokenIdList("twitchId2");

            assert.equal(_tokenId, mintedTokenIdList2[0].toNumber());
        })
        it("getNameTag", async function () {
            assert.equal(await mintContract.getNameTag("twitchId2"), "nameTag1");
            assert.notEqual(await mintContract.getNameTag("twitchId1"), "nameTag1");
        }) 
    })

    describe('mint and get NameTag', function () {
        it("get NameTag : twitchId2, twitchId3", async function () {
            await mintContract.mintNFTWithTokenURI("twitchId2", "URI2", {from: accounts[0]});
            await mintContract.mintNFTWithTokenURI("twitchId3", "URI3", {from: accounts[0]});
            await mintContract.setTokenIdFirst("twitchId2", 1, {from: addresses[1]});
            assert.equal(await mintContract.getNameTag("twitchId2"), "nameTag2")
            assert.equal(await mintContract.getNameTag("twitchId3"), "nameTag3")
        })
        it("get NameTag : twitchId4", async function () {
            // mint는 rawTokenIds의 마지막 tokenId부터 된다
            await mintContract.mintNFTWithTokenURI("twitchId4", "URI5", {from: accounts[0]});
            await mintContract.mintNFTWithTokenURI("twitchId4", "URI4", {from: accounts[0]});
            assert.equal(await mintContract.getNameTag("twitchId4"), "nameTag5")
            await mintContract.setTokenIdFirst("twitchId4", 1, {from: addresses[3]});
            assert.equal(await mintContract.getNameTag("twitchId4"), "nameTag4")
        })
    })
    

})
