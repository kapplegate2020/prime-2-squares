from collections import defaultdict
from sympy import integer_nthroot
from theorem4_1 import getCubeCubePrime



N = 10**16
T = integer_nthroot(N, 3)[0]
mod = 351
#there are other good choices of moduli besides 351, however no smaller modulus is better
#we chose 351 to balance the size of the modulus and the amound of classes skipped



#find the pairs of (t, a) modulo 351 such that t^3+a^3-(t-1)^3 can be a cube
cubes = set()
for i in range(mod):
    cubes.add(pow(i, 3, mod))
    
pairs = defaultdict(list)
for t in range(mod):
    for a in range(mod):
        b = (pow(t, 3, mod)+pow(a, 3, mod)-pow(t-1, 3, mod))%mod
        if b in cubes:
            pairs[t].append(a)



#create generators to skip the appropriate classes mod 351
def getT():
    global mod
    subset = sorted(pairs.keys())
    i, k = 2, 0
    while True:
        if i == len(subset):
            i = 0
            k += 1
        yield subset[i] + k * mod
        i += 1

def getA(t):
    global mod
    subset = pairs[t]
    i, k = 0, 0
    while True:
        if i == len(subset):
            i = 0
            k += 1
        yield subset[i] + k * mod
        i += 1



#loop through t and a, checking that if n-(t-1)^3 is a cube,
#then n is the sum of a prime and two cubes
genT = getT()
t = next(genT)
while t < T:
    if len(pairs[t%mod]) == 0:
        t = next(genT)
        continue
    maxA = 3*t**2+3*t+1
    genA = getA(t%mod)
    a = next(genA)
    while a**3 < maxA:
        n = t**3+a**3
        if integer_nthroot(n-(t-1)**3, 3)[1]:
            if getCubeCubePrime(n) == None:
                print("failed", n)
        a = next(genA)
    t = next(genT)