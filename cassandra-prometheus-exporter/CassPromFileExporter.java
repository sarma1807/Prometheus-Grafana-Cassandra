//////////////////////////////////////////////////
// original code written by Jon Haddad aka rustyrazorblade
// https://github.com/rustyrazorblade/cassandra-prometheus-exporter
//
// CassPromFileExporter.java
// Cassandra Dropwizard Metrics to Prometheus as Flat File
// code version : v01_20240127 : Sarma Pydipally
//////////////////////////////////////////////////

package com.oramad;

import org.apache.cassandra.metrics.CassandraMetricsRegistry;
import java.lang.instrument.Instrumentation;
import io.prometheus.client.CollectorRegistry;
import io.prometheus.client.dropwizard.DropwizardExports;
import io.prometheus.client.exporter.common.TextFormat;
import java.io.FileWriter;
import java.io.Writer;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;


public class CassPromFileExporter {

  private static String vMetricsFileName = "/tmp/oramad_cass_prom_metrics_0.txt";
  private static int vWriteToFileInterval = 5;

  public static void premain(String agentArgs, Instrumentation inst) {
    Thread thread = new Thread(() -> {
      do {
        try {
          Thread.sleep(5000);
        } catch (Exception e) {
          // do nothing
        }
      } while (CassandraMetricsRegistry.Metrics == null);
      System.out.println("INFO  [oramad] CassPromFileExporter : cassandra metrics agent is now ready ...");

      CollectorRegistry.defaultRegistry.register(new DropwizardExports(CassandraMetricsRegistry.Metrics));

      int vInitialDelay = 1;
      int vInterval = vWriteToFileInterval;
      ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();
      scheduler.scheduleAtFixedRate(() -> writeMetricsToFile(), vInitialDelay, vInterval, TimeUnit.MINUTES);
    });
    thread.setName("OramadCassPromFileExporter");
    thread.start();
  }

  private static void writeMetricsToFile() {
    try (Writer writer = new FileWriter(vMetricsFileName)) {
      TextFormat.write004(writer, CollectorRegistry.defaultRegistry.metricFamilySamples());
      writer.close();
    } catch (Exception e) {
      // do nothing
    }
  }
}
