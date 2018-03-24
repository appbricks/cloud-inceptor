# Cloud Automation Inception Tooling

## Overview

This project provide templates for building a secured inception environment for automating deployments using [Terraform](https://www.terraform.io/) templates and [Concourse](https://concourse-ci.org/) pipelines. The Terraform templates provided in the [`modules`](modules) folder enable you to pave an inception environment with a bastion host that provides a secure mechanism to access the Virtual Private Cloud network via VPN. This host also doubles as the inception Concourse automation host which can run pipelines to build distributed cloud infrastructure.