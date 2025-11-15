// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title RevenueAnchor
 * @author BAR M Capital
 *
 * @notice This smart contract anchors daily BRRMS hash values on-chain.
 * Each hash corresponds to a normalized BusinessRevenueRecord produced by BRRMS.
 *
 * Purpose:
 *  - Store cryptographic proofs (hashes) of BAR M business revenue records.
 *  - Provide immutable, timestamped auditability for investor protection.
 *  - Serve as the first stage of the automated revenue distribution pipeline.
 *
 * This contract forms the base layer of BAR M Capital’s tokenization framework,
 * inspired by IBM's BCRMS architecture.
 */

contract RevenueAnchor {
    // Struct to store anchored hashes with timestamps
    struct HashRecord {
        bytes32 hash;
        uint256 timestamp;
    }

    // Mapping: date string (YYYY-MM-DD) → HashRecord
    mapping(string => HashRecord) private anchoredHashes;

    // Event emitted when a hash is anchored
    event HashAnchored(string indexed date, bytes32 indexed hash, uint256 timestamp);

    /**
     * @notice Records a BRRMS hash for a given date.
     * @param date The date (YYYY-MM-DD) associated with the revenue record.
     * @param hash The keccak256 hash of the normalized BRRMS revenue file.
     */
    function recordHash(string calldata date, bytes32 hash) external {
        require(hash != bytes32(0), "Invalid hash");
        require(bytes(date).length == 10, "Invalid date format");

        anchoredHashes[date] = HashRecord({
            hash: hash,
            timestamp: block.timestamp
        });

        emit HashAnchored(date, hash, block.timestamp);
    }

    /**
     * @notice Retrieves the anchored hash for a specific date.
     * @param date The date (YYYY-MM-DD) to query.
     * @return hash The stored hash.
     * @return timestamp The timestamp when it was anchored.
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
     * @notice Checks whether a given date has an anchored record.
     */
    function hasRecord(string calldata date) external view returns (bool) {
        return anchoredHashes[date].timestamp != 0;
    }
}
