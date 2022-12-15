const { ethers } = require("hardhat");

// The deployment script
async function main() {
  // Getting the first signer as the deployer
  const [deployer] = await ethers.getSigners();
  // Saving the info to be logged in the table (deployer address)
  var deployerLog = {
    Label: "Deploying Address",
    Info: deployer.address,
  };
  // Saving the info to be logged in the table (deployer balance)
  var deployerBalanceLog = {
    Label: "Deployer ETH Balance",
    Info: (await deployer.getBalance()).toString(),
  };

  // Creating the instance and contract info for the AccessControl
  const AccessControl = await ethers.getContractFactory("AccessControl");
  const accesscontrol = await AccessControl.deploy();

  await accesscontrol.deployed();

  // Saving the info to be logged in the table (deployment info)
  var accessControlLog = {
    Label: "Deployed AccessControl Address",
    Info: accesscontrol.address,
  };

  console.table([deployerLog, deployerBalanceLog, accessControlLog]);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
