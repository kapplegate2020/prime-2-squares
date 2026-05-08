from time import time
import pickle
from pathlib import Path
import shutil
from multiprocessing import Pool


exceptions = list(map(int, open("../exceptions/prime_cube.txt", "r").read().split()))
possibleCs2, possibleCs3 = pickle.load(open("possibleCs.pkl", "rb"))
    


def getRootFloor(m, k):
    low = 1
    high = m
    while True:
        guess = (low+high)//2
        if guess**k == m:
            return guess
        if high<=low:
            if low**k < m:
                return low
            return low-1
        if guess**k < m:
            low = guess+1
        if guess**k > m:
            high = guess - 1


def tryEC(e):
    try:
        possExceptions = []
        a6 = -27*(e+1)
        E = EllipticCurve([0, 0, -9, 0, a6])
        points = E.integral_points(both_signs=True)
        for point in points:
            x, y = int(point[0]), int(point[1])
            if x%3 == 0 and y%9 == 0 and y>0:
                t = y//9
                c = x//3
                n = e+t**3
                if getRootFloor(n, 3) == t:
                    possExceptions.append(n)
        return possExceptions
    except:
        return None


def skipResidues(start, end, residues, n):
    i = 0
    m = len(residues)
    if start%n>residues[-1]:
        k= start//n+1
    else:
        while start%n > residues[i] and i<m:
            i+=1
        k = start//n
    val = k*n+residues[i]
    while val <= end:
        yield val
        i = (i+1)%m
        if i == 0:
            k += 1
        val = k*n+residues[i]

def cubic_forms(K, D):
    forms = []

    # irreducible
    a_max = floor( (2/(3*sqrt(3))) * K^(1/4) )
    for a in range(1, int(a_max)+1):
        b_max = floor(a/2 + (1/3)*sqrt(max(0, K^(1/2) - (27/4)*a^2)))
        for b in range(0, int(b_max)+1):
            R.<P> = PolynomialRing(RR)
            poly = -4*P^3 + (3*a+6*b)^2*P^2 + 27*a^2*K
            roots = [r for r in poly.roots(multiplicities=False) if r > 0]
            if not roots:
                continue
            P2 = min(roots)

            cmin = ceil((9*b**2-P2)/(9*a))
            cmax = b-a
            n2, residues2 = possibleCs2[(a%(2**6), b%(2**6))]
            n3, residues3 = possibleCs3[(a%(3**3), b%(3**3))]
            residues = []
            for r2 in residues2:
                for r3 in residues3:
                    residues.append(crt([r2, r3], [n2, n3]))
            residues = sorted(residues)

            for c in skipResidues(cmin, cmax, residues, n2*n3):
                R.<d> = PolynomialRing(ZZ)
                f = -27*(a**2*d**2-6*a*b*c*d-3*b**2*c**2+4*a*c**3+4*b**3*d)+108*D
                roots = [r for r in f.roots(multiplicities=False)]
                for root in roots:
                    forms.append((a, b, c, root, D))
        
    #reducible
    Cmin = ceil(-(K/108)^(1/3))
    Cmax = floor((K/27)^(1/2))
    for C in range(Cmin, Cmax+1):
        R.<B> = PolynomialRing(ZZ)
        f = 27*C**2*(3*B**2-4*C)+108*D
        roots = [r for r in f.roots(multiplicities=False)]
        for root in roots:
            forms.append((1, root, C, 0, D))

    return forms

def getIntPoints(e):
    e_transformed = 16*27*(-1-4*e)
    integralXs = set()
    for a, b, c, d, D in cubic_forms(-e_transformed*108, e_transformed):
        t = var("t")
        f = a*t^3 + 3*b*t^2 + 3*c*t + d
        S = gp.thueinit(f, flag=1)
        sols = [tuple(sol) for sol in gp.thue(S, 1)]
        for x, y in sols:
            x, y = int(x), int(y)
            fxx = 6*a*x+6*b*y
            fxy = 6*b*x+6*c*y
            fyy = 6*c*x+6*d*y
            H = fxx*fyy-fxy**2
            assert H%36 == 0
            X = -H//36
            integralXs.add(X)
    
    possExceptions = []
    for x in integralXs:
        y = getRootFloor(x**3+e_transformed, 2)
        if y%36 == 0 and x%12 == 0 and y>0 and (y//36)%2==1:
            t = (y//36+1)//2
            c = x//12
            n = e+t**3
            if getRootFloor(n, 3) == t:
                possExceptions.append(n)
    return possExceptions


def appendFile(filename, message):
    with open(filename, "a") as f:
        f.write(message)


def process(inp):
    i, e = inp
    print(i, e)
    start = time()
    possExceptions = []
    possExceptions = tryEC(e)
    lastTime = time()-start
    if possExceptions == None:
        appendFile(f"temp/log/{i}.txt", f"e={e}, EC failed, time={lastTime}\n")
        start = time()
        possExceptions = getIntPoints(e)
        lastTime = time()-start
        appendFile(f"temp/log/{i}.txt", f"e={e}, method=MWcurve, possExceptions={possExceptions}, time={lastTime}\n")
    else:
        appendFile(f"temp/log/{i}.txt", f"e={e}, method=EC, possExceptions={possExceptions}, time={lastTime}\n")
    appendFile(f"temp/possExceptionByE/{i}.txt", str(e)+":"+str(possExceptions)+"\n")
    for exception in possExceptions:
        appendFile(f"temp/possExceptions/{i}.txt", str(exception)+" ")




totalToDo = len(exceptions)
lastTime = 0
Path("temp").mkdir(exist_ok=True)
Path("temp/log").mkdir(exist_ok=True)
Path("temp/possExceptionByE").mkdir(exist_ok=True)
Path("temp/possExceptions").mkdir(exist_ok=True)
with Pool() as p:
    p.map(process, enumerate(exceptions[:200]))


try:
    shutil.rmtree("logs")
except:
    pass
Path("logs").mkdir(exist_ok=True)
for entry in sorted(Path("temp/log").iterdir(), key=lambda p: int(p.stem)):
    if entry.is_file():
        content = entry.read_text()
        appendFile("logs/log.txt", content)
for entry in sorted(Path("temp/possExceptionByE").iterdir(), key=lambda p: int(p.stem)):
    if entry.is_file():
        content = entry.read_text()
        appendFile("logs/possExceptionByE.txt", content)
for entry in sorted(Path("temp/possExceptions").iterdir(), key=lambda p: int(p.stem)):
    if entry.is_file():
        content = entry.read_text()
        appendFile("logs/possExceptions.txt", content)


shutil.rmtree("temp")
