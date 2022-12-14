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

  // Creating the instance and contract info for the BZAccessControl
  const BZAccessControl = await ethers.getContractFactory("BZAccessControl");
  const bzaccesscontrol = await BZAccessControl.deploy();

  await bzaccesscontrol.deployed();

  // Saving the info to be logged in the table (deployment info)
  var bzaccessControlLog = {
    Label: "Deployed BZAccessControl Address",
    Info: bzaccesscontrol.address,
  };

  console.table([deployerLog, deployerBalanceLog, bzaccessControlLog]);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
