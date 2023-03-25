// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "./challenge/Setup.sol";

contract SelfCode {
    fallback() external payable {
        // This code breaks the rule of the challenge
        // EXTCODECOPY
        // EXTCODESIZE
        // ADDRESS
        // bytes memory code = address(0xF62849F9A0B5Bf2913b396098F7c7019b51A820a).code;
        // bytes memory code = address(this).code;
        // assembly {
        //     return(add(code, 0x20), mload(code))
        // }
        bytes memory code = "0x6080604052348015600f57600080fd5b506000306001600160a01b0316803b806020016040519081016040528181526000908060200190933c9050805160208201f3fea2646970667358221220569064418104eb88ef5acdc0d1b99df0769135a8944b7a3a256d76883287167764736f6c63430008100033";
        assembly {
            return(add(code, 0x20), mload(code))
        }
    }
}

contract TestSourcecode is Test {
    Setup setup;
    Challenge challenge;

    function setUp() public {
        // vm.createSelectFork(vm.rpcUrl("paradigm"));

        setup = new Setup();
        challenge = setup.challenge();
    }

    function testExploit() public {
        //setUp
        bytes memory code = address(new SelfCode()).code;

        // check
        // challenge.safe(code);
        address testTarget = address(new Deployer(code));
        _testCode(code, testTarget);

        //execution
        challenge.solve(code);
        //assert
        require(setup.isSolved(), "Challenge not solved");
    }

    function testDeployer() public {
        bytes memory code = address(new SelfCode()).code;
        address target = address(new Deployer(code));
        _testCode(code, target);
    }

    function _testCode(bytes memory code, address target) internal view {
        (bool ok, bytes memory result) = target.staticcall("");

        console.log("ok ", ok);
        console.log("code");
        console.logBytes(code);
        console.log("keccke(code)");
        console.logBytes32(keccak256(code));

        console.log("target.codehash");
        console.logBytes32(target.codehash);

        console.log("result");
        console.logBytes(result);
        console.log("keccke(result)");
        console.logBytes32(keccak256(result));

        if (ok && keccak256(code) == target.codehash && keccak256(result) == target.codehash) {
            console.log("codehash and result match!!!!!!!!!");
        } else {
            console.log("codehash and result do not match");
        }
    }
}
