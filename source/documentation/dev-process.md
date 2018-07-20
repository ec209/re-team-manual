## Development processes

There is currently no single development process within RE.  The processes to use largely comes down to the programme where the repository originated, and for new repositories, the programme from which the initial contributors to the new repository moved from.

Extract from the PaaS team manual -

> For our wider cultural practices, see the [GDS _It’s OK_ poster](https://gds.blog.gov.uk/2016/05/25/its-ok-to-say-whats-ok/). For instance it’s okay to ask for help, it’s okay to have quiet days, and many other things.

### Using git

Ensure that you are using your GDS email address as the user for any RE git repositories - and set it as the primary email address for alphagov in github settings.

The [GOV.UK Styleguide for git](https://github.com/alphagov/styleguides/blob/master/git.md) contains useful information about using git.

### Commit message format

Refer to the [GOV.UK Styleguide](https://github.com/alphagov/styleguides/blob/master/git.md#commit-messages) for examples of how commit messages should be formatted.

Note: Verify uses/expects the [Co-authored-by:](https://help.github.com/articles/creating-a-commit-with-multiple-authors/) tag in commit messages when the work has been paired on/mobbed so that github can link those commits to the correct users.

### GDS Way code review guidelines

The GDS Way contains guidelines about [how to review code](https://gds-way.cloudapps.digital/manuals/code-review-guidelines.html)

### The GOV.UK, Pay & Verify development processes

The processes for GOV.UK, Pay & Verify are now very similar - the main difference being the required number of approvers for Verify.  The number of approvers required is technically enforced by github.

The GOV.UK development process is documented in the [GOV.UK Styleguide](https://github.com/alphagov/styleguides/blob/master/pull-requests.md)

The Verify development process is documented as an RFC in the [Verify Architecture repo](https://github.com/alphagov/verify-architecture/blob/master/rfcs/rfc-026-use-github-for-release-approval)

The Pay development process is documented in the [Pay Team Manual](https://pay-team-manual.cloudapps.digital/development-processes/development-process/) but it defers to the GOV.UK process.

### The Run/PaaS development process

This is documented in the [PaaS Team Manual](https://team-manual.cloud.service.gov.uk/team/working_practices/)

### The Digital Marketplace process

This is documented in the [Digital Marketplace manual](https://alphagov.github.io/digitalmarketplace-manual/deployment.html#development-and-deployment-process)

### Others?

Raise a PR and add missing content here