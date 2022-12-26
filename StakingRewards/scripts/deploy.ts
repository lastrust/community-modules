import { ethers, run } from "hardhat";
import { NomicLabsHardhatPluginError } from "hardhat/plugins";
import { config } from "./config";

async function main() {
  const StakingRewardsFactory = await ethers.getContractFactory(
    "StakingRewards"
  );
  const stakingRewards = await StakingRewardsFactory.deploy(
    config.rewardsToken,
    config.stakingToken,
    config.duration
  );

  await stakingRewards.deployed();

  console.log(`StakingRewards was deployed to ${stakingRewards.address}`);

  try {
    console.log("\n>>>>>>>>>>>> Verification >>>>>>>>>>>>\n");

    console.log("Verifying: ", stakingRewards.address);
    await run("verify:verify", {
      address: stakingRewards.address,
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
