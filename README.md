# ApacheDS

This Docker image provides an [ApacheDS](https://directory.apache.org/apacheds/) LDAP server. Optionally it could be used to provide a [Kerberos server](https://directory.apache.org/apacheds/advanced-ug/2.1-config-description.html#kerberos-server) as well.

The project sources can be found on [GitHub](https://github.com/xaked/apacheds). The Docker image on [Docker Hub](https://registry.hub.docker.com/u/xaked/apacheds/).


## Build

    git clone https://github.com/xaked/apacheds.git
    docker build -t xaked/apacheds:2.0.0.AM26 apacheds


## Installation

The folder */var/lib/apacheds* contains the runtime data and thus has been defined as a volume. The image uses exactly the file system structure defined by the [ApacheDS documentation](https://directory.apache.org/apacheds/advanced-ug/2.2.1-debian-instance-layout.html).

The container can be started issuing the following command:

    docker run --name ldap -d -p 389:10389 xaked/apacheds


## Usage

You can manage the ldap server with the admin user *uid=admin,ou=system* and the default password *secret*. The *default* instance comes with a pre-configured partition *dc=xaked,dc=org*.

An individual admin password should be set following [this manual](https://directory.apache.org/apacheds/basic-ug/1.4.2-changing-admin-password.html).

Then you can import entries into that partition via your own *ldif* file:

    ldapadd -v -h <your-docker-ip>:389 -c -x -D uid=admin,ou=system -w <your-admin-password> -f sample.ldif


## Customization

It is also possible to start up your own defined Apache DS *instance* with your own configuration for *partitions* and *services*. Therefore you need to mount your [config.ldif](https://github.com/xaked/apacheds/blob/master/instance/config.ldif) file and set the *APACHEDS_INSTANCE* environment variable properly. In the provided sample configuration the instance is named *default*. Assuming your custom instance is called *yourinstance* the following command will do the trick:

    docker run --name ldap -d -p 389:10389 -e APACHEDS_INSTANCE=yourinstance -v /path/to/your/config.ldif:/bootstrap/conf/config.ldif:ro xaked/apacheds


It would be possible to use this ApacheDS image to provide a [Kerberos server](https://directory.apache.org/apacheds/advanced-ug/2.1-config-description.html#kerberos-server) as well. Just provide your own *config.ldif* file for that. Don't forget to expose the right port, then.

Also other services are possible. For further information read the [configuration documentation](https://directory.apache.org/apacheds/advanced-ug/2.1-config-description.html).

### Custom Root DC

To customize the existing configuration with a different root DC you need to find and replace a number of strings within `ome.ldif`, `instance/config.ldif` and `instance/ads-contextentry.decoded`. Specifically find and replace `dc=org`, `dc: org`, `xaked.org` and `xaked`.

For a custom root dc of `example.com`:

```shell
$ sed -i 's/xaked/example/g' ome.ldif ./instance/config.ldif ./instance/ads-contextentry.decoded
$ sed -i 's/dc=org/dc=com/g' ome.ldif ./instance/config.ldif ./instance/ads-contextentry.decoded
$ sed -i 's/dc: org/dc: com/g' ome.ldif ./instance/config.ldif ./instance/ads-contextentry.decoded
```

Then [build](##-Build), [install](##-Installation) and [use](##-Usage) as you normally would.
