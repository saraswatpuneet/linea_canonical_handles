// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract HandlesValidator {
    uint256 public constant MAX_HANDLE_LENGTH = 32; // Maximum allowed handle length
    uint256 public constant MIN_HANDLE_LENGTH = 3; // Minimum allowed handle length

    event HandleValidated(address indexed owner, string handle);
    event HandleClaimed(
        address indexed owner,
        string baseHandle,
        uint256 timestamp
    );

    /// @dev Struct to represent the handle payload
    struct Payload {
        string baseHandle;
    }

    /// @dev Reserved words that cannot be used as handles
    string[] private reservedWords = [
        "adm1n",
        "every0ne",
        "a11",
        "adm1n1strat0r",
        "m0d",
        "m0derat0r",
        "here",
        "channe1"
    ];

    /// @dev Ensure the handle does not exceed the maximum or minimum length
    function verifyHandleLength(string memory handle) internal pure {
        uint256 handleLength = bytes(handle).length;
        require(
            handleLength >= MIN_HANDLE_LENGTH &&
                handleLength <= MAX_HANDLE_LENGTH,
            "Handle length must be within valid range"
        );
    }

    /// @dev Check if a handle contains blocked characters
    function containsBlockedCharacters(
        string memory handle
    ) internal pure returns (bool) {
        bytes memory handleBytes = bytes(handle);
        bytes1[17] memory blockedCharacters = [
            bytes1('"'),
            bytes1("#"),
            bytes1("%"),
            bytes1("("),
            bytes1(")"),
            bytes1(","),
            bytes1("."),
            bytes1("/"),
            bytes1(":"),
            bytes1(";"),
            bytes1("<"),
            bytes1(">"),
            bytes1("@"),
            bytes1("\\"),
            bytes1("`"),
            bytes1("{"),
            bytes1("}")
        ];

        for (uint256 i = 0; i < handleBytes.length; i++) {
            for (uint256 j = 0; j < blockedCharacters.length; j++) {
                if (handleBytes[i] == blockedCharacters[j]) {
                    return true;
                }
            }
        }
        return false;
    }

    /// @dev Check if the handle is a reserved word
    function isReservedWord(string memory handle) internal view returns (bool) {
        for (uint256 i = 0; i < reservedWords.length; i++) {
            if (
                keccak256(bytes(handle)) == keccak256(bytes(reservedWords[i]))
            ) {
                return true;
            }
        }
        return false;
    }

    /// @dev Claim and validate a handle
    function claimHandle(Payload memory payload) public {
        // 1. Validation: Check handle length
        verifyHandleLength(payload.baseHandle);

        // 2. Validation: Ensure handle does not contain blocked characters
        require(
            !containsBlockedCharacters(payload.baseHandle),
            "Handle contains invalid characters"
        );

        // 3. Validation: Ensure handle is not a reserved word
        require(
            !isReservedWord(payload.baseHandle),
            "Handle is a reserved word"
        );

        // Emit event if valid
        emit HandleValidated(msg.sender, payload.baseHandle);
        emit HandleClaimed(msg.sender, payload.baseHandle, block.timestamp);
    }
}
