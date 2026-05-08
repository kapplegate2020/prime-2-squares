possibleBadNs = list(map(int, open("logs/possExceptions.txt", "r").read().split()))

with open("possibleBadNs.txt", "w") as f:
    for x in sorted(possibleBadNs):
        f.write(f"{x}\n")