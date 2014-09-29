samba
=====

Install and configure a simple samba standalone fileserver.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/topics/conventions/formulas.html>`_.

Available states
----------------

``samba``
    Install the ``samba`` package, configure smb.conf file and enable the service.
``samba.users``
    Create unix users and set samba password for authentication.
    The users won't be able to login an shell.
``samba.share_access``
    Controll the existance and ownership of your configured samba shares in
    the filesystem.

All states are configured via pillar data.
Have a look at pillar.example for more information.
