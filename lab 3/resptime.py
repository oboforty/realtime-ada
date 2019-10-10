from lib import fpscalc

"""
dict values in order:
  [C] worst-case comp time
  [T] period time
  [D] deadline
  [J] jitter time: value for Jitter, [Vmin, Vmax] for Jitter range, leave empty for no Jitter
  [B] block time: leave Jitter empty (None or '-') if you have this value, but not Jitter!
"""
# tasks_43 = {
#   "τA": [5, 20, 10, 5],
#   "τB": [30, 50, 50, 10],
# }

tasks = {
  "τ1": [2, 20, 6],
  "τ2": [3, 7, 7],
  "τ3": [5, 14, 13],
  "τ4": [4, 100, 60],
}

prioRM = fpscalc.get_prio(tasks, key=fpscalc.RM)

prioDM = fpscalc.get_prio(tasks, key=fpscalc.DM)



print("RM prio:", prioRM)
print("DM prio:", prioDM)

for i in tasks:
    Ri1 = fpscalc.get_resp(i, tasks, prio=prioRM)
    Ri2 = fpscalc.get_resp(i, tasks, prio=prioDM)

    print("{}:    Ri RM: {}     Ri DM {}".format(i, Ri1, Ri2))


