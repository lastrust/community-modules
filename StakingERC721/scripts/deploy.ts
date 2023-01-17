import { ethers, run } from "hardhat";
import { NomicLabsHardhatPluginError } from "hardhat/plugins";
import { config } from "./config";

async function main() {
  const StakingERC721Factory = await ethers.getContractFactory("StakingERC721");
  const stakingERC721 = await StakingERC721Factory.deploy(
    config.rewardsToken,
    config.stakingToken,
    config.duration
  );

  await stakingERC721.deployed();

  console.log(`StakingERC721 was deployed to ${stakingERC721.address}`);

  try {
    console.log("\n>>>>>>>>>>>> Verification >>>>>>>>>>>>\n");

    console.log("Verifying: ", stakingERC721.address);
    await run("verify:verify", {
      address: stakingERC721.address,
      constructorArguments: [
        config.rewardsToken,
        config.stakingToken,
        config.duration,
      ],
    });
  } catch (error) {
    if (
      error instanceof NomicLabsHardhatPluginError &&
      error.message.includes("Reason: Already Verified")
    ) {
      console.log("Already verified, skipping...");
    } else {
      console.error(error);
    }
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
