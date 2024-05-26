import { AptosAccount } from 'aptos';
export const SERVER_PORT = process.env.SERVER_PORT || 3001;
export const FAUCET_AMOUNT = process.env.FAUCET_AMOUNT || 1;
export const FAUCET_LIMIT_DURATION = process.env.FAUCET_LIMIT_DURATION || 1;
export const NODE_URL = process.env.NODE_URL
export const FAUCET_NODE_URL = process.env.FAUCET_NODE_URL
export const FAUCET_SENDER = process.env.FAUCET_SENDER
export const RECAPTCHA_SECRET = process.env.RECAPTCHA_SECRET

export const FAUCET_SENDER_ACCOUNT = AptosAccount.fromAptosAccountObject({
    privateKeyHex: FAUCET_SENDER,
});




