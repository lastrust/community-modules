import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import {
  MockERC20,
  MockERC20__factory,
  StakingRewards,
  StakingRewards__factory,
} from "../typechain-types";
import {
  increaseTime,
  now,
  restoreSnapshot,
  takeSnapshot,
} from "./utils/helpers";

describe("StakingRewards", function () {
  let accounts: SignerWithAddress[];
  let creator: SignerWithAddress,
    userA: SignerWithAddress,
    stakerA: SignerWithAddress;

  let lastSnapshotId: string;

  let rewardsToken: MockERC20,
    externalRewardsToken: MockERC20,
    stakingToken: MockERC20,
    stakingRewards: StakingRewards;

  const DAY = ethers.BigNumber.from(86400);
  const WEEK = DAY.mul(7);
  const ZERO_BN = ethers.BigNumber.from(0);

  async function doStake(staker: SignerWithAddress, amount: string) {
    await stakingToken.connect(creator).mintTo(staker.address, amount);
    await stakingToken.connect(staker).approve(stakingRewards.address, amount);

    return await stakingRewards.connect(staker).stake(amount);
  }

  async function doFund(amount: string) {
    await rewardsToken.connect(creator).mintTo(creator.address, amount);
    await rewardsToken.connect(creator).approve(stakingRewards.address, amount);

    return await stakingRewards.connect(creator).fund(amount);
  }

  before(async () => {
    accounts = await ethers.getSigners();
    creator = accounts[0];
    userA = accounts[1];
    stakerA = accounts[2];

    const tokenFactory = new MockERC20__factory(creator);
    rewardsToken = await tokenFactory.deploy("REWARDS", "REWARDS");
    externalRewardsToken = await tokenFactory.deploy(
      "EXTREWARDS",
      "EXTREWARDS"
    );
    stakingToken = await tokenFactory.deploy("STAKING", "STAKING");

    const stakingRewardsFactory = new StakingRewards__factory(creator);

    stakingRewards = await stakingRewardsFactory.deploy(
      rewardsToken.address,
      stakingToken.address,
      WEEK
    );
  });

  beforeEach(async () => {
    lastSnapshotId = await takeSnapshot();
  });

  afterEach(async () => {
    await restoreSnapshot(lastSnapshotId);
  });

  describe("constructor & setting", () => {
    it("should set rewards token on constructor", async () => {
      expect(await stakingRewards.rewardsToken()).to.be.equal(
        rewardsToken.address
      );
    });

    it("should staking token on constructor", async () => {
      expect(await stakingRewards.stakingToken()).to.be.equal(
        stakingToken.address
      );
    });

    it("should have rewards duration on constructor", async () => {
      expect(await stakingRewards.rewardsDuration()).to.be.equal(WEEK);
    });
  });

  describe("function permissions", () => {
    const rewardValue = ethers.utils.parseEther("1.0");

    before(async () => {
      await rewardsToken.mintTo(creator.address, rewardValue);
      await rewardsToken
        .connect(creator)
        .approve(stakingRewards.address, rewardValue);
    });

    it("only owner can fund", async () => {
      await expect(
        stakingRewards.connect(userA).fund(rewardValue)
      ).to.be.revertedWith("Ownable: caller is not the owner");

      await expect(stakingRewards.connect(creator).fund(rewardValue)).to.be.not
        .reverted;
    });

    it("only owner can call setRewardsDuration", async () => {
      await increaseTime(WEEK.toNumber());
      await expect(stakingRewards.connect(creator).setRewardsDuration(WEEK)).to
        .be.not.reverted;
    });

    it("only owner can call setPaused", async () => {
      await expect(stakingRewards.connect(creator).setPaused(true)).to.be.not
        .reverted;
    });
  });

  describe("pausable", () => {
    beforeEach(async () => {
      const paused = await stakingRewards.paused();
      if (paused) {
        await stakingRewards.connect(creator).setPaused(false);
      }
    });

    it("should revert calling stake() when paused", async () => {
      await stakingRewards.connect(creator).setPaused(true);

      const stakeValue = ethers.utils.parseEther("100.0");
      await expect(doStake(stakerA, stakeValue.toString())).to.be.revertedWith(
        "Pausable: paused"
      );
    });

    it("should not revert calling stake() when unpaused", async () => {
      const stakeValue = ethers.utils.parseEther("100.0");
      await stakingToken.connect(creator).mintTo(stakerA.address, stakeValue);
      await stakingToken
        .connect(stakerA)
        .approve(stakingRewards.address, stakeValue);

      await expect(stakingRewards.connect(stakerA).stake(stakeValue)).to.be.not
        .reverted;
    });
  });

  describe("external rewards recovery", () => {
    const amount = ethers.utils.parseEther("500.0");

    before(async () => {
      await externalRewardsToken
        .connect(creator)
        .mintTo(creator.address, amount);
      await externalRewardsToken
        .connect(creator)
        .transfer(stakingRewards.address, amount);
    });

    it("only owner can call recoverERC20", async () => {
      await expect(
        stakingRewards
          .connect(userA)
          .recoverERC20(externalRewardsToken.address, amount)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("should revert if recovering staking token", async () => {
      await expect(
        stakingRewards
          .connect(creator)
          .recoverERC20(stakingToken.address, amount)
      ).to.be.revertedWithCustomError(
        stakingRewards,
        "FailedToWithdrawStaking"
      );
    });

    it("should recover external token from staking rewards", async () => {
      const balanceBefore = await externalRewardsToken.balanceOf(
        creator.address
      );

      await stakingRewards
        .connect(creator)
        .recoverERC20(externalRewardsToken.address, amount);
      expect(
        await externalRewardsToken.balanceOf(stakingRewards.address)
      ).to.be.equal(ZERO_BN);

      const balanceAfter = await externalRewardsToken.balanceOf(
        creator.address
      );
      expect(balanceAfter.sub(balanceBefore)).to.be.equal(amount);
    });
  });

  describe("lastTimeRewardApplicable()", () => {
    it("should return period finish", async () => {
      const periodFinish = await stakingRewards.periodFinish();
      expect(await stakingRewards.lastTimeRewardApplicable()).to.be.equal(
        periodFinish
      );
    });

    describe("when updated", async () => {
      const rewardValue = ethers.utils.parseEther("1.0");

      it("should equal current timestamp", async () => {
        await doFund(rewardValue.toString());

        const currentTime = await now();
        const lastTimeRewardApplicable =
          await stakingRewards.lastTimeRewardApplicable();
        expect(lastTimeRewardApplicable).to.be.equal(currentTime);
      });
    });
  });

  describe("rewardPerToken()", () => {
    it("should return 0", async () => {
      expect(await stakingRewards.rewardPerToken()).to.be.equal(ZERO_BN);
    });

    it("should be > 0 when staking", async () => {
      const stakeValue = ethers.utils.parseEther("100.0");
      await doStake(stakerA, stakeValue.toString());

      const rewardValue = ethers.utils.parseEther("5000.0");
      await doFund(rewardValue.toString());

      await increaseTime(DAY.toNumber());

      const rewardPerToken = await stakingRewards.rewardPerToken();
      expect(rewardPerToken).to.be.gt(ZERO_BN);
    });
  });

  describe("stake()", () => {
    it("cannot stake 0", async () => {
      await expect(
        stakingRewards.connect(stakerA).stake("0")
      ).to.be.revertedWithCustomError(stakingRewards, "ZeroAmount");
    });
  });

  describe("earned()", async () => {
    it("should be 0 when not staking", async () => {
      expect(await stakingRewards.earned(stakerA.address)).to.be.equal(ZERO_BN);
    });

    it("should be greater than 0 when staking", async () => {
      const stakeValue = ethers.utils.parseEther("100.0");
      await doStake(stakerA, stakeValue.toString());

      const rewardValue = ethers.utils.parseEther("5000.0");
      await doFund(rewardValue.toString());

      await increaseTime(DAY.toNumber());

      const earned = await stakingRewards.earned(stakerA.address);
      expect(earned).to.be.gt(ZERO_BN);
    });

    it("rewardRate should increase if new rewards come before DURATION ends", async () => {
      const rewardValue = ethers.utils.parseEther("5000.0");
      await doFund(rewardValue.toString());
      const rewardRateInitial = await stakingRewards.rewardRate();

      await doFund(rewardValue.toString());
      const rewardRateNew = await stakingRewards.rewardRate();

      expect(rewardRateNew).to.be.gt(rewardRateInitial);
    });

    it("rewards token balance should roll over after DURATION", async () => {
      const stakeValue = ethers.utils.parseEther("100.0");
      await doStake(stakerA, stakeValue.toString());

      const rewardValue = ethers.utils.parseEther("5000.0");
      await doFund(rewardValue.toString());

      await increaseTime(DAY.mul(7).toNumber());
      const earnedFirst = await stakingRewards.earned(stakerA.address);

      await doFund(rewardValue.toString());

      await increaseTime(DAY.mul(7).toNumber());
      const earnedSecond = await stakingRewards.earned(stakerA.address);

      expect(earnedSecond).to.be.equal(earnedFirst.mul(2));
    });
  });

  describe("claim()", () => {
    it("should increase rewards token balance", async () => {
      const stakeValue = ethers.utils.parseEther("100.0");
      await doStake(stakerA, stakeValue.toString());

      const rewardValue = ethers.utils.parseEther("5000.0");
      await doFund(rewardValue.toString());

      await increaseTime(DAY.toNumber());

      const initialRewardBalance = await rewardsToken.balanceOf(
        stakerA.address
      );
      const initialEarnedBalance = await stakingRewards.earned(stakerA.address);
      await stakingRewards.connect(stakerA).claim();
      const afterRewardBalance = await rewardsToken.balanceOf(stakerA.address);
      const afterEarnedBalance = await stakingRewards.earned(stakerA.address);

      expect(afterRewardBalance).to.be.gt(initialRewardBalance);
      expect(initialEarnedBalance).to.be.gt(afterEarnedBalance);
    });
  });

  describe("setRewardsDuration()", () => {
    const seventyDays = DAY.mul(70);

    it("should increase rewards duration before starting distribution", async () => {
      const defaultDuration = await stakingRewards.rewardsDuration();
      expect(defaultDuration).to.be.equal(WEEK);

      await stakingRewards.connect(creator).setRewardsDuration(seventyDays);
      const newDuration = await stakingRewards.rewardsDuration();
      expect(newDuration).to.be.equal(seventyDays);
    });

    it("should revert when setting setRewardsDuration before period has finished", async () => {
      const stakeValue = ethers.utils.parseEther("100.0");
      await doStake(stakerA, stakeValue.toString());

      const rewardValue = ethers.utils.parseEther("5000.0");
      await doFund(rewardValue.toString());

      await increaseTime(DAY.toNumber());
      await expect(
        stakingRewards.connect(creator).setRewardsDuration(seventyDays)
      ).to.be.revertedWithCustomError(stakingRewards, "WaitToFinish");
    });

    it("should update setRewardsDuration after the period has finished", async () => {
      const stakeValue = ethers.utils.parseEther("100.0");
      await doStake(stakerA, stakeValue.toString());

      const rewardValue = ethers.utils.parseEther("5000.0");
      await doFund(rewardValue.toString());

      await increaseTime(DAY.mul(4).toNumber());
      await stakingRewards.connect(stakerA).claim();
      await increaseTime(DAY.mul(4).toNumber());

      await expect(
        stakingRewards.connect(creator).setRewardsDuration(seventyDays)
      ).to.be.not.reverted;

      await doFund(rewardValue.toString());

      await increaseTime(DAY.mul(71).toNumber());
      await stakingRewards.connect(stakerA).claim();
    });
  });

  describe("unstake()", () => {
    it("cannot unstake if nothing staked", async () => {
      const stakeValue = ethers.utils.parseEther("100.0");
      await expect(
        stakingRewards.connect(userA).unstake(stakeValue)
      ).to.be.revertedWithCustomError(stakingRewards, "NotEnoughBalance");
    });

    it("should increase/decrease staking balance", async () => {
      const stakeValue = ethers.utils.parseEther("100.0");
      await doStake(stakerA, stakeValue.toString());

      const initialStakingBalance = await stakingRewards.balanceOf(
        stakerA.address
      );
      const initialStakingTokenBalance = await stakingToken.balanceOf(
        stakerA.address
      );
      await stakingRewards.connect(stakerA).unstake(stakeValue);
      const afterStakingBalance = await stakingRewards.balanceOf(
        stakerA.address
      );
      const afterStakingTokenBalance = await stakingToken.balanceOf(
        stakerA.address
      );

      expect(initialStakingBalance.sub(afterStakingBalance)).to.be.equal(
        stakeValue
      );
      expect(
        afterStakingTokenBalance.sub(initialStakingTokenBalance)
      ).to.be.equal(stakeValue);
    });

    it("cannot unstake 0", async () => {
      await expect(
        stakingRewards.connect(userA).unstake("0")
      ).to.be.revertedWithCustomError(stakingRewards, "ZeroAmount");
    });
  });

  describe("exit()", () => {
    it("should retrive all earned and staked", async () => {
      const stakeValue = ethers.utils.parseEther("100.0");
      await doStake(stakerA, stakeValue.toString());

      const rewardValue = ethers.utils.parseEther("5000.0");
      await doFund(rewardValue.toString());

      await increaseTime(DAY.toNumber());

      const initialStakingBalance = await stakingRewards.balanceOf(
        stakerA.address
      );
      const initialStakingTokenBalance = await stakingToken.balanceOf(
        stakerA.address
      );
      const initialRewardBalance = await rewardsToken.balanceOf(
        stakerA.address
      );
      await stakingRewards.connect(stakerA).exit();
      const afterStakingBalance = await stakingRewards.balanceOf(
        stakerA.address
      );
      const afterStakingTokenBalance = await stakingToken.balanceOf(
        stakerA.address
      );
      const afterRewardBalance = await rewardsToken.balanceOf(stakerA.address);

      expect(await stakingToken.balanceOf(stakingRewards.address)).to.be.equal(
        ZERO_BN
      );
      expect(initialStakingBalance.sub(afterStakingBalance)).to.be.equal(
        stakeValue
      );
      expect(
        afterStakingTokenBalance.sub(initialStakingTokenBalance)
      ).to.be.equal(stakeValue);
      expect(afterRewardBalance).to.be.gt(initialRewardBalance);
    });
  });

  describe("fund()", () => {
    it("should revert if provided reward is greater than the balance", async () => {
      const rewardValue = ethers.utils.parseEther("5000.0");
      await doFund(rewardValue.toString());

      await stakingRewards
        .connect(creator)
        .recoverERC20(rewardsToken.address, rewardValue.div(100));

      await expect(
        doFund(rewardValue.toString())
      ).to.be.revertedWithCustomError(stakingRewards, "TooHighReward");
    });
  });
});
