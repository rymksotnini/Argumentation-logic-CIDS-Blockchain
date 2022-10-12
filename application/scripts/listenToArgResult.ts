import { ethers } from 'ethers'


(async () => {
    try {
      const metadata = JSON.parse(await remix.call('fileManager', 'getFile', 'browser/contracts/artifacts/Argumentation.json'))
      const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
      const contract = new ethers.Contract("0x3fE43137A38F6eAC086947a72Ff741aeD4A1798c", metadata.abi, provider.getSigner());
      console.log("started listening");
      const eventHandling = await contract.on("decision_result", (result) => {
        console.log("*****Argumentation finished*****")
        console.log(result)
      });
      console.log("ended");
    } catch (e) {
        console.log(e.message)
    }
  })();



