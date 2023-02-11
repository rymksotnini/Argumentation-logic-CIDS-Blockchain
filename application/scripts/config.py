from web3 import Web3
import json
from web3.middleware import geth_poa_middleware

abi = json.loads(open("../contracts/Argumentation.json", 'r').read())['abi']


def get_contract(address):
    web3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))
    web3.eth.default_account = web3.eth.accounts[0]
    web3.middleware_onion.inject(geth_poa_middleware, layer=0)

    contract = web3.eth.contract(
        address=address,
        abi=abi
    )
    return contract
