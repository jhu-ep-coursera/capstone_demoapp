#!/bin/bash

set -x 
rake db:create
rake db:migrate
rake
