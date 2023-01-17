import * as dotenv from "dotenv";

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

dotenv.config();

declare global {
  namespace NodeJS {
    interface ProcessEnv {
      GOERLI_INFURA_API_KEY: string;
      MAINNET_INFURA_API_KEY: string;

      TESTNET_PRIVATE_KEY: string;
      MAINNET_PRIVATE_KEY: string;
      
      ETHERSCAN_API_KEY: string;
    }
  }
}

const config: HardhatUserConfig = {
  solidity: "0.8.9",
  networks: {
    goerli: {
      url: `https://goerli.infura.io/v3/${process.env.GOERLI_INFURA_API_KEY}`,
      accounts: [process.env.TESTNET_PRIVATE_KEY],
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.MAINNET_INFURA_API_KEY}`,
      accounts: [process.env.MAINNET_PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      goerli: process.env.ETHERSCAN_API_KEY,
      mainnet: process.env.ETHERSCAN_API_KEY,
    },
  },
};

export default config;
