# Sanity checks:
if [ -z "$INFLUXDB_VERSION" ]; then
  echo "No version set."
  exit 121
fi

if [[ "$INFLUXDB_OS" == linux* || "$INFLUXDB_OS" == ubuntu* ]]; then
  if [[ "$INFLUXDB_OS" == linux-arm* ]]; then
    export INFLUXDB_OS="linux-arm"
  else
    export INFLUXDB_OS="linux-amd"
  fi
elif [[ "$INFLUXDB_OS" == windows* ]]; then
  export INFLUXDB_OS="windows"
elif [[ "$INFLUXDB_OS" == macos* ]]; then
  export INFLUXDB_OS="macos"
elif [ "${RUNNER_OS}" = Linux ]; then
  if [[ "${RUNNER_ARCH}" == ARM* ]]; then
      export INFLUXDB_OS="linux-arm"
    else
      export INFLUXDB_OS="linux"
  fi
elif [ "${RUNNER_OS}" = Windows ]; then
  export INFLUXDB_OS="windows"
elif [ "${RUNNER_OS}" = macOS ]; then
  export INFLUXDB_OS="macos"
else
  echo "Could not parse os:"
  echo "Input: \"${INFLUXDB_OS}\""
  echo "Runner: \"${RUNNER_OS}\""
  exit 111
fi

tempPath="/tmp/influxdb"
echo "\"${INFLUXDB_TEMP_PATH}\""
if [ -n "${INFLUXDB_TEMP_PATH}" -a -w "${INFLUXDB_TEMP_PATH}" ]; then
  tempPath="${INFLUXDB_TEMP_PATH}/influxdb"
fi
echo "Creating ${tempPath}/bin"
mkdir -p "${tempPath}/bin"
cd $tempPath
decompress="tar xvfz"
extension=".tar.gz"
executable=""
arch="-amd64"
osDownloadName="$INFLUXDB_OS"
fileDownload="wget -q"

if [ "$INFLUXDB_OS" = linux ]; then
  grepFor="linux.amd"
elif [ "$INFLUXDB_OS" = windows ]; then
  decompress="unzip"
  extension=".zip"
  executable=".exe"
  grepFor="windows"
  fileDownload="curl -O -L -sS"
elif [ "$INFLUXDB_OS" = macos ]; then
  grepFor="darwin"
  osDownloadName="darwin"
elif [ "$INFLUXDB_OS" = linux-arm ]; then
  grepFor="linux.arm"
  arch="64" # Hyphen is already in the string..
else
  echo "This error should not be possible, parsing of OS should already have happened."
  exit 123
fi

if [ "$INFLUXDB_VERSION" = "nightly" ]; then
  if [ "$INFLUXDB_OS" = linux ]; then
    influxServerDownload="https://dl.influxdata.com/platform/nightlies/influxdb2-nightly-linux-amd64.tar.gz"
  elif [ "$INFLUXDB_OS" = macos ]; then
    influxServerDownload="https://dl.influxdata.com/platform/nightlies/influxdb2-nightly-darwin-amd64.tar.gz"
  elif [ "$INFLUXDB_OS" = linux-arm ]; then
    influxServerDownload="https://dl.influxdata.com/platform/nightlies/influxdb2-nightly-linux-arm64.tar.gz"
  else
    echo "Nightlies not supported for \"$INFLUXDB_OS\""
    exit 119
  fi
