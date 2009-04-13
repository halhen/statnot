loadavg="`cat /proc/loadavg | awk '{print $1, $2, $3}'`"

echo "[load ${loadavg}]   `date +'%R'`"

