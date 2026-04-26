terraform {
  required_version = "~> 1.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CLOUDFLARE - Zones
# ---------------------------------------------------------------------------------------------------------------------

data "cloudflare_zones" "zone" {
  name = var.domain_name
}

# ---------------------------------------------------------------------------------------------------------------------
# CLOUDFLARE - Records
# ---------------------------------------------------------------------------------------------------------------------
resource "cloudflare_dns_record" "main" {
  zone_id = data.cloudflare_zones.zone.result[0].id
  name    = var.domain_name
  content = var.ip
  type    = "A"
  ttl     = var.ttl
  proxied = true
}

resource "cloudflare_dns_record" "additional_records" {
  for_each = {
    for idx, record in var.additional_records : "${record.type}_${record.name}_${idx}" => record
  }

  zone_id = data.cloudflare_zones.zone.result[0].id
  name    = "${each.value.name}.${var.domain_name}"
  content = each.value.type == "A" ? var.ip : each.value.value
  type    = each.value.type
  proxied = each.value.proxied
  ttl     = each.value.ttl
}

resource "cloudflare_dns_record" "additional_mx_records" {
  for_each = {
    for idx, record in var.additional_mx_records : "${record.name}_${idx}" => record
  }

  zone_id  = data.cloudflare_zones.zone.result[0].id
  name     = each.value.name
  content  = each.value.value
  type     = "MX"
  proxied  = each.value.proxied
  ttl      = each.value.ttl
  priority = each.value.priority
}

# ---------------------------------------------------------------------------------------------------------------------
# CLOUDFLARE - Configuration
# ---------------------------------------------------------------------------------------------------------------------
resource "cloudflare_zone_setting" "min_tls_version" {
  zone_id    = data.cloudflare_zones.zone.result[0].id
  setting_id = "min_tls_version"
  value      = "1.2"
}

resource "cloudflare_zone_setting" "tls_1_3" {
  zone_id    = data.cloudflare_zones.zone.result[0].id
  setting_id = "tls13"
  value      = "on"
}

resource "cloudflare_zone_setting" "automatic_https_rewrites" {
  zone_id    = data.cloudflare_zones.zone.result[0].id
  setting_id = "automatic_https_rewrites"
  value      = "on"
}

resource "cloudflare_zone_setting" "ssl" {
  zone_id    = data.cloudflare_zones.zone.result[0].id
  setting_id = "ssl"
  value      = "full"
}
