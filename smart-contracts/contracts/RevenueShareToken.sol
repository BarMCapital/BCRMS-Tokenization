// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title RevenueShareToken
 * @author BAR M Capital
 *
 * @notice Simple ERC20-style token representing a pro-rata share of a
 *         BAR M Capital revenue stream.
 *
 * This is a minimal, non-production stub designed to:
 *  - Represent fractional ownership
 *  - Be extendable with compliance logic (whitelisting, transfer rules)
 *  - Integrate with RevenueAnchor and off-chain BRRMS calculations
 *
 * In a future phase this contract will:
 *  - Enforce transfer restrictions (Reg D / Reg CF, etc.)
 *  - Integrate with a distribution engine that uses BRRMS netRevenue
 *  - Emit events that off-chain services use to push stablecoins or fiat
 */

contract RevenueShareToken {
    // Basic token metadata
    string public name = "BAR M Revenue Share Token";
    string public symbol = "BRST";
    uint8 public decimals = 18;

    // Total supply of tokens
    uint256 public totalSupply;

    // Owner / admin address (e.g., BAR M Capital or an offering SPV)
    address public owner;

    // Balances and allowances
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    // --- ERC20-style core functions ---

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address tokenOwner, address spender) external view returns (uint256) {
        return allowances[tokenOwner][spender];
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 currentAllowance = allowances[from][msg.sender];
        require(currentAllowance >= amount, "Allowance exceeded");

        allowances[from][msg.sender] = currentAllowance - amount;
        _transfer(from, to, amount);
        return true;
    }

    // --- Minting / admin controls ---

    /**
     * @notice Mint new tokens to a recipient.
     * In a real offering, this would only be called during the raise process
     * as investors purchase revenue-share tokens.
     */
    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Invalid address");
        totalSupply += amount;
        balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    /**
     * @notice Burn tokens from a holder (e.g., buyback, redemption).
     */
    function burn(address from, uint256 amount) external onlyOwner {
        require(from != address(0), "Invalid address");
        require(balances[from] >= amount, "Insufficient balance");

        balances[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    /**
     * @notice Transfer ownership of the token contract (e.g., to a DAO or SPV).
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // --- Internal helpers ---

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "From address invalid");
        require(to != address(0), "To address invalid");
        require(balances[from] >= amount, "Insufficient balance");

        balances[from] -= amount;
        balances[to] += amount;

        emit Transfer(from, to, amount);
    }
}
