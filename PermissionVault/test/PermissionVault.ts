import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import {
  MockERC1155,
  MockERC1155__factory,
  MockERC20,
  MockERC20__factory,
  MockERC721,
  MockERC721__factory,
  PermissionVault,
} from "../typechain-types";
import { restoreSnapshot, takeSnapshot } from "./utils/helpers";

describe("PermissionVault", function () {
  let accounts: SignerWithAddress[];
  let owner: SignerWithAddress,
    controller: SignerWithAddress,
    user1: SignerWithAddress,
    user2: SignerWithAddress;

  let mockERC20: MockERC20, mockERC721: MockERC721, mockERC1155: MockERC1155;
  let permissionVault: PermissionVault;

  let snapshot: string;

  before(async () => {
    [owner, controller, user1, user2] = await ethers.getSigners();

    const MockERC20Factory = new MockERC20__factory(owner);
    mockERC20 = await MockERC20Factory.deploy("Test", "Test");

    const MockERC721Factory = new MockERC721__factory(owner);
    mockERC721 = await MockERC721Factory.deploy("Test", "Test");

    const MockERC1155Factory = new MockERC1155__factory(owner);
    mockERC1155 = await MockERC1155Factory.deploy("uri");

    const PermissionVaultFactory = await ethers.getContractFactory(
      "PermissionVault"
    );
    permissionVault = await PermissionVaultFactory.deploy();

    await mockERC20.mintTo(user1.address, ethers.utils.parseEther("10000"));
    await mockERC721.mintBulkTo(user1.address, 1000);
    await mockERC1155.mintTo(user1.address, 1, 1000);
    await mockERC1155.mintTo(user1.address, 2, 1000);

    return {
      owner,
      user1,
      user2,
      mockERC20,
      mockERC721,
      mockERC1155,
      permissionVault,
    };
  });

  beforeEach(async () => {
    snapshot = await takeSnapshot();
  });

  afterEach(async () => {
    await restoreSnapshot(snapshot);
  });

  describe("Setup", () => {
    it("Should initialize properly with correct configuration", async () => {
      expect(await mockERC20.name()).to.equal("Test");
      expect(await mockERC20.symbol()).to.equal("Test");
      expect(await mockERC721.name()).to.equal("Test");
      expect(await mockERC721.symbol()).to.equal("Test");
      expect(await mockERC20.balanceOf(user1.address)).to.be.equal(
        ethers.utils.parseEther("10000")
      );
      expect(await mockERC721.balanceOf(user1.address)).to.be.equal(1000);
      expect(await mockERC1155.balanceOf(user1.address, 1)).to.be.equal(1000);
      expect(await mockERC20.balanceOf(permissionVault.address)).to.be.equal(0);
      expect(await mockERC721.balanceOf(permissionVault.address)).to.be.equal(
        0
      );
      expect(
        await mockERC1155.balanceOf(permissionVault.address, 1)
      ).to.be.equal(0);
    });
  });

  describe("Controller", () => {
    it("should set the owner as the default admin and controller", async () => {
      const defaultAdminRole = await permissionVault.DEFAULT_ADMIN_ROLE();
      const controllerRole = await permissionVault.CONTROLLER_ROLE();
      expect(await permissionVault.hasRole(defaultAdminRole, owner.address)).to
        .be.true;
      expect(await permissionVault.hasRole(controllerRole, owner.address)).to.be
        .true;
    });

    it("should add a new controller", async () => {
      expect(
        await permissionVault.hasRole(
          permissionVault.CONTROLLER_ROLE(),
          controller.address
        )
      ).to.be.false;

      await expect(
        permissionVault.connect(owner).addController(controller.address)
      )
        .to.emit(permissionVault, "AddController")
        .withArgs(controller.address);

      expect(
        await permissionVault.hasRole(
          permissionVault.CONTROLLER_ROLE(),
          controller.address
        )
      ).to.be.true;
    });

    it("should remove a controller", async () => {
      await permissionVault.connect(owner).addController(controller.address);
      expect(
        await permissionVault.hasRole(
          permissionVault.CONTROLLER_ROLE(),
          controller.address
        )
      ).to.be.true;

      await expect(
        permissionVault.connect(owner).removeController(controller.address)
      )
        .to.emit(permissionVault, "RemoveController")
        .withArgs(controller.address);

      expect(
        await permissionVault.hasRole(
          permissionVault.CONTROLLER_ROLE(),
          controller.address
        )
      ).to.be.false;
    });
  });

  describe("Ether", () => {
    beforeEach(async () => {
      await permissionVault.connect(owner).addController(controller.address);
    });

    it("should deposit ether", async () => {
      const depositAmount = ethers.utils.parseEther("1");

      await expect(
        permissionVault.connect(user1).depositEther({ value: depositAmount })
      )
        .to.changeEtherBalance(permissionVault, depositAmount)
        .emit(permissionVault, "DepositEther")
        .withArgs(user1.address, depositAmount);

      expect(
        await ethers.provider.getBalance(permissionVault.address)
      ).to.equal(depositAmount);
    });

    it("should withdraw ether", async () => {
      const withdrawAmount = ethers.utils.parseEther("1");
      await permissionVault
        .connect(user1)
        .depositEther({ value: withdrawAmount });

      const balanceBefore = await ethers.provider.getBalance(
        permissionVault.address
      );

      await expect(
        permissionVault
          .connect(controller)
          .withdrawEther(user2.address, withdrawAmount)
      )
        .to.emit(permissionVault, "WithdrawEther")
        .withArgs(controller.address, user2.address, withdrawAmount);

      expect(
        await ethers.provider.getBalance(permissionVault.address)
      ).to.equal(balanceBefore.sub(withdrawAmount));
    });

    it("should not withdraw ether if the amount is greater than the balance", async function () {
      const withdrawAmount = ethers.utils.parseEther("1");

      await expect(
        permissionVault
          .connect(controller)
          .withdrawEther(user2.address, withdrawAmount)
      ).to.be.revertedWithCustomError(permissionVault, "NotEnoughBalance");
    });
  });

  describe("ERC20", () => {
    beforeEach(async () => {
      await permissionVault.connect(owner).addController(controller.address);
    });

    it("should revert when deposit amount is zero", async () => {
      await expect(
        permissionVault.depositERC20(mockERC20.address, 0)
      ).to.be.revertedWithCustomError(permissionVault, "ZeroAmount");
    });

    it("should deposit ERC20 tokens", async () => {
      const amount = ethers.utils.parseEther("500");

      const balanceBefore = await mockERC20.balanceOf(user1.address);

      await mockERC20.connect(user1).approve(permissionVault.address, amount);
      await expect(
        permissionVault.connect(user1).depositERC20(mockERC20.address, amount)
      )
        .to.emit(permissionVault, "DepositERC20")
        .withArgs(user1.address, mockERC20.address, amount);

      const balanceAfter = await mockERC20.balanceOf(user1.address);

      expect(balanceBefore.sub(balanceAfter)).to.be.equal(amount);
    });

    it("should revert when vault has insufficient balance", async () => {
      const amount = ethers.utils.parseEther("500");

      await expect(
        permissionVault
          .connect(controller)
          .withdrawERC20(user2.address, mockERC20.address, amount)
      ).to.be.revertedWithCustomError(permissionVault, "NotEnoughBalance");
    });

    it("should withdraw ERC20 tokens", async () => {
      const amount = ethers.utils.parseEther("500");
      const balanceBefore = await mockERC20.balanceOf(user2.address);

      await mockERC20.connect(user1).approve(permissionVault.address, amount);
      await permissionVault
        .connect(user1)
        .depositERC20(mockERC20.address, amount);

      await expect(
        permissionVault
          .connect(controller)
          .withdrawERC20(user2.address, mockERC20.address, amount)
      )
        .to.emit(permissionVault, "WithdrawERC20")
        .withArgs(controller.address, user2.address, mockERC20.address, amount);

      const balanceAfter = await mockERC20.balanceOf(user2.address);

      expect(balanceAfter.sub(balanceBefore)).to.be.equal(amount);
    });
  });

  describe("ERC721", () => {
    beforeEach(async () => {
      await permissionVault.connect(owner).addController(controller.address);
    });

    it("should deposit ERC721 tokens", async () => {
      const tokenId = 500;

      const balanceBefore = await mockERC721.balanceOf(user1.address);

      await mockERC721.connect(user1).approve(permissionVault.address, tokenId);
      await expect(
        permissionVault
          .connect(user1)
          .depositERC721(mockERC721.address, tokenId)
      )
        .to.emit(permissionVault, "DepositERC721")
        .withArgs(user1.address, mockERC721.address, tokenId);

      const balanceAfter = await mockERC721.balanceOf(user1.address);

      expect(balanceBefore.sub(balanceAfter)).to.be.equal(1);
      expect(await mockERC721.ownerOf(tokenId)).to.be.equal(
        permissionVault.address
      );
    });

    it("should revert when vault is not the owner of token", async () => {
      const tokenId = 500;

      await expect(
        permissionVault
          .connect(controller)
          .withdrawERC721(user2.address, mockERC721.address, tokenId)
      ).to.revertedWithCustomError(permissionVault, "NotExistToken");
    });

    it("should withdraw ERC721 token", async () => {
      const tokenId = 500;

      const balanceBefore = await mockERC721.balanceOf(user2.address);

      await mockERC721.connect(user1).approve(permissionVault.address, tokenId);
      await permissionVault
        .connect(user1)
        .depositERC721(mockERC721.address, tokenId);

      await expect(
        permissionVault
          .connect(controller)
          .withdrawERC721(user2.address, mockERC721.address, tokenId)
      )
        .to.emit(permissionVault, "WithdrawERC721")
        .withArgs(
          controller.address,
          user2.address,
          mockERC721.address,
          tokenId
        );

      const balanceAfter = await mockERC721.balanceOf(user2.address);

      expect(balanceAfter.sub(balanceBefore)).to.be.equal(1);
    });
  });

  describe("ERC1155", () => {
    beforeEach(async () => {
      await permissionVault.connect(owner).addController(controller.address);
    });

    it("should revert when deposit amount is zero", async () => {
      const tokenId = 1;
      const amount = 0;

      await expect(
        permissionVault
          .connect(user1)
          .depositERC1155(mockERC1155.address, tokenId, amount)
      ).to.be.revertedWithCustomError(permissionVault, "ZeroAmount");
    });

    it("deposit deposit ERC1155 tokens", async () => {
      const tokenId = 1;
      const amount = 500;

      const balanceBefore = await mockERC1155.balanceOf(user1.address, tokenId);

      await mockERC1155
        .connect(user1)
        .setApprovalForAll(permissionVault.address, true);
      await expect(
        permissionVault
          .connect(user1)
          .depositERC1155(mockERC1155.address, tokenId, amount)
      )
        .to.emit(permissionVault, "DepositERC1155")
        .withArgs(user1.address, mockERC1155.address, tokenId, amount);

      const balanceAfter = await mockERC1155.balanceOf(user1.address, tokenId);

      expect(balanceBefore.sub(balanceAfter)).to.be.equal(amount);
    });

    it("should revert when vault has insufficient balance", async () => {
      const tokenId = 1;
      const amount = 500;

      await expect(
        permissionVault
          .connect(controller)
          .withdrawERC1155(user2.address, mockERC1155.address, tokenId, amount)
      ).to.be.revertedWithCustomError(permissionVault, "NotEnoughBalance");
    });

    it("should withdraw ERC1155 tokens", async () => {
      const tokenId = 1;
      const amount = 500;

      const balanceBefore = await mockERC1155.balanceOf(user2.address, tokenId);

      await mockERC1155
        .connect(user1)
        .setApprovalForAll(permissionVault.address, true);
      await permissionVault
        .connect(user1)
        .depositERC1155(mockERC1155.address, tokenId, amount);

      await expect(
        permissionVault
          .connect(controller)
          .withdrawERC1155(user2.address, mockERC1155.address, tokenId, amount)
      )
        .to.emit(permissionVault, "WithdrawERC1155")
        .withArgs(
          controller.address,
          user2.address,
          mockERC1155.address,
          tokenId,
          amount
        );

      const balanceAfter = await mockERC1155.balanceOf(user2.address, tokenId);

      expect(balanceAfter.sub(balanceBefore)).to.be.equal(amount);
    });
  });
});
