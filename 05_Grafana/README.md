# Grafana

` ASSUMPTION : ~ = /apps/opt/promgraf `

We will install and configure ` Grafana ` only on one server.

```
https://grafana.com/grafana/download
```

Download ` Grafana ` from this webpage. <br><br><br>

At the time of writing this, ` Grafana version 7.4.3 ` was available. <br>

```
cd ~
tar -xzvf ~/software/grafana-7.4.3.linux-amd64.tar.gz
ln -s ~/grafana-7.4.3 ~/grafana-current
mkdir ~/grafana-current/logs
```

` Prometheus ` was extracted to ` ~/grafana-7.4.3 `

<br><br><br>

### Grafana Configuration File

```
# ~/grafana-current/conf/defaults.ini

# default Grafana port is configured in this file :
$ egrep "^http_port" ~/grafana-current/conf/defaults.ini
http_port = 3000
```

<br><br>

Add entry to crontab ... to automatically start ` Grafana ` along with server start :

```
$ crontab -e

##### add following line
@reboot	~/grafana-current/bin/grafana-server -homepath ~/grafana-current -pidfile ~/grafana-current/logs/grafana-server.pid &
```

<br><br><br>

After server restart ` Grafana ` webpage can be accessed at :

```
http://<SERVER_IP_OR_HOSTNAME>:3000/


Default Username / Password :
Username : admin
Password : admin
```

<br><br><br>

After logging into ` Grafana `, we can create our ` Prometheus ` as data source :

```
http://<SERVER_IP_OR_HOSTNAME>:3000/datasources/new

Find "Prometheus" from the list of Data Sources and click on "Select" button.

Use following options to configure this data source :

Name     : myPrometheus
Default  : True
HTTP URL : http://<PROMETHEUS_IP_OR_HOSTNAME>:9090/

Click on "Save & Test" button at the end of page.

If everything is fine, we should see a message "Data source is working"
```

<br><br><br>

After logging into ` Grafana `, we can create our ` Prometheus ` as data source :

```
http://<SERVER_IP_OR_HOSTNAME>:3000/datasources/new

Find "Prometheus" from the list of Data Sources and click on "Select" button.

Use following options to configure this data source :

Name     : myPrometheus
Default  : True
HTTP URL : http://<PROMETHEUS_IP_OR_HOSTNAME>:9090/

Click on "Save & Test" button at the end of page.

If everything is fine, we should see a message "Data source is working"
```


<br><br>



### This configuration is required on only one server which will run Grafana server.

<br>

