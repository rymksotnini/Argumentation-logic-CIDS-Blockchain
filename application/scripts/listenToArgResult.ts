import { ethers } from 'ethers'


(async () => {
    try {
      const metadata = JSON.parse(await remix.call('fileManager', 'getFile', 'browser/contracts/artifacts/Argumentation.json'))
      const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
      const contract = new ethers.Contract("0x4865aD7bdc5389B3a3747EbcAd496622DA6D1b89", metadata.abi, provider.getSigner());
      console.log("started listening");
      var txn = await contract.addArgument('2');
      await txn.wait();
      const eventHandling = await contract.on("decision_result", (result) => {
        console.log("*****Argumentation finished*****")
        console.log(result)
      });
      console.log("ended");
    } catch (e) {
        console.log(e.message)
    }
  })();



