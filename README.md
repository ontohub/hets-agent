[![Build Status](https://travis-ci.org/ontohub/hets-agent.svg?branch=master)](https://travis-ci.org/ontohub/hets-agent)
[![Coverage Status](https://coveralls.io/repos/github/ontohub/hets-agent/badge.svg?branch=master)](https://coveralls.io/github/ontohub/hets-agent?branch=master)
[![Code Climate](https://codeclimate.com/github/ontohub/hets-agent/badges/gpa.svg)](https://codeclimate.com/github/ontohub/hets-agent)
[![GitHub issues](https://img.shields.io/github/issues/ontohub/hets-agent.svg?maxAge=2592000)](https://waffle.io/ontohub/ontohub-backend?source=ontohub%2Fhets-agent)

# hets-agent
RabbitMQ wrapper for Hets. It listens to the queue for Hets-jobs and invokes Hets accordingly. For some jobs, it sends jobs back to the ontohub-backend to post-process the result.

# Installation
* Install Hets
* Install RabbitMQ
* Install the RabbitMQ extension "Recent History Exchange": You can enable it with `rabbitmq-plugins enable rabbitmq_recent_history_exchange`
* Use the Ruby-version that is noted in the file `.ruby-version`.
* To install the dependencies, run
    ```
    bundle
    ```
    in the repository directory.

# Configuration
Create a `config/settings.local.yml` with the local configuration.

The `hets.path` needs to point to the hets executable.

Each instance of the hets-agent in the system (even across machines) needs to have a distinct `agent.id` value.
The `agent.id` is used to create a queue that only this instance listens to.
This queue will receive the version requirement.
This `agent.id` can be overridden by setting the environment variable `HETS_AGENT_ID`.

The `backend.api_key` needs to be registered in the backend.
We recommend to have one API-key per hets-agent instance.

# Usage
Make sure to run `rails rabbitmq:send_hets_version` from the `ontohub-backend` repository before the first
start to set a version requirement.
* To start it in the development environment, run
    ```
    bundle exec bin/hets-agent
    ```
to listen for jobs in a development environment.
* For a production environment, set the environment variable `HETS_AGENT_ENV=production` additionally:
    ```
    HETS_AGENT_ENV=production bundle exec bin/hets-agent
    ```
