import json
import os
import time
from datetime import datetime
import psutil

import deploy
import subprocess


def main():
    results_file = "../data/results.json"
    final_results_file = "../data/finalResults.json"
    time_file = "../data/timeElapsed.txt"
    start_time = time.time()
    if os.stat(results_file).st_size == 0:
        i_scenario = 0
        with open(results_file, "w") as fp:
            json.dump([], fp)
            fp.close()
        with open(final_results_file, "w") as fp:
            json.dump([], fp)
            fp.close()
    else:
        with open(results_file) as fp:
            data = json.load(fp)
            i_scenario = len(data)
    print(i_scenario)

    while True:
        if i_scenario < 5000:
            print("i_scenario: ", i_scenario)
            address = deploy.get_address()
            process1 = subprocess.Popen(
                ["python", "listenToArgsResult.py", address, str(i_scenario)]
            )
            process2 = subprocess.Popen(
                ["python", "listenToFinalResult.py", address, str(i_scenario)]
            )
            for i in range(3):
                try:
                    res = subprocess.run(
                        ["python", "addArguments.py", address, str(i_scenario)],
                        check=False,
                        # capture_output=True,
                        # text=True
                    )
                    if res.returncode != 0:
                        with open(results_file) as fp:
                            listObj = json.load(fp)
                        if len(listObj) > int(i_scenario):
                            print("Removing item...")
                            print("removed item: ", listObj[i_scenario])
                            listObj.remove(listObj[i_scenario])
                            with open(results_file, 'w') as json_file:
                                json.dump(listObj, json_file, indent=4)
                        i_scenario = i_scenario - 1
                        break
                except Exception as e:
                    # catch any other exception that may have occurred
                    print(f"Exception occurred: {e}")
            # with open(results_file) as fp:
            #     listObj = json.load(fp)
            #     print("list length:", len(listObj))
            end_time = time.time()
            elapsed_time = end_time - start_time
            now = datetime.now()
            time_details = now.strftime("%Y-%m-%d %H:%M:%S")
            print(f"***{time_details}, scenario number: {i_scenario}, Elapsed Time: {str(elapsed_time)}, "
                  f"CPU usage: {psutil.cpu_percent(4)}, RAM usage: {psutil.virtual_memory()[2]}\n***")
            with open(time_file, "a") as file:
                file.write(f"{time_details}, scenario number: {i_scenario}, Elapsed Time: {str(elapsed_time)}, "
                           f"CPU usage: {psutil.cpu_percent(4)}, RAM usage: {psutil.virtual_memory()[2]}\n")
            file.close()
            with open(results_file, "r") as fp_res:
                res = json.load(fp_res)
            with open(final_results_file, "r") as fp_fres:
                fres = json.load(fp_fres)

            while len(res) == i_scenario or len(fres) == i_scenario:  # be sure that results where appended
                continue                                              # in file by listener before killing process
            process1.kill()
            process2.kill()
            print("processes killed")
            i_scenario = i_scenario + 1


if __name__ == "__main__":
    main()
