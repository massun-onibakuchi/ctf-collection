// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import "./challenge/TinySig.sol";

contract TestTinySig is Test {
    address constant solver = 0x004870D27dFd8C851c596c4dD4BbB0DabccaAc0a;
    TinySig tinySig;
    uint256 seed;

    function setUp() public {
        vm.createSelectFork("mainnet", 16900000);
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
        bytes memory solution = address(target).code;
        uint256 length = solution.length;
        require(length <= 32, "contract size too big");
        require(tinySig.verify(seed, uint256(bytes32(solution))), "verify failed");
    }
}

// I use this code to generate v, r, hash
// python secp256k1.py
contract TinySigCalleeSol {
    fallback(bytes calldata) external payable returns (bytes memory) {
        // (hash, v, r)
        // return hex"58f68f583debfe3cb8bcf08664ee7a503e64fda4de3ac6dfe87200c10c43f200000000000000000000000000000000000000000000000000000000000000001c00000000000000000000003b78ce563f89a0ed9414f5aa28ad0d96d6795f9c63";
        return
            abi.encode(
                bytes32(0x58f68f583debfe3cb8bcf08664ee7a503e64fda4de3ac6dfe87200c10c43f200),
                uint8(28),
                bytes32(0x00000000000000000000003b78ce563f89a0ed9414f5aa28ad0d96d6795f9c63)
            );
    }
}
