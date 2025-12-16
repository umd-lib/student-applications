# student-applications

Rails application for processing student applications for Libraries employment

A student application ( called "Prospect" to avoid confusion ) is submitted via
a multi-page form. This is managed by serializing the parameters in a session,
which are marshalled at each step of the process.

Each step has a view defined in the "app/views/prospects" directory which is
rendered when the process reaches that step.

## Test Plan

A basic test plan for verifying application functionality is provided in
[docs/TestPlan.md](docs/TestPlan.md).

## Development Setup

**Note:** This application uses the "sprockets" asset pipeline for
CSS and JavaScript. It does *not* use "importmaps", and does *not*
require Node, Webpack, or Yarn.

Requires:

* Ruby 3.4.7
* Bundler v2.5.22
* [Google Chrome](https://www.google.com/chrome/index.html) (for testing)

### Prerequisites

* Update the /etc/hosts file to add:

```text
127.0.0.1       student-applications-local
```

### Application Setup

To run the application:

1) Clone the Git repository and switch into the directory:

```zsh
$ git clone https://github.com/umd-lib/student-applications.git
$ cd student-applications
```

2) Install the dependencies:

```zsh
$ bundle config set without 'production'
$ bundle install
```

---

**Note:** If after installing the gems and running a Rails task (or the server)
you get multiple errors of the form:

```text
Ignoring cgi-0.5.1 because its extensions are not built. Try: gem pristine cgi --version 0.5.1
Ignoring io-console-0.8.1 because its extensions are not built. Try: gem pristine io-console --version 0.8.1
...
```

then run:

```zsh
gem pristine --all
```

to fix the gems.

---

3) Setup the database:

```zsh
$ rails db:migrate
$ rails db:seed
```

4) (Optional) Populate database with sample data:

```zsh
$ rails db:reset_with_sample_data
```

5) The application uses CAS authentication to only allow known users to log in.
The seed data for the database does not contain any users. Run the following
Rake task to add a user:

```zsh
$ rails 'db:add_admin_cas_user[<CAS DIRECTORY ID>,<FULL NAME>]'
```

and replacing the "\<CAS DIRECTORY ID>" and "\<FULL NAME>" with valid user
information. For example, to add "John Smith" with a CAS Directory ID of
"jsmith":

```zsh
$ rails 'db:add_admin_cas_user[jsmith, John Smith]'
```

5) Run the web application:

```zsh
$ rails server
```

To create an application, go to:

<http://student-applications-local:3000/>

To access the administrative interface, go to:

<http://student-applications-local:3000/prospects>

### Running the tests

To run the unit tests:

```zsh
$ rails test
```

To run the system tests:

```zsh
$ rails test:system
```

### Code Style

This application uses the Rails Rubocop configuration
[rubocop-rails-omakase](https://github.com/rails/rubocop-rails-omakase) to
enforce a consistent coding style. To run:

```zsh
$ rubocop -D
```

## Docker.ci and Jenkinsfile

The "Dockerfile.ci" file is used to encapsulate the environment needed by the
continuous integration (ci) server for building and testing the application.

The "Jenkinsfile" provides the Jenkins pipeline steps for building and
testing the application.

## Production Environment Configuration

Requires:

* Postgres client to be installed (on RedHat, the "postgresql" and
  "postgresql-devel" packages)
* The "imagemagick" package (required by the "paperclip" gem)

The application uses the "dotenv" gem to configure the production environment.
The gem expects a ".env" file in the root directory to contain the environment
variables that are provided to Ruby. A sample "env_example" file has been
provided to assist with this process. Simply copy the "env_example" file to
".env" and fill out the parameters as appropriate.

The configured .env file should *not* be checked into the Git repository, as it
contains credential information.

### Delayed Jobs and Mailers

An application submission sends an email to applicants. This email is handled
by ActionMailer, using a [delayed_job](https://github.com/collectiveidea/delayed_job)
queue. To run a delayed_job worker, you can start/stop the daemon process using:

```zsh
$ cd ./student-applications; RAILS_ENV=production ./bin/delayed_job start
$ cd ./student-applications; RAILS_ENV=production ./bin/delayed_job stop
```

There are also a number of Job-related rake tasks that can be invoked
These include:

```zsh
$ ./bin/rails jobs:clear          # Clear the delayed_job queue
$ ./bin/rails jobs:check[max_age] # Exit with error status if any jobs older than max_age seconds haven't been attempted yet
$ ./bin/rails jobs:work           # Start a delayed_job worker
$ ./bin/rails jobs:workoff        # Start a delayed_job worker and exit when all available jobs are complete
```

Note: Include the RAILS_ENV=production flag if you're using this on
application in production-mode.

To view the delayed_job queue status, you can visit /delayed_jobs in the
application. This requires an admin user to be logged in ( first visit
/prospects to login. )

### Adding users

You can add users via a Rails task:

```zsh
$ ./bin/rails 'db:add_admin_cas_user[cas_directory_id,full_name]'  # Add an admin user
$ ./bin/rails 'db:add_cas_user[cas_directory_id,full_name]'        # Add a non-admin user
$ ./bin/rails db:bulk_add_users[csv_file]  # use csv file with full_name, directory_id rows
```

## Rails Tasks

## db:purge_suppressed_prospects

Prospects that are deleted through the GUI are "soft-deleted", that is, they are
not actually destroyed. Instead, the "suppressed" field is simply set to "true",
and the prospects no longer appear in the GUI.

The "db:purge_suppressed_prospects" actually deletes suppressed prospects, once
they have not been updated for a week.

It is anticipated this task will be run periodically in a "cron-link" process.

To run the task manually:

```zsh
$ ./bin/rails db:purge_suppressed_prospects
```

## verify_resume_attachments

Examines the file attachments in the database, and in the attached file storage
location to determine if any files are "missing" or "orphaned".

A "missing" file is a file that is in a database record as an existing
attachment, but which is not found in the attached file storage directory.

An "orphaned" file is a file found in the attached file storage directory, but
does not have an associated database record.

To run the task:

```zsh
$ ./bin/rails db:purge_suppressed_prospects
```

## db:reset_with_sample_data/db:populate_sample_data

Creates 700 sample prospects in the database. Typically used to create
prospects in the development environment.

The "db:reset_with_sample_data" resets the databases before creating 700
new prospects using the "db:populate_sample_data" task.

**Note:** The file attachment storage directory is not cleared in the reset,
so there will likely be "orphaned" files (files without an associated database
record) in that directory.

To run the task:

```zsh
$ ./bin/rails db:reset_with_sample_data
```

The "db:populate_sample_data" task simply adds 700 new prospects to the
existing database (the database is *not* reset).

To run the task:

```zsh
$ ./bin/rails db:populate_sample_data
```
