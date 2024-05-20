const { HexString, TxnBuilderTypes } = require('aptos');
const { createHash } = require('crypto');
function getAddress(pubKey) {
    pubKey = pubKey.replace('0x', '');
    let key = HexString.ensure(pubKey).toUint8Array();

    pubKey = new TxnBuilderTypes.Ed25519PublicKey(key);

    const authKey = TxnBuilderTypes.AuthenticationKey.fromEd25519PublicKey(pubKey);
    let keys = authKey.derivedAddress();
    return keys.hexString.slice(2);
}

function sleep(s) {
    return new Promise(r => setTimeout(r, s * 1000));
}

const encrypt = (algorithm, content) => {
    let hash = createHash(algorithm);
    hash.update(content);
    return hash.digest('hex');
};

const sha1 = content => encrypt('sha1', content);

module.exports = {
    sleep,
    getAddress,
    sha1,
};
