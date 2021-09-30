+++
author = "Lucas DRAESCHER"
title = "How to set up a WireGuard VPN"
date = "2021-09-30"
tags = [
  "Wireguard",
  "VPN"
]
+++

### Introduction
In this article, I'll be writing about how I set up a Wireguard VPN on my home server in order to gain access to my home network remotely. I'll start off with the client side configuration and then we will have a look at the server side.

### Prerequisites
Obviously, the Wireguard software is required to follow this tutorial. On a debian based machine, it's as simple as running 
{{< notice example >}}
sudo apt update  
sudo apt install wireguard
{{< /notice >}}

### Where to find the files
All the config files for wireguard can be found in `/etc/wireguard/`. Root access is required to write in this folder. We will be creating a `wg0.conf` file. You can change `wg0` to whatever you want as it will be the name our VPN network interface will have.

### Common steps
In order to get our server talking with our client, both of them will need a public and a private key. To get them generated, run this command on the server and the client :
{{< notice example >}}
wg genkey | tee privatekey | wg pubkey > publickey
{{< /notice >}}
Two files will now have been created : `privatekey` and `publickey`. __No matter what, NEVER share your private key with anyone__.

### Client side configuration
If you have not done so already, this is the time to create our config file. Do do so, run 
{{< notice example >}}
sudo touch /etc/wireguard/wg0.conf
{{< /notice >}}

Before we start, we are going to need to know a few things. The first one being what subnet our machine is on. To do so, run `ip -c a` and look for your network interface (if wired, usually `eth0`, if on WiFi, usually `wlan0`). 

Now, open it with your editor of choice. We'll be using nano :
{{< notice example >}}
sudo nano /etc/wireguard/wg0.conf
{{< /notice >}}

Populate the file with these contents :
{{< notice example >}}
[Interface]
{{< /notice >}}