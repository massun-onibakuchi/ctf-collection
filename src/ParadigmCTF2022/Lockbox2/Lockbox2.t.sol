// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./challenge/Setup.sol";

contract TestLockbox2 is Test {
    Setup setup;
    Lockbox2 lockbox2;

    function setUp() public {
        setup = new Setup();
        lockbox2 = setup.lockbox2();
    }

    function testExploit() public {}
}
