const { ethers } = require("ethers");

const main = () => {
    const funcSig = '0x1626ba7e'
    const MAGIC = ethers.solidityPackedKeccak256(["string"], ["CHALLENGE_MAGIC"]);
    let count = 0;
    let r = Number(Date.now());
    while (true) {
        r = r + 1;
        const randomSignature = ethers.toBeHex(r.toString())
        const hash = ethers.sha256(ethers.AbiCoder.defaultAbiCoder().encode(['bytes4', 'bytes32', 'bytes'], [funcSig, MAGIC, randomSignature]));
        if (hash.startsWith(funcSig)) {
            console.log(randomSignature);
            break
        }
        count++;
        if (count % 10000 == 0) {
            console.log(count);
            console.log('hash :>> ', hash);
        }
    }
}
main()
