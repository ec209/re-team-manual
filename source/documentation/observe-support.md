## Observe interruptible support

Observe build and operate a Prometheus service for PaaS tenants, and are responsible for the ongoing business as usual Logit tasks.

### Support availability

The observe team are offering an in work hours support, this is currently 9am - 6pm, Monday to Fridays. Any issues out of hours will be recorded and handled during work hours.

### Observe interruptible tasks:
- Keep interruptible Documentation Up To Date
- Respond to PagerDuty alerts
- Support users on the `#re-prometheus-support` and `#reliability-eng` slack channels
- Report any problems on the `#re-prometheus-support` and `#reliability-eng` slack channels with regular updates
- Check emails for Pingdom notifications
- Check emails for Logit and PagerDuty status updates
- Check on the status of the Prometheus service
- Triage issues and bugs
- Initiate the [incident process](#incident-process)

#### Keep Interruptible Documentation Up To Date

Observe interruptible is a new responsibility, we are attempting to document the interruptible process however we expect there to be gaps, one of the primary responsibilities will be to keep this documentation up to date as this role evolves.

#### Respond to PagerDuty alerts

PagerDuty is configured to ring the Interruptible phone when an alert is triggered. PagerDuty alerts should be acknowledged and investigated.

##### If the problem is with the monitoring service (Prometheus or Alert Manager)
 - check if the services are available 
 - check if there are any deployments in progress
 - check that [Grafana](https://grafana-paas.cloudapps.digital/) is pointing to a live Prometheus service by looking at the data sources under configuration.
 - check the health of the ECS cluster to make sure that the services are running in each AZ.

Escalate the issue to the rest of the team if you are unable to track down the problem. 

If the issues are not affecting services  (Users are able to continue to use the service without any disruption) then follow the [triage process](#triage-process).

##### If the problem is with one of the Prometheus tenants

Put a message in slack: `#re-prometheus-support` and speak to someone in the [team](https://docs.google.com/document/d/1WLKqmpSHUbOVygkdJkewM1bj7lOK0MC-r8sBpTIHBzs/edit) who is responsible for the service which has a problem.

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
  - slack the `#re-observe` channel, ask the team and look at existing Trello cards.
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

### Handover process

The [interruptible rota](https://docs.google.com/spreadsheets/d/1iNvK-UvArAKpWAf0rIYGRxK46um-cZSqMqCzD3U_-gM) runs from Wednesday to Wednesday, handover should take place after stand up.

- Update the PagerDuty contact number and name in PagerDuty to your contact number and name.
- Update the slack channels `#re-prometheus-support` and `#reliability-eng`:
  - topic with your slack handle (and name if it's not clear in your handle)
  - notification preferences so that you are aware of all communications on those channels.
- Handover of any outstanding tasks:
  - The plan to resolve the page / ticket.
  - Actions taken, remaining and next step.
  - Share relevant conversation threads or contacts if a conversation hasn't started.

## Alerts

### RE_Observe_AlertManager_Below_Threshold

The current number of Alertmanager's running in production has gone below the expected threshold. Check the AWS console and ensure a new instance is being created (Auto Scaling Group self healing). Once service is
back to normal you may beginning the root cause analysis.

[Grafana](https://grafana-paas.cloudapps.digital/d/G-AIv9dmz/prometheus-benchmark?orgId=1)

For more information you could [search the prometheus-aws-configuration-beta repo for the source of the alert](https://github.com/alphagov/prometheus-aws-configuration-beta/search?q=RE_Observe_AlertManager_Below_Threshold)

### RE_Observe_No_FileSd_Targets

Prometheus was unable to discover the Cloud foundry Platform as a Service targets via the file service discovery option.
There is a number possible failure points at this stage. Please review the following things:

1. Check S3 to ensure that SD targets are being written to the bucket.
2. Check the prometheus service logs in ECS to ensure that the file directory is readable & look for general errors.
3. Check [cf_app_discovery](https://github.com/alphagov/cf_app_discovery) as this is one of the main components for extracting this information. Please use the cloud foundry command line to review app status.
4. Review prometheus targets and metrics to try understand when the issue may have started. Review third party API's for issues.

[Grafana](https://grafana-paas.cloudapps.digital/d/G-AIv9dmz/prometheus-benchmark?orgId=1)

For more information you could [search the prometheus-aws-configuration-beta repo for the source of the alert](https://github.com/alphagov/prometheus-aws-configuration-beta/search?q=RE_Observe_No_FileSd_Targets)

### RE_Observe_Prometheus_Below_Threshold

The current number of Prometheus running in production has gone below the expected threshold. Check the AWS console and ensure a new instance is being created (Auto Scaling Group self healing). Once service is
back to normal you may beginning the root cause analysis.

[Grafana](https://grafana-paas.cloudapps.digital/d/G-AIv9dmz/prometheus-benchmark?orgId=1)

For more information you could [search the prometheus-aws-configuration-beta repo for the source of the alert](https://github.com/alphagov/prometheus-aws-configuration-beta/search?q=RE_Observe_Prometheus_Below_Threshold)

### RE_Observe_Prometheus_High_Load

Prometheus query engine timing is above the expected threshold. It indicates Prometheus cannot cope with the load and is
critically over capacity. This could be caused by too many queries being run against it. Queries can originate from a Grafana
instance or be manually run by a user.
                                                                
If this issue occurs please notify and discuss with the team.


[Grafana](https://grafana-paas.cloudapps.digital/d/G-AIv9dmz/prometheus-benchmark?orgId=1)

For more information you could [search the prometheus-aws-configuration-beta repo for the source of the alert](https://github.com/alphagov/prometheus-aws-configuration-beta/search?q=RE_Observe_Prometheus_High_Load)

### RE_Observe_Prometheus_Over_Capacity

Prometheus query engine timing is above the expected threshold. It indicates Prometheus cannot cope with the load and is critically over capacity.
This could be caused by too many queries being run against it. Queries can originate from a Grafana instance or be manually run by a user.

If this issue occurs please notify and discuss with the team.

[Grafana](https://grafana-paas.cloudapps.digital/d/G-AIv9dmz/prometheus-benchmark?orgId=1)

For more information you could [search the prometheus-aws-configuration-beta repo for the source of the alert](https://github.com/alphagov/prometheus-aws-configuration-beta/search?q=RE_Observe_Prometheus_Over_Capacity)
