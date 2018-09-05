#
# Grafana provider
#
provider "grafana" {
  url     = "http://localhost:3000"
  auth    = "admin:admin"
  version = "~> 1.2"
}

resource "grafana_organization" "org" {
  count        = "${length(var.orgs)}"
  name         = "${var.orgs[count.index]}"
  admin_user   = "admin"
}

#
# CF provider
#
provider "cf" {
  api_url             = "https://api.local.pcfdev.io"
  user                = "admin"
  password            = "admin"
  uaa_client_id       = "admin"
  uaa_client_secret   = "admin-client-secret"
  skip_ssl_validation = true
}
resource "cf_org" "orgs" {
  count        = "${length(var.orgs)}"
  name         = "${var.orgs[count.index]}"
  managers = ["admin"]
}
resource "cf_space" "spaces" {
  count = "${length(var.orgs)}"
  org   = "${element(cf_org.orgs.*.id, count.index)}"
  name  = "dev"
  developers = [
    "${element(cf_user.users.*.id, count.index)}"
  ]
}

resource "random_string" "passwords" {
  count = "${length(var.orgs)}"
  length = 16
  special = true
  override_special = "/@\" "
}

resource "cf_user" "users" {
  count = "${length(var.orgs)}"
  name = "${format("%s-ciuser",var.orgs[count.index])}"
  password = "${element(random_string.passwords.*.result, count.index)}"
}
  
