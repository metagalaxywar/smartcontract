const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const MetaGalaxyWarToken = artifacts.require("MetaGalaxyWarToken");
module.exports = async function (deployer,network) {
    await deployer.deploy(MetaGalaxyWarToken);
    // await deployProxy(MetaGalaxyWarToken, {deployer});
}