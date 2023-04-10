import { ethers } from "hardhat";

export const blockNumber = async () => {
  return await ethers.provider.getBlockNumber();
};

export const increaseTime = async (seconds: number) => {
  await ethers.provider.send("evm_increaseTime", [seconds]);
  await ethers.provider.send("evm_mine", []);
};

// block time in second unit
export const mineToBlock = async (blockNumber: number, blockTime = 13) => {
  for (let i = 0; i < blockNumber; i++) {
    await increaseTime(blockTime);
  }
};

export const takeSnapshot = async () => {
  const result = await ethers.provider.send("evm_snapshot", []);
  await mineToBlock(1);
  return result;
};

export const restoreSnapshot = async (id: string) => {
  await ethers.provider.send("evm_revert", [id]);
  await mineToBlock(1);
};
