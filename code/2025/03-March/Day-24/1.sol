// ============================================================
// Contract name: FunToken
// Contract address: 0x9e951d63bbf435733dc9cb73d3000233e9d591fb
// Liquidity: $17356.84
// Chain: BNB Smart Chain (56)
// Source: BscScan verified contract
// ============================================================
// ===== Original source: FunToken.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// idosgames.com and idos.games powered by iDos Games

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function decimals() external returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IAllowedList {
    function isAuthorized(address _addr) external view returns (bool);
    function isBlacklistMode() external view returns (bool);
}

contract FunToken is IERC20 {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint8 public constant version = 2;

    address public initialFrom;
    address public deployerFrom;
    bool public isInitialized;
    bool public dexInitiated;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    IAllowedList public allowedList;

    function initialize(
        uint256 initialSupply,
        string memory _name,
        string memory _symbol,
        address _midDeployer,
        address _deployer,
        address _allowedList
    ) external {
        require(!isInitialized, "Already initialized");
        require(_allowedList != address(0), "AllowedList cannot be a null address");

        _mint(_midDeployer, initialSupply);
        initialFrom = _midDeployer;
        deployerFrom = _deployer;
        name = _name;
        symbol = _symbol;
        allowedList = IAllowedList(_allowedList);
        isInitialized = true;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        require(_validateTransfer(msg.sender, recipient), "Transfer not allowed");
        _transfer(msg.sender, recipient, amount);
        return true;
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
        require(_validateTransfer(sender, recipient), "Transfer not allowed");
        require(_allowances[sender][msg.sender] >= amount, "Insufficient authorizations");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function burn(uint256 amount) public returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "invalid transfer amount");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _validateTransfer(address _from, address _to) internal view returns (bool) {
        if (dexInitiated) {
            return true;
        }

        if (_from == initialFrom || _to == initialFrom || _from == deployerFrom || _to == deployerFrom) {
            return true;
        }

        if (allowedList.isBlacklistMode()) {
            return (allowedList.isAuthorized(_from) && allowedList.isAuthorized(_to));
        }
        else {
            return (allowedList.isAuthorized(_from) || allowedList.isAuthorized(_to));
        }
    }

    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        require(spender != address(0));

        _allowances[msg.sender][spender] = (_allowances[msg.sender][spender] +
            addedValue);
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        require(spender != address(0));

        _allowances[msg.sender][spender] = (_allowances[msg.sender][spender] -
            subtractedValue);
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0));
        require(amount <= _balances[account]);

        _totalSupply = _totalSupply - amount;
        _balances[account] = _balances[account] - amount;
        emit Transfer(account, address(0), amount);
    }

    function initiateDex() public {
        require(msg.sender == initialFrom, "only fun allowed");
        dexInitiated = true;
    }
}
