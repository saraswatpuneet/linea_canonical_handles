// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title SuffixGenerator
/// @dev Generates unique shuffled suffix sequences for a given range and canonical handle.
contract SuffixGenerator {
    /// @dev Generates a unique shuffled suffix sequence.
    /// @param canonicalHandle The canonical base handle.
    /// @param min The minimum value of the suffix range.
    /// @param max The maximum value of the suffix range.
    /// @return A shuffled array of suffixes.
    function generateUniqueSuffixes(
        string memory canonicalHandle,
        uint16 min,
        uint16 max
    ) public pure returns (uint16[] memory) {
        require(
            min <= max,
            "Invalid range: min must be less than or equal to max"
        );

        // Compute a seed from the canonical handle
        uint256 seed = uint256(keccak256(abi.encodePacked(canonicalHandle)));

        // Generate the range of suffixes
        uint16[] memory suffixes = new uint16[](max - min + 1);
        for (uint16 i = 0; i < suffixes.length; i++) {
            suffixes[i] = min + i;
        }

        // Shuffle the suffixes using Fisher-Yates algorithm
        for (uint16 i = uint16(suffixes.length - 1); i > 0; i--) {
            uint16 j = uint16(seed % (i + 1));
            seed = uint256(keccak256(abi.encodePacked(seed, i, j))); // Update seed
            (suffixes[i], suffixes[j]) = (suffixes[j], suffixes[i]); // Swap
        }

        return suffixes;
    }
}
