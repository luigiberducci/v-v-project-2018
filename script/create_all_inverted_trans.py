#Create all the table mutations. Each one change a single cell adding or subtracting a percentual value.
import os

SCRIPT = "create_single_inverted_trans.py"

FIRST_ARROW_INVERTIBLE=1
LAST_ARROW_INVERTIBLE=14
for i in range(FIRST_ARROW_INVERTIBLE, LAST_ARROW_INVERTIBLE+1):
    command = "python %s %d" %(SCRIPT, i)
    os.system(command)
