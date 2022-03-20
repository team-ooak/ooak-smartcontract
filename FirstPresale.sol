pragma solidity ^0.5.0;

import "./IdTag.sol";
import "./Ownable.sol";
import "./Whitelist.sol";
import "./Nickname.sol";
import "./Receipt.sol";
import "./FirstPresaleBuyer.sol";

contract FirstPresale is Ownable {
    using SafeMath for uint256;

    IdTag public nft;
    Receipt public receipt;
    Whitelist public wl;
    Nickname public nickname;
    FirstPresaleBuyer public buyer;

    uint256 public mintPrice = 20 * 1e18;
    uint256 public nowNum = 1;
    uint256 public presaleLimit = 960;
    uint256 public finalMintNum;
    bool public saleState = true;

    constructor(address _nft,address _receipt ,address _wl, address _nickname, address _buyer) public {
        nft = IdTag(_nft);
        receipt = Receipt(_receipt);
        wl = Whitelist(_wl);
        nickname = Nickname(_nickname);
        buyer = FirstPresaleBuyer(_buyer);

    }



    function nftReceiptMint(string memory _nickname) external payable  {
        require(saleState == true);
        require(wl.isWhitelist(msg.sender));
        require(presaleLimit > nowNum);
        require(msg.value == mintPrice);

        string memory tokenURI = "https://gateway.pinata.cloud/ipfs/QmWi7pw84v4u1ZsZSDyLBmovzafdvCvWkU2wECXxTo9tJL";//test용 uri
        nickname.putIn(nowNum, _nickname);
        receipt.mintWithTokenURI(msg.sender, nowNum, tokenURI);
        buyer.putIn(msg.sender);

        nowNum = nowNum.add(1);
    }

    function nftIdTagMint(uint256 _to, uint256 _from) public onlyOwner {
        require(_from > 0 );
        require(_to > 0 );
        require(_to <= buyer.totalNum());
        require(saleState == true);
        string memory tokenURI = "ipfs://QmPNjTEBcHY8a5VDmSQ57ZSyNUJ32HQwnfe2HrYw2sPPq6";//test용 uri
        for(uint256 i = _from; i <= _to; i++) {
            nft.mintWithTokenURI(buyer.buyerList(i-1), i, tokenURI);
            finalMintNum = _to;
        }
    }

    function setSaleState(bool newState) public onlyOwner {
        saleState = newState;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        msg.sender.transfer(balance);
    }
}