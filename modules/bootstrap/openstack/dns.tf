#
# Public DNS zones are not managed by this module on OpenStack/OVH.
# Configure NS delegation and A records for var.vpc_dns_zone manually,
# or extend this module when a provider DNS API is available.
#
# Internal names are served by PowerDNS on the bastion (see bastion-config).
#
