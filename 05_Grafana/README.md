# Grafana

https://grafana.com/grafana/dashboards/14070

---

` ASSUMPTION : ~ = /apps/opt/promgraf `

We will install and configure ` Grafana ` only on one server.

#### go to https://grafana.com/grafana/download

Download ` Grafana ` from this webpage. <br><br><br>

At the time of writing this, ` Grafana version 7.4.3 ` was available. <br>

```
cd ~
tar -xzvf ~/software/grafana-7.4.3.linux-amd64.tar.gz
ln -s ~/grafana-7.4.3 ~/grafana-current
mkdir ~/grafana-current/logs
```

` Grafana ` was extracted to ` ~/grafana-7.4.3 `

---

### Grafana Configuration File

```
# ~/grafana-current/conf/defaults.ini

# default Grafana port is configured in this file :
$ egrep "^http_port" ~/grafana-current/conf/defaults.ini
http_port = 3000
```

---

Add entry to crontab ... to automatically start ` Grafana ` along with server start :

```
$ crontab -e
```

##### add following line and adjust the file paths according to your environment

```
@reboot	~/grafana-current/bin/grafana-server -homepath ~/grafana-current -pidfile ~/grafana-current/logs/grafana-server.pid &
```

<br>

### This configuration is required on only one server which will run Grafana server.

<br><br><br>

After server restart ` Grafana ` webpage can be accessed at :

```
http://<GRAFANA_IP_OR_HOSTNAME>:3000/


Default Username / Password :
Username : admin
Password : admin
```

<br><br><br>

After logging into ` Grafana `, we can create our ` Prometheus ` as data source :

```
# in OLDER versions of Grafana - out-of-the-box - it came with a default Prometheus data source
# so we just need to edit those settings
http://<GRAFANA_IP_OR_HOSTNAME>:3000/datasources/edit/1/
*** Note that we are editing the default "Prometheus" Data Source ***


# in NEWER versions of Grafana - out-of-the-box - it DOES NOT come with a default Prometheus data source
# so we just need to add a new data source
http://<GRAFANA_IP_OR_HOSTNAME>:3000/datasources
*** select "Prometheus" as Data Source ***


Use following options to configure this data source :

Name     : Prometheus
Default  : True
HTTP URL : http://<PROMETHEUS_IP_OR_HOSTNAME>:9090/

Click on "Save & Test" button at the end of page.

If everything is fine, we should see a message "Data source is working".
```

---

#### Now let us import ` Cassandra Dashboard ` into ` Grafana ` :

##### if your server HAS internet access :

```
http://<GRAFANA_IP_OR_HOSTNAME>:3000/dashboard/import

Put "14070" in text box for "Import via grafana.com"

Click on "Load" button.

Grafana should download the dashboard from grafana.com

Under "Options" - select "Prometheus" as your data source.

Click on "Import" button.
```

##### if your server does NOT have internet access :

```
http://<GRAFANA_IP_OR_HOSTNAME>:3000/dashboard/import

Click on "Upload JSON file" button.

Download and select "CassandraDashboardByORAMAD_<DATE>.json".

Under "Options" - select "Prometheus" as your data source.

Click on "Import" button.
```

---

<br>

### Enjoy the Cassandra Dashboard developed by ORAMAD

```
http://<GRAFANA_IP_OR_HOSTNAME>:3000/d/reQeDG2Gk/
```

<br><br><br>

