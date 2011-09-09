DDNSUpdate
==========

DDNSUpdate is a simple wrapper around nsupdate and dig to make updating
a dynamic dns host easier. Right now, options are quite limited (single
host with optionnal wildcard) but it may change over time.

**Author**:    [Hugues Lismonde](mailto:ryan@wonko.com)

**Version**:   0.1.6 (2011-09-09)

**Copyright**: Copyright (c) 2011 Hugues Lismonde. All rights reserved.

**License**:   WTFPL 2.0 (http://sam.zoy.org/wtfpl/)

**Website**:   http://github.com/epicagency/ddnsupdate/


Installation
------------

  gem install ddnsupdate

Usage
-----

ddnsupdate <command> [options]

**Commands:**

                up:   Updates host
               gen:   Generate secret key from password
                ip:   Display current local or remote ip

**Update options:**

     --key, -k <s>:   DNS Key
    --host, -h <s>:   Hostname to update
      --remote, -r:   Use remote IP (default: local ip)
        --wild, -w:   Add a wildcard on the same IP (i.e. *.host IN A ip)

**Generate options:**

    --pass, -p <s>:   Password to hash
    --bind, -b <s>:   Output as a bind key definition

**IP options:**

      --remote, -r:   Display remote ip instead of local

Usage example
-------------

First you have to setup your dns server (see below for an example). Once
done, generate a key for your host by running:

    ddnsupdate gen -p <password>

Append `-b <hostname>` to output to a bind key format if that's what you
use.

After your setup is complete, periodicaly run:

    ddnsupdate up -h <hostname> -k <password>

This will update <hostname> with your local ip (usefull for testing on a
local network). If you want it to be your remote IP simply add `-r`.

You can also use the `-w` flag to add a wildcard to your host, pointing
on the same IP (so host.name and \*.host.name both point on the same
address).

Bind configuration example
--------------------------

For DDNSUpdate to be of any use you need to have a DNS server that
accepts dynamic update through `nsupdate`. Here you'll find a quick
example how to setup a zone to do just that.

First you'll have to chose a subdomain to use. While it's possible to
set it up on the root domain, I strongly recommand you do not so if you
have static hosts defined. nsupdate will mess with your zone file,
rendering it unreadable.

So, let's say we have `example.com` as our root domain and we want to
use `dyn.example.com` for our dynamic needs. First thing to do is
delegate the subdomain to another server (it doesn't need to be a
physically different host).

In the `example.com` zone file add:

    $ORIGIN dyn.example.com.
    @ IN NS dns.example.com.

Where `dns.example.com` is the server that will host the sub zone.

Then, create a new zone file for the sub zone and add the SOA:

    $ORIGIN .
    $TTL 300  ; 5 minutes
    @    IN SOA  dns.example.com. info.example.com. (
        2011090933 ; serial
        1800       ; refresh (30 minutes)
        900        ; retry (15 minutes)
        604800     ; expire (1 week)
        1800       ; minimum (30 minutes)
        )
      NS  dns.example.com.

A TTL of 5 minutes is good but change according to your needs.

Finally you need to update your `named.conf` to allow ddnsupdate to
update the zone.

    zone "dyn.example.com" {
      type master;
      file "/var/named/dyn.example.com.conf";
      update-policy {
        grant *.dyn.example.com. self dyn.example.com. A;
        };
      };

Add your key files (use `ddnsupdate gen -p <pass> -b <host>` to get one
suitable for ddnsupdate):

    key "host1.dyn.example.com." {
      algorithm hmac-md5;
      secret "YWNiZDE4ZGI0Y2MyZjg1Y2VkZWY2NTRmY2NjNGE0ZDg=";
    };

Reload named and you should be good to go.

If you want to allow wildcard updates, you will need to add one grant
line per host allowed using the following model:

    grant host1.dyn.example.com. subdomain host1.dyn.example.com. A;

Know issues
-----------

* If ddnsupdate can't find the SOA for the given host it will probably
loop infinitely. That will be corrected in the near future.

License
-------
<pre>
            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
                    Version 2, December 2004 

 Copyright (C) 2004 Sam Hocevar <sam@hocevar.net> 

 Everyone is permitted to copy and distribute verbatim or modified 
 copies of this license document, and changing it is allowed as long 
 as the name is changed. 

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION 

  0. You just DO WHAT THE FUCK YOU WANT TO.
</pre>
