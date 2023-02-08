const ethers = require("ethers");
const artifact =  require("../contracts/Argumentation.json");


class Argument {
  flowDuration: number;
  idleMean: number;
  label: number;
  clusterId: number;

  constructor(flowDuration: number, idleMean: number, label: number, clusterId: number) {
    this.flowDuration = flowDuration;
    this.idleMean = idleMean;
    this.label = label;
    this.clusterId = clusterId;
  }
}

class Argumentor {
  node: string;
  argument: Argument;

  constructor(node: string, argument: Argument) {
    this.node = node;
    this.argument = argument;
  }

}


async function addArgument(argument: Argument){

} 

(async () => {
    try {
      const contractAddress = "0x9e6f95785384A9d8aFF8C096B79ee4Ff41A171eC";
      const argumentors: Argumentor[] = [
        new Argumentor ("8545", new Argument(55915, 0, 0, 1)),
        new Argumentor ("8546", new Argument(43356751, 12840650, 1, 2)),
        new Argumentor ("8547", new Argument(51864196, 10372754, 1, 2))
      ];
      //const metadata = JSON.parse(await remix.call('fileManager', 'getFile', 'browser/contracts/artifacts/Argumentation.json'))
      var count= 100;
      for (var i=0; i< argumentors.length; i++){
        let provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:" + argumentors[i].node); 
        let contract = new ethers.Contract(contractAddress, artifact.abi, provider.getSigner());
        console.log("started Adding");
        var txn = await contract.addArgument(argumentors[i].argument.flowDuration, argumentors[i].argument.idleMean, argumentors[i].argument.label, argumentors[i].argument.clusterId);
        await txn.wait();
        count = await provider.getTransactionCount(txn.hash);
        console.log("count", count);
        console.log("Added successfully");
      }
    } catch (e: any) {
        console.log(e.message);
    }
  })();