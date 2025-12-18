// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {UniswapV2ERC20} from "./UniswapV2ERC20.sol";
import {UniswapV2Factory} from "./UniswapV2Factory.sol";
import "../libraries/Math.sol";
import "../libraries/SafeMath.sol";
import "../libraries/UQ112x112.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UniswapV2Pair is UniswapV2ERC20 {
    using Math for uint;
    using SafeMath for uint;
    using UQ112x112 for uint224;
    uint public constant MINIMUM_LIQUIDITY = 10 ** 3;
    bytes4 private constant SELECTOR =
        bytes4(keccak256(bytes("transfer(address,uint256)")));

    address public factory;
    address public token0;
    address public token1;
    uint112 private reserve0;
    uint112 private reserve1;
    uint32 private blockTimestampLast;
    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast;
    uint private unlocked = 1;

    modifier lock() {
        _lockBefore();
        _;
        _lockAfter();
    }

    function _lockBefore() internal {
        require(unlocked == 1, "UniswapV2: LOCKED");
        unlocked = 0;
    }

    function _lockAfter() internal {
        unlocked = 1;
    }

    function getReserves()
        public
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        )
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(SELECTOR, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "UniswapV2: TRANSFER_FAILED"
        );
    }

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    constructor() {
        factory = msg.sender;
    }

    //这个函数由factory调用，用来初始化pair，设置token0和token1
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, "UniswapV2: FORBIDDEN");
        token0 = _token0;
        token1 = _token1;
    }

    function _update(
        //更新后tokenA的储备量
        uint balance0,
        //更新后tokenB的储备量
        uint balance1,
        //上次记录tokenA的储备量
        uint112 _reserve0,
        //上次记录tokenB的储备量
        uint112 _reserve1
    ) private {
        require(
            balance0 <= type(uint112).max && balance1 <= type(uint112).max,
            "UniswapV2: OVERFLOW"
        );
        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // uint224: [高112位:整数] [低112位:小数]
            //                ↑             ↑
            //             整数部分       小数部分
            price0CumulativeLast +=
                uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) *
                timeElapsed;
            price1CumulativeLast +=
                uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) *
                timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    function _mintFee(
        uint112 _reserve0,
        uint112 _reserve1
    ) private returns (bool feeOn) {
        // 获取收取手续费的地址
        address feeTo = UniswapV2Factory(factory).feeTo();
        //先计算feeTo != address(0)
        //true表示打开收费功能，false表示关闭收费功能
        feeOn = feeTo != address(0);
        // 节省gas
        uint _kLast = kLast;
        if (feeOn) {
            if (_kLast != 0) {
                //当前sqrt(k)值
                // rootk=sqrt(_reserve0 * _reserve1)
                uint rootK = Math.sqrt(uint(_reserve0) * uint(_reserve1));
                // 上一次交易后的sqrt(k)值
                uint rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    // 分子(lptoken总量*(rootK-rootKLast))
                    uint numerator = totalSupply() * (rootK - rootKLast);
                    // 分母(rooL*5+rooKLast)
                    uint denominator = (rootK * 5) + rootKLast;
                    // liquidity = ( totalSupply * ( sqrt(_reserve0 * _reserve1) -  sqrt(_kLast) ) ) / sqrt(_reserve0 * _reserve1) * 5 + sqrt(_kLast)
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    function mint(address to) external lock returns (uint liquidity) {
        //旧的token0,token1的余额
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves();
        //新的token0,token1的余额
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        //表示用户存入的tokenA,tokenB的数量
        uint amount0 = balance0 - _reserve0;
        uint amount1 = balance1 - _reserve1;
        // 判断是否进行收取手续费
        bool feeOn = _mintFee(_reserve0, _reserve1);
        // 获得总LP数量
        uint _totalSupply = totalSupply();
        // 创建一个新的流动性池
        if (_totalSupply == 0) {
            //因为 LP token 的总价值必须与池子的总价值成正比。
            //首次添加 = 建立价格 + 建立基准 LP 供应量

            liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY);
        } else {
            // 添加流动性所获得的lptoken数量(进行添加流动性的两种token的数量*目前lptoken的数量/当前token的储备量-->取较小值)
            //非首次添加 = 按比例加入，不改变价格。
            liquidity = Math.min(
                (amount0 * _totalSupply) / _reserve0,
                (amount1 * _totalSupply) / _reserve1
            );
        }
        require(liquidity > 0, "UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED");
        // 铸造lptoken函数
        _mint(to, liquidity);
        // 更新储备函数
        _update(balance0, balance1, _reserve0, _reserve1);
        // 如果收取手续费，更新交易后的k值
        if (feeOn) kLast = uint(reserve0) * uint(reserve1);
        emit Mint(msg.sender, amount0, amount1);
    }

    function burn(
        address to
    ) external lock returns (uint amount0, uint amount1) {
        // 节省gas
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves();
        address _token0 = token0;
        address _token1 = token1;
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        // 为什么用addres(this)?-->因为获取退出lptoken数量时，是在route合约中先将lptoken转到当前合约，然后直接获得当前合约lptoken的数量
        uint liquidity = balanceOf(address(this));
        // 收取手续费，_reserve0, _reserve1是当前池子中token0,token1的储备量
        bool feeOn = _mintFee(_reserve0, _reserve1);
        // 节省gas，必须在这里定义，因为totalSupply可以在_mintFee中更新
        uint _totalSupply = totalSupply();
        // 使用余额确保按比例分配-->(持有lptoken/总lptoken)*合约中持有token的数量
        //amount/balance = liquidity/totalSupply
        amount0 = (liquidity * balance0) / _totalSupply;
        amount1 = (liquidity * balance1) / _totalSupply;
        require(
            amount0 > 0 && amount1 > 0,
            "UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED"
        );
        //address(this)指的是当前合约本身的地址
        _burn(address(this), liquidity);
        // 转账两种token
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        // 更新储备量函数
        //balance0, balance1是新的tokenA,tokenB的余额
        //_reserve0, _reserve1是当前池子中token0,token1的储备量，旧的
        _update(balance0, balance1, _reserve0, _reserve1);
        // 如果收取手续费，更新交易后的k值
        if (feeOn) kLast = uint(reserve0) * uint(reserve1);
        emit Burn(msg.sender, amount0, amount1, to);
    }

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external lock {
        require(
            amount0Out > 0 || amount1Out > 0,
            "UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        // 获取token在交易对中的储备量，节省gas
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves();
        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "UniswapV2: INSUFFICIENT_LIQUIDITY"
        );
        uint balance0;
        uint balance1;
        {
            // _token{0,1}的作用域，避免堆栈过深的错误
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, "UniswapV2: INVALID_TO");
            // 转移代币
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out);
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out);
            // 合约拥有两种token的数量
            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
        }
        // 进行兑换的token量
        // 获得合约两种token的数量，前提是(balance > _reserve - amountOut)，就是当前合约拥有的token数量应该是大于(储备值-输出到to地址的值)，返回之间的差值
        //amount0In,amount1In其中一个值必然为0，另一个值大于0

        //因为如果用户用token0兑换token1，
        //那么amount0In>0,amount1In=0,
        //amount0In是用户输入的token0数量，如果输入少了系统自动回滚
        uint amount0In = balance0 > _reserve0 - amount0Out
            ? balance0 - (_reserve0 - amount0Out)
            : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out
            ? balance1 - (_reserve1 - amount1Out)
            : 0;
        // 投入金额不足
        require(
            amount0In > 0 || amount1In > 0,
            "UniswapV2: INSUFFICIENT_INPUT_AMOUNT"
        );
        {
            // Adjusted{0,1}的作用域，避免堆栈过深的错误
            // balanceAdjusted = balance * 1000 - amountIn * 3(确保在计算余额调整后的值时不会因为小数精度问题而导致错误)
            //balanceAdjusted = balance - amountIn * 0.003
            //扣除手续费后用户真正投入池子中的金额
            uint balance0Adjusted = (balance0 * 1000) - (amount0In * 3);
            uint balance1Adjusted = (balance1 * 1000) - (amount1In * 3);
            // 确保在交易完成后，资金池的储备量满足 Uniswap V2 中的 K 恒定公式，即 K = _reserve0 * _reserve1
            require(
                // balance0Adjusted * balance1Adjusted >= _reserve0 * _reserve0 * 1000 ** 2
                (balance0Adjusted * balance1Adjusted) >=
                    (uint(_reserve0) * uint(_reserve1)) * (1000 ** 2),
                "UniswapV2: K"
            );
        }
        // 更新储备量函数
        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    function skim(address to) external lock {
        address _token0 = token0;
        address _token1 = token1;
        _safeTransfer(
            _token0,
            to,
            IERC20(_token0).balanceOf(address(this)) - reserve0
        );
        _safeTransfer(
            _token1,
            to,
            IERC20(_token1).balanceOf(address(this)) - reserve1
        );
    }

    function sync() external lock {
        _update(
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this)),
            reserve0,
            reserve1
        );
    }
}
