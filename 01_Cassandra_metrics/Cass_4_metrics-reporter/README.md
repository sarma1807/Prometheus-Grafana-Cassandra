## This method only works if you are using :
- Apache Cassandra 4.1.3 or below versions
- DataStax Enterprise 6.8.x or below versions

<br>

# Apache Cassandra's metrics-reporter

We will configure Cassandra's built in ` metrics-reporter ` to extract and publish Cassandra metrics to a local text file. <br>

```
metrics-reporter.yaml
```
Download this configuration file and place it in the same folder where we have our ` cassandra.yaml ` file. 
<br><br><br>


Add following 1 line code to ` cassandra-env.sh ` file (as a last line of the file). <br>
` cassandra-env.sh ` file is in the same folder where we have our ` cassandra.yaml ` file. <br>

```
JVM_OPTS="$JVM_OPTS -Dcassandra.metricsReporterConfigFile=metrics-reporter.yaml"
```

<br>

### This configuration change is required on each of our Cassandra nodes.

<br>

### These changes will become active after the Cassandra restart.

