LDAP
====

Cleanup
-------

To cleanup the tree on the development LDAP server, use the ldapdelete command::

````
ldapdelete -Wx -h ldap-ci.docker.openmicroscopy.org -p 10389 -D uid=admin,ou=system -r dc=merge,dc=trout,dc=openmicroscopy,dc=org
````

The tree can be re-initialized from the init.ldif file a

````
ldapadd  -h ldap-ci.docker.openmicroscopy.org -p 10389 -x -D uid=admin,ou=system -W -f init.ldif
````

To visualize the content of the tree, use ldapsearch

````
ldapsearch -h ldap-ci.docker.openmicroscopy.org -p 10389 -x -D uid=admin,ou=system -W -b dc=merge,dc=trout,dc=openmicroscopy,dc=org
````

User and group management
-------------------------

The [user](user) and [group](group) scripts allow to populate the LDAP tree as
follows.

To add a new user to the LDAP server:

````
./user ldapuser-xx add
````

This will create a user named ldapuser-xx

To add a new group to the LDAP server:


````
./group ldap-group add
```

To add an existing user `ldapuser-xx` to a group `ldap-group`:


````
./user ldapuser-xx in ldap-group
````

To remove an existing user `ldapuser-xx` from the group `ldap-group`:


````
./user ldapuser-xx out ldap-group
````

To set an existing user `ldapuser-xx` as owner of the group `ldap-group`:


````
./user ldapuser-xx owner ldap-group
````

To set an existing user `ldapuser-xx` as member of the group `ldap-group`:


````
./user ldapuser-xx member ldap-group
````