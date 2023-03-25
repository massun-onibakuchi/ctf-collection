// ref credit:
// - https://github.com/hrkrshnn/crunchvanity/blob/develop/src/main.rs
// - Foundry cast `cast create2`

use std::env;

use ethers::{
    prelude::{rand::thread_rng, *},
    utils::hex,
};
use rayon::prelude::*;

fn main() {
    let prefix = env::var("PREFIX").expect("PREFIX not set");
    let prefix = prefix.replace("0x", "").to_lowercase();
    let factory: Address = env::var("FACTORY") // 0x2B89c5c274C484B926D4E0417C45484cC4D634D2
        .expect("FACTORY not set")
        .parse()
        .unwrap();
    let init_code_hash = env::var("INIT_CODE_HASH").expect("INIT_CODE_HASH not set"); // 0x1fc924196cd154e95bffa954e5fd41653ac723075a71aad686f4b7ed1c3d0162
    let init_code_hash = Bytes::from(
        hex::decode(init_code_hash.strip_prefix("0x").unwrap_or(&init_code_hash)).unwrap(),
    );

    let result = std::iter::repeat(())
        .par_bridge()
        .map(|_| {
            let salt = H256::random_using(&mut thread_rng());
            let salt = Bytes::from(salt.to_fixed_bytes());

            let derived_address = ethers::core::utils::get_create2_address_from_hash(
                factory,
                salt.clone(),
                init_code_hash.to_vec(), // TODO avoid clone
            );
            (salt, derived_address)
        })
        .find_any(|(_, derived_address)| hex::encode(derived_address).starts_with(&prefix));

    // if find any, print out the result
    if let Some((salt, derived_address)) = result {
        println!("factory: {}", hex::encode(factory));
        println!("salt: {}", salt);
        println!("derived address: {}", hex::encode(derived_address));
    } else {
        println!("Crunching failed. Bigger range?");
    }
}

#[cfg(test)]
mod test {

    // fn to_bytes(i: u64) -> Bytes {
    //     let signature: Vec<u8> = format!("{}", i).as_bytes().into();
    //     Bytes::from(signature)
    // }

    #[test]
    fn test_create2() {
        // let factory: Address = "0x2B89c5c274C484B926D4E0417C45484cC4D634D2"
        //     .parse()
        //     .unwrap();
        // let salt = H256::random_using(&mut thread_rng());
        // let salt = Bytes::from(salt.to_fixed_bytes());
        // // let salt = keccak256(abi::encode(&[ethers::abi::Token::Uint(U256::from(1_u64))]));
        // // println!("salt: {:?}", hex::decode(salt.clone()));
        // let init_code_hash = Bytes::from(
        //     hex::decode("61f746e5ec7ec2d76c4fa8c6dc661a8d5a90815a898ca64d1c3a992f9534ac9b")
        //         .unwrap(),
        // );
        // let derived_address =
        //     ethers::core::utils::get_create2_address_from_hash(factory, salt, &init_code_hash);
        // assert_eq!(
        //     derived_address,
        //     "0x297d5aB96A2235d6aD3f86d6a4B1210Dc739Cd39"
        //         .parse()
        //         .unwrap()
        // );
    }
}
