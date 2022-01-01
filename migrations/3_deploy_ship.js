const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const Ship = artifacts.require("Ship");
module.exports = async function (deployer,network) {
    await deployProxy(Ship,[], {deployer});
}