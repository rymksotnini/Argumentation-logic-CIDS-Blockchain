import sys
import json
from web3 import Web3
import config
from web3.middleware import geth_poa_middleware

abi = json.loads(open("../contracts/Argumentation.json", 'r').read())['abi']

class Argument:
    def __init__(self, flow_duration, idle_mean, label, cluster_id):
        self.flow_duration = flow_duration
        self.idle_mean = idle_mean
        self.label = label
        self.cluster_id = cluster_id


class Argumentor:
    def __init__(self, node, argument: Argument):
        self.node = node
        self.argument = argument


argumentors = [
    Argumentor("8545", Argument(55915, 0, 0, 1)),
    Argumentor("8546", Argument(43356751, 12840650, 1, 2)),
    Argumentor("8547", Argument(51864196, 10372754, 1, 2))
]




def main():
    print(sys.argv[1])
    address = sys.argv[1]
    for argumentor in argumentors:
        provider = Web3(Web3.HTTPProvider("http://127.0.0.1:" + argumentor.node))
        provider.eth.default_account = provider.eth.accounts[0]
        provider.middleware_onion.inject(geth_poa_middleware, layer=0)
        contract = provider.eth.contract(
            address=address,
            abi=abi
        )
        transaction_hash = contract.functions.addArgument(
            argumentor.argument.flow_duration,
            argumentor.argument.idle_mean,
            argumentor.argument.label,
            argumentor.argument.cluster_id
        ).transact()
        receipt = provider.eth.wait_for_transaction_receipt(transaction_hash)
        print(receipt['status'])


if __name__ == "__main__":
    main()
