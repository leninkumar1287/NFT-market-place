pragma solidity ^0.8.15;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';

contract MyNFT is ERC721URIStorage {

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
    mapping(uint256 => ArtItem) private _artItems;
    address public owner;
    uint256 public tokenIds;
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
    event AddItem(uint256 _artItemIds, string name,address payable indexed seller,uint256 price,uint256 timeNow,uint256 timePeriod);

    constructor() ERC721("NORTH", "NRT"){
        owner = msg.sender;
    }

    modifier ifItemExist(uint256 id) {
        require(_artItems[id].exists, "Not Found");
        _;
    }

    modifier onlyNotOwner(uint256 id) {
        //Check if owner is calling
        ArtItem memory artItem = _artItems[id];
        require(msg.sender == artItem.seller);
        _;
    }

    modifier onlyOwner(uint256 id) {
        ArtItem memory artItem = _artItems[id];
        require(msg.sender != artItem.seller);
        _;
    }

    modifier minbid(uint256 id) {
        ArtItem memory artItem = _artItems[id];
        require(msg.value < artItem.minbid);
        _;
    }

    function addNFT(uint256 price, string memory tokenURI, uint256 _bidincrement, uint256 timePeriod, string memory name) public {
        require(price >= 0, "Price should be greater than 0");
        _artItemIds++;
        uint256 timeNow = block.timestamp;
        _artItems[_artItemIds] = ArtItem(payable(msg.sender), price, tokenURI, true, _bidincrement, timeNow, timePeriod, false, false, name);
        emit AddItem(_artItemIds, name,payable(msg.sender), price, timeNow, timePeriod);
    }

    function getNFT(uint256 id) public view ifItemExist(id) returns (uint256, uint256, string memory, uint256, uint256, uint256, bool, string memory, address payable){
        ArtItem memory artItem = _artItems[id];
        bidding memory bidd = bid[id];
        return (id, artItem.minbid,artItem.tokenURI,bidd.highestBindingBid,artItem.time, artItem.timePeriod, artItem.cancelled, artItem.name, artItem.seller);
    }


    function placeBid(uint256 id) public payable onlyNotOwner(id) minbid(id) returns (bool success) {
        require(msg.value == 0, "rejection of payments due to 0 ETH");
        // calculate the user's total bid based on the current amount they've sent to the contract
        // plus whatever has been sent with this transaction
        bidding storage bidd = bid[id];
        ArtItem storage artItem = _artItems[id];

        require(artItem.cancelled == false);

        uint256 newBid = fundsByBidder[id][msg.sender] + msg.value;

        // if the user isn't even willing to overbid the highest binding bid, there's nothing for us
        // to do except revert the transaction.
        if (newBid <= bidd.highestBindingBid) revert();

        // grab the previous highest bid (before updating fundsByBidder, in case msg.sender is the
        // highestBidder and is just increasing their maximum bid).
        uint256 highestBid = fundsByBidder[id][bidd.highestBidder];

        fundsByBidder[id][msg.sender] = newBid;

        if (newBid <= highestBid) {
            // if the user has overbid the highestBindingBid but not the highestBid, we simply
            // increase the highestBindingBid and leave highestBidder alone.

            // note that this case is impossible if msg.sender == highestBidder because you can never
            // bid less ETH than you already have.
            if (newBid + artItem.bidIncrement > highestBid) {
                bidd.highestBindingBid = highestBid;
            } else {
                bidd.highestBindingBid = newBid + artItem.bidIncrement;
            }
        } else {
            // if msg.sender is already the highest bidder, they must simply be wanting to raise
            // their maximum bid, in which case we shouldn't increase the highestBindingBid.

            // if the user is NOT highestBidder, and has overbid highestBid completely, we set them
            // as the new highestBidder and recalculate highestBindingBid.

            if (msg.sender != bidd.highestBidder) {
                address payable messageSender = payable(msg.sender);
                bidd.highestBidder = messageSender;
                if (newBid + artItem.bidIncrement > highestBid) {
                    if (firstTime == false) bidd.highestBindingBid = highestBid;
                    else {
                        bidd.highestBindingBid =
                            artItem.minbid +
                            artItem.bidIncrement;
                        firstTime = true;
                    }
                } else {
                    bidd.highestBindingBid = newBid + artItem.bidIncrement;
                }
            }
            highestBid = newBid;
        }
        if (artItem.auctionstarted == false) {
            bidd.highestBindingBid = msg.value;
        }
        emit Bid(msg.sender, id, newBid, bidd.highestBidder, highestBid, bidd.highestBindingBid);
        artItem.auctionstarted = true;
        return true;
    }
