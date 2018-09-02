# Ansible-HAProxy-Nginx-Nginx
Using Ansible Configure HAproxy with Two Nginx Backends

**SPECIFICATIONS:**

Using Ansible configure HAProxy and Nginx Servers with a behavior illustrated below

1. There are three Cent OS 6 VMs viz. HAproxy/Test1 (192.168.30.1), Nginx/Test2 (192.168.30.2) and Nginx/Test3 (192.168.30.3)
2. HAProxy is installed and listens on port 80
3. HAProxy backend comprises of two Nginx server and that, are load balanced
4. Nginx is installed and listens on port 8000
5. Nginx Location directive rules are as follows
  1. /probe\_local should show the contents of /var/www/local.html
  2. /probe\_applicant&quot; should return your availability for being 24/7 on-call 
  3. /\* forwarded to [http://www.google.com](http://www.google.com)
  4. /probe\_remote orwarded to localhost:5500
6. Key configurations like those of Kernel, CPU, Selinux etc. must be taken into an account



## SETUP VM ##

      I've used Vagrant to create VMs on MacBook pro machine. Since, the installation and vagrant overview is out of scope of this document. So, I'll focus strictly on, on How did I use Vagrant. However, click on [Getting Started with Vagrant](https://www.vagrantup.com/intro/index.html) to know more on vagrant.

The Controller (Ansible) machine is provisioned using following

1. ansible-bootstrap.sh which installs the epel repo and ansible on the controller.
2. Common-bootstrap.sh which sets PasswordAuthentication to yes in /etc/ssh/sshd\_config file and restarts sshd services

**Note:** Common-bootstrap.sh runs on all machine

1. Copy Playbooks from my local machine to controller

      Then, the other machines which are Test1 (192.168.30.1), Test2 (192.168.30.2) and Test3 (192.168.30.3) are then created which are provision with common-bootstrap.sh.

      Login on each machine is done by vagrant ssh &quot;Machine\_Name&quot; and then, set a passwordless SSH access from Controller (Ansible) to rest of the Machines. By doing simple steps

1.
  1. ssh-keygen – To generate SSH KEY
  2. ssh-keygen -R 192.168.30.x \&gt;\&gt; ~vagrant/.ssh/known\_hosts  - Add to known hosts (x = 1, 2, 3 respectively)
  3. Did the same as above for hostnames viz Test1, Test2 and Test3 respectively
  4. ssh-copy-id for above hosts/ips to update authorized\_keys
    1. user vagrant, password vagrant


## ANSIBLE – ENVIRONMENT SETUP

**cd ~vagrant/Production**

[vagrant@controller Production]$ ansible -i hosts all -m ping

Test1 | SUCCESS; {

    changed: true,

    ping: pong;

}

Test2 | SUCCESS; {

    changed: true,

    ping: pong;

}

Test3 | SUCCESS; {

    changed: true,

    ping: pong;

}

controller | SUCCESS; {

    changed: true,

    ping: pong;

}

Following is the Playbook structure. We have Three roles viz. common, webservers and loadbalancer which is equivalent to common (as that stays common to all both webservers and loadbalancer), Nginx and Haproxy respectively.



`-- Production

    |-- hosts

    |-- roles

    |   |-- common

    |   |   |-- handlers

    |   |   |   `-- main.yaml

    |   |   |-- tasks

    |   |   |   |-- install\_packages.yaml

    |   |   |   |-- iptables.yaml

    |   |   |   |-- main.yaml

    |   |   |   |-- selinux.yaml

    |   |   |   `-- setup\_etc\_hosts.yaml

    |   |   `-- templates

    |   |       `-- iptables.j2

    |   |-- loadbalancer

    |   |   |-- defaults

    |   |   |   `-- main.yaml

    |   |   |-- handlers

    |   |   |   `-- main.yaml

    |   |   |-- tasks

    |   |   |   |-- configure\_rsyslog.yaml

    |   |   |   |-- haproxy\_cfg.yaml

    |   |   |   |-- haproxy\_sysctl.yaml

    |   |   |   |-- install\_haproxy.yaml

    |   |   |   `-- main.yaml

    |   |   `-- templates

    |   |       |-- haproxy.cfg.j2

    |   |       |-- haproxy.conf.j2

    |   |       `-- rsyslog.conf.j2

    |   `-- webservers

    |       |-- defaults

    |       |   `-- main.yaml

    |       |-- files

    |       |   `-- simple-nodejs-ws.js

    |       |-- handlers

    |       |   `-- main.yaml

    |       |-- tasks

    |       |   |-- install\_nginx.yaml

    |       |   |-- main.yaml

    |       |   |-- nginx\_config.yaml

    |       |   |-- nginx\_sysctl.yaml

    |       |   |-- selinux\_nginx.yaml

    |       |   `-- set-up-a-simple-nodejs-ws-listen5500.yaml

    |       `-- templates

    |           |-- default.conf.j2

    |           |-- local.html.j2

    |           |-- nginx.conf.j2

    |           `-- on-call-schedule.html.j2

    |-- site.yaml



## NGINX CONFIGURATIONS

**Following is the nginx.conf.**

#{{ ansible\_managed }}

user  {{ ngx\_user }};

worker\_processes &quot;{{ ansible\_processor\_vcpus|default(ansible\_processor\_count) }}&quot;;

# The optimal value depends on many factors including (but not limited to) the number of CPU cores,

# the number of hard disk drives that store data, and load pattern.

# grep processor /proc/cpuinfo | wc -l

# Maximum open file descriptors per process, this value must be higher than worker\_connections

worker\_rlimit\_nofile {{ ngx\_worker\_rlimit\_nofile | default(&#39;4096&#39;) }};

events {

        worker\_connections {{ ngx\_worker\_connections | default(&#39;1024&#39;) }};

        # ulimit -n

        # Determines how many clients will be served by each worker process.

        # Formula - Max clients = worker\_connections \* worker\_processes

        # (Above is without using reverse proxy, for reverse proxy divide the obtained value by 2)

}

error\_log  /var/log/nginx/error.log warn;

pid        /var/run/nginx.pid;

http {

    # Define Mime types

    include       /etc/nginx/mime.types;

    default\_type  application/octet-stream;

    # Define the Log Format

    log\_format  main  $remote\_addr - $remote\_user [$time\_local] $request&quot; &#39;

                      &#39;$status $body\_bytes\_sent &quot;$http\_referer&quot; &#39;

                      &#39;&quot;$http\_user\_agent&quot; &quot;$http\_x\_forwarded\_for&quot;&#39;;

    access\_log  /var/log/nginx/access.log  main;

    sendfile        on;

    # sendfile Nginx option enables to use of sendfile(2)

    # Sendfile(2) allows zero copy,

    # which means writing directly the kernel buffer from the block device memory through DMA.

    # sendfile is not recommended with reverse proxy

    tcp\_nodelay    on;

    # Nginx uses tcp\_nodelay on http keepalive connections

    # It&#39;s a way to bypass Nagle&#39;s theorem. So, tcp\_nodelay can save upto 0.2 seconds per http request.

    tcp\_nopush     on;

    # optimizes the amount of data sent at once.

    # Nginx tcp\_nopush activates the TCP\_CORK option in the Linux TCP stack

    # Refer - https://elixir.bootlin.com/linux/latest/source/net/ipv4/tcp.c#L2525

    keepalive\_timeout  65;

    types\_hash\_max\_size 2048;

    send\_timeout 60;

    add\_header    X-Content-Type-Options nosniff;

    add\_header    X-Frame-Options SAMEORIGIN;

    add\_header    X-XSS-Protection &quot;1; mode=block&quot;;

    server\_tokens       off;

    gzip             on;

    gzip\_comp\_level  2;

    gzip\_min\_length  1000;

    gzip\_proxied     expired no-cache no-store private auth;

    gzip\_types       text/plain;

    include /etc/nginx/conf.d/\*.conf;

}

**Following default configuration that, defines the rules to serve the requests**

#Ansible managed

server {

        listen 8000 default\_server;

        server\_name \_;

        root /var/www;

        location = /probe\_local {

          default\_type &quot;text/html&quot;;

          alias  /var/www/local.html;

        }

        location /probe\_applicant {

          default\_type &quot;text/html&quot;;

          alias /var/www/on-call-schedule.html;

        }

        location /probe\_remote {

          proxy\_set\_header X-Real-IP $remote\_addr;

          proxy\_set\_header X-Forwarded-For $proxy\_add\_x\_forwarded\_for;

          proxy\_set\_header Host $host;

          proxy\_set\_header X-NginX-Proxy true;

          proxy\_pass http://localhost:5500/;

        }

        location /\* {

          return 301 http://www.google.com;

        }

}



## HAPROXY CONFIGURATIONS

Following is haproxy.cfg

# {{ ansible\_managed }}

global

    log         127.0.0.1 local2 #Log configuration

    chroot      /var/lib/haproxy

    pidfile     /var/run/haproxy.pid

    maxconn     4000

    nbproc      {{ haproxy\_procs }}

{% for cpu\_idx in range(0,haproxy\_procs | int) %}

  cpu-map {{ cpu\_idx+1 }} {{ cpu\_idx }}

{% endfor %}

    stats       bind-process {{ haproxy\_procs }}

    user        {{ haproxy\_usr }}

    group       {{ haproxy\_usr }}

    daemon

    # turn on stats unix socket

    stats socket /var/lib/haproxy/stats level admin

defaults

    mode                    {{ mode }}

    log                     global

    option                  httplog

    option                  dontlognull

    option http-server-close

    option forwardfor       except 127.0.0.0/8

    option                  redispatch

    retries                 3

    timeout http-request    10s

    timeout queue           1m

    timeout connect         10s

    timeout client          1m

    timeout server          1m

    timeout http-keep-alive 10s

    timeout check           10s

    maxconn                 3000

frontend main

    bind \*:{{ listenport }}

    #option http-server-close

    mode {{ mode  }}

    default\_backend app

backend app

  balance {{ balance }}                                    # Balance   algorithm - ROUND ROBIN

  option httplog

  http-request set-header X-Forwarded-Port %[dst\_port]

  option tcp-check

  tcp-check connect

  tcp-check send GET\ /probe\_local\ HTTP/1.1\r\n

  tcp-check send Host:\ localhost\r\n

  tcp-check send \r\n

  tcp-check expect rstring (2..|3..)

  tcp-check connect

  tcp-check send GET\ /probe\_applicant\ HTTP/1.1\r\n

  tcp-check send Host:\ localhost\r\n

  tcp-check send \r\n

  tcp-check expect rstring (2..|3..)

  tcp-check connect

  tcp-check send GET\ /probe\_remote\ HTTP/1.1\r\n

  tcp-check send Host:\ localhost\r\n

  tcp-check send \r\n

  tcp-check expect rstring (2..|3..)

  tcp-check connect

  tcp-check send GET\ /\*\ HTTP/1.1\r\n

  tcp-check send Host:\ localhost\r\n

  tcp-check send \r\n

  tcp-check expect rstring (2..|3..)

{% for host in groups.webservers %}

  server {{ host }} {{ hostvars[host][&#39;ansible\_&#39;+interface].ipv4.address }}:{{ backend\_srv\_port }} check inter 5s fall 5 rise 3  #Check before Failover/Failback

{% endfor %}

HAPROXY Logging

Since, HAProxy does not write to disk so, have setup rsyslog to capture HAProxy logs. I didn&#39;t use HAProxy Monitoring.





## SIMPLE NODE JS SERVER – [http://localhost:5000](http://localhost:5000) (test1/TEst2)

Below is a simple Hello World Node JS code I&#39;ve use to test /probe\_remote rule.

var http = require(&#39;http&#39;);

//create a server object:

http.createServer(function (req, res) {

  res.write(&#39;Hello World!&#39;); //write a response to the client

  res.end(); //end the response

}).listen(5500);

## TESTING

**NOTE- test.sh needs to be run on Test1 (192.168.30.1)/HAProxy server.**
