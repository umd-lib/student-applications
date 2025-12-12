# student-applications

Rails application for processing student applications for Libraries employment

A student application ( called "Prospect" to avoid confusion ) is submitted via
a multi-page form. This is managed by serializing the parameters in a session,
which are marshalled at each step of the process.

Each step has a view defined in the app/views/prospect which is rendered when
the process reaches that step.

## Test Plan

A basic test plan for verifying application functionality is provided in
[docs/TestPlan.md](docs/TestPlan.md).

## Development Setup

**Note:** This application uses the Rails v4 "asset pipeline" for
CSS and JavaScript. It does *not* use Webpack or Yarn.

Requires:

* Ruby 2.7.5
* Bundler v1.17.3
* [Google Chrome](https://www.google.com/chrome/index.html) (for testing)

### Prerequisites

* Update the /etc/hosts file to add:

```text
127.0.0.1       student-applications-local
```

### Application Setup

To run the application:

1) Checkout the code and install dependencies:

```bash
$ git clone https://github.com/umd-lib/student-applications.git
$ cd student-applications

# The following two commands are required for Apple Silicon
$ bundle config --local build.nio4r --with-cflags="-Wno-incompatible-pointer-types"
$ bundle config --local build.sqlite3 --with-cflags="-Wno-incompatible-pointer-types -Wno-error=implicit-function-declaration -Wno-int-conversion"

$ bundle install --without production
```

2) Setup the database:

```bash
$ ./bin/rails db:migrate
$ ./bin/rails db:seed
```

3) (Optional) Populate database with sample data:

```bash
$ ./bin/rails db:reset_with_sample_data
```

4) The application uses CAS authentication to only allow known users to log in.
The seed data for the database does not contain any users. Run the following
Rake task to add a user:

```bash
$ ./bin/rails 'db:add_admin_cas_user[<CAS DIRECTORY ID>,<FULL NAME>]'
```

and replacing the "\<CAS DIRECTORY ID>" and "\<FULL NAME>" with valid user
information. For example, to add "John Smith" with a CAS Directory ID of
"jsmith":

```bash
$ ./bin/rails 'db:add_admin_cas_user[jsmith, John Smith]'
```

5) Run the web application:

```bash
$ ./bin/rails server
```

To develop, you can run [Guard](https://github.com/guard/guard) by issuing:

```bash
$ ./bin/bundle exec guard
```

## Testing Setup

Testing uses [Minitest](https://github.com/seattlerb/minitest),
[Capybara](https://github.com/jnicklas/capybara) and the Selenium web driver.

Google Chrome and the "webdriver" gem are used to provide a headless browser for
testing.

CSS animations and transitions cause visibility/timing issues when testing in
a headless browser. When running the tests, they have turned off by the
"lib/no_animations.rb" file, which is added as Rack middleware in the
"config/environment/test.rb" file.

**Note:** As of December 3, 2025, the
[webdriver](https://github.com/titusfortner/webdrivers)
gem no longer correctly downloads and installs the latest chromedriver
executable.

To set up the chromedriver:

1) Determine the version of Chrome installed on the local workstation:

```zsh
$ /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version
```

This will print out a version such as:

```text
Google Chrome 143.0.7499.41
```

2) In a web browser, go to

<https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json>

This JSON page of all the available chromedriver versions (it looks best in
Mozilla Firefox).

Find the chromedriver version closest to the version on the local workstation
(without going over), and note the "download" URL for the "mac-arm64" platform
in the "chromedriver" section, i.e.:

```json
  "version": "143.0.7499.40",
  "revision": "1536371",
   "downloads": {
    ...
    "chromedriver": [
          ...
          {
            "platform": "mac-arm64",
            "url": "https://storage.googleapis.com/chrome-for-testing-public/143.0.7499.40/mac-arm64/chromedriver-mac-arm64.zip"
          },
          ...
```

3) Download the "chromedriver" using "wget" into th project directory. Using
the example URL from the previous step:

```zsh
$ wget https://storage.googleapis.com/chrome-for-testing-public/143.0.7499.40/mac-arm64/chromedriver-mac-arm64.zip
```

4) Extract the Zip file:

```zsh
$ unzip chromedriver-mac-arm64.zip
```

5) Rename the "chromedriver-mac-arm64" subdirectory to "chromedriver" (this is
done to provide consistency between the macOS environment and the Linux
environment used in "Dockerfile.ci"):

```zsh
$ mv chromedriver-mac-arm64 chromedriver
```

This will create a "chromedriver-mac-arm64" directory.

6) To run the unit tests:

```zsh
$ rake test
```

7) To run the system tests:

```zsh
$ rake test:system
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

```bash
$ cd ./student-applications; RAILS_ENV=production ./bin/delayed_job start
$ cd ./student-applications; RAILS_ENV=production ./bin/delayed_job stop
```

There are also a number of Job-related rake tasks that can be invoked
These include:

```bash
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

```bash
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

```bash
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

```bash
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

```bash
$ ./bin/rails db:reset_with_sample_data
```

The "db:populate_sample_data" task simply adds 700 new prospects to the
existing database (the database is *not* reset).

To run the task:

```bash
$ ./bin/rails db:populate_sample_data
```
