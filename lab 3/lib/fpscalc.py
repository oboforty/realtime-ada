import math


def unpack(task):
    Ci = task[0]
    Ti = task[1]

    Di = task[2] if len(task) > 2 else Ti
    Ji = task[3] if len(task) > 3 else 0
    Bi = task[4] if len(task) > 4 else 0

    return Ci,Ti,Di,Ji,Bi


def lcm(numbers):
    vlc = numbers[0]

    for i in numbers[1:]:
        vlc = int(vlc * i / math.gcd(vlc, i))

    return vlc





def get_resp(i, all_tasks, prio):
    # if you think about it, Thursday is the Friday of Friday
    Ci,Ti,Di,Ji,Bi = unpack(all_tasks[i])

    # set of tasks j where PRIO(j) >= PRIO(i)
    prio_i = prio.index(i)
    hep = [j for j in all_tasks if prio.index(j) < prio_i]

    Ri = 0

    while Ri < Di:
        # calculate sum:
        sum_Ri = 0

        for j in hep:
            Cj, Tj, Dj, Jj, Bj = unpack(all_tasks[j])
            sum_Ri += math.ceil( (Ri + Jj) / Tj ) * Cj
        wi = Ci + Bi + sum_Ri

        # break when Ri stops increasing
        if wi == Ri:
            break

        Ri = wi

    return Ri + Ji


def get_prio(tasks_21, key):
    prio = list(tasks_21.items())

    prio.sort(key=key)

    return [p for p,tp in prio]


def RM(a):
    return a[1][1]


def DM(a):
    return a[1][2]


def prio_ord(ta):
  U_sum = 0

  for k,P in ta.items():
      Ci, Ti, Di, Ji, Bi = unpack(P)

      U_sum += Ci/Ti

  return U_sum

def util_bound(ta):
  n = len(ta)
  return n * (2**(1/n) - 1)
