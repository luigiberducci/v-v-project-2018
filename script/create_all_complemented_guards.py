#Create all the guard mutations. Each one complement a single guard.
import os

SCRIPT = "create_single_complemented_guard.py"

FIRST_MUTABLE_GUARD=0
LAST_MUTABLE_GUARD=5
for i in range(FIRST_MUTABLE_GUARD, LAST_MUTABLE_GUARD+1):
    command = "python %s %d" %(SCRIPT, i)
    os.system(command)
    print "-----------------------------------------------------------"
