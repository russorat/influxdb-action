
if [ "$INFLUXDB_START" = "true" ]
then
    influxd --http-bind-address :8086 --reporting-disabled > /dev/null 2>&1 &
    until curl -s http://localhost:8086/health; do sleep 1; done
    if [ -z ${INFLUXDB_TOKEN+x} ];
        then influx setup --host http://localhost:8086 -f \
            -o $INFLUXDB_ORG \
            -u $INFLUXDB_USER \
            -p $INFLUXDB_PASSWORD \
            -b $INFLUXDB_BUCKET
        else influx setup --host http://localhost:8086 -f \
            -o $INFLUXDB_ORG \
            -u $INFLUXDB_USER \
            -p $INFLUXDB_PASSWORD \
            -b $INFLUXDB_BUCKET \
            -t $INFLUXDB_TOKEN
    fi
fi