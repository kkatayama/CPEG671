# Kali-VM Setup & PenTest Lab On-boarding

After installing your Kali VM, this guide will get you connected to our Pentest Lab.



**1. Run the following command to update and upgrade your Kali packages**

```bash
sudo apt update && sudo apt full-upgrade -y
```

**2. Enable `ssh` so we can easily transfer files from your machine to kali VM**

```bash
sudo systemctl enable --now ssh
```

**3. Verify `ssh` is `enabled` and `active`**

```bash
systemctl status ssh
```

You should see something like the following output:
![](/Users/katayama/Library/Application%20Support/marktext/images/2026-10-26-19-02-21-image.png)



**4. Locate the IP address of your Kali VM**

```bash
ip a
```

Look for the device `eth0` and the `inet` reference:

![](/Users/katayama/Library/Application%20Support/marktext/images/2026-10-26-19-17-07-image.png)

> My IP address is `172.16.163.128`



**5. `ssh` into your Kali VM with `user@ip-address` from a terminal on your local machine**

```bash
ssh teddy@172.16.163.128
```

Run `pwd` to "print working directory" of your "home"

```bash
pwd
```

My home directory is `/home/teddy`

Then run `exit` to return to your local machine.

```bash
exit
```

![](/Users/katayama/Library/Application%20Support/marktext/images/2026-10-26-19-20-02-image.png)

**6. Now transfer the OVPN config file you received via email using `scp` command**

> I downloaded mine to `/Users/katayama/Downloads/instructor-teddy-2.ovpn`

```bash
scp /Users/katayama/Downloads/instructor-teddy-2.ovpn teddy@172.16.163.128:/home/teddy/.
```

![](/Users/katayama/Library/Application%20Support/marktext/images/2026-10-26-19-25-28-image.png)

> With the transfer completed, we can return to our Kali VM and configure it for persistent Open VPN access to our Pentest Lab



**8. In a terminal on your Kali VM, verify the ovpn file successfully transferred with `ls` command:**

```bash
ls -lh
```

![](/Users/katayama/Library/Application%20Support/marktext/images/2026-10-26-19-59-53-image.png)



**9. Move your `ovpn` file to `/etc/openvpn/openvpn.conf`**

```bash
sudo mv instructor-teddy-2.ovpn /etc/openvpn/openvpn.conf
```



**10. Confirm the `ovpn` has been moved:**

```bash
ls -lh /etc/openvpn
```

```bash
$ ls -lh /etc/openvpn
total 16K
drwxr-xr-x 2 root  root  4.0K Jul  1 15:46 client
-rw------- 1 teddy teddy 2.6K Oct 26 19:24 openvpn.conf
drwxr-xr-x 2 root  root  4.0K Jul  1 15:46 server
-rwxr-xr-x 1 root  root  1.5K Jul  1 15:46 update-resolv-conf
```



**11. Enable and start the OpenVPN service**

```bash
sudo systemctl enable --now openvpn
```



**12. Check the OpenVPN service is `active` and `running`**

```bash
systemctl status --no-pager openvpn@openvpn.service
```

![](/Users/katayama/Library/Application%20Support/marktext/images/2026-10-26-20-22-55-image.png)



**13. Now run the `ip a` command, you should see a new tunnel device `tun0` has been added**

```bash
ip a
```

```py
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:61:28:85 brd ff:ff:ff:ff:ff:ff
    inet 172.16.163.128/24 brd 172.16.163.255 scope global dynamic noprefixroute eth0
       valid_lft 996sec preferred_lft 996sec
    inet6 fe80::20c:29ff:fe61:2885/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
5: tun0: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/none 
    inet 10.8.0.21/24 brd 10.8.0.255 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::9303:3c80:5401:f562/64 scope link stable-privacy proto kernel_ll 
       valid_lft forever preferred_lft forever

```

> Take note of your `tun0` IP address and submit it to canvas, mine is `10.8.0.21` 



## My Personal Kali Enhancements

These next steps are configuration modifications I typically do to improve efficiency.

> Often referred to as DOT-FILES

**1. Open your `~/.zshrc` ZSH profile in a text editor, here we will use `nano` in a terminal**  

```bash
nano ~/.zshrc
```



**2. Update History Size Limits**

Scroll down to the `# History configuration` section 

```editorconfig
# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
```

add a `0` to `HISTSIZE` and `SAVEHIST` to increase the values by magnitude of `10`.

> These defaults were set in the late 2000's when many machines were under powered with limited memory



it should now look like this:

```editorconfig
# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=20000
```



**3. Enable History with TimeStamps**

comment out the `alias history` line:

```editorconfig
# force zsh to show the complete history
alias history="history 0"
```

should now look like:

```editorconfig
# force zsh to show the complete history
#alias history="history 0"
```

underneath that line, add the following:

```editorconfig
# Force extended history timestamp logging
setopt EXTENDED_HISTORY

# Define the Kali/Zsh history time format
export HISTTIMEFORMAT="%F %T "

alias history="fc -il 0"
```



**4. Enable ZSH Scrollable History**

add these lines to the end of the file:

```editorconfig

# Enable beginning-of-line history search
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Bind Up and Down arrow keys safely via terminfo mapping
[[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
[[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" down-line-or-beginning-search

```



**5. Save your changes and reload your config!**

press `CTRL+X` to initiate exit of `nano` editor

![](/Users/katayama/Library/Application%20Support/marktext/images/2026-10-27-10-06-51-image.png)

press `Y` to save buffer

![](/Users/katayama/Library/Application%20Support/marktext/images/2026-10-27-10-07-32-image.png)

finally, press `Enter` to save

then reload your config:

```bash
source ~/.zshrc
```
