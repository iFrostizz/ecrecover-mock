// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Ecrecover.sol";

contract Verifier {
    function call(address who, bytes calldata what) external returns (bool, uint256) {
        assembly {
            let fmp := mload(0x40)
            // mock write "v" to memory
            mstore(fmp, 12345)
            calldatacopy(add(fmp, 0x60), what.offset, what.length)
            // we want it to return data at the free memory pointer with a length of 32 (0x20)
            // ret data will be written at "v" location
            let ret := call(gas(), who, 0, add(fmp, 0x60), what.length, fmp, 32)

            mstore(add(fmp, 0x20), ret)
            mstore(add(fmp, 0x40), returndatasize())
            return(add(fmp, 0x20), 0x40)
        }
    }
}

contract EcTest is Test {
    Ecrecover public rec;

    function setUp() public {
        rec = new Ecrecover();
    }

    function testRecover() public {
        // deploy a "verifier contract", that needs to call ecrecover precompile
        Verifier ver = new Verifier();
        // call the verifier contract, make it call the precompile in turn
        (bool ret, uint256 size) = ver.call(address(rec), abi.encodeWithSelector(rec.recover.selector));

        // should be 0, as recover returned ∅
        assertEq(size, 0);
        assertFalse(ret);
    }
}
