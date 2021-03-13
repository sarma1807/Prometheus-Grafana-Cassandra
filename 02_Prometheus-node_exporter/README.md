# Prometheus node_exporter

We will configure ` node_exporter ` to extract and publish operating system metrics to a local text file. <br>

```
https://prometheus.io/download/
```

Download ` node_exporter ` from this webpage. <br><br><br>

At the time of writing this, ` node_exporter version 1.1.2 ` was available. <br>
```
cd ~
tar -xzvf ~/software/node_exporter-1.1.2.linux-amd64.tar.gz
```

` node_exporter ` was extracted to ` ~/node_exporter-1.1.2.linux-amd64 `
<br><br><br>

```
# check node_exporter version :

$ ~/node_exporter-1.1.2.linux-amd64/node_exporter --version

node_exporter, version 1.1.2 (branch: HEAD, revision: b597c1244d7bef49e6f3359c87a56dd7707f6719)
  build user:       root@f07de8ca602a
  build date:       20210305-09:29:10
  go version:       go1.15.8
  platform:         linux/amd64

$
```

<br>

### This configuration is required on each of our Cassandra nodes.

<br>
