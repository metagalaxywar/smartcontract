const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const TokenSale = artifacts.require("TokenSale");
const MetaGalaxyWarToken = artifacts.require("MetaGalaxyWarToken");
module.exports = async function (deployer,network) {
    var usdtAddress = "0x55d398326f99059ff775485246999027b3197955";

    if(network=="testnet"){
        usdtAddress = "0x4f8518407f00d26358BB7bca3E82682f50030002";
    }
    await deployProxy(TokenSale,[ MetaGalaxyWarToken.address, usdtAddress], {deployer});
}