#!/bin/bash

### https://github.com/Sarma1807/Prometheus-Grafana-Cassandra

# Prometheus & Grafana for Cassandra
# script version : v01_20240125 : Sarma Pydipally

#########################
### start - change following settings according to your environment
#########################

# blacklist few mount points to avoid sending unwanted mount point info to Prometheus
# | (pipe) separated string values

BLACKLISTED_MOUNT_POINTS="tmpfs|boot|tools|home|tmp|usr|local|var"

#########################
### end - change following settings according to your environment
### NO FURTHER CHANGES ARE REQUIRED IN THIS FILE
#########################

echo "`date +'%d-%b-%Y %I:%M:%S %p'` : Script started executing." > ${BASH_SOURCE}.log

source ~/.bash_profile > /dev/null ;

        PROM_FILE=/tmp/oramad_cass_metrics_prom.tmp
  PROM_FILE_FINAL=/tmp/oramad_cass_metrics.prom
        NODE_INFO=/tmp/oramad_nodetool_info.tmp
      NODE_STATUS=/tmp/oramad_nodetool_status.tmp
    MR_INPUT_FILE=/tmp/oramad_cass_prom_metrics_0.txt
MR_OUTPUT_FILE_01=/tmp/oramad_cass_prom_metrics_1.tmp
MR_OUTPUT_FILE_02=/tmp/oramad_cass_prom_metrics_2.tmp
MR_OUTPUT_FILE_03=/tmp/oramad_cass_prom_metrics_3.tmp
MR_OUTPUT_FILE_04=/tmp/oramad_cass_prom_metrics_4.tmp
MR_OUTPUT_FILE_05=/tmp/oramad_cass_prom_metrics_5.tmp

rm -f ${PROM_FILE}
rm -f ${NODE_INFO}
rm -f ${NODE_STATUS}
rm -f ${MR_OUTPUT_FILE_01}
rm -f ${MR_OUTPUT_FILE_02}
rm -f ${MR_OUTPUT_FILE_03}
rm -f ${MR_OUTPUT_FILE_04}
rm -f ${MR_OUTPUT_FILE_05}

CASS_CLUSTER_NAME="unknown_cluster"
CASS_DC_NAME="unknown_datacenter"

CONFIG_CHANGED=false

### identify if Cassandra is UP or DOWN
CASS_PROCESS_COUNT=`ps -ef | egrep -i "CassandraDaemon|dse.server" | grep -v "grep" | wc -l`
if [[ "${CASS_PROCESS_COUNT}" -gt "0" ]]; then
  ### Cassandra is UP

  ### get Cassandra Cluster Name
  if [ "${CASS_CLUSTER_NAME}" = "unknown_cluster" ]; then
    CASS_CLUS_NAME=`nodetool describecluster | grep Name | cut -d":" -f2`
    CASS_CLUS_NAME=$(echo ${CASS_CLUS_NAME})
    sed -i "0,/unknown_cluster/s//${CASS_CLUS_NAME}/" ${BASH_SOURCE}
    CONFIG_CHANGED=true
  fi

  ### get Cassandra Node Data Center Name
  if [ "${CASS_DC_NAME}" = "unknown_datacenter" ]; then
    CASS_DC_NAME=`nodetool info | grep "Data Center" | cut -d":" -f2`
    CASS_DC_NAME=$(echo ${CASS_DC_NAME})
    sed -i "0,/unknown_datacenter/s//${CASS_DC_NAME}/" ${BASH_SOURCE}
    CONFIG_CHANGED=true
  fi

  if [ "${CONFIG_CHANGED}" = "true" ]; then
    echo "`date +'%d-%b-%Y %I:%M:%S %p'` : Initial script configuration completed." >> ${BASH_SOURCE}.log
    exit 1
  fi
else
  ### Cassandra is DOWN
  echo "`date +'%d-%b-%Y %I:%M:%S %p'` : Cassandra was DOWN on this node. Script was executed with ERRORs." >> ${BASH_SOURCE}.log
fi

##################################################
### start - system metrics
##################################################

