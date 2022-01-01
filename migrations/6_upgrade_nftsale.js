const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');
const NFTSale = artifacts.require("NFTSale");
const Ship = artifacts.require("Ship");
const MetaGalaxyWarToken = artifacts.require("MetaGalaxyWarToken");
module.exports = async function (deployer,network) {
    
    await upgradeProxy(NFTSale.address,NFTSale, {deployer});
}