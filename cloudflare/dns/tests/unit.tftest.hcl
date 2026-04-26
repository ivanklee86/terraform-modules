mock_provider "cloudflare" {
  mock_data "cloudflare_zones" {
    defaults = {
      result = [
        {
          id                    = "mock-zone-id-abc123"
          name                  = "example.com"
          status                = "active"
          type                  = "full"
          paused                = false
          development_mode      = 0
          activated_on          = "2024-01-01T00:00:00Z"
          created_on            = "2024-01-01T00:00:00Z"
          modified_on           = "2024-01-01T00:00:00Z"
          cname_suffix          = ""
          original_dnshost      = ""
          original_registrar    = ""
          verification_key      = ""
          name_servers          = []
          original_name_servers = []
          vanity_name_servers   = []
          permissions           = []
          account = {
            id   = "mock-account-id"
            name = "mock-account"
          }
          meta = {
            cdn_only                 = false
            custom_certificate_quota = 0
            dns_only                 = false
            foundation_dns           = false
            page_rule_quota          = 3
            phishing_detected        = false
            step                     = 0
          }
          owner = {
            id   = "mock-owner-id"
            name = "mock-owner"
            type = "user"
          }
          plan = {
            can_subscribe      = false
            currency           = "USD"
            externally_managed = false
            frequency          = ""
            id                 = "free"
            is_subscribed      = true
            legacy_discount    = false
            legacy_id          = "free"
            name               = "Free Website"
            price              = 0
          }
          tenant      = { id = "", name = "" }
          tenant_unit = { id = "" }
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
    condition     = cloudflare_dns_record.main.type == "A"
    error_message = "Apex record must be type A"
  }

  assert {
    condition     = cloudflare_dns_record.main.content == "1.2.3.4"
    error_message = "Apex record must use var.ip"
  }

  assert {
    condition     = cloudflare_dns_record.main.proxied == true
    error_message = "Apex record must be proxied"
  }

  assert {
    condition     = length(cloudflare_dns_record.additional_records) == 0
    error_message = "No additional records should exist with default variables"
  }

  assert {
    condition     = length(cloudflare_dns_record.additional_mx_records) == 0
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
    condition     = cloudflare_dns_record.additional_records["A_whoami_0"].content == var.ip
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
    condition     = cloudflare_dns_record.additional_records["CNAME_www_0"].content == "target.example.com"
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
    condition     = cloudflare_dns_record.additional_mx_records["example.com_0"].type == "MX"
    error_message = "MX records must have type MX"
  }

  assert {
    condition     = cloudflare_dns_record.additional_mx_records["example.com_0"].priority == 10
    error_message = "MX record priority must match input"
  }
}

run "zone_settings_hardened" {
  command = plan

  assert {
    condition     = cloudflare_zone_setting.min_tls_version.value == "1.2"
    error_message = "Zone must require TLS 1.2 minimum"
  }

  assert {
    condition     = cloudflare_zone_setting.tls_1_3.value == "on"
    error_message = "Zone must have TLS 1.3 enabled"
  }

  assert {
    condition     = cloudflare_zone_setting.ssl.value == "full"
    error_message = "Zone must use full SSL mode"
  }

  assert {
    condition     = cloudflare_zone_setting.automatic_https_rewrites.value == "on"
    error_message = "Zone must have automatic HTTPS rewrites enabled"
  }
}
