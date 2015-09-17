#!/bin/bash
STATSD_IP="<%= @ip %>"
STATSD_PORT="<%= @port %>"

msg=${1:?"Usage $0 message"}

echo $msg | /bin/nc -w 2 -u $STATSD_IP $STATSD_PORT

