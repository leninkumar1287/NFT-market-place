pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721 {

/// Note: structure of the NFT
    struct ArtItem {
        address payable seller;
        uint256 minbid;
        string tokenURI;
        bool exists;
        uint256 bidIncrement;
        uint256 time;
        uint256 timePeriod;
        bool cancelled;
        bool auctionstarted;
        string name;
    }

    struct bidding {
        //highestBindingBid of the tokenid
        uint256 highestBindingBid;
        address payable highestBidder;
    }
    mapping(uint256 => ArtItem) private _artItem;
    address public owner;
    uint256 public _tokenIds;
    uint256 public _artItemIds;
    //Unique ID up images for sale but not tokenized
    mapping(uint256 => mapping(address => uint256)) public fundsByBidder;
    //map _artItemIds to fundsByBidder
    //Map tokenIds to _artItemIds so as to connect to struct.
    mapping(int256 => uint256) token;
    //mapping tokenid to bidding
    mapping(uint256 => bidding) public bid;
    bool firstTime = false;

    event Bid(address indexed bidder,uint256 indexed artItemId,uint256 bid,address indexed highestBidder,uint256 highestBid,uint256 highestBindingBid);
    event Withdrawal(address indexed withdrawer, address indexed withdrawalAccount,uint256 amount);
    event AddItem(uint256 _artItemIds, string name,address payable indexed seller,uint256 price,uint256 nowTime,uint256 timePeriod);

    constructor() public ERC721("NORTH", "NRT")
    {
        owner = msg.sender;
    }

    modifier artItemExist(uint256 id) {
        require(_artItems[id].exists, "Not Found");
        _;
    }

    modifier onlyNotOwner(uint256 id) {
        //Check if owner is calling
        ArtItem memory artItem = _artItems[id];
        if (msg.sender == artItem.seller) 
        revert();
        _;
    }

    modifier onlyOwner(uint256 id) {
        ArtItem memory artItem = _artItems[id];
        if (msg.sender != artItem.seller) 
        revert();
        _;
    }

    modifier minbid(uint256 id) {
        ArtItem memory artItem = _artItems[id];
        if (msg.value < artItem.minbid) 
        revert();
        _;
    }
}