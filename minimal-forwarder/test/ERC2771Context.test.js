const ethSigUtil = require("eth-sig-util");
const Wallet = require("ethereumjs-wallet").default;

const { BN, expectEvent } = require("@openzeppelin/test-helpers");
const { expect } = require("chai");

const ERC2771ContextMock = artifacts.require("ERC2771ContextMock");
const MinimalForwarder = artifacts.require("MinimalForwarder");
const ContextMock = artifacts.require("ContextMock");
const ContextMockCaller = artifacts.require("ContextMockCaller");

const name = "MinimalForwarder";
const version = "0.0.1";

const EIP712Domain = [
  { name: "name", type: "string" },
  { name: "version", type: "string" },
  { name: "chainId", type: "uint256" },
  { name: "verifyingContract", type: "address" },
];

const Permit = [
  { name: "owner", type: "address" },
  { name: "spender", type: "address" },
  { name: "value", type: "uint256" },
  { name: "nonce", type: "uint256" },
  { name: "deadline", type: "uint256" },
];

async function domainSeparator(name, version, chainId, verifyingContract) {
  return (
    "0x" +
    ethSigUtil.TypedDataUtils.hashStruct(
      "EIP712Domain",
      { name, version, chainId, verifyingContract },
      { EIP712Domain }
    ).toString("hex")
  );
}

function shouldBehaveLikeRegularContext(sender) {
  describe("msgSender", function () {
    it("returns the transaction sender when called from an EOA", async function () {
      const receipt = await this.context.msgSender({ from: sender });
      expectEvent(receipt, "Sender", { sender });
    });

    it("returns the transaction sender when from another contract", async function () {
      const { tx } = await this.caller.callSender(this.context.address, {
        from: sender,
      });
      await expectEvent.inTransaction(tx, ContextMock, "Sender", {
        sender: this.caller.address,
      });
    });
  });

  describe("msgData", function () {
    const integerValue = new BN("42");
    const stringValue = "OpenZeppelin";

    let callData;

    beforeEach(async function () {
      callData = this.context.contract.methods
        .msgData(integerValue.toString(), stringValue)
        .encodeABI();
    });

    it("returns the transaction data when called from an EOA", async function () {
      const receipt = await this.context.msgData(integerValue, stringValue);
      expectEvent(receipt, "Data", {
        data: callData,
        integerValue,
        stringValue,
      });
    });

    it("returns the transaction sender when from another contract", async function () {
      const { tx } = await this.caller.callData(
        this.context.address,
        integerValue,
        stringValue
      );
      await expectEvent.inTransaction(tx, ContextMock, "Data", {
        data: callData,
        integerValue,
        stringValue,
      });
    });
  });
}

contract("ERC2771Context", function (accounts) {
  beforeEach(async function () {
    this.forwarder = await MinimalForwarder.new(name, version);
    this.recipient = await ERC2771ContextMock.new(this.forwarder.address);

    this.domain = {
      name,
      version,
      chainId: await web3.eth.getChainId(),
      verifyingContract: this.forwarder.address,
    };
    this.types = {
      EIP712Domain,
      ForwardRequest: [
        { name: "from", type: "address" },
        { name: "to", type: "address" },
        { name: "value", type: "uint256" },
        { name: "gas", type: "uint256" },
        { name: "nonce", type: "uint256" },
        { name: "data", type: "bytes" },
      ],
    };
  });

  it("recognize trusted forwarder", async function () {
    expect(await this.recipient.isTrustedForwarder(this.forwarder.address));
  });

  context("when called directly", function () {
    beforeEach(async function () {
      this.context = this.recipient; // The Context behavior expects the contract in this.context
      this.caller = await ContextMockCaller.new();
    });

    shouldBehaveLikeRegularContext(...accounts);
  });

  context("when receiving a relayed call", function () {
    beforeEach(async function () {
      this.wallet = Wallet.generate();
      this.sender = web3.utils.toChecksumAddress(
        this.wallet.getAddressString()
      );
      this.data = {
        types: this.types,
        domain: this.domain,
        primaryType: "ForwardRequest",
      };
    });

    describe("msgSender", function () {
      it("returns the relayed transaction original sender", async function () {
        const data = this.recipient.contract.methods.msgSender().encodeABI();

        const req = {
          from: this.sender,
          to: this.recipient.address,
          value: "0",
          gas: "100000",
          nonce: (await this.forwarder.getNonce(this.sender)).toString(),
          data,
        };

        const sign = ethSigUtil.signTypedMessage(this.wallet.getPrivateKey(), {
          data: { ...this.data, message: req },
        });
        expect(await this.forwarder.verify(req, sign)).to.equal(true);

        const { tx } = await this.forwarder.execute(req, sign);
        await expectEvent.inTransaction(tx, ERC2771ContextMock, "Sender", {
          sender: this.sender,
        });
      });
    });

    describe("msgData", function () {
      it("returns the relayed transaction original data", async function () {
        const integerValue = "42";
        const stringValue = "OpenZeppelin";
        const data = this.recipient.contract.methods
          .msgData(integerValue, stringValue)
          .encodeABI();

        const req = {
          from: this.sender,
          to: this.recipient.address,
          value: "0",
          gas: "100000",
          nonce: (await this.forwarder.getNonce(this.sender)).toString(),
          data,
        };

        const sign = ethSigUtil.signTypedMessage(this.wallet.getPrivateKey(), {
          data: { ...this.data, message: req },
        });
        expect(await this.forwarder.verify(req, sign)).to.equal(true);

        const { tx } = await this.forwarder.execute(req, sign);
        await expectEvent.inTransaction(tx, ERC2771ContextMock, "Data", {
          data,
          integerValue,
          stringValue,
        });
      });
    });
  });
});
