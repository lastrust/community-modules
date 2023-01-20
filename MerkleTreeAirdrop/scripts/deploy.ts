import { ethers, run } from "hardhat";
import { NomicLabsHardhatPluginError } from "hardhat/plugins";
import { config } from "./config";

async function main() {
  const MerkleTreeAirdropFactory = await ethers.getContractFactory(
    "MerkleTreeAirdrop"
  );
  const merkleTreeAirdrop = await MerkleTreeAirdropFactory.deploy(
    config.token,
    config.merkleRoot
  );

  await merkleTreeAirdrop.deployed();

  console.log(`MerkleTreeAirdrop was deployed to ${merkleTreeAirdrop.address}`);

  try {
    console.log("\n>>>>>>>>>>>> Verification >>>>>>>>>>>>\n");

    console.log("Verifying: ", merkleTreeAirdrop.address);
    await run("verify:verify", {
      address: merkleTreeAirdrop.address,
      constructorArguments: [
        config.token,
        config.merkleRoot,
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
