![CassPromGraf_00_Arch.jpg](https://github.com/sarma1807/Prometheus-Grafana-Cassandra/blob/main/Screenshots/JPGs/CassPromGraf_00_Arch.jpg) <br><br>

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
Completed and code has been published during November 2021.
<br><br><br>

---

### Latest Verification

```
# 16-October-2022
# this is working properly with following software versions :

Linux OS : CentOS Stream release 9 (5.14.0-171.el9.x86_64)
Apache Cassandra Release Version 4.1-beta1
Prometheus node_exporter version 1.4.0
Prometheus version 2.39.1
Prometheus AlertManager version 0.24.0
Grafana version 9.2.0

```

---

### New Requirements
```
currently using "sendmail"
in future can we support "mailx" too ?
```

