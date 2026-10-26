// ============================================================
// Contract name: TokenWithVesting
// Contract address: 0x8b9abdd229ec0c4a28e01b91aacdc5daafc25c2b
// Liquidity: $31889.53
// Chain: BNB Smart Chain (56)
// Source: BscScan verified contract
// ============================================================
// ===== Original source: @openzeppelin/contracts/access/Ownable.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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


// ===== Original source: @openzeppelin/contracts/security/ReentrancyGuard.sol =====
// SPDX-License-Identifier: MIT
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


// ===== Original source: @openzeppelin/contracts/token/ERC20/ERC20.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
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
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

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
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
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
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
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
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}


// ===== Original source: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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


// ===== Original source: @openzeppelin/contracts/token/ERC20/IERC20.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


// ===== Original source: @openzeppelin/contracts/utils/Context.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.0;

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


// ===== Original source: contracts/TokenWithVesting.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// Add PancakeSwap interfaces
interface IPancakeRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

/**
 * @title TokenWithTransferVesting
 * @dev ERC20 token with vesting restrictions on transfers and dynamic fees.
 * Tokens are distributed to beneficiaries immediately, but transfers are restricted
 * based on vesting schedules. Additionally, transfers incur fees that decrease over time.
 */
contract TokenWithVesting is ERC20, Ownable, ReentrancyGuard {
    // Vesting schedule structure
    struct VestingSchedule {
        uint256 totalAmount;        // Total amount of tokens subject to vesting
        uint256 tgeAmount;          // Amount released at TGE (Token Generation Event)
        uint256 vestedAmount;       // Amount subject to vesting schedule
        uint256 vestingDuration;    // Duration of the vesting period in seconds
        uint256 vestingStartTime;   // Start time of the vesting period
        uint256 cliffDuration;      // Duration of the cliff period in seconds (0 for no cliff)
        bool initialized;           // Whether the vesting schedule is initialized
    }
    
    // Distribution percentages
    uint8 private constant LIQUIDITY_PERCENTAGE = 25;      // 25% for liquidity
    uint8 private constant PUBLIC_PERCENTAGE = 20;         // 20% for public distribution
    uint8 private constant RONALDINHO_PERCENTAGE = 20;     // 20% for Ronaldinho
    uint8 private constant MARKETING_PERCENTAGE = 15;      // 15% for marketing
    uint8 private constant TEAM_PERCENTAGE = 15;           // 15% for team
    uint8 private constant CEX_PERCENTAGE = 5;             // 5% for CEX
    
    // TGE percentages
    uint8 private constant LIQUIDITY_TGE_PERCENTAGE = 30;  // 30% at TGE
    uint8 private constant PUBLIC_TGE_PERCENTAGE = 100;    // 100% at TGE
    uint8 private constant RONALDINHO_TGE_PERCENTAGE = 0;  // 0% at TGE
    uint8 private constant MARKETING_TGE_PERCENTAGE = 14;  // 14% at TGE
    uint8 private constant TEAM_TGE_PERCENTAGE = 0;        // 0% at TGE (total lock for 6 months)
    uint8 private constant CEX_TGE_PERCENTAGE = 100;       // 100% at TGE
    
    // Vesting duration
    uint256 private constant TWO_YEARS = 730 days;         // 24 months
    uint256 private constant THREE_YEARS = 1095 days;      // 36 months
    uint256 private constant SIX_MONTHS = 180 days;        // 6 months cliff for team
    
    // Mapping from address to vesting schedule
    mapping(address => VestingSchedule) public vestingSchedules;
    
    // Mapping to track how many tokens have been transferred by each address
    mapping(address => uint256) public transferredTokens;
    
    // Addresses that are excluded from vesting restrictions
    mapping(address => bool) public excludedFromVesting;
    
    // Token metadata URI
    string public tokenURI;
    
    // Events
    event VestingScheduleCreated(address indexed beneficiary, uint256 totalAmount, uint256 tgeAmount, uint256 vestingDuration, uint256 cliffDuration);
    event ExcludedFromVesting(address indexed account, bool excluded);
    event TokensBurned(address indexed burner, uint256 amount);

    
    /**
     * @dev Constructor that initializes the token
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        address liquidityWallet,
        address publicDistributionWallet,
        address ronaldinhoWallet,
        address marketingWallet,
        address teamWallet,
        address cexWallet
    ) ERC20(name, symbol) {
        // Mint all tokens to the contract creator
        _mint(msg.sender, totalSupply);
        
        // Exclude specific addresses from vesting restrictions and fees
        _setupExclusions();
        
        // Distribute tokens and set up vesting schedules
        _distributeTokens(
            totalSupply,
            liquidityWallet,
            publicDistributionWallet,
            ronaldinhoWallet,
            marketingWallet,
            teamWallet,
            cexWallet
        );
    }
    
    /**
     * @dev Set up exclusions from vesting and fees
     */
    function _setupExclusions() private {
        // Exclude from vesting
        excludedFromVesting[owner()] = true;
        excludedFromVesting[address(this)] = true;
    }
    
    /**
     * @dev Distribute tokens to wallets and set up vesting schedules
     */
    function _distributeTokens(
        uint256 totalSupply,
        address liquidityWallet,
        address publicDistributionWallet,
        address ronaldinhoWallet,
        address marketingWallet,
        address teamWallet,
        address cexWallet
    ) private {
        // Distribute liquidity tokens
        uint256 amount = (totalSupply * LIQUIDITY_PERCENTAGE) / 100;
        _transfer(msg.sender, liquidityWallet, amount);
        _createVestingSchedule(liquidityWallet, amount, LIQUIDITY_TGE_PERCENTAGE, TWO_YEARS, 0);
        
        // Distribute public tokens
        amount = (totalSupply * PUBLIC_PERCENTAGE) / 100;
        _transfer(msg.sender, publicDistributionWallet, amount);
        _createVestingSchedule(publicDistributionWallet, amount, PUBLIC_TGE_PERCENTAGE, 0, 0);
        
        // Distribute Ronaldinho tokens
        amount = (totalSupply * RONALDINHO_PERCENTAGE) / 100;
        _transfer(msg.sender, ronaldinhoWallet, amount);
        _createVestingSchedule(ronaldinhoWallet, amount, RONALDINHO_TGE_PERCENTAGE, THREE_YEARS, SIX_MONTHS);
        
        // Distribute marketing tokens
        amount = (totalSupply * MARKETING_PERCENTAGE) / 100;
        _transfer(msg.sender, marketingWallet, amount);
        _createVestingSchedule(marketingWallet, amount, MARKETING_TGE_PERCENTAGE, TWO_YEARS, 0);
        
        // Distribute team tokens - 0% TGE, 6 months cliff, 36 months vesting
        amount = (totalSupply * TEAM_PERCENTAGE) / 100;
        _transfer(msg.sender, teamWallet, amount);
        _createVestingSchedule(teamWallet, amount, TEAM_TGE_PERCENTAGE, THREE_YEARS, SIX_MONTHS);
        
        // Distribute CEX tokens
        amount = (totalSupply * CEX_PERCENTAGE) / 100;
        _transfer(msg.sender, cexWallet, amount);
        _createVestingSchedule(cexWallet, amount, CEX_TGE_PERCENTAGE, 0, 0);
    }
    
    /**
     * @dev Creates a vesting schedule for a beneficiary
     * @param beneficiary Address of the beneficiary
     * @param totalAmount Total amount of tokens subject to vesting
     * @param tgePercentage Percentage of tokens released at TGE (0-100)
     * @param vestingDuration Duration of the vesting period in seconds
     * @param cliffDuration Duration of the cliff period in seconds
     */
    function _createVestingSchedule(
        address beneficiary,
        uint256 totalAmount,
        uint256 tgePercentage,
        uint256 vestingDuration,
        uint256 cliffDuration
    ) private {
        require(tgePercentage <= 100, "TGE percentage cannot exceed 100%");
        require(!vestingSchedules[beneficiary].initialized, "Vesting schedule already exists");
        
        uint256 tgeAmount = (totalAmount * tgePercentage) / 100;
        uint256 vestedAmount = totalAmount - tgeAmount;
        
        VestingSchedule storage schedule = vestingSchedules[beneficiary];
        schedule.totalAmount = totalAmount;
        schedule.tgeAmount = tgeAmount;
        schedule.vestedAmount = vestedAmount;
        schedule.vestingDuration = vestingDuration;
        schedule.vestingStartTime = block.timestamp;
        schedule.cliffDuration = cliffDuration;
        schedule.initialized = true;
        
        emit VestingScheduleCreated(beneficiary, totalAmount, tgeAmount, vestingDuration, cliffDuration);
    }
    
    /**
     * @dev Calculates the amount of tokens that can be transferred by an address
     * @param account Address to check
     * @return The amount of tokens that can be transferred
     */
    function getTransferableAmount(address account) public view returns (uint256) {
        if (excludedFromVesting[account]) {
            return balanceOf(account);
        }
        
        VestingSchedule storage schedule = vestingSchedules[account];
        if (!schedule.initialized) {
            return balanceOf(account);
        }
        
        // Check if we're still in cliff period
        if (block.timestamp < schedule.vestingStartTime + schedule.cliffDuration) {
            return _getAvailableAmount(schedule.tgeAmount, account); // Only TGE amount is available during cliff
        }
        
        return _calculateTransferableAmount(account, schedule);
    }
    
    /**
     * @dev Helper function to calculate transferable amount after cliff period
     * @param account Address to check
     * @param schedule Vesting schedule for the account
     * @return The amount of tokens that can be transferred
     */
    function _calculateTransferableAmount(address account, VestingSchedule storage schedule) private view returns (uint256) {
        // TGE amount is immediately transferable
        uint256 transferable = schedule.tgeAmount;
        
        // Calculate vested amount based on time elapsed since cliff ended
        if (schedule.vestingDuration > 0 && schedule.vestedAmount > 0) {
            uint256 timeAfterCliff = block.timestamp - (schedule.vestingStartTime + schedule.cliffDuration);
            
            if (timeAfterCliff >= schedule.vestingDuration) {
                // Vesting completed, all tokens are transferable
                transferable = schedule.totalAmount;
            } else {
                // Linear vesting calculation after cliff
                uint256 vestedTokens = (schedule.vestedAmount * timeAfterCliff) / schedule.vestingDuration;
                transferable = schedule.tgeAmount + vestedTokens;
            }
        }
        
        return _getAvailableAmount(transferable, account);
    }

    /**
     * @dev Validates if a transfer is allowed based on vesting schedule
     */
    function _validateTransfer(address sender, uint256 amount) private {
        // Skip validation for excluded addresses
        if (excludedFromVesting[sender]) {
            return;
        }
        
        uint256 transferable = getTransferableAmount(sender);
        require(amount <= transferable, "Transfer amount exceeds vested tokens");
        
        // Update transferred tokens
        transferredTokens[sender] += amount;
    }
    
    /**
     * @dev Helper function to subtract already transferred tokens
     * @param transferable Gross transferable amount
     * @param account Address to check
     * @return Net transferable amount
     */
    function _getAvailableAmount(uint256 transferable, address account) private view returns (uint256) {
        // Subtract already transferred tokens
        if (transferredTokens[account] >= transferable) {
            return 0;
        }
        
        return transferable - transferredTokens[account];
    }

    /**
     * @dev Override _transfer to apply fees
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        // Validate vesting before transfer - usando o valor total para validação
        if (!excludedFromVesting[sender]) {
            _validateTransfer(sender, amount);
        }
        
        // Transfer tokens to recipient
        super._transfer(sender, recipient, amount);
    }
    
    
    /**
     * @dev Exclude or include an account from vesting restrictions
     * @param account Address to exclude/include
     * @param excluded Whether the account should be excluded
     */
    function setExcludedFromVesting(address account, bool excluded) external onlyOwner {
        excludedFromVesting[account] = excluded;
        emit ExcludedFromVesting(account, excluded);
    }
    
    /**
     * @dev Set token URI for metadata
     * @param _tokenURI New token URI
     */
    function setTokenURI(string memory _tokenURI) external onlyOwner {
        tokenURI = _tokenURI;
    }
    
    /**
     * @dev Get vesting information for an address
     * @param account Address to check
     * @return totalAmount Total amount of tokens subject to vesting
     * @return tgeAmount Amount released at TGE
     * @return vestedAmount Amount subject to vesting schedule
     * @return vestingDuration Duration of the vesting period in seconds
     * @return vestingStartTime Start time of the vesting period
     * @return cliffDuration Duration of the cliff period in seconds
     * @return transferableAmount Amount that can be transferred now
     * @return transferredAmount Amount already transferred
     */
    function getVestingInfo(address account) external view returns (
        uint256 totalAmount,
        uint256 tgeAmount,
        uint256 vestedAmount,
        uint256 vestingDuration,
        uint256 vestingStartTime,
        uint256 cliffDuration,
        uint256 transferableAmount,
        uint256 transferredAmount
    ) {
        VestingSchedule storage schedule = vestingSchedules[account];
        
        // Get transferable amount separately to avoid stack too deep error
        uint256 _transferableAmount = getTransferableAmount(account);
        uint256 _transferredAmount = transferredTokens[account];
        
        return (
            schedule.totalAmount,
            schedule.tgeAmount,
            schedule.vestedAmount,
            schedule.vestingDuration,
            schedule.vestingStartTime,
            schedule.cliffDuration,
            _transferableAmount,
            _transferredAmount
        );
    }

    /**
     * @dev Burns a specific amount of tokens from the caller's account.
     * Reduces the total supply.
     * @param amount The amount of tokens to burn
     */
    function burn(uint256 amount) external nonReentrant returns (bool) {
        address account = _msgSender();
        require(amount > 0, "Burn amount must be greater than zero");
        require(balanceOf(account) >= amount, "Burn amount exceeds balance");
        
        // If account has vesting, validate that they can burn these tokens
        if (!excludedFromVesting[account]) {
            uint256 transferable = getTransferableAmount(account);
            require(amount <= transferable, "Burn amount exceeds vested tokens");
            
            // Update transferred tokens to account for burned tokens
            transferredTokens[account] += amount;
        }
        
        // Burn the tokens
        _burn(account, amount);
        
        emit TokensBurned(account, amount);
        return true;
    }

    /**
     * @dev Burns tokens from a specific account. Can only be called by the owner.
     * Useful for removing tokens from circulation or implementing token reduction mechanisms.
     * @param account The account to burn tokens from
     * @param amount The amount of tokens to burn
     */
    function burnFrom(address account, uint256 amount) external onlyOwner nonReentrant returns (bool) {
        require(amount > 0, "Burn amount must be greater than zero");
        require(balanceOf(account) >= amount, "Burn amount exceeds balance");
        
        // Burn the tokens
        _burn(account, amount);
        
        emit TokensBurned(account, amount);
        return true;
    }
    
    /**
     * @dev Allow contract to receive BNB
     */
    receive() external payable {}
} 
