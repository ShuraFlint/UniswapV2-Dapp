// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {UniswapV2Pair} from "../src/UniswapV2Pair.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {TokenA} from "../src/TokenA.sol";
import {TokenB} from "../src/TokenB.sol";

contract UniswapV2FactoryTest is Test {
    UniswapV2Factory factory;
    TokenA tokenA;
    TokenB tokenB;
    UniswapV2Pair pair;

    function setUp() public {
        factory = new UniswapV2Factory(address(this));
        tokenA = new TokenA(address(this), address(this));
        tokenB = new TokenB(address(this), address(this));
    }

    function testCreatePair() public {
        emit log_named_address("factory: ", address(factory));
        emit log_named_address("tokenA: ", address(tokenA));
        emit log_named_address("tokenB: ", address(tokenB));
        (address token0, address token1) = address(tokenA) < address(tokenB)
            ? (address(tokenA), address(tokenB))
            : (address(tokenB), address(tokenA));
        emit log_named_address("token0: ", token0);
        emit log_named_address("token1: ", token1);
        address pairAddress = factory.createPair(
            address(tokenA),
            address(tokenB)
        );
        pair = UniswapV2Pair(pairAddress);
        emit log_named_address("pair: ", address(pair));

        emit log_named_address("pair.token0: ", pair.token0());
        emit log_named_address("pair.token1: ", pair.token1());
        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
        emit log_named_uint("reserve0: ", reserve0);
        emit log_named_uint("reserve1: ", reserve1);

        emit log_named_address("feeTo: ", factory.feeTo());
        emit log_named_decimal_uint(
            "before tokenA pair: ",
            tokenA.balanceOf(address(pair)),
            tokenA.decimals()
        );
        emit log_named_decimal_uint(
            "before tokenB pair: ",
            tokenB.balanceOf(address(pair)),
            tokenB.decimals()
        );
        emit log_named_decimal_uint(
            "pair address(this) LP: ",
            pair.balanceOf(address(this)),
            pair.decimals()
        );
        // 向pair中存入tokenA, tokenB，换取LP
        tokenA.transfer(address(pair), 100 * 10 ** tokenA.decimals());
        tokenB.transfer(address(pair), 100 * 10 ** tokenB.decimals());
        emit log_named_decimal_uint(
            "after tokenA pair: ",
            tokenA.balanceOf(address(pair)),
            tokenA.decimals()
        );
        emit log_named_decimal_uint(
            "after tokenB pair: ",
            tokenB.balanceOf(address(pair)),
            tokenB.decimals()
        );
        pair.mint(address(this));
        emit log_named_decimal_uint(
            "pair address(this) LP: ",
            pair.balanceOf(address(this)),
            pair.decimals()
        );

        tokenA.transfer(address(pair), 100 * 10 ** tokenA.decimals());
        tokenB.transfer(address(pair), 100 * 10 ** tokenB.decimals());
        pair.mint(address(this));
        emit log_named_decimal_uint(
            "pair address(this) LP: ",
            pair.balanceOf(address(this)),
            pair.decimals()
        );

        emit log_named_decimal_uint(
            "before tokenA address(this): ",
            tokenA.balanceOf(address(this)),
            tokenA.decimals()
        );
        emit log_named_decimal_uint(
            "before tokenB address(this): ",
            tokenB.balanceOf(address(this)),
            tokenB.decimals()
        );
        emit log_named_decimal_uint(
            "pair address(pair): ",
            pair.balanceOf(address(pair)),
            pair.decimals()
        );
        emit log("withdraw tokenA, tokenB");
        pair.transfer(address(pair), 100 * 10 ** tokenA.decimals());
        emit log_named_decimal_uint(
            "pair address(pair): ",
            pair.balanceOf(address(pair)),
            pair.decimals()
        );
        // 根据自己的LP，向pair中取出自己的tokenA, tokenB
        pair.burn(address(this));
        emit log_named_decimal_uint(
            "before tokenA address(this): ",
            tokenA.balanceOf(address(this)),
            tokenA.decimals()
        );
        emit log_named_decimal_uint(
            "before tokenB address(this): ",
            tokenB.balanceOf(address(this)),
            tokenB.decimals()
        );
        tokenA.transfer(address(pair), 10 * 10 ** tokenA.decimals());
        emit log_named_decimal_uint(
            "before tokenA address(this): ",
            tokenA.balanceOf(address(this)),
            tokenA.decimals()
        );
        emit log_named_decimal_uint(
            "before tokenB address(this): ",
            tokenB.balanceOf(address(this)),
            tokenB.decimals()
        );
        emit log_named_decimal_uint(
            "after tokenA pair: ",
            tokenA.balanceOf(address(pair)),
            tokenA.decimals()
        );
        emit log_named_decimal_uint(
            "after tokenB pair: ",
            tokenB.balanceOf(address(pair)),
            tokenB.decimals()
        );
        // pair.swap(5 * 10 ** tokenA.decimals(), 0, address(this), "");
        pair.swap(0, 9 * 10 ** tokenA.decimals(), address(this), "");
        emit log_named_decimal_uint(
            "after tokenA pair: ",
            tokenA.balanceOf(address(pair)),
            tokenA.decimals()
        );
        emit log_named_decimal_uint(
            "after tokenB pair: ",
            tokenB.balanceOf(address(pair)),
            tokenB.decimals()
        );
        emit log_named_decimal_uint(
            "before tokenA address(this): ",
            tokenA.balanceOf(address(this)),
            tokenA.decimals()
        );
        emit log_named_decimal_uint(
            "before tokenB address(this): ",
            tokenB.balanceOf(address(this)),
            tokenB.decimals()
        );
    }
}
