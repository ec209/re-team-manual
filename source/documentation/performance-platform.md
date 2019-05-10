# Performance Platform

The Performance Platform is a set of web applications which power gov.uk/performance. Reporting data is [point 17](https://www.gov.uk/service-manual/service-standard/report-performance-data-on-the-performance-platform) on the Digital Service Standard.

## Hosting

The Performance Platform consists of a number of microservices which are hosted on the PaaS:

- backdrop
- stagecraft
- spotlight
- performance-platform-admin

Currently in production `backdrop` is still running in GOV.UK's Carrenza infrastructure.

## Services

### Backdrop

Backdrop is a datastore with two separately deployable HTTP APIs for reading and writing data.

Backdrop can run either with MongoDB (legacy) or using PostgreSQL.

- [Source code](https://github.com/alphagov/backdrop)
- [alphagov/pay-performance-reporter](https://github.com/alphagov/pay-performance-reporter)
  In the wild example of how backdrop is written to
- [GOV.UK Puppet manifests `cmd + f "backdrop"`](https://github.com/alphagov/govuk-puppet/tree/b588e4ade996e97b8975e69cb00800521fff4a48/modules/govuk/manifests/apps)

### Stagecraft

Stagecraft is the internal management django application for managing the performance platform. It also is the canonical source for dashboard configuration which is available publicly.

A.K.A the `admin api`

- [Source code](https://github.com/alphagov/stagecraft)
- [App (Prod)](https://performance-platform-stagecraft-production.cloudapps.digital)
- [App (Staging)](https://performance-platform-stagecraft-staging.cloudapps.digital)
- [Flower (Monitoring) (Prod)](https://performance-platform-stagecraft-flower-production.cloudapps.digital)
- [Flower (Monitoring) (Staging)](https://performance-platform-stagecraft-flower-staging.cloudapps.digital)

Stagecraft has a number of `collectors` which are asynchronous tasks coordinated by Celery. 

### Performance Platform Admin

Performance Platform Admin is a web frontend for dashboard owners to upload XLSX sheets to the performance platform, and for "power" users to edit/manage dashboards.

- [Source code](https://github.com/alphagov/performanceplatform-admin)
- [App (Prod)](https://performance-platform-admin-production.cloudapps.digital)

### Spotlight

Spotlight is a Node.JS frontend for rendering performance platform dashboard. Spotlight sits behind Fastly, which is used as a CDN for improved performance.

Spotlight is the only app where we _really_ care about downtime, everything else is fairly resilient due to the CDN. If Spotlight is down for a long time then users notice and the CDN may also cache a bad page.

- [Source code](https://github.com/alphagov/spotlight)
- [App (Prod)](https://performance-platform-spotlight-production.cloudapps.digital)
- [App (Staging)](https://performance-platform-spotlight-staging.cloudapps.digital)

## Users

### Citizens

Anyone can view statistics hosted on gov.uk/performance, everything is public, including [dashboard metadata hosted on stagecraft](https://performance-platform-stagecraft-staging.cloudapps.digital/public/dashboards?slug=dwp-state-pension-claims-maintained).

### Service owners & developers

There are three ways of putting data into the performance platform, two of which are self-service:

- API
- XLSX upload

Service owners can upload data via the [performance-platform-admin tool](http://performance-platform-admin-production.cloudapps.digital/)

Developers can implement functionality in their service to automatically push statistics to the performance platform, more information is here, hosted on [readthedocs.io](https://performance-platform.readthedocs.io/en/latest/).

### Internal management users

Clifford Sheppard and Daisy Wain are the two people at GDS who manage the performance platform. They liaise with services for the quarterly transaction explorer import.

## Support, monitoring, outages

There is no longer a team who work on this, and there is not much observability of the apps. We did a small amount of work to add some monitoring. The things that we care about principally are:

- Backdrop (read) 200s
- Backdrop (write) 200s
- Backdrop (worker) task successes
- Stagecraft task successes

We only really care about production, staging is used just as a demo environment for transaction explorer data, and ensuring that code changes work.

Stagecraft uses django-celery which allows you to view and create tasks through a [web-ui](https://performance-platform-stagecraft-production.cloudapps.digital/admin/).

We have added Flower, a Celery monitoring tool, to monitor both backdrop and stagecraft:

- [Stagecraft (Prod)](https://performance-platform-stagecraft-flower-production.cloudapps.digital/)
- [Stagecraft (Staging)](https://performance-platform-stagecraft-flower-staging.cloudapps.digital/)
- Backdrop is still running in Carrenza so there is only monitoring in [staging](https://performance-platform-backdrop-flower-staging.cloudapps.digital/).

## App overview

### Backdrop

Has two functions: read and write. The read API receives a request and serves it. The write API receives data from a request and enqueues it.

Backdrop has Celery workers which take enqueued data blobs and writes them to the backdrop database.

The database when running in GOV.UK's infrastructure is MongoDB (v2.4). The database when running on the PaaS is PostgreSQL.

### Stagecraft

Is a big Django app that also uses Celery. The Django app is for management of dashboards (either via an API), or manually using the admin panel.

Stagecraft also has `collectors` which connect to services such as:

- Pingdom
- Google Analytics
- GOV.UK

And retrieve data about various things, e.g. session length, website uptime, etc

In order to access these services, it uses credentials stored in the Stagecraft (PostgreSQL) database.
## Transaction explorer

Every quarter GDS sends out to each department a subset of a [large spreadsheet™](https://docs.google.com/spreadsheets/d/1DN98HNFtOv6POsQt501dnFiZ4Hus6Uj1IrerhDx1Guk/edit?usp=sharing_eil&ts=5b8fd041) which they get each service to fill in. The results are collated in the aforementioned spreadsheet and then ready for being uploaded to the performance platform.

When uploading the data, different pieces need to go to different places. The two destinations are `backdrop` and `stagecraft`. As above, the data needs to go into `backdrop`, and the dashboard metadata needs to go into `stagecraft`.

The process for importing data into backdrop is described in [backdrop-transactions-explorer-collector](https://github.com/alphagov/backdrop-transactions-explorer-collector).

The process for importing data into stagecraft is described in [this document](https://docs.google.com/document/d/1oqCsXOpJBUPzXAVMs8B0FRZJyliUOKxqD5W7p3M-Csk/edit#), but can be roughly summarised as:

- Using credentials in paas-pass:
- Staging:
  ```
  cf target -o gds-performance-platform -s staging
  cf ssh "performance-platform-stagecraft-web" -t -c "/tmp/lifecycle/launcher /home/vcap/app 'bash' ''"
  export GOOGLE_APPLICATION_CREDENTIALS=credentials.json
  export SUMMARIES_URL=https://performance-platform-backdrop-read-staging.cloudapps.digital/data/transactional-services/summaries
  rm -rf *.pickle # in case any files have been cached by this insane process
  python -m stagecraft.tools.import_dashboards --update --commit
  python -m stagecraft.tools.import_organisations # this failed for us, and we don't care because the organisations haven't changed
  ```
- Notify Clifford that staging has been done
- Wait 1 week, get new data
- Production:
  ```
  cf target -o gds-performance-platform -s staging
  cf ssh "performance-platform-stagecraft-web" -t -c "/tmp/lifecycle/launcher /home/vcap/app 'bash' ''"
  export GOOGLE_APPLICATION_CREDENTIALS=credentials.json
  export SUMMARIES_URL=https://www.performance.service.gov.uk/data/transactional-services/summaries
  rm -rf *.pickle # in case any files have been cached by this insane process
  python -m stagecraft.tools.import_dashboards --update --commit
  python -m stagecraft.tools.import_organisations # this failed for us, and we don't care because the organisations haven't changed
  ```

## What we did in Q2 2018

This work was conducted by the PaaS team over a period of months between July and September 2018.

### Code

- Rewrote backdrop to be able to use PostgreSQL instead of MongoDB, upgrade version of Redis, etc
  - [Git history](https://github.com/alphagov/backdrop/compare/71edf44d8616a0bc7707d6e3e3b4288637a7a67d...1256e5075d7e5a0e41afb0f0913a5f2c4bdb9ad8)
- Use new redis transport in performanceplatform-admin and vendor the css because it was not building
  - [Git history](https://github.com/alphagov/performanceplatform-admin/compare/a2d3f49eaf33dd7309c94adbae3c1364e3144a34...a066ff3601e821ff774fed8bb7b5a29408427717)
- Add support for multiuser pingdom, use new redis and celery versions (Stagecraft)
  - [Git history](https://github.com/alphagov/stagecraft/compare/d0d891c8ddc722561ec80d9944771a15e078bc49...29db8f4075829cb7c99aeda695f8a6de629e2c35)
- Added support for the `rediss` transport used by the PaaS's redis service
  - [Celery](https://github.com/alphagov/celery)
  - [Kombu](https://github.com/alphagov/kombu)
  - [Flower](https://github.com/alphagov/flower)
- Added some basic monitoring for stagecraft and backdrop using Flower
- Wrote some scripts to help migrate from staging MongoDB to PostgreSQL
  - [Git repo](https://github.com/alphagov/performanceplatform-migration)


### Data

- Migrated the staging MongoDB to PostgreSQL:
  - [Git repo](https://github.com/alphagov/performanceplatform-migration)
  - Basically `xargs cf run-task` 
- Supported transaction explorer quarterly import into staging/integration/Production sccessfully with the change.

### Transaction Explorer data
  - [Documentation on how to import transaction explorer data](https://docs.google.com/document/d/1oqCsXOpJBUPzXAVMs8B0FRZJyliUOKxqD5W7p3M-Csk/edit#)


## To do

- Migrate backdrop in production from Carrenza to PaaS
- Remove MongoDB database interaction code
- Implement "collection" capping (if necessary)
- Address any performance problems from PostgreSQL migration

## References

- [Technical overview deck](https://docs.google.com/presentation/d/1AeraHGcOulK9cWnroj7wTdd9Rkvy6XhnQF54Eyn7GT0/edit)
- [Handover doc](https://docs.google.com/document/d/1_ewhGR5KOZassPsHMbRiLLUG40fFywS2TZZW_TE7ClA/edit?usp=drive_web&ouid=115270948065632839284)
- [Everything folder](https://drive.google.com/drive/u/0/folders/0B9ve1d3hOs3gaW1fYXdFRzVUOFE)
- [Performance platform epic in Pivotal](https://www.pivotaltracker.com/epic/show/4022286)
