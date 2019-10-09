import sys

import numpy as np
import matplotlib.pyplot as plt

def draw(times, max_T, marks=None, arrows=None, show_outlines=False):
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

        plt.vlines(p, ymin=y_lines[0]-0.15, ymax=y_lines[0]+0.15,  color='.3', linewidth=0.5 if marks is None or p not in marks else 1.5)

        if marks is None or p in marks:
            plt.text(p-0.3, y_lines[0] - 0.4, str(p))


    for i,task in enumerate(times):
        if show_outlines:
            plt.step(t, datas[task] + y_lines[N-i], 'r', linewidth=2, where='post')

        plt.fill_between(t, datas[task] + y_lines[N-i], y_lines[N-i], step='post')
    plt.ylim([-1,2*N+2])


    for i,arr in enumerate(arrows.values()):

        for rrr in arr:
            up, down, jitter = None, None, None
            if len(rrr) > 2:
                jitter,up,down = rrr
            else:
                if len(rrr) > 0: up = rrr[0]
                if len(rrr) > 1: down = rrr[1]

            if up is not None and up != '-':
                plt.arrow(t[up+1], y_lines[N-i], 0, 1.4, head_width=0.5, head_length=0.3, head_starts_at_zero=False, zorder=5, facecolor='#000000')

            if down is not None and down != '-':
                plt.arrow(t[down + 1], y_lines[N-i]+1.7, 0, -1.4, head_width=0.5, head_length=0.3, head_starts_at_zero=False, zorder=5, facecolor='#000000')

            if jitter is not None and jitter != '-':
                plt.arrow(t[jitter+1], y_lines[N-i], 0, 1.4, head_width=0.5, head_length=0.3, head_starts_at_zero=False, zorder=5, facecolor='#FFFFFF')


    # plt.step(t, manchester, 'r', linewidth = 2, where='post')


    plt.gca().axis('off')
    plt.show()


    #bits
    #bits = [0,0,0,0,0,0,0,0,0,1]
    #data = np.repeat(bits, 2)
    # clock = 1 - np.arange(len(data)) % 2
    # manchester = 1 - np.logical_xor(clock, data)