### generate : oramad_system_info{cass_cluster_name="",data_center="",domainname="",hostname_ip="",hostname_ips="",hostname_short="",os_release="",uptime_pretty_short=""} 1

HN_S=`hostname -s`                  # hostname short
HN_D=`hostname | cut -d"." -f2-`    # domainname

# if domainname is missing - then return null
if [ "${HN_S}" = "${HN_D}" ]; then
  HN_D=""
fi

HN_IP=`hostname -i`    # primary ip address
HN_IPS=`hostname -I`   # all ip addresses

OSR=`cat /etc/system-release`   # os info

alias UPP="echo `uptime -p` | sed 's/up //g' | sed 's/,//g'"; UPPT=`UPP`;    # uptime pretty
UPPT_array=($UPPT); UPPTS=`echo ${UPPT_array[@]:0:2} | sed 's/ /+ /g'`;      # uptime pretty short


COMMON_TAGS=cass_cluster_name=\"${CASS_CLUSTER_NAME}\",data_center=\"${CASS_DC_NAME}\",hostname_short=\"${HN_S}\"

# write : oramad_system_info
echo "oramad_system_info{${COMMON_TAGS},domainname=\"${HN_D}\",hostname_ip=\"${HN_IP}\",hostname_ips=\"${HN_IPS}\",os_release=\"${OSR}\",uptime_pretty_short=\"${UPPTS}\"} 1" >> ${PROM_FILE}


### generate : RAM Info counters

free_ram="`free --bytes | grep Mem`"; set -- $free_ram; free_ram_total_bytes=$2; free_ram_available_bytes=$7;
free_ram_used_bytes=$(( $free_ram_total_bytes - $free_ram_available_bytes ))
free_ram_used_percent=$(( (($free_ram_used_bytes * 100)) / $free_ram_total_bytes ))
free_ram_available_percent=$(( 100 - $free_ram_used_percent ))

# write : RAM Info counters
echo "oramad_ram_total_bytes{${COMMON_TAGS}} ${free_ram_total_bytes}"              >> ${PROM_FILE}
echo "oramad_ram_used_bytes{${COMMON_TAGS}} ${free_ram_used_bytes}"                >> ${PROM_FILE}
echo "oramad_ram_available_bytes{${COMMON_TAGS}} ${free_ram_available_bytes}"      >> ${PROM_FILE}
echo "oramad_ram_used_percent{${COMMON_TAGS}} ${free_ram_used_percent}"            >> ${PROM_FILE}
echo "oramad_ram_available_percent{${COMMON_TAGS}} ${free_ram_available_percent}"  >> ${PROM_FILE}



### generate : CPU Info counters

cpu_idle=`top -b -n1 | head -4 | grep Cpu | cut -d',' -f4`
cpu_idle=`echo $cpu_idle | cut -d' ' -f1`
cpu_idle_percent=`printf "%.0f\n" ${cpu_idle}`
cpu_used_percent=$(( 100 - $cpu_idle_percent ))

# write : CPU Info counters
echo "oramad_cpu_used_percent{${COMMON_TAGS}} ${cpu_used_percent}"   >> ${PROM_FILE}
echo "oramad_cpu_idle_percent{${COMMON_TAGS}} ${cpu_idle_percent}"   >> ${PROM_FILE}



### generate : Mount Points Info

