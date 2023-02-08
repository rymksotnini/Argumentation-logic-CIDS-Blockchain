from web3 import Web3
import asyncio
import config


# define function to handle events and print to the console
def handle_event(event):
    print(Web3.toJSON(event))
    # and whatever


# asynchronous defined function to loop
# this loop sets up an event filter and is looking for new entries for the "decision_result" event
# this loop runs on a poll interval
async def log_loop(event_filter, poll_interval):
    while True:
        for event in event_filter.get_new_entries():
            handle_event(event)
        await asyncio.sleep(poll_interval)


def main():
    print(config.address)
    final_decision_result_event_filter = config.contract.events.final_decision_result.createFilter(
        fromBlock='latest'
    )
    loop = asyncio.get_event_loop()
    try:
        print('Started listening')
        loop.run_until_complete(
            asyncio.gather(
                log_loop(final_decision_result_event_filter, 2)))

    finally:
        # close loop to free up system resources
        print('Finished listening')
        loop.close()


if __name__ == "__main__":
    main()
