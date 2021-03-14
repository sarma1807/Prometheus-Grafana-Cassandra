# Prometheus

We will install and configure ` Prometheus ` only on one server.

```
https://prometheus.io/download/
```

Download ` Prometheus ` from this webpage. <br><br><br>

At the time of writing this, ` Prometheus version 2.25.1 ` was available. <br>
```
cd ~
tar -xzvf ~/software/prometheus-2.25.1.linux-amd64.tar.gz
ln -s ~/prometheus-2.25.1.linux-amd64 ~/prometheus-current
```

` Prometheus ` was extracted to ` ~/prometheus-2.25.1.linux-amd64 `

<br><br><br>

# configure Prometheus

```
$ vi ~/prometheus-current/prometheus.yml

# YAML files are sensitive about spaces/tabs - extra spaces/tabs can result in errors
# add following entries at the end of file
  # my cassandra nodes - node_exporter_metrics - provide IPs for all nodes
  - job_name: 'node_exporter_metrics'
    scrape_interval: 180s
    static_configs:
    # - targets: ['<SERVER1_IP_OR_HOSTNAME>:9100', '<SERVER2_IP_OR_HOSTNAME>:9100', '<SERVER3_IP_OR_HOSTNAME>:9100', ...]
    - targets: ['192.168.1.151:9100', '192.168.1.152:9100', '192.168.1.153:9100']
# add your Cassandra servers to this targets list
```