df --block-size=1K --output=target,size,used,itotal,iused,fstype | egrep -v "blocks|${BLACKLISTED_MOUNT_POINTS}" | xargs -L1 | while read output_line ;
do
  set -- $output_line

  mount_point=$1
  mount_total_size_kb=$2
  mount_used_kb=$3
  mount_total_inodes=$4
  mount_used_inodes=$5
  mount_fstype=$6

  mount_available_kb=$(( $mount_total_size_kb - $mount_used_kb ))
  mount_available_inodes=$(( $mount_total_inodes - $mount_used_inodes ))
  mount_used_percent=$(( (($mount_used_kb * 100)) / $mount_total_size_kb ))
  mount_available_percent=$(( 100 - $mount_used_percent ))
  mount_used_inodes_percent=$(( (($mount_used_inodes * 100)) / $mount_total_inodes ))
  mount_available_inodes_percent=$(( 100 - $mount_used_inodes_percent ))

  # write : Mount Points Info
  echo "oramad_mount_total_size_kb{${COMMON_TAGS},mountpoint=\"${mount_point}\",fstype=\"${mount_fstype}\"} ${mount_total_size_kb}"                         >> ${PROM_FILE}
  echo "oramad_mount_used_kb{${COMMON_TAGS},mountpoint=\"${mount_point}\",fstype=\"${mount_fstype}\"} ${mount_used_kb}"                                     >> ${PROM_FILE}
  echo "oramad_mount_total_inodes{${COMMON_TAGS},mountpoint=\"${mount_point}\",fstype=\"${mount_fstype}\"} ${mount_total_inodes}"                           >> ${PROM_FILE}
  echo "oramad_mount_used_inodes{${COMMON_TAGS},mountpoint=\"${mount_point}\",fstype=\"${mount_fstype}\"} ${mount_used_inodes}"                             >> ${PROM_FILE}
  echo "oramad_mount_available_kb{${COMMON_TAGS},mountpoint=\"${mount_point}\",fstype=\"${mount_fstype}\"} ${mount_available_kb}"                           >> ${PROM_FILE}
  echo "oramad_mount_available_inodes{${COMMON_TAGS},mountpoint=\"${mount_point}\",fstype=\"${mount_fstype}\"} ${mount_available_inodes}"                   >> ${PROM_FILE}
  echo "oramad_mount_used_percent{${COMMON_TAGS},mountpoint=\"${mount_point}\",fstype=\"${mount_fstype}\"} ${mount_used_percent}"                           >> ${PROM_FILE}
  echo "oramad_mount_available_percent{${COMMON_TAGS},mountpoint=\"${mount_point}\",fstype=\"${mount_fstype}\"} ${mount_available_percent}"                 >> ${PROM_FILE}
  echo "oramad_mount_used_inodes_percent{${COMMON_TAGS},mountpoint=\"${mount_point}\",fstype=\"${mount_fstype}\"} ${mount_used_inodes_percent}"             >> ${PROM_FILE}
  echo "oramad_mount_available_inodes_percent{${COMMON_TAGS},mountpoint=\"${mount_point}\",fstype=\"${mount_fstype}\"} ${mount_available_inodes_percent}"   >> ${PROM_FILE}
done

##################################################
### end - system metrics
##################################################


##################################################
### start - cassandra nodetool metrics
##################################################

### generate : oramad_cass_up{cass_cluster_name="",data_center="",hostname_short=""} 1

### identify if Cassandra is UP or DOWN
CASS_PROCESS_COUNT=`ps -ef | egrep -i "CassandraDaemon|dse.server" | grep -v "grep" | wc -l`
if [[ "${CASS_PROCESS_COUNT}" -eq "0" ]]; then
  echo "oramad_cass_up{${COMMON_TAGS}} 0"  >> ${PROM_FILE}
  exit 1
else
  echo "oramad_cass_up{${COMMON_TAGS}} 1"  >> ${PROM_FILE}
fi


### generate : oramad_cass_node_info{cass_cluster_name="",data_center="",hostname_short="",cass_version="",data_size="",data_center="",node_rack="",num_tokens="",cass_uptime_pretty="",node_repair_percent=""} 1

### identify Apache Cassandra vs. DataStax Enterprise
CASS_TYPE_CHECK=`ps -ef | grep -i "CassandraDaemon" | grep -v "grep" | wc -l`
if [[ "${CASS_TYPE_CHECK}" -gt "0" ]]; then
  CASS_TYPE="CASS"
fi
CASS_TYPE_CHECK=`ps -ef | grep -i "dse.server" | grep -v "grep" | wc -l`
if [[ "${CASS_TYPE_CHECK}" -gt "0" ]]; then
  CASS_TYPE="DSE"
fi


if [ "${CASS_TYPE}" = "CASS" ]; then
  CN_VER=`nodetool version | cut -d" " -f2`                    # cassandra version
