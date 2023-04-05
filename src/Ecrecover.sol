// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Ecrecover {
    // ecrecover precompile that returns " ∅ "
    function recover() public returns (address) {
        assembly {
            return(0, 0)
        }
    }
}
