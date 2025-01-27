// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title HandleConverter
/// @dev Provides a function to convert a given handle to its canonical form by
/// removing whitespace, replacing confusables, stripping diacritics, and converting to lowercase.
contract HandleCanonicalizer {
    // Confusable characters map (simplified version)
    mapping(bytes1 => bytes1) public confusables;
   // Diacriticals map (simplified version)
    mapping(bytes1 => bytes1) public diacriticals;

    constructor() {
        // Populating the confusables map with some examples. Expand this list as needed.
        confusables[0x30] = 0x6F; // '0' -> 'o'
        confusables[0x31] = 0x6C; // '1' -> 'l'
        // Add more mappings as needed

        // Diacriticals mapping: Add mappings for accented characters.
        diacriticals[0xE9] = 0x65; // 'é' -> 'e'
        diacriticals[0xE0] = 0x61; // 'à' -> 'a'
        diacriticals[0xE8] = 0x65; // 'è' -> 'e'
        diacriticals[0xF1] = 0x6E; // 'ñ' -> 'n'
        diacriticals[0xE7] = 0x63; // 'ç' -> 'c'
    }

    /// @dev Converts a handle to its canonical form.
    /// @param inputStr The input string to convert.
    /// @return The canonicalized string.
    function convertToCanonical(string memory inputStr) public view returns (string memory) {
        string memory noWhitespace = _stripUnicodeWhitespace(inputStr);
        string memory noDiacriticals = _stripDiacriticals(noWhitespace);
        string memory replacedConfusables = _replaceConfusables(noDiacriticals);
        return _toLowerCase(replacedConfusables);
    }

    /// @dev Strips Unicode whitespace from the input string.
    function _stripUnicodeWhitespace(string memory inputStr) internal pure returns (string memory) {
        bytes memory strBytes = bytes(inputStr);
        bytes memory result = new bytes(strBytes.length);
        uint256 index = 0;

        for (uint256 i = 0; i < strBytes.length; i++) {
            bytes1 char = strBytes[i];
            // Check for whitespace characters including U+200C and U+200D
            if (!_isWhitespace(char)) {
                result[index] = char;
                index++;
            }
        }

        bytes memory trimmedResult = new bytes(index);
        for (uint256 i = 0; i < index; i++) {
            trimmedResult[i] = result[i];
        }

        return string(trimmedResult);
    }

    /// @dev Checks if a character is a Unicode whitespace character.
    function _isWhitespace(bytes1 char) internal pure returns (bool) {
        return (char == 0x20 || (char >= 0x09 && char <= 0x0D));
    }

    /// @dev Strips diacriticals by replacing accented characters with their base forms.
    function _stripDiacriticals(string memory inputStr) internal view returns (string memory) {
        bytes memory strBytes = bytes(inputStr);

        for (uint256 i = 0; i < strBytes.length; i++) {
            // Replace diacritical characters based on the map
            if (diacriticals[strBytes[i]] != 0) {
                strBytes[i] = diacriticals[strBytes[i]];
            }
        }

        return string(strBytes);
    }

    /// @dev Replaces confusable characters with their canonical equivalents.
    function _replaceConfusables(string memory inputStr) internal view returns (string memory) {
        bytes memory strBytes = bytes(inputStr);

        for (uint256 i = 0; i < strBytes.length; i++) {
            // Replace confusable characters based on the map
            if (confusables[strBytes[i]] != 0) {
                strBytes[i] = confusables[strBytes[i]];
            }
        }

        return string(strBytes);
    }

    /// @dev Converts the input string to lowercase.
    function _toLowerCase(string memory inputStr) internal pure returns (string memory) {
        bytes memory strBytes = bytes(inputStr);

        for (uint256 i = 0; i < strBytes.length; i++) {
            // Convert uppercase to lowercase by adding 32 to the ASCII value.
            if (strBytes[i] >= 0x41 && strBytes[i] <= 0x5A) {
                strBytes[i] = bytes1(uint8(strBytes[i]) + 32);
            }
        }

        return string(strBytes);
    }
}
