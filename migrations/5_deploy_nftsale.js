const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const NFTSale = artifacts.require("NFTSale");
const Ship = artifacts.require("Ship");
const MetaGalaxyWarToken = artifacts.require("MetaGalaxyWarToken");
module.exports = async function (deployer,network) {
    var usdtAddress = "0x55d398326f99059ff775485246999027b3197955";

    if(network=="testnet"){
        usdtAddress = "0x4f8518407f00d26358BB7bca3E82682f50030002";
    }
    var amounts = [5000,3000,2500,2000,1500,1000];
    var prices = ["156000000000000000","311000000000000000","466000000000000000","622000000000000000","777000000000000000","1127000000000000000"] ;
    var nftSale = await deployProxy(NFTSale,[Ship.address,prices,usdtAddress, "0x8422e482AA9C5A9aEd5a545A62203B1D057de0b0",amounts], {deployer});
    var ship = await Ship.deployed();
    await ship.grantPlatform(nftSale.address);
}