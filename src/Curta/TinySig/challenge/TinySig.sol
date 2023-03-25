// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import {IPuzzle} from "../../interfaces/IPuzzle.sol";

contract TinySig is IPuzzle {
    // This is the address you get by using the private key 0x1.
    // For this challenge, make sure you do not use *your own* private key
    // (other than to initiate the `solve` transaction of course). You only
    // need to use the private key 0x1 for signing things.
    address constant SIGNER = 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf;
    // Private key: 0000000000000000000000000000000000000000000000000000000000000001

    /// @inheritdoc IPuzzle
    function name() external pure returns (string memory) {
        return "TinySig";
    }

    /// @inheritdoc IPuzzle
    function generate(address _seed) external view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_seed)));
    }

    /// @inheritdoc IPuzzle
    /// @param _start The starting value for the puzzle (provided by `generate`). the value solver can't manipulate
    /// @param _solution The solution to the puzzle (provided by the solver)
    function verify(uint256 _start, uint256 _solution) external returns (bool) {
        // @note solver can provide arbitrary code to be deployed within *uint256 range*
        address target = address(new Deployer(abi.encodePacked(_solution)));
        return verify(_start, target);
    }

    function verify(uint256 _start, address target) public view returns (bool) {
        (, bytes memory ret) = target.staticcall("");
        // (hash, v, r)
        (bytes32 h, uint8 v, bytes32 r) = abi.decode(ret, (bytes32, uint8, bytes32));
        // @audit Find h, v, r such that ecrecover(hash, v, r, s) == signer and s is the specified value.
        bool rValueOk = r < bytes32(uint256(1 << 184)); // @note actually r is required to be very small
        bool sigOk = ecrecover(h, v, r, bytes32(_start)) == SIGNER;
        // console.log("rValueOk: %s", rValueOk);
        // console.log("sigOk: %s", sigOk);
        return (rValueOk && sigOk);
    }
}

contract Deployer {
    constructor(bytes memory code) {
        assembly {
            return(add(code, 0x20), mload(code))
        }
    }
}
