# ddns

A key auth based dynamic DNS solution.

---

You'll need to create a key pair that determines who is authorized to update a given subdomain. The private key (on the client) should be named "~/.ddns/_domainname.com.pem". The pubkey, on the server, should be named "/root/.ddns/_subdomain.pub" where the subdomain is the one you'll be updating with the associated privkey.

Optionally, you'll need to create a key pair with a private key for the server for the get IP functionality. The private key should be named "~/.ddns/_getip.pem". (~ is probably /root.) The pubkey goes on the client machine should be named ~/.ddns/_hostname.com.pub, where ~ is the home of the user that will be running the client.

The db file goes in /var/lib/bind/

The named.conf file goes in /etc/bind/

The xinet file goes in /etc/xinetd.d/

Make sure to modify them appropriately.
