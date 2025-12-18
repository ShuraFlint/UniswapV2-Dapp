// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {UniswapV2Pair} from "../src/UniswapV2Pair.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";

contract UniswapV2PairTest is Test {
    UniswapV2Factory factory;
    UniswapV2Pair pair;

    function setUp() public {
        factory = new UniswapV2Factory(address(this));
    }

    function testSetFeeTo() public {
        emit log_named_address("feeTo: ", factory.feeTo());
        factory.setFeeTo(vm.addr(1));
        emit log_named_address("feeTo: ", factory.feeTo());
    }

    function testCreatePair() public {
        emit log_named_uint("allPairsLength: ", factory.allPairsLength());
    }

    // function testInitialize() public {
    //     address token0 = address(0x1);
    //     address token1 = address(0x2);
    //     pair.initialize(token0, token1);
    //     emit log_named_address("token0: ", pair.token0());
    //     emit log_named_address("token1: ", pair.token1());
    //     assertEq(pair.token0(), token0);                                                                             
    //     assertEq(pair.token1(), token1);
    // }

    // function testMul() public {
    //     emit log_named_uint("test_mul: ", pair._testMul());
    // }

    // function testCompare() public {
    //     emit log_named_uint("compare: ", pair.compare(2, 3));
    // }
}
