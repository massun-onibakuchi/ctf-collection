// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "./challenge/TinySig.sol";
import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

contract TestTinySig is Test {
    // This is the address you get by using the private key 0x1.
    // For this challenge, make sure you do not use *your own* private key
    // (other than to initiate the `solve` transaction of course). You only
    // need to use the private key 0x1 for signing things.
    // Private key: 0000000000000000000000000000000000000000000000000000000000000001
    address constant SIGNER = 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf;

    address solver = 0x004870D27dFd8C851c596c4dD4BbB0DabccaAc0a;
    TinySig tinySig;
    uint256 seed;

    // forge test --match-contract=TestTinySig -vvv --match-test=testExploit --fork-url=$MAINNET_RPC_URL
    function setUp() public {
        tinySig = new TinySig();
        seed = tinySig.generate(address(solver));
    }

    function testInvariant_HuffCallee() public {
        address huffCallee = HuffDeployer.deploy("Curta/TinySig/TinySigCallee");
        (, bytes memory ret) = huffCallee.staticcall("");
        (bytes32 h, uint8 v, bytes32 r) = abi.decode(ret, (bytes32, uint8, bytes32));

        TinySigCalleeSol solCallee = new TinySigCalleeSol();
        (, bytes memory _ret) = address(solCallee).staticcall("");
        (bytes32 _h, uint8 _v, bytes32 _r) = abi.decode(_ret, (bytes32, uint8, bytes32));

        require(_h == h, "h");
        require(_v == v, "v");
        require(_r == r, "r");
    }

    function testExploit() public {
        address target = HuffDeployer.deploy("Curta/TinySig/TinySigTargetHuff");
        address callee = address(new TinySigCalleeSol());
        bytes memory solution = address(target).code;
        uint256 length = solution.length;
        console.log("code length :>>", length);

        {
            // Hardcoded Callee address
            require(address(0x000001e2b9b60b686f073f92d1908521FA2d1290).code.length != 0, "code");

            (, bytes memory _ret) = callee.staticcall("");
            (bytes32 _h, uint8 _v, bytes32 _r) = abi.decode(_ret, (bytes32, uint8, bytes32));

            (, bytes memory ret) = target.staticcall("");
            (bytes32 h, uint8 v, bytes32 r) = abi.decode(ret, (bytes32, uint8, bytes32));

            require(_h == h, "h");
            require(_v == v, "v");
            require(_r == r, "r");
        }

        require(tinySig.verify(seed, address(target)), "verify failed");
        require(tinySig.verify(seed, uint256(bytes32(solution))), "verify failed");
    }
}

/*
I use this code to generate v, r, hash
```python secp256k1.py
s = 0x4e12e14f842803868e861e7c44865edf2aa30674c8e7be2a94d32f5dc4ef247b
e = 0x0000000000000000000000000000000000000000000000000000000000000001
k = (curve.n - 1) // 2

r = scalar_mult(k, curve.g)[0]
v = (r * inverse_mod(s, curve.n)) % curve.n
z = (k * s % curve.n - r * e % curve.n) % curve.n
if r < (2 << 184):
    print("k found:r ", hex(r), "k", hex(k))
    print("v found:v ", hex(v), "z", hex(z))
else:
    print("k not found", hex(r), "k", hex(k))
```
*/
contract TinySigCalleeSol {
    fallback(bytes calldata) external payable returns (bytes memory) {
        // (hash, v, r)
        // return hex"58f68f583debfe3cb8bcf08664ee7a503e64fda4de3ac6dfe87200c10c43f200000000000000000000000000000000000000000000000000000000000000001c00000000000000000000003b78ce563f89a0ed9414f5aa28ad0d96d6795f9c63";
        return abi.encode(
            bytes32(0x58f68f583debfe3cb8bcf08664ee7a503e64fda4de3ac6dfe87200c10c43f200),
            uint8(28),
            bytes32(0x00000000000000000000003b78ce563f89a0ed9414f5aa28ad0d96d6795f9c63)
        );
    }
}
