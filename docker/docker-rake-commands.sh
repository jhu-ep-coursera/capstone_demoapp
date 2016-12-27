#!/bin/bash

/usr/local/bin/vnc.sh
set -x 
rake db:create
rake db:migrate
rake
