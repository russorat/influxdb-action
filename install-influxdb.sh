cd /tmp
if [ "$INFLUXDB_VERSION" = "latest" ];
then
  export INFLUXDB_VERSION=$(curl --silent "https://api.github.com/repos/influxdata/influxdb/releases" | jq -r '. | sort_by(.tag_name) | reverse[] | .tag_name' | sed -e 's/v//g' | head -n 1)
  export INFLUXDB_DOWNLOAD_PATH="https://dl.influxdata.com/influxdb/releases"
elif [ "$INFLUXDB_VERSION" = "nightly" ];
then
  export INFLUXDB_DOWNLOAD_PATH="https://dl.influxdata.com/platform/nightlies"
else
  export INFLUXDB_DOWNLOAD_PATH="https://dl.influxdata.com/influxdb/releases"
fi
wget -q $INFLUXDB_DOWNLOAD_PATH/influxdb2-$INFLUXDB_VERSION-linux-amd64.tar.gz
tar xvfz influxdb2-$INFLUXDB_VERSION-linux-amd64.tar.gz
sudo cp influxdb2_linux_amd64/influxd /usr/local/bin/
rm -r influxdb2_linux_amd64/

wget -q $INFLUXDB_DOWNLOAD_PATH/influxdb2-client-$INFLUXDB_VERSION-linux-amd64.tar.gz
tar xvfz influxdb2-client-$INFLUXDB_VERSION-linux-amd64.tar.gz
sudo cp influxdb2-client-$INFLUXDB_VERSION-linux-amd64/influx /usr/local/bin/
rm -r influxdb2-client-$INFLUXDB_VERSION-linux-amd64/

cd -
