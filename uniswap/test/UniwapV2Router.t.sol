// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {UniswapV2Router} from "../src/UniswapV2Router.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {TokenA} from "../src/TokenA.sol";
import {TokenB} from "../src/TokenB.sol";
import {UniswapV2Library} from "../libraries/UniswapV2Library.sol";
import {UniswapV2Pair} from "../src/UniswapV2Pair.sol";

contract UniswapV2RouterTest is Test {
    TokenA tokenA;
    TokenB tokenB;
    UniswapV2Factory factory;
    UniswapV2Router router;
    address pair;
    uint deadline;

    function setUp() public {
        tokenA = new TokenA(address(this), address(this));
        tokenB = new TokenB(address(this), address(this));
        //构造函数传入的地址拥有设置feeTo的权限
        factory = new UniswapV2Factory(address(this));
        //构造函数需要传入factory的地址
        router = new UniswapV2Router(address(factory));
        tokenA.approve(address(router), 100 * 10 ** 18);
        tokenB.approve(address(router), 100 * 10 ** 18);

        deadline = block.timestamp + 20 minutes;
        (uint amountToken, uint amountETH, uint liquidity) = router
            .addLiquidity(
                address(tokenA),
                address(tokenB),
                100 * 10 ** 18,
                100 * 10 ** 18,
                99 * 10 ** 18,
                99 * 10 ** 18,
                address(this),
                deadline
            );
        //获得这两个token的pair
        pair = UniswapV2Library.pairFor(
            address(factory),
            //这里不是必须加address，而是tokenA是合约类型，不是地址类型，所以需要加address
            address(tokenA),
            address(tokenB)
        );
    }

    function testAddliquidity() public {
        emit log_named_address("factory: ", router.factory());
        emit log_named_address("pair: ", pair);

        emit log("use 100 tokenA and 100 tokenB to add liquidity");

        // 为 Router 合约授权转移代币

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
            "pair address(this) LP: ",
            UniswapV2Pair(pair).balanceOf(address(this)),
            UniswapV2Pair(pair).decimals()
        );

        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        // 计算UniswapV2Pair合约的 init code hash
        bytes32 init_code_hash = keccak256(type(UniswapV2Pair).creationCode);
        emit log_named_bytes32(
            "init_code_hash of UniswapV2Pair: ",
            init_code_hash
        );
    }

    function testRemoveLiquidity() public {
        emit log("remove 10 LP to get tokenA and tokenB");
        deadline = block.timestamp + 20 minutes;
        UniswapV2Pair(pair).approve(address(router), 10 * 10 ** 18);
        (uint amountA, uint amountB) = router.removeLiquidity(
            address(tokenA),
            address(tokenB),
            10 * 10 ** 18,
            9 * 10 ** 18,
            9 * 10 ** 18,
            address(this),
            deadline
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
            "pair address(this) LP: ",
            UniswapV2Pair(pair).balanceOf(address(this)),
            UniswapV2Pair(pair).decimals()
        );
    }

    function testSwapExactTokensForTokens() public {
        emit log("use 10 tokenA to swap for indefinite amount of tokenB");
        deadline = block.timestamp + 20 minutes;
        tokenA.approve(address(router), 10 * 10 ** 18);
        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);
        router.swapExactTokensForTokens(
            10 * 10 ** 18,
            5 * 10 ** 18,
            path,
            address(this),
            deadline
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
            "pair address(this) LP: ",
            UniswapV2Pair(pair).balanceOf(address(this)),
            UniswapV2Pair(pair).decimals()
        );
    }

    function testSwapTokensForExactTokens() public {
        emit log("use indefinite amount of tokenA to swap for 10 tokenB");
        deadline = block.timestamp + 20 minutes;
        tokenA.approve(address(router), 20 * 10 ** 18);
        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);
        router.swapTokensForExactTokens(
            10 * 10 ** 18,
            20 * 10 ** 18,
            path,
            address(this),
            deadline
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
            "pair address(this) LP: ",
            UniswapV2Pair(pair).balanceOf(address(this)),
            UniswapV2Pair(pair).decimals()
        );
        emit log_named_address("vm.addr(1)", vm.addr(1));
    }
}
