Mumble Server - the open source VoIP solution
=============================================

Mumble_ is open source, low-latency, high quality voice chat software
primarily intended for use while gaming. The client and server are free
software. The client is called Mumble and the server is called Mumble
Server.

Mumble Server supports public and private voice servers, extensive user
permission configuration using access control lists (ACLs), and
programmatic administration through RPC. One daemon can run multiple
virtual servers on different TCP and UDP ports.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

    - Mumble Server from the Debian package repository.

    - Encrypted Mumble client connections on TCP port 64738, with voice
      traffic on UDP port 64738. Amazon EC2 users must also allow these
      ports in their security group.

    - A TurnKey web control panel with a link to Webmin.

    **Note:** A browser-based Mumble administration interface is not
    included. Administrators can use the official Mumble client or a local
    Ice-based tool described in the `Mumble administration documentation`_.
    Use an SSH tunnel when an Ice tool runs on another system.

Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH: username **root**
-  Mumble Server: username **SuperUser**

.. _Mumble: https://www.mumble.info/
.. _TurnKey Core: https://www.turnkeylinux.org/core
.. _Mumble administration documentation: https://www.mumble.info/documentation/administration/
