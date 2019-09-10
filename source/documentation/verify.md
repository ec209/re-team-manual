## DNS changes

The main domain associated with Verify infrastructural things is ida.digital.cabinet-office.gov.uk. It lives in GOV.UK DNS.
signin.service.gov.uk also lives in GOV.UK DNS.

### How to deploy GOV.UK DNS changes

* Make a change to [alphagov/govuk-dns-config](https://github.com/alphagov/govuk-dns-config) (private repo). There's a YAML file for each zone in the root of the repository. Make a PR with your changes, get someone to approve it, and merge.
* Run `gds aws govuk-production-admin -e` in shell to get your credentials. You will need some GOV.UK production access to do this.
* Go to [https://deploy.publishing.service.gov.uk/job/Deploy_DNS/build](https://deploy.publishing.service.gov.uk/job/Deploy_DNS/build) - this is the 'Build with Parameters' form of the DNS deployment job
* You'll need to log into Jenkins using GitHub, you will need to be in the gov-uk-dns-administrators team.
* Fill out the form with your credentials, action will be 'plan', and the correct zone for your change. Do this once with provider aws and once with provider gcp.
* Click on each of the plan jobs and look at their console output (you may have to wait for it to complete, especially the AWS plan).
  * If you updated a record, expect to see Terraform deleting and re-creating it.
  * If you add a new record, expect to see lots of green.
  * When you apply changes to GCP, there may be some unrelated TXT record updates containing quotes and backslashes. This is due to a bug with govuk-dns - the underlying system - and how it splits long TXT records per provider. These are able to be ignored.
* If that was okay, fill out the form for each provider again but this time with action 'apply'. If updating a record, the GCP one may need to be repeated to work properly as it will try to create a record before Terraform has processed the destruction of the previous one.
