//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

/// @title NFT market place
/// @notice You can use this contract for selling NFT's
/// @dev All function calls are currently implemented without side effects
/// @custom:experimental This is an experimental contract.

contract ERC721Auction {

    //Events -> this could be emitted by the related function
    event Start();
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    event End(address highestBidder, uint amount);

    //State variables
    uint nftId;
    address nftAddress;
    address payable public immutable seller;
    uint32 public endAt;
    bool started;
    bool ended;
    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) bids;

    // Struct for saving the auction winner details and also NFT Details
    struct auctionWinner {
        uint nftIdentity;
        address buyer;
        address seller;
    }
    auctionWinner[] public winnerList;
    

    constructor(address _nft, uint _nftId, uint _startingBid) {
        nftAddress = _nft;
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
    /// @notice Starting the Auction
    /// @dev This function will start the auction, and only the seller can start the auction
    function start() onlyOwner(msg.sender)external{
        address payable owner = payable(msg.sender);
        require(owner == seller, "not a seller");
        require(!started, "started");
        started = true;
        endAt = uint32(block.timestamp + 30);
        emit Start();
    }

    /// @notice Bidding against the product
    /// @dev This function will start the auction, and only the seller can start the auction
    function bid() external payable minbid(msg.value){
        require(started, " auction not started ");
        require(seller != msg.sender, "you cant bid");
        require(started, "Auction not started");
        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }
        highestBid = msg.value;
        highestBidder = msg.sender;
        emit Bid(msg.sender, msg.value);
    }

    /// @notice withdraw the fund after the auction
    /// @dev Here you can withdraw if you lost in auction else you will get the NFT
    function withdraw(address bidderAddress) external {
        require(!started, " Auction not ended");
        uint bal = bids[bidderAddress];
        require(bal > 0, "you dont have any bidvalues");
        payable(bidderAddress).transfer(bal);
        emit Withdraw(bidderAddress, bal);
    }

    /// @notice transfer the NFT to winner of auction  
    /// @dev It end the auction status and also its transfer the NFT to the winner in auction
    function end() public onlyOwner(msg.sender){
        started = false;
        if(started == false)
        if(highestBidder != address(0)) {
            transferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        } else {
            transferFrom(address(this), seller, nftId);
        }
        emit End(highestBidder, highestBid);
    }

    /// @notice invoke transfer function & NFT to winner of auction  
    /// @dev Save the acution winner detail and NFT details
    function transferFrom(address from, address to, uint _nftId) internal returns(bool){
        auctionWinner memory result = auctionWinner(_nftId, from, to);
        winnerList.push(result);
        return true;
    }

    function activeStatuOfAuction() public view returns(bool) {
        return started;
    }

    function endStatusOfAuction() public view returns(bool) {
        return ended;
    }

    function viewHeigestBid() public view returns(address) {
        return highestBidder;
    }
    
    function balance(address requester) public view returns(uint bal) {
        bal = address(requester).balance;
        return bal;
    }

}