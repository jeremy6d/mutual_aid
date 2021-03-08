#!/bin/sh

DATE=`date +%Y-%m-%d-%s`
CONN=`heroku config:get DATABASE_URL --app rvamutualaid`
pg_dump $CONN > ./db/dumps/madrva_production_$DATE.sql
