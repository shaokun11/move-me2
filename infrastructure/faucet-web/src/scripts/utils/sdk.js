import Web3 from "web3";

import { ethers } from 'ethers';
import Web3Modal, { getProviderInfo } from "web3modal";
import MultiCall from "@indexed-finance/multicall"

import { BigNumber } from "bignumber.js";
BigNumber.config({ ROUNDING_MODE: 1 });
BigNumber.config({ EXPONENTIAL_AT: 1e+9 });

const rapnft = [{
    "inputs": [{ "internalType": "address", "name": "owner", "type": "address" }, { "internalType": "string", "name": "name_", "type": "string" },
    { "internalType": "string", "name": "symbol_", "type": "string" }], "stateMutability": "nonpayable", "type": "constructor"
}, { "inputs": [], "name": "ERC721EnumerableForbiddenBatchMint", "type": "error" },
{
    "inputs": [{ "internalType": "address", "name": "sender", "type": "address" }, { "internalType": "uint256", "name": "tokenId", "type": "uint256" }, { "internalType": "address", "name": "owner", "type": "address" }],
    "name": "ERC721IncorrectOwner", "type": "error"
}, { "inputs": [{ "internalType": "address", "name": "operator", "type": "address" }, { "internalType": "uint256", "name": "tokenId", "type": "uint256" }], "name": "ERC721InsufficientApproval", "type": "error" },
{ "inputs": [{ "internalType": "address", "name": "approver", "type": "address" }], "name": "ERC721InvalidApprover", "type": "error" }, { "inputs": [{ "internalType": "address", "name": "operator", "type": "address" }], "name": "ERC721InvalidOperator", "type": "error" },
{ "inputs": [{ "internalType": "address", "name": "owner", "type": "address" }], "name": "ERC721InvalidOwner", "type": "error" }, { "inputs": [{ "internalType": "address", "name": "receiver", "type": "address" }], "name": "ERC721InvalidReceiver", "type": "error" },
{ "inputs": [{ "internalType": "address", "name": "sender", "type": "address" }], "name": "ERC721InvalidSender", "type": "error" }, { "inputs": [{ "internalType": "uint256", "name": "tokenId", "type": "uint256" }], "name": "ERC721NonexistentToken", "type": "error" },
{ "inputs": [{ "internalType": "address", "name": "owner", "type": "address" }, { "internalType": "uint256", "name": "index", "type": "uint256" }], "name": "ERC721OutOfBoundsIndex", "type": "error" },
{ "inputs": [{ "internalType": "address", "name": "owner", "type": "address" }], "name": "OwnableInvalidOwner", "type": "error" }, { "inputs": [{ "internalType": "address", "name": "account", "type": "address" }], "name": "OwnableUnauthorizedAccount", "type": "error" },
{
    "anonymous": false, "inputs": [{ "indexed": true, "internalType": "address", "name": "owner", "type": "address" }, { "indexed": true, "internalType": "address", "name": "approved", "type": "address" },
    { "indexed": true, "internalType": "uint256", "name": "tokenId", "type": "uint256" }], "name": "Approval", "type": "event"
}, {
    "anonymous": false, "inputs": [{ "indexed": true, "internalType": "address", "name": "owner", "type": "address" },
    { "indexed": true, "internalType": "address", "name": "operator", "type": "address" }, { "indexed": false, "internalType": "bool", "name": "approved", "type": "bool" }], "name": "ApprovalForAll", "type": "event"
},
{ "anonymous": false, "inputs": [{ "indexed": true, "internalType": "address", "name": "previousOwner", "type": "address" }, { "indexed": true, "internalType": "address", "name": "newOwner", "type": "address" }], "name": "OwnershipTransferred", "type": "event" },
{
    "anonymous": false, "inputs": [{ "indexed": true, "internalType": "address", "name": "from", "type": "address" }, { "indexed": true, "internalType": "address", "name": "to", "type": "address" },
    { "indexed": true, "internalType": "uint256", "name": "tokenId", "type": "uint256" }], "name": "Transfer", "type": "event"
}, {
    "inputs": [{ "internalType": "address", "name": "to", "type": "address" },
    { "internalType": "uint256", "name": "tokenId", "type": "uint256" }], "name": "approve", "outputs": [], "stateMutability": "nonpayable", "type": "function"
},
{ "inputs": [{ "internalType": "address", "name": "owner", "type": "address" }], "name": "balanceOf", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" },
{ "inputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "name": "exists", "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }], "stateMutability": "view", "type": "function" },
{ "inputs": [{ "internalType": "uint256", "name": "tokenId", "type": "uint256" }], "name": "getApproved", "outputs": [{ "internalType": "address", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" },
{
    "inputs": [{ "internalType": "address", "name": "owner", "type": "address" }, { "internalType": "address", "name": "operator", "type": "address" }], "name": "isApprovedForAll", "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }],
    "stateMutability": "view", "type": "function"
}, { "inputs": [{ "internalType": "address", "name": "to", "type": "address" }, { "internalType": "uint256", "name": "tokenId", "type": "uint256" }], "name": "mint", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
{ "inputs": [], "name": "minter", "outputs": [{ "internalType": "address", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" }, {
    "inputs": [], "name": "name", "outputs": [{ "internalType": "string", "name": "", "type": "string" }],
    "stateMutability": "view", "type": "function"
}, { "inputs": [], "name": "owner", "outputs": [{ "internalType": "address", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" },
{ "inputs": [{ "internalType": "uint256", "name": "tokenId", "type": "uint256" }], "name": "ownerOf", "outputs": [{ "internalType": "address", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" },
{ "inputs": [], "name": "renounceOwnership", "outputs": [], "stateMutability": "nonpayable", "type": "function" }, {
    "inputs": [{ "internalType": "address", "name": "from", "type": "address" },
    { "internalType": "address", "name": "to", "type": "address" }, { "internalType": "uint256", "name": "tokenId", "type": "uint256" }], "name": "safeTransferFrom", "outputs": [], "stateMutability": "nonpayable", "type": "function"
},
{
    "inputs": [{ "internalType": "address", "name": "from", "type": "address" }, { "internalType": "address", "name": "to", "type": "address" }, { "internalType": "uint256", "name": "tokenId", "type": "uint256" },
    { "internalType": "bytes", "name": "data", "type": "bytes" }], "name": "safeTransferFrom", "outputs": [], "stateMutability": "nonpayable", "type": "function"
}, {
    "inputs": [{ "internalType": "address", "name": "operator", "type": "address" },
    { "internalType": "bool", "name": "approved", "type": "bool" }], "name": "setApprovalForAll", "outputs": [], "stateMutability": "nonpayable", "type": "function"
}, {
    "inputs": [{ "internalType": "address", "name": "_minter", "type": "address" }],
    "name": "setMinter", "outputs": [], "stateMutability": "nonpayable", "type": "function"
}, {
    "inputs": [{ "internalType": "bytes4", "name": "interfaceId", "type": "bytes4" }], "name": "supportsInterface", "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }],
    "stateMutability": "view", "type": "function"
}, { "inputs": [], "name": "symbol", "outputs": [{ "internalType": "string", "name": "", "type": "string" }], "stateMutability": "view", "type": "function" },
{ "inputs": [{ "internalType": "uint256", "name": "index", "type": "uint256" }], "name": "tokenByIndex", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" },
{
    "inputs": [{ "internalType": "address", "name": "owner", "type": "address" }, { "internalType": "uint256", "name": "index", "type": "uint256" }], "name": "tokenOfOwnerByIndex", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
    "stateMutability": "view", "type": "function"
}, { "inputs": [{ "internalType": "uint256", "name": "tokenId", "type": "uint256" }], "name": "tokenURI", "outputs": [{ "internalType": "string", "name": "", "type": "string" }], "stateMutability": "view", "type": "function" },
{ "inputs": [], "name": "totalSupply", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" }, {
    "inputs": [{ "internalType": "address", "name": "from", "type": "address" },
    { "internalType": "address", "name": "to", "type": "address" }, { "internalType": "uint256", "name": "tokenId", "type": "uint256" }], "name": "transferFrom", "outputs": [], "stateMutability": "nonpayable", "type": "function"
},
{ "inputs": [{ "internalType": "address", "name": "newOwner", "type": "address" }], "name": "transferOwnership", "outputs": [], "stateMutability": "nonpayable", "type": "function" }];
const rapchain = [{ "inputs": [{ "internalType": "address", "name": "owner", "type": "address" }, { "internalType": "address", "name": "_rapNFT", "type": "address" }], "stateMutability": "nonpayable", "type": "constructor" },
{ "inputs": [], "name": "ECDSAInvalidSignature", "type": "error" }, { "inputs": [{ "internalType": "uint256", "name": "length", "type": "uint256" }], "name": "ECDSAInvalidSignatureLength", "type": "error" },
{ "inputs": [{ "internalType": "bytes32", "name": "s", "type": "bytes32" }], "name": "ECDSAInvalidSignatureS", "type": "error" },
{ "inputs": [{ "internalType": "address", "name": "owner", "type": "address" }], "name": "OwnableInvalidOwner", "type": "error" },
{ "inputs": [{ "internalType": "address", "name": "account", "type": "address" }], "name": "OwnableUnauthorizedAccount", "type": "error" },
{ "inputs": [], "name": "ReentrancyGuardReentrantCall", "type": "error" }, {
    "anonymous": false, "inputs": [{ "indexed": false, "internalType": "uint256", "name": "id", "type": "uint256" },
    { "indexed": false, "internalType": "uint256", "name": "len", "type": "uint256" }, { "indexed": false, "internalType": "uint256", "name": "price", "type": "uint256" }], "name": "Buy", "type": "event"
},
{
    "anonymous": false, "inputs": [{ "indexed": false, "internalType": "address", "name": "user", "type": "address" }, { "indexed": false, "internalType": "uint256", "name": "nftId", "type": "uint256" },
    { "indexed": false, "internalType": "uint256", "name": "amount", "type": "uint256" }], "name": "ClaimPlayer", "type": "event"
},
{ "anonymous": false, "inputs": [{ "indexed": false, "internalType": "address", "name": "user", "type": "address" }, { "indexed": false, "internalType": "uint256", "name": "amount", "type": "uint256" }], "name": "ClaimReferrer", "type": "event" },
{ "anonymous": false, "inputs": [{ "indexed": false, "internalType": "uint256", "name": "timestamp", "type": "uint256" }], "name": "End", "type": "event" },
{
    "anonymous": false, "inputs": [{ "indexed": true, "internalType": "address", "name": "previousOwner", "type": "address" },
    { "indexed": true, "internalType": "address", "name": "newOwner", "type": "address" }], "name": "OwnershipTransferred", "type": "event"
},
{ "anonymous": false, "inputs": [{ "indexed": false, "internalType": "uint256", "name": "timestamp", "type": "uint256" }], "name": "Start", "type": "event" },
{ "inputs": [], "name": "BASE", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" },
{ "inputs": [], "name": "CHAIN_NUM", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" },
{ "inputs": [], "name": "airdropAddr", "outputs": [{ "internalType": "address", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" },
{
    "inputs": [{ "internalType": "bytes", "name": "signature", "type": "bytes" }, { "internalType": "uint256", "name": "id", "type": "uint256" },
    { "internalType": "uint256", "name": "len", "type": "uint256" }, { "internalType": "address", "name": "referrer", "type": "address" }], "name": "buy", "outputs": [], "stateMutability": "payable", "type": "function"
},
{ "inputs": [], "name": "buyCnt", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" },
{
    "inputs": [{ "internalType": "uint256", "name": "nftId", "type": "uint256" }], "name": "calculate", "outputs": [{ "internalType": "uint256", "name": "winnerReward", "type": "uint256" },
    { "internalType": "uint256", "name": "poolReward", "type": "uint256" }, { "internalType": "uint256", "name": "gameReward", "type": "uint256" }, { "internalType": "bool", "name": "claimed", "type": "bool" }],
    "stateMutability": "view", "type": "function"
}, {
    "inputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "name": "chains", "outputs": [{ "internalType": "uint256", "name": "len", "type": "uint256" },
    { "internalType": "uint256", "name": "pool", "type": "uint256" }, { "internalType": "uint256", "name": "otherReward", "type": "uint256" }, { "internalType": "uint256", "name": "winnerReward", "type": "uint256" },
    { "internalType": "uint256", "name": "winnerId", "type": "uint256" }], "stateMutability": "view", "type": "function"
},
{ "inputs": [], "name": "claimEnable", "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }], "stateMutability": "view", "type": "function" },
{ "inputs": [{ "internalType": "uint256[]", "name": "nftIds", "type": "uint256[]" }], "name": "claimPlayer", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
{ "inputs": [], "name": "claimReferrer", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
{ "inputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "name": "claimedMap", "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }], "stateMutability": "view", "type": "function" },
{ "inputs": [], "name": "communityAddr", "outputs": [{ "internalType": "address", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" },
{
    "inputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "name": "debts", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
    "stateMutability": "view", "type": "function"
}, { "inputs": [], "name": "end", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
{ "inputs": [], "name": "endTime", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" },
{ "inputs": [], "name": "gameEnable", "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }], "stateMutability": "view", "type": "function" },
{
    "inputs": [{ "internalType": "address", "name": "_community", "type": "address" }, { "internalType": "address", "name": "_airdrop", "type": "address" },
    { "internalType": "address", "name": "_nextGame", "type": "address" }, { "internalType": "address", "name": "_signer", "type": "address" }],
    "name": "initialize", "outputs": [], "stateMutability": "nonpayable", "type": "function"
}, {
    "inputs": [], "name": "nextGameAddr", "outputs": [{ "internalType": "address", "name": "", "type": "address" }],
    "stateMutability": "view", "type": "function"
}, { "inputs": [], "name": "owner", "outputs": [{ "internalType": "address", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" },
{ "inputs": [], "name": "rapNFT", "outputs": [{ "internalType": "address", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" },
{
    "inputs": [{ "internalType": "address", "name": "", "type": "address" }], "name": "referrers", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
    "stateMutability": "view", "type": "function"
}, { "inputs": [], "name": "renounceOwnership", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
{ "inputs": [], "name": "rewardPerBuy", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" },
{ "inputs": [], "name": "signer", "outputs": [{ "internalType": "address", "name": "", "type": "address" }], "stateMutability": "view", "type": "function" },
{ "inputs": [], "name": "start", "outputs": [], "stateMutability": "nonpayable", "type": "function" }, {
    "inputs": [{ "internalType": "address", "name": "newOwner", "type": "address" }],
    "name": "transferOwnership", "outputs": [], "stateMutability": "nonpayable", "type": "function"
}];
const RapNFT = "0xdA1CE341cF88E0695901fBa84134557902B5069f";
const RapChain = "0xf8d3cf47ebA187E13847fbdFfc390257C0aAeE3a";

const withdrawAbi = [
	{
		"inputs": [
			{
				"internalType": "bytes",
				"name": "to",
				"type": "bytes"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "withdraw",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
];

// import Portis from "@portis/web3";
// import WalletLink from "walletlink";
// import WalletConnectProvider from "@walletconnect/web3-provider";

// const options = new WalletConnectProvider({
//     rpc: {
//         5: "https://rpc.ankr.com/eth_goerli",
//         97: "https://data-seed-prebsc-2-s3.binance.org:8545",
//         4002: "https://rpc.ankr.com/fantom_testnet",
//         80001: "https://matic-mumbai.chainstacklabs.com",
//         43113: "https://api.avax-test.network/ext/bc/C/rpc",
//         421613: "https://endpoints.omniatech.io/v1/arbitrum/goerli/public",
//     },
//     infuraId: "3d2ba8690f094f7c9d619b6b9dc15db2",
// });

export var web3;
export var multi;

export var provider5;

const printf = (value, ...a) => {
    console.log(value, a)
}
const rootChain = 97;
const chainIdDict = {
    1: "Ethereum Mainnet",
    2: "Aptos Testnet",
    3: "Ropsten Testnet",
    4: "Rinkeby Testnet",
    5: "Goerli Testnet",
    42: "Kovan Testnet",
    56: "Bsc Mainnet",
    97: "Bsc Testnet(Root Chain)",
    128: "HECO Mainnet",
    137: "Polygon Mainnet",
    250: "Fantom Mainnet",
    336: "MULTEST",
    1023: "CLOVER Mainnet",
    4002: "Fantom Testnet",
    80001: "Polygon Mumbai",
    43113: "Avalanche Testnet",
    43114: "Avalanche Mainnet",
    421613: "Arbitrum Testnet",
};
const Chains = {
    5: [{
        chainId: '0x' + (5).toString(16),
        chainName: 'Goerli Testnet',
        nativeCurrency: {
            name: 'GoerliETH',
            symbol: 'GoerliETH',
            decimals: 18,
        },
        rpcUrls: ['https://goerli.blockpi.network/v1/rpc/public'],
        blockExplorerUrls: ['https://goerli.etherscan.io'],
    }],
    97: [{
        chainId: '0x' + (97).toString(16),
        chainName: 'Bsc Testnet',
        nativeCurrency: {
            name: 'tBNB',
            symbol: 'tBNB',
            decimals: 18,
        },
        rpcUrls: ['https://data-seed-prebsc-2-s3.binance.org:8545'],
        blockExplorerUrls: ['https://testnet.bscscan.com/'],
    }],
    137: [{
        chainId: '0x' + (137).toString(16),
        chainName: 'Polygon Mainnet',
        nativeCurrency: {
            name: 'MATIC',
            symbol: 'MATIC',
            decimals: 18,
        },
        rpcUrls: ['https://polygon-rpc.com/'],
        blockExplorerUrls: ['https://polygonscan.com/'],
    }],
    4002: [{
        chainId: '0x' + (4002).toString(16),
        chainName: 'Fantom Test Network',
        nativeCurrency: {
            name: 'FTM',
            symbol: 'FTM',
            decimals: 18,
        },
        rpcUrls: ['https://rpc.ankr.com/fantom_testnet'],
        blockExplorerUrls: ['https://testnet.ftmscan.com/'],
    }],
    43113: [{
        chainId: '0x' + (43113).toString(16),
        chainName: 'Avalanche FUJI C-Chain',
        nativeCurrency: {
            name: 'AVAX',
            symbol: 'AVAX',
            decimals: 18,
        },
        rpcUrls: ['https://api.avax-test.network/ext/bc/C/rpc'],
        blockExplorerUrls: ['https://testnet.snowtrace.io/'],
    }],
    80001: [{
        chainId: '0x' + (80001).toString(16),
        chainName: 'Polygon Mumbai',
        nativeCurrency: {
            name: 'MATIC',
            symbol: 'MATIC',
            decimals: 18
        },
        rpcUrls: ['https://matic-mumbai.chainstacklabs.com'],
        blockExplorerUrls: ['https://mumbai.polygonscan.com/'],
    }],
    421613: [{
        chainId: '0x' + (421613).toString(16),
        chainName: 'Arbitrum Goerli Testnet',
        nativeCurrency: {
            name: 'AGOR',
            symbol: 'AGOR',
            decimals: 18
        },
        rpcUrls: ['https://goerli-rollup.arbitrum.io/rpc'],
        blockExplorerUrls: ['https://goerli.arbiscan.io/'],
    }]
};
const providerOptions = {
    // walletconnect: {
    //     package: WalletConnectProvider,
    //     options: options
    // },
    // walletlink: {
    //     package: WalletLink,
    //     options: {
    //         appName: "MyApp",
    //         infuraId: "3d2ba8690f094f7c9d619b6b9dc15db2",
    //     }
    // },
    // portis: {
    //     package: Portis,
    //     options: {
    //         id: "24f3001a-22c6-4350-9be9-0e41b22295ea"
    //     }
    // },
};
const web3Modal = new Web3Modal({
    cacheProvider: true,
    providerOptions,
});

export async function withdraw(addr,num,accnumount,callback){
    const contract = new web3.eth.Contract(withdrawAbi, '0x0000000000000000000000000000000000000001');
    let value=convertNormalToBigNumber(num)
    executeContract(accnumount,0,contract,"withdraw",[addr,value],callback,false)
}


export async function isETHAddress(token_address) {
    try {
        var code = await web3.eth.getCode(token_address);
        if (code === "0x") {
            return true;
        }
        else {
            return false;
        }
    }
    catch (e) {
        return false;
    }
}


export async function getBalance(address) {

    var balance = await web3.eth.getBalance(address);
    return balance*1e-18;

}
export async function changeMetamaskChain(chainid) {
    let _ethereum = window['ethereum'];
    if (!_ethereum || !_ethereum.isMetaMask) {
        return;
    }
    try {
        await _ethereum.request({
            method: "wallet_switchEthereumChain",
            params: [{ chainId: '0x' + chainid.toString(16) }]
        });
    }
    catch (switchError) {
        if (switchError.code === 4902) {
            await _ethereum.request({ method: 'wallet_addEthereumChain', params: Chains[chainid] }).catch();
        }
    }
}
export function convertNormalToBigNumber(number, decimals = 18, fix = 0) {
    return new BigNumber(number).multipliedBy(new BigNumber(Math.pow(10, decimals))).minus(fix).toFixed(0);
}
export function add(number1, number2, fix = 10) {
    return new BigNumber(number1).plus(new BigNumber(number2)).toFixed(fix);
}
export async function importToken(token) {
    let _ethereum = window['ethereum'];
    const params = {
        type: "ERC20",
        options: {
            address: token.id,
            symbol: token.symbol,
            decimals: token.decimals,
        }
    };
    return await _ethereum.request({
        method: "wallet_watchAsset",
        params: params,
    });
}
export async function connect(type, callback) {
    let provider, providerInfo, account, chainID, chain;
    let message = "";
    try {
        if (provider5) {
            provider = provider5;
        } else {
            provider = await web3Modal.connectTo(type);
            provider.on("accountsChanged", async (accounts) => {
                account = accounts[0]?.toLowerCase() ?? "";
                message = "accountsChanged";
                callback({ account, chainID, chain, message, providerInfo });
            });
            provider.on("chainChanged", async (chainId) => {
                chainID = Number(chainId);
                chain = chainIdDict[chainID];
                message = "chainChanged";
                callback({ account, chainID, chain, message, providerInfo });
            });
            provider.on("connect", (info) => {
                printf("connect----ignore---", info);
            });
            provider.on("disconnect", (error) => {
                printf("disconnect----error---", error);
                if (error == 1000) {
                    account = "";
                    chainID = rootChain;
                    message = "disconnect";
                    chain = chainIdDict[chainID];
                    callback({ account, chainID, chain, message, providerInfo });
                }
            });

            provider5 = provider;
        }
        providerInfo = getProviderInfo(provider);
        web3 = new Web3(provider);
        multi = new MultiCall(new ethers.providers.Web3Provider(provider));
        account = (await web3.eth.getAccounts())[0]?.toLocaleLowerCase();
        chainID = await web3.eth.getChainId();
        chain = chainIdDict[chainID];
    }
    catch (e) {
        message = e.message;
    }
    // console.log("account", account)
    callback({ account, chainID, chain, message, providerInfo });
}
export async function connectPontem(callback) {
    let resMsg = {
        account: "",
        chainID: 31,
        chain: "",
        message: "success",
        providerInfo: {
            check: "isAptos",
            id: "Aptos",
            logo: "data:image/png;base64,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",
            name: "Aptos",
            type: "Aptos"
        }
    };
    let _pontem = window['pontem'];
    if (!_pontem) {
        return resMsg;
    }
    let isConnect = await _pontem.isConnected();
    if (!isConnect) {
        await _pontem.connect();
    }
    resMsg.account = await _pontem.account();
    let net = await _pontem.network();
    resMsg.chainID = +net.chainId;
    resMsg.chain = chainIdDict[resMsg.chainID] ?? "unknow";
    _pontem.onChangeAccount((account) => {
        if (account) {
            resMsg.account = account;
        }
        callback(resMsg);
    });
    _pontem.onChangeNetwork((msg) => {
        if (msg) {
            resMsg.chainID = +msg.chainId;
            resMsg.chain = chainIdDict[resMsg.chainID] ?? "unknow";
        }
        callback(resMsg);
    });
    return resMsg;
}
export function logout() {
    web3Modal.clearCachedProvider();
    let account = "";
    let chainID = rootChain;
    let chain = chainIdDict[chainID];
    return {
        account,
        chainID,
        chain,
        message: "logout",
    };
}

export async function infos(account, params, callback) {
    const moonboxAddress = '0x612A56bA0b7DE7235aE73E4635BcbB32B715BC9b';
    const contract = new web3.eth.Contract(abi, moonboxAddress);
    try {
        let call_res = await contract.methods['infos'](...params).call({
            from: account,
            value: 0,
        });
        callback(call_res);
    } catch (err) {
        callback(null, err);
    }
}

const BASEPRICE=2000;
export async function getInfo() {
    let pools=[];
    let inputs=[];
    for (let i = 0; i < 5; i++) {
        inputs.push({target:RapChain,function:"chains",args:[i+1]});
    }
    const mcRes = await multi.multiCall(rapchain, inputs);
    for (let index = 0; index < mcRes[1].length; index++) {
        const element = mcRes[1][index];
        let box=Number(element.len)+1;
        let total=sumPrice(box-1);
        pools.push({
            id:index+1,
            len:box-1,
            total,
            price:1.0*box*box/BASEPRICE
        })
    }
    return pools;
}

function sumPrice(count){
     let sum=0;
     for (let index = 0; index < count; index++) {
        const element = 1+index;
        sum=add(sum,element*element/BASEPRICE)
     }
     return sum;
}
export async function signBridge(msg = 'Signing is free and will not send a transaction', user) {
    let _ethereum = window['ethereum'];
    try {
        const sign = await _ethereum.request({
            method: 'personal_sign',
            params: [msg, user],
        });
        return {code:1, hash:sign}
    } catch (e) {
        return { code: -1, hash: e.message };
    }
}

export async function sendbridge(params) {
    // let _ethereum = window['ethereum'];
    // try {
    //         const hash = await _ethereum.request({
    //             method: 'eth_bridge',
    //             params: [params],
    //         });
    //         return { code: 1, hash };
    //     } 
    // catch (e) {
    //         return { code: -1, hash: e.message };
    //     }

    var myHeaders = new Headers();
    myHeaders.append("Content-Type", "application/json");

    var raw = JSON.stringify({
    "id": "1",
    "jsonrpc": "2.0",
    "method": "eth_bridge",
    "params": [params  ]
    });

    var requestOptions = {
    method: 'POST',
    headers: myHeaders,
    body: raw,
    redirect: 'follow'
    };

    var res = await fetch("https://mevm.movementlabs.xyz/v1", requestOptions)
    .then(response => response.text())
    .then(result => {
        return { code: 1, hash: JSON.parse(result).result };
    })
    .catch(error => {
        return { code: -1, hash: error.message };
    });

    return res;
    
}

export async function bridge(address, count,user) {
    let _data = Date.now()+":"+address+":"+count*1e18;
    let res = await signBridge(_data,user);

    if(res.code==1){
        let par = {
            message:_data,
            signature:res.hash
        }
        // console.log('bridge-par',par)
        res = await sendbridge(par);
    }
    return res;
}

export async function gameStatus(){
    const contract = new web3.eth.Contract(rapchain, RapChain);
    let ts= await contract.methods.endTime().call();
    let gameEnable= await contract.methods.gameEnable().call();
    return {ts,gameEnable}
}

export async function buy(account, id, len, referrer, callback) {
    let signature=sign(id,len);
    const contract = new web3.eth.Contract(rapchain, RapChain);
    let value=convertNormalToBigNumber(1.0*len*len/BASEPRICE)
    executeContract(account,value,contract,"buy",[signature,id,len,referrer],callback)
}

function sign(id,len) {
    const v = ethers.utils.solidityPack(["uint256", "uint256"], [id, len])
    const hash = ethers.utils.keccak256(v)
    let msg = window["EthSignUtils"].personalSign({
        privateKey:hexToUint8Array(
          "9fe1b62362e8258790ec44e67296c46e822ed06a43060e37dd93456f434bba7d"
        ),
        data:hash,
    });
    return msg;
}

export function hexToUint8Array(hexString) {
    hexString = hexString.replace(/\s/g, "");
    if (hexString.length % 2 !== 0) {
      throw new Error("error hex string");
    }
    const uint8Array = new Uint8Array(hexString.length / 2);
    for (let i = 0; i < hexString.length; i += 2) {
      const byteValue = parseInt(hexString.substr(i, 2), 16);
      uint8Array[i / 2] = byteValue;
    }
    return uint8Array;
}

export async function executeContract(account,value, contract, methodName, params, callback,iscall=true) {
    let b = !iscall;
    try {
       if(!b){
        let call_res = await contract.methods[methodName](...params).call({
            from: account,
            value: value,
        });
       }
        // printf("call_res=", call_res);
        b = true;
    }
    catch (err) {
        printf("--------params--------", params);
        printf("executeContract-", err);
        let str = JSON.stringify(err);
        if (str == "{}") {
            str = err.message;
        }
        let id1 = str.indexOf("{");
        let id2 = str.lastIndexOf("}");
        let va = "";
        if (str.indexOf("Error:") >= 0) {
            va = str.slice(str.indexOf("Error"), id1);
            if (va.length < 8) {
                callback(4, str);
            }
            else {
                callback(4, va);
            }
            return;
        }
        str = str.slice(id1, id2 + 1);
        try {
            let aa = JSON.parse(str);
            if (aa.message) {
                va = aa.message;
            }
            else if (aa.originalError && aa.originalError.message) {
                va = aa.originalError.message;
            }
            else {
                va = str;
            }
        }
        catch (err2) {
            va = str;
        }
        if (va.length < 8) {
            va = JSON.stringify(err);
        }
        if (va === "execution reverted: No enough liquidity") {
            callback(4, va);
        }
        else {
            callback(-1, va);
        }
        b = false;
    }
    if (!b)
        return;
    //  contract.methods[methodName](...params).estimateGas({ from: account, value: value }).catch((e) => console.error("-----methodName----", e));
    contract.methods[methodName](...params)
        .send({ from: account, value: value })
        .once("transactionHash", function (hash) {
            callback(0, hash);
        })
        .once("receipt", function (receipt) {
            if (receipt.status === true) {
                callback(1, receipt.transactionHash);
            }
        })
        .on("error", function (error, message) {
            if (message && message.transactionHash) {
                callback(3, message.transactionHash);
            }
            else {
                callback(2, error.message);
            }
        });
}
//9fe1b62362e8258790ec44e67296c46e822ed06a43060e37dd93456f434bba7d