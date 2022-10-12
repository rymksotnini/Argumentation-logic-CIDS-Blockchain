import { ethers } from 'ethers'

(async () => {
    try {
      const metadata = JSON.parse(await remix.call('fileManager', 'getFile', 'browser/contracts/artifacts/Argumentation.json'))
      const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8547");
      const contract = new ethers.Contract("0x2C17B760a5dc4440CfEB4b1E7a6760Ad45994a96", metadata.abi, provider.getSigner());
      console.log("started Adding");
      var txn = await contract.addArgument('1');
      await txn.wait();
      console.log("Added successfully");
    } catch (e) {
        console.log(e.message)
    }
  })();