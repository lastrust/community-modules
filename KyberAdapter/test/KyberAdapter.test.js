const { expect } = require("chai")
const { ethers } = require("hardhat")
const web3 = require("web3")
const { parseUnits, keccak256, toUtf8Bytes } = ethers.utils
const { AdapterTestEnv } = require('../utils/test')

// Goerli Testnet Addresses
const KYBER_SWAPGASESTIMATE = 200_000

const WAVAX_TO_SAVAX_POOL = "0xC6BC80490A3D022ac888b26A5Ae4f1fad89506Bd"
const WAVAX_TO_USDCe_POOL_1 = "0x475d13a015d478aa8271655584348F3268007cBD"
const WAVAX_TO_USDCe_POOL_2 = "0x01BEC8eB4F2f966933C5ae2BfA6d3E827a2434BC"

const WAVAX_ADDRESS = "0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7"
const SAVAX_ADDRESS = "0x2b2C81e08f1Af8835a78Bb2A90AE924ACE0eA4bE"
const USDCe_ADDRESS = "0xa7d7079b0fead91f3e65f86e8915cb59c1a4c664"

const KECCAK256_MAINTAINER_ROLE = keccak256(toUtf8Bytes("MAINTAINER_ROLE"))
const KECCAK256_DEFAULT_ADMIN_ROLE = "0x0000000000000000000000000000000000000000000000000000000000000000"

