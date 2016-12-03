#!/bin/bash

set -x 
rake db:create
rake db:migrate
rspec spec/requests --fail-fast