else
if [[ "$INFLUXDB_VERSION" == v* ]]; then
    INFLUXDB_VERSION=$(echo "${INFLUXDB_VERSION}" | sed 's/v//')
  else
    INFLUXDB_VERSION="${INFLUXDB_VERSION}"
  fi
  echo "Version: \"$INFLUXDB_VERSION\""
  #MAPPING
  downloadsList="https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.6-windows.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.6_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.6_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.6_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.5_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.5_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.5-windows.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.5_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.4_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.4_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.4_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.4-windows.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.3-windows.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.3_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.3_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.3_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.1-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.1-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.1-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.1-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.0-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.0-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.0-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.0-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.6.1-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.6.1-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.6.1-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.6.1-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.6.0-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.6.0-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.6.0-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.6.0-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.5.1-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.5.1-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.5.1-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.5.1-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.5.0-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.5.0-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.5.0-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.5.0-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.4.0-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.4.0-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.4.0-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.4.0-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.3.0-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.3.0-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.3.0-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.3.0-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.2.0-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.2.0-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.2.0-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.2.0-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.1.1-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.1.1-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.1.1-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.1.1-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.1.0-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.1.0-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.1.0-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.1.0-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10-static_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10_linux_armel.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10_linux_armhf.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10_linux_i386.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10_windows_amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.9-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.9-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.9-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.9-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.9-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.9-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.9-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.9-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.8-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.8-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.8-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.8-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.8-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.8-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.8-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.8-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.9-static_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.9_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.9_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.9_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.9_linux_armel.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.9_linux_armhf.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.9_linux_i386.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.9_windows_amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.7-static_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.7_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.7_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.7_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.7_linux_armel.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.7_linux_armhf.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.7_linux_i386.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.7_windows_amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.7-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.7-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.7-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.7-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.7-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.7-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.7-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.7-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.6-static_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.6_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.6_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.6_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.6_linux_armel.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.6_linux_armhf.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.6_linux_i386.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.6_windows_amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.6-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.6-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.6-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.6-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.6-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.6-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.6-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.6-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.5-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.5-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.5-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.5-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.5-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.5-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.5-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.5-windows-amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5-static_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5_linux_armel.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5_linux_armhf.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5_linux_i386.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5_windows_amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5rc1-static_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5rc1_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5rc1_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5rc1_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5rc1_linux_armel.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5rc1_linux_armhf.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5rc1_linux_i386.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5rc1_windows_amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5rc0-static_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5rc0_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5rc0_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5rc0_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5rc0_linux_armel.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5rc0_linux_armhf.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5rc0_linux_i386.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.5rc0_windows_amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb-1.7.11-static_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.7.11_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.7.11_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.7.11_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.7.11_linux_armel.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.7.11_linux_armhf.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.7.11_linux_i386.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.7.11_windows_amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.4-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.4-darwin-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.4-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.4-linux-amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.4-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.0.4-linux-arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.4-static_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.4_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.4_linux_armel.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.4_linux_armhf.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.4_linux_i386.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.4_windows_amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.4_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.4_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.4_windows_amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.3_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2_client_2.0.3_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.3_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2_client_2.0.3_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.3_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb2_client_2.0.3_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.2_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.2_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.2_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.2_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.1_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.1_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.1_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.1_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.0_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.0_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.0-rc.4_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-rc.4_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.0-rc.4_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-rc.4_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.0-rc.3_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-rc.3_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.0-rc.3_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-rc.3_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.0-rc.3_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-rc.3_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.0-rc.2_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-rc.2_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.0-rc.2_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-rc.2_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.0-rc.2_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-rc.2_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.0-rc.1_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-rc.1_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.0-rc.1_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-rc.1_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.3-static_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.3_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.3_linux_armel.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.3_linux_armhf.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.3_linux_i386.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.3_windows_amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.3_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.3_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.3_windows_amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.0-rc.0_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-rc.0_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-2.0.0-rc.0_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-rc.0_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.2-static_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.2_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.2_linux_armel.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.2_linux_armhf.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.2_linux_i386.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.2_windows_amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.2_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.2_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.2_windows_amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.16_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-beta.16_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.16_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-beta.16_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.15_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-beta.15_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.15_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-beta.15_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.1-static_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.1_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.1_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.1_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.1_linux_armel.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.1_linux_armhf.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.1_linux_i386.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.1_windows_amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.14_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-beta.14_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.14_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-beta.14_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.13_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-beta.13_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.13_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-beta.13_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.13_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-beta.13_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.12_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-beta.12_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.12_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-beta.12_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.12_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_client_2.0.0-beta.12_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.10_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.10_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.10_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.9_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.9_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.9_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.0-static_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.0_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.0_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.0_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.0_linux_armel.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.0_linux_armhf.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.0_linux_i386.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb-1.8.0_windows_amd64.zip
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.8_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.8_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.8_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.7_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.7_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.7_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.6_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.6_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.6_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.5_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.5_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.5_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.4_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.4_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.4_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.3_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.3_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.3_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.2_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.2_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.2_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.1_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.1_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-beta.1_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.21_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.21_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.21_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.20_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.20_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.20_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.19_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.19_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.19_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.18_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.18_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.18_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.17_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.17_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.17_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.16_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.16_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.16_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.15_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.15_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.15_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.14_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.14_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.14_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.13_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.13_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.13_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.12_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.12_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.12_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.11_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.11_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.11_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.10_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.10_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.10_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.9_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.9_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.9_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.8_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.8_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.8_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.7_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.7_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.7_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.6_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.6_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.6_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.5_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.5_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.5_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.4_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.4_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.4_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.3_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.3_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.3_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.2_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.2_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.2_linux_arm64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.1_darwin_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.1_linux_amd64.tar.gz
https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.1_linux_arm64.tar.gz"
  url=$(echo "$downloadsList" | grep $extension | grep $grepFor)
  if [ "$INFLUXDB_VERSION" = latest ]; then
    influxServerDownload=$(echo "$url" | head -1)
  else
    influxServerDownload=$(echo "$url" | grep "$INFLUXDB_VERSION" | head -1)
  fi
  # echo "$influxServerDownload from $url"
