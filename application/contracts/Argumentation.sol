// SPDX-License-Identifier: GPL-3.0
import "hardhat/console.sol";
pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title Argumentation
 * @dev Implements argumentation process along with arguments collection
 */

contract Argumentation {

    //we still need this to return the winning argument in a whole

    struct Argument {
        address argumentor;
        //uint32 weight;
        uint _flowDuration;
        uint _idleMean;
        uint _label;
        //lezim k nabaathou mil kmeans incrementi b 1 5atir inajmou issirou mechekil min jorit i sfir
        uint8 _cluster_id;
        bool valid; // initialized to true to indicate if there are any contradiction in the premise and the conclusion
    }

    // for grouping similar arguments and be able to calculate the weight of the winner
    struct ArgumentSet {
        uint8 _cluster_id;
        Argument[] arguments;
        uint32 weight; // increment each loop to know the winner
    }

    mapping (bytes32 => ArgumentSet) argument_clusters;

    mapping (bytes32 => bytes32) argument_clusters_llIndex;  // to delete and parse argumentSet after
    //added to be able to reset the mapping argumentor_adresses
    address[] active_argumentors;
    // mapping that shows if an address represents an argumentor(added an argument) or not
    mapping (address => bool) public argumentor_adresses;

    // A static number that represents the number of IDSs present in the network
    uint8 public IDS_threshold;
    // An incrementable number that represents the actual number of IDSs that participated in the argumentation
    uint8 public IDS_current_nbr;

    // A mapping between each argument and the address of the node that presents it (Will a bijection be needed between the IDS node and the blockchain node (an address that represents both) Frédéric?)
    //mapping(address => Argument) public arguments;

    // an incrementable number that indicates how many argumentation phases were initiated to reach the final result
    uint8 public current_arg_calls_nbr;
    // a static number to indicate the threshold to reach the decision
    uint8 public args_final_nbr;
    // the winning result after each argumentation
    mapping (bytes32 => ArgumentSet) public winning_clusters;  //won't need this now
    //Indexing to be able to parse the different winners
    mapping (bytes32 => bytes32) winning_clusters_llIndex; // same won't need
    // the event that will be emited once the argumentation ends
    event decision_result(ArgumentSet argumentSet, string message);
    // the event that will be emited once the number of the necessary argumentations has been reached
    event final_decision_result(ArgumentSet argumentSet, string message);

    event logging(string message);


    constructor(uint8 IDS_number, uint8 args_threshold
    // , uint8 history_length
    ) {


        args_final_nbr = args_threshold;

        IDS_threshold = IDS_number;

        current_arg_calls_nbr = 0;

        IDS_current_nbr = 0;

    }

    /**
     * @dev Add the IDS's argument to the argumentation logic
     * @param flowDuration flowDuration of the added alert by sender
     * @param idleMean idleMean of the added alert by sender
     * @param label label of the added alert by sender
     * @param cluster_id cluster_id of the added alert by sender
     */
    function addArgument(uint flowDuration, uint idleMean, uint label, uint8 cluster_id) public {
        require(
            newArgumentor(msg.sender),
            "Only a node that has not argumented yet, can add an argument"
        );

        require(
            IDS_current_nbr < IDS_threshold,
            "The number of arguments cannot exceed the fixed threshold"
        );

        addArgumentor(msg.sender);
        //console.log("adding argument");



        IDS_current_nbr = IDS_current_nbr + 1;


        Argument memory argument;

        argument.argumentor = msg.sender;
        argument._flowDuration = flowDuration;
        argument._idleMean = idleMean;
        argument._label = label;
        argument._cluster_id = cluster_id;
        argument.valid =  true;

        // validate the argument (test if premise and conclusion don't contradict)
        validateArgument(argument);

        //invalid aruments will be saved considered but will be aliminated in the argumentation

        //add it to the coresponding cluster
        bytes32 cluster_hash = keccak256(abi.encodePacked(current_arg_calls_nbr, argument._cluster_id));
        argument_clusters[cluster_hash].arguments.push(argument);
        argument_clusters[cluster_hash]._cluster_id = cluster_id;
        addToClusteringLlIndex(cluster_hash, argument_clusters_llIndex);


        argumentor_adresses[msg.sender] = true;
        /*address_indexing_alert_id[msg.sender].alert_id = alert;
        arguments[msg.sender].initialized = true;*/

        emit logging("Argument added");

        if (IDS_current_nbr == IDS_threshold) {


            doArgumentation();

            current_arg_calls_nbr = current_arg_calls_nbr + 1;

            // see if we are in the final argumentation
            if (current_arg_calls_nbr == args_final_nbr) {

                bytes32 id_final_winner = computeFinalWinner();

                if (winning_clusters[id_final_winner].weight != 1) {
                    emit final_decision_result(winning_clusters[id_final_winner], "final Decision making was a success");
                    console.log("final winner cluster weight: ", argument_clusters[id_final_winner].weight);
                    console.log("final winner cluster id: ", argument_clusters[id_final_winner]._cluster_id);
                }
                else {
                    ArgumentSet memory final_winner;
                    final_winner.weight = 0;
                    final_winner._cluster_id = 0;
                    emit decision_result(final_winner, "N/A");
                }
                current_arg_calls_nbr = 0;
            }
            resetArgumentationParams();
        }
    }

    /**
    * @dev Reset the argumentation parameters
    */
    function resetArgumentationParams() private {
        //console.log("Reseting params");
        IDS_current_nbr = 0;
        for (uint i=0; i< active_argumentors.length ; i++) {
            argumentor_adresses[active_argumentors[i]] = false;
        }

        bytes32 current_cluster_id = argument_clusters_llIndex[0x0];

        while(current_cluster_id != 0){
            delete argument_clusters_llIndex[current_cluster_id];
            current_cluster_id = argument_clusters_llIndex[current_cluster_id];
        }
    }

    function validateArgument(Argument memory argument) pure private {
        if ((argument._idleMean < 10000000 || argument._flowDuration < 10000000) && argument._label == 1) {
            argument.valid = false;
        } else if ((argument._idleMean > 10000000 || argument._flowDuration > 10000000) && argument._label == 0){
            argument.valid = false;
        }
        //chech if argument is passed correctly to the other method
    }

    /**
      * @dev Add argumentor to the table of argumentors
      * @param sender the address of the sender which is the argumentor
      */
    function addArgumentor(address sender) private {
        active_argumentors.push(sender);
    }

    /**
     * @dev returns false if an arguement for the specified address already exists
     * @return newArgumentor_ the state of the argument
     */
    function newArgumentor(address sender) public view
    returns (bool newArgumentor_)
    {
        newArgumentor_ = (argumentor_adresses[sender] == false);
    }

    /**
     * @dev launch the argumentation process
     */
    function doArgumentation() private {

        //ArgumentSet[] memory clusters = new ArgumentSet[](IDS_threshold);
        //uint8 k = 0;
        bytes32 current_id = argument_clusters_llIndex[0x0];
        bytes32 winner_id = current_id;
        while (current_id != 0) {
            if (argument_clusters[current_id].arguments.length > argument_clusters[winner_id].arguments.length) {
                // checks if arguments of cluster are valid, checking one is enough
                if (argument_clusters[current_id].arguments[0].valid) {
                    winner_id = current_id;
                }
            }

            current_id = argument_clusters_llIndex[current_id];
        }
        console.log("argumentation finished");
        if (argument_clusters[winner_id].arguments.length != 1) {
            if (winning_clusters[winner_id].weight >= 1 ) {
                winning_clusters[winner_id].weight = winning_clusters[winner_id].weight + 1;
            }
            else {
                winning_clusters[winner_id].weight = 1;
                addToClusteringLlIndex(winner_id, winning_clusters_llIndex);
                winning_clusters[winner_id]._cluster_id = argument_clusters[winner_id]._cluster_id;
            }
            emit decision_result(argument_clusters[winner_id], "Decision making was a success");
        }
        else {
            ArgumentSet memory winner;
            winner.weight = 0;
            winner._cluster_id = 0;
            emit decision_result(winner, "No winner for this round");
        }
    }

    /**
     * @dev add id in the linked list of ID indexes
     * @param _id the alert ID to add in the list
     */
    function addToAlertIDLlIndex(bytes32 _id, mapping (bytes32 => bytes32) storage llIndex) private
    {
        if (!(_id == llIndex[0x0] || llIndex[_id] != 0 )) {
            llIndex[_id] = llIndex[0x0];
            llIndex[0x0] = _id;
        }
    }

    function addToClusteringLlIndex(bytes32 _id, mapping (bytes32 => bytes32) storage llIndex) private
    {
        if (!(_id == llIndex[0x0] || llIndex[_id] != 0 )) {
            llIndex[_id] = llIndex[0x0];
            llIndex[0x0] = _id;
        }
    }

    /**
     * @dev get the final winning argument by calculating the majority
     * @return i_winner the final winning argument id (holding the majority)
     */
    function computeFinalWinner() view private
    returns (bytes32 i_winner)
    {
        bytes32 current_cluster = winning_clusters_llIndex[0x0];
        i_winner = winning_clusters_llIndex[0x0];
        while (current_cluster != 0) {
            if (winning_clusters[current_cluster].weight > winning_clusters[i_winner].weight) {
                i_winner = current_cluster;
            }
            current_cluster = winning_clusters_llIndex[current_cluster];
        }
        console.log("argumentation finished");
        //emit logging("final argumentation finished");

    }

}
