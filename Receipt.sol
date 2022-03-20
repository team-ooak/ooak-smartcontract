pragma solidity ^0.5.0;

import "./Whitelist.sol";
import "./Nickname.sol";
import "./Ownable.sol";
import "./KIP17Token.sol";

contract Receipt is Ownable, KIP17Token {


    constructor(string memory name, string memory symbol)
    public 
    KIP17Token(name, symbol)
    Ownable() {
    }

}