// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract InvalidQuine {
    fallback() external payable {
        bytes memory code = address(this).code;
        assembly {
            return(add(code, 0x20), mload(code))
        }
    }
}
