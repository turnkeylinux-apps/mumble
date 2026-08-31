#!/usr/bin/python3
"""Set Mumble icesecretwrite and Edit Config Files
Option:
    --pass=     unless provided, will ask interactively
"""

import sys
import getopt
from pathlib import Path
import re

from libinithooks.dialog_wrapper import Dialog
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

    config = Path('/etc/mumble/mumble-server.ini')
    content = config.read_text()
    content, count = re.subn(
        r'(?m)^[;#]?icesecretwrite=.*$',
        lambda _: 'icesecretwrite=%s' % password,
        content,
    )
    if count != 1:
        raise RuntimeError('unable to set Mumble Ice write secret')
    config.write_text(content)

    subprocess.run(['service', 'mumble-server', 'restart'], check=True)

if __name__ == "__main__":
    main()
