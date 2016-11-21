#!/usr/bin/python
"""Set Mumble Server Default Super User password and Edit Config Files
Option:
    --pass=     unless provided, will ask interactively
"""

import sys
import getopt
import subprocess

from dialog_wrapper import Dialog

def usage(s=None):
    if s:
        print >> sys.stderr, "Error:", s
    print >> sys.stderr, "Syntax: %s [options]" % sys.argv[0]
    print >> sys.stderr, __doc__
    sys.exit(1)

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "h",
                                       ['help', 'pass='])
    except getopt.GetoptError, e:
        usage(e)

    password = ""
    for opt, val in opts:
        if opt in ('-h', '--help'):
            usage()
        elif opt == '--pass':
            password = val

    if not password:
        d = Dialog('TurnKey Linux - First boot configuration')
        password = d.get_password(
            "Mumble Server SuperUser Password",
            "Enter SuperUser Password.")
    
    subprocess.call('/usr/lib/inithooks/bin/mumblesupw.sh %s' % (str(password)), shell=True)

if __name__ == "__main__":
    main()
