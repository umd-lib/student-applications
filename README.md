# student-applications

Rails application for processing student applications for Libraries employment

# Student Application Application

This is an application to accept applications from students. 

A student application ( called "Prospect" to avoid confusion ) is submitted via a multi-page form. This
is managed by serializing the parameters in a session, which are marshalled at each step of the process.

Each step has a view defined in the app/views/prospect which is rendered when the process reaches that step. 


## Setup 

Requires:

* Ruby 2.2
* Bundler
* [phantomjs](http://phantomjs.org/) - PhantomJS must be installed separately, and the executable directory placed on the PATH.


To run the application:

```
$ git clone https://github.com/umd-lib/student-applications.git
$ cd student-applications
$ bundle
$ ./bin/rake db:migrate
$ ./bin/rake db:seed
$ ./bin/rails s
```

You can load test fixtures in by using db:seed:demo rake task

```
$ ./bin/rake db:seed:demo
```


To develop, you can run [Guard](https://github.com/guard/guard) by issuing:

```
$ ./bin/bundle exec guard
```

Testing uses [Minitest](https://github.com/seattlerb/minitest) and [Capybara](https://github.com/jnicklas/capybara).
[Poltergeist](https://github.com/teampoltergeist/poltergeist) provides a headless Webkit driver for Capybara, which
can be used for Feature tests that use lots of Javascript. 

## Production Environment Configuration

Requires:

* Postgres client to be installed (on RedHat, the "postgresql" and 
"postgresql-devel" packages)

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
$ ./bin/delayed_job start RAILS_ENV=production 
$ ./bin/delayed_job stop RAILS_ENV=production 
```

To view the delayed_job queue status, you can visit /delayed_job in the
application. This requires an admin user to be logged in ( first visit
/prospects to login. )


### Adding users

You can add users via a rake task: 

```
$ ./bin/rake db:add_admin_cas_user[cas_directory_id,full_name]  # Add an admin user
$ ./bin/rake db:add_cas_user[cas_directory_id,full_name]        # Add a non-admin user
$ ./bin/rake db:bulk_add_users[csv_file]  # use csv file with full_name, directory_id rows 
```
