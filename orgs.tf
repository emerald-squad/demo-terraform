#
# Grafana provider
#
provider "grafana" {
  url     = "http://localhost:3000"
  auth    = "admin:admin"
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
  managers     = ["admin"]
}
resource "cf_space" "spaces" {
  count      = "${length(var.orgs)}"
  org        = "${element(cf_org.orgs.*.id, count.index)}"
  name       = "dev"
  developers = [
    "${element(cf_user.users.*.id, count.index)}"
  ]
}

resource "random_string" "passwords" {
  count            = "${length(var.orgs)}"
  length           = 20
  special          = false
}

resource "cf_user" "users" {
  count    = "${length(var.orgs)}"
  name     = "${format("%s-ciuser",var.orgs[count.index])}"
  password = "${element(random_string.passwords.*.result, count.index)}"
}
  
#
# Provider Vault
#
provider "vault" {
}

resource "vault_mount" "secret" {
  path = "secret"
  type = "generic"
  description = "Demo mount"
}

resource "vault_generic_secret" "secrets" {
  count = "${length(var.orgs)}"
  path  = "${format("secret/%s-ciuser-password", var.orgs[count.index])}"
  data_json = <<EOT
{
  "value":   "${element(random_string.passwords.*.result, count.index)}"
}
EOT
}
