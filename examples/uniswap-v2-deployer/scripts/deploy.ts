import { MaxUint256, WeiPerEther } from "ethers";
import { Signer, ContractFactory, ZeroAddress } from "ethers";
import { ethers } from "hardhat";
import UniswapV2FactoryJson from "../contracts/abi/UniswapV2Factory.json"
import UniswapV2Router02Json from "../contracts/abi/UniswapV2Router02.json"
import WETH9Json from "../contracts/abi/WETH9.json";

async function deployContract(
    abi: any,
    bytecode: string,
    deployParams: Array<any>,
    _signer: Signer
) {
    const factory = new ContractFactory(abi, bytecode, _signer);
    return factory.deploy(...deployParams);
}

async function main() {
    const [deployer] = await ethers.getSigners();
    const factory = (await deployContract(
        UniswapV2FactoryJson.abi,
        UniswapV2FactoryJson.bytecode,
        [ZeroAddress],
        deployer
    ))
    const weth9 = (await deployContract(
        WETH9Json.abi,
        WETH9Json.bytecode,
        [],
        deployer
    ))
    const router = (await deployContract(
        UniswapV2Router02Json.abi,
        UniswapV2Router02Json.bytecode,
        [factory.target, weth9.target],
        deployer
    ))
    const token0 = await ethers.deployContract("Token", ["USDT", "USDT"]);
    const token1 = await ethers.deployContract("Token", ["USDC", "USDC"]);
    const call = await ethers.deployContract("Multicall");
    await token0.waitForDeployment()
    await token1.waitForDeployment()
    await call.waitForDeployment()

    await (await token0.mint(deployer.address, 100000000n * WeiPerEther)).wait()
    await (await token1.mint(deployer.address, 100000000n * WeiPerEther)).wait()

    await (await token0.approve(router.target, MaxUint256)).wait();
    await (await token1.approve(router.target, MaxUint256)).wait();
    //@ts-ignore
    await (await router.addLiquidity(
        token0.target,
        token1.target,
        1000n * WeiPerEther,
        1000n * WeiPerEther,
        1,
        1,
        deployer.address,
        MaxUint256,
    )).wait();
    //@ts-ignore
    let pair = await factory.getPair(token0.target, token1.target);
    console.log({
        router: router.target,
        factory: factory.target,
        weth9: weth9.target,
        USDT: token0.target,
        USDC: token1.target,
        call: call.target,
        pair,
        deployer: deployer.address
    })

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
