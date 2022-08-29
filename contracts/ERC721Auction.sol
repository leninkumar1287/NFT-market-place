//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

interface IERC721 {
    function transferFrom (address from, address to, uint nftId) external;
}

contract ERC721Auction {
    event Start();
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    event End(address highestBidder, uint amount);

    IERC721 public immutable nft;
    uint public immutable nftId;
    address payable public immutable seller;
    uint32 public endAt;
    bool public started;
    bool public ended;
    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) bids;

    constructor(address _nft, uint _nftId, uint _startingBid) {
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable(msg.sender);
        highestBid = _startingBid;
        highestBidder = msg.sender;
    }

    modifier onlyOwner(address owner) {
        require(owner == seller);
        _;
    }

    modifier minbid(uint256 bidValue) {
       require(bidValue > highestBid, "bid value is low");
        _;
    }

    function start() onlyOwner(msg.sender)external{
        address payable owner = payable(msg.sender);
        require(owner == seller, "not a seller");
        require(!started, "started");
        started = true;
        endAt = uint32(block.timestamp + 300);
        emit Start();
    }
    function bid() external payable minbid(msg.value){
        require(started, "Auction not started");
        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }
        highestBid = msg.value;
        highestBidder = msg.sender;
        emit Bid(msg.sender, msg.value);
    }
    function withdraw() external {
        uint bal = bids[msg.sender];
        // bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);
        emit Withdraw(msg.sender, bal);
    }
    function end() external onlyOwner(msg.sender){
        require(started, "not started");
        require(!ended, "ended!");
        require(block.timestamp >= endAt, "not ended");
        ended = true;
        if (highestBidder != address(0)) {
            nft.transferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        } else {
            nft.transferFrom(address(this), seller, nftId);
        }
        emit End(highestBidder, highestBid);
    }
}