elif [ "${CASS_TYPE}" = "DSE" ]; then
  CN_DSEVER=`nodetool version | grep DSE | cut -d" " -f3`      # dse version
  CN_VER="DSE ${CN_DSEVER}"
fi



# capture output of cassandra "nodetool status" command
nodetool status | egrep "^U|^D" | cut -d" " -f1-3 > ${NODE_STATUS}

CASS_NODES_TOTAL=`egrep "^U|^D" ${NODE_STATUS} | egrep -v "Datacenter" | wc -l`
CASS_DCS_TOTAL=`egrep "Datacenter" ${NODE_STATUS} | wc -l`

### generate : oramad_cass_nodes_count{cass_cluster_name="",data_center="",hostname_short=""} 1
echo "oramad_cass_nodes_count{${COMMON_TAGS}} ${CASS_NODES_TOTAL}" >> ${PROM_FILE}

### generate : oramad_cass_datacenters_count{cass_cluster_name="",data_center="",hostname_short=""} 1
echo "oramad_cass_datacenters_count{${COMMON_TAGS}} ${CASS_DCS_TOTAL}" >> ${PROM_FILE}



# capture output of cassandra "nodetool info" command
nodetool info > ${NODE_INFO}

CN_DATA=`grep Load ${NODE_INFO} | cut -d":" -f2`                # data on node
  CN_DC=`grep "Data Center" ${NODE_INFO} | cut -d":" -f2`       # cassandra node data center
CN_RACK=`grep Rack ${NODE_INFO} | cut -d":" -f2`                # cassandra node rack
CN_TKNS=`grep Token ${NODE_INFO} | rev | cut -d" " -f2 | rev`   # cassandra node num_tokens

    CN_HEAP_TOTAL_MB=`grep "Heap Memory" ${NODE_INFO} | grep -v Off | cut -d":" -f2 | cut -d"/" -f2 | cut -d"." -f1`     # cassandra total heap memory mb
     CN_HEAP_USED_MB=`grep "Heap Memory" ${NODE_INFO} | grep -v Off | cut -d":" -f2 | cut -d"/" -f1 | cut -d"." -f1`     # cassandra used  heap memory mb
CN_HEAP_USED_PERCENT=$(( (($CN_HEAP_USED_MB * 100)) / $CN_HEAP_TOTAL_MB ))                                               # cassandra used  heap memory percent

 CN_OFF_HEAP_USED_MB=`grep "Off Heap Memory" ${NODE_INFO} | cut -d":" -f2`                                               # cassandra used  off heap memory mb
if [[ "`(expr ${CN_OFF_HEAP_USED_MB} '<' 1)`" -eq "1" ]]; then
  CN_OFF_HEAP_USED_MB="1"
fi

CN_UPT_SEC=`grep Uptime ${NODE_INFO} | cut -d":" -f2`                  # cassandra uptime in seconds
CN_UPT_FORMAT=`TZ=UTC printf "%d:%(%H:%M)T\n" $((CN_UPT_SEC/86400)) ${CN_UPT_SEC}`
CN_UPT_D=`echo ${CN_UPT_FORMAT} | cut -d":" -f1`
CN_UPT_H=`echo ${CN_UPT_FORMAT} | cut -d":" -f2`; CN_UPT_H=${CN_UPT_H/0/};
CN_UPT_M=`echo ${CN_UPT_FORMAT} | cut -d":" -f3`; CN_UPT_M=${CN_UPT_M/0/};

if [[ "${CN_UPT_D}" -gt "0" ]]; then
  CN_UPT_REPORT="${CN_UPT_D}+ days"          # cassandra uptime in days
elif [[ "${CN_UPT_H}" -gt "0" ]]; then
  CN_UPT_REPORT="${CN_UPT_H}+ hours"         # cassandra uptime in hours
elif [[ "${CN_UPT_M}" -gt "0" ]]; then
  CN_UPT_REPORT="${CN_UPT_M}+ minutes"       # cassandra uptime in minutes
else
  CN_UPT_REPORT="few seconds"                # cassandra uptime in seconds
fi


