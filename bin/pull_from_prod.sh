#!/bin/sh

bin/rails db:drop
heroku pg:pull postgresql-curved-56173 mutual_aid_dev --app rvamutualaid
bin/rails runner bin/make_dev_safe.rb
bin/rails db:create
