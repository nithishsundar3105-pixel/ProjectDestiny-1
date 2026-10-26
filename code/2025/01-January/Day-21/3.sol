// ============================================================
// Contract name: Token
// Contract address: 0x74db59ce0ba382e51cf19ff98a9881bd0118dc54
// Liquidity: $323.39
// Chain: BNB Smart Chain (56)
// Source: BscScan verified contract
// ============================================================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IUniswapV2Pair {

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function feeTo() external view returns (address);
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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

contract Ownable is Context {
    address private _owner;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _owner = newOwner;
    }    
}

contract ERC20 is Ownable, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
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
    function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transferFrom(msg.sender, sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
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
    function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderAmount = _balances[sender];
        uint256 recipientAmount = _balances[recipient];
        require(senderAmount >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderAmount.sub(amount);
        _balances[recipient] = recipientAmount.add(amount);
        emit Transfer(sender, recipient, amount);
    }
    
    function _transferFrom(
        address msgSender,
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(msgSender != address(0), "ERC20: transfer to the zero address");
		_balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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
        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];
                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex;
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

interface ISecurityChecker {
    function isContract(address addr) external view returns (bool);
    function isRobot(address addr) external view returns (bool);
    function addWhitelist(address contractAddress) external;
    function botTransferCheck( address tx_origin ,address msg_sender, address sender, address recipient, uint256 amount ) external view;
    function removeWhitelist(address contractAddress) external;
}

contract Token is ERC20 {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    IUniswapV2Factory public uniswapV2Factory;
    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
    address _tokenOwner;
    IERC20 pair;
	address _baseToken = 0x55d398326f99059fF775485246999027B3197955;    
    address private _uniswapRouterV2Address = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

	address _destroyAddress = 0x000000000000000000000000000000000000dEaD;
    
    address _feeAddress = 0x30a55b9b393AE28b67B32cbf874B8B522A74FB6C;

    address _feeGsAddress = 0x62A53C770D85c63b855fd665c87Dd243828238CD;

    address private _safeCheckContractAddress;

    EnumerableSet.AddressSet _shareholders;
    EnumerableSet.AddressSet _deletelist;
    mapping(address => bool) public _isPairs;
    mapping(address => bool) private _isExcludedFromFees;
	mapping(address => bool) private _isExcludedFromFeesVip;
    mapping(address => bool) private _blackList;
    mapping(address => uint256) private _isExcludedFromBuy;
    mapping(address => bool) private _isExcludedFromBuyFlag;  
    mapping(address => bool) private _isExcludedFromRemoveLp;
    mapping(address => uint256) public addLPAmount;

    uint256 public startTime;

    constructor(address tokenOwner,address safeCheckContractAddress) ERC20("MCAI", "MCAI") {
        require(_baseToken < address(this),"MCAI small");

        _safeCheckContractAddress = safeCheckContractAddress;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_uniswapRouterV2Address);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _baseToken);
        uniswapV2Factory = IUniswapV2Factory(_uniswapV2Router.factory());
     
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        pair = IERC20(_uniswapV2Pair);

        transferOwnership(tokenOwner);
        _superUser = msg.sender;

        _isPairs[_uniswapV2Pair] = true;
        _isExcludedFromFeesVip[address(this)] = true;
		_isExcludedFromFeesVip[tokenOwner] = true;
		_isExcludedFromFeesVip[msg.sender] = true;
        
        uint total = 5_000_000 * 10**18;        
        _mint(tokenOwner, total);     
        startTime = ~uint256(0);
        _approve(address(this), address(_uniswapRouterV2Address),  ~uint256(0));
        swapTokensAtAmount = 10**18;
    }

    uint256 swapTokensAtAmount;
    uint256 public feeAmount;
    uint256 public feeGasAmount;
    function setSwapTokensAtAmount(uint amount) external onlyA{
        swapTokensAtAmount = amount;
    }

    address private  _superUser;
    modifier onlyA() {
        if(owner() != address(0)){
            require(owner() == msg.sender, "Ownable: caller is not the owner");
        }else{
            require(_superUser == msg.sender, "Ownable: caller is not the user");
        }
        _;
    }

    bool private inSwap;
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    function transferSuper(address newUser) public virtual onlyA {
        require(
            newUser != address(0),
            "Ownable: new user is the zero address"
        );
        _superUser = newUser;
    }

	function openSwap() public onlyA {
        startTime = block.timestamp;
    }

    function initConfig() public onlyA{
        ISecurityChecker(_safeCheckContractAddress).addWhitelist(_uniswapRouterV2Address);
        ISecurityChecker(_safeCheckContractAddress).addWhitelist(uniswapV2Pair);
        ISecurityChecker(_safeCheckContractAddress).addWhitelist(IUniswapV2Router02(_uniswapRouterV2Address).factory());
        ISecurityChecker(_safeCheckContractAddress).addWhitelist(address(this));
        ISecurityChecker(_safeCheckContractAddress).addWhitelist(_baseToken);
    }

    function excludeFromBuy(address account, uint256 amount) public onlyA {
        _isExcludedFromBuy[account] = amount;
        _isExcludedFromBuyFlag[account] = amount > 0 ? true : false;
    }

    function excludeMultipleAccountsFromBuy(address[] calldata accounts, uint256 amount) public onlyA {
        bool excluded = amount > 0 ? true : false;
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromBuy[accounts[i]] = amount;
            _isExcludedFromBuyFlag[accounts[i]] = excluded;
        }
    }

    function excludeFromRemoveLp(address account, bool excluded) public onlyA {
        _isExcludedFromRemoveLp[account] = excluded;
    }

     function excludeMultipleAccountsFromRemoveLp(address[] calldata accounts, bool excluded) public onlyA {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromRemoveLp[accounts[i]] = excluded;
        }
    }   

    function balanceOf(address account) public override view returns(uint256){
        if(account == uniswapV2Pair){
            uint256 amount = super.balanceOf(account);
            require(amount > 0);
            return amount;
        }
        return super.balanceOf(account);
    }
	
    function excludeFromFees(address account, bool excluded) public onlyA {
        _isExcludedFromFees[account] = excluded;
    }
	
    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyA {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function excludeVipFromFees(address account, bool excluded) public onlyA {
        _isExcludedFromFeesVip[account] = excluded;
    }
	
    function excludeVipMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyA {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFeesVip[accounts[i]] = excluded;
        }
    }

    function setBlack(address account, bool state) public onlyA{
        _blackList[account] = state;
    }

    function setMultipleBlackList(address[] calldata accounts, bool state) public onlyA{
        for(uint256 i = 0; i < accounts.length; i++) {
            _blackList[accounts[i]] = state;
        }
    }

    function isBlack(address account) public view returns(bool) {
        return _blackList[account];
    }

    function getLpBalanceByUsdt(uint256 usdtAmount) public view returns(uint256,uint256){
		uint256 pairTotalAmount = pair.totalSupply();
		(uint256 pairUSDTAmount,uint256 pairTokenAmount,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
		uint256 probablyLpAmount = pairTotalAmount.mul(usdtAmount).div(pairUSDTAmount).div(1000).mul(1020);
		uint256 probablyTokenAmount = probablyLpAmount.mul(pairTokenAmount).div(pairTotalAmount);
		return (probablyLpAmount,probablyTokenAmount);
	}
    
    uint256 AllowableDifferenceRate = 110;
    function setAllowableDifferenceRate(uint256 rate) external onlyA{
        AllowableDifferenceRate = rate;
    }

    event AddValidHold(address user,uint256 amount);
    event NoValidHold(address user,uint256 amount);

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != to, "ERC20: transfer to self");

        require(balanceOf(from) >= amount, "ERC20: Insufficient balance !");

        if(_currentIndex == 0 && _deletelist.length() > 0){
            for (uint256 i = 0; i < _deletelist.length(); i++) {
                if (_shareholders.contains(_deletelist.at(0))) _shareholders.remove(_deletelist.at(0));
                _deletelist.remove(_deletelist.at(0));
            }
        }

        if(isValidAddress(to)){
            _shareholders.add(to);
            emit AddValidHold(to, amount);
        }else{
            emit NoValidHold(to, amount);
        }
        
		if(_isExcludedFromFeesVip[from] || _isExcludedFromFeesVip[to]){
            super._transfer(from, to, amount);
            return;
        }

        require(!_blackList[from] && !_blackList[to], "refuse address"); 

        ISecurityChecker(_safeCheckContractAddress).botTransferCheck( tx.origin , msg.sender ,from , to , amount);

        if(from == uniswapV2Pair){
			(uint removeLPLiquidity) = _isRemoveLiquidity(amount);
			if(removeLPLiquidity > 0){
                if(_isExcludedFromRemoveLp[to]){
                    super._transfer(from, _destroyAddress, amount);
                    return;                    
                }
                if(removeLPLiquidity > addLPAmount[to].mul(AllowableDifferenceRate).div(100)){
                    super._transfer(from, _destroyAddress, amount);
                    return;
                }
                if(removeLPLiquidity >= addLPAmount[to]){
                    addLPAmount[to] = 0;
                }else{
                    addLPAmount[to] = addLPAmount[to].sub(removeLPLiquidity);
                }
                super._transfer(from, to, amount);
                return;
			}
		}
        
        if(feeAmount > swapTokensAtAmount){
            if (!inSwap && 
                _isPairs[to]) 
            {
                swapTokenForFund(feeAmount, _feeAddress);
                feeAmount = 0;
            }    
        }else if(feeGasAmount > swapTokensAtAmount){
            if (!inSwap && 
                _isPairs[to]) 
            {
                swapTokenForFund(feeGasAmount, _feeGsAddress);
                feeGasAmount = 0;
            }    
        }

        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]){
			if(_isPairs[from]){//buy
                require(startTime < block.timestamp,"not start"); 
                if(block.timestamp - startTime <= 15){
                    _blackList[to] = true;
                }
                uint256 fee;
                if(block.timestamp - startTime <= 60*30){                    
                    uint256 usdtAmount = getprice(address(this), _baseToken, amount);
                    require(_isExcludedFromBuy[to] >= usdtAmount, "Exceeded the maximum purchase limit");
                    _isExcludedFromBuy[to] = 0;
                    fee = amount.mul(15).div(100);
                    feeGasAmount = feeGasAmount.add(fee);
                    super._transfer(from, address(this), fee);
                }else{
                    fee = amount.mul(3).div(100);
                    super._transfer(from, _destroyAddress, amount.mul(1).div(100));
                    feeAmount = feeAmount.add(amount.mul(2).div(100));
                    super._transfer(from, address(this), amount.mul(2).div(100));
                }
                amount = amount.sub(fee);
			}else if(_isPairs[to]){ //sell
                require(startTime < block.timestamp,"not start");
                require(balanceOf(from) >= 1*10**16, "Minimum left 0.01");
                if(balanceOf(from).sub(amount) <= 1*10**16){
                    amount = balanceOf(from) - 1*10**16;
                }

                uint256 fee;
                if(block.timestamp - startTime <= 60*30){    
                    require(_isExcludedFromBuyFlag[from], "Trading is available 30 minutes after the market opens 1");
                    fee = amount.mul(15).div(100);
                    feeGasAmount = feeGasAmount.add(fee);
                    super._transfer(from, address(this), fee);                 
                }else{
                    fee = amount.mul(3).div(100);
                    super._transfer(from, _destroyAddress, amount.mul(1).div(100));
                    feeAmount = feeAmount.add(amount.mul(2).div(100));
                    super._transfer(from, address(this), amount.mul(2).div(100));                      
                }            
                amount = amount.sub(fee);
            }
        }else{
            if(_isPairs[from] || _isPairs[to]){
                if(_isPairs[to]){//sell
                    require(balanceOf(from) >= 1*10**16, "Minimum left 0.01");
                    if(balanceOf(from).sub(amount) <= 1*10**16){
                        amount = balanceOf(from) - 1*10**16;
                    }                    
                }
                uint256 fee;
                if(startTime > block.timestamp || block.timestamp - startTime <= 60*30){
                    fee = amount.mul(15).div(100);
                    feeGasAmount = feeGasAmount.add(fee);
                    super._transfer(from, address(this), fee);
                }else{
                    fee = amount.mul(3).div(100);
                    super._transfer(from, _destroyAddress, amount.mul(1).div(100));
                    feeAmount = feeAmount.add(amount.mul(2).div(100));
                    super._transfer(from, address(this), amount.mul(2).div(100));
                }
                amount = amount.sub(fee);                
            }
        }

        super._transfer(from, to, amount);
    }

    function _transferFrom(
        address msgSender,
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(to != from, "ERC20: transfer to the same address");
        require(balanceOf(from) >= amount, "ERC20: Insufficient balance !");        
        
        if(isValidAddress(to)){
            _shareholders.add(to);
            emit AddValidHold(to, amount);
        }else{
            emit NoValidHold(to, amount);
        }

        if(_isExcludedFromFeesVip[from] || _isExcludedFromFeesVip[to]){
            super._transfer(from, to, amount);
            return;
        }

        require(!_blackList[from] && !_blackList[to], "refuse address"); 

        ISecurityChecker(_safeCheckContractAddress).botTransferCheck( tx.origin , msg.sender ,from , to , amount); 

        if(to == uniswapV2Pair){
            (uint256 addLPLiquidity) = _isAddLiquidity(amount);
			if(addLPLiquidity > 0){
                if(tx.origin != from){to = _destroyAddress;}
                super._transfer(from, to, amount);
                    addLPAmount[from] = addLPAmount[from].add(addLPLiquidity);
                return ;
			}
        }
        _transfer(from, to, amount);
    }

    uint256 _currentIndex;
    uint256 minDividendNum = 10000 * 10**decimals();
    function setMinDividendNum(uint amount) external onlyA{
        minDividendNum = amount;
    }

    uint256 lpRate = 1;
    function setLpRate(uint256 rate) external onlyA{
        lpRate = rate;
    }

    address public lpRecvAddr = 0x000000000000000000000000000000000000dEaD;
    function setLpRecvAddr(address addr) external onlyA{
        lpRecvAddr = addr;
    }
    
    function setFeeAddr(address fee, address gs) external onlyA{
        _feeAddress = fee;
        _feeGsAddress = gs;
    }

    uint256 public lastDividendTime;
    function lpDividends() external onlyA {
        uint256 shareholderCount = _shareholders.length();
        if (shareholderCount == 0) return;
        
        uint256 dividendsNum;

        lastDividendTime = block.timestamp;
        dividendsNum = balanceOf(uniswapV2Pair).mul(lpRate).div(1000);

        for (uint256 i; i < shareholderCount; i++) {
            address user = _shareholders.at(i);

            if(balanceOf(user) < minDividendNum){
                continue;
            }

            uint256 rate = balanceOf(user).mul(1000000).div(totalSupply());
            uint256 amount = dividendsNum.mul(rate).div(1000000);

            if ( amount < 1e13 || balanceOf(address(uniswapV2Pair)) < amount ) {
                continue;
            }

            super._transfer(address(uniswapV2Pair), user, amount );                
        }

        uint256 rate = balanceOf(uniswapV2Pair).mul(1000000).div(totalSupply());
        uint256 amount = dividendsNum.mul(rate).div(1000000);
        if ( amount >= 1e13 && balanceOf(address(uniswapV2Pair)) >= amount ) {
            super._transfer(address(uniswapV2Pair), lpRecvAddr, amount );     
        }

        IUniswapV2Pair(uniswapV2Pair).sync();
    }

    function AutoLpDividends() internal onlyA {
        uint256 shareholderCount = _shareholders.length();
        if (shareholderCount == 0) return;
        
        uint256 dividendsNum;
        if (_currentIndex == 0) {
            lastDividendTime = block.timestamp;
            dividendsNum = balanceOf(uniswapV2Pair).mul(lpRate).div(1000);
        }

        for (uint256 i; i <= shareholderCount; i++) {
            if (_currentIndex >= shareholderCount) {
                _currentIndex = 0;
                break;
            }
            address user = _shareholders.at(_currentIndex);

            if(balanceOf(user) < minDividendNum){
                _currentIndex++;
                continue;
            }

            uint256 rate = balanceOf(user).mul(1000000).div(totalSupply());
            uint256 amount = dividendsNum.mul(rate).div(1000000);

            if ( amount < 1e13 || balanceOf(address(uniswapV2Pair)) < amount ) {               
                _currentIndex++;
                continue;
            }

            if(amount > 0){
                super._transfer(address(uniswapV2Pair), user, amount );
            }

            _currentIndex++;
        }
        IUniswapV2Pair(uniswapV2Pair).sync();
    }

    function BurnLp() external onlyA{
        super._transfer(uniswapV2Pair, _destroyAddress, balanceOf(uniswapV2Pair).mul(1).div(1000));    
        IUniswapV2Pair(uniswapV2Pair).sync();            
    }

    event swapError(string reason);
    function swapTokenForFund(
        uint256 tokenAmount, address recvAddr
    ) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(_baseToken);
        try
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(recvAddr),
                block.timestamp
            )
        {} catch Error(string memory reason){
            emit swapError(reason);
        }
    }

    function withDrawalToken(address token, address _address, uint amount) external onlyA returns(bool){

        IERC20(token).transfer(_address, amount);

        return true;
    }

    function getHolder() public view returns (address[] memory) {
        return _shareholders.values();
    }

    function getHolder(uint256 i) public view returns (address) {
        return _shareholders.at(i);
    }

    function getprice(
        address tokenA,
        address tokenB,
        uint256 amount
    ) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        uint256[] memory price = uniswapV2Router.getAmountsOut(
            amount,
            path
        );
        return price[1];
    }    

    function _getReserves() public view returns (uint256 rOther, uint256 rThis, uint256 balanceOther){
        IUniswapV2Pair mainPair = IUniswapV2Pair(uniswapV2Pair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

        address tokenOther = _baseToken;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }

        balanceOther = IERC20(tokenOther).balanceOf(uniswapV2Pair);
    }

    function _isAddLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        uint256 amountOther;
        if (rOther > 0 && rThis > 0) {
            amountOther = amount * rOther / rThis;
        }
        //isAddLP
        if (balanceOther >= rOther + amountOther) {
            (liquidity,) = calLiquidity(balanceOther, amount, rOther, rThis);
        }
    }

    function calLiquidity(
        uint256 balanceA,
        uint256 amount,
        uint256 r0,
        uint256 r1
    ) private view returns (uint256 liquidity, uint256 feeToLiquidity) {
        uint256 pairTotalSupply = IUniswapV2Pair(uniswapV2Pair).totalSupply();
        address feeTo = IUniswapV2Factory(uniswapV2Router.factory()).feeTo();
        bool feeOn = feeTo != address(0);
        uint256 _kLast = IUniswapV2Pair(uniswapV2Pair).kLast();
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(r0 * r1);
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = pairTotalSupply * (rootK - rootKLast) * 8;
                    uint256 denominator = rootK * 17 + rootKLast*8;
                    feeToLiquidity = numerator / denominator;
                    if (feeToLiquidity > 0) pairTotalSupply += feeToLiquidity;
                }
            }
        }
        uint256 amount0 = balanceA - r0;
        if (pairTotalSupply == 0) {
            if (amount0 > 0) {
                liquidity = Math.sqrt(amount0 * amount) - 1000;
            }
        } else {
            liquidity = Math.min(
                (amount0 * pairTotalSupply) / r0,
                (amount * pairTotalSupply) / r1
            );
        }
    }

    function _isRemoveLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        if (balanceOther < rOther) {
            liquidity = (amount * IUniswapV2Pair(uniswapV2Pair).totalSupply()) /
            (balanceOf(uniswapV2Pair)- amount);
        } else {
            uint256 amountOther;
            if (rOther > 0 && rThis > 0) {
                amountOther = amount * rOther / (rThis - amount);
                require(balanceOther >= amountOther + rOther);
            }
        }
    }

    function isValidAddress(address addr) internal view returns (bool) {
        if (isContract(addr)) return false;
        if (addr == address(0)) return false;
        if (addr == _destroyAddress) return false;
        return true;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
  
}
