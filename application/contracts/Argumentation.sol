// SPDX-License-Identifier: GPL-3.0

import "hardhat/console.sol";

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title Argumentation
 * @dev Implements argumentation process along with arguments collection
 */

contract Argumentation {

    /* struct Argument {
        uint32 alert_id;
        bool initialized;
    } */

//we still need this to return the winning argument in a whole

    struct Argument {
        address[] argumentors;
        uint32 weight;
        bytes32 _type;
        bytes32 _target;
        bytes32 _source;
    }

// for each argument class we will return winner depending on it and finally see which generated alerts matches the composed winning alert of each class
    
    bytes32[] alerts; //change uint to bytes I guess
    //added to be able to reset the mapping argumentor_adresses
    address[] active_argumentors;
    // mapping that shows if an address represents an argumentor(added an argument) or not
    mapping (address => bool) public argumentor_adresses;
    // for an id alert this mapping help in finding the related addresses 
    // mapping (uint32 => address[]) public address_indexing_alert_id;
    // for an alert hash this mapping help in finding the related argument 
    mapping (bytes32 => Argument) public arg_indexing_alert;
    // alert hash linked list indexes
    mapping (bytes32 => bytes32) alertHash_llIndex; 

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
    // an array that indicates the state of an argumentation process
    // bool[] public argumentation_history;
    // the winning result after each argumentation
    mapping (bytes32 => Argument) public winners; 
    // Indexing to be able to parse the different winners
    mapping (bytes32 => bytes32) winner_llIndex;
    // the final winner of the different argumentations
    Argument public final_winner;
    // the event that will be emited once the argumentation ends
    event decision_result(Argument argument, string message);
    // the event that will be emited once the number of the necessary argumentations has been reached
    event final_decision_result(Argument argument, string message);


    constructor(uint8 IDS_number, uint8 args_threshold
    // , uint8 history_length
    ) {
        
        /* argumentation_history = new bool[](history_length);
        for (uint8 i = 0; i < history_length; i++) {
            argumentation_history[i] = false;
        } */

        args_final_nbr = args_threshold;

        IDS_threshold = IDS_number;

        current_arg_calls_nbr = 0; 

        IDS_current_nbr = 0;

    }

    /** 
     * @dev Add the IDS's argument to the argumentation logic
     * @param arg_type type of the added alert by sender
     * @param arg_target target of the added alert by sender
     * @param arg_source source of the added alert by sender
     */
    function addArgument(string memory arg_type, string memory arg_target, string memory arg_source) public {
        require(
            newArgumentor(msg.sender),
            "Only a node that has not argumented yet, can add an argument"
        );

        require(
            IDS_current_nbr < IDS_threshold,
            "The number of arguments cannot exceed the fixed threshold"
        );

        addArgumentor(msg.sender);
        console.log("adding argument");

        

        IDS_current_nbr = IDS_current_nbr + 1;
        //generate hash of three arguments for map indexing
        bytes32 alert = keccak256(abi.encodePacked(stringToBytes32(arg_type), stringToBytes32(arg_source), stringToBytes32(arg_target)));
        arg_indexing_alert[alert].argumentors.push(msg.sender);
        arg_indexing_alert[alert]._type = stringToBytes32(arg_type);
        arg_indexing_alert[alert]._source = stringToBytes32(arg_source);
        arg_indexing_alert[alert]._target = stringToBytes32(arg_target);
        addToAlertIDLlIndex(alert, alertHash_llIndex);

        // test if alert doesn't already exist to add it to the table of alerts
        if (arg_indexing_alert[alert]._type == 0 && arg_indexing_alert[alert]._target == 0 && arg_indexing_alert[alert]._source == 0){
            alerts.push(alert);
        }
        
        argumentor_adresses[msg.sender] = true;
        /* address_indexing_alert_id[msg.sender].alert_id = alert;
        arguments[msg.sender].initialized = true; */

        if (IDS_current_nbr == IDS_threshold) {
            // emit event to be catched in the front end
            // or execute directly the argumentation (internal function call)
            require(
            current_arg_calls_nbr < args_final_nbr,
            "The number of launched argumentations cannot exceed the fixed threshold"
            );
            console.log("calling argumentation");
            doArgumentation();
           
            current_arg_calls_nbr = current_arg_calls_nbr + 1; 
            resetArgumentationParams();

            // see if we are in the final argumentation
            if (current_arg_calls_nbr == args_final_nbr) {
                final_winner = computeFinalWinner();
                console.log("final winner: ");
                emit final_decision_result(final_winner, "final Decision making was a success");
                console.log("Final winner alert type: ", string(abi.encodePacked(final_winner._type)));
                console.log("Final winner alert target: ", string(abi.encodePacked(final_winner._target)));
                console.log("Final winner alert source: ", string(abi.encodePacked(final_winner._source)));
                console.log("Final winner alert weight: ", final_winner.weight);
            }
        }
    }

     /** 
     * @dev Reset the argumentation parameters
     */
    function resetArgumentationParams() private {
        console.log("Reseting params");
        IDS_current_nbr = 0;
        for (uint i=0; i< active_argumentors.length ; i++) {
            argumentor_adresses[active_argumentors[i]] = false;
        }
        for (uint i=0; i< alerts.length ; i++) {
            delete arg_indexing_alert[alerts[i]];
        }
        delete alerts;
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
        
        Argument memory winner;
        Argument[] memory args = new Argument[](IDS_threshold);
        uint8 k = 0;
        bytes32 current_id = alertHash_llIndex[0x0];
        while (current_id != 0) {
            console.log("k = ", k);
            console.log("current_id = ", string(abi.encodePacked(current_id)));
            args[k] = arg_indexing_alert[current_id];
            current_id = alertHash_llIndex[current_id];
            k = k + 1;
        }
        console.log("argumentation finished");
        winner = computeWinner(args);
        bytes32 alert = keccak256(abi.encodePacked(winner._type, winner._source, winner._target));
        if (winners[alert].weight >= 1 ) {
            winners[alert].weight = winners[alert].weight + 1;
        }
        else {
            winners[alert] = winner;
            addToAlertIDLlIndex(alert, winner_llIndex);
            winners[alert].weight = 1;
        }
        emit decision_result(winner, "Decision making was a success");
        console.log("winner alert hash: ", string(abi.encodePacked(alert)));
        console.log("winner alert weight: ", winners[alert].weight);
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

    /** 
     * @dev get the winner from a list of arguments by computing the arguments that is held by the majority  
     * @param _args list of arguments to determine which is the winner
     * @return winner_ the winning argument (holding the majority)
     */
    function computeWinner(Argument[] memory _args) private pure
            returns (Argument memory winner_) 
    {
        uint8 i_winner = 0;
        for (uint8 i = 0; i < _args.length; i++) {
            if (_args[i].argumentors.length > _args[i_winner].argumentors.length) {
                i_winner = i;
            }
        }
        winner_= _args[i_winner];
    }

    /** 
     * @dev get the final winning argument by calculating the majority  
     * @return winner_ the final winning argument (holding the majority)
     */
    function computeFinalWinner() private view
            returns (Argument memory winner_) 
    {

        Argument[] memory args = new Argument[](IDS_threshold);
        uint8 k = 0;
        bytes32 current_winner = winner_llIndex[0x0];
        while (current_winner != 0) {
            console.log("k = ", k);
            console.log("current_winner = ", string(abi.encodePacked(current_winner)));
            args[k] = winners[current_winner];
            current_winner = winner_llIndex[current_winner];
            k = k + 1;
        }
        console.log("argumentation finished");

        uint8 i_winner = 0;
        for (uint8 i = 0; i < args.length; i++) {
            if (args[i].weight > args[i_winner].weight) {
                i_winner = i;
            }
        }
        winner_= args[i_winner];
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }

    assembly {
        result := mload(add(source, 32))
    }
}

    // This function returns the percentage of bytes that are similar
// between two byte arrays.
/* function byteSimilarity(bytes32 a, bytes32 b) public pure returns (uint) {
  // The number of matching bytes.
  uint matches = 0;

  // Loop through each byte in the arrays and check if they are equal.
  for (uint i = 0; i < 32; i++) {
    if (a[i] == b[i]) {
      matches++;
    }
  }

  // Return the percentage of bytes that match.
  return (matches / 32) * 100;
} */

}