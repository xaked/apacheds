LDAP
====

A collection of scripts to manage LDAP trees on the CI LDAP servers. Four scripts are available:

- [clear](clear) clears an existing LDAP tree
- [initialize](initialize) initializes a new LDAP tree
- [user](user) manages LDAP users (addition, group membership/ownership)
- [user](user) manages LDAP groups (addition)

The connection credentials and the tree domain are defined and can be overriden
using four environment variable: `LDAPHOST, `LDAPPORT`, `LDAPPASS` and
`LDAPDOMAIN`.

To visualize the content of the tree, use ldapsearch

````
ldapsearch -h $LDAPHOST -p $LDAPPORT -x -D uid=admin,ou=system -W -b $LDAPDOMAIN
````