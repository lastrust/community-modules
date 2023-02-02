const { expect } = require("chai")
const { ethers } = require("hardhat")
const web3 = require("web3")
const { parseUnits, keccak256, toUtf8Bytes } = ethers.utils
const { AdapterTestEnv } = require('../utils/test')

// Goerli Testnet Addresses
const UNISWAPV3_FACTORY_ADDRESS = "0x1F98431c8aD98523631AE4a59f267346ea31F984"
const UNISWAPV3_QUOTER_ADDRESS = "0x426366212BB3a133a69E4cA70A8e3Ed88336Da91"
const UNISWAPV3_SWAPGASESTIMATE = 380000
const UNISWAPV3_QUOTERGASESTIMATE = 380000

const WETH_ADDRESS = "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6"
const USDC_ADDRESS = "0x07865c6E87B9F70255377e024ace6630C1Eaa37F"
const DAI_ADDRESS = "0xdc31Ee1784292379Fbb2964b3B9C4124D8F89C60"

const KECCAK256_MAINTAINER_ROLE = keccak256(toUtf8Bytes("MAINTAINER_ROLE"))
const KECCAK256_DEFAULT_ADMIN_ROLE = "0x0000000000000000000000000000000000000000000000000000000000000000"

describe("Test UniswapV3Adapter", function () {
    let owner, trader, nonOwner, tester
    let uniswapV3AdapterFactory
    let uniswapV3Adapter
    let usdcToken, daiToken, wethToken
    let adapterTestEnv

    before(async function () {
        // Getting the users provided by ethers
        const signers = await ethers.getSigners()
        owner = signers[0]
        trader = signers[1]
        nonOwner = signers[2]
        tester = signers[3]

        // Getting the UniswapV3Adapter contract code (abi, bytecode, name)
        uniswapV3AdapterFactory = await ethers.getContractFactory("UniswapV3Adapter")

        // Deploying the instance
        uniswapV3Adapter = await uniswapV3AdapterFactory.deploy("UniswapV3Adapter", UNISWAPV3_SWAPGASESTIMATE, UNISWAPV3_QUOTERGASESTIMATE, UNISWAPV3_QUOTER_ADDRESS, UNISWAPV3_FACTORY_ADDRESS)
        await uniswapV3Adapter.deployed()

        usdcToken = await ethers.getContractAt("ERC20Mock", USDC_ADDRESS)
        daiToken = await ethers.getContractAt("ERC20Mock", DAI_ADDRESS)
        wethToken = await ethers.getContractAt("IWETH", WETH_ADDRESS)

        adapterTestEnv = new AdapterTestEnv(uniswapV3Adapter, trader)

        const value = parseUnits('10', 'ether')
        await wethToken.connect(trader).deposit({ value: value })
    })

    it("check deployment", async function () {

    })

    describe("onlyMaintainer", function () {
        it("Allows the owner to call an onlyMaintainer function", async function () {
            await expect(uniswapV3Adapter.connect(owner).setSwapGasEstimate(UNISWAPV3_SWAPGASESTIMATE)).to.not.reverted
        })

        it("Does not allow a non-maintainer to call an onlyMaintainer function", async function () {
            await expect(uniswapV3Adapter.connect(nonOwner).setSwapGasEstimate(UNISWAPV3_SWAPGASESTIMATE)).to.be.revertedWith(
                "Maintainable: Caller is not a maintainer"
            )
        })

        it("Allows the owner to grant access to a new maintainer who can call an onlyMaintainer function", async function () {
            await uniswapV3Adapter.connect(owner).addMaintainer(nonOwner.address)
            await expect(uniswapV3Adapter.connect(nonOwner).setSwapGasEstimate(UNISWAPV3_SWAPGASESTIMATE)).to.not.reverted
            await uniswapV3Adapter.connect(owner).removeMaintainer(nonOwner.address)
        })

        it("Does not allow a maintainer to call an onlyMaintainer function after the new owner has revoked their role", async function () {
            await uniswapV3Adapter.connect(owner).addMaintainer(nonOwner.address)
            await uniswapV3Adapter.connect(owner).removeMaintainer(nonOwner.address)
            await expect(uniswapV3Adapter.connect(nonOwner).setSwapGasEstimate(UNISWAPV3_SWAPGASESTIMATE)).to.be.revertedWith(
                "Maintainable: Caller is not a maintainer"
            )
        })
    })

    describe("AccessControl", function () {
        describe("Adding a maintainer", function () {
            it("Allows the owner to add a new maintainer", async function () {
                await expect(uniswapV3Adapter.connect(owner).addMaintainer(nonOwner.address)).to.not.reverted;
                await uniswapV3Adapter.connect(owner).removeMaintainer(nonOwner.address)
            })

            it("Does not allow a maintainer to add a new maintainer", async () => {
                await uniswapV3Adapter.connect(owner).addMaintainer(nonOwner.address);
                await expect(uniswapV3Adapter.connect(nonOwner).addMaintainer(tester.address)).to.be.revertedWith(
                    `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
                await uniswapV3Adapter.connect(owner).removeMaintainer(nonOwner.address)
            });

            it("Does not allow a random user to add a new maintainer", async () => {
                await expect(uniswapV3Adapter.connect(nonOwner).addMaintainer(tester.address)).to.be.revertedWith(
                    `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
            });
        })

        describe("Removing a maintainer", () => {
            it("Allows the owner to remove a maintainer", async () => {
                await uniswapV3Adapter.connect(owner).addMaintainer(nonOwner.address);
                await expect(uniswapV3Adapter.connect(owner).removeMaintainer(nonOwner.address)).to.not.reverted;
            });

            it("Does not allow a maintainer to remove a maintainer", async () => {
                await uniswapV3Adapter.connect(owner).addMaintainer(nonOwner.address);
                await expect(uniswapV3Adapter.connect(nonOwner).removeMaintainer(tester.address)).to.be.revertedWith(
                    `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
                await uniswapV3Adapter.connect(owner).removeMaintainer(nonOwner.address)
            });

            it("Does not allow a random user to remove a maintainer", async () => {
                await uniswapV3Adapter.connect(owner).addMaintainer(nonOwner.address);
                await expect(uniswapV3Adapter.connect(tester).removeMaintainer(nonOwner.address)).to.be.revertedWith(
                    `AccessControl: account ${tester.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
                await uniswapV3Adapter.connect(owner).removeMaintainer(nonOwner.address)
            });
        });
    })

    describe("Transfering ownership", () => {
        it("Allows the owner to transfer ownership", async () => {
            await expect(uniswapV3Adapter.connect(owner).transferOwnership(nonOwner.address)).to.not.reverted;
            await expect(uniswapV3Adapter.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });

        it("Does not allow the owner to add a maintainer after transfering ownership", async () => {
            await uniswapV3Adapter.connect(owner).transferOwnership(nonOwner.address);
            await expect(uniswapV3Adapter.connect(owner).addMaintainer(tester.address)).to.be.revertedWith(
                `AccessControl: account ${owner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
            );
            await expect(uniswapV3Adapter.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });

        it("Does not allow a maintainer to transfer ownership", async () => {
            uniswapV3Adapter.connect(owner).addMaintainer(nonOwner.address);
            await expect(uniswapV3Adapter.connect(nonOwner).transferOwnership(nonOwner.address)).to.be.revertedWith(
                `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
            );
            await uniswapV3Adapter.connect(owner).removeMaintainer(nonOwner.address)
        });

        it("Does not allow a random user to transfer ownership", async () => {
            await expect(uniswapV3Adapter.connect(nonOwner).transferOwnership(nonOwner.address)).to.be.revertedWith(
                `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
            );
        });
    });

    describe("Events", () => {
        it("Emits the expected event when the owner adds a maintainer", async () => {
            await expect(uniswapV3Adapter.connect(owner).addMaintainer(nonOwner.address))
                .to.emit(uniswapV3Adapter, "RoleGranted")
                .withArgs(KECCAK256_MAINTAINER_ROLE, nonOwner.address, owner.address);
            await uniswapV3Adapter.connect(owner).removeMaintainer(nonOwner.address)
        });

        it("Emits the expected event when the owner removes a maintainer", async () => {
            await uniswapV3Adapter.connect(owner).addMaintainer(nonOwner.address);
            await expect(uniswapV3Adapter.connect(owner).removeMaintainer(nonOwner.address))
                .to.emit(uniswapV3Adapter, "RoleRevoked")
                .withArgs(KECCAK256_MAINTAINER_ROLE, nonOwner.address, owner.address);
            await uniswapV3Adapter.connect(owner).removeMaintainer(nonOwner.address)
        });

        it("Emits the role granted event when the owner transfers ownership", async () => {
            await expect(uniswapV3Adapter.connect(owner).transferOwnership(nonOwner.address))
                .to.emit(uniswapV3Adapter, "RoleGranted")
                .withArgs(KECCAK256_DEFAULT_ADMIN_ROLE, nonOwner.address, owner.address);
            await expect(uniswapV3Adapter.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });

        it("Emits the role revoked event when the owner transfers ownership", async () => {
            await expect(uniswapV3Adapter.connect(owner).transferOwnership(nonOwner.address))
                .to.emit(uniswapV3Adapter, "RoleRevoked")
                .withArgs(KECCAK256_DEFAULT_ADMIN_ROLE, owner.address, owner.address);
            await expect(uniswapV3Adapter.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
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

    it('Adapter can only spend max-gas + buffer', async () => {
        const gasBuffer = ethers.BigNumber.from('50000')
        const quoterGasLimit = await uniswapV3Adapter.quoterGasLimit()
        const dy = await uniswapV3Adapter.estimateGas.query(
            ethers.utils.parseUnits('1000000', 6),
            usdcToken.address,
            wethToken.address
        )
        expect(dy).to.lt(quoterGasLimit.add(gasBuffer))
    })

    it('Gas-estimate is between max-gas-used and 110% max-gas-used', async () => {
        const options = [
            ['1', wethToken, usdcToken],
            ['1', wethToken, daiToken],
        ]
        await adapterTestEnv.checkGasEstimateIsSensible(options)
    })
})