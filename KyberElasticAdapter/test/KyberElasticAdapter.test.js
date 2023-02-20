const { expect } = require("chai")
const { ethers } = require("hardhat")
const web3 = require("web3")
const { parseUnits, keccak256, toUtf8Bytes } = ethers.utils
const { AdapterTestEnv } = require('../utils/test')

// Goerli Testnet Addresses
const KYBERELASTIC_QUOTER_ADDRESS = "0x14ec368E625b1d7a0cC5A9E381794CF56d6224EA"
const KYBERELASTIC_SWAPGASESTIMATE = 210_000
const KYBERELASTIC_QUOTERGASESTIMATE = 210_000

const SAVAX_WAVAX_POOL = "0x897a83cf016f33fb061e756e4ca89baa9f17990a"
const WAVAX_USDCe_POOL = "0x7CC5BE39CE2EddE09998cF1431121541EdfFF4cA"

const WAVAX_ADDRESS = "0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7"
const SAVAX_ADDRESS = "0x2b2C81e08f1Af8835a78Bb2A90AE924ACE0eA4bE"
const USDCe_ADDRESS = "0xa7d7079b0fead91f3e65f86e8915cb59c1a4c664"

const KECCAK256_MAINTAINER_ROLE = keccak256(toUtf8Bytes("MAINTAINER_ROLE"))
const KECCAK256_DEFAULT_ADMIN_ROLE = "0x0000000000000000000000000000000000000000000000000000000000000000"

