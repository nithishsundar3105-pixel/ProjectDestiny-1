// ============================================================
// Contract name: MarvinToken
// Contract address: 0xa2f14e3a5835ce525da1aed4449bef1c0dea5b84
// Liquidity: $26571.13
// Chain: BNB Smart Chain (56)
// Source: BscScan verified contract
// ============================================================
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
   __  __                   _            
  |  \/  |                 (_)           
  | \  / | __ _ _ __  _ __  _ _ __   __ _ 
  | |\/| |/ _` | '_ \| '_ \| | '_ \ / _` |
  | |  | | (_| | | | | | | | | | | | (_| |
  |_|  |_|__,__|_| |_|_| |_|_|_| |_|__,__| 

   Marvin TOKEN
   Total Supply: 1,000,000,000 tokens (with 9 decimals)
*/

contract MarvinToken {
    // Owner variable to manage privileges
    address public owner;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipRenounced(address indexed previousOwner);

    // Modifier to restrict access to owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender; // Set deployer as owner
        name = "Elon Musk's Dog"; // Token name: Elon Musk's Dog
        symbol = "Marvin";     // Token symbol: Marvin
        decimals = 9;          // 9 decimals
        totalSupply = 1000000000 * 10 ** uint256(decimals); // 1 billion tokens
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    /// @notice Allows the owner to renounce their ownership.
    /// After calling this function, owner-only functions will no longer be callable.
    function renounceOwnership() external onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }


    /// @notice Transfers tokens to a specified address
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /// @notice Approves a spender to spend a certain amount of tokens
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Invalid spender");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @notice Transfers tokens from one address to another using an allowance
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != address(0), "Invalid from address");
        require(_to != address(0), "Invalid to address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}
