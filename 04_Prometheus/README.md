# Prometheus

` ASSUMPTION : ~ = /apps/opt/promgraf `

We will install and configure ` Prometheus ` only on one server.

#### go to https://prometheus.io/download/

Download ` Prometheus ` from this webpage. <br><br><br>

At the time of writing this, ` Prometheus version 2.25.1 ` was available. <br>

```
cd ~
tar -xzvf ~/software/prometheus-2.25.1.linux-amd64.tar.gz
ln -s ~/prometheus-2.25.1.linux-amd64 ~/prometheus-current
```

` Prometheus ` was extracted to ` ~/prometheus-2.25.1.linux-amd64 `

<br><br><br>

### Configure Prometheus

```
$ vi ~/prometheus-current/prometheus.yml
```
add following lines at the end of file
```
# YAML files are sensitive about spaces/tabs - extra spaces/tabs can result in errors
# add following entries at the end of file
  # my cassandra nodes - provide IPs for all nodes
  - job_name: 'oramad_cassandra_metrics'
    scrape_interval: 180s
    static_configs:
    # - targets: ['<SERVER1_IP_OR_HOSTNAME>:9100', '<SERVER2_IP_OR_HOSTNAME>:9100', '<SERVER3_IP_OR_HOSTNAME>:9100', ...]
    - targets: ['192.168.1.151:9100', '192.168.1.152:9100', '192.168.1.153:9100']
# add your Cassandra servers to this targets list
```

<br><br>

Add entry to crontab ... to automatically start ` Prometheus ` along with server start :

```
$ crontab -e

##### add following line
@reboot	cd ~/prometheus-current;~/prometheus-current/prometheus --config.file='/apps/opt/promgraf/prometheus-current/prometheus.yml' &
```

<br><br><br>

After server restart ` Prometheus ` webpage can be accessed at :

```
http://<SERVER_IP_OR_HOSTNAME>:9090/
```

<br>

Webpage for status of ` Prometheus Targets ` can be accessed at :

```
http://<SERVER_IP_OR_HOSTNAME>:9090/targets
```

<br><br>

### This configuration is required on only one server which will run Prometheus server.

<br>

