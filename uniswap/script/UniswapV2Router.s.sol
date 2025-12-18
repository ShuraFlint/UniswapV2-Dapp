// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;
import {Script} from "forge-std/Script.sol";
import {TokenA} from "../src/TokenA.sol";
import {TokenB} from "../src/TokenB.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {UniswapV2Router} from "../src/UniswapV2Router.sol";

//forge script script/UniswapV2Router.s.sol --rpc-url http://localhost:8545 --broadcast
contract UniswapV2RouterScript is Script {
    TokenA public tokenA;
    TokenB public tokenB;
    UniswapV2Factory public factory;
    UniswapV2Router public router;
    uint256 public privateKey;

    function setUp() public {
        privateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    }

    function run() public {
        vm.startBroadcast(privateKey);

        //0x5FbDB2315678afecb367f032d93F642f64180aa3
        //cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "name()" | cast --to-ascii
        tokenA = new TokenA(vm.addr(privateKey), vm.addr(privateKey));
        //0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
        //cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "name()" | cast --to-ascii
        tokenB = new TokenB(vm.addr(privateKey), vm.addr(privateKey));
        //0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
        //cast call 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 "feeToSetter()"
        factory = new UniswapV2Factory(vm.addr(privateKey));
        //0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
        //cast call 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9 "factory()"
        router = new UniswapV2Router(address(factory));

        vm.stopBroadcast();
    }
}

/**
我在tokenA中授权router 100代币
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
  "approve(address,uint256)" \
  0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9 \
  100000000000000000000 \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "balanceOf(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 | cast --to-dec
1000000000000000000000

cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "allowance(address,address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9 | cast --to-dec
100000000000000000000

//我在tokenBB中授权router 100代币
cast send 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512   "approve(address,uint256)"   0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9 
  100000000000000000000   --rpc-url http://localhost:8545   --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# 常量定义
export TOKEN_A=0x5FbDB2315678afecb367f032d93F642f64180aa3
export TOKEN_B=0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
export ROUTER=0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
export USER=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# 计算 deadline
TIMESTAMP=$(cast block-number)
BLOCK_TIMESTAMP=$(cast block $TIMESTAMP --field timestamp)
DEADLINE=$((BLOCK_TIMESTAMP + 1200))

# 执行 addLiquidity
cast send $ROUTER \
  "addLiquidity(address,address,uint256,uint256,uint256,uint256,address,uint256)" \
  $TOKEN_A \
  $TOKEN_B \
  100000000000000000000 \
  100000000000000000000 \
  99000000000000000000 \
  99000000000000000000 \
  $USER \
  $DEADLINE \
  --rpc-url http://localhost:8545 \
  --private-key $PRIVATE_KEY

  查看pair
  cast call 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 \
  "getPair(address,address)" \
  0x5FbDB2315678afecb367f032d93F642f64180aa3 \
  0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
0x000000000000000000000000477138f725b2710928185d507b0efce1614b4246
0x477138f725b2710928185d507b0efce1614b4246
export PAIR=0x477138f725b2710928185d507b0efce1614b4246

我在pair中的LP
cast call 0x477138f725b2710928185d507b0efce1614b4246 \
  "balanceOf(address)" \
  0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 | cast --to-dec

  移除流动性
  TIMESTAMP=$(cast block-number)
BLOCK_TIMESTAMP=$(cast block $TIMESTAMP --field timestamp)
DEADLINE=$((BLOCK_TIMESTAMP + 1200))

cast send $PAIR \
  "approve(address,uint256)" \
  $ROUTER \
  10000000000000000000 \
  --rpc-url http://localhost:8545 \
  --private-key $PRIVATE_KEY

cast send $ROUTER \
  "removeLiquidity(address,address,uint256,uint256,uint256,address,uint256)" \
  $TOKEN_A \
  $TOKEN_B \
  10000000000000000000 \
  9000000000000000000 \
  9000000000000000000 \
  $USER \
  $DEADLINE \
  --rpc-url http://localhost:8545 \
  --private-key $PRIVATE_KEY

  使用确定的A交换B
  cast send $TOKEN_A   "approve(address,uint256)"   $ROUTER   10000000000000000000   --rpc-url http://localhost:8545   --private-
key $PRIVATE_KEY

TIMESTAMP=$(cast block-number)
BLOCK_TIMESTAMP=$(cast block $TIMESTAMP --field timestamp)
DEADLINE=$((BLOCK_TIMESTAMP + 1200))

DEADLINE=$(( $(cast block $(cast block-number) --field timestamp) + 1200 ))

cast send $ROUTER \
  "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)" \
  10000000000000000000 \
  5000000000000000000 \
  "[$TOKEN_A,$TOKEN_B]" \
  $USER \
  $DEADLINE \
  --rpc-url http://localhost:8545 \
  --private-key $PRIVATE_KEY

  使用A换取确定的B
  cast send $TOKEN_A   "approve(address,uint256)"   $ROUTER   20000000000000000000   --rpc-url http://localhost:8545   --private-
key $PRIVATE_KEY

cast send $ROUTER \
  "swapTokensForExactTokens(uint256,uint256,address[],address,uint256)" \
  10000000000000000000 \
  20000000000000000000 \
  "[$TOKEN_A,$TOKEN_B]" \
  $USER \
  $DEADLINE \
  --rpc-url http://localhost:8545 \
  --private-key $PRIVATE_KEY

cast send $ROUTER \
  "swapTokensForExactTokens(uint256,uint256,address[],address,uint256)" \
  10000000000000000000 \
  20000000000000000000 \
  "[$TOKEN_A,$TOKEN_B]" \
  $USER \
  $DEADLINE \
  --rpc-url http://localhost:8545 \
  --private-key $PRIVATE_KEY
 */
