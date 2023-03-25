// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../interfaces/ICurta.sol";
import "./challenge/F1A9.sol";
import "./Creater2.sol";

contract TestF1A9 is Test {
    uint256 constant blockNumber = uint256(0x1004320);
    address sender = 0x004870D27dFd8C851c596c4dD4BbB0DabccaAc0a;
    F1A9 f1a9;
    uint256 start;

    function setUp() public {
        vm.createSelectFork("mainnet", blockNumber);
        f1a9 = new F1A9();
        start = f1a9.generate(sender);
        console.log("block.number :>>", block.number);
        console.log("f1a9.generate() :>>", start);
    }

    function getPrefix(address _seed) public view returns (uint256) {
        uint256 _start = f1a9.generate(_seed);
        uint256 prefix = block.timestamp < 1678446000 ? (0xF1A9 << 16) | _start : 0;
        return prefix;
    }

    function testExploit() public {
        vm.roll(uint256(0x1004700));

        address curta = 0x0000000006bC8D9e5e9d436217B88De704a9F307;
        address factory = 0xD655A7ce4C39c7a02998B8374f5d8E81c93D3E4e; // creater2 address

        // find salt and address that starts with a prefix with create2crunch.rs
        bytes32 salt = 0x8b11ac1274360b77814d1dee4755cbaa6222f0d64e4549328f42caaf86c39e4a; // input
        address found_vanity_address = 0xF1A90dabEd2c8734B6Ab9c33abd77f715662e466; //input
        uint256 solution = 0x00F1A90dabEd2c8734B6Ab9c33abd77f715662e466; // 0x00<found_vanity_address>

        address _solve = Creater2(factory).deploy(salt);
        require(_solve == found_vanity_address, "not vanity address");
        require(Solve(found_vanity_address).curtaPlayer() == curta, "not sender");
        require(getPrefix(sender) == (solution >> 128), "invalid prefix");

        vm.prank(sender);
        ICurta(curta).solve(2, solution);
    }

    function _getCreate2Address(
        address factory,
        bytes32 salt,
        bytes32 init_code_hash
    ) public pure returns (address) {
        address predictedAddress = address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), factory, salt, init_code_hash))))
        );
        return predictedAddress;
    }
}
