// ============================================================
// Contract name: LBToken
// Contract address: 0xe7a64c6ef6b4173a36518c36b7379aaeb6a7df8d
// Liquidity: $169863.38
// Chain: BNB Smart Chain (56)
// Source: BscScan verified contract
// ============================================================
// SPDX-License-Identifier: MIT
/**
开发者免责声明

本声明由 [LP]（以下简称“开发者”）针对[LongBi合约]（以下简称“项目”）的开发与交付作出，明确开发者与项目方（以下简称“客户”）之间的责任界限。使用本项目的任何人或实体（以下简称“用户”）在使用前应仔细阅读本声明。

1.项目合规性
    客户须确保其在使用本项目时遵守所有适用的法律法规、行业标准及相关政策。开发者在项目开发过程中，已依据客户的要求提供技术实现及相关服务，但不对客户使用本项目的合规性作出任何保证或承担任何责任。

2.违规操作责任
    若客户在使用本项目的过程中，出现任何形式的违规操作，包括但不限于违反法律法规、侵害第三方权益、未履行合规性义务等，开发者不对因这些违规操作引发的任何损失、责任、索赔、费用或开支承担任何责任。客户应自行承担因其违规操作导致的所有后果，并承担相应的赔偿责任。

3.第三方风险
    本项目可能涉及到与第三方服务、系统或平台的对接。客户在使用这些第三方服务时，应自行判断其合法性和合规性。开发者不对任何第三方的行为或产品的合法性、合规性或适用性承担责任。


Developer Disclaimer

This statement is made by [LP] (hereinafter referred to as "Developer") for the development and delivery of [LongBi contract] (hereinafter referred to as "project"), and clarifies the responsibility boundary between the developer and the project party (hereinafter referred to as "customer"). Any person or entity using this project (hereinafter referred to as "user") should read this statement carefully before using it.

1. Project Compliance
Customers must ensure that they comply with all applicable laws, regulations, industry standards and relevant policies when using this project. During the project development process, the developer has provided technical implementation and related services according to the customer's requirements, but does not make any guarantee or assume any responsibility for the compliance of the customer's use of this project.

2. Responsibility for Illegal Operations
If the customer has any form of illegal operation during the use of this project, including but not limited to violation of laws and regulations, infringement of third-party rights, failure to perform compliance obligations, etc., the developer shall not be responsible for any losses, liabilities, claims, costs or expenses caused by these illegal operations. The customer shall bear all consequences caused by its illegal operations and bear the corresponding compensation liability.

3. Third-party risks
This project may involve docking with third-party services, systems or platforms. When using these third-party services, customers should make their own judgments on their legality and compliance. Developers are not responsible for the legality, compliance, or applicability of any third-party actions or products.
*/
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;


/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol


// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC-20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC-721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in ERC-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC-1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC-20
 * applications.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Skips emitting an {Approval} event indicating an allowance update. This is not
     * required by the ERC. See {xref-ERC20-_approve-address-address-uint256-bool-}[_approve].
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     *
     * ```solidity
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance < type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: contracts/HHB.sol

/**
 *Submitted for verification at BscScan.com on 2024-08-20
*/

/**
开发者免责声明

本声明由 [LP]（以下简称“开发者”）针对[LongBi合约]（以下简称“项目”）的开发与交付作出，明确开发者与项目方（以下简称“客户”）之间的责任界限。使用本项目的任何人或实体（以下简称“用户”）在使用前应仔细阅读本声明。

1.项目合规性
    客户须确保其在使用本项目时遵守所有适用的法律法规、行业标准及相关政策。开发者在项目开发过程中，已依据客户的要求提供技术实现及相关服务，但不对客户使用本项目的合规性作出任何保证或承担任何责任。

2.违规操作责任
    若客户在使用本项目的过程中，出现任何形式的违规操作，包括但不限于违反法律法规、侵害第三方权益、未履行合规性义务等，开发者不对因这些违规操作引发的任何损失、责任、索赔、费用或开支承担任何责任。客户应自行承担因其违规操作导致的所有后果，并承担相应的赔偿责任。

3.第三方风险
    本项目可能涉及到与第三方服务、系统或平台的对接。客户在使用这些第三方服务时，应自行判断其合法性和合规性。开发者不对任何第三方的行为或产品的合法性、合规性或适用性承担责任。


Developer Disclaimer

This statement is made by [LP] (hereinafter referred to as "Developer") for the development and delivery of [LongBi contract] (hereinafter referred to as "project"), and clarifies the responsibility boundary between the developer and the project party (hereinafter referred to as "customer"). Any person or entity using this project (hereinafter referred to as "user") should read this statement carefully before using it.

1. Project Compliance
Customers must ensure that they comply with all applicable laws, regulations, industry standards and relevant policies when using this project. During the project development process, the developer has provided technical implementation and related services according to the customer's requirements, but does not make any guarantee or assume any responsibility for the compliance of the customer's use of this project.

2. Responsibility for Illegal Operations
If the customer has any form of illegal operation during the use of this project, including but not limited to violation of laws and regulations, infringement of third-party rights, failure to perform compliance obligations, etc., the developer shall not be responsible for any losses, liabilities, claims, costs or expenses caused by these illegal operations. The customer shall bear all consequences caused by its illegal operations and bear the corresponding compensation liability.

3. Third-party risks
This project may involve docking with third-party services, systems or platforms. When using these third-party services, customers should make their own judgments on their legality and compliance. Developers are not responsible for the legality, compliance, or applicability of any third-party actions or products.
*/
pragma solidity ^0.8.20;







library Percentage {
    using SafeMath for uint256;
    uint256 constant BASE = 1000000;

    function percentage(
        uint256 amount,
        uint256 percent
    ) internal pure returns (uint256) {
        return amount.mul(percent).div(BASE);
    }

}

library TokenUtils {

    function balanceOf(address erc20, address accout) internal view returns (uint256) {
        return IERC20(erc20).balanceOf(accout);
    }

    function approve(address erc20, address to, uint256 amount) internal {
        TransferHelper.safeApprove(erc20, to, amount);
    }

    function transfer(address erc20, address to, uint256 amount) internal {
        TransferHelper.safeTransfer(erc20, to, amount);
    }

    function transferFrom(address erc20, address from, address to, uint256 amount) internal {
        TransferHelper.safeTransferFrom(erc20, from, to, amount);
    }

}

interface IWBNB {
    function deposit() external payable;
    function withdraw(uint wad) external;
}

interface ISuperNodeInterface {
    function increaseSuperQuantity(address account, uint256 amount) external;
    function upgradeSuperNode(address account) external;
    function upgradeTheCreation(address account) external ;
    function notifySuperReward(uint256 reward) external;
    function isSuperNode(address account) external view returns(bool);
    function isCreationNode(address account) external view returns(bool);
    function notifyCreationReward(uint256 reward) external;
    function increaseCreationQuantity(address account, uint256 amount) external;
}

interface IBuyBackToInterface {
    function autoBuyBack() external returns(bool);
}

contract HHBTO is Ownable,ReentrancyGuard {
    using Percentage for uint256;
    using TokenUtils for address;
    IUniswapV2Router02 uniswap;
    address private constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // address private constant ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; //testnet
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant USDT = 0x55d398326f99059fF775485246999027B3197955;

    constructor() Ownable(msg.sender){
        uniswap = IUniswapV2Router02(ROUTER);
    }
    receive() external payable { }

    function swapExactTokensForTokens(address tokenA, address tokenB, uint amountIn) internal {
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        tokenA.approve(ROUTER, amountIn * 14 / 10);
        uniswap.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn, 
            0, 
            path, 
            address(this), 
            block.timestamp + 300
        );
    }

    function swapExactTokensForWBNB(address tokenA, uint amountIn) internal {
        address[] memory path = new address[](3);
        path[0] = tokenA;
        path[1] = USDT;
        path[2] = WBNB;
        tokenA.approve(ROUTER, amountIn * 14 / 10);
        uniswap.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn, 
            0, 
            path, 
            address(this), 
            block.timestamp + 300
        );
    }

    function swapExactTokensForETH(address tokenA, uint amountIn) internal {
        address[] memory path = new address[](3);
        path[0] = tokenA;
        path[1] = USDT;
        path[2] = WBNB;
        tokenA.approve(ROUTER, amountIn * 14 / 10);
        uniswap.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountIn,
            0, 
            path, 
            address(this), 
            block.timestamp + 300
        );
    }

    function swapPoolSupport(address wbnb, address usdt, address pool, uint256 amount) external onlyOwner {
        swapExactTokensForTokens(wbnb,usdt,amount);
        uint256 usdtBalance = usdt.balanceOf(address(this));
        usdt.transfer(pool, usdtBalance);
    }

    //uint256 operationFee, uint256 nodeFee, uint256 lianchuangFee, uint256 destroyFee
    function apple(address erc20A, uint256[4] memory fee, address[3] memory feeAddr) public onlyOwner returns(uint256, uint256, uint256){
        uint256 feeAll = fee[0] + fee[1] + fee[2] + fee[3];
        uint256 feeWAll = fee[0] + fee[1];

        uint256 feeTokenSum = erc20A.balanceOf(address(this)) * feeWAll / feeAll;
        swapExactTokensForWBNB(erc20A, feeTokenSum);
        uint256 sum = WBNB.balanceOf(address(this));

        uint256 operationWbnb = sum * fee[0] / feeWAll;
        uint256 nodeWbnb = sum - operationWbnb;
        WBNB.transfer(feeAddr[0], operationWbnb);
        WBNB.transfer(feeAddr[1], nodeWbnb);

        (uint256 s, uint256 c) = calculateNodeReward(erc20A, fee, feeAddr[2]);
        return (nodeWbnb, s, c);
    }

    function calculateNodeReward(address erc20A, uint256[4] memory fee, address node) internal returns(uint256, uint256) {
        swapExactTokensForETH(erc20A, erc20A.balanceOf(address(this)));
        uint256 totalBnBAmount = address(this).balance;
        uint256 superNodeBnb = totalBnBAmount * fee[3] / (fee[2] + fee[3]);
        payable(node).transfer(totalBnBAmount);
        return (superNodeBnb, totalBnBAmount - superNodeBnb);
    }

    //uint256 operationFee, uint256 nodeFee, uint256 lianchuangFee, uint256 destroyFee
    function apple(address erc20A, address erc20B, uint256 amountIn) internal returns(uint256){
        uint256 start = erc20B.balanceOf(address(this));
        swapExactTokensForTokens(erc20A,erc20B,amountIn);
        uint256 stop = erc20B.balanceOf(address(this));
        return stop - start;
    }

    event Log(uint,uint,uint);
    function addLiquidity(address tokenA, address tokenB, uint256 amountToken, uint256 amountBNB,address to, address swap) internal returns(uint, uint, uint){
        tokenA.approve(ROUTER, amountToken * 14 / 10);
        tokenB.approve(ROUTER, amountBNB * 14 / 10);
        (uint amountA, uint amountB, uint liquidity) = uniswap.addLiquidity(
            tokenA,
            tokenB,
            amountToken,
            amountBNB,
            0,
            0,
            to,
            block.timestamp + 300
        );
        emit Log(amountA, amountB, liquidity);
        if(amountBNB > amountB){
            tokenB.transfer(swap,amountBNB - amountB);
        }
        if(amountToken > amountA){
            tokenA.transfer(swap,amountToken - amountA);
        }
        IUniswap(swap).sync();
        return (amountA, amountB, liquidity);
    }

    function swapAndAddLiquidity(address tokenA, address tokenB, address tokenC, uint256 amountBNB,address to, address swap) public onlyOwner{
        uint256 amountUsdt = apple(tokenA, tokenC, amountBNB);
        uint256 halfU = amountUsdt / 2;
        uint256 amountToken = apple(tokenC, tokenB, halfU);
        addLiquidity(tokenB, tokenC, amountToken, halfU, to, swap);
    }
}

contract LBToken is ERC20,Ownable,ReentrancyGuard {
    using Percentage for uint256;
    using TokenUtils for address;
    using SafeMath for uint256;
    IUniswapV2Router02 uniswap;
    HHBTO tohhb;
    address public hhbTo;
    // BSC-MainNet
    address private constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //mainnet
    // address private constant ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; //testnet

    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    uint256 private _totalSupply = 39999 * 10**decimals();//代币总量
    uint256 public hashrateMultiple = 1000;//算力倍数
    address public swap;//swap地址
    uint256 public isSwapPrice = 3999000000000000000000;//开启买入价格
    uint256 public operationFee = 10000;//运营比例
    uint256 public superNodeFee = 10000;//运营比例
    uint256 public nodeFee = 20000;//节点比例
    uint256 public lianchuangFee = 10000;//联创比例
    uint256 public destroyFee = 40000;//黑洞比例
    address public operation = address(0x6568f6D1e1594BDeB42F1186fcFfd750fa531302);
    address public defaultAddr = 0xe459f557aC6BA89A3a8B6F8072c5e36d8fE7D641;

    address public fundAddress = 0x9AF4af21e97d29cC4d5FBfcD2144bBD5577E6936;

    address public node;//节点地址
    address public destroy = address(0xdEaD);//黑洞地址

    address public supportPool;//护盘池
    uint256 public volatilityRatio = 20; //
    uint256 public lastAutoBuyBackTime;
    uint256 public autoBuyBackInteral = 2 minutes;
    bool public isAuto = true;

    uint256 public period = 1 days;

    uint256 referrerRequired = 3;
    uint256 public nodeRequiredNumber = 10; 
    uint256 public upgradeNodeRequiredAmount = 10 ether;
    uint256 public requiredUpgradePerformance = 10 ether;
    uint256 public requiredUpgradeCreation = 45 ether;

    address public superNode;

    mapping (address => uint256) public accountAchievement;
    mapping (address => uint256) public teamAchievement;

    uint256 public preachTime = 1738547880;  //布道时间
    uint256 public increment = 10000;  //算力递增比例

    uint256 public wholeHashrateStatic2;//全网总静态   周期=》当日全网总静态
    uint256 public wholeHashrateDynamic2;//全网总动态   周期=》当日全网总动态
    mapping(uint256 => uint256) public wholeHashrateStatic;//全网总静态   周期=》当日全网总静态
    mapping(uint256 => uint256) public wholeHashrateDynamic;//全网总动态   周期=》当日全网总动态
    mapping(uint256 => uint256) public wholeStatic;//单日总静态奖励   周期=》当日总静态奖励
    mapping(uint256 => uint256) public wholeDynamic;//单日总动态奖励   周期=》当日总动态奖励

    mapping(uint256 => uint256) public wholeNodePeople;//全网节点人数   周期=全网节点人数
    mapping(uint256 => uint256) public wholeNode;//单日总节点奖励   周期=》当日总节点奖励

    mapping(address => User) public users;

    uint256 public min = 100000000000000000;  //最小

    mapping(address => mapping(uint256 => uint256)) public userCycleStatic;//用户=》周期=》静态
    mapping(address => mapping(uint256 => uint256)) public userCycleDynamic;//用户=》周期=》动态

    mapping (uint256 => uint256) public cyclePrice;

    // 用于检查地址是否已被记录
    mapping(address => bool) private isTtss;

    uint256 public ttss = 5;
    uint256 public isSwapTtss = 15000;//开启买入持币地址数量
    
    constructor() ERC20("LongBi", "LB") Ownable(msg.sender){
        _mint(0xC2BC02180b1c23cf84640C73dFfdf618308138b9, 1900 * 10**decimals());
        _mint(address(this), _totalSupply - (1900 * 10**decimals()));
        uniswap = IUniswapV2Router02(ROUTER);
        node = address(this);
        tohhb = new HHBTO();
        hhbTo = address(tohhb);
    }

    struct User {
        address superior; //上级地址
        uint256 bnbAmount; // bnb数量
        uint256 hashrateStatic; // 静态算力
        uint256 hashrateDynamic; // 动态算力
        uint256 staticReceived; //静态已领取
        uint256 dynamicReceived; //动态已领取
        uint256 nodeReceived; //节点已领取
        uint256 lastStaticCycle; // 上一次静态挖矿领奖周期
        uint256 lastDynamicCycle; // 上一次动态挖矿领奖周期
        uint256 lastNodeCycle; // 上一次节点领奖周期
        uint256 people; // 直推有效人数
        uint256 isNode; // 是否节点，1：是，0：否
    }

    function setPeriod(uint256 _period) external onlyOwner {
        period = _period;
    }

    function setUpgradeNodeRequiredAmount(
        uint256 _nodeRequiredNumber,
        uint256 _upgradeNodeRequiredAmount, 
        uint256 _requiredUpgradePerformance, 
        uint256 _referrerRequired,
        uint256 _requiredUpgradeCreation
    ) external onlyOwner {
        nodeRequiredNumber = _nodeRequiredNumber;
        upgradeNodeRequiredAmount = _upgradeNodeRequiredAmount;
        requiredUpgradePerformance = _requiredUpgradePerformance;
        referrerRequired = _referrerRequired;
        requiredUpgradeCreation = _requiredUpgradeCreation;
    }

    function setFundConfig(address _fundAddress) external onlyOwner {
        fundAddress = _fundAddress;
    }

    function setSwap(address val) public onlyOwner {
        swap = val;
    }

    function setSuperNode(address _superNode) external onlyOwner {
        superNode = _superNode;
    }

    function setsupportPool(address _supportPool) external onlyOwner {
        supportPool = _supportPool;
    }

    function setAutoBuyBackConfig(
        bool _isAuto,
        uint256 _volatilityRatio,
        uint256 _autoBuyBackInteral
    ) external onlyOwner {
        isAuto = _isAuto;
        volatilityRatio = _volatilityRatio;
        autoBuyBackInteral =_autoBuyBackInteral;
    }

    function setPreachTime(uint256 _preachTime) external onlyOwner {
        preachTime = _preachTime;
    }

    function setIsSwapPrice(uint256 _price) external onlyOwner {
        isSwapPrice = _price;
    }

    event Log(uint112,uint112,uint256,uint256);
    // 覆写转账函数以实现通缩机制
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        if (swap == sender) { // buy
            if(recipient == hhbTo || recipient == address(this) || recipient == address(supportPool)){
                super._transfer(sender, recipient, amount);
            }else {
                if(getHHBUSDT() < isSwapPrice && ttss < isSwapTtss){
                    super._transfer(sender, destroy, amount);
                }else {
                    uint256 fee = operationFee + nodeFee + lianchuangFee + superNodeFee;
                    uint256 feeSum = amount.percentage(fee);
                    super._transfer(sender, hhbTo, feeSum);
                    super._transfer(sender, recipient, amount - feeSum);
                }
            }
        } else if (swap == recipient) { //sell
            if(sender == hhbTo || sender == address(this)){
                super._transfer(sender, recipient, amount);
            }else {
                uint256 fee = operationFee + nodeFee + lianchuangFee + superNodeFee;
                uint256 feeSum = amount.percentage(fee);
                uint256 destroySum = amount.percentage(destroyFee);
                super._transfer(sender, destroy, destroySum);
                super._transfer(sender, hhbTo, feeSum);
                super._transfer(sender, recipient, amount - feeSum - destroySum);
            }
        } else if(amount == 0){
            feeFenFa(sender);
            if(sender == recipient){
                //领取静态奖励
                drawUserStaticIncome(sender);
            }else if(recipient == address(this)){
                //领取节点奖励
                drawUserNode(sender);
            }else if(recipient == destroy){
                //领取动态奖励
                drawUserDynamicIncome(sender);
            }else {
                blind(sender, recipient);
            }
            super._transfer(sender, recipient, amount);
        }else {
            feeFenFa(sender);
            super._transfer(sender, recipient, amount);
        }

        if(amount != 0){
            if (!isTtss[recipient]) {
                isTtss[recipient] = true;
                ttss++;
            }

            if (
                sender != address(hhbTo) && 
                sender != address(supportPool) &&
                balanceOf(sender) == 0 && 
                isTtss[sender] && 
                ttss > 0
            ) {
                isTtss[sender] = false;
                ttss--;
            }
        }
        setCycleTotalAward();
        setCyclePrice();
    }

    //绑定
    event Blind(address account,address superior,uint256 time);
    mapping(address => address[]) internal userTeam;

    function blind(address account,address superior) internal nonReentrant{
        require(superior != address(0), "1");
        require(superior != account, "2");
        require(account != defaultAddr, "4");
        require(users[superior].superior != address(0) || superior == defaultAddr, "3");
        require(users[account].superior == address(0), "4");
        users[account].superior = superior;
        userTeam[superior].push(account);
        emit Blind(account,superior,block.timestamp);
    }

    function feeFenFa(address from) internal {
        uint256 currentPrice = swap != address(0) ? getHHBUSDT() : 0;
        uint256 triggerPrice = cyclePrice[getCycle()].sub(cyclePrice[getCycle()].mul(volatilityRatio).div(100));
        if(
            isAuto &&
            cyclePrice[getCycle()] > 0 && 
            currentPrice < triggerPrice && 
            block.timestamp > lastAutoBuyBackTime.add(autoBuyBackInteral) && 
            from != address(supportPool)
        ) {
            try IBuyBackToInterface(supportPool).autoBuyBack() returns(bool res) {
                if(res) {
                   lastAutoBuyBackTime = block.timestamp;
                }
            } catch {}
        } else if(from != address(supportPool) && address(this).balanceOf(hhbTo) > 10000000000000000) {
                uint256[4] memory fees;
                fees[0] = operationFee;
                fees[1] = nodeFee;
                fees[2] = lianchuangFee;
                fees[3] = superNodeFee;
                address[3] memory feeAddr;
                feeAddr[0] = operation;
                feeAddr[1] = node;
                feeAddr[2] = superNode;
                (uint256 nodeWbnb, uint256 superNodeWbnb, uint256 lianchuangWbnb) = tohhb.apple(address(this),fees,feeAddr);
                wholeNode[getCycle()]+=nodeWbnb;
                if(superNode != address(0)) {
                    ISuperNodeInterface(superNode).notifySuperReward(superNodeWbnb);
                    ISuperNodeInterface(superNode).notifyCreationReward(lianchuangWbnb);
                }
        }    
    }

    function setCyclePrice() internal {
        uint256 cycle = getCycle();
        if(cyclePrice[cycle] <= 0 && swap != address(0)) {
            cyclePrice[cycle] = getHHBUSDT();
        }
    }

    function getUserTeam(address account) public view returns(address[] memory) {
        return userTeam[account];
    }

    function getCycle() public view returns (uint256 cycle) {
        if(block.timestamp > preachTime){
            return (block.timestamp - preachTime) / period;
        }else {
            return 0;
        }
    }

    function getHHBUSDT() public view returns (uint256 price) {
        if(swap != address(0)){
            uint256 hhbwbnb = getTokenPrice(address(this),USDT,1 ether);
            return hhbwbnb;
        } else {
            return 100000000000000000;
        }
    }

    function getTokenPrice(address tokenA, address tokenB, uint256 amountIn) public view returns (uint256 tokenPrice) {
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        return uniswap.getAmountsOut(amountIn, path)[1];
    }

    function getCycleStatic() public view returns (uint256 totalStatic) {
        uint256 hhbPrice = getHHBUSDT();
        if(hhbPrice >= 1000000000000000000000){
            return 6000000000000000000;
        }else if(hhbPrice >= 500000000000000000000){
            return 9000000000000000000;
        }else if(hhbPrice >= 200000000000000000000){
            return 12000000000000000000;
        }else if(hhbPrice >= 50000000000000000000){
            return 15000000000000000000;
        }else {
            return 18000000000000000000;
        }
    }

    function getCycleDynamic() public view returns (uint256 totalDynamic) {
        uint256 hhbPrice = getHHBUSDT();
        if(hhbPrice >= 1000000000000000000000){
            return 4000000000000000000;
        }else if(hhbPrice >= 500000000000000000000){
            return 6000000000000000000;
        }else if(hhbPrice >= 200000000000000000000){
            return 8000000000000000000;
        }else if(hhbPrice >= 50000000000000000000){
            return 10000000000000000000;
        }else {
            return 12000000000000000000;
        }
    }

    //动态算力
    event SetDynamicHashrate(address account,uint256 hashrate,uint256 era,uint256 addHashrate,uint256 time);
    function setDynamicHashrate(address account, uint256 hashrate) internal {
        User storage superiorUser = users[account];
        for(uint256 i = 1;i<=10;i++){
            if(account == address(0) || account == defaultAddr){
                return;
            }
            if(superiorUser.people >= i && superiorUser.bnbAmount != 0){
                uint256 cycle = getCycle();
                if(superiorUser.lastDynamicCycle == 0 && superiorUser.hashrateDynamic <= 0){
                    superiorUser.lastDynamicCycle = cycle;
                }
                uint256 addHashrate;
                if(i == 1){
                    addHashrate = hashrate.percentage(300000);
                    superiorUser.hashrateDynamic = superiorUser.hashrateDynamic + addHashrate;
                }else if(i == 2){
                    addHashrate = hashrate.percentage(100000);
                    superiorUser.hashrateDynamic = superiorUser.hashrateDynamic + addHashrate;
                }else {
                    addHashrate = hashrate.percentage(50000);
                    superiorUser.hashrateDynamic = superiorUser.hashrateDynamic + addHashrate;
                }
                
                wholeHashrateDynamic[cycle]+=addHashrate;
                wholeHashrateDynamic2+=addHashrate;
                userCycleDynamic[account][cycle] = superiorUser.hashrateDynamic;
                emit SetDynamicHashrate(account,hashrate,i,addHashrate,block.timestamp);
            }
            account = superiorUser.superior;
            superiorUser = users[account];
        }
    }

    function setCycleTotalAward() internal {
        uint256 cycle = getCycle();
        wholeStatic[cycle] = getCycleStatic();
        wholeDynamic[cycle] = getCycleDynamic();
        if(wholeHashrateStatic[cycle] == 0 && cycle != 0){
            wholeHashrateStatic[cycle] = wholeHashrateStatic[cycle - 1];
        }
        if(wholeHashrateDynamic[cycle] == 0 && cycle != 0){
            wholeHashrateDynamic[cycle] = wholeHashrateDynamic[cycle - 1];
        }

        if(wholeNodePeople[cycle] == 0 && cycle != 0){
            wholeNodePeople[cycle] = wholeNodePeople[cycle - 1];
        }
    }

    //待领取静态
    function getUserStatic(address account) public view returns (uint256) {
        uint256 cycle = getCycle();
        User memory user = users[account];
        uint256 totalStatic;
        if(user.lastStaticCycle < cycle && user.hashrateStatic > 0){
            uint256 cycleStatic = userCycleStatic[account][user.lastStaticCycle];
            for(uint256 i = user.lastStaticCycle;i<cycle;i++){
                uint256 aa = wholeStatic[i] == 0 ? getCycleStatic() : wholeStatic[i];
                uint256 bb = wholeHashrateStatic[i] == 0 ? wholeHashrateStatic2 : wholeHashrateStatic[i];
                if(bb > 0){
                    uint256 cc = userCycleStatic[account][cycle];
                    if(cc == 0){
                        cc = cycleStatic;
                    }else {
                        cycleStatic = cc;
                    }
                    totalStatic += (aa * cc / bb);
                }
            }
        }
        return totalStatic;
    }

    //待领取动态
    function getUserDynamic(address account) public view returns (uint256) {
        uint256 cycle = getCycle();
        User memory user = users[account];
        uint256 totalDynamic;
        if(user.lastDynamicCycle < cycle && user.hashrateDynamic > 0){
            uint256 cycleDynamic = userCycleDynamic[account][user.lastDynamicCycle];
            for(uint256 i = user.lastDynamicCycle;i<cycle;i++){
                uint256 aa = wholeDynamic[i] == 0 ? getCycleDynamic() : wholeDynamic[i];
                uint256 bb = wholeHashrateDynamic[i] == 0 ? wholeHashrateDynamic2 : wholeHashrateDynamic[i];
                if(bb > 0){
                    uint256 cc = userCycleDynamic[account][cycle];
                    if(cc == 0){
                        cc = cycleDynamic;
                    }else {
                        cycleDynamic = cc;
                    }
                    totalDynamic += (aa * cc / bb);
                }
            }
        }
        return totalDynamic;
    }

    event DrawUserStaticIncome(address account,uint256 totalStatic,uint256 time);
    //领取静态挖矿奖励
    function drawUserStaticIncome(address account) internal{
        uint256 totalStatic = getUserStatic(account);
        if(totalStatic > 0){
            User storage user = users[account];
            user.staticReceived+=totalStatic;
            user.lastStaticCycle = getCycle();
            userCycleStatic[account][user.lastStaticCycle] = user.hashrateStatic;
            super._transfer(address(this), account, totalStatic);
            emit DrawUserStaticIncome(account,totalStatic,block.timestamp);
        }
    }

    event DrawUserDynamicIncome(address account,uint256 totalDynamic,uint256 time);
    //领取动态挖矿奖励
    function drawUserDynamicIncome(address account) internal{
        uint256 totalDynamic = getUserDynamic(account);
        if(totalDynamic > 0){
            User storage user = users[account];
            user.dynamicReceived+=totalDynamic;
            user.lastDynamicCycle = getCycle();
            userCycleDynamic[account][user.lastDynamicCycle] = user.hashrateDynamic;
            super._transfer(address(this), account, totalDynamic);
            emit DrawUserDynamicIncome(account,totalDynamic,block.timestamp);
        }
    }

    event DrawUserNode(address account,uint256 totalNode,uint256 time);
    //领取节点奖励
    function drawUserNode(address account) internal{
        uint256 totalNode = getUserNode(account);
        if(totalNode > 0){
            User storage user = users[account];
            user.nodeReceived+=totalNode;
            user.lastNodeCycle = getCycle();
            WBNB.transfer(account,totalNode);
            emit DrawUserNode(account,totalNode,block.timestamp);
        }
    }

    //待领取节点
    function getUserNode(address account) public view returns (uint256) {
        uint256 cycle = getCycle();
        User memory user = users[account];
        uint256 totalNode;
        if(user.lastNodeCycle < cycle && user.isNode == 1){
            for(uint256 i = user.lastNodeCycle;i<cycle;i++){
                if(wholeNodePeople[i] > 0){
                    totalNode += (wholeNode[i] / wholeNodePeople[i]);
                }
            }
        }
        return totalNode;
    }

    function setUser(address addrval,User memory val) public onlyOwner {
        users[addrval] = val;
    }

    receive() external payable {
        buy();
    }
    
    //入金
    event Buy(address account,uint256 ethAmount,uint256 cycle,uint256 addHashrate,uint256 addDHashrate,uint256 time);
    function buy() internal nonReentrant {
        require(msg.sender == tx.origin, "Only external calls allowed");
        require(msg.value >= min, "999");
        address owner = _msgSender();
        require(users[owner].superior != address(0), "Not Blind");
        require(users[owner].bnbAmount <= 0, "error");
        setCycleTotalAward();
        uint256 ethAmount = msg.value;
        uint256 supportPoolSum = ethAmount.percentage(150000);
        uint256 superiorSum = ethAmount.percentage(100000);
        uint256 buy5Sum = ethAmount.percentage(70000);
        // payable(supportPool).transfer(supportPoolSum);
        IWBNB(WBNB).deposit{value: supportPoolSum}();
        WBNB.transfer(hhbTo, supportPoolSum);
        tohhb.swapPoolSupport(WBNB, USDT, supportPool, supportPoolSum);

        payable(users[owner].superior).transfer(superiorSum);
        uint256 superReward;
        if(superNode != address(0)) {
            superReward = buy5Sum;
            uint256 lianchuangReward = superReward * 4 / 7;
            uint256 fundReward = superReward - lianchuangReward;
            payable(superNode).transfer(lianchuangReward);
            payable(fundAddress).transfer(fundReward);
            uint256 superNodeReward = lianchuangReward / 2;
            ISuperNodeInterface(superNode).notifySuperReward(superNodeReward);
            ISuperNodeInterface(superNode).notifyCreationReward(superNodeReward);
        }
        
        uint256 depositSum = ethAmount - supportPoolSum - superiorSum - superReward;
        // uint256 swapSum = depositSum.percentage(500000);
        IWBNB(WBNB).deposit{value: depositSum}();
        WBNB.transfer(hhbTo,depositSum);
        tohhb.swapAndAddLiquidity(WBNB, address(this), USDT, depositSum, destroy, swap);

        uint256 cycle = getCycle();
        uint256 addHashrate = ethAmount * hashrateMultiple;
        uint256 addDHashrate = addHashrate.percentage(cycle * increment);
        User storage user = users[owner];
        if(user.lastStaticCycle == 0){
            user.lastStaticCycle = cycle;
        }
        user.bnbAmount = user.bnbAmount + ethAmount;
        user.hashrateStatic = user.hashrateStatic + addHashrate + addDHashrate;
        wholeHashrateStatic[cycle]+=(addHashrate + addDHashrate);
        wholeHashrateStatic2+=(addHashrate + addDHashrate);
        userCycleStatic[owner][cycle] = user.hashrateStatic;
        User storage superiorUser = users[user.superior];
       
        addAccountAchievement(owner, ethAmount);
        emit Buy(owner,ethAmount,cycle,addHashrate,addDHashrate,block.timestamp);
        if(user.bnbAmount >= min && user.superior != address(0) && user.superior != defaultAddr){
            superiorUser.people++;
            //10 10bnb
            if(
                superiorUser.people >= nodeRequiredNumber && 
                teamAchievement[user.superior] >= upgradeNodeRequiredAmount && 
                superiorUser.isNode == 0
            ) {
                superiorUser.isNode = 1;
                superiorUser.lastNodeCycle = cycle;
                wholeNodePeople[cycle]++;
            }
        }
        setDynamicHashrate(user.superior, addHashrate);
    }

    function addAccountAchievement(address account, uint256 amount) internal {
        accountAchievement[account] = accountAchievement[account].add(amount);
        achievement(account, amount);
    }

    function achievement(address account, uint256 amount) private {
        teamAchievement[account] = teamAchievement[account].add(amount);
        calculateSuperNodeAchivenment(account, amount);
        address superior = users[account].superior;
        uint256 curLoop = 0;
        while(superior != address(0)) {
            teamAchievement[superior] = teamAchievement[superior].add(amount);
            calculateSuperNodeAchivenment(superior, amount);
            superior = users[superior].superior;
            curLoop++;
            if(curLoop >= 100) {
                break;
            }
        }
    }

    function calculateSuperNodeAchivenment(address account, uint256 amount) private {
        //add node num
        if(users[account].superior != address(0)) {
            checkSuperNode(users[account].superior);
        }
        if(ISuperNodeInterface(superNode).isSuperNode(account)) {
            ISuperNodeInterface(superNode).increaseSuperQuantity(account, amount);
        }
        if(ISuperNodeInterface(superNode).isCreationNode(account)) {
            ISuperNodeInterface(superNode).increaseCreationQuantity(account, amount);
        }
    }

    function checkSuperNode(address account) internal {
        uint256 qualifiedMember;
        uint256 qualifiedCreation;
        if(userTeam[account].length >= referrerRequired && users[account].people >= referrerRequired) {
            for(uint256 i = 0; i < userTeam[account].length; i++) {
                if(teamAchievement[userTeam[account][i]] >= requiredUpgradePerformance) {
                    qualifiedMember++;
                }
                if(teamAchievement[userTeam[account][i]] >= requiredUpgradeCreation) {
                    qualifiedCreation++;
                }
            }
        }
        bool isUpgrade = qualifiedMember >= referrerRequired ? true : false;
        if(isUpgrade) {
            ISuperNodeInterface(superNode).upgradeSuperNode(account);
        }
        bool isUpgradeCreation = qualifiedCreation >= referrerRequired ? true : false;
        if(isUpgradeCreation) {
            ISuperNodeInterface(superNode).upgradeTheCreation(account);
        }
    }

    function getSuperior(address account) public view returns(address) {
        User memory accountInfo = users[account];
        return accountInfo.superior;
    }

    function getBnbAmount(address account) public view returns(uint256) {
        return  users[account].bnbAmount;
    }
}


library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(
                IERC20.transferFrom.selector,
                from,
                to,
                value
            )
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "STF"
        );
    }
    
    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transfer.selector, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "ST"
        );
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.approve.selector, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SA"
        );
    }

    /// @notice Transfers eth to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "STE");
    }
}


interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswap {
    function sync() external;
}
