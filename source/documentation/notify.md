## Accessing Metrics

Notify uses [Grafana](https://grafana.com/) for displaying metrics  and [Prometheus](https://prometheus.io/) for metric collection on its PaaS infrastructure. 

The RE-Team Manual has a section on [Prometheus For GDS PaaS Users](https://re-team-manual.cloudapps.digital/prometheus-for-gds-paas-users.html#content) which outlines the monitoring and alerting service for GDS PaaS tenants.

Notify also uses [CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html) metrics for its infrastructure components in AWS.

### Grafana

Accessing Notify's Grafana dashboards:

1. Navigate to PaaS's central Grafana account: [grafana-paas.cloudapps.digital](https://grafana-paas.cloudapps.digital).
2. Choose the "Sign in with Google" login option to authenticate via a GDS email account.
3. From the "Home Copy" dropdown, select "Notify" to view the available Notify dashboards.

Notify has three dashboards: 

- [Document Download](https://grafana-paas.cloudapps.digital/d/FwXIHjiiz)

- [Notify Apps](https://grafana-paas.cloudapps.digital/d/aCYK0WDik)

- [Postgres](https://grafana-paas.cloudapps.digital/d/SYlv1gAmz)


### CloudWatch

**The GDS CLI and [YubiKey](https://re-team-manual.cloudapps.digital/yubikeys.html#yubikeys) setup are required to access CloudWatch metrics.** 

Once GDS CLI and YubiKey configuration is set up, open a new terminal window and run:

```
$ gds aws <some-notify-service>
```

This command will prompt a GPG key sign-in process.

On successful sign in, a browser window will open on the Notify service CloudWatch landing page.

## Checking Logs

## Testing SMS and Email

## Rolling AMIs

## Running Ansible

## Using CloudFoundary