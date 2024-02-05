# Send All Metrics To Prometheus

use : ` send_cass_metrics_to_prom.sh `
for :
- Apache Cassandra 4.1.3 or below versions
- DataStax Enterprise 6.8.x or below versions

---

use : ` send_cass_metrics_to_prom_2024.sh `
for :
- Apache Cassandra 5.0 or above versions
- NOT TESTED for DataStax Enterprise

---

# Send All Metrics To Prometheus

```
send_cass_metrics_to_prom.sh
or
send_cass_metrics_to_prom_2024.sh
```
Download this shell script and place it in ` ~/node_exporter-current/ ` folder. <br><br><br>

Change permissions for shell script :
```
chmod u+rwx ~/node_exporter-current/send_cass_metrics_to_prom.sh
or
chmod u+rwx ~/node_exporter-current/send_cass_metrics_to_prom_2024.sh
```

<br><br>
Add entry to crontab ... to start publishing all metrics to Prometheus.
```
$ crontab -e

##### add following line
*/5 * * * *  sh ~/node_exporter-current/send_cass_metrics_to_prom.sh
```
or
```
$ crontab -e

##### add following line
*/2 * * * *  sh ~/node_exporter-current/send_cass_metrics_to_prom_2024.sh
```

<br><br><br>

### This configuration is required on each of our Cassandra nodes.

<br>