describe("Test KyberElasticAdapter", function () {
    let owner, trader, nonOwner, tester
    let kyberElasticAdapterFactory
    let kyberElasticAdapter
    let usdceToken, wavaxToken, savaxToken
    let adapterTestEnv

    before(async function () {
        // Getting the users provided by ethers
        const signers = await ethers.getSigners()
        owner = signers[0]
        trader = signers[1]
        nonOwner = signers[2]
        tester = signers[3]

        // Getting the KyberElasticAdapter contract code (abi, bytecode, name)
        kyberElasticAdapterFactory = await ethers.getContractFactory("KyberElasticAdapter")

        // Deploying the instance
        kyberElasticAdapter = await kyberElasticAdapterFactory.deploy("KyberElasticAdapter", KYBERELASTIC_SWAPGASESTIMATE, KYBERELASTIC_QUOTERGASESTIMATE, KYBERELASTIC_QUOTER_ADDRESS, [SAVAX_WAVAX_POOL, WAVAX_USDCe_POOL])
        await kyberElasticAdapter.deployed()

        usdceToken = await ethers.getContractAt("ERC20Mock", USDCe_ADDRESS)
        savaxToken = await ethers.getContractAt("ERC20Mock", SAVAX_ADDRESS)
        wavaxToken = await ethers.getContractAt("IWETH", WAVAX_ADDRESS)

        adapterTestEnv = new AdapterTestEnv(kyberElasticAdapter, trader)

        const value = parseUnits('10', 'ether')
        await wavaxToken.connect(trader).deposit({ value: value })
    })

    it("check deployment", async function () {

    })

    describe("onlyMaintainer", function () {
        it("Allows the owner to call an onlyMaintainer function", async function () {
            await expect(kyberElasticAdapter.connect(owner).setSwapGasEstimate(KYBERELASTIC_SWAPGASESTIMATE)).to.not.reverted
        })

        it("Does not allow a non-maintainer to call an onlyMaintainer function", async function () {
            await expect(kyberElasticAdapter.connect(nonOwner).setSwapGasEstimate(KYBERELASTIC_SWAPGASESTIMATE)).to.be.revertedWith(
                "Maintainable: Caller is not a maintainer"
            )
        })

        it("Allows the owner to grant access to a new maintainer who can call an onlyMaintainer function", async function () {
            await kyberElasticAdapter.connect(owner).addMaintainer(nonOwner.address)
            await expect(kyberElasticAdapter.connect(nonOwner).setSwapGasEstimate(KYBERELASTIC_SWAPGASESTIMATE)).to.not.reverted
            await kyberElasticAdapter.connect(owner).removeMaintainer(nonOwner.address)
        })

        it("Does not allow a maintainer to call an onlyMaintainer function after the new owner has revoked their role", async function () {
            await kyberElasticAdapter.connect(owner).addMaintainer(nonOwner.address)
            await kyberElasticAdapter.connect(owner).removeMaintainer(nonOwner.address)
            await expect(kyberElasticAdapter.connect(nonOwner).setSwapGasEstimate(KYBERELASTIC_SWAPGASESTIMATE)).to.be.revertedWith(
                "Maintainable: Caller is not a maintainer"
            )
        })
    })

    describe("AccessControl", function () {
        describe("Adding a maintainer", function () {
            it("Allows the owner to add a new maintainer", async function () {
                await expect(kyberElasticAdapter.connect(owner).addMaintainer(nonOwner.address)).to.not.reverted;
                await kyberElasticAdapter.connect(owner).removeMaintainer(nonOwner.address)
            })

            it("Does not allow a maintainer to add a new maintainer", async () => {
                await kyberElasticAdapter.connect(owner).addMaintainer(nonOwner.address);
                await expect(kyberElasticAdapter.connect(nonOwner).addMaintainer(tester.address)).to.be.revertedWith(
                    `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
                await kyberElasticAdapter.connect(owner).removeMaintainer(nonOwner.address)
            });

            it("Does not allow a random user to add a new maintainer", async () => {
                await expect(kyberElasticAdapter.connect(nonOwner).addMaintainer(tester.address)).to.be.revertedWith(
                    `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
            });
        })

        describe("Removing a maintainer", () => {
            it("Allows the owner to remove a maintainer", async () => {
                await kyberElasticAdapter.connect(owner).addMaintainer(nonOwner.address);
                await expect(kyberElasticAdapter.connect(owner).removeMaintainer(nonOwner.address)).to.not.reverted;
            });

            it("Does not allow a maintainer to remove a maintainer", async () => {
                await kyberElasticAdapter.connect(owner).addMaintainer(nonOwner.address);
                await expect(kyberElasticAdapter.connect(nonOwner).removeMaintainer(tester.address)).to.be.revertedWith(
                    `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
                await kyberElasticAdapter.connect(owner).removeMaintainer(nonOwner.address)
            });

            it("Does not allow a random user to remove a maintainer", async () => {
                await kyberElasticAdapter.connect(owner).addMaintainer(nonOwner.address);
                await expect(kyberElasticAdapter.connect(tester).removeMaintainer(nonOwner.address)).to.be.revertedWith(
                    `AccessControl: account ${tester.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
                await kyberElasticAdapter.connect(owner).removeMaintainer(nonOwner.address)
            });
        });
    })

    describe("Transfering ownership", () => {
        it("Allows the owner to transfer ownership", async () => {
            await expect(kyberElasticAdapter.connect(owner).transferOwnership(nonOwner.address)).to.not.reverted;
            await expect(kyberElasticAdapter.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });

        it("Does not allow the owner to add a maintainer after transfering ownership", async () => {
            await kyberElasticAdapter.connect(owner).transferOwnership(nonOwner.address);
            await expect(kyberElasticAdapter.connect(owner).addMaintainer(tester.address)).to.be.revertedWith(
                `AccessControl: account ${owner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
            );
            await expect(kyberElasticAdapter.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });

        it("Does not allow a maintainer to transfer ownership", async () => {
            kyberElasticAdapter.connect(owner).addMaintainer(nonOwner.address);
            await expect(kyberElasticAdapter.connect(nonOwner).transferOwnership(nonOwner.address)).to.be.revertedWith(
                `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
            );
            await kyberElasticAdapter.connect(owner).removeMaintainer(nonOwner.address)
        });

        it("Does not allow a random user to transfer ownership", async () => {
            await expect(kyberElasticAdapter.connect(nonOwner).transferOwnership(nonOwner.address)).to.be.revertedWith(
                `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
            );
        });
    });

    describe("Events", () => {
        it("Emits the expected event when the owner adds a maintainer", async () => {
            await expect(kyberElasticAdapter.connect(owner).addMaintainer(nonOwner.address))
                .to.emit(kyberElasticAdapter, "RoleGranted")
                .withArgs(KECCAK256_MAINTAINER_ROLE, nonOwner.address, owner.address);
            await kyberElasticAdapter.connect(owner).removeMaintainer(nonOwner.address)
        });

        it("Emits the expected event when the owner removes a maintainer", async () => {
            await kyberElasticAdapter.connect(owner).addMaintainer(nonOwner.address);
            await expect(kyberElasticAdapter.connect(owner).removeMaintainer(nonOwner.address))
                .to.emit(kyberElasticAdapter, "RoleRevoked")
                .withArgs(KECCAK256_MAINTAINER_ROLE, nonOwner.address, owner.address);
            await kyberElasticAdapter.connect(owner).removeMaintainer(nonOwner.address)
        });

        it("Emits the role granted event when the owner transfers ownership", async () => {
            await expect(kyberElasticAdapter.connect(owner).transferOwnership(nonOwner.address))
                .to.emit(kyberElasticAdapter, "RoleGranted")
                .withArgs(KECCAK256_DEFAULT_ADMIN_ROLE, nonOwner.address, owner.address);
            await expect(kyberElasticAdapter.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });

        it("Emits the role revoked event when the owner transfers ownership", async () => {
            await expect(kyberElasticAdapter.connect(owner).transferOwnership(nonOwner.address))
                .to.emit(kyberElasticAdapter, "RoleRevoked")
                .withArgs(KECCAK256_DEFAULT_ADMIN_ROLE, owner.address, owner.address);
            await expect(kyberElasticAdapter.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
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

    it('Adapter can only spend max-gas + buffer', async () => {
        const gasBuffer = ethers.BigNumber.from('50000')
        const quoterGasLimit = await kyberElasticAdapter.quoterGasLimit()
        const dy = await kyberElasticAdapter.estimateGas.query(
            ethers.utils.parseUnits('1000000000', 6),
            usdceToken.address,
            wavaxToken.address
        )
        expect(dy).to.lt(quoterGasLimit.add(gasBuffer))
    })

    it('Gas-estimate is between max-gas-used and 110% max-gas-used', async () => {
        const options = [
            ['1', wavaxToken, usdceToken],
            ['1', wavaxToken, savaxToken],
        ]
        await adapterTestEnv.checkGasEstimateIsSensible(options)
    })
})