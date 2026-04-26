mock_provider "cloudflare" {
  mock_data "cloudflare_zones" {
    defaults = {
      zones = [
        {
          id   = "mock-zone-id-abc123"
          name = "example.com"
        }
      ]
    }
  }
}

variables {
  domain_name = "example.com"
  ip          = "1.2.3.4"
}

run "minimal_apex_record" {
  command = plan

  assert {
    condition     = cloudflare_record.main.type == "A"
    error_message = "Apex record must be type A"
  }

  assert {
    condition     = cloudflare_record.main.content == "1.2.3.4"
    error_message = "Apex record must use var.ip"
  }

  assert {
    condition     = cloudflare_record.main.proxied == true
    error_message = "Apex record must be proxied"
  }

  assert {
    condition     = length(cloudflare_record.additional_records) == 0
    error_message = "No additional records should exist with default variables"
  }

  assert {
    condition     = length(cloudflare_record.additional_mx_records) == 0
    error_message = "No MX records should exist with default variables"
  }
}

run "additional_a_record_uses_ip_not_value_field" {
  command = plan

  variables {
    additional_records = [
      {
        type    = "A"
        name    = "whoami"
        value   = "9.9.9.9"
        proxied = true
        ttl     = 1
      }
    ]
  }

  assert {
    condition     = cloudflare_record.additional_records["A_whoami_0"].content == var.ip
    error_message = "Additional A records must use var.ip, not the value field in the record definition"
  }
}

run "additional_non_a_record_uses_own_value" {
  command = plan

  variables {
    additional_records = [
      {
        type    = "CNAME"
        name    = "www"
        value   = "target.example.com"
        proxied = true
        ttl     = 1
      }
    ]
  }

  assert {
    condition     = cloudflare_record.additional_records["CNAME_www_0"].content == "target.example.com"
    error_message = "Non-A records must use the record's own value field"
  }
}

run "mx_records_have_correct_type_and_priority" {
  command = plan

  variables {
    additional_mx_records = [
      {
        name     = "example.com"
        value    = "mail.example.com"
        proxied  = false
        ttl      = 600
        priority = 10
      }
    ]
  }

  assert {
    condition     = cloudflare_record.additional_mx_records["example.com_0"].type == "MX"
    error_message = "MX records must have type MX"
  }

  assert {
    condition     = cloudflare_record.additional_mx_records["example.com_0"].priority == 10
    error_message = "MX record priority must match input"
  }
}

run "zone_settings_hardened" {
  command = plan

  assert {
    condition     = cloudflare_zone_settings_override.zone_settings.settings[0].min_tls_version == "1.2"
    error_message = "Zone must require TLS 1.2 minimum"
  }

  assert {
    condition     = cloudflare_zone_settings_override.zone_settings.settings[0].tls_1_3 == "on"
    error_message = "Zone must have TLS 1.3 enabled"
  }

  assert {
    condition     = cloudflare_zone_settings_override.zone_settings.settings[0].ssl == "full"
    error_message = "Zone must use full SSL mode"
  }

  assert {
    condition     = cloudflare_zone_settings_override.zone_settings.settings[0].automatic_https_rewrites == "on"
    error_message = "Zone must have automatic HTTPS rewrites enabled"
  }
}
