# Capistrano::Crontab

[![Gem Version](https://badge.fury.io/rb/capistrano-crontab.svg)](https://badge.fury.io/rb/capistrano-crontab)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/KumukanGmbH/capistrano-crontab/master/LICENSE.txt)

This capistrano plugin is inspired by [fab_deploy.crontab](https://bitbucket.org/kmike/django-fab-deploy/src/9c07813e136bf3e059684b4205e0577973c157b4/fab_deploy/crontab.py?at=default&fileviewer=file-view-default)
and allows you to add, remove and update cronjobs in your crontab.

## Requirements

* capistrano >= 3.0
* sshkit >= 1.2

## Installation

Add this to your `Gemfile`:

```ruby
group :development do
  gem "capistrano"
  gem "capistrano-crontab"
end
```

And then:

```
$ bundle install
```

## Setup

Add this line to `Capfile`:

```ruby
require "capistrano/crontab"
```

## DSL usage

```ruby
on roles(:all) do

  # The temporary Crontab file is uploaded to the /tmp folder.
  # Not all users have permission to write to /tmp. You can
  # override the location.

  set :deploy_user, "deploy"
  set :tmp_dir, ->{ File.join('home', fetch(:deploy_user), 'tmp') }
  Capistrano::DSL::Crontab.tmp_dir(fetch(:tmp_dir))


  # output the content of your crontab using `puts`
  crontab_puts_content

  #
  # Crontab:
  #   30 7 * * * start -q anacron || :
  #

  # get the content of your crontab
  crontab = crontab_get_content

  #
  # Crontab:
  #   30 7 * * * start -q anacron || :
  #

  # add a new cronjob to your crontab and mark it with "date"
  crontab_add_line("*/5 * * * * date >> /tmp/date", "date")

  #
  # Crontab:
  #   30 7 * * * start -q anacron || :
  #   */5 * * * * data >> /tmp/date # MARKER:date
  #

  # update an existing cronjob in your crontab, which is marked with "date"
  crontab_update_line("*/2 * * * * date >> /tmp/date", "date")

  #
  # Crontab:
  #   30 7 * * * start -q anacron || :
  #   */2 * * * * date >> /tmp/date # MARKER:date
  #

  # ensure that a cronjob exists in your crontab, and mark it with "snapshot"
  crontab_update_line("0 * * * * create_snapshot", "snapshot")

  #
  # Crontab
  #   30 7 * * * start -q anacron || :
  #   */2 * * * * date >> /tmp/date # MARKER:date
  #   0 * * * * create_snapshot # MARKER:snapshot
  #

  # remove the cronjob, which is marked with "date"
  crontab_remove_line("date")

  #
  # Crontab:
  #   30 7 * * * start -q anacron || :
  #   0 * * * * create_snapshot # MARKER:snapshot
  #

  # overwrite the whole crontab
  crontab_set_content("* * 1 * * send_invoices_to_customers")

  #
  # Crontab:
  #   * * 1 * * send_invoices_to_customers
  #
end
```

## TODOs

* Update DSL to look more like `fab_deploy.crontab` (e.g. `crontab.add_line`)
* Add bulk line changes