CN_PR=`grep "Percent Repaired" ${NODE_INFO} | cut -d":" -f2 | cut -d"." -f1`      # cassandra percent repaired
CN_PR=$(echo "${CN_PR}" | sed 's/%//g')       # if we get NaN% - then remove %
if [[ "${CN_PR}" -eq "0" ]] || [ "${CN_PR}" = "NaN" ]; then
  CN_PR="N/A"       # if we get Zero or NaN - then replace it with N/A
fi


# remove leading whitespace
CN_DATA=$(echo ${CN_DATA})
CN_DC=$(echo ${CN_DC})
CN_RACK=$(echo ${CN_RACK})
CN_HEAP_TOTAL_MB=$(echo ${CN_HEAP_TOTAL_MB})
CN_HEAP_USED_MB=$(echo ${CN_HEAP_USED_MB})
CN_OFF_HEAP_USED_MB=$(echo ${CN_OFF_HEAP_USED_MB})
CN_UPT_SEC=$(echo ${CN_UPT_SEC})
CN_UPT_REPORT=$(echo ${CN_UPT_REPORT})
CN_PR=$(echo ${CN_PR})


# write : oramad_cass_node_info
echo "oramad_cass_node_info{${COMMON_TAGS},cass_version=\"${CN_VER}\",data_size=\"${CN_DATA}\",node_rack=\"${CN_RACK}\",num_tokens=\"${CN_TKNS}\",cass_uptime_pretty=\"${CN_UPT_REPORT}\",node_repair_percent=\"${CN_PR}\"} 1" >> ${PROM_FILE}

# write : oramad_cass_heap_*
echo "oramad_cass_heap_total_mb{${COMMON_TAGS}} ${CN_HEAP_TOTAL_MB}"             >> ${PROM_FILE}
echo "oramad_cass_heap_used_mb{${COMMON_TAGS}} ${CN_HEAP_USED_MB}"               >> ${PROM_FILE}
echo "oramad_cass_heap_used_percent{${COMMON_TAGS}} ${CN_HEAP_USED_PERCENT}"     >> ${PROM_FILE}
echo "oramad_cass_off_heap_used_mb{${COMMON_TAGS}} ${CN_OFF_HEAP_USED_MB}"       >> ${PROM_FILE}

##################################################
### end - cassandra nodetool metrics
##################################################


##################################################
### start - cassandra oramad/CassPromFileExporter.java
##################################################

touch ${MR_INPUT_FILE}

# remove unwanted lines and write MR_OUTPUT_FILE_01
cat ${MR_INPUT_FILE} | grep -v "^#" > ${MR_OUTPUT_FILE_01}

# formatting MR_OUTPUT_FILE_01
 MR_INPUT_ROWPREFIX=org_apache_cassandra_metrics_
MR_OUTPUT_ROWPREFIX=oacm_
sed -i "s/${MR_INPUT_ROWPREFIX}/${MR_OUTPUT_ROWPREFIX}/g" ${MR_OUTPUT_FILE_01}

# select WANTED metrics and write to MR_OUTPUT_FILE_02
cat ${MR_OUTPUT_FILE_01} | grep -v "^#" | egrep -i "${MR_OUTPUT_ROWPREFIX}CommitLog_"     | egrep -i "CompletedTasks|PendingTasks|TotalCommitLogSize"                                > ${MR_OUTPUT_FILE_02}
cat ${MR_OUTPUT_FILE_01} | grep -v "^#" | egrep -i "${MR_OUTPUT_ROWPREFIX}CQL_"           | egrep -i "PreparedStatementsCount|PreparedStatementsExecuted|RegularStatementsExecuted" >> ${MR_OUTPUT_FILE_02}
cat ${MR_OUTPUT_FILE_01} | grep -v "^#" | egrep -i "${MR_OUTPUT_ROWPREFIX}Client_"        | egrep -i "AuthFailure|AuthSuccess"                                                      >> ${MR_OUTPUT_FILE_02}
cat ${MR_OUTPUT_FILE_01} | grep -v "^#" | egrep -i "${MR_OUTPUT_ROWPREFIX}Storage_"       | egrep -i "Exceptions|TotalHints|TotalHintsInProgress"                                   >> ${MR_OUTPUT_FILE_02}
cat ${MR_OUTPUT_FILE_01} | grep -v "^#" | egrep -i "${MR_OUTPUT_ROWPREFIX}Cache_"         | egrep -i "Capacity|Size|Requests|Hits|Misses"                                           >> ${MR_OUTPUT_FILE_02}
cat ${MR_OUTPUT_FILE_01} | grep -v "^#" | egrep -i "${MR_OUTPUT_ROWPREFIX}ClientRequest_" | egrep -i "Timeouts"                                                                     >> ${MR_OUTPUT_FILE_02}
cat ${MR_OUTPUT_FILE_01} | grep -v "^#" | egrep -i "${MR_OUTPUT_ROWPREFIX}keyspace_"      | egrep -i "TotalDiskSpaceUsed"                                                           >> ${MR_OUTPUT_FILE_02}