fi

if [ -z "$influxServerDownload" ]; then
  influxVersionsList="$(curl --silent 'https://api.github.com/repos/influxdata/influxdb/releases')"
  if [ "$INFLUXDB_VERSION" = latest ]; then
    influxServerDownload=$(echo "$influxVersionsList" | jq -r '. | sort_by(.tag_name) | reverse[0] | .body' | grep "$extension" | grep -o '\(https[^\)]*\)' | grep "$grepFor") # Between ( and )
  else
    influxServerDownload=$(echo "$influxVersionsList" | jq -r ".|arrays[] | select( .tag_name==\"v$INFLUXDB_VERSION\" ) | .body" | grep "$extension" | grep -o '\(https[^\)]*\)' | grep "$grepFor") # Between ( and )
  fi

  if [ -z "$influxServerDownload" ]; then
    echo "Could not find download link for $INFLUXDB_VERSION."
    # echo "GitHub release body: $influxDbDownloadBody"
    # echo "from: $influxVersionsList"
    exit 121
  fi
fi


echo "The Server is downloading from: $influxServerDownload"
$fileDownload $influxServerDownload && echo "Downloaded $influxServerDownload" || echo "Failed download $influxServerDownload" 
$decompress ./*$extension
binary=$(find . -name "influxd${executable}" -type f)
if [ -n "$binary" -a -x "$binary" ]; then
  mv "$binary" ./bin/
  rm -r $(ls | grep -v bin)
else
  echo "The server is not found at \"$binary\", ls *: "
  ls *
  rm -r $(ls | grep -v bin)
  exit 123
fi

influxClientDownload=$(echo "$influxServerDownload" | sed 's/\/influxdb2/\/influxdb2-client/' | sed 's/_/-/g')
# Solve client inconsistencies
if [[ "$influxClientDownload" == *"2.7.6"* ]]; then
  influxClientDownload="https://download.influxdata.com/influxdb/releases/influxdb2-client-2.7.5-${osDownloadName}${arch}${extension}"
elif [[ "$influxClientDownload" == *"2.5.1"* ]]; then
  influxClientDownload="https://download.influxdata.com/influxdb/releases/influxdb2-client-2.5.0-${osDownloadName}${arch}${extension}"
elif [[ "$INFLUXDB_OS" = windows && "$influxClientDownload" != *"${arch}"* ]]; then
  influxClientDownload=$(echo "$influxClientDownload" | sed "s/.zip/${arch}.zip/")
fi
echo "The Client is downloading from: $influxClientDownload"
if ! ( $fileDownload $influxClientDownload ); then
  echo "Failed to get client $influxClientDownload"
  exit 120
fi
$decompress ./*$extension
binary=$(find . -name "influx${executable}" -type f)
if [ -n "$binary" -a -x "$binary" ]; then
  mv "$binary" ./bin/
  rm -r $(ls | grep -v bin)
else
  echo "The client is not found at \"$binary\", ls *: "
  ls *
  rm -r $(ls | grep -v bin)
  exit 123
fi

echo "${tempPath}/bin" >> $GITHUB_PATH

cd -
