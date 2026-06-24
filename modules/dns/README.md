# DNS module

Shared Terraform module that delegates a **public** DNS zone and publishes bastion records through **AWS Route53**, **Google Cloud DNS**, or **Azure DNS**.

Use this when compute runs on a platform without a native DNS API (for example OpenStack/OVH) but public DNS should still be managed in an existing cloud DNS service. All record targets are supplied as module inputs; there is no private/split-horizon DNS and no cloud-network coupling (for example AWS VPC association).

## Usage

```hcl
module "dns" {
  source = "../../modules/dns"

  attach_dns_zone = true
  dns_provider    = "aws" # aws | google | azure

  vpc_name     = "inceptor-uk1"
  vpc_dns_zone = "test-uk1.ovh.appbricks.io"

  bastion_public_ip    = "203.0.113.10"
  bastion_admin_itf_ip = "172.20.65.253"

  bastion_host_name        = "inceptor"
  bastion_allow_public_ssh = true
  smtp_relay_host          = ""
}
```

Configure the provider matching `dns_provider` in the root module (credentials, region/project, and so on). Resources for other providers are not created.

## Inputs

| Name | Description |
|------|-------------|
| `attach_dns_zone` | Enable DNS management (default `false`). |
| `dns_provider` | `aws`, `google`, `azure`, or empty to skip. |
| `vpc_name` | Tag/name metadata for the delegated zone. |
| `vpc_dns_zone` | FQDN of the child zone (no trailing dot). |
| `bastion_public_ip` | Public A record target (floating IP). |
| `bastion_admin_itf_ip` | Admin interface IP for mail/admin records. |
| `bastion_host_name` | Optional admin host label in the public zone. |
| `bastion_allow_public_ssh` | When true, admin A record is skipped. |
| `smtp_relay_host` | When set, creates mail/MX/TXT records. |
| `parent_dns_zone_name` | Parent zone for NS delegation (defaults from `vpc_dns_zone`). |
| `azure_resource_group` | Azure resource group for parent and delegated DNS zones. |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_dns_public_zone_id` | Public zone ID in the selected provider. |
| `vpc_dns_public_zone_name` | Delegated zone FQDN. |
| `vpc_dns_private_zone_id` | Always empty (public DNS only). |
| `vpc_dns_private_zone_name` | Always empty (public DNS only). |
| `bastion_fqdn` | `vpc_dns_zone` when enabled, otherwise `bastion_public_ip`. |

## OpenStack integration

The OpenStack bootstrap module calls this module when both `attach_dns_zone = true` and `dns_provider` is set. See `modules/bootstrap/openstack/dns.tf` and `examples/inceptor/openstack/`.

## Notes

- Internal `.local` zones remain on PowerDNS inside the bastion; this module only manages the external public zone.
- Record layouts mirror the public-DNS portions of the existing AWS, Google, and Azure bootstrap modules.
