pragma solidity ^0.5.0;

import './Ownable.sol';
import './Whitelist.sol';

contract Nickname is Ownable{
    mapping (string => bool) public isRegisterd;
    mapping (uint256 => string) public tokenIdToNickname;
    mapping (string => uint256) public nicknameToTokenId;
    string[] public nl;
    bool public nlIsActive = true;
    uint256 public totalNum;
    Whitelist public wl;

    constructor(Whitelist _wl) public Ownable(){
        wl = _wl;
    }

    function putIn(uint256 _tokenId, string calldata _nickname) external {
        require(nlIsActive == true);
        require(isRegisterd[_nickname] != true, "The nickname is already registered");
        // require(wl.isWhitelist(msg.sender) == true, "You are not in WL");

        isRegisterd[_nickname] = true;
        tokenIdToNickname[_tokenId] = _nickname;
        nicknameToTokenId[_nickname] = _tokenId;
        nl.push(_nickname);

        totalNum = totalNum + 1;
    }

    function setNLState(bool newState) public onlyOwner {
        nlIsActive = newState;
    }
}