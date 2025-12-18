// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/extensions/draft-ERC20Bridgeable.sol)

pragma solidity ^0.8.20;

import {ERC20} from "../ERC20.sol";
import {ERC165, IERC165} from "../../../utils/introspection/ERC165.sol";
import {IERC7802} from "../../../interfaces/draft-IERC7802.sol";

/**
 * @dev ERC20 extension that implements the standard token interface according to
 * https://eips.ethereum.org/EIPS/eip-7802[ERC-7802].
 */
abstract contract ERC20Bridgeable is ERC20, ERC165, IERC7802 {
    /// @dev Modifier to restrict access to the token bridge.
    //强制检查调用者是否是受信任的桥合约
    modifier onlyTokenBridge() {
        // Token bridge should never be impersonated using a relayer/forwarder. Using msg.sender is preferable to
        // _msgSender() for security reasons.
        _checkTokenBridge(msg.sender);
        _;
    }

    /// @inheritdoc ERC165
    //ERC-7802标准：让一个普通的 ERC20 代币安全地支持跨链桥（bridge）的铸造和销毁操作，从而实现原生代币在不同链之间的转移（而不是包装代币形式）。
    //让外界可以通过 supportsInterface 检测该代币支持 ERC-7802 标准
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC7802).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC7802-crosschainMint}. Emits a {IERC7802-CrosschainMint} event.
     */
    function crosschainMint(address to, uint256 value) public virtual override onlyTokenBridge {
        _mint(to, value);
        emit CrosschainMint(to, value, _msgSender());
    }

    /**
     * @dev See {IERC7802-crosschainBurn}. Emits a {IERC7802-CrosschainBurn} event.
     */
    function crosschainBurn(address from, uint256 value) public virtual override onlyTokenBridge {
        _burn(from, value);
        emit CrosschainBurn(from, value, _msgSender());
    }

    /**
     * @dev Checks if the caller is a trusted token bridge. MUST revert otherwise.
     *
     * Developers should implement this function using an access control mechanism that allows
     * customizing the list of allowed senders. Consider using {AccessControl} or {AccessManaged}.
     */
    function _checkTokenBridge(address caller) internal virtual;
}