cat ${MR_OUTPUT_FILE_01} | grep -v "^#" | egrep -i "${MR_OUTPUT_ROWPREFIX}Table_"         | egrep -i "TotalDiskSpaceUsed"                                                           >> ${MR_OUTPUT_FILE_02}

# select WANTED metrics and remove quantile metrics and write to MR_OUTPUT_FILE_02
cat ${MR_OUTPUT_FILE_01} | grep -v "^#" | egrep -i "${MR_OUTPUT_ROWPREFIX}Table_"         | egrep -i "_ReadLatency|_RangeLatency|_WriteLatency"                              | egrep -v "{quantile=" >> ${MR_OUTPUT_FILE_02}
cat ${MR_OUTPUT_FILE_01} | grep -v "^#" | egrep -i "${MR_OUTPUT_ROWPREFIX}Table_"         | egrep -i "CoordinatorReadLatency|CoordinatorWriteLatency|CoordinatorScanLatency" | egrep -v "{quantile=" >> ${MR_OUTPUT_FILE_02}


### prom formatting
sed -i 's/oacm_CommitLog_CompletedTasks/oramad_commitlog_completed_tasks{~}/g'        ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_CommitLog_PendingTasks/oramad_commitlog_pending_tasks{~}/g'            ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_CommitLog_TotalCommitLogSize/oramad_commitlog_size_bytes{~}/g'         ${MR_OUTPUT_FILE_02}

sed -i 's/oacm_CQL_PreparedStatementsCount/oramad_cql_prep_stmts_cached{~}/g'         ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_CQL_PreparedStatementsExecuted/oramad_cql_prep_stmts_executed{~}/g'    ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_CQL_RegularStatementsExecuted/oramad_cql_unprep_stmts_executed{~}/g'   ${MR_OUTPUT_FILE_02}

sed -i 's/oacm_Client_AuthFailure_total/oramad_cass_auth_failures{~}/g'               ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_Client_AuthSuccess_total/oramad_cass_auth_success{~}/g'                ${MR_OUTPUT_FILE_02}

sed -i 's/oacm_Storage_Exceptions/oramad_cass_storage_exceptions{~}/g'                    ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_Storage_TotalHintsInProgress/oramad_cass_hints_being_sent{~}/g'            ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_Storage_TotalHints/oramad_cass_total_hints_stored{~}/g'                    ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_Storage_RepairExceptions/oramad_cass_storage_repair_exceptions_NEW{~}/g'   ${MR_OUTPUT_FILE_02}

sed -i 's/oacm_Cache_Capacity_KeyCache/oramad_cass_KeyCache_allocated_bytes{~}/g'              ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_Cache_Size_KeyCache/oramad_cass_KeyCache_used_bytes{~}/g'                       ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_Cache_Requests_KeyCache_total/oramad_cass_KeyCache_requests{~}/g'               ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_Cache_Hits_KeyCache_total/oramad_cass_KeyCache_hits{~}/g'                       ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_Cache_Misses_KeyCache_total/oramad_cass_KeyCache_misses{~}/g'                   ${MR_OUTPUT_FILE_02}

