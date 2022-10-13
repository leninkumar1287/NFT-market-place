const ERC721Auction = artifacts.require("ERC721Auction");

module.exports = function (deployer) {
  deployer.deploy(ERC721Auction, "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", 123, 2);
};