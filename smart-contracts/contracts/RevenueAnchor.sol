// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title RevenueAnchor
 * @author BAR M Capital
 *
 * @notice This contract anchors BRRMS revenue event hashes on-chain.
 *
 * Deterministic Purpose:
 *  - Store cryptographic proofs of normalized BRRMS revenue events.
 *  - Provide immutable, timestamped anchoring for audit, settlement, and insurance modules.
 *  - Serve as the entry-point for deterministic on-chain verification across BAR M systems.
 *
 * All logic in this contract is non-interpretive and contains no subjective branching,
 * consistent with BAR M's Anti-Capacious Language Standard.
 */
contract RevenueAnchor {

    /**
     * @notice Struct representing an anchored BRRMS hash.
     * @dev Contains no subjective fields; timestamp is block-level deterministic.
     */
    struct HashRecord {
        bytes32 hash;        // keccak256 of normalized BRRMS revenue file
        uint256 timestamp;   // block timestamp when recorded
    }

    // Mapping: ISO date string (YYYY-MM-DD) → HashRecord
    mapping(string => HashRecord) private anchoredHashes;

    /**
     * @notice Emitted whenever a BRRMS hash is deterministically anchored.
     * @param date The ISO date string.
     * @param hash The keccak256 hash.
     * @param timestamp The block timestamp.
     */
    event HashAnchored(
        string indexed date,
        bytes32 indexed hash,
        uint256 timestamp
    );

    /**
     * @notice Anchors a BRRMS hash for a given ISO date.
     * @dev Requirements:
     *  - hash must be non-zero
     *  - date must follow YYYY-MM-DD format (length 10)
     *
     * @param date ISO date string (YYYY-MM-DD)
     * @param hash keccak256 hash of the normalized BRRMS file
     */
    function recordHash(string calldata date, bytes32 hash) external {
        require(hash != bytes32(0), "INVALID_HASH");
        require(bytes(date).length == 10, "INVALID_DATE");

        anchoredHashes[date] = HashRecord({
            hash: hash,
            timestamp: block.timestamp
        });

        emit HashAnchored(date, hash, block.timestamp);
    }

    /**
     * @notice Retrieves the anchored hash and timestamp for an ISO date.
     * @param date ISO date string (YYYY-MM-DD)
     */
    function getHash(string calldata date)
        external
        view
        returns (bytes32 hash, uint256 timestamp)
    {
        HashRecord memory record = anchoredHashes[date];
        return (record.hash, record.timestamp);
    }

    /**
     * @notice Returns true if the given date has been anchored.
     * @param date ISO date string (YYYY-MM-DD)
     */
    function hasRecord(string calldata date) external view returns (bool) {
        return anchoredHashes[date].timestamp != 0;
    }
}
