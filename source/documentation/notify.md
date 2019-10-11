## Accessing Metrics

Notify uses [Grafana](https://grafana.com/) for displaying metrics  and [Prometheus](https://prometheus.io/) for metric collection on its PaaS infrastructure. 

The RE-Team Manual has a section on [Prometheus For GDS PaaS Users](https://re-team-manual.cloudapps.digital/prometheus-for-gds-paas-users.html#content) which outlines the monitoring and alerting service for GDS PaaS tenants.

Notify also uses [CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html) metrics for its infrastructure components in AWS.

### Grafana dashboards

Accessing Notify's Grafana dashboards:

1. Navigate to PaaS's central Grafana account: [grafana-paas.cloudapps.digital](https://grafana-paas.cloudapps.digital).
2. Choose the "Sign in with Google" login option to authenticate via a GDS email account.
3. From the "Home Copy" dropdown, select "Notify" to view the available Notify dashboards.

Notify has three dashboards: 

- [Document Download](https://grafana-paas.cloudapps.digital/d/FwXIHjiiz)

- [Notify Apps](https://grafana-paas.cloudapps.digital/d/aCYK0WDik)

- [Postgres](https://grafana-paas.cloudapps.digital/d/SYlv1gAmz)


### CloudWatch dashboards

**Prerequisites: the [GDS CLI](https://github.com/alphagov/gds-cli) and [YubiKey](https://re-team-manual.cloudapps.digital/yubikeys.html#yubikeys) setup are required to access CloudWatch metrics.** 

Once GDS CLI and YubiKey configuration is set up, open a new terminal window and run:

```
$ gds aws <some-notify-service>
```

This command will prompt a sign-in process with the use of MFA stored on a YubiKey.

On successful sign in, a browser window will open on the Notify service CloudWatch landing page.

## Checking Logs

Notify uses [Kibana](https://www.elastic.co/products/kibana) for collecting application logs and CloudWatch for logs related to its AWS infrastructure.

System logs for infrastructure in PaaS can be accessed by creating a support ticket with the PaaS team.

### Kibana

Follow the RE Team Manual's ["Getting started with Logit"](https://reliability-engineering.cloudapps.digital/logging.html#content) instructions to access Kibana logs.

### CloudWatch

Follow the accessing [CloudWatch dashboards](#cloudwatch-dashboards) instructions.

## Testing SMS and Email

**Prerequisites: a Notify Admin account is required to test SMS and email notifications.**

Once SC clearance is passed, a member of the RE-Portfolio team will set up the necessary Notify Admin account. 

### Testing SMS:

1. Navigate to GOV.UK Notify's [notifications.service.gov.uk](https://www.notifications.service.gov.uk/sign-in).
2. Enter GDS email and account password to sign in.
3. On successful signin, the browser will redirect to the "Check your phone" page **and** an automatic SMS will be sent to the user.
4. Use the SMS code to complete the sign in process and verify SMS notifications work.

### Testing email

1. Navigate and sign in to [notifications.service.gov.uk](https://www.notifications.service.gov.uk/sign-in).
2. Choose the desired service to check.
3. From the sidebar, choose the "Templates" option.
4. Choose an email template from the list.
5. Click "Send".
6. Configure where the user's reply will arrive (e.g. govwifi-support) – this is often pre-populated in the template.
7. Configure the target email (where the email will be sent, e.g., your GDS email).
8. Preview and approve.
9. Check the target email account to verify an email has arrived.

## Rolling AMIs

Instructions for rolling AMIs can be found in the [notifications-aws repo](https://github.com/alphagov/notifications-aws).

Once changes have been made to the AMI, run the [Packer documentation instructions](https://github.com/alphagov/notifications-aws/blob/master/packer/README.md) and then the [Terraform documentation instructions](https://github.com/alphagov/notifications-aws/blob/master/terraform/README.md). 

These instructions will be automated by Concourse. 

## Running Ansible

Notify uses [Ansible](https://docs.ansible.com/) to configure Jenkins, create Packer images, and manage applications.

The notifications-aws Ansible [documentation](https://github.com/alphagov/notifications-aws/blob/master/ansible/README.md) contains instructions on how to run Ansible playbooks
