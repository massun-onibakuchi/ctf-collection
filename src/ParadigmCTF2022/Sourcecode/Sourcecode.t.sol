// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

import "./challenge/Setup.sol";

contract TestSourcecode is Test {
    Setup setup;
    Challenge challenge;

    function setUp() public {
        setup = new Setup();
        challenge = setup.challenge();
    }

    function testExploit() public {
        //setUp
        address target = HuffDeployer.deploy("ParadigmCTF2022/Sourcecode/Quine");

        // check
        _checkCode(target);
        require(safe(target.code), "deploy/code-unsafe");

        //execution
        bytes memory code = target.code;
        challenge.solve(code);

        //assert
        require(setup.isSolved(), "Challenge not solved");
    }

    function _checkCode(address target) internal view {
        (bool ok, bytes memory result) = target.staticcall("");
        bytes memory code = target.code;

        console.log("ok ", ok);
        console.log("code");
        console.logBytes(code);

        console.log("result");
        console.logBytes(result);

        if (ok && keccak256(code) == target.codehash && keccak256(result) == target.codehash) {
            console.log("codehash and result match!!!!!!!!!");
        } else {
            console.log("codehash and result do not match");
        }
    }

    // Copy of the safe function from the challenge
    function safe(bytes memory code) private pure returns (bool) {
        uint256 i = 0;
        while (i < code.length) {
            uint8 op = uint8(code[i]);

            if (op >= 0x30 && op <= 0x48) {
                return false;
            }

            if (
                op == 0x54 || // SLOAD
                op == 0x55 || // SSTORE
                op == 0xF0 || // CREATE
                op == 0xF1 || // CALL
                op == 0xF2 || // CALLCODE
                op == 0xF4 || // DELEGATECALL
                op == 0xF5 || // CREATE2
                op == 0xFA || // STATICCALL
                op == 0xFF // SELFDESTRUCT
            ) return false;

            if (op >= 0x60 && op < 0x80) i += (op - 0x60) + 1;

            i++;
        }

        return true;
    }
}
