pragma solidity ^0.5.0;

import "./Ownable.sol";

// minting한 사람만 추가되도록 보안 강화 필요
contract FirstPresaleBuyer is Ownable {
    mapping(address => bool) public isBuyer;
    uint256 public totalNum;
    address[] public buyerList;
    bool public buyerListIsActive = true;


    function putIn(address _buyer) external {
        require(buyerListIsActive);
        require(!isBuyer[msg.sender]);
        isBuyer[_buyer] = true;
        buyerList.push(_buyer);
        totalNum += 1;
    }

    function setbuyerListState(bool newState) public onlyOwner {
        buyerListIsActive = newState;
    }

    constructor() public Ownable() {}
}