describe("Test KyberAdapter", function () {
    let owner, trader, nonOwner, tester
    let kyberAdapterFactory
    let kyberAdapter
    let savaxToken, usdceToken, wavaxToken
    let adapterTestEnv

    before(async function () {
        // Getting the users provided by ethers
        [owner, trader, nonOwner, tester] = await ethers.getSigners()

        // Getting the KyberAdapter contract code (abi, bytecode, name)
        kyberAdapterFactory = await ethers.getContractFactory("KyberAdapter")

        // Deploying the instance
        kyberAdapter = await kyberAdapterFactory.deploy("KyberAdapter", [WAVAX_TO_SAVAX_POOL, WAVAX_TO_USDCe_POOL_1, WAVAX_TO_USDCe_POOL_2], KYBER_SWAPGASESTIMATE)
        await kyberAdapter.deployed()

        savaxToken = await ethers.getContractAt("ERC20Mock", SAVAX_ADDRESS)
        usdceToken = await ethers.getContractAt("ERC20Mock", USDCe_ADDRESS)
        wavaxToken = await ethers.getContractAt("IWETH", WAVAX_ADDRESS)

        adapterTestEnv = new AdapterTestEnv(kyberAdapter, trader)

        const value = parseUnits('10', 'ether')
        await wavaxToken.connect(trader).deposit({ value: value })
    })

    it("check deployment", async function () {

    })

    describe("onlyMaintainer", function () {
        it("Allows the owner to call an onlyMaintainer function", async function () {
            await expect(kyberAdapter.connect(owner).setSwapGasEstimate(KYBER_SWAPGASESTIMATE)).to.not.reverted
        })

        it("Does not allow a non-maintainer to call an onlyMaintainer function", async function () {
            await expect(kyberAdapter.connect(nonOwner).setSwapGasEstimate(KYBER_SWAPGASESTIMATE)).to.be.revertedWith(
                "Maintainable: Caller is not a maintainer"
            )
        })

        it("Allows the owner to grant access to a new maintainer who can call an onlyMaintainer function", async function () {
            await kyberAdapter.connect(owner).addMaintainer(nonOwner.address)
            await expect(kyberAdapter.connect(nonOwner).setSwapGasEstimate(KYBER_SWAPGASESTIMATE)).to.not.reverted
            await kyberAdapter.connect(owner).removeMaintainer(nonOwner.address)
        })

        it("Does not allow a maintainer to call an onlyMaintainer function after the new owner has revoked their role", async function () {
            await kyberAdapter.connect(owner).addMaintainer(nonOwner.address)
            await kyberAdapter.connect(owner).removeMaintainer(nonOwner.address)
            await expect(kyberAdapter.connect(nonOwner).setSwapGasEstimate(KYBER_SWAPGASESTIMATE)).to.be.revertedWith(
                "Maintainable: Caller is not a maintainer"
            )
        })
    })

    describe("AccessControl", function () {
        describe("Adding a maintainer", function () {
            it("Allows the owner to add a new maintainer", async function () {
                await expect(kyberAdapter.connect(owner).addMaintainer(nonOwner.address)).to.not.reverted;
                await kyberAdapter.connect(owner).removeMaintainer(nonOwner.address)
            })

            it("Does not allow a maintainer to add a new maintainer", async () => {
                await kyberAdapter.connect(owner).addMaintainer(nonOwner.address);
                await expect(kyberAdapter.connect(nonOwner).addMaintainer(tester.address)).to.be.revertedWith(
                    `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
                await kyberAdapter.connect(owner).removeMaintainer(nonOwner.address)
            });

            it("Does not allow a random user to add a new maintainer", async () => {
                await expect(kyberAdapter.connect(nonOwner).addMaintainer(tester.address)).to.be.revertedWith(
                    `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
            });
        })

        describe("Removing a maintainer", () => {
            it("Allows the owner to remove a maintainer", async () => {
                await kyberAdapter.connect(owner).addMaintainer(nonOwner.address);
                await expect(kyberAdapter.connect(owner).removeMaintainer(nonOwner.address)).to.not.reverted;
            });

            it("Does not allow a maintainer to remove a maintainer", async () => {
                await kyberAdapter.connect(owner).addMaintainer(nonOwner.address);
                await expect(kyberAdapter.connect(nonOwner).removeMaintainer(tester.address)).to.be.revertedWith(
                    `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
                await kyberAdapter.connect(owner).removeMaintainer(nonOwner.address)
            });

            it("Does not allow a random user to remove a maintainer", async () => {
                await kyberAdapter.connect(owner).addMaintainer(nonOwner.address);
                await expect(kyberAdapter.connect(tester).removeMaintainer(nonOwner.address)).to.be.revertedWith(
                    `AccessControl: account ${tester.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
                await kyberAdapter.connect(owner).removeMaintainer(nonOwner.address)
            });
        });
    })

    describe("Transfering ownership", () => {
        it("Allows the owner to transfer ownership", async () => {
            await expect(kyberAdapter.connect(owner).transferOwnership(nonOwner.address)).to.not.reverted;
            await expect(kyberAdapter.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });

        it("Does not allow the owner to add a maintainer after transfering ownership", async () => {
            await kyberAdapter.connect(owner).transferOwnership(nonOwner.address);
            await expect(kyberAdapter.connect(owner).addMaintainer(tester.address)).to.be.revertedWith(
                `AccessControl: account ${owner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
            );
            await expect(kyberAdapter.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });

        it("Does not allow a maintainer to transfer ownership", async () => {
            kyberAdapter.connect(owner).addMaintainer(nonOwner.address);
            await expect(kyberAdapter.connect(nonOwner).transferOwnership(nonOwner.address)).to.be.revertedWith(
                `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
            );
            await kyberAdapter.connect(owner).removeMaintainer(nonOwner.address)
        });

        it("Does not allow a random user to transfer ownership", async () => {
            await expect(kyberAdapter.connect(nonOwner).transferOwnership(nonOwner.address)).to.be.revertedWith(
                `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
            );
        });
    });

    describe("Events", () => {
        it("Emits the expected event when the owner adds a maintainer", async () => {
            await expect(kyberAdapter.connect(owner).addMaintainer(nonOwner.address))
                .to.emit(kyberAdapter, "RoleGranted")
                .withArgs(KECCAK256_MAINTAINER_ROLE, nonOwner.address, owner.address);
            await kyberAdapter.connect(owner).removeMaintainer(nonOwner.address)
        });

        it("Emits the expected event when the owner removes a maintainer", async () => {
            await kyberAdapter.connect(owner).addMaintainer(nonOwner.address);
            await expect(kyberAdapter.connect(owner).removeMaintainer(nonOwner.address))
                .to.emit(kyberAdapter, "RoleRevoked")
                .withArgs(KECCAK256_MAINTAINER_ROLE, nonOwner.address, owner.address);
            await kyberAdapter.connect(owner).removeMaintainer(nonOwner.address)
        });

        it("Emits the role granted event when the owner transfers ownership", async () => {
            await expect(kyberAdapter.connect(owner).transferOwnership(nonOwner.address))
                .to.emit(kyberAdapter, "RoleGranted")
                .withArgs(KECCAK256_DEFAULT_ADMIN_ROLE, nonOwner.address, owner.address);
            await expect(kyberAdapter.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });

        it("Emits the role revoked event when the owner transfers ownership", async () => {
            await expect(kyberAdapter.connect(owner).transferOwnership(nonOwner.address))
                .to.emit(kyberAdapter, "RoleRevoked")
                .withArgs(KECCAK256_DEFAULT_ADMIN_ROLE, owner.address, owner.address);
            await expect(kyberAdapter.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });
    });

    describe("Swapping matches query", function () {
        it("1 WAVAX -> SAVAX", async function () {
            await adapterTestEnv.checkSwapMatchesQuery('1', wavaxToken, savaxToken)
        })

        it("1 WAVAX -> USDCe", async function () {
            await adapterTestEnv.checkSwapMatchesQuery('1', wavaxToken, usdceToken)
        })
    })

    it("Query returns zero if tokens not found", async function () {
        const supportedToken = wavaxToken
        await adapterTestEnv.checkQueryReturnsZeroForUnsupportedTkns(supportedToken)
    })

    it('Gas-estimate is between max-gas-used and 110% max-gas-used', async () => {
        const options = [
            ['1', wavaxToken, savaxToken],
            ['1', wavaxToken, usdceToken],
        ]
        await adapterTestEnv.checkGasEstimateIsSensible(options)
    })
})