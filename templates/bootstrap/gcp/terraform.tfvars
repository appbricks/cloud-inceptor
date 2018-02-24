#
# Company information used in certificate creation
#
company_name = "appbricks"

organization_name = "appbricks dev"

locality = "Boston"

province = "MA"

country = "US"

#
# VPC details
#
region = "europe-west4"

vpc_name = "inceptor"

# DNS Name for VPC will be 'test.gcp.appbricks.cloud'
vpc_dns_zone = "test.gcp.appbricks.cloud"

# Name of parent zone 'gcp.appbricks.cloud' to which the 
# name server records of the 'vpc_dns_zone' will be added.
dns_managed_zone_name = "gcp-appbricks-cloud"

#
# Bootstrap pipeline
#
bootstrap_pipeline_file = "../../../pipelines/bootstrap-hello-world/pipeline.yml"
