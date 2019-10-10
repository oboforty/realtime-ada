import os
import sys

import json
from lib.timing_diag import draw, save, show, close


def draw_save(fn):
    name,ext = os.path.splitext(os.path.basename(fn))

    with open(fn, encoding='utf8') as fh:
        kwargs = json.load(fh)

    draw(**kwargs)
    save("img/"+name+".png")


if __name__ == "__main__":
    if len(sys.argv) <= 1:
        print("Saving all diagrams to img/")
        for fn in os.listdir('diagrams'):
            draw_save('diagrams/'+fn)
            close()
    else:
        fn = sys.argv[1]

        draw_save(fn)
        show()
        close()

