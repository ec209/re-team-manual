# Reliability Engineering Team Manual

## Technical documentation

This is a static site generated with Middleman.

## Tech docs template

This project uses [alphagov/tech-docs-template](https://github.com/alphagov/tech-docs-template).

### Dependencies

- Ruby.
- The `middleman` gem.

### Making changes

To make changes, edit the source files in the `source` directory. To add a
completely new page, create a file with a `.html.md` extension in the `/source`
directory.

Whilst writing documentation we can run a middleman server to preview how the
published version will look in the browser. After saving a change the preview in
the browser will automatically refresh. Run `bundle exec middleman server`,
then the website will be available locally at http://localhost:4567.

### Building the project

Build the site with:

```
bundle exec middleman build
```

This will create a bunch of static files in `/build`.

### Deployment

This is deployed to the PaaS manually.

## Licence

[MIT License](LICENCE.md)

