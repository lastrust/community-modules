import { BigNumber as BN, constants } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { time } from "@nomicfoundation/hardhat-network-helpers";

const Decimals = BN.from(18);
const OneToken = BN.from(10).pow(Decimals);

import {
  Staking,
  Staking__factory,
  MockERC20,
  MockERC20__factory,
} from "../typechain-types";
import {max} from "hardhat/internal/util/bigint";
import {equal} from "assert";

describe("Test EscrowByAgent contract: ", () => {
  let owner: SignerWithAddress;
  let user1: SignerWithAddress;
  let user2: SignerWithAddress;
  let user3: SignerWithAddress;
  let user4: SignerWithAddress;
  let user5: SignerWithAddress;
  let feeWallet: SignerWithAddress;

  let stkToken: MockERC20;
  let stakingContract: Staking;


  const ethAmount = OneToken.mul(10);
  const amount = OneToken.mul(2000);
  const harvestFeePercent = 100;
  const maxFeePercent = 400;
  const rewardPerBlock = OneToken.div(1000);
  const totalReward = OneToken.mul(1000000);


  before(async () => {
    [owner, user1, user2, user3, user4, user5, feeWallet] = await ethers.getSigners();
  });

  describe("1. Deploy contracts", () => {
    it("Deploy mock contracts", async () => {
      const erc20Factory = new MockERC20__factory(owner);
      stkToken = await erc20Factory.deploy("Staking Token", "STK");
    });

    it("Deploy main contracts", async () => {
      const stakingFactory = new Staking__factory(owner);
      stakingContract = await stakingFactory.deploy(
        stkToken.address,
        rewardPerBlock,
        feeWallet.address,
        maxFeePercent,
        harvestFeePercent
      );
    });
  });

  describe("2. Token transfer", () => {
    it("transfer tokens mock contracts", async () => {
      await stkToken.transfer(user1.address, OneToken.mul(100000));
      await stkToken.transfer(user2.address, OneToken.mul(100000));
      await stkToken.transfer(user3.address, OneToken.mul(100000));
      await stkToken.transfer(user4.address, OneToken.mul(100000));
      await stkToken.transfer(user5.address, OneToken.mul(100000));
    });
  });

  describe("3. Function unit test: ", () => {
    describe("- setHarvestFee function: ", () => {
      it("setHarvestFee: feePercent invalid", async () => {
        await expect(
          stakingContract.setHarvestFee(maxFeePercent + 1)
        ).to.be.revertedWith("setHarvestFee: feePercent invalid");
      });

      it("depositByETH success !!!", async () => {
        const _harvestFeePercent = harvestFeePercent / 2;
        await stakingContract.setHarvestFee(_harvestFeePercent);

        await expect(await stakingContract.harvestFee()).to.be.equal(_harvestFeePercent);

        await stakingContract.setHarvestFee(harvestFeePercent);
      });
    });

    describe("- depositReward function: ", () => {
      it("rewardBalance is 0", async () => {
        await expect(
            stakingContract.connect(user1).stake(OneToken.mul(1000))
        ).to.be.revertedWith("rewardBalance is 0");
      });

      it("ERC20: insufficient allowance", async () => {
        await expect(
            stakingContract.depositReward(totalReward)
        ).to.be.revertedWith("ERC20: insufficient allowance");
      });

      it("depositReward success !!!", async () => {
        await stkToken.approve(stakingContract.address, totalReward);
        await stakingContract.depositReward(totalReward);

        await expect(await stakingContract.getRewardBalance()).to.be.equal(totalReward);
      });
    });
  });

  describe("4. Staking workflow test: ", () => {
    it("User1 deposit 1000 STK token", async () => {
      const amount = OneToken.mul(1000);
      await stkToken.connect(user1).approve(stakingContract.address, amount);
      await stakingContract.connect(user1).stake(amount);

      const userInfo = await stakingContract.userInfo(user1.address);
      expect(userInfo.amount).equal(amount);
    });

    it("User2 deposit 1500 STK token", async () => {
      const amount = OneToken.mul(1500);
      await stkToken.connect(user2).approve(stakingContract.address, amount);
      await stakingContract.connect(user2).stake(amount);

      const userInfo = await stakingContract.userInfo(user2.address);
      expect(userInfo.amount).equal(amount);

      const pendingRewardOfUser1 = await stakingContract.getPending(user1.address);
      const harvestFeeOfUser1 = rewardPerBlock.mul(2).mul(harvestFeePercent).div(1000)
      expect(pendingRewardOfUser1).to.be.equal(rewardPerBlock.mul(2).sub(harvestFeeOfUser1));

      const pendingRewardOfUser2 = await stakingContract.getPending(user2.address);
      expect(pendingRewardOfUser2).to.be.equal(OneToken.mul(0));
    });

    it("User3 deposit 2500 STK token", async () => {
      const amount = OneToken.mul(2500);
      await stkToken.connect(user3).approve(stakingContract.address, amount);
      await stakingContract.connect(user3).stake(amount);

      const userInfo = await stakingContract.userInfo(user3.address);
      expect(userInfo.amount).equal(amount);

      const pendingRewardOfUser1 = await stakingContract.getPending(user1.address);
      const rewardOfUser1 = rewardPerBlock.mul(2).add(rewardPerBlock.mul(2).mul(10).div(25));
      const harvestFeeOfUser1 = rewardOfUser1.mul(harvestFeePercent).div(1000)
      expect(pendingRewardOfUser1).to.be.equal(rewardOfUser1.sub(harvestFeeOfUser1));

      const pendingRewardOfUser2 = await stakingContract.getPending(user2.address);
      const rewardOfUser2 = rewardPerBlock.mul(2).mul(15).div(25);
      const harvestFeeOfUser2 = rewardOfUser2.mul(harvestFeePercent).div(1000)
      expect(pendingRewardOfUser2).to.be.equal(rewardOfUser2.sub(harvestFeeOfUser2));

      const pendingRewardOfUser3 = await stakingContract.getPending(user3.address);
      expect(pendingRewardOfUser3).to.be.equal(OneToken.mul(0));
    });

    it("unStake: amount invalid", async () => {
      await expect(
          stakingContract.connect(user1).unStake(OneToken.mul(10000))
      ).to.be.revertedWith("unStake: amount invalid");
    });

    it("User4 deposit 5000 STK token", async () => {
      const amount = OneToken.mul(5000);
      await stkToken.connect(user4).approve(stakingContract.address, amount);
      await stakingContract.connect(user4).stake(amount);

      const userInfo = await stakingContract.userInfo(user4.address);
      expect(userInfo.amount).equal(amount);

      const pendingRewardOfUser1 = await stakingContract.getPending(user1.address);
      const rewardOfUser1 = rewardPerBlock.mul(2)
          .add(rewardPerBlock.mul(2).mul(10).div(25))
          .add(rewardPerBlock.mul(2).mul(10).div(50));
      const harvestFeeOfUser1 = rewardOfUser1.mul(harvestFeePercent).div(1000)
      expect(pendingRewardOfUser1).to.be.equal(rewardOfUser1.sub(harvestFeeOfUser1));

      const pendingRewardOfUser2 = await stakingContract.getPending(user2.address);
      const rewardOfUser2 = rewardPerBlock.mul(2).mul(15).div(25)
          .add(rewardPerBlock.mul(2).mul(15).div(50));
      const harvestFeeOfUser2 = rewardOfUser2.mul(harvestFeePercent).div(1000)
      expect(pendingRewardOfUser2).to.be.equal(rewardOfUser2.sub(harvestFeeOfUser2));

      const pendingRewardOfUser3 = await stakingContract.getPending(user3.address);
      const rewardOfUser3 = rewardPerBlock.mul(2).mul(25).div(50);
      const harvestFeeOfUser3 = rewardOfUser3.mul(harvestFeePercent).div(1000)
      expect(pendingRewardOfUser3).to.be.equal(rewardOfUser3.sub(harvestFeeOfUser3));

      const pendingRewardOfUser4 = await stakingContract.getPending(user4.address);
      expect(pendingRewardOfUser4).to.be.equal(OneToken.mul(0));
    });

    it("unStake User4", async () => {
      const totalStakedAmount = await stakingContract.totalStakedAmount();
      await stakingContract.connect(user4).unStake(OneToken.mul(5000));
      const updatedTotalStakedAmount = await stakingContract.totalStakedAmount();
      expect(updatedTotalStakedAmount).to.be.equal(totalStakedAmount.sub(OneToken.mul(5000)));
    });

    it("harvest: False", async () => {
      const oldBalance = await stkToken.balanceOf(user3.address);
      const pendingReward = await stakingContract.getPending(user3.address);
      const reward = pendingReward.add(rewardPerBlock.mul(25).div(50).mul(1000 - harvestFeePercent).div(1000))
      await stakingContract.connect(user3).harvest(false);
      const balance = await stkToken.balanceOf(user3.address);
      expect(balance).to.be.equal(oldBalance.add(reward));

      const userInfo = await stakingContract.userInfo(user3.address);
      expect(userInfo.pendingAmount).to.be.equal(OneToken.mul(0));
    });

    it("harvest: True", async () => {
      const userInfo = await stakingContract.userInfo(user2.address);
      const oldAmount = userInfo.amount;
      const pendingReward = await stakingContract.getPending(user2.address);
      const reward = pendingReward.mul(1000).div(1000 - harvestFeePercent).add(rewardPerBlock.mul(15).div(50));
      await stakingContract.connect(user2).harvest(true);
      const newUserInfo = await stakingContract.userInfo(user2.address);
      const newAmount = newUserInfo.amount;
      expect(newAmount).to.be.equal(oldAmount.add(reward));
    });
  });
});
