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
