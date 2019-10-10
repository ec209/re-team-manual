This document will serve as a quick reference for people on the Automate
interruptible or on-call rotas. It often links to external resources for more
detail and context.

## Interruptible routines

A few things to do as part of the interruptible routine:

1. Update the document that is linked from the #re-autom8 channel topic with
   that week's (or day's) interruptible person
1. Update the topic in #reliabily-eng with that week's (or day's) interruptible
   person

## GOV.UK Verify

Team manual:
[https://verify-team-manual.cloudapps.digital/](https://verify-team-manual.cloudapps.digital/)

### Hub

#### On call

Only escalations from the Verify primary on-call team apply; Alertmanager won't
directly page reliability engineering. On occasion it may also be the result of
a cyber security escalation.

[Concourse](https://deployer.tools.signin.service.gov.uk/teams/main/pipelines/deploy-verify-hub)
deploys the Hub to ECS (one cluster per application) on EC2 (i.e. not ECS on
Fargate). Reliability engineering only offer out-of-hours support for the
production services. Some useful links:

* [verify-infrastructure
  repository](https://github.com/alphagov/verify-infrastructure)
* [verify-infrastructure-config
  repository](https://github.com/alphagov/verify-infrastructure-config)
* [verify-terraform repository](https://github.com/alphagov/verify-terraform)
* [environment
  links](https://verify-team-manual.cloudapps.digital/documentation/support/second-line/environment-links.html)

Relevant gds-cli aws account names:

* verify-prod-a
* verify-tools

#### Interruptible

Reliability engineers may also need to respond in hours to issues and incidents
in non-production environments. Examples:

* problems deploying the application to non-production environments (such as
  integration or staging)
* machine reboots (prometheus only; all other non-tools environment machines are
  routinely rebuilt by
  [concourse](https://deployer.tools.signin.service.gov.uk/teams/main/pipelines/deploy-verify-hub?group=instance-rolling))

Some useful links:

* [Verify concourse](https://deployer.tools.signin.service.gov.uk)
* [smoke
  tests](https://deployer.tools.signin.service.gov.uk/teams/main/pipelines/smoketests)

Relevant gds-cli aws account names:

* verify-staging
* verify-integration-a

### DCS

#### On call

The Document Checking Service runs in UKCloud and Carrenza with puppet managing
the software. As with Hub, reliability engineering are not part of the primary
on call flow and so will only be called on if necessary as part of an
escalation.

The most common action out of hours activity for DCS is a [DNS-based failover
from one provider to the
other](https://re-team-manual.cloudapps.digital/verify.html#dns-changes).


Some useful links:

* [verify-boxes repository](https://github.com/alphagov/verify-boxes)
* [verify-puppet repository](https://github.com/alphagov/verify-puppet)
* [verify-ansible repository](https://github.com/alphagov/verify-ansible)
* [doc-checking repository](https://github.com/alphagov/doc-checking)
* [UKCloud IL2 portal](https://portal.skyscapecloud.com/login)
* [UKCloud IL3 portal](https://portal.skyscapecloud.gsi.gov.uk/login)
* [Carrenza portal (low side)](https://vcloud.carrenza.com/cloud/org/62xq)
* [Carrenza portal (high side)](https://vcloud.carrenza.com/cloud/org/62xq-P)
* [Carrenza VPN
  access](https://github.com/alphagov/verify-puppet/wiki/Carrenza-Login-&-New-User-Information#vpn-access)
* [Carrenza support portal](https://6dg.service-now.com/)
* [DCS grafana
  dashboard](https://grafana.tools.signin.service.gov.uk/d/yOz9AKRZk/dcs-ukc-and-cr?orgId=1&var-Graphite=All)
* [Additional DCS support
  docs](https://verify-team-manual.cloudapps.digital/documentation/support/#dcs)

#### Interruptible

The most common task are the [UKCloud and Carrenza machine
reboots](https://verify-team-manual.cloudapps.digital/documentation/support/dcs/rolling-reboots.html).
Other notable items include available disk space on packages-1, sensu alerts
(both low-side and high-side) and other general escalations from the yak team or
the Verify devs.

Useful links:

* [verify-ansible repository](https://github.com/alphagov/verify-ansible)
* [verify-dashing repository](https://github.com/alphagov/verify-dashing)

### Proxy Node

#### On call

The proxy node is part of the eIDAS framework. It is deployed to the GSP on the
Verify cluster by the [in-cluster
concourse](https://ci.london.verify.govsvc.uk/teams/proxy-node-prod/pipelines/deploy).

At the time of writing, the proxy node is not supported out of hours, except for
one scenario: a security issue severe enough to warrant the invocation of the
[kill
switch](https://ci.london.verify.govsvc.uk/teams/proxy-node-prod/pipelines/killswitch).

### Dev infrastructure

#### Interruptible

Other "misc" infrastructure for Verify is supported in-hours:

* AWS tools environment which includes concourse, motomo, dash etc.
* UKCloud components such as artifactory and jenkins

Relevant gds-cli aws account names:

* verify-tools

## Observe

### Alertmanager

#### On call

The Observe Alertmanager deployment is used by several programme's services to
route alerts to other systems like PagerDuty. It is part of Observe's Prometheus
service. Alertmanager is deployed to ECS Fargate by
[concourse](https://cd.gds-reliability.engineering/teams/autom8/pipelines/prometheus).
Alertmanager instances are clustered together to handle (among other things)
deduplication of downstream alerting (each prometheus instance sends alerts to
all the Alertmanager instances).

The most probable source of any kind of event will be cronitor.

* [alerts-1](https://alerts-1.monitoring.gds-reliability.engineering/)
* [alerts-2](https://alerts-2.monitoring.gds-reliability.engineering/)
* [alerts-3](https://alerts-3.monitoring.gds-reliability.engineering/)
* [prometheus-aws-configuration-beta
  repository](https://github.com/alphagov/prometheus-aws-configuration-beta)
* [main
  article](https://re-team-manual.cloudapps.digital/prometheus-for-gds-paas-users.html)

Relevant gds-cli account names:

* re-prom-prod

#### Interruptible

In addition to Alertmanager, the Prometheus instances need to be managed
in-hours. The most common incident involving the Oberve prometheus instances is
related to the PaaS service broker not removing deleted PaaS apps from its S3
store, causing prometheus to alert on instances being down.

Main article: [Prometheus for GDS PaaS
Service](https://re-team-manual.cloudapps.digital/prometheus-for-gds-paas-users.html)

Useful links:

* [re-secrets repository](https://github.com/alphagov/re-secrets)
* [service broker repository](https://github.com/alphagov/cf_app_discovery)
* [grafana](https://grafana-paas.cloudapps.digital/)

Relevant gds-cli account names:

* re-prom-staging

## Cyber security escalations

### On call

Cyber security may escalate to reliability engineering out of hours for a number
of reasons. Possible candidates:

* proxy node or connector metadata CloudHSM communications look suspicious
* certain AWS account access out-of-hours (such as admin)
* some GSP cluster access patterns out-of-hours

Useful links:

* [GSP documentation](https://github.com/alphagov/gsp/tree/master/docs)

Relevant gds-cli targets:

* gsp-verify (for AWS)
* verify (for `kubectl` & other GSP-related actions)

#### Interruptible

TODO

## Performance Platform

Performance Platform is supported best effort, in-hours only.

### Interruptible

Main article: [Performance
Platform](https://re-team-manual.cloudapps.digital/performance-platform.html)

## Multi-tenant concourse

Terraform applied manually from the
[tech-ops-private](https://github.com/alphagov/tech-ops-private/tree/master/reliability-engineering/terraform/deployments/gds-tech-ops/cd)
repository.

Useful links:

* [Multi-tenant concourse](https://cd.gds-reliability.engineering/)
* [tech-ops repository](https://github.com/alphagov/tech-ops)
* [tech-ops-private repository](https://github.com/alphagov/tech-ops-private)

Relevant gds-cli account names:

* techops

## New AWS account users

### Interruptible

Main article: [GDS AWS Account Management
Service](https://re-team-manual.cloudapps.digital/gds-aws-account-management-service.html)
