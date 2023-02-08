from web3 import Web3
import json
from web3.middleware import geth_poa_middleware


abi = json.loads(open("../contracts/Argumentation.json", 'r').read())['abi']
bytecode = json.loads(open("../contracts/Argumentation.json", 'r').read())['data']['bytecode']['object']

web3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))
web3.eth.default_account = web3.eth.accounts[0]

ArgumentationContract = web3.eth.contract(abi=abi, bytecode=bytecode)

# Indicate that it is POA using middleware
web3.middleware_onion.inject(geth_poa_middleware, layer=0)

# Submit the transaction for the argumentationContract deployment
tx_hash = ArgumentationContract.constructor(3, 2).transact()

# Wait for the deployment to end
tx_receipt = web3.eth.wait_for_transaction_receipt(tx_hash)

# Get the contract instance with address of the deployment
address = tx_receipt.contractAddress
print("contract address", address)
