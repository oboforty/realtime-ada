import sys

import json
from timing_diag import draw


if len(sys.argv) <= 1:
    print("Please provide filename:    'draw.py file.json'")
    sys.exit()

with open(sys.argv[1], encoding='utf8') as fh:
    kwargs = json.load(fh)


draw(**kwargs)
