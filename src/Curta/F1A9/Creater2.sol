// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import "./Solve.sol";

contract Creater2 {
    bytes32 public constant INIT_CODE_HASH = keccak256(abi.encodePacked(type(Solve).creationCode));

    function deploy(bytes32 salt) external returns (address) {
        return address(new Solve{salt: salt}());
    }
}
