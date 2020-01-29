#
# Grafana provider
#
provider "grafana" {
  url     = "http://localhost:3000"
  auth    = "admin:admin"
}

resource "grafana_data_source" "metrics" {
  type          = "influxdb"
  name          = "awesome_app_metrics"
  url           = "http://localhost:8086"
  database_name = influxdb_database.metrics.name
}

#
# InfluxDB provider
#
provider "influxdb" {
  url      = "http://localhost:8086"
}

resource "influxdb_database" "metrics" {
  name = "awesome_app"
}
