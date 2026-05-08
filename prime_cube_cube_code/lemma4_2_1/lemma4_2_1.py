exceptionList = list(map(int, open("../../exceptions/prime_cube.txt", "r").read().split()))
polynomialValues = {}
t = 1
val = 1
while val < exceptionList[-1]:
    polynomialValues[val] = t
    t+=1
    val = 3*t**2-3*t+1

possibleBadNs = set()

for i, e1 in enumerate(exceptionList):
    for e2 in exceptionList[i:]:
        if e2-e1 in polynomialValues:
            possibleBadNs.add(polynomialValues[e2-e1]**3+e1)

with open("possibleBadNs.txt", "w") as f:
    for x in sorted(possibleBadNs):
        f.write(f"{x}\n")
