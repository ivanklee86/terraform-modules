terraform {
  required_version = "~> 1.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CLOUDFLARE - Zones
# ---------------------------------------------------------------------------------------------------------------------

data "cloudflare_zones" "zone" {
  filter {
    name = var.domain_name
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CLOUDFLARE - Records
# ---------------------------------------------------------------------------------------------------------------------
resource "cloudflare_record" "main" {
  zone_id = data.cloudflare_zones.zone.zones[0].id
  name    = var.domain_name
  content = var.ip
  type    = "A"
  ttl     = var.ttl
  proxied = true
}

resource "cloudflare_record" "additional_records" {
  for_each = {
    for idx, record in var.additional_records : "${record.type}_${record.name}_${idx}" => record
  }

  zone_id = data.cloudflare_zones.zone.zones[0].id
  name    = each.value.name
  content = each.value.type == "A" ? var.ip : each.value.value
  type    = each.value.type
  proxied = each.value.proxied
  ttl     = each.value.ttl
}

resource "cloudflare_record" "additional_mx_records" {
  for_each = {
    for idx, record in var.additional_mx_records : "${record.name}_${idx}" => record
  }

  zone_id  = data.cloudflare_zones.zone.zones[0].id
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
resource "cloudflare_zone_settings_override" "zone_settings" {
  zone_id = data.cloudflare_zones.zone.zones[0].id
  settings {
    min_tls_version          = "1.2"
    tls_1_3                  = "on"
    automatic_https_rewrites = "on"
    ssl                      = "full"
  }
}
