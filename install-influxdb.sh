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

echo "The Server is downloading "
wget -q $INFLUXDB_DOWNLOAD_PATH/influxdb2_$INFLUXDB_VERSION-linux-amd64.tar.gz
tar xvfz influxdb2-$INFLUXDB_VERSION-linux-amd64.tar.gz
if [  -x "/tmp/influxdb2_linux_amd64/influxd" ]; then
  cp influxdb2_linux_amd64/influxd /usr/local/bin/
  rm -r influxdb2_linux_amd64/
else
  echo "The server is not found.."
  ls /tmp/influxdb2-client/
  rm -r influxdb2_linux_amd64/
  exit 123
fi

echo "The Client is downloading "
wget -q $INFLUXDB_DOWNLOAD_PATH/influxdb2-client-$INFLUXDB_VERSION-linux-amd64.tar.gz
mkdir  /tmp/influxdb2-client/ 
tar xvfz influxdb2-client-$INFLUXDB_VERSION-linux-amd64.tar.gz -C /tmp/influxdb2-client/

if [  -x "/tmp/influxdb2-client/influxdb2-client-$INFLUXDB_VERSION-linux-amd64/influx" ]; then
  echo "The client is in subdir."
  cp /tmp/influxdb2-client/influxdb2-client-$INFLUXDB_VERSION-linux-amd64/influx /usr/local/bin/
elif [  -x "/tmp/influxdb2-client/influx" ]; then
  echo "The client is in basedir."
  cp /tmp/influxdb2-client/influx /usr/local/bin/
  rm -r /tmp/influxdb2-client/
else
  echo "The client is not found.."
  ls /tmp/influxdb2-client/
  rm -r /tmp/influxdb2-client/
  exit 123
fi

cd -
