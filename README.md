# Argumentation Logic CIDS Blockchain

## Overview

This project deploys a private Ethereum network that operates on a proof of authority consensus mechanism. It includes miners and validator nodes and simulates a distributed intrusion detection system using the SABU dataset. Data visualization is done through PCA and clustering to aid in alert aggregation, and the aggregated alerts are shared on the blockchain to simulate interaction between intrusion detection nodes.

## Features

- Private Ethereum Network
- Proof of Authority Consensus
- Distributed Intrusion Detection System (DIDS)
- Data Visualization with PCA and Clustering
- Argumentation Framework on Blockchain

## How to Start

### Downloading the Project

1. Go to this [GitHub repository](https://github.com/rymksotnini/Argumentation-logic-CIDS-Blockchain).
2. Download the repository.

### Launching the Network

1. Unzip the downloaded repository.
2. Navigate to the main repository folder.
3. Run the following command to start the network:
   ```bash
   docker-compose up
4. Ensure Docker is running as a service in the background.

### Uploading Necessary Files in Remix IDE
1. Upload the smart contract `Argumentation.sol` located under `application/contracts`.
2. Upload the script `addArgument.ts` located under `application/scripts`.
3. Upload the script `listenToArgResult.ts` located under `application/scripts`.

### Compiling the Smart Contract
1. Select `Argumentation.sol` in Remix IDE.
2. Click on the `Solidity compiler` tab.
3. Click on `Compile Argumentation.sol`.

### Deploying the Smart Contract
1. Go to the `Deploy & run transactions` tab.
2. In the `Environment` section, choose `External Http Provider` to link it to the deployed private network.
3. Update the endpoint with the port of the node you want to connect to (e.g., `8546`). Available ports are `8545`, `8546`, and `8547`.
4. In the `Deploy` section, specify `IDS_NUMBER`, `ARGS_THRESHOLD`, and `HISTORY_LENGTH`.
5. Click `transact` to deploy the smart contract.

### Running the Listener Script
1. Go to the `File Explorer` tab and select the `listenToArgResult.ts` file.
2. Update the contract address with the one that was recently deployed.
3. Run the script by clicking on the green `Run Script` icon.

### Adding Arguments

#### Using Remix
1. In the `Deploy & run transactions` tab under the `Deployed Contracts` section, go to the `addArgument` method.
2. Specify the `alert_id` and click on `transact`.

#### Using Script
1. Go to the `File Explorer` tab and select the `addArgument.ts` file.
2. Update the contract address with the one that was recently deployed.
3. Specify the `alert_id` to pass in the `addArgument` method.
4. Run the script by clicking on the green `Run Script` icon.

### Checking the Success of the Experiment
1. Once the number of times an argument was added reaches the number of IDSs specified, the `decision_result` event is triggered, and the argumentation ends by returning the winning argument and its nodes.
2. Add arguments as needed using both methods to test the end results.
