// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

import {ISolve} from "./challenge/F1A9.sol";

contract Solve is ISolve {
    function curtaPlayer() external pure override returns (address) {
        return 0x0000000006bC8D9e5e9d436217B88De704a9F307;
    }
}
