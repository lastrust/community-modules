const { expect } = require("chai")
const { ethers } = require("hardhat")
const web3 = require("web3")
const { parseUnits, keccak256, toUtf8Bytes } = ethers.utils
const { usdcAddress, daiAddress, WMATICAddress, uniAddress, usdtAddress, SushiSwapFactoryAddress, UniswapV3FactoryAddress, UniswapV3QuoterAddress } = require('./config.js');
const helpers = require('./helpers')

const KECCAK256_MAINTAINER_ROLE = keccak256(toUtf8Bytes("MAINTAINER_ROLE"))
const KECCAK256_DEFAULT_ADMIN_ROLE = "0x0000000000000000000000000000000000000000000000000000000000000000"

describe("DexAggregator Test", function () {
    let owner, trader, nonOwner, feeClaimer, tester;
    let SushiSwapAdapter, UniswapV3Adapter, DexAggregator, BytesManipulation;
    let usdcToken, wmaticToken;

    before(async () => {
        [owner, trader, nonOwner, feeClaimer, tester] = await ethers.getSigners();

        // Deploy BytesManipulation
        const BytesManipulationContract = await hre.ethers.getContractFactory("BytesManipulation", {});
        BytesManipulation = await BytesManipulationContract.deploy();
        await BytesManipulation.deployed();

        // Deploy SushiSwapAdapter (UniswapV2Adapter Type)
        const SushiSwapAdapterContract = await hre.ethers.getContractFactory("UniswapV2Adapter", {});
        SushiSwapAdapter = await SushiSwapAdapterContract.deploy("SushiSwapAdapter", SushiSwapFactoryAddress, 3, 120000);
        await SushiSwapAdapter.deployed();

        // Deploy UniswapV3Adapter
        const UniswapV3AdapterContract = await hre.ethers.getContractFactory("UniswapV3Adapter", {});
        UniswapV3Adapter = await UniswapV3AdapterContract.deploy("UniswapV3Adapter", 170000, 170000, UniswapV3QuoterAddress, UniswapV3FactoryAddress)
        await UniswapV3Adapter.deployed();

        const DexAggregatorContract = await hre.ethers.getContractFactory("DexAggregator", {
            libraries: {
                BytesManipulation: BytesManipulation.address,
            }
        });
        const trustedTokens = [
            WMATICAddress,
            usdcAddress,
            daiAddress
        ];
        DexAggregator = await DexAggregatorContract.deploy(
            [SushiSwapAdapter.address, UniswapV3Adapter.address],
            trustedTokens,
            feeClaimer.address,
            WMATICAddress
        );
        await DexAggregator.deployed();

        usdcToken = await ethers.getContractAt("ERC20Mock", usdcAddress)
        wmaticToken = await ethers.getContractAt("IWETH", WMATICAddress)
    })

    it("check deployment", async function () {

    })

    describe("onlyMaintainer", function () {
        it("Allows the owner to call an onlyMaintainer function", async function () {
            await expect(DexAggregator.connect(owner).setFeeClaimer(feeClaimer.address)).to.not.reverted
        })

        it("Does not allow a non-maintainer to call an onlyMaintainer function", async function () {
            await expect(DexAggregator.connect(nonOwner).setFeeClaimer(feeClaimer.address)).to.be.revertedWith(
                "Maintainable: Caller is not a maintainer"
            )
        })

        it("Allows the owner to grant access to a new maintainer who can call an onlyMaintainer function", async function () {
            await DexAggregator.connect(owner).addMaintainer(nonOwner.address)
            await expect(DexAggregator.connect(nonOwner).setFeeClaimer(feeClaimer.address)).to.not.reverted
            await DexAggregator.connect(owner).removeMaintainer(nonOwner.address)
        })

        it("Does not allow a maintainer to call an onlyMaintainer function after the new owner has revoked their role", async function () {
            await DexAggregator.connect(owner).addMaintainer(nonOwner.address)
            await DexAggregator.connect(owner).removeMaintainer(nonOwner.address)
            await expect(DexAggregator.connect(nonOwner).setFeeClaimer(feeClaimer.address)).to.be.revertedWith(
                "Maintainable: Caller is not a maintainer"
            )
        })
    })

    describe("AccessControl", function () {
        describe("Adding a maintainer", function () {
            it("Allows the owner to add a new maintainer", async function () {
                await expect(DexAggregator.connect(owner).addMaintainer(nonOwner.address)).to.not.reverted;
                await DexAggregator.connect(owner).removeMaintainer(nonOwner.address)
            })

            it("Does not allow a maintainer to add a new maintainer", async () => {
                await DexAggregator.connect(owner).addMaintainer(nonOwner.address);
                await expect(DexAggregator.connect(nonOwner).addMaintainer(tester.address)).to.be.revertedWith(
                    `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
                await DexAggregator.connect(owner).removeMaintainer(nonOwner.address)
            });

            it("Does not allow a random user to add a new maintainer", async () => {
                await expect(DexAggregator.connect(nonOwner).addMaintainer(tester.address)).to.be.revertedWith(
                    `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
            });
        })

        describe("Removing a maintainer", () => {
            it("Allows the owner to remove a maintainer", async () => {
                await DexAggregator.connect(owner).addMaintainer(nonOwner.address);
                await expect(DexAggregator.connect(owner).removeMaintainer(nonOwner.address)).to.not.reverted;
            });

            it("Does not allow a maintainer to remove a maintainer", async () => {
                await DexAggregator.connect(owner).addMaintainer(nonOwner.address);
                await expect(DexAggregator.connect(nonOwner).removeMaintainer(tester.address)).to.be.revertedWith(
                    `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
                await DexAggregator.connect(owner).removeMaintainer(nonOwner.address)
            });

            it("Does not allow a random user to remove a maintainer", async () => {
                await DexAggregator.connect(owner).addMaintainer(nonOwner.address);
                await expect(DexAggregator.connect(tester).removeMaintainer(nonOwner.address)).to.be.revertedWith(
                    `AccessControl: account ${tester.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
                );
                await DexAggregator.connect(owner).removeMaintainer(nonOwner.address)
            });
        });
    })

    describe("Transfering ownership", () => {
        it("Allows the owner to transfer ownership", async () => {
            await expect(DexAggregator.connect(owner).transferOwnership(nonOwner.address)).to.not.reverted;
            await expect(DexAggregator.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });

        it("Does not allow the owner to add a maintainer after transfering ownership", async () => {
            await DexAggregator.connect(owner).transferOwnership(nonOwner.address);
            await expect(DexAggregator.connect(owner).addMaintainer(tester.address)).to.be.revertedWith(
                `AccessControl: account ${owner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
            );
            await expect(DexAggregator.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });

        it("Does not allow a maintainer to transfer ownership", async () => {
            DexAggregator.connect(owner).addMaintainer(nonOwner.address);
            await expect(DexAggregator.connect(nonOwner).transferOwnership(nonOwner.address)).to.be.revertedWith(
                `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
            );
            await DexAggregator.connect(owner).removeMaintainer(nonOwner.address)
        });

        it("Does not allow a random user to transfer ownership", async () => {
            await expect(DexAggregator.connect(nonOwner).transferOwnership(nonOwner.address)).to.be.revertedWith(
                `AccessControl: account ${nonOwner.address.toLowerCase()} is missing role ${KECCAK256_DEFAULT_ADMIN_ROLE}`
            );
        });
    });

    describe("Events", () => {
        it("Emits the expected event when the owner adds a maintainer", async () => {
            await expect(DexAggregator.connect(owner).addMaintainer(nonOwner.address))
                .to.emit(DexAggregator, "RoleGranted")
                .withArgs(KECCAK256_MAINTAINER_ROLE, nonOwner.address, owner.address);
            await DexAggregator.connect(owner).removeMaintainer(nonOwner.address)
        });

        it("Emits the expected event when the owner removes a maintainer", async () => {
            await DexAggregator.connect(owner).addMaintainer(nonOwner.address);
            await expect(DexAggregator.connect(owner).removeMaintainer(nonOwner.address))
                .to.emit(DexAggregator, "RoleRevoked")
                .withArgs(KECCAK256_MAINTAINER_ROLE, nonOwner.address, owner.address);
            await DexAggregator.connect(owner).removeMaintainer(nonOwner.address)
        });

        it("Emits the role granted event when the owner transfers ownership", async () => {
            await expect(DexAggregator.connect(owner).transferOwnership(nonOwner.address))
                .to.emit(DexAggregator, "RoleGranted")
                .withArgs(KECCAK256_DEFAULT_ADMIN_ROLE, nonOwner.address, owner.address);
            await expect(DexAggregator.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });

        it("Emits the role revoked event when the owner transfers ownership", async () => {
            await expect(DexAggregator.connect(owner).transferOwnership(nonOwner.address))
                .to.emit(DexAggregator, "RoleRevoked")
                .withArgs(KECCAK256_DEFAULT_ADMIN_ROLE, owner.address, owner.address);
            await expect(DexAggregator.connect(nonOwner).transferOwnership(owner.address)).to.not.reverted;
        });
    });

    describe("DexAggregator - query", function () {
        it("Return the best option for trade between adapters", async () => {
            let adapterCount = await DexAggregator.adaptersCount()
            let amountIn = parseUnits('10')
            let tokenIn = daiAddress
            let tokenOut = usdcAddress
            let options = []
            for (let i = 0; i < adapterCount; i++) {
                let result = await DexAggregator.queryAdapter(
                    amountIn,
                    tokenIn,
                    tokenOut,
                    i
                )
                options.push(result)
            }
            let bestOptionQuery = await DexAggregator['queryNoSplit(uint256,address,address)'](
                amountIn,
                tokenIn,
                tokenOut
            )
            // Check that number of options equals the number of adapters
            expect(await DexAggregator.adaptersCount()).to.equal(options.length)
            // Check that the most profitable option is returned as the best option
            let bestOptionCalc = options.sort((a, b) => b.gt(a) ? 1 : -1)[0]
            expect(bestOptionCalc).to.equal(bestOptionQuery[3])
        })

        it("Return the best path between two tokens that are directly connected", async () => {
            let amountIn = parseUnits('10')
            let tokenIn = daiAddress
            let tokenOut = usdcAddress
            let steps = 2
            let result = await DexAggregator.findBestPath(
                amountIn,
                tokenIn,
                tokenOut,
                steps
            )
            // Only one step (direct connection)
            expect(result.adapters.length).to.equal(1)
            // Path consists of from and to token
            expect(result.path[0]).to.equal(tokenIn)
            expect(result.path[result.path.length - 1]).to.equal(tokenOut)
            // First amount equals input amount
            expect(result.amounts[0]).to.equal(amountIn)
            // Amountout equals the query without split
            let bestOptionQuery = await DexAggregator['queryNoSplit(uint256,address,address)'](
                amountIn,
                tokenIn,
                tokenOut
            )
            expect(bestOptionQuery.amountOut).to.equal(result.amounts[1])
        })


        it('Return the best path between two tokens that are not directly connected (USDC -> USDT)', async () => {
            let amountIn = parseUnits('10')
            let tokenIn = usdcAddress
            let tokenOut = usdtAddress
            let steps = 2
            let result = await DexAggregator.findBestPath(
                amountIn,
                tokenIn,
                tokenOut,
                steps
            )
            // Expect to find a path 
            expect(result.amounts[result.amounts.length - 1]).to.gt('0')
            // Expect first token in the path to be token from
            expect(result.path[0]).to.equal(tokenIn)
            // Expect the last token in the path to be token to
            expect(result.path[result.path.length - 1]).to.equal(tokenOut)
        })

        it('Return the best path between two tokens that are not directly connected (UNI -> USDT)', async () => {
            let amountIn = parseUnits('10')
            let tokenIn = uniAddress
            let tokenOut = usdcAddress
            let steps = 2
            let result = await DexAggregator.findBestPath(
                amountIn,
                tokenIn,
                tokenOut,
                steps
            )
            // Expect to find a path 
            expect(result.amounts[result.amounts.length - 1]).to.gt('0')
            // Expect first token in the path to be token from
            expect(result.path[0]).to.equal(tokenIn)
            // Expect the last token in the path to be token to
            expect(result.path[result.path.length - 1]).to.equal(tokenOut)
        })

        it('Return the best path between two trusted tokens', async () => {
            let amountIn = parseUnits('10')
            let tokenIn = daiAddress
            let tokenOut = daiAddress
            let steps = 2
            let result = await DexAggregator.findBestPath(
                amountIn,
                tokenIn,
                tokenOut,
                steps
            )
            // Expect to find a path 
            expect(result.amounts[result.amounts.length - 1]).to.gt('0')
            // Expect first token in the path to be token from
            expect(result.path[0]).to.equal(tokenIn)
            // Expect the last token in the path to be token to
            expect(result.path[result.path.length - 1]).to.equal(tokenOut)
        })

        it('Return an empty array if no path is found between the tokens', async () => {
            let amountIn = parseUnits('10')
            let tokenIn = usdtAddress
            let tokenOut = DexAggregator.address  // Not a token
            let steps = 2
            let result = await DexAggregator.findBestPath(
                amountIn,
                tokenIn,
                tokenOut,
                steps
            )
            // Expect empty arrays
            expect(result.amounts).to.be.empty
            expect(result.adapters).to.be.empty
            expect(result.path).to.be.empty
        })

        it('Return the best path with 4 steps', async () => {
            let amountIn = parseUnits('10')
            let tokenIn = usdtAddress
            let tokenOut = uniAddress
            let steps = 4
            let result = await DexAggregator.findBestPath(
                amountIn,
                tokenIn,
                tokenOut,
                steps
            )
            // Expect to find a path 
            expect(result.amounts[result.amounts.length - 1]).to.gt('0')
            // Expect first token in the path to be token from
            expect(result.path[0]).to.equal(tokenIn)
            // Expect the last token in the path to be token to
            expect(result.path[result.path.length - 1]).to.equal(tokenOut)
        })

        it('Returning best path with gas should return gasEstimate', async () => {
            let amountIn = parseUnits('1')
            let tokenIn = usdtAddress
            let tokenOut = uniAddress
            let gasPrice = parseUnits('225', 'gwei')
            let steps = 3
            let result = await DexAggregator.findBestPathWithGas(
                amountIn,
                tokenIn,
                tokenOut,
                steps,
                gasPrice,
                { gasLimit: 1e9 }
            )
            // Expect to find a path 
            expect(result.amounts[result.amounts.length - 1]).to.gt('0')
            // Expect first token in the path to be token from
            expect(result.path[0]).to.equal(tokenIn)
            // Expect the last token in the path to be token to
            expect(result.path[result.path.length - 1]).to.equal(tokenOut)
            expect(result.gasEstimate).to.gt(ethers.constants.Zero)
        })
    })

    describe("DexAggregator - swap", function () {
        it("Router swap matched the query - multiple hops", async () => {
            // Call the query
            let tokenIn = WMATICAddress
            let tokenOut = usdtAddress
            let steps = 2
            let fee = '0'
            let amountIn = parseUnits('10')
            let result = await DexAggregator.findBestPath(
                amountIn,
                tokenIn,
                tokenOut,
                steps
            )
            // Top up trader with starting tokens
            await wmaticToken.connect(trader).deposit({ value: amountIn })
            // Approve for input token
            await helpers.approveERC20(trader, result.path[0], DexAggregator.address, ethers.constants.MaxUint256)
            // Do the swap
            await DexAggregator.connect(trader).swapNoSplit(
                [
                    result.amounts[0],
                    result.amounts[result.amounts.length - 1],
                    result.path,
                    result.adapters
                ],
                trader.address,
                fee
            )
            const outputTokenContract = await ethers.getContractAt("ERC20Mock", usdtAddress)
            expect(await outputTokenContract.balanceOf(trader.address)).to.equal(
                result.amounts[result.amounts.length - 1]
            )
        })

        it('User gets expected out-amount if conditions dont change', async () => {
            // Call the query
            let tokenIn = WMATICAddress
            let tokenOut = usdtAddress
            let steps = 2
            let fee = '0'
            let amountIn = parseUnits('10')

            // Query trade
            let result = await DexAggregator.findBestPath(
                amountIn,
                tokenIn,
                tokenOut,
                steps
            )

            let tokenOutBalBefore = await helpers.getERC20Balance(ethers.provider, tokenOut, trader.address)
            // Do the swap
            await DexAggregator.connect(trader).swapNoSplitFromETH(
                [
                    result.amounts[0],
                    result.amounts[result.amounts.length - 1],
                    result.path,
                    result.adapters
                ],
                trader.address,
                fee,
                { value: amountIn }
            )
            // Check the balance after
            let tokenOutBalAfter = await helpers.getERC20Balance(ethers.provider, tokenOut, trader.address)
            expect(tokenOutBalAfter - tokenOutBalBefore).to.equal(
                result.amounts[result.amounts.length - 1]
            )
        })

        it('Transactions reverts if expected out-amount is not within slippage', async () => {
            // Call the query
            let tokenIn = wmaticToken
            let tokenOut = usdcToken
            let amountIn = parseUnits('2000')
            let steps = 2
            let fee = '0'

            // Query trade
            let result = await DexAggregator.findBestPath(
                amountIn,
                tokenIn.address,
                tokenOut.address,
                steps
            )
            const adapters = [
                SushiSwapAdapter,
                UniswapV3Adapter
            ]
            let tradeAdapters = Object.values(adapters).filter(adapter => {
                return result.adapters.includes(adapter.address)
            })

            // Conditions change negatively (trade in between in the same direction)
            // (Use first adapter from the query to do the trade)
            let externalTrader = tester
            let firstAdapter = tradeAdapters[0]
            let amountInChange = parseUnits('2000')
            let traderTknBal1 = await tokenOut.balanceOf(externalTrader.address)
            await tokenIn.connect(externalTrader).deposit({ value: amountInChange })
            await tokenIn.connect(externalTrader).transfer(firstAdapter.address, amountInChange)
            const amountOut = await firstAdapter.query(amountInChange, tokenIn.address, tokenOut.address)
            await firstAdapter.connect(externalTrader).swap(
                amountInChange,
                amountOut,
                tokenIn.address,
                tokenOut.address,
                externalTrader.address
            )
            let traderTknBal2 = await tokenOut.balanceOf(externalTrader.address)
            expect(traderTknBal2).to.gt(traderTknBal1)
            // Do the swap
            await expect(DexAggregator.connect(trader).swapNoSplitFromETH(
                [
                    result.amounts[0],
                    result.amounts[result.amounts.length - 1],
                    result.path,
                    result.adapters
                ],
                trader.address,
                fee,
                { value: amountIn }
            )).to.reverted
        })

        it('User gets expected out-amount within slippage if conditions change negatively', async () => {
            // Call the query
            let tokenIn = wmaticToken
            let tokenOut = usdcToken
            let slippageDenominator = parseUnits('1', 5)
            let slippage = parseUnits('0.01', 5)
            let amountIn = parseUnits('10')
            let steps = 2
            let fee = '0'

            // Query trade
            let result = await DexAggregator.findBestPath(
                amountIn,
                tokenIn.address,
                tokenOut.address,
                steps
            )
            const adapters = [
                SushiSwapAdapter,
                UniswapV3Adapter
            ]
            let tradeAdapters = result.adapters.map(rAdapter => {
                return Object.values(adapters).find(a => a.address == rAdapter)
            })
            // Conditions change negatively (trade in between in the same direction)
            // (Use first adapter from the query to do the trade)
            let externalTrader = tester
            let firstAdapter = tradeAdapters[0]
            let amountInChange = parseUnits('1')
            let tokenInChange = tokenIn
            let tokenOutChange = await ethers.getContractAt("IWETH", result.path[1])

            let changeTknBal1 = await tokenOutChange.balanceOf(externalTrader.address)
            await tokenInChange.connect(externalTrader).deposit({ value: amountInChange })
            await tokenInChange.connect(externalTrader).transfer(firstAdapter.address, amountInChange)
            const amountOut = await firstAdapter.query(amountInChange, tokenInChange.address, tokenOutChange.address)
            await firstAdapter.connect(externalTrader).swap(
                amountInChange,
                amountOut,
                tokenInChange.address,
                tokenOutChange.address,
                externalTrader.address
            )
            let changeTknBal2 = await tokenOutChange.balanceOf(externalTrader.address)
            expect(changeTknBal2).to.gt(changeTknBal1)
            // Do the swap
            const minAmountOut = result.amounts[result.amounts.length - 1].mul(slippageDenominator.sub(slippage)).div(slippageDenominator)
            await DexAggregator.connect(trader).swapNoSplitFromETH(
                [
                    result.amounts[0],
                    minAmountOut,
                    result.path,
                    result.adapters
                ],
                trader.address,
                fee,
                { value: amountIn }
            )
            // Check the balance after
            let traderTknBal3 = await tokenOut.balanceOf(trader.address)
            expect(traderTknBal3).to.gt(
                minAmountOut
            )
        })

        it('Optional fee goes to the claimer', async () => {
            const _amountIn = parseUnits('10')
            const _amountOut = '0'
            const _fee = parseUnits('0.03', 4)
            const _feeDenominator = parseUnits('1', 4)
            const _path = [
                wmaticToken,
                usdcToken
            ]
            const _adapters = [SushiSwapAdapter.address]
            const feeClaimer = await DexAggregator.FEE_CLAIMER()
            await DexAggregator.connect(trader).swapNoSplitFromETH(
                [
                    _amountIn,
                    _amountOut,
                    _path.map(t => t.address),
                    _adapters
                ],
                trader.address,
                _fee,
                { value: _amountIn }
            )
            const claimerBalAfter = await _path[0].balanceOf(feeClaimer)
            const expectedFeeAmount = _amountIn.mul(_fee).div(_feeDenominator)
            expect(claimerBalAfter).to.equal(expectedFeeAmount)
        })
    })
})