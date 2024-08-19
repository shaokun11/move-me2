export default function (txPool) {
    console.log('tx worker txPool', txPool);
    const allTx = [];
    Object.values(txPool).forEach(txArr => {
        allTx.push(...txArr);
    });
    allTx.sort((a, b) => {
        if (a.ts !== b.ts) {
            return a.ts - b.ts;
        } else {
            return a.nonce - b.nonce;
        }
    });
    return allTx;
}
