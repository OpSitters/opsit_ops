#!/bin/bash
CARBON_IP="<%= @ip %>"
CARBON_PORT="<%= @port %>"

metric=${1:?"Usage $0 metric value"}
value=${2:?"Usage $0 metric value"}

echo $metric $value `date +%s`| /bin/nc -w 2 -q0 $CARBON_IP $CARBON_PORT
