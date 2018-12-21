## Prometheus for PaaS interruptible support

Automate operate a Prometheus service for PaaS tenants, and are responsible for the ongoing business as usual Logit tasks.

### Support availability

The automate team are offering an in work hours support, this is currently 9am - 6pm, Monday to Fridays. Any issues out of hours will be recorded and handled during work hours.

### Interruptible tasks related to Prometheus for PaaS
- Keep interruptible Documentation Up To Date
- Respond to PagerDuty alerts
- Support users on the `#re-prometheus-support` and `#reliability-eng` slack channels
- Report any problems on the `#re-prometheus-support` and `#reliability-eng` slack channels with regular updates
- Check emails for Pingdom notifications
- Check emails for Logit and PagerDuty status updates
- Check on the status of the Prometheus service
- Check [Zendesk queue](https://govuk.zendesk.com/agent/dashboard) for tickets
- Triage issues and bugs
- Initiate the [incident process](#incident-process)

#### Keep Interruptible Documentation Up To Date

Observe interruptible is a new responsibility, we are attempting to document the interruptible process however we expect there to be gaps, one of the primary responsibilities will be to keep this documentation up to date as this role evolves.

#### Respond to PagerDuty alerts

PagerDuty is configured to ring the Interruptible phone when an alert is triggered. PagerDuty alerts should be acknowledged and investigated.

#### Support users on the `#re-prometheus-support` and `#reliability-eng` slack channels

Users of the monitoring service can request help on the `#re-prometheus-support` and `#reliability-eng` slack channels, as interruptible you should be monitoring the channel and engage with users.

- help solve the users problem if it is simple
- [triage](#triage-process) the users problem if it is an issue or bug
- keep the user updated with progress

#### Check emails for Pingdom notifications

- check that each prometheus and alert managers endpoints are reachable.
- if not then check if there are any reported issues on PagerDuty and raise one if not and follow the [triage process](#triage-process).

#### Check emails for Logit and PagerDuty status updates
- inform `#reliability-eng` on slack and send something in the reliability engineering announce email group

#### Check on the status of the Prometheus service

- Periodically
  - Monitor the Prometheus benchmark (beta) dashboard on Grafana
  - Check the Prometheus targets on the active Prometheus dashboard

#### Triage issues and bugs

The monitoring service is still under development therefore it is possible that you can come across problems with the service. If you spot what you believe to be an issue or bug then investigate following the [triage process](#triage-process).

### Triage Process
One of the goals is to capture which tasks are being performed whilst on the interruptible duty.

It is important that tasks are recorded in [Trello](https://trello.com/b/Z7dOu9Up/re-observe-team) cards so that we understand what tasks are being performed and how long they take, the card should have the label `Interruptible`.
This information is important so that we can feedback and improve the process.

When triaging an issue you should take some time to ask the following questions:

- is someone else already looking at the issue
  - slack the `#re-autom8` channel, ask the team and look at existing Trello cards.
- what impact is it having on tenants:
  - High - does it affect their services, i.e. cause problems with deployments, affects performance of their apps.
  - Mid - does it impact their metrics collection, i.e. see unexpected gaps in metrics, or odd values, loss of historical metrics.
  - Low - is it causing problems in viewing metrics on Grafana, but metrics are still being collected and stored.
- how long will the issue take to resolve
  - get estimate from the person who is working on resolving the issue.
  - update the tenant(s) affected with progress.

Ideally you will not need to spend more then 30 minutes finding the answers.

If it is a new issue, and no one else is aware of it then create a [Trello](https://trello.com/b/Z7dOu9Up/re-observe-team) card adding the details you have found and add the appropriate label.

Talk to the team and decide who is going to be responsible for fixing the issue.

### Incident Process
- Identify the impact to the end user.
- Inform stakeholders on `#re-prometheus-support` for prometheus or `#reliability-eng` for Logit, slack channels if it affects all tenants or on their team slack channel if it is team specific.
- If a page / ticket is not already created on PagerDuty then create one.
- Triage and technical enquiry
  - speak to the observe team to find out who has best knowledge around the issue.
- Gather and preserve evidence.
- Resolution, update initiators that issue has been resolved.
- Closure, organise a team incident review.

## Alerts

### RE_Observe_AlertManager_Below_Threshold

The current number of Alertmanagers running in production has gone below two.

1. Check using the AWS console that there are sufficient number of running ECS instances (Auto Scaling Group self healing).
2. Check using the AWS console if the ECS Alertmanager tasks are trying to start and are failing to do so.
3. Check the ECS logs for the alertmanager services - these can be found in the ECS console.

#### Links

- [Alert definition](https://github.com/alphagov/prometheus-aws-configuration-beta/search?q=RE_Observe_AlertManager_Below_Threshold)

### RE_Observe_No_FileSd_Targets

Prometheus has no targets via file service discovery for the GOV.UK PaaS.

Check the [S3 targets bucket](https://s3.console.aws.amazon.com/s3/buckets/gds-prometheus-targets/?region=eu-west-1&tab=overview) in the GDS Tech Ops AWS account to ensure that the targets exist in the bucket.

If there are files in the targets bucket then:

1. Check the [Prometheus logs][] for errors.
2. SSH onto Prometheus and check if the target files exist on the instance.

If there are no files in the targets bucket then:

1. Check the [service broker logs][] for errors.
2. Check the `prometheus-service-broker` and `prometheus-target-updater` are running by logging into the PaaS `prometheus-production` space.

#### Links

- [Grafana: Prometheus](https://grafana-paas.cloudapps.digital/d/G-AIv9dmz)
- [Grafana: Service broker](https://grafana-paas.cloudapps.digital/d/JFAHBG1ik)
- [Alert definition](https://github.com/alphagov/prometheus-aws-configuration-beta/search?q=RE_Observe_No_FileSd_Targets)

### RE_Observe_Prometheus_Below_Threshold

The current number of Prometheis running in production has gone below two.

1. Check the status of the Prometheus instances in EC2.
2. Check the [Prometheus logs][] for errors.

#### Links

- [Grafana: Prometheus](https://grafana-paas.cloudapps.digital/d/G-AIv9dmz)
- [Alert definition](https://github.com/alphagov/prometheus-aws-configuration-beta/search?q=RE_Observe_Prometheus_Below_Threshold)

### RE_Observe_Prometheus_Disk_Predicted_To_Fill

The available disk space on the `/mnt` EBS volume is predicted to reach 0GB within 72 hours.

Look at [Grafana for the volume's disk usage](https://grafana-paas.cloudapps.digital/d/xIhaZyJmk/prometheus-nodes) or the [raw data in Prometheus](https://prom-3.monitoring.gds-reliability.engineering/graph?g0.range_input=1d&g0.expr=node_filesystem_avail%7B%20mountpoint%3D%22%2Fmnt%22%2C%20job%3D%22prometheus_node%22%20%7D&g0.tab=0&g1.range_input=1d&g1.stacked=0&g1.expr=predict_linear(node_filesystem_avail%7B%20mountpoint%3D%22%2Fmnt%22%20%7D%5B12h%5D%2C3%20*%2086400)&g1.tab=0). This will show the current available disk space.

Increase the EBS volume size (base the increase on the current growth rate in the Prometheus dashboard) in [RE Observe Prometheus terraform repository](https://github.com/alphagov/prometheus-aws-configuration-beta/blob/fc476319f504ee8ede3cefca70fbf9d7137efb7b/terraform/modules/enclave/prometheus/main.tf#L53) code and then run `terraform apply`. When the instance is available `ssh` into each instance and run `sudo resize2fs /dev/xvdh` so that the file system picks up the available disk space.

#### Links

- [Alert definition](https://github.com/alphagov/prometheus-aws-configuration-beta/search?q=RE_Observe_Prometheus_Disk_Predicted_To_Fill)

### RE_Observe_Prometheus_High_Load

Prometheus query engine timing is above the expected threshold. It indicates Prometheus may be beginning to struggle with the current load. This could be caused by:

- too many queries being run against it
- queries being run which are too resource intensive as they query over too many metrics or too long a time period
- an increase in the number of metrics being scraped causing existing queries to be too resource intensive

Queries can originate from a Grafana instance, alerting or recording rules, or be manually run by a user.

If this issue occurs please notify and discuss with the team.

#### Links

- [Grafana: Prometheus](https://grafana-paas.cloudapps.digital/d/G-AIv9dmz)
- [Alert definition](https://github.com/alphagov/prometheus-aws-configuration-beta/search?q=RE_Observe_Prometheus_High_Load)

### RE_Observe_Prometheus_Over_Capacity

Prometheus query engine timing is above the expected threshold. It indicates Prometheus cannot cope with the load and is critically over capacity. This could be caused by:

- too many queries being run against it
- queries being run which are too resource intensive as they query over too many metrics or too long a time period
- an increase in the number of metrics being scraped causing existing queries to be too resource intensive

Queries can originate from a Grafana instance, alerting or recording rules, or be manually run by a user.

If this issue occurs please notify and discuss with the team.

#### Links

- [Grafana: Prometheus](https://grafana-paas.cloudapps.digital/d/G-AIv9dmz)
- [Alert definition](https://github.com/alphagov/prometheus-aws-configuration-beta/search?q=RE_Observe_Prometheus_Over_Capacity)

### RE_Observe_Target_Down

There is a Prometheus target that has been marked as down for 24 hours.

This alert is used as a catch all to identify failing targets that may have no related alert (of which there are several).

You should identify who is responsible for the target and check their alerting rules to see if they would have been notified of this. If they would not have received an alert because they do not have one set up then you should contact them.

If the target is a leftover test app deployed by ourselves then check with the team but we can likely delete the application if no longer needed or unbind the service from the app, either [manually](https://cli.cloudfoundry.org/en-US/cf/unbind-service.html) or by removing the service from the application manifest.

We have also seen a potential bug with our PaaS service discovery leaving targets for
blue-green deployed apps even after the old (also known as venerable) application has been deleted. If this is the case we should try and identify what caused it. If we can't figure out why, manually delete the file from the [gds-prometheus-targets bucket](https://s3.console.aws.amazon.com/s3/object/gds-prometheus-targets).

#### Links

- [Prometheus targets](https://prom-1.monitoring.gds-reliability.engineering/targets)
- [Alert definition](https://github.com/alphagov/prometheus-aws-configuration-beta/search?q=RE_Observe_Target_Down)

### RE_Observe_Grafana_Down

The Grafana endpoint hasn't been successfully scraped for over 5 minutes. This could be caused by:

1. A deploy is taking longer than expected.
2. An issue with the PaaS.

Check:

1. Check with the team to see if there is a current deploy happening.
2. Check the [non 2xx Grafana logs][]

#### Links

- [Alert definition](https://github.com/alphagov/prometheus-aws-configuration-beta/search?q=RE_Observe_Grafana_Down)

## Runbook

### There is a problem with the monitoring service (Prometheus or Alert Manager)
 - check if the services are available
 - check if there are any deployments in progress
 - check that [Grafana](https://grafana-paas.cloudapps.digital/) is pointing to a live Prometheus service by looking at the data sources under configuration.
 - check the health of the ECS cluster to make sure that the services are running in each AZ.

Escalate the issue to the rest of the team if you are unable to track down the problem.

If the issues are not affecting services  (Users are able to continue to use the service without any disruption) then follow the [triage process](#triage-process).


### There is a problem with one of the Prometheus tenants

Put a message in slack: `#re-prometheus-support` and speak to someone in the [team](https://docs.google.com/document/d/1WLKqmpSHUbOVygkdJkewM1bj7lOK0MC-r8sBpTIHBzs/edit) who is responsible for the service which has a problem.


### Adding and editing Grafana permissions

If a user requests a change in Grafana permissions, for example so that they can edit a team dashboard, then you should add that user to the relevant Grafana team and ensure that the team has admin permissions for their team folder.

Do not change a user's overall permissions found in **Configuration > Users** - this should remain as 'Viewer' for all users who are not part of the RE Observe team.

### Rotate basic auth credentials for Prometheus for PaaS

1. Create a new password, for example using `openssl rand -base64 12`

2. Save the plaintext password in the re-secrets store under `re-secrets/observe/prometheus-basic-auth`.

3. Hash the password:

    ```
    docker run -ti ubuntu
    apt-get update
    apt-get -y install whois
    mkpasswd -m sha-512
    ```

4. Append `grafana:` to your hashed password and save this in the re-secrets store under `re-secrets/observe/prometheus-basic-auth-htpasswd`.

5. Deploy Prometheus to staging. As this deploy changes the `cloud.conf` for our instances, you may need to follow steps
in the Prometheus README to deploy with zero downtime.

6. Update the basic auth password for the Prometheus staging data source in Grafana. You will need to do this for every
Grafana organisation.

7. Repeat step 5 for production. Note, as soon as this has been deployed to the main Prometheus that Grafana is using as
a datasource our users dashboards will start breaking as they will still using the old credentials.

8. Repeat step 6 for production.

9. Let users know via the #re-prometheus-support Slack channel that they may need to refresh any Grafana dashboards they
have open to use the new basic auth credentials.
