# Prometheus alertmanager

We will configure ` alertmanager ` to publish alerts when down services are identified. <br>

#### go to https://prometheus.io/download/

Download ` alertmanager ` from this webpage. <br><br><br>

At the time of writing this, ` alertmanager version 0.23.0 ` was available. <br>
```
cd ~
tar -xzvf ~/software/alertmanager-0.23.0.linux-amd64.tar.gz
ln -s ~/alertmanager-0.23.0.linux-amd64 ~/alertmanager-current
```

` alertmanager ` was extracted to ` ~/alertmanager-0.23.0.linux-amd64 `
<br><br><br>

```
# check alertmanager version :

$ ~/alertmanager-0.23.0.linux-amd64/alertmanager --version

alertmanager, version 0.23.0 (branch: HEAD, revision: 61046b17771a57cfd4c4a51be370ab930a4d7d54)
  build user:       root@e21a959be8d2
  build date:       20210825-10:48:55
  go version:       go1.16.7
  platform:         linux/amd64

$

```

<br><br><br>

### Configure alertmanager

```
# we will not use the original alertmanager.yml file
mv ~/alertmanager-current/alertmanager.yml ~/alertmanager-current/alertmanager.yml_original

vi ~/alertmanager-current/alertmanager.yml

# YAML files are sensitive about spaces/tabs - extra spaces/tabs can result in errors
# add following entries to this file

### global: global configuration parameters applies to alertmanager at global level
global:
  smtp_smarthost: 'mysmtp.OracleByExample.com:25'
  smtp_hello: 'promgraf.OracleByExample.com'
  smtp_from: 'prom.alertmgr@promgraf.OracleByExample.com'
  smtp_require_tls: false

route:
  receiver: 'email_to_dbateam'

receivers:
- name: 'email_to_dbateam'
  email_configs:
  - to: alerts@mysmtp.OracleByExample.com
    send_resolved: true

### end of file
```

<br><br>

Add entry to crontab ... to automatically start ` alertmanager ` along with server start :

```
$ crontab -e

##### add following line
@reboot	cd ~/alertmanager-current ; ./alertmanager &
```

<br><br><br>

After server restart ` Prometheus alertmanager ` webpage can be accessed at :

```
http://<SERVER_IP_OR_HOSTNAME>:9093/#/status
```

<br><br>

### This configuration is required on only one server which will run Prometheus alertmanager.
### You can choose to run Prometheus and alertmanager on the same server.

<br><br>

### Inform Prometheus Server About Alertmanager

```
vi ~/prometheus-current/prometheus.yml

# add following entries to this file
# make sure to remove the duplicate entries

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - '<IP_ADDRESS_OF_ALERTMANAGER>:9093'

rule_files:
  - "alert.rules.yml"
```

### Create Prometheus Alert Rules Configuration File

```
vi ~/prometheus-current/alert.rules.yml

# add following entries to this file

groups:
- name: alert_group
  rules:
  - alert: Cassandra_Down
    expr: oramad_cass_up == 0
    for: 1m
    # adding custom labels to alerts is possible in following way
    labels:
      severity: "critical"
    annotations:
      summary: "Cassandra on {{ $labels.hostname_short }} in {{ $labels.cass_cluster_name }} is down"
      description: "Cassandra on {{ $labels.hostname_short }} in {{ $labels.cass_cluster_name }} is down"

```

### This will require a restart of Prometheus

<hr>

use ` alertmanager.yml ` - if you are sending email notifications to a single team
<br>
use ` alertmanager.yml-MultipleTeams ` - if you are sending email notifications to multiple teams

