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

    struct Argument {
        uint32 alert_id;
        address[] argumentors;
    }

    // mapping that shows if an address represents an argumentor(added an argument) or not
    mapping (address => bool) public argumentor_adresses;
    // for an id alert this mapping help in finding the related addresses 
    // mapping (uint32 => address[]) public address_indexing_alert_id;
    // for an id alert this mapping help in finding the related arggument 
    mapping (uint32 => Argument) public arg_indexing_alert_id;
    // alert ID linked list indexes
    mapping (uint32 => uint32) ID_llIndex;

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
    bool[] public  argumentation_history;
    // the winning result after an argumentation
    Argument public winner; 
    // the event that will be emited once the argumentation ends
    event decision_result(Argument argument, string message);

    constructor(uint8 IDS_number, uint8 args_threshold, uint8 history_length) {
        
        argumentation_history = new bool[](history_length);
        for (uint8 i = 0; i < history_length; i++) {
            argumentation_history[i] = false;
        }

        args_final_nbr = args_threshold;

        IDS_threshold = IDS_number;

        current_arg_calls_nbr = 0;

        IDS_current_nbr = 0;

    }

    /** 
     * @dev Add the IDS's argument to the argumentation logic
     * @param alert id of the added alert by sender
     */
    function addArgument(uint32 alert) public {
        require(
            newArgumentor(msg.sender),
            "Only a node that has not argumented yet, can add an argument"
        );

        require(
            IDS_current_nbr < IDS_threshold,
            "The number of arguments cannot exceed the fixed threshold"
        );
        
        console.log("adding argument");

        IDS_current_nbr = IDS_current_nbr + 1;
        arg_indexing_alert_id[alert].argumentors.push(msg.sender);
        arg_indexing_alert_id[alert].alert_id = alert;
        addToAlertIDLlIndex(alert);
        
        argumentor_adresses[msg.sender] = true;
        /* address_indexing_alert_id[msg.sender].alert_id = alert;
        arguments[msg.sender].initialized = true; */

        if (IDS_current_nbr == IDS_threshold) {
            // emit event to be catched in the front end
            // or execute directly the argumentation (internal function call)
            console.log("calling argumentation");
            doArgumentation();
        }

        // reinitialize argumentor_adresses, arg_indexing_alert_id, ID_llIndex
        // update argumentation_history
        // we will have a new winner, a table of winners may be more approriate 
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
        
        Argument[] memory args = new Argument[](IDS_threshold);
        uint8 k = 0;
        uint32 current_id = ID_llIndex[0x0];
        while (current_id != 0) {
            console.log("k = ", k);
            console.log("current_id = ", current_id);
            args[k] = arg_indexing_alert_id[current_id];
            current_id = ID_llIndex[current_id];
            k = k + 1;
        }
        console.log("argumentation finished");
        winner = computeWinner(args);
        emit decision_result(winner, "Decision making was a success");
    }

    /** 
     * @dev add id in the linked list of ID indexes 
     * @param _id the alert ID to add in the list
     */
    function addToAlertIDLlIndex(uint32 _id) private
    {
        if (!(_id == ID_llIndex[0x0] || ID_llIndex[_id] != 0 )) {
            ID_llIndex[_id] = ID_llIndex[0x0];
            ID_llIndex[0x0] = _id;
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

     
}