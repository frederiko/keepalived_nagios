#!/bin/bash
# keepalived_heartbeat.sh
#
# reports to nagios the service check status for keepalived
# required notify_nagios.rb script.
#
NOTIFY_SCRIPT="/usr/local/bin/notify_nagios.rb"
NAGIOS_IP="171.64.144.11"
NAGIOS_SERVICE_NAME="keepalived"
KEEPALIVED_PID="/var/run/keepalived.pid"

if [ -f $KEEPALIVED_PID ] ; then
   # reports service is up. Don't concern about the state.
   $NOTIFY_SCRIPT -H $NAGIOS_IP -s $NAGIOS_SERVICE_NAME -S OK -m "OK: heartbeat passive check received"
else
   # reports service is up. Don't concern about the state.
   $NOTIFY_SCRIPT -H $NAGIOS_IP -s $NAGIOS_SERVICE_NAME -S CRITICAL -m fault
fi

exit 0