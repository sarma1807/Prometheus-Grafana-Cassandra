# Prometheus & Grafana for Apache Cassandra

### Environment

##### Following servers are running with ` CentOS Linux release 7.8.2003 (Core) ` :
```
192.168.1.151      eternal1      eternal1.OracleByExample.com
192.168.1.152      eternal2      eternal2.OracleByExample.com
192.168.1.153      eternal3      eternal3.OracleByExample.com
192.168.1.191      PromGraf      PromGraf.OracleByExample.com
```
<br><br><br>

### Apache Cassandra
3 node Cassandra cluster ` cluster_name: 'id_cluster' ` version : ` Apache Cassandra 4.0-beta4 ` running on following servers :
```
192.168.1.151      eternal1      eternal1.OracleByExample.com
192.168.1.152      eternal2      eternal2.OracleByExample.com
192.168.1.153      eternal3      eternal3.OracleByExample.com
```
We will configure Cassandra's built in ` metrics-reporter ` to extract and publish metrics to Prometheus. <br>
We will also configure ` Prometheus node_exporter ` on each of our Cassandra nodes to extract and publish metrics to Prometheus.
<br><br><br>


### Prometheus & Grafana
We will configure and run ` Prometheus & Grafana ` on following server :
```
192.168.1.191      PromGraf      PromGraf.OracleByExample.com
```
` Prometheus ` will gather and organize all collected metrics into its internal time-series database. <br>
` Grafana ` will consume the metrics from Prometheus and display them in a nice dashboard. <br>
<br><br><br>


### Prometheus Alertmanager
In future, we should implement ` Alertmanager `.
<br><br><br>

