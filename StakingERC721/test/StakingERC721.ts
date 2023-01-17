import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { BigNumber } from "ethers";
import {
  MockERC20,
  MockERC20__factory,
  MockERC721,
  MockERC721__factory,
  StakingERC721,
  StakingERC721__factory,
} from "../typechain-types";
import { now, restoreSnapshot, takeSnapshot } from "./utils/helpers";

describe("StakingERC721", function () {
  let accounts: SignerWithAddress[];
  let creator: SignerWithAddress,
    nftHolder: SignerWithAddress,
    nonNftHolder: SignerWithAddress,
    anotherNftHolder: SignerWithAddress;

  let lastSnapshotId: string;

  let stakingToken: MockERC721, rewardsToken: MockERC20, staking: StakingERC721;

  const REWARD_DURATION = 31556952; // 1 year in seconds
  const REWARD = ethers.utils.parseEther("1000000"); // 1000000 ERC20
  const REWARD_RATE = REWARD.div(REWARD_DURATION);

  async function doFund(amount: BigNumber) {
    await rewardsToken.connect(creator).mintTo(creator.address, amount);
    await rewardsToken.connect(creator).approve(staking.address, amount);

    return await staking.connect(creator).fund(amount);
  }

  before(async () => {
    const signers = await ethers.getSigners();
    [creator, nftHolder, nonNftHolder, anotherNftHolder] = signers;

    const MockERC20Factory = new MockERC20__factory(creator);
    rewardsToken = await MockERC20Factory.deploy("REWARDS", "REWARDS");

    const MockERC721Factory = new MockERC721__factory(creator);
    stakingToken = await MockERC721Factory.deploy("STAKING", "STAKING");

    const StakingERC721Factory = new StakingERC721__factory(creator);
    staking = await StakingERC721Factory.deploy(
      rewardsToken.address,
      stakingToken.address,
      REWARD_DURATION
    );
  });

  beforeEach(async function () {
    lastSnapshotId = await takeSnapshot();
  });

  afterEach(async function () {
    await restoreSnapshot(lastSnapshotId);
  });

  it("Should initialize properly with correct configuration", async () => {
    expect(await staking.rewardsToken()).to.equal(rewardsToken.address);
    expect(await staking.stakingToken()).to.equal(stakingToken.address);
    expect(await staking.rewardsDuration()).to.equal(REWARD_DURATION);
    expect(await staking.getRewardForDuration()).to.equal(0);
  });

  describe("Owner", () => {
    it("Should set creator to deployer", async () => {
      expect(await staking.owner()).to.equal(creator.address);
    });

    it("Should allow creator to pause", async () => {
      await expect(staking.setPaused(true))
        .to.emit(staking, "Paused")
        .withArgs(creator.address);
    });

    it("Should allow creator to unpause", async () => {
      await staking.setPaused(true);
      await expect(staking.setPaused(false))
        .to.emit(staking, "Unpaused")
        .withArgs(creator.address);
    });

    it("Should not allow nonOnwer to pause", async () => {
      const expectedRevertMessage = "Ownable: caller is not the owner";
      await expect(
        staking.connect(nftHolder).setPaused(true)
      ).to.be.revertedWith(expectedRevertMessage);
    });

    it("Should not allow nonOnwer to unpause", async () => {
      const expectedRevertMessage = "Ownable: caller is not the owner";
      await staking.setPaused(true);
      await expect(
        staking.connect(nftHolder).setPaused(false)
      ).to.be.revertedWith(expectedRevertMessage);
    });

    it("Should not allow nonOwner to change rewardsDuration", async () => {
      const expectedRevertMessage = "Ownable: caller is not the owner";
      await expect(
        staking.connect(nftHolder).setRewardsDuration(REWARD_DURATION)
      ).to.be.revertedWith(expectedRevertMessage);
    });

    it("Should not allow nonOwner to notifyRewardAmount", async () => {
      const expectedRevertMessage = "Ownable: caller is not the owner";
      await expect(staking.connect(nftHolder).fund(1)).to.be.revertedWith(
        expectedRevertMessage
      );
    });
  });

  it("Should update rewards duration accordingly", async () => {
    await staking.setRewardsDuration(REWARD_DURATION);
    expect(await staking.rewardsDuration()).to.equal(REWARD_DURATION);
  });

  it("Should emit event on update rewards duration", async () => {
    await expect(staking.setRewardsDuration(REWARD_DURATION))
      .to.emit(staking, "RewardsDurationUpdated")
      .withArgs(REWARD_DURATION);
  });

  it("Should not update rewards duration if previous reward period as not finished", async () => {
    await doFund(REWARD);
    await expect(
      staking.setRewardsDuration(REWARD_DURATION + 1)
    ).to.revertedWithCustomError(staking, "WaitToFinish");
  });

  it("Should notifyRewardsAmount accordingly when period finished", async () => {
    await staking.setRewardsDuration(10);
    await doFund(ethers.utils.parseEther("1"));
    const currentNow = await now();

    expect(await staking.rewardRate()).to.equal(
      ethers.utils.parseEther("1").div(10)
    );
    expect(await staking.lastUpdateTime()).to.equal(currentNow);
    expect(await staking.periodFinish()).to.equal(currentNow + 10);
    expect(await staking.getRewardForDuration()).to.equal(
      ethers.utils.parseEther("1")
    );
  });

  it("Should fund accordingly when period has not finished", async () => {
    const ONE_ERC20 = ethers.utils.parseEther("1");
    await staking.connect(creator).setRewardsDuration(10);
    await doFund(ONE_ERC20);
    const firstExpectedRewardRate = ONE_ERC20.div(10);
    expect(await staking.rewardRate()).to.equal(firstExpectedRewardRate);
    expect(await staking.getRewardForDuration()).to.equal(ONE_ERC20);

    await doFund(ONE_ERC20);
    const currentNow = await now();
    expect(await staking.rewardRate()).to.equal(
      firstExpectedRewardRate.mul(7).add(ONE_ERC20).div(10)
    );
    expect(await staking.lastUpdateTime()).to.equal(currentNow);
    expect(await staking.periodFinish()).to.equal(currentNow + 10);
  });

  describe("", () => {
    before(async () => {
      await staking.connect(creator).setRewardsDuration(REWARD_DURATION);
      await doFund(REWARD);
    });

    it("Should set reward rate properly", async () => {
      expect(await staking.rewardRate()).to.equal(REWARD_RATE);
    });

    it("Should set reward for duration properly", async () => {
      expect(await staking.getRewardForDuration()).to.equal(
        REWARD_RATE.mul(REWARD_DURATION)
      );
    });

    it("Should revert if reward is too high", async () => {
      await staking
        .connect(creator)
        .recoverERC20(rewardsToken.address, REWARD.div(100));

      await expect(doFund(REWARD)).to.be.revertedWithCustomError(
        staking,
        "TooHighReward"
      );
    });

    describe("Staking", () => {
      it("Should stake NFTs successfully", async () => {
        await stakingToken.connect(creator).mintBulkTo(nftHolder.address, 2);
        await stakingToken
          .connect(nftHolder)
          .setApprovalForAll(staking.address, true);

        await staking.connect(nftHolder).stake([1, 2]);

        const balanceOfContract = await stakingToken.balanceOf(staking.address);
        expect(balanceOfContract.toNumber()).to.equal(2);
        expect(await staking.totalSupply()).to.equal(2);
        expect(await staking.balances(nftHolder.address)).to.equal(2);
        expect(await staking.stakedAssets(1)).to.equal(nftHolder.address);
        expect(await staking.stakedAssets(2)).to.equal(nftHolder.address);
      });

      it("Should update fields correctly on second time staking", async () => {
        await stakingToken.mintBulkTo(nftHolder.address, 3);
        await stakingToken
          .connect(nftHolder)
          .setApprovalForAll(staking.address, true);
        await staking.connect(nftHolder).stake([1]);
        expect(
          (await stakingToken.balanceOf(staking.address)).toNumber()
        ).to.equal(1);

        await staking.connect(nftHolder).stake([2, 3]);
        const balanceOfContract = await stakingToken.balanceOf(staking.address);
        expect(balanceOfContract.toNumber()).to.equal(3);
        expect(await staking.totalSupply()).to.equal(3);
        expect(await staking.balances(nftHolder.address)).to.equal(3);
        expect(await staking.stakedAssets(1)).to.equal(nftHolder.address);
        expect(await staking.stakedAssets(2)).to.equal(nftHolder.address);
        expect(await staking.stakedAssets(3)).to.equal(nftHolder.address);
      });

      it("Should emit events correctly", async () => {
        await stakingToken.mintBulkTo(nftHolder.address, 2);
        await stakingToken
          .connect(nftHolder)
          .setApprovalForAll(staking.address, true);

        await expect(staking.connect(nftHolder).stake([1, 2]))
          .to.emit(stakingToken, "Transfer")
          .withArgs(nftHolder.address, staking.address, 1)
          .to.emit(stakingToken, "Transfer")
          .withArgs(nftHolder.address, staking.address, 2)
          .to.emit(staking, "Staked")
          .withArgs(nftHolder.address, 2, [1, 2]);
      });

      it("Should revert on staking non-existing tokens", async () => {
        const expectedRevertMessage = "ERC721: invalid token ID";
        await stakingToken
          .connect(nftHolder)
          .setApprovalForAll(staking.address, true);
        await expect(
          staking.connect(nftHolder).stake([100])
        ).to.be.revertedWith(expectedRevertMessage);
      });

      it("Should revert on staking non-owned tokens", async () => {
        const expectedRevertMessage =
          "ERC721: caller is not token owner or approved";
        await stakingToken.mintBulkTo(creator.address, 1);
        await stakingToken
          .connect(nonNftHolder)
          .setApprovalForAll(staking.address, true);
        await expect(
          staking.connect(nonNftHolder).stake([1])
        ).to.be.revertedWith(expectedRevertMessage);
      });

      it("Should not allow staking of no tokens", async () => {
        await expect(
          staking.connect(nftHolder).stake([])
        ).to.be.revertedWithCustomError(staking, "NoTokenIds");
      });

      it("Should not allow staking when paused", async () => {
        const expectedRevertMessage = "Pausable: paused";
        await staking.setPaused(true);

        await expect(staking.connect(nftHolder).stake([1])).to.be.revertedWith(
          expectedRevertMessage
        );
      });
    });

    describe("Unstake", async () => {
      beforeEach(async () => {
        await stakingToken.mintBulkTo(nftHolder.address, 2);
        await stakingToken
          .connect(nftHolder)
          .setApprovalForAll(staking.address, true);
        await staking.connect(nftHolder).stake([1, 2]);
      });

      it("Should unstake staked NFTs successfully", async () => {
        const balanceOfContractBefore = await stakingToken.balanceOf(
          staking.address
        );
        expect(balanceOfContractBefore.toNumber()).to.equal(2);
        expect(await staking.totalSupply()).to.equal(2);
        expect(await staking.balances(nftHolder.address)).to.equal(2);
        expect(await staking.stakedAssets(1)).to.equal(nftHolder.address);
        expect(await staking.stakedAssets(2)).to.equal(nftHolder.address);

        await staking.connect(nftHolder).unstake([1, 2]);
        const balanceOfContractAfter = await stakingToken.balanceOf(
          staking.address
        );
        expect(balanceOfContractAfter.toNumber()).to.equal(0);

        const balanceOfStaker = await stakingToken.balanceOf(nftHolder.address);
        expect(balanceOfStaker.toNumber()).to.equal(2);
        expect(await stakingToken.ownerOf(1)).to.equal(nftHolder.address);
        expect(await stakingToken.ownerOf(2)).to.equal(nftHolder.address);
        expect(await staking.totalSupply()).to.equal(0);
        expect(await staking.balances(nftHolder.address)).to.equal(0);
        expect(await staking.stakedAssets(1)).to.equal(
          ethers.constants.AddressZero
        );
        expect(await staking.stakedAssets(2)).to.equal(
          ethers.constants.AddressZero
        );
      });

      it("Should unstake when paused", async () => {
        await staking.setPaused(true);
        await expect(staking.connect(nftHolder).unstake([1, 2])).to.be.reverted;
      });

      it("Should use the same amount even if estate size changes", async () => {
        await staking.connect(nftHolder).unstake([2]);

        const balanceOfContractAfter = await stakingToken.balanceOf(
          staking.address
        );
        expect(balanceOfContractAfter.toNumber()).to.equal(1);

        const balanceOfStaker = await stakingToken.balanceOf(nftHolder.address);
        expect(balanceOfStaker.toNumber()).to.equal(1);
        expect(await stakingToken.ownerOf(1)).to.equal(staking.address);
        expect(await stakingToken.ownerOf(2)).to.equal(nftHolder.address);
        expect(await staking.totalSupply()).to.equal(1);
        expect(await staking.balances(nftHolder.address)).to.equal(1);
        expect(await staking.stakedAssets(1)).to.equal(nftHolder.address);
        expect(await staking.stakedAssets(2)).to.equal(
          ethers.constants.AddressZero
        );
      });

      it("Should emit events correctly on Unstake", async () => {
        await expect(staking.connect(nftHolder).unstake([1, 2]))
          .to.emit(stakingToken, "Transfer")
          .withArgs(staking.address, nftHolder.address, 1)
          .to.emit(stakingToken, "Transfer")
          .withArgs(staking.address, nftHolder.address, 2)
          .to.emit(staking, "Unstaked")
          .withArgs(nftHolder.address, 2, [1, 2]);
      });

      it("Should not be able to unstake NFTs staked by other person", async () => {
        await expect(
          staking.connect(nonNftHolder).unstake([1, 2])
        ).revertedWithCustomError(staking, "NotTokenOwner");
      });

      it("Should not allow staking of no tokens", async () => {
        await expect(
          staking.connect(nftHolder).unstake([])
        ).to.be.revertedWithCustomError(staking, "NoTokenIds");
      });
    });

    describe("Rewards", async () => {
      before(async () => {
        await stakingToken.mintBulkTo(nftHolder.address, 10);
        await stakingToken.mintBulkTo(anotherNftHolder.address, 10);
        await stakingToken
          .connect(nftHolder)
          .setApprovalForAll(staking.address, true);
        await stakingToken
          .connect(anotherNftHolder)
          .setApprovalForAll(staking.address, true);
      });

      it("Should not emit and send if no rewards have been accrued", async () => {
        await expect(staking.connect(nftHolder).claim())
          .to.not.emit(rewardsToken, "Transfer")
          .to.not.emit(staking, "Claimed");
      });

      it("Should accrue correct amount for one holder per second", async () => {
        await staking.connect(nftHolder).stake([1]);
        const earnedBefore = await staking.earned(nftHolder.address);
        await ethers.provider.send("evm_mine", []);

        const earnedAfter = await staking.earned(nftHolder.address);
        expect(earnedBefore.add(REWARD_RATE)).to.equal(earnedAfter);

        // Accrues 100 more as reward
        await staking.connect(nftHolder).claim();
        expect(await rewardsToken.balanceOf(nftHolder.address)).to.equal(
          REWARD_RATE.mul(2)
        );
        expect(await rewardsToken.balanceOf(staking.address)).to.equal(
          REWARD.sub(REWARD_RATE.mul(2))
        );
      });

      it("Should accrue correct amount for balance > 1 per second", async () => {
        await staking.connect(nftHolder).stake([1, 2, 3, 4, 5, 6, 7, 8, 9]);
        const earnedBefore = await staking.earned(nftHolder.address);
        await ethers.provider.send("evm_mine", []);

        const earnedAfter = await staking.earned(nftHolder.address);
        expect(earnedBefore.add(REWARD_RATE)).to.equal(earnedAfter);

        await staking.connect(nftHolder).claim();
        expect(await rewardsToken.balanceOf(nftHolder.address)).to.equal(
          REWARD_RATE.mul(2)
        );
        expect(await rewardsToken.balanceOf(staking.address)).to.equal(
          REWARD.sub(REWARD_RATE.mul(2))
        );
      });

      it("Should accrue correct amount for multiple users per second", async () => {
        await staking.connect(nftHolder).stake([1]);
        const holder1EarnedT0 = await staking.earned(nftHolder.address);

        // 1 second elapses; nftHolder=100; anotherNftHolder=0
        await staking.connect(anotherNftHolder).stake([11]);
        const holder1EarnedT1 = await staking.earned(nftHolder.address);
        const holder2EarnedT0 = await staking.earned(anotherNftHolder.address);

        // 2 seconds elapse; nftHolder=150; anotherNftHolder=50
        await ethers.provider.send("evm_mine", []);
        const holder1EarnedT2 = await staking.earned(nftHolder.address);
        const holder2EarnedT1 = await staking.earned(anotherNftHolder.address);

        // 3 seconds elapse; nftHolder=0; anotherNftHolder=100
        await staking.connect(nftHolder).claim();
        const holder1EarnedT3 = await staking.earned(nftHolder.address);
        const holder2EarnedT2 = await staking.earned(anotherNftHolder.address);

        // 4 seconds elapse; nftHolder=50; anotherNftHolder=150
        await staking.connect(anotherNftHolder).claim();
        const holder2EarnedT3 = await staking.earned(anotherNftHolder.address);

        // nftHolder balances
        expect(holder1EarnedT0).to.equal(0);
        expect(holder1EarnedT1).to.equal(REWARD_RATE);
        expect(holder1EarnedT2).to.equal(REWARD_RATE.mul(3).div(2));
        expect(holder1EarnedT3).to.equal(0);
        expect(await rewardsToken.balanceOf(nftHolder.address)).to.equal(
          REWARD_RATE.mul(2)
        );

        // anotherNftHolder balances
        expect(holder2EarnedT0).to.equal(0);
        expect(holder2EarnedT1).to.equal(REWARD_RATE.div(2));
        expect(holder2EarnedT2).to.equal(REWARD_RATE);
        expect(holder2EarnedT3).to.equal(0);
        expect(await rewardsToken.balanceOf(anotherNftHolder.address)).to.equal(
          REWARD_RATE.mul(3).div(2)
        );

        // Staking contract balance
        expect(await rewardsToken.balanceOf(staking.address)).to.equal(
          REWARD.sub(REWARD_RATE.mul(7).div(2))
        );
      });

      it("Should accrue correct amount for multiple users proportionally to their balance per second", async () => {
        // Balance for nftHolder is 1
        await staking.connect(nftHolder).stake([1]);
        const holder1EarnedT0 = await staking.earned(nftHolder.address);

        // Balance for anotherNftHolder is 4
        // 1 second elapses
        await staking.connect(anotherNftHolder).stake([11, 13, 15, 17]);
        const holder1EarnedT1 = await staking.earned(nftHolder.address);
        const holder2EarnedT0 = await staking.earned(anotherNftHolder.address);

        // 2 second elapse
        await ethers.provider.send("evm_mine", []);

        const holder1EarnedT2 = await staking.earned(nftHolder.address);
        const holder2EarnedT1 = await staking.earned(anotherNftHolder.address);

        // nftHolder accrues 20% of REWARDS_RATE/sec
        // anotherNftHolder accrues 80% of REWARDS_RATE/sec
        await staking.connect(nftHolder).claim();
        const holder1EarnedT3 = await staking.earned(nftHolder.address);
        const holder2EarnedT2 = await staking.earned(anotherNftHolder.address);

        await staking.connect(anotherNftHolder).claim();
        const holder1EarnedT4 = await staking.earned(nftHolder.address);
        const holder2EarnedT3 = await staking.earned(anotherNftHolder.address);

        expect(holder1EarnedT0).to.equal(0);
        expect(holder1EarnedT1).to.equal(REWARD_RATE);
        expect(holder1EarnedT2).to.equal(REWARD_RATE.add(REWARD_RATE.div(5)));
        expect(holder1EarnedT3).to.equal(0);
        expect(holder1EarnedT4).to.equal(REWARD_RATE.div(5));
        expect(await rewardsToken.balanceOf(nftHolder.address)).to.equal(
          REWARD_RATE.mul(7).div(5)
        );

        expect(holder2EarnedT0).to.equal(0);
        expect(holder2EarnedT1).to.equal(REWARD_RATE.mul(4).div(5));
        expect(holder2EarnedT2).to.equal(REWARD_RATE.mul(8).div(5));
        expect(holder2EarnedT3).to.equal(0);
        expect(await rewardsToken.balanceOf(anotherNftHolder.address)).to.equal(
          REWARD_RATE.mul(12).div(5)
        );

        // Staking contract balance
        expect(await rewardsToken.balanceOf(staking.address)).to.equal(
          REWARD.sub(REWARD_RATE.mul(19).div(5))
        );
      });

      it("Should emit correct events on Claim", async () => {
        await staking.connect(nftHolder).stake([1]);

        await expect(staking.connect(nftHolder).claim())
          .to.emit(rewardsToken, "Transfer")
          .withArgs(staking.address, nftHolder.address, REWARD_RATE)
          .to.emit(staking, "Claimed")
          .withArgs(nftHolder.address, REWARD_RATE);
      });
    });

    it("Should be able to exit", async () => {
      await stakingToken.mintBulkTo(nftHolder.address, 2);
      await stakingToken
        .connect(nftHolder)
        .setApprovalForAll(staking.address, true);
      await staking.connect(nftHolder).stake([1, 2]);

      await staking.connect(nftHolder).exit([1, 2]);
      const balanceOfContractAfter = await stakingToken.balanceOf(
        staking.address
      );
      expect(balanceOfContractAfter.toNumber()).to.equal(0);

      const balanceOfStaker = await stakingToken.balanceOf(nftHolder.address);
      expect(balanceOfStaker.toNumber()).to.equal(2);
      expect(await stakingToken.ownerOf(1)).to.equal(nftHolder.address);
      expect(await stakingToken.ownerOf(2)).to.equal(nftHolder.address);
      expect(await staking.totalSupply()).to.equal(0);
      expect(await staking.balances(nftHolder.address)).to.equal(0);
      expect(await staking.stakedAssets(1)).to.equal(
        ethers.constants.AddressZero
      );
      expect(await staking.stakedAssets(2)).to.equal(
        ethers.constants.AddressZero
      );

      expect(await rewardsToken.balanceOf(staking.address)).to.equal(
        REWARD.sub(REWARD_RATE)
      );
      expect(await rewardsToken.balanceOf(nftHolder.address)).to.equal(
        REWARD_RATE
      );
    });

    it("Should emit correct events when exit", async () => {
      await stakingToken.mintBulkTo(nftHolder.address, 2);
      await stakingToken
        .connect(nftHolder)
        .setApprovalForAll(staking.address, true);
      await staking.connect(nftHolder).stake([1, 2]);

      await expect(staking.connect(nftHolder).exit([1, 2]))
        .to.emit(stakingToken, "Transfer")
        .withArgs(staking.address, nftHolder.address, 1)
        .to.emit(stakingToken, "Transfer")
        .withArgs(staking.address, nftHolder.address, 2)
        .to.emit(staking, "Unstaked")
        .withArgs(nftHolder.address, 2, [1, 2])
        .to.emit(rewardsToken, "Transfer")
        .withArgs(staking.address, nftHolder.address, REWARD_RATE)
        .to.emit(staking, "Claimed")
        .withArgs(nftHolder.address, REWARD_RATE);
    });
  });
});
