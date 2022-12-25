const { expect } = require("chai");

describe("ERC721Lockable contract", function () {
  let owner;
  let alice;
  let erc721Lockable;

  beforeEach(async () => {
    [owner, alice] = await ethers.getSigners();

    const ERC721LockableMock = await ethers.getContractFactory(
      "ERC721LockableMock"
    );
    erc721Lockable = await ERC721LockableMock.deploy("Mock", "M");
  });

  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const ownerBalance = await erc721Lockable.balanceOf(owner.address);
    expect(await erc721Lockable.totalSupply()).to.equal(ownerBalance);
  });

  it("lockMint works", async function () {
    const NFTId = 0;
    const block = await ethers.provider.getBlockNumber();
    const blockBefore = await ethers.provider.getBlock(block);
    const timestamp = blockBefore.timestamp;
    await erc721Lockable.lockMint(alice.address, NFTId, timestamp + 2);

    expect(await erc721Lockable.isLocked(NFTId)).eq(true);
    expect(await erc721Lockable.lockerOf(NFTId)).eq(owner.address);
  });

  it("Can not transfer when token is locked", async function () {
    const NFTId = 0;
    const block = await ethers.provider.getBlockNumber();
    const blockBefore = await ethers.provider.getBlock(block);
    const timestamp = blockBefore.timestamp;
    await erc721Lockable.lockMint(owner.address, NFTId, timestamp + 3);

    // can not transfer when token is locked
    await expect(
      erc721Lockable.transferFrom(owner.address, alice.address, NFTId)
    ).to.be.revertedWith("ERC721Lockable: Token transfer while locked");

    // can transfer when token is unlocked
    await ethers.provider.send("evm_mine", []);
    await erc721Lockable.transferFrom(owner.address, alice.address, NFTId);
    expect(await erc721Lockable.ownerOf(NFTId)).eq(alice.address);
  });

  it("isLocked works", async function () {
    const NFTId = 0;
    const block = await ethers.provider.getBlockNumber();
    const blockBefore = await ethers.provider.getBlock(block);
    const timestamp = blockBefore.timestamp;
    await erc721Lockable.lockMint(owner.address, NFTId, timestamp + 2);

    // isLocked works
    expect(await erc721Lockable.isLocked(NFTId)).eq(true);
    await ethers.provider.send("evm_mine", []);
    expect(await erc721Lockable.isLocked(NFTId)).eq(false);
  });

  it("lockFrom works", async function () {
    const NFTId = 0;
    let block = await ethers.provider.getBlockNumber();
    const blockBefore = await ethers.provider.getBlock(block);
    const timestamp = blockBefore.timestamp;
    await erc721Lockable.lockMint(owner.address, NFTId, timestamp + 3);

    await expect(
      erc721Lockable.lockFrom(owner.address, NFTId, timestamp + 5)
    ).to.be.revertedWith("ERC721Lockable: token is locked");

    await ethers.provider.send("evm_mine", []);
    await erc721Lockable.lockFrom(owner.address, NFTId, timestamp + 5);
  });

  it("unlockFrom works with lockMint", async function () {
    const NFTId = 0;
    const block = await ethers.provider.getBlockNumber();
    const blockBefore = await ethers.provider.getBlock(block);
    const timestamp = blockBefore.timestamp;
    await erc721Lockable.lockMint(owner.address, NFTId, timestamp + 3);

    // unlock works
    expect(await erc721Lockable.isLocked(NFTId)).eq(true);
    expect(await erc721Lockable.lockerOf(NFTId)).eq(owner.address);
    await erc721Lockable.unlockFrom(owner.address, NFTId);
    expect(await erc721Lockable.isLocked(NFTId)).eq(false);
  });

  it("unlockFrom works", async function () {
    const NFTId = 0;

    await erc721Lockable.mint(owner.address, NFTId);

    await expect(
      erc721Lockable.unlockFrom(owner.address, NFTId)
    ).to.be.revertedWith("ERC721Lockable: locker query for non-locked token");
    const block = await ethers.provider.getBlockNumber();
    const blockBefore = await ethers.provider.getBlock(block);
    const timestamp = blockBefore.timestamp;
    await erc721Lockable.lockFrom(owner.address, NFTId, timestamp + 3);
    expect(await erc721Lockable.isLocked(NFTId)).eq(true);
    await erc721Lockable.unlockFrom(owner.address, NFTId);
    expect(await erc721Lockable.isLocked(NFTId)).eq(false);
  });

  it("lockApprove works", async function () {
    const NFTId = 0;
    await erc721Lockable.mint(alice.address, NFTId);

    let block = await ethers.provider.getBlockNumber();
    const blockBefore = await ethers.provider.getBlock(block);
    const timestamp = blockBefore.timestamp;
    await expect(
      erc721Lockable.lockFrom(owner.address, NFTId, timestamp + 2)
    ).to.be.revertedWith(
      "ERC721Lockable: lock caller is not owner nor approved"
    );

    await erc721Lockable.connect(alice).lockApprove(owner.address, NFTId);
    expect(await erc721Lockable.getLockApproved(NFTId)).eq(owner.address);

    await expect(
      erc721Lockable.lockFrom(owner.address, NFTId, timestamp + 4)
    ).to.be.revertedWith("ERC721Lockable: lock from incorrect owner");
    await erc721Lockable.lockFrom(alice.address, NFTId, timestamp + 6);
    expect(await erc721Lockable.isLocked(NFTId)).eq(true);

    await expect(
      erc721Lockable.lockApprove(alice.address, NFTId)
    ).to.be.revertedWith("ERC721Lockable: token is locked");
  });

  it("setLockApproveForAll works", async function () {
    const NFTId = 0;

    await erc721Lockable.mint(alice.address, NFTId);
    const block = await ethers.provider.getBlockNumber();
    const blockBefore = await ethers.provider.getBlock(block);
    const timestamp = blockBefore.timestamp;
    await expect(
      erc721Lockable.lockFrom(alice.address, NFTId, timestamp + 2)
    ).to.be.revertedWith(
      "ERC721Lockable: lock caller is not owner nor approved"
    );

    await erc721Lockable
      .connect(alice)
      .setLockApprovalForAll(owner.address, true);
    expect(
      await erc721Lockable.isLockApprovedForAll(alice.address, owner.address)
    ).eq(true);

    await erc721Lockable.lockFrom(alice.address, NFTId, timestamp + 6);

    await erc721Lockable
      .connect(alice)
      .setLockApprovalForAll(owner.address, false);
    expect(
      await erc721Lockable.isLockApprovedForAll(alice.address, owner.address)
    ).eq(false);
  });
});
