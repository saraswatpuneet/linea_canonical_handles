import Web3 from 'web3'; // Import Web3 using ES Module syntax

// Connect to Ethereum network (Goerli testnet using Infura)
const web3 = new Web3('http://localhost:8545');

// Define the contract ABI (Application Binary Interface)
const contractABI = [
    {
        "inputs": [
            { "internalType": "uint16[]", "name": "values", "type": "uint16[]" }  // Only values now
        ],
        "name": "initializeCombiningMarks",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            { "internalType": "uint256[]", "name": "salts", "type": "uint256[]" }
        ],
        "name": "initializeCombiningMarksSalt",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            { "internalType": "string", "name": "inputStr", "type": "string" }
        ],
        "name": "stripDiacritics",
        "outputs": [
            { "internalType": "string", "name": "", "type": "string" }
        ],
        "stateMutability": "view",
        "type": "function"
    }
];

// Set the contract address
const contractAddress = '0xa50a51c09a5c451C52BB714527E1974b686D8e77';

// Create contract instance
const contract = new web3.eth.Contract(contractABI, contractAddress);

// Your private key (NEVER expose your private key in production)
const privateKey = '8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63';

// Your Ethereum account address (Make sure it's the one you use to deploy or interact)
const account = '0xFE3B557E8Fb62b89F4916B721be55cEb828dBd73';

// To sign and send a transaction
async function sendTransaction(data, from) {
    // Estimate gas for the transaction
    const gas = await data.estimateGas({ from: from });
    const gasPrice = await web3.eth.getGasPrice(); // Optionally, use a custom gas price
    const tx = {
        from: from,
        to: contractAddress,
        data: data.encodeABI(),
        gas,
        gasPrice
    };

    // Sign the transaction
    const signedTx = await web3.eth.accounts.signTransaction(tx, privateKey);

    // Send the signed transaction
    return web3.eth.sendSignedTransaction(signedTx.rawTransaction);
}

// Call the initializeCombiningMarks function
async function initializeCombiningMarks() {
    try {
        const tx = contract.methods.initializeCombiningMarks([10, 20, 30]);  // Only values (no keys)
        const receipt = await sendTransaction(tx, account);
        console.log('Combining Marks Initialization successful:', receipt);
    } catch (error) {
        console.error('Error initializing combining marks:', error);
    }
}

// Call the initializeCombiningMarksSalt function
async function initializeCombiningMarksSalt() {
    try {
        const tx = contract.methods.initializeCombiningMarksSalt([123, 456, 789]);
        const receipt = await sendTransaction(tx, account);
        console.log('Combining Marks Salt Initialization successful:', receipt);
    } catch (error) {
        console.error('Error initializing combining marks salt:', error);
    }
}

// Call the stripDiacritics function
async function stripDiacritics(inputStr) {
    try {
        const result = await contract.methods.stripDiacritics(inputStr).call();
        console.log('Stripped string:', result);
    } catch (error) {
        console.error('Error stripping diacritics:', error);
    }
}

// Test function usage
async function test() {
    await initializeCombiningMarks();  // Initialize combining marks
    await initializeCombiningMarksSalt();  // Initialize combining salts
    await stripDiacritics('Thérè äre sôme dîâcrítîcs here!'); // Test stripping diacritics
}

test();  // Call the test function
