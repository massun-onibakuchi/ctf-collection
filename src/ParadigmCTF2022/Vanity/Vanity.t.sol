// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import "forge-std/Test.sol";
import "./challenge/Setup.sol";
import "./challenge/IERC1271.sol";

contract TestVanity is Test {
    using stdStorage for StdStorage;

    function setUp() public {}

    bytes32 private immutable MAGIC = keccak256(abi.encodePacked("CHALLENGE_MAGIC"));

    function testExploit() public {
        // vm.createSelectFork(vm.rpcUrl("paradigm"));
        Setup setup = new Setup();
        Challenge chal = setup.challenge();
        bytes memory signature = "0x20";
        (bool success, bytes memory result) = address(0x02).staticcall(
            abi.encodeWithSelector(IERC1271.isValidSignature.selector, MAGIC, signature)
        );
        bytes32 _hash = sha256(abi.encodeWithSelector(IERC1271.isValidSignature.selector, MAGIC, signature));
        console.log("hash compare :>>");
        console.logBytes32(_hash);
        console.logBytes32(abi.decode(result, (bytes32)));
    }
}
