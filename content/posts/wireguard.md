+++
author = "Lucas DRAESCHER"
title = "A super fast WireGuard config"
date = "2021-10-05"
tags = [
  "WireGuard",
  "VPN",
  "networking"
]
+++


# Introduction
In this article, I'll be writing about how I set up a Wireguard VPN on my home server in order to gain access to my home network remotely. We'll start off with the server-side configuration and move on to the client-side next.


# Table of Contents
- [Introduction](#introduction)
- [Table of Contents](#table-of-contents)
- [Prerequisites](#prerequisites)
- [Where to find the files](#where-to-find-the-files)
- [Common steps](#common-steps)
- [Server-side configuration](#server-side-configuration)
- [Client-side configuration](#client-side-configuration)
- [Connect the client to the server](#connect-the-client-to-the-server)
- [Sources](#sources)


# Prerequisites
Obviously, the Wireguard software is required to follow this tutorial. On a debian based machine, it's as simple as running :
```bash
sudo apt update  
sudo apt install wireguard
```


# Where to find the files
All the config files for wireguard can be found in `/etc/wireguard/`. Root access is required to write in this folder. We will be creating a `wg0.conf` file. You can change `wg0` to whatever you want as it is only the name of the interface.


# Common steps
In order to get our server talking with our client, both of them will need a public and a private key. To get them generated, run this command on the server and the client :
```bash
wg genkey | tee privatekey | wg pubkey > publickey
```
Two files will now have been created : `privatekey` and `publickey`.

{{< notice warning >}}
No matter what, NEVER share your private key with anyone.
{{< /notice >}}


# Server-side configuration
If you have not done so already, this is the time to create the config file. Do do so, run :
```bash
sudo touch /etc/wireguard/wg0.conf
```

Insert these contents in the file :
```bash
[Interface]
Address = <server-ip-address>/<subnet>
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o <interface> -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o <interface> -j MASQUERADE
ListenPort = 51820
PrivateKey = <server-private-key>  
```

Let's go over this config line by line
- `PrivateKey` is the private key of the server.
- `Address` is a list of IP(v4/v6) addresses that the interface can use.
- `ListenPort` sets the port the WireGuard server will listen on.
- `PostUp` and `PostDown` are commands that will be ran just after the interface is brought up or down.

How to fill the placeholders ?
- `<server-private-key> ` : the private key you just generated.
- `<server-ip-address>` : virtual address of the local WireGuard peer. A safe default is `10.0.0.1`.
- `<subnet>` : virtual subnet, goes in pair with the `<server-ip-address>`. A safe default is `/24`.
- `<interface>` : the name of the network interface your VPN will listen on.

[Optional] Configure wireguard to start when the server boots up :
```bash
sudo systemctl enable wg-quick@wg0
```


# Client-side configuration
Just as before, if you have not done so already, you need to create the config file :
```bash
sudo touch /etc/wireguard/wg0.conf
```

Now, open the config file you just created with your editor of choice. We'll be using nano :
```bash
sudo nano /etc/wireguard/wg0.conf
```

Paste these lines into it :
```bash
[Interface]
Address = <client-ip-address>/<subnet>
PrivateKey = <client-private-key>

[Peer]
PublicKey = <server-public-key>
Endpoint = <server-public-ip-address>:51820
AllowedIPs = 0.0.0.0/0, ::/0

# This is for if you're behind a NAT and
# want the connection to be kept alive.
PersistentKeepalive = 25
```

You should already be familiar with the first lines as they are exactly the same as with the server config. The only difference being that the `Address` CANNOT be the same as the server. You can use `10.0.0.3/24` for example.

However, the three lines under `[Peer]` are new, let's go over them :
- `PublicKey`, here you need to paste the server's public key that you generated earlier.
- `Endpoint`, this is where you set the PUBLIC IP address that the server is behind.
- `AllowedIPs`, here you can set the range of IP addresses to be forwarded to the server. By using `0.0.0.0/0` you're forwarding the entirety of the traffic.

Now that everything is configured, you can bring the VPN's interface up. Assuming you've called it `wg0` run this command :
```bash
wg-quick up wg0
```

{{< notice note >}}
This command might require sudo privileges.
{{< /notice >}}

Your client is now ready to be added to the server. You can check the status of the connection by running :
```bash
wg
```

# Connect the client to the server
You can now bring the server's interface up :
```bash
wg-quick up wg0
```

Add the client to the server using :
```bash
wg set wg0 peer <client-public-key> allowed-ips <client-ip-address>/32
```

{{< notice note >}}
This command might require sudo privileges.
{{< /notice >}}

You can check if the connection is established correctly by running :
```bash
wg
```

If everything is in order, save the server's configuration using :
```bash
wg-quick save wg0
```

Congratulations, you've just set up your own Virtual Private Network. This is a very basic implementation, I encourage you to read the documentation to find out what can be done using this piece of software.


# Sources
Here are the sources I used to write this article and troubleshoot my own installation :
- [PRO CUSTODIBUS - WIREGUARD ENDPOINTS AND IP ADDRESSES](https://www.procustodibus.com/blog/2021/01/wireguard-endpoints-and-ip-addresses/)
- [WireGuard man page](https://manpages.debian.org/unstable/wireguard-tools/wg-quick.8.en.html)
- [Some Unofficial WireGuard Documentation](https://github.com/pirate/wireguard-docs)
- [The Digital Life - WireGuard installation and configuration on Linux](https://www.the-digital-life.com/wireguard-installation-and-configuration/)
- [serverfault - Wireguard VPN can't access internet and LAN](https://serverfault.com/questions/1039643/wireguard-vpn-cant-access-internet-and-lan)
- [IVPN - Linux Autostart WireGuard in systemd](https://www.ivpn.net/knowledgebase/linux/linux-autostart-wireguard-in-systemd/)
- [Stupid simple setting up WireGuard - Server and multiple peers](https://gist.github.com/chrisswanda/88ade75fc463dcf964c6411d1e9b20f4)