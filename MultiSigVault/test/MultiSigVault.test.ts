import { ethers } from "hardhat"
import { expect } from "chai"

import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { ContractFactory, Contract } from "ethers"
import "@nomiclabs/hardhat-ethers"
import web3 from "web3"

const SIGNER_ROLE = web3.utils.soliditySha3("SIGNER")
const DEFAULT_ADMIN_ROLE = "0x0000000000000000000000000000000000000000000000000000000000000000"
const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"
const DEPOSIT_VALUE = web3.utils.toWei("10000", "ether")
const TRANSACTION_VALUE = web3.utils.toWei("10", "ether")
const REST_VALUE = web3.utils.toWei("9990", "ether")

describe("Test MultiSigVault", function () {
    let owner: SignerWithAddress
    let signer_1: SignerWithAddress
    let signer_2: SignerWithAddress
    let other: SignerWithAddress
    let to: SignerWithAddress
    let multiSigVaultFactory: ContractFactory
    let multiSigVault: Contract
    let mockTokenFactory: ContractFactory
    let mockToken: Contract

    before(async function () {
        // Getting the users provided by ethers
        [owner, signer_1, signer_2, other, to] = await ethers.getSigners()

        // Getting the MultiSigVault contract code (abi, bytecode, name)
        multiSigVaultFactory = await ethers.getContractFactory("MultiSigVault")

        // Deploying the instance
        multiSigVault = await multiSigVaultFactory.deploy()
        await multiSigVault.deployed()

        // Getting the ERC20Mock contract code (abi, bytecode, name)
        mockTokenFactory = await ethers.getContractFactory("ERC20Mock")

        // Deploying the instance
        mockToken = await mockTokenFactory.deploy("MockToken", "MK")
        await mockToken.deployed()
    })

    it("check deployment", async function () {
    })

    describe("before token set", function () {
        it("revert get balance if token is not set", async function () {
            await expect(multiSigVault.balance()).to.be.revertedWith("token isn't set")
        })

        it("revert withdraw if token is not set", async function () {
            await expect(multiSigVault.emergencyWithdraw()).to.be.revertedWith("token isn't set")
        })
    })

    describe("check role", function () {
        before(async function () {
            await multiSigVault.grantRole(SIGNER_ROLE, signer_1.address)
        })

        it("deployer has default admin role", async function () {
            expect(await multiSigVault.hasRole(DEFAULT_ADMIN_ROLE, owner.address)).to.equal(true)
        })

        it("non-admin cannot grant role to other accounts", async function () {
            await expect(
                multiSigVault.connect(other).grantRole(SIGNER_ROLE, signer_1.address)
            ).to.be.revertedWith(
                `AccessControl: account ${other.address.toLowerCase()} is missing role ${DEFAULT_ADMIN_ROLE}`
            )
        })
    })

    describe("connect token", function () {
        it("admin can connect token", async function () {
            await multiSigVault.connectToOtherContracts([mockToken.address])
            expect(
                await multiSigVault.token()
            ).to.be.equal(mockToken.address)
        })

        it("non-admin cannot connect token", async function () {
            await expect(
                multiSigVault.connect(signer_1).connectToOtherContracts([mockToken.address])
            ).to.be.revertedWith(
                "Ownable: caller is not the owner"
            )
        })

        it("revert if the contract address is not set", async function () {
            await expect(
                multiSigVault.connectToOtherContracts([])
            ).to.be.revertedWith(
                "invalid contracts length"
            )
        })

        it("revert if the contract address is 0", async function () {
            await expect(
                multiSigVault.connectToOtherContracts([ZERO_ADDRESS])
            ).to.be.revertedWith(
                "invalid contract address"
            )
        })
    })

    describe("set signer limit and deposit token", function () {
        before(async function () {
            await multiSigVault.connectToOtherContracts([mockToken.address])
            await multiSigVault.grantRole(SIGNER_ROLE, signer_1.address)
            await multiSigVault.grantRole(SIGNER_ROLE, signer_2.address)
        })

        it("revert if limit is 0", async function () {
            await expect(
                multiSigVault.setSignerLimit(0)
            ).to.be.revertedWith("signer limit is 0")
        })

        it("revert if limit is greater than signers count", async function () {
            await expect(
                multiSigVault.setSignerLimit(3)
            ).to.be.revertedWith("signer limit is greater than member count")
        })

        it("set signer limit", async function () {
            await multiSigVault.setSignerLimit(2)
            expect(
                await multiSigVault.signerLimit()
            ).to.be.equal(2)
        })

        it("deposit token", async function () {
            await mockToken.transfer(multiSigVault.address, DEPOSIT_VALUE)
            expect(
                await multiSigVault.balance()
            ).to.be.equal(DEPOSIT_VALUE)
        })
    })

    describe("add transaction", function () {
        it("non-signers cannot add transaction", async function () {
            await expect(
                multiSigVault.connect(other).addTransaction(to.address, TRANSACTION_VALUE, 0)
            ).to.be.revertedWith(
                `AccessControl: account ${other.address.toLowerCase()} is missing role ${SIGNER_ROLE}`
            )
        })

        it("revert if to address is 0", async function () {
            await expect(
                multiSigVault.connect(signer_1).addTransaction(ZERO_ADDRESS, TRANSACTION_VALUE, 0)
            ).to.be.revertedWith(
                "invalid to address"
            )
        })

        it("revert if amount is 0", async function () {
            await expect(
                multiSigVault.connect(signer_1).addTransaction(to.address, 0, 0)
            ).to.be.revertedWith(
                "amount is 0"
            )
        })

        it("revert if unlock time is invalid", async function () {
            await expect(
                multiSigVault.connect(signer_1).addTransaction(to.address, TRANSACTION_VALUE, 10000000000)
            ).to.be.revertedWith(
                "Enter an unix timestamp in seconds, not miliseconds"
            )
        })

        it("signers can add transaction", async function () {
            await expect(
                multiSigVault.connect(signer_1).addTransaction(to.address, TRANSACTION_VALUE, 0)
            ).to.emit(multiSigVault, "TransactionCreated").withArgs(signer_1.address, to.address, TRANSACTION_VALUE, 0, 0)
        })
    })

    describe("sign transaction", function () {
        it("non-signers cannot sign transaction", async function () {
            await expect(
                multiSigVault.connect(other).signTransaction(0)
            ).to.be.revertedWith(
                `AccessControl: account ${other.address.toLowerCase()} is missing role ${SIGNER_ROLE}`
            )
        })

        it("revert if transaction is invalid", async function () {
            await expect(
                multiSigVault.connect(signer_2).signTransaction(1)
            ).to.be.revertedWith(
                "invalid transaction"
            )
        })

        it("signers can sign transaction", async function () {
            await expect(
                multiSigVault.connect(signer_2).signTransaction(0)
            ).to.emit(multiSigVault, "TransactionSigned").withArgs(signer_2.address, 0)
        })

        it("revert if transaction is already signed", async function () {
            await expect(
                multiSigVault.connect(signer_2).signTransaction(0)
            ).to.be.revertedWith(
                "already signed"
            )
        })
    })

    describe("reject transaction", function () {
        it("non-signers cannot reject transaction", async function () {
            await expect(
                multiSigVault.connect(other).rejectTransaction(0)
            ).to.be.revertedWith(
                `AccessControl: account ${other.address.toLowerCase()} is missing role ${SIGNER_ROLE}`
            )
        })

        it("revert if transaction is invalid", async function () {
            await expect(
                multiSigVault.connect(signer_2).rejectTransaction(1)
            ).to.be.revertedWith(
                "invalid transaction"
            )
        })

        it("signers can reject transaction", async function () {
            await expect(
                multiSigVault.connect(signer_2).rejectTransaction(0)
            ).to.emit(multiSigVault, "TransactionRejected").withArgs(signer_2.address, 0)
        })

        it("revert if transaction is already rejected", async function () {
            await expect(
                multiSigVault.connect(signer_2).rejectTransaction(0)
            ).to.be.revertedWith(
                "already rejected"
            )
        })
    })

    describe("execute transaction", function () {
        before(async function () {
            await multiSigVault.connect(signer_1).signTransaction(0)
        })

        it("non-signers cannot execute transaction", async function () {
            await expect(
                multiSigVault.connect(other).executeTransaction(0)
            ).to.be.revertedWith(
                `AccessControl: account ${other.address.toLowerCase()} is missing role ${SIGNER_ROLE}`
            )
        })

        it("revert if transaction is invalid", async function () {
            await expect(
                multiSigVault.connect(signer_2).executeTransaction(1)
            ).to.be.revertedWith(
                "invalid transaction"
            )
        })

        it("revert if don't have enough signatures", async function () {
            await expect(
                multiSigVault.connect(signer_2).executeTransaction(0)
            ).to.be.revertedWith(
                "you don't have enough signatures"
            )
        })

        it("signers can execute transaction", async function () {
            expect(
                await mockToken.balanceOf(to.address)
            ).to.be.equal(web3.utils.toWei("0", "ether"))
            await multiSigVault.connect(signer_2).signTransaction(0)
            await expect(
                multiSigVault.connect(signer_2).executeTransaction(0)
            ).to.emit(multiSigVault, "TransactionCompleted").withArgs(signer_2.address, to.address, TRANSACTION_VALUE, 0, 0)
            expect(
                await mockToken.balanceOf(to.address)
            ).to.be.equal(TRANSACTION_VALUE)
        })

        it("revert if transaction is already executed", async function () {
            await expect(
                multiSigVault.connect(signer_2).executeTransaction(0)
            ).to.be.revertedWith(
                "transaction already executed"
            )
        })
    })

    describe("withdraw", function () {
        it("non-admin cannot withdraw", async function () {
            await expect(
                multiSigVault.connect(other).emergencyWithdraw()
            ).to.be.revertedWith(
                'Ownable: caller is not the owner'
            )
        })

        it("admin can withdraw", async function () {
            expect(
                await multiSigVault.balance()
            ).to.be.equal(REST_VALUE)
            await expect(
                multiSigVault.emergencyWithdraw()
            ).to.emit(mockToken, "Transfer").withArgs(multiSigVault.address, owner.address, REST_VALUE)
            expect(
                await multiSigVault.balance()
            ).to.be.equal(0)
        })

        it("revert if balance is 0", async function () {
            await expect(
                multiSigVault.emergencyWithdraw()
            ).to.be.revertedWith('balance is 0')
        })
    })
})