import { ethers } from 'hardhat'
import { expect } from 'chai'
import web3 from 'web3'

import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { ContractFactory, Contract } from 'ethers'
import '@nomiclabs/hardhat-ethers'

describe('Test Base64Wrapper', function () {
    let owner: SignerWithAddress
    let base64WrapperFactory: ContractFactory
    let base64Wrapper: Contract

    before(async function () {
        // Getting the users provided by ethers
        [owner] = await ethers.getSigners()

        // Getting the Base64Wrapper contract code (abi, bytecode, name)
        base64WrapperFactory = await ethers.getContractFactory('Base64Wrapper')

        // Deploying the instance
        base64Wrapper = await base64WrapperFactory.deploy()
        await base64Wrapper.deployed()
    })

    it('check deployment', async function () {
    })

    it('empty bytes', async function () {
        expect(await base64Wrapper.encode([])).to.equal('')
    })

    it('convert to base64 encoded short strings', async function () {
        expect(await base64Wrapper.encode(web3.utils.asciiToHex('M'))).to.equal('TQ==')
        expect(await base64Wrapper.encode(web3.utils.asciiToHex('Mi'))).to.equal('TWk=')
        expect(await base64Wrapper.encode(web3.utils.asciiToHex('Mil'))).to.equal('TWls')
        expect(await base64Wrapper.encode(web3.utils.asciiToHex('Mila'))).to.equal('TWlsYQ==')
        expect(await base64Wrapper.encode(web3.utils.asciiToHex('Milad'))).to.equal('TWlsYWQ=')
        expect(await base64Wrapper.encode(web3.utils.asciiToHex('Milady'))).to.equal('TWlsYWR5')
    })

    it('converts to base64 encoded string with double padding', async function () {
        const TEST_MESSAGE = 'test'
        const input = web3.utils.asciiToHex(TEST_MESSAGE)
        expect(await base64Wrapper.encode(input)).to.equal('dGVzdA==')
    })

    it('converts to base64 encoded string with single padding', async function () {
        const TEST_MESSAGE = 'test1'
        const input = web3.utils.asciiToHex(TEST_MESSAGE)
        expect(await base64Wrapper.encode(input)).to.equal('dGVzdDE=')
    })

    it('converts to base64 encoded string without padding', async function () {
        const TEST_MESSAGE = 'test12'
        const input = web3.utils.asciiToHex(TEST_MESSAGE)
        expect(await base64Wrapper.encode(input)).to.equal('dGVzdDEy')
    })

    it('converts to base64 encoded sentence', async function () {
        const TEST_MESSAGE = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
        const input = web3.utils.asciiToHex(TEST_MESSAGE)
        expect(await base64Wrapper.encode(input)).to.equal('TG9yZW0gaXBzdW0gZG9sb3Igc2l0IGFtZXQsIGNvbnNlY3RldHVyIGFkaXBpc2NpbmcgZWxpdC4=')
    })

    it('converts to base64 encoded word boundary', async function () {
        expect(await base64Wrapper.encode(web3.utils.asciiToHex('012345678901234567890'))).to.equal('MDEyMzQ1Njc4OTAxMjM0NTY3ODkw')
        expect(await base64Wrapper.encode(web3.utils.asciiToHex('0123456789012345678901'))).to.equal('MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMQ==')
        expect(await base64Wrapper.encode(web3.utils.asciiToHex('01234567890123456789012'))).to.equal('MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI=')
        expect(await base64Wrapper.encode(web3.utils.asciiToHex('012345678901234567890123'))).to.equal('MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIz')
        expect(await base64Wrapper.encode(web3.utils.asciiToHex('0123456789012345678901234'))).to.equal('MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNA==')
    })

    it('convert to base64 decoded short strings', async function () {
        expect(await base64Wrapper.decode('TQ==')).to.equal(web3.utils.asciiToHex('M'))
        expect(await base64Wrapper.decode('TWk=')).to.equal(web3.utils.asciiToHex('Mi'))
        expect(await base64Wrapper.decode('TWls')).to.equal(web3.utils.asciiToHex('Mil'))
        expect(await base64Wrapper.decode('TWlsYQ==')).to.equal(web3.utils.asciiToHex('Mila'))
        expect(await base64Wrapper.decode('TWlsYWQ=')).to.equal(web3.utils.asciiToHex('Milad'))
        expect(await base64Wrapper.decode('TWlsYWR5')).to.equal(web3.utils.asciiToHex('Milady'))
    })

    it('converts to base64 decoded string with double padding', async function () {
        const TEST_MESSAGE = 'test'
        const input = web3.utils.asciiToHex(TEST_MESSAGE)
        expect(await base64Wrapper.decode('dGVzdA==')).to.equal(input)
    })

    it('converts to base64 decoded string with single padding', async function () {
        const TEST_MESSAGE = 'test1'
        const input = web3.utils.asciiToHex(TEST_MESSAGE)
        expect(await base64Wrapper.decode('dGVzdDE=')).to.equal(input)
    })

    it('converts to base64 decoded string without padding', async function () {
        const TEST_MESSAGE = 'test12'
        const input = web3.utils.asciiToHex(TEST_MESSAGE)
        expect(await base64Wrapper.decode('dGVzdDEy')).to.equal(input)
    })

    it('converts to base64 decoded sentence', async function () {
        const TEST_MESSAGE = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
        const input = web3.utils.asciiToHex(TEST_MESSAGE)
        expect(await base64Wrapper.decode('TG9yZW0gaXBzdW0gZG9sb3Igc2l0IGFtZXQsIGNvbnNlY3RldHVyIGFkaXBpc2NpbmcgZWxpdC4=')).to.equal(input)
    })

    it('converts to base64 decoded word boundary', async function () {
        expect(await base64Wrapper.decode('MDEyMzQ1Njc4OTAxMjM0NTY3ODkw')).to.equal(web3.utils.asciiToHex('012345678901234567890'))
        expect(await base64Wrapper.decode('MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMQ==')).to.equal(web3.utils.asciiToHex('0123456789012345678901'))
        expect(await base64Wrapper.decode('MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI=')).to.equal(web3.utils.asciiToHex('01234567890123456789012'))
        expect(await base64Wrapper.decode('MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIz')).to.equal(web3.utils.asciiToHex('012345678901234567890123'))
        expect(await base64Wrapper.decode('MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNA==')).to.equal(web3.utils.asciiToHex('0123456789012345678901234'))
    })
})