sed -i 's/oacm_Cache_Capacity_RowCache/oramad_cass_RowCache_allocated_bytes{~}/g'              ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_Cache_Size_RowCache/oramad_cass_RowCache_used_bytes{~}/g'                       ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_Cache_Requests_RowCache_total/oramad_cass_RowCache_requests{~}/g'               ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_Cache_Hits_RowCache_total/oramad_cass_RowCache_hits{~}/g'                       ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_Cache_Misses_RowCache_total/oramad_cass_RowCache_misses{~}/g'                   ${MR_OUTPUT_FILE_02}

sed -i 's/oacm_Cache_Capacity_CounterCache/oramad_cass_CounterCache_allocated_bytes{~}/g'      ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_Cache_Size_CounterCache/oramad_cass_CounterCache_used_bytes{~}/g'               ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_Cache_Requests_CounterCache_total/oramad_cass_CounterCache_requests{~}/g'       ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_Cache_Hits_CounterCache_total/oramad_cass_CounterCache_hits{~}/g'               ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_Cache_Misses_CounterCache_total/oramad_cass_CounterCache_misses{~}/g'           ${MR_OUTPUT_FILE_02}

sed -i 's/oacm_ClientRequest_Timeouts_/#oramad_cass_client_request_timeouts{~,timeout_type="/g'            ${MR_OUTPUT_FILE_02}
egrep "^#oramad_cass_client_request_timeouts" ${MR_OUTPUT_FILE_02} > ${MR_OUTPUT_FILE_03}
sed -i 's/_total / /g' ${MR_OUTPUT_FILE_03}
sed -i 's/ /"} /g' ${MR_OUTPUT_FILE_03}
sed -i 's/#//g'  ${MR_OUTPUT_FILE_03}
cat ${MR_OUTPUT_FILE_03} >> ${MR_OUTPUT_FILE_02}

sed -i 's/oacm_keyspace_TotalDiskSpaceUsed_/#oramad_keyspace_size_bytes{~,keyspace_name="/g'            ${MR_OUTPUT_FILE_02}
egrep "^#oramad_keyspace_size_bytes" ${MR_OUTPUT_FILE_02} > ${MR_OUTPUT_FILE_03}
sed -i 's/ /"} /g' ${MR_OUTPUT_FILE_03}
sed -i 's/#//g'  ${MR_OUTPUT_FILE_03}
cat ${MR_OUTPUT_FILE_03} >> ${MR_OUTPUT_FILE_02}


# find list of keyspaces - order them DESC based on length(keyspace_name)
cat ${MR_OUTPUT_FILE_02} | grep oramad_keyspace_size_bytes | grep -v "^#" | cut -d'"' -f2 > ${MR_OUTPUT_FILE_04}
cat ${MR_OUTPUT_FILE_04} | sort | uniq | while read VLINE; do echo "${#VLINE}:${VLINE}"; done | sort -n -r | cut -d':' -f2 > ${MR_OUTPUT_FILE_05}

# source : keyspace_name_table_name
# split and change entries to : keyspace_name="keyspace_name",table_name="table_name"
# metric : oramad_table_size_bytes
sed -i 's/oacm_Table_TotalDiskSpaceUsed_/#oramad_table_size_bytes{~,keyspace_name="/g'            ${MR_OUTPUT_FILE_02}
egrep "^#oramad_table_size_bytes" ${MR_OUTPUT_FILE_02} > ${MR_OUTPUT_FILE_03}
cat ${MR_OUTPUT_FILE_05} | while read VLINE; do sed -i "s/~,keyspace_name=\"${VLINE}_/~,keyspace_name=\"@~${VLINE}~@/g" ${MR_OUTPUT_FILE_03}; done
sed -i "s/~,keyspace_name=\"all /~,keyspace_name=\"@~all\",table_name=\"all /g" ${MR_OUTPUT_FILE_03}
sed -i "s/~@/\",table_name=\"/g" ${MR_OUTPUT_FILE_03}
sed -i "s/@~//g"                 ${MR_OUTPUT_FILE_03}
sed -i 's/ /"} /g'               ${MR_OUTPUT_FILE_03}
sed -i 's/#//g'                  ${MR_OUTPUT_FILE_03}
cat ${MR_OUTPUT_FILE_03} >> ${MR_OUTPUT_FILE_02}

