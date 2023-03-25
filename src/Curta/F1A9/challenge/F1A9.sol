// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../interfaces/IPuzzle.sol";

interface ISolve {
    function curtaPlayer() external pure returns (address);
}

/// @title 0xF1A9
/// @author fiveoutofnine
contract F1A9 is IPuzzle {
    /// @inheritdoc IPuzzle
    function name() external pure returns (string memory) {
        return "0xF1A9";
    }

    /// @inheritdoc IPuzzle
    function generate(address _seed) external view returns (uint256) {
        return (uint256(uint160(_seed)) >> (((block.number >> 8) & 0x1F) << 2)) & 0xFFFF;
    }

    /// @inheritdoc IPuzzle
    function verify(uint256 _start, uint256 _solution) external returns (bool) {
        uint256 prefix = block.timestamp < 1678446000 ? (0xF1A9 << 16) | _start : 0;
        // console.logBytes32(bytes32(uint256(0xF1A9 << 16)));
        // 0xf1a90000 | 0x4bbb (19387) BLOCK 16788237??
        // 0xf1a90000 | 0x4dd4 = 0xf1a94dd4 BLOCK 0x1002e01
        // 0xf1a90000 | 0x6c4d = 0xf1a96c4d BLOCK 0x10030b0
        console.log("address(uint160(_solution)) :>>", address(uint160(_solution)));
        console.log(prefix == (_solution >> 128));
        console.log(ISolve(address(uint160(_solution))).curtaPlayer());
        return prefix == (_solution >> 128) && ISolve(address(uint160(_solution))).curtaPlayer() == msg.sender;
    }
}