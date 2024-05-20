const URL = process.env.URL;
const PORT = process.env.PORT || 3001;
const FAUCET_SENDER = process.env.FAUCET_SENDER;
const RECAPTCHA_SECRET = process.env.RECAPTCHA_SECRET;
module.exports = {
    URL,
    PORT,
    RECAPTCHA_SECRET,
    FAUCET_SENDER,
};
