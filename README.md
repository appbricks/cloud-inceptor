# Cloud Automation Inception Tooling

## Overview

This project provide templates for building an secure inception environment for automating deployments via [Concourse](https://concourse.ci/) pipelines. The Terraform templates provided in the [`/templates/cloud`](templates/cloud) folder enable you to pave an inception environment with a bastion host that provides a secure mechanism to access the Virtual Private Cloud network via VPN. This host also doubles as the inception Concourse automation host which can run pipelines to build complex distributed cloud infrastructure.