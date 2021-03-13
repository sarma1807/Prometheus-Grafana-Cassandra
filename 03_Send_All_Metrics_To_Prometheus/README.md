# Send All Metrics To Prometheus

```
send_cass_metrics_to_prom.sh
```
Download this shell script and place it in ` ~/node_exporter-1.1.2.linux-amd64/ ` folder. <br><br><br>

Change permissions for shell script :
```
chmod u+rwx ~/node_exporter-1.1.2.linux-amd64/send_cass_metrics_to_prom.sh
```

<br><br>
Add entry to crontab ... to start publishing all metrics to Prometheus.
```
$ crontab -e

##### add following line
*/5 * * * *  sh ~/node_exporter-1.1.2.linux-amd64/send_cass_metrics_to_prom.sh
```

<br><br><br>

### This configuration is required on each of our Cassandra nodes.

<br>
