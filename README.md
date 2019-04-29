## Introduction
Using Ansible Configure HAproxy with Two Nginx Backends

## Specs

Using `Ansible` configure `HAProxy` and `Nginx` Servers with a behavior illustrated below

1. There are three Cent OS 6 VMs viz. 
   ```
   - HAproxy/Test1 (192.168.30.1)
   - Nginx/Test2 (192.168.30.2)
   - Nginx/Test3 (192.168.30.3)
   ```
2. `HAProxy` is installed and listens on port `80`
3. `HAProxy` backend comprises of two `Nginx` server and that, are load balanced
4. `Nginx` is installed and listens on port `8000`
5. `Nginx` Location directive rules are as follows
    -  ```/probe\_local``` should show the contents of ```/var/www/local.html```
    - ```/probe\_applicant``` should return your availability for being 24/7 on-call 
    - ```/\*``` forwarded to [google](http://www.google.com)
    - ```/probe\_remote``` orwarded to ```localhost:5500```
6. Key configurations like those of Kernel, CPU, Selinux etc. must be taken into an account



## Setup
I've used Vagrant to create VMs on MacBook pro machine. Since, the installation and vagrant overview is out of scope of this document. So, I'll focus strictly on, on How did I use Vagrant. However, click on [Getting Started with Vagrant](https://www.vagrantup.com/intro/index.html) to know more on vagrant.

The Controller (Ansible) machine is provisioned using following

1. ansible-bootstrap.sh which installs the epel repo and ansible on the controller.
2. Common-bootstrap.sh which sets PasswordAuthentication to yes in /etc/ssh/sshd\_config file and restarts sshd services

**Note:** `Common-bootstrap.sh` runs on all machine

Copy Playbooks from my local machine to controller. Then, the other machines which are
```
- Test1 (192.168.30.1)
- Test2 (192.168.30.2)
- Test3 (192.168.30.3)
``` 
created and are provisioned using `common-bootstrap.sh`. Login on each machine is done by `vagrant ssh` and set a passwordless SSH access from Controller (Ansible) to rest of the Machines. By doing simple steps
```
  1. ssh-keygen # – generate SSH KEY
  2. ssh-keygen -R 192.168.30.x /~vagrant/.ssh/known_hosts  # - Add to known hosts (x = 1, 2, 3 respectively)
  3. Did the same as above for hostnames viz Test1, Test2 and Test3 respectively
  4. ssh-copy-id # for above hosts/ips to update authorized\_keys
     -- user vagrant, password vagrant
```
