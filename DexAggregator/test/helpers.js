const { ethers } = require("hardhat")

module.exports.approveERC20 = (signer, token, spender, amount) => {
    return signer.sendTransaction({
        to: token,
        data: `0x095ea7b3${spender.slice(2).padStart(64, '0')}${amount.toHexString().slice(2).padStart(64, '0')}`
    })
}

module.exports.getERC20Balance = (provider, token, holder) => {
    return provider.call({
        to: token,
        data: `0x70a08231${holder.slice(2).padStart(64, '0')}`
    }).then(ethers.BigNumber.from)
} 