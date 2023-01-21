# wg-pihole-docker
 How to setup a VPN and a DNS sinkhole on a Debian server, using Wireguard, Pi-hole and Docker.

 These instructions are meant for a Debian server and assume that you are using Linux or macOS. Take some time to read the documentation as well as the scripts before you run anything on your server.

## Creating a user

- SSH into the server using `ssh root@serverip` and run `apt-get update && apt-get upgrade`.
- Create a new user with `useradd -m username` and set a password for this user with `passwd username`.
- Add the newly created user to the `sudo` group with `adduser username sudo`.
- Use `su username` to connect as the user you have just created.
- By default Debian does not use `bash`, which means you won't have tab completion or syntax colouring. To remedy that, use `chsh -s /bin/bash` then log out and log back in with `exit` and then `su username`.
- In you home directory create a `.ssh` folder as well as a file named `authorized_keys` with `mkdir ~/.ssh && touch ~/.ssh/authorized_keys`.

## Configuring SSH

- On your computer, go into you `.ssh` folder with `cd ~/.ssh`. If the folder does not exist create it using `mkdir ~/.ssh`.
- Use `ssh-keygen -t rsa -b 4096` to generate an SSH key pair. It is recommended that you name the key so that you can keep track of them.
- You need to copy the public key that you have just created to your server. To do that use `scp yourkey.pub username@serverip:`. Do not forget the `:` at the end.
- To be able to connect to the server using your SSH key, you need to add it to the `authorized_keys` file using `cat yourkey.pub >> .ssh/authorized_keys`. You can then delete the public key from the server using `rm yourkey.pub`.
- Make a copy of the `sshd_config` with `sudo cp /etc/ssh/sshd_config /root/`.
- Edit the content of the SSH daemon configuration using `sudo nano /etc/ssh/sshd_config`.
- A configuration example can be found in wg-pihole-docker/example-sshd_config. You might want to change the default SSH port.
- Once you have made changes in the `sshd_config` file, restart the daemon using `sudo systemctl restart sshd`. If you have changed the SSH port, make sure to change the firewall rules accordingly before you log off.
- From now on, in order to log back into your server you will have to use the following command `ssh -2 -i ~/.ssh/yourkey username@serverip -p portnumber`.

## Configuring the firewall

- Install git with `sudo apt-get install git`
- Clone this repository with `git clone https://github.com/Oliems/wg-pihole-docker.git`
- Read, make changes if needed and then run the firewall script with `sudo bash firewall-config.sh`. Note that this script will erase all `iptables` rules and chains and replace them. If you run this script after the installation of Docker, you will need to run `service docker restart` in order to re-install the rules and chains Docker needs in order to run properly.
- By default, `iptables` rules are reset after a reboot. In order to restore them automatically you will need to install the package `iptables-persistent` with `sudo apt-get install iptables-persistent`. The installer will ask you if you want to save your current IPv4 and IPv6 rules, select `Yes` for both. If you were to make changes to the rules and want to save them again, use `sudo iptables-save > /etc/iptables/rules.v4` and/or or `sudo ip6tables-save > /etc/iptables/rules.v6`. You can also use `sudo netfilter-persistent save` to save both files at once and `sudo netfilter-persistent reload` to restore back to how they were last time you saved them.

## Installing Docker and Docker-compose

### Docker

The following instruction are taken from https://docs.docker.com/engine/install/debian/, go to this page for more details.

- Update the apt package index and install packages to allow apt to use a repository over HTTPS

```
sudo apt-get update && sudo apt-get install ca-certificates curl gnupg lsb-release
```

- Add Docker’s official GPG key:

```
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

- Use the following command to set up the stable repository:

```
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

- Update the apt package index, and install the latest version of Docker Engine and containerd:

```
sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io
```

At this point the Docker Engine should be up and running, you can check if docker.service is running with `systemctl --type=service`.

### Docker-compose

The following instruction are taken from https://docs.docker.com/compose/install/, go to this page for more details.

- Run this command to download the current stable release of Docker Compose:

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

- Apply executable permissions to the binary:

```
sudo chmod +x /usr/local/bin/docker-compose
```

- Test the installation:

```
docker-compose --version
```

## Deploying wg-easy and docker-pi-hole

Modify docker-compose.yml to add your server's static IP and your passwords for the Wireguard and the Pi-hole WebUIs. Then, from inside the `wg-pihole-docker` directory, run `sudo docker-compose up -d`. You should now be able to access the Pi-hole WebUI at `http://yourserverip/admin` or at `http://pi.hole/admin` and the Wireguard WebUI at `http://yourserverip:51821`.

## Upgrading

In order to upgrade, just stop and delete the container you want to upgrade using `sudo docker stop container_name` and `sudo docker rm container_name` then run `sudo docker-compose up -d`.

## Changing the adlist

By default, Pi-hole uses [Steven Black's hosts files](https://github.com/StevenBlack/hosts). To manage the adlists, on Pi-hole's admin page you can go to `Group Management > Adlists` then add or remove adlists as you see fit. Once you are done, go to `Tools > Update Gravity` and click on `Update` to apply the changes.

## Useful resources

- https://github.com/pi-hole/docker-pi-hole
- https://github.com/WeeJeWel/wg-easy
- https://docs.pi-hole.net
- https://docs.docker.com
