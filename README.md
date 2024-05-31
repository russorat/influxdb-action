# InfluxDB Action

This action downloads, installs, and configures an InfluxDB OSS instance and CLI tooling that can be used in your automation.

This downloads the specified version (or `latest` or `nightly`), and adds `influxd` and `influx` commands to `${GITHUB_PATH}`.

# Usage

See [action.yml](action.yml)

### Setup and configure InfluxDB and CLI Tools
```yaml
steps:
  - name: Check out repo
    uses: actions/checkout@v2
  - name: Setup InfluxDB
    uses: influxdata/influxdb-action@v3
    with:
      influxdb_version: latest
      influxdb_org: influxdata
      influxdb_user: ci_user
      influxdb_password: password
      influxdb_bucket: dummy
```

### Install but don't start InfluxDB (influx CLI Tooling Only)
```yaml
steps:
  - name: Check out repo
    uses: actions/checkout@v2
  - name: Setup InfluxDB
    uses: influxdata/influxdb-action@v3
    with:
      influxdb_version: latest
      influxdb_start: false
```

### Use a specific version of InfluxDB
```yaml
steps:
  - name: Check out repo
    uses: actions/checkout@v2
  - name: Setup InfluxDB
    uses: influxdata/influxdb-action@v3
    with:
      influxdb_version: 2.0.7
      influxdb_org: influxdata
      influxdb_user: ci_user
      influxdb_password: password
      influxdb_bucket: dummy
      influxdb_token: apitoken
```
