import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require('dotenv').config();
const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    m1: {
      url: `https://mevm.devnet.m1.movementlabs.xyz/v1`,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 336,
      gasPrice: "auto",
    },
  }
};

export default config;
