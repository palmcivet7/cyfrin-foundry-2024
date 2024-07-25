# Section 4: Merkle Airdrop & Signatures

### Scripts

Run: `forge script script/GenerateInput.s.sol` to get `input.json`.

Run: `forge script script/MakeMerkle.s.sol  ` to get `output.json`.

### Deploying

`forge create src/BagelToken.sol:BagelToken --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL} --account defaultKey --legacy --zksync`

`export TOKEN_ADDRESS=address(token)`

`forge create src/MerkleAirdrop.sol:MerkleAirdrop --constructor-args 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4 ${TOKEN_ADDRESS} --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL} --account defaultKey --legacy --zksync`

### Private Key Management

`cast wallet import defaultKey --interactive`

`defaultKey` is name given to the account

`cast wallet list` to see list of accounts

### Interactions

updates state:
`cast send <CONTRACT_ADDRESS> "functionName(uint256)" 123 --rpc-url $RPC_URL --account accountName`

reads state:
`cast call <CONTRACT_ADDRESS> "getValue()"`

---

`export AIRDROP_ADDRESS=0xc4C4Cbe4CE80303c819ef35354943802D5E0BFB7`

`cast call ${AIRDROP_ADDRESS} "getMessageHash(address,uint256)" 0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd 25000000000000000000 --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL}`

0xc6a18717a87c93b53e6572f56b5d80ca368c0c0a84595ecb3a52ca6527e29077

`cast wallet sign --no-hash 0xc6a18717a87c93b53e6572f56b5d80ca368c0c0a84595ecb3a52ca6527e29077 --account accountName`

// put signature in signature.txt

`forge script script/SplitSignature.s.sol:SplitSignature`

`export V=`

`export R=`

`export S=`

`cast send ${TOKEN_ADDRESS} "mint(address,uint256)" <MY_EOA_ADDRESS> 100000000000000000000 --account accountName --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL}`

`cast send ${TOKEN_ADDRESS} "transfer(address,uint256)" ${AIRDROP_ADDRESS} 100000000000000000000 --account accountName --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL}`

`cast send ${AIRDROP_ADDRESS} "claim(address,uint256,bytes32[],uint8,bytes32,bytes32)" 0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd 25000000000000000000 "[0x4fd31fee0e75780cd67704fbc43caee70fddcaa43631e2e1bc9fb233fada2394, 0x81f0e530b56872b6fc3e10f8873804230663f8407e21cef901b8aeb06a25e5e2]" ${V} ${R} ${S} --account accountName --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL}`

`cast call ${TOKEN_ADDRESS} "balanceOf(address)" <RECEIVING_EOA_ADDRESS> --rpc-url {ZKSYNC_SEPOLIA_RPC_URL}`
