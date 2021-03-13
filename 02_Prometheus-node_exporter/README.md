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

<br><br><br>

```
node_exporter_runtime.sh
```
Download this shell script and place it in ` ~/node_exporter-1.1.2.linux-amd64/ ` folder. <br><br><br>

Change permissions for shell script :
```
chmod u+rwx ~/node_exporter-1.1.2.linux-amd64/node_exporter_runtime.sh
```

##### Note that this shell script contains an entry for starting ` node_exporter ` on ` port 9100 `


<br><br>
Add entry to crontab ... to automatically start ` node_exporter ` along with server start :
```
$ crontab -e

##### add following line
@reboot	sh ~/node_exporter-1.1.2.linux-amd64/node_exporter_runtime.sh
```

<br><br><br>
After server restart ` node_exporter ` webpage can be accessed at :
```
http://<SERVER_IP_OR_HOSTNAME>:9100/metrics
```

<br>

### This configuration is required on each of our Cassandra nodes.

<br>
