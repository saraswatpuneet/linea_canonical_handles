use ethers::contract::Contract;
use ethers::middleware::SignerMiddleware;
use ethers::{
    abi::Abi,
    providers::{Http, Provider},
    signers::{LocalWallet, Signer},
    types::{Address, U256},
};
use std::convert::TryFrom;
use std::sync::Arc;

#[tokio::main]
async fn main() -> eyre::Result<()> {
    // Replace with your Infura/Alchemy HTTP URL
    let provider_url = "http://localhost:8545";
    let provider = Provider::<Http>::try_from(provider_url)?;

    // Your private key for the wallet
    let private_key = "8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63";
    let wallet: LocalWallet = private_key.parse()?;
    let wallet = wallet.with_chain_id(5u64); // Set your chain ID (5 for Goerli, etc.)

    // Create a SignerMiddleware (this wraps the provider with the wallet)
    let client = SignerMiddleware::new(provider.clone(), wallet.clone());
    let client = Arc::new(client); // Wrap the client in an Arc to make it thread-safe

    // Deployed contract address
    let contract_address: Address = "0x338F940F4231662Dd9a689DdC4691450de932Be5".parse()?;

    // ABI definition of your contract (add the full ABI as JSON)
    let abi: Abi = serde_json::from_str(
        r#"
    [
        {
            "inputs": [
                {"internalType": "uint16[]", "name": "keys", "type": "uint16[]"},
                {"internalType": "uint16[]", "name": "values", "type": "uint16[]"}
            ],
            "name": "initializeCombiningMarks",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {"internalType": "uint256[]", "name": "salts", "type": "uint256[]"}
            ],
            "name": "initializeCombiningMarksSalt",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        }
    ]
    "#,
    )?;

    // Now, pass the SignerMiddleware (wrapped in Arc) to the Contract
    let contract = Contract::<SignerMiddleware<Provider<Http>, LocalWallet>>::new(
        contract_address,
        abi,
        client,
    );

    // Define keys and values for combining marks (example data)
    let keys: Vec<u16> = vec![768, 769, 770, 771]; // Example Unicode diacritic keys
    let values: Vec<u16> = vec![97, 101, 105, 111]; // Example base character mappings

    // Define salt values (example data)
    let salts: Vec<U256> = vec![U256::from(12345), U256::from(67890)];

    // Call initializeCombiningMarks
    let method_call =
        contract.method::<_, ()>("initializeCombiningMarks", (keys.clone(), values.clone()))?;
    let tx = method_call.send().await?;
    println!("CombiningMarks transaction hash: {:?}", tx.tx_hash());

    // Call initializeCombiningMarksSalt
    let method_call = contract.method::<_, ()>("initializeCombiningMarksSalt", (salts.clone(),))?;
    let tx = method_call.send().await?;
    println!("CombiningMarksSalt transaction hash: {:?}", tx.tx_hash());

    println!("CombiningMarksSalt transaction hash: {:?}", tx.tx_hash());

    Ok(())
}
