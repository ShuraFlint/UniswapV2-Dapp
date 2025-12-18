// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {
    ERC20Burnable
} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {
    ERC20Permit
} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract UniswapV2ERC20 is ERC20, ERC20Burnable, ERC20Permit {
    constructor() ERC20("Uniswap V2", "UNI-V2") ERC20Permit("Uniswap V2") {}

    function mint(address to, uint256 amount) internal {
        _mint(to, amount);
    }
}
