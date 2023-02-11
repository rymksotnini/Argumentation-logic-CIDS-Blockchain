import deploy
import subprocess


def main():
    i = 0
    address = deploy.get_address()
    subprocess.Popen(["python", "listenToArgsResult.py", address])
    subprocess.Popen(["python", "listenToFinalResult.py", address])
    while True:
        if i < 1:
            for i in range(2):
                subprocess.run(["python", "addArguments.py", address])


if __name__ == "__main__":
    main()
