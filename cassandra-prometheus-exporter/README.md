this code is in testing phase - not production ready

this code is based on https://github.com/rustyrazorblade/cassandra-prometheus-exporter

---

# config
$ tail -2 ~/conf/cassandra-env.sh
### add compiled fat-jar as agent into ` Apache Cassandra ReleaseVersion: 5.0-beta1 `
JVM_OPTS="$JVM_OPTS -javaagent:~/customLibs/cassPromFileExporter-j17-all.jar"
$

## restart Cassandra
#### during restart Cassandra will load the cassandra-prometheus-exporter agent and will start writing metrics at an interval of 5 minutes to file : /tmp/oramad_cass_prom_metrics_0.txt : currently it is taking less than 2 seconds to write about 19000+ metrics to file

---

### crontab entry
*/2 * * * * sh ~/send_cass_metrics_to_prom_2024.sh
### this shell script will prepare and publish metrics to prometheus using node-exporter : currently this shell script is taking less than 10 seconds to execute

---

![CassPromGraf_24_Arch.jpg](https://github.com/sarma1807/Prometheus-Grafana-Cassandra/blob/main/cassandra-prometheus-exporter/CassPromGraf_24_Arch.jpg)
