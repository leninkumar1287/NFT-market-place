const ERC721Auction = artifacts.require("ERC721Auction")

contract("ERC721Auction", (accounts) => {
    let bidder1 = accounts[1];
    let bidder2 = accounts[2];
    let ERC721Token = null;
    before(async () => {
        console.log("accounts : ", accounts);
    })

    it("Contract should be deployed", async () => {
        ERC721Token = await ERC721Auction.deployed();
        console.log("ERC721Token : ", ERC721Token)
        assert(ERC721Token.address)
    })

    it("Auction should be start", async () => {
        await ERC721Token.start();
        let auctionStatus = await ERC721Token.activeStatuOfAuction();
        assert(auctionStatus == true);
    })

    it("User can bid and checking with heighest bidder", async () => {
        let v = await ERC721Token.bid({ from : bidder1, value: 3 });
        await ERC721Token.bid({ from : bidder2, value: 4 });
        let HeighestBidder = await ERC721Token.viewHeigestBid();
        console.log(" this is out  : ", v); 
        console.log(" this is out  : ", HeighestBidder);
        assert(HeighestBidder == bidder2);
    })

    it("End function to end the auction", async () => {
        let beforeEnd = await ERC721Token.activeStatuOfAuction();
        await ERC721Token.end();
        let afterEnd = await ERC721Token.activeStatuOfAuction();
        console.log(" this is out  : ", afterEnd);
        assert(beforeEnd == (!afterEnd));
    })
    
    it("if your lose the auction then bids can be withdraw after the auction end ", async () => {
        // actual bid value is 3
        let adder = BigInt(3)
        let requester= accounts[1];
        let beforeWithdraw = await ERC721Token.balance(requester);
        await ERC721Token.withdraw(requester);
        let afterWithdraw = await ERC721Token.balance(requester);
        assert(BigInt(beforeWithdraw)+adder == BigInt(afterWithdraw));
    })
})