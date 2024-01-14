import {Pair, Token, TokenAmount, WETH} from "@uniswap/sdk";
import {keccak256, pack} from '@ethersproject/solidity'
import {getCreate2Address} from '@ethersproject/address'

export const G_CONFIG :any= {
    router: process.env.REACT_APP_ROUTER,
    weth: process.env.REACT_APP_WETH,
    factory: process.env.REACT_APP_FACTORY,
    call: process.env.REACT_APP_CALL,
    codeHash: "0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f",
    tokens: [
        {
            decimals: 18,
            symbol: 'USDC',
            name: 'USDC',
            chainId: 336,
            address: process.env.REACT_APP_USDC,
            logoURI: 'https://raw.githubusercontent.com/compound-finance/token-list/master/assets/ctoken_usdc.svg'
        },
        {
            decimals: 18,
            symbol: 'USDT',
            name: 'USDT',
            chainId: 336,
            address: process.env.REACT_APP_USDT,
            logoURI: 'https://raw.githubusercontent.com/compound-finance/token-list/master/assets/asset_USDT.svg'
        }
    ]
}

const computePairAddress = ({
                                factoryAddress,
                                tokenA,
                                tokenB
                            }: {
    factoryAddress: string
    tokenA: Token
    tokenB: Token
}): string => {
    const [token0, token1] = tokenA.sortsBefore(tokenB) ? [tokenA, tokenB] : [tokenB, tokenA] // does safety checks
    return getCreate2Address(
        factoryAddress,
        keccak256(['bytes'], [pack(['address', 'address'], [token0.address, token1.address])]),
        G_CONFIG.codeHash
    )
}

export class MyPair extends Pair {
    constructor(tokenAmountA: TokenAmount, tokenAmountB: TokenAmount) {
        super(tokenAmountA, tokenAmountB)
        const tokenAmounts = tokenAmountA.token.sortsBefore(tokenAmountB.token) // does safety checks
            ? [tokenAmountA, tokenAmountB] : [tokenAmountB, tokenAmountA];
        // eslint-disable-next-line @typescript-eslint/ban-ts-ignore
        // @ts-ignore
        this.liquidityToken = new Token(tokenAmounts[0].token.chainId, MyPair.getAddress(tokenAmounts[0].token, tokenAmounts[1].token), 18, 'UNI-V2', 'Uniswap V2');
        // eslint-disable-next-line @typescript-eslint/ban-ts-ignore
        // @ts-ignore
        this["tokenAmounts"] = tokenAmounts;
    }

    public static getAddress(tokenA: Token, tokenB: Token): string {
        const pair = computePairAddress({
            tokenA,
            tokenB,
            factoryAddress: G_CONFIG.factory
        })
        console.log("-----pair-----", pair)
        return pair
    }

}

export const GWETH = {
    ...WETH,
    336: G_CONFIG.weth
}
