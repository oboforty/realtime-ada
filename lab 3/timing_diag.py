import sys

import numpy as np
import matplotlib.pyplot as plt

def draw(times, max_T, marks=None, arrows=None):
    if arrows is None:
        arrows = []

    max_T += 1
    datas = {}
    for task, execs in times.items():
        # initialize:
        datas[task] = np.repeat([0], max_T+1)

        for s,t in execs:
            datas[task][s+1:t+1] = 1

    y_lines = [0, 2, 4, 6, 8, 10]
    t = np.concatenate((np.array([-0.01]), np.arange(0, max_T)))
    N = len(times)-1


    # Y lines
    for i,name in enumerate(times.keys()):
        p = y_lines[N-i]
        plt.text(-2.0, y_lines[N-i]+0.1, name)

        plt.axhline(p, xmin=0.04,  color='.3', linewidth=0.5)

    # draw bars and texts
    for p in range(0,max_T):
        plt.axvline(p, ymin=0.12, ymax=0.16,  color='.3', linewidth=0.5 if marks is None or p not in marks else 1.5)

        if marks is None or p in marks:
            plt.text(p-0.3, y_lines[0] - 0.4, str(p))


    for i,task in enumerate(times):
        plt.step(t, datas[task] + y_lines[N-i], 'r', linewidth=2, where='post')
    plt.ylim([-1,2*N+2])


    for i,arr in enumerate(arrows.values()):

        for up,down in arr:
            if up is not None and up != '-':
                plt.arrow(t[up+1], y_lines[N-i], 0, 1.4, head_width=0.5, head_length=0.3, head_starts_at_zero=False, zorder=5)

            if down is not None and down != '-':
                plt.arrow(t[down + 1], y_lines[N-i]+1.7, 0, -1.4, head_width=0.5, head_length=0.3, head_starts_at_zero=False, zorder=5)


    # plt.step(t, manchester, 'r', linewidth = 2, where='post')


    plt.gca().axis('off')
    plt.show()


    #bits
    #bits = [0,0,0,0,0,0,0,0,0,1]
    #data = np.repeat(bits, 2)
    # clock = 1 - np.arange(len(data)) % 2
    # manchester = 1 - np.logical_xor(clock, data)
