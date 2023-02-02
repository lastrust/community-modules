const { expect } = require("chai")
const { ethers } = require("hardhat")
const web3 = require("web3")
const { parseUnits, keccak256, toUtf8Bytes } = ethers.utils
const { AdapterTestEnv } = require('../utils/test')

// Goerli Testnet Addresses
const UNISWAPV2_FACTORY_ADDRESS = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f"
const UNISWAPV2_FEE = 3
const UNISWAPV2_SWAPGASESTIMATE = 150000

const WETH_ADDRESS = "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6"
const USDC_ADDRESS = "0x07865c6E87B9F70255377e024ace6630C1Eaa37F"
const DAI_ADDRESS = "0xdc31Ee1784292379Fbb2964b3B9C4124D8F89C60"

const KECCAK256_MAINTAINER_ROLE = keccak256(toUtf8Bytes("MAINTAINER_ROLE"))
const KECCAK256_DEFAULT_ADMIN_ROLE = "0x0000000000000000000000000000000000000000000000000000000000000000"

describe("Test UniswapV2Adapter", function () {
    let owner, trader, nonOwner, tester
    let uniswapV2AdapterFactory
    let uniswapV2Adapter
    let usdcToken, daiToken, wethToken
    let adapterTestEnv

    before(async function () {
        // Getting the users provided by ethers
        [owner, trader, nonOwner, tester] = await ethers.getSigners()

        // Getting the UniswapV2Adapter contract code (abi, bytecode, name)
        uniswapV2AdapterFactory = await ethers.getContractFactory("UniswapV2Adapter")

        // Deploying the instance
        uniswapV2Adapter = await uniswapV2AdapterFactory.deploy("UniswapV2Adapter", UNISWAPV2_FACTORY_ADDRESS, UNISWAPV2_FEE, UNISWAPV2_SWAPGASESTIMATE)
        await uniswapV2Adapter.deployed()

        usdcToken = await ethers.getContractAt("ERC20Mock", USDC_ADDRESS)
        daiToken = await ethers.getContractAt("ERC20Mock", DAI_ADDRESS)
        wethToken = await ethers.getContractAt("IWETH", WETH_ADDRESS)

        adapterTestEnv = new AdapterTestEnv(uniswapV2Adapter, trader)

        const value = parseUnits('10', 'ether')
        await wethToken.connect(trader).deposit({ value: value })
    })

    it("check deployment", async function () {

    })

    describe("onlyMaintainer", function () {
        it("Allows the owner to call an onlyMaintainer function", async function () {
            await expect(uniswapV2Adapter.connect(owner).setSwapGasEstimate(UNISWAPV2_SWAPGASESTIMATE)).to.not.reverted
        })

        it("Does not allow a non-maintainer to call an onlyMaintainer function", async function () {
            await expect(uniswapV2Adapter.connect(nonOwner).setSwapGasEstimate(UNISWAPV2_SWAPGASESTIMATE)).to.be.revertedWith(
                "Maintainable: Caller is not a maintainer"
            )
        })

        it("Allows the owner to grant access to a new maintainer who can call an onlyMaintainer function", async function () {
            await uniswapV2Adapter.connect(owner).addMaintainer(nonOwner.address)
            await expect(uniswapV2Adapter.connect(nonOwner).setSwapGasEstimate(UNISWAPV2_SWAPGASESTIMATE)).to.not.reverted
            await uniswapV2Adapter.connect(owner).removeMaintainer(nonOwner.address)
        })

        it("Does not allow a maintainer to call an onlyMaintainer function after the new owner has revoked their role", async function () {
            await uniswapV2Adapter.connect(owner).addMaintainer(nonOwner.address)
            await uniswapV2Adapter.connect(owner).removeMaintainer(nonOwner.address)
            await expect(uniswapV2Adapter.connect(nonOwner).setSwapGasEstimate(UNISWAPV2_SWAPGASESTIMATE)).to.be.revertedWith(
                "Maintainable: Caller is not a maintainer"
            )
        })
    })

    describe("AccessControl", function () {
        describe("Adding a maintainer", function () {
            it("Allows the owner to add a new maintainer", async function () {
                await expect(uniswapV2Adapter.connect(owner).addMaintainer(nonOwner.address)).to.not.reverted;
                await uniswapV2Adapter.connect(owner).removeMaintainer(nonOwner.address)
            })

            it("Does not allow a maintainer to add a new maintainer", async () => {
                await uniswapV2Adapter.connect(owner).addMaintainer(nonOwner.address);
                await expect(uniswapV2Adapter.connect(nonOwner).addMaintainer(tester.address)).to.be.revertedWith(
                    `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
                await uniswapV2Adapter.connect(owner).removeMaintainer(nonOwner.address)
            });

            it("Does not allow a random user to add a new maintainer", async () => {
                await expect(uniswapV2Adapter.connect(nonOwner).addMaintainer(tester.address)).to.be.revertedWith(
                    `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
            });
        })

        describe("Removing a maintainer", () => {
            it("Allows the owner to remove a maintainer", async () => {
                await uniswapV2Adapter.connect(owner).addMaintainer(nonOwner.address);
                await expect(uniswapV2Adapter.connect(owner).removeMaintainer(nonOwner.address)).to.not.reverted;
            });

            it("Does not allow a maintainer to remove a maintainer", async () => {
                await uniswapV2Adapter.connect(owner).addMaintainer(nonOwner.address);
                await expect(uniswapV2Adapter.connect(nonOwner).removeMaintainer(tester.address)).to.be.revertedWith(
                    `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
                await uniswapV2Adapter.connect(owner).removeMaintainer(nonOwner.address)
            });

            it("Does not allow a random user to remove a maintainer", async () => {
                await uniswapV2Adapter.connect(owner).addMaintainer(nonOwner.address);
                await expect(uniswapV2Adapter.connect(tester).removeMaintainer(nonOwner.address)).to.be.revertedWith(
                    `AccessControl: account ${tester.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
                await uniswapV2Adapter.connect(owner).removeMaintainer(nonOwner.address)
            });
        });
    })

    describe("Transfering ownership", () => {
        it("Allows the owner to transfer ownership", async () => {
            await expect(uniswapV2Adapter.connect(owner).transferOwnership(nonOwner.address)).to.not.reverted;
            await expect(uniswapV2Adapter.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });

        it("Does not allow the owner to add a maintainer after transfering ownership", async () => {
            await uniswapV2Adapter.connect(owner).transferOwnership(nonOwner.address);
            await expect(uniswapV2Adapter.connect(owner).addMaintainer(tester.address)).to.be.revertedWith(
                `AccessControl: account ${owner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
            );
            await expect(uniswapV2Adapter.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });

        it("Does not allow a maintainer to transfer ownership", async () => {
            uniswapV2Adapter.connect(owner).addMaintainer(nonOwner.address);
            await expect(uniswapV2Adapter.connect(nonOwner).transferOwnership(nonOwner.address)).to.be.revertedWith(
                `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
            );
            await uniswapV2Adapter.connect(owner).removeMaintainer(nonOwner.address)
        });

        it("Does not allow a random user to transfer ownership", async () => {
            await expect(uniswapV2Adapter.connect(nonOwner).transferOwnership(nonOwner.address)).to.be.revertedWith(
                `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
            );
        });
    });

    describe("Events", () => {
        it("Emits the expected event when the owner adds a maintainer", async () => {
            await expect(uniswapV2Adapter.connect(owner).addMaintainer(nonOwner.address))
                .to.emit(uniswapV2Adapter, "RoleGranted")
                .withArgs(KECCAK256_MAINTAINER_ROLE, nonOwner.address, owner.address);
            await uniswapV2Adapter.connect(owner).removeMaintainer(nonOwner.address)
        });

        it("Emits the expected event when the owner removes a maintainer", async () => {
            await uniswapV2Adapter.connect(owner).addMaintainer(nonOwner.address);
            await expect(uniswapV2Adapter.connect(owner).removeMaintainer(nonOwner.address))
                .to.emit(uniswapV2Adapter, "RoleRevoked")
                .withArgs(KECCAK256_MAINTAINER_ROLE, nonOwner.address, owner.address);
            await uniswapV2Adapter.connect(owner).removeMaintainer(nonOwner.address)
        });

        it("Emits the role granted event when the owner transfers ownership", async () => {
            await expect(uniswapV2Adapter.connect(owner).transferOwnership(nonOwner.address))
                .to.emit(uniswapV2Adapter, "RoleGranted")
                .withArgs(KECCAK256_DEFAULT_ADMIN_ROLE, nonOwner.address, owner.address);
            await expect(uniswapV2Adapter.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });

        it("Emits the role revoked event when the owner transfers ownership", async () => {
            await expect(uniswapV2Adapter.connect(owner).transferOwnership(nonOwner.address))
                .to.emit(uniswapV2Adapter, "RoleRevoked")
                .withArgs(KECCAK256_DEFAULT_ADMIN_ROLE, owner.address, owner.address);
            await expect(uniswapV2Adapter.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });
    });

    describe("Swapping matches query", function () {
        it("1 WETH -> USDC", async function () {
            await adapterTestEnv.checkSwapMatchesQuery('1', wethToken, usdcToken)
        })

        it("1 WETH -> DAI", async function () {
            await adapterTestEnv.checkSwapMatchesQuery('1', wethToken, daiToken)
        })
    })

    it("Query returns zero if tokens not found", async function () {
        const supportedToken = wethToken
        await adapterTestEnv.checkQueryReturnsZeroForUnsupportedTkns(supportedToken)
    })

    it('Gas-estimate is between max-gas-used and 110% max-gas-used', async () => {
        const options = [
            ['1', wethToken, usdcToken],
            ['1', wethToken, daiToken],
        ]
        await adapterTestEnv.checkGasEstimateIsSensible(options)
    })
})