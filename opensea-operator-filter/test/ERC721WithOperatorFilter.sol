import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { BigNumber } from "ethers";

import {
  ERC721WithOperatorFilterer,
  ERC721WithOperatorFilterer__factory

} from "../typechain-types";


describe("ERC721WithOperatorFilter", function () {
  let owner: SignerWithAddress;
  let nftUser1: SignerWithAddress;
  let nftUser2: SignerWithAddress;
  let nftUser3: SignerWithAddress;
  let nftUser4: SignerWithAddress;
  let nftUser5: SignerWithAddress;

  let erc721WithOperatorFilterer: ERC721WithOperatorFilterer;

  before(async function () {
    [owner, nftUser1, nftUser2, nftUser3, nftUser4] = await ethers.getSigners();

    const erc721WithOperatorFilterFactory = new ERC721WithOperatorFilterer__factory(owner)

    erc721WithOperatorFilterer = await erc721WithOperatorFilterFactory.deploy("Test NFT token", "NFT");

  })
});