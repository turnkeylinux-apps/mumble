#!/usr/bin/python3
"""Set Mumble icesecretwrite and Edit Config Files
Option:
    --pass=     unless provided, will ask interactively
"""

import sys
import getopt

from dialog_wrapper import Dialog
import subprocess

def usage(s=None):
    if s:
        print("Error:", s, file=sys.stderr)
    print("Syntax: %s [options]" % sys.argv[0], file=sys.stderr)
    print(__doc__, file=sys.stderr)
    sys.exit(1)

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "h",
                                       ['help', 'pass='])
    except getopt.GetoptError as e:
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
            "Mumble Ice Secret Write For ICE Administration",
            "Enter icesecretwrite.")
    
        subprocess.run(['sed', '-i', "s/.*icesecretwrite=.*/icesecretwrite=%s/g" % password, '/etc/mumble-server.ini'])

    for i in ('mumble-server', 'apache2'):
        subprocess.run(['service', i, 'restart'])

if __name__ == "__main__":
    main()
