
if [ "$INFLUXDB_START" = "true" ]
then
    influxd --http-bind-address :8086 --reporting-disabled > /dev/null 2>&1 &
    $COUNT=0
    until curl -s http://localhost:8086/health; do 
        COUNT=$(( $COUNT + 1 ));
        if (( $COUNT >= $INFLUXDB_TIMEOUT )); then
            echo "Timedout after $INFLUXDB_TIMEOUT sec on starting influx.."
            exit 123;
        fi
        sleep 1;
    done
    tokenString=""
    if [ -n "${INFLUXDB_TOKEN}" ]; then 
        tokenString="-t $INFLUXDB_TOKEN"
    fi
    influx setup --host http://localhost:8086 -f \
            -o $INFLUXDB_ORG \
            -u $INFLUXDB_USER \
            -p $INFLUXDB_PASSWORD \
            -b $INFLUXDB_BUCKET \
            $tokenString
fi