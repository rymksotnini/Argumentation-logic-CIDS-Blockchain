import json


def main():
    results_file = "../data/results.json"
    final_results_file = "../data/finalResults.json"
    with open(final_results_file) as fp:
        data = json.load(fp)
    with open(results_file) as fp:
        details = json.load(fp)
    reliability = 0
    no_winning_cluster = 0
    previous_scenario = data[0]["num_scenario"]
    for element in data:
        print("previous_scenario", previous_scenario)
        print("element[num_scenario]", element["num_scenario"])
        #take into consideration the duplication of results
        if (previous_scenario == element["num_scenario"]) and (previous_scenario != data[0]["num_scenario"]):
            print("duplicate case")
            continue
        winning_cluster = element["final_decision"][0]
        print("winning_cluster", winning_cluster)
        if winning_cluster != 0:
            for item in details[int(element["num_scenario"])]["arg_decisions"]:
                if (item[0] == winning_cluster) and (item[1][0][3] == 1):
                    reliability = reliability + 1
                    break
        else:
            no_winning_cluster = no_winning_cluster + 1
            print("No winning cluster")
        print("Reliability", reliability)
        previous_scenario = element["num_scenario"]
    print("no_winning_cluster",no_winning_cluster)
    print("Reliability percentage", reliability/(len(details)-no_winning_cluster)*100)
    print("Reliability percentage for the total", reliability/len(details)*100)
        


if __name__ == "__main__":
    main()
