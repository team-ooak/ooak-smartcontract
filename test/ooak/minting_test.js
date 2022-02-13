const { assert } = require('chai');
const shouldFail = require('../helpers/shouldFail');

const OoakMinting = artifacts.require('OoakMinting.sol');

var mintContract
var addresses
contract('Score Test', function (accounts) {
    before(async function () {
        mintContract = await OoakMinting.new({ from : accounts[0] });
        addresses = [
            "0x33ebcd60ce9291674bafE4cDfe156E976e39de88",
            "0x78a17cd56BE4E7b06a07Dc2823BAea29B7dDc650",
            "0xeEBACF33A62934f3bf8Ed43D2bb9Ed5Eaa3F290C",
            "0x39A8E4AB8dB61A22993C646B40ec5a4d58BF3B04",
            "0x12756876B8c3b37eF967fd4146fBA031f243395a",
            "0xCEe5CE3F45f2AD4AA6d637a7Cf94542518ecf79b",
        ]
    })

    describe('Register NameTag', function () {
        it("test for register : twitchId1, twitchId2, twitchId3", async function () {
            await mintContract.registerNameTag("twitchId1", addresses[0], "nameTag1", {from: accounts[0]})
            await mintContract.registerNameTag("twitchId2", addresses[1], "nameTag2")
            await mintContract.registerNameTag("twitchId3", addresses[2], "nameTag3")
            assert.equal(await mintContract.getNameTag("twitchId1"), "nameTag1")

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
    describe('Change score contract to ScoreV2', function () {
        it("deploy ScoreV2 contract", async function () {
  
        })
        it("test for accounts1", async function () {
            
        })
        it("test for accounts2", async function () {
            
        })
    })
})