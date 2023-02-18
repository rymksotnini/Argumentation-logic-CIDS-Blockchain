import json
import deploy
import subprocess


def main():
    i_scenario = 0
    filename = "../data/results.json"
    with open(filename, "w") as fp:
        json.dump([], fp)
    while True:
        if i_scenario < 5000:
            address = deploy.get_address()
            subprocess.Popen(["python", "listenToArgsResult.py", address, str(i_scenario)])
            subprocess.Popen(["python", "listenToFinalResult.py", address, str(i_scenario)])
            for i in range(3):
                subprocess.run(["python", "addArguments.py", address, str(i_scenario)])
            i_scenario = i_scenario + 1


if __name__ == "__main__":
    main()
