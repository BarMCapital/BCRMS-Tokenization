// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title RevenueShareToken
 * @author BAR M Capital
 *
 * @notice ERC20-style token representing fractional units of a defined BAR M
 *         revenue stream. This contract is deterministic and contains no
 *         subjective branching, consistent with BAR M's Anti-Capacious
 *         Language Standard.
 *
 * Core purposes:
 *  - Represent fractional ownership units of a specified revenue pool.
 *  - Allow deterministic transfer, approval, and balance tracking.
 *  - Provide a stable interface for off-chain BRRMS-based distribution engines
 *    and on-chain anchoring via RevenueAnchor.
 *
 * Compliance, offering-specific rules, and payout mechanics are handled by
 * dedicated modules or off-chain services that consume BRRMS outputs and
 * anchored hashes. This contract does not make regulatory judgments.
 */
contract RevenueShareToken {
    // Basic token metadata (immutable after deployment)
    string public name = "BAR M Revenue Share Token";
    string public symbol = "BRST";
    uint8 public decimals = 18;

    // Total supply of tokens
    uint256 public totalSupply;

    // Owner / admin address (e.g., BAR M Capital or an offering SPV)
    address public owner;

    // Balances and allowances (standard ERC20-style mappings)
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    // Events: deterministic state transitions only
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    /**
     * @notice Sets the initial owner. No tokens are minted at deployment.
     */
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @notice Returns the token balance of a given account.
     * @param account Address to query.
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    /**
     * @notice Returns the remaining number of tokens that `spender`
     *         is allowed to spend on behalf of `tokenOwner`.
     */
    function allowance(address tokenOwner, address spender) external view returns (uint256) {
        return allowances[tokenOwner][spender];
    }

    /**
     * @notice Transfers tokens to a specified address.
     * @param to Recipient address.
     * @param value Amount of tokens to transfer.
     */
    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @notice Approves `spender` to spend `value` tokens on behalf of caller.
     * @param spender Address allowed to spend.
     * @param value Amount approved.
     */
    function approve(address spender, uint256 value) external returns (bool) {
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @notice Transfers tokens from `from` to `to` using an existing allowance.
     * @param from Source address.
     * @param to Destination address.
     * @param value Amount of tokens to transfer.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        uint256 currentAllowance = allowances[from][msg.sender];
        require(currentAllowance >= value, "ALLOWANCE_EXCEEDED");

        allowances[from][msg.sender] = currentAllowance - value;
        _transfer(from, to, value);
        return true;
    }

    /**
     * @notice Internal transfer function with deterministic checks only.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "ZERO_ADDRESS");
        require(balances[from] >= value, "INSUFFICIENT_BALANCE");

        balances[from] -= value;
        balances[to] += value;

        emit Transfer(from, to, value);
    }

    /**
     * @notice Mints new tokens to a specified address.
     * @dev Restricted to owner. Intended to align with off-chain offering logic
     *      and BRRMS-defined cap tables.
     * @param to Recipient of the minted tokens.
     * @param value Amount of tokens to mint.
     */
    function mint(address to, uint256 value) external onlyOwner {
        require(to != address(0), "ZERO_ADDRESS");
        totalSupply += value;
        balances[to] += value;
        emit Transfer(address(0), to, value);
    }

    /**
     * @notice Transfers ownership to a new address.
     * @param newOwner New owner address.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "ZERO_ADDRESS");
        address previousOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(previousOwner, newOwner);
    }
}
