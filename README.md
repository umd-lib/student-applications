# student-applications

Rails application for processing student applications for Libraries employment

A student application ( called "Prospect" to avoid confusion ) is submitted via a multi-page form. This
is managed by serializing the parameters in a session, which are marshalled at each step of the process.

Each step has a view defined in the app/views/prospect which is rendered when the process reaches that step.

## Setup

Requires:

* Ruby 2.7.2
* Bundler v1.17.3
* [Google Chrome](https://www.google.com/chrome/index.html) (for testing)

To run the application:

```
$ git clone https://github.com/umd-lib/student-applications.git
$ cd student-applications
$ bundle
$ ./bin/rails db:migrate
$ ./bin/rails db:seed
$ ./bin/rails s
```

You can load test fixtures in by using db:seed:demo rake task

```
$ ./bin/rails db:seed:demo
```

To develop, you can run [Guard](https://github.com/guard/guard) by issuing:

```
$ ./bin/bundle exec guard
```

## Testing Setup

Testing uses [Minitest](https://github.com/seattlerb/minitest),
[Capybara](https://github.com/jnicklas/capybara) and the Selenium web driver.

Google Chrome and the "webdriver" gem are used to provide a headless browser for
testing.

The [webdriver](https://github.com/titusfortner/webdrivers)
gem should automatically download and install the latest chromedrivee executable
into ~/.chromedriver.

CSS animations and transitions cause visibility/timing issues when testing in
a headless browser. When running the tests, they have turned off by the
"lib/no_animations.rb" file, which is added as Rack middleware in the
"config/environment/test.rb" file.

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

The configured .env file should _not_ be checked into the Git repository, as it
contains credential information.

### Delayed Jobs and Mailers

An application submission sends an email to applicants. This email is handled
by ActionMailer, using a [delayed_job](https://github.com/collectiveidea/delayed_job) queue.
To run a delayed_job worker, you can start/stop the daemon process using :

```
$ cd ./student-applications; RAILS_ENV=production ./bin/delayed_job start
$ cd ./student-applications; RAILS_ENV=production ./bin/delayed_job stop
```

There are also a number of Job-related rake tasks that can be invoked
These include:

```
./bin/rails jobs:clear                                         # Clear the delayed_job queue
./bin/rails jobs:check[max_age]                                # Exit with error status if any jobs older than max_age seconds haven't been attempted yet
./bin/rails jobs:work                                          # Start a delayed_job worker
./bin/rails jobs:workoff                                       # Start a delayed_job worker and exit when all available jobs are complete
```

Note: Include the RAILS_ENV=production flag if you're using this on
application in production-mode.

To view the delayed_job queue status, you can visit /delayed_jobs in the
application. This requires an admin user to be logged in ( first visit
/prospects to login. )

### Adding users

You can add users via a Rails task:

```
$ ./bin/rails 'db:add_admin_cas_user[cas_directory_id,full_name]'  # Add an admin user
$ ./bin/rails 'db:add_cas_user[cas_directory_id,full_name]'        # Add a non-admin user
$ ./bin/rails db:bulk_add_users[csv_file]  # use csv file with full_name, directory_id rows
```