# source : keyspace_name_table_name
# split and change entries to : keyspace_name="keyspace_name",table_name="table_name"
# metric : oramad_cass_latency
sed -i             's/oacm_Table_ReadLatency_/#oramad_cass_latency{~,latency_type="Node-Read",keyspace_name="/g'              ${MR_OUTPUT_FILE_02}
sed -i            's/oacm_Table_RangeLatency_/#oramad_cass_latency{~,latency_type="Node-Range",keyspace_name="/g'             ${MR_OUTPUT_FILE_02}
sed -i            's/oacm_Table_WriteLatency_/#oramad_cass_latency{~,latency_type="Node-Write",keyspace_name="/g'             ${MR_OUTPUT_FILE_02}
sed -i  's/oacm_Table_CoordinatorReadLatency_/#oramad_cass_latency{~,latency_type="Coordinator-Read",keyspace_name="/g'       ${MR_OUTPUT_FILE_02}
sed -i 's/oacm_Table_CoordinatorWriteLatency_/#oramad_cass_latency{~,latency_type="Coordinator-Write",keyspace_name="/g'      ${MR_OUTPUT_FILE_02}
sed -i  's/oacm_Table_CoordinatorScanLatency_/#oramad_cass_latency{~,latency_type="Coordinator-Scan",keyspace_name="/g'       ${MR_OUTPUT_FILE_02}
egrep "^#oramad_cass_latency" ${MR_OUTPUT_FILE_02} > ${MR_OUTPUT_FILE_03}
sed -i 's/_count / /g' ${MR_OUTPUT_FILE_03}
cat ${MR_OUTPUT_FILE_05} | while read VLINE; do sed -i "s/,keyspace_name=\"${VLINE}_/,keyspace_name=\"@~${VLINE}~@/g" ${MR_OUTPUT_FILE_03}; done
sed -i "s/,keyspace_name=\"all /,keyspace_name=\"@~all\",table_name=\"all /g" ${MR_OUTPUT_FILE_03}
sed -i "s/~@/\",table_name=\"/g" ${MR_OUTPUT_FILE_03}
sed -i "s/@~//g"                 ${MR_OUTPUT_FILE_03}
sed -i 's/ /"} /g'               ${MR_OUTPUT_FILE_03}
sed -i 's/#//g'                  ${MR_OUTPUT_FILE_03}
cat ${MR_OUTPUT_FILE_03} >> ${MR_OUTPUT_FILE_02}


### replace COMMON_TAGS
sed -i "s/~/${COMMON_TAGS}/g" ${MR_OUTPUT_FILE_02}

### write final output to PROM_FILE
egrep -v "^#"        ${MR_OUTPUT_FILE_02} > ${MR_OUTPUT_FILE_03}   # remove commented lines
egrep -v " 0.0$| 0$" ${MR_OUTPUT_FILE_03} > ${MR_OUTPUT_FILE_04}   # remove all ZERO value metrics
egrep -v 'keyspace_name="system|keyspace_name="dse|keyspace_name="HiveMetaStore|keyspace_name="solr_admin|keyspace_name="all' ${MR_OUTPUT_FILE_04} > ${MR_OUTPUT_FILE_03}   # remove all {system|dse|HiveMetaStore|solr_admin|all} keyspaces/tables
cat ${MR_OUTPUT_FILE_03} >> ${PROM_FILE}
cat ${PROM_FILE} > ${PROM_FILE_FINAL}

##################################################
### end - cassandra oramad/CassPromFileExporter.java
##################################################


# finally
# rm -f ${PROM_FILE}
# rm -f ${NODE_INFO}
# rm -f ${NODE_STATUS}
# rm -f ${MR_OUTPUT_FILE_01}
# rm -f ${MR_OUTPUT_FILE_02}
# rm -f ${MR_OUTPUT_FILE_03}
# rm -f ${MR_OUTPUT_FILE_04}
# rm -f ${MR_OUTPUT_FILE_05}

echo "`date +'%d-%b-%Y %I:%M:%S %p'` : Script was executed without ERRORs." >> ${BASH_SOURCE}.log

#########################

