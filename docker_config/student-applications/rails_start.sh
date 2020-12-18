#!/usr/bin/env bash

cd /home/app/webapp
bundle exec rails db:migrate

# Start the delayed job
/home/app/webapp/bin/delayed_job start

# Use "exec" to start Rails so that the application will receive the SIGTERM
# sent to the root process (PID 1), giving the application a chance to
# gracefully shutdown.
exec bundle exec rails server -b 0.0.0.0
