#!/bin/bash

/usr/local/bin/vnc.sh
set -x 
rake db:create
rake db:migrate
rspec spec/features --fail-fast
tail -f Gemfile
