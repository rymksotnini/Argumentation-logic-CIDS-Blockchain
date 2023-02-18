import json
import sys

from web3 import Web3
import asyncio
import config


# define function to handle events and print to the console
def handle_event(event, i_scenario):
    # Read JSON file
    filename = "../data/results.json"
    with open(filename) as fp:
        listObj = json.load(fp)

    print(event["args"])
    listObj[int(i_scenario)].update({"final_decision": event["args"]["argumentSet"]})

    # Verify updated list
    print(listObj)

    with open(filename, 'w') as json_file:
        json.dump(listObj, json_file, indent=4)

    print('Successfully appended to the JSON file')


# asynchronous defined function to loop
# this loop sets up an event filter and is looking for new entries for the "decision_result" event
# this loop runs on a poll interval
async def log_loop(event_filter, poll_interval, i_scenario):
    while True:
        for event in event_filter.get_new_entries():
            handle_event(event, i_scenario)
        await asyncio.sleep(poll_interval)


def main():
    print(sys.argv[1])
    address = sys.argv[1]
    i_scenario = sys.argv[2]
    final_decision_result_event_filter = config.get_contract(address).events.final_decision_result.createFilter(
        fromBlock='latest'
    )
    loop = asyncio.get_event_loop()
    try:
        print('Started listening from final decision results')
        loop.run_until_complete(
            asyncio.gather(
                log_loop(final_decision_result_event_filter, 2, i_scenario)))

    finally:
        # close loop to free up system resources
        print('Finished listening')
        loop.close()


if __name__ == "__main__":
    main()
