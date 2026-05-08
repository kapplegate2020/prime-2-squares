exceptionList = list(map(int, open("../../exceptions/prime_cube.txt", "r").read().split()))
cubes = set(t**3 for t in range(0, int(exceptionList[-1]**(1/3))+2))

maxT = 0
val = 1
while val < exceptionList[-1]:
    maxT+=1
    val = 3*maxT**2-3*maxT+1


possibleBadNs = set()

for t in range(1, maxT+1):
    for e in exceptionList:
        if (t-1)**3+e-t**3 in cubes:
            possibleBadNs.add((t-1)**3+e)

with open("possibleBadNs.txt", "w") as f:
    for x in sorted(possibleBadNs):
        f.write(f"{x}\n")
