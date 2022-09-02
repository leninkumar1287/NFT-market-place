const ERC721Auction = artifacts.require("ERC721Auction")
var utils = require('ethers').utils;

contract("ERC721Auction", (accounts) => {
    let bidder1 = accounts[1];
    let bidder2 = accounts[2];
    let ERC721Token = null;
    before(async () => {
        console.log("accounts : ", accounts);
    })

    it("Contract should be deployed", async () => {
        ERC721Token = await ERC721Auction.deployed();
        assert(ERC721Token.address)
    })

    it("Auction should be start", async () => {
        await ERC721Token.start();
        let auctionStatus = await ERC721Token.activeStatuOfAuction();
        assert(auctionStatus == true);
    })

    it("User can bid and checking with heighest bidder", async () => {
        await ERC721Token.bid({ from : bidder1, value: 3 });
        await ERC721Token.bid({ from : bidder2, value: 4 });
        let HeighestBidder = await ERC721Token.viewHeigestBid();
        assert(HeighestBidder == bidder2);
    })

    it("End function to end the auction", async () => {
        let beforeEnd = await ERC721Token.activeStatuOfAuction();
        await ERC721Token.end();
        let afterEnd = await ERC721Token.activeStatuOfAuction();
        assert(beforeEnd == (!afterEnd));
    })
    
    it("if your lose the auction then bids can be withdraw after the auction end ", async () => {
        let requester= accounts[1];
        let beforeWithdraw = await ERC721Token.balance(requester);
        let beforeValue = BigInt(beforeWithdraw).toString();
        await ERC721Token.withdraw(requester);
        let afterWithdraw = await ERC721Token.balance(requester);
        let afterValue = BigInt(afterWithdraw).toString();
        console.log("",beforeValue,"\n",afterValue.length)
        var wei = utils.bigNumberify(beforeValue+4);
        console.log("\n",wei.toString())
        assert(BigInt(beforeWithdraw).toString() == BigInt(afterWithdraw).toString());
    })
})