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
        _checkQuine(target);

        //execution
        bytes memory code = target.code;
        challenge.solve(code);

        //assert
        require(setup.isSolved(), "Challenge not solved");
    }

    function _checkQuine(address target) internal view {
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
}
