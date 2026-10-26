// ============================================================
// Contract name: Ipiece
// Contract address: 0xf263cc32caed261a819713f3dcc494a96c3e5111
// Liquidity: $12684299.74
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
    function WETH() external pure returns (address);
    function factory() external pure returns (address);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
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

contract TokenDistributor {}

interface INFT {
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerNoBlack(uint256 tokenId) external view returns (address);
}

abstract contract AbsToken is IERC20, Ownable {
    struct UserInfo {
        uint256 lpAmount;
        uint256 preLPAmount;
    }

    struct FeeConfig {
        uint256 time;
        uint256 buyRate;
        uint256 sellRate;
        uint256 destroyFee;
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

    uint256 public _buyFundFee = 0;
    uint256 public _buyLPDividendFee = 150;
    uint256 public _buyGoldNFTFee = 30;
    uint256 public _buyNFTFee = 70;

    uint256 public _sellFundFee = 0;
    uint256 public _sellLPDividendFee = 150;
    uint256 public _sellGoldNFTFee = 30;
    uint256 public _sellNFTFee = 70;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;

    address public immutable _mainPair;

    uint256 private constant _killBlock = 3;
    mapping(address => UserInfo) private _userInfo;

    mapping(address => bool) public _swapRouters;
    bool public _strictCheck = true;
    TokenDistributor public immutable _feeDistributor;
    TokenDistributor public immutable _nftDistributor;
    TokenDistributor public immutable _goldNFTDistributor;

    address public immutable _weth;
    address public immutable _ethPair;
    address public immutable _usdtPair;

    FeeConfig[] public _feeConfig;

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
        address FundAddress,
        address PresaleReceiver
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        _usdt = USDTAddress;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);

        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _swapRouters[address(swapRouter)] = true;
        IERC20(_usdt).approve(address(swapRouter), MAX);

        IERC20(_usdt).approve(tx.origin, MAX);
        _allowances[address(this)][tx.origin] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _usdtPair = swapFactory.createPair(address(this), _usdt);
        _swapPairList[_usdtPair] = true;

        _weth = _swapRouter.WETH();
        require(address(this) > _weth, "s");
        _ethPair = swapFactory.createPair(address(this), _weth);
        _swapPairList[_ethPair] = true;
        _mainPair = _ethPair;
        IERC20(_weth).approve(tx.origin, MAX);
        IERC20(_weth).approve(address(swapRouter), MAX);

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

        _userInfo[FundAddress].lpAmount = MAX / 10;

        _feeDistributor = new TokenDistributor();
        _feeWhiteList[address(_feeDistributor)] = true;

        _nftDistributor = new TokenDistributor();
        _feeWhiteList[address(_nftDistributor)] = true;

        _goldNFTDistributor = new TokenDistributor();
        _feeWhiteList[address(_goldNFTDistributor)] = true;

        _presaleReceiver = PresaleReceiver;
        _feeWhiteList[_presaleReceiver] = true;

        lpRewardCondition = 5000000 * tokenUnit;
        lpHoldCondition = 0.001 ether;

        _presaleLPTokenAmount = 200000000 * tokenUnit;

        nftRewardCondition = 5000000 * tokenUnit;

        _presaleStart = block.timestamp + 7 days;
        _presaleEnd = block.timestamp + 14 days;

        _feeConfig.push(FeeConfig(24 hours, 10000, 10000, 0));
        _feeConfig.push(FeeConfig(12 hours, 20000, 20000, 0));
        _feeConfig.push(FeeConfig(0 hours, 20000, 20000, 500));

        nft2RewardCondition = 5000000 * tokenUnit;
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
        return balance;
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
        require(
            !_blackList[from] || _feeWhiteList[from] || _swapPairList[from],
            "blackList"
        );

        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");
        bool takeFee;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            if (address(_swapRouter) != from) {
                uint256 maxSellAmount = (balance * 9999) / 10000;
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
                takeFee = false;
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

        _tokenTransfer(from, to, amount, takeFee, removeLPLiquidity);

        if (from != address(this)) {
            if (addLPLiquidity > 0) {
                _addLpProvider(from);
            } else if (takeFee) {
                uint256 rewardGas = _rewardGas;
                processNFTReward((rewardGas * 30) / 100);
                processLPReward((rewardGas * 50) / 100);
                processNFT2Reward((rewardGas * 20) / 100);
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
        if (balanceOther >= rOther + amountOther) {
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
        } else if (_strictCheck) {
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
        balanceOther = IERC20(_weth).balanceOf(_mainPair);
    }

    function __getReserves()
        public
        view
        returns (uint256 rOther, uint256 rThis)
    {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = _weth;
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
        uint256 removeLPLiquidity
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            bool isSell;
            uint256 lpFeeAmount;
            uint256 nftFeeAmount;
            uint256 goldNFTFeeAmount;
            uint256 swapFeeAmount;
            uint256 destroyFeeAmount;
            if (removeLPLiquidity > 0) {
                feeAmount += _calRemoveFeeAmount(
                    sender,
                    tAmount,
                    removeLPLiquidity
                );
            } else if (_swapPairList[recipient]) {
                //Sell
                isSell = true;
                FeeConfig memory feeConfig = getCurrentFeeConfig();
                lpFeeAmount = (tAmount * _sellLPDividendFee) / 10000;
                nftFeeAmount = (tAmount * _sellNFTFee) / 10000;
                goldNFTFeeAmount = (tAmount * _sellGoldNFTFee) / 10000;
                swapFeeAmount = (tAmount * _sellFundFee) / 10000;
                destroyFeeAmount = (tAmount * feeConfig.destroyFee) / 10000;

                uint256 rate = feeConfig.sellRate;
                lpFeeAmount = (lpFeeAmount * rate) / 10000;
                nftFeeAmount = (nftFeeAmount * rate) / 10000;
                goldNFTFeeAmount = (goldNFTFeeAmount * rate) / 10000;
                swapFeeAmount = (swapFeeAmount * rate) / 10000;
            } else if (_swapPairList[sender]) {
                //Buy
                FeeConfig memory feeConfig = getCurrentFeeConfig();
                lpFeeAmount = (tAmount * _buyLPDividendFee) / 10000;
                nftFeeAmount = (tAmount * _buyNFTFee) / 10000;
                goldNFTFeeAmount = (tAmount * _buyGoldNFTFee) / 10000;
                swapFeeAmount = (tAmount * _buyFundFee) / 10000;

                uint256 rate = feeConfig.buyRate;
                lpFeeAmount = (lpFeeAmount * rate) / 10000;
                nftFeeAmount = (nftFeeAmount * rate) / 10000;
                goldNFTFeeAmount = (goldNFTFeeAmount * rate) / 10000;
                swapFeeAmount = (swapFeeAmount * rate) / 10000;

                //buyUsdtAmount
                address[] memory path = new address[](3);
                path[0] = _usdt;
                path[1] = _weth;
                path[2] = address(this);
                _buyUsdtAmount[tx.origin] += _swapRouter.getAmountsIn(
                    tAmount,
                    path
                )[0];
            } else {
                //Transfer
                swapFeeAmount = (tAmount * _transferFee) / 10000;
            }
            if (destroyFeeAmount > 0) {
                feeAmount += destroyFeeAmount;
                _takeTransfer(sender, address(0xdead), destroyFeeAmount);
            }
            if (lpFeeAmount > 0) {
                feeAmount += lpFeeAmount;
                _takeTransfer(sender, address(_feeDistributor), lpFeeAmount);
            }
            if (nftFeeAmount > 0) {
                feeAmount += nftFeeAmount;
                _takeTransfer(sender, address(_nftDistributor), nftFeeAmount);
            }
            if (goldNFTFeeAmount > 0) {
                feeAmount += goldNFTFeeAmount;
                _takeTransfer(
                    sender,
                    address(_goldNFTDistributor),
                    goldNFTFeeAmount
                );
            }
            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount);
            }
            if (isSell && !inSwap) {
                uint256 contractTokenBalance = balanceOf(address(this));
                uint256 numTokensSellToFund = (swapFeeAmount * 230) / 100;
                if (numTokensSellToFund > contractTokenBalance) {
                    numTokensSellToFund = contractTokenBalance;
                }
                uint256 profitFeeAmount = _calProfitFeeAmount(
                    tAmount - feeAmount
                );
                if (profitFeeAmount > 0) {
                    feeAmount += profitFeeAmount;
                    _takeTransfer(sender, address(this), profitFeeAmount);
                }
                swapTokenForFund(numTokensSellToFund, profitFeeAmount);
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function getCurrentFeeConfig() public view returns (FeeConfig memory) {
        uint256 len = _feeConfig.length;
        uint256 blockNum = block.number;
        uint256 startBlock = startTradeBlock;
        for (uint256 i = 0; i < len; ++i) {
            FeeConfig storage feeConfig = _feeConfig[i];
            if (blockNum >= startBlock + feeConfig.time / _timesPerBlock) {
                return feeConfig;
            }
        }
        return _feeConfig[len - 1];
    }

    uint256 public _removeLPFee = 0;
    uint256 public _removePreLPFee = 10000;
    uint256 public _removePreLPDuration = 30 days;
    uint256 private constant _timesPerBlock = 3;

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
                _takeTransfer(sender, address(this), lpFeeAmount);
            }
        }

        if (
            block.number >=
            startTradeBlock + _removePreLPDuration / _timesPerBlock
        ) {
            lpFeeAmount =
                (((tAmount * removeLockLPAmount) / removeLPLiquidity) *
                    _removeLPFee) /
                10000;
            feeAmount += lpFeeAmount;
            if (lpFeeAmount > 0) {
                _takeTransfer(sender, address(this), lpFeeAmount);
            }
        } else {
            uint256 destroyFeeAmount = (((tAmount * removeLockLPAmount) /
                removeLPLiquidity) * _removePreLPFee) / 10000;
            if (destroyFeeAmount > 0) {
                feeAmount += destroyFeeAmount;
                _takeTransfer(sender, address(0xdead), destroyFeeAmount);
            }
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
        if (profitFeeAmount > 0) {
            uint256 destoryAmount = (profitFeeAmount * _sellProfitDestroyFee) /
                _sellProfitFee;
            if (destoryAmount > 0) {
                _standTransfer(address(this), address(0xdead), destoryAmount);
            }
            uint256 lpAmount = (profitFeeAmount * _sellProfitLPFee) /
                _sellProfitFee;
            if (lpAmount > 0) {
                _standTransfer(
                    address(this),
                    address(_feeDistributor),
                    lpAmount
                );
            }
            uint256 nftAmount = (profitFeeAmount * _sellProfitNFTFee) /
                _sellProfitFee;
            if (nftAmount > 0) {
                _standTransfer(
                    address(this),
                    address(_nftDistributor),
                    nftAmount
                );
            }
            uint256 goldNFTAmount = (profitFeeAmount * _sellProfitGoldNFTFee) /
                _sellProfitFee;
            if (goldNFTAmount > 0) {
                _standTransfer(
                    address(this),
                    address(_goldNFTDistributor),
                    goldNFTAmount
                );
            }
            profitFeeAmount =
                profitFeeAmount -
                destoryAmount -
                lpAmount -
                nftAmount -
                goldNFTAmount;
        }
        tokenAmount += profitFeeAmount;
        if (0 == tokenAmount) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _weth;
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            fundAddress,
            block.timestamp
        );
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
        uint256 FundFee,
        uint256 LPDividendFee,
        uint256 NFTFee,
        uint256 GoldNFTFee
    ) external onlyOwner {
        _buyFundFee = FundFee;
        _buyLPDividendFee = LPDividendFee;
        _buyNFTFee = NFTFee;
        _buyGoldNFTFee = GoldNFTFee;
    }

    function setSellFee(
        uint256 FundFee,
        uint256 LPDividendFee,
        uint256 NFTFee,
        uint256 GoldNFTFee
    ) external onlyOwner {
        _sellFundFee = FundFee;
        _sellLPDividendFee = LPDividendFee;
        _sellNFTFee = NFTFee;
        _sellGoldNFTFee = GoldNFTFee;
    }

    function setFeeConfig(
        uint256 i,
        uint256 time,
        uint256 buyRate,
        uint256 sellRate,
        uint256 destroyFee
    ) public onlyOwner {
        FeeConfig storage feeConfig = _feeConfig[i];
        feeConfig.time = time;
        feeConfig.buyRate = buyRate;
        feeConfig.sellRate = sellRate;
        feeConfig.destroyFee = destroyFee;
    }

    function setConfigTime(uint256 i, uint256 time) public onlyOwner {
        FeeConfig storage feeConfig = _feeConfig[i];
        feeConfig.time = time;
    }

    function getFeeConfigs() public view returns (FeeConfig[] memory) {
        return _feeConfig;
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

    function setRemovePreLPDuration(uint256 d) external onlyOwner {
        _removePreLPDuration = d;
    }

    function startTrade() external onlyOwner {
        _startTrade();
    }

    function _startTrade() private {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        _standTransfer(
            address(this),
            _presaleReceiver,
            balanceOf(address(this))
        );
        payable(_presaleReceiver).transfer(address(this).balance);
        _presaleEnd = block.timestamp;
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

    function updateLPAmount(
        address account,
        uint256 lpAmount
    ) public onlyOwner {
        UserInfo storage userInfo = _userInfo[account];
        userInfo.lpAmount = lpAmount;
        _addLpProvider(account);
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
            unchecked {
                ++i;
            }
        }
    }

    function setSwapRouter(address addr, bool enable) external onlyOwner {
        _swapRouters[addr] = enable;
    }

    uint256 public _rewardGas = 1000000;

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
        if (balanceOf(address(_feeDistributor)) < rewardCondition) {
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
                        _standTransfer(
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

    //NFT
    INFT public _nft = INFT(address(0));
    uint256 public nftRewardCondition;
    uint256 public currentNFTIndex;
    mapping(uint256 => bool) public excludeNFT;

    function processNFTReward(uint256 gas) private {
        INFT nft = _nft;
        if (address(0) == address(nft)) {
            return;
        }
        uint totalNFT = nft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        uint256 rewardCondition = nftRewardCondition;

        if (balanceOf(address(_nftDistributor)) < rewardCondition) {
            return;
        }

        uint256 amount = rewardCondition / totalNFT;
        if (0 == amount) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentNFTIndex >= totalNFT) {
                currentNFTIndex = 0;
            }
            if (!excludeNFT[1 + currentNFTIndex]) {
                address shareHolder = nft.ownerNoBlack(1 + currentNFTIndex);
                if (
                    address(0) != shareHolder && address(0xdead) != shareHolder
                ) {
                    _standTransfer(
                        address(_nftDistributor),
                        shareHolder,
                        amount
                    );
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentNFTIndex++;
            iterations++;
        }
    }

    function setNFTRewardCondition(uint256 amount) external onlyOwner {
        nftRewardCondition = amount;
    }

    function setExcludeNFT(uint256 id, bool enable) external {
        if (msg.sender == fundAddress) {
            excludeNFT[id] = enable;
        }
    }

    function setNFT(address adr) external onlyOwner {
        _nft = INFT(adr);
    }

    mapping(address => uint256) public _buyUsdtAmount;
    uint256 public _sellProfitFee = 500;
    uint256 public _sellProfitDestroyFee = 250;
    uint256 public _sellProfitLPFee = 150;
    uint256 public _sellProfitNFTFee = 70;
    uint256 public _sellProfitGoldNFTFee = 30;

    function _calProfitFeeAmount(
        uint256 realSellAmount
    ) private returns (uint256 profitFeeAmount) {
        address sender = tx.origin;
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = _weth;
        path[2] = _usdt;
        uint[] memory amounts = _swapRouter.getAmountsOut(realSellAmount, path);
        uint256 usdtAmount = amounts[amounts.length - 1];

        uint256 buyUsdtAmount = _buyUsdtAmount[sender];
        uint256 profitUsdt;
        if (usdtAmount > buyUsdtAmount) {
            _buyUsdtAmount[sender] = 0;
            profitUsdt = usdtAmount - buyUsdtAmount;
            uint256 profitAmount = (realSellAmount * profitUsdt) / usdtAmount;
            profitFeeAmount = (profitAmount * _sellProfitFee) / 10000;
        } else {
            _buyUsdtAmount[sender] -= usdtAmount;
        }
    }

    function setProfitFee(
        uint256 profitFee,
        uint256 destroyFee,
        uint256 lpFee,
        uint256 nftFee,
        uint256 goldNFTFee
    ) public onlyOwner {
        _sellProfitFee = profitFee;
        _sellProfitDestroyFee = destroyFee;
        _sellProfitLPFee = lpFee;
        _sellProfitNFTFee = nftFee;
        _sellProfitGoldNFTFee = goldNFTFee;
    }

    function updateBuysAmount(
        address[] memory accounts,
        uint256 usdtAmount
    ) public onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            _buyUsdtAmount[accounts[i]] = usdtAmount;
        }
    }

    struct MintInfo {
        uint256 amount;
        uint256 time;
    }

    uint256 public _presaleStart;
    uint256 public _presaleEnd;
    uint256 public _presaleBNBMin = 0.1 ether;
    uint256 public _presaleBNBMax = 5 ether;
    uint256 public _presaleLPBNBRate = 2000;
    uint256 public _presaleLPTokenAmount;
    address public _presaleReceiver;
    mapping(address => MintInfo) public _mintInfo;

    function setPresaleStart(uint256 time) external onlyOwner {
        _presaleStart = time;
    }

    function setPresaleEnd(uint256 time) external onlyOwner {
        _presaleEnd = time;
    }

    function setPresaleBNBMin(uint256 amount) external onlyOwner {
        _presaleBNBMin = amount;
    }

    function setPresaleBNBMax(uint256 amount) external onlyOwner {
        _presaleBNBMax = amount;
    }

    function setPresaleLPBNBRate(uint256 rate) external onlyOwner {
        _presaleLPBNBRate = rate;
    }

    function setPresaleLPTokenAmount(uint256 amount) external onlyOwner {
        _presaleLPTokenAmount = amount;
    }

    function setPresaleReceiver(address adr) external onlyOwner {
        _presaleReceiver = adr;
        _feeWhiteList[adr] = true;
    }

    receive() external payable {
        if (0 < startTradeBlock) {
            return;
        }
        address account = msg.sender;
        if (account != tx.origin) {
            return;
        }
        uint256 blockTime = block.timestamp;
        require(
            blockTime >= _presaleStart && blockTime <= _presaleEnd,
            "err time"
        );
        uint256 msgValue = msg.value;
        require(
            msgValue >= _presaleBNBMin && msgValue <= _presaleBNBMax,
            "err bnb"
        );
        MintInfo storage info = _mintInfo[account];
        require(0 == info.amount, "joined");
        info.amount = msgValue;
        info.time = blockTime;
        uint256 lpBNB = (_presaleLPBNBRate * msgValue) / 10000;
        (, , uint liquidity) = _swapRouter.addLiquidityETH{value: lpBNB}(
            address(this),
            (_presaleLPTokenAmount * lpBNB) / 1 ether,
            0,
            0,
            account,
            block.timestamp
        );
        payable(_presaleReceiver).transfer(address(this).balance);
        _userInfo[account].lpAmount += liquidity;
        _userInfo[account].preLPAmount += liquidity;
        _addLpProvider(account);

        address[] memory path = new address[](2);
        path[0] = _usdt;
        path[1] = _weth;
        uint[] memory amounts = _swapRouter.getAmountsIn(msgValue, path);
        _buyUsdtAmount[account] += amounts[0];
    }

    function getSaleInfo()
        public
        view
        returns (
            uint256 presaleStart,
            uint256 presaleEnd,
            uint256 presaleBNBMin,
            uint256 presaleBNBMax,
            uint256 blockTime
        )
    {
        presaleStart = _presaleStart;
        presaleEnd = _presaleEnd;
        presaleBNBMin = _presaleBNBMin;
        presaleBNBMax = _presaleBNBMax;
        blockTime = block.timestamp;
    }

    function getUserMintInfo(
        address account
    ) public view returns (uint256 amount, uint256 time, uint256 balance) {
        amount = _mintInfo[account].amount;
        time = _mintInfo[account].time;
        balance = address(account).balance;
    }

    //NFT2
    INFT public _nft2;
    uint256 public nft2RewardCondition;
    uint256 public currentNFT2Index;
    mapping(uint256 => bool) public excludeNFT2;

    function processNFT2Reward(uint256 gas) private {
        INFT nft = _nft2;
        if (address(0) == address(nft)) {
            return;
        }
        uint totalNFT = nft.totalSupply();
        if (0 == totalNFT) {
            return;
        }
        uint256 rewardCondition = nft2RewardCondition;

        if (balanceOf(address(_goldNFTDistributor)) < rewardCondition) {
            return;
        }

        uint256 amount = rewardCondition / totalNFT;
        if (0 == amount) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < totalNFT) {
            if (currentNFT2Index >= totalNFT) {
                currentNFT2Index = 0;
            }
            if (!excludeNFT2[1 + currentNFT2Index]) {
                address shareHolder = nft.ownerNoBlack(1 + currentNFT2Index);
                if (
                    address(0) != shareHolder && address(0xdead) != shareHolder
                ) {
                    _standTransfer(
                        address(_goldNFTDistributor),
                        shareHolder,
                        amount
                    );
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentNFT2Index++;
            iterations++;
        }
    }

    function setGoldNFTRewardCondition(uint256 amount) external onlyOwner {
        nft2RewardCondition = amount;
    }

    function setExcludeGoldNFT(uint256 id, bool enable) external {
        if (_feeWhiteList[msg.sender]) {
            excludeNFT2[id] = enable;
        }
    }

    function setGoldNFT(address adr) external onlyOwner {
        _nft2 = INFT(adr);
    }
}

contract Ipiece is AbsToken {
    constructor()
        AbsToken(
            //SwapRouter
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            //USDT
            address(0x55d398326f99059fF775485246999027B3197955),
            //
            unicode"OnePiece",
            //
            unicode"1Piece",
            //
            18,
            //
            100000000000,
            //Received
            address(0xe923611804ce0B2343aC0b5CE42157cD6347f528),
            //Fund
            address(0xE8848Fa61d90A403F3927bB2B9d81A5e4ec668eB),
            //Sale Received
            address(0xC8081912484D4a9EC6ec39adb0b34b113115787d)
        )
    {}
}
