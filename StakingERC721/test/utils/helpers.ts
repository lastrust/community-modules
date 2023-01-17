import { ethers, network } from "hardhat";

export const now = async () => {
  const blockNumber = await ethers.provider.getBlockNumber();
  const block = await ethers.provider.getBlock(blockNumber);
  return block.timestamp;
};

export const blockNumber = async () => {
  return await ethers.provider.getBlockNumber();
};

export const increaseTime = async (seconds: number) => {
  await ethers.provider.send("evm_increaseTime", [seconds]);
  await ethers.provider.send("evm_mine", []);
};

export const setBlockTime = async (timestamp: number) => {
  await network.provider.send("evm_setNextBlockTimestamp", [timestamp]);
  await network.provider.send("evm_mine");
};

export const disableAutoMining = async () => {
  await network.provider.send("evm_setAutomine", [false]);
};

export const enableAutoMining = async (seconds: number) => {
  await network.provider.send("evm_setIntervalMining", [seconds]);
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
