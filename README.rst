Mumble Server - the open source VoIP solution
=============================================

Mumble_ is an open source, low-latency, high quality voice chat
software primarily intended for use while gaming. Mumble is 
free software, meaning it is available at no cost and under a very 
liberal license. The client is called "Mumble". The Server is 
known as "Mumble Server" or "Murmur".

Mumble's server component, Murmur, allows anyone to run a server 
of their own for public or private use, free of charge. Murmur 
supports extensive user permission configuration using access 
control groups (ACLs) and can be configured programmatically via 
RPC. A single Murmur daemon can also run multiple Murmur servers 
on different TCP/UDP ports.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

    - Mumble Server/MurMur

    - Default Mumble port 64738 open by default (Amazon EC2 users will
      need to open additional manually).

    **Note** due to incompatabilities with PHP7 the web UI compents
    have been removed from v15.x release. Remote Mumble server
    management can be done using either the offical `Mumble` app, or
    one of the many `third party apps`_.

Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH: username **root**
-  Mumble Server: username **superuser**

.. _Mumble: https://wiki.mumble.info/
.. _TurnKey Core: https://www.turnkeylinux.org/core
.. _third party apps: https://wiki.mumble.info/wiki/3rd_Party_Applications
