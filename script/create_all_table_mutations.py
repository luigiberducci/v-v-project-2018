#Create all the table mutations. Each one change a single cell adding or subtracting a percentual value.
import os

ROWS = 6
COLS = 4
SCRIPT = "create_single_table_mutation.py"

for t in ["UP_TABLE", "DOWN_TABLE"]:
    for r in range(0, ROWS):
        for c in range(0, COLS):
            for i in ["--inc",""]:
                command = "python %s %s %d %d %s" %(SCRIPT, t, r, c, i)
                os.system(command)
