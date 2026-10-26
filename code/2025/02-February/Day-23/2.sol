// ============================================================
// Contract name: SNP
// Contract address: 0x3a9e15b28e099708d0812e0843a9ed70c508fb4b
// Liquidity: $5352.65
// Chain: BNB Smart Chain (56)
// Source: BscScan verified contract
// ============================================================
pragma solidity ^0.8.28;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Collection of functions related to the address type
 */
library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    function setOwner(address _newOwner) internal {
        _owner = _newOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}

// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

 
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

  
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

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
    ) external returns (uint amountToken, uint amountETH);
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

contract SNP is Context, IERC20, Ownable {
    using Address for address;
    using Address for address payable;

    // ROUTER SETTINGS
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    // MAIN WALLET ADDRESSES
    address constant public DEAD                    = 0x000000000000000000000000000000000000dEaD;
    address constant public ZERO                    = 0x0000000000000000000000000000000000000000;
    address constant public MINT                    = 0x69b90DfFB77cAe9330d20337A70f2C156FA91FC6; 
    address constant public MARKETING               = 0xd4B2F2C5F3826Cc40dAF2BaCC22d30948f34f24D; 
    address constant public PROJECT                 = 0x69b90DfFB77cAe9330d20337A70f2C156FA91FC6; 

    // TOKEN GLOBAL VARIABLES
    string constant private _name                    = "Snappy";
    string constant private _symbol                  = "SNAP";
    uint8  constant private _decimals                = 18;
    uint256         private _totalSupply             = 1000000000 * 10 ** _decimals;

    // MAPPINGS
    mapping (address => uint256) private               _balances;
    mapping (address => bool) public                   isFeeExempt;
    mapping (address => bool) public                   liquidityAddress;
    mapping (address => mapping (address => uint256)) private  _allowances;

    // BUY & TRANSFER FEE
    uint256 constant public transferTaxRate          = 500;
    bool    constant public takeFeeIfNotLiquidity    = false;
    bool             public enableTrading            = false;

    // SELL FEE & DISTRIBUTION SETTINGS
    uint256 constant public burnFee                  = 100;
    uint256 constant public liquidityFee             = 0;
    uint256 constant public marketingFee             = 100;
    uint256 constant public projectFee               = 300; 

    // SETS UP TOTAL FEE
    uint256 constant public totalFee = (marketingFee + burnFee + liquidityFee + projectFee);

    // MAX TOTAL FEE SHOULD BE REASONABLE.
    uint256 constant public MAX_TOTAL_FEE            = 1000;

    // FEE DENOMINATOR CANNOT BE CHANGED.
    uint256 constant public feeDenominator           = 10000;
    
    bool private swapping;

    event Burn(uint256 indexed amount);
    event AdminTokenRecovery(address tokenAddress, uint256 tokenAmount);     

    // TOKEN SWAP SETTINGS
    bool           inSwap;
    uint256 public swapThreshold                     = _totalSupply / 100000 *  1; // MINIMUM SWAPBACK 0,001%
    uint256 public MAX_SWAPBACK                      = _totalSupply / 10000 * 100; // MAXIMUM SWABACK 1,00%
        
    constructor () {
        // GLOBAL REQUIREMENTS
        require(totalFee <= MAX_TOTAL_FEE,"totalFee must be reasonable. Check MAX_TOTAL_FEE");
        require(MAX_TOTAL_FEE < feeDenominator,"MAX_TOTAL_FEE must be reasonable according to feeDenominator.");

        // ROUTER SETTINGS
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address ethPair  = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router                              = _uniswapV2Router;
        uniswapV2Pair                                = ethPair;

        // FEE EXEMPTS 
        isFeeExempt[address(this)]                   = true;
        isFeeExempt[DEAD]                            = true;
        isFeeExempt[PROJECT]                         = true;
        isFeeExempt[MINT]                            = true;

        // LIQUIDITY ADDRESSES
        liquidityAddress[uniswapV2Pair]              = true;

        // INITIAL DISTRIBUTION
        _balances[MINT]                              = _totalSupply;
        
        // DEPLOY EVENTS
        emit Transfer(address(0), MINT, _totalSupply);
    }

    function name() public pure returns (string memory) { return _name; }

    function symbol() public pure returns (string memory) { return _symbol; }

    function decimals() public pure returns (uint8) { return _decimals; }

    function totalSupply() public view override returns (uint256) { return _totalSupply; }

    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }

    function allowance(address owner, address spender) public view override returns (uint256) { return _allowances[owner][spender]; }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(_allowances[sender][_msgSender()] >= amount, "Not enough allowance");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }
    
     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    // FALLBACK FUNCTION. DO NOT TRY TO FOOL MY SMART CONTRACT
    uint private n = 0;
    fallback() external payable {
        n = 0;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        // GLOBAL REQUIREMENTS
        require(enableTrading || isFeeExempt[sender], "Trading is not enabled");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must not be zero");
        // SHOULD I SWAP BACK?
        shouldSwapBack(sender, recipient);
        // NICE, YOU DID IT
        trade(sender, recipient, amount); 
    } 
    // TRADES TOKENS BETWEEN WALLETS
    function trade(address sender, address recipient, uint256 amount) private returns (uint256) {
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        // EXCHANGE TOKENS
        _balances[sender] -= amount;
        _balances[recipient] += amountReceived;
        emit Transfer(sender, recipient, amountReceived);
        return amountReceived;
    }  
    // SHOULD I SWAP BACK?
    function shouldSwapBack(address from, address to) private {
        if (balanceOf(address(this)) >= swapThreshold 
        && !swapping && !liquidityAddress[from] 
        && from != owner() 
        && to != owner()) {
            if (!liquidityAddress[from]) {
                swapping = true;
                swapBack();
                swapping = false;
            }
        }
    }   
    // TAKES CONTRACT FEE
    function takeFee(address sender, address recipient, uint256 amount) private returns (uint256) {
        if (   !liquidityAddress[sender]
            && !liquidityAddress[recipient]
            && sender != address(uniswapV2Router)
            && recipient != address(uniswapV2Router)
            && msg.sender != address(uniswapV2Router)
            && !takeFeeIfNotLiquidity) {
            return amount;
        }
        uint256 feeAmount   = 0;
        address feeReceiver = address(this);
        bool    feeTaken    = false;
        if (!feeTaken && liquidityAddress[recipient] && totalFee > 0) {
            feeAmount = (amount * totalFee / feeDenominator);
        }
        else if (!feeTaken) {
            feeAmount = (amount * transferTaxRate / feeDenominator);
        }
        if (feeAmount > 0) {
            _balances[feeReceiver] += feeAmount;
            emit Transfer(sender, feeReceiver, feeAmount);
            return (amount - feeAmount);
        } else {
            return amount;
        }
    }
    // SHOULD WE TAKE ANY TRANSACTION FEE ON THIS?
    function shouldTakeFee(address sender, address recipient) private view returns (bool) {
         if (!isFeeExempt[sender] && !isFeeExempt[recipient]) {
             return true;
         }
         else { return false; }
    } 
    // BASIC TRANSFER METHOD
    function _basicTransfer(address sender, address recipient, uint256 amount) private returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }     
    //SWAPS BACK
    function swapBack() private {
        // SETS UP AMOUNT THAT NEEDS TO BE SWAPPED
        uint256 amount = (balanceOf(address(this)));
        if (amount > MAX_SWAPBACK) {
            amount = MAX_SWAPBACK;
        }
        // CHECKS IF THERE IS ANY FEE THAT NEEDS TOKENS TO BE SWAPPED
        if (amount > 0 && balanceOf(address(this)) >= amount) {
            // GLOBAL SETUP
            uint256 amountLIQUIDITY = 0;
            uint256 amountLIQUIFY   = 0;
            uint256 amountETH       = 0;
            uint256 amountBURN      = 0;
            uint256 amountMARKETING = 0;
            // DENOMINATOR
            uint256 ethDenominator  = (totalFee - burnFee);

            // BURNS TOKENS
            amountBURN = (amount * burnFee / totalFee);
            if (burnFee > 0 && balanceOf(address(this)) >= amountBURN) {
                _basicTransfer(address(this), DEAD, amountBURN);
                emit Burn(amountBURN);
            }

            // LIQUIDITY RESERVE
            if (liquidityFee > 0) {
                amountLIQUIFY = (amount * (liquidityFee / 2) / totalFee);
                // DEFINES NEW DENOMINATOR
                ethDenominator -= liquidityFee;
            }   

            // SWAPS EVERYTHING BACK TO BNB
            amount -= amountBURN;
            amount -= amountLIQUIFY;
            amountETH = swapTokensForEth(amount);
            if (amountETH > 0) {
                // SETUP LIQUIDITY FIRST             
                amountLIQUIDITY = (amountETH * (liquidityFee / 2) / ethDenominator);
                // ADDS LIQUIDITY IF THERE IS ANY TO BE ADDED
                if(amountLIQUIDITY > 0 
                && address(this).balance >= amountLIQUIDITY 
                && balanceOf(address(this)) >= amountLIQUIFY) {
                    addLiquidity(amountLIQUIFY, amountLIQUIDITY);
                }
                // FINAL ETH DISTRIBUTION STARTS HERE
                amountETH = address(this).balance;
                // DEFINES NEW DENOMINATOR
                ethDenominator = (totalFee - burnFee - liquidityFee);

                if (amountETH > 0) {
                    // MARKETING DISTRIBUTION
                    if (marketingFee > 0) {
                        amountMARKETING = (amountETH * marketingFee / ethDenominator);
                        if (amountMARKETING > 0 && address(this).balance >= amountMARKETING) {
                            payable(MARKETING).sendValue((amountMARKETING));
                        }
                    }
                    // PROJECT DISTRIBUTION
                    if (address(this).balance >= 0) {
                        payable(PROJECT).sendValue(address(this).balance);      
                    }       
                }             
            }            
        }    
    }
    //SWAP FOR ETH
    function swapTokensForEth(uint256 tokenAmount) private returns (uint256) {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        return (address(this).balance);
    }
    //ADD LIQUIDITY
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // adds liquidity
        (,uint256 ethFromLiquidity,) = uniswapV2Router.addLiquidityETH {value: ethAmount} (
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            DEAD,
            block.timestamp
        );
        
        if (ethAmount - ethFromLiquidity > 0) {
            ethAmount = 0;
        }
    }
    // EXCLUDE FROM FEES
    function excludeFromFees(address holder, bool exempt) external onlyOwner {
        require(isFeeExempt[holder] != exempt, "Already set in that condition");
        isFeeExempt[holder] = exempt;
    }

    // ENABLE TRADING
    function enableTrade() external onlyOwner {
        require(!enableTrading, "Already set in that condition");
        enableTrading = true;
    }
    
    // RENOUNCE CONTRACT
    function renounceOwnership() external onlyOwner {
            setOwner(DEAD);
            emit OwnershipTransferred(msg.sender, DEAD);
    }
    
    // TRANSFER CONTRACT
    function transferOwnership(address newOwner) external onlyOwner {
            // GLOBAL REQUIREMENTS
            require(newOwner != DEAD 
            && newOwner != ZERO 
            && newOwner != uniswapV2Pair
            && newOwner != address(this) 
            && newOwner != owner(), "Renounce is recommended in this case.");
            // NICE! YOU DID IT!
            setOwner(newOwner);
            emit OwnershipTransferred(msg.sender, newOwner);
    }
    // CIRCULATING SUPPLY
    function getCirculatingSupply() public view returns (uint256) {
        return (totalSupply() - balanceOf(DEAD) - balanceOf(ZERO));
    }
    ///////////////////////////////////////////////////////////////////////////////////////
}
