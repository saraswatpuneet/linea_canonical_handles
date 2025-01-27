#!/bin/bash

# Ensure the contract address and RPC URL are set
CONTRACT_ADDRESS="0x43D1F9096674B5722D359B6402381816d5B22F28"
RPC_URL="http://localhost:8545"
PRIVATE_KEY="your_private_key_here"

# Array of 32-byte valid handles
handles=(
    "aabbccddeeffgghhiijjkkllmmnnooppqqrrssttuuvvwwxxyyzz"  # Valid ASCII handle
    "aaaabbbbccccddddeeeeffffgggghhhhiiiijjjjkkkkllllmmmm"  # Another valid ASCII
    "abcdеfghijklmnopqrstuvwxyzaaabbbccc"  # Mixing Latin and Cyrillic characters
    "0123456789abcdefghijABCDEFGHIJKL"  # 32-byte handle with digits
    "testhandle1234567890testhandle123"  # Alphanumeric handle
    "handlewithnumber1234567890123456"  # Number included
    "homoglyphs???????zzzzzzzzzzzzzzzz"  # Handle with some invalid characters
    "homoglyphsss111111222222333333444"  # Mixing homoglyphs with digits
    "nonblockedhandlewithspacesinthetext"  # Valid but contains spaces
    "validhandlewithspacesinbetweenvalid"  # Another valid handle with spaces
    "alphanumeric1234567890abcdefghijklmnopqrstuvwxyz"  # Full alphanumeric handle
    "abcdefgh1234567890ijklmnopqrstuvwxy"  # Random alphanumeric sequence
    "handleswithoutanynumbers123456"  # Handle without numbers
    "withunicodeпшзчшлщр"  # Including Cyrillic characters
    "handlevalidabcdefghijklmopqrstuvwxyz"  # 32-byte Latin handle
    "superlonghandlewithvalid32characters"  # Longer valid handle
    "handlecharactersabcdefghijklmnopqrstuvwxyz1234"  # Another valid example
    "firstvalidhandle32charactersisthisone"  # Another valid
    "max32byteshandlewithnoerrorvalidationworks"  # Maximum length valid handle
    "abcdefghijklmnopqrstuvwx0123456789"  # Combination of alphabet and digits
)

# Loop through the array of handles and send each one to the contract
for handle in "${handles[@]}"; do
    echo "Sending handle: $handle"
    
    # Send the handle as part of the Payload struct
    cast send $CONTRACT_ADDRESS "claimHandle(tuple(string))" "$handle" --rpc-url $RPC_URL --private-key $PRIVATE_KEY --value 0
    
    if [ $? -eq 0 ]; then
        echo "Handle $handle successfully sent!"
    else
        echo "Failed to send handle $handle."
    fi
    echo "-----------------------------------------"
done
