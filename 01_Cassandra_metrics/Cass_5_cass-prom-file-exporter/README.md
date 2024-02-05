## This method only works if you are using :
- Apache Cassandra 5.0 or above versions
- requires Java 11 or above
- NOT TESTED for DataStax Enterprise

<br>

# Cassandra-Prometheus-File-Exporter

We will download & configure a highly efficient and tiny agent written in Java.

First identify your Java version and download the correct version of compiled jar from :
https://github.com/sarma1807/cass-prom-file-exporter/tree/main/build/libs/

for Java 11 : ` CassPromFileExporter-j11-all.jar `

for Java 17 : ` CassPromFileExporter-j17-all.jar `

### create folder on all nodes of Cassandra cluster and download jar file

```
mkdir ~/myLibs/
cd    ~/myLibs/
wget https://github.com/sarma1807/cass-prom-file-exporter/tree/main/build/libs/CassPromFileExporter-j11-all.jar
wget https://github.com/sarma1807/cass-prom-file-exporter/tree/main/build/libs/CassPromFileExporter-j17-all.jar
```


## configure the jar file in ~/conf/cassandra-env.sh

for Java 11 :
```
echo 'JVM_OPTS="$JVM_OPTS -javaagent:~/myLibs/CassPromFileExporter-j11-all.jar"' >> ~/conf/cassandra-env.sh
```

for Java 17 :
```
echo 'JVM_OPTS="$JVM_OPTS -javaagent:~/myLibs/CassPromFileExporter-j11-all.jar"' >> ~/conf/cassandra-env.sh
```

## verify
```
cat ~/conf/cassandra-env.sh | grep javaagent
```

expected output :
```
$ cat ~/conf/cassandra-env.sh | grep javaagent
# add the jamm javaagent
JVM_OPTS="$JVM_OPTS -javaagent:$CASSANDRA_HOME/lib/jamm-0.4.0.jar"
JVM_OPTS="$JVM_OPTS -javaagent:~/myLibs/CassPromFileExporter-j11-all.jar"
$
```

<br>

### This configuration change is required on each of our Cassandra nodes.

<br>

### These changes will become active after the Cassandra restart.

