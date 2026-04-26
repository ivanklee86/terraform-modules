<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 5.19.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudflare_dns_record.additional_mx_records](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_dns_record.additional_records](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_dns_record.main](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_zone_setting.automatic_https_rewrites](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone_setting) | resource |
| [cloudflare_zone_setting.min_tls_version](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone_setting) | resource |
| [cloudflare_zone_setting.ssl](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone_setting) | resource |
| [cloudflare_zone_setting.tls_1_3](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone_setting) | resource |
| [cloudflare_zones.zone](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_mx_records"></a> [additional\_mx\_records](#input\_additional\_mx\_records) | Additional MX DNS records to configure. | <pre>list(<br/>    object({<br/>      name     = string<br/>      value    = string<br/>      proxied  = bool<br/>      ttl      = number<br/>      priority = number<br/>    })<br/>  )</pre> | `[]` | no |
| <a name="input_additional_records"></a> [additional\_records](#input\_additional\_records) | Additional generic DNS records to configure. | <pre>list(<br/>    object({<br/>      type    = string<br/>      name    = string<br/>      value   = string<br/>      proxied = bool<br/>      ttl     = number<br/>    })<br/>  )</pre> | `[]` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name to modify. | `string` | n/a | yes |
| <a name="input_ip"></a> [ip](#input\_ip) | IP address. | `string` | n/a | yes |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | TTL for DNS record. | `number` | `600` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
