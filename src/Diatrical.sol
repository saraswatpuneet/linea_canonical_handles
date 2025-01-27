// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DiatricalNormalizer {
    mapping(uint16 => uint16) public combiningMarks;
    uint256[] public combiningMarksSalt;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    event CombiningMarksInitialized(uint16[] keys, uint16[] values);
    event CombiningMarksSaltInitialized(uint256[] salts);

    function initializeCombiningMarks(uint16[] memory keys, uint16[] memory values) external onlyOwner {
        require(keys.length == values.length, "Keys and values must have the same length");
        for (uint256 i = 0; i < keys.length; i++) {
            combiningMarks[keys[i]] = values[i];
        }
        emit CombiningMarksInitialized(keys, values);
    }

    function initializeCombiningMarksSalt(uint256[] memory salts) external onlyOwner {
        uint256 length = salts.length;
        for (uint256 i = 0; i < length; i++) {
            combiningMarksSalt.push(salts[i]);
        }
        emit CombiningMarksSaltInitialized(salts);
    }

    function mph_lookup(
        uint32 x,
        uint16[] memory salt,
        uint32[] memory keys,
        uint16[] memory values,
        uint16 default_value
    ) internal pure returns (uint16) {
        uint256 index = my_hash(x, 0, salt.length);
        uint32 s = salt[index];
        uint256 key_index = my_hash(x, s, salt.length);

        if (x == keys[key_index]) {
            return values[key_index];
        } else {
            return default_value;
        }
    }

    function my_hash(
        uint32 x,
        uint32 s,
        uint256 salt_len
    ) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(x, s))) % salt_len;
    }

    function stripDiacritics(string memory inputStr) public view returns (string memory) {
        bytes memory inputBytes = bytes(inputStr);
        bytes memory outputBytes = new bytes(inputBytes.length); // Allocate initially
        uint256 outputIndex = 0;

        for (uint256 i = 0; i < inputBytes.length; i++) {
            uint16 char = uint16(uint8(inputBytes[i]));
            uint16 baseChar = _getBaseCharacter(char);

            if (baseChar != 0) {
                outputBytes[outputIndex] = bytes1(uint8(baseChar));
            } else {
                outputBytes[outputIndex] = inputBytes[i]; // Retain original if no mapping exists
            }

            outputIndex++;
        }

        // Resize array if necessary (for smaller output)
        assembly {
            mstore(outputBytes, outputIndex)
        }

        return string(outputBytes);
    }

    function _getBaseCharacter(uint16 char) internal view returns (uint16) {
        return combiningMarks[char];
    }
}
