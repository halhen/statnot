if [ $# -eq 0 ]; then
    loadavg="`cat /proc/loadavg | awk '{print $1, $2, $3}'`";
    echo "[load ${loadavg}]   `date +'%R'`";
else
    echo "NOTIFICATION: $1";
fi

