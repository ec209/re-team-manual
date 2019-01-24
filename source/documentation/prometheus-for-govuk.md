"**From metrics to insight**" read up on that catchy phrase and more at [prometheus.io](https://prometheus.io)

Simply put, Prometheus lets us see and respond to things that happen on the computers we look after.

## Purpose
Prometheus is a flexible monitoring system that other teams across GDS use. Implementation can be on a small or large scale, simple or complex. All of this makes it a good choice to get monitoring in place quickly.

Some of this has been written about on the [GDS Technology Blog](https://gdstechnology.blog.gov.uk/2018/11/09/building-testing-and-iterating-our-monitoring-and-alerting-service/) and in other documentation [e.g. monitoring Data GOV UK](https://docs.publishing.service.gov.uk/manual/data-gov-uk-monitoring.html).

### Tell me more...
Prometheus uses a client/server pull model to collect time series data. The Prometheus server will pull data from each configured node or exporter. This data can then be used in a number of ways.

Various configurations are possible but at it's most simple the "Prometheus monitoring server" can be installed and can collect metrics from itself.

In more complex configurations multiple exporters can be setup for the server to pull data from, "Alertmanager" can be used for push alerting and data can be exported and visualised by, for example, Grafana. [See diagram and more from prometheus.io](https://prometheus.io/docs/introduction/overview/)

## Keepers
At GDS, Reliability Engineering (_slack #reliability-eng_) is the best place to start. Some teams will be better suited to help with specific questions depending on the implementation and what needs to be done. Any code is generally "owned" by a specific team that has implemented it.

There's a public community supporting the software and more information can be found at [Prometheus.io Community](https://prometheus.io/community).

There's also a [London Prometheus Meetup](https://www.meetup.com/Prometheus-London/) that GDS has helped organise and has given talks at (there's often free pizza and drinks!).

## Learning
A good start is [prometheus.io](https://prometheus.io). [note: If you find good reading please add it to this page!]

Of course you should read this guide if interested in GOV.UK implementation and say hello to Reliability Engineering (_slack #reliability-eng_) if you have any questions.


## Prometheus Implementation for GOV.UK 
How do I read, run and change the code?

### Read it
**Git Hub Repositories**

```
alphagov/govuk-aws
alphagov/govuk-aws-data
alphagov/govuk-dns-config
alphagov/govuk-puppet
alphagov/packager
```

**alphagov/govuk-aws**

Code for`terraform/projects/app-prometheus` creates:
* a "node" using the`node_group` module
* an EBS volume
* an IAM role and policy for prometheus

Code for `terraform/projects/infra-security-groups` creates:
* security groups for access control

Code for `terraform/projects/infra-public-services` creates:
* an "LB" using the `lb` module
* the Auto-Scaling Group data and attachment
* route 53 records

**alphagov/govuk-aws-data**

Puppet data used by `app-prometheus` (subnets) and `infra-public-services` (service name).

**alphagov/govuk-dns-config**

DNS setup for `publishing.service.gov.uk` CNAME records, using `govuk.digital` data for the different environments the prometheus server is deployed to.

**alphagov/govuk-puppet**

Code for `govuk_prometheus_node_exporter` sets the `apt::source`, installs and configures the software, permits inbound `9080` port access and sets up an `icinga::check`.

Code for `govuk_prometheus`, sets the `apt::source`, installs and configures the software (including nginx), and sets up an `icinga::check`.

Existing code was modified to include the modules where needed and also add a new `govuk::node` for prometheus. The `apt_mirror_hostname` for both packages is included in the hieradata.

**alphagov/packager**

FPM recipes for `prometheus` & `prometheus-node-exporter` can be found here.

The Jenkins job [documented](https://docs.publishing.service.gov.uk/manual/debian-packaging.html#creating-packages) fails ([see here](https://ci.integration.publishing.service.gov.uk/job/build_fpm_package/)). Instead, a manual process similar to what was documented was used to create and distribute the packages to the aptly mirrors.

Requires the `aptly::repo` puppet resource



### Run it
1. Package the prometheus software
    * see `alphagov/packager` repo
1. Get package onto mirrors for distribution
    * follow steps in [GOV.UK docs](https://docs.publishing.service.gov.uk/manual/debian-packaging.html#creating-packages)
    * manual steps might be needed
1. [Run terraform](https://ci-deploy.integration.publishing.service.gov.uk/job/Deploy_Terraform_GOVUK_AWS/) to create infrastructure
    * deploy `govuk` `infra-security-groups`
    * deploy `govuk` `infra-public-services`
    * deploy `blue` `app-prometheus`
1. [Deploy puppet](https://docs.publishing.service.gov.uk/manual/deploy-puppet.html#header) to complete configuration
    * autodeployment to integration
    * check [puppet deployment status](https://release.publishing.service.gov.uk/applications/puppet)  in staging and production
1. [Configure](https://github.com/alphagov/govuk-dns-config) & [Deploy DNS](https://deploy.publishing.service.gov.uk/job/Deploy_DNS/)



### Change it
* what to set up
    * access
        * to aws
        * to the required github repos
        * to [getting started on GOV.UK](https://docs.publishing.service.gov.uk/manual/get-started.html)
    * testing
        * solo - could be a VM or aws instance, make sure it's appropriate, the correct distribution/OS/ami is a good start.
        * together - there are shared or common [GOV.UK environments](https://docs.publishing.service.gov.uk/manual/environments.html#header). Know the users of each and how to notify them of changes. Integration is often exposed to _breaking_ changes but that can still impact a large number of people who don't expect it.
    * software
        * all the brew installs and downloads
        * the existing code base


* what to build
    * build the software packages
    * `brew install all_the_things` _(please check individual repos for specifics)_


* how to test
    * check you can browse to the package on the aptly mirrors, https://apt.publishing.service.gov.uk/
    * use `dpkg -l` to list all software on a host and confirm package is installed
    * check the config files
        * `/etc/prometheus/prometheus.yml` - to confirm details expected for the server, e.g.`scrape_configs` and ec2 discovery
        * `/etc/init/node-exporter.conf` - to confirm details expected for the node exporter
    * check the AWS Console to confirm resources have been created by terraform
    * check ports are listening on clients
        * ssh onto a host and `curl localhost:9080/metrics`
        * check connectivity between hosts, e.g. `a_host$ curl http://<b_host>:9080/metrics`
    * check access to the load balancer
        * from a browser: `https://prometheus.<integration|staging|production>.govuk.digital`
        * check the health of the targets in the AWS Console
    * raise a `govuk-puppet` PR and check the tests in [CI govuk-puppet](https://ci.integration.publishing.service.gov.uk/job/govuk-puppet/)
     * check other related [CI Jobs](https://ci.integration.publishing.service.gov.uk/) for errors
     * check [GOV.UK Icinga Alerting](https://docs.publishing.service.gov.uk/manual/tools.html#icinga) for errors

* how to deploy it
    * always run changes through integration before progressing them onto staging and production
    * talk in govuk and reliability engineering slack channels about testing
    * get PRs raised and peer reviewed for your changes
    * run the [terraform job](https://ci-deploy.integration.publishing.service.gov.uk/job/Deploy_Terraform_GOVUK_AWS/) with a `plan`. Check the output, then run the `apply`
    * run the `Deploy_Puppet` [jenkins jobs](https://docs.publishing.service.gov.uk/manual/deploy-puppet.html#header)
    * check [GOV.UK Icinga Alerts](https://docs.publishing.service.gov.uk/manual/tools.html#icinga) after deploying


# 
> Note: the format of these docs has been inspired by the "Language System API" section of https://github.com/saiaps/language-system-api
