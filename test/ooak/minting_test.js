const { assert } = require('chai');
const shouldFail = require('../helpers/shouldFail');

const OoakMinting = artifacts.require('OoakMinting.sol');
const OoakNFT = artifacts.require('OoakNFT.sol')

var mintContract
var nftContract
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

        mintContract = await OoakMinting.new({ from : accounts[0] });
        nftContract = await OoakNFT.new({ from : accounts[0]} );
        await nftContract.setOoakContract(mintContract.address, {from : accounts[0]});
        await mintContract.setNFTContract(nftContract.address, {from : accounts[0]});
        await nftContract.addMinter(mintContract.address, {from : accounts[0]});
    })

    describe('Register NameTag', function () {
        it("test for register : twitchId1, twitchId2, twitchId3", async function () {
            await mintContract.registerNameTag("twitchId1", addresses[0], "nameTag1", {from: accounts[0]})
            await mintContract.registerNameTag("twitchId2", addresses[1], "nameTag2")
            await mintContract.registerNameTag("twitchId3", addresses[2], "nameTag3")
        })
        it("test should fail : this nameTag already exist", async function () {
            await shouldFail.reverting.withMessage(
                mintContract.registerNameTag("twitchId4",addresses[3],"nameTag1"), 'this nameTag already exist');
        })
        it("test should fail : already register nameTag", async function () {
            await shouldFail.reverting.withMessage( 
                mintContract.registerNameTag("twitchId2",addresses[4],"nameTag4"), 'already register nameTag');
        })
        it("test should fail : only owner can register id", async function () {
            await shouldFail.reverting.withMessage( 
                mintContract.registerNameTag("twitchId6",addresses[5],"nameTag6",{from: accounts[1]}));
        })
    })
    describe('get NameTag', function () {
        it("get NameTag : twitchId1, twitchId2, twitchId3", async function () {
            assert.equal(await mintContract.getNameTag("twitchId1"), "nameTag1")
            assert.equal(await mintContract.getNameTag("twitchId2"), "nameTag2")
            assert.equal(await mintContract.getNameTag("twitchId3"), "nameTag3")
        })
    })
    describe('NFT', function () {
        it("mint", async function () {
            sampleId = "twitchId1"
            sampleURI = "URI1"

            await mintContract.mintNFTWithTokenURI(sampleId, sampleURI, {from: accounts[0]});
            _address = await mintContract.getAddress(sampleId)
            _tokenId = await mintContract.getTokenId(sampleId);
            _ownerAddress = await nftContract.ownerOf(_tokenId);
            _URI = await nftContract.tokenURI(_tokenId);
            assert.equal(_address, _ownerAddress)
            assert.equal(sampleURI, _URI);
        })
        it("transfer NFT : twitchId1 to twitchId2", async function () {
            _address1 = await mintContract.getAddress("twitchId1");
            _address2 = await mintContract.getAddress("twitchId2");
            _tokenId = await mintContract.getTokenId("twitchId1");
            await nftContract.safeTransferFrom(_address1, _address2, _tokenId.toNumber(), {from: _address1});

            assert.equal(await mintContract.getTokenId("twitchId2"), _tokenId.toNumber());
            assert.equal(await mintContract.getNameTagWithTokenId(_tokenId.toNumber()), "nameTag1");
        })
        it("getNameTag", async function () {
            assert.equal(await mintContract.getNameTag("twitchId2"), "nameTag1");
            assert.notEqual(await mintContract.getNameTag("twitchId1"), "nameTag1");
        }) 
    })

})
