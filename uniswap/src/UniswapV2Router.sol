// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {UniswapV2Library} from "../libraries/UniswapV2Library.sol";
import {UniswapV2Factory} from "./UniswapV2Factory.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {UniswapV2Pair} from "./UniswapV2Pair.sol";

contract UniswapV2Router {
    address public immutable factory;
    modifier ensure(uint deadline) {
        require(block.timestamp <= deadline, "UniswapV2Router: EXPIRED");
        _;
    }

    constructor(address _factory) public {
        factory = _factory;
    }

    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {
        if (UniswapV2Factory(factory).getPair(tokenA, tokenB) == address(0)) {
            UniswapV2Factory(factory).createPair(tokenA, tokenB);
        }

        (uint reserveA, uint reserveB) = UniswapV2Library.getReserves(
            address(factory),
            tokenA,
            tokenB
        );

        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = UniswapV2Library.quote(
                amountADesired,
                reserveA,
                reserveB
            );

            if (amountBOptimal <= amountBDesired) {
                require(
                    amountBOptimal >= amountBMin,
                    "UniswapV2Router: INSUFFICIENT_B_AMOUNT"
                );
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = UniswapV2Library.quote(
                    amountBDesired,
                    reserveB,
                    reserveA
                );
                require(
                    amountAOptimal <= amountADesired,
                    "UniswapV2Router: INSUFFICIENT_A_AMOUNT"
                );
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    )
        external
        virtual
        ensure(deadline)
        returns (uint amountA, uint amountB, uint liquidity)
    {
        (amountA, amountB) = _addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin
        );
        address pair = UniswapV2Library.pairFor(
            address(factory),
            tokenA,
            tokenB
        );

        IERC20(tokenA).transferFrom(msg.sender, pair, amountA);
        IERC20(tokenB).transferFrom(msg.sender, pair, amountB);

        liquidity = UniswapV2Pair(pair).mint(to);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public virtual ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        UniswapV2Pair(pair).transferFrom(msg.sender, pair, liquidity);
        (uint amount0, uint amount1) = UniswapV2Pair(pair).burn(to);
        (address token0, address token1) = UniswapV2Library.sortTokends(
            tokenA,
            tokenB
        );
        (amountA, amountB) = tokenA == token0
            ? (amount0, amount1)
            : (amount1, amount0);
        require(
            amountA >= amountAMin,
            "UniswapV2Router: INSUFFICIENT_A_AMOUNT"
        );
        require(
            amountB >= amountBMin,
            "UniswapV2Router: INSUFFICIENT_B_AMOUNT"
        );
    }

    function _swap(
        uint[] memory amounts,
        address[] memory path,
        address _to
    ) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = UniswapV2Library.sortTokends(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0
                ? (uint(0), amountOut)
                : (amountOut, uint(0));
            //这里自动判断了，如果没到最后一对，就用pairFor，如果到了最后一对，就用_to
            address to = i < path.length - 2
                ? UniswapV2Library.pairFor(factory, output, path[i + 2])
                : _to;
            UniswapV2Pair(UniswapV2Library.pairFor(factory, input, output))
                .swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual ensure(deadline) returns (uint[] memory amounts) {
        // 根据传入的tokenA的数量和path获得兑换后的amounts
        amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
        // 判断最终获得的tokenB的数量是否大于amountOutMin
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        // 将tokenA传入第一对交易对中
        IERC20(path[0]).transferFrom(
            msg.sender,
            UniswapV2Library.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        // 兑换
        _swap(amounts, path, to);
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual ensure(deadline) returns (uint[] memory amounts) {
        //从最后一个token反推需要输入的第一个token的数量
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(
            amounts[0] <= amountInMax,
            "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT"
        );
        IERC20(path[0]).transferFrom(
            msg.sender,
            UniswapV2Library.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }
}
