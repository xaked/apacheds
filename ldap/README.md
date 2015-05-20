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