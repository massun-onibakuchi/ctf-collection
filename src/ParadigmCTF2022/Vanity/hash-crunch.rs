// ref credit: https://github.com/hrkrshnn/crunchvanity/blob/develop/src/main.rs

use ethers::abi::AbiEncode;
use ethers::{
    prelude::{k256::sha2::Digest, *},
    utils::hex,
};
use rayon::prelude::*;

const MAGIC: &str = "CHALLENGE_MAGIC";
const FUNC_SIG: &str = "1626ba7e";

// Generates the binding `IsValidSignatureCall`
// Need to run `forge build` before `cargo build`.
// abigen!(IERC1271, "./out/IERC1271.sol/IERC1271.json");

abigen!(
    IERC1271,
    r"[
        function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue)
    ]"
);

fn to_signature(i: u64) -> Bytes {
    let signature: Vec<u8> = format!("{}", i).as_bytes().into();
    Bytes::from(signature)
}

fn abi_encode(hash: [u8; 32], signature: Bytes) -> Vec<u8> {
    IsValidSignatureCall { hash, signature }.encode()
}

fn main() {
    let MAGIC_HASH: [u8; 32] = ethers::utils::keccak256(MAGIC);
    // 19bb34e293bba96bf0caeea54cdd3d2dad7fdf44cbea855173fa84534fcfb528
    let res = (0..u64::MAX).into_par_iter().find_any(|i| {
        let signature = to_signature(*i);
        let hash = ethers::core::k256::sha2::Sha256::digest(&abi_encode(MAGIC_HASH, signature));
        if i % 100000 == 0 {
            println!("i: {} hash: {}", i, hex::encode(hash));
        }
        hex::encode(hash).starts_with(FUNC_SIG)
    });
    if let Some(i) = res {
        println!("i: {}", i);
        let signature = to_signature(i);
        let abi_encoding = abi_encode(MAGIC_HASH, signature.clone());
        let hash = hex::encode(ethers::core::k256::sha2::Sha256::digest(&abi_encoding));
        println!("signature: {}", signature);
        println!("ABI encoding: {:?}", hex::encode(abi_encoding));
        println!("sha256: {}", hash);
    } else {
        println!("Crunching failed. Bigger range?");
    }
}
